create or replace procedure     build_agree_file
(
   S_month in number
)
as

   P_error_code number;
   P_error_message varchar2(512);
   P_proc_name varchar2(32);
   P_code_area varchar2(32);

   S_file_name varchar2(12);
   S_lname varchar2(32);

   S_fname varchar2(32);
   dir_name varchar2(128);
   S_cytotech number;
   S_tech varchar2(4);
   curr_line varchar2(300);
   curr_page number;
   rcnt number;
   margin varchar2(32);
   indent varchar2(16);
   dline varchar2(256);
   dline2 varchar2(256);
   heading1 varchar2(256);
   heading2 varchar2(256);

   heading3 varchar2(256);
   heading4 varchar2(256);
   heading5 varchar2(256);
   heading6 varchar2(256);
   heading7 varchar2(256);
   cbuf varchar2(256);
   cbuf1 varchar2(256);
   cbuf2 varchar2(256);
   cbuf3 varchar2(256);

   S_period varchar2(64);

   temp_num1 number;

   temp_num2 number;
   temp_num3 number;
   temp_num4 number;

   last_date date;

   file_handle UTL_FILE.FILE_TYPE;
   check_point number;

   cursor tech_list is
      select distinct A.cytotech, B.cytotech_code
      from pcs.lab_results A, pcs.cytotechs B
      where A.cytotech=B.cytotech

      and A.cytotech<>2981
      and to_number(to_char(A.datestamp,'YYYYMM'))=S_month
      order by B.cytotech_code;
   -- cytotech 2981 corresponds to cytotech_code HPV; used for HPV only testing

   tech number;
   tech_code varchar2(5);

   cursor referred_list is
      select A.lab_number
      from lab_results A, lab_result_codes B
      where A.lab_number=B.lab_number
      and B.bethesda_code='13R'

      and A.cytotech=tech
      and to_number(to_char(A.datestamp,'YYYYMM'))=S_month;

   lab_num number;
   total_referred number;
   total_agreed number;
   change_12 number;
   change_13 number;

begin

   P_proc_name:='BUILD_AGREE_FILE';


   P_code_area:='PREP';
   check_point:=0;
   last_date:=LAST_DAY(TO_DATE(TO_CHAR(S_month),'YYYYMM'));
   cbuf1:=TO_CHAR(last_date,'MONYYYY');
   S_file_name:=cbuf1||'.agr';
   dir_name:='REPORTS_DIR';
   file_handle:=UTL_FILE.FOPEN(dir_name,S_file_name,'w');

   S_period:=TO_CHAR(last_date,'MONTH YYYY');

   P_code_area:='HEADER';
   curr_page:=1;
   margin:='   ';

   indent:='   ';
   dline:=margin||'--------------------------------------------------------------------------------';
   heading1:=margin||'PENNSYLVANIA CYTOLOGY SERVICES';
   heading2:=margin||'CYTOLOGIST/PATHOLOGIST AGREEMENT FOR REFERRED 13RS';
   heading3:=margin||'MONTH OF '||S_period;
   heading5:=margin||'						     CHANGE TO		CHANGE TO';
   heading6:=margin||'		  REFERRED	    AGREED	     012		011, 013 OR 014';
   heading7:=margin||'CYTOLOGIST       #	   #	  %	      #      %		 #	%';

   UTL_FILE.PUTF(file_handle,'%s\n',heading1);
   UTL_FILE.PUTF(file_handle,'%s\n',heading2);
   UTL_FILE.PUTF(file_handle,'%s\n',heading3);
   UTL_FILE.PUTF(file_handle,'%s\n',heading5);

   UTL_FILE.PUTF(file_handle,'%s\n',heading6);
   UTL_FILE.PUTF(file_handle,'%s\n',heading7);
   UTL_FILE.PUTF(file_handle,'%s\n',dline);
   open tech_list;
   loop
      fetch tech_list into tech,tech_code;
      exit when tech_list%NOTFOUND;
      total_referred:=0;
      total_agreed:=0;
      change_12:=0;
      change_13:=0;
      open referred_list;
      loop

	 fetch referred_list into lab_num;
	 exit when referred_list%NOTFOUND;
	 total_referred:=total_referred+1;
	 select count(*) into temp_num1
	 from pcs.pathologist_control_codes
	 where lab_number=lab_num
	 and bethesda_code='13R';
	 if (temp_num1>0) then
	    total_agreed:=total_agreed+1;
	 else
	    select count(*) into temp_num2
	    from pcs.pathologist_control_codes
	    where lab_number=lab_num

	    and bethesda_code='012';
	    if (temp_num2>0) then
	       change_12:=change_12+1;
	    else
	       select count(*) into temp_num2
	       from pcs.pathologist_control_codes
	       where lab_number=lab_num
	       and bethesda_code in ('011','013','014');
	       if (temp_num2>0) then
		  change_13:=change_13+1;
	       end if;
	    end if;
	 end if;

      end loop;
      close referred_list;
      if (total_referred<>0) then
	 temp_num2:=(total_agreed/total_referred)*100;
	 temp_num3:=(change_12/total_referred)*100;
	 temp_num4:=(change_13/total_referred)*100;
      else
	 temp_num2:=0;
	 temp_num3:=0;
	 temp_num4:=0;
      end if;
      curr_line:=margin||RPAD(tech_code,6)||LPAD(total_referred,12)||LPAD(total_agreed,12)||TO_CHAR(temp_num2,'990.99')||LPAD(change_12,12)||TO_CHAR(temp_num3,'990.99')||LPAD(change_13,12)||TO_CHAR(temp_num4,'990.99');
      UTL_FILE.PUTF(file_handle,'%s\n\n',curr_line);

   end loop;
   close tech_list;

   commit;

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
