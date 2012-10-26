create or replace procedure build_adph_851_file
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
   rcnt number;
   margin varchar2(32);

   ADPH_lab number;
   ADPH_patient varchar2(64);
   ADPH_patient_id varchar2(16);
   ADPH_DOS varchar2(16);
   ADPH_account number;
   ADPH_name varchar2(64);
   ADPH_provider varchar2(96);


   heading2 varchar2(256);
   heading3 varchar2(256);
   heading4 varchar2(256);
   heading5 varchar2(256);

   cbuf1 varchar2(256);

   S_period varchar2(64);

   last_date date;

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;


   cursor r_list is
      select a.lab_number, c.path_status, c.qc_status
      from pcs.practice_statement_labs a, pcs.practices b, pcs.lab_results c
      where a.lab_number=c.lab_number
      and a.practice=b.practice
      and b.practice_type='ADPH'
      and a.statement_id=S_month;
   L_num number;
   P_status varchar2(2);
   Q_status varchar2(2);

   cursor c_list is

      select bethesda_code from pcs.lab_result_codes
      where lab_number=L_num;

   cursor q_list is
      select bethesda_code from pcs.quality_control_codes
      where lab_number=L_num;

   cursor p_list is
      select bethesda_code from pcs.pathologist_control_codes
      where lab_number=L_num;

   b_code varchar2(4);
   b_cat char(1);



   -- Labs that had an 851 code
   cursor code_851 is
      select distinct a.lab_number,c.practice,
	 substr(c.name,1,24),substr(patient_name,1,24),
	 NVL(b.patient_id,' '),to_char(b.date_collected,'MM/DD/YYYY'),
	 substr(b.doctor_text,1,36)
      from practice_statement_labs a, lab_requisitions b,
	 practices c, temp_table d
      where statement_id=S_month
      and a.lab_number=b.lab_number

      and b.practice=c.practice
      and b.lab_number=d.row_id
      and c.practice_type='ADPH'
      and d.message_text='851'
      order by substr(c.name,1,24),substr(patient_name,1,24);

   cursor provider_counts is
      select e.lname||', '||e.fname,count(e.lname||', '||e.fname)
      from practice_statement_labs a, lab_requisitions b,
	 practices c, temp_table d, doctors e
      where statement_id=S_month
      and a.lab_number=b.lab_number
      and b.doctor=e.doctor

      and b.practice=c.practice
      and b.lab_number=d.row_id
      and c.practice_type='ADPH'
      and d.message_text='851'
      group by e.lname||', '||e.fname;

begin

   P_proc_name:='BUILD_ADPH_851_FILE';

   P_code_area:='PREP';
   check_point:=0;


      delete from pcs.temp_table;
      commit;
      open r_list;
      loop
	 fetch r_list into L_num,P_status,Q_status;
	 exit when r_list%NOTFOUND;
	 if (P_status='Y') then
	    open p_list;
	    loop
	       fetch p_list into b_code;
	       exit when p_list%NOTFOUND;
	       select category into b_cat from pcs.bethesda_codes
	       where bethesda_code=b_code;

	       if (b_cat='S') then
		  insert into pcs.temp_table (row_id,message_text)
		  values (L_num,b_code);
	       end if;
	    end loop;
	    close p_list;
	 elsif (Q_status='Y') then
	    open q_list;
	    loop
	       fetch q_list into b_code;
	       exit when q_list%NOTFOUND;
	       select category into b_cat from pcs.bethesda_codes
	       where bethesda_code=b_code;

	       if (b_cat='S') then
		  insert into pcs.temp_table (row_id,message_text)
		  values (L_num,b_code);
	       end if;
	    end loop;
	    close q_list;
	 else
	    open c_list;
	    loop
	       fetch c_list into b_code;
	       exit when c_list%NOTFOUND;
	       select category into b_cat from pcs.bethesda_codes
	       where bethesda_code=b_code;

	       if (b_cat='S') then
		  insert into pcs.temp_table (row_id,message_text)
		  values (L_num,b_code);
	       end if;
	    end loop;
	    close c_list;
	 end if;
      end loop;
      close r_list;
      commit;


   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));

   cbuf1:=TO_CHAR(last_date,'MONYYYY');
   S_file_name:=cbuf1||'.851';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   S_period:=TO_CHAR(last_date,'MONTHYYYY');

   P_code_area:='HEADER';
   heading2:='MONTHLY SUMMARY OF NO ENDOCERVICALS';
   heading3:='MONTH OF '||S_period;
   heading4:='ACCOUNT,LAB#,LAST,FIRST,ID#,DATE,PROVIDER';
   heading5:='PROVIDER NAME,COUNT';


   P_code_area:='851_CODES';

   UTL_FILE.PUTF(file_handle,'%s\n',heading2);
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3);
   UTL_FILE.PUTF(file_handle,'%s\n',heading4);

   open code_851;
   loop
      fetch code_851 into
	 ADPH_lab,ADPH_account,ADPH_name,ADPH_patient,
	 ADPH_patient_id,ADPH_DOS,ADPH_provider;
      exit when code_851%NOTFOUND;
      curr_line:=ADPH_name||','||ADPH_lab||','||ADPH_patient||','||

	 ADPH_patient_id||','||ADPH_DOS||','||ADPH_provider;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end loop;
   close code_851;

   UTL_FILE.NEW_LINE(file_handle);
   UTL_FILE.PUTF(file_handle,'%s\n',heading5);

   open provider_counts;
   loop
      fetch provider_counts into
	 ADPH_provider, rcnt;
      exit when provider_counts%NOTFOUND;

      curr_line:=ADPH_provider||','||rcnt;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end loop;
   close provider_counts;

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
      (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,ADPH_lab);
      commit;
      RAISE;

end;
\

grant execute on build_adph_851_file to pcs_user
\
