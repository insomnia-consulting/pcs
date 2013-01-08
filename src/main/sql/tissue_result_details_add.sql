create or replace procedure tissue_result_details_add
(
   R_lab_number in number,
   R_result_letter in char,
   R_result_label in varchar2,
   R_result_type in varchar2,
   R_result_text in varchar2,
   R_pseq in number
)
as

   P_error_code number;
   P_error_message varchar2(512);

   P_proc_name varchar2(32);
   P_code_area varchar2(32);

begin

      P_proc_name:='TISSUE_RESULT_DETAILS_ADD';
      P_code_area:='INSERT';
      insert into pcs.tissue_results
	 (lab_number,result_letter,result_label,result_type,result_text,p_seq)
      values
	 (R_lab_number,R_result_letter,R_result_label,
	  R_result_type,R_result_text,R_pseq);
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

grant execute on tissue_result_details_add to pcs_user
\