CREATE OR REPLACE PROCEDURE default_rules (L_num              IN NUMBER,
                                           L_billing_choice   IN NUMBER)
AS
   P_error_code                        NUMBER;
   P_error_message                     VARCHAR2 (512);
   P_proc_name                         VARCHAR2 (32);
   P_code_area                         VARCHAR2 (32);

   /* Constants for Lab preparations

   */
   CONVENTIONAL               CONSTANT NUMBER := 1;
   THIN_LAYER                 CONSTANT NUMBER := 2;
   CYT_NON_PAP                CONSTANT NUMBER := 4;
   HPV_ONLY                   CONSTANT NUMBER := 5;
   SURGICAL                   CONSTANT NUMBER := 6;
   IMAGED_SLIDE               CONSTANT NUMBER := 7;

   /* Constants for CPT codes
   */
   MANUAL_SCREEN              CONSTANT VARCHAR2 (8) := '88164';
   MANUAL_SCREEN_MED          CONSTANT VARCHAR2 (8) := 'P3000';
   MANUAL_SCREEN_OTHER        CONSTANT VARCHAR2 (8) := '88150';

   LIQUID_BASED               CONSTANT VARCHAR2 (8) := '88142';
   LIQUID_BASED_MED           CONSTANT VARCHAR2 (8) := 'G0123';
   OTHER_SOURCE               CONSTANT VARCHAR2 (8) := '88160';
   AUTOMATED_SYS              CONSTANT VARCHAR2 (8) := '88175';
   AUTOMATED_SYS_MED          CONSTANT VARCHAR2 (8) := 'G0145';
   LEVEL4_SURGICAL_PATH       CONSTANT VARCHAR2 (8) := '88305';
   LEVEL5_SURGICAL_PATH       CONSTANT VARCHAR2 (8) := '88307';
   PHYSICIAN_REQ              CONSTANT VARCHAR2 (8) := '88141';
   PHYSICIAN_REQ_MANUAL_MED   CONSTANT VARCHAR2 (8) := 'P3001';
   PHYSICIAN_REQ_LIQUID_MED   CONSTANT VARCHAR2 (8) := 'G0124';
   HPV_TEST                   CONSTANT VARCHAR2 (8) := '87621';
   HORMONAL_EVAL              CONSTANT VARCHAR2 (8) := '88155';


   /* Constants for billing codes
   */
   DB                         CONSTANT NUMBER := 121; /* bill goes to patient */
   DOC                        CONSTANT NUMBER := 122; /* bill goes to doc office */
   PPD                        CONSTANT NUMBER := 161; /* bill is prepaid by patient */
   PRC                        CONSTANT NUMBER := 127; /* professional courtesy */

   /* Miscellaneous constants
   */
   BIOPSY_CONE                CONSTANT NUMBER := 62; /* the value for cone in pcs.detail_codes */
   WV_DPA                     CONSTANT NUMBER := 1047; /* primary key for West Virginia med asst */
   CYTOTECH                   CONSTANT INTEGER := 0;
   PATHOLOGIST                CONSTANT INTEGER := 1;


   L_practice                          NUMBER;
   L_price_code                        VARCHAR2 (2);
   L_item_cost                         NUMBER;
   L_rebilling                         NUMBER;
   L_prep                              NUMBER;
   CPT_code                            CHAR (5);
   L_path_status                       CHAR (1);
   L_qc_status                         CHAR (1);
   L_num_vials                         NUMBER;
   L_cone_biopsy                       NUMBER;
   screening_level                     INTEGER;
   L_carrier                           NUMBER;

   L_payer                             VARCHAR2 (32);
   H_date                              DATE;
   H_test_sent                         VARCHAR2 (2);
   rcnt                                INTEGER;
BEGIN
   P_proc_name := 'DEFAULT_RULES';

   SELECT practice, preparation, slide_qty
     INTO L_practice, L_prep, L_num_vials
     FROM pcs.lab_requisitions
    WHERE lab_number = L_num;

   SELECT path_status, qc_status
     INTO L_path_status, L_qc_status
     FROM pcs.lab_results
    WHERE lab_number = L_num;

   SELECT price_code
     INTO L_price_code
     FROM pcs.practices
    WHERE practice = L_practice;

   SELECT MAX (rebilling)
     INTO L_rebilling
     FROM pcs.billing_details
    WHERE lab_number = L_num;

   SELECT carrier_id
     INTO L_carrier
     FROM pcs.billing_details
    WHERE lab_number = L_num AND rebilling = L_rebilling;

   IF (L_prep = HPV_ONLY)
   THEN
      GOTO HPV_SECTION;
   END IF;

    /* This block of code determines whether there will be patholoigst

charges included with the billing. The variable screening_level
will be 1 if there should be pathologist charges; 0 otherwise.
    */
   P_code_area := 'PATH SCREENING';
   screening_level := CYTOTECH;

   IF (L_path_status = 'Y')
   THEN
      screening_level := PATHOLOGIST;

      SELECT COUNT (*)
        INTO rcnt
        FROM pcs.pathologist_control_codes
       WHERE bethesda_code IN ('012', '010') AND lab_number = L_num;

      IF (rcnt < 1)
      THEN
         screening_level := CYTOTECH;
      END IF;

      SELECT COUNT (*)
        INTO rcnt
        FROM pcs.pathologist_control_codes
       WHERE bethesda_code = '13R' AND lab_number = L_num;

      IF (rcnt > 0)
      THEN
         SELECT COUNT (*)
           INTO rcnt
           FROM pcs.pathologist_control_codes
          WHERE bethesda_code = '040' AND lab_number = L_num;

         IF (rcnt > 0)
         THEN
            screening_level := CYTOTECH;
         ELSE
            screening_level := PATHOLOGIST;
         END IF;
      END IF;

      IF (screening_level <> PATHOLOGIST)
      THEN
         IF (L_qc_status = 'Y')
         THEN
            screening_level := PATHOLOGIST;

            SELECT COUNT (*)
              INTO rcnt
              FROM pcs.quality_control_codes
             WHERE bethesda_code IN ('012', '010') AND lab_number = L_num;

            IF (rcnt < 1)
            THEN
               screening_level := CYTOTECH;
            END IF;

            SELECT COUNT (*)
              INTO rcnt
              FROM pcs.quality_control_codes
             WHERE bethesda_code = '13R' AND lab_number = L_num;

            IF (rcnt > 0)
            THEN
               SELECT COUNT (*)
                 INTO rcnt
                 FROM pcs.quality_control_codes
                WHERE bethesda_code = '040' AND lab_number = L_num;

               IF (rcnt > 0)
               THEN
                  screening_level := CYTOTECH;
               ELSE
                  screening_level := PATHOLOGIST;
               END IF;
            END IF;
         END IF;
      END IF;

      IF (screening_level <> PATHOLOGIST)
      THEN
         screening_level := PATHOLOGIST;

         SELECT COUNT (*)
           INTO rcnt
           FROM pcs.lab_result_codes
          WHERE bethesda_code IN ('012', '010') AND lab_number = L_num;

         IF (rcnt < 1)
         THEN
            screening_level := CYTOTECH;
         END IF;

         SELECT COUNT (*)
           INTO rcnt
           FROM pcs.lab_result_codes
          WHERE bethesda_code = '13R' AND lab_number = L_num;

         IF (rcnt > 0)
         THEN
            SELECT COUNT (*)
              INTO rcnt
              FROM pcs.lab_result_codes
             WHERE bethesda_code = '040' AND lab_number = L_num;

            IF (rcnt > 0)
            THEN
               screening_level := CYTOTECH;
            ELSE
               screening_level := PATHOLOGIST;
            END IF;
         END IF;
      END IF;
   END IF;


    /* Determine which CPT code to use based on the type
of lab preparation; note that for a surgical biopsy
additional info from the requisition is needed to
determine which code to use. Note that for conventional
preparation specific carrier WV medical assistance
uses a different CPT code.
    */
   P_code_area := 'GET CHARGES';

   IF (L_prep = CONVENTIONAL)
   THEN
      IF (L_carrier = WV_DPA)
      THEN
         CPT_code := MANUAL_SCREEN_OTHER;
      ELSE
         CPT_code := MANUAL_SCREEN;
      END IF;
   ELSIF (L_prep = THIN_LAYER)
   THEN
      CPT_code := LIQUID_BASED;
   ELSIF (L_prep = CYT_NON_PAP)
   THEN
      CPT_code := OTHER_SOURCE;
   ELSIF (L_prep = IMAGED_SLIDE)
   THEN
      CPT_code := AUTOMATED_SYS;
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
   END IF;

   DBMS_OUTPUT.put_line (
         '0.  Price code:'
      || L_price_code
      || ' and CPT_code: '
      || CPT_code
      || ' and lab num: '
      || L_num);

   SELECT base_price
     INTO L_item_cost
     FROM pcs.price_code_details p
    WHERE     PRICE_CODE = L_price_code
          AND procedure_code = CPT_code
          AND lab_number =
                 (SELECT MAX (lab_number)
                    FROM price_code_details
                   WHERE     lab_number <= L_num
                         AND PRICE_CODE = L_price_code
                         AND procedure_code = CPT_code);


    /* Before insert into charges, check for special charges that would
over-ride these ones; variable L_payer being not null indicates
a check for this should be made. Also, if this is patient billing,
i.e. DB, and there was a prior billing, then the patient cost

is the special charge if it exists.
    */
   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.carriers
    WHERE carrier_id = L_carrier;

   L_payer := NULL;

   IF (rcnt > 0)
   THEN
      SELECT payer_id
        INTO L_payer
        FROM pcs.carriers
       WHERE carrier_id = L_carrier;
   END IF;

   IF (L_rebilling > 0 AND L_billing_choice = DB)
   THEN
      SELECT carrier_id
        INTO rcnt
        FROM pcs.billing_details
       WHERE lab_number = L_num AND rebilling = L_rebilling - 1;

      IF (rcnt > 0)
      THEN
         SELECT payer_id
           INTO L_payer
           FROM pcs.carriers
          WHERE carrier_id = rcnt;
      END IF;
   END IF;

   IF (L_payer IS NOT NULL)
   THEN
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
      END IF;
   END IF;

    /* If a surgical biopsy was performed, then the charges are
multiplied by the number of vials; the value for the number

of vials is stored in lab_requisitions.slide_qty.
    */
   IF (L_prep = SURGICAL)
   THEN
      L_item_cost := L_item_cost * L_num_vials;
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

    /* If during regular screening it was determined that the results require
that physician screening be performed, then an addional charge is

added. Note that a screening level of PATHOLOGIST assumes that the lab
preparation was not SURGICAL or HPV_ONLY.
    */
   P_code_area := 'PATH CHARGES';

   IF (screening_level = PATHOLOGIST)
   THEN
      CPT_code := PHYSICIAN_REQ;
      DBMS_OUTPUT.put_line (
            '1.  Price code:'
         || L_price_code
         || ' and CPT_code: '
         || CPT_code
         || ' and lab num: '
         || L_num);

      SELECT base_price
        INTO L_item_cost
        FROM pcs.price_code_details p
       WHERE     PRICE_CODE = L_price_code
             AND procedure_code = CPT_code
             AND lab_number =
                    (SELECT MAX (lab_number)
                       FROM price_code_details
                      WHERE     lab_number <= L_num
                            AND PRICE_CODE = L_price_code
                            AND procedure_code = CPT_code);

      /*
         Before insert into charges, check for special charges that would
         over-ride these ones; variable L_payer being not null indicates
         a check for this should be made. Also, if this is patient billing,
         i.e. DB, and there was a prior billing, then the patient cost

         is the special charge if it exists.
      */
      IF (L_payer IS NOT NULL)
      THEN
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
         END IF;
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

    /* This is an add-on code to any other procedure that is included; it
is a request for a definitive hormonal evaluation, results of which
are stored in the table lab_mat_index.
    */
   P_code_area := 'MAT INDEX';

   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.lab_mat_index
    WHERE lab_number = L_num;

   IF (rcnt > 0)
   THEN
      CPT_code := HORMONAL_EVAL;
      DBMS_OUTPUT.put_line (
            '2.  Price code:'
         || L_price_code
         || ' and CPT_code: '
         || CPT_code
         || ' and lab num: '
         || L_num);

      SELECT base_price
        INTO L_item_cost
        FROM pcs.price_code_details p
       WHERE     PRICE_CODE = L_price_code
             AND procedure_code = CPT_code
             AND lab_number =
                    (SELECT MAX (lab_number)
                       FROM price_code_details
                      WHERE     lab_number <= L_num
                            AND PRICE_CODE = L_price_code
                            AND procedure_code = CPT_code);

      /*
         Check for special charges (see other comment for additional
         information).
      */
      IF (L_payer IS NOT NULL)
      THEN
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
         END IF;
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
         DBMS_OUTPUT.put_line (
               '3.  Price code:'
            || L_price_code
            || ' and CPT_code: '
            || CPT_code
            || ' and lab num: '
            || L_num);

         SELECT base_price
           INTO L_item_cost
           FROM pcs.price_code_details p
          WHERE     PRICE_CODE = L_price_code
                AND procedure_code = CPT_code
                AND lab_number = (SELECT MAX (lab_number)
                                    FROM price_code_details
                                   WHERE lab_number <= L_num
								   and PRICE_CODE = L_price_code
                				   AND procedure_code = CPT_code);

         /*
            Check for special charges (see other comment for additional               information).
         */
         IF (L_payer IS NOT NULL)
         THEN
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
            END IF;
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


    /* If the type of billing does not fall into one of these types,
which basically amounts to an OI billing, then this procedure
must be ran. The diagnosis_update checks each test result code
of the screening against the cross-reference table beth_icd9_xref;
and if there is a match, then the corresponding diganosis code
must be added to the lab. This increases the probability that
the carrier is going to pay for the testing.
    */
   IF (L_billing_choice NOT IN (DB, DOC, PPD, PRC))
   THEN
      pcs.diagnosis_update (L_num);
   END IF;
exception
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_num);
      commit;
      RAISE;

END;
\
