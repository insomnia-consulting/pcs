create or replace procedure     build_FedEx_import_file                                                                                                                                               
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   

   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   cursor practice_list is                                                                                                                                                          
      select TO_CHAR(P.practice,'009'),SUBSTR(P.name,1,35),SUBSTR(P.address1,1,35),                                                                                                 
         SUBSTR(P.address2,1,35),SUBSTR(P.city,1,24),P.state,P.zip,P.phone                                                                                                          
      from pcs.practices P                                                                                                                                                          
      where P.active_status='A' and practice_type='ADPH'                                                                                                                            
      order by P.practice;                                                                                                                                                          
                                                                                                                                                                                    
   /* Fields in FedEx Template RECIPEINT 1 IMP                                                                                                                                      
      Note:  The "F_" is appended to the field name                                                                                                                                 
   */                                                                                                                                                                               

   F_recipient varchar2(10);                                                                                                                                                        
   F_company varchar2(35);                                                                                                                                                          
   F_contact varchar2(35);                                                                                                                                                          
   F_addr1 varchar2(32);                                                                                                                                                            
   F_addr2 varchar2(32);                                                                                                                                                            
   F_city varchar2(24);                                                                                                                                                             
   F_state varchar2(14);                                                                                                                                                            
   F_country_code char(2);                                                                                                                                                          
   F_zip varchar2(9);                                                                                                                                                               
   F_phone varchar2(10);                                                                                                                                                            
   F_acct varchar2(9);                                                                                                                                                              
   F_third_party varchar2(9);                                                                                                                                                       
   F_tax_id varchar2(15);                                                                                                                                                           

                                                                                                                                                                                    
   P_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
   curr_line varchar2(256);                                                                                                                                                         
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_FEDEX_IMPORT_FILE';                                                                                                                                          
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   P_file_name:='FedEx.imp';                                                                                                                                                        

   dir_name:=RTRIM('REPORTS_DIR');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,P_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   /* Set values for fields that are either blank or will                                                                                                                           
      have a default value                                                                                                                                                          
   */                                                                                                                                                                               
   F_contact:=' ';                                                                                                                                                                  
   F_country_code:='US';                                                                                                                                                            
   F_acct:=' ';                                                                                                                                                                     
   F_third_party:=' ';                                                                                                                                                              
   F_tax_id:=' ';                                                                                                                                                                   
                                                                                                                                                                                    
   P_code_area:='DATA';                                                                                                                                                             

   open practice_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch practice_list into                                                                                                                                                      
         F_recipient,F_company,F_addr1,F_addr2,F_city,F_state,F_zip,F_phone;                                                                                                        
      exit when practice_list%NOTFOUND;                                                                                                                                             
      P_code_area:='DATA FETCHED';                                                                                                                                                  
      if (F_addr2 IS NULL) then                                                                                                                                                     
         F_addr2:=' ';                                                                                                                                                              
      end if;                                                                                                                                                                       
      curr_line:=RPAD(RTRIM(LTRIM(F_recipient)),10);                                                                                                                                
      curr_line:=curr_line||RPAD(F_company,35);                                                                                                                                     
      curr_line:=curr_line||RPAD(F_contact,35);                                                                                                                                     
      curr_line:=curr_line||RPAD(F_addr1,35);                                                                                                                                       

      curr_line:=curr_line||RPAD(F_addr2,35);                                                                                                                                       
      curr_line:=curr_line||RPAD(F_city,24);                                                                                                                                        
      curr_line:=curr_line||RPAD(F_state,14);                                                                                                                                       
      curr_line:=curr_line||RPAD(F_country_code,2);                                                                                                                                 
      curr_line:=curr_line||RPAD(F_zip,9);                                                                                                                                          
      curr_line:=curr_line||RPAD(F_phone,10);                                                                                                                                       
      curr_line:=curr_line||RPAD(F_acct,9);                                                                                                                                         
      curr_line:=curr_line||RPAD(F_third_party,9);                                                                                                                                  
      curr_line:=curr_line||RPAD(F_tax_id,15);                                                                                                                                      
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

      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                                            
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,TO_NUMBER(F_recipient));                                                                             
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;        
\

grant execute on build_FedEx_import_file to pcs_user 
\