create or replace procedure check_billing_info
(
   M_lab_number in number,
   M_rebilling in number,
   qmode in number,
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
   M_dob varchar2(10);
   M_ssn varchar2(9);
   M_prname varchar2(64);
   M_addr1 varchar2(64);
   M_addr2 varchar2(64);
   M_city varchar2(32);
   M_state char(2);

   M_zip char(5);
   M_fax char(14);
   M_dr_lname varchar2(64);
   M_dr_fname varchar2(32);
   M_doctor_text varchar2(64);
   M_upin varchar2(16);
   M_npi varchar2(16);
   M_license varchar2(16);
   M_bs_provider varchar2(16);
   M_group varchar2(32);
   M_subscriber varchar2(16);
   M_sublname varchar2(32);
   M_subfname varchar2(32);

   M_carrier number;
   M_carrier_name varchar(128);
   pat_addr1 varchar2(64);
   pat_city varchar2(32);
   pat_state char(2);
   pat_zip varchar2(9);
   pat_dob date;
   dir_name varchar2(128);
   M_date char(10);
   M_choice_code varchar2(3);
   C_tpp varchar2(4);
   C_type char(1);
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
   letter_flag number(1);

   L_file_name varchar2(64);

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

begin

   P_proc_name:='CHECK_BILLING_INFO';

   P_code_area:='PREP';
   check_point:=0;
   letter_flag:=0;
   L_file_name:='generic.ltr';

   dir_name:='REPORTS_DIR';

   select LTRIM(RTRIM(TO_CHAR(R.practice,'009'))),TO_CHAR(R.date_collected,'MM/DD/YYYY'),
      P.lname,P.fname,PR.name,PR.address1,PR.address2,PR.city,
      PR.state,SUBSTR(PR.zip,1,5),PR.fax,P.address1,P.city,P.state,P.zip,P.dob,
      B.choice_code,D.lname,D.fname,D.upin,D.license,D.bs_provider,
      SUBSTR(R.doctor_text,1,64),P.dob,P.ssn,D.npi
   into M_practice_id,M_date,M_lname,M_fname,M_prname,M_addr1,M_addr2,M_city,
      M_state,M_zip,M_fax,pat_addr1,pat_city,pat_state,pat_zip,pat_dob,M_choice_code,
      M_dr_lname, M_dr_fname, M_upin, M_license,M_bs_provider,M_doctor_text,M_dob,
      M_ssn,M_npi
   from pcs.lab_requisitions R, pcs.patients P, pcs.practices PR,
      pcs.billing_choices B, pcs.doctors D

   where R.patient=P.patient and R.practice=PR.practice and R.doctor=D.doctor
      and R.billing_choice=B.billing_choice and D.practice=PR.practice
      and R.lab_number=M_lab_number;

   select subscriber,sub_lname,sub_fname,carrier_id
   into M_subscriber,M_sublname,M_subfname,M_carrier from pcs.billing_details
   where rebilling=M_rebilling and lab_number=M_lab_number;
   if (M_subscriber is NOT NULL and M_subscriber<>'SELF' and M_carrier>0) then
      select name into M_carrier_name from pcs.carriers
      where carrier_id=M_carrier;
      if (M_sublname is NULL or M_subfname is NULL) then
	 letter_flag:=1;
      end if;

   else
      M_sublname:='NA';
      M_subfname:='NA';
   end if;

   if (LENGTH(M_fax)=10) then
      M_fax:=SUBSTR(M_fax,1,3)||'.'||SUBSTR(M_fax,4,6)||'.'||SUBSTR(M_fax,7);
   else
      M_fax:=NULL;
   end if;

   check_point:=2;


   if (M_choice_code='BS') then
      P_code_area:='BS';
      if (pat_dob is NULL) then
	 letter_flag:=1;
      end if;
      if (M_bs_provider is NOT NULL) then
	 if (M_dr_lname is NULL or M_dr_fname is NULL) then
	    letter_flag:=1;
	 end if;
      end if;
      select MAX(BD.group_number) into M_group
      from pcs.billing_details BD, pcs.billing_choices BC
      where BD.billing_choice=BC.billing_choice

      and BD.lab_number=M_lab_number
      and BC.choice_code='BS';
      if (M_group is NULL) then
	 letter_flag:=1;
      end if;
   end if;
   if (pat_addr1 is NULL or pat_city is NULL or pat_state is NULL or pat_zip is NULL) then
      letter_flag:=1;
   end if;
   if (M_choice_code in ('MED','OI','DPA')) then
      P_code_area:='MED OI DPA';
      if (M_dr_lname is NULL or M_dr_fname is NULL) then
	 letter_flag:=1;

      end if;
      if (M_choice_code='MED' and (M_npi is NULL or pat_dob is NULL)) then
	 letter_flag:=1;
      end if;
      if (M_choice_code='DPA' and M_npi is NULL) then
	 letter_flag:=1;
      end if;
   end if;

   if (letter_flag=1) then

      P_code_area:='HEADING';
      file_handle:=UTL_FILE.FOPEN(dir_name,L_file_name,'a');


      select count(*) into rcnt from pcs.fax_letters
      where (letter_type='GENERIC' and (in_queue=1 or in_queue=-1))
      or (letter_type='BLANK' and in_queue=-1);

      if (rcnt>0) then
	 curr_line:=chr(12);
	 UTL_FILE.PUTF(file_handle,'%s',curr_line);
      end if;

      insert into pcs.fax_letters (lab_number,letter_type,in_queue,date_sent,origin)
      values (M_lab_number,'GENERIC',qmode,SysDate,M_origin);
      commit;


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
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

      curr_line:=margin||M_prname||'  (ACCT#'||M_practice_id||')';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||M_addr1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      if (M_addr2 is not null) then
	 curr_line:=margin||M_addr2;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      end if;
      curr_line:=margin||M_city||', '||M_state||'  '||M_zip;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      if (M_fax is NOT NULL) then
	 curr_line:=margin||'FAX: '||M_fax;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      end if;
      UTL_FILE.NEW_LINE(file_handle);

      P_code_area:='DETAILS';

      curr_line:=margin||'	 RE: INFORMATION NEEDED';
      UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);

      curr_line:=margin||'Laboratory #'||LTRIM(TO_CHAR(M_lab_number));
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

      curr_line:=margin||'Patient:	       '||M_lname||', '||M_fname;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||'Date of Service:     '||M_date;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      if (M_dob is NOT NULL) then
	 curr_line:=margin||'Date of Birth:    '||M_dob;
      end if;
      if (M_ssn is NOT NULL) then
	 curr_line:=margin||'SSN:	       '||M_ssn;
      end if;
      if (M_dr_lname is NOT NULL and M_dr_fname is NOT NULL) then
	 curr_line:=margin||'Referring Physician: '||M_doctor_text;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

      else
	 UTL_FILE.NEW_LINE(file_handle);
      end if;

      curr_line:=margin||'Dear '||M_prname||':';
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);

      curr_line:=margin||'We are processing a Pap smear on your patient and are missing';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||'the following information.';
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

      if (M_subfname is NULL or M_sublname is NULL) then

	 curr_line:=margin||'COVERAGE: '||M_carrier_name;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 if (M_subfname is NULL) then
	    curr_line:=margin||'Subscriber First Name: _____________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    update pcs.fax_letters set missing_fields=missing_fields||'BILLING_DETAILS.SUB_FNAME '
	    where lab_number=M_lab_number and letter_type='GENERIC';
	 else
	    curr_line:=margin||'Subscriber First Name: '||M_subfname;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 end if;
	 if (M_sublname is NULL) then
	    curr_line:=margin||'Subscriber Last Name: ______________________________';

	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    update pcs.fax_letters set missing_fields=missing_fields||'BILLING_DETAILS.SUB_LNAME '
	    where lab_number=M_lab_number and letter_type='GENERIC';
	 else
	    curr_line:=margin||'Subscriber Last Name: '||M_sublname;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 end if;
      end if;

      if (M_choice_code in ('MED','OI','DPA')) then
	 if (M_dr_lname is NULL or M_dr_fname is NULL) then
	    curr_line:=margin||'Dr Last Name:  _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

	    curr_line:=margin||'Dr First Name: _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    if (M_dr_fname is NULL) then
	       update pcs.fax_letters set missing_fields=missing_fields||'DOCTORS.FNAME '
	       where lab_number=M_lab_number and letter_type='GENERIC';
	    end if;
	    if (M_dr_lname is NULL) then
	       update pcs.fax_letters set missing_fields=missing_fields||'DOCTORS.LNAME '
	       where lab_number=M_lab_number and letter_type='GENERIC';
	    end if;
	 end if;
	 if (M_choice_code='MED') then
	    if (M_npi is NULL) then

	       curr_line:=margin||'DR FULL NAME: _____________________________________';
	       UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	       curr_line:=margin||'DR NPI#:	 _____________________________________';
	       UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	       update pcs.fax_letters set missing_fields=missing_fields||'DOCTORS.NPI '
	       where lab_number=M_lab_number and letter_type='GENERIC';
	    end if;
	    if (pat_dob is NULL) then
	       curr_line:=margin||'Date of Birth: _____________________________________';
	       UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	       update pcs.fax_letters set missing_fields=missing_fields||'PATIENTS.DOB '
	       where lab_number=M_lab_number and letter_type='GENERIC';
	    end if;

	 elsif (M_choice_code='DPA' and M_npi is NULL) then
	    curr_line:=margin||'DR NPI#:      _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    update pcs.fax_letters set missing_fields=missing_fields||'DOCTORS.NPI '
	    where lab_number=M_lab_number and letter_type='GENERIC';
	 end if;
      end if;

      if (M_choice_code='BS' and M_group is NULL) then
	 curr_line:=margin||'Group Number:  _____________________________________';
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 update pcs.fax_letters set missing_fields=missing_fields||'BILLING_DETAILS.GROUP_NUMBER '
	 where lab_number=M_lab_number and letter_type='GENERIC';

      end if;
      if (M_choice_code='BS' and pat_dob is NULL) then
	 curr_line:=margin||'Date of Birth: _____________________________________';
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 update pcs.fax_letters set missing_fields=missing_fields||'PATIENTS.DOB '
	 where lab_number=M_lab_number and letter_type='GENERIC';
      end if;
      if (M_choice_code='BS' and M_bs_provider is NOT NULL) then
	 if (M_dr_lname is NULL or M_dr_fname is NULL) then
	    curr_line:=margin||'Dr Last Name:  _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    curr_line:=margin||'Dr First Name: _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

	    if (M_dr_fname is NULL) then
	       update pcs.fax_letters set missing_fields=missing_fields||'DOCTORS.FNAME '
	       where lab_number=M_lab_number and letter_type='GENERIC';
	    end if;
	    if (M_dr_lname is NULL) then
	       update pcs.fax_letters set missing_fields=missing_fields||'DOCTORS.LNAME '
	       where lab_number=M_lab_number and letter_type='GENERIC';
	    end if;
	 end if;
      end if;
      if (pat_addr1 is NULL or pat_city is NULL or pat_state is NULL or pat_zip is NULL) then
	 if (pat_addr1 is NULL) then
	    curr_line:=margin||'Address:       _____________________________________';

	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    update pcs.fax_letters set missing_fields=missing_fields||'PATIENTS.ADDRESS1 '
	    where lab_number=M_lab_number and letter_type='GENERIC';
	 else
	    curr_line:=margin||'Address:       '||pat_addr1;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 end if;
	 if (pat_city is NULL) then
	    curr_line:=margin||'City:	       _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    update pcs.fax_letters set missing_fields=missing_fields||'PATIENTS.CITY '
	    where lab_number=M_lab_number and letter_type='GENERIC';
	 else

	    curr_line:=margin||'City:	       '||pat_city;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 end if;
	 if (pat_state is NULL) then
	    curr_line:=margin||'State:	       _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    update pcs.fax_letters set missing_fields=missing_fields||'PATIENTS.STATE '
	    where lab_number=M_lab_number and letter_type='GENERIC';
	 else
	    curr_line:=margin||'State:	       '||pat_state;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 end if;
	 if (pat_zip is NULL) then

	    curr_line:=margin||'Zip:	       _____________________________________';
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	    update pcs.fax_letters set missing_fields=missing_fields||'PATIENTS.ZIP '
	    where lab_number=M_lab_number and letter_type='GENERIC';
	 else
	    curr_line:=margin||'Zip:	       '||pat_zip;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 end if;
      end if;

      curr_line:=margin||'Please provide this information on this form and fax it back to us';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||'at 412.373.7027 as soon as possible.	Many thanks.';

      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

      curr_line:=margin||'Pennsylvania Cytology Services';
      UTL_FILE.PUTF(file_handle,'%s\n\n\n\n',curr_line);

      curr_line:=margin||'As per ___________________________________ Date _____________';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||'	 (Please sign to verify our records)';
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

   end if;

-- exception
--    when UTL_FILE.INVALID_PATH then
--       UTL_FILE.FCLOSE(file_handle);

--       RAISE_APPLICATION_ERROR(-20051,'invalid path');
--    when UTL_FILE.INVALID_MODE then
--       UTL_FILE.FCLOSE(file_handle);
--       RAISE_APPLICATION_ERROR(-20052,'invalid mode');
--    when UTL_FILE.INVALID_FILEHANDLE then
--       UTL_FILE.FCLOSE(file_handle);
--       RAISE_APPLICATION_ERROR(-20053,'invalid file handle');
--    when UTL_FILE.INVALID_OPERATION then
--       UTL_FILE.FCLOSE(file_handle);
--       RAISE_APPLICATION_ERROR(-20054,'invalid operation');
--    when UTL_FILE.READ_ERROR then
--       UTL_FILE.FCLOSE(file_handle);
--       RAISE_APPLICATION_ERROR(-20055,'read error');

--    when UTL_FILE.WRITE_ERROR then
--       UTL_FILE.FCLOSE(file_handle);
--       RAISE_APPLICATION_ERROR(-20056,'write error');
--    when OTHERS then
--       UTL_FILE.FCLOSE(file_handle);
--       P_error_code:=SQLCODE;
--       P_error_message:=SQLERRM;
--       insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
--       values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,M_lab_number);
--       commit;
--       RAISE;

end;
\

grant execute on check_billing_info to pcs_user
\
