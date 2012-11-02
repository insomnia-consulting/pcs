create or replace function random_name
  return varchar2
as 
  r_num number(3);
  max_num number(3);
  random_name varchar2(255);
begin
	select count(*) into max_num from random_names;
	select round(dbms_random.value(1,max_num)) into r_num from dual;
	select upper(name) into random_name from random_names where id = r_num;
	return random_name;
end;
/
