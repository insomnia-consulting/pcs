create or replace
procedure     lab_results_add
(
   R_lab_number in number,
   R_date_completed in varchar2,
   R_cytotech in number,
   R_pathologist in char,
   R_comment_text in varchar2,
   R_lab_comments in varchar2,
   R_qc_status in char,
   R_qc_date in varchar2,
   R_qc_cytotech in number,
   R_super in number,
   R_inter in number,
   R_para in number,
   R_print_flag in number,
   R_path_status in char,
   R_path_date in varchar2,
   R_path_init in varchar2,
   R_class in number,
   R_bcode in varchar2,
   R_limited in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   D_date_completed date;
   D_qc_date date;
   D_path_date date;
   r_cnt integer;
   mi_test number;
   tech_code varchar2(3);
   R_pap_class number;

begin
  set transaction use rollback segment pcs_rbs1;
  begin
    P_proc_name:='LAB_RESULTS_ADD';
    if (R_bcode is NOT NULL) then
       select papclass into R_pap_class from pcs.bethesda_codes
       where bethesda_code=R_bcode;
    else
       R_pap_class:=R_class;
    end if;
  exception
    when OTHERS then
      rollback;
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;
  end;
  begin
    P_code_area:='INSERT';
    commit;
    D_date_completed:=TO_DATE(R_date_completed,'MMDDYYYY');
    mi_test:=R_super+R_inter+R_para;
    insert into pcs.lab_results
       (lab_number,date_completed,cytotech,pathologist,qc_status,
        first_print,datestamp,sys_user,path_status,pap_class,biopsy_code,
        limited,change_date,change_user)
    values
       (R_lab_number,D_date_completed,R_cytotech,R_pathologist,R_qc_status,
        R_print_flag,SysDate,UID,R_path_status,R_pap_class,R_bcode,R_limited,
        SysDate,UID);
    if (R_comment_text is not null)
    then
       P_code_area:='REPT COMMENTS';
       insert into pcs.lab_result_comments
          (lab_number,comment_text)
       values
          (R_lab_number,R_comment_text);
    end if;
  exception
    when OTHERS then
      rollback;
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;
  end;
    /*
    if (R_lab_comments is not null)
    then
       P_code_area:='COMMENTS';
       select count(*) into r_cnt from pcs.lab_req_comments
       where lab_number=R_lab_number;
       if (r_cnt>0)
       then
          update pcs.lab_req_comments
          set comment_text=R_lab_comments
          where lab_number=R_lab_number;
       else
          insert into pcs.lab_req_comments values (R_lab_number,R_lab_comments);
       end if;
    end if;
    */
  begin
    if (R_qc_status='Y')
    then
       P_code_area:='QC';
       D_qc_date:=TO_DATE(R_qc_date,'MMDDYYYY');
       insert into pcs.quality_control
          (qc_id,lab_number,qc_date,cytotech)
       values
          (pcs.qc_seq.nextval,R_lab_number,D_qc_date,R_qc_cytotech);
    end if;
    if (R_path_status='Y')
    then
       P_code_area:='PATH';
       D_path_date:=TO_DATE(R_path_date,'MMDDYYYY');
       insert into pcs.pathologist_control (lab_number,path_date,pathologist_code)
       values (R_lab_number,D_path_date,R_path_init);
    end if;
  exception
    when OTHERS then
      rollback;
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;
  end;
  begin
    P_code_area:='MI';
    if (mi_test>0)
    then
       insert into pcs.lab_mat_index
          (lab_number,superficial,intermediate,parabasal)
       values
          (R_lab_number,R_super,R_inter,R_para);
    elsif (mi_test<0)
    then
       delete from pcs.lab_req_details
       where lab_number=R_lab_number and detail_code=12;
    end if;
  exception
    when OTHERS then
      rollback;
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;
  end;
  begin
    P_code_area:='PRINT FLAG';
    if (R_print_flag>0)
    then
       insert into pcs.cytopath_print_queue values (R_lab_number,R_print_flag);
       /*
          print flag of one signifies draft print for cytopath rept.;
          the final print is waiting for pathologist signature
       */
       if ((R_print_flag=1) and (R_pathologist is not null))
       then
          insert into pcs.pathologist_holds
             (lab_number,pathologist_code,submitted)
          values
             (R_lab_number,R_pathologist,SysDate);
       end if;
    end if;
  exception
    when OTHERS then
      rollback;
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;
  end;
    /*
       Value of finished = 1 indicates results have been entered
    */
  begin
    update pcs.lab_requisitions set finished=1 where lab_number=R_lab_number;
  exception
    when OTHERS then
      rollback;
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
      commit;
      RAISE;
  end;
  commit;
exception
  when OTHERS then
    rollback;
    P_error_code:=SQLCODE;
    P_error_message:=SQLERRM;
    insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)
    values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);
    commit;
    RAISE;
end;

