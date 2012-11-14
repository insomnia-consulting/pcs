create or replace procedure     build_doctor_statement                                                                                                                                                
(                                                                                                                                                                                   
   S_practice in number,                                                                                                                                                            
   S_month in number                                                                                                                                                                
)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        

                                                                                                                                                                                    
   S_billing_choice number(3);                                                                                                                                                      
   year_adjust number;                                                                                                                                                              
   last_date date;                                                                                                                                                                  
                                                                                                                                                                                    
   P_name varchar2(64);                                                                                                                                                             
   P_address1 varchar2(64);                                                                                                                                                         
   P_address2 varchar2(64);                                                                                                                                                         
   P_city varchar2(32);                                                                                                                                                             
   P_state char(2);                                                                                                                                                                 
   P_zip varchar2(9);                                                                                                                                                               
                                                                                                                                                                                    
   /* NEW STUFF */                                                                                                                                                                  

   H_prior_balance number;                                                                                                                                                          
   H_total_charges number;                                                                                                                                                          
   H_total_payments number;                                                                                                                                                         
   H_total_plus number;                                                                                                                                                             
   H_total_minus number;                                                                                                                                                            
   H_total_balance number;                                                                                                                                                          
   H_tmp_num number;                                                                                                                                                                
                                                                                                                                                                                    
   is_zero number;                                                                                                                                                                  
   chk_charges number;                                                                                                                                                              
                                                                                                                                                                                    
   cursor payment_list is                                                                                                                                                           
      select TO_CHAR(p.payment_id,'000009'),a.adjust_reason,                                                                                                                        

         TO_CHAR(p.receive_date,'MMDD'),p.payment_type,                                                                                                                             
         TO_CHAR(p.payment_amount,'9999.99')                                                                                                                                        
      from pcs.payments p, pcs.payment_adjust_reasons a                                                                                                                             
      where p.payment_id=a.payment_id(+) and                                                                                                                                        
         p.billing_choice=S_billing_choice and                                                                                                                                      
         TO_NUMBER(TO_CHAR(payment_date,'YYYYMM'))=S_month and                                                                                                                      
         p.account_id=S_practice                                                                                                                                                    
      order by payment_date;                                                                                                                                                        
                                                                                                                                                                                    
   cursor lab_list is                                                                                                                                                               
      select SUBSTR(TO_CHAR(lab_number),5,10),SUBSTR(patient_name,1,32),                                                                                                            
         TO_CHAR(date_results_entered,'MMDD'),procedure_code,code_description,                                                                                                      
         TO_CHAR(item_amount,'9999.99'),RTRIM(choice_code),                                                                                                                         

         TO_CHAR(date_collected,'MMDD'),lab_number,item_amount                                                                                                                      
      from pcs.practice_statement_labs ps                                                                                                                                           
      where statement_id=S_month                                                                                                                                                    
      order by lab_number,p_seq;                                                                                                                                                    
                                                                                                                                                                                    
   S_file_name varchar2(8);                                                                                                                                                         
   dir_name varchar2(128);                                                                                                                                                          
   practice_id char(3);                                                                                                                                                             
   S_lab varchar2(16);                                                                                                                                                              
   S_name varchar2(32);                                                                                                                                                             
   S_date varchar2(8);                                                                                                                                                              
   S_collected varchar2(8);                                                                                                                                                         
   S_proc varchar2(8);                                                                                                                                                              

   S_proc_descr varchar2(32);                                                                                                                                                       
   S_charge varchar2(16);                                                                                                                                                           
   S_choice_code char(3);                                                                                                                                                           
   S_forwarded varchar2(12);                                                                                                                                                        
   S_period char(10);                                                                                                                                                               
   S_ttl_payments varchar2(12);                                                                                                                                                     
   S_curr_amount varchar2(12);                                                                                                                                                      
   S_ttl_amount varchar2(12);                                                                                                                                                       
   S_ttl_plus_adjusts varchar2(12);                                                                                                                                                 
   S_ttl_minus_adjusts varchar2(12);                                                                                                                                                
   curr_line varchar2(100);                                                                                                                                                         
   heading varchar2(100);                                                                                                                                                           
   cbuf varchar2(128);                                                                                                                                                              

   cbuf2 varchar2(128);                                                                                                                                                             
   line_num number;                                                                                                                                                                 
   num_records number;                                                                                                                                                              
   num_pages number;                                                                                                                                                                
   curr_page number;                                                                                                                                                                
   rcnt number;                                                                                                                                                                     
   ttl_pay number;                                                                                                                                                                  
   ttl_p_adjust number;                                                                                                                                                             
   ttl_m_adjust number;                                                                                                                                                             
   margin varchar2(32);                                                                                                                                                             
   dline varchar2(128);                                                                                                                                                             
   last_lab varchar(16);                                                                                                                                                            
   stmt_id number;                                                                                                                                                                  

   L_num number;                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_DOCTOR_STATEMENT';                                                                                                                                           
                                                                                                                                                                                    
   P_code_area:='PREP0';                                                                                                                                                            
                                                                                                                                                                                    
   select name,address1,address2,city,state,SUBSTR(zip,1,5)                                                                                                                         
   into P_name,P_address1,P_address2,P_city,P_state,P_zip                                                                                                                           
   from pcs.practices where practice=S_practice;                                                                                                                                    
                                                                                                                                                                                    

   P_code_area:='PREP1';                                                                                                                                                            
   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));                                                                                                                         
   select curr_statement_id into stmt_id                                                                                                                                            
   from pcs.practice_accounts where practice=S_practice;                                                                                                                            
                                                                                                                                                                                    
   P_code_area:='PREP1';                                                                                                                                                            
   practice_id:=LPAD(TO_CHAR(S_practice),3,'0');                                                                                                                                    
   cbuf:=TO_CHAR(S_month);                                                                                                                                                          
   S_file_name:=RTRIM(practice_id||substr(cbuf,5,2)||substr(cbuf,1,1)||substr(cbuf,3,2));                                                                                           
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   P_code_area:='PREP3';                                                                                                                                                            

   select billing_choice into S_billing_choice                                                                                                                                      
   from pcs.billing_choices where choice_code='DOC';                                                                                                                                
   select count(*) into rcnt from pcs.payments                                                                                                                                      
      where TO_NUMBER(TO_CHAR(payment_date,'YYYYMM'))=S_month and account_id=S_practice;                                                                                            
   select count(*) into num_records                                                                                                                                                 
   from pcs.lab_results lr, lab_billing_items lb,lab_requisitions lq                                                                                                                
   where lr.lab_number=lq.lab_number and lq.lab_number=lb.lab_number                                                                                                                
   and lq.billing_choice=S_billing_choice and                                                                                                                                       
      TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMM'))=S_month and lq.practice=S_practice;                                                                                                 
                                                                                                                                                                                    
   P_code_area:='PREP4';                                                                                                                                                            
   num_records:=num_records+rcnt;                                                                                                                                                   
   select count(distinct lb.lab_number) into rcnt                                                                                                                                   

   from pcs.lab_results lr, lab_billing_items lb,lab_requisitions lq                                                                                                                
   where lr.lab_number=lq.lab_number and lq.lab_number=lb.lab_number                                                                                                                
   and lq.billing_choice<>S_billing_choice and                                                                                                                                      
      TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMM'))=S_month and lq.practice=S_practice;                                                                                                 
                                                                                                                                                                                    
   P_code_area:='PREP5';                                                                                                                                                            
   num_records:=num_records+rcnt;                                                                                                                                                   
   if (num_records<33) then                                                                                                                                                         
      num_pages:=1;                                                                                                                                                                 
   else                                                                                                                                                                             
      num_records:=num_records-33;                                                                                                                                                  
      rcnt:=(num_records/50)-floor(num_records/50);                                                                                                                                 
      if (rcnt>0) then rcnt:=1;                                                                                                                                                     

      end if;                                                                                                                                                                       
      num_pages:=round(floor(num_records/50)+rcnt)+1;                                                                                                                               
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   P_code_area:='PREP6';                                                                                                                                                            
   /*                                                                                                                                                                               
   select TO_CHAR(ps.forwarded_amount,'99990.99'),ps.total_payments,                                                                                                                
      TO_CHAR(last_date,'MM/DD/YYYY'),TO_CHAR(ps.total_payments,'99990.99'),                                                                                                        
      TO_CHAR(ps.current_amount,'99990.99'),TO_CHAR(pa.total_balance,'99990.99'),                                                                                                   
      TO_CHAR(ps.total_plus,'99990.99'),TO_CHAR(ps.total_minus,'99990.99')                                                                                                          
   into S_forwarded, ttl_pay, S_period, S_ttl_payments, S_curr_amount,                                                                                                              
      S_ttl_amount,S_ttl_plus_adjusts,S_ttl_minus_adjusts                                                                                                                           
   from pcs.practice_statements ps, pcs.practice_accounts pa                                                                                                                        

   where ps.statement_id=pa.curr_statement_id and pa.practice=S_practice;                                                                                                           
   */                                                                                                                                                                               
                                                                                                                                                                                    
   select TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM')),'MM/DD/YYYY')                                                                                                        
   into S_period from dual;                                                                                                                                                         
                                                                                                                                                                                    
   /*                                                                                                                                                                               
   select TO_CHAR(NVL(sum(payment_amount),0),'99990.99'), NVL(sum(payment_amount),0)                                                                                                
   into S_ttl_plus_adjusts, ttl_p_adjust from pcs.payments                                                                                                                          
   where TO_NUMBER(TO_CHAR(payment_date,'YYYYMM'))=S_month and account_id=S_practice                                                                                                
   and payment_type='PLUS ADJUST';                                                                                                                                                  
                                                                                                                                                                                    
   select TO_CHAR(NVL(sum(payment_amount),0),'99990.99'), NVL(sum(payment_amount),0)                                                                                                

   into S_ttl_minus_adjusts, ttl_m_adjust from pcs.payments                                                                                                                         
   where TO_NUMBER(TO_CHAR(payment_date,'YYYYMM'))=S_month and account_id=S_practice                                                                                                
   and payment_type='MINUS ADJUST';                                                                                                                                                 
   */                                                                                                                                                                               
                                                                                                                                                                                    
   --ttl_pay:=ttl_pay-ttl_m_adjust+ttl_p_adjust;                                                                                                                                    
   select TO_CHAR(ttl_pay,'99990.99') into S_ttl_payments from dual;                                                                                                                
                                                                                                                                                                                    
   P_code_area:='HEADING';                                                                                                                                                          
   curr_page:=1;                                                                                                                                                                    
   margin:='    ';                                                                                                                                                                  
   heading:=margin||RPAD('IDENTIFICATION',30)||RPAD('DATE',6)||                                                                                                                     
      RPAD('PROFESSIONAL SERVICE',31)||'FEE';                                                                                                                                       

   dline:=margin||                                                                                                                                                                  
      '-----------------------------------------------------------------------';                                                                                                    
                                                                                                                                                                                    
   UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                                
   line_num:=5;                                                                                                                                                                     
   cbuf:=LPAD('STATEMENT',41);                                                                                                                                                      
   curr_line:=margin||'PENNSYLVANIA CYTOLOGY SERVICES'||cbuf;                                                                                                                       
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   cbuf:='PAGE '||to_char(curr_page)||' OF '||to_char(num_pages);                                                                                                                   
   cbuf:=LPAD(cbuf,44);                                                                                                                                                             
   curr_line:=margin||'Suite 1700 Parkway Building'||cbuf;                                                                                                                          
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
   cbuf:='CLIENT NUMBER: '||practice_id;                                                                                                                                            
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
   UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                          
   UTL_FILE.NEW_LINE(file_handle,2);                                                                                                                                                
   line_num:=line_num+3;                                                                                                                                                            
   UTL_FILE.NEW_LINE(file_handle);                                                                                                                                                  
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',heading);                                                                                                                                       

   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   line_num:=line_num+1;                                                                                                                                                            
                                                                                                                                                                                    
   S_proc:=RPAD(' ',7);                                                                                                                                                             
   P_code_area:='PAYMENTS';                                                                                                                                                         
   open payment_list;                                                                                                                                                               
   loop                                                                                                                                                                             
      fetch payment_list into S_lab,S_name,S_date,S_proc_descr,S_charge;                                                                                                            
      exit when payment_list%NOTFOUND;                                                                                                                                              
      if (S_proc_descr<>'PLUS ADJUST' and S_proc_descr<>'MINUS ADJUST') then                                                                                                        
         S_proc_descr:='PAYMENT - THANK YOU!';                                                                                                                                      
      end if;                                                                                                                                                                       

      if (S_name is null) then cbuf:=' ';                                                                                                                                           
      else cbuf:=substr(S_name,1,21);                                                                                                                                               
      end if;                                                                                                                                                                       
      S_name:=cbuf;                                                                                                                                                                 
      S_lab:=LTRIM(S_lab);                                                                                                                                                          
      curr_line:=margin||RPAD(S_lab,8)||RPAD(S_name,22)||RPAD(S_date,5)||S_proc||                                                                                                   
         RPAD(S_proc_descr,21)||LPAD(LTRIM(S_charge),8);                                                                                                                            
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      line_num:=line_num+1;                                                                                                                                                         
      if (line_num>60) then                                                                                                                                                         
         curr_page:=curr_page+1;                                                                                                                                                    
         line_num:=1;                                                                                                                                                               
         UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                         

         UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                          
         line_num:=line_num+4;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',heading);                                                                                                                                 
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=line_num+1;                                                                                                                                                      
      end if;                                                                                                                                                                       
   end loop;                                                                                                                                                                        
   close payment_list;                                                                                                                                                              
                                                                                                                                                                                    
   last_lab:='  ';                                                                                                                                                                  
   P_code_area:='LABS';                                                                                                                                                             
   chk_charges:=0;                                                                                                                                                                  

   open lab_list;                                                                                                                                                                   
   loop                                                                                                                                                                             
      <<loop_top>>                                                                                                                                                                  
      fetch lab_list into S_lab,S_name,S_date,S_proc,S_proc_descr,                                                                                                                  
         S_charge,S_choice_code,S_collected,L_num,is_zero;                                                                                                                          
      exit when lab_list%NOTFOUND;                                                                                                                                                  
      if (last_lab=S_lab and S_choice_code<>'DOC') then                                                                                                                             
         goto loop_top;                                                                                                                                                             
      end if;                                                                                                                                                                       
      if (S_choice_code<>'DOC') then                                                                                                                                                
         S_charge:=RTRIM(S_choice_code);                                                                                                                                            
      end if;                                                                                                                                                                       
      chk_charges:=chk_charges+is_zero;                                                                                                                                             

      if (is_zero=0) then                                                                                                                                                           
         S_charge:=RTRIM('LC');                                                                                                                                                     
      end if;                                                                                                                                                                       
      S_name:=substr(S_name,1,21);                                                                                                                                                  
      curr_line:=margin||RPAD(S_lab,8)||RPAD(S_name,22)||                                                                                                                           
         RPAD(S_collected,6)||RPAD(S_proc,6)||                                                                                                                                      
         RPAD(S_proc_descr,21)||LPAD(LTRIM(S_charge),8);                                                                                                                            
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      line_num:=line_num+1;                                                                                                                                                         
      if (line_num>60) then                                                                                                                                                         
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=line_num+1;                                                                                                                                                      
         if (curr_page=1) then                                                                                                                                                      

            cbuf:='PLEASE REMIT TOTAL DUE ON LAST PAGE';                                                                                                                            
            curr_line:=LPAD(cbuf,57);                                                                                                                                               
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
            line_num:=line_num+1;                                                                                                                                                   
         end if;                                                                                                                                                                    
         curr_page:=curr_page+1;                                                                                                                                                    
         line_num:=1;                                                                                                                                                               
         UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                         
         UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                          
         line_num:=line_num+5;                                                                                                                                                      
         cbuf:=margin||'CLIENT NUMBER: '||practice_id||'     PERIOD ENDING: '||S_period;                                                                                            
         curr_line:=cbuf;                                                                                                                                                           
         cbuf:='PAGE '||to_char(curr_page)||' OF '||to_char(num_pages);                                                                                                             

         cbuf:=LPAD(cbuf,22);                                                                                                                                                       
         curr_line:=curr_line||cbuf;                                                                                                                                                
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         UTL_FILE.NEW_LINE(file_handle);                                                                                                                                            
         line_num:=line_num+2;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',heading);                                                                                                                                 
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=line_num+1;                                                                                                                                                      
      end if;                                                                                                                                                                       
      last_lab:=S_lab;                                                                                                                                                              
   end loop;                                                                                                                                                                        
   close lab_list;                                                                                                                                                                  

                                                                                                                                                                                    
   select total_charges into H_total_charges                                                                                                                                        
   from pcs.practice_accounts_history                                                                                                                                               
   where practice=S_practice and year_month=S_month;                                                                                                                                
   insert into temp_table values (H_total_charges,'H_total_charges');                                                                                                               
   insert into temp_table values (chk_charges,'chk_charges');                                                                                                                       
   if (H_total_charges<>chk_charges) then                                                                                                                                           
      chk_charges:=(H_total_charges-chk_charges);                                                                                                                                   
      commit;                                                                                                                                                                       
      pcs.update_account(S_practice,S_month,chk_charges);                                                                                                                           
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
   /* NEW STUFF */                                                                                                                                                                  

   select prior_balance,total_charges,total_payments,total_plus,total_minus,total_balance                                                                                           
   into H_prior_balance,H_total_charges,H_total_payments,                                                                                                                           
      H_total_plus,H_total_minus,H_total_balance                                                                                                                                    
   from pcs.practice_accounts_history                                                                                                                                               
   where practice=S_practice and year_month=S_month;                                                                                                                                
                                                                                                                                                                                    
   P_code_area:='FOOTER';                                                                                                                                                           
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   line_num:=line_num+1;                                                                                                                                                            
   if (line_num>50) then                                                                                                                                                            
      curr_page:=curr_page+1;                                                                                                                                                       
      line_num:=1;                                                                                                                                                                  
      UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                            

      UTL_FILE.NEW_LINE(file_handle,4);                                                                                                                                             
      line_num:=line_num+5;                                                                                                                                                         
      cbuf:=margin||'CLIENT NUMBER: '||practice_id||'     PERIOD ENDING: '||S_period;                                                                                               
      curr_line:=cbuf;                                                                                                                                                              
      cbuf:='PAGE '||to_char(curr_page)||' OF '||to_char(num_pages);                                                                                                                
      cbuf:=LPAD(cbuf,22);                                                                                                                                                          
      curr_line:=curr_line||cbuf;                                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      UTL_FILE.NEW_LINE(file_handle);                                                                                                                                               
      line_num:=line_num+2;                                                                                                                                                         
      UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                      
      line_num:=line_num+1;                                                                                                                                                         
   end if;                                                                                                                                                                          

   UTL_FILE.NEW_LINE(file_handle,2);                                                                                                                                                
   line_num:=line_num+2;                                                                                                                                                            
   ttl_pay:=TO_NUMBER(S_forwarded);                                                                                                                                                 
   cbuf:='PAST AMOUNT DUE:';                                                                                                                                                        
   curr_line:=LPAD(cbuf,60)||'      '||TO_CHAR(H_prior_balance,'99990.99');                                                                                                         
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   rcnt:=TO_NUMBER(S_ttl_payments);                                                                                                                                                 
   cbuf:='TOTAL PAYMENTS:';                                                                                                                                                         
   curr_line:=LPAD(cbuf,60)||'   -  '||TO_CHAR(H_total_payments,'99990.99');                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   ttl_pay:=ttl_pay-rcnt;                                                                                                                                                           

   cbuf:='------------';                                                                                                                                                            
   curr_line:=LPAD(cbuf,75);                                                                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   H_tmp_num:=H_prior_balance-H_total_payments;                                                                                                                                     
   cbuf2:=TO_CHAR(H_tmp_num,'99990.99');                                                                                                                                            
   cbuf:='PAST BALANCE:';                                                                                                                                                           
   curr_line:=LPAD(cbuf,60)||' $    '||cbuf2;                                                                                                                                       
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   rcnt:=TO_NUMBER(S_curr_amount);                                                                                                                                                  
   ttl_pay:=ttl_pay+rcnt;                                                                                                                                                           
   cbuf:='CURRENT CHARGES:';                                                                                                                                                        

   curr_line:=LPAD(cbuf,60)||'    + '||TO_CHAR(H_total_charges,'99990.99');                                                                                                         
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   cbuf:='------------';                                                                                                                                                            
   curr_line:=LPAD(cbuf,75);                                                                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   H_tmp_num:=H_tmp_num+H_total_charges;                                                                                                                                            
   cbuf:='CURRENT BALANCE:';                                                                                                                                                        
   cbuf2:=TO_CHAR(H_tmp_num,'99990.99');                                                                                                                                            
   curr_line:=LPAD(cbuf,60)||' $    '||cbuf2;                                                                                                                                       
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   rcnt:=TO_NUMBER(S_ttl_minus_adjusts);                                                                                                                                            

   ttl_pay:=ttl_pay-rcnt;                                                                                                                                                           
   rcnt:=TO_NUMBER(S_ttl_plus_adjusts);                                                                                                                                             
   ttl_pay:=ttl_pay+rcnt;                                                                                                                                                           
   cbuf:='TOTAL MINUS ADJUSTMENTS:';                                                                                                                                                
   curr_line:=LPAD(cbuf,60)||'    - '||TO_CHAR(H_total_minus,'99990.99');                                                                                                           
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   cbuf:='TOTAL PLUS ADJUSTMENTS:';                                                                                                                                                 
   curr_line:=LPAD(cbuf,60)||'    + '||TO_CHAR(H_total_plus,'99990.99');                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   cbuf:='------------';                                                                                                                                                            
   curr_line:=LPAD(cbuf,75);                                                                                                                                                        

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   -- added 02/04 to see if corrects                                                                                                                                                
   S_ttl_amount:=TO_CHAR(ttl_pay,'99990.99');                                                                                                                                       
   if (H_total_balance>=0) then                                                                                                                                                     
   	cbuf:='TOTAL AMOUNT DUE:';                                                                                                                                                      
      curr_line:=LPAD(cbuf,60)||' $    '||TO_CHAR(H_total_balance,'99990.99');                                                                                                      
   else                                                                                                                                                                             
	   cbuf:='CREDIT AMOUNT:';                                                                                                                                                         
      curr_line:=LPAD(cbuf,60)||' $   ('||TO_CHAR(H_total_balance,'99990.99')||')';                                                                                                 
   end if;                                                                                                                                                                          
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            

                                                                                                                                                                                    
   UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                               
   UTL_FILE.FCLOSE(file_handle);                                                                                                                                                    
                                                                                                                                                                                    
   update pcs.practice_statements set file_name=S_file_name                                                                                                                         
   where practice=S_practice and statement_id=stmt_id;                                                                                                                              
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
\

grant execute on build_doctor_statement to pcs_user ; 
\