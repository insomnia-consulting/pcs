                                       
procedure     build_doc_summ_ptype                                                                                                                                                  
(                                                                                                                                                                                   
   S_month in number,                                                                                                                                                               
   P_type in varchar2,                                                                                                                                                              
   P_program in varchar2                                                                                                                                                            

)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   P_name varchar2(64);                                                                                                                                                             
   P_address1 varchar2(64);                                                                                                                                                         
   P_address2 varchar2(64);                                                                                                                                                         
   P_city varchar2(32);                                                                                                                                                             
   P_state char(2);                                                                                                                                                                 

   P_zip varchar2(9);                                                                                                                                                               
                                                                                                                                                                                    
   invoice_date varchar2(16);                                                                                                                                                       
   invoice_number varchar2(16);                                                                                                                                                     
   f_date date;                                                                                                                                                                     
                                                                                                                                                                                    
   cbuf1 varchar2(256);                                                                                                                                                             
   cbuf2 varchar2(256);                                                                                                                                                             
   cbuf3 varchar2(256);                                                                                                                                                             
   cbuf4 varchar2(256);                                                                                                                                                             
                                                                                                                                                                                    
   C_pap_class number(2);                                                                                                                                                           
   C_pap_descr varchar2(4000);                                                                                                                                                      

                                                                                                                                                                                    
   /* Class 8 is combined with Class 6                                                                                                                                              
      Class 0 is unknown and Class 10 is unused                                                                                                                                     
      In actuality both 0 and 10 are unused                                                                                                                                         
   */                                                                                                                                                                               
   cursor papclass_list is                                                                                                                                                          
      select pap_class,description,tmp_num from pcs.pap_classes                                                                                                                     
      where reporting_sort is NOT NULL order by reporting_sort                                                                                                                      
   for update;                                                                                                                                                                      
                                                                                                                                                                                    
   cursor lab_list is                                                                                                                                                               
      select SUBSTR(TO_CHAR(lq.lab_number),5,10),                                                                                                                                   
         RTRIM(p.lname)||', '||RTRIM(p.fname),                                                                                                                                      

         TO_CHAR(lq.date_collected,'MM/DD/YY'),lq.doctor_text,                                                                                                                      
         lq.patient_id,lq.lab_number,p.ssn                                                                                                                                          
      from pcs.lab_requisitions lq, pcs.patients p, pcs.doc_sum_work dw                                                                                                             
      where lq.patient=p.patient                                                                                                                                                    
      and lq.lab_number=dw.lab_number and dw.pap_class=C_pap_class                                                                                                                  
      order by p.lname, p.fname;                                                                                                                                                    
                                                                                                                                                                                    
   cursor adequacy_list is                                                                                                                                                          
      select row_id,message_text                                                                                                                                                    
      from pcs.temp_table                                                                                                                                                           
      where message_text like '%[6M]%'                                                                                                                                              
      order by message_text;                                                                                                                                                        
                                                                                                                                                                                    

   S_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
   practice_id varchar2(16);                                                                                                                                                        
   S_lab varchar2(16);                                                                                                                                                              
   S_name varchar2(64);                                                                                                                                                             
   S_date varchar2(8);                                                                                                                                                              
   S_period char(10);                                                                                                                                                               
   S_patient_id varchar2(16);                                                                                                                                                       
   s_patient_SSN varchar2(16);                                                                                                                                                      
   curr_line varchar2(256);                                                                                                                                                         
   heading varchar2(100);                                                                                                                                                           
   heading2 varchar2(100);                                                                                                                                                          
   heading3 varchar2(100);                                                                                                                                                          

   heading4 varchar2(100);                                                                                                                                                          
   cbuf varchar2(128);                                                                                                                                                              
   line_num number;                                                                                                                                                                 
   num_records number;                                                                                                                                                              
   curr_page number;                                                                                                                                                                
   rcnt number;                                                                                                                                                                     
   curr_pap_count number;                                                                                                                                                           
   curr_remaining number;                                                                                                                                                           
   margin varchar2(32);                                                                                                                                                             
   dline varchar2(128);                                                                                                                                                             
   dline2 varchar2(128);                                                                                                                                                            
   str_len number;                                                                                                                                                                  
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  

                                                                                                                                                                                    
   doc_fname varchar2(32);                                                                                                                                                          
   doc_name varchar2(32);                                                                                                                                                           
   dr_text varchar(128);                                                                                                                                                            
                                                                                                                                                                                    
   six_month_total number;                                                                                                                                                          
   six_month_pap_count number;                                                                                                                                                      
                                                                                                                                                                                    
   t_date date;                                                                                                                                                                     
   start_prior date;                                                                                                                                                                
   end_prior date;                                                                                                                                                                  
                                                                                                                                                                                    
   class_count number(2);                                                                                                                                                           

   curr_class_ndx number(2);                                                                                                                                                        
                                                                                                                                                                                    
   SIL_LG number;                                                                                                                                                                   
   SIL_LG_descr varchar(4000);                                                                                                                                                      
   SIL_LG_count number;                                                                                                                                                             
                                                                                                                                                                                    
   A_code varchar2(128);                                                                                                                                                            
   A_description varchar2(4000);                                                                                                                                                    
   A_count number;                                                                                                                                                                  
   A_count_6M number;                                                                                                                                                               
   A_class number;                                                                                                                                                                  
   A_flag number;                                                                                                                                                                   
   M_flag number;                                                                                                                                                                   

   end_ndx number;                                                                                                                                                                  
                                                                                                                                                                                    
   no_ecc number;                                                                                                                                                                   
   lab_num number;                                                                                                                                                                  
   ECC_count number;                                                                                                                                                                
                                                                                                                                                                                    
   tmp_num number;                                                                                                                                                                  
                                                                                                                                                                                    
   /* HPV vars */                                                                                                                                                                   
   print_hpv char(1);                                                                                                                                                               
   has_hpv number;                                                                                                                                                                  
   hpv_sent varchar2(2);                                                                                                                                                            
   hpv_data varchar2(2);                                                                                                                                                            

                                                                                                                                                                                    
   S_practice number;                                                                                                                                                               
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_DOC_SUMM_PTYPE';                                                                                                                                             
   P_code_area:='PREP';                                                                                                                                                             
                                                                                                                                                                                    
   /*                                                                                                                                                                               
      Initializations                                                                                                                                                               
   */                                                                                                                                                                               
   delete from pcs.doc_sum_work;                                                                                                                                                    
   insert into pcs.doc_sum_work                                                                                                                                                     

      select lr.lab_number,lr.pap_class                                                                                                                                             
      from pcs.lab_results lr, pcs.lab_requisitions lq                                                                                                                              
      where lq.lab_number=lr.lab_number                                                                                                                                             
      and lq.practice in                                                                                                                                                            
         (select practice                                                                                                                                                           
          from pcs.practices                                                                                                                                                        
          where practice_type=p_type                                                                                                                                                
          and program=p_program)                                                                                                                                                    
      and lr.pap_class<17                                                                                                                                                           
      and lr.lab_number in                                                                                                                                                          
         (select lab_number from pcs.practice_statement_labs                                                                                                                        
          where statement_id=S_month);                                                                                                                                              
   update pcs.doc_sum_work set pap_class=6 where pap_class=8;                                                                                                                       

   update pcs.pap_classes set tmp_num=0;                                                                                                                                            
   ECC_count:=0;                                                                                                                                                                    
                                                                                                                                                                                    
   S_practice:=0;                                                                                                                                                                   
                                                                                                                                                                                    
   P_code_area:='PREP2';                                                                                                                                                            
   t_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));                                                                                                                            
   end_prior:=t_date+1;                                                                                                                                                             
   start_prior:=ADD_MONTHS(t_date,-6);                                                                                                                                              
                                                                                                                                                                                    
   practice_id:=LPAD(P_program,5,'0');                                                                                                                                              
                                                                                                                                                                                    
   invoice_date:=TO_CHAR(SysDate,'MM/DD/YYYY');                                                                                                                                     

   f_date:=TO_DATE(TO_CHAR(S_month),'YYYYMM');                                                                                                                                      
   cbuf1:=TO_CHAR(f_date,'MonYYYY');                                                                                                                                                
   cbuf3:=SUBSTR(P_program,1,2);                                                                                                                                                    
   S_file_name:=cbuf1||'.'||cbuf3||'2';                                                                                                                                             
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
                                                                                                                                                                                    
   select TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM')),'MM/DD/YYYY')                                                                                                        
   into S_period from dual;                                                                                                                                                         
   select count(*) into num_records                                                                                                                                                 
   from pcs.lab_results lr, lab_requisitions lq                                                                                                                                     
   where lr.lab_number=lq.lab_number                                                                                                                                                

   and lq.practice in                                                                                                                                                               
         (select practice                                                                                                                                                           
          from pcs.practices                                                                                                                                                        
          where practice_type=p_type                                                                                                                                                
          and program=p_program)                                                                                                                                                    
   and lr.pap_class<17                                                                                                                                                              
   and lr.lab_number in                                                                                                                                                             
      (select lab_number from pcs.practice_statement_labs                                                                                                                           
       where statement_id=S_month);                                                                                                                                                 
                                                                                                                                                                                    
   P_code_area:='PREP3';                                                                                                                                                            
   select count(distinct pap_class) into class_count                                                                                                                                
   from pcs.lab_requisitions lq, pcs.lab_results lr                                                                                                                                 

   where lq.lab_number=lr.lab_number                                                                                                                                                
      and lq.practice in                                                                                                                                                            
         (select practice                                                                                                                                                           
          from pcs.practices                                                                                                                                                        
          where practice_type=p_type                                                                                                                                                
          and program=p_program)                                                                                                                                                    
   and lr.pap_class<17                                                                                                                                                              
   and lr.lab_number in                                                                                                                                                             
      (select lab_number from pcs.practice_statement_labs                                                                                                                           
       where statement_id=S_month);                                                                                                                                                 
                                                                                                                                                                                    
   P_code_area:='HEADING';                                                                                                                                                          
   curr_class_ndx:=0;                                                                                                                                                               

   curr_page:=1;                                                                                                                                                                    
   margin:='    ';                                                                                                                                                                  
   heading:=margin||'        LAB NUMBER      PATIENT                       DATE';                                                                                                   
   dline:=margin||                                                                                                                                                                  
      '-----------------------------------------------------------------------';                                                                                                    
   dline2:=margin||'        ------------------------------------------------------';                                                                                                
                                                                                                                                                                                    
   heading2:=margin||'LAB NUMBER      PATIENT                       DATE      DOCTOR';                                                                                              
   heading3:=margin||'LAB NUMBER      PATIENT                       DATE    PATIENT ID ';                                                                                           
   heading4:=margin||'SSN NUMBER      PATIENT                       DATE      DOCTOR';                                                                                              
                                                                                                                                                                                    
   P_name:='WV DEPT OF HEALTH & HUMAN RESOURCES';                                                                                                                                   
   P_address1:='BUREAU FOR PUBLIC HEALTH';                                                                                                                                          

   P_address2:='350 CAPITOL STREET, ROOM 427';                                                                                                                                      
   P_city:='CHARLESTON';                                                                                                                                                            
   P_state:='WV';                                                                                                                                                                   
   P_zip:='25301';                                                                                                                                                                  
                                                                                                                                                                                    
   print_hpv:='Y';                                                                                                                                                                  
   if (print_hpv='Y') then                                                                                                                                                          
      heading:=heading||LPAD('HPV',13);                                                                                                                                             
      heading2:=heading2||LPAD('HPV',9);                                                                                                                                            
      heading3:=heading3||LPAD('HPV',5);                                                                                                                                            
      dline2:=dline2||'---------';                                                                                                                                                  
   end if;                                                                                                                                                                          
                                                                                                                                                                                    

   UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                                
   line_num:=5;                                                                                                                                                                     
   cbuf:='PAGE '||to_char(curr_page);                                                                                                                                               
   cbuf:=LPAD(cbuf,41);                                                                                                                                                             
   curr_line:=margin||'PENNSYLVANIA CYTOLOGY SERVICES'||cbuf;                                                                                                                       
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   curr_line:=margin||'Suite 1700 Parkway Building';                                                                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   curr_line:=margin||'339 Old Haymaker Road';                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            

   curr_line:=margin||'Monroeville, PA 15146-1447';                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   curr_line:=margin||'Phone: 412-373-8300';                                                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
   line_num:=line_num+2;                                                                                                                                                            
   UTL_FILE.NEW_LINE(file_handle);                                                                                                                                                  
   line_num:=line_num+1;                                                                                                                                                            
   cbuf:=margin||margin||P_name;                                                                                                                                                    
   curr_line:=RPAD(cbuf,50);                                                                                                                                                        
   cbuf:='PROGRAM CODE: '||practice_id;                                                                                                                                             
   curr_line:=curr_line||cbuf;                                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     

   line_num:=line_num+1;                                                                                                                                                            
                                                                                                                                                                                    
   cbuf:=margin||margin||P_address1;                                                                                                                                                
   curr_line:=RPAD(cbuf,50);                                                                                                                                                        
   cbuf:='PERIOD ENDING: '||S_period;                                                                                                                                               
   curr_line:=curr_line||cbuf;                                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   if (P_address2 is not null) then                                                                                                                                                 
      cbuf:=margin||margin||P_address2;                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                       
      line_num:=line_num+1;                                                                                                                                                         
   end if;                                                                                                                                                                          

   cbuf:=RTRIM(P_city)||', '||P_state||'  '||RTRIM(P_zip);                                                                                                                          
   cbuf:=margin||margin||cbuf;                                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',cbuf);                                                                                                                                      
   cbuf:='                         SUMMARY OF CYTOLOGY FINDINGS';                                                                                                                   
   UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                          
   line_num:=line_num+5;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   line_num:=line_num+1;                                                                                                                                                            
                                                                                                                                                                                    
   P_code_area:='P-CLASS';                                                                                                                                                          
   open papclass_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      <<loop_top>>                                                                                                                                                                  

      fetch papclass_list into C_pap_class,C_pap_descr,rcnt;                                                                                                                        
      exit when papclass_list%NOTFOUND;                                                                                                                                             
      if (C_pap_class=16) then                                                                                                                                                      
         select count(distinct l.lab_number) into curr_pap_count                                                                                                                    
         from pcs.lab_requisitions l, pcs.lab_results r,                                                                                                                            
            pcs.practice_statement_labs ps                                                                                                                                          
         where l.lab_number=r.lab_number                                                                                                                                            
         and r.lab_number=ps.lab_number                                                                                                                                             
         and l.practice in                                                                                                                                                          
            (select practice                                                                                                                                                        
             from pcs.practices                                                                                                                                                     
             where practice_type=p_type                                                                                                                                             
             and program=p_program)                                                                                                                                                 

         and ps.statement_id=S_month                                                                                                                                                
         and r.limited=1;                                                                                                                                                           
         update pcs.pap_classes set tmp_num=curr_pap_count                                                                                                                          
         where current of papclass_list;                                                                                                                                            
         goto loop_top;                                                                                                                                                             
      end if;                                                                                                                                                                       
      select count(*) into curr_pap_count from pcs.doc_sum_work                                                                                                                     
      where pap_class=C_pap_class;                                                                                                                                                  
      curr_remaining:=curr_pap_count;                                                                                                                                               
      if ((line_num+10)>=60 and curr_class_ndx<class_count) then                                                                                                                    
         curr_page:=curr_page+1;                                                                                                                                                    
         line_num:=1;                                                                                                                                                               
         UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                         

         UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                          
         line_num:=line_num+5;                                                                                                                                                      
         cbuf:=margin||'PROGRAM CODE: '||                                                                                                                                           
            practice_id||'     PERIOD ENDING: '||S_period;                                                                                                                          
         curr_line:=cbuf;                                                                                                                                                           
         cbuf:='PAGE '||to_char(curr_page);                                                                                                                                         
         cbuf:=LPAD(cbuf,22);                                                                                                                                                       
         curr_line:=curr_line||cbuf;                                                                                                                                                
         UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                             
         line_num:=line_num+2;                                                                                                                                                      
         cbuf:='                         SUMMARY OF CYTOLOGY FINDINGS';                                                                                                             
         UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                    
         line_num:=line_num+1;                                                                                                                                                      

         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=line_num+1;                                                                                                                                                      
      end if;                                                                                                                                                                       
      if (curr_pap_count>0) then                                                                                                                                                    
         curr_class_ndx:=curr_class_ndx+1;                                                                                                                                          
         UTL_FILE.NEW_LINE(file_handle);                                                                                                                                            
         line_num:=line_num+1;                                                                                                                                                      
         curr_line:=margin||margin||margin||                                                                                                                                        
            'DESCRIPTION:  '||RTRIM(C_pap_descr);                                                                                                                                   
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         curr_line:=margin||margin||margin||                                                                                                                                        
            'TOTAL:        '||TO_CHAR(curr_pap_count);                                                                                                                              

         UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                             
         line_num:=line_num+2;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',heading);                                                                                                                                 
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',dline2);                                                                                                                                  
         line_num:=line_num+1;                                                                                                                                                      
         P_code_area:='GET LAB NUM';                                                                                                                                                
         open lab_list;                                                                                                                                                             
         loop                                                                                                                                                                       
            fetch lab_list into S_lab,S_name,S_date,dr_text,                                                                                                                        
               S_patient_id,lab_num,S_patient_SSN;                                                                                                                                  
            exit when lab_list%NOTFOUND;                                                                                                                                            
            S_name:=substr(S_name,1,27);                                                                                                                                            

            cbuf4:=S_lab;                                                                                                                                                           
            curr_line:=margin||margin||RPAD(cbuf4,16)||RPAD(S_name,28)||S_date;                                                                                                     
            P_code_area:='GET HPV DATA';                                                                                                                                            
            has_hpv:=0;                                                                                                                                                             
            if (print_hpv='Y') then                                                                                                                                                 
               select count(*) into has_hpv                                                                                                                                         
               from pcs.hpv_requests                                                                                                                                                
               where lab_number=lab_num;                                                                                                                                            
               if (has_hpv>0) then                                                                                                                                                  
                  select test_sent, test_results                                                                                                                                    
                  into hpv_sent, hpv_data                                                                                                                                           
                  from pcs.hpv_requests                                                                                                                                             
                  where lab_number=lab_num;                                                                                                                                         

                  if hpv_sent IN ('P','Q') then                                                                                                                                     
                     hpv_data:=hpv_sent;                                                                                                                                            
                  elsif hpv_data NOT IN ('+','-') then                                                                                                                              
                     has_hpv:=0;                                                                                                                                                    
                  end if;                                                                                                                                                           
               end if;                                                                                                                                                              
            end if;                                                                                                                                                                 
            P_code_area:='GET NO ECC';                                                                                                                                              
            no_ecc:=pcs.is_no_ecc(lab_num);                                                                                                                                         
            P_code_area:='GOT NO ECC';                                                                                                                                              
            if (no_ecc=1 and P_type='ADPH') then                                                                                                                                    
               curr_line:='   *'||curr_line;                                                                                                                                        
               ECC_count:=ECC_count+1;                                                                                                                                              

            else                                                                                                                                                                    
               curr_line:=margin||curr_line;                                                                                                                                        
            end if;                                                                                                                                                                 
            P_code_area:='CONTINUE';                                                                                                                                                
            /* ADD ON HPV DATA IF APPLIES                                                                                                                                           
            */                                                                                                                                                                      
            if (has_hpv>0) then                                                                                                                                                     
               curr_line:=RPAD(SUBSTR(curr_line,1,70),73)||hpv_data;                                                                                                                
            end if;                                                                                                                                                                 
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
            line_num:=line_num+1;                                                                                                                                                   
            curr_remaining:=curr_remaining-1;                                                                                                                                       
            if (line_num>=60 and curr_remaining>0) then                                                                                                                             

               curr_page:=curr_page+1;                                                                                                                                              
               line_num:=1;                                                                                                                                                         
               UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                   
               UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                    
               line_num:=line_num+5;                                                                                                                                                
               cbuf:=margin||'PROGRAM CODE: '||practice_id||                                                                                                                        
                  '     PERIOD ENDING: '||S_period;                                                                                                                                 
               curr_line:=cbuf;                                                                                                                                                     
               cbuf:='PAGE '||to_char(curr_page);                                                                                                                                   
               cbuf:=LPAD(cbuf,22);                                                                                                                                                 
               curr_line:=curr_line||cbuf;                                                                                                                                          
               UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                       
               line_num:=line_num+2;                                                                                                                                                

               cbuf:='                         SUMMARY OF CYTOLOGY FINDINGS';                                                                                                       
               UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                              
               line_num:=line_num+1;                                                                                                                                                
               UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                             
               line_num:=line_num+1;                                                                                                                                                
               if (curr_remaining>0) then                                                                                                                                           
                  UTL_FILE.PUTF(file_handle,'%s\n',heading);                                                                                                                        
                  line_num:=line_num+1;                                                                                                                                             
                  UTL_FILE.PUTF(file_handle,'%s\n',dline2);                                                                                                                         
                  line_num:=line_num+1;                                                                                                                                             
               end if;                                                                                                                                                              
            end if;                                                                                                                                                                 
            update pcs.billing_details set date_sent=SysDate                                                                                                                        

            where lab_number=S_lab and billing_choice=122;                                                                                                                          
         end loop;                                                                                                                                                                  
         close lab_list;                                                                                                                                                            
         UTL_FILE.NEW_LINE(file_handle);                                                                                                                                            
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=line_num+1;                                                                                                                                                      
      end if;                                                                                                                                                                       
      update pcs.pap_classes set tmp_num=curr_pap_count                                                                                                                             
      where current of papclass_list;                                                                                                                                               
   end loop;                                                                                                                                                                        
   close papclass_list;                                                                                                                                                             
   P_code_area:='FOOTER';                                                                                                                                                           

   curr_page:=curr_page+1;                                                                                                                                                          
   line_num:=0;                                                                                                                                                                     
   UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                               
   UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                                
   line_num:=4;                                                                                                                                                                     
   cbuf:=margin||'PROGRAM CODE: '||practice_id||'     PERIOD ENDING: '||S_period;                                                                                                   
   curr_line:=cbuf;                                                                                                                                                                 
   cbuf:='PAGE '||to_char(curr_page);                                                                                                                                               
   cbuf:=LPAD(cbuf,22);                                                                                                                                                             
   curr_line:=curr_line||cbuf;                                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
   line_num:=line_num+2;                                                                                                                                                            
   --cbuf:='                         SUMMARY OF CYTOLOGY FINDINGS';                                                                                                                 

   cbuf:='         SUMMARY OF CYTOLOGY FINDINGS';                                                                                                                                   
   UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                          
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   line_num:=line_num+1;                                                                                                                                                            
   curr_line:=margin||                                                                                                                                                              
      '                                          MONTHLY          SIX-MONTH';                                                                                                       
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   curr_line:=margin||                                                                                                                                                              
      '                                          TOTALS:            TOTALS:';                                                                                                       
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            

   curr_line:='                                          ---------------- ----------------';                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   select count(*) into six_month_total                                                                                                                                             
   from pcs.lab_requisitions l, pcs.lab_results r                                                                                                                                   
   where l.lab_number=r.lab_number                                                                                                                                                  
   and r.pap_class<17                                                                                                                                                               
      and l.practice in                                                                                                                                                             
         (select practice                                                                                                                                                           
          from pcs.practices                                                                                                                                                        
          where practice_type=p_type                                                                                                                                                
          and program=p_program)                                                                                                                                                    
   and r.datestamp>start_prior                                                                                                                                                      

   and r.datestamp<=end_prior;                                                                                                                                                      
   P_code_area:='P-CLASS 2';                                                                                                                                                        
   open papclass_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch papclass_list into C_pap_class,C_pap_descr,curr_pap_count;                                                                                                              
      exit when papclass_list%NOTFOUND;                                                                                                                                             
      if (LENGTH(C_pap_descr)>35) then                                                                                                                                              
         C_pap_descr:=SUBSTR(C_pap_descr,1,35)||'...';                                                                                                                              
      end if;                                                                                                                                                                       
      if (C_pap_class=16) then                                                                                                                                                      
         select count(*) into six_month_pap_count                                                                                                                                   
         from pcs.lab_requisitions l, pcs.lab_results r                                                                                                                             
         where l.lab_number=r.lab_number                                                                                                                                            

            and l.practice in                                                                                                                                                       
               (select practice                                                                                                                                                     
                from pcs.practices                                                                                                                                                  
                where practice_type=p_type                                                                                                                                          
                and program=p_program)                                                                                                                                              
            and r.datestamp>start_prior and                                                                                                                                         
            r.datestamp<=end_prior and                                                                                                                                              
            r.limited=1;                                                                                                                                                            
      elsif (C_pap_class<>6) then                                                                                                                                                   
         select count(*) into six_month_pap_count                                                                                                                                   
         from pcs.lab_requisitions l, pcs.lab_results r                                                                                                                             
         where l.lab_number=r.lab_number                                                                                                                                            
            and l.practice in                                                                                                                                                       

               (select practice                                                                                                                                                     
                from pcs.practices                                                                                                                                                  
                where practice_type=p_type                                                                                                                                          
                and program=p_program)                                                                                                                                              
            and r.datestamp>start_prior and                                                                                                                                         
            r.datestamp<=end_prior and                                                                                                                                              
            r.pap_class=C_pap_class;                                                                                                                                                
      else                                                                                                                                                                          
         select count(*) into six_month_pap_count                                                                                                                                   
         from pcs.lab_requisitions l, pcs.lab_results r                                                                                                                             
         where l.lab_number=r.lab_number                                                                                                                                            
            and l.practice in                                                                                                                                                       
               (select practice                                                                                                                                                     

                from pcs.practices                                                                                                                                                  
                where practice_type=p_type                                                                                                                                          
                and program=p_program)                                                                                                                                              
            and r.datestamp>start_prior and                                                                                                                                         
            r.datestamp<=end_prior and                                                                                                                                              
            (r.pap_class=C_pap_class or r.pap_class=8);                                                                                                                             
      end if;                                                                                                                                                                       
      if (num_records>0) then                                                                                                                                                       
         rcnt:=((curr_pap_count/num_records)*100);                                                                                                                                  
      else                                                                                                                                                                          
         rcnt:=0;                                                                                                                                                                   
      end if;                                                                                                                                                                       
      cbuf:=TO_CHAR(rcnt,'990.99')||' %';                                                                                                                                           

      if (C_pap_class in (3,4,12)) then                                                                                                                                             
         cbuf2:=margin||'     '||RPAD(C_pap_descr,33)||                                                                                                                             
            LPAD(TO_CHAR(curr_pap_count),6)||LPAD(cbuf,10);                                                                                                                         
         cbuf:=LPAD(TO_CHAR(six_month_pap_count),7);                                                                                                                                
         curr_line:=cbuf2||cbuf;                                                                                                                                                    
      else                                                                                                                                                                          
         cbuf2:=margin||RPAD(C_pap_descr,38)||                                                                                                                                      
            LPAD(TO_CHAR(curr_pap_count),6)||LPAD(cbuf,10);                                                                                                                         
         cbuf:=LPAD(TO_CHAR(six_month_pap_count),7);                                                                                                                                
         curr_line:=cbuf2||cbuf;                                                                                                                                                    
      end if;                                                                                                                                                                       
      if (six_month_total>0) then                                                                                                                                                   
         rcnt:=((six_month_pap_count/six_month_total)*100);                                                                                                                         

      else                                                                                                                                                                          
         rcnt:=0;                                                                                                                                                                   
      end if;                                                                                                                                                                       
      cbuf:=TO_CHAR(rcnt,'990.99')||' %';                                                                                                                                           
      cbuf2:=curr_line||LPAD(cbuf,10);                                                                                                                                              
      curr_line:=cbuf2;                                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      line_num:=line_num+1;                                                                                                                                                         
   end loop;                                                                                                                                                                        
   close papclass_list;                                                                                                                                                             
   P_code_area:='FOOTER 2';                                                                                                                                                         
   curr_line:='                                          ---------------- ----------------';                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     

   line_num:=line_num+1;                                                                                                                                                            
   cbuf:=TO_CHAR(num_records);                                                                                                                                                      
   cbuf2:=LPAD(cbuf,48)||LPAD('100.00 %',10);                                                                                                                                       
   cbuf:=TO_CHAR(six_month_total);                                                                                                                                                  
   curr_line:=LPAD(cbuf,7)||LPAD('100.00 %',10);                                                                                                                                    
   cbuf:=cbuf2||curr_line;                                                                                                                                                          
   UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                          
   line_num:=line_num+1;                                                                                                                                                            
                                                                                                                                                                                    
   P_code_area:='ADEQUACY 1';                                                                                                                                                       
   delete from pcs.temp_table;                                                                                                                                                      
   insert into pcs.temp_table                                                                                                                                                       
      select count(b.bethesda_code), b.bethesda_code                                                                                                                                

      from pcs.lab_results lr, pcs.lab_requisitions lq, pcs.practices p,                                                                                                            
         pcs.adequacy_result_codes lc, pcs.bethesda_codes b                                                                                                                         
      where lq.lab_number=lr.lab_number                                                                                                                                             
      and lr.lab_number=lc.lab_number                                                                                                                                               
      and lc.bethesda_code=b.bethesda_code                                                                                                                                          
      and b.category='S'                                                                                                                                                            
      and lq.practice=p.practice                                                                                                                                                    
      and p.practice_type=P_type                                                                                                                                                    
      and p.program=P_program                                                                                                                                                       
      and lr.lab_number in                                                                                                                                                          
         (select lab_number from pcs.practice_statement_labs                                                                                                                        
          where statement_id=S_month)                                                                                                                                               
      group by b.bethesda_code;                                                                                                                                                     

   insert into temp_table                                                                                                                                                           
      select count(b.bethesda_code||' [6M]'),b.bethesda_code||' [6M]'                                                                                                               
      from pcs.lab_requisitions l,pcs.lab_results r, pcs.practices p,                                                                                                               
         pcs.adequacy_result_codes lc, pcs.bethesda_codes b                                                                                                                         
      where l.lab_number=r.lab_number                                                                                                                                               
      and r.lab_number=lc.lab_number                                                                                                                                                
      and lc.bethesda_code=b.bethesda_code                                                                                                                                          
      and b.category='S'                                                                                                                                                            
      and l.practice=p.practice                                                                                                                                                     
      and p.practice_type=P_type                                                                                                                                                    
      and p.program=P_program                                                                                                                                                       
      and r.datestamp>ADD_MONTHS(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM')),-6)                                                                                                   
      and r.datestamp<=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'))+1                                                                                                               

      group by b.bethesda_code||' [6M]';                                                                                                                                            
                                                                                                                                                                                    
   /* MAKE SURE ENTRY FOR EACH OF 849,850,851 IN TABLE */                                                                                                                           
   P_code_area:='ADEQUACY 2';                                                                                                                                                       
   select count(*) into rcnt from pcs.temp_table                                                                                                                                    
   where message_text='849 [6M]';                                                                                                                                                   
   if (rcnt=0) then                                                                                                                                                                 
      insert into pcs.temp_table                                                                                                                                                    
      values (0,'849 [6M]');                                                                                                                                                        
   end if;                                                                                                                                                                          
   select count(*) into rcnt from pcs.temp_table                                                                                                                                    
   where message_text='850 [6M]';                                                                                                                                                   
   if (rcnt=0) then                                                                                                                                                                 

      insert into pcs.temp_table                                                                                                                                                    
      values (0,'850 [6M]');                                                                                                                                                        
   end if;                                                                                                                                                                          
   select count(*) into rcnt from pcs.temp_table                                                                                                                                    
   where message_text='851 [6M]';                                                                                                                                                   
   if (rcnt=0) then                                                                                                                                                                 
      insert into pcs.temp_table                                                                                                                                                    
      values (0,'851 [6M]');                                                                                                                                                        
   end if;                                                                                                                                                                          
   cbuf:='             ADEQUACY BREAKDOWN         (PERCENTAGES BASED ON TOTALS ABOVE)';                                                                                             
   UTL_FILE.PUTF(file_handle,'\n%s\n',cbuf);                                                                                                                                        
   line_num:=line_num+2;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         

   line_num:=line_num+1;                                                                                                                                                            
   A_flag:=0;                                                                                                                                                                       
   curr_line:=margin||'SATISFACTORY FOR EVALUATION:';                                                                                                                               
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   open adequacy_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch adequacy_list into A_count_6M,A_code;                                                                                                                                   
      exit when adequacy_list%NOTFOUND;                                                                                                                                             
      if (line_num>=56) then                                                                                                                                                        
         curr_page:=curr_page+1;                                                                                                                                                    
         line_num:=0;                                                                                                                                                               
         UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                         

         UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                          
         line_num:=4;                                                                                                                                                               
         cbuf:=margin||'PROGRAM CODE: '||practice_id||'     PERIOD ENDING: '||S_period;                                                                                             
         curr_line:=cbuf;                                                                                                                                                           
         cbuf:='PAGE '||to_char(curr_page);                                                                                                                                         
         cbuf:=LPAD(cbuf,22);                                                                                                                                                       
         curr_line:=curr_line||cbuf;                                                                                                                                                
         UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                             
         line_num:=line_num+2;                                                                                                                                                      
         cbuf:='             ADEQUACY BREAKDOWN';                                                                                                                                   
         UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                    
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   

         line_num:=line_num+1;                                                                                                                                                      
         curr_line:=margin||                                                                                                                                                        
            '                                          MONTHLY          SIX-MONTH';                                                                                                 
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         curr_line:=margin||                                                                                                                                                        
            '                                          TOTALS:            TOTALS:';                                                                                                 
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         curr_line:='                                          ---------------- ----------------';                                                                                  
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         cbuf:=TO_CHAR(num_records);                                                                                                                                                

         cbuf2:=LPAD(cbuf,48)||LPAD('100.00 %',10);                                                                                                                                 
         cbuf:=TO_CHAR(six_month_total);                                                                                                                                            
         curr_line:=LPAD(cbuf,7)||LPAD('100.00 %',10);                                                                                                                              
         cbuf:=cbuf2||curr_line;                                                                                                                                                    
         UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                    
         line_num:=line_num+1;                                                                                                                                                      
         curr_line:='                                          ---------------- ----------------';                                                                                  
         UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                             
         line_num:=line_num+2;                                                                                                                                                      
      end if;                                                                                                                                                                       
      A_code:=SUBSTR(A_code,1,3);                                                                                                                                                   
      /*                                                                                                                                                                            
         Two strings repeat within the adequacy category of the result codes. Each will                                                                                             

         begin with either SATISFACTORY FOR EVALUATION or SPECIMEN PROCESSED AND                                                                                                    
         EXAMINED. This is redundent on the report so both need to be extracted from                                                                                                
         the description.                                                                                                                                                           
      */                                                                                                                                                                            
      select REPLACE(description,'SATISFACTORY FOR EVALUATION, '),papclass                                                                                                          
      into A_description,A_class                                                                                                                                                    
      from pcs.bethesda_codes                                                                                                                                                       
      where bethesda_code=A_code;                                                                                                                                                   
      A_description:=REPLACE(A_description,'SPECIMEN PROCESSED AND EXAMINED, BUT UNSATISFACTORY FOR EVALUATION ');                                                                  
      select count(*) into rcnt                                                                                                                                                     
      from pcs.temp_table                                                                                                                                                           
      where message_text=A_code;                                                                                                                                                    
      if (rcnt>0) then                                                                                                                                                              

         select row_id into A_count                                                                                                                                                 
         from pcs.temp_table                                                                                                                                                        
         where message_text=A_code;                                                                                                                                                 
         if (A_code=851) then                                                                                                                                                       
            A_count:=ECC_count;                                                                                                                                                     
         end if;                                                                                                                                                                    
      else                                                                                                                                                                          
         A_count:=0;                                                                                                                                                                
      end if;                                                                                                                                                                       
      if (A_class=1 AND A_flag=0) then                                                                                                                                              
         A_flag:=1;                                                                                                                                                                 
      end if;                                                                                                                                                                       
      if (A_flag=1) then                                                                                                                                                            

         curr_line:=margin||'UNSATISFACTORY:';                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                             
         line_num:=line_num+2;                                                                                                                                                      
         A_flag:=(-1);                                                                                                                                                              
      end if;                                                                                                                                                                       
      if (A_code='849') then                                                                                                                                                        
         A_count:=0;                                                                                                                                                                
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.lab_result_codes b                                                                                                                             
         where a.lab_number=b.lab_number                                                                                                                                            
         and a.qc_status='N' and a.path_status='N'                                                                                                                                  
         and b.bethesda_code='849'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        

            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.quality_control_codes b                                                                                                                        
         where a.lab_number=b.lab_number                                                                                                                                            
         and a.qc_status='Y' and a.path_status='N'                                                                                                                                  
         and b.bethesda_code='849'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        

            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.pathologist_control_codes b                                                                                                                    
         where a.lab_number=b.lab_number                                                                                                                                            
         and a.path_status='Y'                                                                                                                                                      
         and b.bethesda_code='849'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        

            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
      elsif (A_code='850') then                                                                                                                                                     
         A_count:=0;                                                                                                                                                                
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.lab_result_codes b                                                                                                                             
         where a.lab_number=b.lab_number                                                                                                                                            
         and a.qc_status='N' and a.path_status='N'                                                                                                                                  

         and b.bethesda_code='850'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        
            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.quality_control_codes b                                                                                                                        
         where a.lab_number=b.lab_number                                                                                                                                            
         and a.qc_status='Y' and a.path_status='N'                                                                                                                                  

         and b.bethesda_code='850'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        
            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.pathologist_control_codes b                                                                                                                    
         where a.lab_number=b.lab_number                                                                                                                                            
         and a.path_status='Y'                                                                                                                                                      

         and b.bethesda_code='850'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        
            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
      elsif (A_code='851') then                                                                                                                                                     
         A_count:=0;                                                                                                                                                                
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.lab_result_codes b                                                                                                                             

         where a.lab_number=b.lab_number                                                                                                                                            
         and a.qc_status='N' and a.path_status='N'                                                                                                                                  
         and b.bethesda_code='851'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        
            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.quality_control_codes b                                                                                                                        

         where a.lab_number=b.lab_number                                                                                                                                            
         and a.qc_status='Y' and a.path_status='N'                                                                                                                                  
         and b.bethesda_code='851'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        
            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
         select count(*) into tmp_num                                                                                                                                               
         from pcs.lab_results a, pcs.pathologist_control_codes b                                                                                                                    

         where a.lab_number=b.lab_number                                                                                                                                            
         and a.path_status='Y'                                                                                                                                                      
         and b.bethesda_code='851'                                                                                                                                                  
         and a.lab_number in                                                                                                                                                        
            (select lab_number                                                                                                                                                      
             from pcs.practice_statement_labs a, pcs.practices b                                                                                                                    
             where a.practice=b.practice                                                                                                                                            
             and b.practice_type=P_type                                                                                                                                             
             and b.program=P_program                                                                                                                                                
             and statement_id=S_month);                                                                                                                                             
         A_count:=A_count+tmp_num;                                                                                                                                                  
      end if;                                                                                                                                                                       
      cbuf:=A_description;                                                                                                                                                          

      cbuf3:=LPAD(TO_CHAR(A_count),6);                                                                                                                                              
      if (A_count>0) then                                                                                                                                                           
         A_count:=((A_count/num_records)*100);                                                                                                                                      
      end if;                                                                                                                                                                       
      cbuf3:=cbuf3||LPAD(TO_CHAR(A_count,'990.99')||' %',10);                                                                                                                       
      cbuf3:=cbuf3||LPAD(TO_CHAR(A_count_6M),7);                                                                                                                                    
      if (A_count_6M>0) then                                                                                                                                                        
         A_count_6M:=((A_count_6M/six_month_total)*100);                                                                                                                            
      end if;                                                                                                                                                                       
      cbuf3:=cbuf3||TO_CHAR(A_count_6M,'990.99')||' %';                                                                                                                             
      if (LENGTH(cbuf)>36) then                                                                                                                                                     
         cbuf2:=cbuf;                                                                                                                                                               
         end_ndx:=0;                                                                                                                                                                

         M_flag:=0;                                                                                                                                                                 
         while (LENGTH(cbuf2)>36)                                                                                                                                                   
         loop                                                                                                                                                                       
            for rcnt in 1..36 loop                                                                                                                                                  
               if (SUBSTR(cbuf2,rcnt,1)=' ') then                                                                                                                                   
                  end_ndx:=rcnt;                                                                                                                                                    
               end if;                                                                                                                                                              
            end loop;                                                                                                                                                               
            cbuf:=SUBSTR(cbuf2,1,end_ndx);                                                                                                                                          
            cbuf2:=LTRIM(RTRIM(SUBSTR(cbuf2,end_ndx)));                                                                                                                             
            cbuf2:=margin||cbuf2;                                                                                                                                                   
            if (M_flag=0) then                                                                                                                                                      
               curr_line:=margin||RPAD(cbuf,38)||cbuf3;                                                                                                                             

               M_flag:=1;                                                                                                                                                           
            else                                                                                                                                                                    
               curr_line:=margin||RPAD(cbuf,38);                                                                                                                                    
            end if;                                                                                                                                                                 
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
            line_num:=line_num+1;                                                                                                                                                   
            M_flag:=1;                                                                                                                                                              
         end loop;                                                                                                                                                                  
         if (NVL(LENGTH(cbuf2),0)>0) then                                                                                                                                           
            curr_line:=margin||cbuf2;                                                                                                                                               
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
            line_num:=line_num+1;                                                                                                                                                   
         end if;                                                                                                                                                                    

      else                                                                                                                                                                          
         curr_line:=margin||RPAD(cbuf,38)||cbuf3;                                                                                                                                   
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
      end if;                                                                                                                                                                       
      /*                                                                                                                                                                            
         The first three codes in this section are 849, 850, and 851. All labs                                                                                                      
         will include one and only one of these three codes excluding any that.                                                                                                     
         are unsatisfactory; put a new line to separate these from others.                                                                                                          
      */                                                                                                                                                                            
      if (A_code='851') then                                                                                                                                                        
         if (P_type='ADPH') then                                                                                                                                                    
            cbuf3:='     (PATIENT NAMES WITH *)';                                                                                                                                   

            curr_line:=margin||RPAD(cbuf3,38);                                                                                                                                      
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
            line_num:=line_num+1;                                                                                                                                                   
         end if;                                                                                                                                                                    
         UTL_FILE.NEW_LINE(file_handle);                                                                                                                                            
         line_num:=line_num+1;                                                                                                                                                      
      end if;                                                                                                                                                                       
   end loop;                                                                                                                                                                        
   close adequacy_list;                                                                                                                                                             
                                                                                                                                                                                    
   UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                               
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_practice);                                                                                         

      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                                                                                                                                         