create or replace procedure     process_no_response_claims
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);
   P_rebilling number;

   S_file_name varchar2(12);
   dir_name varchar2(128);
   curr_line varchar2(300);
   rcnt number;

   margin varchar2(32);
   cbuf1 varchar2(256);
   cbuf2 varchar2(256);
   C_date char(10);
   C_lab number(11);
   C_batch number;
   C_lname varchar2(32);
   C_fname varchar2(32);
   C_practice varchar2(64);
   C_account varchar2(4);
   C_payer varchar2(64);
   C_payer_id varchar2(32);
   L_choice_code varchar2(3);

   C_balance varchar2(16);
   B_level char(3);
   P_id number;
   PR_id number;
   R_bill number;
   C_id number;
   C_status varchar2(2);
   F_lab varchar2(10);
   F_batch varchar2(5);
   P_block char(1);
   curr_rebilling number;

   cursor BS_claim_list is

      select TO_CHAR(C.datestamp,'MM/DD/YYYY'),C.lab_number,
	 C.batch_number,P.lname,P.fname,PR.name,
	 TO_CHAR(L.practice,'009'),TO_CHAR(LB.balance,'990.99'),
	 C.claim_status,LB.rebilling
      from pcs.lab_claims C, pcs.lab_requisitions L, pcs.lab_billings LB,
	 pcs.billing_details BD, pcs.patients P, pcs.practices PR
      where C.lab_number=L.lab_number and L.practice=PR.practice and
	 L.patient=P.patient and (SysDate-C.datestamp>45) and LB.balance>0 and
	 LB.billing_choice=124 and LB.rebilling=BD.rebilling and
	 C.claim_status in ('S','B','O') and LB.lab_number=C.lab_number and
	 LB.lab_number=BD.lab_number and C.claim_id=BD.claim_id
	 and L.finished<4
      order by C.batch_number,C.claim_status,C.lab_number;


   cursor MED_claim_list is
      select TO_CHAR(C.datestamp,'MM/DD/YYYY'),C.lab_number,
	 C.batch_number,P.lname,P.fname,PR.name,TO_CHAR(L.practice,'009'),
	 SUBSTR(CR.name,1,64),TO_CHAR(LB.balance,'990.99'),C.claim_status,
	 LB.rebilling
      from pcs.lab_claims C, pcs.lab_requisitions L, pcs.lab_billings LB,
	 pcs.billing_details BD, pcs.patients P,
	 pcs.practices PR, pcs.carriers CR
      where C.lab_number=L.lab_number and L.practice=PR.practice and
	 L.patient=P.patient and (SysDate-C.datestamp>45) and LB.balance>0 and
	 LB.billing_choice=125 and C.claim_status in ('S','B','O') and
	 BD.carrier_id=CR.carrier_id and LB.rebilling=BD.rebilling and

	 LB.lab_number=BD.lab_number and LB.lab_number=C.lab_number and
	 C.claim_id=BD.claim_id and L.finished<4
      order by C.batch_number,C.claim_status,C.lab_number;

   cursor OI_claim_list is
      select TO_CHAR(C.datestamp,'MM/DD/YYYY'),C.lab_number,C.batch_number,
	 P.lname,P.fname,PR.name,TO_CHAR(L.practice,'009'),
	 SUBSTR(CR.name,1,54), CR.payer_id,TO_CHAR(LB.balance,'990.99'),
	 P.patient,PR.practice,LB.rebilling,C.claim_status
      from pcs.lab_claims C, pcs.lab_requisitions L, pcs.billing_details B,
	 pcs.patients P, pcs.practices PR, pcs.carriers CR, pcs.lab_billings LB
      where C.lab_number=L.lab_number and LB.balance>0 and
	 LB.billing_choice=126 and C.claim_status in ('S','B','O') and

	 (SysDate-C.datestamp>45) and LB.rebilling=B.rebilling and
	 L.patient=P.patient and L.practice=PR.practice and
	 LB.lab_number=B.lab_number and LB.lab_number=C.lab_number and
	 B.carrier_id=CR.carrier_id and CR.e_billing='Y' and
	 C.claim_id=B.claim_id and L.finished<4
      order by C.batch_number,C.claim_status,C.lab_number;

   cursor PPR_claim_list is
      select TO_CHAR(C.datestamp,'MM/DD/YYYY'),C.lab_number,C.batch_number,
	 P.lname,P.fname,PR.name,TO_CHAR(L.practice,'009'),
	 SUBSTR(CR.name,1,54), TO_CHAR(LB.balance,'990.99'),
	 P.patient,PR.practice,LB.rebilling,C.claim_status
      from pcs.lab_claims C, pcs.lab_requisitions L, pcs.billing_details B,

	 pcs.patients P, pcs.practices PR, pcs.carriers CR, pcs.lab_billings LB
      where C.lab_number=L.lab_number and LB.balance>0 and
	 LB.billing_choice=126 and C.claim_status in ('S','B','O') and
	 (SysDate-C.datestamp>45) and LB.rebilling=B.rebilling and
	 L.patient=P.patient and L.practice=PR.practice and
	 B.lab_number=LB.lab_number and LB.lab_number=C.lab_number and
	 B.carrier_id=CR.carrier_id and CR.e_billing='N' and
	 C.claim_id=B.claim_id and L.finished<4
      order by C.batch_number,C.claim_status,C.lab_number;

   cursor DPA_claim_list is
      select TO_CHAR(C.datestamp,'MM/DD/YYYY'),C.lab_number,C.batch_number,
	 P.lname,P.fname,PR.name,TO_CHAR(L.practice,'009'),

	 SUBSTR(CR.name,1,54),TO_CHAR(LB.balance,'990.99'),C.claim_status
      from pcs.lab_claims C, pcs.lab_requisitions L, pcs.billing_details B,
	 pcs.patients P, pcs.practices PR, pcs.carriers CR, pcs.lab_billings LB
      where C.lab_number=L.lab_number and LB.balance>0 and
	 LB.billing_choice=123 and C.claim_status in ('S','B','O') and
	 (SysDate-C.datestamp>45) and LB.rebilling=B.rebilling and
	 L.patient=P.patient and L.practice=PR.practice and
	 B.carrier_id=CR.carrier_id and B.lab_number=LB.lab_number and
	 LB.lab_number=C.lab_number and C.claim_id=B.claim_id
	 and L.finished<4
      order by C.batch_number,C.claim_status,C.lab_number;

   cursor rebill_list is

      select row_id,message_text from pcs.temp_table;

   data_flag number(1);
   line_1 varchar2(128);
   headings_1 varchar2(128);
   line_2 varchar2(128);
   headings_2 varchar2(128);
   title1 varchar2(64);
   title2 varchar2(64);
   title3 varchar2(64);
   page_num number;
   line_num number;
   new_page varchar2(3);

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

begin

   P_proc_name:='PROCESS_NO_RESPONSE_CLAIMS';
   C_lab:=0;

   P_code_area:='PREP';
   check_point:=0;
   page_num:=1;
   line_num:=1;
   new_page:=CHR(12);

   S_file_name:='claim.rpt';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   P_code_area:='HEADING';
   select TO_CHAR(SysDate,'MM/DD/YYYY') into cbuf1 from dual;
   margin:='   ';
   title1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   title2:=margin||'NO RESPONSE CLAIM REPORT';
   title3:=margin||'WEEK ENDING: '||cbuf1;
   line_1:=margin||'-----------------------------------------------------------------';
   headings_1:=margin||'LAB/BATCH	DATE	   PATIENT	       ACCOUNT	 TOTAL';
   line_2:=margin||'-----------------------------------------------------------------------------------------------';

   headings_2:=margin||'LAB/BATCH	DATE	   PATIENT	     ACCOUNT PAYER			       TOTAL';

   delete from pcs.temp_table;

   UTL_FILE.PUTF(file_handle,'\n%s\n',title1);
   UTL_FILE.PUTF(file_handle,'%s\n',title2);
   UTL_FILE.PUTF(file_handle,'%s\n',title3);
   curr_line:=margin||'PAGE '||page_num;
   UTL_FILE.PUTF(file_handle,'\n%s\n\n\n',curr_line);
   line_num:=line_num+8;

   P_code_area:='BS CLAIMS';
   data_flag:=0;

   open BS_claim_list;
   loop
      fetch BS_claim_list into
	 C_date,C_lab,C_batch,C_lname,C_fname,C_practice,
	 C_account,C_balance,C_status,P_rebilling;
      exit when BS_claim_list%NOTFOUND;
      P_code_area:='BS: '||TO_CHAR(C_lab);
      if (line_num>=56) then
	 UTL_FILE.PUT(file_handle,new_page);
	 line_num:=1;
	 data_flag:=0;
	 page_num:=page_num+1;
	 UTL_FILE.PUTF(file_handle,'\n%s\n',title1);

	 UTL_FILE.PUTF(file_handle,'%s\n',title2);
	 UTL_FILE.PUTF(file_handle,'%s\n',title3);
	 curr_line:=margin||'PAGE '||page_num;
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);
	 line_num:=line_num+7;
      end if;
      if (data_flag=0) then
	 P_code_area:='BS+45: '||TO_CHAR(C_lab);
	 curr_line:=margin||'BS CLAIMS PAST 45 DAYS';
	 UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_1);
	 UTL_FILE.PUTF(file_handle,'%s\n',headings_1);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_1);

	 line_num:=line_num+6;
	 data_flag:=1;
      end if;
      F_lab:=RTRIM(LTRIM(TO_CHAR(C_lab)));
      F_batch:=RTRIM(LTRIM(TO_CHAR(C_batch)));
      curr_line:=margin||F_lab||' '||RPAD(F_batch,4)||' '||C_date||' '||
	 RPAD(SUBSTR(RTRIM(C_lname)||', '||RTRIM(C_fname),1,20),22)||' '||
	 C_account||' '||C_balance||' '||C_status;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_num:=line_num+1;
      if (C_status in ('S','B')) then
	 insert into pcs.billing_queue
	    (lab_number,billing_route,datestamp,billing_type,rebilling,rebill_code)

	 values (C_lab,'WKS',SysDate,'WKS',P_rebilling,null);
	 update pcs.lab_claims set claim_status='O', change_date=SysDate,
	    claim_comment=claim_comment||' CLAIM OLDER THAN 45 DAYS'
	 where lab_number=C_lab and claim_status=C_status;
      end if;
   end loop;
   close BS_claim_list;
   if (data_flag=0) then
      curr_line:=margin||'THERE ARE NO BS CLAIMS PAST 45 DAYS';
      UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
      line_num:=line_num+3;
   end if;


   P_code_area:='MED CLAIMS';
   C_lab:=0;
   data_flag:=0;
   open MED_claim_list;
   loop
      fetch MED_claim_list into
	 C_date,C_lab,C_batch,C_lname,C_fname,C_practice,
	 C_account,C_payer,C_balance,C_status,P_rebilling;
      exit when MED_claim_list%NOTFOUND;
      P_code_area:='MED: '||TO_CHAR(C_lab);
      if (line_num>=56) then
	 UTL_FILE.PUT(file_handle,new_page);
	 line_num:=1;

	 data_flag:=0;
	 page_num:=page_num+1;
	 UTL_FILE.PUTF(file_handle,'\n%s\n',title1);
	 UTL_FILE.PUTF(file_handle,'%s\n',title2);
	 UTL_FILE.PUTF(file_handle,'%s\n',title3);
	 curr_line:=margin||'PAGE '||page_num;
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);
	 line_num:=line_num+7;
      end if;
      if (data_flag=0) then
	 P_code_area:='MED+45: '||TO_CHAR(C_lab);
	 curr_line:=margin||'MED CLAIMS PAST 45 DAYS';
	 UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);

	 UTL_FILE.PUTF(file_handle,'%s\n',line_1);
	 UTL_FILE.PUTF(file_handle,'%s\n',headings_1);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_1);
	 data_flag:=1;
	 line_num:=line_num+6;
      end if;
      F_lab:=RTRIM(LTRIM(TO_CHAR(C_lab)));
      F_batch:=RTRIM(LTRIM(TO_CHAR(C_batch)));
      curr_line:=margin||F_lab||' '||RPAD(F_batch,4)||' '||C_date||' '||
	 RPAD(SUBSTR(RTRIM(C_lname)||', '||RTRIM(C_fname),1,20),22)||' '||
	 C_account||' '||C_balance||' '||C_status;
      if (C_payer LIKE 'TRAVELERS%') then
	 curr_line:=curr_line||'  (T)';

      end if;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_num:=line_num+1;
      if (C_status in ('S','B')) then
	 insert into pcs.billing_queue
	    (lab_number,billing_route,datestamp,billing_type,rebilling,rebill_code)
	 values (C_lab,'WKS',SysDate,'WKS',P_rebilling,null);
	 update pcs.lab_claims set claim_status='O', change_date=SysDate,
	    claim_comment=claim_comment||' CLAIM OLDER THAN 45 DAYS'
	 where lab_number=C_lab and claim_status=C_status;
      end if;
   end loop;
   close MED_claim_list;

   if (data_flag=0) then
      curr_line:=margin||'THERE ARE NO MED CLAIMS PAST 45 DAYS';
      UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
      line_num:=line_num+3;
   end if;

   P_code_area:='OI CLAIMS';
   C_lab:=0;
   data_flag:=0;
   open OI_claim_list;
   loop
      fetch OI_claim_list into
	 C_date,C_lab,C_batch,C_lname,C_fname,C_practice,C_account,

	 C_payer,C_payer_id,C_balance,P_id,PR_id,R_bill,C_status;
      exit when OI_claim_list%NOTFOUND;
      P_code_area:='OI: '||TO_CHAR(C_lab);
      if (line_num>=56) then
	 UTL_FILE.PUT(file_handle,new_page);
	 line_num:=1;
	 data_flag:=0;
	 page_num:=page_num+1;
	 UTL_FILE.PUTF(file_handle,'\n%s\n',title1);
	 UTL_FILE.PUTF(file_handle,'%s\n',title2);
	 UTL_FILE.PUTF(file_handle,'%s\n',title3);
	 curr_line:=margin||'PAGE '||page_num;
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);

	 line_num:=line_num+7;
      end if;
      if (data_flag=0) then
	 P_code_area:='OI+45: '||TO_CHAR(C_lab);
	 curr_line:=margin||'ELECTRONIC OI CLAIMS PAST 45 DAYS - S/B LABS HAVE BEEN DIRECT BILLED';
	 UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_2);
	 UTL_FILE.PUTF(file_handle,'%s\n',headings_2);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_2);
	 data_flag:=1;
	 line_num:=line_num+6;
      end if;
      F_lab:=RTRIM(LTRIM(TO_CHAR(C_lab)));

      F_batch:=RTRIM(LTRIM(TO_CHAR(C_batch)));
      curr_line:=margin||F_lab||' '||RPAD(F_batch,4)||' '||C_date||' '||
	 RPAD(SUBSTR(RTRIM(C_lname)||', '||RTRIM(C_fname),1,18),20)||' '||
	 C_account||' '||RPAD(SUBSTR(C_payer||'('||C_payer_id||')',1,30),32)||C_balance||' '||C_status;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      select count(*) into rcnt from pcs.billing_details
      where lab_number=C_lab and billing_level='PRT';
      if (rcnt>0) then
	 B_level:='PRT';
      else
	 B_level:='RBL';
      end if;
      check_point:=1;

      if (C_status<>'O') then
	 insert into pcs.temp_table (row_id,message_text) values (C_lab,B_level);
      end if;
      line_num:=line_num+1;
   end loop;
   close OI_claim_list;
   if (data_flag=0) then
      curr_line:=margin||'THERE ARE NO ELECTRONIC OI CLAIMS PAST 45 DAYS';
      UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
      line_num:=line_num+3;
   end if;

   P_code_area:='PPR CLAIMS';

   C_lab:=0;
   data_flag:=0;
   open PPR_claim_list;
   loop
      fetch PPR_claim_list into
	 C_date,C_lab,C_batch,C_lname,C_fname,C_practice,
	 C_account,C_payer,C_balance,P_id,PR_id,R_bill,C_status;
      exit when PPR_claim_list%NOTFOUND;
      P_code_area:='PPR: '||TO_CHAR(C_lab);
      if (line_num>=56) then
	 UTL_FILE.PUT(file_handle,new_page);
	 line_num:=1;
	 data_flag:=0;

	 page_num:=page_num+1;
	 UTL_FILE.PUTF(file_handle,'\n%s\n',title1);
	 UTL_FILE.PUTF(file_handle,'%s\n',title2);
	 UTL_FILE.PUTF(file_handle,'%s\n',title3);
	 curr_line:=margin||'PAGE '||page_num;
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);
	 line_num:=line_num+7;
      end if;
      if (data_flag=0) then
	 P_code_area:='PPR+45: '||TO_CHAR(C_lab);
	 curr_line:=margin||'PAPER OI CLAIMS PAST 45 DAYS - S/B LABS HAVE BEEN DIRECT BILLED';
	 UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_2);

	 UTL_FILE.PUTF(file_handle,'%s\n',headings_2);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_2);
	 data_flag:=1;
	 line_num:=line_num+6;
      end if;
      F_lab:=RTRIM(LTRIM(TO_CHAR(C_lab)));
      F_batch:=RTRIM(LTRIM(TO_CHAR(C_batch)));
      curr_line:=margin||F_lab||' '||RPAD(F_batch,4)||' '||C_date||' '||
	 RPAD(SUBSTR(RTRIM(C_lname)||', '||RTRIM(C_fname),1,18),20)||' '||
	 C_account||' '||RPAD(SUBSTR(C_payer,1,30),32)||C_balance||' '||C_status;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      select count(*) into rcnt from pcs.billing_details
      where lab_number=C_lab and billing_level='PRT';

      if (rcnt>0) then
	 B_level:='PRT';
      else
	 B_level:='RBL';
      end if;
      line_num:=line_num+1;
      if (C_status<>'O') then
	 insert into pcs.temp_table (row_id,message_text) values (C_lab,B_level);
      end if;
   end loop;
   close PPR_claim_list;
   if (data_flag=0) then
      curr_line:=margin||'THERE ARE NO PAPER OI CLAIMS PAST 45 DAYS';

      UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
      line_num:=line_num+3;
   end if;

   P_code_area:='DPA CLAIMS';
   C_lab:=0;
   data_flag:=0;
   open DPA_claim_list;
   loop
      fetch DPA_claim_list into
	 C_date,C_lab,C_batch,C_lname,C_fname,C_practice,
	 C_account,C_payer,C_balance,C_status;
      exit when DPA_claim_list%NOTFOUND;

      P_code_area:='DPA: '||TO_CHAR(C_lab);
      if (line_num>=56) then
	 UTL_FILE.PUT(file_handle,new_page);
	 line_num:=1;
	 data_flag:=0;
	 page_num:=page_num+1;
	 UTL_FILE.PUTF(file_handle,'\n%s\n',title1);
	 UTL_FILE.PUTF(file_handle,'%s\n',title2);
	 UTL_FILE.PUTF(file_handle,'%s\n',title3);
	 curr_line:=margin||'PAGE '||page_num;
	 UTL_FILE.PUTF(file_handle,'\n%s\n\n',curr_line);
	 line_num:=line_num+7;
      end if;

      if (data_flag=0) then
	 P_code_area:='DPA+45: '||TO_CHAR(C_lab);
	 curr_line:=margin||'DPA CLAIMS PAST 45 DAYS';
	 UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_2);
	 UTL_FILE.PUTF(file_handle,'%s\n',headings_2);
	 UTL_FILE.PUTF(file_handle,'%s\n',line_2);
	 data_flag:=1;
	 line_num:=line_num+6;
      end if;
      F_lab:=RTRIM(LTRIM(TO_CHAR(C_lab)));
      F_batch:=RTRIM(LTRIM(TO_CHAR(C_batch)));
      curr_line:=margin||F_lab||' '||RPAD(F_batch,4)||' '||C_date||' '||

	 RPAD(SUBSTR(RTRIM(C_lname)||', '||RTRIM(C_fname),1,18),20)||' '||
	 C_account||' '||RPAD(SUBSTR(C_payer,1,30),32)||C_balance||' '||C_status;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      line_num:=line_num+1;
   end loop;
   close DPA_claim_list;
   if (data_flag=0) then
      curr_line:=margin||'THERE ARE NO DPA CLAIMS PAST 45 DAYS';
      UTL_FILE.PUTF(file_handle,'\n\n%s\n',curr_line);
      line_num:=line_num+3;
   end if;

   UTL_FILE.PUT(file_handle,new_page);

   UTL_FILE.FCLOSE(file_handle);

   P_code_area:='REBILL';
   C_lab:=0;
   open rebill_list;
   loop
      fetch rebill_list into C_lab,B_level;
      exit when rebill_list%NOTFOUND;
      check_point:=3;
      -- BILLING CHOICE #126 IS OI
      P_code_area:='REBILL 1 '||C_lab;
      select L.patient,L.practice,B.rebilling,B.claim_id,C.claim_status
      into P_id,PR_id,R_bill,C_id,C_status

      from pcs.lab_requisitions L, pcs.billing_details B, pcs.lab_claims C
	   where C.claim_status in ('S','B') and C.claim_id=B.claim_id and
	 L.lab_number=B.lab_number and B.billing_choice=126 and B.lab_number=C_lab;
      P_code_area:='REBILL 2 '||C_lab;
      select block_patient into P_block from pcs.practices where practice=PR_id;
      if (P_block<>'Y') then
	 pcs.rebill_add(C_lab,P_id,PR_id,R_bill,'DB',-1,NULL,NULL,NULL,NULL,NULL,
	    NULL,NULL,'NP',NULL,NULL,NULL,NULL,B_level,NULL);
	 update pcs.lab_claims set claim_status='N',change_date=SysDate where claim_id=C_id;
      else
	 P_code_area:='REBILL 3 '||C_lab;
	 select MAX(rebilling) into P_rebilling from pcs.billing_details
	 where lab_number=C_lab;

	 insert into pcs.billing_queue
	    (lab_number,billing_route,datestamp,billing_type,rebilling,rebill_code)
	 values (C_lab,'WKS',SysDate,'WKS',P_rebilling,null);
	 update pcs.lab_claims set claim_status='O',change_date=SysDate,
	    claim_comment=claim_comment||' CLAIM OLDER THAN 45 DAYS CANNOT BE DIRECT BILLED'
	 where lab_number=C_lab and claim_status=C_status;
      end if;
   end loop;
   close rebill_list;

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
      insert into pcs.error_log
	(error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values
	(P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,C_lab);

      commit;
      RAISE;

end;
\