-- Documentation of things might need done; but some aren't done every import and some aren't done in the context of this user
--2.  grant dba to pcs;
--3.  grant select on sys.dba_free_space to pcs;

create or replace directory REPORTS_DIR as '/u01/reports'
/
drop procedure stupid
/
-- Change the default dir of reports from a physical location to the virtual UTIL_FILE required by 11g
update tpps set dir_name = 'REPORTS_DIR'
/

--Need to add an update statement so that the tables which have a user ID will reflect the change to a new user id as the new users are created.  This might have to be done manually

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence patient_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(patient)+1 into maxvalue from patients ; 
	dbms_output.put_line('========= Creating sequence patient_seq');
	execute immediate 'create sequence patient_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence req_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(req_number)+1 into maxvalue from lab_requisitions ; 
	dbms_output.put_line('=========== Creating sequence req_seq');
	execute immediate 'create sequence req_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/

BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence lab_req_detail_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(detail_id)+1 into maxvalue from pcs.lab_req_details_additional ; 
	dbms_output.put_line('=========== Creating sequence lab_req_detail_seq');
	execute immediate 'create sequence lab_req_detail_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/


BEGIN
   dbms_output.put_line('Dropping Sequence');
   EXECUTE IMMEDIATE 'DROP sequence payments_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
		dbms_output.put_line('Sequence does not exist.. moving on');
      END IF;
END;
/

declare 
	maxvalue number;
begin
	dbms_output.put_line('Getting necessary max value for sequence');
	select max(payment_id)+1 into maxvalue from pcs.payments ; 
	dbms_output.put_line('=========== Creating sequence payments_seq');
	execute immediate 'create sequence payments_seq start with '||maxvalue||' nomaxvalue' ; 
end ;
/


