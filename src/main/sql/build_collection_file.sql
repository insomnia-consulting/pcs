create or replace procedure     build_collection_file
(
   sent_mode in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   PENDING constant number := -2;
   DEQUEUE constant number := -1;

   QUEUE constant number := 0;
   PRIOR_BATCH constant number := 1;
   NOTIFY constant number := 2;
   NOTIFIED constant number := 3;

   P_name varchar2(24);
   P_address  varchar2(48);
   P_amt_due varchar2(12);
   P_completed varchar2(12);
   P_phone varchar2(12);
   P_comments varchar2(128);

   R_sent_mode number;

   cursor collection_list is
      select * from pcs.patient_accounts_in_collection
	where sent=R_sent_mode order by lab_number
   for update;
   collection_fields collection_list%ROWTYPE;

   file_handle UTL_FILE.FILE_TYPE;
   file_name varchar2(16);

   rcnt number;
   has_comments number;
   comment_flag varchar2(8);
   curr_line varchar2(256);

   hdr_1 varchar2(128);
   hdr_2 varchar2(128);
   hdr_3 varchar2(256);
   hdr_4 varchar2(256);
   rept_title varchar2(128);
   line_cntr number;
   page_nmbr number;
   R_batch_number number;

begin

   P_proc_name:='BUILD_COLLECTION_FILE';
   P_code_area:='PREP';


   if (sent_mode=PENDING) then
      rept_title:='   ACCOUNTS QUEUED FOR COLLECTIONS REPORT:  ';
      file_name:='PENDING.col';
   elsif (sent_mode=DEQUEUE) then
      rept_title:='   ACCOUNTS DEQUEUED FOR COLLECTIONS REPORT:  ';
      file_name:='DEQUEUE.col';
   elsif (sent_mode=QUEUE) then
      select pcs.collections_seq.nextval into R_batch_number from dual;
      file_name:=RTRIM(LTRIM(TO_CHAR(R_batch_number,'000009')))||'.col';
      rept_title:='   SENT FOR COLLECTION SUMMARY REPORT [BATCH #'||
	 RTRIM(LTRIM(TO_CHAR(R_batch_number,'000009')))||']:  ';
   elsif (sent_mode=NOTIFY) then

      rept_title:='   ACCOUNTS TO BE REMOVED FROM COLLECTION:  ';
      hdr_4:='	 PLEASE REMOVE THE ACCOUNTS LISTED FROM OUR'||
	     ' COLLECTIONS LIST - THANK YOU';
      file_name:='NOTIFY.col';
   elsif (sent_mode=NOTIFIED) then
      rept_title:='   TAKEN OUT OF COLLECTION:	';
      file_name:='NOTIFIED.col';
   end if;
	dbms_output.put_line('File name is '||file_name);
   file_handle:=UTL_FILE.FOPEN('REPORTS_DIR',file_name,'w');
   line_cntr:=0;
   page_nmbr:=1;


   hdr_1:='   PENNSYLVANIA CYTOLOGY SERVICES';
   select rept_title||TO_CHAR(SysDate,'MM/DD/YYYY') into hdr_2 from dual;
   if (sent_mode=NOTIFY) then
      hdr_3:='	 '||RPAD('ACCOUNT#',11)||RPAD('PATIENT NAME',24)||' '||
	 RPAD('PATIENT ADDRESS',48)||' '||
	 LPAD('CHARGE',8)||'  '||'COMMENTS';
   else
      hdr_3:='	 '||RPAD('ACCOUNT#',11)||RPAD('PATIENT NAME',24)||' '||
	 RPAD('PATIENT ADDRESS',48)||' '||
	 LPAD('CHARGE',8)||'  '||RPAD('COMPLETED',12)||RPAD('PHONE',12);
   end if;

   if (sent_mode<>QUEUE and sent_mode<>NOTIFY) then

      hdr_3:=hdr_3||'COMMENTS';
   end if;

   if (sent_mode=PENDING) then R_sent_mode:=0;
   else R_sent_mode:=sent_mode;
   end if;

   open collection_list;
   loop
      P_code_area:='FETCH';
      fetch collection_list into collection_fields;
      exit when collection_list%NOTFOUND;
      select count(*) into has_comments from pcs.lab_req_comments

      where lab_number=collection_fields.lab_number;
      if (line_cntr=0 or line_cntr>60) then
	 if (line_cntr<>0) then
	    UTL_FILE.PUTF(file_handle,'%s',CHR(12));
	    page_nmbr:=page_nmbr+1;
	    line_cntr:=0;
	 else
	    UTL_FILE.PUTF(file_handle,'%s',CHR(27)||CHR(15));

	 end if;
	 UTL_FILE.NEW_LINE(file_handle);
	 line_cntr:=line_cntr+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',hdr_1);

	 line_cntr:=line_cntr+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',hdr_2);
	 line_cntr:=line_cntr+1;
	 UTL_FILE.PUTF(file_handle,'%s\n','   PAGE: '||TO_CHAR(page_nmbr));
	 line_cntr:=line_cntr+1;
	 if (sent_mode=NOTIFY) then
	    UTL_FILE.PUTF(file_handle,'\n%s\n',hdr_4);
	    line_cntr:=line_cntr+2;
	 end if;
	 UTL_FILE.NEW_LINE(file_handle);
	 line_cntr:=line_cntr+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',hdr_3);
	 line_cntr:=line_cntr+1;

	 UTL_FILE.NEW_LINE(file_handle);
	 line_cntr:=line_cntr+1;
      end if;
      select SUBSTR(lname||', '||fname||' '||mi,1,24),
	 SUBSTR(address1||', '||city||' '||state||' '||
	 SUBSTR(zip,1,5),1,48),phone
      into P_name,P_address,P_phone
      from pcs.patients a, pcs.lab_requisitions b
      where a.patient=b.patient and b.lab_number=collection_fields.lab_number;
      if (P_address is NULL) then P_address:=' ';
      end if;
      if (P_phone is NULL) then P_phone:=' ';
      end if;

      P_comments:=NULL;
      if (has_comments>0) then
	 select SUBSTR(comment_text,1,106) into P_comments from pcs.lab_req_comments
	 where lab_number=collection_fields.lab_number;
	 P_comments:=REPLACE(P_comments,CHR(10));
      end if;
      P_amt_due:=TO_CHAR(collection_fields.outstanding_balance,'990.00');
      select TO_CHAR(date_completed,'MM/DD/YYYY') into P_completed
      from pcs.lab_results where lab_number=collection_fields.lab_number;
      if (has_comments>0) then
	 comment_flag:='  *';
      else
	 comment_flag:='   ';

      end if;
      if (sent_mode=NOTIFY) then
	 curr_line:=comment_flag||TO_CHAR(collection_fields.lab_number)||
	    ' '||RPAD(P_name,24)||
	    ' '||RPAD(P_address,48)||' '||LPAD(P_amt_due,8)||
	    '__________________________';
      else
	 curr_line:=comment_flag||TO_CHAR(collection_fields.lab_number)||
	    ' '||RPAD(P_name,24)||
	    ' '||RPAD(P_address,48)||' '||LPAD(P_amt_due,8)||'	'||RPAD(P_completed,12)||
	    RPAD(P_phone,12);
      end if;
      if (sent_mode=QUEUE) then

	 update pcs.patient_accounts_in_collection set
	    sent=PRIOR_BATCH,change_date=SysDate,batch_number=R_batch_number
	 where current of collection_list;
      elsif (sent_mode<>NOTIFY) then
	 curr_line:=curr_line||P_comments;
      end if;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      if (sent_mode=NOTIFY) then
	 UTL_FILE.NEW_LINE(file_handle);
      end if;
      line_cntr:=line_cntr+1;
   end loop;
   close collection_list;
	commit;

   if (sent_mode=QUEUE) then
      update pcs.patient_accounts_in_collection
      set sent=QUEUE,change_date=SysDate where sent=DEQUEUE;
   end if;

   UTL_FILE.PUT(file_handle,CHR(12));
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
      insert into pcs.error_log
	 (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,
	 P_code_area,SysDate,UID,collection_fields.lab_number);
      commit;
      RAISE;


end;
\

grant execute on build_collection_file to pcs_user
\