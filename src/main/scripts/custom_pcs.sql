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
grant pcs_user to lritchey ; 
grant dba to pcs ;