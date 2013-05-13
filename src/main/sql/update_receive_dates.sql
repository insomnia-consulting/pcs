create or replace procedure     update_receive_dates
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   system_start number;
   cursor null_dates is
      select lab_number from pcs.lab_requisitions
      where receive_date is null and lab_number>=system_start
   for update of receive_date;
   L_number number;
   R_date date;

   begin

      P_proc_name:='UPDATE_RECEIVE_DATES';
      P_code_area:='NULL DATES';
      select job_status into system_start
      from pcs.job_control
      where job_descr='SYSTEM START';
      open null_dates;
      loop
	 fetch null_dates into L_number;
	 exit when null_dates%NOTFOUND;
	 R_date:=pcs.get_receive_date(L_number);
	 if (TO_CHAR(R_date,'MMDDYYYY')='01011900') then
	    R_date:=NULL;
	 end if;
	 update pcs.lab_requisitions set receive_date=R_date
	 where current of null_dates;
      end loop;
      close null_dates;
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
   
   grant execute on update_receive_dates to pcs_user
   \