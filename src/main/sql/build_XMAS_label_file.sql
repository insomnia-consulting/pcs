                                      
procedure     build_XMAS_label_file                                                                                                                                                 
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   cursor practice_list is                                                                                                                                                          
      select TO_CHAR(practice,'009'),name,                                                                                                                                          

         address1,address2,city,state,SUBSTR(zip,1,5)                                                                                                                               
      from pcs.practices                                                                                                                                                            
      where active_status='A'                                                                                                                                                       
      and ((practice_type in ('PCS','STD','ADPH')) or (practice_type='WV' and practice=parent_account))                                                                             
      order by name;                                                                                                                                                                
                                                                                                                                                                                    
   P_practice varchar2(5);                                                                                                                                                          
   P_name varchar2(128);                                                                                                                                                            
   P_addr1 varchar2(128);                                                                                                                                                           
   P_addr2 varchar2(128);                                                                                                                                                           
   P_city varchar2(128);                                                                                                                                                            
   P_state varchar2(128);                                                                                                                                                           
   P_zip varchar2(128);                                                                                                                                                             

   P_csz varchar2(128);                                                                                                                                                             
                                                                                                                                                                                    
   rcnt number;                                                                                                                                                                     
   check_point number;                                                                                                                                                              
   curr_line varchar2(1024);                                                                                                                                                        
   line_1 varchar2(256);                                                                                                                                                            
   line_2 varchar2(256);                                                                                                                                                            
   line_3 varchar2(256);                                                                                                                                                            
   line_4 varchar2(256);                                                                                                                                                            
   lbl_fname varchar2(13);                                                                                                                                                          
   dir_name varchar2(128);                                                                                                                                                          
   label_file UTL_FILE.FILE_TYPE;                                                                                                                                                   
                                                                                                                                                                                    

begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_XMAS_LABEL_FILE';                                                                                                                                            
   P_code_area:='PREP';                                                                                                                                                             
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   lbl_fname:='XMAS.lbl';                                                                                                                                                           
   label_file:=UTL_FILE.FOPEN(dir_name,lbl_fname,'w');                                                                                                                              
                                                                                                                                                                                    
   P_code_area:='P_LIST';                                                                                                                                                           
   rcnt:=0;                                                                                                                                                                         
   open practice_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      P_code_area:='FETCH';                                                                                                                                                         

      fetch practice_list into                                                                                                                                                      
         P_practice,P_name,P_addr1,P_addr2,P_city,P_state,P_zip;                                                                                                                    
      P_code_area:='DATA BEGIN';                                                                                                                                                    
      exit when practice_list%NOTFOUND;                                                                                                                                             
      rcnt:=0;                                                                                                                                                                      
      line_1:=P_name;                                                                                                                                                               
      line_2:=P_addr1;                                                                                                                                                              
      line_3:=P_addr2;                                                                                                                                                              
      line_4:=P_city||' '||P_state||'  '||P_zip;                                                                                                                                    
      curr_line:=line_1||','||line_2||','||line_4;                                                                                                                                  
      UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                   
   end loop;                                                                                                                                                                        
   close practice_list;                                                                                                                                                             

                                                                                                                                                                                    
                                                                                                                                                                                    
   P_code_area:='END';                                                                                                                                                              
   check_point:=0;                                                                                                                                                                  
                                                                                                                                                                                    
                                                                                                                                                                                    
   /**************/                                                                                                                                                                 
   UTL_FILE.FCLOSE(label_file);                                                                                                                                                     
   commit;                                                                                                                                                                          
                                                                                                                                                                                    
exception                                                                                                                                                                           
   when UTL_FILE.INVALID_PATH then                                                                                                                                                  
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  

      RAISE_APPLICATION_ERROR(-20051,'invalid path');                                                                                                                               
   when UTL_FILE.INVALID_MODE then                                                                                                                                                  
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20051,'invalid mode');                                                                                                                               
   when UTL_FILE.INVALID_FILEHANDLE then                                                                                                                                            
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20051,'invalid file handle');                                                                                                                        
   when UTL_FILE.INVALID_OPERATION then                                                                                                                                             
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20051,'invalid operation');                                                                                                                          
   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20051,'read error');                                                                                                                                 

   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20051,'write error');                                                                                                                                
   when OTHERS then                                                                                                                                                                 
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      P_error_code:=SQLCODE;                                                                                                                                                        
      P_error_message:=SQLERRM;                                                                                                                                                     
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                                            
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,TO_NUMBER(P_practice));                                                                              
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
end;                                                                                                                                         