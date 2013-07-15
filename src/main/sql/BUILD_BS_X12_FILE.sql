CREATE OR REPLACE PROCEDURE build_bs_x12_file (C_directory       IN CHAR,
                                               C_file            IN CHAR,
                                               C_billing_route   IN VARCHAR2,
                                               C_retran_status   IN NUMBER,
                                               test_indicator    IN CHAR)
AS
   P_error_code                 NUMBER;
   P_error_message              VARCHAR2 (512);
   P_proc_name                  VARCHAR2 (32);

   P_code_area                  VARCHAR2 (32);

   CURSOR claim_list
   IS
        SELECT c.carrier_id,
               c.name,
               RTRIM (LTRIM (bd.id_number)),
               bd.group_number,
               bd.subscriber,
               bd.sub_lname,
               bd.sub_fname,
               TO_CHAR (bd.sign_date, 'MMDDYYYY'),
               p.lname,
               p.fname,
               p.mi,
               LTRIM (RTRIM (SUBSTR (p.address1, 1, 30))),
               LTRIM (RTRIM (p.city)),
               p.state,
               p.zip,
               p.phone,
               p.patient,
               TO_CHAR (p.dob, 'YYYYMMDD'),
               pr.name,
               lb.bill_amount,
               TO_CHAR (lr.date_collected, 'YYYYMMDD'),
               bq.lab_number,
               bq.rebilling,
               NVL (lb.balance, lb.bill_amount),
               lr.doctor,
               NVL (bd.claim_id, -1),
               lr.slide_qty,
               lr.preparation
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
      ORDER BY c.name, p.lname, p.fname;

   carrier_idnum                NUMBER;
   carrier_name                 VARCHAR2 (128);
   policy_id                    VARCHAR2 (32);
   policy_group                 VARCHAR2 (32);

   policy_subscriber            VARCHAR2 (16);
   policy_lname                 VARCHAR2 (32);
   policy_fname                 VARCHAR2 (32);
   policy_sign                  CHAR (8);
   patient_lname                VARCHAR2 (32);
   patient_fname                VARCHAR2 (32);
   patient_mi                   CHAR (1);
   patient_addr                 VARCHAR2 (64);
   patient_city                 VARCHAR2 (32);
   patient_state                CHAR (2);
   patient_zip                  VARCHAR2 (9);
   patient_phone                CHAR (10);
   patient_id                   NUMBER;

   patient_dob                  CHAR (8);
   practice_name                VARCHAR2 (64);
   claim_total                  NUMBER;
   lab_collected                CHAR (8);
   claim_lab_number             NUMBER;
   lab_rebilling                NUMBER;
   lab_balance                  NUMBER;
   lab_doctor                   NUMBER;
   lab_claim_id                 NUMBER;
   lab_vials                    NUMBER;
   lab_prep                     NUMBER;

   patient_payments             NUMBER;


   dr_lname                     VARCHAR2 (32);
   dr_fname                     VARCHAR2 (32);
   dr_npi                       VARCHAR2 (16);

   lab_CLIA                     VARCHAR2 (16);
   lab_tax_id                   VARCHAR2 (12);

   CURSOR diagnosis_list
   IS
        SELECT *
          FROM pcs.lab_req_diagnosis
         WHERE lab_number = claim_lab_number AND rebilling = lab_rebilling
      ORDER BY d_seq;

   diagnosis_fields             diagnosis_list%ROWTYPE;


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

   procedure_fields             procedure_list%ROWTYPE;

   curr_line                    VARCHAR2 (4000);
   cbuf1                        VARCHAR2 (1000);

   cbuf2                        VARCHAR2 (1000);
   cbuf3                        VARCHAR2 (80);
   rcnt                         NUMBER;
   claim_batch_number           NUMBER;
   claim_ebill                  CHAR (1);
   C_tpp                        VARCHAR2 (5);
   C_claims                     NUMBER;
   num_diags                    NUMBER (1);
   last_carrier                 NUMBER;
   resubmitted                  NUMBER;
   C_status                     VARCHAR2 (2);

   x12_fname                    VARCHAR2 (13);

   file_handle                  UTL_FILE.FILE_TYPE;

   --************************************
   sender_id                    VARCHAR2 (15);
   receiver_id                  VARCHAR2 (15);
   trading_id                   VARCHAR2 (32);
   security_id                  VARCHAR2 (32);
   interchange_date             CHAR (6);
   interchange_time             VARCHAR2 (6);
   interchange_number           VARCHAR2 (9);
   interchange_control_header   VARCHAR2 (4000);
   date_today                   CHAR (8);


   functional_group_header      VARCHAR2 (4000);
   transaction_set_header       VARCHAR2 (4000);
   transaction_ref              CHAR (2);
   trx_set_control_num          CHAR (6);
   group_control_num            VARCHAR2 (9);

   NPI_id                       VARCHAR2 (64);

   -- Health Care Provider Taxonomy Code
   PXC_taxonomy_code   CONSTANT VARCHAR2 (50) := '291U00000X';
   -- Place of Service Code for Professional Services
   POS_code            CONSTANT VARCHAR2 (2) := '81';
   -- Implementation Convention Reference

   impl_conv_ref       CONSTANT VARCHAR2 (16) := '005010X222A1';

   insurer_type                 CHAR (2);

   segment_count                NUMBER;
   HL_count                     NUMBER;
BEGIN
   P_proc_name := 'BUILD_BS_X12_FILE';
   P_code_area := 'PREP';

   num_diags := 0;

   last_carrier := 0;

   SELECT COUNT (*)
     INTO C_claims
     FROM pcs.billing_queue
    WHERE billing_route = C_billing_route;

   IF (C_claims > 0 AND C_billing_route <> 'DUP')
   THEN
      IF (C_retran_status = 0)
      THEN
         SELECT pcs.claim_submission_seq.NEXTVAL
           INTO claim_batch_number
           FROM DUAL;

         transaction_ref := '01';
         C_tpp := C_billing_route;
      ELSE
         claim_batch_number := C_retran_status;

         SELECT LTRIM (
                   RTRIM (TO_CHAR ( (MAX (submission_number) + 1), '09')))
           INTO transaction_ref
           FROM pcs.claim_submissions
          WHERE batch_number = claim_batch_number;

         SELECT tpp
           INTO C_tpp
           FROM pcs.claim_batches
          WHERE batch_number = claim_batch_number;
      END IF;
   END IF;

   P_code_area := 'CHECK_NPI';
   pcs.check_npi_numbers (C_billing_route);

   claim_ebill := 'Y';

   IF (C_claims > 0 AND C_billing_route <> 'DUP' AND C_retran_status = 0)
   THEN
      INSERT INTO pcs.claim_batches (batch_number,
                                     e_billing,
                                     number_of_claims,
                                     datestamp,
                                     sys_user,
                                     tpp)
           VALUES (claim_batch_number,
                   claim_ebill,
                   C_claims,
                   SYSDATE,
                   UID,
                   C_tpp);
   END IF;

   SELECT id_number
     INTO receiver_id
     FROM pcs.business_id_nums
    WHERE id_code = 'DASID';

   SELECT id_number
     INTO sender_id
     FROM pcs.business_id_nums
    WHERE id_code = C_tpp;

   SELECT id_number
     INTO lab_CLIA
     FROM pcs.business_id_nums
    WHERE id_code = 'CLIA';

   SELECT id_number
     INTO NPI_id
     FROM pcs.business_id_nums
    WHERE id_code = 'NPI';

   SELECT id_number
     INTO security_id
     FROM pcs.business_id_nums
    WHERE id_code = 'DASSECID';

   SELECT id_number
     INTO trading_id
     FROM pcs.business_id_nums
    WHERE id_code = 'DASTRID';

   SELECT REPLACE (id_number, '-')
     INTO lab_tax_id
     FROM pcs.business_id_nums
    WHERE id_code = 'TAXID';

   HL_count := 1;


   SELECT TO_CHAR (SYSDATE, 'YYMMDD') INTO interchange_date FROM DUAL;

   SELECT TO_CHAR (SYSDATE, 'YYYYMMDD') INTO date_today FROM DUAL;

   SELECT TO_CHAR (SYSDATE, 'HH24MI') INTO interchange_time FROM DUAL;

   interchange_number := LTRIM (RTRIM (TO_CHAR (claim_batch_number)));

   x12_fname :=
         transaction_ref
      || LTRIM (RTRIM (TO_CHAR (claim_batch_number, '000009')));
   DBMS_OUTPUT.ENABLE;
   DBMS_OUTPUT.PUT_LINE ('C_directory = ' || C_directory);
   DBMS_OUTPUT.PUT_LINE ('x12_fname = ' || x12_fname);
   file_handle := UTL_FILE.FOPEN (C_directory, x12_fname, 'w');

   P_code_area := 'HEADERS';
   --   Interchange Control Header (ISA)

   interchange_control_header :=
         'ISA*00*          *00*          *ZZ*'
      || RPAD (security_id, 15)
      || '*33*'
      || RPAD (receiver_id, 15)
      || '*'
      || interchange_date
      || '*'
      || interchange_time
      || '*^*'
      || '00501'
      || '*'
      || LPAD (interchange_number, 9, '0')
      || '*1*'
      || test_indicator
      || '*:~';
   UTL_FILE.PUTF (file_handle, '%s\n', interchange_control_header);

   SELECT RTRIM (LTRIM (TO_CHAR (group_control_num_seq.NEXTVAL)))
     INTO group_control_num
     FROM DUAL;

   -- Functional Group Header (GS)


   functional_group_header :=
         'GS*HC*'
      || RTRIM (trading_id)
      || '*'
      || RTRIM (receiver_id)
      || '*'
      || date_today
      || '*'
      || interchange_time
      || '*'
      || group_control_num
      || '*X*'
      || impl_conv_ref
      || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', functional_group_header);


   -- Transaction Set Header (ST)

   segment_count := 1;

   SELECT RTRIM (LTRIM (TO_CHAR (transet_id_seq.NEXTVAL, '000009')))
     INTO trx_set_control_num
     FROM DUAL;

   transaction_set_header :=
      'ST*837*' || trx_set_control_num || '*' || impl_conv_ref || '~';

   UTL_FILE.PUTF (file_handle, '%s\n', transaction_set_header);


   -- Beginning of Hierarchical Transaction (BHT)

   SELECT TO_CHAR (SYSDATE, 'HH24MISS') INTO interchange_time FROM DUAL;

   IF (transaction_ref = '01')
   THEN
      transaction_ref := '00';
   ELSE
      transaction_ref := '18';
   END IF;

   curr_line :=
         'BHT*0019*'
      || transaction_ref
      || '*'
      || LTRIM (RTRIM (TO_CHAR (claim_batch_number)))
      || '*'
      || date_today
      || '*'
      || interchange_time
      || '*CH~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;

   -- ********* LOOP 1000 SUBMITTER AND RECEIVER INFORMATION

   -- LOOP 1000A SUBMITTER

   --    Submitter Name (NM1)

   curr_line :=
         'NM1*41*2*PENNSYLVANIA CYTOLOGY SERVICES*****46*'
      || RTRIM (trading_id)
      || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;
   -- Submitter EDI Contact Information (PER)
   curr_line := 'PER*IC*LISA RITCHEY*TE*4123738300*FX*4123737027~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;

   -- LOOP 1000B RECEIVER


   --   Receiver Name (NM1)
   curr_line := 'NM1*40*2*HIGHMARK*****46*' || receiver_id || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;

   -- ********* HL - BILLING PROVIDER HIERARCHICAL LEVEL

   -- LOOP 2000A BILLING PROVIDER HIERARCHICAL LEVEL
   curr_line := 'HL*' || TO_CHAR (HL_count) || '**20*1~';
   HL_count := HL_count + 1;
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

   segment_count := segment_count + 1;

   -- Billing Provider Specialty Information (PRV)
   curr_line := 'PRV*BI*PXC*' || PXC_taxonomy_code || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;

   -- LOOP 2010AA BILLING PROVIDER NAME
   curr_line :=
      'NM1*85*2*PENNSYLVANIA CYTOLOGY SERVICES*****XX*' || NPI_id || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;


   -- Billing Provider Address (N3)
   curr_line := 'N3*SUITE 1700 PARKWAY BUILDING*339 OLD HAYMAKER ROAD~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;

   -- Billing Provider City/State/Zip Code (N4)
   curr_line := 'N4*MONROEVILLE*PA*151461447~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;

   -- Billing Provider Tax ID (Now required with Version 5010)

   curr_line := 'REF*EI*' || lab_tax_id || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   segment_count := segment_count + 1;

   P_code_area := 'CLAIMS';

   OPEN claim_list;

   LOOP
      FETCH claim_list
         INTO carrier_idnum,
              carrier_name,
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
              lab_collected,
              claim_lab_number,
              lab_rebilling,
              lab_balance,
              lab_doctor,
              lab_claim_id,
              lab_vials,
              lab_prep;

      EXIT WHEN claim_list%NOTFOUND;


      IF (    C_retran_status = 0
          AND last_carrier = 0
          AND C_billing_route <> 'DUP')
      THEN
         last_carrier := carrier_idnum;

         INSERT INTO pcs.payer_batch_amounts (carrier_id,
                                              batch_number,
                                              amount_submitted,
                                              amount_recorded,
                                              amount_received)
              VALUES (carrier_idnum,
                      claim_batch_number,
                      0,
                      0,
                      0);

         COMMIT;
      END IF;

      resubmitted := 0;

      SELECT COUNT (*)
        INTO resubmitted
        FROM pcs.lab_claims
       WHERE lab_number = claim_lab_number AND claim_id = lab_claim_id;

      IF (resubmitted > 0)
      THEN
         SELECT claim_status
           INTO C_status
           FROM pcs.lab_claims
          WHERE claim_id = lab_claim_id;

         IF (C_status <> 'B')
         THEN
            resubmitted := 0;
         END IF;
      END IF;


      -- values are from old X12 specs
      -- if insurer_type ends up null then policy_subscriber is OTHER
      insurer_type := NULL;

      IF (policy_subscriber = 'SELF')
      THEN
         insurer_type := '18';
      ELSIF (policy_subscriber = 'SPOUSE')
      THEN
         insurer_type := '01';
      ELSIF (policy_subscriber = 'DEPENDENT')
      THEN
         insurer_type := '02';
      END IF;

      -- ********* HL SUBSCRIBER HIERARCHICAL LEVEL

      -- LOOP 2000B SUBSCRIBER HIERARCHICAL LEVEL
      curr_line := 'HL*' || TO_CHAR (HL_count) || '*1*22*';
      HL_count := HL_count + 1;

      IF (policy_subscriber = 'SELF')
      THEN
         curr_line := curr_line || '0~';
      ELSE
         curr_line := curr_line || '1~';
      END IF;

      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      segment_count := segment_count + 1;

      SELECT NVL (SUM (payment_amount), 0)
        INTO patient_payments
        FROM pcs.payments P
       WHERE     P.lab_number = claim_lab_number
             AND P.billing_choice = 121
             AND payment_type NOT IN ('PLUS ADJUST', 'MINUS ADJUST');



      -- Subscriber Information (SBR)
      -- If the group num is null, default to six nines
      IF (policy_group IS NULL)
      THEN
         policy_group := '999999';
      END IF;

      curr_line := 'SBR*P*';

      -- Subscriber and Patient are the same person
      IF (policy_subscriber = 'SELF')
      THEN
         curr_line := curr_line || insurer_type;
      END IF;

      curr_line := curr_line || '*' || RTRIM (policy_group) || '******BL~';
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      segment_count := segment_count + 1;

      -- LOOP 2010BA SUBSCRIBER NAME
      --   Subscriber Name (NM1)
      cbuf1 := pcs.strip_chars (policy_lname);
      cbuf2 := pcs.strip_chars (policy_fname);
      curr_line :=
            'NM1*IL*1*'
         || RTRIM (cbuf1)
         || '*'
         || RTRIM (cbuf2)
         || '****MI*'
         || policy_id
         || '~';
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

      segment_count := segment_count + 1;

      IF (policy_subscriber = 'SELF')
      THEN
         -- Subscriber Address (N3)
         cbuf1 := pcs.strip_chars (patient_addr);
         curr_line := 'N3*' || cbuf1 || '~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         -- Subscriber City/State/Zip Code (N4)
         cbuf1 := pcs.strip_chars (patient_city);

         curr_line :=
               'N4*'
            || cbuf1
            || '*'
            || patient_state
            || '*'
            || patient_zip
            || '~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         -- Subscriber Demographic Information (DMG)
         -- NOTE: Assume F always for sex
         curr_line := 'DMG*D8*' || patient_dob || '*F~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;
      END IF;

      -- LOOP 2010BB PAYER NAME
      --   Payer Name (NM1)

      curr_line := 'NM1*PR*2*HIGHMARK*****PI*' || receiver_id || '~';
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      segment_count := segment_count + 1;

      -- Subscriber and Patient are different people
      IF (policy_subscriber <> 'SELF')
      THEN
         -- Patient Hierarchical Level (HL)
         curr_line :=
               'HL*'
            || TO_CHAR (HL_count)
            || '*'
            || TO_CHAR (HL_count - 1)
            || '*23*0~';

         HL_count := HL_count + 1;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         -- Patient Information (PAT)
         -- Assumes policy subscriber is not SELF
         curr_line := 'PAT*';

         IF (policy_subscriber = 'DEPENDENT')
         THEN
            curr_line := curr_line || '19~';
         ELSIF (policy_subscriber = 'SPOUSE')
         THEN
            curr_line := curr_line || '01~';
         ELSE
            curr_line := curr_line || 'G8~';
         END IF;

         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         -- Patient Name (NM1)
         cbuf1 := pcs.strip_chars (SUBSTR (patient_lname, 1, 20));
         cbuf2 := pcs.strip_chars (SUBSTR (patient_fname, 1, 12));
         curr_line := 'NM1*QC*1*' || cbuf1 || '*' || cbuf2;

         IF (patient_mi IS NOT NULL)
         THEN
            curr_line := curr_line || '*' || patient_mi;
         END IF;

         curr_line := curr_line || '~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         -- Patient Address (N3)
         cbuf1 := pcs.strip_chars (patient_addr);
         curr_line := 'N3*' || cbuf1 || '~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;


         -- Patient City/State/Zip Code (N4)
         cbuf1 := pcs.strip_chars (patient_city);
         curr_line :=
               'N4*'
            || cbuf1
            || '*'
            || patient_state
            || '*'
            || patient_zip
            || '~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         -- Patient Demographic Information (DMG)
         -- Assumes sex is F always
         curr_line := 'DMG*D8*' || patient_dob || '*F~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;
      END IF;

      -- LOOP 2300 CLAIM INFORMATION
      --
      --   Health Care Claim (CLM)
      --   NOTE: claim_total holds lab_billings.bill_amount which is programmed
      --   to hold the sum of all lab_billing_items.item_amount (line items)
      cbuf1 := TO_CHAR (claim_total);
      curr_line :=
            'CLM*'
         || claim_lab_number
         || '*'
         || cbuf1
         || '***'
         || POS_code
         || ':B:1*Y*A*Y*I*P~';
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      segment_count := segment_count + 1;


      -- Patient Amount Paid (AMT)
      IF (patient_payments > 0)
      THEN
         cbuf1 := TO_CHAR (patient_payments);
         curr_line := 'AMT*F5*' || cbuf1 || '~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;
      END IF;

      -- CLIA Number (REF)
      curr_line := 'REF*X4*' || lab_CLIA || '~';

      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      segment_count := segment_count + 1;

      -- Health Care Information Codes (HI)
      -- NOTE: When ICD10 is implemented BK becomes ABK and
      -- BF becomes ABF
      curr_line := 'HI';
      num_diags := 0;

      OPEN diagnosis_list;

      LOOP
         FETCH diagnosis_list INTO diagnosis_fields;

         EXIT WHEN diagnosis_list%NOTFOUND;

         cbuf1 := REPLACE (diagnosis_fields.diagnosis_code, '.');

         IF (diagnosis_fields.d_seq = 1)
         THEN
            cbuf2 := 'BK';
         ELSE
            cbuf2 := 'BF';
         END IF;

         curr_line := curr_line || '*' || cbuf2 || ':' || cbuf1;
         num_diags := num_diags + 1;
      END LOOP;

      CLOSE diagnosis_list;

      curr_line := curr_line || '~';
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      segment_count := segment_count + 1;


      -- LOOP 2310A REFERR
      -- ING PROVIDER NAME
      SELECT lname, fname, npi
        INTO dr_lname, dr_fname, dr_npi
        FROM pcs.doctors
       WHERE doctor = lab_doctor;

      IF (    dr_lname IS NOT NULL
          AND dr_fname IS NOT NULL
          AND dr_npi IS NOT NULL)
      THEN
         curr_line :=
               'NM1*DN*1*'
            || dr_lname
            || '*'
            || dr_fname
            || '****XX*'
            || dr_npi
            || '~';

         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;
      END IF;


      -- ********* LX SERVICE LINE NUMBER
      --       SERVICE LINE LOOP 2400
      rcnt := 1;

      OPEN procedure_list;

      LOOP
         FETCH procedure_list INTO procedure_fields;

         EXIT WHEN procedure_list%NOTFOUND;
         cbuf1 := LTRIM (TO_CHAR (rcnt));
         cbuf2 := LTRIM (TO_CHAR (procedure_fields.item_amount));
         curr_line := 'LX*' || cbuf1 || '~';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         IF (lab_prep = 6)
         THEN
            cbuf3 := RTRIM (LTRIM (TO_CHAR (lab_vials)));
         ELSE
            cbuf3 := '1';
         END IF;

         curr_line :=
               'SV1*HC:'
            || procedure_fields.procedure_code
            || '*'
            || cbuf2
            || '*UN*'
            || cbuf3
            || '***';

         IF (rcnt = 1)
         THEN
            curr_line := curr_line || '1';

            IF (num_diags = 2)
            THEN
               curr_line := curr_line || ':2~';
            ELSIF (num_diags = 3)
            THEN
               curr_line := curr_line || ':2:3~';
            ELSIF (num_diags = 4)
            THEN
               curr_line := curr_line || ':2:3:4~';
            ELSE
               curr_line := curr_line || '~';
            END IF;
         ELSE
            IF (num_diags = 1)
            THEN
               curr_line := curr_line || '1';
            ELSE
               curr_line := curr_line || '2';
            END IF;

            IF (num_diags = 3)
            THEN
               curr_line := curr_line || ':3~';
            ELSIF (num_diags = 4)
            THEN
               curr_line := curr_line || ':3:4~';
            ELSE
               curr_line := curr_line || '~';
            END IF;
         END IF;

         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;

         -- Date of Service (DTP)
         curr_line := 'DTP*472*D8*' || lab_collected || '~';

         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         segment_count := segment_count + 1;
         rcnt := rcnt + 1;
      END LOOP;

      CLOSE procedure_list;

      IF (C_claims > 0 AND C_billing_route <> 'DUP')
      THEN
         IF (C_retran_status > 0)
         THEN
            UPDATE pcs.lab_claims
               SET datestamp = SYSDATE, change_date = SYSDATE
             WHERE claim_id = lab_claim_id;

            UPDATE pcs.billing_details
               SET date_sent = SYSDATE
             WHERE claim_id = lab_claim_id;
         ELSE
            UPDATE pcs.payer_batch_amounts
               SET amount_submitted =
                      amount_submitted + (claim_total - patient_payments)
             WHERE     carrier_id = carrier_idnum
                   AND batch_number = claim_batch_number;

            IF (resubmitted = 0)
            THEN
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
      END IF;
   END LOOP;

   CLOSE claim_list;

   segment_count := segment_count + 1;

   P_code_area := 'TRAILERS';

   -- Transaction Set Trailer
   curr_line := 'SE*' || segment_count || '*' || trx_set_control_num || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

   -- Functional Group Trailer (GE)
   curr_line := 'GE*1*' || group_control_num || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);


   -- Interchange Control Trailer (ISA)
   curr_line := 'IEA*1*' || LPAD (interchange_number, 9, '0') || '~';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

   IF (test_indicator <> 'T')
   THEN
      DELETE FROM pcs.billing_queue
            WHERE billing_route = C_billing_route;

      INSERT INTO pcs.claim_submissions (batch_number,
                                         tpp,
                                         submission_number,
                                         creation_date)
           VALUES (claim_batch_number,
                   C_tpp,
                   TO_NUMBER (transaction_ref),
                   SYSDATE);
   END IF;

   UPDATE pcs.tpps
      SET file_name = x12_fname
    WHERE tpp = C_tpp;

   --**************
   UTL_FILE.FCLOSE (file_handle);
   COMMIT;
EXCEPTION
   WHEN UTL_FILE.INVALID_PATH
   THEN
      UTL_FILE.FCLOSE (file_handle);
      RAISE_APPLICATION_ERROR (-20051, 'invalid path');
   WHEN UTL_FILE.INVALID_MODE
   THEN
      UTL_FILE.FCLOSE (file_handle);
      RAISE_APPLICATION_ERROR (-20052, 'invalid mode');
   WHEN UTL_FILE.INVALID_FILEHANDLE
   THEN
      UTL_FILE.FCLOSE (file_handle);
      RAISE_APPLICATION_ERROR (-20053, 'invalid file handle');
   WHEN UTL_FILE.INVALID_OPERATION
   THEN
      UTL_FILE.FCLOSE (file_handle);
      RAISE_APPLICATION_ERROR (-20054, 'invalid operation');
   WHEN UTL_FILE.READ_ERROR
   THEN
      UTL_FILE.FCLOSE (file_handle);
      RAISE_APPLICATION_ERROR (-20055, 'read error');
   WHEN UTL_FILE.WRITE_ERROR
   THEN
      UTL_FILE.FCLOSE (file_handle);
      RAISE_APPLICATION_ERROR (-20056, 'write error');
   WHEN OTHERS
   THEN
      UTL_FILE.FCLOSE (file_handle);
      P_error_code := SQLCODE;
      P_error_message := SQLERRM;
      claim_lab_number := claim_lab_number;

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
END
\

grant execute on build_bs_x12_file to pcs_user
\
