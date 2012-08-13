create or replace procedure     build_ADPH_abnormal_file
(
   S_month in number
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

   ADPH_lab number;
   ADPH_patient varchar2(64);
   ADPH_patient_id varchar2(16);
   ADPH_DOS varchar2(16);
   ADPH_account number;
   ADPH_name  varchar2(64);


   dline varchar2(256);
   heading1 varchar2(256);
   heading2 varchar2(256);
   heading3 varchar2(256);
   heading4 varchar2(256);
   heading5 varchar2(256);

   cbuf1 varchar2(256);

   S_period varchar2(64);

   last_date date;


   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

   -- Labs that had a 092 code with a positive HPV test
   cursor ascus_hpv is
      select distinct a.lab_number,c.practice,
	 substr(c.name,1,28),substr(patient_name,1,36),
	 NVL(b.patient_id,' '),to_char(b.date_collected,'MM/DD/YYYY')
      from practice_statement_labs a, lab_requisitions b,
	 practices c, pathologist_control_codes d,hpv_requests e
      where statement_id=S_month

      and a.lab_number=b.lab_number
      and b.practice=c.practice
      and b.lab_number=d.lab_number
      and d.lab_number=e.lab_number
      and e.test_results='+'
      and c.practice_type='ADPH'
      and d.bethesda_code='092'
      order by substr(c.name,1,28),substr(patient_name,1,36);

   -- Labs that had a code in the 100s
   cursor low_grade is
      select distinct a.lab_number,c.practice,

	 substr(c.name,1,28),substr(patient_name,1,36),
	 NVL(b.patient_id,' '),to_char(b.date_collected,'MM/DD/YYYY')
      from practice_statement_labs a, lab_requisitions b,
	 practices c, pathologist_control_codes d
      where statement_id=S_month
      and a.lab_number=b.lab_number
      and b.practice=c.practice
      and b.lab_number=d.lab_number
      and c.practice_type='ADPH'
      and d.bethesda_code like '10%'
      order by substr(c.name,1,28),substr(patient_name,1,36);

   -- Labs that had a code in the 200s

   cursor high_grade is
      select distinct a.lab_number,c.practice,
	 substr(c.name,1,28),substr(patient_name,1,36),
	 NVL(b.patient_id,' '),to_char(b.date_collected,'MM/DD/YYYY')
      from practice_statement_labs a, lab_requisitions b,
	 practices c, pathologist_control_codes d
      where statement_id=S_month
      and a.lab_number=b.lab_number
      and b.practice=c.practice
      and b.lab_number=d.lab_number
      and c.practice_type='ADPH'
      and d.bethesda_code like '20%'

      order by substr(c.name,1,28),substr(patient_name,1,36);

begin

   P_proc_name:='BUILD_ADPH_ABNORMAL_FILE';

   P_code_area:='PREP';
   check_point:=0;
   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));
   cbuf1:=TO_CHAR(last_date,'MONYYYY');
   S_file_name:=cbuf1||'.abn';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');


   S_period:=TO_CHAR(last_date,'MONTHYYYY');

   P_code_area:='HEADER';
   curr_page:=1;
   margin:='  ';
   dline:=margin||'----------------------------------------------------------------------------------------------';
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||'MONTHLY SUMMARY OF ABNORMALS FOR ADPH';
   heading3:=margin||'MONTH OF '||S_period;
   heading4:=margin||'ACCOUNT			 LAB#	       PATIENT NAME		   ID#		  DATE';

   line_num:=1;

   curr_page:=1;

   P_code_area:='ASCUS_HPV';
   heading5:=margin||'ASCUS HPV+';
   curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),64);
   line_num:=1;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
   UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
   UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading5); line_num:=line_num+2;
   UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;

   UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
   open ascus_hpv;
   loop
      fetch ascus_hpv into
	 ADPH_lab,ADPH_account,ADPH_name,ADPH_patient,ADPH_patient_id,ADPH_DOS;
      exit when ascus_hpv%NOTFOUND;
      if (line_num>=58) then
	 curr_page:=curr_page+1;
	 UTL_FILE.PUT(file_handle,chr(12));
	 curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),64);
	 line_num:=1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;

	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
	 UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
	 UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading5); line_num:=line_num+2;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
      end if;
      curr_line:=margin||RPAD(ADPH_name,27)||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,28)||
	 RPAD(ADPH_patient_id,15)||ADPH_DOS;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
   end loop;
   close ascus_hpv;


   line_num:=1;
   curr_page:=curr_page+1;
   P_code_area:='LOW GRADES';
   heading5:=margin||'LOW GRADES';
   UTL_FILE.PUT(file_handle,chr(12));
   curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),64);
   line_num:=1;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
   UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
   UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading5); line_num:=line_num+2;

   UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
   open low_grade;
   loop
      fetch low_grade into
	 ADPH_lab,ADPH_account,ADPH_name,ADPH_patient,ADPH_patient_id,ADPH_DOS;
      exit when low_grade%NOTFOUND;
      if (line_num>=58) then
	 curr_page:=curr_page+1;
	 UTL_FILE.PUT(file_handle,chr(12));
	 curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),64);
	 line_num:=1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;

	 UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
	 UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
	 UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading5); line_num:=line_num+2;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
      end if;
      curr_line:=margin||RPAD(ADPH_name,27)||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,28)||
	 RPAD(ADPH_patient_id,15)||ADPH_DOS;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
   end loop;
   close low_grade;


   line_num:=1;
   curr_page:=curr_page+1;
   P_code_area:='HIGH GRADES';
   heading5:=margin||'HIGH GRADES';
   UTL_FILE.PUT(file_handle,chr(12));
   curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),64);
   line_num:=1;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
   UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
   UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;

   UTL_FILE.PUTF(file_handle,'%s\n\n',heading5); line_num:=line_num+2;
   UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
   open high_grade;
   loop
      fetch high_grade into
	 ADPH_lab,ADPH_account,ADPH_name,ADPH_patient,ADPH_patient_id,ADPH_DOS;
      exit when high_grade%NOTFOUND;
      if (line_num>=58) then
	 curr_page:=curr_page+1;
	 UTL_FILE.PUT(file_handle,chr(12));
	 curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),64);
	 line_num:=1;

	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;
	 UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
	 UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading5); line_num:=line_num+2;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;
      end if;
      curr_line:=margin||RPAD(ADPH_name,27)||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,28)||
	 RPAD(ADPH_patient_id,15)||ADPH_DOS;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
   end loop;

   close high_grade;

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
      insert into pcs.error_log
	 (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,ADPH_lab);
      commit;
      RAISE;

end;
\
