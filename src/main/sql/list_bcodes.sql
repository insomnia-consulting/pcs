
procedure     list_bcodes                                                                                                                                                           
as                                                                                                                                                                                  
                                                                                                                                                                                    
   cursor b_codes is                                                                                                                                                                
      select                                                                                                                                                                        
         bethesda_code,                                                                                                                                                             
         LTRIM(RTRIM(a.description)),                                                                                                                                               
         LTRIM(RTRIM(b.description))                                                                                                                                                
      from bethesda_codes a, pap_classes b                                                                                                                                          
      where a.papclass=b.pap_class                                                                                                                                                  
      and a.active_status='A'                                                                                                                                                       
      order by bethesda_code;                                                                                                                                                       
                                                                                                                                                                                    

   b_code varchar2(4);                                                                                                                                                              
   b_code_desc varchar2(4000);                                                                                                                                                      
   p_class_desc varchar2(4000);                                                                                                                                                     
   cbuf varchar2(4000);                                                                                                                                                             
                                                                                                                                                                                    
   file_name varchar2(64);                                                                                                                                                          
   dir_name varchar2(64);                                                                                                                                                           
                                                                                                                                                                                    
   file_handle UTL_FILE.FILE_TYPE;                                                                                                                                                  
                                                                                                                                                                                    
begin                                                                                                                                                                               
                                                                                                                                                                                    
      file_name:='bcode.csv';                                                                                                                                                       

      dir_name:='vol1:';                                                                                                                                                            
      file_handle:=UTL_FILE.FOPEN(dir_name,file_name,'w');                                                                                                                          
                                                                                                                                                                                    
      cbuf:='BETHESDA_CODE,DESCRIPTION,CATEGORY';                                                                                                                                   
      UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                       
      open b_codes;                                                                                                                                                                 
      loop                                                                                                                                                                          
         fetch b_codes into b_code,b_code_desc,p_class_desc;                                                                                                                        
         exit when b_codes%NOTFOUND;                                                                                                                                                
         cbuf:='"'||LTRIM(RTRIM(b_code))||'","'||b_code_desc||'","'||p_class_desc||'"';                                                                                             
         UTL_FILE.PUTF(file_handle,'%s\n',cbuf);                                                                                                                                    
      end loop;                                                                                                                                                                     
      close b_codes;                                                                                                                                                                

                                                                                                                                                                                    
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
      RAISE_APPLICATION_ERROR(-20054,'invalid operation ');                                                                                                                         
   when UTL_FILE.READ_ERROR then                                                                                                                                                    
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20055,'read error');                                                                                                                                 
   when UTL_FILE.WRITE_ERROR then                                                                                                                                                   
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20056,'write error');                                                                                                                                
   when NO_DATA_FOUND then                                                                                                                                                          
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20057,'no data found ');                                                                                                                             
   when VALUE_ERROR then                                                                                                                                                            

      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
      RAISE_APPLICATION_ERROR(-20058,'value error ');                                                                                                                               
   when OTHERS then                                                                                                                                                                 
      UTL_FILE.FCLOSE(file_handle);                                                                                                                                                 
                                                                                                                                                                                    
end;                                                                                                                                         