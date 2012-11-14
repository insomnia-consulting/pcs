create or replace procedure     build_adph_quarterly_file                                                                                                                                             
(                                                                                                                                                                                   
   quarter in number,                                                                                                                                                               
   year in varchar2                                                                                                                                                                 
)                                                                                                                                                                                   
as                                                                                                                                                                                  
                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             

   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   S_file_name varchar2(12);                                                                                                                                                        
   dir_name varchar2(128);                                                                                                                                                          
                                                                                                                                                                                    
   curr_line varchar2(512);                                                                                                                                                         
   line_num number;                                                                                                                                                                 
   curr_page number;                                                                                                                                                                
   rcnt number;                                                                                                                                                                     
   margin varchar2(32);                                                                                                                                                             
                                                                                                                                                                                    

   YM_low number;                                                                                                                                                                   
   YM_high number;                                                                                                                                                                  
   S_quarter varchar2(16);                                                                                                                                                          
   S_title varchar2(48);                                                                                                                                                            
                                                                                                                                                                                    
   cbuf1 varchar2(256);                                                                                                                                                             
   cbuf2 varchar2(256);                                                                                                                                                             
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   check_point number;                                                                                                                                                              
                                                                                                                                                                                    
   /* Total number of Paps done per program                                                                                                                                         
   */                                                                                                                                                                               

   cursor total_per_pgm is                                                                                                                                                          
      select A.adph_program,count(A.adph_program)                                                                                                                                   
      from adph_lab_whp A, lab_requisitions C                                                                                                                                       
      where A.lab_number=C.lab_number                                                                                                                                               
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))>=YM_low                                                                                                                     
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))<=YM_high                                                                                                                    
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
   /* Breakdown of HPV tests per program for                                                                                                                                        
      positive and negative result (+,-) and total                                                                                                                                  
   */                                                                                                                                                                               
   cursor hpv_results_per_pgm is                                                                                                                                                    
      select A.adph_program,                                                                                                                                                        

         sum(decode(C.test_results,'+',1,0)),                                                                                                                                       
         sum(decode(C.test_results,'-',1,0)),                                                                                                                                       
         sum(decode(C.test_results,'Q',1,0)),                                                                                                                                       
         count(A.adph_program)                                                                                                                                                      
      from adph_lab_whp A, lab_results B, hpv_requests C                                                                                                                            
      where A.lab_number=B.lab_number                                                                                                                                               
      and B.lab_number=C.lab_number                                                                                                                                                 
      and TO_NUMBER(TO_CHAR(C.results_received,'YYYYMM'))>=YM_low                                                                                                                   
      and TO_NUMBER(TO_CHAR(C.results_received,'YYYYMM'))<=YM_high                                                                                                                  
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
   cursor pap_classes is                                                                                                                                                            
      select pap_class,description                                                                                                                                                  

      from pcs.pap_classes                                                                                                                                                          
      where pap_class>=1 and pap_class<=15                                                                                                                                          
      order by pap_class;                                                                                                                                                           
   p_class number;                                                                                                                                                                  
   p_class_descr varchar2(4000);                                                                                                                                                    
                                                                                                                                                                                    
   /* Number of tests per program per pap class                                                                                                                                     
   */                                                                                                                                                                               
   cursor class_results_per_pgm is                                                                                                                                                  
      select A.adph_program,count(A.adph_program)                                                                                                                                   
      from adph_lab_whp A, lab_results B, lab_requisitions c                                                                                                                        
      where A.lab_number=B.lab_number                                                                                                                                               
      and B.lab_number=C.lab_number                                                                                                                                                 

      and B.pap_class=p_class                                                                                                                                                       
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))>=YM_low                                                                                                                     
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))<=YM_high                                                                                                                    
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
   cursor class_seven_200 is                                                                                                                                                        
      select A.adph_program,count(A.adph_program)                                                                                                                                   
      from adph_lab_whp A, lab_results B, lab_requisitions c, pathologist_control_codes d                                                                                           
      where A.lab_number=B.lab_number                                                                                                                                               
      and B.lab_number=C.lab_number                                                                                                                                                 
      and B.lab_number=D.lab_number                                                                                                                                                 
      and D.bethesda_code='200'                                                                                                                                                     
      and B.path_status='Y'                                                                                                                                                         

      and B.pap_class=7                                                                                                                                                             
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))>=YM_low                                                                                                                     
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))<=YM_high                                                                                                                    
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
   cursor class_seven_207 is                                                                                                                                                        
      select A.adph_program,count(A.adph_program)                                                                                                                                   
      from adph_lab_whp A, lab_results B, lab_requisitions c, pathologist_control_codes d                                                                                           
      where A.lab_number=B.lab_number                                                                                                                                               
      and B.lab_number=C.lab_number                                                                                                                                                 
      and B.lab_number=D.lab_number                                                                                                                                                 
      and D.bethesda_code='207'                                                                                                                                                     
      and B.path_status='Y'                                                                                                                                                         

      and B.pap_class=7                                                                                                                                                             
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))>=YM_low                                                                                                                     
      and TO_NUMBER(TO_CHAR(C.date_collected,'YYYYMM'))<=YM_high                                                                                                                    
      group by A.adph_program;                                                                                                                                                      
                                                                                                                                                                                    
   pgm_name varchar2(32);                                                                                                                                                           
   lab_count number;                                                                                                                                                                
   hpv_pos number;                                                                                                                                                                  
   hpv_neg number;                                                                                                                                                                  
   hpv_qn number;                                                                                                                                                                   
                                                                                                                                                                                    
   dline varchar2(128);                                                                                                                                                             
                                                                                                                                                                                    

begin                                                                                                                                                                               
                                                                                                                                                                                    
   P_proc_name:='BUILD_ADPH_QUARTERLY_FILE';                                                                                                                                        
                                                                                                                                                                                    
   P_code_area:='PREP';                                                                                                                                                             
   check_point:=0;                                                                                                                                                                  
   S_file_name:='ADPH'||year||'.Q'||quarter;                                                                                                                                        
   dir_name:=RTRIM('vol1:');                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');                                                                                                                           
                                                                                                                                                                                    
   dline:='---------------------------------------------------';                                                                                                                    
                                                                                                                                                                                    
   /* If an invalid quarter is passed in                                                                                                                                            

      will default to fourth quarter                                                                                                                                                
   */                                                                                                                                                                               
   if (quarter=1) then                                                                                                                                                              
      YM_low:=TO_NUMBER(year||'01');                                                                                                                                                
      YM_high:=TO_NUMBER(year||'03');                                                                                                                                               
      S_quarter:='FIRST';                                                                                                                                                           
   elsif (quarter=2) then                                                                                                                                                           
      YM_low:=TO_NUMBER(year||'04');                                                                                                                                                
      YM_high:=TO_NUMBER(year||'06');                                                                                                                                               
      S_quarter:='SECOND';                                                                                                                                                          
   elsif (quarter=3) then                                                                                                                                                           
      YM_low:=TO_NUMBER(year||'07');                                                                                                                                                
      YM_high:=TO_NUMBER(year||'09');                                                                                                                                               

      S_quarter:='THIRD';                                                                                                                                                           
   else                                                                                                                                                                             
      YM_low:=TO_NUMBER(year||'10');                                                                                                                                                
      YM_high:=TO_NUMBER(year||'12');                                                                                                                                               
      S_quarter:='FOURTH';                                                                                                                                                          
   end if;                                                                                                                                                                          
   S_title:='DATE OF SERVICE THROUGH SEPTEMBER 2005';                                                                                                                               
   YM_low:=200501;                                                                                                                                                                  
   YM_high:=200509;                                                                                                                                                                 
                                                                                                                                                                                    
   curr_line:=S_title;                                                                                                                                                              
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);                                                                                                                                   
                                                                                                                                                                                    

   curr_line:='TOTAL PAPS PER PROGRAM';                                                                                                                                             
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);                                                                                                                                   
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   curr_line:=RPAD('PROGRAM',12)||LPAD('TOTAL',12);                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   open total_per_pgm;                                                                                                                                                              
   loop                                                                                                                                                                             
      fetch total_per_pgm into pgm_name,lab_count;                                                                                                                                  
      exit when total_per_pgm%NOTFOUND;                                                                                                                                             
      curr_line:=RPAD(pgm_name,12)||LPAD(TO_CHAR(lab_count),12);                                                                                                                    
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end loop;                                                                                                                                                                        

   close total_per_pgm;                                                                                                                                                             
                                                                                                                                                                                    
   curr_line:='POSITIVE, NEGATIVE, AND TOTAL HPV TESTS PER PROGRAM';                                                                                                                
   UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);                                                                                                                                 
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   curr_line:=RPAD('PROGRAM',12)||LPAD('POSITIVE',12)||LPAD('NEGATIVE',12)||LPAD('QUAN. INS.',12)||LPAD('TOTAL',12);                                                                
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                     
   UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                         
   open hpv_results_per_pgm;                                                                                                                                                        
   loop                                                                                                                                                                             
      fetch hpv_results_per_pgm into pgm_name,hpv_pos,hpv_neg,hpv_qn,lab_count;                                                                                                     
      exit when hpv_results_per_pgm%NOTFOUND;                                                                                                                                       
      curr_line:=RPAD(pgm_name,12)||LPAD(TO_CHAR(hpv_pos),12)||LPAD(TO_CHAR(hpv_neg),12)||LPAD(TO_CHAR(hpv_qn),12)||LPAD(TO_CHAR(lab_count),12);                                    

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
   end loop;                                                                                                                                                                        
   close hpv_results_per_pgm;                                                                                                                                                       
                                                                                                                                                                                    
   open pap_classes;                                                                                                                                                                
   loop                                                                                                                                                                             
      fetch pap_classes into p_class,p_class_descr;                                                                                                                                 
      exit when pap_classes%NOTFOUND;                                                                                                                                               
      UTL_FILE.PUTF(file_handle,'\n\n%s\n',p_class_descr);                                                                                                                          
      UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                      
      curr_line:=RPAD('PROGRAM',12)||LPAD('TOTAL',12);                                                                                                                              
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                                  
      UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                      

      if (p_class<>7) then                                                                                                                                                          
         open class_results_per_pgm;                                                                                                                                                
         loop                                                                                                                                                                       
            fetch class_results_per_pgm into pgm_name,lab_count;                                                                                                                    
            exit when class_results_per_pgm%NOTFOUND;                                                                                                                               
            curr_line:=RPAD(pgm_name,12)||LPAD(TO_CHAR(lab_count),12);                                                                                                              
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
         end loop;                                                                                                                                                                  
         close class_results_per_pgm;                                                                                                                                               
      else                                                                                                                                                                          
         UTL_FILE.PUTF(file_handle,'\n\n%s\n',p_class_descr);                                                                                                                       
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         curr_line:=RPAD('PROGRAM',12)||LPAD('TOTAL',12);                                                                                                                           

         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         open class_seven_200;                                                                                                                                                      
         loop                                                                                                                                                                       
            fetch class_seven_200 into pgm_name,lab_count;                                                                                                                          
            exit when class_seven_200%NOTFOUND;                                                                                                                                     
            curr_line:=RPAD(pgm_name,12)||LPAD(TO_CHAR(lab_count),12);                                                                                                              
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
         end loop;                                                                                                                                                                  
         close class_seven_200;                                                                                                                                                     
         cbuf1:='ATYPCIAL SQUAMOUS CELLS - HIGH';                                                                                                                                   
         UTL_FILE.PUTF(file_handle,'\n\n%s\n',cbuf1);                                                                                                                               
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   

         curr_line:=RPAD('PROGRAM',12)||LPAD('TOTAL',12);                                                                                                                           
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         UTL_FILE.PUTF(file_handle,'%s\n',dline);                                                                                                                                   
         open class_seven_207;                                                                                                                                                      
         loop                                                                                                                                                                       
            fetch class_seven_207 into pgm_name,lab_count;                                                                                                                          
            exit when class_seven_207%NOTFOUND;                                                                                                                                     
            curr_line:=RPAD(pgm_name,12)||LPAD(TO_CHAR(lab_count),12);                                                                                                              
            UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                            
         end loop;                                                                                                                                                                  
         close class_seven_207;                                                                                                                                                     
      end if;                                                                                                                                                                       
   end loop;                                                                                                                                                                        

   close pap_classes;                                                                                                                                                               
                                                                                                                                                                                    
   commit;                                                                                                                                                                          
                                                                                                                                                                                    
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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user)                                                                                   
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID);                                                                                                    
      commit;                                                                                                                                                                       
      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
end;                 
\

grant execute on build_adph_quarterly_file to pcs_user ; 
\