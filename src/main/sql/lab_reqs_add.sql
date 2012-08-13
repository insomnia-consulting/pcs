create or replace procedure lab_reqs_add
(
   L_lab_number in number,
   L_patient in number,
   L_practice in number,
   L_doctor in number,
   L_patient_id in varchar2,
   L_diagnosis_code in varchar2,
   L_diagnosis_code2 in varchar2,
   L_diagnosis_code3 in varchar2,
   L_diagnosis_code4 in varchar2,
   L_slide_qty in number,
   L_date_collected in varchar2,

   L_lmp in varchar2,
   L_rush in char,
   L_billing_choice in number,
   L_carrier_id in number,
   L_id_number in varchar2,
   L_group_number in varchar2,
   L_subscriber in varchar2,
   L_sub_lname in varchar2,
   L_sub_fname in varchar2,
   L_sign_date in varchar2,
   L_medicare_code in char,
   L_client_notes in varchar2,
   L_comment_text in varchar2,

   L_age in number,
   L_prep in number,
   L_prev_lab in number,
   L_check_number in number,
   L_payment_amount in number,
   L_payment_info in varchar2,
   L_doctor_text in varchar2,
   L_date_received in varchar2,
   L_hpv_request in varchar2,
   L_ADPH_program in varchar2
)
as


   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   D_date_collected date;
   D_sign_date date;
   L_receive_date date;
   L_start_lab number(11);
   L_choice_code varchar2(3);
   L_medicare_type char(1);
   L_finished number;
   rcnt number;

   dr_id number;
   dr_lname varchar2(64);
   dr_fname varchar2(32);
   dr_license varchar2(16);
   dr_upin varchar2(16);
   dr_bs_provider varchar2(16);
   dr_status char(1);
   dr_alt_license varchar2(16);
   dr_alt_state char(2);
   practice_state char(2);
   payer_state char(2);
   id_num varchar2(32);
   L_msg varchar2(128);

   L_pay_type varchar2(16);
   L_check number;
   L_pay_id number;

begin

      P_proc_name:='LAB_REQS_ADD';

      P_code_area:='PREP';
      if (L_prep=0) then
	 L_finished:=-1;
      else
	 L_finished:=0;

      end if;
      L_medicare_type:=L_medicare_code;
      if (L_date_received is NOT NULL) then
	 L_receive_date:=TO_DATE(L_date_received,'MMDDYYYY');
      else
	 L_receive_date:=pcs.get_receive_date(L_lab_number);
	 if (TO_CHAR(L_receive_date,'MMDDYYYY')='01011900') then
	    L_receive_date:=NULL;
	 end if;
      end if;
      commit;
      if (L_billing_choice=122) then
	 id_num:=TO_CHAR(L_practice,'009');

      else
	 id_num:=L_id_number;
      end if;
      D_date_collected:=TO_DATE(L_date_collected,'MMDDYYYY');
      select choice_code into L_choice_code from pcs.billing_choices
      where billing_choice=L_billing_choice;
      commit;
      if (L_sign_date is not null)
      then
	 D_sign_date:=TO_DATE(L_sign_date,'MMDDYYYY');
      end if;
      P_code_area:='COMMENT';
      if (L_comment_text is not null)

      then
	 insert into pcs.lab_req_comments (lab_number,comment_text)
	 values (L_lab_number,L_comment_text);
	 commit;
      end if;
      P_code_area:='VALIDATE DOCTOR';

--	 Validate doctor; select default if not valid

      dr_id:=pcs.validate_doctor
	 (L_lab_number,L_practice,L_doctor,L_carrier_id,L_choice_code);
       -- If the doctor validation results in the default doctor being selected
       -- 	 to facilitate billing then update the req table; also add comment

      
      if (L_doctor<>dr_id) then
	 update pcs.lab_requisitions set doctor=dr_id where lab_number=L_lab_number;

      end if;
      P_code_area:='INSERT';
      insert into pcs.lab_requisitions
	 (lab_number,req_number,patient,practice,doctor,patient_id,
	  slide_qty,date_collected,lmp,rush,
	  billing_choice,finished,age,preparation,previous_lab,receive_date,doctor_text)


      values
	 (L_lab_number,pcs.req_seq.nextval,L_patient,L_practice,dr_id,
	  L_patient_id,L_slide_qty,D_date_collected,
	  L_lmp,L_rush,L_billing_choice,L_finished,L_age,L_prep,L_prev_lab,
	  L_receive_date,L_doctor_text);
      commit;
      if (L_client_notes is not null)
      then
	 insert into pcs.lab_req_client_notes
	    (lab_number,client_notes)
	 values
	    (L_lab_number,L_client_notes);
	 commit;

      end if;
      if (L_medicare_code='F') then
	 pcs.build_diagnosis_letter(L_lab_number,1,1);
	 L_medicare_type:=NULL;
      end if;
      insert into pcs.billing_details
	 (carrier_id,lab_number,id_number,group_number,subscriber,
	  sub_lname,sub_fname,sign_date,medicare_code,rebilling,
	  billing_choice,datestamp,sys_user,billing_level,
	  change_user,change_date)
      values
	 (L_carrier_id,L_lab_number,id_num,L_group_number,
	  L_subscriber,L_sub_lname,L_sub_fname,D_sign_date,

	  L_medicare_type,0,L_billing_choice,SysDate,UID,'FST',UID,SysDate);
      commit;
      update pcs.patients set last_lab=L_lab_number where patient=L_patient;
      commit;
      if (L_diagnosis_code is not null)
      then
	 P_code_area:='DIAG';
	 insert into pcs.lab_req_diagnosis (lab_number,diagnosis_code,d_seq,rebilling)

	 values (L_lab_number,L_diagnosis_code,1,0);
	 commit;
	 if (L_diagnosis_code2 is not null)

	 then
	    insert into pcs.lab_req_diagnosis (lab_number,diagnosis_code,d_seq,rebilling)

	    values (L_lab_number,L_diagnosis_code2,2,0);
	    commit;
	    if (L_diagnosis_code3 is not null)
	    then
	       insert into pcs.lab_req_diagnosis
		 (lab_number,diagnosis_code,d_seq,rebilling)
	       values (L_lab_number,L_diagnosis_code3,3,0);
	       commit;
	       if (L_diagnosis_code4 is not null)

	       then
		  insert into pcs.lab_req_diagnosis
		    (lab_number,diagnosis_code,d_seq,rebilling)
		  values (L_lab_number,L_diagnosis_code4,4,0);
		  commit;
	       end if;
	    end if;
	 end if;
      end if;
      P_code_area:='HPV REQUEST';
      if (L_hpv_request in ('Y','19','20','R')) then
	 insert into pcs.hpv_requests (lab_number,datestamp,hpv_code)
	 values (L_lab_number,SysDate,L_hpv_request);

      end if;
      if (L_choice_code='PPD') then
	 if (L_check_number IS NULL) then
	    L_check:=(-1);
	 else
	    L_check:=L_check_number;
	 end if;
	 if (L_check>0) then
	    L_pay_type:='CHECK';
	 else
	    L_pay_type:='CASH';
	 end if;
	 select pcs.payments_seq.nextval into L_pay_id from dual;

	 insert into pcs.payments (payment_id,billing_choice,account_id,
	    payment_type,payment_amount, payment_date,date_posted,
	    check_number,sys_user,receive_date,lab_number)
	 values (L_pay_id,L_billing_choice,L_patient,L_pay_type,L_payment_amount,SysDate,
	    SysDate,L_check,UID,SysDate,L_lab_number);
	 insert into pcs.prepaid_labs
	    (lab_number,payment_amount,check_number,additional_info,sys_user,datestamp)

	 values
	    (L_lab_number,L_payment_amount,L_check_number,L_payment_info,UID,SysDate);

	 commit;
      end if;
      commit;
      P_code_area:='ADPH';
      if (L_ADPH_program is NOT NULL) then
	 insert into pcs.adph_lab_whp (lab_number,adph_program)
	 values (L_lab_number,L_ADPH_program);
      end if;
      --Added for surgical pathology; system keeps track of next lab number 
      if (L_prep=6) then
	 update pcs.job_control set job_status=job_status+1

	 where job_descr='TISSUE PATHOLOGY';
	 commit;
      end if;
      P_code_area:='CHECK BILLING';
      if (L_choice_code in ('DB','MED','BS','OI')) then
	 	pcs.check_billing_info(L_lab_number,0,1,1);
      end if;

       -- for HPV only testing a "stub" lab_results record must be
       -- 	 created; no patient history needed for HPV only
      
      if (L_prep=5) then
	 insert into pcs.lab_results (lab_number,date_completed,cytotech,pathologist,pap_class,
	     qc_status,datestamp,sys_user,first_print,path_status, biopsy_code,limited,change_date,change_user)
	  values
	     (L_lab_number,SysDate,2981,NULL,18,'N',SysDate,UID,2, 'N',NULL,0,SysDate,UID);
	  commit;
	  pcs.set_hpv(L_lab_number);
	  update pcs.job_control set job_status=job_status+1
	  where job_descr='HPV ONLY';
	  commit;
      else
		 pcs.get_patient_history(L_patient,L_lab_number,L_practice,0);

      end if;

   commit;

exception
  when OTHERS then
     P_error_code:=SQLCODE;
     P_error_message:=SQLERRM;
     insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
     values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);

     commit;
     RAISE;
end;
\