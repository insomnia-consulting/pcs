/* PL/SQL procedure that prints CMS 1500 insurance claims forms. Assumes
 * printed is loaded with pre-printed forms, and program will print the
 * necessary data in the correct location on the forms.
 * 
 * May 2, 2013: FP modifier printing on WV DPA claims and should not be;
 * this was a transitional error (i.e. correction made after initial 
 * load of database. As of this comment, the FP modifier will now be
 * omitted from OH and WV Medicaid claims; any other states with
 * Medicaid claims the modifier will print on the form.
*/
create or replace procedure build_1500_claim_forms
(
   C_directory in char,
   C_file in char,
   C_billing_route in char
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);


   cursor claim_list is
      select
	    c.carrier_id,
	    SUBSTR(c.name,1,48),
	    c.address1,
	    c.address2,
	    c.city,
	    c.state,
	    c.zip,
	    c.payer_id,
	    bd.id_number,
	    bd.group_number,
	    bd.subscriber,
	    bd.sub_lname,
	    bd.sub_fname,
	    TO_CHAR(bd.sign_date,'MMDDYYYY'),
	    p.lname,
	    p.fname,
	    p.mi,
	    p.address1,
	    p.city,
	    p.state,
	    p.zip,
	    p.phone,
	    p.patient,
	    TO_CHAR(p.dob,'MMDDYYYY'),

	 pr.name,
	 lb.bill_amount,
	 TO_CHAR(lr.date_collected,'MMDDYYYY'),
	 bq.lab_number,
	 bq.rebilling,
	 pr.state,
	 NVL(lb.balance,lb.bill_amount),
	 lb.bill_amount-(NVL(lb.allowance,lb.bill_amount)),
	 TO_CHAR(lr.date_collected,'MM DD YY'),
	 NVL(bd.claim_id,-1),
	 c.provider_id,
	 bd.rebill_code,
	 lr.slide_qty,

	 lr.preparation
      from
	 pcs.carriers c, pcs.billing_details bd, pcs.patients p,
	 pcs.practices pr, pcs.lab_billings lb, pcs.billing_queue bq,
	 pcs.lab_requisitions lr, pcs.lab_results r
      where
	 bq.lab_number=lr.lab_number and
	 lr.lab_number=r.lab_number and
	 lr.lab_number=bd.lab_number and
	 lr.patient=p.patient and
	 lr.practice=pr.practice and
	 bd.carrier_id=c.carrier_id and
	 bd.lab_number=lb.lab_number and

	 bq.rebilling=bd.rebilling and
	 bq.billing_route=C_billing_route
      order by c.billing_choice,c.name,p.lname,p.fname;

   carrier_idnum number;
   carrier_name varchar2(256);
   carrier_addr1 varchar2(128);
   carrier_addr2 varchar2(128);
   carrier_city varchar2(64);
   carrier_state char(2);
   carrier_zip varchar2(16);
   carrier_pid varchar2(64);
   carrier_prov varchar2(64);

   policy_id varchar2(64);
   policy_group varchar2(64);
   policy_lname varchar2(64);
   policy_fname varchar2(64);
   policy_subscriber varchar2(32);
   policy_sign char(16);
   policy_rebill_code varchar2(16);
   patient_lname varchar2(64);
   patient_fname varchar2(64);
   patient_mi char(1);
   patient_addr varchar2(128);
   patient_city varchar2(64);
   patient_state char(2);

   patient_zip varchar2(16);
   patient_phone char(16);
   patient_id number;
   patient_dob char(16);
   practice_name varchar2(128);
   lab_completed char(16);
   lab_collected char(16);
   claim_total number;
   claim_lab_number number;
   lab_rebilling number;
   practice_state char(2);
   lab_balance number;
   total_loss number;

   lab_claim_id number;
   total_payments number;
   lab_vials number;
   lab_prep number;

   dr_lname varchar2(128);
   dr_fname varchar2(64);
   dr_mi char(1);
   dr_upin varchar(32);
   dr_number number;
   dr_license varchar2(32);
   dr_alt_license varchar2(32);
   dr_alt_state char(2);

   dr_title varchar2(32);
   dr_npi varchar2(16);

   diag_1 varchar2(32);
   diag_2 varchar2(32);
   diag_3 varchar2(32);
   diag_4 varchar2(32);
   diag_5 varchar2(32);
   diag_string varchar2(32);
   lab_CLIA varchar2(32);
   lab_tax_id varchar2(32);
   lab_pin_num varchar2(48);
   lab_npi varchar2(16);

   trav_med char(1);

   cursor diagnosis_list is
      select * from pcs.lab_req_diagnosis
      where lab_number=claim_lab_number and rebilling=lab_rebilling
      order by d_seq;
   diagnosis_fields diagnosis_list%ROWTYPE;

   cursor procedure_list is
      select bi.lab_number,bi.price_code,bi.procedure_code,
	 bi.item_amount,bi.rebilling,p.p_seq
      from pcs.lab_billing_items bi, pcs.procedure_codes p
      where bi.lab_number=claim_lab_number

      and bi.procedure_code=p.procedure_code
      and bi.item_amount>0
      order by p.p_seq;
   procedure_fields procedure_list%ROWTYPE;

   curr_line varchar2(512);
   cbuf1 varchar2(512);
   cbuf2 varchar2(512);
   cbuf3 varchar2(512);
   cbuf4 varchar2(512);
   margin varchar2(16);
   rcnt number;
   curr_item number;

   claim_batch_number number;
   claim_ebill char(1);
   C_tpp varchar2(16);
   C_claims number;
   C_choice_code varchar2(16);
   check_point number;
   num_diags number(1);
   last_carrier number;
   max_rebilling number;
   resubmitted number;
   C_status varchar2(2);
   tmp_num number;


   lbl_fname varchar2(48);
   file_handle UTL_FILE.FILE_TYPE;
   label_file UTL_FILE.FILE_TYPE;

begin

   P_proc_name:='BUILD_1500_CLAIM_FORMS';

   P_code_area:='PREP';
   check_point:=0;
   num_diags:=0;
   last_carrier:=0;
   trav_med:='N';


   select count(*) into C_claims
   from pcs.billing_queue where billing_route=C_billing_route;
   if (C_claims>0 and C_billing_route<>'DUP') then
      select pcs.claim_submission_seq.nextval into claim_batch_number from dual;
   end if;
   margin:='  ';
   C_tpp:=C_billing_route;

   P_code_area:='BATCH';
   if (C_claims>0 and C_billing_route<>'DUP') then
      insert into pcs.claim_batches
	 (batch_number,e_billing,number_of_claims,datestamp,sys_user,tpp)

      values
	 (claim_batch_number,'N',C_claims,SysDate,UID,C_tpp);
      insert into pcs.payer_batch_amounts
	 (carrier_id,batch_number,amount_submitted,amount_recorded,amount_received)
	    select distinct bd.carrier_id,claim_batch_number,0,0,0
	    from pcs.billing_details bd, pcs.lab_billings lb, pcs.billing_queue bq
	    where bd.lab_number=lb.lab_number and lb.lab_number=bq.lab_number
	       and bd.rebilling=lb.rebilling and bq.billing_route=C_billing_route;
   end if;

   select id_number into lab_CLIA from pcs.business_id_nums where id_code='CLIA';
   select id_number into lab_tax_id from pcs.business_id_nums where id_code='TAXID';
   select id_number into lab_npi from pcs.business_id_nums where id_code='NPI';


   P_code_area:='CHECK_NPI';
   pcs.check_npi_numbers(C_billing_route);

   file_handle:=UTL_FILE.FOPEN(C_directory,C_file,'w');

   if (C_billing_route='PPR') then
      lbl_fname:=C_file||'.lbl';
      label_file:=UTL_FILE.FOPEN(C_directory,lbl_fname,'w');
   end if;

   P_code_area:='CLAIMS';
   open claim_list;

   loop
      fetch claim_list into
	 carrier_idnum,
	 carrier_name,
	 carrier_addr1,
	 carrier_addr2,
	 carrier_city,
	 carrier_state,
	 carrier_zip,
	 carrier_pid,
	 policy_id,
	 policy_group,
	 policy_subscriber,

	 policy_lname,
	 policy_fname,
	 policy_sign,
	 patient_lname,
	 patient_fname,
	 patient_mi,
	 patient_addr,
	 patient_city,
	 patient_state,
	 patient_zip,
	 patient_phone,
	 patient_id,
	 patient_dob,

	 practice_name,
	 claim_total,
	 lab_completed,
	 claim_lab_number,
	 lab_rebilling,
	 practice_state,
	 lab_balance,
	 total_loss,
	 lab_collected,
	 lab_claim_id,
	 carrier_prov,
	 policy_rebill_code,
	 lab_vials,

	 lab_prep;
      exit when claim_list%NOTFOUND;

      resubmitted:=0;
      C_status:='*';
      P_code_area:='CLAIMS Q1';
      select count(*) into resubmitted from pcs.lab_claims
      where lab_number=claim_lab_number and claim_id=lab_claim_id;
      if (resubmitted>0) then
	 P_code_area:='CLAIMS Q2';
	 select claim_status into C_status
	 from pcs.lab_claims where claim_id=lab_claim_id;
	 if (C_status<>'B') then

	    resubmitted:=0;
	 end if;
      end if;

      P_code_area:='CLAIMS Q3 '||claim_lab_number;
      select MAX(rebilling) into max_rebilling from pcs.billing_details
      where lab_number=claim_lab_number;
      if (max_rebilling>lab_rebilling) then
	 P_code_area:='CLAIMS Q4';
	 select
	    c.carrier_id,c.name,c.address1,c.address2,c.city,c.state,
	    c.zip,c.payer_id,bd.id_number,bd.group_number,bd.subscriber,
	    bd.sub_lname,bd.sub_fname,TO_CHAR(bd.sign_date,'MMDDYYYY')

	 into
	    carrier_idnum,carrier_name,carrier_addr1,carrier_addr2,
	    carrier_city,carrier_state,carrier_zip,carrier_pid,
	    policy_id,policy_group,policy_subscriber,policy_lname,
	    policy_fname,policy_sign
	 from pcs.billing_details bd, pcs.carriers c
	 where bd.carrier_id=c.carrier_id and bd.rebilling=max_rebilling
	    and bd.lab_number=claim_lab_number;
      end if;

	--   The carrier_id for PA Medicaid is 1048; they have requested that
      --   thier name and address not be printed on the top of the paper
      --   form (12/29/2003 - jjc)

      P_code_area:='CLAIMS Q3.1';
      if ((C_billing_route='PPR'
      or C_billing_route='DUP' or C_billing_route='ENV') and carrier_idnum<>1048) then
	 UTL_FILE.NEW_LINE(file_handle);
	 cbuf1:=LPAD(' ',40);
	 curr_line:=cbuf1||carrier_name;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 curr_line:=cbuf1||carrier_addr1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 if (carrier_addr2 is not null) then
	    curr_line:=cbuf1||carrier_addr2;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 end if;

	 if (carrier_city is not null and carrier_state is not null
	 and carrier_zip is not null) then
	    curr_line:=cbuf1||carrier_city||', '||carrier_state||' '||carrier_zip;
	 else
	    curr_line:='  ';
	 end if;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 if (carrier_addr2 is not null) then
	    UTL_FILE.NEW_LINE(file_handle,3);
	 else
	    UTL_FILE.NEW_LINE(file_handle,4);
	 end if;
      else

	 UTL_FILE.NEW_LINE(file_handle,8);
      end if;

      P_code_area:='CLAIMS Q5';
      select A.choice_code into C_choice_code
      from pcs.billing_choices A, pcs.carriers B
      where A.billing_choice=B.billing_choice and B.carrier_id=carrier_idnum;

      P_code_area:='CLAIMS Q6';
      select NVL(SUM(payment_amount),0) into total_payments from pcs.payments P
      where P.payment_type<>'PLUS ADJUST' and P.lab_number=claim_lab_number;

      P_code_area:='CLAIMS Q6.001';

      select NVL(SUM(payment_amount),0) into tmp_num from pcs.payments P
      where P.payment_type='PLUS ADJUST' and P.lab_number=claim_lab_number;

      P_code_area:='CLAIMS Q6.002';
      total_payments:=total_payments-tmp_num;
      P_code_area:='CLAIMS Q6.003';

      if (carrier_idnum<>last_carrier) then
	 P_code_area:='CLAIMS Q6.334';
	 if (C_billing_route='PPR') then
	    if (carrier_addr1 is NOT NULL and carrier_city is NOT NULL and
	    carrier_state is NOT NULL and carrier_zip is NOT NULL) then
	       rcnt:=3;

	       curr_line:=SUBSTR(carrier_name,1,32);
	       UTL_FILE.PUTF(label_file,'%s\n',curr_line);
	       curr_line:=SUBSTR(carrier_addr1,1,32);
	       UTL_FILE.PUTF(label_file,'%s\n',curr_line);
	       if (carrier_addr2 is not null) then
		  rcnt:=2;
		  curr_line:=SUBSTR(carrier_addr2,1,32);
		  UTL_FILE.PUTF(label_file,'%s\n',curr_line);
	       end if;
	       cbuf1:=SUBSTR(carrier_zip,1,5);
	       if (length(carrier_zip)>5) then
		  cbuf2:=SUBSTR(carrier_zip,6,4);
		  cbuf1:=cbuf1||'-'||cbuf2;

	       end if;
	       curr_line:=SUBSTR(carrier_city||
		  ', '||carrier_state||' '||cbuf1,1,32);
	       UTL_FILE.PUTF(label_file,'%s\n',curr_line);
	       UTL_FILE.NEW_LINE(label_file,rcnt);
	       rcnt:=0;
	    end if;
	 end if;
      end if;

      UTL_FILE.NEW_LINE(file_handle);
      -- LINE 3
      cbuf1:=null;

      cbuf2:=null;
      curr_line:=null;
      -- BLOCK #1
      if (carrier_name='CHAMPUS') then
	 cbuf1:=LPAD('X',14);
      elsif (C_choice_code='DPA') then
	 cbuf1:=LPAD('X',7);
	 policy_subscriber:='SELF';
	 if (carrier_state='WV') then
	    P_code_area:='CLAIMS Q8';
	    select id_number into lab_pin_num
	    from pcs.business_id_nums where id_code='WVPR';
	 elsif (carrier_state='OH') then

	    P_code_area:='CLAIMS Q9';
	    select '  '||id_number into lab_pin_num
	    from pcs.business_id_nums where id_code='OHPR';
	 elsif (carrier_state='PA') then
	    P_code_area:='CLAIMS Q10';
	    select id_number into lab_pin_num
	    from pcs.business_id_nums where id_code='PAPR';
	 elsif (carrier_state='AL') then
	    select id_number into lab_pin_num
	    from pcs.business_id_nums where id_code='ALPR';
	 end if;
      elsif (C_choice_code='MED' and SUBSTR(policy_id,1,1)>='A'
      and SUBSTR(policy_id,1,1)<='Z') then

	 cbuf1:='X';
	 select id_number into lab_pin_num
	 from pcs.business_id_nums where id_code='TMPR';
	 trav_med:='Y';
      else
	 cbuf1:=LPAD('X',44);
	 if (C_choice_code='BS') then
	    select id_number into lab_pin_num
	    from pcs.business_id_nums where id_code='BSPR';
	 end if;
      end if;
      -- BLOCK #1A
      curr_line:=RPAD(cbuf1,50)||policy_id;

      curr_line:=margin||curr_line;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 5
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      -- BLOCK #2
      cbuf1:=rtrim(patient_lname)||', '||rtrim(patient_fname)||' '||patient_mi;
      cbuf1:=substr(cbuf1,1,28);
      cbuf1:=RPAD(cbuf1,28);
      
      /* This block of code removed 04/18/13; it prevented the patient's DOB from
       * being printed on the form. Code commented out for now pending testing
       * of a batch of paper claims. The goto statement label must also be removed.
      if (C_choice_code='DPA' and carrier_state='OH') then
	     goto skip_ln5;
      end if;
      */
      
      -- BLOCK #3
      if (patient_dob is not null) then
	 if (carrier_idnum=23744) then
	    cbuf1:=cbuf1||' '||substr(patient_dob,1,2);
	    cbuf1:=cbuf1||' '||substr(patient_dob,3,2);
	    cbuf1:=cbuf1||' '||substr(patient_dob,7,2)||'  ';
	 else
	    cbuf1:=cbuf1||' '||substr(patient_dob,1,2);
	    cbuf1:=cbuf1||' '||substr(patient_dob,3,2);
	    cbuf1:=cbuf1||' '||substr(patient_dob,5,4);
	 end if;
	 /* Fix for F sex field being printe in problem location on form 
	  */
     cbuf1:=cbuf1||'       X'
      else
                           
	 cbuf1:=cbuf1||'	   ';
      end if;
                           
      cbuf1:=cbuf1||'	   X';
      -- BLOCK #4
     if (policy_subscriber='SELF' and C_billing_route<>'PPR') then
	    cbuf1:=cbuf1||'  '||'SAME';
     elsif (carrier_idnum=1048) then
	 -- do nothing
	 cbuf1:=cbuf1;
      elsif (C_choice_code<>'MED') then
	 cbuf2:=rtrim(policy_lname)||', '||rtrim(policy_fname);
	 cbuf2:=substr(cbuf2,1,29);

	 cbuf1:=cbuf1||'   '||cbuf2;
      end if;
      /*
      <<skip_ln5>>
      */
      curr_line:=margin||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 7
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_choice_code='DPA' and carrier_state='OH') then
	 -- BLOCK #6 (5 IS BLANK)

	 cbuf1:=LPAD('X',33);
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      else
	 -- BLOCK #5
	 cbuf1:=rtrim(patient_addr);
	 cbuf1:=substr(cbuf1,1,29);
	 if (cbuf1 IS NULL) then
	    cbuf1:=' ';
	 end if;
	 cbuf1:=RPAD(cbuf1,29);
	 -- BLOCK #6

	 if (policy_subscriber='SELF') then
	    cbuf1:=cbuf1||'  X		      ';
	 elsif (policy_subscriber='SPOUSE') then
	    cbuf1:=cbuf1||'	  X	      ';
	 elsif (policy_subscriber='DEPENDENT') then
	    cbuf1:=cbuf1||'	      X       ';
	 else
	    cbuf1:=cbuf1||'		  X   ';
	 end if;
	 if (C_billing_route<>'PPR') then
	    cbuf1:=cbuf1||'SAME';
	 end if;
	 curr_line:=margin||cbuf1;

	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      end if;

      -- LINE 9
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_choice_code='DPA' and carrier_state='OH') then
	 UTL_FILE.NEW_LINE(file_handle,2);
      else
	 cbuf1:=rtrim(patient_city);
	 cbuf1:=substr(patient_city,1,24);

	 cbuf1:=RPAD(cbuf1,24)||' '||patient_state;
	 -- defaulting marital status to other
	 cbuf1:=RPAD(cbuf1,45)||'X';
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      end if;

      -- LINE 11
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_choice_code='DPA' and carrier_state='OH') then

	 UTL_FILE.NEW_LINE(file_handle,2);
      else
	 cbuf1:=rtrim(patient_zip);
	 cbuf1:=RPAD(cbuf1,14);
	 cbuf2:=substr(patient_phone,1,3);
	 cbuf1:=cbuf1||cbuf2;
	 cbuf1:=RPAD(cbuf1,18);
	 cbuf2:=substr(patient_phone,4,7);
	 cbuf1:=cbuf1||cbuf2;
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      end if;


      -- LINE 13
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_choice_code='DPA') then
	 UTL_FILE.NEW_LINE(file_handle,2);
      else
	 if (C_choice_code='MED' or C_choice_code='OI') then
	    cbuf1:='N/A';
	 else
	    cbuf1:='SAME';
	 end if;

	 cbuf1:=RPAD(cbuf1,49);
	 if (C_choice_code='MED') then
	    cbuf1:=cbuf1||'NONE';
	 else
	    cbuf1:=cbuf1||substr(policy_group,1,29);
	 end if;
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      end if;

      -- LINE 15
      cbuf1:=null;

      cbuf2:=null;
      curr_line:=null;
      if (C_choice_code='DPA' and carrier_state='WV') then
	 UTL_FILE.NEW_LINE(file_handle,2);
      else
	 cbuf1:=LPAD('X',40);
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      end if;

      -- LINE 17
      cbuf1:=null;

      cbuf2:=null;
      curr_line:=null;
      if (C_choice_code='DPA' and carrier_state='WV') then
	 UTL_FILE.NEW_LINE(file_handle,2);
      else
	 cbuf1:=LPAD('X',40);
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      end if;

      -- LINE 19
      cbuf1:=null;

      cbuf2:=null;
      curr_line:=null;
      if (C_choice_code='DPA' and carrier_state='WV') then
	 UTL_FILE.NEW_LINE(file_handle,2);
      else
	 cbuf1:=LPAD('X',40);
	 cbuf1:=RPAD(cbuf1,49);
	 if (C_billing_route='ENV') then
	    cbuf1:=cbuf1||carrier_pid;
	 end if;
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);

      end if;

      -- LINE 21 (no data)
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_billing_route='ENV') then
	 if (carrier_pid is NULL) then
	    cbuf1:=LPAD(' ',56);
	    cbuf1:=cbuf1||'X';
	    curr_line:=margin||cbuf1;
	 else
	    cbuf1:=LPAD(' ',30)||carrier_pid;

	    cbuf1:=RPAD(cbuf1,54);
	    cbuf1:=cbuf1||'X';
	    curr_line:=margin||cbuf1;
	 end if;
      end if;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 23 (no data)
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 25 (no data; signatures)
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_billing_route='PPR' or C_billing_route='DUP') then
	 if (C_choice_code<>'DPA') then
	    cbuf1:=LPAD('SIGNATURE ON FILE',31);
	    cbuf2:=LPAD(lab_collected,22);
	    curr_line:=cbuf1||cbuf2||LPAD('SIGNATURE ON FILE',22);
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    UTL_FILE.NEW_LINE(file_handle);

	 -- 1048 is PA DPA
	 elsif (carrier_idnum=1048) then
	    cbuf1:=LPAD('SIGNATURE EXCEPTION',27);
	    cbuf2:=LPAD(TO_CHAR(SysDate,'MMDDYYYY'),20);
	    curr_line:=cbuf1||cbuf2;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	    UTL_FILE.NEW_LINE(file_handle);
	 else
	    UTL_FILE.NEW_LINE(file_handle,2);
	 end if;
      else
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);

      end if;

      -- LINE 27 (no data)
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      -- LINE 29
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      P_code_area:='CLAIMS Q13';

      select doctor into dr_number from pcs.lab_requisitions
      where lab_number=claim_lab_number;
      P_code_area:='CLAIMS Q14';
      select lname,fname,mi,upin,license,alt_license,alt_state,title,npi
      into dr_lname,dr_fname,dr_mi,dr_upin,dr_license,dr_alt_license,
	 dr_alt_state,dr_title,dr_npi
      from pcs.doctors where doctor=dr_number;
      cbuf1:=rtrim(dr_fname);
      if (dr_mi is not null) then
	 cbuf1:=cbuf1||' '||dr_mi;
      end if;
      cbuf1:=cbuf1||' '||rtrim(dr_lname);
      if (dr_title is NOT NULL) then

	 cbuf1:=cbuf1||' '||RTRIM(LTRIM(dr_title));
      end if;
      if (dr_upin is null) then
	 cbuf2:='	 ';
      elsif (C_choice_code='BS' or C_choice_code='MED') then
	 cbuf2:='	 ';
      else
	 cbuf2:='1G '||dr_upin;
      end if;
      if (C_choice_code='DPA') then
	 cbuf2:=REPLACE(dr_license,' ');
	 if (dr_alt_state is NOT NULL and carrier_state=dr_alt_state) then
	    cbuf2:=REPLACE(dr_alt_license,' ');

	 end if;
	 cbuf2:='0B '||cbuf2;
      end if;
      if (cbuf2 IS NOT NULL) then
	 cbuf3:=' ';
	 cbuf3:=RPAD(cbuf3,31);
	 curr_line:=cbuf3||cbuf2;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      else
	 UTL_FILE.NEW_LINE(file_handle);
      end if;
      --cbuf2:=dr_npi;
      cbuf1:=RPAD(cbuf1,29);

      --cbuf1:=cbuf1||cbuf2;
      curr_line:=margin||cbuf1;
      if (dr_npi is NOT NULL) then
	 curr_line:=curr_line||'   '||dr_npi;
      end if;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 31
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      -- PA DPA is 1048 and puts 1/11 in 19.Reserved for local use;

      --   this is only when 1048 is secondary carrier (SEC)
      --   02/10 changed from 1/11 to AT11
      if (carrier_idnum=1048 and policy_rebill_code='SEC') then
	 curr_line:=margin||'AT11';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 UTL_FILE.NEW_LINE(file_handle);
      else
	 UTL_FILE.NEW_LINE(file_handle,2);
      end if;

      diag_1:=null;
      diag_2:=null;
      diag_3:=null;

      diag_4:=null;
      P_code_area:='DIAGNOSIS';
      open diagnosis_list;
      loop
	 fetch diagnosis_list into diagnosis_fields;
	 exit when diagnosis_list%NOTFOUND;
	 if (diagnosis_fields.d_seq=1) then
	    diag_1:=diagnosis_fields.diagnosis_code;
	 elsif (diagnosis_fields.d_seq=2) then
	    diag_2:=diagnosis_fields.diagnosis_code;
	 elsif (diagnosis_fields.d_seq=3) then
	    diag_3:=diagnosis_fields.diagnosis_code;
	 elsif (diagnosis_fields.d_seq=4) then

	    diag_4:=diagnosis_fields.diagnosis_code;
	 end if;
      end loop;
      close diagnosis_list;
      -- for PA DPA 1048
      if (carrier_idnum=1048) then
	 diag_1:='LAB16 ';
	 diag_2:=NULL;
	 diag_3:=NULL;
	 diag_4:=NULL;
      end if;

      -- LINE 33

      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (diag_1 is not null) then
	 cbuf2:=REPLACE(diag_1,'.',' ');
	 cbuf1:='  '||cbuf2;
      end if;
      if (diag_3 is not null) then
	 cbuf2:=REPLACE(diag_3,'.',' ');
	 cbuf2:=LPAD(cbuf2,26);
	 cbuf1:=cbuf1||cbuf2;
      end if;
      curr_line:=margin||cbuf1;

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 35
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (diag_2 is not null) then
	 cbuf2:=REPLACE(diag_2,'.',' ');
	 cbuf1:='  '||cbuf2;
      end if;
      if (diag_4 is not null) then
	 cbuf2:=REPLACE(diag_4,'.',' ');

	 cbuf2:=LPAD(cbuf2,27);
	 cbuf1:=cbuf1||cbuf2;
      end if;
      if (cbuf1 is null) then
	 cbuf1:=RPAD(' ',49);
      else
	 cbuf1:=RPAD(cbuf1,49);
      end if;
      if (C_billing_route='ENV' or C_choice_code='MED') then
	 cbuf1:=cbuf1||rtrim(lab_CLIA);
      end if;
      curr_line:=margin||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 37 (no data)
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      --UTL_FILE.NEW_LINE(file_handle);

      -- LINES 39 to 49
      -- param diag_string used for box 24E on form
      -- diag_5 is a temporary place holder
      diag_5:=null;

      if (diag_1 is not null) then
	 diag_5:='1';
      end if;
      if (diag_2 is not null) then
	 diag_5:=diag_5||'2';
      end if;
      if (diag_3 is not null) then
	 diag_5:=diag_5||'3';
      end if;
      if (diag_4 is not null) then
	 diag_5:=diag_5||'4';
      end if;
      if (diag_5 is null) then

	 diag_5:=' ';
      end if;
      rcnt:=0;
      P_code_area:='PROCEDURE';
      open procedure_list;
      loop
	 fetch procedure_list into procedure_fields;
	 exit when procedure_list%NOTFOUND;
	 rcnt:=rcnt+1;
	 cbuf1:=null;
	 cbuf2:=null;
	 curr_line:=null;
	 --   For a one day only service PA DPA does not want to

	 --   see the same date twice (i.e both TO and FROM)
	 --   As per current specs PA DPA was getting DOS 
	 --   on form once; all Alabama were getting it
	 --  twice, and then everyone else twice
	 if (carrier_idnum=1048) then
	    cbuf1:=lab_completed||'       ';
	 elsif (carrier_idnum=23744) then
	    cbuf2:=SUBSTR(lab_completed,1,2)||' ';
	    cbuf2:=cbuf2||SUBSTR(lab_completed,3,2)||' ';
	    cbuf2:=cbuf2||SUBSTR(lab_completed,7,2);
	    cbuf1:=cbuf2||' '||cbuf2;
	 else
	    cbuf1:=lab_completed||' '||lab_completed;
	 end if;
	 -- PLACE OF SERVICE (24B)


	 -- Type of Service code eliminated on new claim form
	 cbuf1:=RPAD(cbuf1,11 )||'       81';
	 -- PROCEDURE CODE AND MODIFIERS (24D)

	 cbuf1:=RPAD(cbuf1,24)||procedure_fields.procedure_code;
	 if (C_choice_code='MED' and policy_sign is NOT NULL) then
	    cbuf1:=cbuf1||'  GA';
	 -- AS PER LISA INCLUDE FP MODIFIER ON ALL DPA PROCEDURE CODES (2/4/9)
	 -- 5/2/13: Exclude WV (carrier_id=1047) from modifier along
	 -- with OH (1046)
	 elsif (C_choice_code='DPA' AND carrier_idnum NOT IN (1046,1047)) then
	    cbuf1:=cbuf1||'  FP';
	 end if;
	 -- THIS IS WHERE THE DIAGNOSIS POINTER GOES (24E)


	 --   The procedure codes 88141 and 87621 should not include
	 --   diag_1, so we extract the '1,' from diag_5 into diag_string
	 if (procedure_fields.procedure_code IN ('88141','87621')) then
	    -- For Alabama DPA is 23744
	    if (carrier_idnum=23744) then
	       diag_string:='2';
	    else
	       diag_string:=REPLACE(diag_5,'1,');
	    end if;
	 else
	    if (carrier_idnum=23744) then
	       diag_string:='1';
	    else
	       diag_string:=diag_5;
	    end if;
	 end if;
	 if (trav_med='Y') then
	    diag_string:='1';
	 end if;
	 cbuf1:=RPAD(cbuf1,43)||RPAD(diag_string,7);
	 cbuf1:=RPAD(cbuf1,47);
	 curr_item:=procedure_fields.item_amount;
	 curr_line:=TO_CHAR(curr_item,'99999.99');
	 cbuf2:=substr(curr_line,1,6);
	 cbuf2:=LTRIM(cbuf2);
	 cbuf2:=RTRIM(cbuf2);

	 cbuf2:='  '||LPAD(cbuf2,5);
	 cbuf1:=cbuf1||cbuf2||' ';
	 cbuf2:=substr(curr_line,8,2);
	 cbuf1:=cbuf1||cbuf2;
	 -- Units:  always one, unless biopsies we go with number of vials */
	 if (lab_prep=6) then
	    cbuf3:=RTRIM(LTRIM(TO_CHAR(lab_vials)));
	 else
	    cbuf3:='1';
	 end if;
	 cbuf1:=RPAD(cbuf1,58)||cbuf3;
	 cbuf1:=cbuf1||'       '||lab_npi;
	 curr_line:=margin||cbuf1;
	 curr_line:=REPLACE(curr_line,' 081 ','  81 ');
	 curr_line:=REPLACE(curr_line,' 181 ','  81 ');
	 -- PA DPA IS 1048
	 if (carrier_idnum=1048) then
	    cbuf1:=RPAD(' ',65)||'1D '||carrier_prov;
	    UTL_FILE.PUTF(file_handle,'%s\n',cbuf1);

	 elsif (trav_med='Y') then
	    cbuf1:=RPAD(' ',65)||'1C';
	       UTL_FILE.PUTF(file_handle,'%s\n',cbuf1);
	     else
	       UTL_FILE.NEW_LINE(file_handle);
	     end if;
	     UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      end loop;
      close procedure_list;
      for ndx in (rcnt+1)..6 loop
	 cbuf1:=null;
	 cbuf2:=null;

	 curr_line:=null;
	 UTL_FILE.NEW_LINE(file_handle,2);
      end loop;
      UTL_FILE.NEW_LINE(file_handle);

      -- LINE 51
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      /* Note there was a comment to get rid of the old EIN after
       * Nov. 29, 2006; this was reoved today (06/13/2013
       */
      cbuf1:=RPAD(lab_tax_id,18)||'X';
      --cbuf1:=RPAD(cbuf1,22);
      cbuf2:='	'||SUBSTR(RTRIM(LTRIM(TO_CHAR(claim_lab_number))),3);
      cbuf1:=cbuf1||cbuf2;
      if (C_choice_code='DPA') then
	 	cbuf1:=RPAD(cbuf1,37)||' ';
      else
	 	cbuf1:=RPAD(cbuf1,35)||'X';
      end if;
      
      cbuf1:=RPAD(cbuf1,47);
      
      cbuf2:=TO_CHAR(claim_total,'999990.99');
      
      curr_line:=substr(cbuf2,1,7);
      curr_line:=LTRIM(curr_line);
      curr_line:=RTRIM(curr_line);
      cbuf2:=LPAD(curr_line,7);
      cbuf1:=cbuf1||cbuf2||' ';
      cbuf2:=TO_CHAR(claim_total,'999990.99');
      curr_line:=substr(cbuf2,9,2);

      cbuf1:=cbuf1||curr_line;

      -- PA DPA is 1048
      if (carrier_idnum<>1048) then
		 cbuf2:=TO_CHAR(total_payments,'99990.99');
		 curr_line:=substr(cbuf2,1,6);
		 curr_line:=LTRIM(curr_line);
		 curr_line:=RTRIM(curr_line);
		 cbuf2:=LPAD(curr_line,6);
		 cbuf3:=cbuf1||cbuf2||' ';
		 cbuf2:=TO_CHAR(total_payments,'99990.99');
		 curr_line:=substr(cbuf2,8,2);
		 cbuf3:=cbuf3||curr_line;
	
		 cbuf2:=TO_CHAR(claim_total-total_payments,'99990.99');
		 curr_line:=substr(cbuf2,1,6);
		 curr_line:=LTRIM(curr_line);
		 curr_line:=RTRIM(curr_line);
		 cbuf2:=LPAD(curr_line,6);
		 cbuf1:=cbuf3||cbuf2||'  ';
		 --cbuf2:=TO_CHAR(lab_balance,'99990.99');
		 cbuf2:=TO_CHAR(claim_total-total_payments,'99990.99');
		 curr_line:=substr(cbuf2,8,2);
		 cbuf1:=cbuf1||curr_line;
      end if;
      curr_line:=margin||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);


      cbuf2:=LPAD(' ',64);
      cbuf1:=cbuf2||'412 373 8300';
      curr_line:=margin||cbuf1;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      -- LINE 53
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_billing_route='ENV') then
	 cbuf1:=LPAD('SAME',26);
	 cbuf1:=RPAD(cbuf1,49);

	 cbuf1:=cbuf1||'PA CYTOLOGY SERVICES G';
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      elsif (carrier_idnum=1048) then
	 cbuf1:=LPAD(' ',26);
	 cbuf1:=RPAD(cbuf1,49);
	 cbuf1:=cbuf1||'PA CYTOLOGY SERVICES';
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      else
	 if (C_choice_code='DPA' or C_choice_code='OI') then
	    cbuf1:=LPAD('    ',26);
	    cbuf1:=RPAD(cbuf1,49);

	    if (carrier_idnum=1048) then
	       cbuf1:=cbuf1||'				 ';
	    else
	       cbuf1:=cbuf1||'PENNSYLVANIA CYTOLOGY SERV';
	    end if;
	    curr_line:=margin||cbuf1;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 elsif (C_choice_code='MED' or C_choice_code='BS') then
	    cbuf1:=LPAD(' ',22)||'PENNSYLVANIA CYTOLOGY SERV';
	    cbuf1:=RPAD(cbuf1,49);
	    cbuf1:=cbuf1||'PENNSYLVANIA CYTOLOGY SERV';
	    curr_line:=margin||cbuf1;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

	 end if;
      end if;

      -- LINE 54
      cbuf1:=null;
      cbuf2:=null;
      curr_line:=null;
      if (C_billing_route='ENV') then
	 cbuf1:='339 OLD HAYMAKER ROAD';
	 cbuf2:=LPAD(' ',49);
	 cbuf1:=cbuf2||cbuf1;
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      elsif (C_choice_code='DPA' or C_choice_code='OI') then
	    if (C_choice_code='DPA') then
	       cbuf1:=LPAD(' ',26);
	    -- hardcoded for Molina Healthcare
	    elsif (carrier_idnum=23663) then
	       cbuf1:='PA CYTOLOGY SERVICES  SAME';
	    else
	       cbuf1:=LPAD('SAME',26);
	    end if;
	    cbuf1:=RPAD(cbuf1,49);
	    cbuf1:=cbuf1||'339 HAYMAKER RD STE 1700';
	    curr_line:=margin||cbuf1;

	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 elsif (C_choice_code='MED' or C_choice_code='BS') then
	    cbuf1:=LPAD(' ',22)||'339 HAYMAKER RD S 1700';
	    cbuf1:=RPAD(cbuf1,49);
	    cbuf1:=cbuf1||'339 HAYMAKER RD STE 1700';
	    curr_line:=margin||cbuf1;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 end if;
      end if;

      -- LINE 55
      cbuf1:=null;
      cbuf2:=null;

      curr_line:=null;
      -- values hardcoded for UPMC HealthPlan with Pgh addresses
      if (carrier_idnum in (2575,2695,4008)) then
	 cbuf2:=RPAD('R H SWEDARSKY  ',49);
	 cbuf1:=cbuf2||'MONROEVILLE PA	15146';
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      elsif (carrier_idnum=23524) then
	 cbuf2:=RPAD('SIGNATURE ON FILE',49);
	 cbuf1:=cbuf2||'MONROEVILLE PA	15146';
	 curr_line:=margin||cbuf1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      else

	 if (C_choice_code='DPA' or C_choice_code='OI') then
	    -- hardcoded OH provider for Molina Healthcare
	    if (carrier_idnum=23663) then
	       cbuf1:=LPAD('2478948',20)||'	 ';
	    else
	       cbuf1:=LPAD(' ',26);
	    end if;
	    cbuf1:=RPAD(cbuf1,49);
	    cbuf1:=cbuf1||'MONROEVILLE, PA 15146';
	    curr_line:=margin||cbuf1;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 elsif (C_choice_code='MED' or C_choice_code='BS') then
	    cbuf1:=LPAD(' ',22)||'MONROEVILLE, PA 15146';

	    cbuf1:=RPAD(cbuf1,49);
	    cbuf1:=cbuf1||'MONROEVILLE, PA 15146';
	    curr_line:=margin||cbuf1;
	    UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 end if;
      end if;

     -- LINE 56
     cbuf1:=NULL;
     cbuf2:=NULL;
     cbuf3:=NULL;
     cbuf2:=LPAD(' ',14);
     cbuf1:=RPAD(lab_npi,11);

     if (carrier_prov IS NOT NULL) then
	if (C_choice_code='DPA') then
	   cbuf2:=carrier_prov;
	elsif (C_choice_code='BS') then
	   cbuf2:='1B'||carrier_prov;
	elsif (C_choice_code='MED') then
	   cbuf2:='		   ';
	else
	   cbuf2:='G2'||carrier_prov;
	end if;
	cbuf2:=RPAD(cbuf2,16);
     else
	cbuf2:=RPAD(' ',16);

     end if;
     cbuf3:=RPAD(' ',22);
     cbuf4:=RPAD(' ',27);
     -- PA DPA IS 1048
     if (carrier_idnum=1048) then
	curr_line:=margin||cbuf3||cbuf4||cbuf1||cbuf2;
     else
	--if (trav_med='Y') then
	--   curr_line:=margin||cbuf3||cbuf1||cbuf2||cbuf1;
	--else
	   curr_line:=margin||cbuf3||cbuf1||cbuf2||cbuf1||cbuf2;
	--end if;
     end if;

     UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
     UTL_FILE.NEW_LINE(file_handle,3);

      if (C_claims>0 and C_billing_route<>'DUP') then
	 P_code_area:='CLAIMS Q15';
	 update pcs.payer_batch_amounts set
	    amount_submitted=amount_submitted+(claim_total-total_payments)
	 where carrier_id=carrier_idnum and batch_number=claim_batch_number;
	 if (resubmitted=0) then
	    P_code_area:='CLAIMS Q16';
	    select pcs.claim_seq.nextval into lab_claim_id from dual;
	    insert into pcs.lab_claims (claim_id,lab_number,batch_number,
	       claim_status,datestamp,change_date)

	    values (lab_claim_id,claim_lab_number,claim_batch_number,
	       'S',SysDate,SysDate);
	    update pcs.billing_details
	    set claim_id=lab_claim_id, date_sent=SysDate
	    where lab_number=claim_lab_number and rebilling=lab_rebilling;
	    update pcs.lab_requisitions set finished=2
	    where lab_number=claim_lab_number and finished<=2;
	 else
	    update pcs.lab_claims
	    set batch_number=claim_batch_number,datestamp=SysDate,change_date=SysDate
	    where claim_id=lab_claim_id;
	 end if;
      end if;


      last_carrier:=carrier_idnum;

   end loop;
   close claim_list;

   delete from pcs.billing_queue where billing_route=C_billing_route;
   if (C_claims>0 and C_billing_route<>'DUP') then
      insert into pcs.claim_submissions (batch_number,tpp,submission_number,creation_date)
      values (claim_batch_number,C_billing_route,1,SysDate);
   end if;

   UTL_FILE.FCLOSE(file_handle);

   if (C_billing_route='PPR') then
      UTL_FILE.FCLOSE(label_file);
   end if;
   commit;

exception
   when UTL_FILE.INVALID_PATH then
      UTL_FILE.FCLOSE(file_handle);
      if (C_billing_route='PPR') then
	 UTL_FILE.FCLOSE(label_file);
      end if;
      RAISE_APPLICATION_ERROR(-20051,'invalid path');
   when UTL_FILE.INVALID_MODE then

      UTL_FILE.FCLOSE(file_handle);
      if (C_billing_route='PPR') then
	 UTL_FILE.FCLOSE(label_file);
      end if;
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');
   when UTL_FILE.INVALID_FILEHANDLE then
      UTL_FILE.FCLOSE(file_handle);
      if (C_billing_route='PPR') then
	 UTL_FILE.FCLOSE(label_file);
      end if;
      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');
   when UTL_FILE.INVALID_OPERATION then
      UTL_FILE.FCLOSE(file_handle);

      if (C_billing_route='PPR') then
	 UTL_FILE.FCLOSE(label_file);
      end if;
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');
   when UTL_FILE.READ_ERROR then
      UTL_FILE.FCLOSE(file_handle);
      if (C_billing_route='PPR') then
	 UTL_FILE.FCLOSE(label_file);
      end if;
      RAISE_APPLICATION_ERROR(-20055,'read error');
   when UTL_FILE.WRITE_ERROR then
      UTL_FILE.FCLOSE(file_handle);
      if (C_billing_route='PPR') then

	 UTL_FILE.FCLOSE(label_file);
      end if;
      RAISE_APPLICATION_ERROR(-20056,'write error');
   when OTHERS then
      UTL_FILE.FCLOSE(file_handle);
      if (C_billing_route='PPR') then
	 UTL_FILE.FCLOSE(label_file);
      end if;
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,claim_lab_number);
      commit;

      RAISE;
end;
\

grant execute on build_1500_claim_forms to pcs_user
\
