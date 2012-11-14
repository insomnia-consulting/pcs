                                       
procedure     build_practice_lable_file                                                                                                                                             
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    

                                                                                                                                                                                    
   S_period varchar2(64);                                                                                                                                                           
   last_practice number;                                                                                                                                                            
   last_date date;                                                                                                                                                                  
   un_count number;                                                                                                                                                                 
   curr_count number;                                                                                                                                                               
   total_count number;                                                                                                                                                              
                                                                                                                                                                                    
   S_file_name varchar2(12);                                                                                                                                                        
   summary_file UTL_FILE.FILE_TYPE;                                                                                                                                                 
   dir_name varchar2(128);                                                                                                                                                          
   check_point number;                                                                                                                                                              
                                                                                                                                                                                    

begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_BIOPSY_FILES';                                                                                                                                               
                                                                                                                                                                                    
   S_file_name:='rfb';                                                                                                                                                              
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   summary_file:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                          
                                                                                                                                                                                    
                                                                                                                                                                                    
   P_code_area:='END';                                                                                                                                                              
   UTL_FILE.PUTF(summary_file,'%s',chr(12));                                                                                                                                        
   UTL_FILE.FCLOSE(summary_file);                                                                                                                                                   
   commit;                                                                                                                                                                          

                                                                                                                                                                                    
exception                                                                                                                                                                           
   when UTL_FILE.INVALID_PATH then                                                                                                                                                  
      UTL_FILE.FCLOSE(summary_file);                                                                                                                                                
      RAISE_APPLICATION_ERROR(-20051,'invalid path');                                                                                                                               
   when UTL_FILE.INVALID_MODE then                                                                                                                                                  
      UTL_FILE.FCLOSE(summary_file);                                                                                                                                                
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');                                                                                                                               
   when UTL_FILE.INVALID_FILEHANDLE then                                                                                                                                            
      UTL_FILE.FCLOSE(summary_file);                                                                                                                                                
      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');                                                                                                                        
   when UTL_FILE.INVALID_OPERATION then                                                                                                                                             
      UTL_FILE.FCLOSE(summary_file);                                                                                                                                                

      RAISE_APPLICATION_ERROR(-20054,'invalid operation');                                                                                                                          
   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      UTL_FILE.FCLOSE(summary_file);                                                                                                                                                
      RAISE_APPLICATION_ERROR(-20055,'read error');                                                                                                                                 
   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      UTL_FILE.FCLOSE(summary_file);                                                                                                                                                
      RAISE_APPLICATION_ERROR(-20056,'write error');                                                                                                                                
   when OTHERS then                                                                                                                                                                 
      UTL_FILE.FCLOSE(summary_file);                                                                                                                                                
      P_error_code:=SQLCODE;                                                                                                                                                        
      P_error_message:=SQLERRM;                                                                                                                                                     
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)                                                                                   
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);                                                                                                    

      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                                                                                                                                         