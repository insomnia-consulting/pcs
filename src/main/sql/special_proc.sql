bbcreate or replace procedure     special_proc                                                                                                                                                          
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
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   e_job_failure exception;                                                                                                                                                         
   e_invalid_time exception;                                                                                                                                                        
   rcnt number;                                                                                                                                                                     
   job_failures number;                                                                                                                                                             
   job_indicator number;                                                                                                                                                            
   job_prior number;                                                                                                                                                                

                                                                                                                                                                                    
   job_date_text1 varchar2(16);                                                                                                                                                     
   job_date_text2 varchar2(16);                                                                                                                                                     
   job_date1 date;                                                                                                                                                                  
   job_date2 date;                                                                                                                                                                  
   this_time date;                                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='DAILY_JOBS';                                                                                                                                                       
   P_code_area:='PREP';                                                                                                                                                             
   job_indicator:=0;                                                                                                                                                                
                                                                                                                                                                                    

   file_handle:=UTL_FILE.FOPEN('vol1:','dailyjob.log','a');                                                                                                                         
   P_code_area:='HEADER';                                                                                                                                                           
   select TO_CHAR(SysDate-1,'MM/DD/YYYY HH24:Mi:SS') into date_today from dual;                                                                                                     
   curr_line:='DAILY JOB LOG FOR: '||date_today||' ***SPECIAL***';                                                                                                                  
   UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                                 
                                                                                                                                                                                    
   rcnt:=0;                                                                                                                                                                         
   select job_status into rcnt from pcs.job_control where job_descr='SPECIAL';                                                                                                      
   if (rcnt=1) then                                                                                                                                                                 
      P_code_area:='SPEICAL';                                                                                                                                                       
      S_month:='200310';                                                                                                                                                            
      curr_line:='* * * R U N N I N G   S P E C I A L * * *';                                                                                                                       
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              

      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='CREATING SUMMARIES: '||date_today;                                                                                                                                
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.generate_summaries(S_month);                                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='AGING REPORT: '||date_today;                                                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_eom_aging_file(S_month);                                                                                                                                            
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='SUMMARY OF BILLING TYPES: '||date_today;                                                                                                                          
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_eom_summary_file(S_month);                                                                                                                                          
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 

      curr_line:='UNSATISFACTORY PAP SMEARS: '||date_today;                                                                                                                         
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_unsatisfactory_file(S_month);                                                                                                                                       
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='BIOPSY FILES: '||date_today;                                                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_biopsy_files(S_month);                                                                                                                                              
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='CYTOTECH SUMMARY: '||date_today;                                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_cytotech_summary_file(S_month);                                                                                                                                     
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='PATH0LOGIST SUMMARY: '||date_today;                                                                                                                               

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_pathologist_summary_file(S_month);                                                                                                                                  
      select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                 
      curr_line:='STD CLINIC FILE: '||date_today;                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      pcs.build_stdclinic_file(S_month);                                                                                                                                            
      update pcs.job_control set job_status=0 where job_descr='SPECIAL';                                                                                                            
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   <<exit_point>>                                                                                                                                                                   
   commit;                                                                                                                                                                          
                                                                                                                                                                                    
   P_code_area:='END';                                                                                                                                                              

   select TO_CHAR(SysDate,'HH:Mi:SS') into date_today from dual;                                                                                                                    
   if (job_prior=3) then                                                                                                                                                            
      curr_line:='*** DAILY JOBS IN SUSPENDED MODE TODAY ***';                                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   elsif (job_prior=2) then                                                                                                                                                         
      curr_line:='*** DAILY JOBS TURNED OFF ***';                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end if;                                                                                                                                                                          
   curr_line:='END DAILY JOBS: '||date_today||' ***SPECIAL***';                                                                                                                     
   UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                                 
   curr_line:=                                                                                                                                                                      
      '-------------------------------------------------------------------------------';                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     

                                                                                                                                                                                    
   set transaction use rollback segment pcs_rbs1;                                                                                                                                   
   update job_control set job_status=1                                                                                                                                              
   where job_descr='JOB_STATUS' and job_status<>2;                                                                                                                                  
   commit;                                                                                                                                                                          
                                                                                                                                                                                    
   UTL_FILE.FCLOSE(file_handle);                                                                                                                                                    
                                                                                                                                                                                    
exception                                                                                                                                                                           
   when UTL_FILE.INVALID_PATH then                                                                                                                                                  
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 

      RAISE_APPLICATION_ERROR(-20051,'invalid path');                                                                                                                               
   when UTL_FILE.INVALID_MODE then                                                                                                                                                  
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');                                                                                                                               
   when UTL_FILE.INVALID_FILEHANDLE then                                                                                                                                            
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');                                                                                                                        
   when UTL_FILE.INVALID_OPERATION then                                                                                                                                             
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            

      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');                                                                                                                          
   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20055,'read error');                                                                                                                                 
   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      commit;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20056,'write error');                                                                                                                                

   when e_job_failure then                                                                                                                                                          
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      commit;                                                                                                                                                                       
      if (job_failures=1) then                                                                                                                                                      
         curr_line:='*** CANNOT RUN DAILY JOBS DUE TO PRIOR FAILURES: '||date_today;                                                                                                
         UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                             
         curr_line:='*** DAILY JOBS MUST BE RESET BY DBA';                                                                                                                          
         UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                             
      end if;                                                                                                                                                                       
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20060,'prior failure error ');                                                                                                                       
   when e_invalid_time then                                                                                                                                                         
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 

      RAISE_APPLICATION_ERROR(-20061,'invalid time error ');                                                                                                                        
   when OTHERS then                                                                                                                                                                 
      curr_line:='ENDING DAILY JOBS ERROR: '||date_today;                                                                                                                           
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      P_error_code:=SQLCODE;                                                                                                                                                        
      P_error_message:=SQLERRM;                                                                                                                                                     
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)                                                                                   
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);                                                                                                    
      update job_control set job_status=-1 where job_descr='JOB_STATUS';                                                                                                            
      if (job_indicator=1) then                                                                                                                                                     
         update business_info set                                                                                                                                                   
            current_message='WARNING!!! DAILY JOBS DID NOT RUN DUE TO FAILURE [1] - PLEASE NOTIFY MANAGEMENT',                                                                      

            message_foreground=-65536, message_background=-16777216;                                                                                                                
      elsif (job_indicator=2) then                                                                                                                                                  
         update business_info set                                                                                                                                                   
            current_message='WARNING!!! DAILY JOBS DID NOT RUN DUE TO FAILURE [2] - PLEASE NOTIFY MANAGEMENT',                                                                      
            message_foreground=-65536, message_background=-16777216;                                                                                                                
      elsif (job_indicator=3) then                                                                                                                                                  
         update business_info set                                                                                                                                                   
            current_message='WARNING!!! EOM DID NOT RUN DUE TO FAILURE [3] - PLEASE NOTIFY MANAGEMENT',                                                                             
            message_foreground=-65536, message_background=-16777216;                                                                                                                
      end if;                                                                                                                                                                       
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    

end;                                                                                                                                                                                
/