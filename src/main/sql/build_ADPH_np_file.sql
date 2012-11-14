create or replace procedure     build_adph_np_file
(
   begin_date varchar2,
   end_date varchar2
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_file_name varchar2(12);

   dir_name varchar2(128);

   curr_line varchar2(512);
   line_num number;
   curr_page number;
   rcnt number;
   margin varchar2(32);

   ADPH_lname varchar2(64);
   ADPH_fname varchar2(64);
   ADPH_patient_id varchar2(16);
   ADPH_account number;
   ADPH_name varchar2(128);

   ADPH_DOS varchar2(24);
   PCS_lab_number number;

   cbuf1 varchar2(256);
   cbuf2 varchar2(256);

   B_date date;
   E_date date;

   cursor ADPH_list is
	select A.lab_number,C.name,C.practice,
	 E.lname,E.fname,A.patient_id,TO_CHAR(A.date_collected,'MM/DD/YYYY')
	from lab_requisitions a, adph_lab_whp B,

		practices C, patients E
	where A.lab_number=B.lab_number
	and A.practice=C.practice
	and A.patient=E.patient
      and A.datestamp>=B_date
      and A.datestamp<=E_date
	and B.adph_program='NP' order by C.practice,E.lname
   for update of np_file_date;

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

begin


   P_proc_name:='BUILD_ADPH_NP_FILE';
   P_code_area:='PREP';
   check_point:=0;

   -- If the in param end_date is NULL then the assumption is made that
   --    that the program should be run starting with the begin_date (which
   --    would typically be the first of a month) ending with the last day
   --    of the same month.
   B_date:=TO_DATE(begin_date,'MMDDYYYY');
   if (end_date is NULL) then
      P_code_area:='NULL_END_DATE_SET';

      E_date:=LAST_DAY(B_date);
      S_file_name:=TO_CHAR(B_date,'MONYY')||'NP.txt';
   else
      E_date:=TO_DATE(end_date,'MMDDYYYY');
      S_file_name:='NO_PGM.txt';
   end if;

   P_code_area:='CREATE_FILE';
   dir_name:='REPORTS_DIR';
   
   
   
   
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   P_code_area:='HEADER';
   curr_line:='BEGIN: '||TO_CHAR(B_date,'MM/DD/YYYY');

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='END:   '||TO_CHAR(E_date,'MM/DD/YYYY');
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='RETURN FILE DETAILS';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   if (end_date is NULL) then
      cbuf1:=SUBSTR(S_file_name,1,7)||'.csv';
   else
      cbuf1:='NO_PGM.csv';
   end if;
   curr_line:='Please ensure that the file name of the return file is: '||cbuf1;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='Please ensure that these guidelines are followed.';

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='Each line of the return file MUST contain three and only three';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='data elements - each separated by a comma.';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='Data element #1 is the ACCOUNT#';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='Data element #2 is the PCS LAB#';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='Data element #3 is the Program Code';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='There are ONLY five valid values for data '||
      'element #3 - Program Code';

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='Please ensure that ONLY one of these five values is used:';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='   FP	   (FAMILY PLANNING)';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='   MAT	   (MATERNITY PROGRAM)';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='   ABCCEDP  (ALABAMA BREAST AND CERVICAL CANCER)';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='   NP	   (NO PROGRAM IDENTIFICATION)';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='   GYN	   (GYN)';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;

   curr_line:='Please ensure that NO data element is left blank (i.e. no value)';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='Invalid program code or missing values will cause the';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
   curr_line:='PCS data processing program to crash.';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;
   curr_line:='NAME,ACCOUNT,LNAME,FNAME,PATIENT_ID,LAB_NUMBER,DOS';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;

   P_code_area:='ADPH LIST';
   open ADPH_list;
   loop
      fetch ADPH_list into PCS_lab_number,ADPH_name,ADPH_account,

	 ADPH_lname,ADPH_fname,ADPH_patient_id,ADPH_DOS;
      exit when ADPH_list%NOTFOUND;
      curr_line:=RTRIM(ADPH_name)||','||TO_CHAR(ADPH_account)||
	 ','||ADPH_lname||','||ADPH_fname||','||ADPH_patient_id||','||
	 PCS_lab_number||','||ADPH_DOS;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+2;
      update pcs.adph_lab_whp
      set np_file_date=TO_DATE(TO_CHAR(SysDate,'MMDDYYYY'),'MMDDYYYY')
      where current of ADPH_list;

   end loop;
   close ADPH_list;
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
	(error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values
	(P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;

end;
\

grant execute on build_adph_np_file to pcs_user
\