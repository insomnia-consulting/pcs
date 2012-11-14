
procedure     build_report_lbl_file                                                                                                                                                 
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   cursor practice_list is                                                                                                                                                          
      select                                                                                                                                                                        
         LTRIM(RTRIM(TO_CHAR(practice,'009'))),                                                                                                                                     

         name,address1,address2,                                                                                                                                                    
         SUBSTR(city||', '||state||' '||SUBSTR(zip,1,5),1,32),attn_message                                                                                                          
      from pcs.practices                                                                                                                                                            
      where cover_sheet='Y'                                                                                                                                                         
      order by practice;                                                                                                                                                            
                                                                                                                                                                                    
   p_acct varchar2(8);                                                                                                                                                              
   p_name varchar2(128);                                                                                                                                                            
   p_addr1 varchar2(128);                                                                                                                                                           
   p_addr2 varchar2(128);                                                                                                                                                           
   p_csz varchar2(128);                                                                                                                                                             
   p_msg varchar2(128);                                                                                                                                                             
                                                                                                                                                                                    

   rcnt number;                                                                                                                                                                     
   curr_line varchar2(48);                                                                                                                                                          
   label_file UTL_FILE.FILE_TYPE;                                                                                                                                                   
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_RERPORT_LBL_FILE';                                                                                                                                           
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   label_file:=UTL_FILE.FOPEN('vol1:','reports.lbl','w');                                                                                                                           
                                                                                                                                                                                    
   open practice_list;                                                                                                                                                              
   loop                                                                                                                                                                             

      fetch practice_list into p_acct,p_name,p_addr1,p_addr2,p_csz,p_msg;                                                                                                           
      exit when practice_list%NOTFOUND;                                                                                                                                             
      rcnt:=3;                                                                                                                                                                      
      curr_line:=p_name;                                                                                                                                                            
      UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                   
      curr_line:=p_addr1;                                                                                                                                                           
      UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                   
      if (p_addr2 is not null) then                                                                                                                                                 
         rcnt:=rcnt-1;                                                                                                                                                              
         curr_line:=p_addr2;                                                                                                                                                        
         UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                
      end if;                                                                                                                                                                       
      curr_line:=p_csz;                                                                                                                                                             

      UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                   
      if (p_msg is not null) then                                                                                                                                                   
         rcnt:=rcnt-1;                                                                                                                                                              
         curr_line:='ATTN: '||p_msg;                                                                                                                                                
         UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                
      end if;                                                                                                                                                                       
      UTL_FILE.NEW_LINE(label_file,rcnt);                                                                                                                                           
   end loop;                                                                                                                                                                        
   close practice_list;                                                                                                                                                             
                                                                                                                                                                                    
   UTL_FILE.FCLOSE(label_file);                                                                                                                                                     
   commit;                                                                                                                                                                          
                                                                                                                                                                                    

exception                                                                                                                                                                           
   when UTL_FILE.INVALID_PATH then                                                                                                                                                  
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20051,'invalid path');                                                                                                                               
   when UTL_FILE.INVALID_MODE then                                                                                                                                                  
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');                                                                                                                               
   when UTL_FILE.INVALID_FILEHANDLE then                                                                                                                                            
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');                                                                                                                        
   when UTL_FILE.INVALID_OPERATION then                                                                                                                                             
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');                                                                                                                          

   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20055,'read error');                                                                                                                                 
   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      RAISE_APPLICATION_ERROR(-20056,'write error');                                                                                                                                
   when OTHERS then                                                                                                                                                                 
      UTL_FILE.FCLOSE(label_file);                                                                                                                                                  
      P_error_code:=SQLCODE;                                                                                                                                                        
      P_error_message:=SQLERRM;                                                                                                                                                     
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                                            
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,p_acct);                                                                                             
      commit;                                                                                                                                                                       

      RAISE;                                                                                                                                                                        
end;                                                                                                                                        