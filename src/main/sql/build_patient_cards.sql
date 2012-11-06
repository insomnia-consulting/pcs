create or replace procedure     build_patient_cards
(
   S_practice in number,
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   PR_name varchar2(64);

   PR_addr1 varchar2(64);
   PR_addr2 varchar2(64);
   PR_city varchar2(32);
   PR_state varchar2(2);
   PR_zip varchar2(9);

   cursor lab_list is
      select p.lname,p.fname,p.address1,p.city,p.state,p.zip,
	 TO_CHAR(lq.date_collected,'MM/DD/YYYY'),p.patient
      from pcs.lab_requisitions lq, pcs.patients p, pcs.lab_results lr
      where lq.patient=p.patient and
	 lq.lab_number=lr.lab_number and
	 TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMM'))=S_month and lq.practice=S_practice

      order by p.lname, p.fname;

   S_file_name varchar2(12);
   dir_name varchar2(128);
   practice_id char(3);
   P_lname varchar2(32);
   P_fname varchar2(32);
   P_address varchar2(64);
   P_city varchar2(32);
   P_state char(2);
   P_zip varchar2(9);
   P_date varchar2(10);
   P_patient number;

   prac_phone varchar2(128);
   curr_line varchar2(100);
   cbuf varchar2(128);
   cbuf2 varchar2(128);
   rcnt number;
   margin varchar2(32);
   file_handle UTL_FILE.FILE_TYPE;

begin

   P_proc_name:='BUILD_PATIENT_CARDS';

   P_code_area:='PREP';

   practice_id:=LPAD(TO_CHAR(S_practice),3,'0');
   cbuf:=TO_CHAR(S_month);
   S_file_name:=RTRIM(practice_id||substr(cbuf,5,2)||substr(cbuf,1,1)||substr(cbuf,3,2))||'.pcd';
   dir_name:='REPORTS_DIR';
   
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   select name,address1,address2,city,state,SUBSTR(zip,1,5)
   into PR_name,PR_addr1,PR_addr2,PR_city,PR_state,PR_zip
   from pcs.practices where practice=S_practice;

   margin:='	';

   select phone into prac_phone from pcs.practices where practice=S_practice;

   cbuf:='(';
   cbuf2:=SUBSTR(prac_phone,1,3);
   cbuf:=cbuf||cbuf2||') ';
   cbuf2:=SUBSTR(prac_phone,4,3);
   cbuf:=cbuf||cbuf2||'-';
   cbuf2:=SUBSTR(prac_phone,7);
   cbuf:=cbuf||cbuf2;
   prac_phone:=LPAD(cbuf,41);

   P_code_area:='LABS';
   open lab_list;
   loop
      fetch lab_list into P_lname,P_fname,P_address,P_city,P_state,P_zip,P_date,P_patient;

      exit when lab_list%NOTFOUND;
      cbuf:=null;
      cbuf2:=null;
      curr_line:=null;
      UTL_FILE.NEW_LINE(file_handle,1);
      curr_line:=' Dear '||RTRIM(P_fname)||' '||RTRIM(P_lname)||':';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle);
      curr_line:=' Our records indicate it is time to repeat your Pap smear. Please call';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=' our office at your convenience for an appointment.';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle,2);

      UTL_FILE.PUTF(file_handle,'%s\n',prac_phone);
      UTL_FILE.NEW_LINE(file_handle,5);
      curr_line:='  '||RTRIM(P_fname)||' '||RTRIM(P_lname);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:='  '||P_address;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:='  '||RTRIM(P_city)||' '||P_state||'  '||SUBSTR(P_zip,1,5);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      cbuf:=LPAD(' ',36);
      curr_line:=cbuf||'Date of last Pap smear: '||P_date;
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
      curr_line:=cbuf||PR_name;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      curr_line:=cbuf||PR_addr1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=cbuf||PR_addr2;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=cbuf||PR_city||' '||PR_state||'  '||SUBSTR(PR_zip,1,5);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle,4);
   end loop;
   close lab_list;

   UTL_FILE.FCLOSE(file_handle);
   insert into pcs.pcard_queue values (S_practice,S_file_name);
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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,P_patient);

      commit;
      RAISE;

end;

\