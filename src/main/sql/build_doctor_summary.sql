CREATE OR REPLACE PROCEDURE build_doctor_summary (S_practice   IN NUMBER,
                                                  S_month      IN NUMBER)
AS
   P_error_code                            NUMBER;
   P_error_message                         VARCHAR2 (512);
   P_proc_name                             VARCHAR2 (32);
   P_code_area                             VARCHAR2 (32);

   -- Account variables

   P_name                                  VARCHAR2 (512);
   P_address1                              VARCHAR2 (64);
   P_address2                              VARCHAR2 (64);
   P_city                                  VARCHAR2 (32);
   P_state                                 CHAR (2);
   P_zip                                   VARCHAR2 (9);
   P_csz                                   VARCHAR2 (80);
   P_parent                                NUMBER (6);
   P_e_reporting                           CHAR (1);
   P_program                               VARCHAR2 (16);
   P_type                                  VARCHAR2 (32);
   P_print_doctors                         CHAR (1);
   P_print_hpv                             CHAR (1);

   -- Patient variables

   PT_lab_number                           NUMBER;
   PT_name                                 VARCHAR2 (128);
   PT_DOS                                  VARCHAR2 (16);
   PT_doctor                               VARCHAR2 (128);
   PT_id                                   VARCHAR2 (32);
   PT_SSN                                  VARCHAR2 (16);
   PT_DOB                                  VARCHAR2 (16);

   -- PAP Class and Result variables
   PC_current                              NUMBER;
   PC_previous                             NUMBER;

   PC_description                          VARCHAR2 (512);
   PC_count                                NUMBER;
   PC_six_month_count                      NUMBER;
   PC_total                                NUMBER;
   PC_six_month_total                      NUMBER;
   PC_percent                              NUMBER;
   LR_no_ecc                               NUMBER;
   LR_code                                 VARCHAR2 (4);

   -- HPV variables
   HPV_sent                                CHAR (1);
   HPV_results                             CHAR (1);

   HPV_txt                                 CHAR (1);

   -- PCS variables
   LAB_name                                VARCHAR2 (80);
   LAB_addr1                               VARCHAR2 (80);
   LAB_addr2                               VARCHAR2 (80);
   LAB_csz                                 VARCHAR2 (80);
   LAB_phone                               VARCHAR2 (80);

   -- Report and misc. variables
   LINE_LENGTH                    CONSTANT NUMBER := 80;

   PAGE_LENGTH                    CONSTANT NUMBER := 60;
   MIN_CATEGORY_LENGTH            CONSTANT NUMBER := 13;
   BOTTOM_MARGIN                  CONSTANT NUMBER := 4;
   PAGE_txt                                VARCHAR2 (80);
   CLIENT_NUMBER_txt                       VARCHAR2 (80);
   PERIOD_ENDING_txt                       VARCHAR2 (80);
   REPORT_TITLE_txt                        VARCHAR2 (80);
   DESCRIPTION_txt                         VARCHAR2 (80);
   TOTAL_txt                               VARCHAR2 (80);
   char_buffer                             VARCHAR2 (256);
   curr_line                               VARCHAR2 (256);
   line_num                                NUMBER;
   curr_page                               NUMBER;

   column_heading                          VARCHAR2 (96);
   long_line                               VARCHAR2 (128);
   short_line                              VARCHAR2 (32);
   ndx                                     NUMBER;
   offset                                  NUMBER;
   report_style                            NUMBER;
   is_continued                            NUMBER;
   S_month_low                             NUMBER;
   t_date                                  DATE;
   u_flag                                  NUMBER;

   -- Report style constants

   NO_PRINT                       CONSTANT NUMBER := 100;
   STANDARD                       CONSTANT NUMBER := 101;
   STANDARD_WITH_DOCTOR           CONSTANT NUMBER := 102;
   STANDARD_WITH_HPV              CONSTANT NUMBER := 103;
   STANDARD_WITH_DOCTOR_AND_HPV   CONSTANT NUMBER := 104;
   ACCOUNT_082                    CONSTANT NUMBER := 201;
   ADPH                           CONSTANT NUMBER := 301;
   ADPH_WITH_HPV                  CONSTANT NUMBER := 302;

   -- File variables
   file_handle                             UTL_FILE.FILE_TYPE;
   directory_name                          VARCHAR2 (256);
   wv_directory_name                       VARCHAR2 (256);

   print_file_name                         VARCHAR2 (256);
   trans_file_name                         VARCHAR2 (256);
   file_extension                          VARCHAR2 (256);

   CURSOR pap_class_list
   IS
        SELECT LR.pap_class, COUNT (LR.pap_class)
          FROM pcs.lab_results LR, pcs.practice_statement_labs PSL
         WHERE     LR.lab_number = PSL.lab_number
               AND PSL.practice = S_practice
               AND PSL.statement_id = S_month
               AND PSL.prac_2 = 0
      GROUP BY LR.pap_class;

   CURSOR lab_list
   IS
        SELECT PSL.lab_number,
               PSL.patient_name,
               TO_CHAR (PSL.date_collected, 'MM/DD/YYYY'),
               LQ.doctor_text,
               LQ.patient_id,
                  SUBSTR (PT.SSN, 1, 3)
               || '-'
               || SUBSTR (PT.SSN, 4, 2)
               || '-'
               || SUBSTR (PT.SSN, 6),
               TO_CHAR (PT.DOB, 'MM/DD/YYYY'),
               PC.tmp_num,
               PC.description,
               HPV.test_sent,
               HPV.test_results,
               LR.pap_class
          FROM pcs.practice_statement_labs PSL,
               pcs.lab_requisitions LQ,
               pcs.patients PT,
               pcs.pap_classes PC,
               pcs.hpv_requests HPV,
               pcs.lab_results LR
         WHERE     PSL.lab_number = LQ.lab_number
               AND PSL.lab_number = LR.lab_number
               AND PSL.lab_number = HPV.lab_number(+)
               AND LQ.patient = PT.patient
               AND LR.pap_class = PC.pap_class
               AND PSL.practice = S_practice
               AND PSL.statement_id = S_month
               AND PSL.prac_2 = 0
               AND LR.pap_class > 0
               AND LR.pap_class < 16
      ORDER BY PC.reporting_sort, PSL.patient_name;

   CURSOR six_month_list
   IS
        SELECT pap_class, description, tmp_num
          FROM pcs.pap_classes
         WHERE pap_class > 0 AND pap_class < 17
      ORDER BY reporting_sort;


   CURSOR adequacy_list
   IS
        SELECT bethesda_code,
               pap_class,
               description,
               one_month,
               six_month
          FROM pcs.adequacy_result_codes
      ORDER BY bethesda_code;
BEGIN
   P_proc_name := 'BUILD_DOCTOR_SUMMARY';
   P_code_area := 'PREP';

   -- Initialize Lab heading variables
   LAB_name := 'PENNSYLVANIA CYTOLOGY SERVICES';

   LAB_addr1 := 'SUITE 1700 PARKWAY BUILDING';
   LAB_addr2 := '339 OLD HAYMAKER ROAD';
   LAB_csz := 'MONROEVILLE, PA  15146-1477';
   LAB_phone := 'PHONE: 412-373-8300';

   P_code_area := 'GET ACCT DATA';

   -- Retrieve account data
   SELECT name,
          address1,
          address2,
          city,
          state,
          SUBSTR (zip, 1, 5),
          parent_account,
          practice_type,
          e_reporting,
          program,
          hpv_on_summary,
          print_doctors
     INTO P_name,
          P_address1,
          P_address2,
          P_city,
          P_state,
          P_zip,
          P_parent,
          P_type,
          P_e_reporting,
          P_program,
          P_print_hpv,
          P_print_doctors
     FROM pcs.practices
    WHERE practice = S_practice;

   P_csz := P_city || ', ' || P_state || '  ' || P_zip;

   P_code_area := 'INIT REPT VARS';
   -- Initialize report formatting variables
   curr_page := 0;
   is_continued := 0;
   PAGE_txt := 'PAGE ';
   CLIENT_NUMBER_txt := 'CLIENT NUMBER: ';
   PERIOD_ENDING_txt := 'PERIOD ENDING: ';
   REPORT_TITLE_txt := 'SUMMARY OF CYTOLOGY FINDINGS';
   DESCRIPTION_txt := 'DESCRIPTION: ';

   TOTAL_txt := 'TOTAL: ';

   char_buffer := TO_CHAR (S_practice, '009');
   CLIENT_NUMBER_txt := CLIENT_NUMBER_txt || char_buffer;

   char_buffer :=
      TO_CHAR (LAST_DAY (TO_DATE (TO_CHAR (S_month), 'YYYYMM')),
               'MM/DD/YYYY');
   PERIOD_ENDING_txt := PERIOD_ENDING_txt || char_buffer;

   P_code_area := 'SET REPT STYLE';
   -- Column data varies depending on the needs of the client. For
   --    all intents and purposes this is controlled by options set
   --    in the account profile. The exceptions are account 082
   --    and ADPH accounts in which their special needs are

   --    hard-coded - unfortunately.
   report_style := NO_PRINT;

   IF (S_practice = 82)
   THEN
      report_style := ACCOUNT_082;
      column_heading := 'DOB	     PATIENT		       DATE	     DOCTOR';
   ELSIF (P_type = 'ADPH')
   THEN
      report_style := ADPH;
      column_heading := 'LAB NUMBER	PATIENT 		  DATE		PATIENT ID';

      IF (P_print_hpv = 'Y')
      THEN
         report_style := ADPH_WITH_HPV;
         column_heading := column_heading || LPAD ('HPV', 16);
      END IF;
   ELSIF (P_print_doctors = 'Y')
   THEN
      report_style := STANDARD_WITH_DOCTOR;
      column_heading := 'LAB NUMBER    PATIENT		       DATE	     DOCTOR';

      IF (P_print_hpv = 'Y')
      THEN
         report_style := STANDARD_WITH_DOCTOR_AND_HPV;
         column_heading := column_heading || LPAD ('HPV', 20);
      END IF;
   ELSE
      report_style := STANDARD;
      column_heading := 'LAB NUMBER	     PATIENT			      DATE';

      IF (P_print_hpv = 'Y')
      THEN
         report_style := STANDARD_WITH_HPV;

         column_heading := column_heading || LPAD ('HPV', 20);
      END IF;
   END IF;

   IF (report_style = NO_PRINT)
   THEN
      GOTO exit_point;
   END IF;

   ndx := 0;
   long_line := '-';

   FOR ndx IN 1 .. (LINE_LENGTH - 1)
   LOOP
      long_line := long_line || '-';
   END LOOP;

   short_line := '------------------';


   P_code_area := 'CALC MONTH TTLS';

   -- Calculate monthly totals and store value
   --    in tmp_num field of pap_class table.
   UPDATE pcs.pap_classes
      SET tmp_num = 0;

   OPEN pap_class_list;

   LOOP
      FETCH pap_class_list
         INTO PC_current, PC_count;

      EXIT WHEN pap_class_list%NOTFOUND;

      UPDATE pcs.pap_classes
         SET tmp_num = PC_count
       WHERE pap_class = PC_current;
   END LOOP;

   CLOSE pap_class_list;

   COMMIT;

   P_code_area := 'ABSORB PCLASS 0->10';

   -- Assumption is made that any lab that
   --    has an unknown pap_class is a non-gyn;
   --    therefore 0 and 10 are combined.
   SELECT tmp_num
     INTO PC_count
     FROM pcs.pap_classes
    WHERE pap_class = 0;

   UPDATE pcs.pap_classes
      SET tmp_num = 0
    WHERE pap_class = 0;

   UPDATE pcs.pap_classes
      SET tmp_num = tmp_num + PC_count
    WHERE pap_class = 10;

   COMMIT;

   SELECT COUNT (*)
     INTO PC_count
     FROM pcs.practice_statement_labs PSL, lab_results LR
    WHERE     PSL.lab_number = LR.lab_number
          AND PSL.statement_id = S_month
          AND PSL.practice = S_practice
          AND PSL.prac_2 = 0
          AND LR.limited = 1;

   UPDATE pcs.pap_classes
      SET tmp_num = PC_count
    WHERE pap_class = 16;

   COMMIT;

   P_code_area := 'OPEN FILE';
   -- Open file for report.
   --    Format for report name is <ACT><MM><C><YY>.file_extension;
   --    as of this writing the file extension for this report
   --    is ?sum.?

   --    EXAMPLE: Suppose this report is being ran for
   --    Account #567 for August, 2009. Then:

   --   <ACT> = 567
   --   <MM>  = 08
   --   <C>   = 2
   --   <YY>  = 09
   --    so the file name would be:  56708209.sum
   directory_name := 'REPORTS_DIR';
   wv_directory_name := 'WV_REPORTS_DIR';
   file_extension := '.sum';

   -- Need to decide here if the file needs to be printed
   -- Those need printed are not marked as 'N', 'B' needs printed and transmitted, 'Y' is just transmitted
   -- prepare both filenames.. if e_reporting is a 'B' then at the end of the procedure we copy from one file to the other; otherwise, we just use one filename
   trans_file_name :=
         LTRIM (RTRIM (TO_CHAR (P_parent, '009')))
      || '_'
      || P_program
      || '_'
      || SUBSTR (TO_CHAR (S_month), 1, 4)
      || SUBSTR (TO_CHAR (S_month), 5, 2)
      || file_extension;
   print_file_name :=
         LTRIM (RTRIM (TO_CHAR (S_practice, '009')))
      || SUBSTR (TO_CHAR (S_month), 5, 2)
      || SUBSTR (TO_CHAR (S_month), 1, 1)
      || SUBSTR (TO_CHAR (S_month), 3, 2)
      || file_extension;

   IF (P_e_reporting = 'Y' OR P_e_reporting = 'B')
   THEN
      --TRANSMITTED

      file_handle := UTL_FILE.FOPEN (wv_directory_name, trans_file_name, 'w');
   ELSE
      --PRINTED
      -- Does a weird thing with S_month to get a 3 digit year.

      file_handle := UTL_FILE.FOPEN (directory_name, print_file_name, 'w');
   END IF;

   P_code_area := 'WRITE PG1 HEADING';
   -- This is the first page heading.
   --    It will take (14) lines; (13) if the account
   --    does not use a two line address.
   curr_page := 1;
   line_num := 15;
   char_buffer := LTRIM (RTRIM (TO_CHAR (curr_page)));
   offset := LINE_LENGTH - LENGTH (REPORT_TITLE_txt);
   curr_line :=
      REPORT_TITLE_txt || LPAD ( (PAGE_txt || ' ' || char_buffer), offset);
   UTL_FILE.PUTF (file_handle, '\n%s\n\n\n', curr_line);

   UTL_FILE.PUTF (file_handle, '%s\n', LAB_name);
   UTL_FILE.PUTF (file_handle, '%s\n', LAB_addr1);
   UTL_FILE.PUTF (file_handle, '%s\n', LAB_addr2);
   UTL_FILE.PUTF (file_handle, '%s\n', LAB_csz);
   UTL_FILE.PUTF (file_handle, '%s\n\n', LAB_phone);
   char_buffer := '   ' || P_name;
   offset := LINE_LENGTH - LENGTH (PERIOD_ENDING_txt);
   curr_line := RPAD (char_buffer, offset) || CLIENT_NUMBER_txt;
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   char_buffer := '   ' || P_address1;
   curr_line := RPAD (char_buffer, offset) || PERIOD_ENDING_txt;
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

   IF (P_address2 IS NOT NULL)
   THEN
      curr_line := '   ' || P_address2;
      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      line_num := 16;
   END IF;

   curr_line := '   ' || P_csz;
   UTL_FILE.PUTF (file_handle, '%s\n\n', curr_line);

   PC_previous := 0;
   P_code_area := 'OPEN LAB_LIST';

   OPEN lab_list;

   LOOP
      P_code_area := 'LOOP TOP';

      FETCH lab_list
         INTO PT_lab_number,
              PT_name,
              PT_DOS,
              PT_doctor,
              PT_id,
              PT_SSN,
              PT_DOB,
              PC_count,
              PC_description,
              HPV_sent,
              HPV_results,
              PC_current;

      EXIT WHEN lab_list%NOTFOUND;
      P_code_area := 'AFTER FETCH';
      P_code_area := 'LAB_LIST: ' || TO_CHAR (PT_lab_number);
      LR_no_ecc := pcs.is_no_ecc (PT_lab_number);
      HPV_txt := ' ';

      IF (P_print_hpv = 'Y')
      THEN
         IF (HPV_sent IS NOT NULL)
         THEN
            IF (HPV_sent = 'Q')
            THEN
               HPV_txt := HPV_sent;
            ELSIF (HPV_sent = 'Y')
            THEN
               HPV_txt := HPV_results;
            END IF;
         END IF;
      END IF;

      IF (PC_previous <> PC_current)
      THEN
         IF ( (PAGE_LENGTH - line_num) < MIN_CATEGORY_LENGTH)
         THEN
            line_num := line_num + (MIN_CATEGORY_LENGTH - BOTTOM_MARGIN);
         END IF;
      END IF;

      IF ( (PAGE_LENGTH - line_num) < BOTTOM_MARGIN)
      THEN
         UTL_FILE.PUTF (file_handle, '\n%s\n', long_line);
         curr_page := curr_page + 1;
         UTL_FILE.PUT (file_handle, CHR (12));

         char_buffer := LTRIM (RTRIM (TO_CHAR (curr_page)));
         offset := LINE_LENGTH - LENGTH (REPORT_TITLE_txt);
         curr_line :=
               REPORT_TITLE_txt
            || LPAD ( (PAGE_txt || ' ' || char_buffer), offset);
         UTL_FILE.PUTF (file_handle, '\n%s\n\n\n', curr_line);
         UTL_FILE.PUTF (file_handle, '%s\n', LAB_name);
         UTL_FILE.PUTF (file_handle, '%s\n', CLIENT_NUMBER_txt);
         UTL_FILE.PUTF (file_handle, '%s\n\n', PERIOD_ENDING_txt);
         line_num := 9;

         IF (PC_previous = PC_current)
         THEN
            is_continued := 1;
         END IF;
      END IF;

      IF (PC_previous <> PC_current OR is_continued = 1)
      THEN
         -- Print category subheading.
         --    This normally uses (7) lines;
         --    if the is_continued flag is set it means that
         --    data in the current category is no two separate
         --    pages, and a CONT'D message is printed instead
         --    and the category subheading only takes (6) lines.
         PC_previous := PC_current;
         UTL_FILE.PUTF (file_handle, '%s\n\n', long_line);

         IF (is_continued = 1)
         THEN
            curr_line := PC_description || ', CONT''D';
            UTL_FILE.PUTF (file_handle, '%s\n\n', curr_line);
            line_num := line_num + 6;
         ELSE
            curr_line := RPAD (DESCRIPTION_txt, 14) || PC_description;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
            curr_line :=
               RPAD (TOTAL_txt, 14) || LTRIM (RTRIM (TO_CHAR (PC_count)));
            UTL_FILE.PUTF (file_handle, '%s\n\n', curr_line);
            line_num := line_num + 7;
         END IF;

         UTL_FILE.PUTF (file_handle, '%s\n', column_heading);
         UTL_FILE.PUTF (file_handle, '%s\n', long_line);
      END IF;

      IF (report_style = STANDARD)
      THEN
         curr_line :=
               RPAD (LTRIM (RTRIM (TO_CHAR (PT_lab_number))), 22)
            || RPAD (SUBSTR (PT_name, 1, 22), 34)
            || PT_DOS;
      ELSIF (report_style = STANDARD_WITH_HPV)
      THEN
         curr_line :=
               RPAD (LTRIM (RTRIM (TO_CHAR (PT_lab_number))), 22)
            || RPAD (SUBSTR (PT_name, 1, 22), 34)
            || RPAD (PT_DOS, 22)
            || HPV_txt;
      ELSIF (report_style = STANDARD_WITH_DOCTOR)
      THEN
         curr_line :=
               RPAD (LTRIM (RTRIM (TO_CHAR (PT_lab_number))), 14)
            || RPAD (SUBSTR (PT_name, 1, 22), 26)
            || RPAD (PT_DOS, 14)
            || SUBSTR (PT_doctor, 1, 22);
      ELSIF (report_style = STANDARD_WITH_DOCTOR_AND_HPV)
      THEN
         curr_line :=
               RPAD (LTRIM (RTRIM (TO_CHAR (PT_lab_number))), 14)
            || RPAD (SUBSTR (PT_name, 1, 22), 26)
            || RPAD (PT_DOS, 14)
            || RPAD (SUBSTR (PT_doctor, 1, 22), 24)
            || HPV_txt;
      ELSIF (report_style = ADPH)
      THEN
         IF (LR_no_ecc = 1)
         THEN
            char_buffer := '*';
         ELSE
            char_buffer := ' ';
         END IF;

         char_buffer := char_buffer || LTRIM (RTRIM (TO_CHAR (PT_lab_number)));
         curr_line :=
               RPAD (char_buffer, 14)
            || RPAD (SUBSTR (PT_name, 1, 22), 26)
            || RPAD (PT_DOS, 14)
            || SUBSTR (PT_id, 1, 22);
      ELSIF (report_style = ADPH_WITH_HPV)
      THEN
         IF (LR_no_ecc = 1)
         THEN
            char_buffer := '*';
         ELSE
            char_buffer := ' ';
         END IF;

         char_buffer := char_buffer || LTRIM (RTRIM (TO_CHAR (PT_lab_number)));
         curr_line :=
               RPAD (char_buffer, 14)
            || RPAD (SUBSTR (PT_name, 1, 22), 26)
            || RPAD (PT_DOS, 14)
            || RPAD (SUBSTR (PT_id, 1, 22), 24)
            || HPV_txt;
      ELSIF (report_style = ACCOUNT_082)
      THEN
         curr_line :=
               RPAD (PT_DOB, 14)
            || RPAD (SUBSTR (PT_name, 1, 22), 26)
            || RPAD (PT_DOS, 14)
            || SUBSTR (PT_doctor, 1, 22);
      END IF;

      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      line_num := line_num + 1;
      is_continued := 0;
   END LOOP;

   CLOSE lab_list;


   t_date := LAST_DAY (TO_DATE (TO_CHAR (S_month), 'YYYYMM')) + 1;
   t_date := ADD_MONTHS (t_date, -6);
   S_month_low := TO_NUMBER (TO_CHAR (t_date, 'YYYYMM'));

   P_code_area := 'SUMMARY PAGES';
   UTL_FILE.PUTF (file_handle, '\n%s\n', long_line);
   curr_page := curr_page + 1;
   UTL_FILE.PUT (file_handle, CHR (12));
   char_buffer := LTRIM (RTRIM (TO_CHAR (curr_page)));
   offset := LINE_LENGTH - LENGTH (REPORT_TITLE_txt);
   curr_line :=
      REPORT_TITLE_txt || LPAD ( (PAGE_txt || ' ' || char_buffer), offset);
   UTL_FILE.PUTF (file_handle, '%s\n\n\n', curr_line);

   UTL_FILE.PUTF (file_handle, '%s\n', LAB_name);
   UTL_FILE.PUTF (file_handle, '%s\n', CLIENT_NUMBER_txt);
   UTL_FILE.PUTF (file_handle, '%s\n\n', PERIOD_ENDING_txt);
   UTL_FILE.PUTF (file_handle, '%s\n', long_line);
   char_buffer := LPAD ('MONTHLY TOTALS', 59);
   curr_line := char_buffer || LPAD ('SIX-MONTH TOTALS', 20);
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   char_buffer := LPAD (short_line, 61);
   curr_line := char_buffer || ' ' || short_line;
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

   SELECT SUM (tmp_num)
     INTO PC_total
     FROM pcs.pap_classes
    WHERE pap_class > 0 AND pap_class < 16;

   SELECT COUNT (*)
     INTO PC_six_month_total
     FROM pcs.lab_results LR,
          pcs.practice_statement_labs PSL,
          pcs.pap_classes PC
    WHERE     LR.lab_number = PSL.lab_number
          AND PC.pap_class = LR.pap_class(+)
          AND PSL.practice = S_practice
          AND PSL.statement_id >= S_month_low
          AND PSL.statement_id <= S_month
          AND PSL.prac_2 = 0
          AND LR.pap_class > 0
          AND LR.pap_class < 16;


   P_code_area := 'OPEN SIX_MONTH_LIST';

   OPEN six_month_list;

   LOOP
      FETCH six_month_list
         INTO PC_current, PC_description, PC_count;

      EXIT WHEN six_month_list%NOTFOUND;
      P_code_area := 'SIX_MONTH_LIST: ' || TO_CHAR (PC_current);

      IF (PC_current = 16)
      THEN
         SELECT COUNT (*)
           INTO PC_six_month_count
           FROM pcs.practice_statement_labs PSL, lab_results LR
          WHERE     PSL.lab_number = LR.lab_number
                AND PSL.practice = S_practice
                AND PSL.statement_id >= S_month_low
                AND PSL.statement_id <= S_month
                AND PSL.prac_2 = 0
                AND LR.limited = 1;
      ELSE
         SELECT COUNT (*)
           INTO PC_six_month_count
           FROM pcs.practice_statement_labs PSL, lab_results LR
          WHERE     PSL.lab_number = LR.lab_number
                AND PSL.practice = S_practice
                AND PSL.statement_id >= S_month_low
                AND PSL.statement_id <= S_month
                AND PSL.prac_2 = 0
                AND LR.pap_class = PC_current;
      END IF;

      IF (PC_current IN (3, 4, 12))
      THEN
         PC_description := '     ' || PC_description;
      END IF;

      IF (LENGTH (PC_description) > 40)
      THEN
         PC_description := SUBSTR (PC_description, 1, 40) || '...';
      END IF;

      curr_line := RPAD (PC_description, 43);
      char_buffer := LPAD (TO_CHAR (PC_count), 6);
      curr_line := curr_line || char_buffer;

      IF (PC_total > 0)
      THEN
         PC_percent := (PC_count / PC_total) * 100;
      ELSE
         PC_percent := 0;
      END IF;

      char_buffer := LPAD (TO_CHAR (PC_percent, '990.00') || ' %', 11);
      curr_line := curr_line || char_buffer;
      char_buffer := LPAD (TO_CHAR (PC_six_month_count), 8);
      curr_line := curr_line || char_buffer;

      IF (PC_six_month_total > 0)
      THEN
         PC_percent := (PC_six_month_count / PC_six_month_total) * 100;
      ELSE
         PC_percent := 0;
      END IF;

      char_buffer := LPAD (TO_CHAR (PC_percent, '990.00') || ' %', 11);
      curr_line := curr_line || char_buffer;

      UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   END LOOP;

   CLOSE six_month_list;

   char_buffer := LPAD (short_line, 61);
   curr_line := char_buffer || ' ' || short_line;
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   curr_line := LPAD (TO_CHAR (PC_total), 49);
   char_buffer := LPAD ('100.00 %', 11);
   curr_line := curr_line || char_buffer;
   char_buffer := LPAD (TO_CHAR (PC_six_month_total), 8);
   curr_line := curr_line || char_buffer;
   char_buffer := LPAD ('100.00 %', 11);

   curr_line := curr_line || char_buffer;
   UTL_FILE.PUTF (file_handle, '%s\n\n', curr_line);
   curr_line := RPAD ('ADEQUACY BREAKDOWN', 45);
   char_buffer := '(PERCENTAGES BASED ON TOTALS ABOVE)';
   curr_line := curr_line || char_buffer;
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
   UTL_FILE.PUTF (file_handle, '%s\n', long_line);
   curr_line := 'SATISFACTORY FOR EVALUATION:';
   UTL_FILE.PUTF (file_handle, '%s\n', curr_line);

   P_code_area := 'OPEN ADEQUACY_LIST';
   u_flag := 0;

   OPEN adequacy_list;

   LOOP
      FETCH adequacy_list
         INTO LR_code,
              PC_current,
              PC_description,
              PC_count,
              PC_six_month_count;

      EXIT WHEN adequacy_list%NOTFOUND;
      P_code_area := 'ADEQUACY_LIST: ' || LR_code;
      PC_description :=
         REPLACE (PC_description, 'SATISFACTORY FOR EVALUATION, ');
      PC_description :=
         REPLACE (
            PC_description,
            'SPECIMEN PROCESSED AND EXAMINED, BUT UNSATISFACTORY FOR EVALUATION ');

      IF (PC_current = 1 AND u_flag = 0)
      THEN
         u_flag := 1;
      END IF;

      IF (u_flag = 1)
      THEN
         UTL_FILE.PUTF (file_handle, '\n%s\n', 'UNSATISFACTORY:');
         u_flag := (-1);
      END IF;

      char_buffer := LPAD (TO_CHAR (PC_count), 6);

      IF (PC_total > 0)
      THEN
         PC_percent := (PC_count / PC_total) * 100;
      ELSE
         PC_percent := 0;
      END IF;

      char_buffer :=
         char_buffer || LPAD (TO_CHAR (PC_percent, '990.00') || ' %', 11);
      char_buffer := char_buffer || LPAD (TO_CHAR (PC_six_month_count), 8);

      IF (PC_six_month_total > 0)
      THEN
         PC_percent := (PC_six_month_count / PC_six_month_total) * 100;
      ELSE
         PC_percent := 0;
      END IF;

      char_buffer :=
         char_buffer || LPAD (TO_CHAR (PC_percent, '990.00') || ' %', 11);

      IF (LENGTH (PC_description) > 40)
      THEN
         P_name := PC_description;
         offset := 0;
         is_continued := 0;

         WHILE (LENGTH (P_name) > 40)
         LOOP
            FOR ndx IN 1 .. 40
            LOOP
               IF (SUBSTR (P_name, ndx, 1) = ' ')
               THEN
                  offset := ndx;
               END IF;
            END LOOP;

            DESCRIPTION_txt := SUBSTR (P_name, 1, offset);
            P_name := LTRIM (RTRIM (SUBSTR (P_name, offset)));
            P_name := '	  ' || P_name;

            IF (is_continued = 0)
            THEN
               curr_line := RPAD (DESCRIPTION_txt, 43) || char_buffer;
               is_continued := 1;
            ELSE
               curr_line := RPAD (DESCRIPTION_txt, 43);
            END IF;

            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
            is_continued := 1;
         END LOOP;

         IF (NVL (LENGTH (P_name), 0) > 0)
         THEN
            curr_line := P_name;
            UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
         END IF;
      ELSE
         curr_line := RPAD (PC_description, 43) || char_buffer;
         UTL_FILE.PUTF (file_handle, '%s\n', curr_line);
      END IF;
   END LOOP;	

   CLOSE adequacy_list;

   UTL_FILE.PUT (file_handle, CHR (12));

   UTL_FILE.FCLOSE (file_handle);

   IF (P_e_reporting = 'B')
   THEN
      UTL_FILE.FCOPY (wv_directory_name,
                      trans_file_name,
                      directory_name,
                      print_file_name);
   END IF;

  <<exit_point>>
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
                   S_practice);
      COMMIT;
      RAISE;
END;
\
grant execute on build_doctor_summary to pcs_user
\
