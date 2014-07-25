create or replace procedure     reset_claim_status
(
   C_lab_number in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   C_rebilling number;
   C_claim_id number;
   C_claim_status varchar2(2);

   BD_claim_id number;

   in_queue number;

   E_invalid_claim exception;
   E_invalid_status exception;
   E_in_queue exception;

begin

   P_proc_name:='REVERSE_DB';

   P_code_area:='PREP';

   select MAX(rebilling) into C_rebilling from pcs.billing_details
   where lab_number=C_lab_number;
   select NVL(claim_id,-1) into BD_claim_id from pcs.billing_details
   where lab_number=C_lab_number and rebilling=C_rebilling;
   select MAX(claim_id) into C_claim_id from pcs.lab_claims
   where lab_number=C_lab_number;
   select claim_status into C_claim_status from pcs.lab_claims
   where lab_number=C_lab_number and claim_id=C_claim_id;
   select count(*) into in_queue from pcs.billing_queue
   where lab_number=C_lab_number;

   if (in_queue>0) then
      RAISE E_in_queue;
   elsif (BD_claim_id<>C_claim_id) then
      RAISE E_invalid_claim;
   else
      if (C_claim_status IN ('P','PP','P2','SU','S')) then
	 RAISE E_invalid_status;
      end if;
   end if;

   update pcs.lab_requisitions set finished=3
   where lab_number=C_lab_number;
   update pcs.lab_claims set claim_status='S'
   where lab_number=C_lab_number and claim_id=C_claim_id;
   commit;

exception
   when E_invalid_claim then
      RAISE_APPLICATION_ERROR(-20170,'CURRENT BILLING NOT AT CLAIM LEVEL');
   when E_invalid_status then
      RAISE_APPLICATION_ERROR(-20171,'CLAIM STATUS ['||C_claim_status||'] CANNOT BE RESET'
);

   when E_in_queue then
      RAISE_APPLICATION_ERROR(-20172,'CANNOT RESET LAB IN BILLING QUEUE');
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sy
s_user)

      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;

end;
\
grant execute on reset_claim_status to pcs_user
\