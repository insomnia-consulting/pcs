create or replace procedure     build_WV_invoice_summary_8                                                                                                                                            
(                                                                                                                                                                                   
   S_month in number,                                                                                                                                                               
   cycle in number,                                                                                                                                                                 
   pgm in varchar2                                                                                                                                                                  
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
                                                                                                                                                                                    
   WV_name varchar2(64);                                                                                                                                                            
                                                                                                                                                                                    
   tran_item varchar2(16);                                                                                                                                                          
   tran_total number;                                                                                                                                                               
   grand_total number;                                                                                                                                                              

                                                                                                                                                                                    
   dline varchar2(256);                                                                                                                                                             
   dline2 varchar2(256);                                                                                                                                                            
   heading1A varchar2(256);                                                                                                                                                         
   heading1B varchar2(256);                                                                                                                                                         
   heading1C varchar2(256);                                                                                                                                                         
   heading1D varchar2(256);                                                                                                                                                         
   heading2 varchar2(256);                                                                                                                                                          
   heading3A varchar2(256);                                                                                                                                                         
   heading3B varchar2(256);                                                                                                                                                         
   heading3C varchar2(256);                                                                                                                                                         
   heading3D varchar2(256);                                                                                                                                                         
                                                                                                                                                                                    

   cbuf1 varchar2(256);                                                                                                                                                             
   cbuf2 varchar2(256);                                                                                                                                                             
   cbuf3 varchar2(256);                                                                                                                                                             
   cbuf4 varchar2(256);                                                                                                                                                             
                                                                                                                                                                                    
   invoice_date varchar2(16);                                                                                                                                                       
   invoice_number varchar2(16);                                                                                                                                                     
   f_date date;                                                                                                                                                                     
                                                                                                                                                                                    
   cursor summary_list is                                                                                                                                                           
      select                                                                                                                                                                        
         TO_CHAR(a.practice,'009'),                                                                                                                                                 
         TO_CHAR(MIN(a.date_collected),'MM/DD/YYYY'),                                                                                                                               

         TO_CHAR(MAX(a.date_collected),'MM/DD/YYYY'),                                                                                                                               
         TO_CHAR(SUM(a.item_amount),'99990.00'),                                                                                                                                    
         SUM(a.item_amount)                                                                                                                                                         
      from practice_statement_labs a, practices b                                                                                                                                   
      where a.practice=b.practice                                                                                                                                                   
      and a.statement_id=S_month                                                                                                                                                    
      and a.billing_cycle=cycle                                                                                                                                                     
      and b.practice_type='WV'                                                                                                                                                      
      and b.program=pgm                                                                                                                                                             
      group by a.practice                                                                                                                                                           
      having sum(a.item_amount)>0                                                                                                                                                   
      order by a.practice;                                                                                                                                                          
                                                                                                                                                                                    

   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   check_point number;                                                                                                                                                              
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_WV_INVOICE_SUMMARY_8';                                                                                                                                       
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   check_point:=0;                                                                                                                                                                  
   invoice_date:=TO_CHAR(SysDate,'MM/DD/YYYY');                                                                                                                                     
                                                                                                                                                                                    
   P_code_area:='HEADER';                                                                                                                                                           
   dline:='-------------------------------------'||                                                                                                                                 

      '-------------------------------------------';                                                                                                                                
   dline2:='                                                                        --------';                                                                                      
   heading1A:='PENNSYLVANIA CYTOLOGY SERVICES';                                                                                                                                     
   heading1B:='SUITE 1700 PARKWAY BUILDLING';                                                                                                                                       
   heading1C:='339 OLD HAYMAKER ROAD';                                                                                                                                              
   heading1D:='MONROEVILLE, PA  15146';                                                                                                                                             
                                                                                                                                                                                    
   cbuf1:=RTRIM(TO_CHAR(TO_DATE(TO_CHAR(S_month),'YYYYMM'),'MONTH'));                                                                                                               
   cbuf2:=RTRIM(TO_CHAR(TO_DATE(TO_CHAR(S_month),'YYYYMM'),'YYYY'));                                                                                                                
   heading2:=cbuf1||' '||cbuf2;                                                                                                                                                     
                                                                                                                                                                                    
   f_date:=TO_DATE(TO_CHAR(S_month),'YYYYMM');                                                                                                                                      
   cbuf1:=TO_CHAR(f_date,'MonYYYY');                                                                                                                                                

   cbuf2:=RTRIM(LTRIM(TO_CHAR(cycle)));                                                                                                                                             
   cbuf3:=SUBSTR(pgm,1,2);                                                                                                                                                          
   S_file_name:=cbuf1||'.'||cbuf3||'8';                                                                                                                                             
   dir_name:=RTRIM('REPORTS_DIR');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   line_num:=0;                                                                                                                                                                     
   curr_page:=1;                                                                                                                                                                    
   curr_line:=RPAD(heading1A,73)||'PAGE '||RTRIM(LTRIM(TO_CHAR(curr_page)));                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',heading1B);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            

   UTL_FILE.PUTF(file_handle,'%s\n',heading1C);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',heading1D);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   curr_line:=LPAD(heading2,42);                                                                                                                                                    
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
                                                                                                                                                                                    
   heading3A:='BPH-'||pgm;                                                                                                                                                          
   heading3B:='350 CAPITOL STREET, ROOM 427';                                                                                                                                       
   heading3C:='CHARLESTON, WV  25301';                                                                                                                                              
   heading3D:=                                                                                                                                                                      
      'IDENTIFICATION                    DATE OF SERVICE                         AMOUNT';                                                                                           

                                                                                                                                                                                    
   curr_line:=RPAD(heading3A,64)||'DATE: '||RTRIM(LTRIM(invoice_date));                                                                                                             
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',heading3B);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3C);                                                                                                                                   
   line_num:=line_num+2;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',heading3D);                                                                                                                                     
   line_num:=line_num+1;                                                                                                                                                            
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         

   line_num:=line_num+1;                                                                                                                                                            
                                                                                                                                                                                    
   grand_total:=0;                                                                                                                                                                  
   open summary_list;                                                                                                                                                               
   loop                                                                                                                                                                             
      fetch summary_list into WV_name,cbuf1,cbuf2,tran_item,tran_total;                                                                                                             
      exit when summary_list%NOTFOUND;                                                                                                                                              
      if (line_num>=58) then                                                                                                                                                        
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=0;                                                                                                                                                               
         UTL_FILE.PUT(file_handle,chr(12));                                                                                                                                         
         curr_page:=curr_page+1;                                                                                                                                                    
         curr_line:=RPAD(heading1A,73)||'PAGE '||RTRIM(LTRIM(TO_CHAR(curr_page)));                                                                                                  

         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',heading1B);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',heading1C);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n\n',heading1D);                                                                                                                             
         line_num:=line_num+2;                                                                                                                                                      
         curr_line:=RPAD(heading3A,64)||'DATE: '||RTRIM(LTRIM(invoice_date));                                                                                                       
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',heading3B);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      

         UTL_FILE.PUTF(file_handle,'%s\n\n',heading3C);                                                                                                                             
         line_num:=line_num+2;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',heading3D);                                                                                                                               
         line_num:=line_num+1;                                                                                                                                                      
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         line_num:=line_num+1;                                                                                                                                                      
      end if;                                                                                                                                                                       
      grand_total:=grand_total+tran_total;                                                                                                                                          
      cbuf3:=LTRIM(RTRIM(TO_CHAR(S_month)))||LTRIM(RTRIM(WV_name))||'-'||TO_CHAR(cycle);                                                                                            
      curr_line:=RPAD(cbuf3,34)||cbuf1||' - '||cbuf2||LPAD(tran_item,23);                                                                                                           
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

      line_num:=line_num+1;                                                                                                                                                         
   end loop;                                                                                                                                                                        
   close summary_list;                                                                                                                                                              
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   curr_line:=LPAD('TOTAL:',69)||LPAD(TO_CHAR(grand_total,'999,990.00'),11);                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
                                                                                                                                                                                    
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
      P_error_code:=SQLCODE;                                                                                                                                                        
      P_error_message:=SQLERRM;                                                                                                                                                     
      insert into pcs.error_log                                                                                                                                                     
         (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                                                                   
      values                                                                                                                                                                        
         (P_error_code,P_error_message,P_proc_name,P_code_area,                                                                                                                     
          SysDate,UID,TO_NUMBER(WV_name));                                                                                                                                          
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        

                                                                                                                                                                                    
end;               
\
grant execute on build_WV_invoice_summary_8 to pcs_user 
\