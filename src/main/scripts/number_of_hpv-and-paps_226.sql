select '226 PAPs', count(*)
from lab_requisitions l, lab_results h
where l.lab_number = h.lab_number(+)
and l.preparation in (1, 2, 7)
and l.datestamp > sysdate - 360
and l.practice in (226)
union
select '226 HPVs', count(*)
from lab_requisitions l, hpv_requests h
where l.lab_number = h.lab_number(+)
and h.test_results in ('+', '-')
and l.datestamp > sysdate - 360
and l.practice in (226)
/
