create or replace procedure get_patient_history
(
   P_patient in number,
   P_lab_number in number,
   P_practice in number,
   P_mode in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);


   P_lname varchar2(32);
   P_fname varchar2(32);
   P_dob date;
   P_ssn varchar2(9);

   P_NULL_dob constant date := SysDate;
   P_NULL_ssn constant varchar2(9) := '000000000';

   M_lab number;
   M_practice number;
   M_dob date;
   M_ssn varchar2(9);


   M_NULL_dob constant date := SysDate+1;
   M_NULL_ssn constant varchar2(9) := '999999999';

   cursor DOB_SSN_list is
      select last_lab
      from pcs.patients
      where dob is not NULL
      and ssn is not NULL
      and dob=P_dob
      and ssn=P_ssn
      and last_lab<>P_lab_number;


   cursor NAME_list is
      select l.lab_number,l.practice,NVL(p.ssn,M_NULL_ssn),NVL(p.dob,M_NULL_dob)
      from pcs.lab_requisitions l, pcs.patients p
      where l.patient=p.patient
      and p.lname=P_lname
      and p.fname=P_fname
      and l.lab_number<>P_lab_number;

   M_level number;
   min_lab number;
   curr_lab number;

   done number;
   rcnt number;

begin

   P_proc_name:='GET_PATIENT_HISTORY';
   P_code_area:='PREP';

   select min(lab_number) into min_lab
   from pcs.lab_requisitions;

   --Last and first name, DOB and SSN of
   --   the current requisition.


   select lname,fname,NVL(dob,P_NULL_dob),NVL(ssn,P_NULL_ssn)
   into P_lname,P_fname,P_dob,P_ssn
   from pcs.patients where patient=P_patient;

   update pcs.job_control
   set job_status=job_status+1
   where job_descr='MATCH_COUNT';
   commit;

   -- Level 1
   --    Only these records will get an M_level of 1
   

   P_code_area:='LEVEL_1';
   M_level:=1;
   curr_lab:=P_lab_number;
   done:=1;
   while (done>0) loop
      select previous_lab into M_lab
      from pcs.lab_requisitions
      where lab_number=curr_lab;
      if (M_lab<>curr_lab AND M_lab>=min_lab) then
	 select count(*) into rcnt
	 from pcs.history_match_queue where lab_match=M_lab;
	 if (rcnt=0) then
	    insert into pcs.history_match_queue

	      (lab_number,lab_match,patient,m_level,sys_user,printed)
	    values (P_lab_number,M_lab,P_patient,M_level,UID,P_mode);
	    update pcs.job_control
	    set job_status=job_status+0.01
	    where job_descr='MATCH_COUNT';
	    commit;
	    curr_lab:=M_lab;
	 end if;
      else
	 done:=0;
      end if;
   end loop;


   --  Level 2
   --    Only these records will get an M_level of 2
   -- 
   P_code_area:='LEVEL_2';
   M_level:=2;
   if (P_dob<>P_NULL_dob AND P_ssn<>P_NULL_ssn) then
      open DOB_SSN_list;
      loop
	 fetch DOB_SSN_list into M_lab;
	 exit when DOB_SSN_list%NOTFOUND;
	 select count(*) into rcnt
	 from pcs.history_match_queue where lab_match=M_lab;
	 if (rcnt=0) then

	    insert into pcs.history_match_queue
	      (lab_number,lab_match,patient,m_level,sys_user,printed)
	    values (P_lab_number,M_lab,P_patient,M_level,UID,P_mode);
	    update pcs.job_control
	    set job_status=job_status+0.01
	    where job_descr='MATCH_COUNT';
	    commit;
	 end if;
      end loop;
      close DOB_SSN_list;
   end if;

    -- Level 3

    --   These records get an M_level between 3 and 5 as follows:
    --   All records will have a match of first and last name.
    --   M_level=3: The practice and one of either the ssn or dob matches.
    --   M_level=4: One of either the ssn or dob matches.
    --   M_level=5: Only the practice matches.
   
   P_code_area:='LEVEL_3';
   open NAME_list;
   loop
      fetch NAME_list into M_lab,M_practice,M_ssn,M_dob;
      exit when NAME_list%NOTFOUND;
      M_level:=0;
      if (M_dob=P_dob OR M_ssn=P_ssn) then

	 if (M_practice=P_practice) then
	    M_level:=3;
	 else
	    M_level:=4;
	 end if;
      elsif (M_practice=P_practice) then
	 M_level:=5;
      end if;
      select count(*) into rcnt from pcs.history_match_queue where lab_match=M_lab;

      if (rcnt=0 and M_level>0) then
	 insert into pcs.history_match_queue

	    (lab_number,lab_match,patient,m_level,sys_user,printed)
	 values (P_lab_number,M_lab,P_patient,M_level,UID,P_mode);
	 update pcs.job_control
	 set job_status=job_status+0.01
	 where job_descr='MATCH_COUNT';
	 commit;
      end if;
   end loop;
   close NAME_list;

   commit;

exception

   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,P_lab_number);
      commit;
      RAISE;

end;
\