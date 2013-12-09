-- Documentation of things might need done; but some aren't done every import and some aren't done in the context of this user
--2.  grant dba to pcs;
--3.  grant select on sys.dba_free_space to pcs;
connect / as sysdba
grant dba to pcs ; 
grant select on sys.dba_free_space to pcs ; 
create role pcs_user not identified ;
disconnect
connect pcs/ahb21@pcs

create or replace directory REPORTS_DIR as '/u01/reports'
create or replace directory WV_REPORTS_DIR as '/u01/reports/LabInfoSystem/ElectronicReporting/wv'
/
drop procedure stupid
/
-- Change the default dir of reports from a physical location to the virtual UTIL_FILE required by 11g
update tpps set dir_name = 'REPORTS_DIR'
/


--Need to add an update statement so that the tables which have a user ID will reflect the change to a new user id as the new users are created.  This might have to be done manually
BEGIN

   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence patient_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(patient)+1 into maxvalue from patients ; 
	dbms_output.put_line('========= Creating sequence patient_seq');
	execute immediate 'create sequence patient_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/



grant SELECT on PATIENT_SEQ to pcs_user ;

--Need to add an update statement so that the tables which have a user ID will reflect the change to a new user id as the new users are created.  This might have to be done manually
BEGIN

   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence qc_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(qc_id)+1 into maxvalue from quality_control ; 
	dbms_output.put_line('========= Creating sequence qc_seq with '||maxvalue);
	execute immediate 'create sequence qc_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant SELECT on QC_SEQ to pcs_user ;


BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence req_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/



declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(req_number)+1 into maxvalue from lab_requisitions ; 
	dbms_output.put_line('=========== Creating sequence req_seq');
	execute immediate 'create sequence req_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/
grant SELECT on req_seq to pcs_user ;


BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence lab_req_detail_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
	maxvalue_d number;
	maxvalue_a number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	
	select max(detail_id)+1 into maxvalue_d from pcs.lab_req_details ; 
	select max(detail_id)+1 into maxvalue_a from pcs.lab_req_details_additional ; 
	if (maxvalue_d > maxvalue_a) then
		maxvalue := maxvalue_d;
	else
		maxvalue := maxvalue_a;
	end if;
	dbms_output.put_line('=========== Creating sequence lab_req_detail_seq');
	execute immediate 'create sequence lab_req_detail_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/


BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence doctor_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(doctor)+1 into maxvalue from pcs.doctors ; 
	dbms_output.put_line('=========== Creating sequence doctor_seq');
	execute immediate 'create sequence doctor_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant SELECT on doctor_seq to pcs_user  ;

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence carriers_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(carrier_id)+1 into maxvalue from pcs.carriers ; 
	dbms_output.put_line('=========== Creating sequence carriers_seq');
	execute immediate 'create sequence carriers_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant SELECT on carriers_seq to pcs_user  ;

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence patient_statements_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(statement_id)+1 into maxvalue from pcs.patient_statements ; 
	dbms_output.put_line('=========== Creating sequence patient_statements_seq');
	execute immediate 'create sequence patient_statements_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant SELECT on patient_statements_seq to pcs_user  ;

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence payments_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(payment_id)+1 into maxvalue from pcs.payments ; 
	dbms_output.put_line('=========== Creating sequence payments_seq');
	execute immediate 'create sequence payments_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant SELECT on payments_seq to pcs_user  ;

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence pcs_payer_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(id_number)+1 into maxvalue from pcs.carriers ; 
	dbms_output.put_line('=========== Creating sequence pcs_payer_seq');
	execute immediate 'create sequence pcs_payer_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant SELECT on pcs_payer_seq to pcs_user  ;

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence tech_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue_c number;
	maxvalue_p number;
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(pathologist)+1 into maxvalue_p from pcs.pathologists ; 
	select max(cytotech)+1 into maxvalue_c from pcs.cytotechs ; 
	if (maxvalue_c > maxvalue_p) then
		maxvalue := maxvalue_c;
	else
		maxvalue := maxvalue_p;
	end if;
	dbms_output.put_line('=========== Creating sequence tech_seq');
	execute immediate 'create sequence tech_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant SELECT on tech_seq to pcs_user  ;



grant DELETE on ADEQUACY_RESULT_CODES to pcs_user ;                                                 
grant INSERT on ADEQUACY_RESULT_CODES to pcs_user ;                                                 
grant SELECT on ADEQUACY_RESULT_CODES to pcs_user ;                                                 
grant UPDATE on ADEQUACY_RESULT_CODES to pcs_user ;                                                 
grant DELETE on ADPH_LAB_WHP to pcs_user ;                                                          
grant INSERT on ADPH_LAB_WHP to pcs_user ;                                                          
grant SELECT on ADPH_LAB_WHP to pcs_user ;                                                          
grant UPDATE on ADPH_LAB_WHP to pcs_user ;                                                          
grant DELETE on ADPH_LAB_WHP_TMP to pcs_user ;                                                      
grant INSERT on ADPH_LAB_WHP_TMP to pcs_user ;                                                      
grant SELECT on ADPH_LAB_WHP_TMP to pcs_user ;                                                      
grant UPDATE on ADPH_LAB_WHP_TMP to pcs_user ;                                                      
grant DELETE on ADPH_PROGRAMS to pcs_user ;                                                         

grant INSERT on ADPH_PROGRAMS to pcs_user ;                                                         
grant SELECT on ADPH_PROGRAMS to pcs_user ;                                                         
grant UPDATE on ADPH_PROGRAMS to pcs_user ;                                                         
grant DELETE on BENCHMARKS to pcs_user ;                                                            
grant INSERT on BENCHMARKS to pcs_user ;                                                            
grant SELECT on BENCHMARKS to pcs_user ;                                                            
grant UPDATE on BENCHMARKS to pcs_user ;                                                            
grant DELETE on BETHESDA_CODES to pcs_user ;                                                        
grant INSERT on BETHESDA_CODES to pcs_user ;                                                        
grant SELECT on BETHESDA_CODES to pcs_user ;                                                        
grant UPDATE on BETHESDA_CODES to pcs_user ;                                                        
grant DELETE on BETHESDA_PRIOR_DESCR to pcs_user ;                                                  
grant INSERT on BETHESDA_PRIOR_DESCR to pcs_user ;                                                  

grant SELECT on BETHESDA_PRIOR_DESCR to pcs_user ;                                                  
grant UPDATE on BETHESDA_PRIOR_DESCR to pcs_user ;                                                  
grant DELETE on BETH_HPV_XREF to pcs_user ;                                                         
grant INSERT on BETH_HPV_XREF to pcs_user ;                                                         
grant SELECT on BETH_HPV_XREF to pcs_user ;                                                         
grant UPDATE on BETH_HPV_XREF to pcs_user ;                                                         
grant DELETE on BETH_ICD9_XREF to pcs_user ;                                                        
grant INSERT on BETH_ICD9_XREF to pcs_user ;                                                        
grant SELECT on BETH_ICD9_XREF to pcs_user ;                                                        
grant UPDATE on BETH_ICD9_XREF to pcs_user ;                                                        
grant DELETE on BETH_STD_XREF to pcs_user ;                                                         
grant INSERT on BETH_STD_XREF to pcs_user ;                                                         
grant SELECT on BETH_STD_XREF to pcs_user ;                                                         
grant UPDATE on BETH_STD_XREF to pcs_user ;                                                         

grant DELETE on BILLING_CHOICES to pcs_user ;                                                       
grant INSERT on BILLING_CHOICES to pcs_user ;                                                       
grant SELECT on BILLING_CHOICES to pcs_user ;                                                       
grant UPDATE on BILLING_CHOICES to pcs_user ;                                                       
grant SELECT on BILLING_CHOICES_SEQ to pcs_user ;                                                   
grant DELETE on BILLING_DETAILS to pcs_user ;                                                       
grant INSERT on BILLING_DETAILS to pcs_user ;                                                       
grant SELECT on BILLING_DETAILS to pcs_user ;                                                       
grant UPDATE on BILLING_DETAILS to pcs_user ;                                                       
grant DELETE on BILLING_QUEUE to pcs_user ;                                                         
grant INSERT on BILLING_QUEUE to pcs_user ;                                                         
grant SELECT on BILLING_QUEUE to pcs_user ;                                                         
grant UPDATE on BILLING_QUEUE to pcs_user ;                                                         

grant DELETE on BILLING_ROUTES to pcs_user ;                                                        
grant INSERT on BILLING_ROUTES to pcs_user ;                                                        
grant SELECT on BILLING_ROUTES to pcs_user ;                                                        
grant UPDATE on BILLING_ROUTES to pcs_user ;                                                        
grant DELETE on BILLING_TYPES to pcs_user ;                                                         
grant INSERT on BILLING_TYPES to pcs_user ;                                                         
grant SELECT on BILLING_TYPES to pcs_user ;                                                         
grant UPDATE on BILLING_TYPES to pcs_user ;                                                         
grant DELETE on BT_SUM_WORK to pcs_user ;                                                           
grant INSERT on BT_SUM_WORK to pcs_user ;                                                           
grant SELECT on BT_SUM_WORK to pcs_user ;                                                           
grant UPDATE on BT_SUM_WORK to pcs_user ;                                                           

grant DELETE on BUSINESS_ID_NUMS to pcs_user ;                                                      
grant INSERT on BUSINESS_ID_NUMS to pcs_user ;                                                      
grant SELECT on BUSINESS_ID_NUMS to pcs_user ;                                                      
grant UPDATE on BUSINESS_ID_NUMS to pcs_user ;                                                      
grant DELETE on BUSINESS_INFO to pcs_user ;                                                         
grant INSERT on BUSINESS_INFO to pcs_user ;                                                         
grant SELECT on BUSINESS_INFO to pcs_user ;                                                         
grant UPDATE on BUSINESS_INFO to pcs_user ;                                                         
grant DELETE on CARRIERS to pcs_user ;                                                              
grant INSERT on CARRIERS to pcs_user ;                                                              
grant SELECT on CARRIERS to pcs_user ;                                                              
grant UPDATE on CARRIERS to pcs_user ;                                                              
grant SELECT on CARRIERS_SEQ to pcs_user ;                                                          

grant DELETE on CARRIER_COMMENTS to pcs_user ;                                                      
grant INSERT on CARRIER_COMMENTS to pcs_user ;                                                      
grant SELECT on CARRIER_COMMENTS to pcs_user ;                                                      
grant UPDATE on CARRIER_COMMENTS to pcs_user ;                                                      
grant DELETE on CLAIM_BATCHES to pcs_user ;                                                         
grant INSERT on CLAIM_BATCHES to pcs_user ;                                                         
grant SELECT on CLAIM_BATCHES to pcs_user ;                                                         
grant UPDATE on CLAIM_BATCHES to pcs_user ;                                                         
grant SELECT on CLAIM_SEQ to pcs_user ;                                                             
grant DELETE on CLAIM_STATUSES to pcs_user ;                                                        
grant INSERT on CLAIM_STATUSES to pcs_user ;                                                        
grant SELECT on CLAIM_STATUSES to pcs_user ;                                                        
grant UPDATE on CLAIM_STATUSES to pcs_user ;                                                        

grant DELETE on CLAIM_STATUS_RESPONSES to pcs_user ;                                                
grant INSERT on CLAIM_STATUS_RESPONSES to pcs_user ;                                                
grant SELECT on CLAIM_STATUS_RESPONSES to pcs_user ;                                                
grant UPDATE on CLAIM_STATUS_RESPONSES to pcs_user ;                                                
grant DELETE on CLAIM_SUBMISSIONS to pcs_user ;                                                     
grant INSERT on CLAIM_SUBMISSIONS to pcs_user ;                                                     
grant SELECT on CLAIM_SUBMISSIONS to pcs_user ;                                                     
grant UPDATE on CLAIM_SUBMISSIONS to pcs_user ;                                                     
grant SELECT on CLAIM_SUBMISSION_SEQ to pcs_user ;                                                  
grant SELECT on COLLECTIONS_SEQ to pcs_user ;                                                       
grant SELECT on CONV_SEQ to pcs_user ;                                                              
grant DELETE on CYTOPATH_HISTORY to pcs_user ;                                                      
grant INSERT on CYTOPATH_HISTORY to pcs_user ;                                                      

grant SELECT on CYTOPATH_HISTORY to pcs_user ;                                                      
grant UPDATE on CYTOPATH_HISTORY to pcs_user ;                                                      
grant DELETE on CYTOPATH_PRINT_QUEUE to pcs_user ;                                                  
grant INSERT on CYTOPATH_PRINT_QUEUE to pcs_user ;                                                  
grant SELECT on CYTOPATH_PRINT_QUEUE to pcs_user ;                                                  
grant UPDATE on CYTOPATH_PRINT_QUEUE to pcs_user ;                                                  
grant DELETE on CYTOTECHS to pcs_user ;                                                             
grant INSERT on CYTOTECHS to pcs_user ;                                                             
grant SELECT on CYTOTECHS to pcs_user ;                                                             
grant UPDATE on CYTOTECHS to pcs_user ;                                                             
grant DELETE on DB_COMMENTS to pcs_user ;                                                           
grant INSERT on DB_COMMENTS to pcs_user ;                                                           
grant SELECT on DB_COMMENTS to pcs_user ;                                                           
grant UPDATE on DB_COMMENTS to pcs_user ;                                                           

grant DELETE on DB_VERIFY to pcs_user ;                                                             
grant INSERT on DB_VERIFY to pcs_user ;                                                             
grant SELECT on DB_VERIFY to pcs_user ;                                                             
grant UPDATE on DB_VERIFY to pcs_user ;                                                             
grant DELETE on DETAIL_CODES to pcs_user ;                                                          
grant INSERT on DETAIL_CODES to pcs_user ;                                                          
grant SELECT on DETAIL_CODES to pcs_user ;                                                          
grant UPDATE on DETAIL_CODES to pcs_user ;                                                          
grant DELETE on DIAGNOSIS_CODES to pcs_user ;                                                       
grant INSERT on DIAGNOSIS_CODES to pcs_user ;                                                       
grant SELECT on DIAGNOSIS_CODES to pcs_user ;                                                       
grant UPDATE on DIAGNOSIS_CODES to pcs_user ;                                                       

grant DELETE on DIRECTORS to pcs_user ;                                                             
grant INSERT on DIRECTORS to pcs_user ;                                                             
grant SELECT on DIRECTORS to pcs_user ;                                                             
grant UPDATE on DIRECTORS to pcs_user ;                                                             
grant DELETE on DOCTORS to pcs_user ;                                                               
grant INSERT on DOCTORS to pcs_user ;                                                               
grant SELECT on DOCTORS to pcs_user ;                                                               
grant UPDATE on DOCTORS to pcs_user ;                                                               
grant SELECT on DOCTOR_SEQ to pcs_user ;                                                            
grant DELETE on DOC_SUM_WORK to pcs_user ;                                                          
grant INSERT on DOC_SUM_WORK to pcs_user ;                                                          
grant SELECT on DOC_SUM_WORK to pcs_user ;                                                          
grant UPDATE on DOC_SUM_WORK to pcs_user ;                                                          

grant DELETE on ERROR_LOG to pcs_user ;                                                             
grant INSERT on ERROR_LOG to pcs_user ;                                                             
grant SELECT on ERROR_LOG to pcs_user ;                                                             
grant UPDATE on ERROR_LOG to pcs_user ;                                                             
grant DELETE on FAX_LETTERS to pcs_user ;                                                           
grant INSERT on FAX_LETTERS to pcs_user ;                                                           
grant SELECT on FAX_LETTERS to pcs_user ;                                                           
grant UPDATE on FAX_LETTERS to pcs_user ;                                                           
grant SELECT on GENERIC_SEQ to pcs_user ;                                                           
grant SELECT on GROUP_CONTROL_NUM_SEQ to pcs_user ;                                                 
grant DELETE on HISTORY_MATCH_QUEUE to pcs_user ;                                                   
grant INSERT on HISTORY_MATCH_QUEUE to pcs_user ;                                                   
grant SELECT on HISTORY_MATCH_QUEUE to pcs_user ;                                                   
grant UPDATE on HISTORY_MATCH_QUEUE to pcs_user ;                                                   

grant DELETE on HISTORY_WORKTBL to pcs_user ;                                                       
grant INSERT on HISTORY_WORKTBL to pcs_user ;                                                       
grant SELECT on HISTORY_WORKTBL to pcs_user ;                                                       
grant UPDATE on HISTORY_WORKTBL to pcs_user ;                                                       
grant DELETE on HPV_HISTORY to pcs_user ;                                                           
grant INSERT on HPV_HISTORY to pcs_user ;                                                           
grant SELECT on HPV_HISTORY to pcs_user ;                                                           
grant UPDATE on HPV_HISTORY to pcs_user ;                                                           
grant DELETE on HPV_PRINT_QUEUE to pcs_user ;                                                       
grant INSERT on HPV_PRINT_QUEUE to pcs_user ;                                                       
grant SELECT on HPV_PRINT_QUEUE to pcs_user ;                                                       
grant UPDATE on HPV_PRINT_QUEUE to pcs_user ;                                                       

grant DELETE on HPV_REQUESTS to pcs_user ;                                                          
grant INSERT on HPV_REQUESTS to pcs_user ;                                                          
grant SELECT on HPV_REQUESTS to pcs_user ;                                                          
grant UPDATE on HPV_REQUESTS to pcs_user ;                                                          
grant DELETE on IBC_PREFIXES to pcs_user ;                                                          
grant INSERT on IBC_PREFIXES to pcs_user ;                                                          
grant SELECT on IBC_PREFIXES to pcs_user ;                                                          
grant UPDATE on IBC_PREFIXES to pcs_user ;                                                          
grant DELETE on INVOICE_WORK to pcs_user ;                                                          
grant INSERT on INVOICE_WORK to pcs_user ;                                                          
grant SELECT on INVOICE_WORK to pcs_user ;                                                          
grant UPDATE on INVOICE_WORK to pcs_user ;                                                          
grant DELETE on JOB_CONTROL to pcs_user ;                                                           

grant INSERT on JOB_CONTROL to pcs_user ;                                                           
grant SELECT on JOB_CONTROL to pcs_user ;                                                           
grant UPDATE on JOB_CONTROL to pcs_user ;                                                           
grant DELETE on LAB_BILLINGS to pcs_user ;                                                          
grant INSERT on LAB_BILLINGS to pcs_user ;                                                          
grant SELECT on LAB_BILLINGS to pcs_user ;                                                          
grant UPDATE on LAB_BILLINGS to pcs_user ;                                                          
grant DELETE on LAB_BILLING_ITEMS to pcs_user ;                                                     
grant INSERT on LAB_BILLING_ITEMS to pcs_user ;                                                     
grant SELECT on LAB_BILLING_ITEMS to pcs_user ;                                                     
grant UPDATE on LAB_BILLING_ITEMS to pcs_user ;                                                     
grant DELETE on LAB_CLAIMS to pcs_user ;                                                            
grant INSERT on LAB_CLAIMS to pcs_user ;                                                            
grant SELECT on LAB_CLAIMS to pcs_user ;                                                            

grant UPDATE on LAB_CLAIMS to pcs_user ;                                                            
grant DELETE on LAB_CLAIMS_HISTORY to pcs_user ;                                                    
grant INSERT on LAB_CLAIMS_HISTORY to pcs_user ;                                                    
grant SELECT on LAB_CLAIMS_HISTORY to pcs_user ;                                                    
grant UPDATE on LAB_CLAIMS_HISTORY to pcs_user ;                                                    
grant DELETE on LAB_MAT_INDEX to pcs_user ;                                                         
grant INSERT on LAB_MAT_INDEX to pcs_user ;                                                         
grant SELECT on LAB_MAT_INDEX to pcs_user ;                                                         
grant UPDATE on LAB_MAT_INDEX to pcs_user ;                                                         
grant SELECT on LAB_NUM_SEQ to pcs_user ;                                                           
grant DELETE on LAB_PREPARATIONS to pcs_user ;                                                      
grant INSERT on LAB_PREPARATIONS to pcs_user ;                                                      
grant SELECT on LAB_PREPARATIONS to pcs_user ;                                                      

grant UPDATE on LAB_PREPARATIONS to pcs_user ;                                                      
grant DELETE on LAB_REQUISITIONS to pcs_user ;                                                      
grant INSERT on LAB_REQUISITIONS to pcs_user ;                                                      
grant SELECT on LAB_REQUISITIONS to pcs_user ;                                                      
grant UPDATE on LAB_REQUISITIONS to pcs_user ;                                                      
grant DELETE on LAB_REQ_CLIENT_NOTES to pcs_user ;                                                  
grant INSERT on LAB_REQ_CLIENT_NOTES to pcs_user ;                                                  
grant SELECT on LAB_REQ_CLIENT_NOTES to pcs_user ;                                                  
grant UPDATE on LAB_REQ_CLIENT_NOTES to pcs_user ;                                                  
grant DELETE on LAB_REQ_COMMENTS to pcs_user ;                                                      
grant INSERT on LAB_REQ_COMMENTS to pcs_user ;                                                      
grant SELECT on LAB_REQ_COMMENTS to pcs_user ;                                                      
grant UPDATE on LAB_REQ_COMMENTS to pcs_user ;                                                      

grant DELETE on LAB_REQ_DETAILS to pcs_user ;                                                       
grant INSERT on LAB_REQ_DETAILS to pcs_user ;                                                       
grant SELECT on LAB_REQ_DETAILS to pcs_user ;                                                       
grant UPDATE on LAB_REQ_DETAILS to pcs_user ;                                                       
grant DELETE on LAB_REQ_DETAILS_ADDITIONAL to pcs_user ;                                            
grant INSERT on LAB_REQ_DETAILS_ADDITIONAL to pcs_user ;                                            
grant SELECT on LAB_REQ_DETAILS_ADDITIONAL to pcs_user ;                                            
grant UPDATE on LAB_REQ_DETAILS_ADDITIONAL to pcs_user ;                                            

grant DELETE on LAB_REQ_DIAGNOSIS to pcs_user ;                                                     
grant INSERT on LAB_REQ_DIAGNOSIS to pcs_user ;                                                     
grant SELECT on LAB_REQ_DIAGNOSIS to pcs_user ;                                                     
grant UPDATE on LAB_REQ_DIAGNOSIS to pcs_user ;                                                     

grant DELETE on LAB_RESULTS to pcs_user ;                                                           
grant INSERT on LAB_RESULTS to pcs_user ;                                                           
grant SELECT on LAB_RESULTS to pcs_user ;                                                           
grant UPDATE on LAB_RESULTS to pcs_user ;                                                           
grant DELETE on LAB_RESULT_CODES to pcs_user ;                                                      
grant INSERT on LAB_RESULT_CODES to pcs_user ;                                                      
grant SELECT on LAB_RESULT_CODES to pcs_user ;                                                      
grant UPDATE on LAB_RESULT_CODES to pcs_user ;                                                      
grant DELETE on LAB_RESULT_COMMENTS to pcs_user ;                                                   
grant INSERT on LAB_RESULT_COMMENTS to pcs_user ;                                                   
grant SELECT on LAB_RESULT_COMMENTS to pcs_user ;                                                   
grant UPDATE on LAB_RESULT_COMMENTS to pcs_user ;                                                   
grant DELETE on MAILER to pcs_user ;                                                                

grant INSERT on MAILER to pcs_user ;                                                                
grant SELECT on MAILER to pcs_user ;                                                                
grant UPDATE on MAILER to pcs_user ;                                                                
grant DELETE on MONTHLY_REPORTS to pcs_user ;                                                       
grant INSERT on MONTHLY_REPORTS to pcs_user ;                                                       
grant SELECT on MONTHLY_REPORTS to pcs_user ;                                                       
grant UPDATE on MONTHLY_REPORTS to pcs_user ;                                                       
grant DELETE on PAP_CLASSES to pcs_user ;                                                           
grant INSERT on PAP_CLASSES to pcs_user ;                                                           
grant SELECT on PAP_CLASSES to pcs_user ;                                                           
grant UPDATE on PAP_CLASSES to pcs_user ;                                                           
grant DELETE on PAP_CLASS_CHANGES to pcs_user ;                                                     
grant INSERT on PAP_CLASS_CHANGES to pcs_user ;                                                     

grant SELECT on PAP_CLASS_CHANGES to pcs_user ;                                                     
grant UPDATE on PAP_CLASS_CHANGES to pcs_user ;                                                     
grant DELETE on PATHOLOGISTS to pcs_user ;                                                          
grant INSERT on PATHOLOGISTS to pcs_user ;                                                          
grant SELECT on PATHOLOGISTS to pcs_user ;                                                          
grant UPDATE on PATHOLOGISTS to pcs_user ;                                                          
grant DELETE on PATHOLOGIST_CONTROL to pcs_user ;                                                   
grant INSERT on PATHOLOGIST_CONTROL to pcs_user ;                                                   
grant SELECT on PATHOLOGIST_CONTROL to pcs_user ;                                                   
grant UPDATE on PATHOLOGIST_CONTROL to pcs_user ;                                                   
grant DELETE on PATHOLOGIST_CONTROL_CODES to pcs_user ;                                             
grant INSERT on PATHOLOGIST_CONTROL_CODES to pcs_user ;                                             
grant SELECT on PATHOLOGIST_CONTROL_CODES to pcs_user ;                                             
grant UPDATE on PATHOLOGIST_CONTROL_CODES to pcs_user ;                                             

grant DELETE on PATHOLOGIST_HOLDS to pcs_user ;                                                     
grant INSERT on PATHOLOGIST_HOLDS to pcs_user ;                                                     
grant SELECT on PATHOLOGIST_HOLDS to pcs_user ;                                                     
grant UPDATE on PATHOLOGIST_HOLDS to pcs_user ;                                                     
grant DELETE on PATIENTS to pcs_user ;                                                              
grant INSERT on PATIENTS to pcs_user ;                                                              
grant SELECT on PATIENTS to pcs_user ;                                                              
grant UPDATE on PATIENTS to pcs_user ;                                                              
grant DELETE on PATIENT_ACCOUNTS to pcs_user ;                                                      
grant INSERT on PATIENT_ACCOUNTS to pcs_user ;                                                      
grant SELECT on PATIENT_ACCOUNTS to pcs_user ;                                                      
grant UPDATE on PATIENT_ACCOUNTS to pcs_user ;                                                      

grant DELETE on PATIENT_ACCOUNTS_IN_COLLECTION to pcs_user ;                                        
grant INSERT on PATIENT_ACCOUNTS_IN_COLLECTION to pcs_user ;                                        
grant SELECT on PATIENT_ACCOUNTS_IN_COLLECTION to pcs_user ;                                        
grant UPDATE on PATIENT_ACCOUNTS_IN_COLLECTION to pcs_user ;                                        
grant DELETE on PATIENT_CREDITS to pcs_user ;                                                       
grant INSERT on PATIENT_CREDITS to pcs_user ;                                                       
grant SELECT on PATIENT_CREDITS to pcs_user ;                                                       
grant UPDATE on PATIENT_CREDITS to pcs_user ; 
                                                           
grant DELETE on PATIENT_STATEMENTS to pcs_user ;                                                    
grant INSERT on PATIENT_STATEMENTS to pcs_user ;                                                    
grant SELECT on PATIENT_STATEMENTS to pcs_user ;                                                    
grant UPDATE on PATIENT_STATEMENTS to pcs_user ;                                                    

grant SELECT on PATIENT_STATEMENTS_SEQ to pcs_user ;                                                
grant DELETE on PATIENT_STATEMENT_HISTORY to pcs_user ;                                             
grant INSERT on PATIENT_STATEMENT_HISTORY to pcs_user ;                                             
grant SELECT on PATIENT_STATEMENT_HISTORY to pcs_user ;                                             
grant UPDATE on PATIENT_STATEMENT_HISTORY to pcs_user ;                                             
grant DELETE on PAYER_BATCH_AMOUNTS to pcs_user ;                                                   
grant INSERT on PAYER_BATCH_AMOUNTS to pcs_user ;                                                   
grant SELECT on PAYER_BATCH_AMOUNTS to pcs_user ;                                                   
grant UPDATE on PAYER_BATCH_AMOUNTS to pcs_user ;                                                   
grant DELETE on PAYMENTS to pcs_user ;                                                              
grant INSERT on PAYMENTS to pcs_user ;                                                              
grant SELECT on PAYMENTS to pcs_user ;                                                              
grant UPDATE on PAYMENTS to pcs_user ;                                                              

grant SELECT on PAYMENTS_SEQ to pcs_user ;                                                          
grant DELETE on PAYMENT_ADJUST_REASONS to pcs_user ;                                                
grant INSERT on PAYMENT_ADJUST_REASONS to pcs_user ;                                                
grant SELECT on PAYMENT_ADJUST_REASONS to pcs_user ;                                                
grant UPDATE on PAYMENT_ADJUST_REASONS to pcs_user ;                                                
grant DELETE on PAYMENT_REVERSALS to pcs_user ;                                                     
grant INSERT on PAYMENT_REVERSALS to pcs_user ;                                                     
grant SELECT on PAYMENT_REVERSALS to pcs_user ;                                                     
grant UPDATE on PAYMENT_REVERSALS to pcs_user ;                                                     
grant DELETE on PAYMENT_TYPES to pcs_user ;                                                         
grant INSERT on PAYMENT_TYPES to pcs_user ;                                                         
grant SELECT on PAYMENT_TYPES to pcs_user ;                                                         
grant UPDATE on PAYMENT_TYPES to pcs_user ;                                                         

grant DELETE on PCARD_QUEUE to pcs_user ;                                                           
grant INSERT on PCARD_QUEUE to pcs_user ;                                                           
grant SELECT on PCARD_QUEUE to pcs_user ;                                                           
grant UPDATE on PCARD_QUEUE to pcs_user ;                                                           
grant SELECT on PCS_PAYER_SEQ to pcs_user ;                                                         
grant DELETE on PENDING_CARRIERS to pcs_user ;                                                      
grant INSERT on PENDING_CARRIERS to pcs_user ;                                                      
grant SELECT on PENDING_CARRIERS to pcs_user ;                         

grant UPDATE on PENDING_CARRIERS to pcs_user ;                                                      
grant DELETE on PRACTICES to pcs_user ;                                                             
grant INSERT on PRACTICES to pcs_user ;                                                             
grant SELECT on PRACTICES to pcs_user ;                                                             
grant UPDATE on PRACTICES to pcs_user ;                                                             
grant EXECUTE on PRACTICES_ADD to pcs_user ;                                                        

grant SELECT on PRACTICES_SEQ to pcs_user ;                                                         
grant DELETE on PRACTICE_ACCOUNTS to pcs_user ;                                                     
grant INSERT on PRACTICE_ACCOUNTS to pcs_user ;                                                     
grant SELECT on PRACTICE_ACCOUNTS to pcs_user ;                                                     
grant UPDATE on PRACTICE_ACCOUNTS to pcs_user ;                                                     
grant DELETE on PRACTICE_ACCOUNTS_HISTORY to pcs_user ;                                             
grant INSERT on PRACTICE_ACCOUNTS_HISTORY to pcs_user ;                                             
grant SELECT on PRACTICE_ACCOUNTS_HISTORY to pcs_user ;                                             
grant UPDATE on PRACTICE_ACCOUNTS_HISTORY to pcs_user ;                                             
grant DELETE on PRACTICE_ACCOUNTS_SAVE to pcs_user ;                                                
grant INSERT on PRACTICE_ACCOUNTS_SAVE to pcs_user ;                                                
grant SELECT on PRACTICE_ACCOUNTS_SAVE to pcs_user ;                                                
grant UPDATE on PRACTICE_ACCOUNTS_SAVE to pcs_user ;                                                

grant DELETE on PRACTICE_COMMENTS to pcs_user ;                                                     
grant INSERT on PRACTICE_COMMENTS to pcs_user ;                                                     
grant SELECT on PRACTICE_COMMENTS to pcs_user ;                                                     
grant UPDATE on PRACTICE_COMMENTS to pcs_user ;                                                     
grant SELECT on PRACTICE_SEQ to pcs_user ;                                                          
grant DELETE on PRACTICE_STATEMENTS to pcs_user ;                                                   
grant INSERT on PRACTICE_STATEMENTS to pcs_user ;                                                   
grant SELECT on PRACTICE_STATEMENTS to pcs_user ;                                                   
grant UPDATE on PRACTICE_STATEMENTS to pcs_user ;                                                   
grant SELECT on PRACTICE_STATEMENTS_SEQ to pcs_user ;                                               
grant DELETE on PRACTICE_STATEMENT_LABS to pcs_user ;                                               
grant INSERT on PRACTICE_STATEMENT_LABS to pcs_user ;                                               
grant SELECT on PRACTICE_STATEMENT_LABS to pcs_user ;                                               

grant UPDATE on PRACTICE_STATEMENT_LABS to pcs_user ;                                               
grant DELETE on PREPAID_LABS to pcs_user ;                                                          
grant INSERT on PREPAID_LABS to pcs_user ;                                                          
grant SELECT on PREPAID_LABS to pcs_user ;                                                          
grant UPDATE on PREPAID_LABS to pcs_user ;                                                          
grant DELETE on PRICE_CODES to pcs_user ;                                                           
grant INSERT on PRICE_CODES to pcs_user ;                                                           
grant SELECT on PRICE_CODES to pcs_user ;                                                           
grant UPDATE on PRICE_CODES to pcs_user ;                                                           
grant DELETE on PRICE_CODE_DETAILS to pcs_user ;                                                    
grant INSERT on PRICE_CODE_DETAILS to pcs_user ;                                                    
grant SELECT on PRICE_CODE_DETAILS to pcs_user ;                                                    
grant UPDATE on PRICE_CODE_DETAILS to pcs_user ;                                                    

grant DELETE on PROCEDURE_CODES to pcs_user ;                                                       
grant INSERT on PROCEDURE_CODES to pcs_user ;                                                       
grant SELECT on PROCEDURE_CODES to pcs_user ;                                                       
grant UPDATE on PROCEDURE_CODES to pcs_user ;                                                       
grant DELETE on PROCEDURE_CODE_LIMITS to pcs_user ;                                                 
grant INSERT on PROCEDURE_CODE_LIMITS to pcs_user ;                                                 
grant SELECT on PROCEDURE_CODE_LIMITS to pcs_user ;                                                 
grant UPDATE on PROCEDURE_CODE_LIMITS to pcs_user ;                                                 
grant DELETE on PURGE_HISTORY to pcs_user ;                                                         
grant INSERT on PURGE_HISTORY to pcs_user ;                                                         
grant SELECT on PURGE_HISTORY to pcs_user ;                                                         
grant UPDATE on PURGE_HISTORY to pcs_user ;                                                         
grant DELETE on PURGE_HISTORY_COPY to pcs_user ;                                                    

grant INSERT on PURGE_HISTORY_COPY to pcs_user ;                                                    
grant SELECT on PURGE_HISTORY_COPY to pcs_user ;                                                    
grant UPDATE on PURGE_HISTORY_COPY to pcs_user ;                                                    
grant SELECT on QC_SEQ to pcs_user ;                                                                
grant DELETE on QUALITY_CONTROL to pcs_user ;                                                       
grant INSERT on QUALITY_CONTROL to pcs_user ;                                                       
grant SELECT on QUALITY_CONTROL to pcs_user ;                                                       
grant UPDATE on QUALITY_CONTROL to pcs_user ;                                                       
grant DELETE on QUALITY_CONTROL_CODES to pcs_user ;                                                 
grant INSERT on QUALITY_CONTROL_CODES to pcs_user ;                                                 
grant SELECT on QUALITY_CONTROL_CODES to pcs_user ;                                                 
grant UPDATE on QUALITY_CONTROL_CODES to pcs_user ;                                                 
grant DELETE on RACE_CATEGORIES to pcs_user ;                                                       

grant INSERT on RACE_CATEGORIES to pcs_user ;                                                       
grant SELECT on RACE_CATEGORIES to pcs_user ;                                                       
grant UPDATE on RACE_CATEGORIES to pcs_user ;                                                       
grant DELETE on REBILL_CODES to pcs_user ;                                                          
grant INSERT on REBILL_CODES to pcs_user ;                                                          
grant SELECT on REBILL_CODES to pcs_user ;                                                          
grant UPDATE on REBILL_CODES to pcs_user ;                                                          
grant DELETE on RECEIVE_DATES to pcs_user ;                                                         
grant INSERT on RECEIVE_DATES to pcs_user ;                                                         
grant SELECT on RECEIVE_DATES to pcs_user ;                                                         
grant UPDATE on RECEIVE_DATES to pcs_user ;                                                         

grant DELETE on RESPONSE_FILES to pcs_user ;                                                        

grant INSERT on RESPONSE_FILES to pcs_user ;                                                        
grant SELECT on RESPONSE_FILES to pcs_user ;                                                        
grant UPDATE on RESPONSE_FILES to pcs_user ;                                                        
grant DELETE on SCREENING_STATS_WORK to pcs_user ;                                                  
grant INSERT on SCREENING_STATS_WORK to pcs_user ;                                                  
grant SELECT on SCREENING_STATS_WORK to pcs_user ;                                                  
grant UPDATE on SCREENING_STATS_WORK to pcs_user ;                                                  


grant DELETE on SPECIAL_CHARGES to pcs_user ;                                                       
grant INSERT on SPECIAL_CHARGES to pcs_user ;                                                       
grant SELECT on SPECIAL_CHARGES to pcs_user ;                                                       
grant UPDATE on SPECIAL_CHARGES to pcs_user ;                                                       
grant DELETE on SUMMARY_QUEUE to pcs_user ;                                                         
grant INSERT on SUMMARY_QUEUE to pcs_user ;                                                         
grant SELECT on SUMMARY_QUEUE to pcs_user ;                                                         
grant UPDATE on SUMMARY_QUEUE to pcs_user ;                                                         

grant DELETE on TEMP_TABLE to pcs_user ;                                                            
grant INSERT on TEMP_TABLE to pcs_user ;                                                            
grant SELECT on TEMP_TABLE to pcs_user ;                                                            
grant UPDATE on TEMP_TABLE to pcs_user ;                                                            

grant DELETE on TISSUE_CODES to pcs_user ;                                                          
grant INSERT on TISSUE_CODES to pcs_user ;                                                          
grant SELECT on TISSUE_CODES to pcs_user ;                                                          
grant UPDATE on TISSUE_CODES to pcs_user ;                                                          
grant DELETE on TISSUE_RESULTS to pcs_user ;                                                        
grant INSERT on TISSUE_RESULTS to pcs_user ;                                                        
grant SELECT on TISSUE_RESULTS to pcs_user ;                                                        
grant UPDATE on TISSUE_RESULTS to pcs_user ;                                                        
grant DELETE on TPPS to pcs_user ;                                                                  
grant INSERT on TPPS to pcs_user ;                                                                  
grant SELECT on TPPS to pcs_user ;                                                                  
grant UPDATE on TPPS to pcs_user ;                                                                  
grant SELECT on TRANSET_ID_SEQ to pcs_user ;                                                        

grant DELETE on TRASH to pcs_user ;                                                                 
grant INSERT on TRASH to pcs_user ;                                                                 
grant SELECT on TRASH to pcs_user ;                                                                 
grant UPDATE on TRASH to pcs_user ;                                                                 
grant DELETE on USER_LOG to pcs_user ;                                                              
grant INSERT on USER_LOG to pcs_user ;                                                              
grant SELECT on USER_LOG to pcs_user ;                                                              
grant UPDATE on USER_LOG to pcs_user ;                                                              
grant SELECT on USER_RESTRICTIONS to pcs_user ;                                                     
grant DELETE on USER_RESTRICTIONS to pcs_user ;                                                     
grant INSERT on USER_RESTRICTIONS to pcs_user ;                                                     
grant SELECT on USER_RESTRICTIONS to pcs_user ;                                                     
grant UPDATE on USER_RESTRICTIONS to pcs_user ;                                                     

grant DELETE on X12_ACK_CODES to pcs_user ;                                                         
grant INSERT on X12_ACK_CODES to pcs_user ;                                                         
grant SELECT on X12_ACK_CODES to pcs_user ;                                                         
grant UPDATE on X12_ACK_CODES to pcs_user ;                                                         
grant DELETE on X12_DATA_ERRORS to pcs_user ;                                                       
grant INSERT on X12_DATA_ERRORS to pcs_user ;                                                       
grant SELECT on X12_DATA_ERRORS to pcs_user ;                                                       
grant UPDATE on X12_DATA_ERRORS to pcs_user ;                                                       
grant DELETE on X12_FGROUP_SYNTAX_ERRORS to pcs_user ;                                              
grant INSERT on X12_FGROUP_SYNTAX_ERRORS to pcs_user ;                                              
grant SELECT on X12_FGROUP_SYNTAX_ERRORS to pcs_user ;                                              
grant UPDATE on X12_FGROUP_SYNTAX_ERRORS to pcs_user ;                                              
grant DELETE on X12_INTERCHANGE_CODES to pcs_user ;   

grant execute on PRACTICES_ADD to pcs_user ;                                                                                                
grant execute on DOCTORS_ADD to pcs_user ;                                                                                                  
grant execute on PRACTICES_UPDATE to pcs_user ;                                                                                             
grant execute on LAB_REQS_ADD to pcs_user ;                                                                                                 
grant execute on LAB_REQ_DETAIL_ADD to pcs_user ;                                                                                           
grant execute on LAB_RESULTS_ADD to pcs_user ;                                                                                              
grant execute on LAB_RESULT_CODES_ADD to pcs_user ;                                                                                         
grant execute on DEFAULT_RULES to pcs_user ;                                                                                                
grant execute on GET_PATIENTS to pcs_user ;                                                                                                 
grant execute on MED_RULES to pcs_user ;                                                                                                    
grant execute on BUILD_HCFA1500_FILE to pcs_user ;                                                                                          
grant execute on DIAGNOSIS_UPDATE to pcs_user ;                                                                                             
grant execute on FIX_DOCTORS2 to pcs_user ;                                                                                                 

grant execute on FIX_DOCTORS to pcs_user ;                                                                                                  
grant execute on GET_CLINHIST to pcs_user ;                                                                                                 
grant execute on FINISH_LAB_REQS to pcs_user ;                                                                                              
grant execute on GET_HIST to pcs_user ;                                                                                                     
grant execute on TRASH_PROC to pcs_user ;                                                                                                   
grant execute on LAB_RESULTS_UPDATE to pcs_user ;                                                                                           
grant execute on POST_PAYMENTS to pcs_user ;                                                                                                
grant execute on GET_PATIENT_HISTORY to pcs_user ;                                                                                          
grant execute on BUILD_DOCTOR_STATEMENT to pcs_user ;                                                                                       
grant execute on GET_PREVIOUS_LABS to pcs_user ;                                                                                            
grant execute on PATIENT_ACCOUNT_UPDATE to pcs_user ;                                                                                       
grant execute on PRACTICES_EOM to pcs_user ;                                                                                                

grant execute on MAKE_JC_INVOICE to pcs_user ;                                                                                              
grant execute on BUILD_DAILY_REPORT_FILE to pcs_user ;                                                                                      
grant execute on BUILD_PATHOLOGIST_SUMMARY_FILE to pcs_user ;                                                                               
grant execute on BUILD_CYTOTECH_SUMMARY_FILE to pcs_user ;                                                                                  
grant execute on BUILD_BIOPSY_FILES to pcs_user ;                                                                                           
grant execute on BUILD_UNSATISFACTORY_FILE to pcs_user ;                                                                                    
grant execute on BUILD_EOM_SUMMARY_FILE to pcs_user ;                                                                                       
grant execute on BUILD_EOM_AGING_FILE to pcs_user ;                                                                                         
grant execute on COMPUTE_LABNUMBER_GAPS to pcs_user ;                                                                                       
grant execute on CHECK_BILLING_INFO to pcs_user ;                                                                                           
grant execute on BUILD_DIAGNOSIS_LETTER to pcs_user ;                                                                                       
grant execute on NMN_LETTER_UPDATE to pcs_user ;                                                                                            
grant execute on LOAD_ACCOUNT to pcs_user ;                                                                                                 

grant execute on CLINHIST_CONV_1D to pcs_user ;                                                                                             
grant execute on LOAD_ACCOUNTS to pcs_user ;                                                                                                
grant execute on CLINHIST_CONV_1 to pcs_user ;                                                                                              
grant execute on BUILD_PRACTICE_LABEL_FILE to pcs_user ;                                                                                    
grant execute on BUILD_PRACTICE_LABLE_FILE to pcs_user ;                                                                                    
grant execute on EDIT_RECEIVE_DATE to pcs_user ;                                                                                            
grant execute on FIX_CYTOTECHS to pcs_user ;                                                                                                
grant execute on BILLING_QUEUE_DELETE to pcs_user ;                                                                                         
grant execute on REBILL_UPDATE to pcs_user ;                                                                                                
grant execute on POST_ONE_PAYMENT to pcs_user ;                                                                                             
grant execute on PAYER_MERGE to pcs_user ;                                                                                                  
grant execute on BUILD_PRAC_MED_LBL_FILE to pcs_user ;                                                                                      
grant execute on ANALYZE_ACTIVITY_2 to pcs_user ;                                                                                           

grant execute on DIRECT_BILL_UPDATE to pcs_user ;                                                                                           
grant execute on BUILD_COLLECTION_FILE to pcs_user ;                                                                                        
grant execute on FIX_ACTIVITY to pcs_user ;                                                                                                 
grant execute on CALCULATE_BALANCES_2 to pcs_user ;                                                                                         
grant execute on CALCULATE_BALANCES to pcs_user ;                                                                                           
grant execute on GENERATE_SUMMARIES to pcs_user ;                                                                                           
grant execute on BUILD_MED_HIPAA_FILE to pcs_user ;                                                                                         
grant execute on GENERATE_STATEMENTS to pcs_user ;                                                                                          
grant execute on LAB_PAP_CLASS to pcs_user ;                                                                                                
grant execute on BUILD_MED_HIPPA_FILE to pcs_user ;                                                                                         
grant execute on BUILD_BS_HIPPA_FILE to pcs_user ;                                                                                          
grant execute on BUILD_HIPPA_FILE to pcs_user ;                                                                                             

grant execute on FIX_LIMITED to pcs_user ;                                                                                                  
grant execute on BUILD_WV_INVOICE_SUMMARY_9 to pcs_user ;                                                                                   
grant execute on BUILD_WV_INVOICE_SUMMARY_1 to pcs_user ;                                                                                   
grant execute on BUILD_WV_SUMMARY_1 to pcs_user ;                                                                                           
grant execute on BUILD_DOC_SUMM_PTYPE to pcs_user ;                                                                                         
grant execute on BUILD_WV_INVOICE_SUMM_FILE to pcs_user ;                                                                                   
grant execute on BUILD_ADPH_INVOICE_SUMM_FIX to pcs_user ;                                                                                  
grant execute on LOCATE_MISSING_CHARGES to pcs_user ;                                                                                       
grant execute on CHECK_NPI_NUMBERS to pcs_user ;                                                                                            
grant execute on RESET_CLAIM_STATUS to pcs_user ;                                                                                           
grant execute on BUILD_ADPH_INVOICE_SUMM_FILE to pcs_user ;                                                                                 
grant execute on DATA_PURGE to pcs_user ;                                                                                                   
grant execute on LIST_BCODES to pcs_user ;                                                                                                  

grant execute on COMMISSION to pcs_user ;                                                                                                   
grant execute on GENERATE_HISTORIES to pcs_user ;                                                                                           
grant execute on PRACTICES_DELETE to pcs_user ;                                                                                             
grant execute on PRACTICES_EOM_FIX to pcs_user ;                                                                                            
grant execute on REMOVE_RANGE to pcs_user ;                                                                                                 
grant execute on BUILD_REPORT_LBL_FILE to pcs_user ;                                                                                        
grant execute on BUILD_1500_CLAIM_FORMS to pcs_user ;                                                                                       
grant execute on REMOVE_YEAR to pcs_user ;                                                                                                  
grant execute on BUILD_ADPH_GRANT_FILE to pcs_user ;                                                                                        
grant execute on BUILD_ADPH_851_FILE to pcs_user ;                                                                                          
grant execute on CREATE_PATIENTS to pcs_user ;                                                                                              
grant execute on REMOVE_LAB to pcs_user ;                                                                                                   
grant execute on BENCHMARK to pcs_user ;                                                                                                    

grant execute on BUILD_ADPH_ABNORMAL_FILE to pcs_user ;                                                                                     
grant execute on BUILD_ADPH_ASCH_FILE to pcs_user ;                                                                                         
grant execute on BUILD_QB_IMPORT_FILE to pcs_user ;                                                                                         
grant execute on PRACTICES_MID to pcs_user ;                                                                                                
grant execute on TISSUE_RESULT_DETAILS_UPDATE to pcs_user ;                                                                                 
grant execute on TISSUE_RESULTS_DELETE to pcs_user ;                                                                                        
grant execute on TISSUE_RESULTS_UPDATE to pcs_user ;                                                                                        
grant execute on TISSUE_RESULT_DETAILS_ADD to pcs_user ;                                                                                    
grant execute on TISSUE_RESULTS_ADD to pcs_user ;                                                                                           
grant execute on BUILD_ADPH_SUMM2_FILE to pcs_user ;                                                                                        
grant execute on FIX_SUMMARIES to pcs_user ;                                                                                                
grant execute on FIX_PAP_CLASS to pcs_user ;                                                                                                
grant execute on FIX_PAP_CLASSES to pcs_user ;                                                                                              

grant execute on BUILD_EOM_ADPH_FILE to pcs_user ;                                                                                          
grant execute on BUILD_EOM_ADPH to pcs_user ;                                                                                               
grant execute on BUILD_XMAS_LABEL_FILE to pcs_user ;                                                                                        
grant execute on ADPH_SPSHT_INVOICE to pcs_user ;                                                                                           
grant execute on BUILD_FEDEX_IMPORT_FILE to pcs_user ;                                                                                      
grant execute on BUILD_AGREE_FILE to pcs_user ;                                                                                             
grant execute on BUILD_ADPH_QUARTERLY_FILE to pcs_user ;                                                                                    
grant execute on BUILD_ADPH_NP_FILE to pcs_user ;                                                                                           
grant execute on CREATE_DUMMY_CLAIM to pcs_user ;                                                                                           
grant execute on BUILD_ADPH_SUMMARY_FILE to pcs_user ;                                                                                      
grant execute on BUILD_ACCT_LIST_FILE to pcs_user ;                                                                                         
grant execute on BUILD_ASCUS_HPV_FILE to pcs_user ;                                                                                         
grant execute on SET_HPV to pcs_user ;                                                                                                      

grant execute on BUILD_ADEQUACY_RESULTS to pcs_user ;                                                                                       
grant execute on DOCUMENT_MED_CHANGE to pcs_user ;                                                                                          
grant execute on BUILD_ACCT_SUMMARY_FILE to pcs_user ;                                                                                      
grant execute on DAILY_JOBS to pcs_user ;                                                                                                   
grant execute on BUILD_CLINIC_CASES_FILE to pcs_user ;                                                                                      
grant execute on QUICKBOOKS2 to pcs_user ;                                                                                                  
grant execute on BUILD_STDCLINIC_YR_FILE to pcs_user ;                                                                                      
grant execute on REVERSE_CLAIM_PAYMENT to pcs_user ;                                                                                        
grant execute on QUICKBOOKS to pcs_user ;                                                                                                   
grant execute on APRIL_PRACTICES_EOM to pcs_user ;                                                                                          
grant execute on APRIL_BUILD_DOCTOR_STATEMENT to pcs_user ;                                                                                 
grant execute on TJJ_RERUN_STATEMENTS to pcs_user ;                                                                                         
grant execute on INIT_SCREENING_STATS_TABLE to pcs_user ;                                                                                   

grant execute on INITIALIZE_PRAC_EOM_DATA to pcs_user ;                                                                                     
grant execute on BUILD_XMAS_LBL_FILE to pcs_user ;                                                                                          
grant execute on CALCULATE_REBILL to pcs_user ;                                                                                             
grant execute on INITIALIZE_EOM_DATA to pcs_user ;                                                                                          
grant execute on BUILD_BETH_CODES_FILE to pcs_user ;                                                                                        
grant execute on DAILY_JOBS_TEST to pcs_user ;                                                                                              
grant execute on INIT_NEXT_EOM to pcs_user ;                                                                                                
grant execute on BUILD_WV_INVOICE_SUMMARY_8 to pcs_user ;                                                                                   
grant execute on BUILD_DOC_STATEMENT to pcs_user ;                                                                                          
grant execute on UPDATE_ACCOUNT to pcs_user ;                                                                                               
grant execute on BUILD_PAST_DUE_FILE to pcs_user ;                                                                                          
grant execute on RECALCULATE_MONTH to pcs_user ;                                                                                            
grant execute on NO_CHARGE_HPV to pcs_user ;                                                                                                

grant execute on FIX_ACCOUNT to pcs_user ;                                                                                                  
grant execute on SPECIAL_PROC to pcs_user ;                                                                                                 
grant execute on HPV_PENDING to pcs_user ;                                                                                                  
grant execute on RERUN_SUMMARIES to pcs_user ;                                                                                              
grant execute on RERUN_STATEMENTS to pcs_user ;                                                                                             
grant execute on FIX_FORWARDED to pcs_user ;                                                                                                
grant execute on FIX_ADJUSTMENTS to pcs_user ;                                                                                              
grant execute on VERIFY_CODES_EOM to pcs_user ;                                                                                             
grant execute on CHANGE_LAB_NUMBER to pcs_user ;                                                                                            
grant execute on CALCULATE_BALANCES_3 to pcs_user ;                                                                                         
grant execute on REVERSE_PAYMENT to pcs_user ;                                                                                              
grant execute on SUBMIT_NIGHT_JOBS to pcs_user ;                                                                                            

grant execute on BUILD_STDCLINIC_FILE to pcs_user ;                                                                                         
grant execute on REVERSE_DB to pcs_user ;                                                                                                   
grant execute on FIX_PATIENT_ACCOUNTS2 to pcs_user ;                                                                                        
grant execute on FIX_PATIENT_ACCOUNTS to pcs_user ;                                                                                         
grant execute on FIX_PAYMENTS to pcs_user ;                                                                                                 
grant execute on RESET_NIGHT_JOBS to pcs_user ;                                                                                             
grant execute on BUILD_PRACTICE_SUMMARY_FILE to pcs_user ;                                                                                  
grant execute on UPDATE_RECEIVE_DATES to pcs_user ;                                                                                         
grant execute on DOCTOR_MERGE to pcs_user ;                                                                                                 
grant execute on PROCESS_PENDING_PAYERS to pcs_user ;                                                                                       
grant execute on E_PAYER_INSERT to pcs_user ;                                                                                               
grant execute on BUILD_CLAIM_WKS_FILE to pcs_user ;                                                                                         
grant execute on PROCESS_NO_RESPONSE_CLAIMS to pcs_user ;                                                                                   

grant execute on BUILD_BLANK_LETTER to pcs_user ;                                                                                           
grant execute on BUILD_MEDICARE_LETTER to pcs_user ;                                                                                        
grant execute on CLAIM_REWORK to pcs_user ;                                                                                                 
grant execute on BUILD_MED_X12_FILE to pcs_user ;                                                                                           
grant execute on RUN_EOM to pcs_user ;                                                                                                      
grant execute on RESUBMIT_CLAIM to pcs_user ;                                                                                               
grant execute on LAB_PROCEDUER_UPDATE to pcs_user ;                                                                                         
grant execute on CLAIM_PAYMENT_UPDATE to pcs_user ;                                                                                         
grant execute on CLAIM_PAYMENT_ADD to pcs_user ;                                                                                            
grant execute on BUILD_BS_X12_FILE to pcs_user ;                                                                                            
grant execute on BUILD_PATIENT_CARDS to pcs_user ;                                                                                          
grant execute on BUILD_MA319C_FILE to pcs_user ;                                                                                            
grant execute on BUILD_DOCTOR_SUMMARY to pcs_user ;                                                                                         

grant execute on REBILL_ADD to pcs_user ;                                                                                                   
grant execute on BUILD_HM_WORKSHEET_COPY to pcs_user ;                                                                                      
grant execute on DELETE_RANGE to pcs_user ;                                                                                                 
grant execute on CREATE_RDATES to pcs_user ;                                                                                                
grant execute on GET_LAST_LABS to pcs_user ;                                                                                                
grant execute on PBS_RULES to pcs_user ;                                                                                                    
grant execute on DOC_RULES to pcs_user ;                                                                                                    
grant execute on CALCULATE_COST to pcs_user ;                                                                                               
grant execute on LAB_REQS_UPDATE to pcs_user ;                                                                                              
grant execute on DOCTORS_UPDATE to pcs_user ;                                                                                               
grant execute on VERIFY_DATE to pcs_user ;                                                                                                  
grant execute on VERIFY_NUMBER to pcs_user ;                                                                                                
grant execute on GET_CURRENT_BALANCE to pcs_user ;                                                                                          

grant execute on GET_ACCOUNT_NAME to pcs_user ;                                                                                             
grant execute on IS_EOM to pcs_user ;                                                                                                       
grant execute on GET_EOM_DATE to pcs_user ;                                                                                                 
grant execute on GET_EOM_MODE to pcs_user ;                                                                                                 
grant execute on GET_ACCOUNT_MIDPOINT to pcs_user ;                                                                                         
grant execute on GET_NEXT_SMONTH to pcs_user ;                                                                                              
grant execute on GET_PURGE_COUNT to pcs_user ;                                                                                              
grant execute on IS_NO_ECC to pcs_user ;                                                                                                    
grant execute on VALIDATE_DOCTOR to pcs_user ;                                                                                              
grant execute on GET_PAP_CLASS to pcs_user ;                                                                                                
grant execute on GET_ACCOUNT_INFO to pcs_user ;                                                                                             
grant execute on VERIFY_CHARGES to pcs_user ;                                                                                               
grant execute on GET_RECEIVE_DATE to pcs_user ;                                                                                             

grant execute on STRIP_CHARS to pcs_user ;   

grant pcs_user to lritchey;
grant pcs_user to achioda;
grant pcs_user to pcollins;


