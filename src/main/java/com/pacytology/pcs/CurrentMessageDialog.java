package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       CurrentMessageDialog.java
    Created By: John Cardella, Software Engineer
    
    Function:   Form for changing the system message 
    that appears on the bottom of the main screen.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import java.awt.event.ActionEvent;

import javax.swing.*;

import com.pacytology.pcs.actions.CurrentMessageDialogActionMap;
import com.pacytology.pcs.ui.PcsDialog;
import com.pacytology.pcs.ui.Square;
import java.sql.*;

public class CurrentMessageDialog extends PcsDialog
{
    PCSLabEntry parent;
    int[] colorArray = new int[8];
    
	public CurrentMessageDialog()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Set Current Message");
		setResizable(false);
		setModal(true);
		getContentPane().setLayout(null);
		getContentPane().setBackground(new java.awt.Color(204,204,204));
		getContentPane().setForeground(java.awt.Color.black);
		getContentPane().setFont(new Font("Dialog", Font.PLAIN, 12));
		setSize(298,165);
		setVisible(false);
		messageText.setLineWrap(true);
		messageText.setWrapStyleWord(true);
		getContentPane().add(messageText);
		messageText.setBounds(16,54,264,48);
		getContentPane().add(fgColors);
		fgColors.setBounds(140,110,130,20);
		getContentPane().add(bgColors);
		bgColors.setBounds(140,134,130,20);
		JLabel1.setText("Foreground");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(24,110,96,14);
		JLabel2.setText("Background");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(24,134,96,14);
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
		F2lbl.setBounds(78,6,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Submit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(62,30,50,16);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Exit");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,50,16);
		//}}
		
		fgColors.addItem("BLACK");
		fgColors.addItem("WHITE");
		fgColors.addItem("RED");
		fgColors.addItem("BLUE");
		fgColors.addItem("YELLOW");
		fgColors.addItem("GREEN");
		fgColors.addItem("ORANGE");
		fgColors.addItem("MAGENTA");
		fgColors.setSelectedIndex(1);
		
		bgColors.addItem("BLACK");
		bgColors.addItem("WHITE");
		bgColors.addItem("RED");
		bgColors.addItem("BLUE");
		bgColors.addItem("YELLOW");
		bgColors.addItem("GREEN");
		bgColors.addItem("ORANGE");
		bgColors.addItem("MAGENTA");
		bgColors.setSelectedIndex(3);
		
		colorArray[0]=(Color.black.getRGB());
		colorArray[1]=(Color.white.getRGB());
		colorArray[2]=(Color.red.getRGB());
		colorArray[3]=(Color.blue.darker().getRGB());
		colorArray[4]=(Color.yellow.getRGB());
		colorArray[5]=(Color.green.getRGB());
		colorArray[6]=(Color.orange.getRGB());
		colorArray[7]=(Color.magenta.getRGB());
	
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		messageText.addKeyListener(aSymKey);
		//}}
		
		this.actionMap = new CurrentMessageDialogActionMap(this);
		this.setupKeyPressMap();
		
	}
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();


		rp.getActionMap().put("F12", actionMap.finalAction);
		rp.getActionMap().put("ENTER", actionMap.finalAction);

		return rp;
	}
	public CurrentMessageDialog(PCSLabEntry p)
	{
		this();
		this.parent=p;
		Utils.setColors(this.getContentPane());
		(this.getContentPane()).setBackground((Color.red).darker());
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(100,100);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new CurrentMessageDialog()).setVisible(true);
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
	public javax.swing.JTextArea messageText = new javax.swing.JTextArea();
	public javax.swing.JComboBox fgColors = new javax.swing.JComboBox();
	public javax.swing.JComboBox bgColors = new javax.swing.JComboBox();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	//}}


	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == CurrentMessageDialog.this)
				CurrentMessageDialog_windowOpened(event);
		}

		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == CurrentMessageDialog.this)
				CurrentMessageDialog_windowClosing(event);
		}
	}

	void CurrentMessageDialog_windowClosing(java.awt.event.WindowEvent event)
	{
		// to do: code goes here.
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == messageText)
				messageText_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == CurrentMessageDialog.this)
				CurrentMessageDialog_keyPressed(event);
		}
	}

	void CurrentMessageDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		int key = event.getKeyCode();
		if (key==event.VK_F9) {
		    this.dispose();
		}
		else if (key==event.VK_F12 || key==event.VK_ENTER) {
			finalActions();
		    this.dispose();
		}
		else if (key==event.VK_ESCAPE) {
		    
		}
	}
	
	public void finalActions()
	{
	    int F = colorArray[fgColors.getSelectedIndex()];
	    int B = colorArray[bgColors.getSelectedIndex()];
	    parent.currentMsg.setForeground(new Color(F));
	    parent.currentMsg.setBackground(new Color(B));
	    parent.currentMsg.setText(messageText.getText());
	    updateMessage(F,B);
	}

	void messageText_keyTyped(java.awt.event.KeyEvent event)
	{
		forceUpper(event,108);
	}

	void CurrentMessageDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		messageText.requestFocus();
	}
	
	public void forceUpper(java.awt.event.KeyEvent event, int size) {
	    if ( ((JTextArea)event.getComponent()).getText().length()>(size-1) )
	        event.consume();
	    else {
            try {
	            char key=event.getKeyChar();
	            if ( (key>='a')&&(key<='z') ) 
	                event.setKeyChar((char)(key-32));
            }
            catch (Exception e) { System.out.println(e); }            
        }
    }	    
    
    public boolean updateMessage(int F, int B)  {
        boolean exitStatus = true;
        try  {
            String query = 
                "UPDATE pcs.business_info SET \n"+
                "   current_message = ?, \n"+
                "   message_foreground = ?, \n"+
                "   message_background = ? \n";
            PreparedStatement pstmt = DbConnection.process().prepareStatement(query);
            pstmt.setString(1,messageText.getText());
            pstmt.setInt(2,F);
            pstmt.setInt(3,B);
            pstmt.executeUpdate();
        }
        catch( Exception e ) { 
            System.out.println(e); 
            exitStatus=false;
        }
        return exitStatus;
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
		
		
	}
	@Override
	public void resetActions() {
		// TODO Auto-generated method stub

	}
	
}
