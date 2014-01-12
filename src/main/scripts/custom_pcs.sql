--create tablespace pcs_users datafile '/u01/app/oracle/oradata/pcsdev/pcs_users_1.dbf' size 100M autoextend on next 1M maxsize 1G extent management local uniform size 128k ;
--create tablespace pcs_temp datafile '/u01/app/oracle/oradata/pcsdev/pcs_temp_1.dbf' size 100M autoextend on next 1M maxsize 1G extent management local uniform size 128k ;
create tablespace pcs_1 datafile '/u01/app/oracle/oradata/pcsdev/pcs_1.dbf' size 100M autoextend on next 1M maxsize 1G extent management local uniform size 128k ;
create tablespace data_1 datafile '/u01/app/oracle/oradata/pcsdev/data_1.dbf' size 100M autoextend on next 1M maxsize 3G extent management local uniform size 256k ;
create tablespace data_2 datafile '/u01/app/oracle/oradata/pcsdev/data_2.dbf' size 100M autoextend on next 1M maxsize 1G extent management local uniform size 256k ;
create tablespace index_1 datafile '/u01/app/oracle/oradata/pcsdev/index_1.dbf' size 100M autoextend on next 1M maxsize 2G extent management local uniform size 256k ;
create tablespace index_2 datafile '/u01/app/oracle/oradata/pcsdev/index_2.dbf' size 100M autoextend on next 1M maxsize 2G extent management local uniform size 256k ;

create user pcs identified by abh21 ; 
create user lritchey identified by lritchey ; 
create role pcs_user not identified ;
create or replace directory REPORTS_DIR as '/uTest/reports';
create or replace directory WV_REPORTS_DIR as '/uTest/reports/LabInfoSystem/ElectronicReporting/wv';
grant read, write on directory reports_dir to pcs ;
grant read, write on directory wv_reports_dir to pcs ;
grant connect to pcs_user ; 
grant pcs_user to lritchey ;
grant pcs_user to pcs ; 
create user gakins identified by Password1 ; 
grant pcs_user to gakins ; 
grant select on sys.dba_free_space to pcs ;

grant dba to pcs ;