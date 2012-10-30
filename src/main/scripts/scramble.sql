create or replace function scramble
  (value_in in varchar2)
  return varchar2
   is
  scrambled_result varchar2(4000);
  nextchar char(1);
begin
   scrambled_result := '';
   if (value_in is not null) then
   for i in 0..length(value_in)-1
   loop
      if ( mod(i,2) <> 0 ) then
         nextchar := substr(value_in, i, 1);
      else
         nextchar := 'X';
      end if;
      scrambled_result := scrambled_result || nextchar;
   end loop;
   end if;
   return scrambled_result ;
end;
