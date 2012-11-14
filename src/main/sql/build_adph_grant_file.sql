create or replace procedure     build_adph_grant_file                                                                                                                                                 
(                                                                                                                                                                                   

   B_date in varchar2, E_date in varchar2, F_ext in varchar2                                                                                                                        
)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   S_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
   curr_line varchar2(300);                                                                                                                                                         
   margin varchar2(32);                                                                                                                                                             

   dline varchar2(512);                                                                                                                                                             
   dline2 varchar2(512);                                                                                                                                                            
   heading1 varchar2(512);                                                                                                                                                          
   heading2 varchar2(512);                                                                                                                                                          
   heading3 varchar2(512);                                                                                                                                                          
                                                                                                                                                                                    
   pgm_name varchar2(32);                                                                                                                                                           
   TTL number;                                                                                                                                                                      
   POS number;                                                                                                                                                                      
   NEG number;                                                                                                                                                                      
                                                                                                                                                                                    
   D_begin date;                                                                                                                                                                    
   D_end date;                                                                                                                                                                      

                                                                                                                                                                                    
   /* Total number of Paps done per program                                                                                                                                         
   */                                                                                                                                                                               
   cursor total_per_pgm is                                                                                                                                                          
      select A.adph_program,count(A.adph_program)                                                                                                                                   
      from adph_lab_whp A, lab_requisitions C                                                                                                                                       
      where A.lab_number=C.lab_number                                                                                                                                               
      and C.date_collected>=D_begin                                                                                                                                                 
      and C.date_collected<=D_end                                                                                                                                                   
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
                                                                                                                                                                                    
   /* Breakdown of HPV tests per program for                                                                                                                                        

      positive and negative result (+,-) and total                                                                                                                                  
   */                                                                                                                                                                               
   cursor HPV_results is                                                                                                                                                            
      select A.adph_program,                                                                                                                                                        
         sum(decode(C.test_results,'+',1,0)),                                                                                                                                       
         sum(decode(C.test_results,'-',1,0)),                                                                                                                                       
         count(A.adph_program)                                                                                                                                                      
      from adph_lab_whp A, lab_results B, hpv_requests C, lab_requisitions D                                                                                                        
      where A.lab_number=B.lab_number                                                                                                                                               
      and B.lab_number=C.lab_number                                                                                                                                                 
      and B.lab_number=D.lab_number                                                                                                                                                 
      and D.date_collected>=D_begin                                                                                                                                                 
      and D.date_collected<=D_end                                                                                                                                                   

      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
                                                                                                                                                                                    
   /* Total number ASC or higher per program                                                                                                                                        
   */                                                                                                                                                                               
   cursor ASC_higher is                                                                                                                                                             
      select A.adph_program,count(A.adph_program)                                                                                                                                   
      from adph_lab_whp A, lab_requisitions C, lab_result_codes D                                                                                                                   
      where A.lab_number=C.lab_number                                                                                                                                               
      and C.lab_number=D.lab_number                                                                                                                                                 
      and D.bethesda_code>='090' and D.bethesda_code<'500'                                                                                                                          
      and D.bethesda_code<>'13R'                                                                                                                                                    
      and C.date_collected>=D_begin                                                                                                                                                 

      and C.date_collected<=D_end                                                                                                                                                   
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
                                                                                                                                                                                    
   /* Total number HSC or higher per program                                                                                                                                        
   */                                                                                                                                                                               
   cursor HSC_higher is                                                                                                                                                             
      select A.adph_program,count(A.adph_program)                                                                                                                                   
      from adph_lab_whp A, lab_requisitions C, lab_results D, pathologist_control_codes E                                                                                           
      where A.lab_number=C.lab_number                                                                                                                                               
      and C.lab_number=D.lab_number                                                                                                                                                 
      and C.lab_number=E.lab_number                                                                                                                                                 
      and D.path_status='Y'                                                                                                                                                         

      and C.date_collected>=D_begin                                                                                                                                                 
      and C.date_collected<=D_end                                                                                                                                                   
      and ((E.bethesda_code>='200' and E.bethesda_code<='400')                                                                                                                      
        or (E.bethesda_code='040'))                                                                                                                                                 
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_ADPH_GRANT_FILE';                                                                                                                                            
                                                                                                                                                                                    
   S_file_name:='ADPHgnt.'||F_ext;                                                                                                                                                  

   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   P_code_area:='OPEN FILE 1';                                                                                                                                                      
   P_code_area:='PREP';                                                                                                                                                             
   D_begin:=TO_DATE(B_date,'MMDDYYYY');                                                                                                                                             
   D_end:=TO_DATE(E_date,'MMDDYYYY');                                                                                                                                               
                                                                                                                                                                                    
   margin:='      ';                                                                                                                                                                
   dline:=margin||'------------------------';                                                                                                                                       
   dline2:=margin||'------------------------------------------------';                                                                                                              
                                                                                                                                                                                    
   heading1:=margin||'PROGRAM            TOTAL';                                                                                                                                    

   heading2:=margin||'PROGRAM         POSITIVE    NEGATIVE       TOTAL';                                                                                                            
   heading3:=margin||'REPORTING PERIOD:  '||TO_CHAR(D_begin,'MM/DD/YY')||                                                                                                           
      ' - '||TO_CHAR(D_end,'MM/DD/YYYY');                                                                                                                                           
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3);                                                                                                                                    
                                                                                                                                                                                    
   /* Sometimes some of the programs have a blank space at the                                                                                                                      
      end and this throws things off; this block strips any                                                                                                                         
      blank spaces.                                                                                                                                                                 
   */                                                                                                                                                                               
   update adph_lab_whp set adph_program='ABCCEDP' where adph_program like '%ABCCEDP%';                                                                                              
   update adph_lab_whp set adph_program='FP' where adph_program like '%FP%';                                                                                                        
   update adph_lab_whp set adph_program='GYN' where adph_program like '%GYN%';                                                                                                      
   update adph_lab_whp set adph_program='MAT' where adph_program like '%MAT%';                                                                                                      

   update adph_lab_whp set adph_program='NP' where adph_program like '%NP%';                                                                                                        
                                                                                                                                                                                    
   curr_line:=margin||'TOTAL PAPS PER PROGRAM';                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   UTL_FILE.PUTF(file_handle,'%s\n',heading1);                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   open total_per_pgm;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch total_per_pgm into pgm_name,TTL;                                                                                                                                        
      exit when total_per_pgm%NOTFOUND;                                                                                                                                             
      curr_line:=margin||RPAD(pgm_name,12)||LPAD(TO_CHAR(TTL),12);                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  

   end loop;                                                                                                                                                                        
   close total_per_pgm;                                                                                                                                                             
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',dline);                                                                                                                                     
                                                                                                                                                                                    
   curr_line:=margin||'TOTAL NUMBER OF HPV TESTS PER PROGRAM';                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',dline2);                                                                                                                                        
   UTL_FILE.PUTF(file_handle,'%s\n',heading2);                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',dline2);                                                                                                                                        
   open HPV_results;                                                                                                                                                                
   loop                                                                                                                                                                             
      fetch HPV_results into pgm_name,POS,NEG,TTL;                                                                                                                                  
      exit when HPV_results%NOTFOUND;                                                                                                                                               

      curr_line:=margin||RPAD(pgm_name,12)||LPAD(TO_CHAR(POS),12)||                                                                                                                 
         LPAD(TO_CHAR(NEG),12)||LPAD(TO_CHAR(TTL),12);                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end loop;                                                                                                                                                                        
   close HPV_results;                                                                                                                                                               
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',dline2);                                                                                                                                    
                                                                                                                                                                                    
   curr_line:=margin||'ASC OR HIGHER PER PROGRAM';                                                                                                                                  
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   UTL_FILE.PUTF(file_handle,'%s\n',heading1);                                                                                                                                      
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   open ASC_higher;                                                                                                                                                                 

   loop                                                                                                                                                                             
      fetch ASC_higher into pgm_name,TTL;                                                                                                                                           
      exit when ASC_higher%NOTFOUND;                                                                                                                                                
      curr_line:=margin||RPAD(pgm_name,12)||LPAD(TO_CHAR(TTL),12);                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end loop;                                                                                                                                                                        
   close ASC_higher;                                                                                                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',dline);                                                                                                                                     
                                                                                                                                                                                    
   curr_line:=margin||'HSC OR HIGHER PER PROGRAM';                                                                                                                                  
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   UTL_FILE.PUTF(file_handle,'%s\n',heading1);                                                                                                                                      

   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   open HSC_higher;                                                                                                                                                                 
   loop                                                                                                                                                                             
      fetch HSC_higher into pgm_name,TTL;                                                                                                                                           
      exit when HSC_higher%NOTFOUND;                                                                                                                                                
      curr_line:=margin||RPAD(pgm_name,12)||LPAD(TO_CHAR(TTL),12);                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end loop;                                                                                                                                                                        
   close HSC_higher;                                                                                                                                                                
   UTL_FILE.PUTF(file_handle,'%s\n\n\n\n\n\n\n',dline);                                                                                                                             
                                                                                                                                                                                    
   curr_line:=margin||'FILE: '||dir_name||'\\'||S_file_name;                                                                                                                        
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
      RAISE_APPLICATION_ERROR(-20054,'invalid operation '||P_code_area);                                                                                                            
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
      insert into pcs.error_log                                                                                                                                                     
        (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)                                                                                                    
      values                                                                                                                                                                        
        (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,0);                                                                                                       
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;         
\

grant execute on build_adph_grant_file to pcs_user;
\