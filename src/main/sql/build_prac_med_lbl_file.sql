                                       
procedure     build_prac_med_lbl_file                                                                                                                                               
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   cursor practice_list is                                                                                                                                                          

      select distinct practice from pcs.lab_requisitions a, pcs.billing_details b                                                                                                   
      where a.lab_number=b.lab_number and b.billing_choice=125 and b.rebilling=0                                                                                                    
         and a.lab_number>2002006316 order by practice;                                                                                                                             
                                                                                                                                                                                    
   p_name varchar2(32);                                                                                                                                                             
   p_addr1 varchar2(32);                                                                                                                                                            
   p_addr2 varchar2(32);                                                                                                                                                            
   p_csz varchar2(32);                                                                                                                                                              
   p_acct number;                                                                                                                                                                   
                                                                                                                                                                                    
   rcnt number;                                                                                                                                                                     
   curr_line varchar2(48);                                                                                                                                                          
   label_file UTL_FILE.FILE_TYPE;                                                                                                                                                   

                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_PRAC_MED_LBL_FILE';                                                                                                                                          
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   label_file:=UTL_FILE.FOPEN('vol1:','prac_med.lbl','w');                                                                                                                          
                                                                                                                                                                                    
   open practice_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch practice_list into p_acct;                                                                                                                                              
      exit when practice_list%NOTFOUND;                                                                                                                                             
      p_name:=NULL;                                                                                                                                                                 

      p_addr1:=NULL;                                                                                                                                                                
      p_addr2:=NULL;                                                                                                                                                                
      p_csz:=NULL;                                                                                                                                                                  
      select SUBSTR(name,1,32),SUBSTR(address1,1,32),SUBSTR(address2,1,32),                                                                                                         
         SUBSTR(city||', '||state||' '||SUBSTR(zip,1,5),1,32)                                                                                                                       
      into p_name,p_addr1,p_addr2,p_csz                                                                                                                                             
      from pcs.practices where practice=p_acct;                                                                                                                                     
      rcnt:=3;                                                                                                                                                                      
      curr_line:=p_name;                                                                                                                                                            
      UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                   
      curr_line:=p_addr1;                                                                                                                                                           
      UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                   
      if (p_addr2 is not null) then                                                                                                                                                 

         rcnt:=2;                                                                                                                                                                   
         curr_line:=p_addr2;                                                                                                                                                        
         UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                
      end if;                                                                                                                                                                       
      curr_line:=p_csz;                                                                                                                                                             
      UTL_FILE.PUTF(label_file,'%s\n',curr_line);                                                                                                                                   
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