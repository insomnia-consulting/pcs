package com.pacytology.pcs;


/*
		A basic implementation of the JFrame class.
*/

import java.awt.*;
import java.awt.event.KeyEvent;

import javax.swing.*;
import com.pacytology.pcs.ui.Square;

public class PCodeAdjustForm extends javax.swing.JFrame
{
    BillingForm parent;
	public PCodeAdjustForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Procedure Code Adjustments");
		setResizable(false);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(253,129);
		setVisible(false);
		JLabel3.setRequestFocusEnabled(false);
		JLabel3.setText("Old Code");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(32,76,64,16);
		oldPCode.setEnabled(false);
		getContentPane().add(oldPCode);
		oldPCode.setFont(new Font("DialogInput", Font.PLAIN, 12));
		oldPCode.setBounds(96,74,50,20);
		getContentPane().add(F1sq);
		F1sq.setBounds(25,4,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F3");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(29,4,20,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(87,4,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F9");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(91,4,20,20);
		getContentPane().add(F3sq);
		F3sq.setBounds(149,4,20,20);
		F3lbl.setRequestFocusEnabled(false);
		F3lbl.setText("F12");
		getContentPane().add(F3lbl);
		F3lbl.setForeground(java.awt.Color.black);
		F3lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F3lbl.setBounds(150,4,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Exit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(62,28,70,16);
		F3action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F3action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F3action.setText("Submit");
		getContentPane().add(F3action);
		F3action.setForeground(java.awt.Color.black);
		F3action.setBounds(124,28,70,16);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Update");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(0,28,70,18);
		JLabel1.setRequestFocusEnabled(false);
		JLabel1.setText("New Code");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(32,98,64,12);
		newPCode.setEnabled(false);
		getContentPane().add(newPCode);
		newPCode.setFont(new Font("DialogInput", Font.PLAIN, 12));
		newPCode.setBounds(96,96,50,20);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		newPCode.addKeyListener(aSymKey);
		oldPCode.addKeyListener(aSymKey);
		//}}
	}

	public PCodeAdjustForm(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public PCodeAdjustForm(BillingForm p)
	{
	    this();
	    this.parent=p;
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(200,200);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new PCodeAdjustForm()).setVisible(true);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted)
			return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets and menu bar
		Insets insets = getInsets();
		javax.swing.JMenuBar menuBar = getRootPane().getJMenuBar();
		int menuBarHeight = 0;
		if (menuBar != null)
			menuBarHeight = menuBar.getPreferredSize().height;
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height + menuBarHeight);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	//{{DECLARE_CONTROLS
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JTextField oldPCode = new javax.swing.JTextField();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	Square F3sq = new Square();
	javax.swing.JLabel F3lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F3action = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JTextField newPCode = new javax.swing.JTextField();
	//}}

	//{{DECLARE_MENUS
	//}}


	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == newPCode)
				newPCode_keyTyped(event);
			else if (object == oldPCode)
				oldPCode_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == PCodeAdjustForm.this)
				PCodeAdjustForm_keyPressed(event);
			else if (object == newPCode)
				newPCode_keyPressed(event);
			else if (object == oldPCode)
				oldPCode_keyPressed(event);
		}
	}

	void PCodeAdjustForm_keyPressed(java.awt.event.KeyEvent event)
	{
		int key = event.getKeyCode();
		int currNdx;
		switch (key) {
            case KeyEvent.VK_F3:
                oldPCode.setEnabled(true);
                oldPCode.requestFocus();
                newPCode.setEnabled(true);
                break;
            case KeyEvent.VK_F9:
                this.dispose();
                break;
            case KeyEvent.VK_F12:
                this.setCursor(new java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
                //parent.labOps.updateProcedureCode(
                //    oldPCode.getText(),newPCode.getText());
                this.dispose();
                break;                    
		}
	}

	void newPCode_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER)
		    oldPCode.requestFocus();
	}

	void newPCode_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}

	void oldPCode_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER)
		    newPCode.requestFocus();
	}

	void oldPCode_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}
	
}
