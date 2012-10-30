update billing_Details
set sub_lname = scramble(sub_lname),
sub_fname = scramble(sub_fname) ; 

update business_info
set local_phone = scramble(local_phone), scramble(toll_free_phone) ; 

update carriers
set name = scramble(name), address = scramble(address), address2 = scramble(address2), phone = scramble(phone), fax = scramble(fax);


update lab_claims set claim_comment = scramble(claim_comment);

update lab_req_client_notes set client_notes = scramble(client_notes) ; 

update lab_req_comments set comment_text = scramble(comment_text);

update lab_req_details_additional set comment_text = scramble(comment_text);

update lab_result_comments set comment_text = scramble(comment_text);

update mailer set name = scramble(name), address1 = scramble(address1), address2 = scramble(address2), city = scramble(city), zip = scramble(zip);

update patients set lname = scramble(lname), fname = scramble(fname), ssn = 'XXXXXXXXX', address1 = scramble(address1), address2 = scramble(address2), phone=scramble(phone), city = scramble(city), zip = scramble(zip), race=scramble(race);

update patient_statements set comment_text = scramble(comment_text);

update patient_statement_history set comment_text = scramble(comment_text);

update payment_adjust_reasons set adjust_reason = scramble(adjust_reason);

update practice_comments set comment_text = scramble(comment_text);





 



