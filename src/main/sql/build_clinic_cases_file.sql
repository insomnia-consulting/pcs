create or replace procedure  build_clinic_cases_file
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_file_name varchar2(12);
   S_name varchar2(64);

   S_fname varchar2(32);
   dir_name varchar2(128);
   S_cytotech number;
   S_tech varchar2(4);
   S_prep number;
   curr_line varchar2(300);
   curr_page number;
   rcnt number;
   margin varchar2(32);
   dline varchar2(256);
   dline2 varchar2(256);
   heading1 varchar2(256);
   heading2 varchar2(256);

   heading3 varchar2(256);
   heading4 varchar2(256);
   heading5 varchar2(256);
   heading6 varchar2(256);
   heading7 varchar2(256);
   cbuf1 varchar2(256);
   cbuf2 varchar2(256);

   S_period varchar2(64);
   last_practice number;
   curr_count number;
   curr_total number;
   total_count number;


   num_single_slide number;
   num_two_slide number;
   num_non_gyne number;
   num_pathologist number;
   num_qc number;
   num_completed number;
   num_limited number;
   ttl_single_slide number;
   ttl_two_slide number;
   ttl_non_gyne number;
   ttl_pathologist number;
   ttl_qc number;

   ttl_completed number;
   ttl_path_conv number;
   ttl_path_thin number;
   ttl_qc_conv number;
   ttl_qc_thin number;
   ttl_limited_conv number;
   ttl_limited_thin number;
   p_class number;
   num_conventional number;
   num_thin_prep number;
   ttl_conventional number;
   ttl_thin_prep number;
   ttl_limited number;


   temp_num1 number;
   temp_num2 number;

   S_comp_date varchar2(32);
   total_completed number;
   last_date date;

   cursor clinic_cases is
      select c.lname||', '||c.fname,
	 count(c.lname||', '||c.fname),
	 sum(decode(lq.preparation,1,1,0)),
	 sum(decode(lq.preparation,2,1,0))

      from pcs.lab_results lr, pcs.lab_requisitions lq, pcs.cytotechs c
      where lr.lab_number=lq.lab_number and
	 lr.cytotech=c.cytotech and
	 TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMM'))=S_month and
	 lq.preparation in (1,2) and
	 lq.practice>=600 and lq.practice<800 and
	 lq.practice<>770
      group by c.lname||', '||c.fname;


   file_handle UTL_FILE.FILE_TYPE;
   check_point number;


begin

   P_proc_name:='BUILD_CLINIC_CASES_FILE';

   P_code_area:='PREP';
   check_point:=0;
   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));
   cbuf1:=TO_CHAR(last_date,'MONYYYY');
   S_file_name:=cbuf1||'.cln';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   S_period:=TO_CHAR(last_date,'MONTH YYYY');


   P_code_area:='HEADER';
   curr_page:=1;
   margin:='	      ';
   dline:=margin||'----------------------------------------------------------------';
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||'CLINIC CASES BY CYTOLOGIST';
   heading3:=margin||'MONTH OF '||S_period;
   heading4:=margin||'NAME				    TP	    CONV       TTL';

   UTL_FILE.PUTF(file_handle,'\n%s\n',heading1);
   UTL_FILE.PUTF(file_handle,'%s\n',heading2);
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3);

   UTL_FILE.PUTF(file_handle,'\n%s\n',dline);
   UTL_FILE.PUTF(file_handle,'%s\n',heading4);
   UTL_FILE.PUTF(file_handle,'%s\n',dline);

   P_code_area:='STATS';
   open clinic_cases;
   loop
      fetch clinic_cases into S_name,num_completed,num_conventional,num_thin_prep;
      exit when clinic_cases%NOTFOUND;
      curr_line:=margin||RPAD(S_name,30)||LPAD(TO_CHAR(num_thin_prep),10)||
	 LPAD(TO_CHAR(num_conventional),10)||LPAD(TO_CHAR(num_completed),10);
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
   end loop;

   close clinic_cases;
   commit;

   UTL_FILE.PUTF(file_handle,'\n%s\n',dline);
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_cytotech);
      commit;
      RAISE;

end;
\

grant execute on build_clinic_cases_file to pcs_user
\
