create or replace procedure default_rules
(
   L_num in number,
   L_billing_choice in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   /* Constants for Lab preparations

   */
   CONVENTIONAL constant number := 1;
   THIN_LAYER constant number :=2;
   CYT_NON_PAP constant number := 4;
   HPV_ONLY constant number := 5;
   SURGICAL constant number := 6;
   IMAGED_SLIDE constant number := 7;

   /* Constants for CPT codes
   */
   MANUAL_SCREEN constant varchar2(8) := '88164';
   MANUAL_SCREEN_MED constant varchar2(8) := 'P3000';
   MANUAL_SCREEN_OTHER constant varchar2(8) := '88150';

   LIQUID_BASED constant varchar2(8) := '88142';
   LIQUID_BASED_MED constant varchar2(8) := 'G0123';
   OTHER_SOURCE constant varchar2(8) := '88160';
   AUTOMATED_SYS constant varchar2(8) := '88175';
   AUTOMATED_SYS_MED constant varchar2(8) := 'G0145';
   LEVEL4_SURGICAL_PATH constant varchar2(8) := '88305';
   LEVEL5_SURGICAL_PATH constant varchar2(8) := '88307';
   PHYSICIAN_REQ constant varchar2(8) := '88141';
   PHYSICIAN_REQ_MANUAL_MED constant varchar2(8) := 'P3001';
   PHYSICIAN_REQ_LIQUID_MED constant varchar2(8) := 'G0124';
   HPV_TEST constant varchar2(8) := '87621';
   HORMONAL_EVAL constant varchar2(8) := '88155';


   /* Constants for billing codes
   */
   DB constant number := 121;		 /* bill goes to patient */
   DOC constant number := 122;		 /* bill goes to doc office */
   PPD constant number := 161;		 /* bill is prepaid by patient */
   PRC constant number := 127;		 /* professional courtesy */

   /* Miscellaneous constants
   */
   BIOPSY_CONE constant number := 62;	 /* the value for cone in pcs.detail_codes */
   WV_DPA constant number := 1047;	 /* primary key for West Virginia med asst */
   CYTOTECH constant integer := 0;
   PATHOLOGIST constant integer := 1;


   L_practice number;
   L_price_code varchar2(2);
   L_item_cost number;
   L_rebilling number;
   L_prep number;
   CPT_code char(5);
   L_path_status char(1);
   L_qc_status char(1);
   L_num_vials number;
   L_cone_biopsy number;
   screening_level integer;
   L_carrier number;

   L_payer varchar2(32);
   H_date date;
   H_test_sent varchar2(2);
   rcnt integer;

begin

      P_proc_name:='DEFAULT_RULES';

      select practice,preparation,slide_qty
      into L_practice,L_prep,L_num_vials
      from pcs.lab_requisitions where lab_number=L_num;
      select path_status,qc_status

      into L_path_status,L_qc_status from pcs.lab_results where lab_number=L_num;
      select price_code into L_price_code from pcs.practices
      where practice=L_practice;

      select max(rebilling)into L_rebilling from pcs.billing_details
      where lab_number=L_num;

      select carrier_id into L_carrier from pcs.billing_details
      where lab_number=L_num and rebilling=L_rebilling;

      if (L_prep=HPV_ONLY) then
	 goto HPV_SECTION;
      end if;

      /* This block of code determines whether there will be patholoigst

	 charges included with the billing. The variable screening_level
	 will be 1 if there should be pathologist charges; 0 otherwise.
      */
      P_code_area:='PATH SCREENING';
      screening_level:=CYTOTECH;
      if (L_path_status='Y') then
	 screening_level:=PATHOLOGIST;
	 select count(*) into rcnt from pcs.pathologist_control_codes
	 where bethesda_code IN ('012','010') and lab_number=L_num;
	 if (rcnt<1) then
	    screening_level:=CYTOTECH;
	 end if;
	 select count(*) into rcnt from pcs.pathologist_control_codes

	 where bethesda_code='13R' and lab_number=L_num;
	 if (rcnt>0) then
	    select count(*) into rcnt from pcs.pathologist_control_codes
	    where bethesda_code='040' and lab_number=L_num;
	    if (rcnt>0) then
	       screening_level:=CYTOTECH;
	    else
	       screening_level:=PATHOLOGIST;
	    end if;
	 end if;
	 if (screening_level<>PATHOLOGIST) then
	    if (L_qc_status='Y') then
	       screening_level:=PATHOLOGIST;

	       select count(*) into rcnt from pcs.quality_control_codes
	       where bethesda_code IN ('012','010') and lab_number=L_num;
	       if (rcnt<1) then
		  screening_level:=CYTOTECH;
	       end if;
	       select count(*) into rcnt from pcs.quality_control_codes
	       where bethesda_code='13R' and lab_number=L_num;
	       if (rcnt>0) then
		  select count(*) into rcnt from pcs.quality_control_codes
		  where bethesda_code='040' and lab_number=L_num;
		  if (rcnt>0) then
		     screening_level:=CYTOTECH;
		  else

		     screening_level:=PATHOLOGIST;
		  end if;
	       end if;
	    end if;
	 end if;
	 if (screening_level<>PATHOLOGIST) then
	    screening_level:=PATHOLOGIST;
	    select count(*) into rcnt from pcs.lab_result_codes
	    where bethesda_code IN ('012','010') and lab_number=L_num;
	    if (rcnt<1) then
	       screening_level:=CYTOTECH;
	    end if;
	    select count(*) into rcnt from pcs.lab_result_codes

	    where bethesda_code='13R' and lab_number=L_num;
	    if (rcnt>0) then
	       select count(*) into rcnt from pcs.lab_result_codes
	       where bethesda_code='040' and lab_number=L_num;
	       if (rcnt>0) then
		  screening_level:=CYTOTECH;
	       else
		  screening_level:=PATHOLOGIST;
	       end if;
	    end if;
	 end if;
      end if;


      /* Determine which CPT code to use based on the type
	 of lab preparation; note that for a surgical biopsy
	 additional info from the requisition is needed to
	 determine which code to use. Note that for conventional
	 preparation specific carrier WV medical assistance
	 uses a different CPT code.
      */
      P_code_area:='GET CHARGES';
      if (L_prep=CONVENTIONAL) then
	 if (L_carrier=WV_DPA) then
	    CPT_code:=MANUAL_SCREEN_OTHER;
	 else
	    CPT_code:=MANUAL_SCREEN;

	 end if;
      elsif (L_prep=THIN_LAYER) then
	 CPT_code:=LIQUID_BASED;
      elsif (L_prep=CYT_NON_PAP) then
	 CPT_code:=OTHER_SOURCE;
      elsif (L_prep=IMAGED_SLIDE) then
	 CPT_code:=AUTOMATED_SYS;
      elsif (L_prep=SURGICAL) then
	 select count(*) into L_cone_biopsy
	 from pcs.lab_req_details
	 where lab_number=L_num
	 and detail_code=BIOPSY_CONE;
	 if (L_cone_biopsy>0) then

	    CPT_code:=LEVEL5_SURGICAL_PATH;
	 else
	    CPT_code:=LEVEL4_SURGICAL_PATH;
	 end if;
      end if;
      select base_price into L_item_cost from pcs.price_code_details p where PRICE_CODE=L_price_code and
      procedure_code=CPT_code and lab_number = (select max(lab_number) from price_code_details where lab_number <= L_num
      and PRICE_CODE=L_price_code and procedure_code=CPT_code);      


      /* Before insert into charges, check for special charges that would
	 over-ride these ones; variable L_payer being not null indicates
	 a check for this should be made. Also, if this is patient billing,
	 i.e. DB, and there was a prior billing, then the patient cost

	 is the special charge if it exists.
      */
      select count(*) into rcnt from pcs.carriers where carrier_id=L_carrier;
      L_payer:=NULL;
      if (rcnt>0) then
	 select payer_id into L_payer from pcs.carriers where carrier_id=L_carrier;
      end if;
      if (L_rebilling>0 and L_billing_choice=DB) then
	 select carrier_id into rcnt from pcs.billing_details
	 where lab_number=L_num and rebilling=L_rebilling-1;
	 if (rcnt>0) then
	    select payer_id into L_payer from pcs.carriers
	    where carrier_id=rcnt;

	 end if;
      end if;
      if (L_payer is NOT NULL) then
	 select count(*) into rcnt from pcs.special_charges
	 where payer_id=L_payer and procedure_code=CPT_code;
	 if (rcnt>0) then
	    select special_charge into L_item_cost from pcs.special_charges
	    where payer_id=L_payer and procedure_code=CPT_code;
	 end if;
      end if;

      /* If a surgical biopsy was performed, then the charges are
	 multiplied by the number of vials; the value for the number

	 of vials is stored in lab_requisitions.slide_qty.
      */
      if (L_prep=SURGICAL) then
	 L_item_cost:=L_item_cost*L_num_vials;
      end if;

      insert into pcs.lab_billing_items
	 (lab_number,price_code,procedure_code,item_amount,rebilling)
      values
	 (L_num,L_price_code,CPT_code,L_item_cost,L_rebilling);

      /* If during regular screening it was determined that the results require
	 that physician screening be performed, then an addional charge is

	 added. Note that a screening level of PATHOLOGIST assumes that the lab
	 preparation was not SURGICAL or HPV_ONLY.
      */
      P_code_area:='PATH CHARGES';
      if (screening_level=PATHOLOGIST) then
	 CPT_code:=PHYSICIAN_REQ;
     select base_price into L_item_cost from pcs.price_code_details p where PRICE_CODE=L_price_code and
     procedure_code=CPT_code and lab_number = (select max(lab_number) from price_code_details where lab_number <= L_num
     and PRICE_CODE=L_price_code and procedure_code=CPT_code);
	 /*
	    Before insert into charges, check for special charges that would
	    over-ride these ones; variable L_payer being not null indicates
	    a check for this should be made. Also, if this is patient billing,
	    i.e. DB, and there was a prior billing, then the patient cost

	    is the special charge if it exists.
	 */
	 if (L_payer is NOT NULL) then
	    select count(*) into rcnt from pcs.special_charges
	    where payer_id=L_payer and procedure_code=CPT_code;
	    if (rcnt>0) then
	       select special_charge into L_item_cost from pcs.special_charges
	       where payer_id=L_payer and procedure_code=CPT_code;
	    end if;
	 end if;
	 insert into pcs.lab_billing_items
	    (lab_number,price_code,procedure_code,item_amount,rebilling)
	 values

	    (L_num,L_price_code,CPT_code,L_item_cost,L_rebilling);
      end if;

      /* This is an add-on code to any other procedure that is included; it
	 is a request for a definitive hormonal evaluation, results of which
	 are stored in the table lab_mat_index.
      */
      P_code_area:='MAT INDEX';
      select count(*) into rcnt from pcs.lab_mat_index where lab_number=L_num;
      if (rcnt>0) then
	 CPT_code:=HORMONAL_EVAL;
     select base_price into L_item_cost from pcs.price_code_details p where PRICE_CODE=L_price_code and
     procedure_code=CPT_code and lab_number = (select max(lab_number) from price_code_details  where lab_number <= L_num
     and PRICE_CODE=L_price_code and procedure_code=CPT_code);

	 /*
	    Check for special charges (see other comment for additional
	    information).
	 */
	 if (L_payer is NOT NULL) then
	    select count(*) into rcnt from pcs.special_charges
	    where payer_id=L_payer and procedure_code=CPT_code;
	    if (rcnt>0) then
	       select special_charge into L_item_cost from pcs.special_charges
	       where payer_id=L_payer and procedure_code=CPT_code;
	    end if;
	 end if;
	 insert into pcs.lab_billing_items

	    (lab_number,price_code,procedure_code,item_amount,rebilling)
	 values
	    (L_num,L_price_code,CPT_code,L_item_cost,L_rebilling);
      end if;
      commit;

      /*  This section determines if an HPV test was done, and adds
	  the CPT code and charges for that. If it is an HPV only
	  test, then this is the only charge that gets added on.
	  If there was other testing AND HPV then all the charges
	  are added to the lab.
      */
      <<HPV_SECTION>>

      P_code_area:='HPV';
      select count(*) into rcnt from pcs.hpv_requests
      where lab_number=L_num and test_sent in ('Y','Q');
      if (rcnt>0) then
	 select datestamp,test_sent
	 into H_date,H_test_sent
	 from pcs.hpv_requests where lab_number=L_num;
	 if (H_date is NOT NULL) then
	    CPT_code:=HPV_TEST;
      select base_price into L_item_cost from pcs.price_code_details p where PRICE_CODE=L_price_code and
      procedure_code=CPT_code and lab_number = (select max(lab_number) from price_code_details where lab_number <= L_num);       
	    /*
	       Check for special charges (see other comment for additional

	       information).
	    */
	    if (L_payer is NOT NULL) then
	       select count(*) into rcnt from pcs.special_charges
	       where payer_id=L_payer and procedure_code=CPT_code;
	       if (rcnt>0) then
		  select special_charge into L_item_cost from pcs.special_charges
		  where payer_id=L_payer and procedure_code=CPT_code;
	       end if;
	    end if;
	    /*
	       If the results of the HPV test were 'Quantity Not Sufficient',
	       this value is stored in hpv_requests.test_sent and not in the

	       field hpv_requests.test_results; for this result there is
	       no charge.
	    */
	    if (H_test_sent='Q') then
	       L_item_cost:=0;
	    end if;
	    insert into pcs.lab_billing_items
	       (lab_number,price_code,procedure_code,item_amount,rebilling)
	    values
	       (L_num,L_price_code,CPT_code,L_item_cost,L_rebilling);
	 end if;
      end if;


      /* If the type of billing does not fall into one of these types,
	 which basically amounts to an OI billing, then this procedure
	 must be ran. The diagnosis_update checks each test result code
	 of the screening against the cross-reference table beth_icd9_xref;
	 and if there is a match, then the corresponding diganosis code
	 must be added to the lab. This increases the probability that
	 the carrier is going to pay for the testing.
      */
      if (L_billing_choice NOT IN (DB,DOC,PPD,PRC)) then
	 pcs.diagnosis_update(L_num);
      end if;

exception
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_num);
      commit;
      RAISE;

   end;
 \