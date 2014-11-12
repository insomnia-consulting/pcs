CREATE OR REPLACE PROCEDURE build_1500_claim_forms_labnum (
   C_directory       IN CHAR,
   C_file            IN CHAR,
   C_billing_route   IN CHAR,
   C_labnum          IN CHAR)
AS
   P_error_code         NUMBER;
   P_error_message      VARCHAR2 (512);
   P_proc_name          VARCHAR2 (32);
   P_code_area          VARCHAR2 (32);


   CURSOR claim_list
   IS
        SELECT c.carrier_id,
               SUBSTR (c.name, 1, 48),
               c.address1,
               c.address2,
               c.city,
               c.state,
               c.zip,
               c.payer_id,
               bd.id_number,
               bd.group_number,
               bd.subscriber,
               bd.sub_lname,
               bd.sub_fname,
               TO_CHAR (bd.sign_date, 'MMDDYYYY'),
               p.lname,
               p.fname,
               p.mi,
               p.address1,
               p.city,
               p.state,
               p.zip,
               p.phone,
               p.patient,
               TO_CHAR (p.dob, 'MMDDYYYY'),
               pr.name,
               lb.bill_amount,
               TO_CHAR (lr.date_collected, 'MMDDYYYY'),
               bq.lab_number,
               bq.rebilling,
               pr.state,
               NVL (lb.balance, lb.bill_amount),
               lb.bill_amount - (NVL (lb.allowance, lb.bill_amount)),
               TO_CHAR (lr.date_collected, 'MM DD YY'),
               NVL (bd.claim_id, -1),
               c.provider_id,
               bd.rebill_code,
               lr.slide_qty,
               lr.preparation,
               c.id_number
          FROM pcs.carriers c,
               pcs.billing_details bd,
               pcs.patients p,
               pcs.practices pr,
               pcs.lab_billings lb,
               pcs.billing_queue bq,
               pcs.lab_requisitions lr,
               pcs.lab_results r
         WHERE     bq.lab_number = lr.lab_number
               AND lr.lab_number = r.lab_number
               AND lr.lab_number = bd.lab_number
               AND lr.patient = p.patient
               AND lr.practice = pr.practice
               AND bd.carrier_id = c.carrier_id
               AND bd.lab_number = lb.lab_number
               AND bq.rebilling = bd.rebilling
               AND bq.billing_route = C_billing_route
               AND bq.lab_number = C_labnum
      ORDER BY c.billing_choice,
               c.name,
               p.lname,
               p.fname;

   carrier_idnum        NUMBER;                                   --carrier_id
   carrier_id_number    NUMBER;                                    --id_number
   carrier_name         VARCHAR2 (256);
   carrier_addr1        VARCHAR2 (128);
   carrier_addr2        VARCHAR2 (128);
   carrier_city         VARCHAR2 (64);
   carrier_state        CHAR (2);
   carrier_zip          VARCHAR2 (16);
   carrier_pid          VARCHAR2 (64);
   carrier_prov         VARCHAR2 (64);
   policy_id            VARCHAR2 (64);
   policy_group         VARCHAR2 (64);
   policy_lname         VARCHAR2 (64);
   policy_fname         VARCHAR2 (64);
   policy_subscriber    VARCHAR2 (32);
   policy_sign          CHAR (16);
   policy_rebill_code   VARCHAR2 (16);
   patient_lname        VARCHAR2 (64);
   patient_fname        VARCHAR2 (64);
   patient_mi           CHAR (1);
   patient_addr         VARCHAR2 (128);
   patient_city         VARCHAR2 (64);
   patient_state        CHAR (2);
   patient_zip          VARCHAR2 (16);
   patient_phone        CHAR (16);
   patient_id           NUMBER;
   patient_dob          CHAR (16);
   practice_name        VARCHAR2 (128);
   lab_completed        CHAR (16);
   lab_collected        CHAR (16);
   claim_total          NUMBER;
   claim_lab_number     NUMBER;
   lab_rebilling        NUMBER;
   practice_state       CHAR (2);
   lab_balance          NUMBER;
   total_loss           NUMBER;
   lab_claim_id         NUMBER;
   total_payments       NUMBER;
   lab_vials            NUMBER;
   lab_prep             NUMBER;
   dr_lname             VARCHAR2 (128);
   dr_fname             VARCHAR2 (64);
   dr_mi                CHAR (1);
   dr_upin              VARCHAR (32);
   dr_number            NUMBER;
   dr_license           VARCHAR2 (32);
   dr_alt_license       VARCHAR2 (32);
   dr_alt_state         CHAR (2);
   dr_title             VARCHAR2 (32);
   dr_npi               VARCHAR2 (16);
   diag_1               VARCHAR2 (32);
   diag_2               VARCHAR2 (32);
   diag_3               VARCHAR2 (32);
   diag_4               VARCHAR2 (32);
   diag_5               VARCHAR2 (32);
   diag_string          VARCHAR2 (32);
   lab_CLIA             VARCHAR2 (32);
   lab_tax_id           VARCHAR2 (32);
   lab_pin_num          VARCHAR2 (48);
   lab_npi              VARCHAR2 (16);
   trav_med             CHAR (1);

   CURSOR diagnosis_list
   IS
        SELECT *
          FROM pcs.lab_req_diagnosis
         WHERE lab_number = claim_lab_number AND rebilling = lab_rebilling
      ORDER BY d_seq;

   diagnosis_fields     diagnosis_list%ROWTYPE;

   CURSOR procedure_list
   IS
        SELECT bi.lab_number,
               bi.price_code,
               bi.procedure_code,
               bi.item_amount,
               bi.rebilling,
               p.p_seq
          FROM pcs.lab_billing_items bi, pcs.procedure_codes p
         WHERE     bi.lab_number = claim_lab_number
               AND bi.procedure_code = p.procedure_code
               AND bi.item_amount > 0
      ORDER BY p.p_seq;

   procedure_fields     procedure_list%ROWTYPE;

   curr_line            VARCHAR2 (512);
   cbuf1                VARCHAR2 (512);
   cbuf2                VARCHAR2 (512);
   cbuf3                VARCHAR2 (512);
   cbuf4                VARCHAR2 (512);
   margin               VARCHAR2 (16);
   rcnt                 NUMBER;
   curr_item            NUMBER;
   claim_batch_number   NUMBER;
   claim_ebill          CHAR (1);
   C_tpp                VARCHAR2 (16);
   C_claims             NUMBER;
   C_choice_code        VARCHAR2 (16);
   check_point          NUMBER;
   num_diags            NUMBER (1);
   last_carrier         NUMBER;
   max_rebilling        NUMBER;
   resubmitted          NUMBER;
   C_status             VARCHAR2 (2);
   tmp_num              NUMBER;


   lbl_fname            VARCHAR2 (48);
   file_handle          UTL_FILE.FILE_TYPE;
   label_file           UTL_FILE.FILE_TYPE;
BEGIN
   P_proc_name := 'BUILD_1500_CLAIM_FORMS';

   P_code_area := 'PREP';
   check_point := 0;
   num_diags := 0;
   last_carrier := 0;
   trav_med := 'N';

   SELECT COUNT (*)
     INTO C_claims
     FROM pcs.billing_queue
    WHERE billing_route = C_billing_route AND lab_number = C_labnum;

   IF (C_claims > 0 AND C_billing_route <> 'DUP')
   THEN
      SELECT pcs.claim_submission_seq.NEXTVAL
        INTO claim_batch_number
        FROM DUAL;
   END IF;

   margin := '  ';
   C_tpp := C_billing_route;

   P_code_area := 'BATCH';

   IF (C_claims > 0 AND C_billing_route <> 'DUP')
   THEN
      INSERT INTO pcs.claim_batches (batch_number,
                                     e_billing,
                                     number_of_claims,
                                     datestamp,
                                     sys_user,
                                     tpp)
           VALUES (claim_batch_number,
                   'N',
                   C_claims,
                   SYSDATE,
                   UID,
                   C_tpp);

      INSERT INTO pcs.payer_batch_amounts (carrier_id,
                                           batch_number,
                                           amount_submitted,
                                           amount_recorded,
                                           amount_received)
         SELECT DISTINCT bd.carrier_id,
                         claim_batch_number,
                         0,
                         0,
                         0
           FROM pcs.billing_details bd,
                pcs.lab_billings lb,
                pcs.billing_queue bq
          WHERE     bd.lab_number = lb.lab_number
                AND lb.lab_number = bq.lab_number
                AND bd.rebilling = lb.rebilling
                AND bq.billing_route = C_billing_route
                AND bd.lab_number = C_labnum;
   END IF;

   SELECT id_number
     INTO lab_CLIA
     FROM pcs.business_id_nums
    WHERE id_code = 'CLIA';

   SELECT id_number
     INTO lab_tax_id
     FROM pcs.business_id_nums
    WHERE id_code = 'TAXID';

   SELECT id_number
     INTO lab_npi
     FROM pcs.business_id_nums
    WHERE id_code = 'NPI';

   P_code_area := 'CHECK_NPI';
   pcs.check_npi_numbers (C_billing_route);

   file_handle := UTL_FILE.FOPEN (C_directory, C_file, 'w');

   IF (C_billing_route = 'PPR')
   THEN
      lbl_fname := C_file || '.lbl';
      label_file := UTL_FILE.FOPEN (C_directory, lbl_fname, 'w');
   END IF;

   P_code_area := 'CLAIMS';

   OPEN claim_list;

   LOOP
      FETCH claim_list
         INTO carrier_idnum,
              carrier_name,
              carrier_addr1,
              carrier_addr2,
              carrier_city,
              carrier_state,
              carrier_zip,
              carrier_pid,
              policy_id,
              policy_group,
              policy_subscriber,
              policy_lname,
              policy_fname,
              policy_sign,
              patient_lname,
              patient_fname,
              patient_mi,
              patient_addr,
              patient_city,
              patient_state,
              patient_zip,
              patient_phone,
              patient_id,
              patient_dob,
              practice_name,
              claim_total,
              lab_completed,
              claim_lab_number,
              lab_rebilling,
              practice_state,
              lab_balance,
              total_loss,
              lab_collected,
              lab_claim_id,
              carrier_prov,
              policy_rebill_code,
              lab_vials,
              lab_prep,
              carrier_id_number;

      EXIT WHEN claim_list%NOTFOUND;

      resubmitted := 0;
      C_status := '*';
      P_code_area := 'CLAIMS Q1';

      SELECT COUNT (*)
        INTO resubmitted
        FROM pcs.lab_claims
       WHERE lab_number = claim_lab_number AND claim_id = lab_claim_id;

      IF (resubmitted > 0)
      THEN
         P_code_area := 'CLAIMS Q2';

         SELECT claim_status
           INTO C_status
           FROM pcs.lab_claims
          WHERE claim_id = lab_claim_id;

         IF (C_status <> 'B')
         THEN
            resubmitted := 0;
         END IF;
      END IF;

      P_code_area := 'CLAIMS Q3 ' || TO_CHAR (claim_lab_number);

      SELECT MAX (rebilling)
        INTO max_rebilling
        FROM pcs.billing_details
       WHERE lab_number = claim_lab_number;

      IF (max_rebilling > lab_rebilling)
      THEN
         P_code_area :=
            'CLAIMS Q4 ' || claim_lab_number || ' and ' || max_rebilling;

         SELECT c.carrier_id,
                c.name,
                c.address1,
                c.address2,
                c.city,
                c.state,
                c.zip,
                c.payer_id,
                bd.id_number,
                bd.group_number,
                bd.subscriber,
                bd.sub_lname,
                bd.sub_fname,
                TO_CHAR (bd.sign_date, 'MMDDYYYY')
           INTO carrier_idnum,
                carrier_name,
                carrier_addr1,
                carrier_addr2,
                carrier_city,
                carrier_state,
                carrier_zip,
                carrier_pid,
                policy_id,
                policy_group,
                policy_subscriber,
                policy_lname,
                policy_fname,
                policy_sign
           FROM pcs.billing_details bd, pcs.carriers c
          WHERE     bd.carrier_id = c.carrier_id
                AND bd.rebilling = max_rebilling
                AND bd.lab_number = claim_lab_number;
      END IF;


      P_code_area := 'CLAIMS Q3.1';

      IF (    (   C_billing_route = 'PPR'
               OR C_billing_route = 'DUP'
               OR C_billing_route = 'ENV')
          AND carrier_idnum <> 1048)
      THEN
         UTL_FILE.NEW_LINE (file_handle);
         cbuf1 := LPAD (' ', 40);
         curr_line := cbuf1 || carrier_name;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         curr_line := cbuf1 || carrier_addr1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

         IF (carrier_addr2 IS NOT NULL)
         THEN
            curr_line := cbuf1 || carrier_addr2;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         END IF;

         IF (    carrier_city IS NOT NULL
             AND carrier_state IS NOT NULL
             AND carrier_zip IS NOT NULL)
         THEN
            curr_line :=
                  cbuf1
               || carrier_city
               || ', '
               || carrier_state
               || ' '
               || carrier_zip;
         ELSE
            curr_line := '  ';
         END IF;

         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

         IF (carrier_addr2 IS NOT NULL)
         THEN
            UTL_FILE.NEW_LINE (file_handle, 3);
         ELSE
            UTL_FILE.NEW_LINE (file_handle, 4);
         END IF;
      ELSE
         UTL_FILE.NEW_LINE (file_handle, 8);
      END IF;

      P_code_area := 'CLAIMS Q5';

      SELECT A.choice_code
        INTO C_choice_code
        FROM pcs.billing_choices A, pcs.carriers B
       WHERE     A.billing_choice = B.billing_choice
             AND B.carrier_id = carrier_idnum;

      P_code_area := 'CLAIMS Q6';

      SELECT NVL (SUM (payment_amount), 0)
        INTO total_payments
        FROM pcs.payments P
       WHERE     P.payment_type <> 'PLUS ADJUST'
             AND P.lab_number = claim_lab_number;

      P_code_area := 'CLAIMS Q6.001';

      SELECT NVL (SUM (payment_amount), 0)
        INTO tmp_num
        FROM pcs.payments P
       WHERE     P.payment_type = 'PLUS ADJUST'
             AND P.lab_number = claim_lab_number;

      P_code_area := 'CLAIMS Q6.002';
      total_payments := total_payments - tmp_num;
      P_code_area := 'CLAIMS Q6.003';

      IF (carrier_idnum <> last_carrier)
      THEN
         P_code_area := 'CLAIMS Q6.334';

         IF (C_billing_route = 'PPR')
         THEN
            IF (    carrier_addr1 IS NOT NULL
                AND carrier_city IS NOT NULL
                AND carrier_state IS NOT NULL
                AND carrier_zip IS NOT NULL)
            THEN
               rcnt := 3;
               curr_line := SUBSTR (carrier_name, 1, 32);
               UTL_FILE.PUTF (label_file, '%s\n', curr_line);
               curr_line := SUBSTR (carrier_addr1, 1, 32);
               UTL_FILE.PUTF (label_file, '%s\n', curr_line);

               IF (carrier_addr2 IS NOT NULL)
               THEN
                  rcnt := 2;
                  curr_line := SUBSTR (carrier_addr2, 1, 32);
                  UTL_FILE.PUTF (label_file, '%s\n', curr_line);
               END IF;

               cbuf1 := SUBSTR (carrier_zip, 1, 5);

               IF (LENGTH (carrier_zip) > 5)
               THEN
                  cbuf2 := SUBSTR (carrier_zip, 6, 4);
                  cbuf1 := cbuf1 || '-' || cbuf2;
               END IF;

               curr_line :=
                  SUBSTR (
                     carrier_city || ', ' || carrier_state || ' ' || cbuf1,
                     1,
                     32);
               UTL_FILE.PUTF (label_file, '%s\n', curr_line);
               UTL_FILE.NEW_LINE (label_file, rcnt);
               rcnt := 0;
            END IF;
         END IF;
      END IF;

      UTL_FILE.NEW_LINE (file_handle);
      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (carrier_name = 'CHAMPUS')
      THEN
         cbuf1 := LPAD ('X', 14);
      ELSIF (C_choice_code = 'DPA')
      THEN
         cbuf1 := LPAD ('X', 7);
         policy_subscriber := 'SELF';

         IF (carrier_state = 'WV')
         THEN
            P_code_area := 'CLAIMS Q8';

            SELECT id_number
              INTO lab_pin_num
              FROM pcs.business_id_nums
             WHERE id_code = 'WVPR';
         ELSIF (carrier_state = 'OH')
         THEN
            P_code_area := 'CLAIMS Q9';

            SELECT '  ' || id_number
              INTO lab_pin_num
              FROM pcs.business_id_nums
             WHERE id_code = 'OHPR';
         ELSIF (carrier_state = 'PA')
         THEN
            P_code_area := 'CLAIMS Q10';

            SELECT id_number
              INTO lab_pin_num
              FROM pcs.business_id_nums
             WHERE id_code = 'PAPR';
         ELSIF (carrier_state = 'AL')
         THEN
            SELECT id_number
              INTO lab_pin_num
              FROM pcs.business_id_nums
             WHERE id_code = 'ALPR';
         END IF;
      ELSIF (    C_choice_code = 'MED'
             AND SUBSTR (policy_id, 1, 1) >= 'A'
             AND SUBSTR (policy_id, 1, 1) <= 'Z')
      THEN
         cbuf1 := 'X';

         SELECT id_number
           INTO lab_pin_num
           FROM pcs.business_id_nums
          WHERE id_code = 'TMPR';

         trav_med := 'Y';
      ELSE
         cbuf1 := LPAD ('X', 44);

         IF (C_choice_code = 'BS')
         THEN
            SELECT id_number
              INTO lab_pin_num
              FROM pcs.business_id_nums
             WHERE id_code = 'BSPR';
         END IF;
      END IF;

      curr_line := RPAD (cbuf1, 50) || policy_id;

      curr_line := margin || curr_line;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;
      cbuf1 :=
            RTRIM (patient_lname)
         || ', '
         || RTRIM (patient_fname)
         || ' '
         || patient_mi;
      cbuf1 := SUBSTR (cbuf1, 1, 28);
      cbuf1 := RPAD (cbuf1, 28);

      /* This block of code removed 04/18/13; it prevented the patient's DOB from *
         being printed on the form. Code commented out for now pending testing * of a
         batch of paper claims. The goto statement label must also be removed.
         if (C_choice_code='DPA' and carrier_state='OH') then goto skip_ln5; end if; */

      IF (patient_dob IS NOT NULL)
      THEN
         IF (carrier_idnum = 23744)
         THEN
            cbuf1 := cbuf1 || ' ' || SUBSTR (patient_dob, 1, 2);
            cbuf1 := cbuf1 || ' ' || SUBSTR (patient_dob, 3, 2);
            cbuf1 := cbuf1 || ' ' || SUBSTR (patient_dob, 7, 2) || '  ';
         ELSE
            cbuf1 := cbuf1 || ' ' || SUBSTR (patient_dob, 1, 2);
            cbuf1 := cbuf1 || ' ' || SUBSTR (patient_dob, 3, 2);
            cbuf1 := cbuf1 || ' ' || SUBSTR (patient_dob, 5, 4);
         END IF;
      ELSE
         cbuf1 := cbuf1 || '           ';
      END IF;

      cbuf1 := cbuf1 || LPAD ('X', 7);

      IF (policy_subscriber = 'SELF' AND C_billing_route <> 'PPR')
      THEN
         cbuf1 := cbuf1 || '  ' || 'SAME';
      ELSIF (carrier_idnum = 1048)
      THEN
         cbuf1 := cbuf1;
      ELSIF (C_choice_code <> 'MED')
      THEN
         cbuf2 := RTRIM (policy_lname) || ', ' || RTRIM (policy_fname);
         cbuf2 := SUBSTR (cbuf2, 1, 29);

         cbuf1 := cbuf1 || '   ' || cbuf2;
      END IF;

      curr_line := margin || cbuf1;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_choice_code = 'DPA' AND carrier_state = 'OH')
      THEN
         cbuf1 := LPAD ('X', 33);
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);



         UTL_FILE.NEW_LINE (file_handle);
      ELSE
         cbuf1 := RTRIM (patient_addr);
         cbuf1 := SUBSTR (cbuf1, 1, 29);

         IF (cbuf1 IS NULL)
         THEN
            cbuf1 := ' ';
         END IF;

         cbuf1 := RPAD (cbuf1, 29);

         IF (policy_subscriber = 'SELF')
         THEN
            cbuf1 := cbuf1 || '  X                   ';
         ELSIF (policy_subscriber = 'SPOUSE')
         THEN
            cbuf1 := cbuf1 || '          X           ';
         ELSIF (policy_subscriber = 'DEPENDENT')
         THEN
            cbuf1 := cbuf1 || '              X       ';
         ELSE
            cbuf1 := cbuf1 || '                  X   ';
         END IF;

         IF (C_billing_route <> 'PPR')
         THEN
            cbuf1 := cbuf1 || 'SAME';
         END IF;



         curr_line := margin || cbuf1;

         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_choice_code = 'DPA' AND carrier_state = 'OH')
      THEN
         UTL_FILE.NEW_LINE (file_handle, 2);
      ELSE
         cbuf1 := RTRIM (patient_city);
         cbuf1 := SUBSTR (patient_city, 1, 24);

         cbuf1 := RPAD (cbuf1, 24) || ' ' || patient_state;
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_choice_code = 'DPA' AND carrier_state = 'OH')
      THEN
         UTL_FILE.NEW_LINE (file_handle, 2);
      ELSE
         cbuf1 := RTRIM (patient_zip);
         cbuf1 := RPAD (cbuf1, 14);
         cbuf2 := SUBSTR (patient_phone, 1, 3);
         cbuf1 := cbuf1 || cbuf2;
         cbuf1 := RPAD (cbuf1, 18);
         cbuf2 := SUBSTR (patient_phone, 4, 7);
         cbuf1 := cbuf1 || cbuf2;
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_choice_code = 'DPA')
      THEN
         UTL_FILE.NEW_LINE (file_handle, 2);
      ELSE
         IF (C_choice_code = 'MED' OR C_choice_code = 'OI')
         THEN
            cbuf1 := 'N/A';
         ELSE
            cbuf1 := 'SAME';
         END IF;

         cbuf1 := RPAD (cbuf1, 49);

         IF (C_choice_code = 'MED')
         THEN
            cbuf1 := cbuf1 || 'NONE';
         ELSE
            cbuf1 := cbuf1 || SUBSTR (policy_group, 1, 29);
         END IF;

         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;

      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_choice_code = 'DPA' AND carrier_state = 'WV')
      THEN
         UTL_FILE.NEW_LINE (file_handle, 2);
      ELSE
         cbuf1 := LPAD ('X', 40);
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;

      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_choice_code = 'DPA' AND carrier_state = 'WV')
      THEN
         UTL_FILE.NEW_LINE (file_handle, 2);
      ELSE
         cbuf1 := LPAD ('X', 40);
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;

      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_choice_code = 'DPA' AND carrier_state = 'WV')
      THEN
         UTL_FILE.NEW_LINE (file_handle, 2);
      ELSE
         cbuf1 := LPAD ('X', 40);
         cbuf1 := RPAD (cbuf1, 49);

         IF (C_billing_route = 'ENV')
         THEN
            cbuf1 := cbuf1 || carrier_pid;
         END IF;

         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);



         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_billing_route = 'ENV')
      THEN
         IF (carrier_pid IS NULL)
         THEN
            cbuf1 := LPAD (' ', 56);
            cbuf1 := cbuf1 || 'X';
            curr_line := margin || cbuf1;
         ELSE
            cbuf1 := LPAD (' ', 30) || carrier_pid;
            cbuf1 := RPAD (cbuf1, 54);
            cbuf1 := cbuf1 || 'X';
            curr_line := margin || cbuf1;
         END IF;
      END IF;

      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);



      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_billing_route = 'PPR' OR C_billing_route = 'DUP')
      THEN
         IF (C_choice_code <> 'DPA')
         THEN
            cbuf1 := LPAD ('SIGNATURE ON FILE', 31);
            cbuf2 := LPAD (lab_collected, 22);
            curr_line := cbuf1 || cbuf2 || LPAD ('SIGNATURE ON FILE', 22);
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
            UTL_FILE.NEW_LINE (file_handle);
         ELSIF (carrier_idnum = 1048)
         THEN
            cbuf1 := LPAD ('SIGNATURE EXCEPTION', 27);
            cbuf2 := LPAD (TO_CHAR (SYSDATE, 'MMDDYYYY'), 20);
            curr_line := cbuf1 || cbuf2;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
            UTL_FILE.NEW_LINE (file_handle);
         ELSE
            UTL_FILE.NEW_LINE (file_handle, 2);
         END IF;
      ELSE
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

      cbuf1 := NULL;
      cbuf2 := NULL;



      curr_line := NULL;
      P_code_area := 'CLAIMS Q13';

      SELECT doctor
        INTO dr_number
        FROM pcs.lab_requisitions
       WHERE lab_number = claim_lab_number;

      P_code_area := 'CLAIMS Q14';

      SELECT lname,
             fname,
             mi,
             upin,
             license,
             alt_license,
             alt_state,
             title,
             npi
        INTO dr_lname,
             dr_fname,
             dr_mi,
             dr_upin,
             dr_license,
             dr_alt_license,
             dr_alt_state,
             dr_title,
             dr_npi
        FROM pcs.doctors
       WHERE doctor = dr_number;

      cbuf1 := RTRIM (dr_fname);

      IF (dr_mi IS NOT NULL)
      THEN
         cbuf1 := cbuf1 || ' ' || dr_mi;
      END IF;

      cbuf1 := cbuf1 || ' ' || RTRIM (dr_lname);

      IF (dr_title IS NOT NULL)
      THEN
         cbuf1 := cbuf1 || ' ' || RTRIM (LTRIM (dr_title));
      END IF;

      IF (dr_upin IS NULL)
      THEN
         cbuf2 := '	 ';
      ELSIF (C_choice_code = 'BS' OR C_choice_code = 'MED')
      THEN
         cbuf2 := '        ';
      ELSE
         cbuf2 := '1G ' || dr_upin;
      END IF;

      IF (C_choice_code = 'DPA')
      THEN
         cbuf2 := REPLACE (dr_license, ' ');

         IF (dr_alt_state IS NOT NULL AND carrier_state = dr_alt_state)
         THEN
            cbuf2 := REPLACE (dr_alt_license, ' ');
         END IF;

         cbuf2 := '0B ' || cbuf2;
      END IF;

      IF (cbuf2 IS NOT NULL)
      THEN
         cbuf3 := ' ';
         cbuf3 := RPAD (cbuf3, 31);
         curr_line := cbuf3 || cbuf2;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      ELSE
         UTL_FILE.NEW_LINE (file_handle);
      END IF;

      IF (LENGTH (cbuf1) > 22)
      THEN
         cbuf1 := SUBSTR (cbuf1, 1, 22);
      END IF;


      cbuf1 := 'DK  ' || RPAD (cbuf1, 26);

      curr_line := margin || cbuf1;

      IF (dr_npi IS NOT NULL)
      THEN
         curr_line := curr_line || '   ' || dr_npi;
      END IF;

      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (carrier_idnum = 1048 AND policy_rebill_code = 'SEC')
      THEN
         curr_line := margin || 'AT11';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      ELSE
         UTL_FILE.NEW_LINE (file_handle, 1);
      END IF;

      curr_line := NULL;

      cbuf1 := '9';
      cbuf1 := LPAD (cbuf1, 44);
      UTL_FILE.PUTF (file_handle, '%s', cbuf1);
      UTL_FILE.NEW_LINE (file_handle, 1);
      cbuf1 := NULL;

      diag_1 := NULL;
      diag_2 := NULL;
      diag_3 := NULL;
      diag_4 := NULL;

      P_code_area := 'DIAGNOSIS';

      OPEN diagnosis_list;

      LOOP
         FETCH diagnosis_list INTO diagnosis_fields;

         EXIT WHEN diagnosis_list%NOTFOUND;

         IF (diagnosis_fields.d_seq = 1)
         THEN
            diag_1 := diagnosis_fields.diagnosis_code;
         ELSIF (diagnosis_fields.d_seq = 2)
         THEN
            diag_2 := diagnosis_fields.diagnosis_code;
         ELSIF (diagnosis_fields.d_seq = 3)
         THEN
            diag_3 := diagnosis_fields.diagnosis_code;
         ELSIF (diagnosis_fields.d_seq = 4)
         THEN
            diag_4 := diagnosis_fields.diagnosis_code;
         END IF;
      END LOOP;



      CLOSE diagnosis_list;

      IF (carrier_idnum = 1048)
      THEN
         diag_1 := 'LAB16 ';
         diag_2 := NULL;
         diag_3 := NULL;
         diag_4 := NULL;
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (diag_1 IS NOT NULL)
      THEN
         cbuf1 := '  ' || diag_1;
      END IF;

      IF (diag_2 IS NOT NULL)
      THEN
         cbuf2 := diag_2;
         cbuf2 := LPAD (cbuf2, 14);
         cbuf1 := cbuf1 || cbuf2;
      END IF;

      IF (diag_3 IS NOT NULL)
      THEN
         cbuf2 := diag_3;
         cbuf2 := LPAD (cbuf2, 12);
         cbuf1 := cbuf1 || cbuf2;
      END IF;

      IF (diag_4 IS NOT NULL)
      THEN
         cbuf2 := diag_4;
         cbuf2 := LPAD (cbuf2, 13);
         cbuf1 := cbuf1 || cbuf2;
      END IF;


      curr_line := margin || cbuf1;

      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;


      IF (cbuf1 IS NULL)
      THEN
         cbuf1 := RPAD (' ', 49);
      ELSE
         cbuf1 := RPAD (cbuf1, 49);
      END IF;

      IF (C_billing_route = 'ENV' OR C_choice_code = 'MED')
      THEN
         cbuf1 := cbuf1 || RTRIM (lab_CLIA);
      END IF;

      curr_line := margin || cbuf1;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

      diag_5 := NULL;

      IF (diag_1 IS NOT NULL)
      THEN
         diag_5 := 'A';
      END IF;

      IF (diag_2 IS NOT NULL)
      THEN
         diag_5 := diag_5 || 'B';
      END IF;

      IF (diag_3 IS NOT NULL)
      THEN
         diag_5 := diag_5 || 'C';
      END IF;

      IF (diag_4 IS NOT NULL)
      THEN
         diag_5 := diag_5 || 'D';
      END IF;

      IF (diag_5 IS NULL)
      THEN
         diag_5 := ' ';
      END IF;

      rcnt := 0;
      P_code_area := 'PROCEDURE';

      OPEN procedure_list;

      LOOP
         FETCH procedure_list INTO procedure_fields;

         EXIT WHEN procedure_list%NOTFOUND;
         rcnt := rcnt + 1;
         cbuf1 := NULL;
         cbuf2 := NULL;



         curr_line := NULL;

         IF (carrier_idnum = 1048)
         THEN
            cbuf1 := lab_completed || '       ';
         /*
         elsif (carrier_idnum=23744) then
         cbuf2:=SUBSTR(lab_completed,1,2)||' ';
         cbuf2:=cbuf2||SUBSTR(lab_completed,3,2)||' ';
         cbuf2:=cbuf2||SUBSTR(lab_completed,7,2);
         cbuf1:=cbuf2||' '||cbuf2;
         */
         ELSE
            cbuf1 := lab_completed || ' ' || lab_completed;
         END IF;

         IF (carrier_idnum = 22797 OR carrier_idnum = 26254)
         THEN
            cbuf1 := RPAD (cbuf1, 8) || ' ' || RPAD (cbuf1, 8) || ' 81';
         ELSE
            cbuf1 := RPAD (cbuf1, 11) || '       81';
         END IF;

         cbuf1 := RPAD (cbuf1, 24) || procedure_fields.procedure_code;

         IF (C_choice_code = 'MED' AND policy_sign IS NOT NULL)
         THEN
            cbuf1 := cbuf1 || '  GA';
         ELSIF (C_choice_code = 'DPA' AND carrier_idnum NOT IN (1046, 1047))
         THEN
            cbuf1 := cbuf1 || '  FP';
         END IF;

         DBMS_OUTPUT.put_line ('Checking for diag code stuff');

         IF (procedure_fields.procedure_code IN ('88141', '87621'))
         THEN
            IF (carrier_idnum = 23744)
            THEN
               diag_string := 'B';
            ELSE
               diag_string := REPLACE (diag_5, 'A,');
            END IF;
         ELSE
            IF (carrier_idnum = 23744)
            THEN
               diag_string := 'A';
            ELSE
               DBMS_OUTPUT.put_line ('But not 23744'||diag_5||'.');
               diag_string := diag_5;
            END IF;
         END IF;

         IF (trav_med = 'Y')
         THEN
            diag_string := 'A';
         END IF;

         cbuf1 := RPAD (cbuf1, 43) || RPAD (diag_string, 7);



         cbuf1 := RPAD (cbuf1, 47);
         curr_item := procedure_fields.item_amount;
         curr_line := TO_CHAR (curr_item, '99999.99');
         cbuf2 := SUBSTR (curr_line, 1, 6);
         cbuf2 := LTRIM (cbuf2);
         cbuf2 := RTRIM (cbuf2);

         cbuf2 := '  ' || LPAD (cbuf2, 5);
         cbuf1 := cbuf1 || cbuf2 || ' ';
         cbuf2 := SUBSTR (curr_line, 8, 2);
         cbuf1 := cbuf1 || cbuf2;

         IF (lab_prep = 6)
         THEN
            cbuf3 := RTRIM (LTRIM (TO_CHAR (lab_vials)));
         ELSE
            cbuf3 := '1';
         END IF;

         cbuf1 := RPAD (cbuf1, 58) || cbuf3;


         cbuf1 := cbuf1 || '       ' || lab_npi;
         curr_line := margin || cbuf1;



         curr_line := REPLACE (curr_line, ' 081 ', '  81 ');
         curr_line := REPLACE (curr_line, ' 181 ', '  81 ');

         IF (carrier_idnum = 1048)
         THEN
            cbuf1 := RPAD (' ', 65) || '1D ' || carrier_prov;
            UTL_FILE.PUTF (file_handle, '%s\n', cbuf1);
         ELSIF (trav_med = 'Y')
         THEN
            cbuf1 := RPAD (' ', 65) || '1C';
            UTL_FILE.PUTF (file_handle, '%s\n', cbuf1);
         ELSE
            UTL_FILE.NEW_LINE (file_handle);
         END IF;

         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      END LOOP;

      CLOSE procedure_list;

      FOR ndx IN (rcnt + 1) .. 6
      LOOP
         cbuf1 := NULL;
         cbuf2 := NULL;

         curr_line := NULL;
         UTL_FILE.NEW_LINE (file_handle, 2);
      END LOOP;

      UTL_FILE.NEW_LINE (file_handle);

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;



      cbuf1 := RPAD (lab_tax_id, 18) || 'X';
      cbuf2 := '	' || SUBSTR (RTRIM (LTRIM (TO_CHAR (claim_lab_number))), 3);
      cbuf1 := cbuf1 || cbuf2;

      IF (C_choice_code = 'DPA')
      THEN
         cbuf1 := RPAD (cbuf1, 37) || ' ';
      ELSE
         cbuf1 := RPAD (cbuf1, 35) || 'X';
      END IF;

      cbuf1 := RPAD (cbuf1, 47);

      cbuf2 := TO_CHAR (claim_total, '999990.99');



      curr_line := SUBSTR (cbuf2, 1, 7);
      curr_line := LTRIM (curr_line);
      curr_line := RTRIM (curr_line);
      cbuf2 := LPAD (curr_line, 7);
      cbuf1 := cbuf1 || cbuf2 || ' ';
      cbuf2 := TO_CHAR (claim_total, '999990.99');
      curr_line := SUBSTR (cbuf2, 9, 2);

      cbuf1 := cbuf1 || curr_line;

      IF (carrier_idnum <> 1048)
      THEN
         cbuf2 := TO_CHAR (total_payments, '99990.99');
         curr_line := SUBSTR (cbuf2, 1, 6);
         curr_line := LTRIM (curr_line);
         curr_line := RTRIM (curr_line);
         cbuf2 := LPAD (curr_line, 6);
         cbuf3 := cbuf1 || cbuf2 || ' ';
         cbuf2 := TO_CHAR (total_payments, '99990.99');
         curr_line := SUBSTR (cbuf2, 8, 2);
         cbuf3 := cbuf3 || curr_line;

         cbuf1 := cbuf3;
      END IF;

      curr_line := margin || cbuf1;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);


      cbuf2 := LPAD (' ', 64);
      cbuf1 := cbuf2 || '412 373 8300';
      curr_line := margin || cbuf1;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

      cbuf1 := NULL;



      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_billing_route = 'ENV')
      THEN
         cbuf1 := LPAD ('SAME', 26);
         cbuf1 := RPAD (cbuf1, 49);

         cbuf1 := cbuf1 || 'PA CYTOLOGY SERVICES G';
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      ELSIF (carrier_idnum = 1048)
      THEN
         cbuf1 := LPAD (' ', 26);
         cbuf1 := RPAD (cbuf1, 49);
         cbuf1 := cbuf1 || 'PA CYTOLOGY SERVICES';
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      ELSE
         IF (C_choice_code = 'DPA' OR C_choice_code = 'OI')
         THEN
            cbuf1 := LPAD ('    ', 26);
            cbuf1 := RPAD (cbuf1, 49);

            IF (carrier_idnum = 1048)
            THEN
               cbuf1 := cbuf1 || '				 ';
            ELSE
               cbuf1 := cbuf1 || 'PENNSYLVANIA CYTOLOGY SERV';
            END IF;

            curr_line := margin || cbuf1;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         ELSIF (C_choice_code = 'MED' OR C_choice_code = 'BS')
         THEN
            cbuf1 := LPAD (' ', 22) || 'PENNSYLVANIA CYTOLOGY SERV';
            cbuf1 := RPAD (cbuf1, 49);
            cbuf1 := cbuf1 || 'PENNSYLVANIA CYTOLOGY SERV';
            curr_line := margin || cbuf1;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         END IF;
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;
      curr_line := NULL;

      IF (C_billing_route = 'ENV')
      THEN
         cbuf1 := '339 OLD HAYMAKER ROAD';



         cbuf2 := LPAD (' ', 49);
         cbuf1 := cbuf2 || cbuf1;
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      ELSE
         IF (C_choice_code = 'DPA' OR C_choice_code = 'OI')
         THEN
            IF (C_choice_code = 'DPA')
            THEN
               cbuf1 := LPAD (' ', 26);
            ELSIF (carrier_idnum = 23663)
            THEN
               cbuf1 := 'PA CYTOLOGY SERVICES  SAME';
            ELSE
               cbuf1 := LPAD ('SAME', 26);
            END IF;

            cbuf1 := RPAD (cbuf1, 49);
            cbuf1 := cbuf1 || '339 HAYMAKER RD STE 1700';
            curr_line := margin || cbuf1;

            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         ELSIF (C_choice_code = 'MED' OR C_choice_code = 'BS')
         THEN
            cbuf1 := LPAD (' ', 22) || '339 HAYMAKER RD S 1700';



            cbuf1 := RPAD (cbuf1, 49);
            cbuf1 := cbuf1 || '339 HAYMAKER RD STE 1700';
            curr_line := margin || cbuf1;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         END IF;
      END IF;

      cbuf1 := NULL;
      cbuf2 := NULL;

      curr_line := NULL;

      IF (carrier_idnum IN (2575, 2695, 4008))
      THEN
         cbuf2 := RPAD ('R H SWEDARSKY  ', 49);
         cbuf1 := cbuf2 || 'MONROEVILLE PA	15146';
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      ELSIF (carrier_idnum = 23524)
      THEN
         cbuf2 := RPAD ('SIGNATURE ON FILE', 49);
         cbuf1 := cbuf2 || 'MONROEVILLE PA	15146';
         curr_line := margin || cbuf1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      ELSE
         IF (C_choice_code = 'DPA' OR C_choice_code = 'OI')
         THEN
            IF (carrier_idnum = 23663)
            THEN
               cbuf1 := LPAD ('2478948', 20) || '	 ';
            ELSE
               cbuf1 := LPAD (' ', 26);
            END IF;

            cbuf1 := RPAD (cbuf1, 49);
            cbuf1 := cbuf1 || 'MONROEVILLE, PA 15146';
            curr_line := margin || cbuf1;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         ELSIF (C_choice_code = 'MED' OR C_choice_code = 'BS')
         THEN
            cbuf1 := LPAD (' ', 22) || 'MONROEVILLE, PA 15146';

            cbuf1 := RPAD (cbuf1, 49);
            cbuf1 := cbuf1 || 'MONROEVILLE, PA 15146';
            curr_line := margin || cbuf1;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         END IF;
      END IF;



      cbuf1 := NULL;
      cbuf2 := NULL;
      cbuf3 := NULL;
      cbuf2 := LPAD (' ', 14);
      cbuf1 := RPAD (lab_npi, 11);

      IF (carrier_prov IS NOT NULL)
      THEN
         IF (C_choice_code = 'DPA')
         THEN
            cbuf2 := carrier_prov;
         ELSIF (C_choice_code = 'BS')
         THEN
            cbuf2 := '1B' || carrier_prov;
         ELSIF (C_choice_code = 'MED')
         THEN
            cbuf2 := '		   ';
         ELSE
            cbuf2 := 'G2' || carrier_prov;
         END IF;

         cbuf2 := RPAD (cbuf2, 16);
      ELSE
         cbuf2 := RPAD (' ', 16);
      END IF;

      cbuf3 := RPAD (' ', 22);
      cbuf4 := RPAD (' ', 27);

      IF (carrier_idnum = 1048)
      THEN
         curr_line := margin || cbuf3 || cbuf4 || cbuf1 || cbuf2;
      ELSIF (carrier_id_number = 10020 OR carrier_id_number = 28025)
      THEN
         curr_line :=
            margin || cbuf3 || cbuf1 || RPAD (' ', 16) || cbuf1 || cbuf2;
      ELSE
         curr_line := margin || cbuf3 || cbuf1 || cbuf2 || cbuf1 || cbuf2;
      END IF;


      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      UTL_FILE.NEW_LINE (file_handle, 3);

      IF (C_claims > 0 AND C_billing_route <> 'DUP')
      THEN
         P_code_area := 'CLAIMS Q15';

         UPDATE pcs.payer_batch_amounts
            SET amount_submitted =
                   amount_submitted + (claim_total - total_payments)
          WHERE     carrier_id = carrier_idnum
                AND batch_number = claim_batch_number;

         IF (resubmitted = 0)
         THEN
            P_code_area := 'CLAIMS Q16';

            SELECT pcs.claim_seq.NEXTVAL INTO lab_claim_id FROM DUAL;

            INSERT INTO pcs.lab_claims (claim_id,
                                        lab_number,
                                        batch_number,
                                        claim_status,
                                        datestamp,
                                        change_date)
                 VALUES (lab_claim_id,
                         claim_lab_number,
                         claim_batch_number,
                         'S',
                         SYSDATE,
                         SYSDATE);

            UPDATE pcs.billing_details
               SET claim_id = lab_claim_id, date_sent = SYSDATE
             WHERE     lab_number = claim_lab_number
                   AND rebilling = lab_rebilling;

            UPDATE pcs.lab_requisitions
               SET finished = 2
             WHERE lab_number = claim_lab_number AND finished <= 2;
         ELSE
            UPDATE pcs.lab_claims
               SET batch_number = claim_batch_number,
                   datestamp = SYSDATE,
                   change_date = SYSDATE
             WHERE claim_id = lab_claim_id;
         END IF;
      END IF;


      last_carrier := carrier_idnum;
   END LOOP;

   CLOSE claim_list;



   DELETE FROM pcs.billing_queue
         WHERE billing_route = C_billing_route;

   IF (C_claims > 0 AND C_billing_route <> 'DUP')
   THEN
      INSERT INTO pcs.claim_submissions (batch_number,
                                         tpp,
                                         submission_number,
                                         creation_date)
           VALUES (claim_batch_number,
                   C_billing_route,
                   1,
                   SYSDATE);
   END IF;

   UTL_FILE.FCLOSE (file_handle);

   IF (C_billing_route = 'PPR')
   THEN
      UTL_FILE.FCLOSE (label_file);
   END IF;

   COMMIT;
EXCEPTION
   WHEN UTL_FILE.INVALID_PATH
   THEN
      UTL_FILE.FCLOSE (file_handle);

      IF (C_billing_route = 'PPR')
      THEN
         UTL_FILE.FCLOSE (label_file);
      END IF;

      RAISE_APPLICATION_ERROR (-20051, 'invalid path');
   WHEN UTL_FILE.INVALID_MODE
   THEN
      UTL_FILE.FCLOSE (file_handle);

      IF (C_billing_route = 'PPR')
      THEN
         UTL_FILE.FCLOSE (label_file);
      END IF;

      RAISE_APPLICATION_ERROR (-20052, 'invalid mode');
   WHEN UTL_FILE.INVALID_FILEHANDLE
   THEN
      UTL_FILE.FCLOSE (file_handle);

      IF (C_billing_route = 'PPR')
      THEN
         UTL_FILE.FCLOSE (label_file);
      END IF;

      RAISE_APPLICATION_ERROR (-20053, 'invalid file handle');
   WHEN UTL_FILE.INVALID_OPERATION
   THEN
      UTL_FILE.FCLOSE (file_handle);

      IF (C_billing_route = 'PPR')
      THEN
         UTL_FILE.FCLOSE (label_file);
      END IF;

      RAISE_APPLICATION_ERROR (-20054, 'invalid operation');
   WHEN UTL_FILE.READ_ERROR
   THEN
      UTL_FILE.FCLOSE (file_handle);

      IF (C_billing_route = 'PPR')
      THEN
         UTL_FILE.FCLOSE (label_file);
      END IF;

      RAISE_APPLICATION_ERROR (-20055, 'read error');
   WHEN UTL_FILE.WRITE_ERROR
   THEN
      UTL_FILE.FCLOSE (file_handle);

      IF (C_billing_route = 'PPR')
      THEN
         UTL_FILE.FCLOSE (label_file);
      END IF;

      RAISE_APPLICATION_ERROR (-20056, 'write error');
   WHEN OTHERS
   THEN
      UTL_FILE.FCLOSE (file_handle);

      IF (C_billing_route = 'PPR')
      THEN
         UTL_FILE.FCLOSE (label_file);
      END IF;

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
                   claim_lab_number);

      COMMIT;

      RAISE;
END;
\

grant execute on update_receive_dates to pcs_user
\
