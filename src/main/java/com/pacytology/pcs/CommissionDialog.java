package com.pacytology.pcs;
/*
		A basic implementation of the JDialog class.
*/

import java.awt.*;
import javax.swing.*;

import java.sql.*;
import java.util.Vector;
import java.io.File;
import java.awt.event.KeyEvent;

public class CommissionDialog extends javax.swing.JDialog
{
    private String B_date;
    private String E_date;
    private int S_account;
    private String fileName;
    
	public CommissionDialog(Frame parent)
	{
		super(parent);
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Commission Report");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(236,140);
		setVisible(false);
		JLabel11.setText("Practice");
		getContentPane().add(JLabel11);
		JLabel11.setForeground(java.awt.Color.black);
		JLabel11.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel11.setBounds(20,16,56,14);
		getContentPane().add(practiceNumber);
		practiceNumber.setFont(new Font("SansSerif", Font.BOLD, 12));
		practiceNumber.setBounds(130,14,40,20);
		JLabel1.setText("Beginning");
		getContentPane().add(JLabel1);
		JLabel1.setForeground(java.awt.Color.black);
		JLabel1.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel1.setBounds(20,38,68,14);
		getContentPane().add(begin);
		begin.setFont(new Font("SansSerif", Font.BOLD, 12));
		begin.setBounds(130,36,80,20);
		JLabel2.setText("Ending");
		getContentPane().add(JLabel2);
		JLabel2.setForeground(java.awt.Color.black);
		JLabel2.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel2.setBounds(20,60,78,14);
		getContentPane().add(end);
		end.setFont(new Font("SansSerif", Font.BOLD, 12));
		end.setBounds(130,58,80,20);
		
		msgLabel.setText("Reporting period from Beginning date to Ending date, both inclusive");
		
		
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.blue);
		msgLabel.setFont(new Font("SansSerif", Font.BOLD, 12));
		msgLabel.setBounds(20,86,196,36);
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		practiceNumber.addKeyListener(aSymKey);
		begin.addKeyListener(aSymKey);
		end.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		this.addKeyListener(aSymKey);
		//}}
		
	}

	public CommissionDialog()
	{
		this((Frame)null);
	}

	public CommissionDialog(String sTitle)
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
		(new CommissionDialog()).setVisible(true);
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
	javax.swing.JLabel JLabel11 = new javax.swing.JLabel();
	javax.swing.JTextField practiceNumber = new javax.swing.JTextField();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JTextField begin = new javax.swing.JTextField();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JTextField end = new javax.swing.JTextField();
	JLabel msgLabel = new JLabel();
	//}}


	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == practiceNumber)
				practiceNumber_keyPressed(event);
			else if (object == begin)
				begin_keyPressed(event);
			else if (object == end)
				end_keyPressed(event);
			else if (object == CommissionDialog.this)
				CommissionDialog_keyPressed(event);
		}

		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == practiceNumber)
				practiceNumber_keyTyped(event);
			else if (object == begin)
				begin_keyTyped(event);
			else if (object == end)
				end_keyTyped(event);
		}
	}

	void practiceNumber_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,3);
	}

	void practiceNumber_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(practiceNumber,"Practice Account Number")) {
		        practiceNumber.setEnabled(false);
		        begin.setEnabled(true);
		        begin.requestFocus();
		    }
		}
	}

	void begin_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.buildDateMask(event);
	}

	void begin_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(begin,"Beginning Date")) {
		        if (Utils.dateVerify(begin)) {
		            begin.setEnabled(false);
		            end.setEnabled(true);
		            end.requestFocus();
		        }
		    }
		}
	}

	void end_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.buildDateMask(event);
	}

	void end_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(begin,"Ending Date")) {
		        if (Utils.dateVerify(end)) {
		            end.setEnabled(false);
		            msgLabel.requestFocus();
		            getReport();
		        }
		    }
		}
	}
	
	void getReport() 
	{
	    if (practiceNumber.getText().equals("0")) fileName="ADPH.asm";
        else fileName=practiceNumber.getText()+".asm";
	    formatInParams();
	    generateReport();
	    Vector printerCodes = new Vector();
	    printerCodes.addElement(Utils.CONDENSED);
        File f = new File("g:\\",fileName);
        if (f.exists()) {
            long fLen = f.length();
            if (fLen>0) { 
                (new ReportViewer(
                    fileName,this.getTitle(),printerCodes)).setVisible(true);            
                this.dispose();
            }	    
        }
		else { 
		    resetForm();
		    Utils.createErrMsg("Cannot locate report"); 
		}
	    
	}
	
	void formatInParams()
	{
	    S_account=(int)Integer.parseInt(practiceNumber.getText());
	    B_date=Utils.stripDateMask(begin.getText());
	    E_date=Utils.stripDateMask(end.getText());
	}

	void generateReport()
	{
        try  {
            CallableStatement cstmt;
	        cstmt=dbConnection.process().prepareCall(
	            "{call pcs.build_acct_summary_file(?,?,?)}");
            cstmt.setString(1,B_date);
            cstmt.setString(2,E_date);
            cstmt.setInt(3,S_account);
            cstmt.executeUpdate();
            try { cstmt.close(); }
            catch (SQLException e) { Utils.createErrMsg(e.toString()); }                
        }
        catch (Exception e) { Utils.createErrMsg(e.toString()); }
    }
	
	
	void clearForm()
	{
	    practiceNumber.setText(null);
	    begin.setText(null);
	    end.setText(null);
	}
	
	void setEnableAllFields(boolean eVal)
	{
	    practiceNumber.setEnabled(eVal);
	    begin.setEnabled(eVal);
	    end.setEnabled(eVal);
	}
	
	void resetForm()
	{
	    clearForm();
	    setEnableAllFields(false);
	    practiceNumber.setEnabled(true);
	    practiceNumber.requestFocus();
	}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowActivated(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == CommissionDialog.this)
				CommissionDialog_windowActivated(event);
		}
	}

	void CommissionDialog_windowActivated(java.awt.event.WindowEvent event)
	{
		resetForm();
	}

	void CommissionDialog_keyPressed( KeyEvent event)
	{
		int key = event.getKeyCode();
		switch (key) {
		    case KeyEvent.VK_F9:
		        this.dispose();
		        break;
		    case KeyEvent.VK_ESCAPE:
		        resetForm();
		        break;
		}
	}
	
}