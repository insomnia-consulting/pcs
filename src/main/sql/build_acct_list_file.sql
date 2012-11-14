create or replace procedure     build_acct_list_file                                                                                                                                                  
as                                                                                                                                                                                  

                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   cursor practice_list is                                                                                                                                                          
      select                                                                                                                                                                        
         to_char(practice,'009'),                                                                                                                                                   
         substr(name,1,46),                                                                                                                                                         
         substr(address1,1,35),                                                                                                                                                     
         substr(address2,1,32),                                                                                                                                                     
         substr(city,1,22)||', '||state||'  '||zip,                                                                                                                                 

         substr(phone,1,3)||'-'||substr(phone,4,3)||'-'||substr(phone,7)                                                                                                            
      from practices where active_status='A'                                                                                                                                        
      order by name;                                                                                                                                                                
                                                                                                                                                                                    
   P_practice varchar2(8);                                                                                                                                                          
   P_name varchar2(64);                                                                                                                                                             
   P_address1 varchar2(64);                                                                                                                                                         
   P_address2 varchar2(64);                                                                                                                                                         
   P_csz varchar2(64);                                                                                                                                                              
   P_phone varchar2(16);                                                                                                                                                            
   P_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
   curr_line varchar2(200);                                                                                                                                                         

   heading varchar2(100);                                                                                                                                                           
   heading_x varchar2(100);                                                                                                                                                         
   cbuf1 varchar2(128);                                                                                                                                                             
   cbuf2 varchar2(128);                                                                                                                                                             
   dline varchar2(128);                                                                                                                                                             
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_ACCT_LIST_FILE';                                                                                                                                             
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             

   P_file_name:='acctlist.txt';                                                                                                                                                     
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,P_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   dline:='---------------------------------------------------------------';                                                                                                        
                                                                                                                                                                                    
   P_code_area:='PRACTICE';                                                                                                                                                         
   open practice_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch practice_list into                                                                                                                                                      
         P_practice,P_name,P_address1,P_address2,P_csz,P_phone;                                                                                                                     
      exit when practice_list%NOTFOUND;                                                                                                                                             
      P_code_area:='DATA FETCHED';                                                                                                                                                  

      curr_line:=dline;                                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:=P_practice||' '||P_name;                                                                                                                                           
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:='     '||P_address1;                                                                                                                                               
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      if (P_address2 is NOT NULL) then                                                                                                                                              
         curr_line:='     '||P_address2;                                                                                                                                            
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
      end if;                                                                                                                                                                       
      curr_line:='     '||RPAD(P_csz,45)||P_phone;                                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end loop;                                                                                                                                                                        

   close practice_list;                                                                                                                                                             
                                                                                                                                                                                    
   UTL_FILE.FCLOSE(file_handle);                                                                                                                                                    
   commit;                                                                                                                                                                          
                                                                                                                                                                                    
exception                                                                                                                                                                           
   when UTL_FILE.INVALID_PATH then                                                                                                                                                  
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20051,'invalid path');                                                                                                                               
   when UTL_FILE.INVALID_MODE then                                                                                                                                                  
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');                                                                                                                               
   when UTL_FILE.INVALID_FILEHANDLE then                                                                                                                                            

      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');                                                                                                                        
   when UTL_FILE.INVALID_OPERATION then                                                                                                                                             
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');                                                                                                                          
   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20055,'read error');                                                                                                                                 
   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20056,'write error');                                                                                                                                
   when OTHERS then                                                                                                                                                                 
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 

      P_error_code:=SQLCODE;                                                                                                                                                        
      P_error_message:=SQLERRM;                                                                                                                                                     
      insert into pcs.error_log                                                                                                                                                     
         (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                                                                   
      values                                                                                                                                                                        
         (P_error_code,P_error_message,P_proc_name,P_code_area,                                                                                                                     
          SysDate,UID,TO_NUMBER(P_practice));                                                                                                                                       
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                                                                                                                                                                                
\