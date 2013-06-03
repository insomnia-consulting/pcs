create or replace procedure     build_WV_invoice_summary_9
(
   S_month in number,
   cycle in number,
   pgm in varchar2
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);


   dir_name varchar2(128);
   S_file_name varchar2(128);

   curr_line varchar2(300);

   WV_account number;
   WV_name varchar2(64);

   tran_cost number;
   tran_total number;
   grand_total number;

   dline_1 varchar2(256);

   dline_2 varchar2(256);
   heading1 varchar2(256);
   heading2 varchar2(256);

   cbuf1 varchar2(256);
   cbuf2 varchar2(256);

   f_date date;

   cursor WV_list is
      select distinct a.practice,b.name
      from pcs.practice_statement_labs a, pcs.practices b
      where a.practice=b.practice

      and b.practice_type='WV'
      and b.program=pgm
      and a.statement_id=S_month
      and billing_cycle=cycle
      order by a.practice;

   cursor transaction_list is
      select ps.item_amount
    	from
	   pcs.lab_requisitions a,
	 pcs.practice_statement_labs ps,
	 pcs.patients p
      where a.lab_number=ps.lab_number

      and a.patient=p.patient
      and ps.practice=WV_account
      and ps.statement_id=S_month
      and ps.billing_cycle=cycle
      order by a.lab_number;

   file_handle UTL_FILE.FILE_TYPE;

begin

   P_proc_name:='BUILD_WV_INVOICE_SUMMARY_9';

   P_code_area:='PREP';

   f_date:=TO_DATE(TO_CHAR(S_month),'YYYYMM');
   cbuf1:=TO_CHAR(f_date,'MONYYYY');
   cbuf2:=SUBSTR(pgm,1,2);
   S_file_name:=cbuf1||'.'||cbuf2||'9';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   P_code_area:='HEADER';
   dline_1:='-------------------------------------'||
      '-------------------------------------------';
   dline_2 := lpad('--------', 80);
   heading1:='PENNSYLVANIA CYTOLOGY SERVICES';

   heading2:=
      'ACCT	  NAME								    AMT';

   UTL_FILE.PUTF(file_handle,'%s\n',heading1);
   UTL_FILE.PUTF(file_handle,'%s\n\n','***** REPORT FOR '||pgm||' ACCOUNTS *****');
   UTL_FILE.PUTF(file_handle,'%s\n',heading2);

   P_code_area:='WV_LIST';
   grand_total:=0;
   open WV_list;
   loop
      fetch WV_list into WV_account,WV_name;
      exit when WV_list%NOTFOUND;

      tran_total:=0;
      open transaction_list;
      loop
	 fetch transaction_list into tran_cost;
	 exit when transaction_list%NOTFOUND;
	 tran_total:=tran_total+tran_cost;
      end loop;
      close transaction_list;
      cbuf1:=TO_CHAR(tran_total,'99,999.00');
      curr_line:=LPAD(cbuf1,80);
      grand_total:=grand_total+tran_total;
      curr_line:=TO_CHAR(WV_account,'009')||'	    '||RPAD(WV_name,59)||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   end loop;
   close WV_list;
   cbuf1:=TO_CHAR(grand_total,'99,999.00');
   curr_line:=LPAD(cbuf1,80);
   UTL_FILE.PUTF(file_handle,'\n%s\n',dline_2);
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   UTL_FILE.PUTF(file_handle,'%s\n',dline_1);
   commit;

   UTL_FILE.FCLOSE(file_handle);

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
	 (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,WV_account);
      commit;

      RAISE;

end;
\

grant execute on build_WV_invoice_summary_9 to pcs_user
\