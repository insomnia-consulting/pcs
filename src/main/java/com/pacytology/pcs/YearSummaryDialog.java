package com.pacytology.pcs;

import java.awt.*;
import javax.swing.*;
import java.io.File;
import java.io.OutputStream;
import java.sql.*;
import java.util.Vector;

public class YearSummaryDialog extends javax.swing.JDialog
{

    Login dbLogin;
    int practice=0;
    PCSLabEntry parent;
    
	public YearSummaryDialog(PCSLabEntry parent)
	{
		this.parent=parent;
		this.dbLogin=parent.dbLogin;
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Summary by Year");
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(187,85);
		setVisible(false);
		getContentPane().add(practiceNumber);
		practiceNumber.setFont(new Font("SansSerif", Font.PLAIN, 12));
		practiceNumber.setBounds(130,14,40,20);
		getContentPane().add(stmtYear);
		stmtYear.setFont(new Font("SansSerif", Font.PLAIN, 12));
		stmtYear.setBounds(130,36,40,20);
		JLabel11.setText("Practice");
		getContentPane().add(JLabel11);
		JLabel11.setForeground(java.awt.Color.black);
		JLabel11.setBounds(20,16,56,14);
		JLabel1.setText("Year (YYYY)");
		getContentPane().add(JLabel1);
		JLabel1.setForeground(java.awt.Color.black);
		JLabel1.setBounds(20,38,68,14);
		printerConfirm.setMessageType(javax.swing.JOptionPane.QUESTION_MESSAGE);
		//$$ printerConfirm.move(0,146);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setBounds(12,60,160,14);
		//}}
		
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		stmtYear.addKeyListener(aSymKey);
		practiceNumber.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		//}}
	}

	public YearSummaryDialog()	{	}

	public YearSummaryDialog(String sTitle)
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
		(new YearSummaryDialog()).setVisible(true);
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
	javax.swing.JTextField practiceNumber = new javax.swing.JTextField();
	javax.swing.JTextField stmtYear = new javax.swing.JTextField();
	javax.swing.JLabel JLabel11 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JOptionPane printerConfirm = new javax.swing.JOptionPane();
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	//}}


	void viewReport()
	{
	    if (Utils.isNull(practiceNumber.getText()) ||
	        Utils.isNull(stmtYear.getText())) {
	        Utils.createErrMsg("No Data Entered");
        }
        else {
	        if (practice>0) {
	            Vector printerCodes = new Vector();
	            printerCodes.addElement(Utils.CONDENSED);
	            String title = "Doctor Summary by Year";
	            String fName=stmtYear.getText()+practiceNumber.getText();
                fName=fName+".sby";
                OutputStream out = Export.getFile(Utils.SERVER_DIR + fName);
                if (out.toString().length()>0) { 
                	ReportViewer viewer = ReportViewer.create(out.toString(), "");
                	viewer.setVisible(true);

                }	    
		        else (new ErrorDialog("Cannot locate report")).setVisible(true); 
		        this.dispose();
            }
        }
	}
	
	void buildFile()
	{
        try  {
            CallableStatement cstmt;
	        cstmt=DbConnection.process().prepareCall(
	            "{call pcs.build_practice_summary_file(?,?)}");
            cstmt.setInt(1,Integer.parseInt(stmtYear.getText()));
            cstmt.setString(2,practiceNumber.getText());
            cstmt.executeUpdate();
        }
        catch( Exception e ) {System.out.println(e+" buildFile"); }
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == stmtYear)
				stmtYear_keyTyped(event);
			if (object == practiceNumber)
				practiceNumber_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == YearSummaryDialog.this)
				YearSummaryDialog_keyPressed(event);
			else if (object == stmtYear)
				stmtYear_keyPressed(event);
			if (object == practiceNumber)
				practiceNumber_keyPressed(event);
		}
	}

	void YearSummaryDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_F9) {
		    this.dispose();
		}
		else if (event.getKeyCode()==event.VK_ESCAPE) {
		    practiceNumber.setText(null);
		    stmtYear.setText(null);
		    practiceNumber.requestFocus();
		}
	}

	void stmtYear_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(stmtYear,"Year")) {
		        buildFile();
		        viewReport();
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
		    if (Utils.required(practiceNumber,"Practice"))
		        practiceNumber.transferFocus();
		        practice=Integer.parseInt(practiceNumber.getText());
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
			if (object == YearSummaryDialog.this)
				YearSummaryDialog_windowOpened(event);
		}
	}

	void YearSummaryDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		practiceNumber.requestFocus();
	}
	
	boolean verifyPrinter()
	{
	    boolean status = false;
	    String pType = null;
		int rv = printerConfirm.showConfirmDialog(this,"Make sure printer is ready. \nPrint "+pType+"now?",
		    this.getTitle(),printerConfirm.YES_NO_OPTION,printerConfirm.QUESTION_MESSAGE);
		if (rv==printerConfirm.YES_OPTION) {
		    status=true;
		}
		return (status);
	}
	
}
