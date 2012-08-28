package com.pacytology.pcs ;
/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       BatchClaimInfoForm.java
    Created By: John Cardella, Software Engineer
    
    Function:   Form for entering information about
    submitting an electronic claims file. For files that
    are submitted using X12, this class is set up to read
    the 997 Functional Acknowledgement.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import java.awt.event.KeyEvent;

import javax.swing.*;
import java.io.*;
import java.sql.*;
import java.util.StringTokenizer;
import java.util.Vector;
import com.pacytology.pcs.ui.Square;

public class BatchClaimInfoForm extends javax.swing.JFrame
{
    
    Login dbLogin;
    File ackFile;
    ClaimSubmissionRec submitRec = new ClaimSubmissionRec();
    Vector submitRecVect = new Vector();
    LogFile log;
    int ndx = 0;
    int labNumber = 0;
    int batchNum = 0;
    
	public BatchClaimInfoForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Electronic Claim Submissions");
		getContentPane().setLayout(null);
		setSize(300,347);
		setVisible(false);
		getContentPane().add(F1sq);
		F1sq.setBounds(25,4,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F1");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(29,4,20,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(87,4,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F3");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(91,4,20,20);
		getContentPane().add(F3sq);
		F3sq.setBounds(149,4,20,20);
		F3lbl.setRequestFocusEnabled(false);
		F3lbl.setText("F9");
		getContentPane().add(F3lbl);
		F3lbl.setForeground(java.awt.Color.black);
		F3lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F3lbl.setBounds(153,4,20,20);
		getContentPane().add(F4sq);
		F4sq.setBounds(211,4,20,20);
		F4lbl.setRequestFocusEnabled(false);
		F4lbl.setText("F12");
		getContentPane().add(F4lbl);
		F4lbl.setForeground(java.awt.Color.black);
		F4lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F4lbl.setBounds(212,4,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Update");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(62,28,70,16);
		F3action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F3action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F3action.setText("Exit");
		getContentPane().add(F3action);
		F3action.setForeground(java.awt.Color.black);
		F3action.setBounds(124,28,70,16);
		F4action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F4action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F4action.setText("Submit");
		getContentPane().add(F4action);
		F4action.setForeground(java.awt.Color.black);
		F4action.setBounds(186,28,70,16);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Query");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(0,28,70,18);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		msgLabel.setBounds(24,50,250,14);
		JLabel2.setRequestFocusEnabled(false);
		JLabel2.setText("TPP");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(16,78,40,12);
		tppCode.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		tppCode.setEnabled(false);
		getContentPane().add(tppCode);
		tppCode.setFont(new Font("DialogInput", Font.PLAIN, 12));
		tppCode.setBounds(50,76,30,20);
		tppNameLbl.setRequestFocusEnabled(false);
		tppNameLbl.setText("TPP Name");
		getContentPane().add(tppNameLbl);
		tppNameLbl.setBounds(90,78,200,12);
		batchID.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		batchID.setEnabled(false);
		getContentPane().add(batchID);
		batchID.setFont(new Font("DialogInput", Font.PLAIN, 12));
		batchID.setBounds(156,106,50,20);
		JLabel1.setRequestFocusEnabled(false);
		JLabel1.setText("Batch Number/Claims");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(16,108,128,12);
		JLabel3.setRequestFocusEnabled(false);
		JLabel3.setText("Times Submitted");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(16,134,128,12);
		JLabel4.setRequestFocusEnabled(false);
		JLabel4.setText("File Created On");
		getContentPane().add(JLabel4);
		JLabel4.setBounds(16,160,128,12);
		JLabel5.setRequestFocusEnabled(false);
		JLabel5.setText("File Submitted On");
		getContentPane().add(JLabel5);
		JLabel5.setBounds(16,186,128,12);
		JLabel6.setRequestFocusEnabled(false);
		JLabel6.setText("TPP Control Number");
		getContentPane().add(JLabel6);
		JLabel6.setBounds(16,212,128,12);
		timesSubmitted.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		timesSubmitted.setEnabled(false);
		getContentPane().add(timesSubmitted);
		timesSubmitted.setFont(new Font("DialogInput", Font.PLAIN, 12));
		timesSubmitted.setBounds(156,132,50,20);
		createDate.setEnabled(false);
		getContentPane().add(createDate);
		createDate.setFont(new Font("DialogInput", Font.PLAIN, 12));
		createDate.setBounds(156,158,130,20);
		submitDate.setEnabled(false);
		getContentPane().add(submitDate);
		submitDate.setFont(new Font("DialogInput", Font.PLAIN, 12));
		submitDate.setBounds(156,184,130,20);
		controlNum.setEnabled(false);
		getContentPane().add(controlNum);
		controlNum.setFont(new Font("DialogInput", Font.PLAIN, 12));
		controlNum.setBounds(156,210,130,20);
		numClaims.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		numClaims.setEnabled(false);
		getContentPane().add(numClaims);
		numClaims.setFont(new Font("DialogInput", Font.PLAIN, 12));
		numClaims.setBounds(212,106,30,20);
		JLabel7.setRequestFocusEnabled(false);
		JLabel7.setText("Additional Info:");
		getContentPane().add(JLabel7);
		JLabel7.setBounds(16,232,128,12);
		moreInfo.setEnabled(false);
		getContentPane().add(moreInfo);
		moreInfo.setFont(new Font("DialogInput", Font.PLAIN, 11));
		moreInfo.setBounds(16,246,270,30);
		read277.setText("Process 277");
		read277.setActionCommand("Process 277");
		read277.setEnabled(false);
		getContentPane().add(read277);
		read277.setBounds(16,288,106,24);
		fileName277.setEnabled(false);
		getContentPane().add(fileName277);
		fileName277.setFont(new Font("DialogInput", Font.PLAIN, 12));
		fileName277.setBounds(156,288,130,20);
		display277.setText("Display 277");
		display277.setActionCommand("Process 277");
		display277.setEnabled(false);
		getContentPane().add(display277);
		display277.setBounds(16,316,106,24);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		tppCode.addKeyListener(aSymKey);
		this.addKeyListener(aSymKey);
		submitDate.addKeyListener(aSymKey);
		controlNum.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymAction lSymAction = new SymAction();
		read277.addActionListener(lSymAction);
		fileName277.addKeyListener(aSymKey);
		batchID.addKeyListener(aSymKey);
		//}}
	}

	public BatchClaimInfoForm(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
    public BatchClaimInfoForm(Login dbLogin)
    {
        this();
        this.dbLogin=dbLogin;
        this.log = new LogFile(
            dbLogin.logPath,"BatchClaimInfoForm",dbLogin.dateToday,dbLogin.userName);
        resetForm();
    }        

	public void setVisible(boolean b)
	{
		if (b) setLocation(50,50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new BatchClaimInfoForm()).setVisible(true);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted)
			return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets and menu bar
		Insets insets = getInsets();
		javax.swing.JMenuBar menuBar = getRootPane().getJMenuBar();
		int menuBarHeight = 0;
		if (menuBar != null)
			menuBarHeight = menuBar.getPreferredSize().height;
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height + menuBarHeight);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	//{{DECLARE_CONTROLS
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	Square F3sq = new Square();
	javax.swing.JLabel F3lbl = new javax.swing.JLabel();
	Square F4sq = new Square();
	javax.swing.JLabel F4lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F3action = new javax.swing.JLabel();
	javax.swing.JLabel F4action = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JTextField tppCode = new javax.swing.JTextField();
	javax.swing.JLabel tppNameLbl = new javax.swing.JLabel();
	javax.swing.JTextField batchID = new javax.swing.JTextField();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel4 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel5 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel6 = new javax.swing.JLabel();
	javax.swing.JTextField timesSubmitted = new javax.swing.JTextField();
	javax.swing.JTextField createDate = new javax.swing.JTextField();
	javax.swing.JTextField submitDate = new javax.swing.JTextField();
	javax.swing.JTextField controlNum = new javax.swing.JTextField();
	javax.swing.JTextField numClaims = new javax.swing.JTextField();
	javax.swing.JLabel JLabel7 = new javax.swing.JLabel();
	javax.swing.JTextArea moreInfo = new javax.swing.JTextArea();
	javax.swing.JButton read277 = new javax.swing.JButton();
	javax.swing.JTextField fileName277 = new javax.swing.JTextField();
	javax.swing.JButton display277 = new javax.swing.JButton();
	//}}

	//{{DECLARE_MENUS
	//}}

    private File getFile(String prefix)
    {
        File f = null;
        String fileName = null;
        boolean fileFound = false;
        if (prefix.equals("PBU_P") || prefix.equals("PRJ_P")) {
            for (int n=0;n<1000;n++) {
                String inc = null;
                if (n==0) inc="_000";
                else if (n<10) inc="_00"+n;
                else if (n<100) inc="_0"+n;
                else inc="_"+n;
                String hour = null;
                for (int h=0;h<=24;h++) {
                    if (h<10) hour=".0"+h;
                    else hour="."+h;
                    fileName = prefix+inc+dbLogin.dayNumber+hour;
                    f = new File(Utils.ROOT_DIR,fileName);
                    if (f.exists()) { 
                        fileFound=true;
                        break;
                    }
                }
                if (fileFound) break;
            }
        }
        log.write(fileName+" "+fileFound);
        return f;
    }


	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == tppCode)
				tppCode_keyTyped(event);
			else if (object == submitDate)
				submitDate_keyTyped(event);
			else if (object == controlNum)
				controlNum_keyTyped(event);
			else if (object == fileName277)
				fileName277_keyTyped(event);
			else if (object == batchID)
				batchID_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == tppCode)
				tppCode_keyPressed(event);
			else if (object == BatchClaimInfoForm.this)
				BatchClaimInfoForm_keyPressed(event);
			else if (object == submitDate)
				submitDate_keyPressed(event);
			else if (object == controlNum)
				controlNum_keyPressed(event);
			else if (object == fileName277)
				fileName277_keyPressed(event);
			else if (object == batchID)
				batchID_keyPressed(event);
		}
	}

	void tppCode_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    /*
		    String tppName = tppCode.getText();
		    if (!Utils.isNull(tppName)) {
		        if (tppName.equals("DAS")) {
		            msgLabel.setText("ENTER 935 FILE NAME");
		            fileName277.setEnabled(true);
		            fileName277.requestFocus();
		        }
		        else getClaimSubmissionData(tppName);
		    }
		    else {
		        Utils.createErrMsg("Invalid TPP Code");
		        resetForm();
		    }
		    */
		    String tppName = tppCode.getText();
		    if (!Utils.isNull(tppName)) {
		        msgLabel.setText("ENTER BATCH NUMBER");
		        batchID.setEnabled(true);
		        batchID.requestFocus();
		    }
		    else {
		        Utils.createErrMsg("Invalid TPP Code");
		        resetForm();
		    }
		}
	}

	void tppCode_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}
	
	void getClaimSubmissionData(String tpp)
	{
	    String ackFilePrefix = null;
	    if (tpp.equals("DAS")) {
	        ackFilePrefix="PBU_P";
	        ackFile = getFile(ackFilePrefix);
	        if (ackFile.exists()) {
	            query();
	            fillForm(submitRec);
	            getData(ackFile,tpp);
	            setEnableAllFields(false);
	            msgLabel.requestFocus();
	        }
	        else Utils.createErrMsg("Cannot locate acknowledgement file");
        }
	    else if (tpp.equals("HGS")) {
	        ackFilePrefix="PRJ_P";
	        ackFile = getFile(ackFilePrefix);
	        if (ackFile.exists()) {
	            query();
	            fillForm(submitRec);
	            getData(ackFile,tpp);
	            setEnableAllFields(false);
	            msgLabel.requestFocus();
	        }
	        else Utils.createErrMsg("Cannot locate acknowledgement file");
	    }
	    else if (tpp.equals("ENV")) {
	        query();
	        fillForm(submitRec);
	        setEnableAllFields(false);
	        msgLabel.requestFocus();
	    }
	    else Utils.createErrMsg("TPP does not exist");
	}
	
	void getClaimSubmissionData()
	{
	    String tpp=tppCode.getText();
	    ackFile=new File(Utils.ROOT_DIR,fileName277.getText());
	    if (tpp.equals("DAS")) {
	        if (ackFile.exists()) {
	            query();
	            fillForm(submitRec);
	            getData(ackFile,tpp);
	            setEnableAllFields(false);
	            msgLabel.requestFocus();
	        }
	        else {
	            Utils.createErrMsg("Cannot locate acknowledgement file");
	            resetForm();
	        }
        }
	    else if (tpp.equals("HGS")) {
	        if (ackFile.exists()) {
	            query();
	            fillForm(submitRec);
	            getData(ackFile,tpp);
	            setEnableAllFields(false);
	            msgLabel.requestFocus();
	        }
	        else {
	            Utils.createErrMsg("Cannot locate acknowledgement file");
	            resetForm();
	        }
	    }
	    else if (tpp.equals("ENV")) {
	        query();
	        fillForm(submitRec);
	        setEnableAllFields(false);
	        msgLabel.requestFocus();
	    }
	    else {
	        Utils.createErrMsg("TPP does not exist");
	        resetForm();
	    }
	}

	void BatchClaimInfoForm_keyPressed(java.awt.event.KeyEvent event)
	{
		int key = event.getKeyCode();
		switch (key) {
		    case KeyEvent.VK_F1:
		        resetForm();
		        if (event.isShiftDown()) {
                    fileName277.setEnabled(true);
                    read277.setEnabled(true);
                    fileName277.requestFocus();
		        }
		        else {
		            tppCode.setEnabled(true);
		            tppCode.requestFocus();
		        }
		        break;
		    case KeyEvent.VK_F4:
		        getPayerSummary();
		        break;
            case KeyEvent.VK_ESCAPE:
                resetForm();
                break;
            case KeyEvent.VK_F9:
                closingActions();
                break;
            case KeyEvent.VK_F3:
                updateActions();
                break;
            case KeyEvent.VK_DOWN:
                if (submitRecVect.size()>0) {
                    ndx++;
                    if (ndx>=submitRecVect.size()) ndx=submitRecVect.size()-1;
                    submitRec = (ClaimSubmissionRec)submitRecVect.elementAt(ndx);
                    fillForm(submitRec);
                }
                break;
            case KeyEvent.VK_UP:                
                if (submitRecVect.size()>0) {
                    ndx--;
                    if (ndx<0) ndx=0;
                    submitRec = (ClaimSubmissionRec)submitRecVect.elementAt(ndx);
                    fillForm(submitRec);
                }
                break;
            case KeyEvent.VK_F12:
                finalActions();
                String fName = 
                    submitRec.tpp.toLowerCase()+
                    submitRec.batch_number+
                    submitRec.submission_number+".ack";
                try { ackFile.renameTo(new File(Utils.ROOT_DIR,fName)); }
                catch (SecurityException e) { log.write(e.toString()); }
                break;
		}
	}

	void submitDate_keyPressed(java.awt.event.KeyEvent event)
	{
		// to do: code goes here.
	}

	void submitDate_keyTyped(java.awt.event.KeyEvent event)
	{
		// to do: code goes here.
	}

	void controlNum_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
	        if (Utils.required(controlNum,"Control Number")) {
	            submitRec.control_number=controlNum.getText();
	            submitRec.ack_code="A";
	            finalActions();
	        }
	    }
	}

	void controlNum_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}
	
	void setEnableAllFields(boolean eVal)
	{
	    tppCode.setEnabled(eVal);
	    submitDate.setEnabled(eVal);
	    controlNum.setEnabled(eVal);
	}
	
	void resetForm()
	{
	    Utils.setColors(this.getContentPane());
	    msgLabel.setForeground(Color.green.brighter());
	    tppNameLbl.setForeground(Color.white);
	    tppNameLbl.setText(null);
	    ndx=0;
        submitRecVect = new Vector();
	    setEnableAllFields(false);
	    tppCode.setText(null);
	    batchID.setText(null);
	    moreInfo.setText(null);
	    numClaims.setText(null);
	    timesSubmitted.setText(null);
	    createDate.setText(null);
	    submitDate.setText(null);
	    controlNum.setText(null);
	    read277.setEnabled(false);
	    fileName277.setEnabled(false);
	    fileName277.setText(null);
	    msgLabel.setText(null);
	    msgLabel.requestFocus();
        submitRec = new ClaimSubmissionRec();
	}
	
    private boolean query()  
    {
        boolean exitStatus=true;
        try  {
            String SQL=
                "SELECT S.tpp,TO_CHAR(S.batch_number),TO_CHAR(S.submission_number), \n"+
                "   TO_CHAR(S.creation_date,'MM/DD/YYYY HH24:Mi'), \n"+
                "   TO_CHAR(NVL(S.submission_date,S.creation_date),'MM/DD/YYYY HH24:Mi'), \n"+
                "   S.control_number,TO_CHAR(B.number_of_claims) \n"+
                "FROM pcs.claim_submissions S, pcs.claim_batches B \n"+
                "WHERE S.tpp='"+tppCode.getText()+"' and S.batch_number=B.batch_number \n"+
                "   and S.batch_number="+batchID.getText()+" \n"+
                "ORDER BY S.batch_number, S.submission_number \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { 
                ClaimSubmissionRec sRec = new ClaimSubmissionRec();
                sRec.tpp=rs.getString(1);
                sRec.batch_number=rs.getString(2);
                sRec.submission_number=rs.getString(3);
                sRec.creation_date=rs.getString(4);
                sRec.submission_date=rs.getString(5);
                sRec.control_number=rs.getString(6);
                sRec.number_of_claims=rs.getString(7);
                submitRecVect.addElement(sRec);
            }
            if (submitRecVect.size()>0)
                submitRec=(ClaimSubmissionRec)submitRecVect.elementAt(0);
            else
                Utils.createErrMsg("Invalid Batch Number for TPP");
            try { stmt.close(); rs.close(); }
            catch (SQLException e) { 
                log.write(SQL);
                log.write(e);
                exitStatus=false; 
            }                
        }
        catch (Exception e) {
            log.write(e.toString());
            exitStatus=false;
        }
        return exitStatus;
    }
    
    void fillForm(ClaimSubmissionRec r)
    {
        tppCode.setText(r.tpp);
        batchID.setText(r.batch_number);
        numClaims.setText(r.number_of_claims);
        timesSubmitted.setText(r.submission_number);
        createDate.setText(r.creation_date);
        submitDate.setText(r.submission_date);
        controlNum.setText(r.control_number);
        if (!Utils.isNull(r.ack_code)) {
            String status = getAckCode(r.ack_code);
            msgLabel.setText("Status:  "+status);
            if (Utils.length(r.submission_status)==3) 
                moreInfo.setText(getInterchangeCode(r.submission_status));
            else
                moreInfo.setText(getTranSetCode(r.submission_status));
        }
        else msgLabel.setText(null);
    }
    
    void getData(File f, String tpp)
    {
        FileInputStream fIN = null;
        if (f.exists()) {
            long fLen = f.length();
            if (fLen>0) { 
                StringBuffer s = new StringBuffer();
                try {
                    fIN = new FileInputStream(f);
                    int element = 0;
                    for (;;) {
                        int x = fIN.read();
                        if (x==-1) break;
                        char c = (char)x;
                        if (c=='~') {
                            processSegment(s,tpp);
                            s = new StringBuffer();
                        }
                        else s.append(c);
                    }
                    fIN.close();
                }
                catch (Exception e) { }
            }	    
        }
        
    }
    
    void processSegment(StringBuffer s, String tpp)
    {
        String token = null;
        if (tpp.equals("HGS")) token="*";
        else if (tpp.equals("DAS")) token="^";
        StringTokenizer st = new StringTokenizer(s.toString(),token,false);
        int element = 0;
        String segment = null;
        String sDate = null;
        String status = null;
        while (st.hasMoreTokens()) {
            String t = st.nextToken();
            if (element==0) {
                segment = new String(t);
                element++;
            }
            else {
                if (segment.equals("ISA")) {
                    if (element==9) {
                        sDate=
                            t.substring(2,4)+"/"+t.substring(4,6)+"/20"+t.substring(0,2);
                    }
                    else if (element==10) {
                        sDate=sDate+" "+t.substring(0,2)+":"+t.substring(2,4);
                        submitRec.submission_date=sDate;
                        submitDate.setText(sDate);
                    }
                    else if (element==13) {
                        submitRec.control_number=t;
                        controlNum.setText(t);
                    }
                    element++;
                }
                else if (segment.equals("TA1")) {
                    if (element==4) {
                        submitRec.ack_code=t;
                        status=getAckCode(t);
                    }
                    else if (element==5) {
                        submitRec.submission_status=t;
                        moreInfo.setText(getInterchangeCode(t));
                        msgLabel.setText("Status:  "+status);
                    }
                    element++;
                }
                else if (segment.equals("AK5")) {
                    if (element==1) {
                        submitRec.ack_code=t;
                        status=getAckCode(t);
                    }
                    else if (element==2 && !submitRec.ack_code.equals("A")) {
                        submitRec.submission_status=t;
                        moreInfo.setText(getTranSetCode(t));
                        msgLabel.setText("Status:  "+status);
                    }
                    element++;
                }
                else if (segment.equals("TRN")) {
                    if (element==2) labNumber=(int)Integer.parseInt(t);
                    element++;
                }
                else if (segment.equals("STC")) {
                    if (element==1) processElement(t,labNumber);
                    element++;
                }
            }
        }
    }
    
    void processElement(String e, int labNumber)
    {
        String token = ">";
        StringTokenizer st = new StringTokenizer(e,token,false);
        int element = 0;
        String category = null;
        String status = null;
        while (st.hasMoreTokens()) {
            String t = st.nextToken();
            element++;
            if (element==1) category = new String(t);
            else if (element==2) status = new String(t);
        }
        insertClaimStatus(labNumber,category,status);
    }
    
    private String getAckCode(String code)  
    {
        String s = null;
        try  {
            String SQL=
                "SELECT description \n"+
                "FROM pcs.x12_ack_codes \n"+
                "WHERE code_value='"+code+"' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { s=rs.getString(1); } 
            try { stmt.close(); rs.close(); }
            catch (SQLException e) { log.write(SQL); log.write(e); }
        }
        catch (Exception e) { log.write(e.toString()); }
        return (s);
    }
    
    private String getInterchangeCode(String code)  
    {
        String s = null;
        try  {
            String SQL=
                "SELECT description \n"+
                "FROM pcs.x12_interchange_codes \n"+
                "WHERE ta1_code='"+code+"' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { s=rs.getString(1); } 
            try { stmt.close(); rs.close(); }
            catch (SQLException e) { log.write(SQL); log.write(e); }
        }
        catch (Exception e) { log.write(e.toString()); }
        return (s);
    }
    
    private String getTranSetCode(String code)  
    {
        String s = null;
        try  {
            String SQL=
                "SELECT description \n"+
                "FROM pcs.x12_ts_syntax_errors \n"+
                "WHERE error_code="+code+" \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { s=rs.getString(1); } 
            try { stmt.close(); rs.close(); }
            catch (SQLException e) { log.write(SQL); log.write(e); }
        }
        catch (Exception e) { log.write(e.toString()); }
        return (s);
    }
    
    private void insertClaimStatus(int labNumber, String cat, String st)  
    {
        try  {
            String SQL=
                "INSERT INTO pcs.claim_status_responses \n"+
                "(lab_number,category,status,control_number) \n"+
                "VALUES (?,?,?,?) \n";
            PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,labNumber);
            pstmt.setString(2,cat);
            pstmt.setString(3,st);
            pstmt.setString(4,submitRec.control_number);
            pstmt.execute();
            try { pstmt.close(); }
            catch (SQLException e) { log.write(SQL); log.write(e); }
        }
        catch (Exception e) { log.write(e.toString()); }
    }
    
    private void insert277fileData()  
    {
        try  {
            String SQL=
                "INSERT INTO pcs.response_files \n"+
                "(control_number,file_name,datestamp) \n"+
                "VALUES (?,?,TO_DATE(?,'MM/DD/YYYY HH24:Mi') ) \n";
            PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setString(1,submitRec.control_number);
            pstmt.setString(2,fileName277.getText());
            pstmt.setString(3,submitDate.getText());
            pstmt.execute();
            try { pstmt.close(); }
            catch (SQLException e) { log.write(SQL); log.write(e); }
        }
        catch (Exception e) { log.write(e.toString()); }
    }

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == BatchClaimInfoForm.this)
				BatchClaimInfoForm_windowClosing(event);
		}
	}

	void updateActions()
	{
	    if (!Utils.isNull(tppCode.getText())) {
	        if (tppCode.getText().equals("DAS")) {
	            Utils.createErrMsg("Cannot update DAS submission data");
	        }
	        else if (tppCode.getText().equals("ENV")) {
	            controlNum.setEnabled(true);
	            controlNum.requestFocus();
	            msgLabel.setText("Enter KEA number");
	        }
	    }
	}
	
    private boolean finalActions()  
    {
        boolean exitStatus = true;
        try  {
            String SQL =
                "UPDATE pcs.claim_submissions SET \n"+
                "   submission_date = TO_DATE(?,'MM/DD/YYYY HH24:Mi'), \n"+
                "   control_number = ?, \n"+
                "   ack_code = ?, \n"+
                "   submission_status = ? \n"+
                "WHERE batch_number = ? \n"+
                "AND submission_number = ? \n";

            PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setString(1,submitRec.submission_date);
            pstmt.setString(2,submitRec.control_number);
            pstmt.setString(3,submitRec.ack_code);
            pstmt.setString(4,submitRec.submission_status);
            pstmt.setInt(5,Integer.parseInt(submitRec.batch_number));
            pstmt.setInt(6,Integer.parseInt(submitRec.submission_number));
            int rs = pstmt.executeUpdate();
            try { pstmt.close(); }
            catch (SQLException e) { log.write(SQL); log.write(e); }
        }
        catch (Exception e) {
            log.write(e.toString()); 
            exitStatus=false;
        }
        setEnableAllFields(false);
        msgLabel.requestFocus();
        return exitStatus;
    }
    
    private void getPayerSummary()
    {
        Vector v = new Vector();
        int batch_number = 0;
        try  {
            batch_number = (int)Integer.parseInt(batchID.getText());
            String SQL =
                "SELECT \n"+
                "   SUBSTR(P.name,1,44), \n"+
                "   TO_CHAR(A.amount_submitted,'999,999.99'), \n"+
                "   P.carrier_id \n"+
                "FROM \n"+
                "   pcs.payer_batch_amounts A, \n"+
                "   pcs.carriers P \n"+
                "WHERE \n"+
                "   A.carrier_id=P.carrier_id and \n"+
                "   A.batch_number = ? \n"+
                "ORDER BY P.name \n";

            PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,batch_number);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                String payerName = rs.getString(1);
                String payerAmount = rs.getString(2);
                int carrierID = rs.getInt(3);
                int count = 0;
                String SSQL =
                    "SELECT count(*) FROM \n"+
                    "   pcs.lab_claims C, \n"+
                    "   pcs.billing_details B \n"+
                    "WHERE \n"+
                    "   C.claim_id=B.claim_id and \n"+
                    "   B.carrier_id = ? and \n"+
                    "   C.batch_number = ? \n";
                PreparedStatement stmt = DbConnection.process().prepareStatement(SSQL);
                stmt.setInt(1,carrierID);
                stmt.setInt(2,batch_number);
                ResultSet rss = stmt.executeQuery();
                while (rss.next()) { count = rss.getInt(1); }
                try { rss.close(); stmt.close(); }
                catch (SQLException e) { log.write(SQL); log.write(e); }
                payerName=Utils.rpad(payerName.trim(),46);
                payerAmount=Utils.lpad(payerAmount.trim(),12);
                String nClaims = Integer.toString(count);
                nClaims=Utils.lpad(nClaims.trim(),5);
                String currLine = payerName+nClaims+payerAmount;
                v.addElement(currLine);
            }
            
            SQL =
                "SELECT TO_CHAR(SUM(A.amount_submitted),'999,999.99') \n"+
                "FROM pcs.payer_batch_amounts A \n"+
                "WHERE A.batch_number = ? \n";

            pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,batch_number);
            rs = pstmt.executeQuery();
            while (rs.next()) { 
                String total = rs.getString(1);
                total=Utils.lpad(total,63);
                String currLine=Utils.lpad("----------",63);
                v.addElement(currLine);
                v.addElement(total);
            }
            try { pstmt.close(); }
            catch (SQLException e) { log.write(SQL); log.write(e); }
        }
        catch (Exception e) { log.write(e.toString()); }
        if (v.size()>0) {
            String[] s = new String[v.size()];
            for (int i=0; i<v.size(); i++)
                s[i]=(String)v.elementAt(i);
            (new PickList("Payer Amounts - Batch #"+batch_number,
                50,50,430,320,v.size(),s)).setVisible(true);
        }
    }
    
    void closingActions()
    {
        log.stop();
        this.dispose();
    }

	void BatchClaimInfoForm_windowClosing(java.awt.event.WindowEvent event)
	{
		closingActions();
	}

	class SymAction implements java.awt.event.ActionListener
	{
		public void actionPerformed(java.awt.event.ActionEvent event)
		{
			Object object = event.getSource();
			if (object == read277)
				read277_actionPerformed(event);
		}
	}

	void read277_actionPerformed(java.awt.event.ActionEvent event)
	{
	    if (!Utils.required(fileName277,"277 File Name"))
		    fileName277.requestFocus();
        else 
            process277(fileName277.getText());
	}

	void fileName277_keyTyped(java.awt.event.KeyEvent event)
	{
		// to do: code goes here.
	}

	void fileName277_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (!Utils.isNull(tppCode.getText())) {
		        getClaimSubmissionData();
		    }
		    else Utils.required(fileName277,"277 File Name");
		}
	}
	
	private void process277(String fileName)
	{
        File f = null;
        boolean fileFound = false;
        f = new File(Utils.ROOT_DIR,fileName);
        if (f.exists()) { 
            getData(f,"DAS");
            insert277fileData();
        }
        else {
            Utils.createErrMsg("277 file not located");
            resetForm();
        }
	}

	void batchID_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	void batchID_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    String tppName = tppCode.getText();
		    if (Utils.required(batchID,"Batch Number")) {
		        batchNum = (int)Integer.parseInt(batchID.getText());
		        batchID.setEnabled(false);
		        msgLabel.requestFocus();
		        if (tppName.equals("DAS")) {
		            msgLabel.setText("ENTER 999 FILE NAME");
		            fileName277.setEnabled(true);
		            fileName277.requestFocus();
		        }
		        //else getClaimSubmissionData(tppName);
		        else {
		            Utils.createErrMsg("HGS submits preformatted information - "+
		                "Please check network drive for file.", "Warning!");
		        }
		    }
		    else resetForm();
		}
	}

}
