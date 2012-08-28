package com.pacytology.pcs;

/*
		A basic implementation of the JDialog class.
*/

import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.awt.event.KeyEvent;
import java.io.OutputStream;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.text.MessageFormat;

public class LabStatusDialog extends javax.swing.JDialog
{
    String fileName;
	public LabStatusDialog()
	{
		//super(parent);
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Lab Status Report");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(267,119);
		setVisible(false);
		JLabel11.setText("Starting Lab Number:");
		getContentPane().add(JLabel11);
		JLabel11.setForeground(java.awt.Color.black);
		JLabel11.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel11.setBounds(20,16,130,14);
		getContentPane().add(startLab);
		startLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		startLab.setBounds(160,14,80,20);
		JLabel1.setText("Ending Lab Number:");
		getContentPane().add(JLabel1);
		JLabel1.setForeground(java.awt.Color.black);
		JLabel1.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel1.setBounds(20,42,130,14);
		getContentPane().add(endLab);
		endLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		endLab.setBounds(160,40,80,20);
		msgLabel.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		msgLabel.setText("Generating Report - Please Wait");
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.blue);
		msgLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		msgLabel.setBounds(10,94,240,14);
		printButton.setText("PRINT");
		printButton.setEnabled(false);
		getContentPane().add(printButton);
		printButton.setBounds(160,66,80,20);
		//}}
		
		msgLabel.setText(null);
	
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		startLab.addKeyListener(aSymKey);
		endLab.addKeyListener(aSymKey);
		SymAction lSymAction = new SymAction();
		printButton.addActionListener(lSymAction);
		this.addKeyListener(aSymKey);
		//}}
	}

	public LabStatusDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(50, 50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new LabStatusDialog()).setVisible(true);
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
	javax.swing.JTextField startLab = new javax.swing.JTextField();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JTextField endLab = new javax.swing.JTextField();
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	javax.swing.JButton printButton = new javax.swing.JButton();
	//}}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == LabStatusDialog.this)
				LabStatusDialog_windowOpened(event);
		}
	}

	void LabStatusDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		startLab.requestFocus();
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == startLab)
				startLab_keyPressed(event);
			else if (object == endLab)
				endLab_keyPressed(event);
			else if (object == LabStatusDialog.this)
				LabStatusDialog_keyPressed(event);
		}

		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == startLab)
				startLab_keyTyped(event);
			else if (object == endLab)
				endLab_keyTyped(event);
		}
	}

	void startLab_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	void startLab_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(startLab,"Starting Lab Number")) {
		        fileName=startLab.getText().substring(2)+".bsr";
		        endLab.requestFocus();
		    }
		}
	}

	void endLab_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	void endLab_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (!Utils.isNull(endLab.getText())) {
                int low = Integer.parseInt(startLab.getText());
                int high = Integer.parseInt(endLab.getText());
                if (high<low) {
                    Utils.createErrMsg(
                        "Start Lab must be LESS than End Lab");
                    resetForm();
                }
                else {
				    this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
                    msgLabel.setText("Generating Report - Please Wait");
		            createReport(low,high);
          		    this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
		            msgLabel.setText("Make sure paper is ready before printing");
		            printButton.setEnabled(true);
		            printButton.requestFocus();
		        }
		    }
            else {
		        msgLabel.setText("Make sure paper is ready before printing");
		        printButton.setEnabled(true);
		        printButton.requestFocus();
            }
		}
	}

	class SymAction implements java.awt.event.ActionListener
	{
		public void actionPerformed(java.awt.event.ActionEvent event)
		{
			Object object = event.getSource();
			if (object == printButton)
				printButton_actionPerformed(event);
		}
	}

	void printButton_actionPerformed(java.awt.event.ActionEvent event)
	{
		printReport();
	}
	
	void resetForm()
	{
	    startLab.setText(null);
	    endLab.setText(null);
	    msgLabel.setText(null);
	    startLab.requestFocus();
	    printButton.setEnabled(false);
	}
	
	void createReport(int start, int end)
	{
        msgLabel.setText("Generating Report - Please Wait");
        try  {
            CallableStatement cstmt;
	        cstmt=DbConnection.process().prepareCall(
	            "{call pcs.analyze_activity(?,?)}");
            cstmt.setInt(1,start);
            cstmt.setInt(2,end);
            cstmt.executeUpdate();
            cstmt.close();
        }
        catch (SQLException e) { 
            System.out.println(e);
        }                
        catch( Exception e ) {
            System.out.println(e);
        }
	}
	
	void printReport()
	{
		OutputStream out = Export.getFile(Utils.SERVER_DIR+fileName);
	    Utils.genericPrint(out.toString(), new MessageFormat(""), new MessageFormat(""));
	}

	void LabStatusDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		int key = event.getKeyCode();
		switch (key) {
		    case KeyEvent.VK_ESCAPE: resetForm(); break;
		    case KeyEvent.VK_F9: closingActions(); break;
		}
	}
	
	void closingActions() { this.dispose(); }
	
}
