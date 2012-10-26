create or replace procedure     generate_summaries
(
   S_month in number,
   S_mode in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   P_practice number;

   pcards char(1);
   EOM_status number;
   min_practice number;
   max_practice number;
   stmt_ID number;

   cursor summary_list is
      select distinct L.practice
      from pcs.lab_requisitions L, pcs.lab_results R, pcs.practice_statement_labs P
      where L.lab_number=R.lab_number
      and R.lab_number=P.lab_number
      and R.pap_class>0
      and R.pap_class<16

      and P.practice>=min_practice
      and P.practice<max_practice
      and P.statement_id=stmt_ID;

begin

   P_proc_name:='GENERATE_SUMMARIES';
   P_code_area:='PREP';

   if (S_mode=0) then
      min_practice:=0;
      max_practice:=1000;
      update pcs.job_control

      set job_status=0
      where job_descr='ACCOUNT_MID';
      update pcs.job_control
      set job_status=(-1)
      where job_descr='SUMMARY_MODE';
      stmt_ID:=S_month;
   elsif (S_mode=1) then
      min_practice:=0;
      max_practice:=get_account_midpoint(S_month);
      update pcs.job_control
      set job_status=max_practice
      where job_descr='ACCOUNT_MID';
      update pcs.job_control

      set job_status=S_month
      where job_descr='SUMMARY_MODE';
      stmt_ID:=S_month;
   elsif (S_mode>1) then
      select job_status into min_practice
      from pcs.job_control
      where job_descr='ACCOUNT_MID';
      max_practice:=1000;
      update pcs.job_control
      set job_status=0
      where job_descr='ACCOUNT_MID';
      update pcs.job_control
      set job_status=(-1)

      where job_descr='SUMMARY_MODE';
      stmt_ID:=S_mode;
   end if;
   commit;

   P_code_area:='SUMMARY_LIST';
   P_practice:=0;
   open summary_list;
   loop
      fetch summary_list into P_practice;
      exit when summary_list%NOTFOUND;
      pcs.build_adequacy_results(P_practice,stmt_ID);
      pcs.build_doctor_summary(P_practice,stmt_ID);

      select patient_cards into pcards from pcs.practices where practice=P_practice;
      if (pcards='Y') then
	 pcs.build_patient_cards(P_practice,stmt_ID);
      end if;
   end loop;
   close summary_list;

   commit;

exception
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;

      insert into pcs.error_log
	(error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values
	(P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,P_practice);
      commit;
      RAISE;

end;
\

grant execute on generate_summaries to pcs_user
\