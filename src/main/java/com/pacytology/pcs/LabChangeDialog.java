package com.pacytology.pcs;
/*
		A basic implementation of the JDialog class.
*/

import java.awt.Dimension;
import java.awt.Font;
import java.awt.Frame;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.sql.CallableStatement;
import java.sql.SQLException;
import javax.swing.*;

import com.pacytology.pcs.ui.PcsDialog;
import com.pacytology.pcs.ui.PcsFrame;
import com.pacytology.pcs.ui.Square;


public class LabChangeDialog extends PcsDialog
{
    final int HPV = 101;
    final int BIOPSY = 102;
    final int PAP = 103;
    final int UPDATE_LINK = 104;
    int mode = PAP; 
    int previous_lab = 0;
    
	public LabChangeDialog(PcsFrame parent)
	{

		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Lab Number Correction");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(500,241);
		setVisible(false);
		badLabNumLbl.setRequestFocusEnabled(false);
		badLabNumLbl.setText("INCORRECT Lab Number");
		getContentPane().add(badLabNumLbl);
		badLabNumLbl.setBounds(20,78,170,14);
		getContentPane().add(badLabNumber);
		badLabNumber.setFont(new Font("DialogInput", Font.PLAIN, 12));
		badLabNumber.setBounds(200,76,80,20);
		goodLabNumLbl.setRequestFocusEnabled(false);
		goodLabNumLbl.setText("CORRECT Lab Number");
		getContentPane().add(goodLabNumLbl);
		goodLabNumLbl.setBounds(20,100,170,14);
		getContentPane().add(goodLabNumber);
		goodLabNumber.setFont(new Font("DialogInput", Font.PLAIN, 12));
		goodLabNumber.setBounds(200,98,80,20);
		getContentPane().add(F1sq);
		F1sq.setBounds(25,4,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F9");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(29,4,20,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(87,4,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F12");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(88,4,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Submit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(62,28,70,16);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Exit");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(0,28,70,18);

		warningMessage.setText("WARNING!!!  All instances in the Oracle Database of the INCORRECT Lab Number will be replaced with the CORRECT Lab Number.  It is recommended that the user of the system be sure of the desired results before submitting the change.");

		getContentPane().add(warningMessage);
		warningMessage.setForeground(java.awt.Color.red);
		warningMessage.setFont(new Font("Dialog", Font.BOLD, 12));
		warningMessage.setBounds(24,130,464,96);
		updateLink.setText("Change Previous Lab Number (Link)");
		getContentPane().add(updateLink);
		updateLink.setBounds(20,50,320,20);
		//}}
	
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		badLabNumber.addKeyListener(aSymKey);
		goodLabNumber.addKeyListener(aSymKey);
		this.addKeyListener(aSymKey);
		SymAction lSymAction = new SymAction();
		updateLink.addActionListener(lSymAction);
		//}}
		actionMap = new LabChangeDialogActionMap(this) ;
		this.setupKeyPressMap();
		resetForm();
	}
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();


		rp.getActionMap().put("F12", new AbstractAction() { 
			public void actionPerformed(ActionEvent e) { 
                if (warningMessage.isVisible()) {
                    int old = 0;
                    if (mode==HPV) old=HPV;
                    else if (mode==BIOPSY) old=BIOPSY;
                    if (mode==PAP) {
                        old=(int)Integer.parseInt(badLabNumber.getText());
		                makeCorrection(
		                    old,(int)Integer.parseInt(goodLabNumber.getText()));
		            }
                    else if (mode==HPV || mode==BIOPSY) {
		                makeCorrection(
			                    old,(int)Integer.parseInt(goodLabNumber.getText()));
                    }
		            else {
		                old=(int)Integer.parseInt(badLabNumber.getText());
		                DbConnection.updatePreviousLab(old,previous_lab);
		            }
		            resetForm();
		        }
		        else Utils.createErrMsg(
		            "Must press ENTER to verify correct lab does not exist");
			}
		});	
		return rp;
	}		
	public LabChangeDialog()
	{
		this((PcsFrame)null);
	}

	public LabChangeDialog(String sTitle)
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
		(new LabChangeDialog()).setVisible(true);
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
	javax.swing.JLabel badLabNumLbl = new javax.swing.JLabel();
	javax.swing.JTextField badLabNumber = new javax.swing.JTextField();
	javax.swing.JLabel goodLabNumLbl = new javax.swing.JLabel();
	javax.swing.JTextField goodLabNumber = new javax.swing.JTextField();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	JLabel warningMessage = new JLabel();
	javax.swing.JCheckBox updateLink = new javax.swing.JCheckBox();
	//}}


	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == LabChangeDialog.this)
				labChangeDialog_windowOpened(event);
		}
	}

	void labChangeDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		badLabNumber.requestFocus();
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == badLabNumber)
				badLabNumber_keyPressed(event);
			else if (object == goodLabNumber)
				goodLabNumber_keyPressed(event);
			else if (object == LabChangeDialog.this)
				labChangeDialog_keyPressed(event);
		}

		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == badLabNumber)
				badLabNumber_keyTyped(event);
			else if (object == goodLabNumber)
				goodLabNumber_keyTyped(event);
		}
	}

	void badLabNumber_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}

    
	void badLabNumber_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(badLabNumber,"MISSING Lab Number or Code")) {
		        if (badLabNumber.getText().equals("HPV")) {
		            mode=HPV;
		            badLabNumber.transferFocus();
		        }
		        else if (badLabNumber.getText().equals("BIOPSY")) {
		            mode=BIOPSY;
		            badLabNumber.transferFocus();
		        }
		        else if (mode==PAP || mode==UPDATE_LINK) {
		            try {
		                int labNum=(int)Integer.parseInt(badLabNumber.getText());
		                if (!verifyLabNumber(labNum)) {
		                    Utils.createErrMsg(
		                        "Lab #"+badLabNumber.getText()+" does not exist");
		                    badLabNumber.setText(null);  
		                }
		            }
		            catch (Exception e) {
                        Utils.createErrMsg(
		                    "Enter code HPV or BIOPSY or a Lab Number");
		                resetForm();
		            }
		            if (mode==UPDATE_LINK) {
		                previous_lab=DbConnection.getPreviousLab(
		                    (int)Integer.parseInt(badLabNumber.getText()));
		            }
		            badLabNumber.transferFocus();
		        }
		        else if (mode!=HPV || mode!=BIOPSY || mode!=UPDATE_LINK) {
                    Utils.createErrMsg(
		                "Enter code HPV or BIOPSY or a Lab Number");
		            badLabNumber.setText(null);  
		        }
		    }
		}
	}

	void goodLabNumber_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	void goodLabNumber_keyPressed(java.awt.event.KeyEvent event)
	{
	    boolean labNumberExists=false;
        String msg = null;
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (mode==UPDATE_LINK) updatePrevious();
		    else if (Utils.required(goodLabNumber,"CORRECT Lab Number")) {
		        labNumberExists=verifyLabNumber(
		            (int)Integer.parseInt(goodLabNumber.getText())); 
		        if (verifyLabNumber(
		            (int)Integer.parseInt(goodLabNumber.getText()))) { 
		        	if (mode==HPV) {
		        		warningMessage.setText("WARNING!! Starting lab number for HPV already exists."); 
		        	}
		        	else if (mode==BIOPSY) {
		        		warningMessage.setText("WARNING!! Starting lab number for BIOPSY already exists."); 
		        	}
		            warningMessage.setVisible(true);
		        }
		        else {
		            if (mode==HPV)
		                msg="WARNING!!!  Next lab number for HPV ONLY will be set to "+goodLabNumber.getText();
		            else if (mode==BIOPSY)
		                msg="WARNING!!!  Next lab number for SURGICAL BIOPSY will be set to "+goodLabNumber.getText();
		            if (mode==HPV || mode==BIOPSY) {
		                warningMessage.setText(msg);
		            }
		            warningMessage.setVisible(true); 
		        }
		    }
		}
	}
	
	void updatePrevious()
	{
	    String msg = null;
        if (!Utils.isNull(goodLabNumber.getText())) {
            if (previous_lab==0) {
                msg="WARNING!!  Previous lab number for "+badLabNumber.getText()+
                    " will be set to "+goodLabNumber.getText()+".  Prior to this a "+
                    "previous was not entered.";
            }
		    else msg="WARNING!!!  Previous lab number for "+badLabNumber.getText()+
		        " will be changed from "+previous_lab+" to "+goodLabNumber.getText();
		    previous_lab=(int)Integer.parseInt(goodLabNumber.getText()); 
        }
		else {
		    String s = (new Integer(previous_lab)).toString();
		    goodLabNumber.setText(s);
		    goodLabNumber.setEnabled(false);
		    goodLabNumber.setEditable(false);
		    updateLink.requestFocus();
		    msg="WARNING!!!  Previous lab number for "+badLabNumber.getText()+
		        " will be removed.";
		    previous_lab=0;
		}
		warningMessage.setText(msg);
		warningMessage.setVisible(true);
	}
	
	boolean verifyLabNumber(int labNum)
	{
	    boolean labNumberExists = false;
	    int count = 
	        DbConnection.getRowCount("pcs.lab_requisitions","lab_number="+labNum);
	    if (count>0) labNumberExists=true;
	    return (labNumberExists);
	}
	
	void makeCorrection(int oldLab, int newLab)
	{
        try {
            CallableStatement cstmt=DbConnection.process().prepareCall(
                "{call pcs.change_lab_number(?,?)}");
            cstmt.setInt(1,oldLab);
            cstmt.setInt(2,newLab);
            cstmt.executeUpdate();
            cstmt.close();
        }
        catch (SQLException e) {
        	e.printStackTrace();
        }
        catch (Exception e) { }
	}
	
	void resetForm()
	{
	    resetColors();
	    mode=PAP;
	    previous_lab=0;
	    badLabNumber.setText(null);
	    goodLabNumber.setText(null);
	    badLabNumLbl.setText("INCORRECT Lab Number");
	    goodLabNumLbl.setText("CORRECT Lab Number");
	    goodLabNumber.setEnabled(true);
	    goodLabNumber.setEditable(true);
	    badLabNumber.requestFocus();
	    updateLink.setSelected(false);
	    this.setTitle("Lab Number Correction");
	    warningMessage.setVisible(false);
	}
	
	void resetColors() {
        Utils.setColors(this.getContentPane());
    }

	void labChangeDialog_keyPressed(KeyEvent event)
	{
		int key = event.getKeyCode();
		switch (key) {
		    case KeyEvent.VK_ESCAPE:
		        resetForm();
		        break;
		}
	}
	
	void closingActions() { this.dispose(); }

	class SymAction implements java.awt.event.ActionListener
	{
		public void actionPerformed(java.awt.event.ActionEvent event)
		{
			Object object = event.getSource();
			if (object == updateLink)
				updateLink_actionPerformed(event);
		}
	}

	void updateLink_actionPerformed(java.awt.event.ActionEvent event)
	{
	    if (updateLink.isSelected()) {
            badLabNumLbl.setText("This Lab Number:");
		    goodLabNumLbl.setText("CORRECT Previous Lab#");
		    this.setTitle("Previous Lab# - FIX LINK");
		    mode=UPDATE_LINK;
		    badLabNumber.requestFocus();
	    }
		else resetForm();
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
