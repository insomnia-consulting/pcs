package com.pacytology.pcs;

/*
		A basic implementation of the JDialog class.
*/

import java.awt.*;
import java.sql.*;
import javax.swing.*;

import com.pacytology.pcs.utils.StringUtils;

public class PasswordDialog extends javax.swing.JDialog
{
    Login dbLogin;
    StringUtils format = new StringUtils();
    
	public PasswordDialog(Frame parent)
	{
		super(parent);
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Set Password");
		setResizable(false);
		setModal(true);
		getContentPane().setLayout(null);
		setSize(286,120);
		setVisible(false);
		pwdLabel.setText("Password");
		getContentPane().add(pwdLabel);
		pwdLabel.setForeground(java.awt.Color.black);
		pwdLabel.setBounds(18,42,72,12);
		getContentPane().add(userPwdField);
		userPwdField.setFont(new Font("DialogInput", Font.PLAIN, 12));
		userPwdField.setBounds(110,40,160,20);
		JLabel1.setText("Confirm");
		getContentPane().add(JLabel1);
		JLabel1.setForeground(java.awt.Color.black);
		JLabel1.setBounds(18,64,72,12);
		getContentPane().add(confirmPwd);
		confirmPwd.setFont(new Font("DialogInput", Font.PLAIN, 12));
		confirmPwd.setBounds(110,62,160,20);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setBounds(14,90,260,14);
		userLabel.setText("User Name");
		getContentPane().add(userLabel);
		userLabel.setForeground(java.awt.Color.black);
		userLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		userLabel.setBounds(18,18,84,12);
		userTextField.setEnabled(false);
		getContentPane().add(userTextField);
		userTextField.setFont(new Font("SansSerif", Font.PLAIN, 12));
		userTextField.setBounds(110,16,160,20);
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		userPwdField.addKeyListener(aSymKey);
		confirmPwd.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		this.addKeyListener(aSymKey);
		//}}
	}

	public PasswordDialog()
	{
		this((Frame)null);
	}

	public PasswordDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public PasswordDialog(Login dbLogin)
	{
		this();
		this.dbLogin=dbLogin;
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(50,50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new PasswordDialog()).setVisible(true);
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
	javax.swing.JLabel pwdLabel = new javax.swing.JLabel();
	javax.swing.JPasswordField userPwdField = new javax.swing.JPasswordField();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JPasswordField confirmPwd = new javax.swing.JPasswordField();
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	javax.swing.JLabel userLabel = new javax.swing.JLabel();
	javax.swing.JTextField userTextField = new javax.swing.JTextField();
	//}}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == userPwdField)
				userPwdField_keyPressed(event);
			else if (object == confirmPwd)
				confirmPwd_keyPressed(event);
			else if (object == PasswordDialog.this)
				PasswordDialog_keyPressed(event);
		}
	}

	void userPwdField_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER)
	        userPwdField.transferFocus();
	}

	void confirmPwd_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
	        if (comparePasswords()) updatePassword();
	        else {
	            format.createErrMsg("Passwords do not match");
	            userPwdField.setText(null);
	            confirmPwd.setText(null);
	            userPwdField.requestFocus();
	        }
	    }
	}
	
	boolean comparePasswords()
	{
	    return (userPwdField.getText().equals(confirmPwd.getText()));
	}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == PasswordDialog.this)
				PasswordDialog_windowOpened(event);
		}
	}

	void PasswordDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		userPwdField.requestFocus();
		userTextField.setText(dbLogin.userName);
	}

	void PasswordDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_F9)
		    this.dispose();
	}
	
	void updatePassword()
	{
	    int rv = (-1);
        try  {
            PreparedStatement pstmt;
            String SQL = "ALTER USER "+dbLogin.userName+" IDENTIFIED BY "+confirmPwd.getText();
            pstmt=DbConnection.process().prepareStatement(SQL);
            rv=pstmt.executeUpdate();
        }
        catch( Exception e ) { System.out.println(e+" rv:"+rv); }
        if (rv==0) {
            msgLabel.setText("PASSWORD CHANGED - F9 TO EXIT");
            dbLogin.userPassword=confirmPwd.getText();
            userPwdField.setText(null);
            confirmPwd.setText(null);
            userPwdField.setEnabled(false);
            confirmPwd.setEnabled(false);
            msgLabel.requestFocus();
        }
        else {
            msgLabel.setText(null);
            format.createErrMsg("Illegal password - try again");
            this.dispose();
        }
	}
	
}
