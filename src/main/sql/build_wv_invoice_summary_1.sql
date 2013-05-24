create or replace procedure     build_WV_invoice_summary_1
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


   S_file_name varchar2(12);
   dir_name varchar2(128);

   curr_line varchar2(300);
   line_num number;
   curr_page number;
   rcnt number;

   WV_account number;
   WV_name varchar2(64);
   WV_addr1 varchar2(64);
   WV_addr2 varchar2(64);
   WV_city varchar2(32);

   WV_state varchar2(2);
   WV_zip varchar2(5);
   WV_price varchar2(2);

   tran_DOS varchar2(16);
   tran_SSN varchar2(16);
   tran_patient varchar2(32);
   tran_CPT varchar2(8);
   tran_descr varchar2(32);
   tran_item varchar2(16);
   tran_cost number;
   tran_total number;
   grand_total number;


   dline varchar2(256);
   dline2 varchar2(256);
   heading1A varchar2(256);
   heading1B varchar2(256);
   heading1C varchar2(256);
   heading1D varchar2(256);
   heading2 varchar2(256);
   heading3 varchar2(256);
   heading4 varchar2(256);
   heading5 varchar2(256);

   cbuf1 varchar2(256);

   cbuf2 varchar2(256);
   cbuf3 varchar2(256);
   cbuf4 varchar2(256);

   invoice_date varchar2(16);
   invoice_number varchar2(16);
   f_date date;

   cursor WV_list is
      select distinct a.practice,b.name,b.address1,
	 b.address2,b.city,b.state,SUBSTR(b.zip,1,5),b.price_code
      from pcs.practice_statement_labs a, pcs.practices b
      where a.practice=b.practice

      and b.practice_type='WV'
      and b.program=pgm
      and a.statement_id=S_month
      and billing_cycle=cycle
      order by a.practice;

   cursor transaction_list is
      select
	 to_char(ps.date_collected,'MM/DD/YY'),
	 SUBSTR(p.ssn,1,3)||'-'||SUBSTR(p.ssn,4,2)||'-'||SUBSTR(p.ssn,6),
	 SUBSTR(ps.patient_name,1,19),
	 ps.procedure_code,
	 SUBSTR(ps.code_description,1,24),

	 TO_CHAR(ps.item_amount,'999.00'),
	 ps.item_amount
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
   check_point number;

begin

   P_proc_name:='BUILD_WV_INVOICE_SUMMARY_1';

   P_code_area:='PREP';
   check_point:=0;
   invoice_date:=TO_CHAR(SysDate,'MM/DD/YYYY');
   f_date:=TO_DATE(TO_CHAR(S_month),'YYYYMM');
   cbuf1:=TO_CHAR(f_date,'MONYYYY');
   cbuf2:=RTRIM(LTRIM(TO_CHAR(cycle)));

   cbuf3:=SUBSTR(pgm,1,2);
   S_file_name:=cbuf1||'.'||cbuf3||'1';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   P_code_area:='HEADER';
   curr_page:=1;
   dline:='-------------------------------------'||
      '-------------------------------------------';
   dline2:= lpad('--------', 80);
   heading1A:='PENNSYLVANIA CYTOLOGY SERVICES';
   heading1B:='SUITE 1700 PARKWAY BUILDLING';

   heading1C:='339 OLD HAYMAKER ROAD';
   heading1D:='MONROEVILLE, PA	15146';
   heading2:='INVOICE SUMMARY FOR ';
   heading3:='DATE OF INVOICE: '||invoice_date;
   heading4:=
      'DOS	SSN	     PATIENT		  CPT/DESCRIPTION		 AMOUNT';
   heading5:='INVOICE #';

   UTL_FILE.PUTF(file_handle,'%s\n',heading1A); line_num:=line_num+2;
   UTL_FILE.PUTF(file_handle,'%s\n',heading1B); line_num:=line_num+2;
   UTL_FILE.PUTF(file_handle,'%s\n',heading1C); line_num:=line_num+2;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading1D); line_num:=line_num+2;
   UTL_FILE.PUTF(file_handle,'%s\n\n','***** REPORT FOR '||pgm||' ACCOUNTS *****');

   line_num:=1;
   curr_page:=1;
   P_code_area:='WV_LIST';
   grand_total:=0;

   open WV_list;
   loop
      fetch WV_list into
	 WV_account,WV_name,WV_addr1,WV_addr2,
	 WV_city,WV_state,WV_zip,WV_price;
      exit when WV_list%NOTFOUND;
      invoice_number:=TO_CHAR(S_month)||
	 LTRIM(RTRIM(TO_CHAR(WV_account,'009')))||'-'||TO_CHAR(cycle);

      cbuf1:=heading5||invoice_number;
      cbuf2:=LPAD(cbuf1,(60-LENGTH(WV_name)));
      curr_line:=heading2||WV_name||cbuf2;
      UTL_FILE.PUTF(file_handle,'\n\n\n%s\n',curr_line); line_num:=line_num+1;
      curr_line:='CLINIC ACCOUNT #'||
      LTRIM(TO_CHAR(WV_account,'009'));
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
      UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
      tran_total:=0;
      open transaction_list;

      loop
	 fetch transaction_list into
	    tran_DOS,tran_SSN,tran_patient,tran_CPT,tran_descr,
	    tran_item,tran_cost;
	 exit when transaction_list%NOTFOUND;
	 curr_line:=RPAD(tran_DOS,9)||RPAD(tran_SSN,13)||RPAD(tran_patient,21)||
	    tran_CPT||'-'||RPAD(tran_descr,24)||LPAD(tran_item,7);
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
	 tran_total:=tran_total+tran_cost;
      end loop;
      close transaction_list;
      cbuf1:=TO_CHAR(tran_total,'99,999.00');
      curr_line:=LPAD(cbuf1,80);

      UTL_FILE.PUTF(file_handle,'%s\n',dline2); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
      grand_total:=grand_total+tran_total;
   end loop;
   close WV_list;
   cbuf1:=TO_CHAR(grand_total,'99,999.00');
   curr_line:=LPAD(cbuf1,80);
   UTL_FILE.PUTF(file_handle,'\n%s\n',dline2); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
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

grant execute on build_WV_invoice_summary_1 to pcs_user
\