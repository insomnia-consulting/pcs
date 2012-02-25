package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       HPVTestDialog.java
    Created By: John Cardella, Software Engineer
    
    Function:   Data entry form for HPV test data.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import javax.swing.*;
import com.pacytology.pcs.ui.Square;
import java.sql.*;
import java.util.Vector;

public class HPVTestDialog extends javax.swing.JDialog
{
    LabRec labRec;
    HPVRec hpv;
    int labNumber;
    boolean nullStatus = false;
    String priorStatus;
    LogFile log;
    
	public HPVTestDialog()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("HPV Test Information");
		setResizable(false);
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(300,432);
		setVisible(false);
		labGrpNumLbl.setRequestFocusEnabled(false);
		labGrpNumLbl.setText("HPV Testing Requested");
		getContentPane().add(labGrpNumLbl);
		labGrpNumLbl.setBounds(140,8,150,14);
		getContentPane().add(F1sq);
		F1sq.setBounds(25,6,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F9");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(29,6,20,20);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Exit");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,50,16);
		JLabel1.setRequestFocusEnabled(false);
		JLabel1.setText("Test Status");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(20,54,70,14);
		HPVTestSent.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		HPVTestSent.setEnabled(false);
		getContentPane().add(HPVTestSent);
		HPVTestSent.setFont(new Font("DialogInput", Font.PLAIN, 12));
		HPVTestSent.setBounds(94,52,20,20);
		JLabel2.setRequestFocusEnabled(false);
		JLabel2.setText("HPV Test Results");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(20,136,100,14);
		HPVTestResults.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		HPVTestResults.setEnabled(false);
		getContentPane().add(HPVTestResults);
		HPVTestResults.setFont(new Font("DialogInput", Font.PLAIN, 12));
		HPVTestResults.setBounds(128,134,20,20);
		JLabel3.setRequestFocusEnabled(false);
		JLabel3.setText("Results Received On:");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(20,180,150,14);
		resultsReceived.setEnabled(false);
		getContentPane().add(resultsReceived);
		resultsReceived.setFont(new Font("DialogInput", Font.PLAIN, 12));
		resultsReceived.setBounds(202,178,76,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(77,6,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F12");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(78,6,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Submit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(62,30,50,16);
		additionalInfo.setLineWrap(true);
		additionalInfo.setWrapStyleWord(true);
		getContentPane().add(additionalInfo);
		additionalInfo.setBounds(20,212,258,80);
		JLabel4.setRequestFocusEnabled(false);
		JLabel4.setText("Additional Information:");
		getContentPane().add(JLabel4);
		JLabel4.setBounds(20,196,150,14);
		JLabel5.setRequestFocusEnabled(false);
		JLabel5.setText("Positive ( + )  -OR-  Negative ( - )");
		getContentPane().add(JLabel5);
		JLabel5.setBounds(28,152,220,14);
		JLabel7.setRequestFocusEnabled(false);
		JLabel7.setText("(N) Not done, but was requested");
		getContentPane().add(JLabel7);
		JLabel7.setBounds(28,72,240,14);
		JLabel8.setRequestFocusEnabled(false);
		JLabel8.setText("(R) Requisition waiting to be printed");
		getContentPane().add(JLabel8);
		JLabel8.setBounds(28,84,240,14);
		JLabel9.setRequestFocusEnabled(false);
		JLabel9.setText("(P) Pending results");
		getContentPane().add(JLabel9);
		JLabel9.setBounds(28,96,200,14);
		JLabel10.setRequestFocusEnabled(false);
		JLabel10.setText("(Y) Yes, test results received");
		getContentPane().add(JLabel10);
		JLabel10.setBounds(28,108,230,14);
		JLabel11.setRequestFocusEnabled(false);
		JLabel11.setText("Enter Y for Test Status");
		getContentPane().add(JLabel11);
		JLabel11.setBounds(148,24,150,14);
		JLabel12.setRequestFocusEnabled(false);
		JLabel12.setText("when results received");
		getContentPane().add(JLabel12);
		JLabel12.setBounds(148,36,150,14);
		JLabel13.setRequestFocusEnabled(false);
		JLabel13.setText("(Q) Quantity Not Sufficient");
		getContentPane().add(JLabel13);
		JLabel13.setBounds(28,120,230,14);
		JLabel14.setRequestFocusEnabled(false);
		JLabel14.setText("Billing Info:");
		getContentPane().add(JLabel14);
		JLabel14.setBounds(20,300,150,14);
		getContentPane().add(billingList);
		billingList.setBounds(20,316,260,90);
		facility.setRequestFocusEnabled(false);
		facility.setText("FACILITY");
		getContentPane().add(facility);
		facility.setBounds(122,54,100,14);
		//}}
	
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		HPVTestSent.addKeyListener(aSymKey);
		HPVTestResults.addKeyListener(aSymKey);
		resultsReceived.addKeyListener(aSymKey);
		additionalInfo.addKeyListener(aSymKey);
		this.addKeyListener(aSymKey);
		//}}
	}

	public HPVTestDialog(HPVRec hpv, int labNumber)
	{
		this();
        this.log = new LogFile(
            dbConnection.getLogPath(),
            "HPVTestDialog",
            dbConnection.getDate(),
            dbConnection.getUser());		
		this.hpv=hpv;
		this.labNumber=labNumber;
		this.priorStatus=hpv.test_sent;
		if (Utils.isNull(this.priorStatus)) nullStatus=true;
		log.write("Update HPV data: "+labNumber);
		resetColors();
		fillForm();
	}

	public HPVTestDialog(LabRec labRec)
	{
		this();
        this.log = new LogFile(
            dbConnection.getLogPath(),
            "HPVTestDialog",
            dbConnection.getDate(),
            dbConnection.getUser());		
        this.labRec=labRec;
        this.hpv=labRec.hpv;
		this.labNumber=labRec.lab_number;
		this.priorStatus=hpv.test_sent;
		if (Utils.isNull(this.priorStatus)) nullStatus=true;
		log.write("Update HPV data: "+labNumber);
		resetColors();
		fillForm();
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(500,120);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new HPVTestDialog()).setVisible(true);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted)
			return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets
		Insets insets = getInsets();
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	//{{DECLARE_CONTROLS
	javax.swing.JLabel labGrpNumLbl = new javax.swing.JLabel();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JTextField HPVTestSent = new javax.swing.JTextField();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JTextField HPVTestResults = new javax.swing.JTextField();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JTextField resultsReceived = new javax.swing.JTextField();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JTextArea additionalInfo = new javax.swing.JTextArea();
	javax.swing.JLabel JLabel4 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel5 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel7 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel8 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel9 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel10 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel11 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel12 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel13 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel14 = new javax.swing.JLabel();
	javax.swing.JList billingList = new javax.swing.JList();
	javax.swing.JLabel facility = new javax.swing.JLabel();
	//}}
	
	void resetColors()
	{
	    Utils.setColors(this.getContentPane());
        HPVTestResults.setFont(new Font("SansSerif", Font.PLAIN, 18));	    
	}


	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == HPVTestDialog.this)
				HPVTestDialog_windowClosing(event);
		}

		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == HPVTestDialog.this)
				HPVTestDialog_windowOpened(event);
		}
	}

	void HPVTestDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		HPVTestSent.setEnabled(true);
		HPVTestSent.requestFocus();
	}

	void HPVTestDialog_windowClosing(java.awt.event.WindowEvent event)
	{
		closingActions();
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == HPVTestSent)
				HPVTestSent_keyPressed(event);
			else if (object == HPVTestResults)
				HPVTestResults_keyPressed(event);
			else if (object == resultsReceived)
				resultsReceived_keyPressed(event);
			else if (object == additionalInfo)
				additionalInfo_keyPressed(event);
			else if (object == HPVTestDialog.this)
				HPVTestDialog_keyPressed(event);
		}

		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == HPVTestSent)
				HPVTestSent_keyTyped(event);
			else if (object == HPVTestResults)
				HPVTestResults_keyTyped(event);
			else if (object == resultsReceived)
				resultsReceived_keyTyped(event);
			else if (object == additionalInfo)
				additionalInfo_keyTyped(event);
		}
	}

	void HPVTestSent_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event,1);
	}

	void HPVTestSent_keyPressed(java.awt.event.KeyEvent event)
	{
	    boolean resultsEntered = true;
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (nullStatus) {
		        resultsEntered=Utils.hasResults(labNumber);
		        if (resultsEntered) priorStatus="P";
		        else Utils.createErrMsg("PCS Results have not been entered yet.");
		    }
		    if (resultsEntered) {
		        if (Utils.required(HPVTestSent,"Submitted for HPV Testing")) {
		            String s = HPVTestSent.getText();
		            if (s.equals("Y") || s.equals("N") 
		            || s.equals("R") || s.equals("P") || s.equals("Q")) {
		                if (s.equals("Y")) {
		                    HPVTestResults.setEnabled(true);
		                    resultsReceived.setEnabled(true);
		                }
		                else if (s.equals("Q")) {
		                    resultsReceived.setEnabled(true);
		                }
		                else {
		                    HPVTestResults.setEnabled(false);
		                    resultsReceived.setEnabled(false);
		                    HPVTestResults.setText(null);
		                    resultsReceived.setText(null);
		                }
		                additionalInfo.setEnabled(true);
		                HPVTestSent.transferFocus();
		            }
		            else {
		                Utils.createErrMsg("Valid values are N, R, P, N, or Q");
		                HPVTestSent.setText(null);
		            }
		        }
		    }
		}
	}

	void HPVTestResults_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event,1);
	}

	void HPVTestResults_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(HPVTestResults,"Test Results")) {
		        String s = HPVTestResults.getText();
		        if (s.equals("+") || s.equals("-") || s.equals("I")) {
		            HPVTestResults.transferFocus();
		        }
		        else {
		            Utils.createErrMsg("Valid values are + and -");
		            HPVTestResults.setText(null);
		        }
		    }
		}
	}

	void resultsReceived_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.buildDateMask(event);
	}

	void resultsReceived_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(resultsReceived,"Date results were received")) {
		        if (Utils.dateVerify(resultsReceived))
		            resultsReceived.transferFocus();
		    }
		}
	}

	void additionalInfo_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}

	void additionalInfo_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) event.consume();
	}

	void HPVTestDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		int key = event.getKeyCode();
		if (key==event.VK_F9) closingActions();
		else if (key==event.VK_F12) finalActions(); 
		else if (key==event.VK_CONTROL) ((JTextField)getFocusOwner()).setText(null);
	}
	
	void finalActions()
	{
	    if (nullStatus&&!Utils.hasResults(labNumber)) {
	        Utils.createErrMsg("PCS Results have not been entered yet.");
	    }
	    else if (Utils.isNull(HPVTestSent.getText())) {
	        Utils.createErrMsg("No value entered for status.");
	    }
	    else if (priorStatus.equals("P")) { 
	        if (HPVTestSent.getText().equals("Y") 
	        || HPVTestSent.getText().equals("N") || HPVTestSent.getText().equals("Q")) {
	            fillRecord();
                update(true);
            }
            else {
                Utils.createErrMsg(
                    "Valid actions for pending HPV are: Y, P, or Q - no action taken.");
            }
	    }
	    else if (priorStatus.equals("R")) {
	        Utils.createErrMsg("HPV Requisition queued to be printed - no action taken.");
	    }
	    else if (priorStatus.equals("N")) {
	        if (HPVTestSent.getText().equals("P")) {
	            fillRecord();
                update(true);
            }
            else {
                Utils.createErrMsg(
                    "ONLY valid action for a test sent status N is: N --> P (NO to PENDING with manual requisition assumed).");
            }
	    }
	    else {
	        boolean canUpdate = false;
	        if (!Utils.isNull(HPVTestSent.getText()))
	            if (!Utils.isNull(HPVTestResults.getText()))
	                if (!Utils.isNull(resultsReceived.getText()))
	                    canUpdate=true;
	        if (canUpdate) {
	            hpv.test_sent=priorStatus;
	            HPVTestSent.setText(priorStatus);
	            fillRecord();
	            update(false);
	        }
	        else Utils.createErrMsg("HPV Results not pending - no action taken.");
	    }
	    closingActions();
	}

	void fillRecord()
	{
	    hpv.test_sent=HPVTestSent.getText();
	    hpv.test_results=HPVTestResults.getText();
	    hpv.results_received=Utils.stripDateMask(resultsReceived.getText());
	    hpv.comment_text=additionalInfo.getText();
	}
	
	void fillForm()
	{
	    HPVTestSent.setText(hpv.test_sent);
	    HPVTestResults.setText(hpv.test_results);
	    if (!Utils.isNull(hpv.hpv_lab)) facility.setText(hpv.hpv_lab);
	    resultsReceived.setText(Utils.addDateMask(hpv.results_received));
	    try { additionalInfo.setText(hpv.comment_text); }
	    catch (Exception e) { log.write(e); }
	    getBillingInfo();
	}
	
	void getBillingInfo()
	{
	    PreparedStatement pstmt = null;
	    try {
	        String SQL =
                "select statement_id||'-'||NVL(billing_cycle,0)||' '||code_description \n"+
                "from pcs.practice_statement_labs \n"+
                "where lab_number = ? \n"+
                "order by billing_cycle,p_seq";	    
	        pstmt = dbConnection.process().prepareStatement(SQL); 
	        pstmt.setInt(1,labNumber);
	        ResultSet rs = pstmt.executeQuery();
	        Vector v = new Vector();
	        while (rs.next()) {
	            String s = rs.getString(1);
	            v.addElement(s);
	        }
	        if (v.size()>0) billingList.setListData(v);
	        pstmt.executeUpdate();
	        pstmt.close();
	    }
	    catch (SQLException e) { log.write(e.toString()); }
	    catch (Exception e) { log.write(e); }
	}
	
	void update(boolean withBilling)
	{
	    PreparedStatement pstmt = null;
	    CallableStatement cstmt = null;
	    try { 
	        String SQL =
	            "UPDATE pcs.hpv_requests SET \n"+
	            "   test_sent = ?, \n"+
	            "   test_results = ?, \n"+
	            "   results_received = TO_DATE(?,'MMDDYYYY'), \n"+
	            "   comment_text = ?, \n"+
	            "   datestamp = SysDate \n"+
	            "WHERE lab_number = ? \n";
	        pstmt = dbConnection.process().prepareStatement(SQL); 
	        pstmt.setString(1,hpv.test_sent);
	        pstmt.setString(2,hpv.test_results);
	        pstmt.setString(3,hpv.results_received);
	        pstmt.setString(4,hpv.comment_text);
	        pstmt.setInt(5,labNumber);
	        pstmt.executeUpdate();
	        pstmt.close();
	        SQL =
	            "UPDATE pcs.lab_results SET \n"+
	            "   change_date = SysDate, \n"+
	            "   change_user = UID \n"+
	            "WHERE lab_number = ? \n";
	        pstmt = dbConnection.process().prepareStatement(SQL); 
	        pstmt.setInt(1,labNumber);
	        pstmt.executeUpdate();
	        pstmt.close();
	        if (!Utils.isNull(hpv.test_sent)&&withBilling) {
	            if (hpv.test_sent.equals("N") 
	            ||  hpv.test_sent.equals("Y") || hpv.test_sent.equals("Q")) {
	                int practice = 0;
	                SQL = 
	                    "SELECT practice from pcs.lab_requisitions \n"+
	                    "WHERE lab_number = ? \n";
	                pstmt = dbConnection.process().prepareStatement(SQL); 
	                pstmt.setInt(1,labNumber);
	                ResultSet rs = pstmt.executeQuery();
	                while (rs.next()) { practice=rs.getInt(1); }
	                rs.close();
	                pstmt.close();
	                cstmt=dbConnection.process().prepareCall(
	                    "{call pcs.calculate_cost(?)}");
                    cstmt.setInt(1,labNumber);
                    cstmt.executeUpdate();
                    cstmt.close();
                    log.write("Charges calculated for "+labNumber);
                    // Needs finished
                    /*
                    SQL =
                        "INSERT INTO pcs.hpv_print_queue (lab_number,first_print) \n"+
                        "VALUES (?,?) \n";
                    pstmt = dbConnection.process().prepareStatement(SQL);
                    pstmt.setInt(1,labNumber);
                    pstmt.setInt(2,Lab.CURR_FINAL);
                    pstmt.execute();
                    pstmt.close();
                    */
	            }
	            else {
	                log.write("Charges NOT computed for "+labNumber);
	                Utils.createErrMsg("Charges NOT computed for "+labNumber);
	            }
	        }
        }
	    catch (SQLException e) { log.write(e.toString()); }
	    catch (Exception e) { log.write(e); }
	}
	
	void closingActions() { log.stop(); this.dispose(); }
	
}
