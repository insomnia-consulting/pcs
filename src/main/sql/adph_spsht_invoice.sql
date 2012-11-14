PROCEDURE adph_spsht_invoice                                                                                                                                                        
(                                                                                                                                                                                   
	Statement in number,                                                                                                                                                               
        FILENAME  in varchar2                                                                                                                                                       
)                                                                                                                                                                                   
AS                                                                                                                                                                                  
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
   PRACTICE varchar2(20);                                                                                                                                                           
   LNAME varchar2(32);                                                                                                                                                              
   FNAME varchar2(32);                                                                                                                                                              
   DOB varchar2(10);                                                                                                                                                                
   LAB_NUMBER varchar2(20);                                                                                                                                                         

   PROCEDURE_CODE varchar2(20);                                                                                                                                                     
   CODE_DESCRIPTION varchar2(80);                                                                                                                                                   
   ITEM_AMOUNT varchar2(20);                                                                                                                                                        
   DATE_COLLECTED varchar2(20);                                                                                                                                                     
                                                                                                                                                                                    
   CURSOR BILL_ITEM IS                                                                                                                                                              
        select TO_CHAR(A.practice),                                                                                                                                                 
               C.lname,                                                                                                                                                             
               C.fname,                                                                                                                                                             
               TO_CHAR(C.dob,'MMDDYYYY'),                                                                                                                                           
               TO_CHAR(A.lab_number),                                                                                                                                               
               procedure_code,                                                                                                                                                      
               code_description,                                                                                                                                                    

               LTRIM(TO_CHAR(item_amount,'9999.99')),                                                                                                                               
               TO_CHAR(A.date_collected,'MMDDYYYY')                                                                                                                                 
      from practice_statement_labs A, lab_requisitions B, patients C                                                                                                                
      where A.lab_number=B.lab_number                                                                                                                                               
      and B.patient=C.patient                                                                                                                                                       
      and statement_id=Statement                                                                                                                                                    
      and A.practice in (874,875,876,877,878,885,886)                                                                                                                               
      order by A.lab_number,p_seq;                                                                                                                                                  
                                                                                                                                                                                    
                                                                                                                                                                                    
BEGIN                                                                                                                                                                               
    file_handle:=UTL_FILE.FOPEN('vol1:\',FILENAME, 'w');                                                                                                                            
    UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                               

		'PRACTICE,LAST_NAME,FIRST_NAME,DOB,LAB_NUMBER,TEST,DESCRIPTION,FEE,DATE_OF_SERVICE','w');                                                                                         
	                                                                                                                                                                                   
    open BILL_ITEM;	                                                                                                                                                                
                                                                                                                                                                                    
    loop                                                                                                                                                                            
	fetch BILL_ITEM INTO PRACTICE, LNAME, FNAME, DOB, LAB_NUMBER, PROCEDURE_CODE,CODE_DESCRIPTION,ITEM_AMOUNT, DATE_COLLECTED;                                                         
	exit when BILL_ITEM%NOTFOUND;                                                                                                                                                      
                                                                                                                                                                                    
        UTL_FILE.PUTF(file_handle,'%s\n',                                                                                                                                           
			PRACTICE || ',' ||                                                                                                                                                               
                  LNAME || ',' ||                                                                                                                                                   
                  FNAME || ',' ||                                                                                                                                                   
                  DOB || ',' ||                                                                                                                                                     

			LAB_NUMBER || ',' ||                                                                                                                                                             
			PROCEDURE_CODE || ',' ||                                                                                                                                                         
			CODE_DESCRIPTION || ',' ||                                                                                                                                                       
			ITEM_AMOUNT || ',' ||                                                                                                                                                            
			DATE_COLLECTED);                                                                                                                                                                 
                                                                                                                                                                                    
                                                                                                                                                                                    
    end loop;                                                                                                                                                                       
    UTL_FILE.FCLOSE(file_handle);                                                                                                                                                   
                                                                                                                                                                                    
                                                                                                                                                                                    
                                                                                                                                                                                    
END;                                                                                                                                                                                
\