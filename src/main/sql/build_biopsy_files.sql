create or replace procedure     build_biopsy_files
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_practice number;
   S_practice_id varchar2(8);

   S_name varchar2(64);
   S_file_name varchar2(12);
   L_file_name varchar2(12);
   S_lab_number number;
   S_lname varchar2(32);
   S_fname varchar2(32);
   S_prname varchar2(64);
   S_ssn varchar2(16);
   dir_name varchar2(128);
   S_addr1 varchar2(64);
   S_addr2 varchar2(64);
   S_city varchar2(32);
   S_state char(2);

   S_zip char(5);
   S_recv_date char(10);
   S_comp_date char(10);
   S_description varchar2(256);
   S_code varchar2(4);
   S_tech char(3);
   S_path char(3);
   S_dr_fname varchar2(32);
   S_dr_lname varchar2(32);
   S_doctor_text varchar2(128);
   BX_request char(1);
   curr_line varchar2(300);
   cbuf1 varchar2(128);

   cbuf2 varchar2(128);
   line_num number;
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
   cbuf varchar2(256);

   has_qc char(1);
   has_path char(1);

   S_period varchar2(64);
   last_practice number;
   last_date date;
   un_count number;
   curr_count number;
   total_count number;
   p_class number;

   cursor biopsy_list is
      select lr.lab_number,NVL(p.fname,' '),p.lname,pr.practice,LTRIM(TO_CHAR(pr.practice,'009')),pr.name,

	 pr.address1,pr.address2,pr.city,pr.state,SUBSTR(pr.zip,1,5),lq.doctor_text,
	 TO_CHAR(lq.receive_date,'MM/DD/YYYY'),TO_CHAR(lr.date_completed,'MM/DD/YYYY'),
	 pc.description,NVL(lr.pathologist,'***'),ct.cytotech_code,lr.qc_status,
	 lr.path_status,lr.biopsy_code,SUBSTR(p.ssn,6)
      from pcs.lab_requisitions lq, pcs.lab_results lr,
	 pcs.practices pr, pcs.patients p, pcs.pap_classes pc, pcs.cytotechs ct
      where lq.lab_number=lr.lab_number and lr.biopsy_code is not null and
	 lq.practice=pr.practice and lq.patient=p.patient and
	 lr.pap_class=pc.pap_class and lr.cytotech=ct.cytotech and
	 TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMM'))=S_month
      order by pr.practice, p.lname;

   summary_file UTL_FILE.FILE_TYPE;

   letters_file UTL_FILE.FILE_TYPE;
   check_point number;

begin

   P_proc_name:='BUILD_BIOPSY_FILES';

   P_code_area:='PREP';
   line_num:=1;
   last_practice:=0;
   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));
   check_point:=0;
   cbuf1:=TO_CHAR(last_date,'MONYYYY');

   S_file_name:=cbuf1||'.rfb';
   L_file_name:=cbuf1||'.rbl';
   dir_name:='REPORTS_DIR';
   summary_file:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');
   letters_file:=UTL_FILE.FOPEN(dir_name,L_file_name,'w');

   S_period:=TO_CHAR(last_date,'MONTH YYYY');

   P_code_area:='HEADER';
   curr_page:=1;
   margin:='   ';
   dline:=margin||margin||'--------------------------------------------------------------------------------------------------------------------------------';
   dline2:=margin||margin||'======================================================================';

   heading1:=margin||margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||margin||'MONTHLY DOCTOR BIOPSY REQUEST SUMMARY';
   heading3:=margin||margin||'MONTH OF '||S_period;
   heading4:=margin||margin||'PAGE '||curr_page;
   heading5:=margin||margin||'LAB #	     NAME:				     PATH:     TECH:	 CODE:	   PAP RESULT:';

   UTL_FILE.PUTF(summary_file,'\n%s\n',heading1); line_num:=line_num+2;
   UTL_FILE.PUTF(summary_file,'%s\n',heading2); line_num:=line_num+1;
   UTL_FILE.PUTF(summary_file,'%s\n',heading3); line_num:=line_num+1;
   UTL_FILE.PUTF(summary_file,'%s\n\n',heading4); line_num:=line_num+2;
   UTL_FILE.PUTF(summary_file,'%s\n',heading5);  line_num:=line_num+1;

   P_code_area:='BIOPSY';
	dbms_output.put_line('Starting the Biopsy report');
   open biopsy_list;
   loop
      <<loop_top>>
      check_point:=1;
      fetch biopsy_list into S_lab_number,S_fname,S_lname,S_practice,
	 S_practice_id,S_prname,S_addr1,S_addr2,S_city,S_state,S_zip,S_doctor_text,
	 S_recv_date,S_comp_date,S_description,S_path,S_tech,has_qc,
	 has_path,S_code,S_ssn;
      exit when biopsy_list%NOTFOUND;
      select biopsy_request into BX_request from pcs.bethesda_codes
      where bethesda_code=S_code;
      if (BX_request<>'Y') then
	 goto loop_top;

      end if;
	 check_point:=3;
	 
	    -- Write out data for summary file
	 if (last_practice<>S_practice) then
	    check_point:=4;
	    dbms_output.put_line('Biopsy Report output');
	    UTL_FILE.PUTF(summary_file,'%s\n\n',dline); line_num:=line_num+2;
	    if (line_num>50) then
	       UTL_FILE.PUT(summary_file,CHR(12));
	       line_num:=1;
	       curr_page:=curr_page+1;
	       heading4:=margin||margin||margin||'PAGE '||curr_page;

	       UTL_FILE.PUTF(summary_file,'\n%s\n',heading1); line_num:=line_num+2;
	       UTL_FILE.PUTF(summary_file,'%s\n',heading2); line_num:=line_num+1;
	       UTL_FILE.PUTF(summary_file,'%s\n',heading3); line_num:=line_num+1;
	       UTL_FILE.PUTF(summary_file,'%s\n\n',heading4); line_num:=line_num+2;
	       UTL_FILE.PUTF(summary_file,'%s\n',heading5);  line_num:=line_num+1;
	       UTL_FILE.PUTF(summary_file,'%s\n\n',dline); line_num:=line_num+2;
	    end if;
	    check_point:=4.1;
	    curr_line:=margin||margin||'ACCOUNT #'||S_practice_id||'   '||S_prname;
	    check_point:=4.2;
	    UTL_FILE.PUTF(summary_file,'%s\n\n',curr_line); line_num:=line_num+2;
	    check_point:=4.3;
	    curr_count:=0;

	 end if;
	 check_point:=4.8;
	 P_code_area:='GET PCLASS '||S_code||'.';
	 select papclass into p_class from pcs.bethesda_codes
	 where bethesda_code=S_code;
	 P_code_area:='GET DESC '||S_Code;
	 select description into S_description from pcs.pap_classes
	 where pap_class=p_class;
	 P_code_area:='WRITE DATA';
	 curr_line:=margin||margin||S_lab_number||'	'||RPAD(SUBSTR(RTRIM(S_lname)||', '||RTRIM(S_fname),1,34),40)||S_path||'       '||S_tech||'	  '||S_code||'	     '||S_description;
	 UTL_FILE.PUTF(summary_file,'%s\n',curr_line); line_num:=line_num+1;
	 if (line_num>50) then
	    UTL_FILE.PUT(summary_file,CHR(12));

	    line_num:=1;
	    curr_page:=curr_page+1;
	    heading4:=margin||margin||'PAGE '||curr_page;
	    UTL_FILE.PUTF(summary_file,'\n%s\n',heading1); line_num:=line_num+2;
	    UTL_FILE.PUTF(summary_file,'%s\n',heading2); line_num:=line_num+1;
	    UTL_FILE.PUTF(summary_file,'%s\n',heading3); line_num:=line_num+1;
	    UTL_FILE.PUTF(summary_file,'%s\n\n',heading4); line_num:=line_num+2;
	    UTL_FILE.PUTF(summary_file,'%s\n',heading5);  line_num:=line_num+1;
	    UTL_FILE.PUTF(summary_file,'%s\n\n',dline); line_num:=line_num+2;
	 end if;
	 last_practice:=S_practice;
	 check_point:=5;
	 

	    -- Write out data for letters file
	 UTL_FILE.PUTF(letters_file,'\n%s (#%s)\n',margin||margin||S_prname,S_practice_id);
	 UTL_FILE.PUTF(letters_file,'%s\n',margin||margin||S_addr1);
	 if (S_addr2 is not null) then
	    UTL_FILE.PUTF(letters_file,'%s\n',margin||margin||S_addr2);
	 end if;
	 curr_line:=margin||margin||RTRIM(S_city)||', '||S_state||'  '||SUBSTR(S_zip,1,5);
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||'Attention '||S_prname;
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||'	Our laboratory is updating records in compliance with federal';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);

	 curr_line:=margin||margin||'regulations and current quality assurance programs on abnormal cytology';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'cases.  We would appreciate any information regarding the following';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'patient.  A copy of any pertinent histopathology report would be';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'extremely helpful.  Federal regulations also require that we review';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'all normal or negative smears done at this facility with the past';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'five years for each patient who presents with a current abnormal Pap';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'smear.  All information given will be treated in a confidential manner,';

	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'and will be used for statistical analysis and in-house continuing';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'education programs.';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||'Doctor Name:     '||RTRIM(S_doctor_text);
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'Patient Name:    '||RTRIM(S_lname)||', '||RTRIM(S_fname);
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 if (S_ssn is not null) then
	    cbuf1:='###-##'||S_ssn;
	    curr_line:=margin||margin||'SS Number:	 '||cbuf1;
	    UTL_FILE.PUTF(letters_file,'%s\n',curr_line);

	 end if;
	 curr_line:=margin||margin||'PCS Lab Number:  '||S_lab_number;
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'Date Received:   '||S_recv_date;
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'Date Completed:  '||S_comp_date;
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||'Result:	      '||S_description;
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 UTL_FILE.PUTF(letters_file,'%s\n\n',dline2);
	 curr_line:=margin||margin||'_____ Previous Smears Taken:';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||' PCS Lab Number	Date		Result';

	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||' ____________	__________	____________________________';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 UTL_FILE.PUTF(letters_file,'%s\n\n',dline2);
	 curr_line:=margin||margin||'_____ Patient has returned to our office for a repeat Pap smear:';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||' PCS Lab Number	Date		Result';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||' ____________	__________	____________________________';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 UTL_FILE.PUTF(letters_file,'%s\n\n',dline2);

	 curr_line:=margin||margin||'_____ Patient has had colposcopy/biopsy/surgical follow-up';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||' Procedure 	     Date	   Diagnosis ';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||' ___________________    _________	   _________________________';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 UTL_FILE.PUTF(letters_file,'%s\n\n',dline2);
	 curr_line:=margin||margin||'_____ Patient has not returned to our office';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 UTL_FILE.PUTF(letters_file,'%s\n\n',dline2);
	 curr_line:=margin||margin||'Thank you for your cooperation';
	 UTL_FILE.PUTF(letters_file,'%s\n\n',curr_line);
	 curr_line:=margin||margin||margin||'			 Pennsylvania Cytology Services';

	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||margin||'			  Suite 1700, Parkway Building';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||margin||'			       339 Haymaker Road';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||margin||'			  Monroeville, PA   15146-2512';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 curr_line:=margin||margin||margin||'				 412.373.8300';
	 UTL_FILE.PUTF(letters_file,'%s\n',curr_line);
	 UTL_FILE.PUT(letters_file,CHR(12));
	 check_point:=6;
   end loop;
   close biopsy_list;


   P_code_area:='END';
   UTL_FILE.PUT(summary_file,CHR(12));
   UTL_FILE.FCLOSE(summary_file);
   UTL_FILE.FCLOSE(letters_file);
   commit;

exception
   when UTL_FILE.INVALID_PATH then
      UTL_FILE.FCLOSE(summary_file);
      UTL_FILE.FCLOSE(letters_file);
      RAISE_APPLICATION_ERROR(-20051,'invalid path');
   when UTL_FILE.INVALID_MODE then

      UTL_FILE.FCLOSE(summary_file);
      UTL_FILE.FCLOSE(letters_file);
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');
   when UTL_FILE.INVALID_FILEHANDLE then
      UTL_FILE.FCLOSE(summary_file);
      UTL_FILE.FCLOSE(letters_file);
      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');
   when UTL_FILE.INVALID_OPERATION then
      UTL_FILE.FCLOSE(summary_file);
      UTL_FILE.FCLOSE(letters_file);
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');
   when UTL_FILE.READ_ERROR then
      UTL_FILE.FCLOSE(summary_file);

      UTL_FILE.FCLOSE(letters_file);
      RAISE_APPLICATION_ERROR(-20055,'read error');
   when UTL_FILE.WRITE_ERROR then
      UTL_FILE.FCLOSE(summary_file);
      UTL_FILE.FCLOSE(letters_file);
      RAISE_APPLICATION_ERROR(-20056,'write error');
   when OTHERS then
      UTL_FILE.FCLOSE(letters_file);
      UTL_FILE.FCLOSE(summary_file);
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_lab_number);

      commit;
      RAISE;

end;
\
