create or replace procedure rebill_add
(
   L_lab_number in number,
   L_patient in number,
   L_practice in number,
   L_rebilling in number,
   L_choice_code in varchar2,
   L_carrier_id_num in number,
   L_id_number in varchar2,
   L_group_number in varchar2,
   L_subscriber in varchar2,
   L_sub_lname in varchar2,
   L_sub_fname in varchar2,

   L_sign_date in varchar2,
   L_medicare_code in char,
   L_rebill_code in varchar2,
   L_diag1 in char,
   L_diag2 in char,
   L_diag3 in char,
   L_diag4 in char,
   L_billing_level in char,
   L_claim_status in varchar2
)
as

   P_error_code number;

   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   D_sign_date date;
   L_carrier_id number;
   L_id_num varchar2(23);
   L_billing_choice number;
   L_state char(2);
   L_doctor number;
   L_medicare_type char(1);
   old_billing number;
   old_choice_code char(3);

   old_practice number;
   old_carrier number;
   next_pay_id number;
   L_route char(3);
   L_btype char(4);
   rcnt number;
   C_rebilling number;
   lab_claim_id number;
   L_bill_amount number;
   L_balance number;
   L_allowance number;
   L_total_payments number;
   L_total_charges number;

   L_plus_adjust number;
   p_name varchar2(128);
   dr_id number;
   dr_upin varchar2(16);
   dr_lname varchar2(64);
   dr_fname varchar2(32);
   dr_license varchar2(16);
   dr_bs_provider varchar2(16);
   dr_status char(1);
   dr_alt_license varchar2(16);
   dr_alt_state varchar2(2);
   payer_state varchar2(2);
   practice_state varchar2(2);

   id_num varchar2(32);
   p_block char(1);
   check_point number;
   L_msg varchar2(128);

   E_invalid_rebilling exception;

begin

      P_proc_name:='REBILL_ADD';

      P_code_area:='PREP';
      check_point:=0;


      if (L_choice_code='DB') then
	 select block_patient into p_block from pcs.practices
	 where practice=L_practice;
	 if (p_block='Y') then
	    goto exit_point;
	 end if;
      end if;
      select billing_choice into L_billing_choice from pcs.billing_choices
      where choice_code=L_choice_code;

      /* 09/05: get rid of fax letter if DOC billing
      */

      if (L_choice_code='DOC') then
	 delete from pcs.fax_letters where lab_number=L_lab_number;
      end if;

      L_medicare_type:=L_medicare_code;
      C_rebilling:=L_rebilling+1;
      if (L_billing_choice=122) then
	 id_num:=TO_CHAR(L_practice,'009');
      else
	 id_num:=L_id_number;
      end if;

      commit;

      set transaction use rollback segment pcs_rbs5;

      P_code_area:='GET BILLING';
      /* get prior billing information */
      select billing_choice,carrier_id into old_billing,old_carrier
      from pcs.billing_details where lab_number=L_lab_number and rebilling=L_rebilling;
      check_point:=1;
      select choice_code into old_choice_code from pcs.billing_choices
      where billing_choice=old_billing;

      /* if rebilling from Medicare to non-Medicare billing
	 then remove any pending fax letters (mostly for NMN)
	 2/21/2007

      */
      if (old_choice_code='MED' and L_choice_code<>'MED') then
	 delete from pcs.fax_letters where lab_number=L_lab_number;
      end if;

      /*
      if (L_choice_code in ('BS','DPA','MED','OI')) then
	 if (L_carrier_id_num=old_carrier) then
	    RAISE E_invalid_rebilling;
	 end if;
      end if;
      */


      P_code_area:='GET_DOCTOR';
      select doctor into L_doctor from lab_requisitions where lab_number=L_lab_number;
      P_code_area:='VALIDATE_DOCTOR '||TO_CHAR(L_doctor)||' '||TO_CHAR(L_practice);
      dr_id:=pcs.validate_doctor
	 (L_lab_number,L_practice,L_doctor,L_carrier_id_num,L_choice_code);
      /* If the doctor validation results in the default doctor being selected
	 to facilitate billing then update the req table; also add comment
      */
      if (L_doctor<>dr_id) then
	 P_code_area:='UPD_LQ';
	 update pcs.lab_requisitions set doctor=dr_id where lab_number=L_lab_number;
      end if;


      /* get the current totals for this unit of work */
      P_code_area:='CURR_TOTALS';
      select bill_amount,balance,allowance,bill_amount-balance
      into L_bill_amount,L_balance,L_allowance,L_total_payments
      from pcs.lab_billings where lab_number=L_lab_number;

      P_code_area:='PAYMENTS';
      select NVL(SUM(payment_amount),0) into L_total_payments
      from payments where lab_number=L_lab_number;

      P_code_area:='DB AND DOC';
      delete from pcs.billing_queue where lab_number=L_lab_number;
      if (old_choice_code='DB') then

	 delete from pcs.patient_accounts where patient=L_patient;
	 update pcs.patient_accounts_in_collection set sent=2, change_date=SysDate
	 where lab_number=L_lab_number;
      elsif (old_choice_code='DOC') then
	 select count(*) into rcnt from pcs.billing_queue where lab_number=L_lab_number;
	 if (rcnt>0) then
	    delete from pcs.billing_queue where lab_number=L_lab_number;
	 end if;
	 select practice into old_practice
	 from pcs.lab_requisitions where lab_number=L_lab_number;
	 select pcs.payments_seq.nextval into next_pay_id from dual;
	 insert into pcs.payments (payment_id,billing_choice,account_id,
	    payment_type,payment_amount,payment_date,sys_user,receive_date)

	 values (next_pay_id,old_billing,old_practice,'MINUS ADJUST',
	    L_bill_amount,SysDate,UID,SysDate);
	 select TO_CHAR(L_lab_number)||' '||lname||', '||fname into p_name
	 from pcs.patients where patient=L_patient;
	 insert into pcs.payment_adjust_reasons (payment_id,adjust_reason)
	 values (next_pay_id,p_name);
      end if;
      check_point:=3.1;
      if (L_sign_date is NOT NULL) then
	 D_sign_date:=TO_DATE(L_sign_date,'MMDDYYYY');
      end if;
      check_point:=3.11;
      check_point:=3.12;

      if (L_choice_code='DOC') then
	 check_point:=3.2;
	 L_id_num:=LTRIM(RTRIM(TO_CHAR(old_practice,'009')));
	 if (old_choice_code='DOC') then
	    check_point:=3.3;
	    update pcs.billing_details set id_number=L_id_num
	    where lab_number=L_lab_number and rebilling=L_rebilling;
	    check_point:=3.4;
	 end if;
	 check_point:=check_point+0.01;
	 L_id_num:=LTRIM(RTRIM(TO_CHAR(L_practice,'009')));
      elsif (L_choice_code='DB') then
	 L_id_num:=LTRIM(RTRIM(TO_CHAR(L_patient)));

      else
	 L_id_num:=L_id_number;
      end if;
      check_point:=4;
      if (L_medicare_code='F') then
	 pcs.build_diagnosis_letter(L_lab_number,1,2);
	 L_medicare_type:=NULL;
      end if;
      check_point:=5;
      P_code_area:='BILLING DETAIL INSERT';
      insert into pcs.billing_details
	 (carrier_id,lab_number,id_number,group_number,subscriber,
	 sub_lname,sub_fname,sign_date,medicare_code,rebilling,

	 billing_choice,datestamp,rebill_code,billing_level,sys_user,
	 change_user,change_date)
      values
	 (L_carrier_id_num,L_lab_number,L_id_num,L_group_number,
	 L_subscriber,L_sub_lname,L_sub_fname,D_sign_date,
	 L_medicare_type,L_rebilling+1,L_billing_choice,
	 SysDate,L_rebill_code,L_billing_level,UID,UID,SysDate);
      check_point:=5.1;
      if (L_choice_code='PRC') then
	 update pcs.lab_billings set
	    date_paid=SysDate,date_posted=SysDate,billing_choice=L_billing_choice
	 where lab_number=L_lab_number;
	 update pcs.lab_requisitions set finished=4 where lab_number=L_lab_number;

	 delete from pcs.fax_letters where lab_number=L_lab_number;
	 update pcs.lab_claims set rework_queue=0 where lab_number=L_lab_number;
	 goto exit_point;
      end if;
      P_code_area:='DIAG';
      if (L_diag1 is not null)
      then
	 check_point:=5.11;
	 insert into pcs.lab_req_diagnosis (lab_number,diagnosis_code,d_seq,rebilling)
	 values (L_lab_number,L_diag1,1,L_rebilling+1);
	 if (L_diag2 is not null)
	 then
	    check_point:=5.12;

	    insert into pcs.lab_req_diagnosis (lab_number,diagnosis_code,d_seq,rebilling)
	    values (L_lab_number,L_diag2,2,L_rebilling+1);
	 end if;
	 if (L_diag3 is not null)
	 then
	    check_point:=5.13;
	    insert into pcs.lab_req_diagnosis (lab_number,diagnosis_code,d_seq,rebilling)
	    values (L_lab_number,L_diag3,3,L_rebilling+1);
	 end if;
	 if (L_diag4 is not null)
	 then
	    check_point:=5.14;
	    insert into pcs.lab_req_diagnosis (lab_number,diagnosis_code,d_seq,rebilling)

	    values (L_lab_number,L_diag4,4,L_rebilling+1);
	 end if;
      end if;
      check_point:=6;
      if (L_billing_level<>'PRT') then
	 update pcs.lab_requisitions set billing_choice=L_billing_choice
	 where lab_number=L_lab_number;
      end if;
      check_point:=7;
      P_code_area:='LETTER';
      if (L_claim_status is NULL or L_claim_status<>'SU') then
	 delete from pcs.fax_letters
	 where lab_number=L_lab_number and letter_type in ('GENERIC');

	 rcnt:=0;
	 if (L_choice_code in ('DB','MED','BS','OI')) then
	    pcs.check_billing_info(L_lab_number,L_rebilling+1,1,2);
	    select count(*) into rcnt from pcs.fax_letters
	    where lab_number=L_lab_number and letter_type in ('GENERIC');
	 end if;
	 if (rcnt=0) then
	    if (L_choice_code='DOC') then
	       update pcs.lab_requisitions set practice=L_practice
	       where lab_number=L_lab_number;
	       L_allowance:=NULL;
	       L_total_payments:=0;
	       commit;

	    end if;
	    pcs.calculate_cost(L_lab_number);
	    /*
	    if (L_choice_code='DOC') then
	       delete from pcs.billing_queue where lab_number=L_lab_number;
	       select bill_amount into L_total_charges from pcs.lab_billings
	       where lab_number=L_lab_number;
	       select pcs.payments_seq.nextval into next_pay_id from dual;
	       insert into pcs.payments (payment_id,billing_choice,account_id,
		  payment_type,payment_amount,payment_date,sys_user,receive_date)
	       values (next_pay_id,L_billing_choice,L_practice,'PLUS ADJUST',
		  L_total_charges,SysDate,UID,SysDate);
	       select TO_CHAR(L_lab_number)||' '||lname||', '||fname into p_name

	       from pcs.patients where patient=L_patient;
	       insert into pcs.payment_adjust_reasons (payment_id,adjust_reason)
	       values (next_pay_id,p_name);
	    end if;
	    */
	 end if;
      end if;
      P_code_area:='BILLING QUEUE';
      update pcs.lab_claims set rework_queue=0 where lab_number=L_lab_number;
      if (L_claim_status is NOT NULL and L_choice_code<>'DOC') then
	 if (L_claim_status='P2' or L_claim_status='R2') then
	    L_route:='PPR';
	 end if;

	 if (L_billing_level='PRT' or L_rebill_code='SEC') then
	    select MAX(rebilling) into C_rebilling from pcs.billing_details
	    where lab_number=L_lab_number;
	    if (L_choice_code='DPA') then
	       select state into L_state from pcs.carriers
	       where carrier_id=L_carrier_id_num;
	       L_route:='PPR';
	    elsif (L_choice_code='DB') then
	       L_route:='PAT';
	       L_btype:='CP00';
	    else
	       L_route:='PPR';
	    end if;

	 end if;
	 if (L_route is NOT NULL) then
	    update pcs.billing_queue set
	       billing_route=L_route,rebill_code=L_rebill_code,billing_type=L_btype
	    where lab_number=L_lab_number;
	 end if;
      end if;
      update pcs.lab_requisitions set finished=3
      where lab_number=L_lab_number and finished<=3;
      update pcs.lab_billings set
	 billing_choice=L_billing_choice,
	 rebilling=C_rebilling,
	 allowance=L_allowance

      where lab_number=L_lab_number;
      <<exit_point>>
      commit;

--exception
--   when E_invalid_rebilling then
--      P_error_code:=-20017;
--      P_error_message:='CANNOT REBILL TO SAME PAYER';
--      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
--      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
--      RAISE_APPLICATION_ERROR(P_error_code,P_error_message);
--   when OTHERS then
--      P_error_code:=SQLCODE;
--
--      P_error_message:=SQLERRM;
--      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
--      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
--      RAISE;

end;
\

grant execute on rebill_add to pcs_user
\

