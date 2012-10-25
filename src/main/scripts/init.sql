-- Documentation of things might need done; but some aren't done every import and some aren't done in the context of this user
--2.  grant dba to pcs;
--3.  grant select on sys.dba_free_space to pcs;
connect / as sysdba
grant dba to pcs
grant 
/
grant select on sys.dba_free_space to pcs
/
disconnect
connect pcs/ahb21@pcs


grant ALTER on ADEQUACY_RESULT_CODES to lritchey ;                                                  
grant DELETE on ADEQUACY_RESULT_CODES to lritchey ;                                                 
grant INDEX on ADEQUACY_RESULT_CODES to lritchey ;                                                  
grant INSERT on ADEQUACY_RESULT_CODES to lritchey ;                                                 
grant SELECT on ADEQUACY_RESULT_CODES to lritchey ;                                                 
grant UPDATE on ADEQUACY_RESULT_CODES to lritchey ;                                                 
grant REFERENCES on ADEQUACY_RESULT_CODES to lritchey ;                                             
grant ALTER on ADPH_LAB_WHP to lritchey ;                                                           
grant DELETE on ADPH_LAB_WHP to lritchey ;                                                          
grant INDEX on ADPH_LAB_WHP to lritchey ;                                                           
grant INSERT on ADPH_LAB_WHP to lritchey ;                                                          
grant SELECT on ADPH_LAB_WHP to lritchey ;                                                          
grant UPDATE on ADPH_LAB_WHP to lritchey ;                                                          
grant REFERENCES on ADPH_LAB_WHP to lritchey ;                                                      
grant ALTER on ADPH_LAB_WHP_TMP to lritchey ;                                                       
grant DELETE on ADPH_LAB_WHP_TMP to lritchey ;                                                      
grant INDEX on ADPH_LAB_WHP_TMP to lritchey ;                                                       
grant INSERT on ADPH_LAB_WHP_TMP to lritchey ;                                                      
grant SELECT on ADPH_LAB_WHP_TMP to lritchey ;                                                      
grant UPDATE on ADPH_LAB_WHP_TMP to lritchey ;                                                      
grant REFERENCES on ADPH_LAB_WHP_TMP to lritchey ;                                                  
grant ALTER on ADPH_PROGRAMS to lritchey ;                                                          
grant DELETE on ADPH_PROGRAMS to lritchey ;                                                         

grant INDEX on ADPH_PROGRAMS to lritchey ;                                                          
grant INSERT on ADPH_PROGRAMS to lritchey ;                                                         
grant SELECT on ADPH_PROGRAMS to lritchey ;                                                         
grant UPDATE on ADPH_PROGRAMS to lritchey ;                                                         
grant REFERENCES on ADPH_PROGRAMS to lritchey ;                                                     
grant ALTER on BENCHMARKS to lritchey ;                                                             
grant DELETE on BENCHMARKS to lritchey ;                                                            
grant INDEX on BENCHMARKS to lritchey ;                                                             
grant INSERT on BENCHMARKS to lritchey ;                                                            
grant SELECT on BENCHMARKS to lritchey ;                                                            
grant UPDATE on BENCHMARKS to lritchey ;                                                            
grant REFERENCES on BENCHMARKS to lritchey ;                                                        
grant ALTER on BETHESDA_CODES to lritchey ;                                                         
grant DELETE on BETHESDA_CODES to lritchey ;                                                        
grant INDEX on BETHESDA_CODES to lritchey ;                                                         
grant INSERT on BETHESDA_CODES to lritchey ;                                                        
grant SELECT on BETHESDA_CODES to lritchey ;                                                        
grant UPDATE on BETHESDA_CODES to lritchey ;                                                        
grant REFERENCES on BETHESDA_CODES to lritchey ;                                                    
grant ALTER on BETHESDA_PRIOR_DESCR to lritchey ;                                                   
grant DELETE on BETHESDA_PRIOR_DESCR to lritchey ;                                                  
grant INDEX on BETHESDA_PRIOR_DESCR to lritchey ;                                                   
grant INSERT on BETHESDA_PRIOR_DESCR to lritchey ;                                                  

grant SELECT on BETHESDA_PRIOR_DESCR to lritchey ;                                                  
grant UPDATE on BETHESDA_PRIOR_DESCR to lritchey ;                                                  
grant REFERENCES on BETHESDA_PRIOR_DESCR to lritchey ;                                              
grant ALTER on BETH_HPV_XREF to lritchey ;                                                          
grant DELETE on BETH_HPV_XREF to lritchey ;                                                         
grant INDEX on BETH_HPV_XREF to lritchey ;                                                          
grant INSERT on BETH_HPV_XREF to lritchey ;                                                         
grant SELECT on BETH_HPV_XREF to lritchey ;                                                         
grant UPDATE on BETH_HPV_XREF to lritchey ;                                                         
grant REFERENCES on BETH_HPV_XREF to lritchey ;                                                     
grant ALTER on BETH_ICD9_XREF to lritchey ;                                                         
grant DELETE on BETH_ICD9_XREF to lritchey ;                                                        
grant INDEX on BETH_ICD9_XREF to lritchey ;                                                         
grant INSERT on BETH_ICD9_XREF to lritchey ;                                                        
grant SELECT on BETH_ICD9_XREF to lritchey ;                                                        
grant UPDATE on BETH_ICD9_XREF to lritchey ;                                                        
grant REFERENCES on BETH_ICD9_XREF to lritchey ;                                                    
grant ALTER on BETH_STD_XREF to lritchey ;                                                          
grant DELETE on BETH_STD_XREF to lritchey ;                                                         
grant INDEX on BETH_STD_XREF to lritchey ;                                                          
grant INSERT on BETH_STD_XREF to lritchey ;                                                         
grant SELECT on BETH_STD_XREF to lritchey ;                                                         
grant UPDATE on BETH_STD_XREF to lritchey ;                                                         

grant REFERENCES on BETH_STD_XREF to lritchey ;                                                     
grant ALTER on BILLING_CHOICES to lritchey ;                                                        
grant DELETE on BILLING_CHOICES to lritchey ;                                                       
grant INDEX on BILLING_CHOICES to lritchey ;                                                        
grant INSERT on BILLING_CHOICES to lritchey ;                                                       
grant SELECT on BILLING_CHOICES to lritchey ;                                                       
grant UPDATE on BILLING_CHOICES to lritchey ;                                                       
grant REFERENCES on BILLING_CHOICES to lritchey ;                                                   
grant ALTER on BILLING_CHOICES_SEQ to lritchey ;                                                    
grant SELECT on BILLING_CHOICES_SEQ to lritchey ;                                                   
grant ALTER on BILLING_DETAILS to lritchey ;                                                        
grant DELETE on BILLING_DETAILS to lritchey ;                                                       
grant INDEX on BILLING_DETAILS to lritchey ;                                                        
grant INSERT on BILLING_DETAILS to lritchey ;                                                       
grant SELECT on BILLING_DETAILS to lritchey ;                                                       
grant UPDATE on BILLING_DETAILS to lritchey ;                                                       
grant REFERENCES on BILLING_DETAILS to lritchey ;                                                   
grant ALTER on BILLING_QUEUE to lritchey ;                                                          
grant DELETE on BILLING_QUEUE to lritchey ;                                                         
grant INDEX on BILLING_QUEUE to lritchey ;                                                          
grant INSERT on BILLING_QUEUE to lritchey ;                                                         
grant SELECT on BILLING_QUEUE to lritchey ;                                                         
grant UPDATE on BILLING_QUEUE to lritchey ;                                                         

grant REFERENCES on BILLING_QUEUE to lritchey ;                                                     
grant ALTER on BILLING_ROUTES to lritchey ;                                                         
grant DELETE on BILLING_ROUTES to lritchey ;                                                        
grant INDEX on BILLING_ROUTES to lritchey ;                                                         
grant INSERT on BILLING_ROUTES to lritchey ;                                                        
grant SELECT on BILLING_ROUTES to lritchey ;                                                        
grant UPDATE on BILLING_ROUTES to lritchey ;                                                        
grant REFERENCES on BILLING_ROUTES to lritchey ;                                                    
grant ALTER on BILLING_TYPES to lritchey ;                                                          
grant DELETE on BILLING_TYPES to lritchey ;                                                         
grant INDEX on BILLING_TYPES to lritchey ;                                                          
grant INSERT on BILLING_TYPES to lritchey ;                                                         
grant SELECT on BILLING_TYPES to lritchey ;                                                         
grant UPDATE on BILLING_TYPES to lritchey ;                                                         
grant REFERENCES on BILLING_TYPES to lritchey ;                                                     
grant ALTER on BT_SUM_WORK to lritchey ;                                                            
grant DELETE on BT_SUM_WORK to lritchey ;                                                           
grant INDEX on BT_SUM_WORK to lritchey ;                                                            
grant INSERT on BT_SUM_WORK to lritchey ;                                                           
grant SELECT on BT_SUM_WORK to lritchey ;                                                           
grant UPDATE on BT_SUM_WORK to lritchey ;                                                           
grant REFERENCES on BT_SUM_WORK to lritchey ;                                                       
grant ALTER on BUSINESS_ID_NUMS to lritchey ;                                                       

grant DELETE on BUSINESS_ID_NUMS to lritchey ;                                                      
grant INDEX on BUSINESS_ID_NUMS to lritchey ;                                                       
grant INSERT on BUSINESS_ID_NUMS to lritchey ;                                                      
grant SELECT on BUSINESS_ID_NUMS to lritchey ;                                                      
grant UPDATE on BUSINESS_ID_NUMS to lritchey ;                                                      
grant REFERENCES on BUSINESS_ID_NUMS to lritchey ;                                                  
grant ALTER on BUSINESS_INFO to lritchey ;                                                          
grant DELETE on BUSINESS_INFO to lritchey ;                                                         
grant INDEX on BUSINESS_INFO to lritchey ;                                                          
grant INSERT on BUSINESS_INFO to lritchey ;                                                         
grant SELECT on BUSINESS_INFO to lritchey ;                                                         
grant UPDATE on BUSINESS_INFO to lritchey ;                                                         
grant REFERENCES on BUSINESS_INFO to lritchey ;                                                     
grant ALTER on CARRIERS to lritchey ;                                                               
grant DELETE on CARRIERS to lritchey ;                                                              
grant INDEX on CARRIERS to lritchey ;                                                               
grant INSERT on CARRIERS to lritchey ;                                                              
grant SELECT on CARRIERS to lritchey ;                                                              
grant UPDATE on CARRIERS to lritchey ;                                                              
grant REFERENCES on CARRIERS to lritchey ;                                                          
grant ALTER on CARRIERS_SEQ to lritchey ;                                                           
grant SELECT on CARRIERS_SEQ to lritchey ;                                                          
grant ALTER on CARRIER_COMMENTS to lritchey ;                                                       

grant DELETE on CARRIER_COMMENTS to lritchey ;                                                      
grant INDEX on CARRIER_COMMENTS to lritchey ;                                                       
grant INSERT on CARRIER_COMMENTS to lritchey ;                                                      
grant SELECT on CARRIER_COMMENTS to lritchey ;                                                      
grant UPDATE on CARRIER_COMMENTS to lritchey ;                                                      
grant REFERENCES on CARRIER_COMMENTS to lritchey ;                                                  
grant ALTER on CLAIM_BATCHES to lritchey ;                                                          
grant DELETE on CLAIM_BATCHES to lritchey ;                                                         
grant INDEX on CLAIM_BATCHES to lritchey ;                                                          
grant INSERT on CLAIM_BATCHES to lritchey ;                                                         
grant SELECT on CLAIM_BATCHES to lritchey ;                                                         
grant UPDATE on CLAIM_BATCHES to lritchey ;                                                         
grant REFERENCES on CLAIM_BATCHES to lritchey ;                                                     
grant ALTER on CLAIM_SEQ to lritchey ;                                                              
grant SELECT on CLAIM_SEQ to lritchey ;                                                             
grant ALTER on CLAIM_STATUSES to lritchey ;                                                         
grant DELETE on CLAIM_STATUSES to lritchey ;                                                        
grant INDEX on CLAIM_STATUSES to lritchey ;                                                         
grant INSERT on CLAIM_STATUSES to lritchey ;                                                        
grant SELECT on CLAIM_STATUSES to lritchey ;                                                        
grant UPDATE on CLAIM_STATUSES to lritchey ;                                                        
grant REFERENCES on CLAIM_STATUSES to lritchey ;                                                    
grant ALTER on CLAIM_STATUS_RESPONSES to lritchey ;                                                 

grant DELETE on CLAIM_STATUS_RESPONSES to lritchey ;                                                
grant INDEX on CLAIM_STATUS_RESPONSES to lritchey ;                                                 
grant INSERT on CLAIM_STATUS_RESPONSES to lritchey ;                                                
grant SELECT on CLAIM_STATUS_RESPONSES to lritchey ;                                                
grant UPDATE on CLAIM_STATUS_RESPONSES to lritchey ;                                                
grant REFERENCES on CLAIM_STATUS_RESPONSES to lritchey ;                                            
grant ALTER on CLAIM_SUBMISSIONS to lritchey ;                                                      
grant DELETE on CLAIM_SUBMISSIONS to lritchey ;                                                     
grant INDEX on CLAIM_SUBMISSIONS to lritchey ;                                                      
grant INSERT on CLAIM_SUBMISSIONS to lritchey ;                                                     
grant SELECT on CLAIM_SUBMISSIONS to lritchey ;                                                     
grant UPDATE on CLAIM_SUBMISSIONS to lritchey ;                                                     
grant REFERENCES on CLAIM_SUBMISSIONS to lritchey ;                                                 
grant ALTER on CLAIM_SUBMISSION_SEQ to lritchey ;                                                   
grant SELECT on CLAIM_SUBMISSION_SEQ to lritchey ;                                                  
grant ALTER on COLLECTIONS_SEQ to lritchey ;                                                        
grant SELECT on COLLECTIONS_SEQ to lritchey ;                                                       
grant ALTER on CONV_SEQ to lritchey ;                                                               
grant SELECT on CONV_SEQ to lritchey ;                                                              
grant ALTER on CYTOPATH_HISTORY to lritchey ;                                                       
grant DELETE on CYTOPATH_HISTORY to lritchey ;                                                      
grant INDEX on CYTOPATH_HISTORY to lritchey ;                                                       
grant INSERT on CYTOPATH_HISTORY to lritchey ;                                                      

grant SELECT on CYTOPATH_HISTORY to lritchey ;                                                      
grant UPDATE on CYTOPATH_HISTORY to lritchey ;                                                      
grant REFERENCES on CYTOPATH_HISTORY to lritchey ;                                                  
grant ALTER on CYTOPATH_PRINT_QUEUE to lritchey ;                                                   
grant DELETE on CYTOPATH_PRINT_QUEUE to lritchey ;                                                  
grant INDEX on CYTOPATH_PRINT_QUEUE to lritchey ;                                                   
grant INSERT on CYTOPATH_PRINT_QUEUE to lritchey ;                                                  
grant SELECT on CYTOPATH_PRINT_QUEUE to lritchey ;                                                  
grant UPDATE on CYTOPATH_PRINT_QUEUE to lritchey ;                                                  
grant REFERENCES on CYTOPATH_PRINT_QUEUE to lritchey ;                                              
grant ALTER on CYTOTECHS to lritchey ;                                                              
grant DELETE on CYTOTECHS to lritchey ;                                                             
grant INDEX on CYTOTECHS to lritchey ;                                                              
grant INSERT on CYTOTECHS to lritchey ;                                                             
grant SELECT on CYTOTECHS to lritchey ;                                                             
grant UPDATE on CYTOTECHS to lritchey ;                                                             
grant REFERENCES on CYTOTECHS to lritchey ;                                                         
grant ALTER on DB_COMMENTS to lritchey ;                                                            
grant DELETE on DB_COMMENTS to lritchey ;                                                           
grant INDEX on DB_COMMENTS to lritchey ;                                                            
grant INSERT on DB_COMMENTS to lritchey ;                                                           
grant SELECT on DB_COMMENTS to lritchey ;                                                           
grant UPDATE on DB_COMMENTS to lritchey ;                                                           

grant REFERENCES on DB_COMMENTS to lritchey ;                                                       
grant ALTER on DB_VERIFY to lritchey ;                                                              
grant DELETE on DB_VERIFY to lritchey ;                                                             
grant INDEX on DB_VERIFY to lritchey ;                                                              
grant INSERT on DB_VERIFY to lritchey ;                                                             
grant SELECT on DB_VERIFY to lritchey ;                                                             
grant UPDATE on DB_VERIFY to lritchey ;                                                             
grant REFERENCES on DB_VERIFY to lritchey ;                                                         
grant ALTER on DETAIL_CODES to lritchey ;                                                           
grant DELETE on DETAIL_CODES to lritchey ;                                                          
grant INDEX on DETAIL_CODES to lritchey ;                                                           
grant INSERT on DETAIL_CODES to lritchey ;                                                          
grant SELECT on DETAIL_CODES to lritchey ;                                                          
grant UPDATE on DETAIL_CODES to lritchey ;                                                          
grant REFERENCES on DETAIL_CODES to lritchey ;                                                      
grant ALTER on DIAGNOSIS_CODES to lritchey ;                                                        
grant DELETE on DIAGNOSIS_CODES to lritchey ;                                                       
grant INDEX on DIAGNOSIS_CODES to lritchey ;                                                        
grant INSERT on DIAGNOSIS_CODES to lritchey ;                                                       
grant SELECT on DIAGNOSIS_CODES to lritchey ;                                                       
grant UPDATE on DIAGNOSIS_CODES to lritchey ;                                                       
grant REFERENCES on DIAGNOSIS_CODES to lritchey ;                                                   
grant ALTER on DIRECTORS to lritchey ;                                                              

grant DELETE on DIRECTORS to lritchey ;                                                             
grant INDEX on DIRECTORS to lritchey ;                                                              
grant INSERT on DIRECTORS to lritchey ;                                                             
grant SELECT on DIRECTORS to lritchey ;                                                             
grant UPDATE on DIRECTORS to lritchey ;                                                             
grant REFERENCES on DIRECTORS to lritchey ;                                                         
grant ALTER on DOCTORS to lritchey ;                                                                
grant DELETE on DOCTORS to lritchey ;                                                               
grant INDEX on DOCTORS to lritchey ;                                                                
grant INSERT on DOCTORS to lritchey ;                                                               
grant SELECT on DOCTORS to lritchey ;                                                               
grant UPDATE on DOCTORS to lritchey ;                                                               
grant REFERENCES on DOCTORS to lritchey ;                                                           
grant ALTER on DOCTOR_SEQ to lritchey ;                                                             
grant SELECT on DOCTOR_SEQ to lritchey ;                                                            
grant ALTER on DOC_SUM_WORK to lritchey ;                                                           
grant DELETE on DOC_SUM_WORK to lritchey ;                                                          
grant INDEX on DOC_SUM_WORK to lritchey ;                                                           
grant INSERT on DOC_SUM_WORK to lritchey ;                                                          
grant SELECT on DOC_SUM_WORK to lritchey ;                                                          
grant UPDATE on DOC_SUM_WORK to lritchey ;                                                          
grant REFERENCES on DOC_SUM_WORK to lritchey ;                                                      
grant ALTER on ERROR_LOG to lritchey ;                                                              

grant DELETE on ERROR_LOG to lritchey ;                                                             
grant INDEX on ERROR_LOG to lritchey ;                                                              
grant INSERT on ERROR_LOG to lritchey ;                                                             
grant SELECT on ERROR_LOG to lritchey ;                                                             
grant UPDATE on ERROR_LOG to lritchey ;                                                             
grant REFERENCES on ERROR_LOG to lritchey ;                                                         
grant ALTER on FAX_LETTERS to lritchey ;                                                            
grant DELETE on FAX_LETTERS to lritchey ;                                                           
grant INDEX on FAX_LETTERS to lritchey ;                                                            
grant INSERT on FAX_LETTERS to lritchey ;                                                           
grant SELECT on FAX_LETTERS to lritchey ;                                                           
grant UPDATE on FAX_LETTERS to lritchey ;                                                           
grant REFERENCES on FAX_LETTERS to lritchey ;                                                       
grant ALTER on GENERIC_SEQ to lritchey ;                                                            
grant SELECT on GENERIC_SEQ to lritchey ;                                                           
grant ALTER on GROUP_CONTROL_NUM_SEQ to lritchey ;                                                  
grant SELECT on GROUP_CONTROL_NUM_SEQ to lritchey ;                                                 
grant ALTER on HISTORY_MATCH_QUEUE to lritchey ;                                                    
grant DELETE on HISTORY_MATCH_QUEUE to lritchey ;                                                   
grant INDEX on HISTORY_MATCH_QUEUE to lritchey ;                                                    
grant INSERT on HISTORY_MATCH_QUEUE to lritchey ;                                                   
grant SELECT on HISTORY_MATCH_QUEUE to lritchey ;                                                   
grant UPDATE on HISTORY_MATCH_QUEUE to lritchey ;                                                   

grant REFERENCES on HISTORY_MATCH_QUEUE to lritchey ;                                               
grant ALTER on HISTORY_WORKTBL to lritchey ;                                                        
grant DELETE on HISTORY_WORKTBL to lritchey ;                                                       
grant INDEX on HISTORY_WORKTBL to lritchey ;                                                        
grant INSERT on HISTORY_WORKTBL to lritchey ;                                                       
grant SELECT on HISTORY_WORKTBL to lritchey ;                                                       
grant UPDATE on HISTORY_WORKTBL to lritchey ;                                                       
grant REFERENCES on HISTORY_WORKTBL to lritchey ;                                                   
grant ALTER on HPV_HISTORY to lritchey ;                                                            
grant DELETE on HPV_HISTORY to lritchey ;                                                           
grant INDEX on HPV_HISTORY to lritchey ;                                                            
grant INSERT on HPV_HISTORY to lritchey ;                                                           
grant SELECT on HPV_HISTORY to lritchey ;                                                           
grant UPDATE on HPV_HISTORY to lritchey ;                                                           
grant REFERENCES on HPV_HISTORY to lritchey ;                                                       
grant ALTER on HPV_PRINT_QUEUE to lritchey ;                                                        
grant DELETE on HPV_PRINT_QUEUE to lritchey ;                                                       
grant INDEX on HPV_PRINT_QUEUE to lritchey ;                                                        
grant INSERT on HPV_PRINT_QUEUE to lritchey ;                                                       
grant SELECT on HPV_PRINT_QUEUE to lritchey ;                                                       
grant UPDATE on HPV_PRINT_QUEUE to lritchey ;                                                       
grant REFERENCES on HPV_PRINT_QUEUE to lritchey ;                                                   
grant ALTER on HPV_REQUESTS to lritchey ;                                                           

grant DELETE on HPV_REQUESTS to lritchey ;                                                          
grant INDEX on HPV_REQUESTS to lritchey ;                                                           
grant INSERT on HPV_REQUESTS to lritchey ;                                                          
grant SELECT on HPV_REQUESTS to lritchey ;                                                          
grant UPDATE on HPV_REQUESTS to lritchey ;                                                          
grant REFERENCES on HPV_REQUESTS to lritchey ;                                                      
grant ALTER on IBC_PREFIXES to lritchey ;                                                           
grant DELETE on IBC_PREFIXES to lritchey ;                                                          
grant INDEX on IBC_PREFIXES to lritchey ;                                                           
grant INSERT on IBC_PREFIXES to lritchey ;                                                          
grant SELECT on IBC_PREFIXES to lritchey ;                                                          
grant UPDATE on IBC_PREFIXES to lritchey ;                                                          
grant REFERENCES on IBC_PREFIXES to lritchey ;                                                      
grant ALTER on INVOICE_WORK to lritchey ;                                                           
grant DELETE on INVOICE_WORK to lritchey ;                                                          
grant INDEX on INVOICE_WORK to lritchey ;                                                           
grant INSERT on INVOICE_WORK to lritchey ;                                                          
grant SELECT on INVOICE_WORK to lritchey ;                                                          
grant UPDATE on INVOICE_WORK to lritchey ;                                                          
grant REFERENCES on INVOICE_WORK to lritchey ;                                                      
grant ALTER on JOB_CONTROL to lritchey ;                                                            
grant DELETE on JOB_CONTROL to lritchey ;                                                           
grant INDEX on JOB_CONTROL to lritchey ;                                                            

grant INSERT on JOB_CONTROL to lritchey ;                                                           
grant SELECT on JOB_CONTROL to lritchey ;                                                           
grant UPDATE on JOB_CONTROL to lritchey ;                                                           
grant REFERENCES on JOB_CONTROL to lritchey ;                                                       
grant ALTER on LAB_BILLINGS to lritchey ;                                                           
grant DELETE on LAB_BILLINGS to lritchey ;                                                          
grant INDEX on LAB_BILLINGS to lritchey ;                                                           
grant INSERT on LAB_BILLINGS to lritchey ;                                                          
grant SELECT on LAB_BILLINGS to lritchey ;                                                          
grant UPDATE on LAB_BILLINGS to lritchey ;                                                          
grant REFERENCES on LAB_BILLINGS to lritchey ;                                                      
grant ALTER on LAB_BILLING_ITEMS to lritchey ;                                                      
grant DELETE on LAB_BILLING_ITEMS to lritchey ;                                                     
grant INDEX on LAB_BILLING_ITEMS to lritchey ;                                                      
grant INSERT on LAB_BILLING_ITEMS to lritchey ;                                                     
grant SELECT on LAB_BILLING_ITEMS to lritchey ;                                                     
grant UPDATE on LAB_BILLING_ITEMS to lritchey ;                                                     
grant REFERENCES on LAB_BILLING_ITEMS to lritchey ;                                                 
grant ALTER on LAB_CLAIMS to lritchey ;                                                             
grant DELETE on LAB_CLAIMS to lritchey ;                                                            
grant INDEX on LAB_CLAIMS to lritchey ;                                                             
grant INSERT on LAB_CLAIMS to lritchey ;                                                            
grant SELECT on LAB_CLAIMS to lritchey ;                                                            

grant UPDATE on LAB_CLAIMS to lritchey ;                                                            
grant REFERENCES on LAB_CLAIMS to lritchey ;                                                        
grant ALTER on LAB_CLAIMS_HISTORY to lritchey ;                                                     
grant DELETE on LAB_CLAIMS_HISTORY to lritchey ;                                                    
grant INDEX on LAB_CLAIMS_HISTORY to lritchey ;                                                     
grant INSERT on LAB_CLAIMS_HISTORY to lritchey ;                                                    
grant SELECT on LAB_CLAIMS_HISTORY to lritchey ;                                                    
grant UPDATE on LAB_CLAIMS_HISTORY to lritchey ;                                                    
grant REFERENCES on LAB_CLAIMS_HISTORY to lritchey ;                                                
grant ALTER on LAB_MAT_INDEX to lritchey ;                                                          
grant DELETE on LAB_MAT_INDEX to lritchey ;                                                         
grant INDEX on LAB_MAT_INDEX to lritchey ;                                                          
grant INSERT on LAB_MAT_INDEX to lritchey ;                                                         
grant SELECT on LAB_MAT_INDEX to lritchey ;                                                         
grant UPDATE on LAB_MAT_INDEX to lritchey ;                                                         
grant REFERENCES on LAB_MAT_INDEX to lritchey ;                                                     
grant ALTER on LAB_NUM_SEQ to lritchey ;                                                            
grant SELECT on LAB_NUM_SEQ to lritchey ;                                                           
grant ALTER on LAB_PREPARATIONS to lritchey ;                                                       
grant DELETE on LAB_PREPARATIONS to lritchey ;                                                      
grant INDEX on LAB_PREPARATIONS to lritchey ;                                                       
grant INSERT on LAB_PREPARATIONS to lritchey ;                                                      
grant SELECT on LAB_PREPARATIONS to lritchey ;                                                      

grant UPDATE on LAB_PREPARATIONS to lritchey ;                                                      
grant REFERENCES on LAB_PREPARATIONS to lritchey ;                                                  
grant ALTER on LAB_REQUISITIONS to lritchey ;                                                       
grant DELETE on LAB_REQUISITIONS to lritchey ;                                                      
grant INDEX on LAB_REQUISITIONS to lritchey ;                                                       
grant INSERT on LAB_REQUISITIONS to lritchey ;                                                      
grant SELECT on LAB_REQUISITIONS to lritchey ;                                                      
grant UPDATE on LAB_REQUISITIONS to lritchey ;                                                      
grant REFERENCES on LAB_REQUISITIONS to lritchey ;                                                  
grant ALTER on LAB_REQ_CLIENT_NOTES to lritchey ;                                                   
grant DELETE on LAB_REQ_CLIENT_NOTES to lritchey ;                                                  
grant INDEX on LAB_REQ_CLIENT_NOTES to lritchey ;                                                   
grant INSERT on LAB_REQ_CLIENT_NOTES to lritchey ;                                                  
grant SELECT on LAB_REQ_CLIENT_NOTES to lritchey ;                                                  
grant UPDATE on LAB_REQ_CLIENT_NOTES to lritchey ;                                                  
grant REFERENCES on LAB_REQ_CLIENT_NOTES to lritchey ;                                              
grant ALTER on LAB_REQ_COMMENTS to lritchey ;                                                       
grant DELETE on LAB_REQ_COMMENTS to lritchey ;                                                      
grant INDEX on LAB_REQ_COMMENTS to lritchey ;                                                       
grant INSERT on LAB_REQ_COMMENTS to lritchey ;                                                      
grant SELECT on LAB_REQ_COMMENTS to lritchey ;                                                      
grant UPDATE on LAB_REQ_COMMENTS to lritchey ;                                                      
grant REFERENCES on LAB_REQ_COMMENTS to lritchey ;                                                  

grant ALTER on LAB_REQ_DETAILS to lritchey ;                                                        
grant DELETE on LAB_REQ_DETAILS to lritchey ;                                                       
grant INDEX on LAB_REQ_DETAILS to lritchey ;                                                        
grant INSERT on LAB_REQ_DETAILS to lritchey ;                                                       
grant SELECT on LAB_REQ_DETAILS to lritchey ;                                                       
grant UPDATE on LAB_REQ_DETAILS to lritchey ;                                                       
grant REFERENCES on LAB_REQ_DETAILS to lritchey ;                                                   
grant ALTER on LAB_REQ_DETAILS_ADDITIONAL to lritchey ;                                             
grant DELETE on LAB_REQ_DETAILS_ADDITIONAL to lritchey ;                                            
grant INDEX on LAB_REQ_DETAILS_ADDITIONAL to lritchey ;                                             
grant INSERT on LAB_REQ_DETAILS_ADDITIONAL to lritchey ;                                            
grant SELECT on LAB_REQ_DETAILS_ADDITIONAL to lritchey ;                                            
grant UPDATE on LAB_REQ_DETAILS_ADDITIONAL to lritchey ;                                            
grant REFERENCES on LAB_REQ_DETAILS_ADDITIONAL to lritchey ;                                        

grant ALTER on LAB_REQ_DIAGNOSIS to lritchey ;                                                      
grant DELETE on LAB_REQ_DIAGNOSIS to lritchey ;                                                     
grant INDEX on LAB_REQ_DIAGNOSIS to lritchey ;                                                      
grant INSERT on LAB_REQ_DIAGNOSIS to lritchey ;                                                     
grant SELECT on LAB_REQ_DIAGNOSIS to lritchey ;                                                     
grant UPDATE on LAB_REQ_DIAGNOSIS to lritchey ;                                                     
grant REFERENCES on LAB_REQ_DIAGNOSIS to lritchey ;                                                 

grant ALTER on LAB_RESULTS to lritchey ;                                                            
grant DELETE on LAB_RESULTS to lritchey ;                                                           
grant INDEX on LAB_RESULTS to lritchey ;                                                            
grant INSERT on LAB_RESULTS to lritchey ;                                                           
grant SELECT on LAB_RESULTS to lritchey ;                                                           
grant UPDATE on LAB_RESULTS to lritchey ;                                                           
grant REFERENCES on LAB_RESULTS to lritchey ;                                                       
grant ALTER on LAB_RESULT_CODES to lritchey ;                                                       
grant DELETE on LAB_RESULT_CODES to lritchey ;                                                      
grant INDEX on LAB_RESULT_CODES to lritchey ;                                                       
grant INSERT on LAB_RESULT_CODES to lritchey ;                                                      
grant SELECT on LAB_RESULT_CODES to lritchey ;                                                      
grant UPDATE on LAB_RESULT_CODES to lritchey ;                                                      
grant REFERENCES on LAB_RESULT_CODES to lritchey ;                                                  
grant ALTER on LAB_RESULT_COMMENTS to lritchey ;                                                    
grant DELETE on LAB_RESULT_COMMENTS to lritchey ;                                                   
grant INDEX on LAB_RESULT_COMMENTS to lritchey ;                                                    
grant INSERT on LAB_RESULT_COMMENTS to lritchey ;                                                   
grant SELECT on LAB_RESULT_COMMENTS to lritchey ;                                                   
grant UPDATE on LAB_RESULT_COMMENTS to lritchey ;                                                   
grant REFERENCES on LAB_RESULT_COMMENTS to lritchey ;                                               
grant ALTER on MAILER to lritchey ;                                                                 
grant DELETE on MAILER to lritchey ;                                                                

grant INDEX on MAILER to lritchey ;                                                                 
grant INSERT on MAILER to lritchey ;                                                                
grant SELECT on MAILER to lritchey ;                                                                
grant UPDATE on MAILER to lritchey ;                                                                
grant REFERENCES on MAILER to lritchey ;                                                            
grant ALTER on MONTHLY_REPORTS to lritchey ;                                                        
grant DELETE on MONTHLY_REPORTS to lritchey ;                                                       
grant INDEX on MONTHLY_REPORTS to lritchey ;                                                        
grant INSERT on MONTHLY_REPORTS to lritchey ;                                                       
grant SELECT on MONTHLY_REPORTS to lritchey ;                                                       
grant UPDATE on MONTHLY_REPORTS to lritchey ;                                                       
grant REFERENCES on MONTHLY_REPORTS to lritchey ;                                                   
grant ALTER on PAP_CLASSES to lritchey ;                                                            
grant DELETE on PAP_CLASSES to lritchey ;                                                           
grant INDEX on PAP_CLASSES to lritchey ;                                                            
grant INSERT on PAP_CLASSES to lritchey ;                                                           
grant SELECT on PAP_CLASSES to lritchey ;                                                           
grant UPDATE on PAP_CLASSES to lritchey ;                                                           
grant REFERENCES on PAP_CLASSES to lritchey ;                                                       
grant ALTER on PAP_CLASS_CHANGES to lritchey ;                                                      
grant DELETE on PAP_CLASS_CHANGES to lritchey ;                                                     
grant INDEX on PAP_CLASS_CHANGES to lritchey ;                                                      
grant INSERT on PAP_CLASS_CHANGES to lritchey ;                                                     

grant SELECT on PAP_CLASS_CHANGES to lritchey ;                                                     
grant UPDATE on PAP_CLASS_CHANGES to lritchey ;                                                     
grant REFERENCES on PAP_CLASS_CHANGES to lritchey ;                                                 
grant ALTER on PATHOLOGISTS to lritchey ;                                                           
grant DELETE on PATHOLOGISTS to lritchey ;                                                          
grant INDEX on PATHOLOGISTS to lritchey ;                                                           
grant INSERT on PATHOLOGISTS to lritchey ;                                                          
grant SELECT on PATHOLOGISTS to lritchey ;                                                          
grant UPDATE on PATHOLOGISTS to lritchey ;                                                          
grant REFERENCES on PATHOLOGISTS to lritchey ;                                                      
grant ALTER on PATHOLOGIST_CONTROL to lritchey ;                                                    
grant DELETE on PATHOLOGIST_CONTROL to lritchey ;                                                   
grant INDEX on PATHOLOGIST_CONTROL to lritchey ;                                                    
grant INSERT on PATHOLOGIST_CONTROL to lritchey ;                                                   
grant SELECT on PATHOLOGIST_CONTROL to lritchey ;                                                   
grant UPDATE on PATHOLOGIST_CONTROL to lritchey ;                                                   
grant REFERENCES on PATHOLOGIST_CONTROL to lritchey ;                                               
grant ALTER on PATHOLOGIST_CONTROL_CODES to lritchey ;                                              
grant DELETE on PATHOLOGIST_CONTROL_CODES to lritchey ;                                             
grant INDEX on PATHOLOGIST_CONTROL_CODES to lritchey ;                                              
grant INSERT on PATHOLOGIST_CONTROL_CODES to lritchey ;                                             
grant SELECT on PATHOLOGIST_CONTROL_CODES to lritchey ;                                             
grant UPDATE on PATHOLOGIST_CONTROL_CODES to lritchey ;                                             

grant REFERENCES on PATHOLOGIST_CONTROL_CODES to lritchey ;                                         
grant ALTER on PATHOLOGIST_HOLDS to lritchey ;                                                      
grant DELETE on PATHOLOGIST_HOLDS to lritchey ;                                                     
grant INDEX on PATHOLOGIST_HOLDS to lritchey ;                                                      
grant INSERT on PATHOLOGIST_HOLDS to lritchey ;                                                     
grant SELECT on PATHOLOGIST_HOLDS to lritchey ;                                                     
grant UPDATE on PATHOLOGIST_HOLDS to lritchey ;                                                     
grant REFERENCES on PATHOLOGIST_HOLDS to lritchey ;                                                 
grant ALTER on PATIENTS to lritchey ;                                                               
grant DELETE on PATIENTS to lritchey ;                                                              
grant INDEX on PATIENTS to lritchey ;                                                               
grant INSERT on PATIENTS to lritchey ;                                                              
grant SELECT on PATIENTS to lritchey ;                                                              
grant UPDATE on PATIENTS to lritchey ;                                                              
grant REFERENCES on PATIENTS to lritchey ;                                                          
grant ALTER on PATIENT_ACCOUNTS to lritchey ;                                                       
grant DELETE on PATIENT_ACCOUNTS to lritchey ;                                                      
grant INDEX on PATIENT_ACCOUNTS to lritchey ;                                                       
grant INSERT on PATIENT_ACCOUNTS to lritchey ;                                                      
grant SELECT on PATIENT_ACCOUNTS to lritchey ;                                                      
grant UPDATE on PATIENT_ACCOUNTS to lritchey ;                                                      
grant REFERENCES on PATIENT_ACCOUNTS to lritchey ;                                                  
grant ALTER on PATIENT_ACCOUNTS_IN_COLLECTION to lritchey ;                                         

grant DELETE on PATIENT_ACCOUNTS_IN_COLLECTION to lritchey ;                                        
grant INDEX on PATIENT_ACCOUNTS_IN_COLLECTION to lritchey ;                                         
grant INSERT on PATIENT_ACCOUNTS_IN_COLLECTION to lritchey ;                                        
grant SELECT on PATIENT_ACCOUNTS_IN_COLLECTION to lritchey ;                                        
grant UPDATE on PATIENT_ACCOUNTS_IN_COLLECTION to lritchey ;                                        
grant REFERENCES on PATIENT_ACCOUNTS_IN_COLLECTION to lritchey ;                                    
grant ALTER on PATIENT_CREDITS to lritchey ;                                                        
grant DELETE on PATIENT_CREDITS to lritchey ;                                                       
grant INDEX on PATIENT_CREDITS to lritchey ;                                                        
grant INSERT on PATIENT_CREDITS to lritchey ;                                                       
grant SELECT on PATIENT_CREDITS to lritchey ;                                                       
grant UPDATE on PATIENT_CREDITS to lritchey
/
grant REFERENCES on PATIENT_CREDITS to lritchey 
/
                                                           
grant ALTER on PATIENT_STATEMENTS to lritchey ;                                                     
grant DELETE on PATIENT_STATEMENTS to lritchey ;                                                    
grant INDEX on PATIENT_STATEMENTS to lritchey ;                                                     
grant INSERT on PATIENT_STATEMENTS to lritchey ;                                                    
grant SELECT on PATIENT_STATEMENTS to lritchey ;                                                    
grant UPDATE on PATIENT_STATEMENTS to lritchey ;                                                    
grant REFERENCES on PATIENT_STATEMENTS to lritchey ;                                                
grant ALTER on PATIENT_STATEMENTS_SEQ to lritchey ;                                                 

grant SELECT on PATIENT_STATEMENTS_SEQ to lritchey ;                                                
grant ALTER on PATIENT_STATEMENT_HISTORY to lritchey ;                                              
grant DELETE on PATIENT_STATEMENT_HISTORY to lritchey ;                                             
grant INDEX on PATIENT_STATEMENT_HISTORY to lritchey ;                                              
grant INSERT on PATIENT_STATEMENT_HISTORY to lritchey ;                                             
grant SELECT on PATIENT_STATEMENT_HISTORY to lritchey ;                                             
grant UPDATE on PATIENT_STATEMENT_HISTORY to lritchey ;                                             
grant REFERENCES on PATIENT_STATEMENT_HISTORY to lritchey ;                                         
grant ALTER on PAYER_BATCH_AMOUNTS to lritchey ;                                                    
grant DELETE on PAYER_BATCH_AMOUNTS to lritchey ;                                                   
grant INDEX on PAYER_BATCH_AMOUNTS to lritchey ;                                                    
grant INSERT on PAYER_BATCH_AMOUNTS to lritchey ;                                                   
grant SELECT on PAYER_BATCH_AMOUNTS to lritchey ;                                                   
grant UPDATE on PAYER_BATCH_AMOUNTS to lritchey ;                                                   
grant REFERENCES on PAYER_BATCH_AMOUNTS to lritchey ;                                               
grant ALTER on PAYMENTS to lritchey ;                                                               
grant DELETE on PAYMENTS to lritchey ;                                                              
grant INDEX on PAYMENTS to lritchey ;                                                               
grant INSERT on PAYMENTS to lritchey ;                                                              
grant SELECT on PAYMENTS to lritchey ;                                                              
grant UPDATE on PAYMENTS to lritchey ;                                                              
grant REFERENCES on PAYMENTS to lritchey ;                                                          
grant ALTER on PAYMENTS_SEQ to lritchey ;                                                           

grant SELECT on PAYMENTS_SEQ to lritchey ;                                                          
grant ALTER on PAYMENT_ADJUST_REASONS to lritchey ;                                                 
grant DELETE on PAYMENT_ADJUST_REASONS to lritchey ;                                                
grant INDEX on PAYMENT_ADJUST_REASONS to lritchey ;                                                 
grant INSERT on PAYMENT_ADJUST_REASONS to lritchey ;                                                
grant SELECT on PAYMENT_ADJUST_REASONS to lritchey ;                                                
grant UPDATE on PAYMENT_ADJUST_REASONS to lritchey ;                                                
grant REFERENCES on PAYMENT_ADJUST_REASONS to lritchey ;                                            
grant ALTER on PAYMENT_REVERSALS to lritchey ;                                                      
grant DELETE on PAYMENT_REVERSALS to lritchey ;                                                     
grant INDEX on PAYMENT_REVERSALS to lritchey ;                                                      
grant INSERT on PAYMENT_REVERSALS to lritchey ;                                                     
grant SELECT on PAYMENT_REVERSALS to lritchey ;                                                     
grant UPDATE on PAYMENT_REVERSALS to lritchey ;                                                     
grant REFERENCES on PAYMENT_REVERSALS to lritchey ;                                                 
grant ALTER on PAYMENT_TYPES to lritchey ;                                                          
grant DELETE on PAYMENT_TYPES to lritchey ;                                                         
grant INDEX on PAYMENT_TYPES to lritchey ;                                                          
grant INSERT on PAYMENT_TYPES to lritchey ;                                                         
grant SELECT on PAYMENT_TYPES to lritchey ;                                                         
grant UPDATE on PAYMENT_TYPES to lritchey ;                                                         
grant REFERENCES on PAYMENT_TYPES to lritchey ;                                                     
grant ALTER on PCARD_QUEUE to lritchey ;                                                            

grant DELETE on PCARD_QUEUE to lritchey ;                                                           
grant INDEX on PCARD_QUEUE to lritchey ;                                                            
grant INSERT on PCARD_QUEUE to lritchey ;                                                           
grant SELECT on PCARD_QUEUE to lritchey ;                                                           
grant UPDATE on PCARD_QUEUE to lritchey ;                                                           
grant REFERENCES on PCARD_QUEUE to lritchey ;                                                       
grant ALTER on PCS_PAYER_SEQ to lritchey ;                                                          
grant SELECT on PCS_PAYER_SEQ to lritchey ;                                                         
grant ALTER on PENDING_CARRIERS to lritchey ;                                                       
grant DELETE on PENDING_CARRIERS to lritchey ;                                                      
grant INDEX on PENDING_CARRIERS to lritchey ;                                                       
grant INSERT on PENDING_CARRIERS to lritchey ;                                                      
grant SELECT on PENDING_CARRIERS to lritchey ;                                                      
grant UPDATE on PENDING_CARRIERS to lritchey ;                                                      
grant REFERENCES on PENDING_CARRIERS to lritchey ;                                                  
grant ALTER on PRACTICES to lritchey ;                                                              
grant DELETE on PRACTICES to lritchey ;                                                             
grant INDEX on PRACTICES to lritchey ;                                                              
grant INSERT on PRACTICES to lritchey ;                                                             
grant SELECT on PRACTICES to lritchey ;                                                             
grant UPDATE on PRACTICES to lritchey ;                                                             
grant REFERENCES on PRACTICES to lritchey ;                                                         
grant EXECUTE on PRACTICES_ADD to lritchey ;                                                        

grant ALTER on PRACTICES_SEQ to lritchey ;                                                          
grant SELECT on PRACTICES_SEQ to lritchey ;                                                         
grant ALTER on PRACTICE_ACCOUNTS to lritchey ;                                                      
grant DELETE on PRACTICE_ACCOUNTS to lritchey ;                                                     
grant INDEX on PRACTICE_ACCOUNTS to lritchey ;                                                      
grant INSERT on PRACTICE_ACCOUNTS to lritchey ;                                                     
grant SELECT on PRACTICE_ACCOUNTS to lritchey ;                                                     
grant UPDATE on PRACTICE_ACCOUNTS to lritchey ;                                                     
grant REFERENCES on PRACTICE_ACCOUNTS to lritchey ;                                                 
grant ALTER on PRACTICE_ACCOUNTS_HISTORY to lritchey ;                                              
grant DELETE on PRACTICE_ACCOUNTS_HISTORY to lritchey ;                                             
grant INDEX on PRACTICE_ACCOUNTS_HISTORY to lritchey ;                                              
grant INSERT on PRACTICE_ACCOUNTS_HISTORY to lritchey ;                                             
grant SELECT on PRACTICE_ACCOUNTS_HISTORY to lritchey ;                                             
grant UPDATE on PRACTICE_ACCOUNTS_HISTORY to lritchey ;                                             
grant REFERENCES on PRACTICE_ACCOUNTS_HISTORY to lritchey ;                                         
grant ALTER on PRACTICE_ACCOUNTS_SAVE to lritchey ;                                                 
grant DELETE on PRACTICE_ACCOUNTS_SAVE to lritchey ;                                                
grant INDEX on PRACTICE_ACCOUNTS_SAVE to lritchey ;                                                 
grant INSERT on PRACTICE_ACCOUNTS_SAVE to lritchey ;                                                
grant SELECT on PRACTICE_ACCOUNTS_SAVE to lritchey ;                                                
grant UPDATE on PRACTICE_ACCOUNTS_SAVE to lritchey ;                                                
grant REFERENCES on PRACTICE_ACCOUNTS_SAVE to lritchey ;                                            

grant ALTER on PRACTICE_COMMENTS to lritchey ;                                                      
grant DELETE on PRACTICE_COMMENTS to lritchey ;                                                     
grant INDEX on PRACTICE_COMMENTS to lritchey ;                                                      
grant INSERT on PRACTICE_COMMENTS to lritchey ;                                                     
grant SELECT on PRACTICE_COMMENTS to lritchey ;                                                     
grant UPDATE on PRACTICE_COMMENTS to lritchey ;                                                     
grant REFERENCES on PRACTICE_COMMENTS to lritchey ;                                                 
grant ALTER on PRACTICE_SEQ to lritchey ;                                                           
grant SELECT on PRACTICE_SEQ to lritchey ;                                                          
grant ALTER on PRACTICE_STATEMENTS to lritchey ;                                                    
grant DELETE on PRACTICE_STATEMENTS to lritchey ;                                                   
grant INDEX on PRACTICE_STATEMENTS to lritchey ;                                                    
grant INSERT on PRACTICE_STATEMENTS to lritchey ;                                                   
grant SELECT on PRACTICE_STATEMENTS to lritchey ;                                                   
grant UPDATE on PRACTICE_STATEMENTS to lritchey ;                                                   
grant REFERENCES on PRACTICE_STATEMENTS to lritchey ;                                               
grant ALTER on PRACTICE_STATEMENTS_SEQ to lritchey ;                                                
grant SELECT on PRACTICE_STATEMENTS_SEQ to lritchey ;                                               
grant ALTER on PRACTICE_STATEMENT_LABS to lritchey ;                                                
grant DELETE on PRACTICE_STATEMENT_LABS to lritchey ;                                               
grant INDEX on PRACTICE_STATEMENT_LABS to lritchey ;                                                
grant INSERT on PRACTICE_STATEMENT_LABS to lritchey ;                                               
grant SELECT on PRACTICE_STATEMENT_LABS to lritchey ;                                               

grant UPDATE on PRACTICE_STATEMENT_LABS to lritchey ;                                               
grant REFERENCES on PRACTICE_STATEMENT_LABS to lritchey ;                                           
grant ALTER on PREPAID_LABS to lritchey ;                                                           
grant DELETE on PREPAID_LABS to lritchey ;                                                          
grant INDEX on PREPAID_LABS to lritchey ;                                                           
grant INSERT on PREPAID_LABS to lritchey ;                                                          
grant SELECT on PREPAID_LABS to lritchey ;                                                          
grant UPDATE on PREPAID_LABS to lritchey ;                                                          
grant REFERENCES on PREPAID_LABS to lritchey ;                                                      
grant ALTER on PRICE_CODES to lritchey ;                                                            
grant DELETE on PRICE_CODES to lritchey ;                                                           
grant INDEX on PRICE_CODES to lritchey ;                                                            
grant INSERT on PRICE_CODES to lritchey ;                                                           
grant SELECT on PRICE_CODES to lritchey ;                                                           
grant UPDATE on PRICE_CODES to lritchey ;                                                           
grant REFERENCES on PRICE_CODES to lritchey ;                                                       
grant ALTER on PRICE_CODE_DETAILS to lritchey ;                                                     
grant DELETE on PRICE_CODE_DETAILS to lritchey ;                                                    
grant INDEX on PRICE_CODE_DETAILS to lritchey ;                                                     
grant INSERT on PRICE_CODE_DETAILS to lritchey ;                                                    
grant SELECT on PRICE_CODE_DETAILS to lritchey ;                                                    
grant UPDATE on PRICE_CODE_DETAILS to lritchey ;                                                    
grant REFERENCES on PRICE_CODE_DETAILS to lritchey ;                                                

grant ALTER on PROCEDURE_CODES to lritchey ;                                                        
grant DELETE on PROCEDURE_CODES to lritchey ;                                                       
grant INDEX on PROCEDURE_CODES to lritchey ;                                                        
grant INSERT on PROCEDURE_CODES to lritchey ;                                                       
grant SELECT on PROCEDURE_CODES to lritchey ;                                                       
grant UPDATE on PROCEDURE_CODES to lritchey ;                                                       
grant REFERENCES on PROCEDURE_CODES to lritchey ;                                                   
grant ALTER on PROCEDURE_CODE_LIMITS to lritchey ;                                                  
grant DELETE on PROCEDURE_CODE_LIMITS to lritchey ;                                                 
grant INDEX on PROCEDURE_CODE_LIMITS to lritchey ;                                                  
grant INSERT on PROCEDURE_CODE_LIMITS to lritchey ;                                                 
grant SELECT on PROCEDURE_CODE_LIMITS to lritchey ;                                                 
grant UPDATE on PROCEDURE_CODE_LIMITS to lritchey ;                                                 
grant REFERENCES on PROCEDURE_CODE_LIMITS to lritchey ;                                             
grant ALTER on PURGE_HISTORY to lritchey ;                                                          
grant DELETE on PURGE_HISTORY to lritchey ;                                                         
grant INDEX on PURGE_HISTORY to lritchey ;                                                          
grant INSERT on PURGE_HISTORY to lritchey ;                                                         
grant SELECT on PURGE_HISTORY to lritchey ;                                                         
grant UPDATE on PURGE_HISTORY to lritchey ;                                                         
grant REFERENCES on PURGE_HISTORY to lritchey ;                                                     
grant ALTER on PURGE_HISTORY_COPY to lritchey ;                                                     
grant DELETE on PURGE_HISTORY_COPY to lritchey ;                                                    

grant INDEX on PURGE_HISTORY_COPY to lritchey ;                                                     
grant INSERT on PURGE_HISTORY_COPY to lritchey ;                                                    
grant SELECT on PURGE_HISTORY_COPY to lritchey ;                                                    
grant UPDATE on PURGE_HISTORY_COPY to lritchey ;                                                    
grant REFERENCES on PURGE_HISTORY_COPY to lritchey ;                                                
grant ALTER on QC_SEQ to lritchey ;                                                                 
grant SELECT on QC_SEQ to lritchey ;                                                                
grant ALTER on QUALITY_CONTROL to lritchey ;                                                        
grant DELETE on QUALITY_CONTROL to lritchey ;                                                       
grant INDEX on QUALITY_CONTROL to lritchey ;                                                        
grant INSERT on QUALITY_CONTROL to lritchey ;                                                       
grant SELECT on QUALITY_CONTROL to lritchey ;                                                       
grant UPDATE on QUALITY_CONTROL to lritchey ;                                                       
grant REFERENCES on QUALITY_CONTROL to lritchey ;                                                   
grant ALTER on QUALITY_CONTROL_CODES to lritchey ;                                                  
grant DELETE on QUALITY_CONTROL_CODES to lritchey ;                                                 
grant INDEX on QUALITY_CONTROL_CODES to lritchey ;                                                  
grant INSERT on QUALITY_CONTROL_CODES to lritchey ;                                                 
grant SELECT on QUALITY_CONTROL_CODES to lritchey ;                                                 
grant UPDATE on QUALITY_CONTROL_CODES to lritchey ;                                                 
grant REFERENCES on QUALITY_CONTROL_CODES to lritchey ;                                             
grant ALTER on RACE_CATEGORIES to lritchey ;                                                        
grant DELETE on RACE_CATEGORIES to lritchey ;                                                       

grant INDEX on RACE_CATEGORIES to lritchey ;                                                        
grant INSERT on RACE_CATEGORIES to lritchey ;                                                       
grant SELECT on RACE_CATEGORIES to lritchey ;                                                       
grant UPDATE on RACE_CATEGORIES to lritchey ;                                                       
grant REFERENCES on RACE_CATEGORIES to lritchey ;                                                   
grant ALTER on REBILL_CODES to lritchey ;                                                           
grant DELETE on REBILL_CODES to lritchey ;                                                          
grant INDEX on REBILL_CODES to lritchey ;                                                           
grant INSERT on REBILL_CODES to lritchey ;                                                          
grant SELECT on REBILL_CODES to lritchey ;                                                          
grant UPDATE on REBILL_CODES to lritchey ;                                                          
grant REFERENCES on REBILL_CODES to lritchey ;                                                      
grant ALTER on RECEIVE_DATES to lritchey ;                                                          
grant DELETE on RECEIVE_DATES to lritchey ;                                                         
grant INDEX on RECEIVE_DATES to lritchey ;                                                          
grant INSERT on RECEIVE_DATES to lritchey ;                                                         
grant SELECT on RECEIVE_DATES to lritchey ;                                                         
grant UPDATE on RECEIVE_DATES to lritchey ;                                                         
grant REFERENCES on RECEIVE_DATES to lritchey ;                                                     

grant ALTER on RESPONSE_FILES to lritchey ;                                                         
grant DELETE on RESPONSE_FILES to lritchey ;                                                        

grant INDEX on RESPONSE_FILES to lritchey ;                                                         
grant INSERT on RESPONSE_FILES to lritchey ;                                                        
grant SELECT on RESPONSE_FILES to lritchey ;                                                        
grant UPDATE on RESPONSE_FILES to lritchey ;                                                        
grant REFERENCES on RESPONSE_FILES to lritchey ;                                                    
grant ALTER on SCREENING_STATS_WORK to lritchey ;                                                   
grant DELETE on SCREENING_STATS_WORK to lritchey ;                                                  
grant INDEX on SCREENING_STATS_WORK to lritchey ;                                                   
grant INSERT on SCREENING_STATS_WORK to lritchey ;                                                  
grant SELECT on SCREENING_STATS_WORK to lritchey ;                                                  
grant UPDATE on SCREENING_STATS_WORK to lritchey ;                                                  
grant REFERENCES on SCREENING_STATS_WORK to lritchey ;                                              
grant ALTER on SECURITY_SEQ to lritchey ;                                                           
grant SELECT on SECURITY_SEQ to lritchey ;                                                          
grant DELETE on SMP_BLOB to lritchey ;                                                              
grant INSERT on SMP_BLOB to lritchey ;                                                              
grant SELECT on SMP_BLOB to lritchey ;                                                              
grant UPDATE on SMP_BLOB to lritchey ;                                                              
grant SELECT on SMP_LONG_ID to lritchey ;                                                           
grant DELETE on SMP_LONG_TEXT to lritchey ;                                                         
grant INSERT on SMP_LONG_TEXT to lritchey ;                                                         
grant SELECT on SMP_LONG_TEXT to lritchey ;                                                         
grant UPDATE on SMP_LONG_TEXT to lritchey ;                                                         

grant ALTER on SPECIAL_CHARGES to lritchey ;                                                        
grant DELETE on SPECIAL_CHARGES to lritchey ;                                                       
grant INDEX on SPECIAL_CHARGES to lritchey ;                                                        
grant INSERT on SPECIAL_CHARGES to lritchey ;                                                       
grant SELECT on SPECIAL_CHARGES to lritchey ;                                                       
grant UPDATE on SPECIAL_CHARGES to lritchey ;                                                       
grant REFERENCES on SPECIAL_CHARGES to lritchey ;                                                   
grant ALTER on SUMMARY_QUEUE to lritchey ;                                                          
grant DELETE on SUMMARY_QUEUE to lritchey ;                                                         
grant INDEX on SUMMARY_QUEUE to lritchey ;                                                          
grant INSERT on SUMMARY_QUEUE to lritchey ;                                                         
grant SELECT on SUMMARY_QUEUE to lritchey ;                                                         
grant UPDATE on SUMMARY_QUEUE to lritchey ;                                                         
grant REFERENCES on SUMMARY_QUEUE to lritchey ;                                                     
grant ALTER on TECH_SEQ to lritchey ;                                                               
grant SELECT on TECH_SEQ to lritchey ;                                                              
grant ALTER on TEMP_TABLE to lritchey ;                                                             
grant DELETE on TEMP_TABLE to lritchey ;                                                            
grant INDEX on TEMP_TABLE to lritchey ;                                                             
grant INSERT on TEMP_TABLE to lritchey ;                                                            
grant SELECT on TEMP_TABLE to lritchey ;                                                            
grant UPDATE on TEMP_TABLE to lritchey ;                                                            
grant REFERENCES on TEMP_TABLE to lritchey ;                                                        

grant ALTER on TISSUE_CODES to lritchey ;                                                           
grant DELETE on TISSUE_CODES to lritchey ;                                                          
grant INDEX on TISSUE_CODES to lritchey ;                                                           
grant INSERT on TISSUE_CODES to lritchey ;                                                          
grant SELECT on TISSUE_CODES to lritchey ;                                                          
grant UPDATE on TISSUE_CODES to lritchey ;                                                          
grant REFERENCES on TISSUE_CODES to lritchey ;                                                      
grant ALTER on TISSUE_RESULTS to lritchey ;                                                         
grant DELETE on TISSUE_RESULTS to lritchey ;                                                        
grant INDEX on TISSUE_RESULTS to lritchey ;                                                         
grant INSERT on TISSUE_RESULTS to lritchey ;                                                        
grant SELECT on TISSUE_RESULTS to lritchey ;                                                        
grant UPDATE on TISSUE_RESULTS to lritchey ;                                                        
grant REFERENCES on TISSUE_RESULTS to lritchey ;                                                    
grant ALTER on TPPS to lritchey ;                                                                   
grant DELETE on TPPS to lritchey ;                                                                  
grant INDEX on TPPS to lritchey ;                                                                   
grant INSERT on TPPS to lritchey ;                                                                  
grant SELECT on TPPS to lritchey ;                                                                  
grant UPDATE on TPPS to lritchey ;                                                                  
grant REFERENCES on TPPS to lritchey ;                                                              
grant ALTER on TRANSET_ID_SEQ to lritchey ;                                                         
grant SELECT on TRANSET_ID_SEQ to lritchey ;                                                        

grant ALTER on TRASH to lritchey ;                                                                  
grant DELETE on TRASH to lritchey ;                                                                 
grant INDEX on TRASH to lritchey ;                                                                  
grant INSERT on TRASH to lritchey ;                                                                 
grant SELECT on TRASH to lritchey ;                                                                 
grant UPDATE on TRASH to lritchey ;                                                                 
grant REFERENCES on TRASH to lritchey ;                                                             
grant ALTER on USER_LOG to lritchey ;                                                               
grant DELETE on USER_LOG to lritchey ;                                                              
grant INDEX on USER_LOG to lritchey ;                                                               
grant INSERT on USER_LOG to lritchey ;                                                              
grant SELECT on USER_LOG to lritchey ;                                                              
grant UPDATE on USER_LOG to lritchey ;                                                              
grant REFERENCES on USER_LOG to lritchey ;                                                          
grant SELECT on USER_RESTRICTIONS to lritchey ;                                                     
grant ALTER on USER_RESTRICTIONS to lritchey ;                                                      
grant DELETE on USER_RESTRICTIONS to lritchey ;                                                     
grant INDEX on USER_RESTRICTIONS to lritchey ;                                                      
grant INSERT on USER_RESTRICTIONS to lritchey ;                                                     
grant SELECT on USER_RESTRICTIONS to lritchey ;                                                     
grant UPDATE on USER_RESTRICTIONS to lritchey ;                                                     
grant REFERENCES on USER_RESTRICTIONS to lritchey ;                                                 
grant ALTER on X12_ACK_CODES to lritchey ;                                                          

grant DELETE on X12_ACK_CODES to lritchey ;                                                         
grant INDEX on X12_ACK_CODES to lritchey ;                                                          
grant INSERT on X12_ACK_CODES to lritchey ;                                                         
grant SELECT on X12_ACK_CODES to lritchey ;                                                         
grant UPDATE on X12_ACK_CODES to lritchey ;                                                         
grant REFERENCES on X12_ACK_CODES to lritchey ;                                                     
grant ALTER on X12_DATA_ERRORS to lritchey ;                                                        
grant DELETE on X12_DATA_ERRORS to lritchey ;                                                       
grant INDEX on X12_DATA_ERRORS to lritchey ;                                                        
grant INSERT on X12_DATA_ERRORS to lritchey ;                                                       
grant SELECT on X12_DATA_ERRORS to lritchey ;                                                       
grant UPDATE on X12_DATA_ERRORS to lritchey ;                                                       
grant REFERENCES on X12_DATA_ERRORS to lritchey ;                                                   
grant ALTER on X12_FGROUP_SYNTAX_ERRORS to lritchey ;                                               
grant DELETE on X12_FGROUP_SYNTAX_ERRORS to lritchey ;                                              
grant INDEX on X12_FGROUP_SYNTAX_ERRORS to lritchey ;                                               
grant INSERT on X12_FGROUP_SYNTAX_ERRORS to lritchey ;                                              
grant SELECT on X12_FGROUP_SYNTAX_ERRORS to lritchey ;                                              
grant UPDATE on X12_FGROUP_SYNTAX_ERRORS to lritchey ;                                              
grant REFERENCES on X12_FGROUP_SYNTAX_ERRORS to lritchey ;                                          
grant ALTER on X12_INTERCHANGE_CODES to lritchey ;                                                  
grant DELETE on X12_INTERCHANGE_CODES to lritchey ;   


create or replace directory REPORTS_DIR as '/u01/reports'
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

grant ALTER on PATIENT_SEQ to lritchey ;
grant SELECT on PATIENT_SEQ to lritchey ;

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
grant ALTER on req_seq to lritchey ;
grant SELECT on req_seq to lritchey ;


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
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(detail_id)+1 into maxvalue from pcs.lab_req_details_additional ; 
	dbms_output.put_line('=========== Creating sequence lab_req_detail_seq');
	execute immediate 'create sequence lab_req_detail_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

grant ALTER on lab_req_detail_seq to lritchey ; 
grant SELECT on lab_req_detail_seq to lritchey  ;




