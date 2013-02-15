package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       CytoPathDbOps.java
    Created By: John Cardella, Software Engineer
    
    Function:   Database actions for cytopathology
    reports.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import java.sql.*;
import java.util.Vector;
import javax.swing.JOptionPane;

public class CytoPathDbOps implements Runnable
{
    Thread dbThread;
    CytoPathReport parent;
    boolean createERept = false;
    /*  date results were entered as an integer value in
        the format YYYYMMDD yields a strict chronological
        value that is easily used for date comparisons
    */
    int iDatestamp;
    
    // default constructor; not used
	public CytoPathDbOps()	{ }

    /*
        Constructor that sets the CytoPathReport object as
        the parent of the CytoPathDbOps (CytoPathology Database
        Operations) object.  Logging for this object is written
        to the parent's LogFile object.
    */
	public CytoPathDbOps(CytoPathReport p)
	{
		this();
		this.parent=p;
	}

    /****************************************************************************
        THREADING METHODS FOR DATABASE OPERATIONS
    ****************************************************************************/
    public void kill() {
        try { dbThread.stop(); }
        catch (Exception e) { parent.log.write(e); }
    }
    public void getReports() {
        dbThread = new Thread(this);
        dbThread.setPriority(Thread.MAX_PRIORITY);
        dbThread.start();
    }
	public synchronized void run() {
	    boolean rv = true;
	    /*  Determine which query operation to use based on the print mode.
	        For DRAFT and FINAL mode (i.e. non-queued requests for reports)
	        use straight query that indicates the lab number range
	        requested.
	    */
        if ((parent.printMode==Lab.DRAFT)||(parent.printMode==Lab.FINAL)) {
            createERept=false;
            rv=query(parent.startingLabNumber,parent.endingLabNumber);
            if (!rv) {
                Utils.createErrMsg("No Data Located!!");
                parent.dispose();
            }
        }
        /*
            ... otherwise use the queryQueue method which retrieves data
            for labReport objects based on which lab numbers are currently
            in the print queue for either CURR_DRAFT or CURR_FINAL modes.
        */
        else {
            // call queryQueue() only if there is data in the queue
            if (parent.queueSize>0) { rv=queryQueue(); }
            // otherwise do no printing (since no data) and display error
            else {
                rv=false;
                Utils.createErrMsg("No Cytopathology Reports to Print!");
            }
        }
        // if labReport objects exist call parents print method and exit
        if (rv) {
            Vector eReports = new Vector();
            eReports=extractElectronicReports(parent.labReportVect);
            if (eReports.size()>0) {
                Export eFile = new Export(Lab.CYTOPATHOLOGY_REPORTS, parent.amendedCodes);
                eFile.write(eReports);
            }
	        parent.cytoPathReport();
	        parent.closingActions();
        }
        // otherwise reset the CytoPathReport screen
        else parent.resetForm();
	}
    /***************************************************************************/
	

	/*
	    Retrieve data for lab numbers in the specified
	    range:  sLab (starting) - eLab (ending); this as
	    opposed to retrieving the data currently in the 
	    print queue
	*/
    public boolean query(int sLab, int eLab)  {
        parent.log.write("query("+sLab+".."+eLab+")");
        boolean exitStatus=true;
        String e_report = null;
        String dateReported=null;
        try  {
            // SQL STATEMENT ID 001
            String SQL = new String(
                "SELECT \n"+
                "   lab.lab_number, \n"+                                                //01
                "   lab.patient, \n"+                                                   //02
                "   lab.practice,\n"+                                                   //03
                "   lab.doctor, \n"+                                                    //04
                "   lab.patient_id, \n"+                                                //05
                "   TO_CHAR(lab.date_collected,'MM/DD/YYYY'), \n"+                      //06
                "   TO_CHAR(lab.receive_date,'MM/DD/YYYY'), \n"+                        //07
                "   lab.lmp, \n"+                                                       //08
                "   lab.finished, \n"+                                                  //09
                "   pat.lname, \n"+                                                     //10
                "   pat.fname, \n"+                                                     //11
                "   pat.ssn, \n"+                                                       //12
                "   TO_CHAR(pat.dob,'MM/DD/YYYY'), \n"+                                 //13
                "   cn.client_notes, \n"+                                               //14
                "   pr.practice, \n"+                                                   //15
                "   pr.name, \n"+                                                       //16
                "   pr.address1, \n"+                                                   //17
                "   pr.address2, \n"+                                                   //18
                "   pr.city, \n"+                                                       //19
                "   pr.state, \n"+                                                      //20
                "   pr.zip, \n"+                                                        //21
                "   pr.client_notes, \n"+                                               //22
                "   pr.report_copies, \n"+                                              //23
                "   dr.lname, \n"+                                                      //24
                "   dr.fname, \n"+                                                      //25
                "   lab.previous_lab, \n"+                                              //26
                "   RTRIM(TO_CHAR(SysDate,'fmDay, fmMonth'))||' '||TO_CHAR(SysDate,'DD, fmYYYY'), \n"+
                "   ct.cytotech_code, \n"+                                              //28
                "   res.pathologist, \n"+                                               //29
                "   res.qc_status, \n"+                                                 //30
                "   rem.comment_text, \n"+                                              //31
                "   to_char(mat.superficial,999)||'%', \n"+                             //32
                "   to_char(mat.intermediate,999)||'%', \n"+                            //33
                "   to_char(mat.parabasal,999)||'%', \n"+                               //34
                "   p.lname, \n"+                                                       //35
                "   p.fname, \n"+                                                       //36
                "   p.mi, \n"+                                                          //37
                "   p.title, \n"+                                                       //38
                "   p.degree, \n"+                                                      //39
                "   lab.preparation, \n"+                                               //40
                "   lab.rush, \n"+                                                      //41
                "   NVL(mat.superficial,0)+NVL(mat.intermediate,0)+NVL(mat.parabasal,0), \n"+
                "   res.path_status, \n"+                                               //43
                "   lab.doctor_text, \n"+                                               //44
                "   pat.mi, \n"+                                                        //45
                "   TO_NUMBER(TO_CHAR(res.datestamp,'YYYYMMDD')), \n"+                  //46
                "   TO_CHAR(res.datestamp,'MM/DD/YYYY'), \n"+                           //47
                "   hpv.test_sent, \n"+                                                 //48
                "   TO_CHAR(ph.verified_on,'MM/DD/YYYY'), \n"+                          //49
                "   ph.verified_by, \n"+                                                //50
                "   pr.e_reporting, \n"+                                                //51
                "   pr.program, \n"+                                                    //52
                "   pr.parent_account, \n"+                                             //53
                "   DECODE(res.pap_class,0,10,res.pap_class), \n"+                      //54
                "   pr.practice_type \n"+                                               //55
                "FROM \n"+
                "   pcs.lab_requisitions lab, \n"+
                "   pcs.patients pat, \n"+
                "   pcs.practices pr, \n"+
                "   pcs.lab_req_client_notes cn, \n"+
                "   pcs.doctors dr, \n"+
                "   pcs.cytotechs ct, \n"+
                "   pcs.lab_results res, \n"+
                "   pcs.lab_result_comments rem, \n"+
                "   pcs.lab_mat_index mat, \n"+
                "   pcs.pathologists p, \n"+
                "   pcs.hpv_requests hpv, \n"+
                "   pcs.pathologist_holds ph \n"+
                "WHERE \n"+
                "   lab.lab_number=res.lab_number and \n"+
                "   lab.lab_number=cn.lab_number(+) and \n"+
                "   lab.lab_number=hpv.lab_number(+) and \n"+
                "   lab.practice=pr.practice and \n"+
                "   lab.doctor=dr.doctor and \n"+
                "   lab.patient=pat.patient and \n"+
                "   res.cytotech=ct.cytotech and \n"+
                "   res.lab_number=rem.lab_number(+) and \n"+
                "   res.lab_number=mat.lab_number(+) and \n"+
                "   res.lab_number=ph.lab_number(+) and \n"+
                "   res.pathologist=p.pathologist_code(+) and \n"+
                "   lab.finished>0 and \n"+
                "   lab.lab_number>="+sLab+" and \n"+
                "   lab.lab_number<="+eLab+" \n");
                
            if (parent.printMode==Lab.FINAL) 
                SQL+="ORDER BY pr.practice, lab.lab_number \n";
            else
                SQL+="ORDER BY lab.lab_number \n";

            // get the current date for report(s)
            String dateQuery = new String(
                "SELECT RTRIM(TO_CHAR(SysDate,'fmDay, fmMonth'))"+
                "||' '||TO_CHAR(SysDate,'DD, fmYYYY') FROM DUAL");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(dateQuery);
            while (rs.next()) { parent.reportDate=rs.getString(1); }  

            // retrieve the data
            rs = stmt.executeQuery(SQL);
            while (rs.next()) {
                LabReportRec labReport = new LabReportRec();
                labReport.lab_number=rs.getInt(1);
                labReport.patient=rs.getInt(2);
                labReport.practice=rs.getInt(3);
                labReport.doctor=rs.getInt(4);
                labReport.patient_id=rs.getString(5);
                labReport.date_collected=rs.getString(6);
                labReport.receive_date=rs.getString(7);
                labReport.lmp=rs.getString(8);
                labReport.finished=rs.getInt(9);
                labReport.pat_lname=rs.getString(10);
                labReport.pat_fname=rs.getString(11);
                labReport.pat_ssn=rs.getString(12);
                labReport.pat_dob=rs.getString(13);
                labReport.client_notes=rs.getString(14);
                labReport.practice=rs.getInt(15);
                labReport.prac_name=rs.getString(16);
                labReport.prac_address1=rs.getString(17);
                labReport.prac_address2=rs.getString(18);
                labReport.prac_city=rs.getString(19);
                labReport.prac_state=rs.getString(20);
                labReport.prac_zip=rs.getString(21);
                labReport.prac_client_notes=rs.getString(22);
                labReport.report_copies=rs.getInt(23);
                labReport.doc_lname=rs.getString(24);
                labReport.doc_fname=rs.getString(25);
                labReport.pat_last_lab=rs.getInt(26);
                labReport.cytotech_code=rs.getString(28);
                labReport.pathologist_code=rs.getString(29);
                labReport.qc_status=rs.getString(30);
                labReport.remarks=rs.getString(31);
                labReport.superficial=rs.getString(32);
                labReport.intermediate=rs.getString(33);
                labReport.parabasal=rs.getString(34);
                labReport.path_lname=rs.getString(35);
                labReport.path_fname=rs.getString(36);
                labReport.path_mi=rs.getString(37);
                labReport.path_title=rs.getString(38);
                labReport.path_degree=rs.getString(39);
                labReport.preparation=rs.getInt(40);
                labReport.rush=rs.getString(41);
                labReport.sumMatNdx=rs.getInt(42);
                labReport.path_status=rs.getString(43);
                labReport.doctor_text=rs.getString(44);
                labReport.pat_mi=rs.getString(45);
                iDatestamp=rs.getInt(46);
                labReport.iDatestamp=iDatestamp;
                labReport.datestamp=rs.getString(47);
                labReport.test_sent=rs.getString(48);
                labReport.verified_on=rs.getString(49);
                labReport.verified_by=rs.getString(50);
                labReport.e_reporting=rs.getString(51);
                labReport.program=rs.getString(52);
                labReport.parent_account=rs.getInt(53);
                labReport.pap_class=rs.getInt(54);
                labReport.practice_type=rs.getString(55);
                if (!Utils.isNull(labReport.remarks)) {
                    labReport.formatRemarks();
                }
                // get details for lab currently pointed to
                queryDetails(labReport);
                /*  determine which result set takes precedence
                    and retrieve those results
                */
                setDirector(labReport);
                if (labReport.path_status.equals("Y"))
                    queryPathResults(labReport);
                else if (labReport.qc_status.equals("Y"))
                    queryQCResults(labReport);
                else
                    queryResults(labReport);
                
                /* this is a hard coded value to facilitate use of appropriate date reported on cytology
                 * reports; prior to this implementation the date reported was the date completed of the
                 * screening tech, or QC tech , or pathologist; whichever codes took precedence. From the time
                 * of this implementation forward the date reported on the cytopathology reports will be the date
                 * the results were input into the system. LabReportRec.datestamp holds the numeric value
                 * of the current date; in the format YYYYMMDD it is numerically true.
                 */
                if (labReport.iDatestamp>=20120627) {
                	if (!Utils.isNull(labReport.released))
                		labReport.date_reported=labReport.released;
                	else if (!Utils.isNull(labReport.submitted))
                		labReport.date_reported=labReport.submitted;
                	else
                		labReport.date_reported=dateReported;
                }
                
                if (!Utils.isNull(labReport.test_sent)) {
                    if (labReport.test_sent.equals("R")||labReport.test_sent.equals("P"))
                        labReport.HPVmessage=true;
                }
                e_report=labReport.e_reporting;
                parent.labReportVect.addElement(labReport);
            }
            parent.msgLabel.setText(null);
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }                
        }
        catch (Exception e) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        if (parent.printMode==Lab.FINAL 
        && parent.labReportVect.size()==1 
        && (e_report.equals("Y")||e_report.equals("B"))) {
	        JOptionPane confirmERept = new javax.swing.JOptionPane();
            int rv = confirmERept.showConfirmDialog(
		                null,"Create Electronic Report?",
		                "Electronic Report",confirmERept.YES_NO_OPTION,
		                confirmERept.QUESTION_MESSAGE);
            if (rv==confirmERept.YES_OPTION) {
                createERept=true;
            }
        }
        return(exitStatus);            
    }
	
	/* Set lab director for lab number
    */
	public void setDirector(LabReportRec labReport)
	{
	    PreparedStatement pstmt = null;
	    try {
	        String SQL =
                "SELECT director_name  \n"+
                "FROM pcs.directors \n"+
                "WHERE effective_lab IN \n"+
                "   (SELECT MAX(effective_lab) \n"+
                "    FROM pcs.directors \n"+
                "    WHERE effective_lab <= ?) \n";
	        pstmt = DbConnection.process().prepareStatement(SQL); 
	        pstmt.setInt(1,labReport.lab_number);
	        ResultSet rs = pstmt.executeQuery();
	        while (rs.next()) { labReport.director_name = rs.getString(1); }
            try { rs.close(); pstmt.close(); }
            catch (SQLException e) { parent.log.write(e); }                
	    }
	    catch (SQLException e) { parent.log.write(e.toString()); }
	    catch (Exception e) { parent.log.write(e); }
	}
	
	/*
	    Query the lab details from the requisition
	    for the lab number indicated in labReport
	*/
    public boolean queryDetails(LabReportRec labReport)  
    {
        boolean exitStatus = true;
        try  {
            // SQL STATEMENT ID 002
            String SQL = new String(
                    "SELECT \n"+
                    "   dc.description, \n"+
                    "   dc.additional_info, \n"+
                    "   ld.detail_code, \n"+
                    "   NVL(ldc.comment_text,'  '), \n"+
                    "   dc.detail_type \n"+
                    "FROM \n"+
                    "   pcs.detail_codes dc, \n"+
                    "   pcs.lab_req_details ld, \n"+
                    "   pcs.lab_req_details_additional ldc \n"+
                    "WHERE \n"+
                    "   ld.detail_code=dc.detail_code and \n"+
                    "   ld.detail_id=ldc.detail_id(+) and \n"+
                    "   ld.lab_number="+labReport.lab_number+" \n"+
                    "ORDER BY ld.detail_code \n");
                
            DetailCodeRec dCodeRec = null;
            // Was this lab a rush job?
            if (labReport.rush.equals("Y")) {
                dCodeRec = new DetailCodeRec();
                dCodeRec.description = new String("RUSH");
                dCodeRec.additional_info = new String("N");
                dCodeRec.detail_code=0;
                dCodeRec.textEntered = new String();
                dCodeRec.isSelected=true;
                dCodeRec.detail_type = new String("OTHER");
                labReport.numOthers++;
                labReport.detailVect.addElement(dCodeRec);
                labReport.numDetails++;
            }
            // Is LMP data available?
            if (!Utils.isNull(labReport.lmp)) {
                dCodeRec = new DetailCodeRec();
                dCodeRec.description = new String("LMP");
                dCodeRec.additional_info = new String("Y");
                dCodeRec.detail_code=1;
                dCodeRec.textEntered = new String(labReport.lmp);
                dCodeRec.isSelected=true;
                dCodeRec.detail_type = new String("HISTORY");
                labReport.numHistory++;
                labReport.detailVect.addElement(dCodeRec);
                labReport.numDetails++;
            }

            // Retrieve the details
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            dCodeRec = new DetailCodeRec();
            while (rs.next()) {
                dCodeRec.description=rs.getString(1);
                dCodeRec.additional_info=rs.getString(2);
                dCodeRec.detail_code=rs.getInt(3);
                dCodeRec.textEntered=rs.getString(4);
                dCodeRec.isSelected=true;
                dCodeRec.detail_type=rs.getString(5);
                int code = rs.getInt(3);
                /*
                    The various types of details are tallied; this is necessary
                    in order to format the layout of this section of the report
                */
                if (dCodeRec.detail_type.equals("SOURCE")) labReport.numSources++;
                else if (dCodeRec.detail_type.equals("DEVICE")) labReport.numDevices++;
                else if (dCodeRec.detail_type.equals("CONDITION")) labReport.numConditions++;
                else if (dCodeRec.detail_type.equals("OTHER")) labReport.numOthers++;
                else if (dCodeRec.detail_type.equals("HISTORY")) labReport.numHistory++;
                labReport.numDetails++;
                labReport.detailVect.addElement(dCodeRec);
                dCodeRec = new DetailCodeRec();
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }
        }
        catch (Exception e) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

    /*
        Retrieve the data for all labs CURRENTLY in print queue
        for the print mode that is selected (either DRAFTS or FINALS).
        As results are entered, the lab is queued for printing; pathologist
        cases are defaulted for draft prints first
    */
    public boolean queryQueue()  
    {
        parent.log.write("queryQueue()");
        boolean exitStatus=true;
        String dateReported=null;
        Vector tmpVect = new Vector();
        Vector faxVect = new Vector();
        try  {
            // SQL STATEMENT ID 003
            String SQL = new String( 
                "SELECT \n"+
                "   q.lab_number, \n"+                                                  //01
                "   lab.patient, \n"+                                                   //02
                "   lab.practice,\n"+                                                   //03
                "   lab.doctor, \n"+                                                    //04
                "   lab.patient_id, \n"+                                                //05
                "   TO_CHAR(lab.date_collected,'MM/DD/YYYY'), \n"+                      //06
                "   TO_CHAR(lab.receive_date,'MM/DD/YYYY'), \n"+                        //07
                "   lab.lmp, \n"+                                                       //08
                "   lab.finished, \n"+                                                  //09
                "   pat.lname, \n"+                                                     //10
                "   pat.fname, \n"+                                                     //11
                "   pat.ssn, \n"+                                                       //12
                "   TO_CHAR(pat.dob,'MM/DD/YYYY'), \n"+                                 //13
                "   cn.client_notes, \n"+                                               //14
                "   pr.practice, \n"+                                                   //15
                "   pr.name, \n"+                                                       //16
                "   pr.address1, \n"+                                                   //17
                "   pr.address2, \n"+                                                   //18
                "   pr.city, \n"+                                                       //19
                "   pr.state, \n"+                                                      //20
                "   pr.zip, \n"+                                                        //21
                "   pr.client_notes, \n"+                                               //22
                "   pr.report_copies, \n"+                                              //23
                "   dr.lname, \n"+                                                      //24
                "   dr.fname, \n"+                                                      //25
                "   lab.previous_lab, \n"+                                              //26
                "   RTRIM(TO_CHAR(SysDate,'fmDay, fmMonth'))||' '||TO_CHAR(SysDate,'DD, fmYYYY'), \n"+
                "   ct.cytotech_code, \n"+                                              //28
                "   res.pathologist, \n"+                                               //29
                "   res.qc_status, \n"+                                                 //30
                "   rem.comment_text, \n"+                                              //31
                "   to_char(mat.superficial,999)||'%', \n"+                             //32
                "   to_char(mat.intermediate,999)||'%', \n"+                            //33
                "   to_char(mat.parabasal,999)||'%', \n"+                               //34
                "   p.lname, \n"+                                                       //35
                "   p.fname, \n"+                                                       //36
                "   p.mi, \n"+                                                          //37
                "   p.title, \n"+                                                       //38
                "   p.degree, \n"+                                                      //39
                "   lab.preparation, \n"+                                               //40
                "   lab.rush, \n"+                                                      //41
                "   NVL(mat.superficial,0)+NVL(mat.intermediate,0)+NVL(mat.parabasal,0), \n"+
                "   res.path_status, \n"+                                               //43
                "   lab.doctor_text, \n"+                                               //44
                "   pat.mi, \n"+                                                        //45
                "   res.biopsy_code, \n"+                                               //46
                "   TO_NUMBER(TO_CHAR(res.datestamp,'YYYYMMDD')), \n"+                  //47
                "   TO_NUMBER(TO_CHAR(SysDate,'YYYYMMDD')), \n"+                        //48
                "   TO_CHAR(res.datestamp,'MM/DD/YYYY'), \n"+                           //49
                "   pr.hold_final, \n"+                                                 //50
                "   hpv.test_sent, \n"+                                                 //51
                "   pr.send_fax, \n"+                                                   //52
                "   TO_CHAR(ph.verified_on,'MM/DD/YYYY'), \n"+                          //53
                "   ph.verified_by, \n"+                                                //54
                "   pr.e_reporting, \n"+                                                //55
                "   pr.program, \n"+                                                    //56
                "   pr.parent_account, \n"+                                             //57
                "   DECODE(res.pap_class,0,10,res.pap_class), \n"+                      //58
                "   pr.practice_type \n"+                                               //59
                "FROM \n"+
                "   pcs.lab_requisitions lab, \n"+
                "   pcs.patients pat, \n"+
                "   pcs.practices pr, \n"+
                "   pcs.lab_req_client_notes cn, \n"+
                "   pcs.doctors dr, \n"+
                "   pcs.cytopath_print_queue q, \n"+
                "   pcs.cytotechs ct, \n"+
                "   pcs.lab_results res, \n"+
                "   pcs.lab_result_comments rem, \n"+
                "   pcs.lab_mat_index mat, \n"+
                "   pcs.pathologists p, \n"+
                "   pcs.hpv_requests hpv, \n"+
                "   pcs.pathologist_holds ph \n"+
                "WHERE \n"+
                "   q.lab_number=lab.lab_number and \n"+
                "   lab.finished>0 and \n"+
                "   lab.lab_number=cn.lab_number(+) and \n"+
                "   lab.lab_number=hpv.lab_number(+) and \n"+
                "   lab.practice=pr.practice and \n"+
                "   lab.doctor=dr.doctor and \n"+
                "   lab.patient=pat.patient and \n"+
                "   res.lab_number=q.lab_number and \n"+
                "   res.cytotech=ct.cytotech and \n"+
                "   res.lab_number=rem.lab_number(+) and \n"+
                "   res.lab_number=mat.lab_number(+) and \n"+
                "   res.lab_number=ph.lab_number(+) and \n"+
                "   res.pathologist=p.pathologist_code(+) and \n"+
                "   q.first_print="+parent.printMode+" \n");

            /*  If the print mode is for FINAL reports the sort order puts
                biopsy request labs first as these ones are tagged to be
                faxed.
            */
            if (parent.printMode==Lab.CURR_FINAL) 
                SQL+="ORDER BY res.biopsy_code, pr.practice, lab.lab_number \n";
            else if (parent.printMode==Lab.CURR_HPV)
                SQL+="ORDER BY pr.practice, lab.lab_number \n";
            /*  If the print mode is for DRAFT reports the sort order
                is by straight lab number.
            */
            else
                SQL+="ORDER BY lab.lab_number \n";

            // retrieve and format the current date for the reports
            String dateQuery = new String(
                "SELECT RTRIM(TO_CHAR(SysDate,'fmDay, fmMonth'))"+
                "||' '||TO_CHAR(SysDate,'DD, fmYYYY') FROM DUAL");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(dateQuery);
            while (rs.next()) { parent.reportDate=rs.getString(1); }  
            
            if (parent.printMode==Lab.CURR_DRAFT) 
                parent.NUM_REPORTS=parent.numDrafts;
            else if (parent.printMode==Lab.CURR_FINAL) 
                parent.NUM_REPORTS=parent.numFinals;
            else if (parent.printMode==Lab.CURR_HPV)
                parent.NUM_REPORTS=parent.numHPVs;
                
            int ndx=0;
            try { rs=stmt.executeQuery(SQL); }
            catch (SQLException e) { parent.log.write(e); }
            int reportCounter=parent.NUM_REPORTS;
            iDatestamp=0;
            int iToday=0;
            parent.log.write("   open labReportVect cursor");
            /*  Retrieve the data; the date for each lab number is
                stored in a LabReportRec class; each individual lab
                report object is then stored in a vector of report objects.
            */
            while (rs.next()) {
                LabReportRec labReport = new LabReportRec();
                labReport.lab_number=rs.getInt(1);
                labReport.patient=rs.getInt(2);
                labReport.practice=rs.getInt(3);
                labReport.doctor=rs.getInt(4);
                labReport.patient_id=rs.getString(5);
                labReport.date_collected=rs.getString(6);
                labReport.receive_date=rs.getString(7);
                labReport.lmp=rs.getString(8);
                labReport.finished=rs.getInt(9);
                labReport.pat_lname=rs.getString(10);
                labReport.pat_fname=rs.getString(11);
                labReport.pat_ssn=rs.getString(12);
                labReport.pat_dob=rs.getString(13);
                labReport.client_notes=rs.getString(14);
                labReport.prac_name=rs.getString(16);
                labReport.prac_address1=rs.getString(17);
                labReport.prac_address2=rs.getString(18);
                labReport.prac_city=rs.getString(19);
                labReport.prac_state=rs.getString(20);
                labReport.prac_zip=rs.getString(21);
                labReport.prac_client_notes=rs.getString(22);
                labReport.report_copies=rs.getInt(23);
                labReport.doc_lname=rs.getString(24);
                labReport.doc_fname=rs.getString(25);
                labReport.pat_last_lab=rs.getInt(26);
                labReport.cytotech_code=rs.getString(28);
                labReport.pathologist_code=rs.getString(29);
                labReport.qc_status=rs.getString(30);
                labReport.remarks=rs.getString(31);
                labReport.superficial=rs.getString(32);
                labReport.intermediate=rs.getString(33);
                labReport.parabasal=rs.getString(34);
                labReport.path_lname=rs.getString(35);
                labReport.path_fname=rs.getString(36);
                labReport.path_mi=rs.getString(37);
                labReport.path_title=rs.getString(38);
                labReport.path_degree=rs.getString(39);
                labReport.preparation=rs.getInt(40);
                labReport.rush=rs.getString(41);
                labReport.sumMatNdx=rs.getInt(42);
                labReport.path_status=rs.getString(43);
                labReport.doctor_text=rs.getString(44);
                labReport.pat_mi=rs.getString(45);
                labReport.biopsy_code=rs.getString(46);
                iDatestamp=rs.getInt(47);
                labReport.iDatestamp=iDatestamp;
                labReport.datestamp=rs.getString(49);
                dateReported = rs.getString(49);
                labReport.hold_final=rs.getString(50);
                labReport.test_sent=rs.getString(51);
                labReport.send_fax=rs.getString(52);
                labReport.verified_on=rs.getString(53);
                labReport.verified_by=rs.getString(54);
                labReport.e_reporting=rs.getString(55);
                labReport.program=rs.getString(56);
                labReport.parent_account=rs.getInt(57);
                labReport.pap_class=rs.getInt(58);
                labReport.practice_type=rs.getString(59);
                if (!Utils.isNull(labReport.remarks)) {
                    labReport.formatRemarks();
                }
                // retrieve the details from the requisition for this lab
                queryDetails(labReport);
                /*  determine which result set takes precedence
                    and then retrieve those result codes
                */
                setDirector(labReport);
                if (labReport.path_status.equals("Y"))
                    queryPathResults(labReport);
                else if (labReport.qc_status.equals("Y"))
                    queryQCResults(labReport);
                else
                    queryResults(labReport);

                /* this is a hard coded value to facilitate use of appropriate date reported on cytology
                 * reports; prior to this implementation the date reported was the date completed of the
                 * screening tech, or QC tech , or pathologist; whichever codes took precedence. From the time
                 * of this implementation forward the date reported on the cytopathology reports will be the date
                 * the results were input into the system. LabReportRec.datestamp holds the numeric value
                 * of the current date; in the format YYYYMMDD it is numerically true.
                 */
                if (labReport.iDatestamp>=20120627) {
                	if (!Utils.isNull(labReport.released))
                		labReport.date_reported=labReport.released;
                	else if (!Utils.isNull(labReport.submitted))
                		labReport.date_reported=labReport.submitted;
                	else
                		labReport.date_reported=dateReported;
                }
                
                ndx++;
                /*  the report counter decrements and is used for
                    display purposes; once the user clicks the retrieve
                    button they may visually see the display change 
                    starting from the total number of reports down
                    to zero, at which point the Windows print windows
                    appears
                */
                reportCounter--;
                if (parent.printMode==Lab.CURR_DRAFT)   
                    parent.draftPrints.setText(Integer.toString(reportCounter));
                else if (parent.printMode==Lab.CURR_FINAL) {
                    parent.finalPrints.setText(Integer.toString(reportCounter));
                    if (!Utils.isNull(labReport.test_sent)) {
                        if (labReport.test_sent.equals("P")||labReport.test_sent.equals("R"))
                            labReport.HPVmessage=true;
                    }
                }
                else if (parent.printMode==Lab.CURR_HPV) {
                    parent.hpvPrints.setText(Integer.toString(reportCounter));
                }
                parent.draftPrints.repaint();
                parent.draftPrints.revalidate();
                parent.repaint();
                /*
                if (parent.printMode==Lab.CURR_FINAL
                &&  Utils.equals(labReport.hold_final,"Y")
                &&  Utils.equals(labReport.test_sent,"P")
                &&  Utils.equals(labReport.path_status,"Y")
                &&  Utils.isNull(labReport.biopsy_code)) {
                    tmpVect.addElement(labReport);
                }
                */
                if (parent.printMode==Lab.CURR_FINAL
                && labReport.send_fax.equals("Y")
                && Utils.isNull(labReport.biopsy_code))
                {
                    faxVect.addElement(labReport);
                }
                else
                    parent.labReportVect.addElement(labReport);
            }
            int numHolds = 0;
            int numFaxes = 0;
            if (tmpVect.size()>0) {
                parent.hasHoldFinals=true;
                numHolds=tmpVect.size();
                for (int i=0; i<tmpVect.size(); i++) {
                    LabReportRec r = (LabReportRec)tmpVect.elementAt(i);
                    if (r.path_status.equals("Y"))
                        r.HPVmessage=false;
                    parent.labReportVect.addElement(r);
                }
            }
            if (faxVect.size()>0) {
                parent.hasFaxFinals=true;
                numFaxes=faxVect.size();
                for (int i=0; i<faxVect.size(); i++) {
                    LabReportRec r = (LabReportRec)faxVect.elementAt(i);
                    parent.labReportVect.addElement(r);
                }
            }
            parent.holdFinalsNdx=parent.labReportVect.size()-numHolds-numFaxes;
            parent.log.write(
                "   close labReportVect cursor ["+parent.labReportVect.size()+"]");
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }
            
            /*  Begin retrieving the various HPV data; initially set hasExceptions
                to false.  hasExceptions refers to several special cases for HPV data.
                If any one of these cases occurs the boolean hasExceptions is
                set to true.
            */
            parent.hasExceptions=false;
            /*  The HPVrequests vector holds Strings that are formatted lines
                of HPV data.  This data is added to the Oracle pcs.hpv_requests
                as results are entered; the system determines through rules
                whether a request for HPV testing indicated on a requisition
                will actually be carried out, and if so sets the test_sent field
                to a value of R.  The HPVrequests vector holds all the R values which
                indicate to print the HPV requests on a requisition sheet that is
                printed each time current DRAFTs are printed.  The data is sorted
                by all labs in which the FINAL report should be held until HPV results
                are received, and those that do not have to be held.
            */
            parent.HPVrequests = new Vector();
            // SQL STATEMENT ID 004
            /*
            SQL =
                "select LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30)||'  '|| \n"+
                "DECODE(P.ssn,NULL,'   -  -    ',SUBSTR(P.ssn,1,3)||'-'||SUBSTR(P.ssn,4,2)||'-'||SUBSTR(P.ssn,6,4)) \n"+
                "||'  '||NVL(TO_CHAR(P.dob,'MM/DD/YY'),'  /  /  ')||'  '|| \n"+
                "NVL(TO_CHAR(L.date_collected,'MM/DD/YY'),'  /  /  ')||'   '|| \n"+
                "RPAD(L.doctor_text,30), \n"+
                "D.hold_final,R.biopsy_code,R.path_status \n"+
                "from pcs.lab_requisitions L, pcs.lab_results R, pcs.patients P, \n"+
                "   pcs.hpv_requests H, pcs.practices D \n"+
                "where L.patient=P.patient \n"+
                "and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=D.practice \n"+
                "and H.test_sent='R' \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and L.preparation<>5 \n"+
                "and H.needs_permission<>'Y' \n"+
                "and D.verify_doctor<>'Y' \n"+
                "order by D.hold_final, L.lab_number \n";
            */    
            SQL =
                "SELECT '     |     | '|| "+ 
                "LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30), \n"+
                "D.hold_final,R.biopsy_code,R.path_status \n"+
                "from pcs.lab_requisitions L, pcs.lab_results R, pcs.patients P, \n"+
                "   pcs.hpv_requests H, pcs.practices D \n"+
                "where L.patient=P.patient \n"+
                "and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=D.practice \n"+
                "and H.test_sent='R' \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and L.preparation<>5 \n"+
                "and H.needs_permission<>'Y' \n"+
                "and D.verify_doctor<>'Y' \n"+
                "order by D.hold_final, L.lab_number \n";
           
            stmt = DbConnection.process().createStatement();
            rs = stmt.executeQuery(SQL);
            // flag for message used to separate labs in which FINALs should be held
            boolean holdFinals=false;
            parent.log.write("   open HPVrequests cursor");
            while (rs.next()) {
                String s = rs.getString(1);
                String hold_final = rs.getString(2);
                String b_code = rs.getString(3);
                String path_status = rs.getString(4);
                if (Utils.isNull(b_code)&&hold_final.equals("Y")&&path_status.equals("Y")) 
                    s=s.replace('*',' ');
                if (hold_final.equals("Y")) {
                    if (!holdFinals) {
                        holdFinals=true;
                        /*  Two additional lines that are added to the HPVrequests
                            vector that are actually not lines of HPV data; these are
                            the lines on the HPV requisition sheet that separate the
                            labs in which the practice requests FINALs be held until
                            HPV results are in, from those that do not have to be held.
                        */
                        parent.HPVrequests.addElement("  ");
                        parent.HPVrequests.addElement("<-----HOLD FINAL REPORT PENDING HPV TEST RESULTS----->");
                    }
                }
                parent.HPVrequests.addElement(s);
            }
            parent.log.write(
                "   close HPVrequests cursor ["+parent.HPVrequests.size()+"]");
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write("queryQueue[3] "+e); exitStatus=false; }
            
            /*  Originally an HPV request on the requisition was indicated by either
                a Y (yes) or N (no); this was changed to the values of 19 (yes), 20 (yes),
                and N (no); the 19 and 20 indicate two different types of HPV testing.
                For the transitional phase there existed values of Y (old) and, 
                19 and 20 (new) for HPV testing requested; this section of the HPV
                data sheets listed all lab numbers in which the decision whether the
                test should be sent had to be checked manually (as opposed to the
                change to having the system make this determination through use
                of implemented rules.
            */
            parent.HPVmanual = new Vector();
            // SQL STATEMENT ID 005
            /*
            SQL =
                "select LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30)||'  '|| \n"+
                "DECODE(P.ssn,NULL,'   -  -    ',SUBSTR(P.ssn,1,3)||'-'||SUBSTR(P.ssn,4,2)||'-'||SUBSTR(P.ssn,6,4)) \n"+
                "||'  '||NVL(TO_CHAR(P.dob,'MM/DD/YY'),'  /  /  ')||'  '|| \n"+
                "NVL(TO_CHAR(L.date_collected,'MM/DD/YY'),'  /  /  ')||'   '|| \n"+
                "RPAD(L.doctor_text,30),R.biopsy_code \n"+
                "from pcs.lab_requisitions L, pcs.patients P, pcs.hpv_requests H, pcs.cytopath_print_queue Q, pcs.lab_results R \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and H.lab_number=Q.lab_number \n"+
                "and L.preparation<>5 \n"+
                "and Q.first_print="+parent.printMode+" \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.test_sent='N' \n"+
                "and H.hpv_code='Y' \n"+
                "order by L.lab_number \n";
            */
            SQL =
                "SELECT '     |     | '|| "+ 
                "LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30), \n"+
                "R.biopsy_code \n"+
                "from pcs.lab_requisitions L, pcs.patients P, pcs.hpv_requests H, pcs.cytopath_print_queue Q, pcs.lab_results R \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and H.lab_number=Q.lab_number \n"+
                "and L.preparation<>5 \n"+
                "and Q.first_print="+parent.printMode+" \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.test_sent='N' \n"+
                "and H.hpv_code='Y' \n"+
                "order by L.lab_number \n";
                
            stmt = DbConnection.process().createStatement();
            rs = stmt.executeQuery(SQL);
            parent.log.write("   open HPVmanual cursor");
            while (rs.next()) {
                String s = rs.getString(1);
                String b_code = rs.getString(2);
                parent.HPVmanual.addElement(s);   
                parent.hasExceptions=true;
            }
            parent.log.write(
                "   close HPVmanual cursor ["+parent.HPVmanual.size()+"]");
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write("queryQueue[7] "+e); exitStatus=false; }
            
            /*  HPV requests in which whenever the system rules determine that the
                HPV test should be sent, the physicians office must be called
                in order to get their permission to send the test.
            */
            parent.HPVpermissions = new Vector();
            // SQL STATEMENT ID 006
            /*
            SQL =
                "select LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30)||'  '|| \n"+
                "DECODE(P.ssn,NULL,'   -  -    ',SUBSTR(P.ssn,1,3)||'-'||SUBSTR(P.ssn,4,2)||'-'||SUBSTR(P.ssn,6,4)) \n"+
                "||'  '||NVL(TO_CHAR(P.dob,'MM/DD/YY'),'  /  /  ')||'  '|| \n"+
                "NVL(TO_CHAR(L.date_collected,'MM/DD/YY'),'  /  /  ')||'   '|| \n"+
                "RPAD(L.doctor_text,30), \n"+
                "R.biopsy_code,R.path_status,PR.hold_final \n"+
                "from pcs.lab_requisitions L, pcs.patients P, pcs.hpv_requests H, pcs.lab_results R, pcs.practices PR \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=PR.practice \n"+
                "and L.preparation<>5 \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.test_sent='R' \n"+
                "and H.needs_permission='Y' \n"+
                "order by L.lab_number \n";
            */
            SQL =
                "SELECT '     |     | '|| "+ 
                "LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30), \n"+
                "R.biopsy_code,R.path_status,PR.hold_final \n"+
                "from pcs.lab_requisitions L, pcs.patients P, pcs.hpv_requests H, pcs.lab_results R, pcs.practices PR \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=PR.practice \n"+
                "and L.preparation<>5 \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.test_sent='R' \n"+
                "and H.needs_permission='Y' \n"+
                "order by L.lab_number \n";
                
            stmt = DbConnection.process().createStatement();
            rs = stmt.executeQuery(SQL);
            parent.log.write("   open HPVpermissions cursor");   
            while (rs.next()) {
                String s = rs.getString(1);
                String b_code = rs.getString(2);
                String path_status = rs.getString(3);
                String hold_final = rs.getString(4);
                if (Utils.isNull(b_code)&&hold_final.equals("Y")&&path_status.equals("Y")) 
                    s=s.replace('*',' ');
                parent.HPVpermissions.addElement(s);
                parent.hasExceptions=true;
            }
            parent.log.write(
                "   close HPVpermissions cursor ["+parent.HPVpermissions.size()+"]");
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write("queryQueue[6] "+e); exitStatus=false; }
            
            /*  HPV testing is not to be performed by the defaulted
                lab contracted to do the work; as of this writing all
                HPV testing is sent to CLEARPATH laboratory; however for
                some practices the HPV testing is done by an alternate
                lab instead; this lab is LAB CORP.
            */
            parent.HPValternates = new Vector();
            // SQL STATEMENT ID 007
            
            // DISCONTINUED
            // There are no tests sent to LAB CORP; code block commented out rather
            // than deleted though.
            /*
            SQL =
                "select LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30)||'  '|| \n"+
                "DECODE(P.ssn,NULL,'   -  -    ',SUBSTR(P.ssn,1,3)||'-'||SUBSTR(P.ssn,4,2)||'-'||SUBSTR(P.ssn,6,4)) \n"+
                "||'  '||NVL(TO_CHAR(P.dob,'MM/DD/YY'),'  /  /  ')||'  '|| \n"+
                "NVL(TO_CHAR(L.date_collected,'MM/DD/YY'),'  /  /  ')||'   '|| \n"+
                "RPAD(L.doctor_text,30),R.biopsy_code \n"+
                "from pcs.lab_requisitions L, pcs.patients P, pcs.hpv_requests H, pcs.lab_results R \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.preparation IS NOT NULL \n"+
                "and L.preparation<>5 \n"+
                "and H.test_sent IS NOT NULL \n"+
                "and H.test_sent='R' \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.hpv_lab='LAB CORP' \n"+
                "order by L.lab_number \n";
                
            stmt = dbConnection.process().createStatement();
            rs = stmt.executeQuery(SQL);
            parent.log.write("   open HPValternates cursor");
            while (rs.next()) {
                String s = rs.getString(1);
                String b_code = rs.getString(2);
                parent.HPValternates.addElement(s);
                parent.hasExceptions=true;
            }
            parent.log.write(
                "   close HPValternates cursor ["+parent.HPValternates.size()+"]");
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write("queryQueue[5] "+e); exitStatus=false; }
            */
            
            /*  HPV tests in which the doctor must be verified
                before the test is sent out.
            */
            parent.HPVdrVerify = new Vector();
            // SQL STATEMENT ID 008
            /*
            SQL =
                "select LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30)||'  '|| \n"+
                "DECODE(P.ssn,NULL,'   -  -    ',SUBSTR(P.ssn,1,3)||'-'||SUBSTR(P.ssn,4,2)||'-'||SUBSTR(P.ssn,6,4)) \n"+
                "||'  '||NVL(TO_CHAR(P.dob,'MM/DD/YY'),'  /  /  ')||'  '|| \n"+
                "NVL(TO_CHAR(L.date_collected,'MM/DD/YY'),'  /  /  ')||'   '|| \n"+
                "RPAD(L.doctor_text,30), \n"+
                "R.biopsy_code,R.path_status,D.hold_final \n"+
                "from pcs.lab_requisitions L, pcs.patients P, \n"+
                "   pcs.hpv_requests H, pcs.practices D, pcs.lab_results R \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=D.practice \n"+
                "and L.preparation<>5 \n"+
                "and H.test_sent='R' \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.needs_permission is NOT NULL \n"+
                "and D.verify_doctor='Y' \n"+
                "order by L.lab_number \n";
            */
            SQL =
                "SELECT '     |     | '|| "+ 
                "LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30), \n"+
                "R.biopsy_code,R.path_status,D.hold_final \n"+
                "from pcs.lab_requisitions L, pcs.patients P, \n"+
                "   pcs.hpv_requests H, pcs.practices D, pcs.lab_results R \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=D.practice \n"+
                "and L.preparation<>5 \n"+
                "and H.test_sent='R' \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.needs_permission is NOT NULL \n"+
                "and D.verify_doctor='Y' \n"+
                "order by L.lab_number \n";

            stmt = DbConnection.process().createStatement();
            rs = stmt.executeQuery(SQL);
            parent.log.write("   open HPVdrVerify cursor");
            while (rs.next()) {
                String s = rs.getString(1);
                String b_code = rs.getString(2);
                String path_status = rs.getString(3);
                String hold_final = rs.getString(4);
                if (Utils.isNull(b_code)&&hold_final.equals("Y")&&path_status.equals("Y")) 
                    s=s.replace('*',' ');
                parent.HPVdrVerify.addElement(s);
                parent.hasExceptions=true;
            }
            parent.log.write(
                "   close HPVdrVerify cursor ["+parent.HPVdrVerify.size()+"]");
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write("queryQueue[8] "+e); exitStatus=false; }
            
            /*  HPV testing only
            */
            parent.HPVonly = new Vector();
            // SQL STATEMENT ID 009
            /*
            SQL =
                "select LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30)||'  '|| \n"+
                "DECODE(P.ssn,NULL,'   -  -    ',SUBSTR(P.ssn,1,3)||'-'||SUBSTR(P.ssn,4,2)||'-'||SUBSTR(P.ssn,6,4)) \n"+
                "||'  '||NVL(TO_CHAR(P.dob,'MM/DD/YY'),'  /  /  ')||'  '|| \n"+
                "NVL(TO_CHAR(L.date_collected,'MM/DD/YY'),'  /  /  ')||'   '|| \n"+
                "RPAD(L.doctor_text,30),R.biopsy_code \n"+
                "from pcs.lab_requisitions L, pcs.patients P, \n"+
                "   pcs.hpv_requests H, pcs.practices D, pcs.lab_results R \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=D.practice \n"+
                "and L.preparation=5 \n"+
                "and H.test_sent='R' \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.needs_permission is NOT NULL \n"+
                "order by L.lab_number \n";
            */
            SQL =
                "SELECT '     |     | '|| "+ 
                "LTRIM(to_char(L.practice,'009')||'-'||to_char(L.lab_number))||DECODE(H.test_sent,'P','*','R','*',' ')||' '|| \n"+
                "RPAD(P.lname||', '||P.fname,30), \n"+
                "R.biopsy_code \n"+
                "from pcs.lab_requisitions L, pcs.patients P, \n"+
                "   pcs.hpv_requests H, pcs.practices D, pcs.lab_results R \n"+
                "where L.patient=P.patient and L.lab_number=H.lab_number \n"+
                "and L.lab_number=R.lab_number \n"+
                "and L.practice=D.practice \n"+
                "and L.preparation=5 \n"+
                "and H.test_sent='R' \n"+
                "and H.hpv_lab IS NOT NULL \n"+
                "and H.needs_permission is NOT NULL \n"+
                "order by L.lab_number \n";
                
            stmt = DbConnection.process().createStatement();
            rs = stmt.executeQuery(SQL);
            parent.log.write("   open HPVonly cursor");
            while (rs.next()) {
                String s = rs.getString(1);
                String b_code = rs.getString(2);
                parent.HPVonly.addElement(s);
                parent.hasExceptions=true;
            }
            parent.log.write(
                "   close HPVonly cursor ["+parent.HPVonly.size()+"]");
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write("queryQueue[9] "+e); exitStatus=false; }
        }
        catch (Exception e) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }
	
	/*
	    Retrive the result set for this labReport object. These results
	    are those in which the results indictated by the original
	    screening tech take precedence.
	*/
    public boolean queryResults(LabReportRec labReport)  {
        boolean exitStatus=true;
        try  {
            // SQL STATEMENT ID 010
            String SQL = new String(
                    "SELECT \n"+
                    "   r.bethesda_code, \n"+
                    "   b.description, \n"+
                    "   b.category, \n"+
                    "   TO_CHAR(lr.date_completed,'MM/DD/YYYY') \n"+
                    "FROM \n"+
                    "   pcs.lab_result_codes r, \n"+
                    "   pcs.bethesda_codes b, \n"+
                    "   pcs.lab_results lr \n"+
                    "WHERE \n"+
                    "   r.lab_number=lr.lab_number and \n"+
                    "   r.lab_number="+labReport.lab_number+" and \n"+
                    "   r.bethesda_code=b.bethesda_code \n");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            int ndx=0;
            rs=stmt.executeQuery(SQL);
            while (rs.next()) {
                ResultCodeRec resultCodeRec = new ResultCodeRec();
                resultCodeRec.bethesda_code=rs.getString(1);
                String s = rs.getString(2);
                resultCodeRec.category=rs.getString(3);
                labReport.date_reported=rs.getString(4);
                resultCodeRec.active_status="Y";
                resultCodeRec.description =
                    getCodeDescription(resultCodeRec.bethesda_code,s);
                /*  SPECIAL CONDITION:
                    This account does not want to see a 507 code
                    on their reports.
                */
                if (labReport.practice==428 && resultCodeRec.bethesda_code.equals("507"))
                    continue;
                labReport.resultVect.addElement(resultCodeRec);
            }
            labReport.numResults=labReport.resultVect.size();
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }                
        }
        catch (Exception e) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

	/*
	    Retrive the result set for this labReport object.  This particular
	    labReport object is one that was a Quality Control case, hence
	    the result set indicated by the QC screening tech take precedence.
	*/
    public boolean queryQCResults(LabReportRec labReport)  {
        boolean exitStatus=true;
        try  {
            // SQL STATEMENT ID 011
            String SQL = new String(
                    "SELECT \n"+
                    "   ct.cytotech_code, \n"+
                    "   qr.bethesda_code, \n"+
                    "   b.description, \n"+
                    "   b.category, \n"+
                    "   TO_CHAR(q.qc_date,'MM/DD/YYYY') \n"+
                    "FROM \n"+
                    "   pcs.cytotechs ct, \n"+
                    "   pcs.quality_control_codes qr, \n"+
                    "   pcs.quality_control q, \n"+
                    "   pcs.bethesda_codes b \n"+
                    "WHERE \n"+
                    "   q.cytotech=ct.cytotech and \n"+
                    "   q.lab_number=qr.lab_number and \n"+
                    "   qr.bethesda_code=b.bethesda_code and \n"+
                    "   qr.lab_number="+labReport.lab_number+" \n");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            rs=stmt.executeQuery(SQL);
            while (rs.next()) {
                labReport.qc_cytotech_code=rs.getString(1);
                ResultCodeRec resultCodeRec = new ResultCodeRec();
                resultCodeRec.bethesda_code=rs.getString(2);
                String s = rs.getString(3);
                resultCodeRec.category=rs.getString(4);
                labReport.date_reported=rs.getString(5);
                resultCodeRec.active_status="Y";
                /*  old data; unknown tech code was 999; replace with
                    with QCT (Quality Control Tech) on report.
                */
                if (labReport.qc_cytotech_code.equals("999"))
                    labReport.qc_cytotech_code="QCT";
                resultCodeRec.description =
                    getCodeDescription(resultCodeRec.bethesda_code,s);
                /*  SPECIAL CONDITION:
                    This account does not want to see a 507 code
                    on their reports.
                */
                if (labReport.practice==428 && resultCodeRec.bethesda_code.equals("507"))
                    continue;
                labReport.resultVect.addElement(resultCodeRec);
            }
            labReport.numResults=labReport.resultVect.size();
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }                
        }
        catch( Exception e ) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

	/*
	    Retrive the result set for this labReport object.  This particular
	    labReport object is one that required screening by a pathologist,
	    hence the pathologist result code set takes precedence.
	*/
    public boolean queryPathResults(LabReportRec labReport)  {
        boolean exitStatus=true;
        try  {
            // SQL STATEMENT ID 012
            String SQL = new String(
                    "SELECT \n"+
                    "   p.lname, \n"+
                    "   p.fname, \n"+
                    "   p.mi, \n"+
                    "   p.title, \n"+
                    "   p.degree, \n"+
                    "   pc.pathologist_code, \n"+
                    "   pcc.bethesda_code, \n"+
                    "   b.description, \n"+
                    "   b.category, \n"+
                    "   TO_CHAR(pc.path_date,'MM/DD/YYYY') \n"+
                    "FROM \n"+
                    "   pcs.pathologists p, \n"+
                    "   pcs.pathologist_control_codes pcc, \n"+
                    "   pcs.pathologist_control pc, \n"+
                    "   pcs.bethesda_codes b \n"+
                    "WHERE \n"+
                    "   p.pathologist_code=pc.pathologist_code and \n"+
                    "   pc.lab_number=pcc.lab_number and \n"+
                    "   pcc.bethesda_code=b.bethesda_code and \n"+
                    "   pc.lab_number="+labReport.lab_number+" \n");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) {
                labReport.path_lname=rs.getString(1);
                labReport.path_fname=rs.getString(2);
                labReport.path_mi=rs.getString(3);
                labReport.path_title=rs.getString(4);
                labReport.path_degree=rs.getString(5);
                labReport.pathologist_code=rs.getString(6);
                ResultCodeRec resultCodeRec = new ResultCodeRec();
                resultCodeRec.bethesda_code=rs.getString(7);
                String s = rs.getString(8);
                resultCodeRec.category=rs.getString(9);
                labReport.date_reported=rs.getString(10);
                resultCodeRec.active_status="Y";
                resultCodeRec.description =
                    getCodeDescription(resultCodeRec.bethesda_code,s);
                /*  SPECIAL CONDITION:
                    This account does not want to see a 507 code
                    on their reports.
                */
                if (labReport.practice==428 && resultCodeRec.bethesda_code.equals("507"))
                    continue;
                labReport.resultVect.addElement(resultCodeRec);
            }
            labReport.numResults=labReport.resultVect.size();
            /*  On a pathologist case, if the labReport object was also
                a Quality Control case, then the QC tech's initials
                must also appear on the report.
            */
            if (labReport.qc_status.equals("Y")) {
                try { rs.close(); stmt.close(); }
                catch (SQLException e) { parent.log.write(e); exitStatus=false; }                
                // SQL STATEMENT ID 013
                SQL = new String(
                    "SELECT ct.cytotech_code \n"+
                    "FROM pcs.cytotechs ct,pcs.quality_control_codes q,pcs.quality_control r \n"+
                    "WHERE r.cytotech=ct.cytotech and q.lab_number=r.lab_number \n"+
                    "   and r.lab_number="+labReport.lab_number+" \n");
                stmt=DbConnection.process().createStatement();
                rs=stmt.executeQuery(SQL);
                while (rs.next()) { labReport.qc_cytotech_code=rs.getString(1); }
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }                
        }
        catch (Exception e) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

    /*
        For the lab number indicated, remove this lab number from the
        CytoPathology Report print queue, and then add a print history
        record to the print history table.  Each account of a CytoPathology
        report being printed, DRAFT or FINAL, must be recorded.
    */
    public boolean dequeue(int labNum)  {
        parent.log.write("dequeue("+labNum+","+parent.printMode+")");
        boolean exitStatus=true;
        try  {
            String SQL = new String(
                "DELETE FROM pcs.cytopath_print_queue \n"+
                "WHERE lab_number="+labNum+" and \n"+
                "   first_print="+parent.printMode+" \n");
                
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(SQL);
            /*  The history table will record the lab number, print mode, and 
                date the report was printed.  The print mode will reveal
                whether the lab was printed as a DRAFT or FINAL from the current
                print queue, or whether it was printed as a special request to
                print a DRAFT or FINAL.  SPECIAL NOTE:  As of this writing
                (04/14/2005) there have been cases in which the print mode
                recorded was NO_PRINT and this situation corresponds to cases
                in which duplicate reports were printed; the nature of this
                bug has not been solved yet.
            */
            SQL = new String(
                "INSERT INTO pcs.cytopath_history (lab_number,first_print,print_date) \n"+
                "VALUES ("+labNum+","+parent.printMode+",SysDate) \n");
            rs=stmt.executeUpdate(SQL);
            try { stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }                
        }
        catch (Exception e) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

	public void holdReportForHPV(int labNumber)
	{
	    PreparedStatement pstmt = null;
	    try {
	        String SQL =
	            "UPDATE pcs.cytopath_print_queue \n"+
	            "SET first_print = ? \n"+
	            "WHERE lab_number = ?";
	        pstmt = DbConnection.process().prepareStatement(SQL); 
	        pstmt.setInt(1,Lab.HOLD_HPV);
	        pstmt.setInt(2,labNumber);
	        pstmt.executeUpdate();
            try { pstmt.close(); }
            catch (SQLException e) { parent.log.write(e); }                
	    }
	    catch (SQLException e) { parent.log.write(e.toString()); }
	    catch (Exception e) { parent.log.write(e); }
	}
    
    /*
        Determine whether there are any labReport objects currently queued
        for printing; the return value is the sum of any DRAFT or FINAL
        reports that are currently queued for printing.
    */
    public int checkQueue() {
        try  {
            String SQL = new String(
                "SELECT first_print,count(first_print) \n"+
                "FROM pcs.cytopath_print_queue \n"+
                "GROUP BY first_print");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            int pMode=0;
            while (rs.next()) { 
                pMode=rs.getInt(1);
                // set the total of each type of printing currently queued
                if (pMode==Lab.CURR_DRAFT) parent.numDrafts=rs.getInt(2);
                else if (pMode==Lab.CURR_FINAL) parent.numFinals=rs.getInt(2);
                else if (pMode==Lab.CURR_HPV) parent.numHPVs=rs.getInt(2);
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); }                
        }
        catch (Exception e) { parent.log.write(e); }
        parent.log.write(
            "RETURNING checkQueue("+(parent.numDrafts+parent.numFinals+parent.numHPVs)+")");
        return(parent.numDrafts+parent.numFinals+parent.numHPVs);            
    }
    
    /*
        Retrieves the correct description for a result code.  The parameters
        passed in are the result code and the CURRENT description for that
        code.  The table that is queried contains code descriptions for any
        codes in which the description has changed at least once.  For these 
        codes the correct description that was active at the original date
        the report was printed must be used on any subsequent copies of
        the report.  This is determined based on the date the prior 
        description was terminated compared to the original date the
        results were entered.
    */
    private String getCodeDescription(String rCode, String rDescr)  {
        String uDescr = null;
        try  {
            String SQL = new String(
                "SELECT TO_NUMBER(TO_CHAR(term_date,'YYYYMMDD')), description \n"+
                "FROM pcs.bethesda_prior_descr \n"+
                "WHERE bethesda_code = '"+rCode+"' \n"+
                "ORDER BY term_date \n");
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) {
                int ds = rs.getInt(1);
                String t = rs.getString(2);
                /*  If the termination date for the description for
                    this code is later than the original date of
                    the results, set the return description to this
                    value and break.
                */
                if (ds>iDatestamp) {
                    uDescr=t;
                    break;
                }
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { 
                parent.log.write("ERROR: Closing statement \n"+e);
            }                
        }
        catch (Exception e) {parent.log.write(e+" getCodeDescription"); }
        /*  After the prior description was queried for rCode, if the value
            of the return value uDescr is NULL, then no prior description 
            was located; hence set the return value to the current
            description which was passed in.
        */
        if (Utils.isNull(uDescr)) uDescr=rDescr;
        return (uDescr);
    }        
    
    /*
        For all lab numbers in the HPV requests table that were flagged
        for an HPV requisition (i.e. value of 'R'), update the value
        of test_sent to 'P' (i.e. HPV requisition was printed, test was
        sent, and HPV results are now Pending).
    */
    public boolean HPVupdate()  {
        int dCount = DbConnection.getRowCount("PCS.HPV_REQUESTS","TEST_SENT='R'");
        boolean exitStatus=true;
        parent.log.write("HPVupdate()   count=="+dCount);
        try  {
            String SQL = new String(
                "UPDATE pcs.hpv_requests SET \n"+
                "   test_sent='P', datestamp=SysDate, dequeued=SysDate\n"+
                "WHERE test_sent='R' \n");
                
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(SQL);
            try { stmt.close(); }
            catch (SQLException e) { parent.log.write("HPVupdate[1] "+e); exitStatus=false; }                
        }
        catch (Exception e) {
            parent.log.write("HPVupdate[0] "+e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }
    
    /*
        Called at instansiation of CytoPathReport object, returns a Vector
        of Strings of all results codes that indicate the CytoPathology
        report is an amended report.
    */
    public Vector getAmendedCodes()
    {
        Vector amendedCodes = new Vector();
        try  {
            String SQL = new String(
                "SELECT bethesda_code from pcs.bethesda_codes \n"+
                "WHERE description like '%AMENDED%' \n");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { 
                String amendedCode = rs.getString(1);
                amendedCodes.addElement(amendedCode);
            }
            try { rs.close(); stmt.close(); }
            catch (Exception e) { parent.log.write("getAmendedCodes[1] "+ e); }
        }
        catch (Exception e) {
            parent.log.write("getAmendedCodes[0] "+e);
            parent.msgLabel.setText("Operation Failed");
        }
        return(amendedCodes);            
    }
    
    public Vector getCoverSheets(int prac)
    {
        Vector coverSheets = new Vector();
        try  {
            StringBuffer SQL = new StringBuffer(
                "SELECT LTRIM(RTRIM(TO_CHAR(practice,'009'))), \n"+
                "   name,address1,address2, \n"+
                "   city,state,SUBSTR(zip,1,5),attn_message \n"+
                "FROM pcs.practices \n");
                
            if (prac>0) SQL.append("WHERE practice="+prac+"\n");
            else SQL.append("WHERE cover_sheet='Y' \n");
            SQL.append("ORDER BY practice \n");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL.toString());
            while (rs.next()) { 
                PracticeRec p = new PracticeRec();
                p.practice_id=rs.getString(1);
                p.name=rs.getString(2);
                p.address1=rs.getString(3);
                p.address2=rs.getString(4);
                p.city=rs.getString(5);
                p.state=rs.getString(6);
                p.zip=rs.getString(7);
                p.attn_message=rs.getString(8);
                coverSheets.addElement(p);
            }
            try { rs.close(); stmt.close(); }
            catch (Exception e) { parent.log.write("getCoverSheets[1] "+ e); }
            if (coverSheets.size()==0) {
                String errMsg = null;
                if (prac>0) errMsg="No data located for Account #"+prac;
                else errMsg="There are no cover sheets queued to print";
                Utils.createErrMsg(errMsg);
            }
        }
        catch (Exception e) {
            parent.log.write("getCoverSheets[0] "+e);
            parent.msgLabel.setText("Operation Failed");
        }
        return(coverSheets);            
    }
    
    public void resetCoverSheets()
    {
        try  {
            StringBuffer SQL = new StringBuffer(
                "UPDATE pcs.practices SET cover_sheet='N' \n" +
                "WHERE cover_sheet<>'D' \n");
                
            Statement stmt = DbConnection.process().createStatement();
            stmt.executeUpdate(SQL.toString());
            try { stmt.close(); }
            catch (Exception e) { parent.log.write("resetCoverSheets[1] "+ e); }
        }
        catch (Exception e) {
            parent.log.write("resetCoverSheets[0] "+e);
            parent.msgLabel.setText("Operation Failed");
        }
    }
    
    public Vector extractElectronicReports(Vector v)
    {
        Vector eReports = new Vector();
        for (int i=0; i<v.size(); i++) {
            LabReportRec rept = (LabReportRec)v.elementAt(i);
            if (parent.printMode==Lab.CURR_FINAL) {
                if (rept.e_reporting.equals("Y")||rept.e_reporting.equals("B")) 
                    eReports.addElement(rept);
            }
            else if (parent.printMode==Lab.FINAL) {
                if (createERept) eReports.addElement(rept);
            }
        }
        return (eReports);
    }
 
    /*
        Close the database connection to Oracle.
    */
    public void close()
    {
        parent.log.write("CLOSING CytoPathDbOps");
    }
	
}
