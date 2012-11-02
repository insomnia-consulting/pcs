create or replace function scramble
  (value_in in varchar2)
  return varchar2
   is
  scrambled_result varchar2(4000);
  nextchar char(1);
  tempval number;
begin
   scrambled_result := '';
   if (value_in is not null) then
   for i in 0..length(value_in)-1
   loop
	nextchar := substr(value_in, i, 1);

	if REGEXP_LIKE(nextchar,'[0-9]') then 
	   nextchar := to_char(round(dbms_random.value(1,9), 0));
	elsif REGEXP_LIKE(nextchar, '[A-Z0-9a-z]') then 
	   nextchar := dbms_random.string('U',1);
	end if	;

	scrambled_result := scrambled_result || nextchar;
   end loop;
   end if;
   return scrambled_result ;
end;
/
