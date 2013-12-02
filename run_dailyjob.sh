#!/bin/bash
echo 'Daily Jobs Starting'`date` >> /home/oracle/logs/daily_jobs.log
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_SID=pcs
export SQLPLUS=/u01/app/oracle/product/11.2.0/db_1/bin/sqlplus
echo exit | $SQLPLUS pcs/ahb22@pcs @/home/oracle/run_dailyjob.sql
echo 'Daily Jobs Done'`date` >> /home/oracle/logs/daily_jobs.log

echo 'Copying backups' >> /home/oracle/logs/daily_jobs.log
cp -R -n /u01/app/oracle/flash_recovery_area/* /u01/reports/oracle_backups/
echo 'Backups copied' >> /home/oracle/logs/daily_jobs.log
