create or replace procedure     build_claim_wks_file
(
   C_directory in char,
   C_file in char,
   C_billing_route in char
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);


   cursor claim_list is
      select
	 c.carrier_id,
	 RPAD(SUBSTR(c.name,1,38),40),
	 c.address1,
	 c.address2,
	 c.city,
	 c.state,
	 c.zip,
	 c.payer_id,
	 bd.id_number,
	 bd.group_number,
	 bd.subscriber,

	 bd.sub_lname,
	 bd.sub_fname,
	 TO_CHAR(bd.sign_date,'MMDDYYYY'),
	 p.lname,
	 p.fname,
	 p.mi,
	 p.address1,
	 p.city,
	 p.state,
	 p.zip,
	 p.phone,
	 p.patient,
	 TO_CHAR(p.dob,'MMDDYYYY'),

	 pr.name,
	 lb.bill_amount,
	 TO_CHAR(lr.date_collected,'MMDDYYYY'),
	 bq.lab_number,
	 bq.rebilling,
	 pr.state,
	 NVL(lb.balance,lb.bill_amount),
	 lb.bill_amount-(NVL(lb.allowance,lb.bill_amount)),
	 TO_CHAR(lr.date_collected,'MM DD YY')
      from
	 pcs.carriers c, pcs.billing_details bd, pcs.patients p,
	 pcs.practices pr, pcs.lab_billings lb, pcs.billing_queue bq,
	 pcs.lab_requisitions lr, pcs.lab_results r

      where
	 bq.lab_number=lr.lab_number and
	 lr.lab_number=r.lab_number and
	 lr.lab_number=bd.lab_number and
	 lr.patient=p.patient and
	 lr.practice=pr.practice and
	 bd.carrier_id=c.carrier_id and
	 bd.lab_number=lb.lab_number and
	 bq.rebilling=bd.rebilling and
	 bq.billing_route=C_billing_route
      order by c.billing_choice,bq.datestamp;

   carrier_idnum number;

   carrier_name varchar2(128);
   carrier_addr1 varchar2(64);
   carrier_addr2 varchar2(64);
   carrier_city varchar2(32);
   carrier_state char(2);
   carrier_zip varchar2(9);
   carrier_pid varchar2(32);
   policy_id varchar2(32);
   policy_group varchar2(32);
   policy_lname varchar2(32);
   policy_fname varchar2(32);
   policy_subscriber varchar2(16);
   policy_sign char(8);

   patient_lname varchar2(32);
   patient_fname varchar2(32);
   patient_mi char(1);
   patient_addr varchar2(64);
   patient_city varchar2(32);
   patient_state char(2);
   patient_zip varchar2(9);
   patient_phone char(10);
   patient_id number;
   patient_dob char(8);
   practice_name varchar2(64);
   lab_completed char(8);
   lab_collected char(8);

   claim_total number(5,2);
   claim_lab_number number;
   lab_rebilling number;
   practice_state char(2);
   lab_balance number;
   total_loss number;
   lab_claim_id number;
   total_payments number;

   dr_lname varchar2(64);
   dr_fname varchar2(32);
   dr_mi char(1);
   dr_upin varchar(16);

   dr_number number;
   dr_license varchar2(16);
   dr_alt_license varchar2(16);
   dr_alt_state char(2);

   diag_1 varchar2(16);
   diag_2 varchar2(16);
   diag_3 varchar2(16);
   diag_4 varchar2(16);
   diag_string varchar2(16);
   lab_CLIA varchar2(16);
   lab_tax_id varchar2(12);
   lab_pin_num varchar2(11);


   cursor diagnosis_list is
      select * from pcs.lab_req_diagnosis
      where lab_number=claim_lab_number and rebilling=lab_rebilling
      order by d_seq;
   diagnosis_fields diagnosis_list%ROWTYPE;

   cursor procedure_list is
      select bi.lab_number,bi.price_code,bi.procedure_code,bi.item_amount,bi.rebilling,p.p_seq
      from pcs.lab_billing_items bi, pcs.procedure_codes p
      where bi.lab_number=claim_lab_number and bi.procedure_code=p.procedure_code
      order by p.p_seq;
   procedure_fields procedure_list%ROWTYPE;


   curr_line varchar2(128);
   cbuf1 varchar2(128);
   cbuf2 varchar2(128);
   cbuf3 varchar2(128);
   margin varchar2(10);
   rcnt number;
   curr_item number(5,2);
   claim_batch_number number;
   claim_ebill char(1);
   C_tpp varchar2(5);
   C_claims number;
   C_choice_code varchar2(3);

   check_point number;
   num_diags number(1);
   last_carrier number;
   max_rebilling number;
   resubmitted number;
   C_status varchar2(2);
   tmp_num number;
   C_text varchar2(100);
   line_count number;
   max_lines number;

   file_handle UTL_FILE.FILE_TYPE;


begin
	dbms_output.put_line('Staring to build worksheets for '||C_billing_route);
   P_proc_name:='BUILD_CLAIM_WKS_FILE';

   P_code_area:='PREP';
   check_point:=0;
   num_diags:=0;
   last_carrier:=0;

   select count(*) into C_claims from pcs.billing_queue where billing_route=C_billing_route;
   margin:='  ';
   claim_ebill:='N';
   C_tpp:=C_billing_route;
	dbms_output.put_line('Billing Queue '||C_billing_route||' has '||to_char(C_claims)||' enqueued');

   P_code_area:='BATCH';

   select id_number into lab_CLIA from pcs.business_id_nums where id_code='CLIA';
   select id_number into lab_tax_id from pcs.business_id_nums where id_code='TAXID';

   file_handle:=UTL_FILE.FOPEN(C_directory,C_file,'w');
   max_lines:=21;

   P_code_area:='CLAIMS';
   open claim_list;
   loop
      fetch claim_list into

	 carrier_idnum,
	 carrier_name,
	 carrier_addr1,
	 carrier_addr2,
	 carrier_city,
	 carrier_state,
	 carrier_zip,
	 carrier_pid,
	 policy_id,
	 policy_group,
	 policy_subscriber,
	 policy_lname,
	 policy_fname,

	 policy_sign,
	 patient_lname,
	 patient_fname,
	 patient_mi,
	 patient_addr,
	 patient_city,
	 patient_state,
	 patient_zip,
	 patient_phone,
	 patient_id,
	 patient_dob,
	 practice_name,
	 claim_total,

	 lab_completed,
	 claim_lab_number,
	 lab_rebilling,
	 practice_state,
	 lab_balance,
	 total_loss,
	 lab_collected;
      exit when claim_list%NOTFOUND;

      P_code_area:='HEADER';
      UTL_FILE.NEW_LINE(file_handle);
      line_count:=1;
      curr_line:=carrier_name||'***WKSHEET ONLY-DO NOT SEND***';

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;

      P_code_area:='COMMENTS 0 '||claim_lab_number;
      select MAX(claim_id) into tmp_num from pcs.lab_claims
      where lab_number=claim_lab_number;
      C_text:=NULL;
      P_code_area:='COMMENTS 1 '||claim_lab_number;
      select SUBSTR(claim_comment,1,70) into C_text from pcs.lab_claims
      where claim_id=tmp_num;
      curr_line:=C_text;
      if (C_text is NOT NULL) then
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

	 line_count:=line_count+1;
	 C_text:=NULL;
	 P_code_area:='COMMENTS 2 '||claim_lab_number;
	 select SUBSTR(claim_comment,71,70) into C_text from pcs.lab_claims
	 where claim_id=tmp_num;
	 if (C_text is NOT NULL) then
	    curr_line:=C_text;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    line_count:=line_count+1;
	    C_text:=NULL;
	    select SUBSTR(claim_comment,141,70) into C_text from pcs.lab_claims
	    where claim_id=tmp_num;
	    if (C_text is NOT NULL) then

	       curr_line:=C_text;
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       line_count:=line_count+1;
	    else
	       UTL_FILE.NEW_LINE(file_handle);
	       line_count:=line_count+1;
	    end if;
	 else
	    UTL_FILE.NEW_LINE(file_handle);
	    line_count:=line_count+1;
	 end if;
      else
	 UTL_FILE.NEW_LINE(file_handle);

	 line_count:=line_count+1;
      end if;

      select A.choice_code into C_choice_code
      from pcs.billing_choices A, pcs.carriers B
      where A.billing_choice=B.billing_choice and B.carrier_id=carrier_idnum;

      P_code_area:='PAYMENTS';
      select NVL(SUM(payment_amount),0) into total_payments from pcs.payments P
      where P.payment_type<>'PLUS ADJUST' and P.lab_number=claim_lab_number;
      select NVL(SUM(payment_amount),0) into tmp_num from pcs.payments P
      where P.payment_type='PLUS ADJUST' and P.lab_number=claim_lab_number;
      total_payments:=total_payments-tmp_num;


      UTL_FILE.NEW_LINE(file_handle);
      line_count:=line_count+1;

      P_code_area:='LINE 5';
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      cbuf1:=rtrim(patient_lname)||', '||rtrim(patient_fname)||' '||patient_mi;
      curr_line:=RPAD('PATIENT: ',20)||cbuf1||' [DOB '||patient_dob||']';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;


      P_code_area:='LINE 3';
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=RPAD('INSURANCE ID: ',20);
      curr_line:=curr_line||policy_id;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;

      cbuf1:=null;
      cbuf2:=null;
      curr_line:=RPAD('GROUP NUMBER: ',20);
      curr_line:=curr_line||policy_group;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      line_count:=line_count+1;

      cbuf1:=null;
      cbuf2:=null;
      curr_line:=RPAD('SUBSCRIBER: ',20);
      if (policy_subscriber='SELF') then
	 curr_line:=curr_line||'[SELF]';
      elsif (policy_subscriber is not NULL) then
	 curr_line:=curr_line||policy_lname||', '||policy_fname||'  ['||policy_subscriber||']';
      end if;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;


      P_code_area:='LINE 29';
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      select doctor,doctor_text into dr_number,cbuf3 from pcs.lab_requisitions
      where lab_number=claim_lab_number;
      select lname,fname,mi,upin,license,alt_license,alt_state
      into dr_lname,dr_fname,dr_mi,dr_upin,dr_license,dr_alt_license,dr_alt_state
      from pcs.doctors where doctor=dr_number;
      cbuf1:=rtrim(dr_fname);
      if (dr_mi is not null) then
	 cbuf1:=cbuf1||' '||dr_mi;
      end if;

      cbuf1:=cbuf1||' '||rtrim(dr_lname);
      if (cbuf3 is NOT NULL) then
	 cbuf1:=cbuf3;
      end if;
      if (dr_upin is null) then
	 if (C_billing_route='ENV') then
	    cbuf2:='OTH00000';
	 else
	    cbuf2:='	    ';
	 end if;
      elsif (C_choice_code='BS') then
	 cbuf2:='	 ';
      else

	 cbuf2:=dr_upin;
      end if;
      if (C_choice_code='DPA') then
	 cbuf2:=dr_license;
	 if (dr_alt_state is NOT NULL and carrier_state=dr_alt_state) then
	    cbuf2:=dr_alt_license;
	 end if;
      end if;
      cbuf1:=RPAD(cbuf1,27);
      cbuf1:=cbuf1||cbuf2;
      curr_line:=RPAD('DOCTOR: ',20)||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;

      UTL_FILE.NEW_LINE(file_handle);
      line_count:=line_count+1;

      diag_1:=null;
      diag_2:=null;
      diag_3:=null;
      diag_4:=null;
      open diagnosis_list;
      loop
	 fetch diagnosis_list into diagnosis_fields;
	 exit when diagnosis_list%NOTFOUND;
	 if (diagnosis_fields.d_seq=1) then
	    diag_1:=diagnosis_fields.diagnosis_code;

	 elsif (diagnosis_fields.d_seq=2) then
	    diag_2:=diagnosis_fields.diagnosis_code;
	 elsif (diagnosis_fields.d_seq=3) then
	    diag_3:=diagnosis_fields.diagnosis_code;
	 elsif (diagnosis_fields.d_seq=4) then
	    diag_4:=diagnosis_fields.diagnosis_code;
	 end if;
      end loop;
      close diagnosis_list;

      P_code_area:='LINE 33';
      cbuf1:=null;
      cbuf2:=null;

      curr_line:=null;
      if (diag_1 is not null) then
	 cbuf1:=diag_1;
      end if;
      if (diag_3 is not null) then
	 cbuf1:=RPAD(cbuf1,30);
	 cbuf1:=cbuf1||diag_3;
      end if;
      curr_line:=cbuf1;

      P_code_area:='LINE 35';
      cbuf1:=null;
      cbuf2:=null;

      if (diag_2 is not null) then
	 cbuf1:=diag_2;
      end if;
      if (diag_4 is not null) then
	 cbuf1:=RPAD(cbuf1,30);
	 cbuf1:=cbuf1||diag_4;
      end if;
      if (cbuf1 is null) then
	 cbuf1:=RPAD(' ',49);
      else
	 cbuf1:=RPAD(cbuf1,49);
      end if;
      curr_line:=curr_line||'  '||cbuf1;

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;

      P_code_area:='LINE 39';
      diag_string:=null;
      if (diag_1 is not null) then
	 diag_string:='1';
      end if;
      if (diag_2 is not null) then
	 diag_string:=diag_string||',2';
      end if;
      if (diag_3 is not null) then
	 diag_string:=diag_string||',3';

      end if;
      if (diag_4 is not null) then
	 diag_string:=diag_string||',4';
      end if;
      if (diag_string is null) then
	 diag_string:=' ';
      end if;
      rcnt:=0;
      open procedure_list;
      loop
	 fetch procedure_list into procedure_fields;
	 exit when procedure_list%NOTFOUND;
	 rcnt:=rcnt+1;

	 cbuf1:=null;
	 cbuf2:=null;
	 curr_line:=null;
	 cbuf1:=lab_completed||' '||lab_completed;
	 /*
	    HARDCODED VALUE:  Best Health Care must have a
	    different TOS code than 5; carriers.carrier_id is 4009
	 */
	 if (carrier_idnum=4009) then
	    cbuf1:=RPAD(cbuf1,18)||'81 86';
	 else
	    cbuf1:=RPAD(cbuf1,18)||'81 5 ';
	 end if;

	 cbuf1:=RPAD(cbuf1,24)||procedure_fields.procedure_code;
	 if (C_choice_code='MED' and policy_sign is NOT NULL) then
	    cbuf1:=cbuf1||'  GA';
	 end if;
	 cbuf1:=RPAD(cbuf1,41)||RPAD(diag_string,7);
	 cbuf1:=RPAD(cbuf1,49);
	 curr_item:=procedure_fields.item_amount;
	 curr_line:=TO_CHAR(curr_item,'99999.99');
	 cbuf2:=substr(curr_line,1,6);
	 cbuf2:=LTRIM(cbuf2);
	 cbuf2:=RTRIM(cbuf2);
	 cbuf2:=LPAD(cbuf2,5);
	 cbuf1:=cbuf1||cbuf2||' ';

	 cbuf2:=substr(curr_line,8,2);
	 cbuf1:=cbuf1||cbuf2;
	 if (C_choice_code='DPA' and carrier_state='WV') then
	    cbuf1:=RPAD(cbuf1,58)||'1';
	 elsif (C_billing_route='ENV') then
	    cbuf1:=RPAD(cbuf1,58)||'1';
	 else
	    cbuf1:=RPAD(cbuf1,58)||' ';
	 end if;
	 if (C_choice_code='MED') then
	    cbuf1:=RPAD(cbuf1,69)||lab_pin_num;
	 end if;
	 curr_line:=cbuf1;

	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 line_count:=line_count+1;
      end loop;
      close procedure_list;
      for ndx in (rcnt+1)..4 loop
	 cbuf1:=null;
	 cbuf2:=null;
	 curr_line:=null;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 line_count:=line_count+1;
      end loop;

      cbuf1:=TO_CHAR(claim_lab_number);

      curr_line:='LAB NUMBER: '||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;

      cbuf1:=TO_CHAR(SysDate,'MM/DD/YYYY HH:Mi');
      curr_line:='PRINTED ON: '||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_count:=line_count+1;

      for ndx in (line_count)..max_lines loop
	 UTL_FILE.NEW_LINE(file_handle);
      end loop;


      last_carrier:=carrier_idnum;

   end loop;
   close claim_list;

   delete from pcs.billing_queue where billing_route=C_billing_route;

   /**************/
   UTL_FILE.FCLOSE(file_handle);
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,claim_lab_number);
      commit;
      RAISE;
end;
\

grant execute on build_claim_wks_file to pcs_user
\
