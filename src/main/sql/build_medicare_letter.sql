create or replace procedure   build_medicare_letter
(
   M_lab_number in number,
   M_claim in number,
   second_notice in char,
   M_origin in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);


   M_practice number;
   M_practice_id varchar2(8);
   M_name varchar2(64);
   M_lname varchar2(32);
   M_fname varchar2(32);
   M_prname varchar2(64);
   M_addr1 varchar2(64);
   M_addr2 varchar2(64);
   M_city varchar2(32);
   M_state char(2);
   M_zip char(5);
   M_fax char(14);

   M_patid varchar2(16);
   dir_name varchar2(128);
   M_date char(10);
   curr_line varchar2(300);
   cbuf1 varchar2(128);
   cbuf2 varchar2(128);
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
   L_file_name varchar2(64);

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

begin

   P_proc_name:='BUILD_MEDICARE_LETTER';

   P_code_area:='PREP';

   check_point:=0;
   L_file_name:='medicare.ltr';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,L_file_name,'a');

   select LTRIM(RTRIM(TO_CHAR(R.practice,'009'))),TO_CHAR(R.date_collected,'MM/DD/YYYY'),
      P.lname,P.fname,PR.name,PR.address1,PR.address2,PR.city,
      PR.state,SUBSTR(PR.zip,1,5),PR.fax,R.patient_id
   into M_practice_id,M_date,M_lname,M_fname,M_prname,M_addr1,M_addr2,M_city,
      M_state,M_zip,M_fax,M_patid
   from pcs.lab_requisitions R, pcs.patients P, pcs.practices PR
   where R.patient=P.patient and R.practice=PR.practice and R.lab_number=M_lab_number;


   if (LENGTH(M_fax)=10) then
      M_fax:=SUBSTR(M_fax,1,3)||'.'||SUBSTR(M_fax,4,6)||'.'||SUBSTR(M_fax,7);
   else
      M_fax:=NULL;
   end if;

   if (M_claim>0) then
      update pcs.lab_claims set letter_date=SysDate where claim_id=M_claim;
   end if;

   select count(*) into rcnt from pcs.fax_letters
   where (letter_type='NMN' and (in_queue=1 or in_queue=-1));


   P_code_area:='HEADING';
   margin:='   ';
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||'Suite 1700 Parkway Building';
   heading3:=margin||'339 Old Haymaker Road';
   heading4:=margin||'Monroeville, PA  15146';

   UTL_FILE.PUTF(file_handle,'\n\n%s\n',heading1);
   UTL_FILE.PUTF(file_handle,'%s\n',heading2);
   UTL_FILE.PUTF(file_handle,'%s\n',heading3);
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',heading4);

   select TO_CHAR(SysDate,'MM/DD/YYYY') into cbuf from dual;

   curr_line:=margin||'Date:  '||cbuf;
   if (second_notice='Y') then
      curr_line:=RPAD(curr_line,50)||'*** SECOND NOTICE ***';
   end if;
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   curr_line:=margin||M_practice_id||' - '||M_prname;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||M_addr1;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   if (M_addr2 is not null) then
      curr_line:=margin||M_addr2;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   end if;
   curr_line:=margin||M_city||', '||M_state||'	'||M_zip;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   if (M_fax<>'..') then
      curr_line:=margin||'FAX: '||M_fax;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end if;
   UTL_FILE.NEW_LINE(file_handle);

   curr_line:=margin||'       RE: MEDICARE PAP SMEAR DENIED AS "NOT MEDICALLY NECESSARY"';
   UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);

   P_code_area:='BODY';

   curr_line:=margin||'Laboratory #'||LTRIM(TO_CHAR(M_lab_number));
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   curr_line:=margin||'Patient: 	 '||M_lname||', '||M_fname;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'Date of Service:  '||M_date;
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   if (M_patid is NOT NULL) then
      curr_line:=margin||'Patient ID:	    '||M_patid;
   end if;

   curr_line:=margin||'Dear '||M_prname||':';
   UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);


   curr_line:=margin||'Our laboratory has been notified by Medicare that according to Medicare regulations,';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'Pap smears performed with a diagnosis which they consider "not medically necessary"';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'"will not be covered under the Medicare program.  In order to comply with Medicare';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'regulations, we will need documentation of medical necessity from the ordering ';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'physician for this Pap smear rejected as "not medically necessary.  Please indicate';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'any information to support support the medical necessity for the Pap smear so that we may review this';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'claim for payment so that your patient will not be billed.';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   curr_line:=margin||'Your prompt attention is appreciated. ';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   curr_line:=margin||'Thank you.';
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);

   curr_line:=margin||'Please indicate additional information to support the medical necessity';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'for the Pap smear in the spaces provided.  Include ICD-9 Codes (attach';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   curr_line:=margin||'additional sheets if necessary).';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   curr_line:=margin||'PLEASE CHECK ONE:       |__| SCREENING	    |__| DIAGNOSTIC';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   dline:=margin||'__________________________________________________________________________';
   UTL_FILE.PUTF(file_handle,'%s\n\n',dline);
   UTL_FILE.PUTF(file_handle,'%s\n\n',dline);
   UTL_FILE.PUTF(file_handle,'%s\n\n',dline);
   UTL_FILE.PUTF(file_handle,'%s\n\n',dline);

   curr_line:=margin||' 				   ______________________________________';

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||' 					 Doctor''s signature and date';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   curr_line:=margin||' 				   ______________________________________';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||' 					 Doctor''s full printed name';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   if (M_origin=1) then
      curr_line:=margin||'REQUISITION';
   elsif (M_origin=2) then
      curr_line:=margin||'BILLING';
   else
      curr_line:=' ';

   end if;
   UTL_FILE.PUTF(file_handle,'%s',curr_line);
   UTL_FILE.PUT(file_handle,CHR(12));

   UTL_FILE.FCLOSE(file_handle);

   if (M_claim>0) then
      rcnt:=1;
   else
      rcnt:=-1;
   end if;
   insert into pcs.fax_letters (lab_number,letter_type,in_queue,date_sent,origin)
   values (M_lab_number,'NMN',rcnt,SysDate,M_origin);


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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,M_lab_number);
      commit;
      RAISE;

end;
\

grant execute on build_medicare_letter to pcs_user 
\