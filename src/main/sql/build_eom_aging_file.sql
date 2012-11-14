create or replace procedure     build_eom_aging_file                                                                                                                                                  
(                                                                                                                                                                                   

   S_month number                                                                                                                                                                   
)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   cursor practice_list is                                                                                                                                                          
      select TO_CHAR(P.practice,'009'),P.name,SUBSTR(P.address1,1,32),SUBSTR(P.address2,1,32),                                                                                      
         P.city,P.state,P.zip,NVL(SUBSTR(P.contact,1,31),'NONE'),P.phone,P.stop_code,P.price_code,                                                                                  
         TO_CHAR(A.curr_balance,'999,990.99'),TO_CHAR(A.over30_balance,'999,990.99'),                                                                                               

         TO_CHAR(A.over60_balance,'999,990.99'),TO_CHAR(A.over90_balance,'999,990.99'),                                                                                             
         TO_CHAR(A.total_balance,'999,990.99'),TO_CHAR(A.last_payment,'999,990.99'),                                                                                                
         TO_CHAR(A.last_payment_date,'MM-DD-YYYY')                                                                                                                                  
      from pcs.practices P, pcs.practice_accounts A                                                                                                                                 
      where P.practice=A.practice and A.total_balance<>0                                                                                                                            
      order by P.practice;                                                                                                                                                          
                                                                                                                                                                                    
   S_period varchar2(32);                                                                                                                                                           
   P_practice varchar2(8);                                                                                                                                                          
   P_name varchar2(64);                                                                                                                                                             
   P_address1 varchar2(32);                                                                                                                                                         
   P_address2 varchar2(32);                                                                                                                                                         
   P_city varchar2(32);                                                                                                                                                             

   P_state char(2);                                                                                                                                                                 
   P_zip varchar2(10);                                                                                                                                                              
   P_curr_balance varchar2(16);                                                                                                                                                     
   P_over30_balance varchar2(16);                                                                                                                                                   
   P_over60_balance varchar2(16);                                                                                                                                                   
   P_over90_balance varchar2(16);                                                                                                                                                   
   P_total_balance varchar2(16);                                                                                                                                                    
   P_last_payment varchar2(16);                                                                                                                                                     
   P_last_payment_date varchar2(16);                                                                                                                                                
   P_contact varchar2(32);                                                                                                                                                          
   P_phone varchar2(16);                                                                                                                                                            
   P_stop_code char(1);                                                                                                                                                             
   P_price_code varchar2(2);                                                                                                                                                        

   P_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
   curr_line varchar2(200);                                                                                                                                                         
   heading varchar2(100);                                                                                                                                                           
   heading_x varchar2(100);                                                                                                                                                         
   cbuf1 varchar2(128);                                                                                                                                                             
   cbuf2 varchar2(128);                                                                                                                                                             
   line_num number;                                                                                                                                                                 
   curr_page number;                                                                                                                                                                
   rcnt number;                                                                                                                                                                     
   margin varchar2(32);                                                                                                                                                             
   dline varchar2(128);                                                                                                                                                             
   accum_current number;                                                                                                                                                            

   accum_30 number;                                                                                                                                                                 
   accum_60 number;                                                                                                                                                                 
   accum_90 number;                                                                                                                                                                 
   accum_total number;                                                                                                                                                              
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_EOM_AGING_FILE';                                                                                                                                             
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   cbuf1:=TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM')),'MONYYYY');                                                                                                          

   P_file_name:=cbuf1||'.age';                                                                                                                                                      
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,P_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   select TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM')),'MONTH YYYY')                                                                                                        
   into S_period from dual;                                                                                                                                                         
                                                                                                                                                                                    
   curr_page:=1;                                                                                                                                                                    
   margin:='  ';                                                                                                                                                                    
   dline:='------------------------------------------------------------------------------';                                                                                         
   accum_current:=0;                                                                                                                                                                
   accum_30:=0;                                                                                                                                                                     
   accum_60:=0;                                                                                                                                                                     

   accum_90:=0;                                                                                                                                                                     
   accum_total:=0;                                                                                                                                                                  
                                                                                                                                                                                    
   rcnt:=7;                                                                                                                                                                         
   P_code_area:='PRACTICE';                                                                                                                                                         
   open practice_list;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch practice_list into                                                                                                                                                      
         P_practice,P_name,P_address1,P_address2,P_city,P_state,P_zip,                                                                                                              
         P_contact,P_phone,P_stop_code,P_price_code,P_curr_balance,                                                                                                                 
         P_over30_balance,P_over60_balance,P_over90_balance,P_total_balance,                                                                                                        
         P_last_payment,P_last_payment_date;                                                                                                                                        
      exit when practice_list%NOTFOUND;                                                                                                                                             

      P_code_area:='DATA FETCHED';                                                                                                                                                  
      if (P_last_payment is null) then                                                                                                                                              
         P_last_payment:='    ';                                                                                                                                                    
      end if;                                                                                                                                                                       
      if (P_last_payment_date is null) then                                                                                                                                         
         P_last_payment_date:='    ';                                                                                                                                               
      end if;                                                                                                                                                                       
      rcnt:=rcnt+1;                                                                                                                                                                 
      accum_current:=accum_current+TO_NUMBER(REPLACE(P_curr_balance,',',null));                                                                                                     
      accum_30:=accum_30+TO_NUMBER(REPLACE(P_over30_balance,',',null));                                                                                                             
      accum_60:=accum_60+TO_NUMBER(REPLACE(P_over60_balance,',',null));                                                                                                             
      accum_90:=accum_90+TO_NUMBER(REPLACE(P_over90_balance,',',null));                                                                                                             
      accum_total:=accum_total+TO_NUMBER(REPLACE(P_total_balance,',',null));                                                                                                        

      if (rcnt=8) then                                                                                                                                                              
         rcnt:=0;                                                                                                                                                                   
         if (curr_page>1) then                                                                                                                                                      
            UTL_FILE.PUTF(file_handle,'%s\n',margin||dline);                                                                                                                        
            UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                      
         end if;                                                                                                                                                                    
         UTL_FILE.NEW_LINE(file_handle,2);                                                                                                                                          
         cbuf1:=LPAD('PAGE '||LTRIM(TO_CHAR(curr_page,'999')),48);                                                                                                                  
         curr_line:=margin||'PENNSYLVANIA CYTOLOGY SERVICES'||cbuf1;                                                                                                                
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         curr_line:=margin||'DOCTOR END OF MONTH AGING REPORT'||LPAD(S_period,46);                                                                                                  
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         curr_page:=curr_page+1;                                                                                                                                                    

      end if;                                                                                                                                                                       
      curr_line:=margin||dline;                                                                                                                                                     
      /*                                                                                                                                                                            
         LINE 1 OF DATA BLOCK                                                                                                                                                       
      */                                                                                                                                                                            
      P_code_area:='LINE 1';                                                                                                                                                        
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      cbuf1:=RPAD('ACCOUNT #'||P_practice,50);                                                                                                                                      
      cbuf2:=RPAD('LAST PAYMENT:',15)||LPAD(P_last_payment,12);                                                                                                                     
      curr_line:=margin||cbuf1||cbuf2;                                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
         LINE 2 OF DATA BLOCK                                                                                                                                                       

      */                                                                                                                                                                            
      P_code_area:='LINE 2';                                                                                                                                                        
      cbuf1:=RPAD(SUBSTR(P_name,1,40),50);                                                                                                                                          
      cbuf2:=RPAD('DATE PAID:',15)||LPAD(P_last_payment_date,12);                                                                                                                   
      curr_line:=margin||cbuf1||cbuf2;                                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
         LINE 3 OF DATA BLOCK                                                                                                                                                       
      */                                                                                                                                                                            
      P_code_area:='LINE 3';                                                                                                                                                        
      cbuf1:=RPAD(SUBSTR(P_address1,1,40),50);                                                                                                                                      
      curr_line:=margin||cbuf1;                                                                                                                                                     
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

      /*                                                                                                                                                                            
         LINE 4 OF DATA BLOCK                                                                                                                                                       
      */                                                                                                                                                                            
      P_code_area:='LINE 4';                                                                                                                                                        
      if (P_address2 is not null) then                                                                                                                                              
         cbuf1:=RPAD(SUBSTR(P_address2,1,40),50);                                                                                                                                   
      else                                                                                                                                                                          
         cbuf1:=RPAD(SUBSTR(P_city||' '||P_state||'  '||SUBSTR(P_zip,1,5),1,38),50);                                                                                                
      end if;                                                                                                                                                                       
      curr_line:=margin||cbuf1;                                                                                                                                                     
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
         LINE 5 OF DATA BLOCK                                                                                                                                                       

      */                                                                                                                                                                            
      P_code_area:='LINE 5';                                                                                                                                                        
      if (P_address2 is not null) then                                                                                                                                              
         cbuf1:=RPAD(SUBSTR(P_city||' '||P_state||'  '||SUBSTR(P_zip,1,5),1,38),50);                                                                                                
      else                                                                                                                                                                          
         cbuf1:=RPAD(' ',50);                                                                                                                                                       
      end if;                                                                                                                                                                       
      cbuf2:=RPAD('CURRENT:',15)||LPAD(P_curr_balance,12);                                                                                                                          
      curr_line:=margin||cbuf1||cbuf2;                                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
         LINE 6 OF DATA BLOCK                                                                                                                                                       
      */                                                                                                                                                                            

      P_code_area:='LINE 6';                                                                                                                                                        
      cbuf1:=RPAD(' ',50);                                                                                                                                                          
      cbuf2:=RPAD('PAST 30:',15)||LPAD(P_over30_balance,12);                                                                                                                        
      curr_line:=margin||cbuf1||cbuf2;                                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
         LINE 7 OF DATA BLOCK                                                                                                                                                       
      */                                                                                                                                                                            
      P_code_area:='LINE 7';                                                                                                                                                        
      cbuf1:=RPAD('CONTACT:',10)||RPAD(SUBSTR(P_contact,1,30),40);                                                                                                                  
      cbuf2:=RPAD('PAST 60:',15)||LPAD(P_over60_balance,12);                                                                                                                        
      curr_line:=margin||cbuf1||cbuf2;                                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

      /*                                                                                                                                                                            
         LINE 8 OF DATA BLOCK                                                                                                                                                       
      */                                                                                                                                                                            
      P_code_area:='LINE 8';                                                                                                                                                        
      if (P_phone is not null) then                                                                                                                                                 
         cbuf1:=SUBSTR(P_phone,1,3)||'.'||SUBSTR(P_phone,4,3)||'.'||SUBSTR(P_phone,7);                                                                                              
      else                                                                                                                                                                          
         cbuf1:=' ';                                                                                                                                                                
      end if;                                                                                                                                                                       
      P_phone:=cbuf1;                                                                                                                                                               
      cbuf1:=RPAD('PHONE:',10)||RPAD(SUBSTR(P_phone,1,30),40);                                                                                                                      
      cbuf2:=RPAD('PAST 90:',15)||LPAD(P_over90_balance,12);                                                                                                                        
      curr_line:=margin||cbuf1||cbuf2;                                                                                                                                              

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      /*                                                                                                                                                                            
         LINE 9 OF DATA BLOCK                                                                                                                                                       
      */                                                                                                                                                                            
      P_code_area:='LINE 9A';                                                                                                                                                       
      cbuf1:=RPAD('CODES:',10)||RPAD('P['||P_price_code||']  S['||P_stop_code||']',40);                                                                                             
      P_code_area:='LINE 9B';                                                                                                                                                       
      cbuf2:=RPAD('TOTAL:',15)||LPAD(P_total_balance,12);                                                                                                                           
      P_code_area:='LINE 9C';                                                                                                                                                       
      curr_line:=margin||cbuf1||cbuf2;                                                                                                                                              
      P_code_area:='LINE 9D';                                                                                                                                                       
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      P_code_area:='LINE 9E';                                                                                                                                                       

   end loop;                                                                                                                                                                        
   close practice_list;                                                                                                                                                             
                                                                                                                                                                                    
   P_code_area:='FOOTER';                                                                                                                                                           
   if (rcnt=8) then                                                                                                                                                                 
      rcnt:=0;                                                                                                                                                                      
      if (curr_page>1) then                                                                                                                                                         
         UTL_FILE.PUTF(file_handle,'%s\n',margin||dline);                                                                                                                           
         UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                         
      end if;                                                                                                                                                                       
      UTL_FILE.NEW_LINE(file_handle,2);                                                                                                                                             
      cbuf1:=LPAD('PAGE '||LTRIM(TO_CHAR(curr_page,'999')),48);                                                                                                                     
      curr_line:=margin||'PENNSYLVANIA CYTOLOGY SERVICES'||cbuf1;                                                                                                                   

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_line:=margin||'DOCTOR END OF MONTH AGING REPORT'||LPAD(S_period,46);                                                                                                     
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      curr_page:=curr_page+1;                                                                                                                                                       
   end if;                                                                                                                                                                          
   UTL_FILE.PUTF(file_handle,'%s\n',margin||dline);                                                                                                                                 
   UTL_FILE.NEW_LINE(file_handle);                                                                                                                                                  
   cbuf1:=LPAD(' ',50);                                                                                                                                                             
   cbuf2:='ACCUMULATIVE TOTALS';                                                                                                                                                    
   curr_line:=margin||cbuf1||cbuf2;                                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.NEW_LINE(file_handle);                                                                                                                                                  
   cbuf2:=RPAD('CURRENT:',15)||LPAD(TO_CHAR(accum_current,'999,990.99'),12);                                                                                                        

   curr_line:=margin||cbuf1||cbuf2;                                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   cbuf2:=RPAD('PAST 30:',15)||LPAD(TO_CHAR(accum_30,'999,990.99'),12);                                                                                                             
   curr_line:=margin||cbuf1||cbuf2;                                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   cbuf2:=RPAD('PAST 60:',15)||LPAD(TO_CHAR(accum_60,'999,990.99'),12);                                                                                                             
   curr_line:=margin||cbuf1||cbuf2;                                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   cbuf2:=RPAD('PAST 90:',15)||LPAD(TO_CHAR(accum_90,'999,990.99'),12);                                                                                                             
   curr_line:=margin||cbuf1||cbuf2;                                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   cbuf2:=RPAD('TOTAL:',15)||LPAD(TO_CHAR(accum_total,'999,990.99'),12);                                                                                                            
   curr_line:=margin||cbuf1||cbuf2;                                                                                                                                                 

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUT(file_handle,CHR(12));                                                                                                                                               
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
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,TO_NUMBER(P_practice));                                                                              
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;   
\

grant execute on build_eom_aging_file to pcs_user ; 
\