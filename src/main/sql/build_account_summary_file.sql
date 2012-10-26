create or replace procedure     build_acct_summary_file
(
   B_date in varchar2, E_date in varchar2, S_account number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_procedure char(5);
   S_practice number;

   S_name varchar2(64);
   S_file_name varchar2(12);
   dir_name varchar2(128);
   curr_line varchar2(300);
   cbuf1 varchar2(128);
   line_num number;
   curr_page number;
   margin varchar2(32);
   dline varchar2(512);
   dline2 varchar2(512);
   dline3 varchar2(512);
   heading1 varchar2(512);
   heading2 varchar2(512);

   heading3 varchar2(512);
   heading4 varchar2(512);

   doc_count number;
   doc_amount number;
   doc_g_ttl number;
   doc_g_amount number;
   dpa_count number;
   dpa_amount number;
   dpa_g_ttl number;
   dpa_g_amount number;
   dpa_g_exp number;
   db_count number;

   db_amount number;
   db_g_ttl number;
   db_g_amount number;
   prc_count number;
   prc_amount number;
   prc_g_ttl number;
   bs_count number;
   bs_amount number;
   bs_g_ttl number;
   bs_g_amount number;
   bs_g_exp number;
   med_count number;
   med_amount number;

   med_g_ttl number;
   med_g_amount number;
   med_g_exp number;
   oth_count number;
   oth_amount number;
   oth_g_ttl number;
   oth_g_amount number;
   ppd_count number;
   ppd_amount number;
   ppd_g_ttl number;
   ppd_g_amount number;
   total_count number;
   total_amount number;

   total_g_ttl number;
   total_g_amount number;
   total_g_exp number;

   count_procedure number;
   sum_item_amount number;

   dpa_rate number;
   bs_rate number;
   med_rate number;

   dpa_ucr varchar2(8);
   bs_ucr varchar2(8);

   med_ucr varchar2(8);

   dpa_expected number;
   bs_expected number;
   med_expected number;
   total_expected number;
   month_amount number;

   curr_S_month varchar2(8);
   D_begin date;
   D_end date;
   n_S_month number;
   e_S_month number;


   cursor procedure_list is
      select procedure_code,count(procedure_code),sum(item_amount)
      from pcs.bt_sum_work group by procedure_code;

   cursor practice_list is
      select distinct practice from pcs.bt_sum_work where procedure_code=S_procedure
      order by practice;
   practice_fields practice_list%ROWTYPE;

   cursor ucr_list is
	select a.choice_code, b.limit_amount, b.procedure_code
      from pcs.billing_choices a, pcs.procedure_code_limits b

      where a.billing_choice=b.billing_choice;
   L_choice_code varchar2(4);
   L_limit_amount number;
   L_procedure_code varchar2(32);

   file_handle UTL_FILE.FILE_TYPE;

begin

   P_proc_name:='BUILD_ACCT_SUMMARY_FILE';

   P_code_area:='OPEN FILE 1';
if (S_account=0) then

   cbuf1:='ADPH';
else
   select TO_CHAR(S_account,'009') into cbuf1 from dual;
end if;
   P_code_area:='OPEN FILE 2';
   S_file_name:=LTRIM(RTRIM(cbuf1))||'.asm';
   P_code_area:='OPEN FILE 3';
   dir_name:='REPORTS_DIR';
   P_code_area:='OPEN FILE 4: '||S_file_name;
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');
   P_code_area:='OPEN FILE 5';

   P_code_area:='PREP';

   line_num:=1;
   doc_g_ttl:=0;
   doc_g_amount:=0;
   dpa_g_ttl:=0;
   dpa_g_amount:=0;
   dpa_g_exp:=0;
   db_g_ttl:=0;
   db_g_amount:=0;
   prc_g_ttl:=0;
   bs_g_ttl:=0;
   bs_g_amount:=0;
   bs_g_exp:=0;
   med_g_ttl:=0;

   med_g_amount:=0;
   med_g_exp:=0;
   oth_g_ttl:=0;
   oth_g_amount:=0;
   ppd_g_ttl:=0;
   ppd_g_amount:=0;
   total_g_ttl:=0;
   total_g_amount:=0;
   total_g_exp:=0;

   D_begin:=TO_DATE(B_date,'MMDDYYYY');
   D_end:=TO_DATE(E_date,'MMDDYYYY');
   curr_S_month:=TO_CHAR(D_begin,'YYYYMM');

   n_S_month:=TO_NUMBER(curr_S_month);
   e_S_month:=TO_NUMBER(TO_CHAR(D_end,'YYYYMM'));

   curr_page:=1;
   margin:='	  ';
   dline:=margin||'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';

   dline2:=margin||LPAD(' ',45)||LPAD('-',17,'-')||'   '||LPAD('-',17,'-')||'	'||LPAD('-',17,'-')||'	 '||LPAD('-',17,'-')||'   '||LPAD('-',17,'-')||'   '||LPAD('-',17,'-')||'   '||LPAD('-',17,'-')||'   '||LPAD('-',17,'-')||'   '||LPAD('-',17,'-');

   dline3:=LPAD('DOC',11)||LPAD('DPA'||' '||dpa_ucr,20)||LPAD('DB',20)||LPAD('PRC',20)||LPAD('BS'||' '||bs_ucr,20)||LPAD('MED'||' '||med_ucr,20)||LPAD('OI',20)||LPAD('PPD',20)||LPAD('TOTAL',21);
if (S_account<>0) then

   select TO_CHAR(date_added,'MM/DD/YYYY') into cbuf1
   from pcs.practices where practice=S_account;
else
   cbuf1:='  ';
end if;
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
if (S_account=0) then
   heading2:=margin||'COMMISSION REPORT:  '||'ADPH ACCOUNTS';
else
   heading2:=margin||'COMMISSION REPORT:  ACCOUNT #'||
      LTRIM(RTRIM(TO_CHAR(S_account,'009')))||'  ['||cbuf1||']';
end if;
   heading3:=margin||'REPORTING PERIOD:  '||B_date||' - '||E_date;

   heading4:=margin||'PAGE '||curr_page;

   UTL_FILE.PUTF(file_handle,'%s\n',heading1); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',heading3); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading4); line_num:=line_num+2;

loop

   P_code_area:='WORK AREA';
   delete from pcs.bt_sum_work;
   month_amount:=0;
if (S_account=0) then

   insert into pcs.bt_sum_work
      (procedure_code,practice,name,choice_code,item_amount,description)
      select li.procedure_code, 0, 'ADPH ACCOUNTS', bc.choice_code,
	 li.item_amount, pc.description
      from pcs.lab_results lr, pcs.lab_billing_items li, pcs.practices pr,
	 pcs.lab_requisitions lq, pcs.lab_billings lb,
	 pcs.procedure_codes pc, pcs.billing_choices bc
      where TO_CHAR(lr.datestamp,'YYYYMM')=curr_S_month and
	 pr.practice_type='ADPH' and
	 li.lab_number=lr.lab_number and lr.lab_number=lq.lab_number and
	 lq.lab_number=lb.lab_number and lq.billing_choice=lb.billing_choice and
	 lb.billing_choice=bc.billing_choice and
	 li.procedure_code=pc.procedure_code and pr.practice=lq.practice;

else
   insert into pcs.bt_sum_work
      (procedure_code,practice,name,choice_code,item_amount,description)
      select li.procedure_code, lq.practice, pr.name, bc.choice_code,
	 li.item_amount, pc.description
      from pcs.lab_results lr, pcs.lab_billing_items li, pcs.practices pr,
	 pcs.lab_requisitions lq, pcs.lab_billings lb,
	 pcs.procedure_codes pc, pcs.billing_choices bc
      where TO_CHAR(lr.datestamp,'YYYYMM')=curr_S_month and
	 pr.practice=S_account and
	 li.lab_number=lr.lab_number and lr.lab_number=lq.lab_number and
	 lq.lab_number=lb.lab_number and lq.billing_choice=lb.billing_choice and
	 lb.billing_choice=bc.billing_choice and

	 li.procedure_code=pc.procedure_code and pr.practice=lq.practice;
end if;

   open ucr_list;
   loop
      fetch ucr_list into L_choice_code,L_limit_amount,L_procedure_code;
      exit when ucr_list%NOTFOUND;
      update pcs.bt_sum_work
      set item_amount=L_limit_amount
      where choice_code=L_choice_code and procedure_code=L_procedure_code;
   end loop;
   close ucr_list;


   curr_line:=margin||'MONTH '||SUBSTR(curr_S_month,5,2)||' OF '||SUBSTR(curr_S_month,1,4);
   UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line); line_num:=line_num+3;

   P_code_area:='PROCEDURES';
   open procedure_list;
   loop
      <<loop_top>>
      fetch procedure_list into S_procedure,count_procedure,sum_item_amount;
      exit when procedure_list%NOTFOUND;
      dpa_ucr:=null; bs_ucr:=null; med_ucr:=null;
      if (sum_item_amount>0) then
	 select nvl(sum(decode(A.procedure_code,S_procedure,A.limit_amount,0)),0)
	 into dpa_rate from pcs.procedure_code_limits A, pcs.billing_choices B

	 where A.billing_choice=B.billing_choice and B.choice_code='DPA';
	 select nvl(sum(decode(A.procedure_code,S_procedure,A.limit_amount,0)),0)
	 into bs_rate from pcs.procedure_code_limits A, pcs.billing_choices B
	 where A.billing_choice=B.billing_choice and B.choice_code='BS';
	 select nvl(sum(decode(A.procedure_code,S_procedure,A.limit_amount,0)),0)
	 into med_rate from pcs.procedure_code_limits A, pcs.billing_choices B
	 where A.billing_choice=B.billing_choice and B.choice_code='MED';
      end if;
      if (dpa_rate>0) then dpa_ucr:=TO_CHAR(dpa_rate,'90.00');
      end if;
      if (bs_rate>0) then bs_ucr:=TO_CHAR(bs_rate,'90.00');
      end if;
      if (med_rate>0) then med_ucr:=TO_CHAR(med_rate,'90.00');

      end if;
   	dline3:=LPAD('DOC',11)||LPAD('DPA'||' '||dpa_ucr,20)||LPAD('DB',20)||LPAD('PRC',20)||LPAD('BS'||' '||bs_ucr,20)||LPAD('MED'||' '||med_ucr,20)||LPAD('OI',20)||LPAD('PPD',20)||LPAD('TOTAL',21);
      if ((line_num+5)>=60) then
	 curr_page:=curr_page+1;
	 heading4:=margin||'PAGE '||curr_page;
	 UTL_FILE.PUT(file_handle,CHR(12));
	 line_num:=2;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading1); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading3); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading4); line_num:=line_num+2;
      end if;
      UTL_FILE.PUTF(file_handle,'%s\n\n',dline); line_num:=line_num+2;

      if (sum_item_amount=0) then
	 curr_line:=margin||'PROCEDURE CODE: '||S_procedure||
	    LPAD('THIS CODE WAS NOT USED DURING THIS REPORTING PERIOD.',79);
	 UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;
	 goto loop_top;
      end if;
      curr_line:=margin||RPAD('PROCEDURE CODE: '||S_procedure,45)||dline3;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',dline2); line_num:=line_num+1;
      open practice_list;
      loop
	 fetch practice_list into S_practice;
	 exit when practice_list%NOTFOUND;

	 if (S_practice=0) then
	    S_name:='ADPH';
	 else
	    select name into S_name from pcs.practices where practice=S_practice;
	 end if;
	 select
	    sum(decode(choice_code,'DOC',item_amount,0)),
	    sum(decode(choice_code,'DPA',item_amount,0)),
	    sum(decode(choice_code,'DB',item_amount,0)),
	    sum(decode(choice_code,'PRC',item_amount,0)),
	    sum(decode(choice_code,'BS',item_amount,0)),
	    sum(decode(choice_code,'MED',item_amount,0)),
	    sum(decode(choice_code,'OI',item_amount,0)),

	    sum(decode(choice_code,'PPD',item_amount,0)),
	    sum(item_amount)
	 into doc_amount,dpa_amount,db_amount,prc_amount,bs_amount,med_amount,
	    oth_amount,ppd_amount,total_amount
	 from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice;
	 select count(*) into doc_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice and choice_code='DOC';
	 select count(*) into dpa_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice and choice_code='DPA';
	 select count(*) into db_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice and choice_code='DB';
	 select count(*) into prc_count from pcs.bt_sum_work

	 where procedure_code=S_procedure and practice=S_practice and choice_code='PRC';
	 select count(*) into bs_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice and choice_code='BS';
	 select count(*) into med_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice and choice_code='MED';
	 select count(*) into oth_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice and choice_code='OI';
	 select count(*) into ppd_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice and choice_code='PPD';
	 select count(*) into total_count from pcs.bt_sum_work
	 where procedure_code=S_procedure and practice=S_practice;
	 if ((line_num+5)>=60) then
	    curr_page:=curr_page+1;

	    heading4:=margin||'PAGE '||curr_page;
	    UTL_FILE.PUT(file_handle,CHR(12));
	    line_num:=2;
	    UTL_FILE.PUTF(file_handle,'%s\n',heading1); line_num:=line_num+1;
	    UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
	    UTL_FILE.PUTF(file_handle,'%s\n',heading3); line_num:=line_num+1;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',heading4); line_num:=line_num+2;
	    UTL_FILE.PUTF(file_handle,'%s\n\n',dline); line_num:=line_num+2;
	    curr_line:=margin||RPAD('PROCEDURE CODE: '||S_procedure,45)||dline3;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
	    UTL_FILE.PUTF(file_handle,'%s\n',dline2); line_num:=line_num+1;
	 end if;
	 curr_line:=margin||LTRIM(TO_CHAR(S_practice,'099'))||'  '||RPAD(S_name,38)||'	'||

	    LPAD(LTRIM(TO_CHAR(doc_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(doc_amount,'999,990.00')),10)||'	 '||
	    LPAD(LTRIM(TO_CHAR(dpa_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(dpa_amount,'999,990.00')),10)||'	 '||
	    LPAD(LTRIM(TO_CHAR(db_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(db_amount,'999,990.00')),10)||'   '||
	    LPAD(LTRIM(TO_CHAR(prc_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(prc_amount,'999,990.00')),10)||'	 '||
	    LPAD(LTRIM(TO_CHAR(bs_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(bs_amount,'999,990.00')),10)||'   '||
	    LPAD(LTRIM(TO_CHAR(med_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(med_amount,'999,990.00')),10)||'	 '||
	    LPAD(LTRIM(TO_CHAR(oth_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(oth_amount,'999,990.00')),10)||'	 '||
	    LPAD(LTRIM(TO_CHAR(ppd_count,'9999')),6)||' '||LPAD(LTRIM(TO_CHAR(ppd_amount,'999,990.00')),10)||'	 '||
	    LPAD(LTRIM(TO_CHAR(total_count,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(total_amount,'999,990.00')),10);
	 --UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      end loop;
      close practice_list;
      --UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;

      if ((line_num+5)>=60) then
	 curr_page:=curr_page+1;
	 heading4:=margin||'PAGE '||curr_page;
	 UTL_FILE.PUT(file_handle,CHR(12));
	 UTL_FILE.NEW_LINE(file_handle);
	 line_num:=2;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading1); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',heading3); line_num:=line_num+1;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',heading4); line_num:=line_num+2;
	 UTL_FILE.PUTF(file_handle,'%s\n\n',dline); line_num:=line_num+2;
	 curr_line:=margin||RPAD('PROCEDURE CODE: '||S_procedure,45)||dline3;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;

	 UTL_FILE.PUTF(file_handle,'%s\n',dline2); line_num:=line_num+1;
      end if;
      select
	 sum(decode(choice_code,'DOC',item_amount,0)),
	 sum(decode(choice_code,'DPA',item_amount,0)),
	 sum(decode(choice_code,'DB',item_amount,0)),
	 sum(decode(choice_code,'PRC',item_amount,0)),
	 sum(decode(choice_code,'BS',item_amount,0)),
	 sum(decode(choice_code,'MED',item_amount,0)),
	 sum(decode(choice_code,'OI',item_amount,0)),
	 sum(decode(choice_code,'PPD',item_amount,0)),
	 sum(item_amount)
      into doc_amount,dpa_amount,db_amount,prc_amount,bs_amount,med_amount,

	 oth_amount,ppd_amount,total_amount
      from pcs.bt_sum_work
      where procedure_code=S_procedure;
      select count(*) into doc_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='DOC';
      select count(*) into dpa_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='DPA';
      select count(*) into db_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='DB';
      select count(*) into prc_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='PRC';
      select count(*) into bs_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='BS';

      select count(*) into med_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='MED';
      select count(*) into oth_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='OI';
      select count(*) into ppd_count from pcs.bt_sum_work
      where procedure_code=S_procedure and choice_code='PPD';
      select count(*) into total_count from pcs.bt_sum_work
      where procedure_code=S_procedure;
      curr_line:=margin||'     '||RPAD('TEST TOTALS:',40)||
	 LPAD(LTRIM(TO_CHAR(doc_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(doc_amount,'999,990.00')),10)||'	'||
	 LPAD(LTRIM(TO_CHAR(dpa_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(dpa_amount,'999,990.00')),10)||'	'||
	 LPAD(LTRIM(TO_CHAR(db_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(db_amount,'999,990.00')),10)||'   '||
	 LPAD(LTRIM(TO_CHAR(prc_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(prc_amount,'999,990.00')),10)||'	'||

	 LPAD(LTRIM(TO_CHAR(bs_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(bs_amount,'999,990.00')),10)||'   '||
	 LPAD(LTRIM(TO_CHAR(med_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(med_amount,'999,990.00')),10)||'	'||
	 LPAD(LTRIM(TO_CHAR(oth_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(oth_amount,'999,990.00')),10)||'	'||
	 LPAD(LTRIM(TO_CHAR(ppd_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(ppd_amount,'999,990.00')),10)||'	'||
	 LPAD(LTRIM(TO_CHAR(total_count,'999999')),6)||' '||LPAD(LTRIM(TO_CHAR(total_amount,'999,990.00')),10);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      month_amount:=month_amount+total_amount;
      doc_g_ttl:=doc_g_ttl+doc_count;
      doc_g_amount:=doc_g_amount+doc_amount;
      dpa_g_ttl:=dpa_g_ttl+dpa_count;
      dpa_g_amount:=dpa_g_amount+dpa_amount;
      db_g_ttl:=db_g_ttl+db_count;
      db_g_amount:=db_g_amount+db_amount;

      prc_g_ttl:=prc_g_ttl+prc_count;
      bs_g_ttl:=bs_g_ttl+bs_count;
      bs_g_amount:=bs_g_amount+bs_amount;
      med_g_ttl:=med_g_ttl+med_count;
      med_g_amount:=med_g_amount+med_amount;
      oth_g_ttl:=oth_g_ttl+oth_count;
      oth_g_amount:=oth_g_amount+oth_amount;
      total_g_ttl:=total_g_ttl+total_count;
      total_g_amount:=total_g_amount+total_amount;
      if (dpa_rate>0) then
	 dpa_expected:=dpa_count*dpa_rate;
      else
	 dpa_expected:=dpa_amount;

      end if;
      if (bs_rate>0) then
	 bs_expected:=bs_count*bs_rate;
      else
	 bs_expected:=bs_amount;
      end if;
      if (med_rate>0) then
	 med_expected:=med_count*med_rate;
      else
	 med_expected:=med_amount;
      end if;
      total_expected:=doc_amount+dpa_expected+db_amount+prc_amount+bs_expected+
      med_expected+oth_amount;

      dpa_g_exp:=dpa_g_exp+dpa_expected;
      bs_g_exp:=bs_g_exp+bs_expected;
      med_g_exp:=med_g_exp+med_expected;
      total_g_exp:=total_g_exp+total_expected;
      doc_amount:=0;
      dpa_amount:=dpa_expected-dpa_amount;
      db_amount:=0;
      prc_amount:=0;
      bs_amount:=bs_expected-bs_amount;
      med_amount:=med_expected-med_amount;
      oth_amount:=0;
      ppd_amount:=0;
      total_amount:=total_expected-total_amount;

   end loop;
   close procedure_list;
   curr_line:=margin||LPAD('MONTHLY TOTAL:',198)||
      LPAD(LTRIM(TO_CHAR(month_amount,'999,999.99')),24);
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line); line_num:=line_num+2;
   D_begin:=ADD_MONTHS(D_begin,1);
   curr_S_month:=TO_CHAR(D_begin,'YYYYMM');
   n_S_month:=TO_NUMBER(curr_S_month);
   exit when n_S_month>e_S_month;
end loop;
   if ((line_num+7)>=60) then
      curr_page:=curr_page+1;
      heading4:=margin||'PAGE '||curr_page;

      UTL_FILE.PUT(file_handle,CHR(12));
      UTL_FILE.NEW_LINE(file_handle);
      line_num:=2;
      UTL_FILE.PUTF(file_handle,'%s\n',heading1); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',heading3); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n\n',heading4); line_num:=line_num+2;
   end if;
   UTL_FILE.PUTF(file_handle,'%s\n',dline);
   curr_line:=margin||'GRAND TOTALS:';
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
   curr_line:=margin||RPAD(' ',45)||dline3;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   UTL_FILE.PUTF(file_handle,'%s\n',dline2);
   curr_line:=margin||'     '||RPAD('TEST TOTALS:',36)||
	 LPAD(LTRIM(TO_CHAR(doc_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(doc_g_amount,'9,999,990.00')),14)||'   '||
	 LPAD(LTRIM(TO_CHAR(dpa_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(dpa_g_amount,'999,990.00')),10)||'	 '||
	 LPAD(LTRIM(TO_CHAR(db_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(db_g_amount,'999,990.00')),10)||'   '||
	 LPAD(LTRIM(TO_CHAR(prc_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(prc_amount,'999,990.00')),10)||'   '||
	 LPAD(LTRIM(TO_CHAR(bs_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(bs_g_amount,'999,990.00')),10)||'   '||
	 LPAD(LTRIM(TO_CHAR(med_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(med_g_amount,'999,990.00')),10)||'	 '||
	 LPAD(LTRIM(TO_CHAR(oth_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(oth_g_amount,'999,990.00')),10)||'	 '||
	 LPAD(LTRIM(TO_CHAR(ppd_g_ttl,'99999')),6)||' '||LPAD(LTRIM(TO_CHAR(ppd_g_amount,'999,990.00')),10)||' '||
	 LPAD(LTRIM(TO_CHAR(total_g_ttl,'99999')),7)||' '||LPAD(LTRIM(TO_CHAR(total_g_amount,'99999990.00')),11);
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   doc_amount:=0;

   dpa_amount:=dpa_g_exp-dpa_g_amount;
   db_amount:=0;
   prc_amount:=0;
   bs_amount:=bs_g_exp-bs_g_amount;
   med_amount:=med_g_exp-med_g_amount;
   oth_amount:=0;
   ppd_amount:=0;
   total_amount:=total_g_exp-total_g_amount;
   P_code_area:='END';
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
/*
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_practice);

*/
      commit;
      RAISE;

end;
\

grant execute on build_acct_summary_file to pcs_user
\