drop procedure build_hm_worksheets
/

create or replace function build_hm_worksheets
(
   P_mode in number,
   file_name in varchar2,
   server_dir in varchar2
)
return clob
is

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);
 	reportOutput clob;
 	
   PROCESSING constant number := 999;

   cursor m_list is
      select * from pcs.history_match_queue where printed=PROCESSING
      order by lab_number,lab_match desc
   for update;
   m_fields m_list%ROWTYPE;

   dir_name varchar2(32);
   date_today char(8);
   curr_lab number(11);
   M_date char(5);
   M_tech varchar2(4);
   M_pap_class varchar2(4000);
   pclass_num number;

   curr_line varchar2(100);
   cbuf varchar2(64);
   cbuf2 varchar2(32);
   cbuf3 varchar2(32);
   P_lname varchar2(32);
   P_fname varchar2(32);
   P_ssn varchar2(9);
   P_dob varchar2(8);
   P_practice number;
   P_name varchar2(64);
   file_handle UTL_FILE.FILE_TYPE;
   line_num number(3);
   page_size number(3);

   blank_lines number(3);
   hpv_result char(1);

   test_lab char(20);
   check_point number;
   rcnt number;

begin

   commit;
   P_proc_name:='BUILD_HM_WORKSHEETS';

   P_code_area:='PROCESSING';

   set transaction use rollback segment pcs_rbs5;
   lock table pcs.history_match_queue in row exclusive mode;
   update pcs.history_match_queue set printed=PROCESSING where printed=P_mode;
   commit;

   P_code_area:='PREP';
   select TO_CHAR(SysDate,'YYYYMMDD') into date_today from dual;
   dir_name:=server_dir;
   file_handle:=UTL_FILE.FOPEN(dir_name,file_name,'w');
   page_size:=23;

   delete from pcs.history_match_queue where lab_match not in
      (select lab_number from pcs.lab_results);


   P_code_area:='MATCH';
   curr_lab:=0;
   check_point:=0;
   open m_list;
   dbms_lob.createtemporary(reportOutput, true);
   loop
      fetch m_list into m_fields;
      exit when m_list%NOTFOUND;

      -- clear all variables
      P_lname:=NULL;
      P_fname:=NULL;
      P_dob:=NULL;

      P_ssn:=NULL;
      P_practice:=NULL;
      P_name:=NULL;
      M_date:=NULL;
      M_tech:=NULL;
      M_pap_class:=NULL;
      pclass_num:=NULL;
      hpv_result:=NULL;
      test_lab:=TO_CHAR(m_fields.lab_match);
      if (curr_lab<>m_fields.lab_number) then
	 if (curr_lab<>0) then
	    blank_lines:=page_size-line_num;
	    if (blank_lines>0) then
	       UTL_FILE.NEW_LINE(file_handle,blank_lines);
	    end if;
	 end if;
	 P_code_area:='MATCH Q1';
	 select lname,fname,TO_CHAR(dob,'YYYYMMDD'),ssn
	 into P_lname,P_fname,P_dob,P_ssn
	 from pcs.patients p, pcs.lab_requisitions l
	 where l.patient=p.patient and l.lab_number=m_fields.lab_number;
	 P_code_area:='MATCH Q2';
	 select p.practice,p.name into P_practice,P_name
	 from pcs.practices p, pcs.lab_requisitions l
	 where l.practice=p.practice and l.lab_number=m_fields.lab_number;
	 cbuf:=TO_CHAR(m_fields.lab_number,'9999999999');

	 curr_line:='LAB NUMBER: '||cbuf;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 dbms_lob.writeAppend(reportOutput, length(curr_line||'\n'), curr_line||'\n');
	 cbuf:=RTRIM(P_lname)||', '||RTRIM(P_fname);
	 cbuf3:=NULL;
	 if (P_dob is NOT NULL or P_ssn is NOT NULL) then
	    if (P_dob is NOT NULL) then
	       if (P_ssn is NOT NULL) then
		  cbuf2:=P_dob||'.'||P_ssn;
	       else
		  cbuf2:=P_dob;
	       end if;
	    else
	       if (P_ssn is NOT NULL) then

		  cbuf2:=P_ssn;
	       end if;
	    end if;
	 end if;
	 if (cbuf2 is NOT NULL) then
	    cbuf3:='  ['||cbuf2||']';
	 end if;
	 curr_line:='PATIENT:	  '||cbuf||cbuf3;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 dbms_lob.writeAppend(reportOutput, length(curr_line||'\n'), curr_line||'\n');
	 cbuf:=TO_CHAR(P_practice,'099');
	 cbuf:=cbuf||' '||RTRIM(P_name);
	 curr_line:='ACCOUNT:	 '||cbuf;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	dbms_lob.writeAppend(reportOutput, length(curr_line||'\n\n'), curr_line||'\n\n');
	 curr_line:='PRIOR PA CYTOLOGY RESULTS';
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 dbms_lob.writeAppend(reportOutput, length(curr_line||'\n\n'), curr_line||'\n\n');
	 curr_line:='DATE   LAB NUMBER	TECH	RESULTS';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 dbms_lob.writeAppend(reportOutput, length(curr_line||'\n'), curr_line||'\n');
	 line_num:=8;
      end if;
      P_code_area:='MATCH Q3';
      select count(*) into rcnt
      from pcs.lab_results r, pcs.cytotechs c, pcs.pap_classes pc
      where r.cytotech=c.cytotech and r.pap_class=pc.pap_class
	 and r.lab_number=m_fields.lab_match;
      if (rcnt>0) then
	 select TO_CHAR(r.date_completed,'MM-DD'),

	    c.cytotech_code,SUBSTR(pc.description,1,29),r.pap_class
	 into M_date,M_tech,M_pap_class,pclass_num
	 from pcs.lab_results r, pcs.cytotechs c, pcs.pap_classes pc
	 where r.cytotech=c.cytotech and r.pap_class=pc.pap_class
	    and r.lab_number=m_fields.lab_match;
	 if (6-m_fields.m_level>=1) then
	    curr_line:=M_date||'  '||TO_CHAR(m_fields.lab_match)||'  '||
	       M_tech||'  '||TO_CHAR(6-m_fields.m_level)||'  '||M_pap_class;
	    rcnt:=0;
	    select count(*) into rcnt from pcs.hpv_requests
	    where lab_number=m_fields.lab_match;
	    if (rcnt>0) then
	       select test_results into hpv_result

	       from pcs.hpv_requests
	       where lab_number=m_fields.lab_match;
	       if (hpv_result is NOT NULL) then
		  curr_line:=curr_line||'  [HPV '||hpv_result||' ]';
	       end if;
	    end if;
	    -- pap class 17 is tissue biopsy 
	    if (pclass_num=17) then
	       curr_line:=curr_line||'	[PLEASE PRINT REPORT]';
	    end if;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    dbms_lob.writeAppend(reportOutput, length(curr_line||'\n'), curr_line||'\n');
	    line_num:=line_num+1;
	 end if;

      end if;
      delete from pcs.history_match_queue where current of m_list;
      curr_lab:=m_fields.lab_number;
   end loop;
   close m_list;
	return reportOutput;
   -- *****************
   update pcs.job_control set job_status=0 where job_descr='MATCH_COUNT';
   UTL_FILE.PUT(file_handle,CHR(12));
   dbms_lob.writeAppend(reportOutput, length(CHR(12)), CHR(12));
   UTL_FILE.FCLOSE(file_handle);
   dbms_lob.close(reportOutput);
   return reportOutput;
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,m_fields.lab_number);
      commit;
end;
/