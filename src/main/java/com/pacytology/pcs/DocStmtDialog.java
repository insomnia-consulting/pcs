package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       DocStmtCopyDialog.java
    Created By: John Cardella, Software Engineer
    
    Function:   Form used to retrive and print a copy
    of a prior doctor statement or cytology summary.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

import javax.swing.JLabel;
import javax.swing.JRootPane;

import com.pacytology.pcs.io.FileTransfer;
import com.pacytology.pcs.ui.PcsDialog;

public class DocStmtDialog extends PcsDialog
{

    Login dbLogin;
    int practice=0;
    PCSLabEntry parent;
    String reportType;
    //boolean isStatement;
    
	public DocStmtDialog(PCSLabEntry parent, String reportType)
	{
		this.parent=parent;
		this.reportType=reportType;
		//this.isStatement=isStatement;
		 this.dbLogin=parent.dbLogin;
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Doctor Statements");
		setResizable(false);
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(230,162);
		setVisible(false);
		getContentPane().add(startPracticeNumber);

		startPracticeNumber.setFont(new Font("SansSerif", Font.BOLD, 12));
		startPracticeNumber.setBounds(130,14,40,20);

		getContentPane().add(stmtMonth);
		stmtMonth.setFont(new Font("SansSerif", Font.BOLD, 12));
		stmtMonth.setBounds(130,36,40,20);
		getContentPane().add(stmtYear);
		stmtYear.setFont(new Font("SansSerif", Font.BOLD, 12));
		stmtYear.setBounds(130,58,40,20);
		JLabel11.setText("Practice");
		getContentPane().add(JLabel11);
		JLabel11.setForeground(java.awt.Color.black);
		JLabel11.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel11.setBounds(20,16,56,14);
		JLabel1.setText("Month (MM)");
		getContentPane().add(JLabel1);
		JLabel1.setForeground(java.awt.Color.black);
		JLabel1.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel1.setBounds(20,38,68,14);
		JLabel2.setText("Year (YYYY)");
		getContentPane().add(JLabel2);
		JLabel2.setForeground(java.awt.Color.black);
		JLabel2.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel2.setBounds(20,60,78,14);
		printerConfirm.setMessageType(javax.swing.JOptionPane.QUESTION_MESSAGE);
		//$$ printerConfirm.move(0,408);

			JWrappingLabel1.setText("For ALL accounts leave practice blank.");

		getContentPane().add(JWrappingLabel1);
		JWrappingLabel1.setForeground(java.awt.Color.blue);
		JWrappingLabel1.setFont(new Font("SansSerif", Font.BOLD, 12));
		JWrappingLabel1.setBounds(20,86,200,36);
		reprintBox.setHorizontalTextPosition(javax.swing.SwingConstants.LEFT);
		reprintBox.setBounds(20,120,180,40);
		reprintBox.setText("Reprint from Parent Practice");
		getContentPane().add(reprintBox);
		
		//}}
		
		//if (!isStatement) setTitle("Doctor Summaries");
		if (reportType.equals("SUMMARY")) setTitle("Doctor Summaries");
		else if (reportType.equals("PATIENT_CARD")) setTitle("Patient Cards");
		
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		stmtMonth.addKeyListener(aSymKey);
		stmtYear.addKeyListener(aSymKey);
		startPracticeNumber.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		//}}
		this.actionMap = new DocStmtDialogActionMap(this);
		this.setupKeyPressMap();
		
	}
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();


		rp.getActionMap().put("F12", actionMap.finalAction);
		rp.getActionMap().put("ENTER", actionMap.finalAction);

		return rp;
	}
	

	public DocStmtDialog()	{	}

	public DocStmtDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public void setVisible(boolean b)
	{
		if (b) setLocation(50,50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new DocStmtDialog()).setVisible(true);
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
	javax.swing.JTextField startPracticeNumber = new javax.swing.JTextField();
	
	javax.swing.JTextField stmtMonth = new javax.swing.JTextField();
	javax.swing.JTextField stmtYear = new javax.swing.JTextField();
	javax.swing.JLabel JLabel11 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JOptionPane printerConfirm = new javax.swing.JOptionPane();
	JLabel JWrappingLabel1 = new JLabel();
	javax.swing.JCheckBox reprintBox = new javax.swing.JCheckBox();
	//}}


	void viewReport()
	{
	    String dir = null;
	    if (Utils.isNull(startPracticeNumber.getText()) ||
	        Utils.isNull(stmtMonth.getText()) ||
	        Utils.isNull(stmtYear.getText())) {
	        Utils.createErrMsg("No Data Entered");
        }
        else {
	        if (practice>0) {
	            String title = "Account #"+startPracticeNumber.getText();
	            String fName=startPracticeNumber.getText()+stmtMonth.getText()+
	                stmtYear.getText().substring(0,1)+
	                stmtYear.getText().substring(2);
	            /*
	            if (!isStatement) { 
	                fName=fName+".sum";
	                title+=" Summary";
	            }
	            else title+=" Statement";
	            */
                Vector v = new Vector();
	            if (reportType.equals("SUMMARY")) {
	                fName=fName+".sum";
	                dir="reports\\sum\\";
	                title+=" Summary";
	            }
	            else if (reportType.equals("PATIENT_CARD")) {
	                fName=fName+".pcd";
	                dir="reports\\pcd\\";
	                title+=" Patient Cards";
	                v.addElement(Utils.COMPRESSED);
	            }
	            else {
	                title+=" Statement";
	                dir="reports\\invoice\\";
	            }
                File f =FileTransfer.getFile(Utils.TMP_DIR, Utils.SERVER_DIR, fName);
                if (f.exists()) {
                    long fLen = f.length();
                    if (fLen>0) { 
                        (new ReportViewer(fName,title,v)).setVisible(true);            
                    }	    
                }
                else {
                    if (reportType.equals("SUMMARY")) {
                    	OutputStream out = FileTransfer.getOutputStream(Utils.SERVER_DIR + fName);
                    	if (out != null && out.toString().length() > 0) {
                			ReportViewer viewer = ReportViewer.create(out.toString(), title);
                			viewer.setVisible(true);
                        }
                		else {
                        	Utils.createErrMsg("Cannot locate report: "+fName); 
                		}
                    }
                }
            }
        }
	}
	
	void printAllCopies()
	{
        try  {

            String SQL = 
                "SELECT to_char(parent_account, '009'), TO_CHAR(practice,'009'), statement_copies \n"+
                "FROM pcs.practices ";
        	
//        	 String SQL = 
//                   "SELECT to_char(parent_account, '009'), TO_CHAR(practice,'009'), statement_copies \n"+
//                   "FROM pcs.practices  " + 
//                   "where parent_account  in (203)";

            if (reprintBox.isSelected()) {
            	SQL+=" WHERE parent_account >="+startPracticeNumber.getText()+"\n";   
            }
            SQL+=" WHERE parent_account = -1 \n";   
            SQL+=" ORDER BY ";
            if (!reportType.equals("STATEMENT")) SQL += "parent_account, practice \n";
            else SQL += "statement_copies,practice \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
            parent.setCursor(new Cursor(Cursor.WAIT_CURSOR));
            
            String tempParent = "" ; 
            boolean hasRecord = rs.next();
            int i = 0; 
			while (hasRecord) { 
				List<File> files = new ArrayList<File>();
				tempParent = rs.getString(1) ; 
				while (hasRecord && tempParent.equals(rs.getString(1)))  {

					tempParent = rs.getString(1);
					String prac = rs.getString(2).trim();

					int numCopies = rs.getInt(3);
					String fName = new String(prac + stmtMonth.getText()
							+ stmtYear.getText().substring(0, 1)
							+ stmtYear.getText().substring(2));
					Vector v = new Vector();
					if (reportType.equals("SUMMARY")) {
						fName = fName + ".sum";
						numCopies = 1;
					} else if (reportType.equals("PATIENT_CARD")) {
						fName = fName + ".pcd";
						numCopies = 1;
						v.addElement(Utils.COMPRESSED);
					}

					File printFile = FileTransfer.getFile(Utils.TMP_DIR,
							Utils.SERVER_DIR, fName);
					if (printFile != null) {
						files.add(printFile);
					}

					hasRecord = rs.next();
				}
				if (files.size() > 0) {
					byte[] bArr = Utils.concatenate(files, i++);
					Utils.dotMatrixPrint(bArr);
					double bytesTimesConstant = bArr.length * 2.1 ; 
					long sleepNumber = Math.round(bytesTimesConstant);
					Thread.sleep(sleepNumber) ; //Sleep for a minute to slow down printing
				}
			} 
			
            this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
            parent.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
        }
        catch( Exception e ) {
        	// If printer fails to start here.. Give it some time to recover and start again?
        	e.printStackTrace();
        	System.out.println(e+" printAllCopies"); 
        	
        }
		try { this.dispose(); } 
		catch (Exception e) { }
	}
	




	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == stmtMonth)
				stmtMonth_keyTyped(event);
			else if (object == stmtYear)
				stmtYear_keyTyped(event);
			else if (object == startPracticeNumber)
				practiceNumber_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == DocStmtDialog.this)
				DocStmtDialog_keyPressed(event);
			else if (object == stmtMonth)
				stmtMonth_keyPressed(event);
			else if (object == stmtYear)
				stmtYear_keyPressed(event);
			else if (object == startPracticeNumber)
				practiceNumber_keyPressed(event);
		}
	}

	void DocStmtDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_F9) {
		    this.dispose();
		}
		else if (event.getKeyCode()==event.VK_ESCAPE) {
		    startPracticeNumber.setText(null);
		    stmtMonth.setText(null);
		    stmtYear.setText(null);
		    startPracticeNumber.requestFocus();
		}
	}

	void stmtMonth_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(stmtMonth,"Month"))
		        stmtMonth.transferFocus();
		}
	}

	void stmtMonth_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,2);
	}

	void stmtYear_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
			
		    if (Utils.required(stmtYear,"Year"))
		    	if (Utils.isNull(startPracticeNumber.getText())) practice=0;
			    else practice=Integer.parseInt(startPracticeNumber.getText());
		        if (practice==0 || reprintBox.isSelected()) { 
		            if (verifyPrinter()) {
		            	printAllCopies();
		            }
		            this.dispose();
		        }
		        else {
		            viewReport();
		            this.dispose();
		        }
		}
	}

	void stmtYear_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,4);
	}

	void practiceNumber_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
            startPracticeNumber.transferFocus();
		}
	}

	void practiceNumber_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,3);
	}
	

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == DocStmtDialog.this)
				DocStmtDialog_windowOpened(event);
		}
	}

	void DocStmtDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		startPracticeNumber.requestFocus();
	}
	
	boolean verifyPrinter()
	{
	    boolean status = false;
	    String pType = null;
	    /*
	    if (isStatement) pType=stmtMonth.getText()+"/"+stmtYear.getText()+" statements ";
	    else pType=stmtYear.getText()+" summaries ";
	    */
	    if (reportType.equals("STATEMENT"))
	        pType=stmtMonth.getText()+"/"+stmtYear.getText()+" statements ";
	    else if (reportType.equals("SUMMARY"))
	        pType=stmtYear.getText()+" summaries ";
	    else if (reportType.equals("PATIENT_CARD"))
	        pType=stmtYear.getText()+" patient cards ";
		int rv = printerConfirm.showConfirmDialog(this,"Make sure printer is ready. \nPrint "+pType+"now?",
		    this.getTitle(),printerConfirm.YES_NO_OPTION,printerConfirm.QUESTION_MESSAGE);
		if (rv==printerConfirm.YES_OPTION) {
		    status=true;
		}
		return (status);
	}

	@Override
	public void queryActions() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void addActions() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void updateActions() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void finalActions() {
		System.out.println("Test");
		
	}

	@Override
	public void resetActions() {
		// TODO Auto-generated method stub
		
	}
	
}
