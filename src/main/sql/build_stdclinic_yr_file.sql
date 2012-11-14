create or replace procedure     build_stdclinic_yr_file                                                                                                                                               

(                                                                                                                                                                                   
   S_year in number                                                                                                                                                                 
)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   L_patient_id varchar2(20);                                                                                                                                                       
   L_fname varchar2(20);                                                                                                                                                            
   L_mi char(1);                                                                                                                                                                    

   L_lname varchar2(20);                                                                                                                                                            
   L_dob char(10);                                                                                                                                                                  
   L_gender char(1);                                                                                                                                                                
   L_race char(1);                                                                                                                                                                  
   L_ethnicity char(1);                                                                                                                                                             
   L_street1 varchar2(30);                                                                                                                                                          
   L_city varchar2(20);                                                                                                                                                             
   L_county varchar2(20);                                                                                                                                                           
   L_state char(2);                                                                                                                                                                 
   L_zip char(5);                                                                                                                                                                   
   L_phone varchar2(24);                                                                                                                                                            
   L_age varchar2(19);                                                                                                                                                              
   L_provider_name varchar2(30);                                                                                                                                                    

   L_accession_no varchar2(15);                                                                                                                                                     
   L_collect_date char(10);                                                                                                                                                         
   L_receive_date varchar2(31);                                                                                                                                                     
   L_clia varchar2(10);                                                                                                                                                             
   L_lab_name varchar2(10);                                                                                                                                                         
   L_analysis_date char(10);                                                                                                                                                        
   L_test_type varchar2(30);                                                                                                                                                        
   L_quan_results varchar2(2);                                                                                                                                                      
   L_description varchar2(3);                                                                                                                                                       
   L_slide_number varchar2(5);                                                                                                                                                      
   L_lmp char(10);                                                                                                                                                                  
   L_radiation varchar2(20);                                                                                                                                                        
   L_last_abnormal char(10);                                                                                                                                                        

   L_cytotech varchar2(4);                                                                                                                                                          
   L_pathologist varchar2(4);                                                                                                                                                       
   L_contraceptive varchar2(3);                                                                                                                                                     
   L_contraceptive_type varchar2(3);                                                                                                                                                
                                                                                                                                                                                    
   L_prep number;                                                                                                                                                                   
   L_tech number;                                                                                                                                                                   
   L_lab_number number;                                                                                                                                                             
   L_qc char(1);                                                                                                                                                                    
   L_path char(1);                                                                                                                                                                  
   L_test_char varchar2(2);                                                                                                                                                         
   L_has_200 char(1);                                                                                                                                                               
   L_has_200X char(1);                                                                                                                                                              

                                                                                                                                                                                    
   S_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
   curr_line varchar2(410);                                                                                                                                                         
   cbuf varchar2(128);                                                                                                                                                              
   cbuf2 varchar2(128);                                                                                                                                                             
   line_num number;                                                                                                                                                                 
   num_records number;                                                                                                                                                              
   rcnt number;                                                                                                                                                                     
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
   cursor clinic_list is select * from pcs.practices where std_clinic='Y';                                                                                                          

   --cursor clinic_list is select * from pcs.practices where practice=602;                                                                                                          
   clinic_fields clinic_list%ROWTYPE;                                                                                                                                               
                                                                                                                                                                                    
   cursor lab_list is                                                                                                                                                               
      select L.patient_id,P.fname,P.mi,P.lname,TO_CHAR(P.dob,'MM/DD/YYYY'),                                                                                                         
         SUBSTR(P.address1,1,30),SUBSTR(P.city,1,20),                                                                                                                               
         P.state,SUBSTR(P.zip,1,5),P.phone,RTRIM(LTRIM(TO_CHAR(L.age))),                                                                                                            
         RTRIM(LTRIM(TO_CHAR(L.lab_number))),                                                                                                                                       
         TO_CHAR(L.date_collected,'MM/DD/YYYY'),                                                                                                                                    
         TO_CHAR(L.receive_date,'MM/DD/YYYY'),                                                                                                                                      
         TO_CHAR(R.date_completed,'MM/DD/YYYY'),L.preparation,R.cytotech,                                                                                                           
         R.pathologist,L.lab_number,R.qc_status,R.path_status                                                                                                                       
      from pcs.lab_requisitions L, pcs.patients P, pcs.lab_results R                                                                                                                

      where L.lab_number=R.lab_number and L.patient=P.patient and                                                                                                                   
         L.practice=clinic_fields.practice and                                                                                                                                      
         TO_NUMBER(TO_CHAR(R.datestamp,'YYYY'))=S_year;                                                                                                                             
                                                                                                                                                                                    
   cursor result_list is select * from pcs.lab_result_codes                                                                                                                         
   where lab_number=L_lab_number order by bethesda_code;                                                                                                                            
   result_fields result_list%ROWTYPE;                                                                                                                                               
                                                                                                                                                                                    
   cursor qc_list is select * from pcs.quality_control_codes                                                                                                                        
   where lab_number=L_lab_number order by bethesda_code;                                                                                                                            
   qc_fields qc_list%ROWTYPE;                                                                                                                                                       
                                                                                                                                                                                    
   cursor path_list is select * from pcs.pathologist_control_codes                                                                                                                  

   where lab_number=L_lab_number order by bethesda_code;                                                                                                                            
   path_fields path_list%ROWTYPE;                                                                                                                                                   
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_STDCLINIC_FILE';                                                                                                                                             
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   /*                                                                                                                                                                               
      Initializations                                                                                                                                                               
   */                                                                                                                                                                               
   cbuf:=RTRIM(LTRIM(TO_CHAR(S_year)));                                                                                                                                             
   S_file_name:=cbuf||'.std';                                                                                                                                                       

   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                           
   L_race:=' ';                                                                                                                                                                     
   L_ethnicity:=' ';                                                                                                                                                                
   select SUBSTR(id_number,1,10) into L_clia                                                                                                                                        
   from pcs.business_id_nums where id_code='CLIA';                                                                                                                                  
   L_clia:=RPAD(L_clia,10);                                                                                                                                                         
   L_lab_name:='PACYTOLOGY';                                                                                                                                                        
   L_slide_number:=RPAD(' ',5);                                                                                                                                                     
   L_lmp:=RPAD(' ',10);                                                                                                                                                             
   L_radiation:=RPAD(' ',20);                                                                                                                                                       
   L_last_abnormal:=RPAD(' ',10);                                                                                                                                                   
   L_gender:='F';                                                                                                                                                                   

                                                                                                                                                                                    
   curr_line:=RPAD('PATIENT ID',20)||RPAD('FIRST NAME',20)||' '||RPAD('LAST NAME',20)||RPAD('DOB',10)||                                                                             
            ' '||' '||' '||RPAD('STREET 1',30)||RPAD('CITY',20)||                                                                                                                   
            RPAD('COUNTY',20)||'ST'||'ZIP  '||RPAD('PHONE',12)||RPAD(' ',11)||'AGE'||RPAD(' ',15)||RPAD('PROVIDER NAME',30)||                                                       
            RPAD('ACCESSION NO',15)||RPAD('COLLECTED',10)||RPAD('RECEIVED',30)||RPAD('CLIA',10)||                                                                                   
            RPAD('LAB NAME',10)||RPAD('ANALYZED',10)||RPAD('TEST TYPE',30)||'  '||                                                                                                  
            '   '||'SLIDE'||RPAD('LMP',10)||RPAD('RADIATION',20)||                                                                                                                  
            RPAD('ABNORMAL',10)||'CYT '||'PTH '||'CONTR'||                                                                                                                          
            L_contraceptive_type;                                                                                                                                                   
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
                                                                                                                                                                                    
   P_code_area:='CLINIC LIST';                                                                                                                                                      
   open clinic_list;                                                                                                                                                                

   loop                                                                                                                                                                             
      <<loop_top>>                                                                                                                                                                  
      fetch clinic_list into clinic_fields;                                                                                                                                         
      exit when clinic_list%NOTFOUND;                                                                                                                                               
      open lab_list;                                                                                                                                                                
      loop                                                                                                                                                                          
         fetch lab_list into L_patient_id,L_fname,L_mi,L_lname,L_dob,L_street1,                                                                                                     
            L_city,L_state,L_zip,L_phone,L_age,L_accession_no,                                                                                                                      
            L_collect_date,L_receive_date,L_analysis_date,L_prep,L_tech,                                                                                                            
            L_pathologist,L_lab_number,L_qc,L_path;                                                                                                                                 
         exit when lab_list%NOTFOUND;                                                                                                                                               
         P_code_area:='CL LIST '||L_accession_no;                                                                                                                                   
         if (L_patient_id is NULL) then L_patient_id:=' ';                                                                                                                          

         end if;                                                                                                                                                                    
         L_patient_id:=RPAD(L_patient_id,20);                                                                                                                                       
         if (L_fname is NULL) then L_fname:=' ';                                                                                                                                    
         end if;                                                                                                                                                                    
         L_fname:=RPAD(L_fname,20);                                                                                                                                                 
         if (L_mi) is null then L_mi:=' ';                                                                                                                                          
         end if;                                                                                                                                                                    
         if (L_lname is NULL) then L_lname:=' ';                                                                                                                                    
         end if;                                                                                                                                                                    
         L_lname:=RPAD(L_lname,20);                                                                                                                                                 
         if (L_dob) is null then L_dob:=RPAD(' ',10);                                                                                                                               
         end if;                                                                                                                                                                    
         if (L_street1 is NULL) then L_street1:=' ';                                                                                                                                

         end if;                                                                                                                                                                    
         L_street1:=RPAD(L_street1,30);                                                                                                                                             
         if (L_city is NULL) then L_city:=' ';                                                                                                                                      
         end if;                                                                                                                                                                    
         L_city:=RPAD(L_city,20);                                                                                                                                                   
         L_county:=NULL;                                                                                                                                                            
         if (L_zip is NOT NULL) then                                                                                                                                                
            select count(*) into rcnt from pcs.zipcodes where zip=L_zip;                                                                                                            
            if (rcnt>0) then                                                                                                                                                        
               select SUBSTR(county_name,1,20) into L_county                                                                                                                        
               from pcs.zipcodes where zip=L_zip;                                                                                                                                   
            end if;                                                                                                                                                                 
         end if;                                                                                                                                                                    

         if (L_county is NULL) then L_county:=' ';                                                                                                                                  
         end if;                                                                                                                                                                    
         L_county:=RPAD(L_county,20);                                                                                                                                               
         if (L_state is NULL) then L_state:='  ';                                                                                                                                   
         end if;                                                                                                                                                                    
         if (L_zip is NULL) then L_zip:='     ';                                                                                                                                    
         end if;                                                                                                                                                                    
         if (L_phone is NULL) then L_phone:=' ';                                                                                                                                    
         end if;                                                                                                                                                                    
         L_phone:=RPAD(L_phone,23);                                                                                                                                                 
         if (L_age is NULL) then L_age:=' ';                                                                                                                                        
         end if;                                                                                                                                                                    
         L_age:=RPAD(L_age,18);                                                                                                                                                     

         L_provider_name:=SUBSTR(clinic_fields.name,1,30);                                                                                                                          
         L_provider_name:=RPAD(L_provider_name,30);                                                                                                                                 
         L_accession_no:=RPAD(L_accession_no,15);                                                                                                                                   
         if (L_collect_date is NULL) then L_collect_date:=' ';                                                                                                                      
         end if;                                                                                                                                                                    
         L_collect_date:=RPAD(L_collect_date,10);                                                                                                                                   
         if (L_receive_date is NULL) then L_receive_date:=' ';                                                                                                                      
         end if;                                                                                                                                                                    
         L_receive_date:=RPAD(L_receive_date,30);                                                                                                                                   
         if (L_qc='Y') then                                                                                                                                                         
            select TO_CHAR(qc_date,'MM/DD/YYYY'),cytotech                                                                                                                           
            into L_analysis_date,L_tech from pcs.quality_control                                                                                                                    
            where lab_number=L_lab_number;                                                                                                                                          

         end if;                                                                                                                                                                    
         if (L_analysis_date is NULL) then L_analysis_date:=' ';                                                                                                                    
         end if;                                                                                                                                                                    
         L_analysis_date:=RPAD(L_analysis_date,10);                                                                                                                                 
         select cytotech_code into L_cytotech from pcs.cytotechs                                                                                                                    
         where cytotech=L_tech;                                                                                                                                                     
         if (L_cytotech is NULL) then L_cytotech:=' ';                                                                                                                              
         end if;                                                                                                                                                                    
         L_cytotech:=RPAD(L_cytotech,4);                                                                                                                                            
         if (L_pathologist is NULL) then L_pathologist:=' ';                                                                                                                        
         end if;                                                                                                                                                                    
         L_pathologist:=RPAD(L_pathologist,3);                                                                                                                                      
         if (L_prep=2) then                                                                                                                                                         

            L_test_type:='THIN PREP PAP SMEAR';                                                                                                                                     
         else                                                                                                                                                                       
            L_test_type:='CONVENTIONAL PAP SMEAR';                                                                                                                                  
         end if;                                                                                                                                                                    
         L_test_type:=RPAD(L_test_type,30);                                                                                                                                         
         L_quan_results:=NULL;                                                                                                                                                      
         L_has_200:='N';                                                                                                                                                            
         L_has_200X:='N';                                                                                                                                                           
         P_code_area:='BCODES';                                                                                                                                                     
         if (L_path='Y') then                                                                                                                                                       
            P_code_area:='BCODES PATH';                                                                                                                                             
            open path_list;                                                                                                                                                         
            loop                                                                                                                                                                    

               fetch path_list into path_fields;                                                                                                                                    
               exit when path_list%NOTFOUND;                                                                                                                                        
               L_test_char:=SUBSTR(path_fields.bethesda_code,1,2);                                                                                                                  
               if (L_test_char='40') then                                                                                                                                           
                  L_quan_results:='0';                                                                                                                                              
               elsif (path_fields.bethesda_code in ('305','308','309','313')) then                                                                                                  
                  if (L_has_200<>'Y') then                                                                                                                                          
                     L_quan_results:='0';                                                                                                                                           
                  end if;                                                                                                                                                           
               elsif (path_fields.bethesda_code in ('204','205')) then                                                                                                              
                  L_quan_results:='1';                                                                                                                                              
                  L_has_200:='Y';                                                                                                                                                   
               elsif (path_fields.bethesda_code in ('200','202','207')) then                                                                                                        

                  L_quan_results:='2';                                                                                                                                              
                  L_has_200:='Y';                                                                                                                                                   
               elsif (path_fields.bethesda_code in ('100','101')) then                                                                                                              
                  L_quan_results:='3';                                                                                                                                              
               elsif (L_test_char='09') then                                                                                                                                        
                  L_quan_results:='4';                                                                                                                                              
               elsif (path_fields.bethesda_code in ('300','302','303','304','306','307')) then                                                                                      
                  if (L_has_200<>'Y') then                                                                                                                                          
                     L_quan_results:='5';                                                                                                                                           
                  end if;                                                                                                                                                           
               elsif (L_test_char in ('02','03','04')) then                                                                                                                         
                  L_quan_results:='6';                                                                                                                                              
               elsif (path_fields.bethesda_code in ('014','14R')) then                                                                                                              

                  L_quan_results:='7';                                                                                                                                              
               elsif (L_test_char='87') then                                                                                                                                        
                  L_quan_results:='8';                                                                                                                                              
               end if;                                                                                                                                                              
               if (L_test_char='40') then                                                                                                                                           
                  L_description:='000';                                                                                                                                             
               elsif (path_fields.bethesda_code in ('305','308','309','313')) then                                                                                                  
                  if (L_has_200X<>'Y') then                                                                                                                                         
                     L_description:='000';                                                                                                                                          
                  end if;                                                                                                                                                           
               elsif (path_fields.bethesda_code in ('204','205')) then                                                                                                              
                  L_description:='100';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  

               elsif (path_fields.bethesda_code='200') then                                                                                                                         
                  L_description:='200';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  
               elsif (path_fields.bethesda_code='202') then                                                                                                                         
                  L_description:='201';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  
               elsif (path_fields.bethesda_code='101') then                                                                                                                         
                  L_description:='300';                                                                                                                                             
               elsif (path_fields.bethesda_code='100') then                                                                                                                         
                  L_description:='301';                                                                                                                                             
               elsif (L_test_char='90') then                                                                                                                                        
                  L_description:='400';                                                                                                                                             
               elsif (path_fields.bethesda_code in ('300','302','303','304','306','307')) then                                                                                      

                  if (L_has_200X<>'Y') then                                                                                                                                         
                     L_description:='500';                                                                                                                                          
                  end if;                                                                                                                                                           
               elsif (L_test_char='02') then                                                                                                                                        
                  L_description:='600';                                                                                                                                             
               elsif (path_fields.bethesda_code='053') then                                                                                                                         
                  L_description:='601';                                                                                                                                             
               elsif (path_fields.bethesda_code in ('052','054','055','056','057')) then                                                                                            
                  L_description:='603';                                                                                                                                             
               elsif (path_fields.bethesda_code in ('014','14R')) then                                                                                                              
                  L_description:='700';                                                                                                                                             
               elsif (path_fields.bethesda_code='871') then                                                                                                                         
                  L_description:='800';                                                                                                                                             

               elsif (path_fields.bethesda_code='870') then                                                                                                                         
                  L_description:='801';                                                                                                                                             
               elsif (path_fields.bethesda_code='873') then                                                                                                                         
                  L_description:='802';                                                                                                                                             
               elsif (path_fields.bethesda_code='876') then                                                                                                                         
                  L_description:='803';                                                                                                                                             
               elsif (path_fields.bethesda_code='851') then                                                                                                                         
                  L_description:='804';                                                                                                                                             
               elsif (path_fields.bethesda_code='878') then                                                                                                                         
                  L_description:='806';                                                                                                                                             
               end if;                                                                                                                                                              
            end loop;                                                                                                                                                               
            close path_list;                                                                                                                                                        

         elsif (L_qc='Y') then                                                                                                                                                      
            P_code_area:='BCODES QC';                                                                                                                                               
            line_num:=0;                                                                                                                                                            
            open qc_list;                                                                                                                                                           
            loop                                                                                                                                                                    
               line_num:=line_num+1;                                                                                                                                                
               fetch qc_list into qc_fields;                                                                                                                                        
               exit when qc_list%NOTFOUND;                                                                                                                                          
               L_test_char:=SUBSTR(qc_fields.bethesda_code,1,2);                                                                                                                    
               if (L_test_char='40') then                                                                                                                                           
                  L_quan_results:='0';                                                                                                                                              
               elsif (qc_fields.bethesda_code in ('305','308','309','313')) then                                                                                                    
                  if (L_has_200<>'Y') then                                                                                                                                          

                     L_quan_results:='0';                                                                                                                                           
                  end if;                                                                                                                                                           
               elsif (qc_fields.bethesda_code in ('204','205')) then                                                                                                                
                  L_quan_results:='1';                                                                                                                                              
                  L_has_200:='Y';                                                                                                                                                   
               elsif (qc_fields.bethesda_code in ('200','202','207')) then                                                                                                          
                  L_quan_results:='2';                                                                                                                                              
                  L_has_200:='Y';                                                                                                                                                   
               elsif (qc_fields.bethesda_code in ('100','101')) then                                                                                                                
                  L_quan_results:='3';                                                                                                                                              
               elsif (L_test_char='09') then                                                                                                                                        
                  L_quan_results:='4';                                                                                                                                              
               elsif (qc_fields.bethesda_code in ('300','302','303','304','306','307')) then                                                                                        

                  if (L_has_200<>'Y') then                                                                                                                                          
                     L_quan_results:='5';                                                                                                                                           
                  end if;                                                                                                                                                           
               elsif (L_test_char in ('02','03','04')) then                                                                                                                         
                  L_quan_results:='6';                                                                                                                                              
               elsif (qc_fields.bethesda_code in ('014','14R')) then                                                                                                                
                  L_quan_results:='7';                                                                                                                                              
               elsif (L_test_char='87') then                                                                                                                                        
                  L_quan_results:='8';                                                                                                                                              
               end if;                                                                                                                                                              
               if (L_test_char='40') then                                                                                                                                           
                  L_description:='000';                                                                                                                                             
               elsif (qc_fields.bethesda_code in ('305','308','309','313')) then                                                                                                    

                  if (L_has_200X<>'Y') then                                                                                                                                         
                     L_description:='000';                                                                                                                                          
                  end if;                                                                                                                                                           
               elsif (qc_fields.bethesda_code in ('204','205')) then                                                                                                                
                  L_description:='100';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  
               elsif (qc_fields.bethesda_code='200') then                                                                                                                           
                  L_description:='200';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  
               elsif (qc_fields.bethesda_code='202') then                                                                                                                           
                  L_description:='201';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  
               elsif (qc_fields.bethesda_code='101') then                                                                                                                           

                  L_description:='300';                                                                                                                                             
               elsif (qc_fields.bethesda_code='100') then                                                                                                                           
                  L_description:='301';                                                                                                                                             
               elsif (L_test_char='90') then                                                                                                                                        
                  L_description:='400';                                                                                                                                             
               elsif (qc_fields.bethesda_code in ('300','302','303','304','306','307')) then                                                                                        
                  if (L_has_200X<>'Y') then                                                                                                                                         
                     L_description:='500';                                                                                                                                          
                  end if;                                                                                                                                                           
               elsif (L_test_char='02') then                                                                                                                                        
                  L_description:='600';                                                                                                                                             
               elsif (qc_fields.bethesda_code='053') then                                                                                                                           
                  L_description:='601';                                                                                                                                             

               elsif (qc_fields.bethesda_code in ('052','054','055','056','057')) then                                                                                              
                  L_description:='603';                                                                                                                                             
               elsif (qc_fields.bethesda_code in ('014','14R')) then                                                                                                                
                  L_description:='700';                                                                                                                                             
               elsif (qc_fields.bethesda_code='871') then                                                                                                                           
                  L_description:='800';                                                                                                                                             
               elsif (qc_fields.bethesda_code='870') then                                                                                                                           
                  L_description:='801';                                                                                                                                             
               elsif (qc_fields.bethesda_code='873') then                                                                                                                           
                  L_description:='802';                                                                                                                                             
               elsif (qc_fields.bethesda_code='876') then                                                                                                                           
                  L_description:='803';                                                                                                                                             
               elsif (qc_fields.bethesda_code='851') then                                                                                                                           

                  L_description:='804';                                                                                                                                             
               elsif (qc_fields.bethesda_code='878') then                                                                                                                           
                  L_description:='806';                                                                                                                                             
               end if;                                                                                                                                                              
            end loop;                                                                                                                                                               
            close qc_list;                                                                                                                                                          
         else                                                                                                                                                                       
            P_code_area:='BCODES SCR';                                                                                                                                              
            open result_list;                                                                                                                                                       
            loop                                                                                                                                                                    
               fetch result_list into result_fields;                                                                                                                                
               exit when result_list%NOTFOUND;                                                                                                                                      
               L_test_char:=SUBSTR(result_fields.bethesda_code,1,2);                                                                                                                

               if (L_test_char='40') then                                                                                                                                           
                  L_quan_results:='0';                                                                                                                                              
               elsif (result_fields.bethesda_code in ('305','308','309','313')) then                                                                                                
                  if (L_has_200<>'Y') then                                                                                                                                          
                     L_quan_results:='0';                                                                                                                                           
                  end if;                                                                                                                                                           
               elsif (result_fields.bethesda_code in ('204','205')) then                                                                                                            
                  L_quan_results:='1';                                                                                                                                              
                  L_has_200:='Y';                                                                                                                                                   
               elsif (result_fields.bethesda_code in ('200','202','207')) then                                                                                                      
                  L_quan_results:='2';                                                                                                                                              
                  L_has_200:='Y';                                                                                                                                                   
               elsif (result_fields.bethesda_code in ('100','101')) then                                                                                                            

                  L_quan_results:='3';                                                                                                                                              
               elsif (L_test_char='09') then                                                                                                                                        
                  L_quan_results:='4';                                                                                                                                              
               elsif (result_fields.bethesda_code in ('300','302','303','304','306','307')) then                                                                                    
                  if (L_has_200<>'Y') then                                                                                                                                          
                     L_quan_results:='5';                                                                                                                                           
                  end if;                                                                                                                                                           
               elsif (L_test_char in ('02','03','04')) then                                                                                                                         
                  L_quan_results:='6';                                                                                                                                              
               elsif (result_fields.bethesda_code in ('014','14R')) then                                                                                                            
                  L_quan_results:='7';                                                                                                                                              
               elsif (L_test_char='87') then                                                                                                                                        
                  L_quan_results:='8';                                                                                                                                              

               end if;                                                                                                                                                              
               if (L_test_char='40') then                                                                                                                                           
                  L_description:='000';                                                                                                                                             
               elsif (result_fields.bethesda_code in ('305','308','309','313')) then                                                                                                
                  if (L_has_200X<>'Y') then                                                                                                                                         
                     L_description:='000';                                                                                                                                          
                  end if;                                                                                                                                                           
               elsif (result_fields.bethesda_code in ('204','205')) then                                                                                                            
                  L_description:='100';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  
               elsif (result_fields.bethesda_code='200') then                                                                                                                       
                  L_description:='200';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  

               elsif (result_fields.bethesda_code='202') then                                                                                                                       
                  L_description:='201';                                                                                                                                             
                  L_has_200X:='Y';                                                                                                                                                  
               elsif (result_fields.bethesda_code='101') then                                                                                                                       
                  L_description:='300';                                                                                                                                             
               elsif (result_fields.bethesda_code='100') then                                                                                                                       
                  L_description:='301';                                                                                                                                             
               elsif (L_test_char='90') then                                                                                                                                        
                  L_description:='400';                                                                                                                                             
               elsif (result_fields.bethesda_code in ('300','302','303','304','306','307')) then                                                                                    
                  if (L_has_200X<>'Y') then                                                                                                                                         
                     L_description:='500';                                                                                                                                          
                  end if;                                                                                                                                                           

               elsif (L_test_char='02') then                                                                                                                                        
                  L_description:='600';                                                                                                                                             
               elsif (result_fields.bethesda_code='053') then                                                                                                                       
                  L_description:='601';                                                                                                                                             
               elsif (result_fields.bethesda_code in ('052','054','055','056','057')) then                                                                                          
                  L_description:='603';                                                                                                                                             
               elsif (result_fields.bethesda_code in ('014','14R')) then                                                                                                            
                  L_description:='700';                                                                                                                                             
               elsif (result_fields.bethesda_code='871') then                                                                                                                       
                  L_description:='800';                                                                                                                                             
               elsif (result_fields.bethesda_code='870') then                                                                                                                       
                  L_description:='801';                                                                                                                                             
               elsif (result_fields.bethesda_code='873') then                                                                                                                       

                  L_description:='802';                                                                                                                                             
               elsif (result_fields.bethesda_code='876') then                                                                                                                       
                  L_description:='803';                                                                                                                                             
               elsif (result_fields.bethesda_code='851') then                                                                                                                       
                  L_description:='804';                                                                                                                                             
               elsif (result_fields.bethesda_code='878') then                                                                                                                       
                  L_description:='806';                                                                                                                                             
               end if;                                                                                                                                                              
            end loop;                                                                                                                                                               
            close result_list;                                                                                                                                                      
         end if;                                                                                                                                                                    
         if (L_quan_results is NULL) then L_quan_results:='9';                                                                                                                      
         end if;                                                                                                                                                                    

         if (L_description is NULL) then L_description:='902';                                                                                                                      
         end if;                                                                                                                                                                    
         L_quan_results:=RPAD(L_quan_results,2);                                                                                                                                    
         L_description:=RPAD(L_description,3);                                                                                                                                      
         L_contraceptive:='NO ';                                                                                                                                                    
         L_contraceptive_type:='   ';                                                                                                                                               
         select count(*) into rcnt from pcs.lab_req_details                                                                                                                         
         where lab_number=L_lab_number and detail_code=40;                                                                                                                          
         if (rcnt>0) then                                                                                                                                                           
            L_contraceptive:='YES';                                                                                                                                                 
            L_contraceptive_type:='4  ';                                                                                                                                            
         end if;                                                                                                                                                                    
         select count(*) into rcnt from pcs.lab_req_details                                                                                                                         

         where lab_number=L_lab_number and detail_code=43;                                                                                                                          
         if (rcnt>0) then                                                                                                                                                           
            L_contraceptive:='YES';                                                                                                                                                 
            L_contraceptive_type:='2  ';                                                                                                                                            
         end if;                                                                                                                                                                    
         P_code_area:='FORMAT LINE';                                                                                                                                                
         curr_line:=NULL;                                                                                                                                                           
         curr_line:=L_patient_id||L_fname||L_mi||L_lname||L_dob||                                                                                                                   
            L_gender||L_race||L_ethnicity||L_street1||L_city||                                                                                                                      
            L_county||L_state||L_zip||L_phone||L_age||L_provider_name||                                                                                                             
            L_accession_no||L_collect_date||L_receive_date||L_clia||                                                                                                                
            L_lab_name||L_analysis_date||L_test_type||L_quan_results||                                                                                                              
            L_description||L_slide_number||L_lmp||L_radiation||                                                                                                                     

            L_last_abnormal||L_cytotech||L_pathologist||L_contraceptive||                                                                                                           
            L_contraceptive_type;                                                                                                                                                   
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
      end loop;                                                                                                                                                                     
      close lab_list;                                                                                                                                                               
   end loop;                                                                                                                                                                        
   close clinic_list;                                                                                                                                                               
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_lab_number);                                                                                       
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;            
\

grant execute on build_stdclinic_yr_file to pcs_user ; 
\
