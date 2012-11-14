                                       
PROCEDURE locate_missing_charges                                                                                                                                                    
(                                                                                                                                                                                   
   begin_lab in number,                                                                                                                                                             
   end_lab in number,                                                                                                                                                               
   filename in varchar2                                                                                                                                                             
)                                                                                                                                                                                   
AS                                                                                                                                                                                  

                                                                                                                                                                                    
   P_error_code number;                                                                                                                                                             
   P_error_message varchar2(512);                                                                                                                                                   
   P_proc_name varchar2(32);                                                                                                                                                        
   P_code_area varchar2(32);                                                                                                                                                        
                                                                                                                                                                                    
   L_num number;                                                                                                                                                                    
   L_prac varchar2(8);                                                                                                                                                              
   L_finished number;                                                                                                                                                               
   L_collected varchar2(12);                                                                                                                                                        
   L_proc varchar2(8);                                                                                                                                                              
   L_rebilling number;                                                                                                                                                              
   L_bchoice varchar2(8);                                                                                                                                                           

                                                                                                                                                                                    
   /* BILLING CHOICE 122 = DOC                                                                                                                                                      
      REBILLING OF ZERO MEANS HAS NEVER BEEN REBILLED;                                                                                                                              
      AND REBILLING = n MEANS REBILLED n TIMES                                                                                                                                      
   */                                                                                                                                                                               
   cursor lab_list is                                                                                                                                                               
      select lq.lab_number, TO_CHAR(lq.practice,'009'),                                                                                                                             
         lq.finished,TO_CHAR(lq.date_collected,'MM/DD/YYYY'),                                                                                                                       
         lbi.procedure_code,lb.rebilling,bc.choice_code                                                                                                                             
      from pcs.lab_requisitions lq, pcs.lab_billing_items lbi,                                                                                                                      
         pcs.billing_choices bc, pcs.lab_billings lb                                                                                                                                
      where  lq.lab_number=lbi.lab_number                                                                                                                                           
      and lq.lab_number=lb.lab_number                                                                                                                                               

      and lb.billing_choice=bc.billing_choice                                                                                                                                       
      and lb.billing_choice=122                                                                                                                                                     
      and lb.rebilling>0                                                                                                                                                            
      and lq.lab_number>=begin_lab                                                                                                                                                  
      and lq.lab_number<=end_lab                                                                                                                                                    
      order by lq.lab_number;                                                                                                                                                       
                                                                                                                                                                                    
   I_stmt number;                                                                                                                                                                   
   I_cycle number;                                                                                                                                                                  
   I_prac varchar2(8);                                                                                                                                                              
   I_bchoice varchar2(8);                                                                                                                                                           
   I_proc varchar2(8);                                                                                                                                                              
                                                                                                                                                                                    

   cursor invoice_list is                                                                                                                                                           
      select statement_id,billing_cycle,TO_CHAR(practice,'009'),                                                                                                                    
         choice_code,procedure_code                                                                                                                                                 
      from pcs.practice_statement_labs                                                                                                                                              
      where lab_number=L_num                                                                                                                                                        
      order by statement_id,billing_cycle;                                                                                                                                          
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
   rcnt number;                                                                                                                                                                     
   curr_line varchar2(128);                                                                                                                                                         
                                                                                                                                                                                    
BEGIN                                                                                                                                                                               

                                                                                                                                                                                    
   P_proc_name:='LOCATE_MISSING_CHARGES';                                                                                                                                           
                                                                                                                                                                                    
   P_code_area:='OPEN FILE';                                                                                                                                                        
   file_handle:=UTL_FILE.FOPEN('vol1:\',filename,'w');                                                                                                                              
                                                                                                                                                                                    
   P_code_area:='WRITE HEADING';                                                                                                                                                    
   UTL_FILE.PUTF(file_handle,'%s\n','LAB/PROCEDURE CODES ANALYSIS: '||                                                                                                              
      begin_lab||' to '||end_lab);                                                                                                                                                  
   UTL_FILE.PUTF(file_handle,'%s\n\n',                                                                                                                                              
      'The lab numbers and procedure codes listed do not exist in the invoicing table:');                                                                                           
	                                                                                                                                                                                   
   P_code_area:='LAB_LIST CURSOR';                                                                                                                                                  

   open lab_list;	                                                                                                                                                                  
   loop                                                                                                                                                                             
      P_code_area:='LAB_LIST FETCH';                                                                                                                                                
      fetch lab_list into                                                                                                                                                           
         L_num,L_prac,L_finished,L_collected,L_proc,L_rebilling,L_bchoice;                                                                                                          
	exit when lab_list%NOTFOUND;                                                                                                                                                       
      P_code_area:='GET COUNT';                                                                                                                                                     
      select count(*) into rcnt from pcs.practice_statement_labs                                                                                                                    
      where lab_number=L_num                                                                                                                                                        
      and procedure_code=L_proc                                                                                                                                                     
      and choice_code=L_bchoice;                                                                                                                                                    
      if (rcnt=0) then                                                                                                                                                              
         P_code_area:='ZERO COUNT';                                                                                                                                                 

         curr_line:=L_num||'  '||L_proc||'  '||LPAD(L_bchoice,6)||'    '||                                                                                                          
            L_prac||' '||L_collected||' '||L_finished||' '||L_rebilling;                                                                                                            
         UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                               
         P_code_area:='INVOICE_LIST CURSOR';                                                                                                                                        
         open invoice_list;                                                                                                                                                         
         loop                                                                                                                                                                       
            P_code_area:='INVOICE_LIST FETCH';                                                                                                                                      
            fetch invoice_list into I_stmt,I_cycle,I_prac,I_bchoice,I_proc;                                                                                                         
            exit when invoice_list%NOTFOUND;                                                                                                                                        
            curr_line:='     '||I_stmt||'.'||I_cycle||'  '||                                                                                                                        
               I_prac||' '||LPAD(I_bchoice,5)||' '||I_proc;                                                                                                                         
               UTL_FILE.PUTF(file_handle,'%s\n',curr_line);                                                                                                                         
         end loop;                                                                                                                                                                  

         close invoice_list;                                                                                                                                                        
      end if;                                                                                                                                                                       
      P_code_area:='BOTTOM LOOP';                                                                                                                                                   
      rcnt:=0;                                                                                                                                                                      
   end loop;                                                                                                                                                                        
   close lab_list;                                                                                                                                                                  
                                                                                                                                                                                    
   UTL_FILE.PUTF(file_handle,'\n%s\n','END OF REPORT');                                                                                                                             
   UTL_FILE.FCLOSE(file_handle);                                                                                                                                                    
                                                                                                                                                                                    
EXCEPTION                                                                                                                                                                           
                                                                                                                                                                                    
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
        (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_num);                                                                                                   
      commit;                                                                                                                                                                       

      RAISE;                                                                                                                                                                        
                                                                                                                                                                                    
END;                                                                                                                                         