-- set serverout on
-- dbms_output.put_line('Starting');
-- update billing_details set sub_fname = random_name(), sub_lname = random_name()
-- where lab_number = c_rec.lab_number and rebilling = c_rec.rebilling;
-- dbms_output.put_line('Billing_Details finished');


-- update carriers set name = upper(random_name()), address1 = upper(scramble(address1)), address2 = upper(scramble(address2)), phone = upper(scramble(phone)), fax = upper(scramble(fax));
-- dbms_output.put_line('Carriers finished');

-- update lab_claims set claim_comment = scramble(claim_comment);

update lab_req_client_notes set client_notes = scramble(client_notes) ; 

update lab_req_comments set comment_text = scramble(comment_text);

update lab_req_details_additional set comment_text = scramble(comment_text);

update lab_result_comments set comment_text = scramble(comment_text);

update mailer set name = random_name(), address1 = scramble(address1), address2 = scramble(address2), city = scramble(city), zip = scramble(zip);

update patients set lname = random_name(), fname = random_name(), ssn = 'XXXXXXXXX', address1 = scramble(address1), address2 = scramble(address2), phone=scramble(phone), city = scramble(city), zip = scramble(zip);

update patient_statements set comment_text = scramble(comment_text);

update patient_statement_history set comment_text = scramble(comment_text);

update payment_adjust_reasons set adjust_reason = scramble(adjust_reason);

update practice_comments set comment_text = scramble(comment_text);
/
