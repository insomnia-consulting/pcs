create or replace procedure  init_next_EOM
(
   S_month IN number
)
as

      next_S_month number;
      next_EOM_date date;
      next_first_DOW varchar2(16);
      next_EOM_mode number;
      next_EOM number;

   begin


      next_EOM_date:=ADD_MONTHS(TO_DATE(TO_CHAR(S_month),'YYYYMM'),1);
      next_S_month:=TO_NUMBER(TO_CHAR(next_EOM_date,'YYYYMM'));
      next_EOM_date:=ADD_MONTHS(next_EOM_date,1);
      next_first_DOW:=RTRIM(LTRIM(TO_CHAR(next_EOM_date,'DAY')));
      next_EOM_mode:=0;

      if ((next_first_DOW='TUESDAY') or
	  (next_first_DOW='WEDNESDAY') or
	  (next_first_DOW='THURSDAY') or
	  (next_first_DOW='FRIDAY')) then
	 next_EOM_mode:=1;
      elsif (next_first_DOW='MONDAY') then

	 next_EOM_date:=next_EOM_date-1;
      end if;
      next_EOM:=TO_NUMBER(TO_CHAR(next_EOM_date,'YYYYMMDD'));

      update pcs.job_control
      set job_status=next_S_month
      where job_descr='S_MONTH';

      update pcs.job_control
      set job_status=next_EOM
      where job_descr='EOM_DATE';

      next_EOM_mode:=0;

      update pcs.job_control
      set job_status=next_EOM_mode
      where job_descr='EOM_MODE';

      commit;

   end;
    \
   
   grant execute on init_next_EOM to pcs_user
   \