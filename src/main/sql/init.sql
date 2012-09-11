-- Documentation of things might need done; but some aren't done every import and some aren't done in the context of this user
--2.  grant dba to pcs;
--3.  grant select on sys.dba_free_space to pcs;

create or replace directory REPORTS_DIR as '/u01/reports'
\
drop procedure stupid
\
-- Change the default dir of reports from a physical location to the virtual UTIL_FILE required by 11g
update tpps set dir_name = 'REPORTS_DIR'
\

--Need to add an update statement so that the tables which have a user ID will reflect the change to a new user id as the new users are created.  This might have to be done manually
