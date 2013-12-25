CREATE OR REPLACE PROCEDURE doc_rules (L_num              IN NUMBER,
                                       L_billing_choice   IN NUMBER)
AS
   P_error_code                    NUMBER;
   P_error_message                 VARCHAR2 (512);
   P_proc_name                     VARCHAR2 (32);
   P_code_area                     VARCHAR2 (32);

   /* Constants for Lab preparations
   */
   CONVENTIONAL           CONSTANT NUMBER := 1;
   THIN_LAYER             CONSTANT NUMBER := 2;
   CYT_NON_PAP            CONSTANT NUMBER := 4;
   HPV_ONLY               CONSTANT NUMBER := 5;
   SURGICAL               CONSTANT NUMBER := 6;
   IMAGED_SLIDE           CONSTANT NUMBER := 7;

   /* Constants for CPT codes
   */
   MANUAL_SCREEN          CONSTANT VARCHAR2 (8) := '88164';
   MANUAL_THREE_SLIDE     CONSTANT VARCHAR2 (8) := '88103';
   MANUAL_TWO_SLIDE       CONSTANT VARCHAR2 (8) := '88101';
   LIQUID_BASED           CONSTANT VARCHAR2 (8) := '88142';
   OTHER_SOURCE           CONSTANT VARCHAR2 (8) := '88160';
   AUTOMATED_SYS          CONSTANT VARCHAR2 (8) := '88175';
   LEVEL4_SURGICAL_PATH   CONSTANT VARCHAR2 (8) := '88305';
   LEVEL5_SURGICAL_PATH   CONSTANT VARCHAR2 (8) := '88307';
   PHYSICIAN_REQ          CONSTANT VARCHAR2 (8) := '88141';
   HPV_TEST               CONSTANT VARCHAR2 (8) := '87621';
   HORMONAL_EVAL          CONSTANT VARCHAR2 (8) := '88155';

   /* Constants for billing codes
   */
   DB                     CONSTANT NUMBER := 121;   /* bill goes to patient */
   DOC                    CONSTANT NUMBER := 122; /* bill goes to doc office */
   PPD                    CONSTANT NUMBER := 161; /* bill is prepaid by patient */
   PRC                    CONSTANT NUMBER := 127;  /* professional courtesy */

   /* Miscellaneous constants
   */
   BIOPSY_CONE            CONSTANT NUMBER := 62; /* the value for cone in pcs.detail_codes */

   L_practice                      NUMBER;
   L_price_code                    VARCHAR2 (2);
   L_item_cost                     NUMBER;
   L_rebilling                     NUMBER;
   L_num_slides                    NUMBER;
   L_cone_biopsy                   NUMBER;
   CPT_code                        CHAR (5);
   L_prep                          INTEGER;
   L_payer                         VARCHAR2 (32);
   H_date                          DATE;
   H_test_sent                     VARCHAR2 (2);

   rcnt                            NUMBER;
BEGIN
   P_proc_name := 'DOC_RULES';

   P_code_area := 'GET DECISION DATA';
dbms_output.put_line('DOC_RULES code area: '||P_code_area);
   SELECT practice, slide_qty, preparation
     INTO L_practice, L_num_slides, L_prep
     FROM pcs.lab_requisitions
    WHERE lab_number = L_num;

   SELECT price_code
     INTO L_price_code
     FROM pcs.practices
    WHERE practice = L_practice;

   SELECT MAX (rebilling)
     INTO L_rebilling
     FROM pcs.billing_details
    WHERE lab_number = L_num;

   L_payer := 'DOCTORACCOUNT' || RTRIM (LTRIM (TO_CHAR (L_practice, '009')));

   IF (L_prep = HPV_ONLY)
   THEN
      GOTO HPV_SECTION;
   END IF;

   /* Determine which CPT code to use based on the type
      of lab preparation. Note that for surgical biopsies
      addition info from the requisition is needed to
      determine which code to use.
   */
   P_code_area := 'GET CPT CODE';
	dbms_output.put_line('DOC_RULES code area: '||P_code_area);
   IF (L_prep = CONVENTIONAL)
   THEN
      IF (L_num_slides = 3)
      THEN
         CPT_code := MANUAL_THREE_SLIDE;
      ELSIF (L_num_slides = 2)
      THEN
         CPT_code := MANUAL_TWO_SLIDE;
      ELSE
         CPT_code := MANUAL_SCREEN;
      END IF;
   ELSIF (L_prep = THIN_LAYER)
   THEN
      CPT_code := LIQUID_BASED;
   ELSIF (L_prep = CYT_NON_PAP)
   THEN
      CPT_code := OTHER_SOURCE;
   ELSIF (L_prep = SURGICAL)
   THEN
      SELECT COUNT (*)
        INTO L_cone_biopsy
        FROM pcs.lab_req_details
       WHERE lab_number = L_num AND detail_code = BIOPSY_CONE;

      IF (L_cone_biopsy > 0)
      THEN
         CPT_code := LEVEL5_SURGICAL_PATH;
      ELSE
         CPT_code := LEVEL4_SURGICAL_PATH;
      END IF;
   ELSIF (L_prep = IMAGED_SLIDE)
   THEN
      CPT_code := AUTOMATED_SYS;
   END IF;

   /*
      Before insert into charges, check for special charges that would
      over-ride these ones; variable L_payer being not null indicates
      a check for this should be made. Note that by convention if
      there is an entry in the special_charges table for a doctor account
      the payer_id is DOCTORACCOUNTnnn where nnn is the three digit
      (zero padded) account number.
   */
   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.special_charges
    WHERE payer_id = L_payer AND procedure_code = CPT_code;

   IF (rcnt > 0)
   THEN
      SELECT special_charge
        INTO L_item_cost
        FROM pcs.special_charges
       WHERE payer_id = L_payer AND procedure_code = CPT_code;
   ELSE
      SELECT discount_price
        INTO L_item_cost
        FROM pcs.price_code_details p
       WHERE     PRICE_CODE = L_price_code
             AND procedure_code = CPT_code
             AND lab_number =
                    (SELECT MAX (lab_number)
                       FROM price_code_details
                      WHERE     lab_number <= L_num
                            AND price_code = L_price_code
                            AND procedure_code = CPT_code);
   END IF;

   /* The charges for a biopsy is the item cost multiplied
      by the number of vials that are submitted.  The number
      of vials are recorded under number of slides in reqs.
   */
   IF (L_prep = SURGICAL)
   THEN
      L_item_cost := L_item_cost * L_num_slides;
   END IF;

   INSERT INTO pcs.lab_billing_items (lab_number,
                                      price_code,
                                      procedure_code,
                                      item_amount,
                                      rebilling)
        VALUES (L_num,
                L_price_code,
                CPT_code,
                L_item_cost,
                L_rebilling);

   /* This is an add-on code to any other procedure that is included; it
      is a request for a definitive hormonal evaluation, results of which
      are stored in the table lab_mat_index.
   */
   P_code_area := 'MAT INDEX';
dbms_output.put_line('DOC_RULES code area: '||P_code_area);
   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.lab_mat_index
    WHERE lab_number = L_num;

   IF (rcnt > 0)
   THEN
      CPT_code := HORMONAL_EVAL;

      /*
         Check for special charges (see other comment for additional
         information).
      */
      SELECT COUNT (*)
        INTO rcnt
        FROM pcs.special_charges
       WHERE payer_id = L_payer AND procedure_code = CPT_code;

      IF (rcnt > 0)
      THEN
         SELECT special_charge
           INTO L_item_cost
           FROM pcs.special_charges
          WHERE payer_id = L_payer AND procedure_code = CPT_code;
      ELSE
         SELECT discount_price
           INTO L_item_cost
           FROM pcs.price_code_details p
          WHERE     PRICE_CODE = L_price_code
                AND procedure_code = CPT_code
                AND lab_number =
                       (SELECT MAX (lab_number)
                          FROM price_code_details
                         WHERE     lab_number <= L_num
                               AND price_code = L_price_code
                               AND procedure_code = CPT_code);
      END IF;

      INSERT INTO pcs.lab_billing_items (lab_number,
                                         price_code,
                                         procedure_code,
                                         item_amount,
                                         rebilling)
           VALUES (L_num,
                   L_price_code,
                   CPT_code,
                   L_item_cost,
                   L_rebilling);
   END IF;

   COMMIT;

  /*  This section determines if an HPV test was done, and adds
      the CPT code and charges for that. If it is an HPV only
      test, then this is the only charge that gets added on.
      If there was other testing AND HPV then all the charges
      are added to the lab.
  */
  <<HPV_SECTION>>
   P_code_area := 'HPV';
	dbms_output.put_line('DOC_RULES code area: '||P_code_area);
   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.hpv_requests
    WHERE lab_number = L_num AND test_sent IN ('Y', 'Q');

   IF (rcnt > 0)
   THEN
      SELECT datestamp, test_sent
        INTO H_date, H_test_sent
        FROM pcs.hpv_requests
       WHERE lab_number = L_num;

      IF (H_date IS NOT NULL)
      THEN
         CPT_code := HPV_TEST;
	     dbms_output.put_line('Looking for special charges');
         /*
            Check for special charges (see other comment for additional
            information.
         */
         SELECT COUNT (*)
           INTO rcnt
           FROM pcs.special_charges
          WHERE payer_id = L_payer AND procedure_code = CPT_code;

         IF (rcnt > 0)
         THEN
            SELECT special_charge
              INTO L_item_cost
              FROM pcs.special_charges
             WHERE payer_id = L_payer AND procedure_code = CPT_code;
		 ELSE
		    dbms_output.put_line('Looking for item cost');
            SELECT discount_price
              INTO L_item_cost
              FROM pcs.price_code_details p
             WHERE     PRICE_CODE = L_price_code
                   AND procedure_code = CPT_code
                   AND lab_number =
                          (SELECT MAX (lab_number)
                             FROM price_code_details
                            WHERE     lab_number <= L_num
                                  AND price_code = L_price_code
                                  AND procedure_code = CPT_code);
         END IF;

         /*
            If the results of the HPV test were 'Quantity Not Sufficient',
            this value is stored in hpv_requests.test_sent and not in the
            field hpv_requests.test_results; for this result there is
            no charge.
         */
         IF (H_test_sent = 'Q')
         THEN
            L_item_cost := 0;
         END IF;
		dbms_output.put_line('Inserting into lab_billing_items'||CPT_code);
         INSERT INTO pcs.lab_billing_items (lab_number,
                                            price_code,
                                            procedure_code,
                                            item_amount,
                                            rebilling)
              VALUES (L_num,
                      L_price_code,
                      CPT_code,
                      L_item_cost,
                      L_rebilling);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      P_error_code := SQLCODE;
      P_error_message := SQLERRM;
	  dbms_output.put_line('Error: '||P_error_message);
      INSERT INTO pcs.error_log (ERROR_CODE,
                                 error_message,
                                 proc_name,
                                 code_area,
                                 datestamp,
                                 sys_user,
                                 ref_id)
           VALUES (P_error_code,
                   P_error_message,
                   P_proc_name,
                   P_code_area,
                   SYSDATE,
                   UID,
                   L_num);

      COMMIT;
      RAISE;
END;
\
