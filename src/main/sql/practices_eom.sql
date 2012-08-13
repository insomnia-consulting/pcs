create or replace procedure     practices_eom
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   P_billing_choice number;
   S_id number;


   cursor insert_doc is
      select S_month,bq.lab_number,li.item_amount,'DOC',lq.practice,
	 RTRIM(p.lname)||', '||RTRIM(p.fname),r.datestamp,li.procedure_code,
	 pc.description,pc.p_seq,lq.date_collected,2,lq.slide_qty
      from pcs.billing_queue bq, pcs.lab_requisitions lq, pcs.lab_billing_items li,
	 pcs.patients p, pcs.lab_results r, pcs.procedure_codes pc, pcs.practices pr
      where bq.lab_number=lq.lab_number
      and lq.practice=pr.practice
      and lq.lab_number=li.lab_number
      and lq.lab_number=r.lab_number
      and lq.patient=p.patient
      and li.procedure_code=pc.procedure_code

      and bq.billing_route='PRA';

   cursor insert_non_doc is
      select S_month,lq.lab_number,0,bc.choice_code,lq.practice,
	 RTRIM(p.lname)||', '||RTRIM(p.fname),r.datestamp,li.procedure_code,
	 pc.description,pc.p_seq,lq.date_collected,2,lq.slide_qty
      from pcs.billing_choices bc, pcs.lab_requisitions lq, pcs.lab_billing_items li,
	 pcs.patients p, pcs.lab_results r, pcs.procedure_codes pc, pcs.practices pr
      where lq.lab_number=r.lab_number
      and r.lab_number=li.lab_number
      and lq.patient=p.patient
      and lq.practice=pr.practice
      and lq.billing_choice=bc.billing_choice

      and li.procedure_code=pc.procedure_code
      and TO_NUMBER(TO_CHAR(r.datestamp,'YYYYMM'))=S_month
      and lq.billing_choice<>122;

   INV_ym number;
   INV_lab number;
   INV_amount number;
   INV_code varchar2(3);
   INV_practice number;
   INV_patient varchar2(64);
   INV_result_entered date;
   INV_procedure varchar2(5);
   INV_description varchar2(64);

   INV_seq number;
   INV_collected date;
   INV_cycle number;

   PRIOR_statement number;
   PRIOR_cycle number;
   PRIOR_billing varchar2(3);

   in_items number;
   in_invoice number;
   num_vials number;

begin


   P_proc_name:='PRACTICES_EOM';
   P_code_area:='PREP';

   select billing_choice into P_billing_choice
   from pcs.billing_choices where choice_code='DOC';

   P_code_area:='OPEN DOC CURSOR';
   open insert_doc;
   loop
      fetch insert_doc into
	 INV_ym,INV_lab,INV_amount,INV_code,INV_practice,INV_patient,
	 INV_result_entered,INV_procedure,INV_description,INV_seq,

	 INV_collected,INV_cycle,num_vials;
      exit when insert_doc%NOTFOUND;
      select count(*) into in_items
      from pcs.lab_billing_items
      where lab_number=INV_lab
      and procedure_code=INV_procedure;
      select count(*) into in_invoice
      from pcs.practice_statement_labs
      where lab_number=INV_lab
      and procedure_code=INV_procedure
      and practice=INV_practice;
      if (INV_procedure='88305' AND num_vials>1) then
	 INV_description:=INV_description||' ['||RTRIM(LTRIM(TO_CHAR(num_vials)))||']';

      end if;
      if (in_items>in_invoice) then
	 insert into pcs.practice_statement_labs
	    (statement_id,lab_number,item_amount,choice_code,practice,
	     patient_name,date_results_entered,procedure_code,code_description,
	     p_seq,date_collected,billing_cycle)
	 values
	    (INV_ym,INV_lab,INV_amount,INV_code,INV_practice,INV_patient,
	     INV_result_entered,INV_procedure,INV_description,INV_seq,
	     INV_collected,INV_cycle);
      elsif (in_invoice>0) then
	 select MAX(statement_id) into PRIOR_statement
	 from pcs.practice_statement_labs

	 where lab_number=INV_lab;
	 select MAX(billing_cycle) into PRIOR_cycle
	 from pcs.practice_statement_labs
	 where lab_number=INV_lab
	 and statement_id=PRIOR_statement;
	 select distinct choice_code into PRIOR_billing
	 from pcs.practice_statement_labs
	 where lab_number=INV_lab
	 and statement_id=PRIOR_statement
	 and billing_cycle=PRIOR_cycle;
	 if (PRIOR_billing<>INV_code) then
	    insert into pcs.practice_statement_labs
	       (statement_id,lab_number,item_amount,choice_code,practice,

		patient_name,date_results_entered,procedure_code,code_description,
		p_seq,date_collected,billing_cycle)
	    values
	       (INV_ym,INV_lab,INV_amount,INV_code,INV_practice,INV_patient,
		INV_result_entered,INV_procedure,INV_description,INV_seq,
		INV_collected,INV_cycle);
	 end if;
      end if;
   end loop;
   close insert_doc;

   P_code_area:='OPEN NON-DOC CURSOR';
   open insert_non_doc;

   loop
      fetch insert_non_doc into
	 INV_ym,INV_lab,INV_amount,INV_code,INV_practice,INV_patient,
	 INV_result_entered,INV_procedure,INV_description,INV_seq,
	 INV_collected,INV_cycle,num_vials;
      exit when insert_non_doc%NOTFOUND;
      select count(*) into in_items
      from pcs.lab_billing_items
      where lab_number=INV_lab
      and procedure_code=INV_procedure;
      select count(*) into in_invoice
      from pcs.practice_statement_labs
      where lab_number=INV_lab

      and procedure_code=INV_procedure
      and practice=INV_practice;
      if (INV_procedure='88305' AND num_vials>1) then
	 INV_description:=INV_description||' ['||RTRIM(LTRIM(TO_CHAR(num_vials)))||']';
      end if;
      if (in_items>in_invoice) then
	 insert into pcs.practice_statement_labs
	    (statement_id,lab_number,item_amount,choice_code,practice,
	     patient_name,date_results_entered,procedure_code,code_description,
	     p_seq,date_collected,billing_cycle)
	 values
	    (INV_ym,INV_lab,INV_amount,INV_code,INV_practice,INV_patient,
	     INV_result_entered,INV_procedure,INV_description,INV_seq,

	     INV_collected,INV_cycle);
      elsif (in_invoice>0) then
	 select MAX(statement_id) into PRIOR_statement
	 from pcs.practice_statement_labs
	 where lab_number=INV_lab;
	 select MAX(billing_cycle) into PRIOR_cycle
	 from pcs.practice_statement_labs
	 where lab_number=INV_lab
	 and statement_id=PRIOR_statement;
	 select distinct choice_code into PRIOR_billing
	 from pcs.practice_statement_labs
	 where lab_number=INV_lab
	 and statement_id=PRIOR_statement

	 and billing_cycle=PRIOR_cycle;
	 if (PRIOR_billing<>INV_code) then
	    insert into pcs.practice_statement_labs
	       (statement_id,lab_number,item_amount,choice_code,practice,
		patient_name,date_results_entered,procedure_code,code_description,
		p_seq,date_collected,billing_cycle)
	    values
	       (INV_ym,INV_lab,INV_amount,INV_code,INV_practice,INV_patient,
		INV_result_entered,INV_procedure,INV_description,INV_seq,
		INV_collected,INV_cycle);
	 end if;
      end if;
   end loop;

   close insert_non_doc;

   
      -- Any lab that will be exported for billing to a physician account
      -- will be marked as finished.
   update pcs.lab_requisitions set finished=4 where lab_number in
      (select lab_number from pcs.billing_queue where billing_route='PRA' and
	 TO_NUMBER(TO_CHAR(datestamp,'YYYYMM'))=S_month);

   
      -- In order to preserve the current charges in the accounts history table
      -- the billing_route must first be changed to a temporary value before

      -- all of the PRAs can be deleted from the queue; the trigger p_charge_del
      -- subtracts charges from balance whenever there is a delete on a PRA
      -- from the queue

   commit;
   update pcs.billing_queue set billing_route='DOC' where billing_route='PRA';
   commit;
   	dbms_output.put_line('Deleting from billing queue');
   delete from pcs.billing_queue
   where billing_route='DOC' and TO_NUMBER(TO_CHAR(datestamp,'YYYYMM'))=S_month;
   commit;

   update pcs.practice_accounts_history set activity_flag=0;

   select TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'))+7,'YYYYMM'))
   into S_id from dual;
   dbms_output.put_line(' Year ' || S_id);
   insert into pcs.practice_accounts_history
      (practice,year_month,prior_balance,total_charges,total_payments,
       total_plus,total_minus,total_balance,activity_flag)
   select practice,S_id,total_balance,0,0,0,0,total_balance,1 from practice_accounts;

   update pcs.job_control set
      job_status=0
   where job_descr='MID MONTH' or job_descr='MID MONTH COUNT';

   commit;


--exception
--   when OTHERS then
--      P_error_code:=SQLCODE;
--      P_error_message:=SQLERRM;
--      insert into pcs.error_log
--	(error_code,error_message,proc_name,code_area,datestamp,sys_user)
--      values
--	(P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
--      commit;
--      RAISE;

end;
\