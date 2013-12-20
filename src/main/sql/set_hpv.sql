create or replace PROCEDURE set_hpv (H_lab_number IN NUMBER)
AS
   P_error_code      NUMBER;
   P_error_message   VARCHAR2 (512);
   P_proc_name       VARCHAR2 (32);
   P_code_area       VARCHAR2 (32);

   H_qc              CHAR (1);
   H_path            CHAR (1);

   H_code            VARCHAR2 (2);
   H_sent            VARCHAR2 (2);
   H_practice        NUMBER;
   H_facility        VARCHAR2 (48);
   H_permission      CHAR (1);
   H_ptype           VARCHAR2 (32);

   H_age             NUMBER;
   H_dob             DATE;

   rcnt              NUMBER;
   hpv_in_house      NUMBER;
BEGIN
   P_proc_name := 'SET_HPV';

    /* First, determine whether HPV test has been requested for this lab.
    If it was, then there will be an entry in the hpv_requests table
    for the given lab_number.  In addition, a code would have been
    selected at data entry.  The code is typically 19 or 20.  Use
    of the letter Y is obsolete.  A code of R indicates HPV test
    should be done (R)egardless of the lab results.
     */

   SELECT COUNT (*)
     INTO rcnt
     FROM pcs.hpv_requests
    WHERE lab_number = H_lab_number AND hpv_code IN ('Y', '19', '20', 'R');


   /* Falling into this conditional means HPV test WAS requested */
   IF (rcnt > 0)
   THEN
      /* Determine what case the lab is: pathologist case (path_status=Y),
         quality control cas (qc_status=Y and path_status=N) or just a
         regular case (qc_status=N and path_status=N); this is needed to
         know which set of result codes to use.
      */
      SELECT R.path_status,
             R.qc_status,
             L.practice,
             P.hpv_permission,
             P.practice_type
        INTO H_path,
             H_qc,
             H_practice,
             H_permission,
             H_ptype
        FROM pcs.lab_results R, pcs.lab_requisitions L, pcs.practices P
       WHERE     R.lab_number = L.lab_number
             AND L.practice = P.practice
             AND R.lab_number = H_lab_number;

      SELECT hpv_code, test_sent
        INTO H_code, H_sent
        FROM pcs.hpv_requests
       WHERE lab_number = H_lab_number;

      SELECT job_status
        INTO hpv_in_house
        FROM pcs.job_control
       WHERE job_descr = 'HPV LAB';

      IF (hpv_in_house = 0)
      THEN
         H_facility := 'CLEARPATH';
      ELSE
         H_facility := 'PCS';
      END IF;

      /* Oracle sometimes does strange things with NULL values! */
      IF (H_permission IS NULL)
      THEN
         H_permission := 'N';
      END IF;

      /* Whatever the result set case, does the following.  First, decides
         whether there are any XREF matches between the HPV code selected
         at data entry and any of the final result codes for the lab. Stores
         this value in rcnt (row count).
      */
      IF (H_path = 'Y')
      THEN
         SELECT COUNT (*)
           INTO rcnt
           FROM pcs.pathologist_control_codes P, pcs.beth_hpv_xref X
          WHERE     P.lab_number = H_lab_number
                AND P.bethesda_code = X.bethesda_code
                AND X.practice_type = H_ptype
                AND X.hpv_code = H_code;
      ELSIF (H_qc = 'Y')
      THEN
         SELECT COUNT (*)
           INTO rcnt
           FROM pcs.quality_control_codes Q, pcs.beth_hpv_xref X
          WHERE     Q.lab_number = H_lab_number
                AND Q.bethesda_code = X.bethesda_code
                AND X.practice_type = H_ptype
                AND X.hpv_code = H_code;
      ELSE
         SELECT COUNT (*)
           INTO rcnt
           FROM pcs.lab_result_codes S, pcs.beth_hpv_xref X
          WHERE     S.lab_number = H_lab_number
                AND S.bethesda_code = X.bethesda_code
                AND X.practice_type = H_ptype
                AND X.hpv_code = H_code;
      END IF;

      /* For everyone, to get into the first condition there must
         have been an XREF match OR do HPV regardless was selected
         at data entry. The first condition queues the lab to be
         sent for HPV.

         03/10/2010: added practice_type to xref table today and
         now part of each conditional computing rcnt
      */
      IF (rcnt > 0 OR H_code = 'R')
      THEN
         IF (H_sent IS NULL OR H_sent = 'N')
         THEN
            UPDATE pcs.hpv_requests
               SET datestamp = SYSDATE,
                   test_sent = 'R',
                   hpv_lab = H_facility,
                   needs_permission = H_permission
             WHERE lab_number = H_lab_number;
         END IF;
      /* This is the "fall through" or default for the conditional.

         If none of the specified conditions where met, then although
         HPV testing was requested, the lab will not be sent out for it.
      */
      ELSE
         UPDATE pcs.hpv_requests
            SET datestamp = SYSDATE, test_sent = 'N'
          WHERE lab_number = H_lab_number;
      END IF;
   END IF;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      P_error_code := SQLCODE;
      P_error_message := SQLERRM;

      INSERT INTO pcs.error_log (ERROR_CODE,
                                 error_message,
                                 proc_name,
                                 code_area,
                                 datestamp,
                                 sys_user)
           VALUES (P_error_code,
                   P_error_message,
                   P_proc_name,
                   P_code_area,
                   SYSDATE,
                   UID);

      COMMIT;
      RAISE;
END; 
\

grant execute on pcs.set_hpv to pcs_user
\
