                                       
procedure build_beth_codes_file                                                                                                                                                     
(                                                                                                                                                                                   

   filename in varchar2                                                                                                                                                             
)                                                                                                                                                                                   
AS                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
   B_code varchar2(4);                                                                                                                                                              
   B_description varchar2(512);                                                                                                                                                     

   B_path char(1);                                                                                                                                                                  
   B_category char(1);                                                                                                                                                              
   B_class number;                                                                                                                                                                  
   B_biopsy char(1);                                                                                                                                                                
                                                                                                                                                                                    
   cursor code_list is                                                                                                                                                              
      select bethesda_code,description,path_needed,category,papclass,biopsy_request                                                                                                 
      from bethesda_codes where active_status='A';                                                                                                                                  
                                                                                                                                                                                    
BEGIN                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_BETH_CODES_FILE';                                                                                                                                            
   P_code_area:='OPEN FILE';                                                                                                                                                        

                                                                                                                                                                                    
   file_handle:=UTL_FILE.FOPEN('vol1:\',filename,'w');                                                                                                                              
                                                                                                                                                                                    
   UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                                
     'BCODE|DESCR|PATH_NEEDED|CATEGORY|P_CLASS|BIOPSY');                                                                                                                            
	                                                                                                                                                                                   
   P_code_area:='BILL_ITEM CURSOR';                                                                                                                                                 
   open code_list;	                                                                                                                                                                 
   loop                                                                                                                                                                             
      fetch code_list into                                                                                                                                                          
         B_code,B_description,B_path,B_category,B_class,B_biopsy;                                                                                                                   
	exit when code_list%NOTFOUND;                                                                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                             

         B_code || '|' || B_description || '|' || B_path || '|' ||                                                                                                                  
         B_category || '|' || TO_CHAR(B_class) || '|' || B_biopsy);                                                                                                                 
   end loop;                                                                                                                                                                        
   close code_list;                                                                                                                                                                 
                                                                                                                                                                                    
   UTL_FILE.NEW_LINE(file_handle);                                                                                                                                                  
   UTL_FILE.FCLOSE(file_handle);                                                                                                                                                    
                                                                                                                                                                                    
EXCEPTION                                                                                                                                                                           
                                                                                                                                                                                    
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
      RAISE_APPLICATION_ERROR(-20054,'invalid operation '||P_code_area);                                                                                                            
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
        (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,0);                                                                                                       
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    

END;                                                                                                                                         