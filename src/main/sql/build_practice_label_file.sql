create or replace procedure     build_practice_label_file                                                                                                                                             
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
   lcntr number;                                                                                                                                                                    
   check_point number;                                                                                                                                                              
   curr_line varchar2(256);                                                                                                                                                         
   line_1 varchar2(256);                                                                                                                                                            
   line_2 varchar2(256);                                                                                                                                                            
   line_3 varchar2(256);                                                                                                                                                            
   line_4 varchar2(256);                                                                                                                                                            
   lbl_fname varchar2(13);                                                                                                                                                          
   dir_name varchar2(128);                                                                                                                                                          
   label_file UTL_FILE.FILE_TYPE;                                                                                                                                                   
                                                                                                                                                                                    

begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_PRACTICE_LABEL_FILE';                                                                                                                                        
   P_code_area:='PREP';                                                                                                                                                             
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   lbl_fname:='pracxmas.lbl';                                                                                                                                                       
   label_file:=UTL_FILE.FOPEN(dir_name,lbl_fname,'w');                                                                                                                              
                                                                                                                                                                                    
   P_code_area:='P_LIST';                                                                                                                                                           
   open practice_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      P_code_area:='FETCH';                                                                                                                                                         
      fetch practice_list into                                                                                                                                                      

         P_practice,P_name,P_addr1,P_addr2,P_city,P_state,P_zip;                                                                                                                    
      P_code_area:='DATA FOUND';                                                                                                                                                    
      exit when practice_list%NOTFOUND;                                                                                                                                             
      P_code_area:='DATA FOUND';                                                                                                                                                    
      rcnt:=0;                                                                                                                                                                      
      loop                                                                                                                                                                          
         P_code_area:='LOOP';                                                                                                                                                       
         exit when rcnt=24;                                                                                                                                                         
         rcnt:=rcnt+1;                                                                                                                                                              
         lcntr:=3;                                                                                                                                                                  
         line_1:=RPAD(SUBSTR(P_name,1,28),29);                                                                                                                                      
         curr_line:=line_1||'     '||line_1||'     '||line_1||'     '||line_1;                                                                                                      
         UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                

         line_2:=RPAD(SUBSTR(P_addr1,1,28),29);                                                                                                                                     
         curr_line:=line_2||'     '||line_2||'     '||line_2||'     '||line_2;                                                                                                      
         UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                
         if (P_addr2 is NOT NULL) then                                                                                                                                              
            lcntr:=2;                                                                                                                                                               
            line_3:=RPAD(SUBSTR(P_addr2,1,28),29);                                                                                                                                  
            curr_line:=line_3||'     '||line_3||'     '||line_3||'     '||line_3;                                                                                                   
            UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                             
         end if;                                                                                                                                                                    
         line_4:=SUBSTR(P_zip,1,5);                                                                                                                                                 
         P_csz:=SUBSTR(SUBSTR(P_city,1,19)||', '||P_state||' '||line_4,1,28);                                                                                                       
         P_csz:=RPAD(P_csz,29);                                                                                                                                                     
         curr_line:=P_csz||'     '||P_csz||'     '||P_csz||'     '||P_csz;                                                                                                          

         UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                
         UTL_FILE.NEW_LINE(label_file,lcntr);                                                                                                                                       
         lcntr:=0;                                                                                                                                                                  
      end loop;                                                                                                                                                                     
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
\

grant execute on build_practice_label_file to pcs_user ; 
\