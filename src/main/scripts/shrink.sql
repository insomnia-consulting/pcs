delete from billing_details where change_date < to_date('20120101', 'YYYYmmDD');

delete from adph_lab_whp where lab_number not in (select lab_number from billing_details);

delete from cytopath_history where lab_number not in (select lab_number from billing_details);

delete from hpv_requests where lab_number not in (select lab_number from billing_details);

delete from lab_billings where lab_number not in (select lab_number from billing_details);

delete from lab_billing_items where lab_number not in (select lab_number from billing_details);

delete from lab_claims where lab_number not in (select lab_number from billing_details);

delete from lab_claims_history where claim_id not in (select claim_id from lab_claims);

delete from lab_req_client_notes where lab_number not in (select lab_number from billing_details);
delete from lab_req_details where lab_number not in (select lab_number from billing_details);
delete from lab_results where lab_number not in (select lab_number from billing_details);
delete from lab_requisitions where lab_number not in (select lab_number from lab_req_details);

delete from lab_req_details_additional where detail_id not in (select detail_id from lab_req_details);

delete from lab_result_codes where lab_number not in (select lab_number from billing_details);

delete from lab_result_comments where lab_number not in (select lab_number from billing_details);

delete from pathologist_control where lab_number not in (select lab_number from billing_details);

delete from pathologist_control_codes where lab_number not in  (select lab_number from billing_details);

delete from patient_accounts where lab_number not in (select lab_number from billing_details);

