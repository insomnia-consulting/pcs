                                       
procedure     build_blank_letter                                                                                                                                                    
(                                                                                                                                                                                   
   M_lab_number in number,                                                                                                                                                          
   M_origin in number                                                                                                                                                               
)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    

   M_practice number;                                                                                                                                                               
   M_practice_id varchar2(8);                                                                                                                                                       
   M_name varchar2(64);                                                                                                                                                             
   M_lname varchar2(32);                                                                                                                                                            
   M_fname varchar2(32);                                                                                                                                                            
   M_prname varchar2(64);                                                                                                                                                           
   M_addr1 varchar2(64);                                                                                                                                                            
   M_addr2 varchar2(64);                                                                                                                                                            
   M_city varchar2(32);                                                                                                                                                             
   M_state char(2);                                                                                                                                                                 
   M_zip char(5);                                                                                                                                                                   
   M_fax char(14);                                                                                                                                                                  
   M_dr_lname varchar2(32);                                                                                                                                                         

   M_dr_fname varchar2(32);                                                                                                                                                         
   M_upin varchar2(16);                                                                                                                                                             
   M_license varchar2(16);                                                                                                                                                          
   M_doctor_text varchar2(64);                                                                                                                                                      
   M_patid varchar2(16);                                                                                                                                                            
   pat_addr1 varchar2(64);                                                                                                                                                          
   pat_city varchar2(32);                                                                                                                                                           
   pat_state char(2);                                                                                                                                                               
   pat_zip varchar2(9);                                                                                                                                                             
   pat_dob date;                                                                                                                                                                    
   dir_name varchar2(128);                                                                                                                                                          
   M_date char(10);                                                                                                                                                                 
   M_choice_code varchar2(3);                                                                                                                                                       

   curr_line varchar2(300);                                                                                                                                                         
   rcnt number;                                                                                                                                                                     
   margin varchar2(32);                                                                                                                                                             
   heading1 varchar2(256);                                                                                                                                                          
   heading2 varchar2(256);                                                                                                                                                          
   heading3 varchar2(256);                                                                                                                                                          
   heading4 varchar2(256);                                                                                                                                                          
   heading5 varchar2(256);                                                                                                                                                          
   cbuf varchar2(256);                                                                                                                                                              
   L_file_name varchar2(64);                                                                                                                                                        
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   check_point number;                                                                                                                                                              

                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
      P_proc_name:='BUILD_BLANK_LETTER';                                                                                                                                            
                                                                                                                                                                                    
      P_code_area:='PREP';                                                                                                                                                          
      check_point:=0;                                                                                                                                                               
      L_file_name:='generic.ltr';                                                                                                                                                   
      dir_name:='vol1:';                                                                                                                                                            
                                                                                                                                                                                    
      select TO_CHAR(R.practice,'009'),TO_CHAR(R.date_collected,'MM/DD/YYYY'),                                                                                                      
         P.lname,P.fname,PR.name,PR.address1,PR.address2,PR.city,                                                                                                                   
         PR.state,SUBSTR(PR.zip,1,5),PR.fax,P.address1,P.city,P.state,P.zip,P.dob,                                                                                                  

         B.choice_code,SUBSTR(D.lname,1,32),D.fname,D.upin,D.license,                                                                                                               
         SUBSTR(R.doctor_text,1,64),R.patient_id                                                                                                                                    
      into M_practice_id,M_date,M_lname,M_fname,M_prname,M_addr1,M_addr2,M_city,                                                                                                    
         M_state,M_zip,M_fax,pat_addr1,pat_city,pat_state,pat_zip,pat_dob,M_choice_code,                                                                                            
         M_dr_lname, M_dr_fname, M_upin, M_license, M_doctor_text,M_patid                                                                                                           
      from pcs.lab_requisitions R, pcs.patients P, pcs.practices PR,                                                                                                                
         pcs.billing_choices B, pcs.doctors D                                                                                                                                       
      where R.patient=P.patient and R.practice=PR.practice and                                                                                                                      
         R.doctor=D.doctor and R.billing_choice=B.billing_choice and                                                                                                                
         D.practice=PR.practice and R.lab_number=M_lab_number;                                                                                                                      
                                                                                                                                                                                    
      if (LENGTH(M_fax)=10) then                                                                                                                                                    
         M_fax:=SUBSTR(M_fax,1,3)||'.'||SUBSTR(M_fax,4,6)||'.'||SUBSTR(M_fax,7);                                                                                                    

      else                                                                                                                                                                          
         M_fax:=NULL;                                                                                                                                                               
      end if;                                                                                                                                                                       
                                                                                                                                                                                    
      file_handle:=UTL_FILE.FOPEN(dir_name,L_file_name,'a');                                                                                                                        
                                                                                                                                                                                    
      select count(*) into rcnt from pcs.fax_letters                                                                                                                                
      where (letter_type='GENERIC' and (in_queue=1 or in_queue=-1))                                                                                                                 
      or (letter_type='BLANK' and in_queue=-1);                                                                                                                                     
                                                                                                                                                                                    
      P_code_area:='HEADER';                                                                                                                                                        
      margin:='   ';                                                                                                                                                                
      heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';                                                                                                                           

      heading2:=margin||'Suite 1700 Parkway Building';                                                                                                                              
      heading3:=margin||'339 Old Haymaker Road';                                                                                                                                    
      heading4:=margin||'Monroeville, PA  15146';                                                                                                                                   
                                                                                                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n\n\n%s\n',cbuf,heading1);                                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',heading2);                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',heading3);                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n\n\n',heading4);                                                                                                                               
                                                                                                                                                                                    
      select TO_CHAR(SysDate,'MM/DD/YYYY') into cbuf from dual;                                                                                                                     
      curr_line:=margin||'Date:  '||cbuf;                                                                                                                                           
      UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);                                                                                                                              
                                                                                                                                                                                    

      curr_line:=margin||M_prname;                                                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:=margin||M_addr1;                                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      if (M_addr2 is not null) then                                                                                                                                                 
         curr_line:=margin||M_addr2;                                                                                                                                                
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
      end if;                                                                                                                                                                       
      curr_line:=margin||M_city||', '||M_state||'  '||M_zip;                                                                                                                        
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      if (M_fax is NOT NULL) then                                                                                                                                                   
         curr_line:=margin||'FAX: '||M_fax;                                                                                                                                         
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               

      end if;                                                                                                                                                                       
      UTL_FILE.NEW_LINE(file_handle);                                                                                                                                               
                                                                                                                                                                                    
      curr_line:=margin||'       RE: INFORMATION NEEDED';                                                                                                                           
      UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);                                                                                                                            
                                                                                                                                                                                    
      P_code_area:='DETAILS';                                                                                                                                                       
      curr_line:=margin||'Laboratory #'||LTRIM(TO_CHAR(M_lab_number));                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      curr_line:=margin||'Patient:          '||chr(27)||chr(71)||M_lname||', '||M_fname||chr(27)||chr(72);                                                                          
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:=margin||'Date of Service:  '||M_date;                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                

      if (M_patid is NOT NULL) then                                                                                                                                                 
         curr_line:=margin||'Patient ID:       '||M_patid;                                                                                                                          
      end if;                                                                                                                                                                       
                                                                                                                                                                                    
                                                                                                                                                                                    
      curr_line:=margin||'Dear '||M_prname||':';                                                                                                                                    
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                              
                                                                                                                                                                                    
      curr_line:=margin||'We are processing a Pap smear on the patient above and are missing';                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:=margin||'the following information.';                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
                                                                                                                                                                                    

      curr_line:=margin||'____________________________________________________';                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      curr_line:=margin||'____________________________________________________';                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      curr_line:=margin||'____________________________________________________';                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      curr_line:=margin||'____________________________________________________';                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      curr_line:=margin||'____________________________________________________';                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      curr_line:=margin||'____________________________________________________';                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
                                                                                                                                                                                    

      curr_line:=margin||'Please provide this information on this form and fax it back to us';                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:=margin||'at 412.373.7027 as soon as possible.  Many thanks.';                                                                                                      
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
                                                                                                                                                                                    
      curr_line:=margin||'Pennsylvania Cytology Services';                                                                                                                          
      UTL_FILE.PUTF(file_handle,'%s\n\n\n\n',curr_line);                                                                                                                            
                                                                                                                                                                                    
      curr_line:=margin||'As per ___________________________________ Date _____________';                                                                                           
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:=margin||'       (Please sign to verify our records)';                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      if (M_origin=1) then                                                                                                                                                          

         curr_line:=margin||'REQUISITION';                                                                                                                                          
      elsif (M_origin=2) then                                                                                                                                                       
         curr_line:=margin||'BILLING';                                                                                                                                              
      else                                                                                                                                                                          
         curr_line:=' ';                                                                                                                                                            
      end if;                                                                                                                                                                       
      UTL_FILE.PUTF(file_handle,'%s',curr_line);                                                                                                                                    
                                                                                                                                                                                    
      UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                            
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
                                                                                                                                                                                    
      insert into pcs.fax_letters (lab_number,letter_type,in_queue,date_sent,origin)                                                                                                
      values (M_lab_number,'BLANK',-1,SysDate,M_origin);                                                                                                                            

                                                                                                                                                                                    
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,M_lab_number);                                                                                       
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                                                                                                                                         