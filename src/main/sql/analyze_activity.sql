create or replace procedure     analyze_activity
(
   start_lab_number in number,
   end_lab_number in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   B_rebilling number;

   P_name varchar2(48);
   P_account varchar2(24);
   L_finished number;
   L_finished_descr varchar2(32);
   L_pclass number;
   B_choice number;
   C_code varchar2(8);
   C_carrier number;
   C_name varchar2(128);
   C_id number;
   B_amount varchar2(16);
   P_amount varchar2(16);
   P_due varchar2(32);

   B_lab varchar2(16);
   B_allow varchar2(32);
   P_stmt number;
   F_name varchar2(32);
   C_status varchar2(8);

   P_date varchar2(16);
   P_type varchar2(16);

   rcnt number;
   d_flag number;
   curr_line varchar2(128);
   heading varchar2(128);

   r_info varchar2(128);
   title varchar2(128);
   ttl_payments number;
   ttl_plus number;
   ttl_minus number;
   ttl_due number;

   line_cntr number;
   page_num number;

   cursor lab_list is select * from pcs.lab_requisitions
   where lab_number>=start_lab_number and lab_number<=end_lab_number
   order by lab_number;

   lab_fields lab_list%ROWTYPE;

   file_handle UTL_FILE.FILE_TYPE;

begin

   P_proc_name:='ANALYZE_ACTIVITY';
   P_code_area:='PREP';

   F_name:=SUBSTR(RTRIM(LTRIM(TO_CHAR(start_lab_number))),3)||'.bsr';

   file_handle:=UTL_FILE.FOPEN('REPORTS_DIR',F_name,'w');
   line_cntr:=2;

   page_num:=1;

   title:='PA CYTOLOGY LAB STATUS REPORT				    PAGE ';
   r_info:='CREATED ON: '||TO_CHAR(SysDate,'MM/DD/YYYY HH:Mi')||
      ' 		     '||
      TO_CHAR(start_lab_number)||' TO '||TO_CHAR(end_lab_number);
   heading:='LAB #	 ACCT PATIENT		       CODE FINAL   AMOUNT	   PAID';

   UTL_FILE.NEW_LINE(file_handle);
   UTL_FILE.PUTF(file_handle,'%s\n',title||TO_CHAR(page_num,'999'));
   line_cntr:=line_cntr+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',r_info);
   line_cntr:=line_cntr+2;

   UTL_FILE.PUTF(file_handle,'%s\n\n',heading);
   line_cntr:=line_cntr+1;
   curr_line:=
      '--------------------------------------------------------------------------';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   line_cntr:=line_cntr+1;
   open lab_list;
   loop
      P_code_area:='FETCH';
      fetch lab_list into lab_fields;
      exit when lab_list%NOTFOUND;
      P_code_area:='FORMAT';
      if (line_cntr>=62) then

	 page_num:=page_num+1;
	 UTL_FILE.PUT(file_handle,CHR(12));
	 UTL_FILE.NEW_LINE(file_handle,2);
	 line_cntr:=2;
	 UTL_FILE.PUTF(file_handle,'%s\n',title||TO_CHAR(page_num,'999'));
	 line_cntr:=line_cntr+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',r_info);
	 line_cntr:=line_cntr+2;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading);
	 line_cntr:=line_cntr+1;
	 curr_line:=
	    '--------------------------------------------------------------------------';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

	 line_cntr:=line_cntr+1;
      end if;
      select RPAD(SUBSTR(lname||', '||fname,1,24),26) into P_name
      from pcs.patients where patient=lab_fields.patient;
      select count(*) into rcnt from pcs.lab_billings
      where lab_number=lab_fields.lab_number;
      if (rcnt=0) then
	 select '      ' into B_amount from dual;
	 B_choice:=lab_fields.billing_choice;
      else
	 select TO_CHAR(bill_amount,'990.00'),billing_choice
	 into B_amount,B_choice from pcs.lab_billings
	 where lab_number=lab_fields.lab_number;

      end if;
      select choice_code into C_code from pcs.billing_choices
      where billing_choice=B_choice;
      if (C_code='DOC') then
	 L_finished_descr:=' ';
      elsif (lab_fields.finished>=4) then
	 L_finished_descr:='Y';
      else
	 L_finished_descr:='N';
      end if;

      P_account:=TO_CHAR(lab_fields.practice,'009');


      select NVL(SUM(payment_amount),0) into ttl_plus from pcs.payments
      where lab_number=lab_fields.lab_number and payment_type='PLUS ADJUST';

      select NVL(SUM(payment_amount),0) into ttl_payments from pcs.payments
      where lab_number=lab_fields.lab_number and payment_type<>'PLUS ADJUST';

      P_amount:=TO_CHAR(ttl_payments-ttl_plus,'9990.00');
      if ((ttl_payments-ttl_plus)=0) then
	 P_amount:='	  ';
      end if;

      select count(*) into rcnt from pcs.lab_claims
      where lab_number=lab_fields.lab_number and claim_status='L';

      if (rcnt>0 and P_amount=0) then
	 P_amount:='	LOSS';
      end if;

      select count(*) into rcnt from pcs.lab_billing_items
      where lab_number=lab_fields.lab_number;
      if (rcnt<=0) then
	 P_amount:='NO ITEMS';
      end if;

      if (C_code='MED') then
	 select NVL(r.pap_class,0) into L_pclass
	 from pcs.lab_results r, pcs.lab_requisitions q

	 where q.lab_number=r.lab_number(+)
	 and q.lab_number=lab_fields.lab_number;
	 if (L_pclass=1 and (ttl_payments-ttl_plus)=0) then
	    P_amount:='   UNSAT';
	 end if;
      end if;

      curr_line:=TO_CHAR(lab_fields.lab_number)||' '||P_account||' '||P_name||
	 ' '||RPAD(C_code,3)||'  '||L_finished_descr||'     '||B_amount||
	 '     '||P_amount;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_cntr:=line_cntr+1;
      d_flag:=0;

      d_flag:=0;
      P_code_area:='PAYMENT';
      d_flag:=0;
      P_code_area:='FOOTER';
   end loop;
   close lab_list;

   UTL_FILE.PUT(file_handle,CHR(12));
   UTL_FILE.FCLOSE(file_handle);

exception
   when UTL_FILE.INVALID_PATH then
      UTL_FILE.FCLOSE(file_handle);

      RAISE_APPLICATION_ERROR(-20051,'invalid path'||F_name);
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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,lab_fields.lab_number);
      commit;
      RAISE;

end;
\

grant execute on analyze_activity to pcs_user
\