create or replace procedure patient_account_update
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   cursor patient_list is
      select * from pcs.patient_accounts
      where past_due<3 and past_due>-2
   for update;
   patient_fields patient_list%ROWTYPE;

    
   cursor pif_list is
      select * from pcs.patient_accounts where total_balance<0.01
   for update;
   pif_fields pif_list%ROWTYPE;

   interval number;
   L_rebilling number;
   L_rebill_code char(5);
   L_billing_type char(4);
   L_past_due number;

   collection_flag number;

   L_number number;
   rcnt number;

begin

   P_proc_name:='PATIENT_ACCOUNT_UPDATE';
   L_number:=0;

   select job_status into collection_flag
   from pcs.job_control where job_descr='COLLECTIONS';

   P_code_area:='PATIENT_LIST';

   open patient_list;
   loop
      dbms_output.put_line('Looping..');
      <<loop_top>>
      fetch patient_list into patient_fields;
      exit when patient_list%NOTFOUND;
      L_number:=patient_fields.lab_number;
      select count(*) into rcnt from pcs.billing_queue where lab_number=L_number;
      if (rcnt>0) then
	 goto loop_top;
      end if;
      select round(SysDate)-round(patient_fields.due_date_start) into interval from dual;
      if (interval>30 and interval<61 and patient_fields.past_due=0) then
	 P_code_area:='PATIENT_LIST_30 ['||L_number||']';

	 update pcs.patient_accounts set past_due=1 where current of patient_list;
	 select max(rebilling) into L_rebilling from pcs.billing_details
	 where lab_number=patient_fields.lab_number;
	 select rebill_code into L_rebill_code from pcs.billing_details
	 where lab_number=patient_fields.lab_number and rebilling=L_rebilling;
	 select billing_type into L_billing_type from pcs.patient_statements
	 where lab_number=patient_fields.lab_number;
	 if (L_billing_type='CP00') then
	    L_billing_type:='CP30';
	 else
	    L_billing_type:='DB30';
	 end if;
	 if (patient_fields.total_balance>=5) then

	    delete from pcs.billing_queue
	    where lab_number=patient_fields.lab_number and rebilling=L_rebilling;
	    insert into pcs.billing_queue
	       (lab_number,billing_route,datestamp,billing_type,rebilling,rebill_code)
	    values
	       (patient_fields.lab_number,'PAT',SysDate,
		L_billing_type,L_rebilling,L_rebill_code);
	 else
	    update pcs.patient_accounts set past_due=5 where current of patient_list;
	 end if;
--	 commit;
      elsif (interval>60 and interval<121 and patient_fields.past_due=1) then
	 P_code_area:='PATIENT_LIST_60 ['||L_number||']';

	 update pcs.patient_accounts set past_due=2 where current of patient_list;
	 select max(rebilling) into L_rebilling from pcs.billing_details
	 where lab_number=patient_fields.lab_number;
	 select rebill_code into L_rebill_code from pcs.billing_details
	 where lab_number=patient_fields.lab_number and rebilling=L_rebilling;
	 select billing_type into L_billing_type from pcs.patient_statements
	 where lab_number=patient_fields.lab_number;
	 if (L_billing_type='CP00' or L_billing_type='CP30') then
	    L_billing_type:='CP99';
	 else
	    L_billing_type:='DB99';
	 end if;
	 if (patient_fields.total_balance>=5) then

	    delete from pcs.billing_queue
	    where lab_number=patient_fields.lab_number and rebilling=L_rebilling;
	    insert into pcs.billing_queue
	       (lab_number,billing_route,datestamp,billing_type,rebilling,rebill_code)
	    values
	       (patient_fields.lab_number,'PAT',SysDate,
		L_billing_type,L_rebilling,L_rebill_code);
	 end if;
--	 commit;
      elsif (patient_fields.past_due=(-1)) then
	 P_code_area:='PATIENT_LIST_HOLD ['||L_number||']';
	 if (round(SysDate)>=round(patient_fields.due_date_start)) then
	    update pcs.patient_accounts set past_due=0 where current of patient_list;

	    select max(rebilling) into L_rebilling from pcs.billing_details
	    where lab_number=patient_fields.lab_number;
	    select rebill_code into L_rebill_code from pcs.billing_details
	    where lab_number=patient_fields.lab_number and rebilling=L_rebilling;
	    select billing_type into L_billing_type from pcs.patient_statements
	    where lab_number=patient_fields.lab_number;
	    delete from pcs.billing_queue
	    where lab_number=patient_fields.lab_number and rebilling=L_rebilling;
	    insert into pcs.billing_queue
	       (lab_number,billing_route,datestamp,billing_type,rebilling,rebill_code)
	    values
	       (patient_fields.lab_number,'PAT',SysDate,
		L_billing_type,L_rebilling,L_rebill_code);

--	    commit;
	 end if;
      elsif (interval>120 and patient_fields.past_due<3 and collection_flag=1) then
	 P_code_area:='PATIENT_LIST_120 ['||L_number||']';
	 L_past_due:=5;
	 if (patient_fields.total_balance>=10) then
	    L_past_due:=3;
	    insert into pcs.patient_accounts_in_collection
	       (patient,lab_number,create_date,outstanding_balance,sent,change_date)
	    values
	       (patient_fields.patient,patient_fields.lab_number,SysDate,
		patient_fields.total_balance,0,SysDate);
	 end if;

	 update pcs.patient_accounts
	 set past_due=L_past_due where current of patient_list;
--	 commit;
      end if;
   end loop;
   close patient_list;
commit;
   P_code_area:='PIF';
   open pif_list;
   loop
      fetch pif_list into pif_fields;
      exit when pif_list%NOTFOUND;
      L_number:=pif_fields.lab_number;

      update pcs.lab_requisitions set finished=4 where lab_number=pif_fields.lab_number;
      update pcs.lab_billings
      set date_paid=SysDate where lab_number=pif_fields.lab_number;
      delete from pcs.billing_queue where lab_number=pif_fields.lab_number;
      delete from pcs.patient_accounts where current of pif_list;
      update pcs.patient_accounts_in_collection
      set sent=2 where lab_number=pif_fields.lab_number;
   end loop;
   close pif_list;

   commit;

--exception
--
--   when OTHERS then
--      P_error_code:=SQLCODE;
--      P_error_message:=SQLERRM;
--      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
--      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_number);
--      commit;
--      RAISE;

end;
\