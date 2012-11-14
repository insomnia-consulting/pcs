                                       
PROCEDURE QUICKBOOKS2                                                                                                                                                               
(                                                                                                                                                                                   
	/* Invoke with: "execute QUICKBOOKS2(200406, 'BILLS.TXT') " */                                                                                                                     
	Statement in number,                                                                                                                                                               
        FILENAME  in varchar2                                                                                                                                                       
)                                                                                                                                                                                   
AS                                                                                                                                                                                  
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  

   PRACTICE varchar2(20);                                                                                                                                                           
   LAB_NUMBER varchar2(20);                                                                                                                                                         
   SHORT_LAB_NUMBER varchar2(20);                                                                                                                                                   
   NAME varchar2(80);                                                                                                                                                               
   DATE_RESULTS_ENTERED varchar2(20);                                                                                                                                               
   PROCEDURE_CODE varchar2(20);                                                                                                                                                     
   CODE_DESCRIPTION varchar2(80);                                                                                                                                                   
   ITEM_AMOUNT varchar2(20);                                                                                                                                                        
   CHOICE_CODE varchar2(20);                                                                                                                                                        
   DATE_COLLECTED varchar2(20);                                                                                                                                                     
                                                                                                                                                                                    
   CURSOR BILL_ITEM IS                                                                                                                                                              
        select TO_CHAR(practice),                                                                                                                                                   

               TO_CHAR(lab_number),                                                                                                                                                 
               SUBSTR(TO_CHAR(lab_number),5,10),                                                                                                                                    
               PATIENT_NAME,                                                                                                                                                        
               DATE_RESULTS_ENTERED,                                                                                                                                                
               procedure_code,                                                                                                                                                      
               code_description,                                                                                                                                                    
               TO_CHAR(item_amount,'9999.99'),                                                                                                                                      
               RTRIM(choice_code),                                                                                                                                                  
               TO_CHAR(date_collected,'MMDD')                                                                                                                                       
      from practice_statement_labs                                                                                                                                                  
      where statement_id= statement                                                                                                                                                 
      order by lab_number,p_seq;                                                                                                                                                    
                                                                                                                                                                                    

                                                                                                                                                                                    
BEGIN                                                                                                                                                                               
    file_handle:=UTL_FILE.FOPEN('vol1:\',FILENAME, 'w');                                                                                                                            
    UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                               
		'PRACTICE|LAB_NUMBER|SHORT_LAB_NUMBER|NAME|DAY|CODE|DESCRIPTION|FEE|BILLING_ROUTE|DATE_COLLECTED','w');                                                                           
	                                                                                                                                                                                   
    open BILL_ITEM;	                                                                                                                                                                
                                                                                                                                                                                    
    loop                                                                                                                                                                            
	fetch BILL_ITEM INTO PRACTICE, LAB_NUMBER, SHORT_LAB_NUMBER, NAME, DATE_RESULTS_ENTERED,PROCEDURE_CODE,CODE_DESCRIPTION,ITEM_AMOUNT, CHOICE_CODE, DATE_COLLECTED;                  
	exit when BILL_ITEM%NOTFOUND;                                                                                                                                                      
                                                                                                                                                                                    
        UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                           

			PRACTICE || '|' ||                                                                                                                                                               
			LAB_NUMBER || '|' ||                                                                                                                                                             
			SHORT_LAB_NUMBER|| '|' ||                                                                                                                                                        
			NAME|| '|' ||                                                                                                                                                                    
			DATE_RESULTS_ENTERED|| '|' ||                                                                                                                                                    
			PROCEDURE_CODE|| '|' ||                                                                                                                                                          
			CODE_DESCRIPTION|| '|' ||                                                                                                                                                        
			ITEM_AMOUNT|| '|' ||                                                                                                                                                             
			CHOICE_CODE|| '|' ||                                                                                                                                                             
			DATE_COLLECTED);                                                                                                                                                                 
                                                                                                                                                                                    
                                                                                                                                                                                    
    end loop;                                                                                                                                                                       

    UTL_FILE.FCLOSE(file_handle);                                                                                                                                                   
                                                                                                                                                                                    
                                                                                                                                                                                    
                                                                                                                                                                                    
END;                                                                                                                                         