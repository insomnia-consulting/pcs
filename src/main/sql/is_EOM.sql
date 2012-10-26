
create or replace function is_EOM (this_date IN number)
   return number
   is

      EOM_date number;
      run_EOM number;

   begin

      run_EOM:=0;

      select job_status into EOM_date
      from pcs.job_control

      where job_descr='EOM_DATE';

      if (EOM_date=this_date) then
	 run_EOM:=1;
      end if;

      return(run_EOM);

   end;
   \
   
   grant execute on is_EOM to pcs_user
   \