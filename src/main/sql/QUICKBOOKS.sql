                                       
PROCEDURE QUICKBOOKS                                                                                                                                                                
(                                                                                                                                                                                   
	/* Invoke with: "execute QUICKBOOKS('01-APR-2004', '30-APR-2004', 'BILLS.TXT') " */                                                                                                
	StartMMMDDYY in date,                                                                                                                                                              
	EndMMMDDYY   in date,                                                                                                                                                              
	FILENAME in varchar2                                                                                                                                                               

)                                                                                                                                                                                   
AS                                                                                                                                                                                  
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   PRACTICE varchar2(20);                                                                                                                                                           
   LAB_NUMBER varchar2(20);                                                                                                                                                         
   SHORT_LAB_NUMBER varchar2(20);                                                                                                                                                   
   NAME varchar2(80);                                                                                                                                                               
   DATESTAMP varchar2(20);                                                                                                                                                          
   PROCEDURE_CODE varchar2(20);                                                                                                                                                     
   DESCRIPTION varchar2(80);                                                                                                                                                        
   ITEM_AMOUNT varchar2(20);                                                                                                                                                        
   CHOICE_CODE varchar2(20);                                                                                                                                                        

   DATE_COLLECTED varchar2(20);                                                                                                                                                     
                                                                                                                                                                                    
   CURSOR BILL_ITEM IS                                                                                                                                                              
        select TO_CHAR(lq.practice),                                                                                                                                                
               TO_CHAR(lq.lab_number),                                                                                                                                              
               SUBSTR(TO_CHAR(lq.lab_number),5,10),                                                                                                                                 
               RTRIM(p.lname)||','||RTRIM(p.fname),                                                                                                                                 
               TO_CHAR(lr.datestamp,'MMDD'),                                                                                                                                        
               li.procedure_code,                                                                                                                                                   
               pc.description,                                                                                                                                                      
               TO_CHAR(li.item_amount,'9999.99'),                                                                                                                                   
               RTRIM(bc.choice_code),                                                                                                                                               
               TO_CHAR(lq.date_collected,'MMDD')                                                                                                                                    

      from pcs.lab_requisitions lq, pcs.patients p, pcs.lab_billing_items li,                                                                                                       
         pcs.lab_billings lb, pcs.lab_results lr,                                                                                                                                   
         pcs.procedure_codes pc, pcs.billing_choices bc                                                                                                                             
      where lq.patient=p.patient and lq.lab_number=lb.lab_number and                                                                                                                
         lq.lab_number=lr.lab_number and                                                                                                                                            
         lb.lab_number=li.lab_number and                                                                                                                                            
         lb.rebilling=li.rebilling and li.procedure_code=pc.procedure_code and                                                                                                      
         lb.billing_choice=bc.billing_choice and                                                                                                                                    
	 LR.DATESTAMP >= StartMMMDDYY AND                                                                                                                                                  
	 LR.DATESTAMP <= ENDMMMDDYY                                                                                                                                                        
      order by lq.lab_number,pc.p_seq;                                                                                                                                              
                                                                                                                                                                                    
                                                                                                                                                                                    

BEGIN                                                                                                                                                                               
    file_handle:=UTL_FILE.FOPEN('vol1:\',FILENAME, 'w');                                                                                                                            
    UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                               
		'PRACTICE|LAB_NUMBER|SHORT_LAB_NUMBER|NAME|DAY|CODE|DESCRIPTION|FEE|BILLING_ROUTE|DATE_COLLECTED','w');                                                                           
	                                                                                                                                                                                   
    open BILL_ITEM;	                                                                                                                                                                
                                                                                                                                                                                    
    loop                                                                                                                                                                            
	fetch BILL_ITEM INTO PRACTICE, LAB_NUMBER, SHORT_LAB_NUMBER, NAME, DATESTAMP,PROCEDURE_CODE,DESCRIPTION,ITEM_AMOUNT, CHOICE_CODE, DATE_COLLECTED;                                  
	exit when BILL_ITEM%NOTFOUND;                                                                                                                                                      
                                                                                                                                                                                    
        UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                           
			PRACTICE || '|' ||                                                                                                                                                               

			LAB_NUMBER || '|' ||                                                                                                                                                             
			SHORT_LAB_NUMBER|| '|' ||                                                                                                                                                        
			NAME|| '|' ||                                                                                                                                                                    
			DATESTAMP|| '|' ||                                                                                                                                                               
			PROCEDURE_CODE|| '|' ||                                                                                                                                                          
			DESCRIPTION|| '|' ||                                                                                                                                                             
			ITEM_AMOUNT|| '|' ||                                                                                                                                                             
			CHOICE_CODE|| '|' ||                                                                                                                                                             
			DATE_COLLECTED);                                                                                                                                                                 
                                                                                                                                                                                    
                                                                                                                                                                                    
    end loop;                                                                                                                                                                       
    UTL_FILE.FCLOSE(file_handle);                                                                                                                                                   

                                                                                                                                                                                    
                                                                                                                                                                                    
                                                                                                                                                                                    
END;                                                                                                                                         