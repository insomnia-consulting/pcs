create or replace procedure     analyze_activity_2                                                                                                                                                    
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   B_rebilling number;                                                                                                                                                              
   P_name varchar2(24);                                                                                                                                                             
   L_finished number;                                                                                                                                                               
   B_choice varchar2(3);                                                                                                                                                            
   C_carrier number;                                                                                                                                                                

   C_name varchar2(32);                                                                                                                                                             
   B_amount varchar2(10);                                                                                                                                                           
   P_amount varchar2(10);                                                                                                                                                           
   P_due varchar2(32);                                                                                                                                                              
   B_lab varchar2(16);                                                                                                                                                              
   B_allow varchar2(32);                                                                                                                                                            
                                                                                                                                                                                    
   P_date varchar2(16);                                                                                                                                                             
   P_type varchar2(16);                                                                                                                                                             
                                                                                                                                                                                    
   C_status varchar2(2);                                                                                                                                                            
                                                                                                                                                                                    
   heading_1 varchar2(64);                                                                                                                                                          

                                                                                                                                                                                    
   rec_count number;                                                                                                                                                                
   rcnt number;                                                                                                                                                                     
   d_flag number;                                                                                                                                                                   
   curr_line varchar2(100);                                                                                                                                                         
   ttl_payments number;                                                                                                                                                             
   ttl_plus number;                                                                                                                                                                 
   ttl_minus number;                                                                                                                                                                
   ttl_due number;                                                                                                                                                                  
                                                                                                                                                                                    
   line_cntr number;                                                                                                                                                                
   cursor billing_list is select * from lab_billings where lab_number in                                                                                                            
      (select lab_number from pcs.lab_claims where claim_status='O')                                                                                                                

   order by lab_number;                                                                                                                                                             
   billing_fields billing_list%ROWTYPE;                                                                                                                                             
                                                                                                                                                                                    
   cursor payment_list is select * from pcs.payments                                                                                                                                
   where lab_number=billing_fields.lab_number                                                                                                                                       
   order by payment_id;                                                                                                                                                             
   payment_fields payment_list%ROWTYPE;                                                                                                                                             
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='ANALYZE_ACTIVITY';                                                                                                                                                 

   P_code_area:='PREP';                                                                                                                                                             
                                                                                                                                                                                    
   file_handle:=UTL_FILE.FOPEN('REPORTS_DIR','billing.rpt','w');                                                                                                                          
   UTL_FILE.NEW_LINE(file_handle);                                                                                                                                                  
                                                                                                                                                                                    
   heading_1:='   SUMMARY OF CLAIMS WITH STATUS OF "O"';                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',heading_1);                                                                                                                                     
   UTL_FILE.NEW_LINE(file_handle,2);                                                                                                                                                
   line_cntr:=4;                                                                                                                                                                    
                                                                                                                                                                                    
   rec_count:=0;                                                                                                                                                                    
   open billing_list;                                                                                                                                                               
   loop                                                                                                                                                                             

      <<loop_top>>                                                                                                                                                                  
      P_code_area:='FETCH';                                                                                                                                                         
      fetch billing_list into billing_fields;                                                                                                                                       
      exit when billing_list%NOTFOUND;                                                                                                                                              
      P_code_area:='FORMAT';                                                                                                                                                        
      d_flag:=0;                                                                                                                                                                    
      select MAX(rebilling) into B_rebilling from pcs.billing_details                                                                                                               
      where lab_number=billing_fields.lab_number;                                                                                                                                   
      if (B_rebilling<>billing_fields.rebilling) then                                                                                                                               
         d_flag:=1;                                                                                                                                                                 
      end if;                                                                                                                                                                       
      if (billing_fields.billing_choice NOT IN (124,123,125,126)) then                                                                                                              
         goto loop_top;                                                                                                                                                             

      end if;                                                                                                                                                                       
      select count(*) into rcnt from pcs.lab_claims a, pcs.billing_details b                                                                                                        
      where a.claim_id=b.claim_id and b.rebilling=billing_fields.rebilling                                                                                                          
      and a.lab_number=billing_fields.lab_number;                                                                                                                                   
      if (rcnt>0) then                                                                                                                                                              
         select claim_status into C_status from pcs.lab_claims a, pcs.billing_details b                                                                                             
         where a.claim_id=b.claim_id and b.rebilling=billing_fields.rebilling                                                                                                       
         and a.lab_number=billing_fields.lab_number;                                                                                                                                
      else                                                                                                                                                                          
         goto loop_top;                                                                                                                                                             
      end if;                                                                                                                                                                       
      if (C_status<>'O') then                                                                                                                                                       
         goto loop_top;                                                                                                                                                             

      end if;                                                                                                                                                                       
      if (line_cntr>=45) then                                                                                                                                                       
         UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                         
         UTL_FILE.PUTF(file_handle,'%s\n',heading_1);                                                                                                                               
         UTL_FILE.NEW_LINE(file_handle,2);                                                                                                                                          
         line_cntr:=4;                                                                                                                                                              
      end if;                                                                                                                                                                       
      select SUBSTR(lname||', '||fname,1,24),finished into P_name,L_finished                                                                                                        
      from pcs.patients a, pcs.lab_requisitions b                                                                                                                                   
      where a.patient=b.patient and b.lab_number=billing_fields.lab_number;                                                                                                         
      if (L_finished>=4) then                                                                                                                                                       
         goto loop_top;                                                                                                                                                             
      end if;                                                                                                                                                                       

      rec_count:=rec_count+1;                                                                                                                                                       
      curr_line:='   --------------------------------------------------------------------------';                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      line_cntr:=line_cntr+1;                                                                                                                                                       
      select choice_code, carrier_id into B_choice, C_carrier                                                                                                                       
      from pcs.billing_choices a, pcs.billing_details b                                                                                                                             
      where a.billing_choice=b.billing_choice and b.lab_number=billing_fields.lab_number                                                                                            
         and b.rebilling=B_rebilling;                                                                                                                                               
      if (B_choice in ('BS','DPA','MED','OI')) then                                                                                                                                 
         select SUBSTR(name,1,24) into C_name from pcs.carriers where carrier_id=C_carrier;                                                                                         
      else                                                                                                                                                                          
         C_name:=B_choice;                                                                                                                                                          
      end if;                                                                                                                                                                       

      B_amount:=TO_CHAR(billing_fields.bill_amount,'990.00');                                                                                                                       
      B_lab:=LTRIM(RTRIM(TO_CHAR(billing_fields.lab_number)));                                                                                                                      
      if (d_flag=1) then B_lab:='*'||B_lab;                                                                                                                                         
      else B_lab:=' '||B_lab;                                                                                                                                                       
      end if;                                                                                                                                                                       
      curr_line:='   '||B_lab||' '||RPAD(P_name,20)||' '||RPAD(C_name,20)||' '||LPAD(B_amount,10);                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                
      line_cntr:=line_cntr+1;                                                                                                                                                       
      ttl_payments:=0;                                                                                                                                                              
      ttl_plus:=0;                                                                                                                                                                  
      ttl_minus:=0;                                                                                                                                                                 
      P_code_area:='PAYMENT';                                                                                                                                                       
      open payment_list;                                                                                                                                                            

      loop                                                                                                                                                                          
         P_code_area:='PAYMENT FETCH';                                                                                                                                              
         fetch payment_list into payment_fields;                                                                                                                                    
         exit when payment_list%NOTFOUND;                                                                                                                                           
         P_code_area:='PAYMENT FORMAT';                                                                                                                                             
         if (payment_fields.payment_type='PLUS ADJUST') then                                                                                                                        
            ttl_plus:=ttl_plus+payment_fields.payment_amount;                                                                                                                       
         elsif (payment_fields.payment_type='MINUS ADJUST') then                                                                                                                    
            ttl_minus:=ttl_minus+payment_fields.payment_amount;                                                                                                                     
         else                                                                                                                                                                       
            ttl_payments:=ttl_payments+payment_fields.payment_amount;                                                                                                               
         end if;                                                                                                                                                                    
         P_date:=TO_CHAR(payment_fields.receive_date,'MM/DD/YYYY');                                                                                                                 

         P_amount:=TO_CHAR(payment_fields.payment_amount,'990.00');                                                                                                                 
         P_amount:=LPAD(P_amount,10);                                                                                                                                               
         P_type:=RPAD(payment_fields.payment_type,12);                                                                                                                              
         curr_line:='      '||P_date||'  '||P_type||'  '||P_amount;                                                                                                                 
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_cntr:=line_cntr+1;                                                                                                                                                    
      end loop;                                                                                                                                                                     
      close payment_list;                                                                                                                                                           
      P_code_area:='FOOTER';                                                                                                                                                        
      if (ttl_payments+ttl_plus+ttl_minus>0) then                                                                                                                                   
         UTL_FILE.NEW_LINE(file_handle);                                                                                                                                            
         line_cntr:=line_cntr+1;                                                                                                                                                    
      end if;                                                                                                                                                                       

      if (billing_fields.allowance is NOT NULL) then                                                                                                                                
         ttl_due:=billing_fields.allowance;                                                                                                                                         
         B_allow:=TO_CHAR(billing_fields.allowance,'990.00');                                                                                                                       
         B_allow:=LPAD(B_allow,10);                                                                                                                                                 
         B_allow:='ALLOWANCE: '||B_allow;                                                                                                                                           
         curr_line:='      '||B_allow;                                                                                                                                              
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_cntr:=line_cntr+1;                                                                                                                                                    
      else                                                                                                                                                                          
         ttl_due:=billing_fields.bill_amount;                                                                                                                                       
      end if;                                                                                                                                                                       
      ttl_due:=ttl_due+ttl_plus;                                                                                                                                                    
      ttl_due:=ttl_due-ttl_minus;                                                                                                                                                   

      ttl_due:=ttl_due-ttl_payments;                                                                                                                                                
      if (B_choice='DOC' and billing_fields.balance<=0) then                                                                                                                        
         ttl_due:=0;                                                                                                                                                                
      end if;                                                                                                                                                                       
      P_due:=TO_CHAR(ttl_due,'990.00');                                                                                                                                             
      P_due:=LPAD(P_due,10);                                                                                                                                                        
      P_due:='BALANCE:   '||P_due;                                                                                                                                                  
      curr_line:='      '||P_due;                                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      line_cntr:=line_cntr+1;                                                                                                                                                       
   end loop;                                                                                                                                                                        
   close billing_list;                                                                                                                                                              
   curr_line:='  TOTAL ACCOUNTS: '||TO_CHAR(rec_count);                                                                                                                             

   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                                   
                                                                                                                                                                                    
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,billing_fields.lab_number);                                                                          
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                                                                                                                                         
\

grant execute on analyze_activity_2 to pcs_user 
\