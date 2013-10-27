create or replace
procedure     doc_rules
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
   MANUAL_THREE_SLIDE constant varchar2(8) := '88103';
   MANUAL_TWO_SLIDE constant varchar2(8) := '88101';
   LIQUID_BASED constant varchar2(8) := '88142';
   OTHER_SOURCE constant varchar2(8) := '88160';
   AUTOMATED_SYS constant varchar2(8) := '88175';
   LEVEL4_SURGICAL_PATH constant varchar2(8) := '88305';
   LEVEL5_SURGICAL_PATH constant varchar2(8) := '88307';
   PHYSICIAN_REQ constant varchar2(8) := '88141';
   HPV_TEST constant varchar2(8) := '87621';
   HORMONAL_EVAL constant varchar2(8) := '88155';

   /* Constants for billing codes
   */
   DB constant number := 121;            /* bill goes to patient */
   DOC constant number := 122;           /* bill goes to doc office */
   PPD constant number := 161;           /* bill is prepaid by patient */
   PRC constant number := 127;           /* professional courtesy */

   /* Miscellaneous constants
   */
   BIOPSY_CONE constant number := 62;    /* the value for cone in pcs.detail_codes */

   L_practice number;
   L_price_code varchar2(2);
   L_item_cost number;
   L_rebilling number;
   L_num_slides number;
   L_cone_biopsy number;
   CPT_code char(5);
   L_prep integer;
   L_payer varchar2(32);
   H_date date;
   H_test_sent varchar2(2);

   rcnt number;

   begin

      P_proc_name:='DOC_RULES';

      P_code_area:='GET DECISION DATA';
      select practice, slide_qty, preparation into L_practice, L_num_slides, L_prep
      from pcs.lab_requisitions where lab_number=L_num;
      select price_code into L_price_code from pcs.practices where practice=L_practice;
      select max(rebilling) into L_rebilling from pcs.billing_details
      where lab_number=L_num;
      L_payer:='DOCTORACCOUNT'||RTRIM(LTRIM(TO_CHAR(L_practice,'009')));

      if (L_prep=HPV_ONLY) then
         goto HPV_SECTION;
      end if;

      /* Determine which CPT code to use based on the type
         of lab preparation. Note that for surgical biopsies
         addition info from the requisition is needed to 
         determine which code to use.
      */
      P_code_area:='GET CPT CODE';
      if (L_prep=CONVENTIONAL) then 
         if (L_num_slides=3) then 
            CPT_code:=MANUAL_THREE_SLIDE;
         elsif (L_num_slides=2) then 
            CPT_code:=MANUAL_TWO_SLIDE;
         else 
            CPT_code:=MANUAL_SCREEN;
         end if;
      elsif (L_prep=THIN_LAYER) then 
         CPT_code:=LIQUID_BASED;
      elsif (L_prep=CYT_NON_PAP) then 
         CPT_code:=OTHER_SOURCE;
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
      elsif (L_prep=IMAGED_SLIDE) then 
         CPT_code:=AUTOMATED_SYS;
      end if;

      /*
         Before insert into charges, check for special charges that would
         over-ride these ones; variable L_payer being not null indicates
         a check for this should be made. Note that by convention if
         there is an entry in the special_charges table for a doctor account
         the payer_id is DOCTORACCOUNTnnn where nnn is the three digit
         (zero padded) account number.
      */ 
      select count(*) into rcnt from pcs.special_charges 
      where payer_id=L_payer and procedure_code=CPT_code;
      if (rcnt>0) then
         select special_charge into L_item_cost from pcs.special_charges 
         where payer_id=L_payer and procedure_code=CPT_code;
      else
         select discount_price into L_item_cost from pcs.price_code_details p where PRICE_CODE=L_price_code and
         procedure_code=CPT_code and lab_number = (select max(lab_number) from price_code_details where lab_number <= L_num
         and price_code=L_price_code and procedure_code=CPT_code);
      end if;

      /* The charges for a biopsy is the item cost multiplied
         by the number of vials that are submitted.  The number
         of vials are recorded under number of slides in reqs.
      */
      if (L_prep=SURGICAL) then
         L_item_cost:=L_item_cost*L_num_slides;
      end if;

      insert into pcs.lab_billing_items
         (lab_number,price_code,procedure_code,item_amount,rebilling)
      values
         (L_num,L_price_code,CPT_code,L_item_cost,L_rebilling);

      /* This is an add-on code to any other procedure that is included; it
         is a request for a definitive hormonal evaluation, results of which
         are stored in the table lab_mat_index.
      */
      P_code_area:='MAT INDEX';
      select count(*) into rcnt from pcs.lab_mat_index where lab_number=L_num;
      if (rcnt>0) then
         CPT_code:=HORMONAL_EVAL;
         /*
            Check for special charges (see other comment for additional
            information).
         */ 
         select count(*) into rcnt from pcs.special_charges 
         where payer_id=L_payer and procedure_code=CPT_code;
         if (rcnt>0) then
            select special_charge into L_item_cost from pcs.special_charges 
            where payer_id=L_payer and procedure_code=CPT_code;
         else
            select discount_price into L_item_cost from pcs.price_code_details p where PRICE_CODE=L_price_code and
            procedure_code=CPT_code and lab_number = (select max(lab_number) from price_code_details where lab_number <= L_num
            and price_code=L_price_code and procedure_code=CPT_code);
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
            /*
               Check for special charges (see other comment for additional
               information.
            */ 
            select count(*) into rcnt from pcs.special_charges
            where payer_id=L_payer and procedure_code=CPT_code;
            if (rcnt>0) then
               select special_charge into L_item_cost from pcs.special_charges
               where payer_id=L_payer and procedure_code=CPT_code;
            else
               select discount_price into L_item_cost from pcs.price_code_details p where PRICE_CODE=L_price_code and
               procedure_code=CPT_code and lab_number = (select max(lab_number) from price_code_details where lab_number <= L_num
               and price_code=L_price_code and procedure_code=CPT_code);
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

   exception
   when OTHERS then
      P_error_code:=SQLCODE;
      P_error_message:=SQLERRM;
      insert into pcs.error_log
         (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values 
         (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,L_num);
      commit;
      RAISE;

   end;
 \