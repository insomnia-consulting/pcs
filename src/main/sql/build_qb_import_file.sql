create or replace procedure build_qb_import_file
(
   statement in number,
   filename in varchar2,
   cycle in number
)
AS

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);


   file_handle UTL_FILE.FILE_TYPE;

   practice varchar2(20);
   lab_number varchar2(20);
   short_lab_number varchar2(20);
   name varchar2(80);
   date_results_entered varchar2(20);
   procedure_code varchar2(20);
   code_description varchar2(80);
   item_amount varchar2(20);
   choice_code varchar2(20);
   date_collected varchar2(20);


   cursor bill_item is
      select TO_CHAR(a.practice),TO_CHAR(a.lab_number),
	 SUBSTR(TO_CHAR(a.lab_number),5,10),
	 a.patient_name, a.date_results_entered,a.procedure_code,a.code_description,
	 TO_CHAR(a.item_amount,'9999.99'),RTRIM(a.choice_code),
	 TO_CHAR(a.date_collected,'MMDD')
      from pcs.practice_statement_labs a, pcs.practices b
      where a.practice=b.practice
      and a.statement_id=statement
      and b.program not in ('BCCSP','FPP')
      and a.billing_cycle=cycle
      order by a.lab_number,a.p_seq;


BEGIN

   P_proc_name:='BUILD_QB_IMPORT_FILE';
   P_code_area:='OPEN FILE';

   file_handle:=UTL_FILE.FOPEN('REPORTS_DIR',filename,'w');

   UTL_FILE.PUTF(file_handle,'%s\n',
     'PRACTICE|LAB_NUMBER|SHORT_LAB_NUMBER|NAME|DAY|CODE|DESCRIPTION|'||
     'FEE|BILLING_ROUTE|DATE_COLLECTED','w');
	
   P_code_area:='BILL_ITEM CURSOR';
   open bill_item;	

   loop
      fetch bill_item into
	 practice,lab_number,short_lab_number,name,date_results_entered,
	 procedure_code,code_description,item_amount,choice_code,date_collected;
	exit when bill_item%NOTFOUND;
      UTL_FILE.PUTF(file_handle,'%s\n',
	 practice || '|' || lab_number || '|' || short_lab_number || '|' ||
	 name || '|' || date_results_entered || '|' || procedure_code || '|' ||
	 code_description || '|' || item_amount || '|' || choice_code || '|' ||
	 date_collected);
   end loop;
   close bill_item;


   UTL_FILE.NEW_LINE(file_handle);
   UTL_FILE.FCLOSE(file_handle);

EXCEPTION

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
      RAISE_APPLICATION_ERROR(-20054,'invalid operation '||P_code_area);
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
	(P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,practice);
      commit;
      RAISE;

END;
\

grant execute on build_qb_import_file to pcs_user
\