                                       
procedure make_jc_invoice                                                                                                                                                           
(                                                                                                                                                                                   
   invoice_id in number,                                                                                                                                                            
   close_out in number                                                                                                                                                              
)                                                                                                                                                                                   
as                                                                                                                                                                                  
   file_name varchar2(64);                                                                                                                                                          
   cbuf1 varchar2(4000);                                                                                                                                                            
   s_time varchar2(32);                                                                                                                                                             
   e_time varchar2(32);                                                                                                                                                             

   i_descr varchar2(4000);                                                                                                                                                          
   i_hours varchar2(32);                                                                                                                                                            
   i_dollars varchar2(32);                                                                                                                                                          
   dline varchar2(128);                                                                                                                                                             
   i_value number;                                                                                                                                                                  
   cursor inv_list is                                                                                                                                                               
      select to_char(start_time,'MM/DD/YYYY HH:MI AM'),                                                                                                                             
         to_char(end_time,'MM/DD/YYYY HH:MI AM'),description,                                                                                                                       
         to_char(hours_worked,'90.9999'),to_char(dollars_made,'990.99')                                                                                                             
         from jc_invoice where inv_id=invoice_id order by start_time;                                                                                                               
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               

   dline:='-----------------------------------------------------------------------------';                                                                                          
   select to_char(sysdate,'MMDD') into cbuf1 from dual;                                                                                                                             
   file_name:=TO_CHAR(invoice_id)||cbuf1||'.inv';                                                                                                                                   
   file_handle:=UTL_FILE.FOPEN('vol1:',file_name,'w');                                                                                                                              
   UTL_FILE.PUTF(file_handle,'%s\n\n\n','INVOICE #'||invoice_id);                                                                                                                   
   UTL_FILE.PUTF(file_handle,'%s\n','SERVICES TO:    PA Cytology Services');                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n','                339 Haymaker Road');                                                                                                           
   UTL_FILE.PUTF(file_handle,'%s\n\n','                Monroeville, PA 15146');                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n','PROVIDED BY:    John Cardella, Software Engineer');                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n','                190 Stacie Lane');                                                                                                             
   UTL_FILE.PUTF(file_handle,'%s\n','                Edinburg, PA  16116');                                                                                                         
   UTL_FILE.PUTF(file_handle,'%s\n\n','                HOME: 724.652.6113');                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n\n','                CELL: 724.674.3510');                                                                                                        

   select to_char(sysdate,'MM/DD/YYYY') into cbuf1 from dual;                                                                                                                       
   UTL_FILE.PUTF(file_handle,'%s\n','INVOICE DATE:   '||cbuf1);                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n\n',    'CURRENT RATE:   40.00');                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n','DATE/TIME IN:        DAY/TIME OUT:                           HOURS:   AMOUNT:');                                                               
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   open inv_list;                                                                                                                                                                   
   loop                                                                                                                                                                             
      fetch inv_list into s_time,e_time,i_descr,i_hours,i_dollars;                                                                                                                  
      exit when inv_list%NOTFOUND;                                                                                                                                                  
      cbuf1:=s_time||'  '||e_time||'                  '||i_hours||'    '||i_dollars;                                                                                                
      UTL_FILE.PUTF(file_handle,'%s\n\n',cbuf1);                                                                                                                                    
   end loop;                                                                                                                                                                        
   close inv_list;                                                                                                                                                                  

   select to_char(sum(hours_worked),'990.9999'),to_char(sum(dollars_made),'9,990.99')                                                                                               
   into i_hours,i_dollars from jc_invoice where inv_id=invoice_id;                                                                                                                  
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   cbuf1:='TOTAL HOURS/AMOUNT DUE                                   '||i_hours||'  '||i_dollars;                                                                                    
   UTL_FILE.PUTF(file_handle,'%s\n',cbuf1);                                                                                                                                         
   UTL_FILE.NEW_LINE(file_handle,6);                                                                                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n','PLEASE SEND COPY WITH CHECK. THANKS!');                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',    'SEND TO:        John Cardella');                                                                                                           
   UTL_FILE.PUTF(file_handle,'%s\n',    '                411 Fifth Street');                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',    '                New Castle, PA  16102');                                                                                                   
   UTL_FILE.NEW_LINE(file_handle,6);                                                                                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n\n','SUMMARY OF HOURS WORKED');                                                                                                                   
   UTL_FILE.PUTF(file_handle,'%s\n','DATE/TIME IN:            DESCRIPTION:');                                                                                                       

   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   open inv_list;                                                                                                                                                                   
   loop                                                                                                                                                                             
      fetch inv_list into s_time,e_time,i_descr,i_hours,i_dollars;                                                                                                                  
      exit when inv_list%NOTFOUND;                                                                                                                                                  
      cbuf1:=s_time||'      '||i_descr;                                                                                                                                             
      UTL_FILE.PUTF(file_handle,'%s\n\n',cbuf1);                                                                                                                                    
   end loop;                                                                                                                                                                        
   close inv_list;                                                                                                                                                                  
                                                                                                                                                                                    
   UTL_FILE.FCLOSE(file_handle);                                                                                                                                                    
   if (close_out=1) then                                                                                                                                                            
      select max(inv_id) into i_value from jc_invoice;                                                                                                                              

      i_value:=(i_value+1)*(-1);                                                                                                                                                    
      update jc_invoice set inv_id=i_value where inv_id<0;                                                                                                                          
   end if;                                                                                                                                                                          
                                                                                                                                                                                    
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
      RAISE_APPLICATION_ERROR(-20054,'invalid operation ');                                                                                                                         
   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20055,'read error');                                                                                                                                 
   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20056,'write error');                                                                                                                                
   when NO_DATA_FOUND then                                                                                                                                                          
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20057,'no data found');                                                                                                                              

   when VALUE_ERROR then                                                                                                                                                            
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20058,'value error ');                                                                                                                               
   when OTHERS then                                                                                                                                                                 
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
                                                                                                                                                                                    
end;                                                                                                                                         