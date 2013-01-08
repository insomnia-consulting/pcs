create or replace procedure     calculate_cost
(
   L_num in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   /* Constants for billing codes   */

   DB constant number := 121;		 /* bill goes to patient */
   DOC constant number := 122;		 /* bill goes to doc office */
   DPA constant number := 123;		 /* Medicaid */
   BS constant number := 124;		 /* Blue Cross Blue Shield */
   MED constant number := 125;		 /* Medicare */
   OI constant number := 126;		 /* Other insurance carriers */
   PRC constant number := 127;		 /* Professional courtesy, no charge */
   PPD constant number := 161;		 /* bill is prepaid by patient */

   /* Constants for finished status
   */
   RESULTS_PENDING constant number := 0;
   BILLING_QUEUE constant number := 1;

   SUBMITTED constant number := 2;
   PENDING constant number := 3;
   FINALIZED constant number := 4;

   /* Misc. constants   */
   MAT_INDEX constant number := 12;
   HPV_ONLY constant number := 5;

   L_billing_choice number;
   L_finished number;
   L_preparation number;
   L_rebilling number;

   L_total number;
   L_balance number;
   L_allow number;
   L_line_items number;
   L_other_fees number;
   L_payments number;
   L_tpp char(3);
   L_rebill_code varchar2(5);
   L_medicare_code char(1);
   L_pap_class number;
   L_practice number;
   L_ptype varchar2(32);
   rcnt number;
   
   NoDataExists EXCEPTION;
   pragma exception_init(NoDataExists,100);
begin
      P_proc_name:='CALCULATE_COST';
      P_code_area:='PREP';
      /* If there are pending HPV results, then charges	 cannot be calculated at this time; go to the	 termination point of the procedure, and exit.      */
      select count(*) into rcnt from pcs.hpv_requests
      where lab_number=L_num
      and (test_sent is NULL or test_sent IN ('R','P'));
      
      if (rcnt>0) then
	      goto exit_point;
      end if;

      /* Remove the lab from the billing queue if it is there; the procedure will put it back if applicable. Retrieve the data elements needed to calculate the charges.      */
      delete from pcs.billing_queue where lab_number=L_num;

	      select max(rebilling) into L_rebilling
	      from pcs.billing_details where lab_number=L_num;

	      
      select billing_choice,rebill_code,medicare_code
      into L_billing_choice,L_rebill_code,L_medicare_code
      from pcs.billing_details where lab_number=L_num and rebilling=L_rebilling;

      select finished,preparation
      into L_finished,L_preparation
      from pcs.lab_requisitions
      where lab_number=L_num;

      P_code_area:='BILLING LOGIC';
      delete from pcs.lab_billing_items where lab_number=L_num;
      if (L_billing_choice<>PRC) then
	 if (L_finished=FINALIZED) then

	    update pcs.lab_requisitions set finished=PENDING
	    where lab_number=L_num;
	 end if;
	 /*
	    detail code 12 is request maturation index; if the count is
	    zero, then run a delete to take care of the case that the
	    lab was updated and there was previously a mat. index
	 */
	 select count(*) into rcnt from pcs.lab_req_details
	 where lab_number=L_num and detail_code=MAT_INDEX;
	 if (rcnt=0)
	 then
	    delete from pcs.lab_mat_index where lab_number=L_num;

	 end if;
	 commit;
	 commit;
	 select a.practice,a.practice_type into L_practice,L_ptype
	 from pcs.practices a, pcs.lab_requisitions b
	 where a.practice=b.practice
	 and b.lab_number=L_num;
	 if (L_billing_choice=BS) then
	    P_code_area:='BS';
	    pcs.pbs_rules(L_num,L_billing_choice);
	    select NVL(MIN(a.tpp),'PPR') into L_tpp from pcs.carriers a, pcs.billing_details b
	    where a.carrier_id=b.carrier_id and b.lab_number=L_num
	    and b.rebilling=L_rebilling;

	    insert into pcs.billing_queue
	       (lab_number,billing_route,billing_type,rebilling,rebill_code,datestamp)
	    values
	       (L_num,L_tpp,null,L_rebilling,L_rebill_code,SysDate);
	 elsif (L_billing_choice=MED) then
	    P_code_area:='MED';
	    pcs.med_rules(L_num,L_billing_choice);
	    select pap_class into L_pap_class from pcs.lab_results
	    where lab_number=L_num;
	    select NVL(MIN(a.tpp),'PPR') into L_tpp from pcs.carriers a, pcs.billing_details b
	    where a.carrier_id=b.carrier_id and b.lab_number=L_num
	    and b.rebilling=L_rebilling;
	    insert into pcs.billing_queue

	       (lab_number,billing_route,billing_type,rebilling,rebill_code,datestamp)
	    values
	       (L_num,L_tpp,null,L_rebilling,L_rebill_code,SysDate);
	 elsif (L_billing_choice=DOC) then
	    P_code_area:='DOC';
	    pcs.doc_rules(L_num,L_billing_choice);
	    insert into pcs.billing_queue
	       (lab_number,billing_route,billing_type,rebilling,rebill_code,datestamp)
	    values (L_num,'PRA',null,L_rebilling,L_rebill_code,SysDate);
	 elsif (L_billing_choice=DB) then
	    P_code_area:='DB';
	    rcnt:=0;
	    if (L_ptype='WV') then

	       select count(*) into rcnt
	       from pcs.prepaid_labs
	       where lab_number=L_num;
	    end if;
	    if (rcnt=1) then
	       pcs.doc_rules(L_num,L_billing_choice);
	    else
	       pcs.default_rules(L_num,L_billing_choice);
	    end if;
	    insert into pcs.billing_queue
	       (lab_number,billing_route,billing_type,rebilling,rebill_code,datestamp)
	    values (L_num,'PAT','DB00',L_rebilling,L_rebill_code,SysDate);
	 elsif (L_billing_choice=OI) then

	    P_code_area:='OI';
	    pcs.default_rules(L_num,L_billing_choice);
	    select NVL(MIN(a.tpp),'PPR') into L_tpp from pcs.carriers a, pcs.billing_details b
	    where a.carrier_id=b.carrier_id and b.lab_number=L_num
	    and b.rebilling=L_rebilling;
	    insert into pcs.billing_queue
	       (lab_number,billing_route,billing_type,rebilling,rebill_code,datestamp)
	    values
	       (L_num,L_tpp,null,L_rebilling,L_rebill_code,SysDate);
	 elsif (L_billing_choice=DPA) then
	    P_code_area:='DPA';
	    pcs.default_rules(L_num,L_billing_choice);
	    select NVL(MIN(a.tpp),'PPR') into L_tpp

	    from pcs.carriers a, pcs.billing_details b
	    where a.carrier_id=b.carrier_id and b.lab_number=L_num
	    and b.rebilling=L_rebilling;
	    insert into pcs.billing_queue
	       (lab_number,billing_route,billing_type,rebilling,rebill_code,datestamp)
	    values
	       (L_num,L_tpp,null,L_rebilling,L_rebill_code,SysDate);
	 elsif (L_billing_choice=PPD) then
	    if (L_ptype='WV') then
	       pcs.doc_rules(L_num,L_billing_choice);
	    else
	       pcs.default_rules(L_num,L_billing_choice);
	    end if;

	 end if;
      else
	 P_code_area:='PRC';
	 pcs.default_rules(L_num,L_billing_choice);
	 update pcs.lab_billing_items set
	    item_amount=0
	 where lab_number=L_num
	 and rebilling=L_rebilling;
	 update pcs.lab_requisitions set finished=FINALIZED where lab_number=L_num;
	 commit;
      end if;
      /* Get the total of all line items that have
	 been added by the rules procedure.

      */
      select NVL(sum(item_amount),0) into L_line_items
      from pcs.lab_billing_items
      where lab_number=L_num;
      /*
	 Get the total of any plus adjustments that have
	 been made; this is added to the bill amount.
      */
      select NVL(sum(payment_amount),0) into L_other_fees
      from pcs.payments
      where lab_number=L_num
      and payment_type='PLUS ADJUST';
      L_total:=L_line_items+L_other_fees;

      /*
	 If an allowance has been set by an insurance carrier,
	 then the allowance takes precedence over the amount
	 of total charges in figuring the current balance.
      */
      select NVL(sum(allowance),0) into L_allow
      from pcs.lab_billings
      where lab_number=L_num;
      /*
	 Get the total of any payments that have been made;
	 this will include any minus adjustments that have
	 been made also.
      */

      select NVL(sum(payment_amount),0) into L_payments
      from pcs.payments
      where lab_number=L_num
      and payment_type<>'PLUS ADJUST';
      if (L_allow>0) then
	 L_balance:=(L_allow+L_other_fees)-L_payments;
      else
	 L_balance:=L_total-L_payments;
      end if;

      if (L_billing_choice=PPD) then
	 P_code_area:='PPD';
	 update pcs.billing_details set date_sent=SysDate

	 where lab_number=L_num and billing_choice=L_billing_choice;
	 if (L_balance<=0) then
	    update pcs.lab_requisitions set finished=FINALIZED where lab_number=L_num;
	 else
	    update pcs.lab_requisitions set finished=PENDING where lab_number=L_num;
	 end if;
      elsif (L_billing_choice=PRC) then
	 P_code_area:='PRC';
	 L_total:=0;
	 update pcs.billing_details set date_sent=SysDate
	 where lab_number=L_num
	 and billing_choice=L_billing_choice
	 and rebilling=L_rebilling;

      end if;
      P_code_area:='END DETAILS';
      if (L_billing_choice=MED) then
	 /*
	    Cannot bill Medicare for any Unsats
	 */
	 if (L_pap_class=1) then
	    update pcs.lab_requisitions set finished=FINALIZED where lab_number=L_num;
	    delete from pcs.fax_letters where lab_number=L_num;
	    delete from pcs.billing_queue
	    where lab_number=L_num and rebilling=L_rebilling;
	    commit;
	 end if;

      end if;
      P_code_area:='FX CNT';
      select count(*) into rcnt from pcs.fax_letters where lab_number=L_num;
      if (rcnt>0) then
	 delete from pcs.billing_queue where lab_number=L_num and rebilling=L_rebilling;
      else
	 P_code_area:='LB CNT';
	 select count(*) into rcnt from pcs.lab_billings where lab_number=L_num;
	 P_code_area:='LB CNT=='||TO_CHAR(rcnt);
	 if (rcnt=0) then
	    P_code_area:='INS LB';
	    insert into pcs.lab_billings (billing_choice,lab_number,bill_amount,
	       rebilling,balance,date_posted,date_paid)

	    values (L_billing_choice,L_num,L_total,L_rebilling,
	       L_balance,SysDate,SysDate);
	 else
	    P_code_area:='UPD LB ';
	    update pcs.lab_billings set
	       billing_choice=L_billing_choice,
	       bill_amount=L_total,
	       rebilling=L_rebilling,
	       balance=L_balance,
	       date_posted=SysDate,
	       date_paid=SysDate
	    where lab_number=L_num;
	    P_code_area:='UPD LB OK';

	 end if;
      end if;
      P_code_area:='CC FINISH';
      if (L_billing_choice=PRC) then
	 delete from pcs.billing_queue where lab_number=L_num and rebilling=L_rebilling;
      end if;

      /* If the finished status is zero (results pending), then set the status
	 to one (either in billing queue, or has pending fax letter. If the
	 preparation is an HPV only with a QNS result, then set the total charges
	 and balance due to zero, and set the finished status to four (finalized).
      */
      <<exit_point>>

      P_code_area:='UPD LAB_REQUISITIONS';
      update pcs.lab_requisitions set finished=BILLING_QUEUE
      where finished=RESULTS_PENDING and lab_number=L_num;
      select count(*) into rcnt from pcs.hpv_requests
      where lab_number=L_num and test_sent='Q';
      if (rcnt>0 AND L_preparation=HPV_ONLY) then
	 delete from pcs.billing_queue where lab_number=L_num and rebilling=L_rebilling;
	 update pcs.lab_billings set
	    bill_amount=0,
	    balance=0,
	    date_posted=SysDate,
	    date_paid=SysDate
	 where lab_number=L_num;

	 update pcs.lab_requisitions set finished=4 where lab_number=L_num;
      end if;
      commit;

exception
	when NO_DATA_FOUND then
		dbms_output.put_line('No Data found ');
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_num);
      commit;
      RAISE;

end;