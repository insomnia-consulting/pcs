create or replace procedure     lab_req_detail_add
(
   L_lab_number in number,
   L_detail_code in number,
   L_comment_text in long
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);


begin

      P_proc_name:='LAB_REQ_DETAIL_ADD';
      P_code_area:='INSERT';
      insert into pcs.lab_req_details
	 (detail_id,lab_number,detail_code)
      values
	 (pcs.lab_req_detail_seq.nextval,L_lab_number,L_detail_code);
      commit;
      if (L_comment_text is not null)
      then
	 insert into pcs.lab_req_details_additional
	    (detail_id,comment_text)

	 values
	    (pcs.lab_req_detail_seq.currval,L_comment_text);
	 commit;
      end if;
      commit;

--exception
--   when OTHERS then
--      P_error_code:=SQLCODE;
--      P_error_message:=SQLERRM;
--      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
--      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
--      commit;
--
--      RAISE;

end;
\