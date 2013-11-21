/* 02/17/13: Two carriers that are OI have to have BS rules implemented;
   made this change by adding constants, new variable L_carrier, change to
   an SQL statement and an update in the OI block
 */

CREATE OR REPLACE PROCEDURE calculate_cost (L_num IN NUMBER)
AS
   P_error_code               NUMBER;
   P_error_message            VARCHAR2 (512);
   P_proc_name                VARCHAR2 (32);
   P_code_area                VARCHAR2 (32);

   /* Constants for billing codes   */

   DB                CONSTANT NUMBER := 121;        /* bill goes to patient */
   DOC               CONSTANT NUMBER := 122;     /* bill goes to doc office */
   DPA               CONSTANT NUMBER := 123;                    /* Medicaid */
   BS                CONSTANT NUMBER := 124;      /* Blue Cross Blue Shield */
   MED               CONSTANT NUMBER := 125;                    /* Medicare */
   OI                CONSTANT NUMBER := 126;    /* Other insurance carriers */
   PRC               CONSTANT NUMBER := 127; /* Professional courtesy, no charge */
   PPD               CONSTANT NUMBER := 161;  /* bill is prepaid by patient */

   HIGHMARK_WV       CONSTANT NUMBER := 29476; /* carrier_id for WV Highmark BCBS */
   CAPITAL_BC        CONSTANT NUMBER := 18496; /* carrier_id for Capital Blue Cross */

   /* Constants for finished status
   */
   RESULTS_PENDING   CONSTANT NUMBER := 0;
   BILLING_QUEUE     CONSTANT NUMBER := 1;

   SUBMITTED         CONSTANT NUMBER := 2;
   PENDING           CONSTANT NUMBER := 3;
   FINALIZED         CONSTANT NUMBER := 4;

   /* Misc. constants   */
   MAT_INDEX         CONSTANT NUMBER := 12;
   HPV_ONLY          CONSTANT NUMBER := 5;

   L_billing_choice           NUMBER;
   L_finished                 NUMBER;
   L_preparation              NUMBER;
   L_rebilling                NUMBER;

   L_total                    NUMBER;
   L_balance                  NUMBER;
   L_allow                    NUMBER;
   L_line_items               NUMBER;
   L_other_fees               NUMBER;
   L_payments                 NUMBER;
   L_tpp                      CHAR (3);
   L_rebill_code              VARCHAR2 (5);
   L_medicare_code            CHAR (1);
   L_pap_class                NUMBER;
   L_practice                 NUMBER;
   L_ptype                    VARCHAR2 (32);
   L_carrier                  NUMBER;
   rcnt                       NUMBER;

   NoDataExists               EXCEPTION;
   PRAGMA EXCEPTION_INIT (NoDataExists, 100);
BEGIN
   P_proc_name := 'CALCULATE_COST';
   P_code_area := 'PREP';

   /* If there are pending HPV results, then charges  cannot be calculated at this time; go to the  termination point of the procedure, and exit.      */
   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.hpv_requests
    WHERE     lab_number = L_num
          AND (test_sent IS NULL OR test_sent IN ('R', 'P'));

   IF (rcnt > 0)
   THEN
      GOTO exit_point;
   END IF;

   /* Remove the lab from the billing queue if it is there; the procedure will put it back if applicable. Retrieve the data elements needed to calculate the charges.      */
   DELETE FROM pcs.billing_queue
         WHERE lab_number = L_num;

   SELECT MAX (rebilling)
     INTO L_rebilling
     FROM pcs.billing_details
    WHERE lab_number = L_num;


   SELECT billing_choice,
          rebill_code,
          medicare_code,
          carrier_id
     INTO L_billing_choice,
          L_rebill_code,
          L_medicare_code,
          L_carrier
     FROM pcs.billing_details
    WHERE lab_number = L_num AND rebilling = L_rebilling;

   SELECT finished, preparation
     INTO L_finished, L_preparation
     FROM pcs.lab_requisitions
    WHERE lab_number = L_num;

   P_code_area := 'BILLING LOGIC';

   DELETE FROM pcs.lab_billing_items
         WHERE lab_number = L_num;

   IF (L_billing_choice <> PRC)
   THEN
      IF (L_finished = FINALIZED)
      THEN
         UPDATE pcs.lab_requisitions
            SET finished = PENDING
          WHERE lab_number = L_num;
      END IF;

      /*
         detail code 12 is request maturation index; if the count is
         zero, then run a delete to take care of the case that the
         lab was updated and there was previously a mat. index
      */
      SELECT COUNT (*)
        INTO rcnt
        FROM pcs.lab_req_details
       WHERE lab_number = L_num AND detail_code = MAT_INDEX;

      IF (rcnt = 0)
      THEN
         DELETE FROM pcs.lab_mat_index
               WHERE lab_number = L_num;
      END IF;

      COMMIT;
      COMMIT;

      SELECT a.practice, a.practice_type
        INTO L_practice, L_ptype
        FROM pcs.practices a, pcs.lab_requisitions b
       WHERE a.practice = b.practice AND b.lab_number = L_num;

      IF (L_billing_choice = BS)
      THEN
         P_code_area := 'BS';
         pcs.pbs_rules (L_num, L_billing_choice);

         SELECT NVL (MIN (a.tpp), 'PPR')
           INTO L_tpp
           FROM pcs.carriers a, pcs.billing_details b
          WHERE     a.carrier_id = b.carrier_id
                AND b.lab_number = L_num
                AND b.rebilling = L_rebilling;

         INSERT INTO pcs.billing_queue (lab_number,
                                        billing_route,
                                        billing_type,
                                        rebilling,
                                        rebill_code,
                                        datestamp)
              VALUES (L_num,
                      L_tpp,
                      NULL,
                      L_rebilling,
                      L_rebill_code,
                      SYSDATE);
      ELSIF (L_billing_choice = MED)
      THEN
         P_code_area := 'MED';
         pcs.med_rules (L_num, L_billing_choice);

         SELECT pap_class
           INTO L_pap_class
           FROM pcs.lab_results
          WHERE lab_number = L_num;

         SELECT NVL (MIN (a.tpp), 'PPR')
           INTO L_tpp
           FROM pcs.carriers a, pcs.billing_details b
          WHERE     a.carrier_id = b.carrier_id
                AND b.lab_number = L_num
                AND b.rebilling = L_rebilling;

         INSERT INTO pcs.billing_queue (lab_number,
                                        billing_route,
                                        billing_type,
                                        rebilling,
                                        rebill_code,
                                        datestamp)
              VALUES (L_num,
                      L_tpp,
                      NULL,
                      L_rebilling,
                      L_rebill_code,
                      SYSDATE);
      ELSIF (L_billing_choice = DOC)
      THEN
         P_code_area := 'DOC';
         pcs.doc_rules (L_num, L_billing_choice);

         INSERT INTO pcs.billing_queue (lab_number,
                                        billing_route,
                                        billing_type,
                                        rebilling,
                                        rebill_code,
                                        datestamp)
              VALUES (L_num,
                      'PRA',
                      NULL,
                      L_rebilling,
                      L_rebill_code,
                      SYSDATE);
      ELSIF (L_billing_choice = DB)
      THEN
         P_code_area := 'DB';
         rcnt := 0;

         IF (L_ptype = 'WV')
         THEN
            SELECT COUNT (*)
              INTO rcnt
              FROM pcs.prepaid_labs
             WHERE lab_number = L_num;
         END IF;

         IF (rcnt = 1)
         THEN
            pcs.doc_rules (L_num, L_billing_choice);
         ELSE
            pcs.default_rules (L_num, L_billing_choice);
         END IF;

         INSERT INTO pcs.billing_queue (lab_number,
                                        billing_route,
                                        billing_type,
                                        rebilling,
                                        rebill_code,
                                        datestamp)
              VALUES (L_num,
                      'PAT',
                      'DB00',
                      L_rebilling,
                      L_rebill_code,
                      SYSDATE);
      ELSIF (L_billing_choice = OI)
      THEN
         P_code_area := 'OI';

         IF (L_carrier IN (HIGHMARK_WV, CAPITAL_BC))
         THEN
            pcs.pbs_rules (L_num, L_billing_choice);
         ELSE
            pcs.default_rules (L_num, L_billing_choice);
         END IF;

         SELECT NVL (MIN (a.tpp), 'PPR')
           INTO L_tpp
           FROM pcs.carriers a, pcs.billing_details b
          WHERE     a.carrier_id = b.carrier_id
                AND b.lab_number = L_num
                AND b.rebilling = L_rebilling;

         INSERT INTO pcs.billing_queue (lab_number,
                                        billing_route,
                                        billing_type,
                                        rebilling,
                                        rebill_code,
                                        datestamp)
              VALUES (L_num,
                      L_tpp,
                      NULL,
                      L_rebilling,
                      L_rebill_code,
                      SYSDATE);
      ELSIF (L_billing_choice = DPA)
      THEN
         P_code_area := 'DPA';
         pcs.default_rules (L_num, L_billing_choice);

         SELECT NVL (MIN (a.tpp), 'PPR')
           INTO L_tpp
           FROM pcs.carriers a, pcs.billing_details b
          WHERE     a.carrier_id = b.carrier_id
                AND b.lab_number = L_num
                AND b.rebilling = L_rebilling;

         INSERT INTO pcs.billing_queue (lab_number,
                                        billing_route,
                                        billing_type,
                                        rebilling,
                                        rebill_code,
                                        datestamp)
              VALUES (L_num,
                      L_tpp,
                      NULL,
                      L_rebilling,
                      L_rebill_code,
                      SYSDATE);
      ELSIF (L_billing_choice = PPD)
      THEN
         IF (L_ptype = 'WV')
         THEN
            pcs.doc_rules (L_num, L_billing_choice);
         ELSE
            pcs.default_rules (L_num, L_billing_choice);
         END IF;
      END IF;
   ELSE
      P_code_area := 'PRC';
      pcs.default_rules (L_num, L_billing_choice);

      UPDATE pcs.lab_billing_items
         SET item_amount = 0
       WHERE lab_number = L_num AND rebilling = L_rebilling;

      UPDATE pcs.lab_requisitions
         SET finished = FINALIZED
       WHERE lab_number = L_num;

      COMMIT;
   END IF;

    /* Get the total of all line items that have
been added by the rules procedure.

    */
   SELECT NVL (SUM (item_amount), 0)
     INTO L_line_items
     FROM pcs.lab_billing_items
    WHERE lab_number = L_num;

    /*
Get the total of any plus adjustments that have
been made; this is added to the bill amount.
    */
   SELECT NVL (SUM (payment_amount), 0)
     INTO L_other_fees
     FROM pcs.payments
    WHERE lab_number = L_num AND payment_type = 'PLUS ADJUST';

   L_total := L_line_items + L_other_fees;

    /*
If an allowance has been set by an insurance carrier,
then the allowance takes precedence over the amount
of total charges in figuring the current balance.
    */
   SELECT NVL (SUM (allowance), 0)
     INTO L_allow
     FROM pcs.lab_billings
    WHERE lab_number = L_num;

    /*
Get the total of any payments that have been made;
this will include any minus adjustments that have
been made also.
    */

   SELECT NVL (SUM (payment_amount), 0)
     INTO L_payments
     FROM pcs.payments
    WHERE lab_number = L_num AND payment_type <> 'PLUS ADJUST';

   IF (L_allow > 0)
   THEN
      L_balance := (L_allow + L_other_fees) - L_payments;
   ELSE
      L_balance := L_total - L_payments;
   END IF;

   IF (L_billing_choice = PPD)
   THEN
      P_code_area := 'PPD';

      UPDATE pcs.billing_details
         SET date_sent = SYSDATE
       WHERE lab_number = L_num AND billing_choice = L_billing_choice;

      IF (L_balance <= 0)
      THEN
         UPDATE pcs.lab_requisitions
            SET finished = FINALIZED
          WHERE lab_number = L_num;
      ELSE
         UPDATE pcs.lab_requisitions
            SET finished = PENDING
          WHERE lab_number = L_num;
      END IF;
   ELSIF (L_billing_choice = PRC)
   THEN
      P_code_area := 'PRC';
      L_total := 0;

      UPDATE pcs.billing_details
         SET date_sent = SYSDATE
       WHERE     lab_number = L_num
             AND billing_choice = L_billing_choice
             AND rebilling = L_rebilling;
   END IF;

   P_code_area := 'END DETAILS';

   IF (L_billing_choice = MED)
   THEN
      /*
         Cannot bill Medicare for any Unsats
      */
      IF (L_pap_class = 1)
      THEN
         UPDATE pcs.lab_requisitions
            SET finished = FINALIZED
          WHERE lab_number = L_num;

         DELETE FROM pcs.fax_letters
               WHERE lab_number = L_num;

         DELETE FROM pcs.billing_queue
               WHERE lab_number = L_num AND rebilling = L_rebilling;

         COMMIT;
      END IF;
   END IF;

   P_code_area := 'FX CNT';

   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.fax_letters
    WHERE lab_number = L_num;

   IF (rcnt > 0)
   THEN
      DELETE FROM pcs.billing_queue
            WHERE lab_number = L_num AND rebilling = L_rebilling;
   ELSE
      P_code_area := 'LB CNT';

      SELECT COUNT (*)
        INTO rcnt
        FROM pcs.lab_billings
       WHERE lab_number = L_num;

      P_code_area := 'LB CNT==' || TO_CHAR (rcnt);

      IF (rcnt = 0)
      THEN
         P_code_area := 'INS LB';

         INSERT INTO pcs.lab_billings (billing_choice,
                                       lab_number,
                                       bill_amount,
                                       rebilling,
                                       balance,
                                       date_posted,
                                       date_paid)
              VALUES (L_billing_choice,
                      L_num,
                      L_total,
                      L_rebilling,
                      L_balance,
                      SYSDATE,
                      SYSDATE);
      ELSE
         P_code_area := 'UPD LB ';

         UPDATE pcs.lab_billings
            SET billing_choice = L_billing_choice,
                bill_amount = L_total,
                rebilling = L_rebilling,
                balance = L_balance,
                date_posted = SYSDATE,
                date_paid = SYSDATE
          WHERE lab_number = L_num;

         P_code_area := 'UPD LB OK';
      END IF;
   END IF;

   P_code_area := 'CC FINISH';

   IF (L_billing_choice = PRC)
   THEN
      DELETE FROM pcs.billing_queue
            WHERE lab_number = L_num AND rebilling = L_rebilling;
   END IF;

    /* If the finished status is zero (results pending), then set the status
to one (either in billing queue, or has pending fax letter. If the
preparation is an HPV only with a QNS result, then set the total charges
and balance due to zero, and set the finished status to four (finalized).
    */
  <<exit_point>>
   P_code_area := 'UPD LAB_REQUISITIONS';

   UPDATE pcs.lab_requisitions
      SET finished = BILLING_QUEUE
    WHERE finished = RESULTS_PENDING AND lab_number = L_num;

   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.hpv_requests
    WHERE lab_number = L_num AND test_sent = 'Q';

   IF (rcnt > 0 AND L_preparation = HPV_ONLY)
   THEN
      DELETE FROM pcs.billing_queue
            WHERE lab_number = L_num AND rebilling = L_rebilling;

      UPDATE pcs.lab_billings
         SET bill_amount = 0,
             balance = 0,
             date_posted = SYSDATE,
             date_paid = SYSDATE
       WHERE lab_number = L_num;

      UPDATE pcs.lab_requisitions
         SET finished = 4
       WHERE lab_number = L_num;
   END IF;

   COMMIT;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      DBMS_OUTPUT.put_line ('No Data found ');
   WHEN OTHERS
   THEN
      P_error_code := SQLCODE;
      P_error_message := SQLERRM;

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
