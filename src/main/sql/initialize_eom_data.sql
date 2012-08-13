create or replace procedure     initialize_EOM_data
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   cursor lab_list is
      select lab_number

      from pcs.practice_statement_labs
      where statement_id=S_month
      order by lab_number
   for update;
   curr_lab number;
   previous_lab number;
   ndx number;

begin

   P_proc_name:='INITIALIZE_EOM_DATA';
   P_code_area:='PREP';


   update pcs.practice_statement_labs
   set prac_2=(-1)
   where statement_id=S_month;
   commit;

   ndx:=(-1);
   previous_lab:=0;
   open lab_list;
   loop
      fetch lab_list into curr_lab;
      exit when lab_list%NOTFOUND;
      if (curr_lab<>previous_lab) then
	 ndx:=0;

	 previous_lab:=curr_lab;
      end if;
      update pcs.practice_statement_labs
      set prac_2=ndx
      where current of lab_list;
      ndx:=ndx+1;
   end loop;
   close lab_list;
      commit;

exception
   when OTHERS then
      P_error_code:=SQLCODE;

      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,curr_lab);
      commit;
      RAISE;

end;
\