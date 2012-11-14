create or replace procedure     build_diagnosis_letter                                                                                                                                                
(                                                                                                                                                                                   
   M_lab_number in number,                                                                                                                                                          
   qmode in number,                                                                                                                                                                 
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
   M_dob varchar2(10);                                                                                                                                                              
   M_ssn varchar2(9);                                                                                                                                                               

   M_prname varchar2(64);                                                                                                                                                           
   M_addr1 varchar2(64);                                                                                                                                                            
   M_addr2 varchar2(64);                                                                                                                                                            
   M_city varchar2(32);                                                                                                                                                             
   M_state char(2);                                                                                                                                                                 
   M_zip char(5);                                                                                                                                                                   
   M_fax char(14);                                                                                                                                                                  
   M_patid varchar2(16);                                                                                                                                                            
   dir_name varchar2(128);                                                                                                                                                          
   M_date char(10);                                                                                                                                                                 
   M_receive char(10);                                                                                                                                                              
   curr_line varchar2(300);                                                                                                                                                         
   cbuf1 varchar2(128);                                                                                                                                                             

   cbuf2 varchar2(128);                                                                                                                                                             
   rcnt number;                                                                                                                                                                     
   margin varchar2(32);                                                                                                                                                             
   dline varchar2(256);                                                                                                                                                             
   dline2 varchar2(256);                                                                                                                                                            
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
                                                                                                                                                                                    
   P_proc_name:='BUILD_DIAGNOSIS_LETTER';                                                                                                                                           
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   check_point:=0;                                                                                                                                                                  
   L_file_name:='diag.ltr';                                                                                                                                                         
   check_point:=0.5;                                                                                                                                                                
   dir_name:='vol1:';                                                                                                                                                               
   check_point:=0.6;                                                                                                                                                                

   file_handle:=UTL_FILE.FOPEN(dir_name,L_file_name,'a');                                                                                                                           
   check_point:=0.7;                                                                                                                                                                
                                                                                                                                                                                    
   select RTRIM(LTRIM(TO_CHAR(R.practice,'009'))),TO_CHAR(R.date_collected,'MM/DD/YYYY'),                                                                                           
      P.lname,P.fname,PR.name,PR.address1,PR.address2,PR.city,                                                                                                                      
      PR.state,SUBSTR(PR.zip,1,5),PR.fax,TO_CHAR(R.receive_date,'MM/DD/YYYY'),                                                                                                      
      TO_CHAR(P.dob,'MM/DD/YYYY'),P.ssn,R.patient_id                                                                                                                                
   into M_practice_id,M_date,M_lname,M_fname,M_prname,M_addr1,M_addr2,M_city,                                                                                                       
      M_state,M_zip,M_fax,M_receive,M_dob,M_ssn,M_patid                                                                                                                             
   from pcs.lab_requisitions R, pcs.patients P, pcs.practices PR                                                                                                                    
   where R.patient=P.patient and R.practice=PR.practice and R.lab_number=M_lab_number;                                                                                              
                                                                                                                                                                                    
   if (LENGTH(M_fax)=10) then                                                                                                                                                       

      M_fax:=SUBSTR(M_fax,1,3)||'.'||SUBSTR(M_fax,4,6)||'.'||SUBSTR(M_fax,7);                                                                                                       
   else                                                                                                                                                                             
      M_fax:=NULL;                                                                                                                                                                  
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   select count(*) into rcnt from pcs.fax_letters                                                                                                                                   
   where (letter_type='DIAGNOSIS' and (in_queue=1 or in_queue=-1));                                                                                                                 
                                                                                                                                                                                    
   P_code_area:='HEADING';                                                                                                                                                          
   margin:='   ';                                                                                                                                                                   
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';                                                                                                                              
   heading2:=margin||'Suite 1700 Parkway Building';                                                                                                                                 
   heading3:=margin||'339 Old Haymaker Road';                                                                                                                                       

   heading4:=margin||'Monroeville, PA  15146';                                                                                                                                      
                                                                                                                                                                                    
   UTL_FILE.PUTF(file_handle,'\n\n\n%s\n',heading1);                                                                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n',heading2);                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',heading3);                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',heading4);                                                                                                                                  
                                                                                                                                                                                    
   select TO_CHAR(SysDate,'MM/DD/YYYY') into cbuf from dual;                                                                                                                        
   curr_line:=margin||'Date:  '||cbuf;                                                                                                                                              
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);                                                                                                                                 
                                                                                                                                                                                    
   curr_line:=margin||M_practice_id||' - '||M_prname;                                                                                                                               
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

                                                                                                                                                                                    
   P_code_area:='DETAILS';                                                                                                                                                          
   curr_line:=margin||'Laboratory #'||LTRIM(TO_CHAR(M_lab_number));                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
   curr_line:=margin||'Patient:          '||M_lname||', '||M_fname;                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'Date of Service:  '||M_date;                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
   if (M_dob is NOT NULL) then                                                                                                                                                      
      curr_line:=margin||'Date of Birth:    '||M_dob;                                                                                                                               
   end if;                                                                                                                                                                          
   if (M_ssn is NOT NULL) then                                                                                                                                                      
      curr_line:=margin||'SSN:              '||M_ssn;                                                                                                                               

   end if;                                                                                                                                                                          
   if (M_patid is NOT NULL) then                                                                                                                                                    
      curr_line:=margin||'Patient ID:       '||M_patid;                                                                                                                             
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   curr_line:=margin||'Dear Doctor/Nurse:';                                                                                                                                         
   UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);                                                                                                                                 
                                                                                                                                                                                    
   curr_line:=margin||'We received a Pap smear for the patient above. Since she is a Medicare';                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'patient we need to know whether she is LOW RISK (V76.2 or V72.31), HIGH';                                                                                    
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'RISK (V15.89) or if it was a DIAGNOSTIC PAP smear.  Please complete below';                                                                                  

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'so that we can submit the appropriate ICD-9 Diagnosis code(s) to Medicare.';                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);                                                                                                                                 
                                                                                                                                                                                    
   curr_line:=margin||'     SCREENING LOW RISK PAP (V76.2 OR V72.31):   _____';                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
                                                                                                                                                                                    
   curr_line:=margin||'     SCREENING HIGH RISK PAP (V15.89):           _____';                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);                                                                                                                                 
                                                                                                                                                                                    
   curr_line:=margin||'     DIAGNOSTIC PAP ICD-9 CODE:                  _____  _____  _____  _____';                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'     (Diagnostic Pap MUST include ICD-9 code(s) or it will be RETURNED)';                                                                                    

   UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);                                                                                                                                 
                                                                                                                                                                                    
   curr_line:=margin||'REMINDER: Please get signature for ALL Medicare patients on the front of our';                                                                               
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'requisition.  We are required to have their dated signature on the date a';                                                                                  
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'Pap smear is performed.  Signature on file is not acceptable.';                                                                                              
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
                                                                                                                                                                                    
   curr_line:=margin||'Please fax back to us at 412.373.7027 ASAP so we are not delayed in';                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   curr_line:=margin||'processing this patient''s Pap smear.  Many thanks.';                                                                                                        
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
   values (M_lab_number,'DIAGNOSIS',qmode,SysDate,M_origin);                                                                                                                        
                                                                                                                                                                                    
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
\
 
grant execute on build_diagnosis_letter to pcs_user ; 
\