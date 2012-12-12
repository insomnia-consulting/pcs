package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       DailyReptDialog.java
    Created By: John Cardella, Software Engineer
    
    Function:   Dialog box to request a daily report.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.OutputStream;

import com.pacytology.pcs.io.FileTransfer;

public class DailyReptDialog extends javax.swing.JDialog
{

	public DailyReptDialog()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Daily Reports");
		setResizable(false);
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(187,93);
		setVisible(false);
		getContentPane().add(stmtMonth);
		stmtMonth.setFont(new Font("SansSerif", Font.BOLD, 12));
		stmtMonth.setBounds(130,14,40,20);
		getContentPane().add(stmtDay);
		stmtDay.setFont(new Font("SansSerif", Font.BOLD, 12));
		stmtDay.setBounds(130,36,40,20);
		getContentPane().add(stmtYear);
		stmtYear.setFont(new Font("SansSerif", Font.BOLD, 12));
		stmtYear.setBounds(130,58,40,22);
		JLabel1.setText("Month (MM)");
		getContentPane().add(JLabel1);
		JLabel1.setForeground(java.awt.Color.black);
		JLabel1.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel1.setBounds(20,16,68,14);
		JLabel2.setText("Year (YYYY)");
		getContentPane().add(JLabel2);
		JLabel2.setForeground(java.awt.Color.black);
		JLabel2.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel2.setBounds(20,60,78,14);
		JLabel3.setText("Day (DD)");
		getContentPane().add(JLabel3);
		JLabel3.setForeground(java.awt.Color.black);
		JLabel3.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel3.setBounds(20,38,68,14);
		//}}
		
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		stmtMonth.addKeyListener(aSymKey);
		stmtYear.addKeyListener(aSymKey);
		stmtDay.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		//}}
	}

	public DailyReptDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public void setVisible(boolean b)
	{
		if (b)setLocation(50,50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new DailyReptDialog()).setVisible(true);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted) return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets
		Insets insets = getInsets();
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	//{{DECLARE_CONTROLS
	javax.swing.JTextField stmtMonth = new javax.swing.JTextField();
	javax.swing.JTextField stmtDay = new javax.swing.JTextField();
	javax.swing.JTextField stmtYear = new javax.swing.JTextField();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	//}}

	void viewReport()
	{
	    if (Utils.isNull(stmtMonth.getText()) ||
	        Utils.isNull(stmtYear.getText())) {
	        Utils.createErrMsg("No Data Entered");
        }
        else {
                String fName = stmtYear.getText()+stmtMonth.getText()+stmtDay.getText()+".dwr";
                OutputStream out = FileTransfer.getOutputStream(Utils.SERVER_DIR + fName);
                if (out != null && out.toString().length() > 0) {
        			ReportViewer viewer = ReportViewer.create(out.toString(), "Daily Summary Report");
        			viewer.setVisible(true);
                }
        		else {
                	Utils.createErrMsg("Cannot locate report: "+fName); 
        		}
        }
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
			else if (object == stmtDay)
				stmtDay_keyTyped(event);
			
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == DailyReptDialog.this)
				DailyReptDialog_keyPressed(event);
			else if (object == stmtMonth)
				stmtMonth_keyPressed(event);
			else if (object == stmtYear)
				stmtYear_keyPressed(event);
			else if (object == stmtDay)
				stmtDay_keyPressed(event);
			
		}
	}
	
	private void keyActions(java.awt.event.KeyEvent event)
	{
	    int key = event.getKeyCode();
	    switch (key) {
		    case KeyEvent.VK_F9:
		        this.dispose();
		        break;
		    case KeyEvent.VK_ESCAPE:
		        stmtMonth.setText(null);
		        stmtDay.setText(null);
		        stmtYear.setText(null);
		        stmtMonth.requestFocus();
		        break;
	    }
	}

	void DailyReptDialog_keyPressed(java.awt.event.KeyEvent event)
	{
	    keyActions(event);
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
		        viewReport();
		        this.dispose();
		}
	}

	void stmtYear_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,4);
	}
	

	void stmtDay_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(stmtDay,"Day"))
		        stmtDay.transferFocus();
		}
	}

	void stmtDay_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,2);
	}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == DailyReptDialog.this)
				DailyReptDialog_windowOpened(event);
		}
	}

	void DailyReptDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		stmtMonth.requestFocus();
	}
	
}
