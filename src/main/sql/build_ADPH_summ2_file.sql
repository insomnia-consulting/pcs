                                       
procedure     build_ADPH_summ2_file                                                                                                                                                 
(                                                                                                                                                                                   
   S_month in number,                                                                                                                                                               
   S_practice in number                                                                                                                                                             

)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   S_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
                                                                                                                                                                                    
   curr_line varchar2(300);                                                                                                                                                         
   line_num number;                                                                                                                                                                 

   curr_page number;                                                                                                                                                                
   rcnt number;                                                                                                                                                                     
   margin varchar2(32);                                                                                                                                                             
                                                                                                                                                                                    
   ADPH_lab number;                                                                                                                                                                 
   ADPH_patient varchar2(64);                                                                                                                                                       
   ADPH_patient_id varchar2(16);                                                                                                                                                    
   ADPH_DOS varchar2(16);                                                                                                                                                           
   ADPH_account number;                                                                                                                                                             
   ADPH_name  varchar2(64);                                                                                                                                                         
   ADPH_address1 varchar2(64);                                                                                                                                                      
   ADPH_address2 varchar2(64);                                                                                                                                                      
   ADPH_city varchar2(32);                                                                                                                                                          

   ADPH_state varchar2(2);                                                                                                                                                          
   ADPH_zip varchar2(5);                                                                                                                                                            
   ADPH_whp varchar2(128);                                                                                                                                                          
                                                                                                                                                                                    
   dline varchar2(256);                                                                                                                                                             
   heading1 varchar2(256);                                                                                                                                                          
   heading2 varchar2(256);                                                                                                                                                          
   heading3 varchar2(256);                                                                                                                                                          
   heading4 varchar2(256);                                                                                                                                                          
   heading5 varchar2(256);                                                                                                                                                          
   heading6 varchar2(256);                                                                                                                                                          
   heading7 varchar2(256);                                                                                                                                                          
                                                                                                                                                                                    

   cbuf1 varchar2(256);                                                                                                                                                             
   cbuf2 varchar2(256);                                                                                                                                                             
                                                                                                                                                                                    
   S_period varchar2(64);                                                                                                                                                           
                                                                                                                                                                                    
   last_date date;                                                                                                                                                                  
                                                                                                                                                                                    
   cursor ADPH_list is                                                                                                                                                              
      select practice,name,address1,address2,city,state,SUBSTR(zip,1,5)                                                                                                             
      from pcs.practices                                                                                                                                                            
      where practice_type='ADPH'                                                                                                                                                    
      and practice>=S_practice                                                                                                                                                      
      order by practice;                                                                                                                                                            

                                                                                                                                                                                    
   cursor patient_list is                                                                                                                                                           
      select DISTINCT(A.lab_number),B.patient_name,                                                                                                                                 
         NVL(A.patient_id,'  '),TO_CHAR(A.date_collected,'MM/DD/YYYY')                                                                                                              
      from pcs.lab_requisitions A,                                                                                                                                                  
         pcs.practice_statement_labs B,                                                                                                                                             
         pcs.adph_lab_whp C                                                                                                                                                         
      where A.lab_number=B.lab_number                                                                                                                                               
      and B.lab_number=C.lab_number                                                                                                                                                 
      and B.statement_id=S_month                                                                                                                                                    
      and B.practice=ADPH_account                                                                                                                                                   
      and C.adph_program=ADPH_whp                                                                                                                                                   
      order by TO_CHAR(A.date_collected,'MM/DD/YYYY'),A.lab_number;                                                                                                                 

                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   check_point number;                                                                                                                                                              
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_ADPH_SUMMARY_FILE';                                                                                                                                          
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   check_point:=0;                                                                                                                                                                  
   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));                                                                                                                         
   cbuf1:=TO_CHAR(last_date,'MONYYYY');                                                                                                                                             
   S_file_name:=cbuf1||'.wh2';                                                                                                                                                      

   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   S_period:=TO_CHAR(last_date,'MONTHYYYY');                                                                                                                                        
                                                                                                                                                                                    
   P_code_area:='HEADER';                                                                                                                                                           
   curr_page:=1;                                                                                                                                                                    
   margin:='  ';                                                                                                                                                                    
   dline:=margin||'--------------------------------------------------------------------------';                                                                                     
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';                                                                                                                              
   heading2:=margin||'MONTHLY SUMMARY OF WOMENS HEALTH PROGRAMS FOR ADPH';                                                                                                          
   heading3:=margin||'MONTH OF '||S_period;                                                                                                                                         
   heading4:=margin||'LAB#          PATIENT NAME                    ID#             SERVICE DATE';                                                                                  

                                                                                                                                                                                    
   line_num:=1;                                                                                                                                                                     
   curr_page:=1;                                                                                                                                                                    
                                                                                                                                                                                    
   P_code_area:='ADPH_LIST';                                                                                                                                                        
   open ADPH_list;                                                                                                                                                                  
   loop                                                                                                                                                                             
      fetch ADPH_list into ADPH_account,ADPH_name,ADPH_address1,ADPH_address2,                                                                                                      
         ADPH_city,ADPH_state,ADPH_zip;                                                                                                                                             
      exit when ADPH_list%NOTFOUND;                                                                                                                                                 
      P_code_area:='SUB_HEADING';                                                                                                                                                   
      curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),44);                                                                                                      
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;                                                                                                          

      UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;                                                                                                           
      UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;                                                                                                                         
      cbuf2:=margin||ADPH_name||':  CLINIC ACCOUNT #'||                                                                                                                             
         LTRIM(TO_CHAR(ADPH_account,'009'));                                                                                                                                        
      UTL_FILE.PUTF(file_handle,'%s\n',cbuf2); line_num:=line_num+1;                                                                                                                
      UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address1); line_num:=line_num+1;                                                                                                
      if (ADPH_address2 is NOT NULL) then                                                                                                                                           
         UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address2); line_num:=line_num+1;                                                                                             
      end if;                                                                                                                                                                       
      curr_line:=margin||ADPH_city||', '||ADPH_state||'  '||ADPH_zip;                                                                                                               
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;                                                                                                          
      ADPH_whp:='FP';                                                                                                                                                               

      select count(distinct A.lab_number) into rcnt                                                                                                                                 
      from pcs.practice_statement_labs A, pcs.adph_lab_whp B                                                                                                                        
      where A.lab_number=B.lab_number                                                                                                                                               
      and A.statement_id=S_month                                                                                                                                                    
      and A.practice=ADPH_account                                                                                                                                                   
      and B.adph_program=ADPH_whp;                                                                                                                                                  
      cbuf1:=margin||chr(27)||chr(71)||'             PATIENTS SEEN UNDER FAMILY PLANNING PROGRAM ['||LTRIM(RTRIM(TO_CHAR(rcnt)))||']'||chr(27)||chr(72);                            
      UTL_FILE.PUTF(file_handle,'%s\n',cbuf1); line_num:=line_num+1;                                                                                                                
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                                
      if (rcnt>0) then                                                                                                                                                              
         UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;                                                                                                          
         UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                             
      end if;                                                                                                                                                                       

      P_code_area:='FP_PATIENTS';                                                                                                                                                   
      open patient_list;                                                                                                                                                            
      loop                                                                                                                                                                          
         fetch patient_list into ADPH_lab,ADPH_patient,ADPH_patient_id,ADPH_DOS;                                                                                                    
         exit when patient_list%NOTFOUND;                                                                                                                                           
         if (line_num>=50) then                                                                                                                                                     
            curr_page:=curr_page+1;                                                                                                                                                 
            UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                      
            curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),44);                                                                                                
            line_num:=1;                                                                                                                                                            
            UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;                                                                                                    
            UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;                                                                                                       
            UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;                                                                                                     

            UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;                                                                                                                   
            cbuf2:=margin||ADPH_name||':  CLINIC ACCOUNT #'||                                                                                                                       
               LTRIM(TO_CHAR(ADPH_account,'009'));                                                                                                                                  
            UTL_FILE.PUTF(file_handle,'%s\n',cbuf2); line_num:=line_num+1;                                                                                                          
            UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address1); line_num:=line_num+1;                                                                                          
            if (ADPH_address2 is NOT NULL) then                                                                                                                                     
               UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address2); line_num:=line_num+1;                                                                                       
            end if;                                                                                                                                                                 
            curr_line:=margin||ADPH_city||', '||ADPH_state||'  '||ADPH_zip;                                                                                                         
            UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;                                                                                                    
         end if;                                                                                                                                                                    
         curr_line:=margin||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,32)||                                                                                                              
            RPAD(ADPH_patient_id,18)||ADPH_DOS;                                                                                                                                     

         UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;                                                                                                         
      end loop;                                                                                                                                                                     
      close patient_list;                                                                                                                                                           
      ADPH_whp:='MAT';                                                                                                                                                              
      select count(distinct A.lab_number) into rcnt                                                                                                                                 
      from pcs.practice_statement_labs A, pcs.adph_lab_whp B                                                                                                                        
      where A.lab_number=B.lab_number                                                                                                                                               
      and A.statement_id=S_month                                                                                                                                                    
      and A.practice=ADPH_account                                                                                                                                                   
      and B.adph_program=ADPH_whp;                                                                                                                                                  
      cbuf1:=margin||chr(27)||chr(71)||'                PATIENTS SEEN UNDER MATERNITY PROGRAM ['||LTRIM(RTRIM(TO_CHAR(rcnt)))||']'||chr(27)||chr(72);                               
      UTL_FILE.PUTF(file_handle,'\n%s\n',cbuf1); line_num:=line_num+2;                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                                

      if (rcnt>0) then                                                                                                                                                              
         UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;                                                                                                          
         UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                             
      end if;                                                                                                                                                                       
      P_code_area:='MAT_PATIENTS';                                                                                                                                                  
      open patient_list;                                                                                                                                                            
      loop                                                                                                                                                                          
         fetch patient_list into ADPH_lab,ADPH_patient,ADPH_patient_id,ADPH_DOS;                                                                                                    
         exit when patient_list%NOTFOUND;                                                                                                                                           
         if (line_num>=50) then                                                                                                                                                     
            curr_page:=curr_page+1;                                                                                                                                                 
            UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                      
            curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),44);                                                                                                

            line_num:=1;                                                                                                                                                            
            UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;                                                                                                    
            UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;                                                                                                       
            UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;                                                                                                     
            UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;                                                                                                                   
            cbuf2:=margin||ADPH_name||':  CLINIC ACCOUNT #'||                                                                                                                       
               LTRIM(TO_CHAR(ADPH_account,'009'));                                                                                                                                  
            UTL_FILE.PUTF(file_handle,'%s\n',cbuf2); line_num:=line_num+1;                                                                                                          
            UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address1); line_num:=line_num+1;                                                                                          
            if (ADPH_address2 is NOT NULL) then                                                                                                                                     
               UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address2); line_num:=line_num+1;                                                                                       
            end if;                                                                                                                                                                 
            curr_line:=margin||ADPH_city||', '||ADPH_state||'  '||ADPH_zip;                                                                                                         

            UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;                                                                                                    
         end if;                                                                                                                                                                    
         curr_line:=margin||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,32)||                                                                                                              
            RPAD(ADPH_patient_id,18)||ADPH_DOS;                                                                                                                                     
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;                                                                                                         
      end loop;                                                                                                                                                                     
      close patient_list;                                                                                                                                                           
      ADPH_whp:='ABCCEDP';                                                                                                                                                          
      select count(distinct A.lab_number) into rcnt                                                                                                                                 
      from pcs.practice_statement_labs A, pcs.adph_lab_whp B                                                                                                                        
      where A.lab_number=B.lab_number                                                                                                                                               
      and A.statement_id=S_month                                                                                                                                                    
      and A.practice=ADPH_account                                                                                                                                                   

      and B.adph_program=ADPH_whp;                                                                                                                                                  
      cbuf1:=margin||chr(27)||chr(71)||                                                                                                                                             
         '    PATIENTS SEEN UNDER ALABAMA BREAST AND CERVICAL CANCER PROGRAM ['||                                                                                                   
         LTRIM(RTRIM(TO_CHAR(rcnt)))||']'||chr(27)||chr(72);                                                                                                                        
      UTL_FILE.PUTF(file_handle,'\n%s\n',cbuf1); line_num:=line_num+2;                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                                
      if (rcnt>0) then                                                                                                                                                              
         UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;                                                                                                          
         UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                             
      end if;                                                                                                                                                                       
      P_code_area:='ABCCEDP_PATIENTS';                                                                                                                                              
      open patient_list;                                                                                                                                                            
      loop                                                                                                                                                                          

         fetch patient_list into ADPH_lab,ADPH_patient,ADPH_patient_id,ADPH_DOS;                                                                                                    
         exit when patient_list%NOTFOUND;                                                                                                                                           
         if (line_num>=50) then                                                                                                                                                     
            curr_page:=curr_page+1;                                                                                                                                                 
            UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                      
            curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),44);                                                                                                
            line_num:=1;                                                                                                                                                            
            UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;                                                                                                    
            UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;                                                                                                       
            UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;                                                                                                     
            UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;                                                                                                                   
            cbuf2:=margin||ADPH_name||':  CLINIC ACCOUNT #'||                                                                                                                       
               LTRIM(TO_CHAR(ADPH_account,'009'));                                                                                                                                  

            UTL_FILE.PUTF(file_handle,'%s\n',cbuf2); line_num:=line_num+1;                                                                                                          
            UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address1); line_num:=line_num+1;                                                                                          
            if (ADPH_address2 is NOT NULL) then                                                                                                                                     
               UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address2); line_num:=line_num+1;                                                                                       
            end if;                                                                                                                                                                 
            curr_line:=margin||ADPH_city||', '||ADPH_state||'  '||ADPH_zip;                                                                                                         
            UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;                                                                                                    
         end if;                                                                                                                                                                    
         curr_line:=margin||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,32)||                                                                                                              
            RPAD(ADPH_patient_id,18)||ADPH_DOS;                                                                                                                                     
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;                                                                                                         
      end loop;                                                                                                                                                                     
      close patient_list;                                                                                                                                                           

      ADPH_whp:='GYN';                                                                                                                                                              
      select count(distinct A.lab_number) into rcnt                                                                                                                                 
      from pcs.practice_statement_labs A, pcs.adph_lab_whp B                                                                                                                        
      where A.lab_number=B.lab_number                                                                                                                                               
      and A.statement_id=S_month                                                                                                                                                    
      and A.practice=ADPH_account                                                                                                                                                   
      and B.adph_program=ADPH_whp;                                                                                                                                                  
      cbuf1:=margin||chr(27)||chr(71)||                                                                                                                                             
         '                    PATIENTS SEEN UNDER GYN PROGRAM ['||                                                                                                                  
         LTRIM(RTRIM(TO_CHAR(rcnt)))||']'||chr(27)||chr(72);                                                                                                                        
      UTL_FILE.PUTF(file_handle,'\n%s\n',cbuf1); line_num:=line_num+2;                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                                
      if (rcnt>0) then                                                                                                                                                              

         UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;                                                                                                          
         UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                             
      end if;                                                                                                                                                                       
      P_code_area:='GYN_PATIENTS';                                                                                                                                                  
      open patient_list;                                                                                                                                                            
      loop                                                                                                                                                                          
         fetch patient_list into ADPH_lab,ADPH_patient,ADPH_patient_id,ADPH_DOS;                                                                                                    
         exit when patient_list%NOTFOUND;                                                                                                                                           
         if (line_num>=50) then                                                                                                                                                     
            curr_page:=curr_page+1;                                                                                                                                                 
            UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                      
            curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),44);                                                                                                
            line_num:=1;                                                                                                                                                            

            UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;                                                                                                    
            UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;                                                                                                       
            UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;                                                                                                     
            UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;                                                                                                                   
            cbuf2:=margin||ADPH_name||':  CLINIC ACCOUNT #'||                                                                                                                       
               LTRIM(TO_CHAR(ADPH_account,'009'));                                                                                                                                  
            UTL_FILE.PUTF(file_handle,'%s\n',cbuf2); line_num:=line_num+1;                                                                                                          
            UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address1); line_num:=line_num+1;                                                                                          
            if (ADPH_address2 is NOT NULL) then                                                                                                                                     
               UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address2); line_num:=line_num+1;                                                                                       
            end if;                                                                                                                                                                 
            curr_line:=margin||ADPH_city||', '||ADPH_state||'  '||ADPH_zip;                                                                                                         
            UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;                                                                                                    

         end if;                                                                                                                                                                    
         curr_line:=margin||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,32)||                                                                                                              
            RPAD(ADPH_patient_id,18)||ADPH_DOS;                                                                                                                                     
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;                                                                                                         
      end loop;                                                                                                                                                                     
      close patient_list;                                                                                                                                                           
      ADPH_whp:='NP';                                                                                                                                                               
      select count(distinct A.lab_number) into rcnt                                                                                                                                 
      from pcs.practice_statement_labs A, pcs.adph_lab_whp B                                                                                                                        
      where A.lab_number=B.lab_number                                                                                                                                               
      and A.statement_id=S_month                                                                                                                                                    
      and A.practice=ADPH_account                                                                                                                                                   
      and B.adph_program=ADPH_whp;                                                                                                                                                  

      cbuf1:=margin||chr(27)||chr(71)||'             PATIENTS SEEN WITHOUT PROGRAM IDENTIFICATION ['||LTRIM(RTRIM(TO_CHAR(rcnt)))||']'||chr(27)||chr(72);                           
      UTL_FILE.PUTF(file_handle,'\n%s\n',cbuf1); line_num:=line_num+2;                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                                
      if (rcnt>0) then                                                                                                                                                              
         UTL_FILE.PUTF(file_handle,'%s\n',heading4); line_num:=line_num+1;                                                                                                          
         UTL_FILE.PUTF(file_handle,'%s\n',dline); line_num:=line_num+1;                                                                                                             
      end if;                                                                                                                                                                       
      P_code_area:='NP_PATIENTS';                                                                                                                                                   
      open patient_list;                                                                                                                                                            
      loop                                                                                                                                                                          
         fetch patient_list into ADPH_lab,ADPH_patient,ADPH_patient_id,ADPH_DOS;                                                                                                    
         exit when patient_list%NOTFOUND;                                                                                                                                           
         if (line_num>=50) then                                                                                                                                                     

            curr_page:=curr_page+1;                                                                                                                                                 
            UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                      
            curr_line:=heading1||LPAD('PAGE '||LTRIM(RTRIM(TO_CHAR(curr_page))),44);                                                                                                
            line_num:=1;                                                                                                                                                            
            UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;                                                                                                    
            UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;                                                                                                       
            UTL_FILE.PUTF(file_handle,'%s\n\n',heading3); line_num:=line_num+2;                                                                                                     
            UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;                                                                                                                   
            cbuf2:=margin||ADPH_name||':  CLINIC ACCOUNT #'||                                                                                                                       
               LTRIM(TO_CHAR(ADPH_account,'009'));                                                                                                                                  
            UTL_FILE.PUTF(file_handle,'%s\n',cbuf2); line_num:=line_num+1;                                                                                                          
            UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address1); line_num:=line_num+1;                                                                                          
            if (ADPH_address2 is NOT NULL) then                                                                                                                                     

               UTL_FILE.PUTF(file_handle,'%s\n',margin||ADPH_address2); line_num:=line_num+1;                                                                                       
            end if;                                                                                                                                                                 
            curr_line:=margin||ADPH_city||', '||ADPH_state||'  '||ADPH_zip;                                                                                                         
            UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;                                                                                                    
         end if;                                                                                                                                                                    
         curr_line:=margin||RPAD(ADPH_lab,14)||RPAD(ADPH_patient,32)||                                                                                                              
            RPAD(ADPH_patient_id,18)||ADPH_DOS;                                                                                                                                     
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;                                                                                                         
      end loop;                                                                                                                                                                     
      close patient_list;                                                                                                                                                           
      UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                            
      curr_page:=1;                                                                                                                                                                 
      line_num:=1;                                                                                                                                                                  

   end loop;                                                                                                                                                                        
   close ADPH_list;                                                                                                                                                                 
   commit;                                                                                                                                                                          
                                                                                                                                                                                    
   UTL_FILE.PUTF(file_handle,'\n%s\n',dline);                                                                                                                                       
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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                                            
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,ADPH_lab);                                                                                           
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                                                                                                                                         