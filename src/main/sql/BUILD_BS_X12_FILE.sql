create or replace procedure build_bs_x12_file
(
   C_directory in char,
   C_file in char,
   C_billing_route in varchar2,
   C_retran_status in number,
   test_indicator in char
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);

   P_code_area varchar2(32);

   cursor claim_list is
      select
	 c.carrier_id,
	 c.name,
	 RTRIM(LTRIM(bd.id_number)),
	 bd.group_number,
	 bd.subscriber,
	 bd.sub_lname,
	 bd.sub_fname,
	 TO_CHAR(bd.sign_date,'MMDDYYYY'),
	 p.lname,

	 p.fname,
	 p.mi,
	 LTRIM(RTRIM(SUBSTR(p.address1,1,30))),
	 LTRIM(RTRIM(p.city)),
	 p.state,
	 p.zip,
	 p.phone,
	 p.patient,
	 TO_CHAR(p.dob,'YYYYMMDD'),
	 pr.name,
	 lb.bill_amount,
	 TO_CHAR(lr.date_collected,'YYYYMMDD'),
	 bq.lab_number,

	 bq.rebilling,
	 NVL(lb.balance,lb.bill_amount),
	 lr.doctor,
	 NVL(bd.claim_id,-1),
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
      order by c.name,p.lname,p.fname;

   carrier_idnum number;
   carrier_name varchar2(128);
   policy_id varchar2(32);
   policy_group varchar2(32);

   policy_subscriber varchar2(16);
   policy_lname varchar2(32);
   policy_fname varchar2(32);
   policy_sign char(8);
   patient_lname varchar2(32);
   patient_fname varchar2(32);
   patient_mi char(1);
   patient_addr varchar2(64);
   patient_city varchar2(32);
   patient_state char(2);
   patient_zip varchar2(9);
   patient_phone char(10);
   patient_id number;

   patient_dob char(8);
   practice_name varchar2(64);
   claim_total number;
   lab_collected char(8);
   claim_lab_number number;
   lab_rebilling number;
   lab_balance number;
   lab_doctor number;
   lab_claim_id number;
   lab_vials number;
   lab_prep number;

   patient_payments number;


   dr_lname varchar2(32);
   dr_fname varchar2(32);
   dr_npi varchar2(16);

   lab_CLIA varchar2(16);
   lab_tax_id varchar2(12);

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

   curr_line varchar2(4000);
   cbuf1 varchar2(1000);

   cbuf2 varchar2(1000);
   cbuf3 varchar2(80);
   rcnt number;
   claim_batch_number number;
   claim_ebill char(1);
   C_tpp varchar2(5);
   C_claims number;
   num_diags number(1);
   last_carrier number;
   resubmitted number;
   C_status varchar2(2);

   x12_fname varchar2(13);

   file_handle UTL_FILE.FILE_TYPE;

   /************************************/
   sender_id varchar2(15);
   receiver_id varchar2(15);
   trading_id varchar2(32);
   security_id varchar2(32);
   interchange_date char(6);
   interchange_time varchar2(6);
   interchange_number varchar2(9);
   interchange_control_header varchar2(4000);
   date_today char(8);


   functional_group_header varchar2(4000);
   transaction_set_header varchar2(4000);
   transaction_ref char(2);
   trx_set_control_num char(6);
   group_control_num varchar2(9);

   NPI_id varchar2(64);

   /* Health Care Provider Taxonomy Code */
   PXC_taxonomy_code CONSTANT varchar2(50) := '291U00000X';
   /* Place of Service Code for Professional Services */
   POS_code CONSTANT varchar2(2) := '81';
   /* Implementation Convention Reference */

   impl_conv_ref CONSTANT varchar2(16) := '005010X222A1';

   insurer_type char(2);

   segment_count number;
   HL_count number;

begin

   P_proc_name:='BUILD_BS_X12_FILE';
   P_code_area:='PREP';

   num_diags:=0;

   last_carrier:=0;

   select count(*) into C_claims
   from pcs.billing_queue where billing_route=C_billing_route;
   if (C_claims>0 and C_billing_route<>'DUP') then
      if (C_retran_status=0) then
	 select pcs.claim_submission_seq.nextval into claim_batch_number from du
al;

	 transaction_ref:='01';
	 C_tpp:=C_billing_route;
      else
	 claim_batch_number:=C_retran_status;

	 select LTRIM(RTRIM(TO_CHAR((MAX(submission_number)+1),'09')))
	 into transaction_ref from pcs.claim_submissions
	 where batch_number=claim_batch_number;
	 select tpp into C_tpp
	 from pcs.claim_batches where batch_number=claim_batch_number;
      end if;
   end if;

   P_code_area:='CHECK_NPI';
   pcs.check_npi_numbers(C_billing_route);

   claim_ebill:='Y';
   if (C_claims>0 and C_billing_route<>'DUP' and C_retran_status=0) then

      insert into pcs.claim_batches
	 (batch_number,e_billing,number_of_claims,datestamp,sys_user,tpp)
      values
	 (claim_batch_number,claim_ebill,C_claims,SysDate,UID,C_tpp);
   end if;

   select id_number into receiver_id from pcs.business_id_nums where id_code='DA
SID';

   select id_number into sender_id from pcs.business_id_nums where id_code=C_tpp
;

   select id_number into lab_CLIA from pcs.business_id_nums where id_code='CLIA'

;

   select id_number into NPI_id from pcs.business_id_nums where id_code='NPI';
   select id_number into security_id from pcs.business_id_nums where id_code='DA
SSECID';

   select id_number into trading_id from pcs.business_id_nums where id_code='DAS
TRID';

   select REPLACE(id_number,'-') into lab_tax_id
   from pcs.business_id_nums where id_code='TAXID';

   HL_count:=1;


   select TO_CHAR(SysDate,'YYMMDD') into interchange_date from dual;
   select TO_CHAR(SysDate,'YYYYMMDD') into date_today from dual;
   select TO_CHAR(SysDate,'HH24MI') into interchange_time from dual;
   interchange_number:=LTRIM(RTRIM(TO_CHAR(claim_batch_number)));

   x12_fname:=transaction_ref||LTRIM(RTRIM(TO_CHAR(claim_batch_number,'000009'))
);

   file_handle:=UTL_FILE.FOPEN(C_directory,x12_fname,'w');

   P_code_area:='HEADERS';
   /*

      Interchange Control Header (ISA)
   */
   interchange_control_header:='ISA*00* 	 *00*	       *ZZ*'||
      RPAD(security_id,15)||'*33*'||
      RPAD(receiver_id,15)||'*'||interchange_date||'*'||
      interchange_time||'*^*'||'00501'||'*'||LPAD(interchange_number,9,'0')||
      '*1*'||test_indicator||'*:~';
   UTL_FILE.PUTF(file_handle,'%s\n',interchange_control_header);

   select RTRIM(LTRIM(TO_CHAR(group_control_num_seq.nextval)))
   into group_control_num from dual;
   /*
      Functional Group Header (GS)

   */
   functional_group_header:='GS*HC*'||RTRIM(trading_id)||'*'||RTRIM(receiver_id)
||

      '*'||date_today||'*'||interchange_time||'*'||group_control_num||
      '*X*'||impl_conv_ref||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',functional_group_header);

   /*
      Transaction Set Header (ST)
   */
   segment_count:=1;
   select RTRIM(LTRIM(TO_CHAR(transet_id_seq.nextval,'000009')))

   into trx_set_control_num from dual;
   transaction_set_header:='ST*837*'||trx_set_control_num||'*'||impl_conv_ref||'
~';

   UTL_FILE.PUTF(file_handle,'%s\n',transaction_set_header);

   /*
      Beginning of Hierarchical Transaction (BHT)
   */
   select TO_CHAR(SysDate,'HH24MISS') into interchange_time from dual;
   if (transaction_ref='01') then
      transaction_ref:='00';
   else

      transaction_ref:='18';
   end if;
   curr_line:='BHT*0019*'||transaction_ref||'*'||
      LTRIM(RTRIM(TO_CHAR(claim_batch_number)))||'*'||
      date_today||'*'||interchange_time||'*CH~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;

/********** LOOP 1000 SUBMITTER AND RECEIVER INFORMATION **********/

   /* LOOP 1000A SUBMITTER */
   /*
      Submitter Name (NM1)

   */
   curr_line:='NM1*41*2*PENNSYLVANIA CYTOLOGY SERVICES*****46*'||
      RTRIM(trading_id)||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;
   /*
      Submitter EDI Contact Information (PER)
   */
   curr_line:='PER*IC*LISA RITCHEY*TE*4123738300*FX*4123737027~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;

   /* LOOP 1000B RECEIVER */

   /*
      Receiver Name (NM1)
   */
   curr_line:='NM1*40*2*HIGHMARK*****46*'||receiver_id||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;

/********** HL - BILLING PROVIDER HIERARCHICAL LEVEL **********/

   /* LOOP 2000A BILLING PROVIDER HIERARCHICAL LEVEL */
   curr_line:='HL*'||TO_CHAR(HL_count)||'**20*1~';
   HL_count:=HL_count+1;
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   segment_count:=segment_count+1;
   /*
      Billing Provider Specialty Information (PRV)
   */
   curr_line:='PRV*BI*PXC*'||PXC_taxonomy_code||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;

   /* LOOP 2010AA BILLING PROVIDER NAME */
   curr_line:='NM1*85*2*PENNSYLVANIA CYTOLOGY SERVICES*****XX*'||NPI_id||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;
   /*

      Billing Provider Address (N3)
   */
   curr_line:='N3*SUITE 1700 PARKWAY BUILDING*339 OLD HAYMAKER ROAD~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;
   /*
      Billing Provider City/State/Zip Code (N4)
   */
   curr_line:='N4*MONROEVILLE*PA*151461447~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;
   /*
      Billing Provider Tax ID (Now required with Version 5010)

   */
   curr_line:='REF*EI*'||lab_tax_id||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   segment_count:=segment_count+1;

   P_code_area:='CLAIMS';
   open claim_list;
   loop
      fetch claim_list into
	 carrier_idnum,
	 carrier_name,
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
	 lab_collected,
	 claim_lab_number,
	 lab_rebilling,
	 lab_balance,
	 lab_doctor,
	 lab_claim_id,
	 lab_vials,
	 lab_prep;
      exit when claim_list%NOTFOUND;


      if (C_retran_status=0 and last_carrier=0 and C_billing_route<>'DUP') then
	 last_carrier:=carrier_idnum;
	 insert into pcs.payer_batch_amounts
	    (carrier_id,batch_number,amount_submitted,amount_recorded,amount_rec
eived)

	 values (carrier_idnum,claim_batch_number,0,0,0);
	 commit;
      end if;

      resubmitted:=0;
      select count(*) into resubmitted from pcs.lab_claims
      where lab_number=claim_lab_number and claim_id=lab_claim_id;

      if (resubmitted>0) then
	 select claim_status into C_status
	 from pcs.lab_claims where claim_id=lab_claim_id;
	 if (C_status<>'B') then
	    resubmitted:=0;
	 end if;
      end if;

	/*
	 values are from old X12 specs
	 if insurer_type ends up null then policy_subscriber is OTHER
      */
      insurer_type:=null;

      if (policy_subscriber='SELF') then
	 insurer_type:='18';
      elsif (policy_subscriber='SPOUSE') then
	 insurer_type:='01';
      elsif (policy_subscriber='DEPENDENT') then
	 insurer_type:='02';
      end if;

/********** HL SUBSCRIBER HIERARCHICAL LEVEL **********/

      /* LOOP 2000B SUBSCRIBER HIERARCHICAL LEVEL */
      curr_line:='HL*'||TO_CHAR(HL_count)||'*1*22*';
      HL_count:=HL_count+1;

      if (policy_subscriber='SELF') then
	 curr_line:=curr_line||'0~';
      else
	 curr_line:=curr_line||'1~';
      end if;
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      segment_count:=segment_count+1;

      select NVL(SUM(payment_amount),0) into patient_payments from pcs.payments
P

      where P.lab_number=claim_lab_number and P.billing_choice=121 and
	 payment_type not in ('PLUS ADJUST','MINUS ADJUST');


      /*
	 Subscriber Information (SBR)
	 If the group num is null, default to six nines
      */
      if (policy_group is null) then
	 policy_group:='999999';
      end if;
      curr_line:='SBR*P*';
      /* Subscriber and Patient are the same person */
      if (policy_subscriber='SELF') then
	   curr_line:=curr_line||insurer_type;
      end if;

      curr_line:=curr_line||'*'||RTRIM(policy_group)||'******BL~';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      segment_count:=segment_count+1;

      /* LOOP 2010BA SUBSCRIBER NAME */
      /*
	 Subscriber Name (NM1)
      */
      cbuf1:=pcs.strip_chars(policy_lname);
      cbuf2:=pcs.strip_chars(policy_fname);
      curr_line:='NM1*IL*1*'||RTRIM(cbuf1)||'*'||RTRIM(cbuf2)||
	 '****MI*'||policy_id||'~';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

      segment_count:=segment_count+1;
      if (policy_subscriber='SELF') then
      /*
	 Subscriber Address (N3)
      */
	 cbuf1:=pcs.strip_chars(patient_addr);
	 curr_line:='N3*'||cbuf1||'~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
      /*
	 Subscriber City/State/Zip Code (N4)
      */
	 cbuf1:=pcs.strip_chars(patient_city);

	 curr_line:='N4*'||cbuf1||'*'||patient_state||'*'||patient_zip||'~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
      /*
	 Subscriber Demographic Information (DMG)
	 NOTE: Assume F always for sex
      */
	 curr_line:='DMG*D8*'||patient_dob||'*F~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
      end if;

      /* LOOP 2010BB PAYER NAME */

      /*
	 Payer Name (NM1)
      */
      curr_line:='NM1*PR*2*HIGHMARK*****PI*'||receiver_id||'~';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      segment_count:=segment_count+1;

      /* Subscriber and Patient are different people */
      if (policy_subscriber<>'SELF') then
	 /*
	    Patient Hierarchical Level (HL)
	 */
	 curr_line:='HL*'||TO_CHAR(HL_count)||'*'||TO_CHAR(HL_count-1)||'*23*0~'

;

	 HL_count:=HL_count+1;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 /*
	    Patient Information (PAT)
	    Assumes policy subscriber is not SELF
	 */
	 curr_line:='PAT*';
	 if (policy_subscriber='DEPENDENT') then
	    curr_line:=curr_line||'19~';
	 elsif (policy_subscriber='SPOUSE') then

	    curr_line:=curr_line||'01~';
	 else
	    curr_line:=curr_line||'G8~';
	 end if;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 /*
	    Patient Name (NM1)
	 */
	 cbuf1:=pcs.strip_chars(SUBSTR(patient_lname,1,20));
	 cbuf2:=pcs.strip_chars(SUBSTR(patient_fname,1,12));
	 curr_line:='NM1*QC*1*'||cbuf1||'*'||cbuf2;
	 if (patient_mi is not null) then

	    curr_line:=curr_line||'*'||patient_mi;
	 end if;
	 curr_line:=curr_line||'~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 /*
	    Patient Address (N3)
	 */
	 cbuf1:=pcs.strip_chars(patient_addr);
	 curr_line:='N3*'||cbuf1||'~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 /*

	    Patient City/State/Zip Code (N4)
	 */
	 cbuf1:=pcs.strip_chars(patient_city);
	 curr_line:='N4*'||cbuf1||'*'||patient_state||'*'||patient_zip||'~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 /*
	    Patient Demographic Information (DMG)
	    Assumes sex is F always
	 */
	 curr_line:='DMG*D8*'||patient_dob||'*F~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;

      end if;

      /* LOOP 2300 CLAIM INFORMATION
      /*
	 Health Care Claim (CLM)
	 NOTE: claim_total holds lab_billings.bill_amount which is programmed
	 to hold the sum of all lab_billing_items.item_amount (line items)
      */
      cbuf1:=TO_CHAR(claim_total);
      curr_line:='CLM*'||claim_lab_number||'*'||cbuf1||'***'||POS_code||
	 ':B:1*Y*A*Y*I*P~';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      segment_count:=segment_count+1;

      /*
	 Patient Amount Paid (AMT)
      */
      if (patient_payments>0) then
	 cbuf1:=TO_CHAR(patient_payments);
	 curr_line:='AMT*F5*'||cbuf1||'~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
      end if;
      /*
	 CLIA Number (REF)
      */
      curr_line:='REF*X4*'||lab_CLIA||'~';

      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      segment_count:=segment_count+1;
      /*
	 Health Care Information Codes (HI)
	 NOTE: When ICD10 is implemented BK becomes ABK and
	 BF becomes ABF
      */
      curr_line:='HI';
      num_diags:=0;
      open diagnosis_list;
      loop
	 fetch diagnosis_list into diagnosis_fields;
	 exit when diagnosis_list%NOTFOUND;

	 cbuf1:=REPLACE(diagnosis_fields.diagnosis_code,'.');
	 if (diagnosis_fields.d_seq=1) then
	    cbuf2:='BK';
	 else
	    cbuf2:='BF';
	 end if;
	 curr_line:=curr_line||'*'||cbuf2||':'||cbuf1;
	 num_diags:=num_diags+1;
      end loop;
      close diagnosis_list;
      curr_line:=curr_line||'~';
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      segment_count:=segment_count+1;


      /* LOOP 2310A REFERRING PROVIDER NAME */
      select lname,fname,npi into dr_lname,dr_fname,dr_npi
      from pcs.doctors where doctor=lab_doctor;
      if (dr_lname is NOT NULL and dr_fname is NOT NULL
      and dr_npi is NOT NULL) then
	 curr_line:='NM1*DN*1*'||dr_lname||'*'||dr_fname||'****XX*'||dr_npi||'~'
;

	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
      end if;


/********** LX SERVICE LINE NUMBER **********/
      /* SERVICE LINE LOOP 2400 */
      rcnt:=1;
      open procedure_list;
      loop
	 fetch procedure_list into procedure_fields;
	 exit when procedure_list%NOTFOUND;
	 cbuf1:=LTRIM(TO_CHAR(rcnt));
	 cbuf2:=LTRIM(TO_CHAR(procedure_fields.item_amount));
	 curr_line:='LX*'||cbuf1||'~';
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 if (lab_prep=6) then

	    cbuf3:=RTRIM(LTRIM(TO_CHAR(lab_vials)));
	 else
	    cbuf3:='1';
	 end if;
	 curr_line:='SV1*HC:'||procedure_fields.procedure_code||'*'||cbuf2||'*UN
*'||

	    cbuf3||'***';
	 if (rcnt=1) then
	    curr_line:=curr_line||'1';
	    if (num_diags=2) then
	       curr_line:=curr_line||':2~';
	    elsif (num_diags=3) then

	       curr_line:=curr_line||':2:3~';
	    elsif (num_diags=4) then
	       curr_line:=curr_line||':2:3:4~';
	    else
	       curr_line:=curr_line||'~';
	    end if;
	 else
	    if (num_diags=1) then
	       curr_line:=curr_line||'1';
	    else
	       curr_line:=curr_line||'2';
	    end if;
	    if (num_diags=3) then

	       curr_line:=curr_line||':3~';
	    elsif (num_diags=4) then
	       curr_line:=curr_line||':3:4~';
	    else
	       curr_line:=curr_line||'~';
	    end if;
	 end if;
	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 /*
	    Date of Service (DTP)
	 */
	 curr_line:='DTP*472*D8*'||lab_collected||'~';

	 UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
	 segment_count:=segment_count+1;
	 rcnt:=rcnt+1;
      end loop;
      close procedure_list;

      if (C_claims>0 and C_billing_route<>'DUP') then
	 if (C_retran_status>0) then
	    update pcs.lab_claims set datestamp=SysDate,change_date=SysDate
	    where claim_id=lab_claim_id;
	    update pcs.billing_details set date_sent=SysDate
	    where claim_id=lab_claim_id;
	 else

	    update pcs.payer_batch_amounts set
	       amount_submitted=amount_submitted+(claim_total-patient_payments)
	    where carrier_id=carrier_idnum and batch_number=claim_batch_number;
	    if (resubmitted=0) then
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
	       set batch_number=claim_batch_number,datestamp=SysDate,change_date
=SysDate

	       where claim_id=lab_claim_id;
	    end if;
	 end if;
      end if;

   end loop;
   close claim_list;

   segment_count:=segment_count+1;

   P_code_area:='TRAILERS';
   /*
      Transaction Set Trailer
   */
   curr_line:='SE*'||segment_count||'*'||trx_set_control_num||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   /*
      Functional Group Trailer (GE)
   */
   curr_line:='GE*1*'||group_control_num||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   /*
      Interchange Control Trailer (ISA)
   */
   curr_line:='IEA*1*'||LPAD(interchange_number,9,'0')||'~';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);

   if (test_indicator<>'T') then
      delete from pcs.billing_queue where billing_route=C_billing_route;
      insert into pcs.claim_submissions (batch_number,tpp,submission_number,crea
tion_date)

      values (claim_batch_number,C_tpp,TO_NUMBER(transaction_ref),SysDate);
   end if;

   update pcs.tpps set file_name=x12_fname where tpp=C_tpp;

   /**************/
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
      claim_lab_number:=claim_lab_number;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,da
testamp,sys_user,ref_id)

      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,c
laim_lab_number);

      commit;
      RAISE;


end;