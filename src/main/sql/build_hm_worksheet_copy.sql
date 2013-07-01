create or replace procedure     build_hm_worksheet_copy
(
   start_lab in number,
   end_lab in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   cursor lab_list is
      select patient,lab_number,practice from pcs.lab_requisitions
      where lab_number>=start_lab and lab_number<=end_lab;

   L_lab number;
   L_patient number;
   L_practice number;

   COPY_MODE constant number := 1;
   FILE_NAME constant varchar2(64) := 'copy_wks';
   SERVER_DIR constant varchar2(64) := 'REPORTS_DIR';


begin

   P_proc_name:='BUILD_HM_WORKSHEET_COPY';
   P_code_area:='PREP';
   L_lab:=0;

   if (start_lab IS NULL OR end_lab IS NULL) then
      goto exit_point;
   elsif (start_lab>end_lab) then
      goto exit_point;
   end if;

   P_code_area:='LAB_LIST';
   L_lab:=0;
   open lab_list;
   loop
      fetch lab_list into L_patient,L_lab,L_practice;
      exit when lab_list%NOTFOUND;
      pcs.get_patient_history(L_patient,L_lab,L_practice,COPY_MODE);
   end loop;
   close lab_list;

   pcs.build_hm_worksheets(COPY_MODE,FILE_NAME, SERVER_DIR);

   <<exit_point>>
   commit;

exception
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      delete from pcs.history_match_queue where printed=COPY_MODE;
      insert into pcs.error_log
	 (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values
	 (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_lab);
      commit;
      RAISE;

end;
\

grant execute on pcs.build_hm_worksheets to pcs_user
\
