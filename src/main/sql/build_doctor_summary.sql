create or replace procedure     build_doctor_summary
(
   S_practice in number,
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   /* Account variables

   */
   P_name varchar2(512);
   P_address1 varchar2(64);
   P_address2 varchar2(64);
   P_city varchar2(32);
   P_state char(2);
   P_zip varchar2(9);
   P_csz varchar2(80);
   P_type varchar2(32);
   P_print_doctors char(1);
   P_print_hpv char(1);

   /* Patient variables

   */
   PT_lab_number number;
   PT_name varchar2(128);
   PT_DOS varchar2(16);
   PT_doctor varchar2(128);
   PT_id varchar2(32);
   PT_SSN varchar2(16);
   PT_DOB varchar2(16);

   /* PAP Class and Result variables
   */
   PC_current number;
   PC_previous number;

   PC_description varchar2(512);
   PC_count number;
   PC_six_month_count number;
   PC_total number;
   PC_six_month_total number;
   PC_percent number;
   LR_no_ecc number;
   LR_code varchar2(4);

   /* HPV variables
   */
   HPV_sent char(1);
   HPV_results char(1);

   HPV_txt char(1);

   /* PCS variables
   */
   LAB_name varchar2(80);
   LAB_addr1 varchar2(80);
   LAB_addr2 varchar2(80);
   LAB_csz varchar2(80);
   LAB_phone varchar2(80);

   /* Report and misc. variables
   */
   LINE_LENGTH constant number := 80;

   PAGE_LENGTH constant number := 60;
   MIN_CATEGORY_LENGTH constant number := 13;
   BOTTOM_MARGIN constant number := 4;
   PAGE_txt varchar2(80);
   CLIENT_NUMBER_txt varchar2(80);
   PERIOD_ENDING_txt varchar2(80);
   REPORT_TITLE_txt varchar2(80);
   DESCRIPTION_txt varchar2(80);
   TOTAL_txt varchar2(80);
   char_buffer varchar2(256);
   curr_line varchar2(256);
   line_num number;
   curr_page number;

   column_heading varchar2(96);
   long_line varchar2(128);
   short_line varchar2(32);
   ndx number;
   offset number;
   report_style number;
   is_continued number;
   S_month_low number;
   t_date date;
   u_flag number;

   /* Report style constants
   */

   NO_PRINT constant number := 100;
   STANDARD constant number := 101;
   STANDARD_WITH_DOCTOR constant number := 102;
   STANDARD_WITH_HPV constant number := 103;
   STANDARD_WITH_DOCTOR_AND_HPV constant number := 104;
   ACCOUNT_082 constant number := 201;
   ADPH constant number := 301;
   ADPH_WITH_HPV constant number := 302;

   /* File variables
   */
   file_handle UTL_FILE.FILE_TYPE;
   directory_name varchar2(256);

   file_name varchar2(256);
   file_extension varchar2(256);

   cursor pap_class_list is
      select LR.pap_class, COUNT(LR.pap_class)
      from pcs.lab_results LR, pcs.practice_statement_labs PSL
      where LR.lab_number=PSL.lab_number
      and PSL.practice=S_practice
      and PSL.statement_id=S_month
      and PSL.prac_2=0
      group by LR.pap_class;

   cursor lab_list is

      select PSL.lab_number,
	 PSL.patient_name,
	 TO_CHAR(PSL.date_collected,'MM/DD/YYYY'),
	 LQ.doctor_text,
	 LQ.patient_id,
	 SUBSTR(PT.SSN,1,3)||
	    '-'||SUBSTR(PT.SSN,4,2)||
	    '-'||SUBSTR(PT.SSN,6),
	 TO_CHAR(PT.DOB,'MM/DD/YYYY'),
	 PC.tmp_num,
	 PC.description,
	 HPV.test_sent,
	 HPV.test_results,

	 LR.pap_class
      from pcs.practice_statement_labs PSL,
	 pcs.lab_requisitions LQ,
	 pcs.patients PT,
	 pcs.pap_classes PC,
	 pcs.hpv_requests HPV,
	 pcs.lab_results LR
      where PSL.lab_number=LQ.lab_number
      and PSL.lab_number=LR.lab_number
      and PSL.lab_number=HPV.lab_number(+)
      and LQ.patient=PT.patient
      and LR.pap_class=PC.pap_class
      and PSL.practice=S_practice

      and PSL.statement_id=S_month
      and PSL.prac_2=0
      and LR.pap_class>0
      and LR.pap_class<16
      order by PC.reporting_sort,PSL.patient_name;

   cursor six_month_list is
      select pap_class, description, tmp_num
      from pcs.pap_classes
      where pap_class>0
      and pap_class<17
      order by reporting_sort;


   cursor adequacy_list is
      select bethesda_code, pap_class, description, one_month, six_month
      from pcs.adequacy_result_codes
      order by bethesda_code;

begin

   P_proc_name:='BUILD_DOCTOR_SUMMARY';
   P_code_area:='PREP';

   /* Initialize Lab heading variables
   */
   LAB_name:='PENNSYLVANIA CYTOLOGY SERVICES';

   LAB_addr1:='SUITE 1700 PARKWAY BUILDING';
   LAB_addr2:='339 OLD HAYMAKER ROAD';
   LAB_csz:='MONROEVILLE, PA  15146-1477';
   LAB_phone:='PHONE: 412-373-8300';

   P_code_area:='GET ACCT DATA';
   /* Retrieve account data
   */
   select name,address1,address2,city,
      state,SUBSTR(zip,1,5),practice_type,
      hpv_on_summary,print_doctors
   into P_name,P_address1,P_address2,P_city,
      P_state,P_zip,P_type,P_print_hpv,P_print_doctors

   from pcs.practices where practice=S_practice;
   P_csz:=P_city||', '||P_state||'  '||P_zip;

   P_code_area:='INIT REPT VARS';
   /* Initialize report formatting variables
   */
   curr_page:=0;
   is_continued:=0;
   PAGE_txt:='PAGE ';
   CLIENT_NUMBER_txt:='CLIENT NUMBER: ';
   PERIOD_ENDING_txt:='PERIOD ENDING: ';
   REPORT_TITLE_txt:='SUMMARY OF CYTOLOGY FINDINGS';
   DESCRIPTION_txt:='DESCRIPTION: ';

   TOTAL_txt:='TOTAL: ';

   char_buffer:=TO_CHAR(S_practice,'009');
   CLIENT_NUMBER_txt:=CLIENT_NUMBER_txt||char_buffer;

   char_buffer:=TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM')),'MM/DD/YYYY');
   PERIOD_ENDING_txt:=PERIOD_ENDING_txt||char_buffer;

   P_code_area:='SET REPT STYLE';
   /* Column data varies depending on the needs of the client. For
      all intents and purposes this is controlled by options set
      in the account profile. The exceptions are account 082
      and ADPH accounts in which their special needs are

      hard-coded - unfortunately.
   */
   report_style:=NO_PRINT;
   if (S_practice=82) then
      report_style:=ACCOUNT_082;
      column_heading:='DOB	     PATIENT		       DATE	     DOCTOR';
   elsif (P_type='ADPH') then
      report_style:=ADPH;
      column_heading:=
	 'LAB NUMBER	PATIENT 		  DATE		PATIENT ID';
      if (P_print_hpv='Y') then
	 report_style:=ADPH_WITH_HPV;
	 column_heading:=column_heading||LPAD('HPV',16);

      end if;
   elsif (P_print_doctors='Y') then
      report_style:=STANDARD_WITH_DOCTOR;
      column_heading:='LAB NUMBER    PATIENT		       DATE	     DOCTOR';
      if (P_print_hpv='Y') then
	 report_style:=STANDARD_WITH_DOCTOR_AND_HPV;
	 column_heading:=column_heading||LPAD('HPV',20);
      end if;
   else
      report_style:=STANDARD;
      column_heading:='LAB NUMBER	     PATIENT			      DATE';
      if (P_print_hpv='Y') then
	 report_style:=STANDARD_WITH_HPV;

	 column_heading:=column_heading||LPAD('HPV',20);
      end if;
   end if;
   if (report_style=NO_PRINT) then
      goto exit_point;
   end if;

   ndx:=0;
   long_line:='-';
   for ndx in 1..(LINE_LENGTH-1) loop
      long_line:=long_line||'-';
   end loop;
   short_line:='------------------';


   P_code_area:='CALC MONTH TTLS';
   /* Calculate monthly totals and store value
      in tmp_num field of pap_class table.
   */
   update pcs.pap_classes set tmp_num=0;
   open pap_class_list;
   loop
      fetch pap_class_list into PC_current, PC_count;
      exit when pap_class_list%NOTFOUND;
      update pcs.pap_classes
      set tmp_num=PC_count
      where pap_class=PC_current;

   end loop;
   close pap_class_list;
   commit;

   P_code_area:='ABSORB PCLASS 0->10';
   /* Assumption is made that any lab that
      has an unknown pap_class is a non-gyn;
      therefore 0 and 10 are combined.
   */
   select tmp_num into PC_count
   from pcs.pap_classes
   where pap_class=0;
   update pcs.pap_classes

   set tmp_num=0
   where pap_class=0;
   update pcs.pap_classes
   set tmp_num=tmp_num+PC_count
   where pap_class=10;
   commit;
   select count(*) into PC_count
   from pcs.practice_statement_labs PSL, lab_results LR
   where PSL.lab_number=LR.lab_number
   and PSL.statement_id=S_month
   and PSL.practice=S_practice
   and PSL.prac_2=0
   and LR.limited=1;

   update pcs.pap_classes
   set tmp_num=PC_count
   where pap_class=16;
   commit;

   P_code_area:='OPEN FILE';
   /* Open file for report.
      Format for report name is <ACT><MM><C><YY>.file_extension;
      as of this writing the file extension for this report
      is ?sum.?

      EXAMPLE: Suppose this report is being ran for
      Account #567 for August, 2009. Then:

	 <ACT> = 567
	 <MM>  = 08
	 <C>   = 2
	 <YY>  = 09
      so the file name would be:  56708209.sum
   */
   directory_name:='REPORTS_DIR';
   file_extension:='.sum';
   file_name:=LTRIM(RTRIM(TO_CHAR(S_practice,'009')))||
      SUBSTR(TO_CHAR(S_month),5,2)||
      SUBSTR(TO_CHAR(S_month),1,1)||
      SUBSTR(TO_CHAR(S_month),3,2)||
      file_extension;

   file_handle:=UTL_FILE.FOPEN(directory_name,file_name,'w');

   P_code_area:='WRITE PG1 HEADING';
   /* This is the first page heading.
      It will take (14) lines; (13) if the account
      does not use a two line address.
   */
   curr_page:=1;
   line_num:=15;
   char_buffer:=LTRIM(RTRIM(TO_CHAR(curr_page)));
   offset:=LINE_LENGTH-LENGTH(REPORT_TITLE_txt);
   curr_line:=REPORT_TITLE_txt||LPAD((PAGE_txt||' '||char_buffer),offset);
   UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);

   UTL_FILE.PUTF(file_handle,'%s\n',LAB_name);
   UTL_FILE.PUTF(file_handle,'%s\n',LAB_addr1);
   UTL_FILE.PUTF(file_handle,'%s\n',LAB_addr2);
   UTL_FILE.PUTF(file_handle,'%s\n',LAB_csz);
   UTL_FILE.PUTF(file_handle,'%s\n\n',LAB_phone);
   char_buffer:='   '||P_name;
   offset:=LINE_LENGTH-LENGTH(PERIOD_ENDING_txt);
   curr_line:=RPAD(char_buffer,offset)||CLIENT_NUMBER_txt;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   char_buffer:='   '||P_address1;
   curr_line:=RPAD(char_buffer,offset)||PERIOD_ENDING_txt;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   if (P_address2 IS NOT NULL) then

      curr_line:='   '||P_address2;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_num:=16;
   end if;
   curr_line:='   '||P_csz;
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   PC_previous:=0;
   P_code_area:='OPEN LAB_LIST';
   open lab_list;
   loop
      P_code_area:='LOOP TOP';
      fetch lab_list into PT_lab_number, PT_name, PT_DOS,

	 PT_doctor, PT_id, PT_SSN, PT_DOB, PC_count,
	 PC_description, HPV_sent, HPV_results,
	 PC_current;
      exit when lab_list%NOTFOUND;
      P_code_area:='AFTER FETCH';
      P_code_area:='LAB_LIST: '||TO_CHAR(PT_lab_number);
      LR_no_ecc:=pcs.is_no_ecc(PT_lab_number);
      HPV_txt:=' ';
      if (P_print_hpv='Y') then
	 if (HPV_sent IS NOT NULL) then
	    if (HPV_sent='Q') then
	       HPV_txt:=HPV_sent;
	    elsif (HPV_sent='Y') then

	       HPV_txt:=HPV_results;
	    end if;
	 end if;
      end if;
      if (PC_previous<>PC_current) then
	 if ((PAGE_LENGTH-line_num)<MIN_CATEGORY_LENGTH) then
	    line_num:=line_num+(MIN_CATEGORY_LENGTH-BOTTOM_MARGIN);
	 end if;
      end if;
      if ((PAGE_LENGTH-line_num)<BOTTOM_MARGIN) then
	 UTL_FILE.PUTF(file_handle,'\n%s\n',long_line);
	 curr_page:=curr_page+1;
	 UTL_FILE.PUT(file_handle,CHR(12));

	 char_buffer:=LTRIM(RTRIM(TO_CHAR(curr_page)));
	 offset:=LINE_LENGTH-LENGTH(REPORT_TITLE_txt);
	 curr_line:=REPORT_TITLE_txt||LPAD((PAGE_txt||' '||char_buffer),offset);
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',LAB_name);
	 UTL_FILE.PUTF(file_handle,'%s\n',CLIENT_NUMBER_txt);
		 UTL_FILE.PUTF(file_handle,'%s\n\n',PERIOD_ENDING_txt);
	 line_num:=9;
	 if (PC_previous=PC_current) then
	    is_continued:=1;
	 end if;
      end if;
      if (PC_previous<>PC_current or is_continued=1) then

	 /* Print category subheading.
	    This normally uses (7) lines;
	    if the is_continued flag is set it means that
	    data in the current category is no two separate
	    pages, and a CONT'D message is printed instead
	    and the category subheading only takes (6) lines.
	 */
	 PC_previous:=PC_current;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',long_line);
	 if (is_continued=1) then
	    curr_line:=PC_description||', CONT''D';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    line_num:=line_num+6;

	 else
	    curr_line:=RPAD(DESCRIPTION_txt,14)||PC_description;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    curr_line:=RPAD(TOTAL_txt,14)||LTRIM(RTRIM(TO_CHAR(PC_count)));
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    line_num:=line_num+7;
	 end if;
	 UTL_FILE.PUTF(file_handle,'%s\n',column_heading);
	 UTL_FILE.PUTF(file_handle,'%s\n',long_line);
      end if;
      if (report_style=STANDARD) then
	 curr_line:=RPAD(LTRIM(RTRIM(TO_CHAR(PT_lab_number))),22)||
	    RPAD(SUBSTR(PT_name,1,22),34)||PT_DOS;

      elsif (report_style=STANDARD_WITH_HPV) then
	 curr_line:=RPAD(LTRIM(RTRIM(TO_CHAR(PT_lab_number))),22)||
	    RPAD(SUBSTR(PT_name,1,22),34)||RPAD(PT_DOS,22)||HPV_txt;
      elsif (report_style=STANDARD_WITH_DOCTOR) then
	 curr_line:=RPAD(LTRIM(RTRIM(TO_CHAR(PT_lab_number))),14)||
	    RPAD(SUBSTR(PT_name,1,22),26)||RPAD(PT_DOS,14)||
	    SUBSTR(PT_doctor,1,22);
      elsif (report_style=STANDARD_WITH_DOCTOR_AND_HPV) then
	 curr_line:=RPAD(LTRIM(RTRIM(TO_CHAR(PT_lab_number))),14)||
	    RPAD(SUBSTR(PT_name,1,22),26)||RPAD(PT_DOS,14)||
	    RPAD(SUBSTR(PT_doctor,1,22),24)||HPV_txt;
      elsif (report_style=ADPH) then
	 if (LR_no_ecc=1) then

	    char_buffer:='*';
	 else
	    char_buffer:=' ';
	 end if;
	 char_buffer:=char_buffer||LTRIM(RTRIM(TO_CHAR(PT_lab_number)));
	 curr_line:=RPAD(char_buffer,14)||RPAD(SUBSTR(PT_name,1,22),26)||
	    RPAD(PT_DOS,14)||SUBSTR(PT_id,1,22);
      elsif (report_style=ADPH_WITH_HPV) then
	 if (LR_no_ecc=1) then
	    char_buffer:='*';
	 else
	    char_buffer:=' ';
	 end if;

	 char_buffer:=char_buffer||LTRIM(RTRIM(TO_CHAR(PT_lab_number)));
	 curr_line:=RPAD(char_buffer,14)||RPAD(SUBSTR(PT_name,1,22),26)||
	    RPAD(PT_DOS,14)||RPAD(SUBSTR(PT_id,1,22),24)||HPV_txt;
      elsif (report_style=ACCOUNT_082) then
	 curr_line:=RPAD(PT_DOB,14)||
	    RPAD(SUBSTR(PT_name,1,22),26)||RPAD(PT_DOS,14)||
	    SUBSTR(PT_doctor,1,22);
      end if;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_num:=line_num+1;
      is_continued:=0;
   end loop;
   close lab_list;


   t_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'))+1;
   t_date:=ADD_MONTHS(t_date,-6);
   S_month_low:=TO_NUMBER(TO_CHAR(t_date,'YYYYMM'));

   P_code_area:='SUMMARY PAGES';
   UTL_FILE.PUTF(file_handle,'\n%s\n',long_line);
   curr_page:=curr_page+1;
   UTL_FILE.PUT(file_handle,CHR(12));
   char_buffer:=LTRIM(RTRIM(TO_CHAR(curr_page)));
   offset:=LINE_LENGTH-LENGTH(REPORT_TITLE_txt);
   curr_line:=REPORT_TITLE_txt||LPAD((PAGE_txt||' '||char_buffer),offset);
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);

   UTL_FILE.PUTF(file_handle,'%s\n',LAB_name);
   UTL_FILE.PUTF(file_handle,'%s\n',CLIENT_NUMBER_txt);
   UTL_FILE.PUTF(file_handle,'%s\n\n',PERIOD_ENDING_txt);
   UTL_FILE.PUTF(file_handle,'%s\n',long_line);
   char_buffer:=LPAD('MONTHLY TOTALS',59);
   curr_line:=char_buffer||LPAD('SIX-MONTH TOTALS',20);
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   char_buffer:=LPAD(short_line,61);
   curr_line:=char_buffer||' '||short_line;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   select sum(tmp_num) into PC_total
   from pcs.pap_classes

   where pap_class>0
   and pap_class<16;

   select count(*) into PC_six_month_total
   from pcs.lab_results LR, pcs.practice_statement_labs PSL, pcs.pap_classes PC
   where LR.lab_number=PSL.lab_number
   and PC.pap_class=LR.pap_class(+)
   and PSL.practice=S_practice
   and PSL.statement_id>=S_month_low
   and PSL.statement_id<=S_month
   and PSL.prac_2=0
   and LR.pap_class>0
   and LR.pap_class<16;


   P_code_area:='OPEN SIX_MONTH_LIST';
   open six_month_list;
   loop
      fetch six_month_list
      into PC_current, PC_description, PC_count;
      exit when six_month_list%NOTFOUND;
      P_code_area:='SIX_MONTH_LIST: '||TO_CHAR(PC_current);
      if (PC_current=16) then
	 select count(*) into PC_six_month_count
	 from pcs.practice_statement_labs PSL, lab_results LR
	 where PSL.lab_number=LR.lab_number
	 and PSL.practice=S_practice

	 and PSL.statement_id>=S_month_low
	 and PSL.statement_id<=S_month
	 and PSL.prac_2=0
	 and LR.limited=1;
      else
	 select count(*) into PC_six_month_count
	 from pcs.practice_statement_labs PSL, lab_results LR
	 where PSL.lab_number=LR.lab_number
	 and PSL.practice=S_practice
	 and PSL.statement_id>=S_month_low
	 and PSL.statement_id<=S_month
	 and PSL.prac_2=0
	 and LR.pap_class=PC_current;

      end if;
      if (PC_current IN (3,4,12)) then
	 PC_description:='     '||PC_description;
      end if;
      if (LENGTH(PC_description)>40) then
	 PC_description:=SUBSTR(PC_description,1,40)||'...';
      end if;
      curr_line:=RPAD(PC_description,43);
      char_buffer:=LPAD(TO_CHAR(PC_count),6);
      curr_line:=curr_line||char_buffer;
      if (PC_total>0) then
	 PC_percent:=(PC_count/PC_total)*100;
      else

	 PC_percent:=0;
      end if;
      char_buffer:=LPAD(TO_CHAR(PC_percent,'990.00')||' %',11);
      curr_line:=curr_line||char_buffer;
      char_buffer:=LPAD(TO_CHAR(PC_six_month_count),8);
      curr_line:=curr_line||char_buffer;
      if (PC_six_month_total>0) then
	 PC_percent:=(PC_six_month_count/PC_six_month_total)*100;
      else
	 PC_percent:=0;
      end if;
      char_buffer:=LPAD(TO_CHAR(PC_percent,'990.00')||' %',11);
      curr_line:=curr_line||char_buffer;

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end loop;
   close six_month_list;

   char_buffer:=LPAD(short_line,61);
   curr_line:=char_buffer||' '||short_line;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=LPAD(TO_CHAR(PC_total),49);
   char_buffer:=LPAD('100.00 %',11);
   curr_line:=curr_line||char_buffer;
   char_buffer:=LPAD(TO_CHAR(PC_six_month_total),8);
   curr_line:=curr_line||char_buffer;
   char_buffer:=LPAD('100.00 %',11);

   curr_line:=curr_line||char_buffer;
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   curr_line:=RPAD('ADEQUACY BREAKDOWN',45);
   char_buffer:='(PERCENTAGES BASED ON TOTALS ABOVE)';
   curr_line:=curr_line||char_buffer;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   UTL_FILE.PUTF(file_handle,'%s\n',long_line);
   curr_line:='SATISFACTORY FOR EVALUATION:';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   P_code_area:='OPEN ADEQUACY_LIST';
   u_flag:=0;
   open adequacy_list;

   loop
      fetch adequacy_list into LR_code, PC_current,
	 PC_description, PC_count, PC_six_month_count;
      exit when adequacy_list%NOTFOUND;
      P_code_area:='ADEQUACY_LIST: '||LR_code;
      PC_description:=REPLACE(PC_description,
	 'SATISFACTORY FOR EVALUATION, ');
      PC_description:=REPLACE(PC_description,
	 'SPECIMEN PROCESSED AND EXAMINED, BUT UNSATISFACTORY FOR EVALUATION ');
      if (PC_current=1 and u_flag=0) then
	 u_flag:=1;
      end if;
      if (u_flag=1) then

	 UTL_FILE.PUTF(file_handle,'\n%s\n','UNSATISFACTORY:');
	 u_flag:=(-1);
      end if;
      char_buffer:=LPAD(TO_CHAR(PC_count),6);
      if (PC_total>0) then
	 PC_percent:=(PC_count/PC_total)*100;
      else
	 PC_percent:=0;
      end if;
      char_buffer:=char_buffer||LPAD(TO_CHAR(PC_percent,'990.00')||' %',11);
      char_buffer:=char_buffer||LPAD(TO_CHAR(PC_six_month_count),8);
      if (PC_six_month_total>0) then
	 PC_percent:=(PC_six_month_count/PC_six_month_total)*100;

      else
	 PC_percent:=0;
      end if;
      char_buffer:=char_buffer||LPAD(TO_CHAR(PC_percent,'990.00')||' %',11);
      if (LENGTH(PC_description)>40) then
	 P_name:=PC_description;
	 offset:=0;
	 is_continued:=0;
	 while (LENGTH(P_name)>40)
	 loop
	    for ndx in 1..40 loop
	       if (SUBSTR(P_name,ndx,1)=' ') then
		  offset:=ndx;

	       end if;
	    end loop;
	    DESCRIPTION_txt:=SUBSTR(P_name,1,offset);
	    P_name:=LTRIM(RTRIM(SUBSTR(P_name,offset)));
	    P_name:='	  '||P_name;
	    if (is_continued=0) then
	       curr_line:=RPAD(DESCRIPTION_txt,43)||char_buffer;
	       is_continued:=1;
	    else
	       curr_line:=RPAD(DESCRIPTION_txt,43);
	    end if;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    is_continued:=1;

	 end loop;
	 if (NVL(LENGTH(P_name),0)>0) then
	    curr_line:=P_name;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 end if;
      else
	 curr_line:=RPAD(PC_description,43)||char_buffer;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      end if;
   end loop;
   close adequacy_list;

   UTL_FILE.PUT(file_handle,CHR(12));

   UTL_FILE.FCLOSE(file_handle);
   <<exit_point>>
   commit;

exception
   when UTL_FILE.INVALID_PATH then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20051,'invalid path');
   when UTL_FILE.INVALID_MODE then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');
   when UTL_FILE.INVALID_FILEHANDLE then
      UTL_FILE.FCLOSE(file_handle);

      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');
   when UTL_FILE.INVALID_OPERATION then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');
   when UTL_FILE.READ_ERROR then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20055,'read error');
   when UTL_FILE.WRITE_ERROR then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20056,'write error');
   when OTHERS then
      UTL_FILE.FCLOSE(file_handle);
      P_error_code:=SQLCODE;

      P_error_message:=SQLERRM;
      insert into pcs.error_log
	(error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values
	(P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_practice);
      commit;
      RAISE;

end;
/