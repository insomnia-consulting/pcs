CREATE OR REPLACE PROCEDURE practices_eom (S_month IN NUMBER)
AS
   P_error_code         NUMBER;
   P_error_message      VARCHAR2 (512);
   P_proc_name          VARCHAR2 (32);
   P_code_area          VARCHAR2 (32);

   P_billing_choice     NUMBER;
   S_id                 NUMBER;


   CURSOR insert_doc
   IS
      SELECT S_month,
             bq.lab_number,
             li.item_amount,
             'DOC',
             lq.practice,
             RTRIM (p.lname) || ', ' || RTRIM (p.fname),
             r.datestamp,
             li.procedure_code,
             pc.description,
             pc.p_seq,
             lq.date_collected,
             2,
             lq.slide_qty
        FROM pcs.billing_queue bq,
             pcs.lab_requisitions lq,
             pcs.lab_billing_items li,
             pcs.patients p,
             pcs.lab_results r,
             pcs.procedure_codes pc,
             pcs.practices pr
       WHERE     bq.lab_number = lq.lab_number
             AND lq.practice = pr.practice
             AND lq.lab_number = li.lab_number
             AND lq.lab_number = r.lab_number
             AND lq.patient = p.patient
             AND li.procedure_code = pc.procedure_code
             AND bq.billing_route = 'PRA';

   CURSOR insert_non_doc
   IS
      SELECT S_month,
             lq.lab_number,
             0,
             bc.choice_code,
             lq.practice,
             RTRIM (p.lname) || ', ' || RTRIM (p.fname),
             r.datestamp,
             li.procedure_code,
             pc.description,
             pc.p_seq,
             lq.date_collected,
             2,
             lq.slide_qty
        FROM pcs.billing_choices bc,
             pcs.lab_requisitions lq,
             pcs.lab_billing_items li,
             pcs.patients p,
             pcs.lab_results r,
             pcs.procedure_codes pc,
             pcs.practices pr
       WHERE     lq.lab_number = r.lab_number
             AND r.lab_number = li.lab_number
             AND lq.patient = p.patient
             AND lq.practice = pr.practice
             AND lq.billing_choice = bc.billing_choice
             AND li.procedure_code = pc.procedure_code
             AND TO_NUMBER (TO_CHAR (r.datestamp, 'YYYYMM')) = S_month
             AND lq.billing_choice <> 122;

   INV_ym               NUMBER;
   INV_lab              NUMBER;
   INV_amount           NUMBER;
   INV_code             VARCHAR2 (3);
   INV_practice         NUMBER;
   INV_patient          VARCHAR2 (64);
   INV_result_entered   DATE;
   INV_procedure        VARCHAR2 (5);
   INV_description      VARCHAR2 (64);

   INV_seq              NUMBER;
   INV_collected        DATE;
   INV_cycle            NUMBER;

   PRIOR_statement      NUMBER;
   PRIOR_cycle          NUMBER;
   PRIOR_billing        VARCHAR2 (3);

   in_items             NUMBER;
   in_invoice           NUMBER;
   num_vials            NUMBER;
BEGIN
   P_proc_name := 'PRACTICES_EOM';
   P_code_area := 'PREP';

   SELECT billing_choice
     INTO P_billing_choice
     FROM pcs.billing_choices
    WHERE choice_code = 'DOC';

   P_code_area := 'OPEN DOC CURSOR';

   OPEN insert_doc;

   LOOP
      FETCH insert_doc
         INTO INV_ym,
              INV_lab,
              INV_amount,
              INV_code,
              INV_practice,
              INV_patient,
              INV_result_entered,
              INV_procedure,
              INV_description,
              INV_seq,
              INV_collected,
              INV_cycle,
              num_vials;

      EXIT WHEN insert_doc%NOTFOUND;

      SELECT COUNT (*)
        INTO in_items
        FROM pcs.lab_billing_items
       WHERE lab_number = INV_lab AND procedure_code = INV_procedure;

      SELECT COUNT (*)
        INTO in_invoice
        FROM pcs.practice_statement_labs
       WHERE     lab_number = INV_lab
             AND procedure_code = INV_procedure
             AND practice = INV_practice;

      IF (INV_procedure = '88305' AND num_vials > 1)
      THEN
         INV_description :=
               INV_description
            || ' ['
            || RTRIM (LTRIM (TO_CHAR (num_vials)))
            || ']';
      END IF;

      IF (in_items > in_invoice)
      THEN
         INSERT INTO pcs.practice_statement_labs (statement_id,
                                                  lab_number,
                                                  item_amount,
                                                  choice_code,
                                                  practice,
                                                  patient_name,
                                                  date_results_entered,
                                                  procedure_code,
                                                  code_description,
                                                  p_seq,
                                                  date_collected,
                                                  billing_cycle)
              VALUES (INV_ym,
                      INV_lab,
                      INV_amount,
                      INV_code,
                      INV_practice,
                      INV_patient,
                      INV_result_entered,
                      INV_procedure,
                      INV_description,
                      INV_seq,
                      INV_collected,
                      INV_cycle);
      ELSIF (in_invoice > 0)
      THEN
         SELECT MAX (statement_id)
           INTO PRIOR_statement
           FROM pcs.practice_statement_labs
          WHERE lab_number = INV_lab;

         SELECT MAX (billing_cycle)
           INTO PRIOR_cycle
           FROM pcs.practice_statement_labs
          WHERE lab_number = INV_lab AND statement_id = PRIOR_statement;

         SELECT DISTINCT choice_code
           INTO PRIOR_billing
           FROM pcs.practice_statement_labs
          WHERE     lab_number = INV_lab
                AND statement_id = PRIOR_statement
                AND billing_cycle = PRIOR_cycle;

         IF (PRIOR_billing <> INV_code)
         THEN
            INSERT INTO pcs.practice_statement_labs (statement_id,
                                                     lab_number,
                                                     item_amount,
                                                     choice_code,
                                                     practice,
                                                     patient_name,
                                                     date_results_entered,
                                                     procedure_code,
                                                     code_description,
                                                     p_seq,
                                                     date_collected,
                                                     billing_cycle)
                 VALUES (INV_ym,
                         INV_lab,
                         INV_amount,
                         INV_code,
                         INV_practice,
                         INV_patient,
                         INV_result_entered,
                         INV_procedure,
                         INV_description,
                         INV_seq,
                         INV_collected,
                         INV_cycle);
         END IF;
      END IF;
   END LOOP;

   CLOSE insert_doc;

   P_code_area := 'OPEN NON-DOC CURSOR';

   OPEN insert_non_doc;

   LOOP
      FETCH insert_non_doc
         INTO INV_ym,
              INV_lab,
              INV_amount,
              INV_code,
              INV_practice,
              INV_patient,
              INV_result_entered,
              INV_procedure,
              INV_description,
              INV_seq,
              INV_collected,
              INV_cycle,
              num_vials;

      EXIT WHEN insert_non_doc%NOTFOUND;

      SELECT COUNT (*)
        INTO in_items
        FROM pcs.lab_billing_items
       WHERE lab_number = INV_lab AND procedure_code = INV_procedure;

      SELECT COUNT (*)
        INTO in_invoice
        FROM pcs.practice_statement_labs
       WHERE     lab_number = INV_lab
             AND procedure_code = INV_procedure
             AND practice = INV_practice;

      IF (INV_procedure = '88305' AND num_vials > 1)
      THEN
         INV_description :=
               INV_description
            || ' ['
            || RTRIM (LTRIM (TO_CHAR (num_vials)))
            || ']';
      END IF;

      IF (in_items > in_invoice)
      THEN
         INSERT INTO pcs.practice_statement_labs (statement_id,
                                                  lab_number,
                                                  item_amount,
                                                  choice_code,
                                                  practice,
                                                  patient_name,
                                                  date_results_entered,
                                                  procedure_code,
                                                  code_description,
                                                  p_seq,
                                                  date_collected,
                                                  billing_cycle)
              VALUES (INV_ym,
                      INV_lab,
                      INV_amount,
                      INV_code,
                      INV_practice,
                      INV_patient,
                      INV_result_entered,
                      INV_procedure,
                      INV_description,
                      INV_seq,
                      INV_collected,
                      INV_cycle);
      ELSIF (in_invoice > 0)
      THEN
         SELECT MAX (statement_id)
           INTO PRIOR_statement
           FROM pcs.practice_statement_labs
          WHERE lab_number = INV_lab;

         SELECT MAX (billing_cycle)
           INTO PRIOR_cycle
           FROM pcs.practice_statement_labs
          WHERE lab_number = INV_lab AND statement_id = PRIOR_statement;

         DBMS_OUTPUT.put_line (
               'Selecting CHOICE_CODE for '
            || INV_lab
            || ', '
            || PRIOR_statement
            || ' and '
            || PRIOR_cycle);

         SELECT DISTINCT choice_code
           INTO PRIOR_billing
           FROM pcs.practice_statement_labs
          WHERE     lab_number = INV_lab
                AND statement_id = PRIOR_statement
                AND billing_cycle = PRIOR_cycle;

         IF (PRIOR_billing <> INV_code)
         THEN
            INSERT INTO pcs.practice_statement_labs (statement_id,
                                                     lab_number,
                                                     item_amount,
                                                     choice_code,
                                                     practice,
                                                     patient_name,
                                                     date_results_entered,
                                                     procedure_code,
                                                     code_description,
                                                     p_seq,
                                                     date_collected,
                                                     billing_cycle)
                 VALUES (INV_ym,
                         INV_lab,
                         INV_amount,
                         INV_code,
                         INV_practice,
                         INV_patient,
                         INV_result_entered,
                         INV_procedure,
                         INV_description,
                         INV_seq,
                         INV_collected,
                         INV_cycle);
         END IF;
      END IF;
   END LOOP;

   CLOSE insert_non_doc;


   -- Any lab that will be exported for billing to a physician account
   -- will be marked as finished.
   UPDATE pcs.lab_requisitions
      SET finished = 4
    WHERE lab_number IN
             (SELECT lab_number
                FROM pcs.billing_queue
               WHERE     billing_route = 'PRA'
                     AND TO_NUMBER (TO_CHAR (datestamp, 'YYYYMM')) = S_month);


   -- In order to preserve the current charges in the accounts history table
   -- the billing_route must first be changed to a temporary value before

   -- all of the PRAs can be deleted from the queue; the trigger p_charge_del
   -- subtracts charges from balance whenever there is a delete on a PRA
   -- from the queue

   COMMIT;

   UPDATE pcs.billing_queue
      SET billing_route = 'DOC'
    WHERE billing_route = 'PRA';

   COMMIT;
   DBMS_OUTPUT.put_line ('Deleting from billing queue');

   DELETE FROM pcs.billing_queue
         WHERE     billing_route = 'DOC'
               AND TO_NUMBER (TO_CHAR (datestamp, 'YYYYMM')) = S_month;

   COMMIT;

   UPDATE pcs.practice_accounts_history
      SET activity_flag = 0;

   SELECT TO_NUMBER (
             TO_CHAR (LAST_DAY (TO_DATE (TO_CHAR (S_month), 'YYYYMM')) + 7,
                      'YYYYMM'))
     INTO S_id
     FROM DUAL;

   DBMS_OUTPUT.put_line (' Year ' || S_id);

   INSERT INTO pcs.practice_accounts_history (practice,
                                              year_month,
                                              prior_balance,
                                              total_charges,
                                              total_payments,
                                              total_plus,
                                              total_minus,
                                              total_balance,
                                              activity_flag)
      SELECT practice,
             S_id,
             total_balance,
             0,
             0,
             0,
             0,
             total_balance,
             1
        FROM practice_accounts;

   UPDATE pcs.job_control
      SET job_status = 0
    WHERE job_descr = 'MID MONTH' OR job_descr = 'MID MONTH COUNT';

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      P_error_code := SQLCODE;
      P_error_message := SQLERRM;

      INSERT INTO pcs.error_log (ERROR_CODE,
                                 error_message,
                                 proc_name,
                                 code_area,
                                 datestamp,
                                 sys_user)
           VALUES (P_error_code,
                   P_error_message,
                   P_proc_name,
                   P_code_area,
                   SYSDATE,
                   UID);

      COMMIT;
      RAISE;
END;
\
grant execute on practices_eom to pcs_user
\
