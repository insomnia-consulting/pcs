package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       UnfinishDialog.java
    Created By: John Cardella, Software Engineer
    
    Function:   This class is used to change the
    lab status from finished to unfinished. If the
    inparam boolean recalcuate is true then the
    screen doubles with the option to redo the
    charges on the lab.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import javax.swing.*;
import java.sql.*;
import java.util.Vector;
import com.pacytology.pcs.ui.Square;

public class UnfinishDialog extends javax.swing.JDialog
{
    LogFile log;
    final int UNFINISH = 100;
    final int RECALC = 200;
    int mode;
    
	public UnfinishDialog()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Lab Number");
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(230,118);
		setVisible(false);
		JLabel11.setText("Enter Lab Number:");
		getContentPane().add(JLabel11);
		JLabel11.setForeground(java.awt.Color.black);
		JLabel11.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel11.setBounds(20,16,110,14);
		getContentPane().add(labNumber);
		labNumber.setFont(new Font("SansSerif", Font.BOLD, 12));
		labNumber.setBounds(130,14,80,20);
		getContentPane().add(messageText);
		messageText.setForeground(java.awt.Color.blue);
		messageText.setFont(new Font("Dialog", Font.BOLD, 12));
		messageText.setBounds(20,40,196,68);
		//}}
		
		labNumber.setDisabledTextColor(Color.black);
		
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		labNumber.addKeyListener(aSymKey);
		//}}
	}
	
	public UnfinishDialog(boolean recalculate)
	{
	    this();
	    if (recalculate) {
	        mode=RECALC;
	        this.setTitle("Recalculate Charges");
            this.log = new LogFile(
                dbConnection.getLogPath(),"UnfinishDialog.Recalc.",
                dbConnection.getDate(),dbConnection.getUser());
	        log.write("Recalculate Charges");
	        try {
	            messageText.setText("Charges for this lab number "+
	                "will be recalculated and, if applicable, the "+
	                "lab will be placed into the billing queue.");
	        }
	        catch (Exception e) { log.write(e); }
	    }
	    else {
	        mode=UNFINISH;
	        this.setTitle("Unfinalize Lab Number");
            this.log = new LogFile(
                dbConnection.getLogPath(),"UnfinishDialog",
                dbConnection.getDate(),dbConnection.getUser());
	        log.write("Unfinalize Lab Number");
	        try {
	            messageText.setText("The status of this lab number "+
	                "will be updated to unfinished.");
	        }
	        catch (Exception e) { log.write(e); }
	    }
	}
	
	// old usage
	public UnfinishDialog(Login dbLogin)
	{
	    this();
        this.log = new LogFile(
            dbLogin.logPath,"UnfinishDialog",
            dbLogin.dateToday,dbLogin.userName);
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(50,50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new UnfinishDialog()).setVisible(true);
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
	javax.swing.JTextField labNumber = new javax.swing.JTextField();
	JLabel messageText = new JLabel();
	//}}


	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == UnfinishDialog.this)
				UnfinishDialog_windowClosing(event);
		}

		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == UnfinishDialog.this)
				UnfinishDialog_windowOpened(event);
		}
	}

	void UnfinishDialog_windowOpened(java.awt.event.WindowEvent event)
	{
        labNumber.requestFocus();
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == labNumber)
				labNumber_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == UnfinishDialog.this)
				UnfinishDialog_keyPressed(event);
			else if (object == labNumber)
				labNumber_keyPressed(event);
		}
	}

	void UnfinishDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_F9) closingActions();
	}

	void labNumber_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	void labNumber_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(labNumber,"Lab Number")) {
		        int LN = Integer.parseInt(labNumber.getText());
		        log.write("ACTIONS BEING PERFORMED ON LAB NUMBER "+LN);
		        if (mode==UNFINISH) unfinishActions(LN);
		        else if (mode==RECALC) recalcActions(LN);
		    }
            labNumber.setText(null);
		    labNumber.requestFocus();
		    //else closingActions();
		}
	}
	
	void unfinishActions(int LN)
	{
	    int finished = getStatus(LN); 
		if (finished==4) {
		    log.write("Attempting to UNFINISH Lab #"+labNumber.getText());
		    unfinishLab(LN);
		}
		else {
            String msg = "Lab #"+labNumber.getText()+" is already Unfinalized. "+
                "Set status to FINISHED?\n";
	        JOptionPane confirm = new javax.swing.JOptionPane();
	        Object[] options = {"YES","NO"};
            int rv = confirm.showOptionDialog(
		        null,msg,
		        "Set Lab to FINISH",confirm.DEFAULT_OPTION,
		        confirm.QUESTION_MESSAGE,null,options,options[1]);
            if (rv==confirm.YES_OPTION) {
                finishLab(LN);
            }
            //else closingActions();
		}
	}
	
	void recalcActions(int LN)
	{
	    int finished = getStatus(LN); 
		if (finished==4) {
		    log.write("ERROR: calculateCost on finished lab ["+LN+"]");
		    Utils.createErrMsg("Cannot do recalculate on FINISHED lab!");
		}
		else {
            String msg = "Recalculate charges on Lab #"+LN+"\n"+
                "and place in Billing Queue?\n";
	        JOptionPane confirm = new javax.swing.JOptionPane();
	        Object[] options = {"YES","NO"};
            int rv = confirm.showOptionDialog(
		        null,msg,
		        "Recalculate Charges",confirm.DEFAULT_OPTION,
		        confirm.QUESTION_MESSAGE,null,options,options[1]);
            if (rv==confirm.YES_OPTION) {
                calculateCost(LN);
            }
            //else closingActions();
		}
	}

    void finishLab(int LN) {
        PreparedStatement pstmt = null;
        try  {
            String SQL =
                "UPDATE pcs.lab_requisitions SET \n"+
                "   finished=4 WHERE lab_number = ? \n";
            pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,LN);
            pstmt.executeUpdate();
            log.write("SET pcs.lab_requisitions.finished=4 for "+LN);
            try { pstmt.close(); }
            catch (SQLException e) { log.write("finishLab("+LN+")\n"+e); }                
            catch (Exception e) { log.write("finishLab("+LN+")\n"+e); }
            
            SQL =
                "UPDATE pcs.lab_billings SET date_paid=SysDate \n"+
                "WHERE lab_number = ? \n";
            pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,LN);
            pstmt.executeUpdate();
            try { pstmt.close(); }
            catch (SQLException e) { log.write("finishLab("+LN+")\n"+e); }                
            catch (Exception e) { log.write("finishLab("+LN+")\n"+e); }
            
            SQL =
                "DELETE FROM pcs.billing_queue \n"+
                "WHERE lab_number = ? \n";
            pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,LN);
            pstmt.executeUpdate();
            log.write("DELETE "+LN+" from pcs.billing_queue");
            try { pstmt.close(); }
            catch (SQLException e) { log.write("finishLab("+LN+")\n"+e); }                
            catch (Exception e) { log.write("finishLab("+LN+")\n"+e); }
            
        }
        catch (SQLException e) { log.write("finishLab("+LN+")\n"+e); }
        catch (Exception e) { log.write("finishLab("+LN+")\n"+e); }
        //finally { closingActions(); }
    }
    
    void unfinishLab(int LN) {
        PreparedStatement pstmt = null;
        int finished = 0;
        if (getBillingChoice(LN)==Lab.PPD) finished=1;
        else finished=3;
        try  {
            String SQL =
                "UPDATE pcs.lab_requisitions SET \n"+
                "   finished=? WHERE lab_number = ? \n";
            pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,finished);
            pstmt.setInt(2,LN);
            pstmt.executeUpdate();
            log.write("SET pcs.lab_requisitions.finished=3 for "+LN);
            try { pstmt.close(); }
            catch (SQLException e) { log.write("unfinishLab("+LN+")\n"+e); }                
            catch (Exception e) { log.write("unfinishLab("+LN+")\n"+e); }
            
            SQL =
                "UPDATE pcs.lab_billings SET date_paid=NULL \n"+
                "WHERE lab_number = ? \n";
            pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,LN);
            pstmt.executeUpdate();
            try { pstmt.close(); }
            catch (SQLException e) { log.write("unfinishLab("+LN+")\n"+e); }                
            catch (Exception e) { log.write("unfinishLab("+LN+")\n"+e); }
        }
        catch (SQLException e) { log.write("unfinishLab("+LN+")\n"+e); }
        catch (Exception e) { log.write("unfinishLab("+LN+")\n"+e); }
        //finally { closingActions(); }
    }

    void calculateCost(int LN) {
        try {
            CallableStatement cstmt;
            cstmt=dbConnection.process().prepareCall(
                "{call pcs.calculate_cost(?)}");
            cstmt.setInt(1,LN);
            cstmt.executeUpdate();
            cstmt.close();
        }
        catch (SQLException e) { log.write("calculateCost("+LN+")\n"+e); }
        catch (Exception e) { log.write("calculateCost("+LN+")\n"+e); }
        //finally { closingActions(); }
    }
    
    int getStatus(int LN) 
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int status = 0;
        try  {
            String SQL =
                "SELECT finished FROM pcs.lab_requisitions \n"+
                "WHERE lab_number = ? \n";
            pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,LN);
            rs=pstmt.executeQuery(SQL);
            while (rs.next()) { status = rs.getInt(1); }
            try { rs.close(); pstmt.close(); }
            catch (SQLException e) { log.write("getStatus("+LN+")\n"+e); }                
            catch (Exception e) { log.write("getStatus("+LN+")\n"+e); }
        }
        catch (SQLException e) { log.write("getStatus("+LN+")\n"+e); }
        catch (Exception e) { log.write("getStatus("+LN+")\n"+e); }
        return(status);
    }

    int getBillingChoice(int LN) 
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int billing_choice = 0;
        try  {
            String SQL =
                "SELECT billing_choice FROM pcs.lab_requisitions \n"+
                "WHERE lab_number = ? \n";
            pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,LN);
            rs=pstmt.executeQuery(SQL);
            while (rs.next()) { billing_choice = rs.getInt(1); }
            try { rs.close(); pstmt.close(); }
            catch (SQLException e) { log.write("getBillingChoice("+LN+")\n"+e); }                
            catch (Exception e) { log.write("getBillingChoice("+LN+")\n"+e); }
        }
        catch (SQLException e) { log.write("getBillingChoice("+LN+")\n"+e); }
        catch (Exception e) { log.write("getBillingChoice("+LN+")\n"+e); }
        return(billing_choice);
    }

	void UnfinishDialog_windowClosing(java.awt.event.WindowEvent event)
	{
		closingActions();
	}
	
	void closingActions()
	{
	    log.stop();
	    this.dispose();
	}
	
}
