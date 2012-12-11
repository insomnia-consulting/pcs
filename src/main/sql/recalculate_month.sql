create or replace procedure  recalculate_month
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   start_lab number;
   cursor recalc_list is
      select a.lab_number from lab_requisitions a, lab_billing_items b
      where a.lab_number=b.lab_number(+) and b.lab_number is null
      and a.lab_number>=start_lab and a.finished>0;


   curr_lab number;
   rcnt number;

begin

   P_proc_name:='RECALCULATE_MONTH';
   P_code_area:='PREP';

   select job_status into start_lab from pcs.job_control
   where job_descr='MONTH STARTING';
   commit;
   open recalc_list;

      loop
	 fetch recalc_list into curr_lab;
	 exit when recalc_list%NOTFOUND;
	 pcs.calculate_cost(curr_lab);
      end loop;
   close recalc_list;

exception
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log
	 (error_code,error_message,proc_name,code_area,datestamp,sys_user)

      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;

end;