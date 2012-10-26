create or replace procedure     build_unsatisfactory_file
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   -- Account variables

   P_account number;
   P_account_previous number;
   P_name varchar2(512);

   -- Patient variables
   PT_lab_number number;
   PT_name varchar2(128);

    -- PCS variables
   LAB_name varchar2(80);


   -- Report and misc. variables
   LINE_LENGTH constant number := 80;
   PAGE_LENGTH constant number := 60;
   BOTTOM_MARGIN constant number := 4;
   PAGE_txt varchar2(80);
   CLIENT_NUMBER_txt varchar2(80);
   PERIOD_ENDING_txt varchar2(80);
   REPORT_TITLE_txt varchar2(80);
   TOTAL_txt varchar2(80);
   MONTHLY_TOTAL_txt varchar2(80);
   YEARLY_TOTAL_txt varchar2(80);
   char_buffer varchar2(256);

   curr_line varchar2(256);
   line_num number;
   curr_page number;
   column_heading varchar2(96);
   long_line varchar2(128);
   ndx number;
   offset number;
   S_month_low number;
   UNSATISFACTORY constant number := 1;
   month_count number;
   year_count number;
   month_cumulative number;
   year_cumulative number;


   -- File variables
   file_handle UTL_FILE.FILE_TYPE;
   directory_name varchar2(256);
   file_name varchar2(256);
   file_extension varchar2(256);

   -- NOTE: The field prac_2 in practice_statement_labs is
   --    used to isolate distinct lab numbers; in this table for
   --    a given statement_id (YYYYMM) there are multiple lab
   --    numbers (one for each CPT code, or line item). The
   --    combination of statement_id, lab_number, and prac_2

   --    where prac_2=0 us unique.
   cursor unsatisfactory_list is
      select PSL.lab_number,PSL.patient_name,PSL.practice,P.name
      from pcs.practice_statement_labs PSL, pcs.practices P, pcs.lab_results LR
      where PSL.lab_number=LR.lab_number
      and PSL.practice=P.practice
      and LR.pap_class=UNSATISFACTORY
      and PSL.statement_id=S_month
      and PSL.prac_2=0
      order by PSL.practice,PSL.lab_number;

   cursor practice_list is

      select pap_class,one_month,six_month
      from pcs.adequacy_result_codes
      order by pap_class;

begin

   P_proc_name:='BUILD_UNSATISFACTORY_FILE';
   P_code_area:='INIT REPT VARS';

   -- Initialize Lab heading variables
   LAB_name:='PENNSYLVANIA CYTOLOGY SERVICES';


    -- Initialize report formatting variables
   PAGE_txt:='PAGE ';
   CLIENT_NUMBER_txt:='ACCOUNT: ';
   PERIOD_ENDING_txt:='MONTH ENDING: ';
   REPORT_TITLE_txt:='UNSATISFACTORY PAP SMEAR REPORT';
   TOTAL_txt:='CUMULATIVE TOTALS';
   MONTHLY_TOTAL_txt:='MONTHLY TOTAL:  ';
   YEARLY_TOTAL_txt:='YEARLY TOTAL:   ';

   char_buffer:=TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM')),'MM/DD/YYYY');
   PERIOD_ENDING_txt:=PERIOD_ENDING_txt||char_buffer;


   column_heading:='LAB NUMBER		     PATIENT';

   ndx:=0;
   long_line:='-';
   for ndx in 1..(LINE_LENGTH-1) loop
      long_line:=long_line||'-';
   end loop;

   -- This might be considered a little bit "hokey." We are going to
   --    borrow the adequacy_result_codes table (a temp table) to store
   --    data for monthly and yearly totals for unsatisfactories. In
   --    doing this many CPU cycles should be saved making the
   --    procedure much more efficient. Field name mapping will be

   --    slightly confused (left side):
   -- 	 bethesda_code		NO VALUE
   -- 	 pap_class		PRACTICE
   -- 	 description		NO VALUE
   -- 	 one_month		UNSAT COUNT FOR S_MONTH
   -- 	 six_month		YEARLY COUNT SO FAR

   --    VAR S_month_low is set to January of the current year
   S_month_low:=TO_NUMBER(SUBSTR(TO_CHAR(S_month),1,4)||'01');
   delete from pcs.adequacy_result_codes;
   insert into pcs.adequacy_result_codes
      (bethesda_code,pap_class,description,one_month,six_month)

	 select NULL,PSL.practice,NULL,SUM(DECODE(PSL.statement_id,S_month,1,0)),
	    count(PSL.practice)
	 from pcs.practice_statement_labs PSL, lab_results LR
	 where PSL.lab_number=LR.lab_number
	 and LR.pap_class=UNSATISFACTORY
	 and PSL.prac_2=0
	 and PSL.statement_id>=S_month_low
	 group by PSL.practice;
   commit;

   P_code_area:='OPEN FILE';
   -- Open file for report.
   --    Format for report name is <ACT><MM><C><YY>.file_extension;

   --    as of this writing the file extension for this report
   --    is ?sum.?

   --    EXAMPLE: Suppose this report is being ran for
   --    Account #567 for August, 2009. Then:
   -- 	 <ACT> = 567
   -- 	 <MM>  = 08
   -- 	 <C>   = 2
   -- 	 <YY>  = 09
   --    so the file name would be:  56708209.uns
   P_code_area:='OPEN FILE';
   directory_name:='REPORTS_DIR';

   file_extension:='.uns';
   char_buffer:=TO_CHAR(TO_DATE(TO_CHAR(S_month),'YYYYMM'),'MONYYYY');
   file_name:=LTRIM(RTRIM(char_buffer))||file_extension;
   file_handle:=UTL_FILE.FOPEN(directory_name,file_name,'w');

   P_code_area:='UNSAT_LIST';
   P_account_previous:=0;
   curr_page:=0;
   line_num:=0;
   month_cumulative:=0;
   year_cumulative:=0;
   open unsatisfactory_list;
   loop

      fetch unsatisfactory_list into PT_lab_number,PT_name,P_account,P_name;
      exit when unsatisfactory_list%NOTFOUND;
      P_code_area:='UNSAT_LIST: '||TO_CHAR(PT_lab_number);
      if (P_account<>P_account_previous AND P_account_previous<>0) then
	 select one_month,six_month into month_count,year_count
	 from pcs.adequacy_result_codes
	 where pap_class=P_account_previous;
	 month_cumulative:=month_cumulative+month_count;
	 year_cumulative:=year_cumulative+year_count;
	 char_buffer:=LPAD(RTRIM(LTRIM(TO_CHAR(month_count))),4);
	 curr_line:=LPAD(MONTHLY_TOTAL_txt,29)||char_buffer;
	 UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
	 line_num:=line_num+2;

	 char_buffer:=LPAD(RTRIM(LTRIM(TO_CHAR(year_count))),4);
	 curr_line:=LPAD(YEARLY_TOTAL_txt,29)||char_buffer;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',long_line);
	 line_num:=line_num+4;
	 if ((PAGE_LENGTH-line_num)>=BOTTOM_MARGIN) then
	    curr_line:=LPAD(' ',13)||
	       CLIENT_NUMBER_txt||TO_CHAR(P_account,'009')||' - '||P_name;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    line_num:=line_num+2;
	 end if;
      end if;
      if ((PAGE_LENGTH-line_num)<BOTTOM_MARGIN OR P_account_previous=0) then

	 curr_page:=curr_page+1;
	 UTL_FILE.PUT(file_handle,CHR(12));
	 char_buffer:=LTRIM(RTRIM(TO_CHAR(curr_page)));
	 offset:=LINE_LENGTH-LENGTH(REPORT_TITLE_txt);
	 curr_line:=REPORT_TITLE_txt||LPAD((PAGE_txt||' '||char_buffer),offset);
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',LAB_name);
	 UTL_FILE.PUTF(file_handle,'%s\n',PERIOD_ENDING_txt);
	 UTL_FILE.PUTF(file_handle,'%s\n\n',long_line);
	 curr_line:=LPAD(' ',13)||
	    CLIENT_NUMBER_txt||TO_CHAR(P_account,'009')||' - '||P_name;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 line_num:=14;

      end if;
      P_name:=pcs.get_account_name(P_account);
      curr_line:=LPAD(RTRIM(LTRIM(TO_CHAR(PT_lab_number))),23)||
	 LPAD(' ',15)||PT_name;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_num:=line_num+1;
      P_account_previous:=P_account;
   end loop;
   close unsatisfactory_list;

   -- When the unsatisfactory_list cursor is closed we need the
   --    totals for the last account it was on when it closed
   --    provided the last account was not 0 (indicates that

   --    no data was found)
   if (P_account_previous>0) then
   P_code_area:='UNSAT_LIST LAST TTLS ['||TO_CHAR(P_account_previous)||']';
      select one_month,six_month into month_count,year_count
      from pcs.adequacy_result_codes
      where pap_class=P_account_previous;
      char_buffer:=LPAD(RTRIM(LTRIM(TO_CHAR(month_count))),4);
      curr_line:=LPAD(MONTHLY_TOTAL_txt,29)||char_buffer;
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
      char_buffer:=LPAD(RTRIM(LTRIM(TO_CHAR(year_count))),4);
      curr_line:=LPAD(YEARLY_TOTAL_txt,29)||char_buffer;
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

      UTL_FILE.PUTF(file_handle,'%s\n',long_line);
      UTL_FILE.PUTF(file_handle,'%s\n\n',TOTAL_txt);
      char_buffer:=LPAD(RTRIM(LTRIM(TO_CHAR(month_cumulative))),6);
      curr_line:=LPAD(MONTHLY_TOTAL_txt,29)||char_buffer;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      char_buffer:=LPAD(RTRIM(LTRIM(TO_CHAR(year_cumulative))),6);
      curr_line:=LPAD(YEARLY_TOTAL_txt,29)||char_buffer;
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
      UTL_FILE.PUTF(file_handle,'%s\n',long_line);
   end if;

   P_code_area:='PRACTICE_LIST';
   column_heading:=LPAD('ACCT	  NAME',16)||LPAD('MONTH     YEAR',61);

   P_account_previous:=0;
   open practice_list;
   loop
      <<loop_top>>
      fetch practice_list into P_account,month_count,year_count;
      exit when practice_list%NOTFOUND;
      P_code_area:='PRACTICE_LIST: '||TO_CHAR(P_account,'009');
      -- If the yearly unsat count for the current account is 0
      -- 	 then there is not a monthly either, so do not print
      -- 	 and get the next row.
      if (year_count<1) then
	 goto loop_top;

      end if;
      if ((PAGE_LENGTH-line_num)<BOTTOM_MARGIN OR P_account_previous=0) then
	 curr_page:=curr_page+1;
	 UTL_FILE.PUT(file_handle,CHR(12));
	 char_buffer:=LTRIM(RTRIM(TO_CHAR(curr_page)));
	 offset:=LINE_LENGTH-LENGTH(REPORT_TITLE_txt);
	 curr_line:=REPORT_TITLE_txt||LPAD((PAGE_txt||' '||char_buffer),offset);
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',LAB_name);
	 UTL_FILE.PUTF(file_handle,'%s\n',PERIOD_ENDING_txt);
	 UTL_FILE.PUTF(file_handle,'%s\n',long_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',column_heading);
	 UTL_FILE.PUTF(file_handle,'%s\n',long_line);

	 line_num:=10;
      end if;
      P_account_previous:=P_account;
      curr_line:=LPAD(RTRIM(LTRIM(TO_CHAR(P_account,'009'))),7)||'     ';
      char_buffer:=pcs.get_account_name(P_account);
      curr_line:=curr_line||RPAD(SUBSTR(char_buffer,1,47),48);
      char_buffer:=RTRIM(LTRIM(TO_CHAR(month_count)));
      curr_line:=curr_line||LPAD(char_buffer,8);
      char_buffer:=RTRIM(LTRIM(TO_CHAR(year_count)));
      curr_line:=curr_line||LPAD(char_buffer,9);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_num:=line_num+1;
   end loop;

   close practice_list;

   UTL_FILE.PUT(file_handle,CHR(12));
   UTL_FILE.FCLOSE(file_handle);
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
      RAISE_APPLICATION_ERROR(-20054,'invalid operation ');
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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;

end;
\

grant execute on build_unsatisfactory_file to pcs_user
\
