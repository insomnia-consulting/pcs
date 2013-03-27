select distinct l.practice, d.fname, d.lname, l.doctor_text
from lab_requisitions l, doctors d
where l.doctor = d.doctor(+)
and l.datestamp > sysdate - 360
and preparation in (1)
and l.practice in (226, 082)
order by l.practice
/
