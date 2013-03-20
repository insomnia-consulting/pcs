select lab_number, preparation, date_collected, datestamp, receive_date from lab_requisitions where datestamp > sysdate - 30 and preparation <> 1 and rownum < 10 order by datestamp desc
/
