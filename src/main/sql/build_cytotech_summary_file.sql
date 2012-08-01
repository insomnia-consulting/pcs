create or replace procedure     build_cytotech_summary_file
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   /************************************************************************************/
   /* CONSTANTS 								       */



   /************************************************************************************/

   /* These constants refer to a particular stat_code in the
      screening_stats_work table.
   */
   TOTALS constant number := -99;
   SGL_SLIDE constant number := -98;
   DBL_SLIDE constant number := -97;
   LIMITED constant number := 16;
   PATH_CASE constant number := 101;
   QC_CASE constant number := 102;


   /* In the table pcs.cytologists there is a "dummy" cytologist with
      a primary key of 2981; this had to be done to facilitate HPV only
      tests.
   */
   HPV_ONLY constant number := 2981;

   /* These constants refer to the type of preparation that was used
      for a test; it is stored in lab_requisitions.preparation and is
      a numeric value the same that is assigned here. There is also a
      table pcs.preparations that holds the general information about
      the various preparations that are used.
   */

   CONVENTIONAL constant number := 1;
   THIN_PREP constant number := 2;
   NON_GYN constant number := 4;
   IMAGED constant number := 7;

   /* These constants correspond to the field lab_results.pap_class which is
      a numeric value. This is a category that test results fall under, and
      there are a total of 15 different ones that are listed in the table
      pcs.pap_classes; in addition, in this table, there are a few others
      that are not part of the actual pap_class set, but are used mostly
      for purposes of consistency.
   */
   ORGANISMS constant number := 3;

   REACTIVE_CELL_CHNG constant number := 4;
   INFLAMMATION constant number := 12;
   UNSATISFACTORY constant number := 1;
   OTHER_NEOPLASM_TYPE constant number := 15;

   /* These constants refer to a specific area of the report, and correspond
      to the field screening_stats_work.staff_code; prior to this version the
      staff_code field indicated a specific staff member, but with this version
      the screening_stats_work table is not longer populated with the entire
      data set before the report is output. The staff_code field is being reused,
      or has been overloaded, for this different use.
   */
   DAILY_TOTALS constant number := -200;

   SLIDES_SCREENED constant number := -999;
   SPECIMEN_ADEQUACY constant number := -100;
   NEXT_TECH constant number := 0;

   /* Printing Constants
   */
   MARGIN constant varchar2(16) := '	      ';
   INDENT constant varchar2(8) := '   ';
   LAB_NAME constant varchar2(128) := RPAD('PENNSYLVANIA CYTOLOGY SERVICES',90);
   REPT_NAME constant varchar2(128) := RPAD(
      'SUMMARY OF SLIDES SCREENED BY CYTOLOGIST',109);
   /************************************************************************************/


   /* Accumulator Values and Percentage holders
   */
   num_conv number;
   num_tp number;
   num_img number;
   num_ttl number;
   cyt_pcnt number;
   lab_pcnt number;
   curr_cyt_ttl number;
   curr_lab_ttl number;

   begin_date date;
   end_date date;


   /* This cursor is used to retrieve each cytotechnologist
      who performed work in the reporting period of the report.
      Note that this date is based on the year and month when
      the results were actually entered. Thus, say for example
      the report is being done for SEP of 2011. The value of
      S_month will be 201109. However, for results entered in
      SEP of 2011, there could have been some that had a value
      for the field lab_results.lab_completed that was not in
      SEP of 2011. For example, some results are entered on the
      1st day of the month. Some of these could be for test
      that were completed on the last day of AUG. For this reason,
      the daily totals section of the report can include dates

      that are not in the actual reporting month.
   */
   cursor tech_list is
      SELECT DISTINCT cytotech
      FROM pcs.lab_results
      WHERE cytotech<>HPV_ONLY
      AND datestamp>=begin_date
      AND datestamp<end_date;
   S_cytotech number;
   S_cytotech_initials varchar2(4);
   S_lname varchar2(32);
   S_fname varchar2(32);


   /* This cursor is used to get totals for each individual pap_class
      for a specific cytotech. Each of these different categories,
      of pap classes, is listed on the report, except as noted prior
      all that are an 8 are added in with ones that are 7.
   */
   cursor pclass_list is
      SELECT pap_class
      FROM pcs.pap_classes
      WHERE pap_class>=UNSATISFACTORY
      AND pap_class<=OTHER_NEOPLASM_TYPE;
   p_code number;

   /* This cursor is used to get totals for each bethesda code that

      is in the S category (specimen adequacy) for a specific cytotech.
   */
   cursor adequacy_list is
      SELECT stat_code,RTRIM(LTRIM(TO_CHAR(stat_code)))
      FROM pcs.screening_stats_work
      WHERE staff_code=SPECIMEN_ADEQUACY
   for update;
   b_code varchar2(4);
   s_code number;

   /* This cursor is used get the total number of slides that were screened
      by a particular cytotech. As noted prior (see comment for tech_list
      cursor), there may be dates reported in the daily total list that

      are not in the year and month of the reporting period of the report.
   */
   cursor daily_total is
      SELECT date_completed, COUNT(date_completed)
      FROM pcs.lab_results
      WHERE cytotech=S_cytotech
      AND cytotech<>HPV_ONLY
      AND datestamp>=begin_date
      AND datestamp<end_date
      GROUP BY date_completed
      ORDER BY date_completed;
   date_screened date;
   ttl_screened number;

   row_num number;
   num_daily_ttls number;
   num_columns number;
   col_ptr number;
   sort_num number;

   /* This cursor is used to retrieve all of the data in the table
      pcs.screening_stats_work; with prior versions of this program
      that table held the data for the entire report. With this version
      the table only holds the data for the current tech whose info is
      being output to the report file.
   */
   cursor stat_list is

      SELECT * FROM pcs.screening_stats_work
      ORDER by reporting_sort;
   stat_fields stat_list%ROWTYPE;
   curr_mode number;
   prior_mode number;

   /* Variables used for output file
   */
   S_file_name varchar2(12);
   dir_name varchar2(128);
   last_date date;
   file_handle UTL_FILE.FILE_TYPE;


   /* Formatting, couting, and misc. variables
   */
   header_01 varchar2(256);
   header_02 varchar2(256);
   header_03 varchar2(256);
   header_04 varchar2(256);
   header_05 varchar2(256);
   curr_line varchar2(300);
   curr_page number;
   rcnt number;
   cbuf1 varchar2(256);
   cbuf2 varchar2(256);
   cbuf3 varchar2(256);

   end_ndx number;
   M_flag number;

begin

   P_proc_name:='BUILD_CYTOTECH_SUMMARY_FILE';
   P_code_area:='PREP';

   /* Date ranges for reporting period
   */
   begin_date:=TO_DATE(TO_CHAR(S_month),'YYYYMM');
   end_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'))+1;


   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));
   S_file_name:=TO_CHAR(last_date,'MONYYYY')||'.cyt';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   curr_page:=0;
   cbuf1:='REPORTING PERIOD: '||TO_CHAR(last_date,'MON ')||
      RTRIM(LTRIM(TO_CHAR(last_date,'YYYY')));
   header_01:=MARGIN||LAB_NAME||cbuf1;

   /************************************************************************************/
   /* THE ASSUMPTION IS MADE THAT TABLE SCREEN_STATS_WORK HAS BEEN INITIALIZED	       */
   /************************************************************************************/

   open tech_list;
   loop
      fetch tech_list into S_cytotech;
      exit when tech_list%NOTFOUND;
      P_code_area:='DAILY TOTAL: '||TO_CHAR(S_cytotech);
      /*
	 Initialize accumulating fields to zero for current cytotech
      */
      UPDATE pcs.screening_stats_work SET
	 month_total=0,month_thin=0,month_conv=0,month_img=0;
      /*
	 Retrieve total number of tests screened for each day completed.
	 The temp_table is used to store the text value of the date and

	 corresponding number of tests that were screened.
      */
      DELETE FROM pcs.temp_table;
      DELETE FROM pcs.screening_stats_work
      WHERE stat_code=DAILY_TOTALS;
      row_num:=1;
      open daily_total;
      loop
	 fetch daily_total into date_screened, ttl_screened;
	 exit when daily_total%NOTFOUND;
	 curr_line:=TO_CHAR(date_screened,'MM/DD/YYYY')||
	    LPAD(TO_CHAR(ttl_screened,'9999'),13);
	 INSERT INTO pcs.temp_table

	 VALUES (row_num,curr_line);
	 row_num:=row_num+1;
      end loop;
      close daily_total;
      /* This extra line is added for the times when there is an odd number of
	 total days, making it even.  Keep in mind that upon exit of the cursor,
	 the value of row_num will be one more than it actually is; hence an even
	 value indicates an odd number of rows, and an odd value indicates an
	 even number of rows. In the first case we set num_ttl to the value of
	 row_num because after adding the "dummy" row the total number of rows
	 is equal to the value of row_num. In the second case, that is row_num
	 is an odd number and there is an even number of rows, we set num_ttl
	 to row_num-1, subtracting one to compensate for row_num being one greater

	 than the actual number of rows.
      */
      P_code_area:='FORMAT DAILY TOTALS';
      if (MOD(row_num,2)=0) then
	 INSERT INTO pcs.temp_table
	 VALUES (row_num,'     ');
	 num_ttl:=row_num;
      else
	 num_ttl:=row_num-1;
      end if;
      /* If there are less than 11 daily totals to report, then output all of the
	 data in one column; otherwise use two columns. The variable col_ptr is used
	 to keep track of which row_id in the temp table to use for the second column.

      */
      if (num_ttl<11) then
	 num_daily_ttls:=num_ttl;
	 num_columns:=1;
      else
	 num_daily_ttls:=CEIL(num_ttl/2);
	 num_columns:=2;
      end if;
      col_ptr:=num_daily_ttls+1;
      sort_num:=DAILY_TOTALS;
      for rcnt in 1..num_daily_ttls loop
	 SELECT message_text INTO curr_line
	 FROM pcs.temp_table

	 WHERE row_id=rcnt;
	 if (num_columns=2) then
	    SELECT message_text INTO cbuf1
	    FROM pcs.temp_table
	    WHERE row_id=col_ptr;
	    curr_line:=curr_line||LPAD(cbuf1,33);
	    col_ptr:=col_ptr+1;
	 end if;
	 INSERT INTO pcs.screening_stats_work
	    (stat_code,stat_code_descr,staff_code,reporting_sort)
	 VALUES
	    (DAILY_TOTALS,curr_line,DAILY_TOTALS,sort_num);
	 sort_num:=sort_num+1;

      end loop;
      /*
	 Get accumulated values for TOTALS
	 Note that the lab_requisitions.preparation NON_GYN is included with the
	 preparation THIN_PREP; this is probably to compensate for the fact that
	 a NON_GYN type of test is indicated by both lab_requisitions.preparation
	 and lab_results.pap_class (the value of the NON_GYN preparation is 4,
	 and the value of the NON_GYN pap_class is 10).
      */
      P_code_area:='TOTALS: '||TO_CHAR(S_cytotech);
      SELECT
	 NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),

	 NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
      INTO
	 num_conv, num_tp, num_img
      FROM pcs.lab_requisitions A, pcs.lab_results B
      WHERE A.lab_number=B.lab_number
      AND B.cytotech=S_cytotech
      AND B.datestamp>=begin_date
      AND B.datestamp<end_date;
      num_ttl:=num_conv+num_tp+num_img;
      UPDATE pcs.screening_stats_work SET
	 month_conv=num_conv,
	 month_thin=num_tp,
	 month_img=num_img,

	 month_total=num_ttl
      WHERE stat_code=TOTALS;

      /*
	 Get accumlated values for SINGLE SLIDE CASES
      */
      P_code_area:='SGL SLIDE: '||TO_CHAR(S_cytotech);
      SELECT
	 NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
      INTO
	 num_conv, num_tp, num_img

      FROM pcs.lab_requisitions A, pcs.lab_results B
      WHERE A.lab_number=B.lab_number
      AND A.slide_qty=1
      AND B.cytotech=S_cytotech
      AND B.datestamp>=begin_date
      AND B.datestamp<end_date;
      num_ttl:=num_conv+num_tp+num_img;
      UPDATE pcs.screening_stats_work SET
	 month_conv=num_conv,
	 month_thin=num_tp,
	 month_img=num_img,
	 month_total=num_ttl
      WHERE stat_code=SGL_SLIDE;


      /*
	 Get accumlated values for DOUBLE SLIDE CASES
      */
      P_code_area:='DBL SLIDE: '||TO_CHAR(S_cytotech);
      SELECT
	 NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
      INTO
	 num_conv, num_tp, num_img
      FROM pcs.lab_requisitions A, pcs.lab_results B
      WHERE A.lab_number=B.lab_number

      AND A.slide_qty>1
      AND B.cytotech=S_cytotech
      AND B.datestamp>=begin_date
      AND B.datestamp<end_date;
      num_ttl:=num_conv+num_tp+num_img;
      UPDATE pcs.screening_stats_work SET
	 month_conv=num_conv,
	 month_thin=num_tp,
	 month_img=num_img,
	 month_total=num_ttl
      WHERE stat_code=DBL_SLIDE;

      /*

	 Get accumlated values for each different result category (pap_class)
      */
      open pclass_list;
      loop
	 fetch pclass_list into p_code;
	 exit when pclass_list%NOTFOUND;
	 P_code_area:='P_CLASS: '||TO_CHAR(S_cytotech)||','||TO_CHAR(p_code,'99');
	 SELECT
	    NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	    NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),
	    NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
	 INTO
	    num_conv, num_tp, num_img

	 FROM pcs.lab_requisitions A, pcs.lab_results B
	 WHERE A.lab_number=B.lab_number
	 AND B.pap_class=p_code
	 AND B.cytotech=S_cytotech
	 AND B.datestamp>=begin_date
	 AND B.datestamp<end_date;
	 num_ttl:=num_conv+num_tp+num_img;
	 UPDATE pcs.screening_stats_work SET
	    month_conv=num_conv,
	    month_thin=num_tp,
	    month_img=num_img,
	    month_total=num_ttl
	 WHERE stat_code=p_code;


      end loop;
      close pclass_list;
      	commit;
      /*
	 Get accumulated values for SATISFACTORY WITH QUALIFIERS
	 These are tests that are tagged satisfactory for observation
	 but limited by some factor. The field lab_results.limited
	 is either 0 or 1; if it is 1, then this case applies.
      */
      P_code_area:='LIMITED: '||TO_CHAR(S_cytotech);
      SELECT
	 NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),

	 NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
      INTO
	 num_conv, num_tp, num_img
      FROM pcs.lab_requisitions A, pcs.lab_results B
      WHERE A.lab_number=B.lab_number
      AND B.limited=1
      AND B.cytotech=S_cytotech
      AND B.datestamp>=begin_date
      AND B.datestamp<end_date;
      num_ttl:=num_conv+num_tp+num_img;
      UPDATE pcs.screening_stats_work SET
	 month_conv=num_conv,
	 month_thin=num_tp,

	 month_img=num_img,
	 month_total=num_ttl
      WHERE stat_code=LIMITED;

      /*
	 Get accumulated values for PATHOLOGIST CASES
      */
      P_code_area:='PATH: '||TO_CHAR(S_cytotech);
      SELECT
	 NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
      INTO

	 num_conv, num_tp, num_img
      FROM pcs.lab_requisitions A, pcs.lab_results B
      WHERE A.lab_number=B.lab_number
      AND B.path_status='Y'
      AND B.cytotech=S_cytotech
      AND B.datestamp>=begin_date
      AND B.datestamp<end_date;
      num_ttl:=num_conv+num_tp+num_img;
      UPDATE pcs.screening_stats_work SET
	 month_conv=num_conv,
	 month_thin=num_tp,
	 month_img=num_img,
	 month_total=num_ttl

      WHERE stat_code=PATH_CASE;

      /*
	 Get accumulated values for QUALITY CONTROL CASES
      */
      P_code_area:='QC: '||TO_CHAR(S_cytotech);
      SELECT
	 NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),
	 NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
      INTO
	 num_conv, num_tp, num_img
      FROM pcs.lab_requisitions A, pcs.lab_results B

      WHERE A.lab_number=B.lab_number
      AND B.qc_status='Y'
      AND B.cytotech=S_cytotech
      AND B.datestamp>=begin_date
      AND B.datestamp<end_date;
      num_ttl:=num_conv+num_tp+num_img;
      UPDATE pcs.screening_stats_work SET
	 month_conv=num_conv,
	 month_thin=num_tp,
	 month_img=num_img,
	 month_total=num_ttl
      WHERE stat_code=QC_CASE;


   /************************************************************************************/

   /************************************************************************************/
   /* Get Cytologist totals for specimen adequacy breakdown			       */


   /************************************************************************************/
      /* The field stat_code.screening_stats_work corresponds to the Bethesda Code for
	 results codes that are active and of category S in pcs.bethesda_codes; note that
	 this is a numeric representation as, while most Bethesda Codes are numeric, some
	 contain a letter, hence the field bethesda_code.bethesda_codes is a varchar2(4).
	 This comment is included in case any active S codes were ever added to the table
	 that contained a letter, and the programmer were going nuts trying to figure out

	 what the problem was. The adequacy totals include the cytotech findings for all
	 cases (i.e. only screening, QC, and/or pathologist).
      */
      open adequacy_list;
      loop
	 fetch adequacy_list into s_code,b_code;
	 exit when adequacy_list%NOTFOUND;
	 P_code_area:='ADEQUACY: '||TO_CHAR(S_cytotech)||','||b_code;
	 SELECT
	    NVL(SUM(DECODE(A.preparation,CONVENTIONAL,1,0)),0),
	    NVL(SUM(DECODE(A.preparation,THIN_PREP,1,NON_GYN,1,0)),0),
	    NVL(SUM(DECODE(A.preparation,IMAGED,1,0)),0)
	 INTO

	    num_conv, num_tp, num_img
	 FROM pcs.lab_requisitions A, pcs.lab_results B, pcs.lab_result_codes C
	 WHERE A.lab_number=B.lab_number
	 AND B.lab_number=C.lab_number
	 AND B.cytotech=S_cytotech
	 AND C.bethesda_code=b_code
	 AND B.datestamp>=begin_date
	 AND B.datestamp<end_date;
	 num_ttl:=num_conv+num_tp+num_img;
	 UPDATE pcs.screening_stats_work SET
	    month_conv=num_conv,
	    month_thin=num_tp,
	    month_img=num_img,

	    month_total=num_ttl
	 WHERE stat_code=s_code;

      end loop;
      
      close adequacy_list;
      commit;
   /************************************************************************************/

   /************************************************************************************/
   /* All data has been retrieved for current cytotech; format and output data to file */
   /************************************************************************************/
      /* Prepare variables for printing
      */
      P_code_area:='PRINT HEADER: '||TO_CHAR(S_cytotech);

      header_02:=MARGIN||LPAD('CYTOLOGIST TOTALS',66)||LPAD('LAB TOTALS',38);
      cbuf1:='---------------------------------------';
      header_03:=MARGIN||LPAD(cbuf1,74)||'   '||cbuf1;
      header_04:=MARGIN||LPAD('THIN',48)||LPAD('THIN',41);
      header_05:=MARGIN||LPAD('CONV   PREP    IMG  TOTAL',62)||
	 LPAD('CONV   PREP    IMG  TOTAL',41);
      SELECT lname,fname,cytotech_code INTO S_lname,S_fname,S_cytotech_initials
      FROM pcs.cytotechs WHERE cytotech=S_cytotech;
      prior_mode:=NEXT_TECH;
      open stat_list;
      loop
	 fetch stat_list into stat_fields;
	 exit when stat_list%NOTFOUND;

	 P_code_area:='PRINT STAT: '||S_cytotech_initials||','||
	    TO_CHAR(stat_fields.stat_code,'9999');
	 curr_mode:=stat_fields.staff_code;
	 if (stat_fields.stat_code=TOTALS) then
	    curr_cyt_ttl:=stat_fields.month_total;
	    curr_lab_ttl:=stat_fields.lab_total;
	 end if;
	 if (stat_fields.month_total>0) then
	    cyt_pcnt:=(stat_fields.month_total/curr_cyt_ttl)*100;
	 else
	    cyt_pcnt:=0;
	 end if;
	 if (stat_fields.lab_total>0) then

	    lab_pcnt:=(stat_fields.lab_total/curr_lab_ttl)*100;
	 else
	    lab_pcnt:=0;
	 end if;
	 /* The outer loop parses through all of the techs who have done work
	    in the month and year S_month (Reporting Period). With each pass
	    of this loop prior_mode is set to NEXT_TEXT, thus when that is
	    the prior mode, we know we are the start of a new section of the
	    report.
	 */
	 if (prior_mode=NEXT_TECH) then
	    /* If we are not on the first page of the report, then advance to the
	       next page (page 1 does not need to advance page because it is the

	       beginning of the file.
	    */
	    P_code_area:='NEXT_TECH: '||TO_CHAR(S_cytotech)||','||
	       TO_CHAR(stat_fields.stat_code,'9999');
	    if (curr_page>0) then
	       UTL_FILE.PUT(file_handle,CHR(12));
	    end if;
	    curr_page:=curr_page+1;
	    curr_line:=header_01;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    cbuf1:='PAGE '||RTRIM(LTRIM(TO_CHAR(curr_page,'09')));
	    curr_line:=MARGIN||REPT_NAME||cbuf1;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

	    curr_line:=MARGIN||'CYTOLOGIST:  '||LTRIM(S_lname)||', '||LTRIM(S_fname);
	    UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
	    curr_line:=MARGIN||'CODE:	     '||S_cytotech_initials;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 end if;
	 if (curr_mode=DAILY_TOTALS) then
	    /* A variation between curr_mode and prior_mode would signify this is the
	       first occurence of a new section of the report, and hence there may be
	       particular additional items to output.
	    */
	    P_code_area:='PRINT DAILY_TOTALS: '||TO_CHAR(S_cytotech)||','||
	       TO_CHAR(stat_fields.stat_code,'9999');
	    if (curr_mode<>prior_mode) then

	       curr_line:=MARGIN||'DAILY TOTALS:';
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    end if;
	    curr_line:=MARGIN||stat_fields.stat_code_descr;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 end if;
	 if (curr_mode=SLIDES_SCREENED) then
	    /* A variation between curr_mode and prior_mode would signify this is the
	       first occurence of a new section of the report, and hence there may be
	       particular additional items to output.
	    */
	    P_code_area:='PRINT SLIDES_SCREENED'||TO_CHAR(S_cytotech)||','||
	       TO_CHAR(stat_fields.stat_code,'9999');

	    if (curr_mode<>prior_mode) then
	       curr_line:=header_02;
	       UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
	       curr_line:=header_03;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=header_04;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=header_05;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=header_03;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    end if;
	    /* The description for these three particular test categories

	       must be indented on the report. Constants based on field
	       stat_code.screening_stats_work which is equal to the corresponding
	       value pap_classes.pap_class.
	    */
	    if (stat_fields.stat_code in (ORGANISMS,REACTIVE_CELL_CHNG,INFLAMMATION)) then
	       curr_line:=MARGIN||INDENT||RPAD(stat_fields.stat_code_descr,31);
	    else
	       curr_line:=MARGIN||RPAD(stat_fields.stat_code_descr,34);
	    end if;
	    curr_line:=curr_line||
	       LPAD(TO_CHAR(stat_fields.month_conv,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.month_thin,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.month_img,'99999'),7)||

	       LPAD(TO_CHAR(stat_fields.month_total,'99999'),7)||
	       LPAD(TO_CHAR(cyt_pcnt,'990.99'),10)||' %'||
	       LPAD(TO_CHAR(stat_fields.lab_conv,'99999'),9)||
	       LPAD(TO_CHAR(stat_fields.lab_thin,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.lab_img,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.lab_total,'99999'),7)||
	       LPAD(TO_CHAR(lab_pcnt,'990.99'),10)||' %';
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    if (stat_fields.stat_code=TOTALS) then
	       UTL_FILE.NEW_LINE(file_handle,1);
	    end if;
	 end if;
	 if (curr_mode=SPECIMEN_ADEQUACY) then

	    /* A variation between curr_mode and prior_mode would signify this is the
	       first occurence of a new section of the report, and hence there may be
	       particular additional items to output.
	    */
	    P_code_area:='PRINT ADEQUACY: '||TO_CHAR(S_cytotech)||','||
	       TO_CHAR(stat_fields.stat_code,'9999');
	    if (curr_mode<>prior_mode) then
	       /* We can assume an advance of page every time since this is
		  always the second section of the report for any staff member
	       */
	       UTL_FILE.PUT(file_handle,CHR(12));
	       curr_page:=curr_page+1;
	       curr_line:=header_01;

	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       cbuf1:='PAGE '||RTRIM(LTRIM(TO_CHAR(curr_page,'99')));
	       curr_line:=MARGIN||REPT_NAME||cbuf1;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=MARGIN||'ADEQUACY BREAKDOWN';
	       UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	       curr_line:=margin||'CYTOLOGIST:	'||LTRIM(S_lname)||', '||LTRIM(S_fname);
	       UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
	       curr_line:=margin||'CODE:	'||S_cytotech_initials;
	       UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	       curr_line:=header_02;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=header_03;

	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=header_04;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=header_05;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       curr_line:=header_03;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    end if;
	    cbuf3:=LPAD(TO_CHAR(stat_fields.month_conv,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.month_thin,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.month_img,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.month_total,'99999'),7)||
	       LPAD(TO_CHAR(cyt_pcnt,'990.99'),10)||' %'||

	       LPAD(TO_CHAR(stat_fields.lab_conv,'99999'),9)||
	       LPAD(TO_CHAR(stat_fields.lab_thin,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.lab_img,'99999'),7)||
	       LPAD(TO_CHAR(stat_fields.lab_total,'99999'),7)||
	       LPAD(TO_CHAR(lab_pcnt,'990.99'),10)||' %';
	    cbuf1:=stat_fields.stat_code_descr;
	    /* The adequacy breakdown, or Specimen Adequacy refers to a particular
	       category of the Bethesda Code (there are four, other three are:
	       description, general, and remarks). The stat_code_descr in this section
	       corresponds to the exact wording in bethesda_codes.description for all
	       category S codes. Some of these can be quite lengthy, hence; this section
	       of code is used to format the longer descriptions on the report (these is
	       a minor exception, a number of the S codes begin with or include some of

	       the exact wording; with these codes this specific wording is removed for
	       reporting purposes (see initialize_screening_stats_table.sql).
	    */
	    if (LENGTH(cbuf1)>33) then
	       cbuf2:=cbuf1;
	       end_ndx:=0;
	       M_flag:=0;
	       while (LENGTH(cbuf2)>33)
	       loop
		  for rcnt in 1..33 loop
		     if (SUBSTR(cbuf2,rcnt,1)=' ') then
			end_ndx:=rcnt;
		     end if;

		  end loop;
		  cbuf1:=SUBSTR(cbuf2,1,end_ndx);
		  cbuf2:=LTRIM(RTRIM(SUBSTR(cbuf2,end_ndx)));
		  cbuf2:=INDENT||cbuf2;
		  if (M_flag=0) then
		     curr_line:=MARGIN||RPAD(cbuf1,34)||cbuf3;
		     M_flag:=1;
		  else
		     curr_line:=MARGIN||RPAD(cbuf1,34);
		  end if;
		  UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
		  M_flag:=1;
	       end loop;

	       if (NVL(LENGTH(cbuf2),0)>0) then
		  curr_line:=MARGIN||cbuf2;
		  UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       end if;
	    /* This is the case where the total wording of the description will
	       fit in the available space on the paper, and will therefore only
	       take up one line of the report.
	    */
	    else
	       curr_line:=MARGIN||RPAD(cbuf1,34)||cbuf3;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    end if;
	 end if;

	 prior_mode:=curr_mode;
      end loop;
      close stat_list;
   end loop;
   close tech_list;

   /************************************************************************************/

   UTL_FILE.PUT(file_handle,CHR(12));
   UTL_FILE.FCLOSE(file_handle);

--exception
--   when UTL_FILE.INVALID_PATH then
--
--      UTL_FILE.FCLOSE(file_handle);
--      RAISE_APPLICATION_ERROR(-20051,'invalid path');
--   when UTL_FILE.INVALID_MODE then
--      UTL_FILE.FCLOSE(file_handle);
--      RAISE_APPLICATION_ERROR(-20052,'invalid mode');
--   when UTL_FILE.INVALID_FILEHANDLE then
--      UTL_FILE.FCLOSE(file_handle);
--      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');
--   when UTL_FILE.INVALID_OPERATION then
--      UTL_FILE.FCLOSE(file_handle);
--      RAISE_APPLICATION_ERROR(-20054,'invalid operation');
--   when UTL_FILE.READ_ERROR then
--      UTL_FILE.FCLOSE(file_handle);
--
--      RAISE_APPLICATION_ERROR(-20055,'read error');
--   when UTL_FILE.WRITE_ERROR then
--      UTL_FILE.FCLOSE(file_handle);
--      RAISE_APPLICATION_ERROR(-20056,'write error');
--   when OTHERS then
--      UTL_FILE.FCLOSE(file_handle);
--      P_error_code:=SQLCODE;
--      P_error_message:=SQLERRM;
--      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
--      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_cytotech);
--      commit;
--      RAISE;


end;
/