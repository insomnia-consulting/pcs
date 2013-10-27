create or replace procedure     build_ADPH_invoice_summ_file
(
   S_month in number,
   cycle in number
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
   margin varchar2(32);

   ADPH_account number;
   ADPH_name varchar2(64);
   ADPH_addr1 varchar2(64);
   ADPH_addr2 varchar2(64);
   ADPH_city varchar2(32);

   ADPH_state varchar2(2);
   ADPH_zip varchar2(5);
   ADPH_price varchar2(2);

   tran_descr varchar2(64);
   tran_count number;
   tran_amount number;
   tran_total number;
   tran_proc varchar2(5);
   tran_item number;

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

   cursor ADPH_list is
      select distinct a.practice,b.name,b.address1,
	 b.address2,b.city,b.state,SUBSTR(b.zip,1,5),b.price_code
      from practice_statement_labs a, practices b
      where a.practice=b.practice and b.practice_type='ADPH'
      and a.statement_id=S_month and billing_cycle=cycle
      order by a.practice;

   cursor transaction_list is

      select code_description,count(code_description),sum(item_amount),procedure_code
      from practice_statement_labs where practice=ADPH_account
      and statement_id=S_month and billing_cycle=cycle
      group by code_description,procedure_code;

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

begin

   P_proc_name:='BUILD_ADPH_INVOICE_SUMM_FILE';

   P_code_area:='PREP';

   check_point:=0;
   invoice_date:=TO_CHAR(SysDate,'MM/DD/YYYY');
   f_date:=TO_DATE(TO_CHAR(S_month),'YYYYMM');
   cbuf1:=TO_CHAR(f_date,'MONYYYY');
   cbuf2:=RTRIM(LTRIM(TO_CHAR(cycle)));
   S_file_name:=cbuf1||'.is'||cbuf2;
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   P_code_area:='HEADER';
   curr_page:=1;
   margin:='  ';
   dline:=margin||'--------------------------------------------------------------------------';

   dline2:=margin||'								      --------';
   heading1A:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading1B:=margin||'SUITE 1700 PARKWAY BUILDLING';
   heading1C:=margin||'339 OLD HAYMAKER ROAD';
   heading1D:=margin||'MONROEVILLE, PA	15146';
   heading2:=margin||'INVOICE SUMMARY FOR ';
   heading3:=margin||'DATE OF INVOICE: '||invoice_date;
   heading4:=margin||'TEST NAME 			 QUANTITY' || chr(38) || ' COST		   TOTAL';
   heading5:='INVOICE #';

   line_num:=1;
   curr_page:=1;
   P_code_area:='ADPH_LIST';

   open ADPH_list;
   loop
      fetch ADPH_list into
	 ADPH_account,ADPH_name,ADPH_addr1,ADPH_addr2,
	 ADPH_city,ADPH_state,ADPH_zip,ADPH_price;
      exit when ADPH_list%NOTFOUND;
      invoice_number:=TO_CHAR(S_month)||LTRIM(RTRIM(TO_CHAR(ADPH_account,'009')))||'-'||TO_CHAR(cycle);
      curr_line:=heading1A||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),44);
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;
      UTL_FILE.PUTF(file_handle,'%s\n',heading1B); line_num:=line_num+2;
      UTL_FILE.PUTF(file_handle,'%s\n',heading1C); line_num:=line_num+2;
      UTL_FILE.PUTF(file_handle,'%s\n',heading1D); line_num:=line_num+2;
      cbuf1:=heading5||invoice_number;

      cbuf2:=LPAD(cbuf1,(54-LENGTH(ADPH_name)));
      curr_line:=heading2||ADPH_name||cbuf2;
      UTL_FILE.PUTF(file_handle,'\n\n\n%s\n',curr_line); line_num:=line_num+1;
      curr_line:=margin||'CLINIC ACCOUNT #'||
      LTRIM(TO_CHAR(ADPH_account,'009'));
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
      UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
      UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
      curr_line:=margin||margin||margin||margin||margin||ADPH_name;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      curr_line:=margin||margin||margin||margin||margin||ADPH_addr1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;

      if (ADPH_addr2 is NOT NULL) then
	 curr_line:=margin||margin||margin||margin||margin||ADPH_addr2;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      end if;
      curr_line:=margin||margin||margin||margin||margin||ADPH_city||', '||ADPH_state||'  '||ADPH_zip;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'\n\n\n\n\n\n\n%s\n',heading4); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
      open transaction_list;
      loop
	 fetch transaction_list into tran_descr,tran_count,tran_amount,tran_proc;
	 exit when transaction_list%NOTFOUND;
	 select discount_price into tran_item

	 from pcs.price_code_details
	 where procedure_code=tran_proc and price_code=ADPH_price and lab_number=0;
	 cbuf1:=TO_CHAR(tran_count);
	 cbuf2:=TO_CHAR(tran_item,'999.00');
	 cbuf3:=TO_CHAR(tran_amount,'99,999.00');
	 curr_line:=margin||RPAD(tran_descr,30)||' '||LPAD(cbuf1,6)||
	    ' @ '||LTRIM(RTRIM(cbuf2))||'/each '||LPAD(cbuf3,23);
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      end loop;
      close transaction_list;
      select sum(item_amount) into tran_total from pcs.practice_statement_labs
      where practice=ADPH_account and statement_id=S_month and billing_cycle=cycle;
      cbuf1:=TO_CHAR(tran_total,'99,999.00');

      curr_line:=margin||LPAD(cbuf1,74);
      UTL_FILE.PUTF(file_handle,'%s\n',dline2); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
      line_num:=50;
      curr_page:=curr_page+1;
      UTL_FILE.PUT(file_handle,chr(12));
   end loop;
   close ADPH_list;
   commit;

   UTL_FILE.PUT(file_handle,CHR(12));
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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,ADPH_account);

      commit;
      RAISE;

end;
\

grant execute on build_ADPH_invoice_summ_file to pcs_user
\
