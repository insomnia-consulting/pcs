create or replace procedure lab_result_codes_add
(
   R_lab_number in number,
   R_result_code in varchar2,
   R_mode in integer
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   R_qc_id integer;
   r_code varchar2(4);
   q_code varchar2(4);
   tech_code varchar2(3);
   p_class_assigned number;
   p_class number;


begin

      P_proc_name:='LAB_RESULT_CODE_ADD';
      P_code_area:='INSERT CODE '||TO_CHAR(R_mode);
      select NVL(pap_class,0) into p_class_assigned from pcs.lab_results
      where lab_number=R_lab_number;
      if (R_mode=1)
      then
	 select papclass into p_class from pcs.bethesda_codes
	 where bethesda_code=R_result_code;
	 if (p_class>p_class_assigned) then
	    update pcs.lab_results set pap_class=p_class
	    where lab_number=R_lab_number;
	 end if;
	 insert into pcs.lab_result_codes (lab_number,bethesda_code)d
	 values (R_lab_number,R_result_code);
      end if;
      if (R_mode=2)
      then
	 select papclass into p_class from pcs.bethesda_codes
	 where bethesda_code=R_result_code;
	 if (p_class>p_class_assigned) then
	    update pcs.lab_results set pap_class=p_class
	    where lab_number=R_lab_number;
	 end if;
	 select qc_id into R_qc_id from pcs.quality_control where lab_number=R_lab_number;
	 insert into pcs.quality_control_codes (qc_id,lab_number,bethesda_code)
	 values (R_qc_id,R_lab_number,R_result_code);
      end if;
      if (R_mode=3)
      then
	 select papclass into p_class from pcs.bethesda_codes
	 where bethesda_code=R_result_code;
	 if (p_class>p_class_assigned) then
	    update pcs.lab_results set pap_class=p_class
	    where lab_number=R_lab_number;
	 end if;
	 insert into pcs.pathologist_control_codes (lab_number,bethesda_code)
	 values (R_lab_number,R_result_code);
      end if;
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
grant execute on lab_result_codes_add to pcsuser 
\