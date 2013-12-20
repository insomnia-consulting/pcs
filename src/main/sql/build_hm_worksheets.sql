CREATE OR REPLACE PROCEDURE build_hm_worksheets (P_mode       IN NUMBER,
                                                 file_name    IN VARCHAR2,
                                                 server_dir   IN VARCHAR2)
IS
   P_error_code          NUMBER;
   P_error_message       VARCHAR2 (512);
   P_proc_name           VARCHAR2 (32);
   P_code_area           VARCHAR2 (32);
   reportOutput          CLOB;

   PROCESSING   CONSTANT NUMBER := 999;

   CURSOR m_list
   IS
        SELECT *
          FROM pcs.history_match_queue
         WHERE printed = PROCESSING
      ORDER BY lab_number, lab_match DESC
      FOR UPDATE;

   m_fields              m_list%ROWTYPE;

   dir_name              VARCHAR2 (32);
   date_today            CHAR (8);
   curr_lab              NUMBER (11);
   M_date                CHAR (5);
   M_tech                VARCHAR2 (4);
   M_pap_class           VARCHAR2 (4000);
   pclass_num            NUMBER;

   curr_line             VARCHAR2 (100);
   cbuf                  VARCHAR2 (64);
   cbuf2                 VARCHAR2 (32);
   cbuf3                 VARCHAR2 (32);
   P_lname               VARCHAR2 (32);
   P_fname               VARCHAR2 (32);
   P_ssn                 VARCHAR2 (9);
   P_dob                 VARCHAR2 (8);
   P_practice            NUMBER;
   P_name                VARCHAR2 (64);
   file_handle           UTL_FILE.FILE_TYPE;
   line_num              NUMBER (3);
   page_size             NUMBER (3);

   blank_lines           NUMBER (3);
   hpv_result            CHAR (1);

   test_lab              CHAR (20);
   check_point           NUMBER;
   rcnt                  NUMBER;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Starting build_hm_worksheets');
   P_proc_name := 'BUILD_HM_WORKSHEETS';

   P_code_area := 'PROCESSING';

   SET TRANSACTION USE ROLLBACK SEGMENT pcs_rbs5;
   LOCK TABLE pcs.history_match_queue IN ROW EXCLUSIVE MODE;

   UPDATE pcs.history_match_queue
      SET printed = PROCESSING
    WHERE printed = P_mode;

   COMMIT;

   P_code_area := 'PREP';

   SELECT TO_CHAR (SYSDATE, 'YYYYMMDD') INTO date_today FROM DUAL;

   dir_name := server_dir;
   file_handle := UTL_FILE.FOPEN (dir_name, file_name, 'w');
   page_size := 23;

   DELETE FROM pcs.history_match_queue
         WHERE lab_match NOT IN (SELECT lab_number FROM pcs.lab_results);


   P_code_area := 'MATCH';
   curr_lab := 0;
   check_point := 0;
	DBMS_OUTPUT.PUT_LINE('OPENING HISTORY MATCH QUEUE');
   OPEN m_list;

   LOOP
   	  DBMS_OUTPUT.PUT_LINE('LOOPING THROUGH HISTORY MATCH QUEUE');
      FETCH m_list INTO m_fields;

      EXIT WHEN m_list%NOTFOUND;

      -- clear all variables
      P_lname := NULL;
      P_fname := NULL;
      P_dob := NULL;

      P_ssn := NULL;
      P_practice := NULL;
      P_name := NULL;
      M_date := NULL;
      M_tech := NULL;
      M_pap_class := NULL;
      pclass_num := NULL;
      hpv_result := NULL;
      test_lab := TO_CHAR (m_fields.lab_match);

      IF (curr_lab <> m_fields.lab_number)
      THEN
         IF (curr_lab <> 0)
         THEN
            blank_lines := page_size - line_num;

            IF (blank_lines > 0)
            THEN
               UTL_FILE.NEW_LINE (file_handle, blank_lines);
            END IF;
         END IF;

         P_code_area := 'MATCH Q1';

         SELECT lname,
                fname,
                TO_CHAR (dob, 'YYYYMMDD'),
                ssn
           INTO P_lname,
                P_fname,
                P_dob,
                P_ssn
           FROM pcs.patients p, pcs.lab_requisitions l
          WHERE l.patient = p.patient AND l.lab_number = m_fields.lab_number;

         P_code_area := 'MATCH Q2';

         SELECT p.practice, p.name
           INTO P_practice, P_name
           FROM pcs.practices p, pcs.lab_requisitions l
          WHERE     l.practice = p.practice
                AND l.lab_number = m_fields.lab_number;

         cbuf := TO_CHAR (m_fields.lab_number, '9999999999');

         curr_line := 'LAB NUMBER: ' || cbuf;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

         cbuf := RTRIM (P_lname) || ', ' || RTRIM (P_fname);
         cbuf3 := NULL;

         IF (P_dob IS NOT NULL OR P_ssn IS NOT NULL)
         THEN
            IF (P_dob IS NOT NULL)
            THEN
               IF (P_ssn IS NOT NULL)
               THEN
                  cbuf2 := P_dob || '.' || P_ssn;
               ELSE
                  cbuf2 := P_dob;
               END IF;
            ELSE
               IF (P_ssn IS NOT NULL)
               THEN
                  cbuf2 := P_ssn;
               END IF;
            END IF;
         END IF;

         IF (cbuf2 IS NOT NULL)
         THEN
            cbuf3 := '  [' || cbuf2 || ']';
         END IF;

         curr_line := 'PATIENT:	  ' || cbuf || cbuf3;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         cbuf := TO_CHAR (P_practice, '099');
         cbuf := cbuf || ' ' || RTRIM (P_name);
         curr_line := 'ACCOUNT:	 ' || cbuf;
         UTL_FILE.PUTF (file_handle, '%s\n\n', curr_line);

         curr_line := 'PRIOR PA CYTOLOGY RESULTS';
         UTL_FILE.PUTF (file_handle, '%s\n\n', curr_line);

         curr_line := 'DATE   LAB NUMBER	TECH	RESULTS';
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

         line_num := 8;
      END IF;

      P_code_area := 'MATCH Q3';

      SELECT COUNT (*)
        INTO rcnt
        FROM pcs.lab_results r, pcs.cytotechs c, pcs.pap_classes pc
       WHERE     r.cytotech = c.cytotech
             AND r.pap_class = pc.pap_class
             AND r.lab_number = m_fields.lab_match;

      IF (rcnt > 0)
      THEN
         SELECT TO_CHAR (r.date_completed, 'MM-DD'),
                c.cytotech_code,
                SUBSTR (pc.description, 1, 29),
                r.pap_class
           INTO M_date,
                M_tech,
                M_pap_class,
                pclass_num
           FROM pcs.lab_results r, pcs.cytotechs c, pcs.pap_classes pc
          WHERE     r.cytotech = c.cytotech
                AND r.pap_class = pc.pap_class
                AND r.lab_number = m_fields.lab_match;

         IF (6 - m_fields.m_level >= 1)
         THEN
            curr_line :=
                  M_date
               || '  '
               || TO_CHAR (m_fields.lab_match)
               || '  '
               || M_tech
               || '  '
               || TO_CHAR (6 - m_fields.m_level)
               || '  '
               || M_pap_class;
            rcnt := 0;

            SELECT COUNT (*)
              INTO rcnt
              FROM pcs.hpv_requests
             WHERE lab_number = m_fields.lab_match;

            IF (rcnt > 0)
            THEN
               SELECT test_results
                 INTO hpv_result
                 FROM pcs.hpv_requests
                WHERE lab_number = m_fields.lab_match;

               IF (hpv_result IS NOT NULL)
               THEN
                  curr_line := curr_line || '  [HPV ' || hpv_result || ' ]';
               END IF;
            END IF;

            -- pap class 17 is tissue biopsy
            IF (pclass_num = 17)
            THEN
               curr_line := curr_line || '	[PLEASE PRINT REPORT]';
            END IF;

            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

            line_num := line_num + 1;
         END IF;
      END IF;

      DELETE FROM pcs.history_match_queue
            WHERE CURRENT OF m_list;

      curr_lab := m_fields.lab_number;
   END LOOP;

   CLOSE m_list;

   -- *****************
   UPDATE pcs.job_control
      SET job_status = 0
    WHERE job_descr = 'MATCH_COUNT';

   UTL_FILE.PUT (file_handle, CHR (12));

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
                   m_fields.lab_number);

      COMMIT;
END ; 
\
grant execute on pcs.build_hm_worksheets to pcs_user
\
