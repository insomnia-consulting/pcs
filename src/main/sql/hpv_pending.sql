drop procedure hpv_pending
\

CREATE OR REPLACE function hpv_pending
return clob
is                                                                              
                                                                                
   P_error_code number;                                                         
   P_error_message varchar2(512);                                               
   P_proc_name varchar2(32);                                                    
   P_code_area varchar2(32);                                                    
                                                                                
   H_lab number;                                                                
   H_date varchar2(12);                                                         
   P_name varchar2(32);                                                         
   P_account varchar2(6);                                                       
   reportOutput clob;                                                                            

   rcnt number;                                                                 
   curr_line varchar2(128);                                                     
   line_cntr number;                                                            
      
                                                                                
   cursor hpv_list is                                                           
	select lab_number, TO_CHAR(datestamp,'MM/DD/YYYY')                             
      from pcs.hpv_requests                                                     
   	where (test_sent is NULL or test_sent IN ('R','P')) 
   	--and rownum < 5
   	order by lab_number;                                                        

begin                                                                           
return null;                                                                                
										  P_proc_name:='HPV_PENDING';                                                  
   P_code_area:='PREP';                                                         
   line_cntr:=0;                                                                
   reportOutput := '';
   open hpv_list; 
   
   DBMS_LOB.CREATETEMPORARY(reportOutput,true);
   loop 
   	  
      P_code_area:='FETCH';                                                     
      fetch hpv_list into H_lab,H_date;                                         
      exit when hpv_list%NOTFOUND;                                              
		
      P_code_area:='FORMAT';                                                    
      if (line_cntr>=60 or line_cntr=0) then                                    
         if (line_cntr>0) then                                                  
            dbms_lob.writeAppend(reportOutput, length(CHR(12)), chr(12));                                  
         end if;
         dbms_lob.writeAppend(reportOutput, length('\n\n'), '\n\n');                                  
         dbms_lob.writeAppend(reportOutput, length('\n\n'), '\n\n');                                  
         curr_line:='PENDING HPV REQUESTS\n\n';
         dbms_lob.writeAppend(reportOutput, length(curr_line), curr_line);
         curr_line:='LAB#          ACCT    PATIENT';                    
         dbms_lob.writeAppend(reportOutput, length(curr_line), curr_line);
         line_cntr:=5;                                                          
      end if;                                                                   
      curr_line:=  '--------------------------------------------------------------------------';
      dbms_lob.writeAppend(reportOutput, length(curr_line), curr_line);

      dbms_lob.writeAppend(reportOutput, length(curr_line), curr_line);    

      line_cntr:=line_cntr+1;                                                   
      select RPAD(SUBSTR(lname||', '||fname,1,24),26),TO_CHAR(b.practice,'009') 
      into P_name,P_account                                                     
      from pcs.patients a, pcs.lab_requisitions b                               
      where a.patient=b.patient and b.lab_number=H_lab;                         
      curr_line:=TO_CHAR(H_lab)||'    '||P_account||'    '||P_name;
      dbms_lob.writeAppend(reportOutput, length(curr_line), curr_line);    
      line_cntr:=line_cntr+1;                                                   
   end loop;                                                                    
   close hpv_list;                                                         
	dbms_lob.writeAppend(reportOutput, length(CHR(12)), chr(12));
   return reportOutput; 
                                                                                
exception                                                                       

  when OTHERS then                                                             

     P_error_code:=SQLCODE;                                                    
     P_error_message:=SQLERRM;                                                 
     insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                        
     values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,H_lab);                                                                          
                                                                               
     commit;                                                                   
     RAISE;                                                                    


end;
\