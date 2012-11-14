                                       
procedure     daily_jobs_TEST                                                                                                                                                       
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        

                                                                                                                                                                                    
   S_month number;                                                                                                                                                                  
   S_day number;                                                                                                                                                                    
   j_rec_num number;                                                                                                                                                                
   day_of_week varchar2(16);                                                                                                                                                        
   curr_line varchar2(128);                                                                                                                                                         
   date_today varchar2(128);                                                                                                                                                        
   procedure_begin varchar2(128);                                                                                                                                                   
   procedure_end varchar2(128);                                                                                                                                                     
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   rcnt number;                                                                                                                                                                     
   job_indicator number;                                                                                                                                                            
   job_prior number;                                                                                                                                                                

   mid_month_billing number;                                                                                                                                                        
   this_date number;                                                                                                                                                                
   run_EOM number;                                                                                                                                                                  
   EOM_mode number;                                                                                                                                                                 
   summary_mode number;                                                                                                                                                             
                                                                                                                                                                                    
   job_date_text1 varchar2(16);                                                                                                                                                     
                                                                                                                                                                                    
   cbuf1 varchar2(16);                                                                                                                                                              
   tmp_num1 number;                                                                                                                                                                 
                                                                                                                                                                                    
   min_lab_number number;                                                                                                                                                           
   max_lab_number number;                                                                                                                                                           

   next_purge_date date;                                                                                                                                                            
   purge_date number;                                                                                                                                                               
   purge_count number;                                                                                                                                                              
   purge_MMDD varchar2(4);                                                                                                                                                          
   purge_YYYY varchar2(4);                                                                                                                                                          
                                                                                                                                                                                    
   cursor db_space is                                                                                                                                                               
      select RPAD(SUBSTR(tablespace_name,1,20),22),                                                                                                                                 
         LPAD(TO_CHAR(sum(bytes/(1024*1024)),'99990.00'),10)                                                                                                                        
      from sys.dba_free_space group by tablespace_name;                                                                                                                             
   t_name varchar2(32);                                                                                                                                                             
   t_left varchar2(32);                                                                                                                                                             
                                                                                                                                                                                    

begin                                                                                                                                                                               
                                                                                                                                                                                    
   commit;                                                                                                                                                                          
   set transaction use rollback segment pcs_rbs1;                                                                                                                                   
                                                                                                                                                                                    
   /* indicates the which state the daily jobs program is in:                                                                                                                       
      (0)  daily job program is currently running                                                                                                                                   
      (1)  last run of daily job program completed successfully                                                                                                                     
      (-1) last run of daily job program ended in error                                                                                                                             
   */                                                                                                                                                                               
   select job_status into job_prior from job_control where job_descr='JOB_STATUS';                                                                                                  
   if job_prior=(-1) then                                                                                                                                                           
      /* an error will cause main application message to change the next day;                                                                                                       

         hence the next night reset the message to the default message                                                                                                              
      */                                                                                                                                                                            
      update business_info set                                                                                                                                                      
         current_message='HAVE A NICE DAY!',                                                                                                                                        
         message_foreground=-1, message_background=-16777038;                                                                                                                       
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   /* j_rec_num is the actual day the the daily job program runs;                                                                                                                   
      this value is held in the table pcs.daily_job_record to indicate                                                                                                              
      the jobs ran for that day; this check ensures that the program                                                                                                                
      runs only once for each day                                                                                                                                                   
   */                                                                                                                                                                               
   /*                                                                                                                                                                               

   select TO_NUMBER(TO_CHAR(SysDate,'YYYYMMDD')) into j_rec_num from dual;                                                                                                          
   select count(*) into rcnt from pcs.daily_job_record                                                                                                                              
   where j_rec_number=j_rec_num;                                                                                                                                                    
   if (rcnt>0) then                                                                                                                                                                 
      goto exit_point;                                                                                                                                                              
   end if;                                                                                                                                                                          
   */                                                                                                                                                                               
                                                                                                                                                                                    
   /* open log file */                                                                                                                                                              
   file_handle:=UTL_FILE.FOPEN('vol1:','dailyjob.log','a');                                                                                                                         
                                                                                                                                                                                    
   P_code_area:='HEADER';                                                                                                                                                           
                                                                                                                                                                                    

   /* throughout program date_today records date and time and curr_line formats                                                                                                     
      message in log; used to track time it takes the various programs to run                                                                                                       
   */                                                                                                                                                                               
   select TO_CHAR(SysDate-1,'MM/DD/YYYY HH24:Mi:SS') into date_today from dual;                                                                                                     
   select rtrim(to_char(SysDate,'DAY')) into day_of_week from dual;                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',day_of_week);                                                                                                                                   
   curr_line:='DAILY JOB LOG - LOGIC TEST: '||date_today;                                                                                                                           
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
                                                                                                                                                                                    
   /* if the jobs are set to not run for THIS day (3); or to not run at                                                                                                             
      all for any day (2) then exit                                                                                                                                                 
   */                                                                                                                                                                               
   if (job_prior=2 or job_prior=3) then                                                                                                                                             

      goto exit_point;                                                                                                                                                              
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   /* indicates daily jobs are now running; will block users from                                                                                                                   
      getting into the system                                                                                                                                                       
   */                                                                                                                                                                               
   /*                                                                                                                                                                               
   update pcs.job_control set job_status=0 where job_descr='JOB_STATUS';                                                                                                            
   commit;                                                                                                                                                                          
   */                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='DAILY_JOBS_TEST';                                                                                                                                                  
   P_code_area:='PREP - LOGIC TEST';                                                                                                                                                

                                                                                                                                                                                    
   /* job_indicator identifies whether the job is running:                                                                                                                          
      (1) on a week day (Mon-Fri)                                                                                                                                                   
      (2) on a weekend day (Sat-Sun)                                                                                                                                                
      (3) on the last day (End Of Month)                                                                                                                                            
   */                                                                                                                                                                               
                                                                                                                                                                                    
                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
   /* TASKS THAT ARE RAN EVERY DAY                                              */                                                                                                  
   /*****************************************************************************/                                                                                                  
   job_indicator:=1;                                                                                                                                                                
                                                                                                                                                                                    

   /* the day the job is running for (yesterday) */                                                                                                                                 
   select TO_CHAR(SysDate-1,'YYYYMMDD') into S_day from dual;                                                                                                                       
   /* current day and time */                                                                                                                                                       
   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
                                                                                                                                                                                    
   /*                                                                                                                                                                               
   P_code_area:='RECEIVE DATES';                                                                                                                                                    
   curr_line:='UPDATING REQ RECEIVE DATES: '||date_today;                                                                                                                           
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   pcs.update_receive_dates;                                                                                                                                                        
   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
                                                                                                                                                                                    
   P_code_area:='POST PAYMENTS';                                                                                                                                                    

   curr_line:='POSTING PAYMENTS: '||date_today;                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   pcs.post_payments;                                                                                                                                                               
   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
                                                                                                                                                                                    
   P_code_area:='PATIENT ACCOUNT';                                                                                                                                                  
   curr_line:='UPDATING PATIENT ACCOUNTS: '||date_today;                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   pcs.patient_account_update;                                                                                                                                                      
   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
                                                                                                                                                                                    
   P_code_area:='NMN';                                                                                                                                                              
   curr_line:='UPDATING MEDICARE NMN LETTERS: '||date_today;                                                                                                                        

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   pcs.nmn_letter_update;                                                                                                                                                           
   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
                                                                                                                                                                                    
   P_code_area:='SPACE';                                                                                                                                                            
   curr_line:='DATABASE FREE SPACE: '||date_today;                                                                                                                                  
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   open db_space;                                                                                                                                                                   
   loop                                                                                                                                                                             
      fetch db_space into t_name,t_left;                                                                                                                                            
      exit when db_space%NOTFOUND;                                                                                                                                                  
      curr_line:=t_name||t_left;                                                                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

   end loop;                                                                                                                                                                        
   close db_space;                                                                                                                                                                  
   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
   */                                                                                                                                                                               
                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
                                                                                                                                                                                    
                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
   /* CREATE A DAILY REPORT ON TUE-SAT FOR MON-FRI                              */                                                                                                  
   /*****************************************************************************/                                                                                                  
   if ((RTRIM(day_of_week)<>'SUNDAY') AND (RTRIM(day_of_week)<>'MONDAY')) then                                                                                                      
      curr_line:='   ENTERED DAILY REPORT SECTION';                                                                                                                                 

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
      P_code_area:='DAILY REPT';                                                                                                                                                    
      curr_line:='CREATING DAILY REPORT: '||date_today;                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_daily_report_file(S_day);                                                                                                                                           
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      */                                                                                                                                                                            
   end if;                                                                                                                                                                          
   /*****************************************************************************/                                                                                                  
                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
   /* TASKS THAT ARE RAN ONLY ONCE PER WEEK                                     */                                                                                                  

   /*****************************************************************************/                                                                                                  
   if (RTRIM(day_of_week)='SUNDAY') then                                                                                                                                            
      curr_line:='   ENTERED WEEKLY TASKS SECTION';                                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
      job_indicator:=2;                                                                                                                                                             
      P_code_area:='WEEKLY MAINT';                                                                                                                                                  
      curr_line:='* * * WEEKLY MAINTENANCE - ANALYZE SCHEMA * * *';                                                                                                                 
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='BEGIN: '||date_today;                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      DBMS_UTILITY.ANALYZE_SCHEMA('pcs','COMPUTE');                                                                                                                                 

   elsif (RTRIM(day_of_week)='SATURDAY') then                                                                                                                                       
      job_indicator:=2;                                                                                                                                                             
      P_code_area:='CLAIM REPORT';                                                                                                                                                  
      curr_line:='NO RESPONSE CLAIM REPORT';                                                                                                                                        
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='BEGIN: '||date_today;                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.process_no_response_claims;                                                                                                                                               
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      */                                                                                                                                                                            
   end if;                                                                                                                                                                          

                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
   /* TASKS THAT ARE RAN FOR MID-MONTH BILLING                                  */                                                                                                  
   /*****************************************************************************/                                                                                                  
   select job_status into mid_month_billing                                                                                                                                         
   from pcs.job_control where job_descr='MID MONTH';                                                                                                                                
   if (mid_month_billing=1) then                                                                                                                                                    
      curr_line:='   ENTERED MID-MONTH BILLING TASKS SECTION';                                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
      job_indicator:=4;                                                                                                                                                             

      P_code_area:='MID MONTH';                                                                                                                                                     
      curr_line:='* * * R U N N I N G   M I D - M O N T H   B I L L I N G * * *';                                                                                                   
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
      select TO_CHAR(SysDate,'YYYYMM') into S_month from dual;                                                                                                                      
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='BEGIN: '||date_today;                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='EXTRACTING MID-MONTH DATA: '||date_today;                                                                                                                         
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.practices_mid(S_month);                                                                                                                                                   
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='ADPH SUMMARY FILE: '||date_today;                                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

      pcs.build_ADPH_summary_file(S_month,1);                                                                                                                                       
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='ADPH INVOICE SUMMARY FILE: '||date_today;                                                                                                                         
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_ADPH_invoice_summ_file(S_month,1);                                                                                                                                  
      */                                                                                                                                                                            
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
   /* TASKS THAT ARE RAN ONLY ONCE PER MONTH                                    */                                                                                                  
   /*****************************************************************************/                                                                                                  
   this_date:=TO_NUMBER(TO_CHAR(SysDate,'YYYYMMDD'));                                                                                                                               
   run_EOM:=is_EOM(this_date);                                                                                                                                                      

   S_month:=0;                                                                                                                                                                      
   if (run_EOM=1) then                                                                                                                                                              
                                                                                                                                                                                    
      curr_line:='   ENTERED MONTHLY TASKS SECTION';                                                                                                                                
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      job_indicator:=3;                                                                                                                                                             
      select job_status into S_month                                                                                                                                                
      from pcs.job_control                                                                                                                                                          
      where job_descr='S_MONTH';                                                                                                                                                    
      select job_status into EOM_mode                                                                                                                                               
      from pcs.job_control                                                                                                                                                          
      where job_descr='EOM_MODE';                                                                                                                                                   

      update pcs.job_control                                                                                                                                                        
      set job_status=EOM_mode                                                                                                                                                       
      where job_descr='SUMMARY_MODE';                                                                                                                                               
      commit;                                                                                                                                                                       
                                                                                                                                                                                    
      /*                                                                                                                                                                            
      delete from pcs.billing_queue_save;                                                                                                                                           
      insert into pcs.billing_queue_save select * from billing_queue;                                                                                                               
      commit;                                                                                                                                                                       
      */                                                                                                                                                                            
                                                                                                                                                                                    
      curr_line:='      MONTHLY JOB_CONTROL PARAMS:';                                                                                                                               
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

      curr_line:='      S_MONTH == '||S_month;                                                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='      EOM_MODE == '||EOM_mode;                                                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
                                                                                                                                                                                    
      P_code_area:='EOM';                                                                                                                                                           
      curr_line:=                                                                                                                                                                   
         '* * * R U N N I N G   E N D   O F   M O N T H   L O G I C   T E S T * * *';                                                                                               
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
      select TO_CHAR(SysDate,'DAY MM/DD/YYYY HH:Mi:SS') into date_today from dual;                                                                                                  
      curr_line:='BEGIN TEST: '||date_today;                                                                                                                                        
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                

                                                                                                                                                                                    
      /*                                                                                                                                                                            
      P_code_area:='EOM.PRACTICES_EOM';                                                                                                                                             
      curr_line:='CLOSING DOCTOR ACCOUNTS: ';                                                                                                                                       
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.practices_eom(S_month);                                                                                                                                                   
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.EOM_SUMMARY';                                                                                                                                               
      curr_line:='SUMMARY OF BILLING TYPES: ';                                                                                                                                      
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            

      pcs.build_eom_summary_file(S_month);                                                                                                                                          
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.UNSATISFACTORY';                                                                                                                                            
      curr_line:='UNSATISFACTORY PAP SMEARS: ';                                                                                                                                     
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_unsatisfactory_file(S_month);                                                                                                                                       
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    

      P_code_area:='EOM.BIOPSY';                                                                                                                                                    
      curr_line:='BIOPSY FILES: ';                                                                                                                                                  
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_biopsy_files(S_month);                                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.CYTOTECH_SUMMARY';                                                                                                                                          
      curr_line:='CYTOTECH SUMMARY: ';                                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_cytotech_summary_file(S_month);                                                                                                                                     
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              

      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.PATHOLOGIST_SUMMARY';                                                                                                                                       
      curr_line:='PATH0LOGIST SUMMARY: ';                                                                                                                                           
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_pathologist_summary_file(S_month);                                                                                                                                  
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.CLINIC_CASES';                                                                                                                                              
      curr_line:='CLINIC CASES FILE: ';                                                                                                                                             

      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_clinic_cases_file(S_month);                                                                                                                                         
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.AGREE_FILE';                                                                                                                                                
      curr_line:='CT/PATH AGREE FILE: ';                                                                                                                                            
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_agree_file(S_month);                                                                                                                                                
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

                                                                                                                                                                                    
      curr_line:='**********ADPH PROGRAMS**********';                                                                                                                               
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                                
                                                                                                                                                                                    
      P_code_area:='EOM.ADPH.SUMMARY';                                                                                                                                              
      curr_line:='ADPH SUMMARY FILE: ';                                                                                                                                             
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_ADPH_summary_file(S_month,2);                                                                                                                                       
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.ADPH.INVOICE_SUMM';                                                                                                                                         

      curr_line:='ADPH INVOICE SUMMARY FILE: ';                                                                                                                                     
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_ADPH_invoice_summ_file(S_month,2);                                                                                                                                  
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.ADPH.ABNORMAL';                                                                                                                                             
      curr_line:='ADPH SUMMARY OF ABNORMALS: ';                                                                                                                                     
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_ADPH_abnormal_file(S_month);                                                                                                                                        
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.ADPH.ASCH';                                                                                                                                                 
      curr_line:='ADPH ASC-H/HPV RESULTS: ';                                                                                                                                        
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_ADPH_ASCH_file(S_month);                                                                                                                                            
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.ADPH.851';                                                                                                                                                  
      curr_line:='ADPH 851 RESULTS: ';                                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            

      pcs.build_ADPH_851_file(S_month);                                                                                                                                             
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.ADPH.NP_FILE';                                                                                                                                              
      curr_line:='ADPH NO PROGRAM FILE: ';                                                                                                                                          
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      cbuf1:=TO_CHAR(TO_DATE(TO_CHAR(S_month),'YYYYMM'),'MMDDYYYY');                                                                                                                
      pcs.build_ADPH_np_file(cbuf1,NULL);                                                                                                                                           
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

                                                                                                                                                                                    
      curr_line:='***********WV PROGRAMS***********';                                                                                                                               
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                                
                                                                                                                                                                                    
      P_code_area:='EOM.WV.FPP.INV_SUMM_1';                                                                                                                                         
      curr_line:='FPP INVOICE SUMMARY FILE: ';                                                                                                                                      
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_WV_invoice_summary_1(S_month,2,'FPP');                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.WV.BCCSP.INV_SUMM_1';                                                                                                                                       

      curr_line:='BCCSP INVOICE SUMMARY FILE: ';                                                                                                                                    
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_WV_invoice_summary_1(S_month,2,'BCCSP');                                                                                                                            
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.WV.FPP.INV_SUMM_9';                                                                                                                                         
      curr_line:='FPP INVOICE SUMMARY FILE, PCS OFFICE COPY: ';                                                                                                                     
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_WV_invoice_summary_9(S_month,2,'FPP');                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
                                                                                                                                                                                    
      P_code_area:='EOM.WV.BCCSP.INV_SUMM_9';                                                                                                                                       
      curr_line:='BCCSP INVOICE SUMMARY FILE, PCS OFFICE COPY: ';                                                                                                                   
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_begin from dual;                                                                                                            
      pcs.build_WV_invoice_summary_9(S_month,2,'BCCSP');                                                                                                                            
      select TO_CHAR(SysDate,'HH:Mi:SS') into procedure_end from dual;                                                                                                              
      curr_line:=curr_line||procedure_begin||' to '||procedure_end;                                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
                                                                                                                                                                                    
      select MAX(a.lab_number) into rcnt                                                                                                                                            
      from pcs.lab_results a, pcs.lab_requisitions b                                                                                                                                

      where TO_NUMBER(TO_CHAR(a.datestamp,'YYYYMM'))=S_month                                                                                                                        
      and a.lab_number=b.lab_number and b.preparation<5;                                                                                                                            
      update pcs.job_control set job_status=rcnt                                                                                                                                    
      where job_descr='MONTH STARTING';                                                                                                                                             
      commit;                                                                                                                                                                       
      */                                                                                                                                                                            
      curr_line:='* * * * * I N I T I A L I Z I N G   N E X T   E O M * * * * *';                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='LOGIC TEST - MAKE SURE TABLE VALUES ARE RESET!';                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.init_next_EOM(S_month);                                                                                                                                                   
                                                                                                                                                                                    
   end if;                                                                                                                                                                          

                                                                                                                                                                                    
   select job_status into summary_mode                                                                                                                                              
   from pcs.job_control                                                                                                                                                             
   where job_descr='SUMMARY_MODE';                                                                                                                                                  
   curr_line:='   SUMMARY_MODE == '||summary_mode;                                                                                                                                  
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   if (summary_mode>=0) then                                                                                                                                                        
      curr_line:='   ENTERED SUMMARIES SECTION';                                                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      select TO_CHAR(SysDate,'DAY MM/DD/YYYY HH:Mi:SS') into date_today from dual;                                                                                                  
      curr_line:='BEGIN: '||date_today;                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='RUNNING ';                                                                                                                                                        

      if (summary_mode=0) then                                                                                                                                                      
         curr_line:=curr_line||'ALL ACCOUNTS';                                                                                                                                      
      elsif (summary_mode=1) then                                                                                                                                                   
         curr_line:=curr_line||'FIRST HALF OF ACCOUNTS';                                                                                                                            
      elsif (summary_mode>1) then                                                                                                                                                   
         curr_line:=curr_line||'SECOND HALF OF ACCOUNTS';                                                                                                                           
      end if;                                                                                                                                                                       
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
      pcs.generate_summaries(S_month,summary_mode);                                                                                                                                 
      select TO_CHAR(SysDate,'DAY MM/DD/YYYY HH:Mi:SS') into date_today from dual;                                                                                                  
      curr_line:='END: '||date_today;                                                                                                                                               
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

      */                                                                                                                                                                            
      curr_line:='* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *';                                                                                                 
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   if (S_month>0) then                                                                                                                                                              
      select TO_CHAR(SysDate,'DAY MM/DD/YYYY HH:Mi:SS') into date_today from dual;                                                                                                  
      curr_line:='END TEST: '||date_today;                                                                                                                                          
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='* * * * * * * * * * * * * * * * * * * * * * * * * *';                                                                                                             
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
      select TO_CHAR(SysDate,'DAY MM/DD/YYYY HH:Mi:SS') into date_today from dual;                                                                                                  
   end if;                                                                                                                                                                          

                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
   /* PURGE OLD DATA                                                            */                                                                                                  
   /*****************************************************************************/                                                                                                  
   /*                                                                                                                                                                               
   P_code_area:='PURGE';                                                                                                                                                            
   select job_status into min_lab_number                                                                                                                                            
   from pcs.job_control where job_descr='PURGE';                                                                                                                                    
   select job_status into purge_date                                                                                                                                                
   from pcs.job_control where job_descr='PURGE DATE';                                                                                                                               
   select to_date(to_char(purge_date),'YYYYMMDD')+1 into next_purge_date from dual;                                                                                                 
   purge_date:=TO_NUMBER(TO_CHAR(next_purge_date,'YYYYMMDD'));                                                                                                                      
   update pcs.job_control set job_status=purge_date where job_descr='PURGE DATE';                                                                                                   

   purge_count:=pcs.get_purge_count;                                                                                                                                                
   cbuf1:=RTRIM(LTRIM(TO_CHAR(purge_date)));                                                                                                                                        
   purge_MMDD:=SUBSTR(cbuf1,5);                                                                                                                                                     
   purge_YYYY:=SUBSTR(cbuf1,1,4);                                                                                                                                                   
   curr_line:='*************** DATA PURGE ***************';                                                                                                                         
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                                   
   curr_line:='CURRENT DOS PURGE DATE: ['||purge_date||']';                                                                                                                         
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                                   
   */                                                                                                                                                                               
   /*  If the purge date is Dec. 31 and the count of data to                                                                                                                        
       purge is 0, then set the count to 1 to force the                                                                                                                             
       data purge.                                                                                                                                                                  
       If the purge date is Jan. 1, then assume no DOS for                                                                                                                          

       that date since holiday; set the count to 1 to force                                                                                                                         
       the purge block so that the minimum lab number gets                                                                                                                          
       reset to 1 for the next year.                                                                                                                                                
   */                                                                                                                                                                               
   /*                                                                                                                                                                               
   if (purge_MMDD='1231' AND purge_count=0) then                                                                                                                                    
      purge_count:=1;                                                                                                                                                               
      curr_line:='DATA PURGE FORCED FOR DECEMBER 31,'||purge_YYYY;                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='BECAUSE NO LABS FOR THIS DATE OF SERVCE';                                                                                                                         
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   elsif (purge_MMDD='0101') then                                                                                                                                                   
      purge_count:=1;                                                                                                                                                               

      min_lab_number:=TO_NUMBER(purge_YYYY||'000000');                                                                                                                              
      curr_line:='MINIMUM LAB BEING RESET FOR NEXT PURGE YEAR: '||purge_YYYY;                                                                                                       
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end if;                                                                                                                                                                          
   if (purge_count>0) then                                                                                                                                                          
      curr_line:='OLD DATA LOCATED FOR DOS:  PURGE COUNT = ['||                                                                                                                     
         RTRIM(LTRIM(TO_CHAR(purge_count)))||']';                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   */                                                                                                                                                                               
      /*  If the purge date is Dec. 31, then select the highest                                                                                                                     
          lab number for that year so that any stragglers                                                                                                                           
          are deleted for the end of that purge year.                                                                                                                               
      */                                                                                                                                                                            

   /*                                                                                                                                                                               
      if (purge_MMDD='1231') then                                                                                                                                                   
         tmp_num1:=TO_NUMBER(purge_YYYY||'999999');                                                                                                                                 
         select MAX(lab_number) into max_lab_number                                                                                                                                 
         from lab_requisitions                                                                                                                                                      
         where lab_number<=tmp_num1;                                                                                                                                                
      else                                                                                                                                                                          
         max_lab_number:=min_lab_number+purge_count;                                                                                                                                
      end if;                                                                                                                                                                       
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:=TO_CHAR(min_lab_number)||' TO '||TO_CHAR(max_lab_number);                                                                                                          
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='BEGIN DATA_PURGE STORED PROCEDURE: '||date_today;                                                                                                                 

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   else                                                                                                                                                                             
      curr_line:='DATA PURGE UP TO DATE - NO ACTION TAKEN.';                                                                                                                        
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end if;                                                                                                                                                                          
   */                                                                                                                                                                               
   /* Whether there is data to purge or not the procedure is called;                                                                                                                
      if no data is delete, then all the procedure does is updates                                                                                                                  
      to next date to check in the control table.                                                                                                                                   
   */                                                                                                                                                                               
   /*                                                                                                                                                                               
   pcs.data_purge;                                                                                                                                                                  
   if (purge_count>0) then                                                                                                                                                          

      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='END DATA_PURGE STORED PROCEDURE: '||date_today;                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end if;                                                                                                                                                                          
   */                                                                                                                                                                               
   /*****************************************************************************/                                                                                                  
                                                                                                                                                                                    
                                                                                                                                                                                    
   /*****************************************************************************/                                                                                                  
   /* TASKS THAT ARE RAN ONLY IF A SPECIAL FLAG IS SET                          */                                                                                                  
   /* Code must be modified on an as needed basis                               */                                                                                                  
   /*****************************************************************************/                                                                                                  
   rcnt:=0;                                                                                                                                                                         

   tmp_num1:=0;                                                                                                                                                                     
   select job_status into rcnt from pcs.job_control where job_descr='SPECIAL';                                                                                                      
   if (rcnt=1) then                                                                                                                                                                 
      P_code_area:='SPECIAL';                                                                                                                                                       
      S_month:=NULL;                                                                                                                                                                
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='BEGIN SPECIAL: '||date_today;                                                                                                                                     
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      update pcs.job_control set job_status=0 where job_descr='SPECIAL';                                                                                                            
      commit;                                                                                                                                                                       
      /* INSERT CODE TO RUN HERE *************************************************/                                                                                                 
      /***************************************************************************/                                                                                                 
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 

      curr_line:='END SPECIAL: '||date_today;                                                                                                                                       
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   /*                                                                                                                                                                               
   P_code_area:='RECALCS';                                                                                                                                                          
   pcs.recalculate_month;                                                                                                                                                           
   */                                                                                                                                                                               
                                                                                                                                                                                    
   /* Insert the current day job ran into record table that stops                                                                                                                   
      daily_jobs from running more than once. After current day is                                                                                                                  
      inserted into table, delete old values since they do not need                                                                                                                 
      to be in table; in essence, this is a very simple table that                                                                                                                  

      will only ever hold one or two rows.                                                                                                                                          
   */                                                                                                                                                                               
   /*                                                                                                                                                                               
   insert into pcs.daily_job_record (j_rec_number) values (j_rec_num);                                                                                                              
   delete from pcs.daily_job_record where j_rec_number<j_rec_num;                                                                                                                   
   */                                                                                                                                                                               
                                                                                                                                                                                    
   <<exit_point>>                                                                                                                                                                   
   commit;                                                                                                                                                                          
                                                                                                                                                                                    
   P_code_area:='END';                                                                                                                                                              
   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
                                                                                                                                                                                    

   curr_line:='END DAILY JOBS LOGIC TEST: '||date_today;                                                                                                                            
   UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                                 
   curr_line:='------------------------------------'||                                                                                                                              
      '-------------------------------------------';                                                                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
                                                                                                                                                                                    
   /*                                                                                                                                                                               
   set transaction use rollback segment pcs_rbs1;                                                                                                                                   
   update pcs.job_control set job_status=1                                                                                                                                          
   where job_descr='JOB_STATUS' and job_status<>2;                                                                                                                                  
   commit;                                                                                                                                                                          
   */                                                                                                                                                                               
                                                                                                                                                                                    

   /*                                                                                                                                                                               
   select RTRIM(LTRIM(TO_CHAR(SysDate,'MMDD'))) into job_date_text1 from dual;                                                                                                      
   if (job_date_text1='0806') then                                                                                                                                                  
      update business_info set                                                                                                                                                      
         current_message='HAPPY BIRTHDAY JOHN CARDELLA - AUGUST 6, 1961!!!!!',                                                                                                      
         message_foreground=-65536, message_background=-16777216;                                                                                                                   
   elsif (job_date_text1='0102') then                                                                                                                                               
      update business_info set                                                                                                                                                      
         current_message='HAPPY BIRTHDAY COLENE - JANUARY 2!!!!!',                                                                                                                  
         message_foreground=-65536, message_background=-16777216;                                                                                                                   
   elsif (job_date_text1='0410') then                                                                                                                                               
      update business_info set                                                                                                                                                      
         current_message='HAPPY BIRTHDAY PENNY - APRIL 10!!!!!',                                                                                                                    

         message_foreground=-65536, message_background=-16777216;                                                                                                                   
   elsif (job_date_text1='1023') then                                                                                                                                               
      update business_info set                                                                                                                                                      
         current_message='HAPPY BIRTHDAY AMY - OCTOBER 23!!!!!',                                                                                                                    
         message_foreground=-65536, message_background=-16777216;                                                                                                                   
   elsif (job_date_text1='1014') then                                                                                                                                               
      update business_info set                                                                                                                                                      
         current_message='HAPPY BIRTHDAY JOSEPHINE - OCTOBER 14!!!!!',                                                                                                              
         message_foreground=-65536, message_background=-16777216;                                                                                                                   
   elsif (job_date_text1='1107') then                                                                                                                                               
      update business_info set                                                                                                                                                      
         current_message='HAPPY BIRTHDAY LISA - NOVEMBER 7!!!!!',                                                                                                                   
         message_foreground=-65536, message_background=-16777216;                                                                                                                   

   elsif (job_date_text1='0308') then                                                                                                                                               
      update business_info set                                                                                                                                                      
         current_message='HAPPY BIRTHDAY ZELDA, MATTHEW AND QUASI - MARCH 8, 2009!!!!!',                                                                                            
         message_foreground=-65536, message_background=-16777216;                                                                                                                   
   elsif (job_date_text1='0704') then                                                                                                                                               
      update business_info set                                                                                                                                                      
         current_message='HAPPY FOURTH OF JULY!!!!!',                                                                                                                               
         message_foreground=-65536, message_background=-16777216;                                                                                                                   
   end if;                                                                                                                                                                          
   commit;                                                                                                                                                                          
   */                                                                                                                                                                               
                                                                                                                                                                                    
   UTL_FILE.FCLOSE(file_handle);                                                                                                                                                    

                                                                                                                                                                                    
exception                                                                                                                                                                           
   when UTL_FILE.INVALID_PATH then                                                                                                                                                  
      update pcs.job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                        
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20051,'invalid path');                                                                                                                               
   when UTL_FILE.INVALID_MODE then                                                                                                                                                  
      update pcs.job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                        
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');                                                                                                                               
   when UTL_FILE.INVALID_FILEHANDLE then                                                                                                                                            

      update pcs.job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                        
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');                                                                                                                        
   when UTL_FILE.INVALID_OPERATION then                                                                                                                                             
      update pcs.job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                        
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');                                                                                                                          
   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      update pcs.job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                        
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 

      RAISE_APPLICATION_ERROR(-20055,'read error');                                                                                                                                 
   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      update pcs.job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                        
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20056,'write error');                                                                                                                                
   when OTHERS then                                                                                                                                                                 
      curr_line:='END DAILY JOBS WITH ERROR: '||date_today;                                                                                                                         
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
      curr_line:='------------------------------------'||                                                                                                                           
         '-------------------------------------------';                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 

      P_error_code:=SQLCODE;                                                                                                                                                        
      P_error_message:=SQLERRM;                                                                                                                                                     
      insert into pcs.error_log                                                                                                                                                     
         (error_code,error_message,proc_name,code_area,datestamp,sys_user)                                                                                                          
      values                                                                                                                                                                        
         (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);                                                                                                        
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      insert into pcs.daily_job_record (j_rec_number) values (j_rec_num);                                                                                                           
      curr_line:='WARNING! NIGHT JOB FAILURE, '||P_code_area;                                                                                                                       
      if (job_indicator=1) then                                                                                                                                                     
         curr_line:=curr_line||' [daily]';                                                                                                                                          
      elsif (job_indicator=2) then                                                                                                                                                  
         curr_line:=curr_line||' [weekly]';                                                                                                                                         

      elsif (job_indicator=3) then                                                                                                                                                  
         curr_line:=curr_line||' [monthly]';                                                                                                                                        
      elsif (job_indicator=4) then                                                                                                                                                  
         curr_line:=curr_line||' [mid-month]';                                                                                                                                      
      end if;                                                                                                                                                                       
      update business_info set                                                                                                                                                      
         current_message=curr_line,                                                                                                                                                 
         message_foreground=-65536,                                                                                                                                                 
         message_background=-16777216;                                                                                                                                              
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                                                                                                                                                                                
