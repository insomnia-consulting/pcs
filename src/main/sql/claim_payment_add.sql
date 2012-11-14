create or replace procedure     claim_payment_add
(
   C_lab_number in number,
   C_claim_id in number,
   C_alt_id in varchar2,
   C_claim_status in varchar2,
   C_claim_comment in varchar2,
   C_payment_amount in number,
   C_carrier in number,
   C_receive_date in varchar2,
   C_billing_choice in number,
   C_copay in number,
   C_allow in number,

   C_bill_amount in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   P_receive_date date;
   P_patient number;
   P_practice number;
   P_rebilling number;

   C_rebill_code varchar(5);
   P_payment_id number;
   P_allow number;
   C_batch number;
   amt_due number;
   n_val number;
   rcnt number;
   P_carrier number;

begin

   P_proc_name:='CLAIM_PAYMENT_ADD';


   P_code_area:='PREP';
   P_payment_id:=0;
   update pcs.billing_details
   set change_user=UID, change_date=SysDate
   where lab_number=C_lab_number and claim_id=C_claim_id;
   select count(*) into rcnt from pcs.billing_details where claim_id=C_claim_id;
   if (rcnt>0) then
      select carrier_id into P_carrier from pcs.billing_details where claim_id=C_claim_id;
   else
      P_carrier:=C_carrier;
   end if;
   if (C_receive_date is not null) then
      P_receive_date:=TO_DATE(C_receive_date,'MMDDYYYY');

   else
      select SysDate into P_receive_date from dual;
   end if;
   amt_due:=C_bill_amount-C_payment_amount;
   if (C_allow is not null and C_allow>0) then
      P_allow:=C_allow;
      select count(*) into rcnt from pcs.lab_claims
      where lab_number=C_lab_number and allowance is NOT NULL;
      if (rcnt>0) then
	 select MIN(allowance) into P_allow from pcs.lab_claims where lab_number=C_lab_number;
	 if (P_allow>C_allow) then
	    P_allow:=C_allow;
	    update pcs.lab_billings set allowance=C_allow where lab_number=C_lab_number;

	 end if;
      end if;
      amt_due:=P_allow-C_payment_amount;
   end if;
   P_code_area:='STATUS CODE '||C_claim_status;
   if (C_claim_status='P') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 0,
	 claim_comment = C_claim_comment,
	 amount_paid = NVL(amount_paid,0)+C_payment_amount,
	 allowance = C_allow,

	 change_date = P_receive_date
      where claim_id=C_claim_id;
      select pcs.payments_seq.nextval into P_payment_id from dual;
      insert into pcs.payments (payment_id,billing_choice,account_id,
	 payment_type,payment_amount,payment_date,check_number,sys_user,receive_date,lab_number)
      values (P_payment_id,C_billing_choice,P_carrier,'CLAIM',
	 C_payment_amount,SysDate,C_claim_id,UID,P_receive_date,C_lab_number);
      delete from pcs.billing_queue where lab_number=C_lab_number;
   elsif (C_claim_status='L') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 0,

	 claim_comment = C_claim_comment,
	 amount_paid = 0,
	 allowance = null,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
   elsif (C_claim_status='F' or C_claim_status='R2') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 1,
	 claim_comment = C_claim_comment,
	 allowance = C_allow,
	 change_date = P_receive_date

      where claim_id=C_claim_id;
   elsif (C_claim_status='S' or C_claim_status='B') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 0,
	 claim_comment = C_claim_comment,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
   elsif (C_claim_status in ('R','I','N')) then
      delete from pcs.fax_letters
      where lab_number=C_lab_number and in_queue=0;

      select count(*) into rcnt from billing_details
      where billing_level='PRT' and lab_number=C_lab_number;
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 0,
	 claim_comment = C_claim_comment,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
      select MAX(rebilling) into P_rebilling from pcs.billing_details
      where lab_number=C_lab_number;
      select patient,practice into P_patient,P_practice from pcs.lab_requisitions

      where lab_number=C_lab_number;
      if (C_claim_status='R') then
	 if (rcnt>0) then
	    C_rebill_code:='NCA';
	 else
	    C_rebill_code:='NC';
	 end if;
      elsif (C_claim_status='I') then
	 C_rebill_code:='I';
      else
	 C_rebill_code:='NP';
      end if;
      if (rcnt>0) then

	 pcs.rebill_add(C_lab_number,P_patient,P_practice,P_rebilling,'DB',-1,null,
	    null,null,null,null,null,null,C_rebill_code,null,null,null,null,'PRT',C_claim_status);
      else
	 pcs.rebill_add(C_lab_number,P_patient,P_practice,P_rebilling,'DB',-1,null,
	    null,null,null,null,null,null,C_rebill_code,null,null,null,null,'RBL',C_claim_status);
      end if;
      update pcs.patient_accounts set total_charges=amt_due
      where patient=P_patient and lab_number=C_lab_number;
   elsif (C_claim_status='D') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 0,

	 claim_comment = C_claim_comment,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
      select MAX(rebilling) into P_rebilling from pcs.billing_details
      where lab_number=C_lab_number;
      select patient,practice into P_patient,P_practice from pcs.lab_requisitions
      where lab_number=C_lab_number;
      pcs.rebill_add(C_lab_number,P_patient,P_practice,P_rebilling,'DB',-1,null,
	 null,null,null,null,null,null,'DCT',null,null,null,null,'RBL',C_claim_status);
      update pcs.billing_queue set billing_type='CP00' where lab_number=C_lab_number;
      update pcs.patient_accounts set total_charges=amt_due
      where patient=P_patient and lab_number=C_lab_number;

   elsif (C_claim_status='PP') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 0,
	 claim_comment = C_claim_comment,
	 amount_paid = NVL(amount_paid,0)+C_payment_amount,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
      select pcs.payments_seq.nextval into P_payment_id from dual;
      insert into pcs.payments (payment_id,billing_choice,account_id,
	 payment_type,payment_amount,payment_date,check_number,sys_user,receive_date,lab_number)

      values (P_payment_id,C_billing_choice,P_carrier,'CLAIM',
	 C_payment_amount,SysDate,C_claim_id,UID,P_receive_date,C_lab_number);
      select MAX(rebilling) into P_rebilling from pcs.billing_details
      where lab_number=C_lab_number;
      select patient,practice into P_patient,P_practice from pcs.lab_requisitions
      where lab_number=C_lab_number;
      pcs.rebill_add(C_lab_number,P_patient,P_practice,P_rebilling,'DB',-1,null,
	 null,null,null,null,null,null,'CP',null,null,null,null,'PRT',C_claim_status);
      update pcs.billing_queue set billing_type='CP00' where lab_number=C_lab_number;
      update pcs.patient_accounts set total_charges=amt_due
      where patient=P_patient and lab_number=C_lab_number;
   elsif (C_claim_status='P2' or C_claim_status='SU') then
      n_val:=0;

      if (C_claim_status='P2') then
	 n_val:=1;
      end if;
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = n_val,
	 claim_comment = C_claim_comment,
	 amount_paid = NVL(amount_paid,0)+C_payment_amount,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
      select pcs.payments_seq.nextval into P_payment_id from dual;

      insert into pcs.payments (payment_id,billing_choice,account_id,
	 payment_type,payment_amount,payment_date,check_number,sys_user,receive_date,lab_number)
      values (P_payment_id,C_billing_choice,P_carrier,'CLAIM',
	 C_payment_amount,SysDate,C_claim_id,UID,P_receive_date,C_lab_number);
   elsif (C_claim_status='LT') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 1,
	 claim_comment = C_claim_comment,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;

      pcs.build_medicare_letter(C_lab_number,C_claim_id,'N',2);
   elsif (C_claim_status='MR') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,
	 alt_id = C_alt_id,
	 rework_queue = 0,
	 claim_comment = C_claim_comment,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
   elsif (C_claim_status='O') then
      update pcs.lab_claims set
	 claim_status = C_claim_status,

	 alt_id = C_alt_id,
	 rework_queue = 0,
	 claim_comment = C_claim_comment,
	 allowance = C_allow,
	 change_date = P_receive_date
      where claim_id=C_claim_id;
      select MAX(rebilling) into P_rebilling from pcs.billing_details
      where lab_number=C_lab_number;
      insert into pcs.billing_queue (lab_number,billing_route,datestamp,
	 billing_type,rebilling,rebill_code)
      values (C_lab_number,'WKS',SysDate,'WKS',P_rebilling,null);
   end if;
   if (C_claim_status='L' or C_claim_status='P') then

      update pcs.lab_requisitions set finished=4 where lab_number=C_lab_number;
      update pcs.lab_billings set date_paid=SysDate where lab_number=C_lab_number;
      delete from pcs.fax_letters where lab_number=C_lab_number;
   else
      update pcs.lab_requisitions set finished=3 where lab_number=C_lab_number;
      update pcs.lab_billings set date_paid=NULL where lab_number=C_lab_number;
   end if;
   commit;
   if (P_payment_id>0) then
      P_code_area:='PAYMENT';
      select batch_number into C_batch from pcs.lab_claims where claim_id=C_claim_id;
      update pcs.payer_batch_amounts set
	 amount_recorded=amount_recorded+C_payment_amount

      where carrier_id=P_carrier and batch_number=C_batch;
      pcs.post_one_payment(P_payment_id);
   end if;
   commit;

exception
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,C_lab_number);
      commit;
      RAISE;


end;
