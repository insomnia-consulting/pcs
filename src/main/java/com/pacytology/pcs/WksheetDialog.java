package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       WksheetDialog.java
    Created By: John Cardella, Software Engineer
    
    Function:   Form to create and print HM worksheets.
    
    MODIFICATIONS ----------------------------------------------------------------
    Date/Staff:   Description:
*/

import java.awt.*;
import javax.swing.*;
import java.sql.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

public class WksheetDialog extends javax.swing.JDialog
{
    private Login dbLogin;
    private int startLab;
    private int endLab;
    
	public WksheetDialog(Frame parent)
	{
		super(parent);
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("History Match Worksheet Copies");
		getContentPane().setLayout(null);
		setSize(245,71);
		setVisible(false);
		JLabel1.setText("Starting Lab Number");
		getContentPane().add(JLabel1);
		JLabel1.setForeground(java.awt.Color.black);
		JLabel1.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel1.setBounds(14,14,126,14);
		startingLab.setEnabled(false);
		getContentPane().add(startingLab);
		startingLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		startingLab.setBounds(138,12,90,20);
		JLabel2.setText("Ending Lab Number");
		getContentPane().add(JLabel2);
		JLabel2.setForeground(java.awt.Color.black);
		JLabel2.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel2.setBounds(14,38,126,14);
		endingLab.setEnabled(false);
		getContentPane().add(endingLab);
		endingLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		endingLab.setBounds(138,36,90,20);
		//$$ wksheetOption.move(0,72);
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		startingLab.addKeyListener(aSymKey);
		endingLab.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		this.addKeyListener(aSymKey);
		//}}
	}

	public WksheetDialog()
	{
		this((Frame)null);
	}

	public WksheetDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}

	public WksheetDialog(Login dbLogin)
	{
		this();
		this.dbLogin=dbLogin;
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(100,100);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new WksheetDialog()).setVisible(true);
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
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JTextField startingLab = new javax.swing.JTextField();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JTextField endingLab = new javax.swing.JTextField();
	javax.swing.JOptionPane wksheetOption = new javax.swing.JOptionPane();
	//}}
	
    void buildWorksheets() {
        try  {
            CallableStatement cstmt;
	        cstmt=dbConnection.process().prepareCall(
	            "{call pcs.build_hm_worksheet_copy(?,?)}");
	        cstmt.setInt(1,startLab);
	        cstmt.setInt(2,endLab);
            cstmt.executeUpdate();
            File f = new File("g:\\","copy_wks");
            long fLen = f.length();
            if (fLen>0) { 
                Utils.genericPrint("g:\\","copy_wks",false); 
                this.dispose();
            }
        }
        catch (Exception e) {  }
        
    }
    
	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == startingLab)
				startingLab_keyTyped(event);
			else if (object == endingLab)
				endingLab_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == startingLab)
				startingLab_keyPressed(event);
			else if (object == endingLab)
				endingLab_keyPressed(event);
			else if (object == WksheetDialog.this)
				WksheetDialog_keyPressed(event);
		}
	}

	void startingLab_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(startingLab,"Starting Lab")) {
		        startLab=(int)Integer.parseInt(startingLab.getText());
		        startingLab.transferFocus();
		    }
		}
	}

	void startingLab_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	void endingLab_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.isNull(endingLab.getText())) 
		        endLab=startLab;
		    else
		        endLab=(int)Integer.parseInt(endingLab.getText());
		    if (startLab>endLab) 
		        Utils.createErrMsg("Ending lab must be greater than starting lab");
		    else {
		        int rv = wksheetOption.showConfirmDialog(this,"Make sure printer is ready. \nPrint history match worksheets now?",
		            "History Match Worksheets",wksheetOption.YES_NO_OPTION,wksheetOption.QUESTION_MESSAGE);
		        if (rv==wksheetOption.YES_OPTION) {
		            this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
		            buildWorksheets();
		            this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
		            this.repaint();
		        }
		        else this.dispose();
		    }
		}
	}

	void endingLab_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == WksheetDialog.this)
				WksheetDialog_windowOpened(event);
		}
	}

	void WksheetDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		startingLab.setEnabled(true);
		endingLab.setEnabled(true);
		startingLab.requestFocus();
	}

	void WksheetDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_F9) this.dispose();
		else if (event.getKeyCode()==event.VK_ESCAPE) {
		    startingLab.setText(null);
		    endingLab.setText(null);
		    startingLab.setEnabled(true);
		    endingLab.setEnabled(true);
		    startingLab.requestFocus();
		}
	}

	
}