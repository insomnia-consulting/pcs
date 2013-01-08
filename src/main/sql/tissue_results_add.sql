create or replace procedure tissue_results_add
(
   R_lab_number in number,
   R_date_completed in varchar2,   /* date verified */
   R_cytotech in number,	   /* verifying tech */
   R_path_date in varchar2,
   R_path_init in varchar2
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);

   P_code_area varchar2(32);

   D_date_completed date;
   D_path_date date;
   R_pap_class number;

begin

      P_proc_name:='TISSUE_RESULTS_ADD';

      /* pap class category needed; not really a category;
	 this value assigned for TISSUE PATHOLOGY.
      */

      R_pap_class:=17;

      P_code_area:='INSERT';
      commit;
      set transaction use rollback segment pcs_rbs1;
      D_date_completed:=TO_DATE(R_date_completed,'MMDDYYYY');
      insert into pcs.lab_results
	 (lab_number,date_completed,cytotech,pathologist,qc_status,
	  first_print,datestamp,sys_user,path_status,pap_class,biopsy_code,
	  limited,change_date,change_user)
      values
	 (R_lab_number,D_date_completed,R_cytotech,R_path_init,'N',
	  0,SysDate,UID,'Y',R_pap_class,NULL,0,SysDate,UID);

      P_code_area:='PATH';
      D_path_date:=TO_DATE(R_path_date,'MMDDYYYY');
      insert into pcs.pathologist_control (lab_number,path_date,pathologist_code)
      values (R_lab_number,D_path_date,R_path_init);
      /*
	 Value of finished = 1 indicates results have been entered
      */
      update pcs.lab_requisitions set finished=1 where lab_number=R_lab_number;
      commit;

exception
   when OTHERS then
      P_error_code:=SQLCODE;

      P_error_message:=SQLERRM;
      insert into pcs.error_log
	(error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values
	(P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,R_lab_number);
      commit;
      RAISE;

end;	
\

grant execute on tissue_results_add to pcs_user
\
