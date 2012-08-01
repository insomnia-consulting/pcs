create or replace procedure     build_daily_report_file
(
   S_day in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_file_name varchar2(12);
   S_lname varchar2(32);

   S_fname varchar2(32);
   dir_name varchar2(128);
   S_pathologist number;
   S_path char(3);
   S_prep number;
   S_lab number;
   curr_line varchar2(300);
   curr_page number;
   rcnt number;
   margin varchar2(32);
   dline varchar2(256);
   dline2 varchar2(256);
   heading1 varchar2(256);

   heading2 varchar2(256);
   heading3 varchar2(256);
   heading4 varchar2(256);
   heading5 varchar2(256);
   heading6 varchar2(256);
   heading7 varchar2(256);
   cbuf1 varchar2(256);
   cbuf2 varchar2(256);
   min_time varchar2(64);
   max_time varchar2(64);
   user_hours number;
   S_month date;
   S_year date;


   curr_count number;
   curr_total number;
   total_count number;
   month_total number;
   year_total number;
   month_start number;
   min_lab number;
   max_lab number;
   L_MAX number;
   L_MIN number;

   num_single_slide number;

   num_two_slide number;
   num_non_gyne number;
   num_pathologist number;
   num_qc number;
   num_completed number;
   num_conv number;
   num_tp number;

   total_completed number;
   data_flag number(1);

   l_sent number;
   l_printed number;


   c_status varchar2(2);
   c_descr varchar2(48);
   c_count number;

   b_choice varchar2(3);
   acct number;
   p_date varchar2(10);
   p_amt number;
   last_acct number;
   last_lab number;
   last_prep number;
   prep_lbl varchar2(16);


   M_prior number;
   M_charges number;
   M_payments number;
   M_plus number;
   M_minus number;
   M_total number;

   E_rept_count number;
   E_rept_qc number;
   E_lab_number number;
   E_gap number;
   ndx number;


   cursor reqs_entered is
      select U.username,count(U.username),
	 TO_CHAR(MIN(R.datestamp),'HH:Mi:SS'),
	 TO_CHAR(MAX(R.datestamp),'HH:Mi:SS'),
	 MAX(R.datestamp)-MIN(R.datestamp)
      from pcs.lab_requisitions R, all_users U
      where R.sys_user=U.user_id and TO_NUMBER(TO_CHAR(datestamp,'YYYYMMDD'))=S_day
      group by U.username;

   cursor prep_list is
      select lab_number,preparation
      from pcs.lab_requisitions R

      where TO_NUMBER(TO_CHAR(datestamp,'YYYYMMDD'))=S_day
      order by lab_number;

   cursor results_entered is
      select
	      sum(decode(lq.slide_qty,1,1,0)),
	 sum(decode(lq.slide_qty,2,1,0)),
	 sum(decode(lq.preparation,4,1,0)),
	 sum(decode(lr.path_status,'Y',1,0)),
	 sum(decode(lr.qc_status,'Y',1,0)),
	 count(*),
	 sum(decode(lq.preparation,1,1,0)),
	 sum(decode(lq.preparation,2,1,0))

      from pcs.lab_results lr, pcs.lab_requisitions lq
      where lr.lab_number=lq.lab_number and
	 TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMMDD'))=S_day;

   cursor bill_queue_list is
      select R.billing_choice,count(R.billing_choice),SUM(B.item_amount)
      from lab_requisitions R, lab_billing_items B
      where R.lab_number=B.lab_number and R.lab_number in
	 (select lab_number from billing_queue
	  where TO_NUMBER(TO_CHAR(datestamp,'YYYYMMDD'))=S_day)
      group by R.billing_choice;

   cursor gap_list is

      select message_text from pcs.temp_table order by row_id;

   cursor fax_letter_details is
      select * from pcs.fax_letters
      where TO_NUMBER(TO_CHAR(date_sent,'YYYYMMDD'))=S_day
      order by lab_number;
   fax_letter_fields fax_letter_details%ROWTYPE;

   cursor fax_letter_list is
      select SUM(decode(in_queue,0,1,0)),SUM(decode(in_queue,1,1,0)),letter_type
      from fax_letters group by letter_type;

   cursor claim_status_list is

      select c.claim_status,c.description,count(l.claim_status)
      from lab_claims l, claim_statuses c
      where c.claim_status=l.claim_status(+)
      and (datestamp>=S_month or datestamp is null)
      group by c.claim_status,c.description
      order by c.claim_status;

   cursor claim_rework_list is
      select lab_number,RPAD(claim_status,2),TO_CHAR(datestamp,'MM/DD/YYYY')
      from lab_claims where rework_queue=1
      order by lab_number;

   cursor payment_list is

      select RPAD(SUBSTR(P.payment_type,1,14),14), TO_CHAR(P.payment_amount,'990.99'),
	 P.lab_number,B.choice_code,P.account_id,
	 TO_CHAR(payment_date,'MM/DD/YY'),P.payment_amount
      from pcs.payments P, pcs.billing_choices B
      where P.billing_choice=B.billing_choice
      and TO_NUMBER(TO_CHAR(P.payment_date,'YYYYMMDD'))=S_day
      order by P.billing_choice,P.lab_number;

   cursor pending_list is
      select R.lab_number,P.lname,P.fname,D.name, D.practice
      from pcs.lab_requisitions R, pcs.patients P, pcs.practices D
      where R.patient=P.patient and R.practice=D.practice and R.finished=0
      order by R.lab_number;


   cursor hpv_qc_list is
      select a.lab_number
      from cytopath_history a, lab_requisitions b, practices c
      where a.lab_number=b.lab_number
      and b.practice=c.practice
      and c.e_reporting in ('Y','B')
      and to_char(a.print_date,'YYYYMMDD')=S_day;

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

begin


   P_proc_name:='BUILD_DAILY_REPORT_FILE';

   P_code_area:='PREP';
   check_point:=0;
   S_file_name:=S_day||'.dwr';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   S_year:=TO_DATE(SUBSTR(TO_CHAR(S_day),1,4)||'0101','YYYYMMDD');
   S_month:=TO_DATE(SUBSTR(TO_CHAR(S_day),1,6)||'01','YYYYMMDD');
   select count(*) into month_total from pcs.lab_requisitions
   where datestamp>=S_month and finished<=4;

   select count(*) into year_total from pcs.lab_requisitions
   where datestamp>=S_year and finished<=4;
   select MIN(lab_number) into month_start
   from pcs.lab_requisitions where datestamp>=S_month;
   select MIN(lab_number),MAX(lab_number) into min_lab,max_lab from pcs.lab_requisitions
   where TO_NUMBER(TO_CHAR(datestamp,'YYYYMMDD'))=S_day;

   cbuf1:=SUBSTR(TO_CHAR(S_day),5,2)||'/'||SUBSTR(TO_CHAR(S_day),7,2)||
      '/'||SUBSTR(TO_CHAR(S_day),1,4);
   curr_page:=1;
   margin:='   ';
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||'DAILY WORK REPORT FOR:  '||cbuf1;


   P_code_area:='REQS';
   UTL_FILE.PUTF(file_handle,'\n%s\n',heading1);
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading2);
   curr_total:=0;
   data_flag:=0;
   open reqs_entered;
   loop
      fetch reqs_entered into cbuf1,curr_count,min_time,max_time,user_hours;
      exit when reqs_entered%NOTFOUND;
      if (data_flag=0) then
	 curr_line:=margin||
	    'REQUISITIONS ENTERED ------------------------------------------';

	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 data_flag:=1;
      end if;
      if (curr_count is null) then
	 curr_count:=0;
      end if;
      user_hours:=user_hours*24;
      if (user_hours>0) then
	 user_hours:=curr_count/user_hours;
      end if;
      cbuf2:=TO_CHAR(user_hours,'990.99');
      curr_total:=curr_total+curr_count;
      curr_line:=margin||RPAD(cbuf1,25)||LPAD(TO_CHAR(curr_count),8)||

	 ' '||min_time||'  '||max_time||'  '||cbuf2;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end loop;
   close reqs_entered;
   if (curr_total=0) then
      curr_line:=margin||
	 'NO REQS ENTERED THIS DAY --------------------------------------';
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   else
      open prep_list;
      last_lab:=0;
      last_prep:=0;
      L_MIN:=min_lab;

      L_MAX:=max_lab;
      curr_line:=margin||
	 'RANGES ENTERED ------------------------------------------------';
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);
      loop
	 fetch prep_list into S_lab,S_prep;
	 exit when prep_list%NOTFOUND;
	 prep_lbl:=NULL;
	 if (last_prep<>S_prep) then
	    if (last_lab=0) then
	       L_MIN:=S_lab;
	    else
	       L_MAX:=last_lab;

	       if (last_prep=1) then
		  prep_lbl:='CONVENTIONAL';
	       elsif (last_prep=2) then
		  prep_lbl:='THIN LAYER  ';
	       elsif (last_prep=4) then
		  prep_lbl:='CYT NON-PAP ';
	       elsif (last_prep=7) then
		  prep_lbl:='IMAGED	 ';
	       end if;
	       curr_line:=margin||prep_lbl||' '||TO_CHAR(L_MIN)||' '||TO_CHAR(L_MAX);
	       UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	       L_MIN:=S_lab;
	    end if;

	 end if;
	 last_lab:=S_lab;
	 last_prep:=S_prep;
      end loop;
      close prep_list;
      L_MAX:=last_lab;
      if (last_prep=1) then
	 prep_lbl:='CONVENTIONAL';
      elsif (last_prep=2) then
	 prep_lbl:='THIN LAYER	';
      elsif (last_prep=4) then
	 prep_lbl:='CYT NON-PAP ';
      elsif (last_prep=7) then

	 prep_lbl:='IMAGED	';
      end if;
      curr_line:=margin||prep_lbl||' '||TO_CHAR(L_MIN)||' '||TO_CHAR(L_MAX);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end if;
   curr_line:=margin||RPAD('DAILY TOTAL',25)||LPAD(TO_CHAR(curr_total),8);
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
   curr_line:=margin||RPAD('MONTHLY TOTAL',25)||LPAD(TO_CHAR(month_total),8);
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||RPAD('YEARLY TOTAL',25)||LPAD(TO_CHAR(year_total),8);
   UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);

   select count(*) into E_rept_count

   from cytopath_history a, lab_requisitions b, practices c
   where a.lab_number=b.lab_number
   and b.practice=c.practice
   and c.e_reporting in ('Y','B')
   and to_char(a.print_date,'YYYYMMDD')=S_day;
   if (E_rept_count>0) then
      E_rept_qc:=CEIL(E_rept_count/100);
      E_gap:=ROUND(ROUND(E_rept_count/E_rept_qc,0)/(E_rept_qc+1),0);
      rcnt:=0;
      ndx:=E_gap+1;
      curr_line:=margin||'ELECTRONIC REPORTS - DAILY QC LIST -------------------';
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
      open hpv_qc_list;

      loop
	 fetch hpv_qc_list into E_lab_number;
	 exit when hpv_qc_list%NOTFOUND OR rcnt>=E_rept_qc;
	 if (MOD(ndx,E_gap)=0) then
	    rcnt:=rcnt+1;
	    curr_line:=margin||TO_CHAR(E_lab_number);
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 end if;
	 ndx:=ndx+1;
      end loop;
      curr_line:=margin||'------------------------------------------------------';
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
      close hpv_qc_list;

   else
      curr_line:=margin||'NO ELECTRONIC REPORTS TO QC TODAY';
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);
   end if;

   P_code_area:='RESULTS';
   select count(*) into rcnt from pcs.lab_results lr
   where TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMMDD'))=S_day;
   if (rcnt=0) then
      curr_line:=margin||
	 'NO RESULTS ENTERED FOR THIS DAY -------------------------------';
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
      num_single_slide:=0;

      num_two_slide:=0;
      num_non_gyne:=0;
      num_pathologist:=0;
      num_qc:=0;
      curr_total:=0;
      num_conv:=0;
      num_tp:=0;
   else
      curr_line:=margin||
	 'RESULTS ENTERED -----------------------------------------------';
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
      select
	 sum(decode(lq.slide_qty,1,1,0)),

	 sum(decode(lq.slide_qty,2,1,0)),
	 sum(decode(lq.preparation,4,1,0)),
	 sum(decode(lr.path_status,'Y',1,0)),
	 sum(decode(lr.qc_status,'Y',1,0)),
	 count(*),
	 sum(decode(lq.preparation,1,1,0)),
	 sum(decode(lq.preparation,2,1,0))
      into num_single_slide,num_two_slide,num_non_gyne,
	 num_pathologist,num_qc,curr_total,num_conv,num_tp
      from pcs.lab_results lr, pcs.lab_requisitions lq
      where lr.lab_number=lq.lab_number and
	 TO_NUMBER(TO_CHAR(lr.datestamp,'YYYYMMDD'))=S_day;
      curr_line:=margin||RPAD('SINGLE SLIDE CASES',25)||

	 LPAD(TO_CHAR(num_single_slide),8);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||RPAD('TWO SLIDE CASES',25)||LPAD(TO_CHAR(num_two_slide),8);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||RPAD('NON GYNE',25)||LPAD(TO_CHAR(num_non_gyne),8);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||RPAD('PATHOLOGIST CASES',25)||LPAD(TO_CHAR(num_pathologist),8);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||RPAD('QC CASES',25)||LPAD(TO_CHAR(num_qc),8);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||RPAD('CONVENTIONAL',25)||LPAD(TO_CHAR(num_conv),8);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||RPAD('THIN PREP',25)||LPAD(TO_CHAR(num_tp),8);

      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
      curr_line:=margin||RPAD('TOTAL',25)||LPAD(TO_CHAR(curr_total),8);
      UTL_FILE.PUTF(file_handle,'%s\n\n\n',curr_line);
   end if;

   P_code_area:='BILLING QUEUE';
   total_count:=0;
   curr_page:=0;
   data_flag:=0;
   open bill_queue_list;
   loop
      fetch bill_queue_list into curr_total,rcnt,curr_count;
      exit when bill_queue_list%NOTFOUND;

      if (data_flag=0) then
	 curr_line:=margin||
	    'ADDED TO BILLING QUEUE ----------------------------------------';
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
	 data_flag:=1;
      end if;
      select choice_code,description into cbuf1,cbuf2
      from pcs.billing_choices where billing_choice=curr_total;
      total_count:=total_count+curr_count;
      curr_page:=curr_page+rcnt;
      curr_line:=margin||RPAD(cbuf1,6)||RPAD(cbuf2,18)||
	 LPAD(TO_CHAR(rcnt),8)||LPAD(TO_CHAR(curr_count,'99,990.99'),14);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   end loop;
   close bill_queue_list;
   if (data_flag=1) then
      curr_line:=margin||LPAD(TO_CHAR(curr_page),32)||
	 LPAD(TO_CHAR(total_count,'99,990.99'),14);
      UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);
   end if;

   select count(*) into rcnt from history_match_queue where printed=0;
   curr_line:=margin||'HISTORY-MATCH QUEUE: '||TO_CHAR(rcnt);
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);

   P_code_area:='GAPS';

   pcs.compute_labnumber_gaps(min_lab,max_lab);
   curr_line:=margin||'MONTH STARTING AT:  '||TO_CHAR(month_start);
   UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
   select count(*) into rcnt from pcs.temp_table;
   if (rcnt>0) then
      curr_line:=margin||'LAB NUMBER GAP REPORT:';
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
      open gap_list;
      loop
	 fetch gap_list into curr_line;
	 exit when gap_list%NOTFOUND;
	 UTL_FILE.PUTF(file_handle,'%s%s%s\n',margin,margin,curr_line);
      end loop;

      close gap_list;
   else
      curr_line:=margin||'DAY STARTING AT:    '||TO_CHAR(min_lab);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      curr_line:=margin||'DAY ENDING AT:      '||TO_CHAR(max_lab);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end if;

   P_code_area:='CLAIMS';
   curr_line:=margin||'CLAIM STATUS SUMMARY ------------------------------------------';
   UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
   curr_line:=margin||'CLAIM STATUS:					      COUNT:';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   open claim_status_list;
   loop
      fetch claim_status_list into c_status,c_descr,c_count;
      exit when claim_status_list%NOTFOUND;
      cbuf1:=RPAD(c_status,4);
      cbuf2:=RPAD(c_descr,50);
      curr_line:=margin||cbuf1||cbuf2||TO_CHAR(c_count,'9999');
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   end loop;
   close claim_status_list;

   -- ADJUSTED, 10/09/2002, AS PER LISA - ONLY WANTS TOTALS
   P_code_area:='PAYMENTS';

   curr_total:=0;
   last_acct:=0;
   open payment_list;
   loop
      fetch payment_list into c_descr,cbuf1,min_lab,b_choice,acct,p_date,p_amt;
      exit when payment_list%NOTFOUND;
      curr_total:=(curr_total+p_amt);
      if (c_descr in ('PLUS ADJUST')) then
	 curr_total:=(curr_total-p_amt);
      end if;
   end loop;
   close payment_list;
   if (curr_total>0) then

      cbuf1:='TOTAL PAYMENTS: '||TO_CHAR(curr_total,'99,990.99');
      curr_line:=margin||cbuf1;
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
   end if;

   P_code_area:='SUMMATION';
   select sum(prior_balance),sum(total_charges),sum(total_payments),
      sum(total_plus),sum(total_minus),sum(total_balance)
   into M_prior,M_charges,M_payments,M_plus,M_minus,M_total
   from practice_accounts_history where activity_flag=1;
   curr_line:=margin||'ACCOUNT SUMMATIONS';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'FORWARDED:  '||TO_CHAR(M_prior,'999,990.00');

   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'CHARGES:    '||TO_CHAR(M_charges,'999,990.00');
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'PAYMENTS:   '||TO_CHAR(M_payments,'999,990.00');
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'+ ADJUSTS:  '||TO_CHAR(M_plus,'999,990.00');
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'- ADJUSTS:  '||TO_CHAR(M_minus,'999,990.00');
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||'TOTAL BAL:  '||TO_CHAR(M_total,'999,990.00');
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   UTL_FILE.PUT(file_handle,CHR(12));

   UTL_FILE.FCLOSE(file_handle);
   commit;

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
/