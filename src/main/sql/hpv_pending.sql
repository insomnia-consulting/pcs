CREATE OR REPLACE PROCEDURE hpv_pending                                                       
as                                                                              
                                                                                
   P_error_code number;                                                         
   P_error_message varchar2(512);                                               
   P_proc_name varchar2(32);                                                    
   P_code_area varchar2(32);                                                    
                                                                                
   H_lab number;                                                                
   H_date varchar2(12);                                                         
   P_name varchar2(32);                                                         
   P_account varchar2(6);                                                       
                                                                                

   rcnt number;                                                                 
   curr_line varchar2(128);                                                     
   line_cntr number;                                                            
                                                                                
   cursor hpv_list is                                                           
	select lab_number, TO_CHAR(datestamp,'MM/DD/YYYY')                             
      from pcs.hpv_requests                                                     
   	where test_sent is NULL or test_sent IN ('R','P')                           
   	order by lab_number;                                                        
                                                                                
   file_handle UTL_FILE.FILE_TYPE;                                              
                                                                                
begin                                                                           

                                                                                
   P_proc_name:='HPV_PENDING';                                                  
   P_code_area:='PREP';                                                         
                                                                                
   file_handle:=UTL_FILE.FOPEN('vol1:','pending.hpv','w');                      
   line_cntr:=0;                                                                
                                                                                
   UTL_FILE.NEW_LINE(file_handle);                                              
   open hpv_list;                                                               
   loop                                                                         
      P_code_area:='FETCH';                                                     
      fetch hpv_list into H_lab,H_date;                                         
      exit when hpv_list%NOTFOUND;                                              

      P_code_area:='FORMAT';                                                    
      if (line_cntr>=60 or line_cntr=0) then                                    
         if (line_cntr>0) then                                                  
            UTL_FILE.PUT(file_handle,CHR(12));                                  
         end if;                                                                
         UTL_FILE.NEW_LINE(file_handle,2);                                      
         curr_line:='PENDING HPV REQUESTS';                                     
         UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                         
         curr_line:='LAB#          ACCT    PATIENT';                            
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                           
         line_cntr:=5;                                                          
      end if;                                                                   
      curr_line:=                                                               

         '----------------------------------------------------------------------
----';                                                                          
                                                                                
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                              
      line_cntr:=line_cntr+1;                                                   
      select RPAD(SUBSTR(lname||', '||fname,1,24),26),TO_CHAR(b.practice,'009') 
                                                                                
                                                                                
      into P_name,P_account                                                     
      from pcs.patients a, pcs.lab_requisitions b                               
      where a.patient=b.patient and b.lab_number=H_lab;                         
      curr_line:=TO_CHAR(H_lab)||'    '||P_account||'    '||P_name;             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                              

      line_cntr:=line_cntr+1;                                                   
   end loop;                                                                    
   close hpv_list;                                                              
                                                                                
   UTL_FILE.PUT(file_handle,CHR(12));                                           
   UTL_FILE.FCLOSE(file_handle);                                                
                                                                                
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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,da
testamp,sys_user,ref_id)                                                        
                                                                                
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,H
_lab);                                                                          
                                                                                
      commit;                                                                   
      RAISE;                                                                    
                                                                                

end;                                                                            

