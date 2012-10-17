package com.pacytology.pcs;

/*
		A basic implementation of the JDialog class.
*/

import java.awt.*;
import javax.swing.*;

import com.pacytology.pcs.ui.PcsDialog;
import com.pacytology.pcs.ui.Square;
import java.sql.*;

public class SpecificRecvDateDialog extends PcsDialog
{
	public SpecificRecvDateDialog(Frame parent)
	{
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Specific Receive Date Range");
		getContentPane().setLayout(null);
		setSize(242,145);
		setVisible(false);
		JLabel1.setText("Starting Lab Number");
		getContentPane().add(JLabel1);
		JLabel1.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel1.setBounds(14,60,126,14);
		getContentPane().add(startingLab);
		startingLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		startingLab.setBounds(138,58,90,20);
		JLabel2.setText("Ending Lab Number");
		getContentPane().add(JLabel2);
		JLabel2.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel2.setBounds(14,86,126,14);
		getContentPane().add(endingLab);
		endingLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		endingLab.setBounds(138,84,90,20);
		JLabel3.setText("Date Received");
		getContentPane().add(JLabel3);
		JLabel3.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel3.setBounds(14,112,126,14);
		getContentPane().add(receiveDate);
		receiveDate.setFont(new Font("SansSerif", Font.BOLD, 12));
		receiveDate.setBounds(138,110,90,20);
		getContentPane().add(F1sq);
		F1sq.setBounds(25,6,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F9");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(29,6,20,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(77,6,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F12");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(79,6,20,20);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Exit");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,50,16);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Submit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(62,30,50,16);
		//}}
	
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		startingLab.addKeyListener(aSymKey);
		endingLab.addKeyListener(aSymKey);
		receiveDate.addKeyListener(aSymKey);
		this.addKeyListener(aSymKey);
		//}}
		
		this.actionMap = new SpecificRecvDateDialogActionMap(this);
		this.setupKeyPressMap();
	}
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();
		
		rp.getActionMap().put("F12", actionMap.finalAction);
		


		return rp;
	}
	public SpecificRecvDateDialog()
	{
		this((Frame)null);
	}

	public SpecificRecvDateDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}

	public void setVisible(boolean b)
	{
		if (b)
			setLocation(50, 50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new SpecificRecvDateDialog()).setVisible(true);
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
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JTextField receiveDate = new javax.swing.JTextField();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	//}}


	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == SpecificRecvDateDialog.this)
				SpecificRecvDateDialog_windowOpened(event);
		}
	}

	void SpecificRecvDateDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		startingLab.requestFocus();
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
			else if (object == receiveDate)
				receiveDate_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == startingLab)
				startingLab_keyPressed(event);
			else if (object == endingLab)
				endingLab_keyPressed(event);
			else if (object == receiveDate)
				receiveDate_keyPressed(event);
		}
	}

	void startingLab_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(startingLab,"Starting Lab Number")) 
		        startingLab.transferFocus();
		}
	}

	void startingLab_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,10);
	}

	void endingLab_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
            endingLab.setText(
            Utils.isNull(endingLab.getText(),startingLab.getText()));	        
	        int end = Integer.parseInt(endingLab.getText());
	        int start = Integer.parseInt(startingLab.getText());
	        if (start>end) {
	            Utils.createErrMsg("Starting lab must be less then ending");
	            endingLab.setText(null);
	            endingLab.requestFocus();
	            return;
            }
		    endingLab.transferFocus();
	    }
	}

	void endingLab_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,10);
	}

	void receiveDate_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
	        if (Utils.required(receiveDate,"Date Received")) {
	            if (Utils.dateVerify(receiveDate)) {
	                if (canUpdate()) updateReceiveDates();
	                else clearAll();
	            }
	        }
	    }
	}

	void receiveDate_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.buildDateMask(event);
	}

	
	
	void clearAll() 
	{
	    startingLab.setText(null);
		endingLab.setText(null);
		receiveDate.setText(null);
		startingLab.requestFocus();
	}
	
	boolean canUpdate()
	{
	    boolean confirm = false;
	    JOptionPane confirmRecvDateChange = new javax.swing.JOptionPane();
	    int rv = confirmRecvDateChange.showConfirmDialog(
	        this,"Change receive date for lab numbers \n"+startingLab.getText()+
	        " to "+endingLab.getText()+" to "+receiveDate.getText()+"? "+
	        "\nThis OVERRIDES daily receive dates.",
	        "Confirm Receive Date Change",confirmRecvDateChange.YES_NO_OPTION,
	        confirmRecvDateChange.QUESTION_MESSAGE);
	    if (rv==confirmRecvDateChange.YES_OPTION) confirm=true;
	    return (confirm);
	}
	
	void updateReceiveDates()
	{
        setCursor(new java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
	    try {
	        int end = Integer.parseInt(endingLab.getText());
	        int start = Integer.parseInt(startingLab.getText());
	        String SQL = 
	            "UPDATE pcs.lab_requisitions \n"+
	            "SET receive_date = TO_DATE(?,'MM/DD/YYYY') \n"+
	            "WHERE lab_number >= ? \n"+
	            "AND lab_number <= ? \n";
	        PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
	        pstmt.setString(1,receiveDate.getText());
	        pstmt.setInt(2,start);
	        pstmt.setInt(3,end);
	        pstmt.executeUpdate();
	    }
	    catch (SQLException e) { 
	        System.out.println(e); 
	        setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
        }
        setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
        clearAll();
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
		// TODO Auto-generated method stub
		
	}
	@Override
	public void resetActions() {
		// TODO Auto-generated method stub
		
	}
	
}
