create or replace procedure     build_practice_summary_file
(
   S_year in number,
   S_practice_id in varchar2
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_procedure char(5);

   S_choice number;
   S_practice number;
   S_name varchar2(64);
   S_file_name varchar2(12);
   dir_name varchar2(128);
   curr_line varchar2(300);
   heading varchar2(100);
   heading_x varchar2(100);
   cbuf1 varchar2(128);
   cbuf2 varchar2(128);
   line_num number;
   curr_page number;
   rcnt number;

   margin varchar2(32);
   dline varchar2(256);
   dline2 varchar2(256);
   dline3 varchar2(256);
   heading1 varchar2(256);
   heading2 varchar2(256);
   heading3 varchar2(256);
   heading4 varchar2(256);

   S_choice_code char(3);
   S_item_count number;
   S_item_amount number;
   S_period varchar2(64);


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

   dpa_rate number;
   bs_rate number;
   med_rate number;

   dpa_expected number;
   bs_expected number;
   med_expected number;
   prc_expected number;
   total_expected number;

   cursor procedure_list is

      select distinct procedure_code from pcs.bt_sum_work
      order by procedure_code;

   file_handle UTL_FILE.FILE_TYPE;

begin

   P_proc_name:='BUILD_PRACTICE_SUMMARY_FILE';

   P_code_area:='PREP';
   line_num:=1;
   cbuf1:=TO_CHAR(S_year)||S_practice_id;
   S_file_name:=REPLACE(cbuf1,' ')||'.sby';

   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');
   S_practice:=TO_NUMBER(S_practice_id);

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
   prc_expected:=0;


   select name into S_name from pcs.practices where practice=S_practice;
   S_period:=RTRIM(TO_CHAR(SysDate-1,'MONTH'))||' '||TO_CHAR(SysDate-1,'YYYY');

   P_code_area:='HEADING';
   curr_page:=1;
   margin:='	  ';
   dline:=margin||'------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------';
   dline2:=margin||'						    -------------    --------------    --------------	 --------------    --------------	 --------------    --------------    --------------    ----------------';
   dline3:='				    DOC 	     DPA		DB		 PRC		    BS		     MED	    OI		     PPD		TOTAL';

   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||'SUMMARY OF BILLING TYPES REPORT - ACCOUNT #'||RTRIM(TO_CHAR(S_practice))||' '||S_name;
   heading3:=margin||'YEAR: '||RTRIM(TO_CHAR(S_year));
   heading4:=margin||'PAGE '||curr_page;

   P_code_area:='WORK AREA';
   delete from pcs.bt_sum_work;
   insert into pcs.bt_sum_work
      (procedure_code,practice,name,choice_code,item_amount,description)
      select li.procedure_code, lq.practice, pr.name, bc.choice_code,

	 li.item_amount, pc.description
      from pcs.lab_results lr, pcs.lab_billing_items li, pcs.practices pr,
	 pcs.lab_requisitions lq, pcs.lab_billings lb,
	 pcs.procedure_codes pc, pcs.billing_choices bc
      where TO_NUMBER(TO_CHAR(lr.datestamp,'YYYY'))=S_year and
	 li.lab_number=lr.lab_number and lr.lab_number=lq.lab_number and
	 lq.lab_number=lb.lab_number and lq.billing_choice=lb.billing_choice and
	 lb.billing_choice=bc.billing_choice and
	 li.procedure_code=pc.procedure_code and
	 pr.practice=lq.practice and pr.practice=S_practice;

   P_code_area:='PROCEDURES';
   UTL_FILE.PUTF(file_handle,'%s\n',heading1); line_num:=line_num+1;

   UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n',heading3); line_num:=line_num+1;
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading4); line_num:=line_num+2;
   open procedure_list;
   loop
      fetch procedure_list into S_procedure;
      exit when procedure_list%NOTFOUND;
      select nvl(sum(decode(A.procedure_code,S_procedure,A.limit_amount,0)),0)
      into dpa_rate from pcs.procedure_code_limits A, pcs.billing_choices B
      where A.billing_choice=B.billing_choice and B.choice_code='DPA';
      select nvl(sum(decode(A.procedure_code,S_procedure,A.limit_amount,0)),0)
      into bs_rate from pcs.procedure_code_limits A, pcs.billing_choices B
      where A.billing_choice=B.billing_choice and B.choice_code='BS';

      select nvl(sum(decode(A.procedure_code,S_procedure,A.limit_amount,0)),0)
      into med_rate from pcs.procedure_code_limits A, pcs.billing_choices B
      where A.billing_choice=B.billing_choice and B.choice_code='MED';
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
      curr_line:=margin||'PROCEDURE CODE: '||S_procedure||dline3;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',dline2); line_num:=line_num+1;

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
	    curr_line:=margin||'PROCEDURE CODE: '||S_procedure||dline3;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
	    UTL_FILE.PUTF(file_handle,'%s\n',dline2); line_num:=line_num+1;
	 end if;
      UTL_FILE.NEW_LINE(file_handle); line_num:=line_num+1;

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
	 curr_line:=margin||'PROCEDURE CODE: '||S_procedure||dline3;
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
      curr_line:=margin||RPAD('      TEST TOTALS:',46)||
	 TO_CHAR(doc_count,'9999')||' '||TO_CHAR(doc_amount,'9,990.99')||'   '||
	 TO_CHAR(dpa_count,'9999')||' '||TO_CHAR(dpa_amount,'9,990.99')||'   '||
	 TO_CHAR(db_count,'9999')||' '||TO_CHAR(db_amount,'9,990.99')||'   '||
	 TO_CHAR(prc_count,'9999')||' '||TO_CHAR(prc_amount,'9,990.99')||'   '||

	 TO_CHAR(bs_count,'9999')||' '||TO_CHAR(bs_amount,'9,990.99')||'   '||
	 TO_CHAR(med_count,'9999')||' '||TO_CHAR(med_amount,'9,990.99')||'   '||
	 TO_CHAR(oth_count,'9999')||' '||TO_CHAR(oth_amount,'9,990.99')||'   '||
	 TO_CHAR(ppd_count,'9999')||' '||TO_CHAR(ppd_amount,'9,990.99')||'   '||
	 TO_CHAR(total_count,'99999')||' '||TO_CHAR(total_amount,'99,990.99');
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
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
      if (dpa_rate>0 or bs_rate>0 or med_rate>0) then
	 curr_line:=margin||'	   U & C RATES';
	 if (dpa_rate>0) then
	    curr_line:=curr_line||LPAD(TO_CHAR(dpa_rate,90.99),62);
	 else

	    curr_line:=curr_line||LPAD(' ',62);
	 end if;
	 if (bs_rate>0) then
	    curr_line:=curr_line||LPAD(TO_CHAR(bs_rate,90.99),54);
	 else
	    curr_line:=curr_line||LPAD(' ',54);
	 end if;
	 if (med_rate>0) then
	    curr_line:=curr_line||LPAD(TO_CHAR(med_rate,90.99),18);
	 else
	    curr_line:=curr_line||LPAD(' ',18);
	 end if;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;

      end if;
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
      total_expected:=doc_amount+dpa_expected+db_amount+prc_expected+bs_expected+
      med_expected+oth_amount;
      curr_line:=margin||RPAD('      EXPECTED AMOUNTS:',46)||
	    '	   '||TO_CHAR(doc_amount,'9,990.99')||'   '||
	    '	   '||TO_CHAR(dpa_expected,'9,990.99')||'   '||
	    '	   '||TO_CHAR(db_amount,'9,990.99')||'	 '||
	    '	   '||TO_CHAR(prc_expected,'9,990.99')||'   '||
	    '	   '||TO_CHAR(bs_expected,'9,990.99')||'   '||
	    '	   '||TO_CHAR(med_expected,'9,990.99')||'   '||
	    '	   '||TO_CHAR(oth_amount,'9,990.99')||'   '||

	    '	   '||TO_CHAR(ppd_amount,'9,990.99')||'   '||
	    '	    '||TO_CHAR(total_expected,'99,990.99');
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line); line_num:=line_num+1;
      dpa_g_exp:=dpa_g_exp+dpa_expected;
      bs_g_exp:=bs_g_exp+bs_expected;
      med_g_exp:=med_g_exp+med_expected;
      total_g_exp:=total_g_exp+total_expected;
      doc_amount:=0;
      dpa_amount:=dpa_expected-dpa_amount;
      db_amount:=0;
      prc_amount:=prc_expected-prc_amount;
      bs_amount:=bs_expected-bs_amount;
      med_amount:=med_expected-med_amount;

      oth_amount:=0;
      ppd_amount:=0;
      total_amount:=total_expected-total_amount;
      curr_line:=margin||RPAD('      DIFFERENCE:      ',46)||
	    '	   '||TO_CHAR(doc_amount,'9,990.99')||'   '||
	    '	   '||TO_CHAR(dpa_amount,'9,990.99')||'   '||
	    '	   '||TO_CHAR(db_amount,'9,990.99')||'	 '||
	    '	   '||TO_CHAR(prc_amount,'9,990.99')||'   '||
	    '	   '||TO_CHAR(bs_amount,'9,990.99')||'	 '||
	    '	   '||TO_CHAR(med_amount,'9,990.99')||'   '||
	    '	   '||TO_CHAR(oth_amount,'9,990.99')||'   '||
	    '	   '||TO_CHAR(ppd_amount,'9,990.99')||'   '||
	    '	    '||TO_CHAR(total_amount,'99,990.99');

      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;
   end loop;
   close procedure_list;
   P_code_area:='FOOTER';
   if ((line_num+7)>=60) then
      curr_page:=curr_page+1;
      heading4:=margin||'PAGE '||curr_page;
      UTL_FILE.PUT(file_handle,CHR(12));
      line_num:=2;
      UTL_FILE.PUTF(file_handle,'%s\n',heading1); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',heading2); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n',heading3); line_num:=line_num+1;
      UTL_FILE.PUTF(file_handle,'%s\n\n',heading4); line_num:=line_num+2;

   end if;
   UTL_FILE.PUTF(file_handle,'%s\n\n',dline);
   curr_line:=margin||'GRAND TOTALS:	    '||dline3;
   UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
   UTL_FILE.PUTF(file_handle,'%s\n',dline2);
   curr_line:=margin||RPAD('	  TEST TOTALS:',46)||
	 TO_CHAR(doc_g_ttl,'9999')||TO_CHAR(doc_g_amount,'99,990.99')||'   '||
	 TO_CHAR(dpa_g_ttl,'9999')||TO_CHAR(dpa_g_amount,'99,990.99')||'   '||
	 TO_CHAR(db_g_ttl,'9999')||TO_CHAR(db_g_amount,'99,990.99')||'	 '||
	 TO_CHAR(prc_g_ttl,'9999')||TO_CHAR(prc_amount,'99,990.99')||'	 '||
	 TO_CHAR(bs_g_ttl,'9999')||TO_CHAR(bs_g_amount,'99,990.99')||'	 '||
	 TO_CHAR(med_g_ttl,'9999')||TO_CHAR(med_g_amount,'99,990.99')||'   '||
	 TO_CHAR(oth_g_ttl,'9999')||TO_CHAR(oth_g_amount,'99,990.99')||'   '||

	 TO_CHAR(ppd_g_ttl,'9999')||TO_CHAR(ppd_g_amount,'99,990.99')||'    '||
	 TO_CHAR(total_g_ttl,'9999')||TO_CHAR(total_g_amount,'999,990.99');
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   curr_line:=margin||RPAD('	  EXPECTED AMOUNTS:',46)||
	    '	  '||TO_CHAR(doc_g_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(dpa_g_exp,'99,990.99')||'	 '||
	    '	  '||TO_CHAR(db_g_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(prc_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(bs_g_exp,'99,990.99')||'	'||
	    '	  '||TO_CHAR(med_g_exp,'99,990.99')||'	 '||
	    '	  '||TO_CHAR(oth_g_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(ppd_g_amount,'99,990.99')||'   '||
	    '	   '||TO_CHAR(total_g_exp,'999,990.99');

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
   curr_line:=margin||RPAD('	  DIFFERENCE:	   ',46)||
	    '	  '||TO_CHAR(doc_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(dpa_amount,'99,990.99')||'   '||

	    '	  '||TO_CHAR(db_amount,'99,990.99')||'	 '||
	    '	  '||TO_CHAR(prc_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(bs_amount,'99,990.99')||'	 '||
	    '	  '||TO_CHAR(med_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(oth_amount,'99,990.99')||'   '||
	    '	  '||TO_CHAR(ppd_amount,'99,990.99')||'   '||
	    '	   '||TO_CHAR(total_amount,'999,990.99');
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line); line_num:=line_num+2;

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
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_practice);
      commit;

      RAISE;

end;
\