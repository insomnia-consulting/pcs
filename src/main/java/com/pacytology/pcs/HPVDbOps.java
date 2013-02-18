package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       HPVDbOps.java
    Created By: John Cardella, Software Engineer
    
    Function:   Database actions for HPV reports.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import java.sql.*;
import java.util.Vector;
import javax.swing.JOptionPane;

public class HPVDbOps implements Runnable
{
    Thread dbThread;
    HPVReport parent;
    boolean createERept = false;
    /*  date results were entered as an integer value in
        the format YYYYMMDD yields a strict chronological
        value that is easily used for date comparisons
    */
    int iDatestamp;
    
    // default constructor; not used
	public HPVDbOps()	{ }

    /*
        Constructor that sets the HPVReport object as
        the parent of the HPVDbOps (HPV Database
        Operations) object.  Logging for this object is written
        to the parent's LogFile object.
    */
	public HPVDbOps(HPVReport p)
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
        if (parent.printMode==Lab.FINAL) {
            createERept=false;
            rv=query(parent.startingLabNumber,parent.endingLabNumber);
            if (rv) {
                LabReportRec r = new LabReportRec();
                r = (LabReportRec) parent.labReportVect.elementAt(0);
                if (Utils.isNull(r.cytotech_code)) rv=false;
                else if (r.cytotech_code.equals("HPV")) rv=false;
            }
            if (!rv) {
                Utils.createErrMsg("No Data Located!");
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
                Utils.createErrMsg("No HPV Reports to Print!");
            }
        }
        // if labReport objects exist call parents print method and exit
        if (rv) {
            Vector eReports = new Vector();
            eReports=extractElectronicReports(parent.labReportVect);
            if (eReports.size()>0) {
                Export eFile = new Export(Lab.HPV_REPORTS);
                eFile.write(eReports);
            }
	        parent.hpvReport();
	        parent.closingActions();
        }
        // otherwise reset the HPVReport screen
        else parent.resetForm();
	}
    /***************************************************************************/
	

	/*
	    Retrieve data for lab numbers in the specified
	    range:  sLab (staring) - eLab (ending); this as
	    opposed to retrieving the data currently in the 
	    print queue
	*/
    public boolean query(int sLab, int eLab)  {
        parent.log.write("query("+sLab+".."+eLab+")");
        boolean exitStatus = true;
        String e_report = null;
        try  {
            // SQL STATEMENT ID 001
            String SQL = new String(
                "SELECT \n"+
                "   lab.lab_number, \n"+                                    //01
                "   lab.patient, \n"+                                       //02
                "   lab.practice,\n"+                                       //03
                "   lab.doctor, \n"+                                        //04
                "   lab.patient_id, \n"+                                    //05
                "   TO_CHAR(lab.date_collected,'MM/DD/YYYY'), \n"+          //06
                "   TO_CHAR(lab.receive_date,'MM/DD/YYYY'), \n"+            //07
                "   lab.lmp, \n"+                                           //08
                "   lab.finished, \n"+                                      //09
                "   pat.lname, \n"+                                         //10
                "   pat.fname, \n"+                                         //11
                "   pat.ssn, \n"+                                           //12
                "   TO_CHAR(pat.dob,'MM/DD/YYYY'), \n"+                     //13
                "   cn.client_notes, \n"+                                   //14
                "   pr.practice, \n"+                                       //15
                "   pr.name, \n"+                                           //16
                "   pr.address1, \n"+                                       //17
                "   pr.address2, \n"+                                       //18
                "   pr.city, \n"+                                           //19
                "   pr.state, \n"+                                          //20
                "   pr.zip, \n"+                                            //21
                "   pr.client_notes, \n"+                                   //22
                "   1, \n"+                                                 //23
                "   dr.lname, \n"+                                          //24
                "   dr.fname, \n"+                                          //25
                "   lab.previous_lab, \n"+                                  //26
                "   RTRIM(TO_CHAR(SysDate,'fmDay, fmMonth'))||' '||TO_CHAR(SysDate,'DD, fmYYYY'), \n"+
                "   ct.cytotech_code, \n"+                                  //28
                "   NULL, \n"+                                              //29
                "   NULL, \n"+                                              //30
                "   rem.comment_text, \n"+                                  //31
                "   NULL, \n"+                                              //32
                "   NULL, \n"+                                              //33
                "   NULL, \n"+                                              //34
                "   NULL, \n"+                                              //35
                "   NULL, \n"+                                              //36
                "   NULL, \n"+                                              //37
                "   NULL, \n"+                                              //38
                "   NULL, \n"+                                              //39
                "   lab.preparation, \n"+                                   //40
                "   lab.rush, \n"+                                          //41
                "   NULL, \n"+                                              //42
                "   NULL, \n"+                                              //43
                "   lab.doctor_text, \n"+                                   //44
                "   pat.mi, \n"+                                            //45
                "   TO_NUMBER(TO_CHAR(res.datestamp,'YYYYMMDD')), \n"+      //46
                "   TO_CHAR(res.datestamp,'MM/DD/YYYY'), \n"+               //47
                "   hpv.test_sent, \n"+                                     //48
                "   NULL, \n"+                                              //49
                "   NULL, \n"+                                              //50
                "   pr.e_reporting, \n"+                                    //51
                "   pr.program, \n"+                                        //52
                "   pr.parent_account, \n"+                                 //53
                "   hpv.test_results, \n"+                                  //54
                "   TO_CHAR(hpv.results_received,'MM/DD/YYYY'), \n"+        //55
                "   TO_CHAR(res.date_completed,'MM/DD/YYYY'), \n"+          //56
                "   pr.practice_type \n"+                                   //57
                "FROM \n"+
                "   pcs.lab_requisitions lab, \n"+
                "   pcs.patients pat, \n"+
                "   pcs.practices pr, \n"+
                "   pcs.lab_req_client_notes cn, \n"+
                "   pcs.doctors dr, \n"+
                "   pcs.cytotechs ct, \n"+
                "   pcs.lab_results res, \n"+
                "   pcs.lab_result_comments rem, \n"+
                "   pcs.hpv_requests hpv \n"+
                "WHERE \n"+
                "   lab.lab_number=res.lab_number and \n"+
                "   lab.lab_number=cn.lab_number(+) and \n"+
                "   lab.lab_number=hpv.lab_number(+) and \n"+
                "   lab.practice=pr.practice and \n"+
                "   lab.doctor=dr.doctor and \n"+
                "   lab.patient=pat.patient and \n"+
                "   hpv.cytotech=ct.cytotech and \n"+
                "   res.lab_number=rem.lab_number(+) and \n"+
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
                //labReport.sumMatNdx=rs.getInt(42);
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
                labReport.test_results=rs.getString(54);
                labReport.results_received=rs.getString(55);
                labReport.date_reported=rs.getString(55);
                labReport.practice_type=rs.getString(57);
                if (!Utils.isNull(labReport.remarks)) {
                    labReport.formatRemarks();
                }
                // get details for lab currently pointed to
                queryDetails(labReport);
                /*  determine which result set takes precedence
                    and retrieve those results
                */
                setDirector(labReport);
                parent.labReportVect.addElement(labReport);
                e_report=labReport.e_reporting;
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
        if (parent.labReportVect.size()==0) exitStatus=false;
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
        Vector tmpVect = new Vector();
        Vector faxVect = new Vector();
        try  {
            // SQL STATEMENT ID 003
            String SQL = new String( 
                "SELECT \n"+
                "   q.lab_number, \n"+                                  //01
                "   lab.patient, \n"+                                   //02
                "   lab.practice,\n"+                                   //03
                "   lab.doctor, \n"+                                    //04
                "   lab.patient_id, \n"+                                //05
                "   TO_CHAR(lab.date_collected,'MM/DD/YYYY'), \n"+      //06
                "   TO_CHAR(lab.receive_date,'MM/DD/YYYY'), \n"+        //07
                "   lab.lmp, \n"+                                       //08
                "   lab.finished, \n"+                                  //09
                "   pat.lname, \n"+                                     //10
                "   pat.fname, \n"+                                     //11
                "   pat.ssn, \n"+                                       //12
                "   TO_CHAR(pat.dob,'MM/DD/YYYY'), \n"+                 //13
                "   cn.client_notes, \n"+                               //14
                "   pr.practice, \n"+                                   //15
                "   pr.name, \n"+                                       //16
                "   pr.address1, \n"+                                   //17
                "   pr.address2, \n"+                                   //18
                "   pr.city, \n"+                                       //19
                "   pr.state, \n"+                                      //20
                "   pr.zip, \n"+                                        //21
                "   pr.client_notes, \n"+                               //22
                "   1, \n"+                                             //23
                "   dr.lname, \n"+                                      //24
                "   dr.fname, \n"+                                      //25
                "   lab.previous_lab, \n"+                              //26
                "   RTRIM(TO_CHAR(SysDate,'fmDay, fmMonth'))||' '||TO_CHAR(SysDate,'DD, fmYYYY'), \n"+
                "   ct.cytotech_code, \n"+                              //28
                "   NULL, \n"+                                          //29
                "   NULL, \n"+                                          //30
                "   rem.comment_text, \n"+                              //31
                "   NULL, \n"+                                          //32
                "   NULL, \n"+                                          //33
                "   NULL, \n"+                                          //34
                "   NULL, \n"+                                          //35
                "   NULL, \n"+                                          //36
                "   NULL, \n"+                                          //37
                "   NULL, \n"+                                          //38
                "   NULL, \n"+                                          //39
                "   lab.preparation, \n"+                               //40
                "   lab.rush, \n"+                                      //41
                "   NULL, \n"+                                          //42
                "   NULL, \n"+                                          //43
                "   lab.doctor_text, \n"+                               //44
                "   pat.mi, \n"+                                        //45
                "   res.biopsy_code, \n"+                               //46
                "   TO_NUMBER(TO_CHAR(res.datestamp,'YYYYMMDD')), \n"+  //47          
                "   TO_NUMBER(TO_CHAR(SysDate,'YYYYMMDD')), \n"+        //48
                "   TO_CHAR(res.datestamp,'MM/DD/YYYY'), \n"+           //49
                "   pr.hold_final, \n"+                                 //50
                "   hpv.test_sent, \n"+                                 //51
                "   pr.send_fax, \n"+                                   //52
                "   NULL, \n"+                                          //53
                "   NULL, \n"+                                          //54
                "   pr.e_reporting, \n"+                                //55
                "   pr.program, \n"+                                    //56
                "   pr.parent_account, \n"+                             //57
                "   hpv.test_results, \n"+                              //58
                "   TO_CHAR(hpv.results_received,'MM/DD/YYYY'), \n"+    //59
                "   TO_CHAR(res.date_completed,'MM/DD/YYYY'), \n"+      //60
                "   pr.practice_type \n"+                               //61
                "FROM \n"+
                "   pcs.lab_requisitions lab, \n"+
                "   pcs.patients pat, \n"+
                "   pcs.practices pr, \n"+
                "   pcs.lab_req_client_notes cn, \n"+
                "   pcs.doctors dr, \n"+
                "   pcs.hpv_print_queue q, \n"+
                "   pcs.cytotechs ct, \n"+
                "   pcs.lab_results res, \n"+
                "   pcs.lab_result_comments rem, \n"+
                "   pcs.hpv_requests hpv \n"+
                "WHERE \n"+
                "   q.lab_number=lab.lab_number and \n"+
                "   lab.finished>0 and \n"+
                "   lab.lab_number=cn.lab_number(+) and \n"+
                "   lab.lab_number=hpv.lab_number(+) and \n"+
                "   lab.practice=pr.practice and \n"+
                "   lab.doctor=dr.doctor and \n"+
                "   lab.patient=pat.patient and \n"+
                "   res.lab_number=q.lab_number and \n"+
                "   hpv.cytotech=ct.cytotech and \n"+
                "   res.lab_number=rem.lab_number(+) and \n"+
                "   q.first_print="+parent.printMode+" \n");

            /*  If the print mode is for FINAL reports the sort order puts
                biopsy request labs first as these ones are tagged to be
                faxed.
            */
            if (parent.printMode==Lab.CURR_FINAL) 
                SQL+="ORDER BY pr.practice, lab.lab_number \n";
            else SQL+="ORDER BY lab.lab_number \n";

            // retrieve and format the current date for the reports
            String dateQuery = new String(
                "SELECT RTRIM(TO_CHAR(SysDate,'fmDay, fmMonth'))"+
                "||' '||TO_CHAR(SysDate,'DD, fmYYYY') FROM DUAL");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(dateQuery);
            while (rs.next()) { parent.reportDate=rs.getString(1); }  
            
            if (parent.printMode==Lab.CURR_FINAL) 
                parent.NUM_REPORTS=parent.numFinals;
                
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
                //labReport.sumMatNdx=rs.getInt(42);
                labReport.path_status=rs.getString(43);
                labReport.doctor_text=rs.getString(44);
                labReport.pat_mi=rs.getString(45);
                labReport.biopsy_code=rs.getString(46);
                iDatestamp=rs.getInt(47);
                labReport.iDatestamp=iDatestamp;
                labReport.datestamp=rs.getString(49);
                labReport.hold_final=rs.getString(50);
                labReport.test_sent=rs.getString(51);
                labReport.send_fax=rs.getString(52);
                labReport.verified_on=rs.getString(53);
                labReport.verified_by=rs.getString(54);
                labReport.e_reporting=rs.getString(55);
                labReport.program=rs.getString(56);
                labReport.parent_account=rs.getInt(57);
                labReport.test_results=rs.getString(58);
                //labReport.results_received=rs.getString(59);
                labReport.date_reported=rs.getString(59);
                labReport.practice_type=rs.getString(61);
                if (!Utils.isNull(labReport.remarks)) {
                    labReport.formatRemarks();
                }
                // retrieve the details from the requisition for this lab
                queryDetails(labReport);
                /*  determine which result set takes precedence
                    and then retrieve those result codes
                */
                setDirector(labReport);
                ndx++;
                /*  the report counter decrements and is used for
                    display purposes; once the user clicks the retrieve
                    button they may visually see the display change 
                    starting from the total number of reports down
                    to zero, at which point the Windows print windows
                    appears
                */
                reportCounter--;
                if (parent.printMode==Lab.CURR_FINAL) {
                    parent.finalPrints.setText(Integer.toString(reportCounter));
                }
                parent.repaint();
                if (parent.printMode==Lab.CURR_FINAL
                && labReport.send_fax.equals("Y"))
                {
                    faxVect.addElement(labReport);
                }
                else
                    parent.labReportVect.addElement(labReport);
            }
            int numFaxes = 0;
            if (faxVect.size()>0) {
                parent.hasFaxFinals=true;
                numFaxes=faxVect.size();
                for (int i=0; i<faxVect.size(); i++) {
                    LabReportRec r = (LabReportRec)faxVect.elementAt(i);
                    parent.labReportVect.addElement(r);
                }
            }
            parent.log.write(
                "   close labReportVect cursor ["+parent.labReportVect.size()+"]");
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
        HPV Report print queue, and then add a print history
        record to the print history table.  Each account of an HPV
        report being printed must be recorded.
    */
    public boolean dequeue(int labNum)  {
        parent.log.write("dequeue("+labNum+","+parent.printMode+")");
        boolean exitStatus=true;
        try  {
            String SQL = new String(
                "DELETE FROM pcs.hpv_print_queue \n"+
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
                "INSERT INTO pcs.hpv_history (lab_number,first_print,print_date) \n"+
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
    
    /*
        Determine whether there are any labReport objects currently queued
        for printing; the return value is the sum of any DRAFT or FINAL
        reports that are currently queued for printing.
    */
    public int checkQueue() {
        try  {
            String SQL = new String(
                "SELECT first_print,count(first_print) \n"+
                "FROM pcs.hpv_print_queue \n"+
                "GROUP BY first_print");
                
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            int pMode=0;
            while (rs.next()) { 
                pMode=rs.getInt(1);
                // set the total of each type of printing currently queued
                if (pMode==Lab.CURR_FINAL) parent.numFinals=rs.getInt(2);
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); }                
        }
        catch (Exception e) { parent.log.write(e); }
        parent.log.write(
            "RETURNING checkQueue("+(parent.numFinals)+")");
        return(parent.numFinals);            
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
        parent.log.write("CLOSING HPVDbOps");
    }
	
}
