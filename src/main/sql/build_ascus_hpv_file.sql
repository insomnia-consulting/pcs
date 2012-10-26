create or replace procedure  build_ascus_hpv_file
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_file_name varchar2(12);
   S_name varchar2(64);

   dir_name varchar2(128);
   S_cytotech number;
   S_tech varchar2(4);
   S_ascus number;
   S_hpv_pos number;
   S_pcnt number;
   ttl_ascus number;
   ttl_hpv_pos number;
   last_date date;
   S_period varchar2(64);
   curr_line varchar2(300);
   curr_page number;
   rcnt number;

   margin varchar2(32);
   dline varchar2(256);
   dline2 varchar2(256);
   heading1 varchar2(256);
   heading2 varchar2(256);
   heading3 varchar2(256);
   heading4 varchar2(256);
   heading5 varchar2(256);
   heading6 varchar2(256);
   heading7 varchar2(256);
   cbuf1 varchar2(256);
   cbuf2 varchar2(256);


   ttl_hpv_plus number;
   ttl_hpv_minus number;
   ttl_hpv_qns number;
   ttl_hpv number;

   L_prep number;
   L_prep_descr varchar2(128);
   L_prep_count number;
   L_prep_max number;
   cursor preparations is
      select preparation,description
      from pcs.lab_preparations
      order by preparation;



   cursor ascus_cases is
      select d.cytotech_code,count(d.cytotech_code),
	 sum(decode(b.test_results,'+',1,0)),
	 sum(decode(b.test_results,'+',1,0))/count(d.cytotech_code)*100
      from pcs.lab_results a,
	 pcs.hpv_requests b,
	 pcs.pathologist_control_codes c,
	 pcs.cytotechs d
      where a.lab_number=b.lab_number
      and a.lab_number=c.lab_number
      and c.bethesda_code in ('092','096','098','207')

      and a.cytotech=d.cytotech
      and b.test_sent='Y'
      and to_number(to_char(a.datestamp,'YYYYMM'))=S_month
      group by d.cytotech_code;


   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

begin

   P_proc_name:='BUILD_ASCUS_HPV_FILE';


   P_code_area:='PREP';
   check_point:=0;
   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));
   cbuf1:=TO_CHAR(last_date,'MONYYYY');
   S_file_name:=cbuf1||'.ahp';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   S_period:=TO_CHAR(last_date,'MONTH YYYY');

   P_code_area:='HEADER';
   curr_page:=1;
   margin:='	      ';

   dline:=margin||'----------------------------------------------------------------';
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||'ASCUS HPV REPORT BY CYTOLOGIST';
   heading3:=margin||'MONTH OF '||S_period;
   heading4:=margin||'CYTOTECH		 ASCUS SENT	      HPV +	       PCNT';

   UTL_FILE.PUTF(file_handle,'\n%s\n',heading1);
   UTL_FILE.PUTF(file_handle,'%s\n',heading2);
   UTL_FILE.PUTF(file_handle,'%s\n\n',heading3);
   UTL_FILE.PUTF(file_handle,'\n%s\n',dline);
   UTL_FILE.PUTF(file_handle,'%s\n',heading4);
   UTL_FILE.PUTF(file_handle,'%s\n',dline);


   P_code_area:='STATS';
   ttl_ascus:=0;
   ttl_hpv_pos:=0;
   open ascus_cases;
   loop
      fetch ascus_cases into S_tech,S_ascus,S_hpv_pos,S_pcnt;
      exit when ascus_cases%NOTFOUND;
      curr_line:=margin||RPAD(S_tech,13)||
	 LPAD(TO_CHAR(S_ascus),16)||
	 LPAD(TO_CHAR(S_hpv_pos),16)||
	 LPAD(TO_CHAR(S_pcnt,'990.99'),16);
      UTL_FILE.PUTF(file_handle,'\n%s\n',curr_line);
      ttl_ascus:=ttl_ascus+S_ascus;

      ttl_hpv_pos:=ttl_hpv_pos+S_hpv_pos;
   end loop;
   close ascus_cases;
   S_tech:='LAB';
   S_ascus:=ttl_ascus;
   S_hpv_pos:=ttl_hpv_pos;
   S_pcnt:=ttl_hpv_pos/ttl_ascus*100;
   commit;

   UTL_FILE.PUTF(file_handle,'\n%s\n',dline);
   curr_line:=margin||RPAD(S_tech,13)||
      LPAD(TO_CHAR(S_ascus),16)||
      LPAD(TO_CHAR(S_hpv_pos),16)||

      LPAD(TO_CHAR(S_pcnt,'990.99'),16);
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   UTL_FILE.PUTF(file_handle,'%s\n',dline);

   select count(*) into ttl_hpv
   from pcs.lab_results a, pcs.hpv_requests b
   where a.lab_number=b.lab_number
   and b.test_sent in ('Q','Y')
   and to_number(to_char(a.datestamp,'YYYYMM'))=S_month;

   select count(*) into ttl_hpv_plus
   from pcs.lab_results a, pcs.hpv_requests b
   where a.lab_number=b.lab_number

   and b.test_results='+'
   and to_number(to_char(a.datestamp,'YYYYMM'))=S_month;

   select count(*) into ttl_hpv_minus
   from pcs.lab_results a, pcs.hpv_requests b
   where a.lab_number=b.lab_number
   and b.test_results='-'
   and to_number(to_char(a.datestamp,'YYYYMM'))=S_month;

   select count(*) into ttl_hpv_qns
   from pcs.lab_results a, pcs.hpv_requests b
   where a.lab_number=b.lab_number
   and b.test_sent='Q'

   and to_number(to_char(a.datestamp,'YYYYMM'))=S_month;

   rcnt:=(ttl_ascus/ttl_hpv)*100;
   curr_line:=margin||RPAD('TOTAL HPV',15)||
      LPAD(TO_CHAR(ttl_hpv),14)||
      LPAD(TO_CHAR(rcnt,'990.99'),16)||
      '  (% TTL CASES)';
   UTL_FILE.PUTF(file_handle,'\n\n\n\n%s\n\n',curr_line);

   rcnt:=(ttl_hpv_plus/ttl_hpv)*100;
   curr_line:=margin||RPAD('TOTAL HPV (+)',15)||
      LPAD(TO_CHAR(ttl_hpv_plus),14)||
      LPAD(TO_CHAR(rcnt,'990.99'),16);

   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   rcnt:=(ttl_hpv_minus/ttl_hpv)*100;
   curr_line:=margin||RPAD('TOTAL HPV (-)',15)||
      LPAD(TO_CHAR(ttl_hpv_minus),14)||
      LPAD(TO_CHAR(rcnt,'990.99'),16);
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   rcnt:=(ttl_hpv_qns/ttl_hpv)*100;
   curr_line:=margin||RPAD('TOTAL HPV (QNS)',15)||
      LPAD(TO_CHAR(ttl_hpv_qns),14)||
      LPAD(TO_CHAR(rcnt,'990.99'),16);
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);




   /* END OF MONTH NUMBERS */
   UTL_FILE.PUT(file_handle,CHR(12));
   curr_line:=margin||'END OF MONTH NUMBERS:  PREPARATIONS';
   UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);
   curr_line:=margin||
      'PREPARATION				 COUNT	    HIGHEST LAB';
   UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
   UTL_FILE.PUTF(file_handle,'%s\n',dline);
   open preparations;
   loop

      fetch preparations into L_prep,L_prep_descr;
      exit when preparations%NOTFOUND;
      select count(a.preparation),max(a.lab_number)
      into L_prep_count,L_prep_max
      from lab_requisitions a, lab_results b
      where a.lab_number=b.lab_number
      and a.preparation=L_prep
      and to_char(b.datestamp,'YYYYMM')=S_month;
      curr_line:=margin||TO_CHAR(L_prep)||' '||RPAD(L_prep_descr,30)||
	 LPAD(TO_CHAR(L_prep_count),15)||'	 '||TO_CHAR(L_prep_max);
      UTL_FILE.PUTF(file_handle,'%s\n',curr_line);
      UTL_FILE.PUTF(file_handle,'%s\n',dline);
   end loop;

   close preparations;

   UTL_FILE.FCLOSE(file_handle);

exception
   when UTL_FILE.INVALID_PATH then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20051,'invalid path');
   when UTL_FILE.INVALID_MODE then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20052,'invalid mode');
   when UTL_FILE.INVALID_FILEHANDLE then
      UTL_FILE.FCLOSE(file_handle);

      RAISE_APPLICATION_ERROR(-20053,'invalid file handle');
   when UTL_FILE.INVALID_OPERATION then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20054,'invalid operation');
   when UTL_FILE.READ_ERROR then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20055,'read error');
   when UTL_FILE.WRITE_ERROR then
      UTL_FILE.FCLOSE(file_handle);
      RAISE_APPLICATION_ERROR(-20056,'write error');
   when OTHERS then
      UTL_FILE.FCLOSE(file_handle);
      P_error_code:=SQLCODE;

      P_error_message:=SQLERRM;
      insert into pcs.error_log (error_code,error_message,proc_name,code_area,datestamp,sys_user,ref_id)
      values (P_error_code,P_error_message,P_proc_name,P_code_area,SysDate,UID,S_cytotech);
      commit;
      RAISE;

end;
\

grant execute on build_ascus_hpv_file to pcs_user
\