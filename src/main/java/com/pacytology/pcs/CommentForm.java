package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       CommentForm.java
    Created By: John Cardella, Software Engineer
    
    Function:   Form to display and update comments. This is a 
    generic container.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import java.awt.event.ActionEvent;

import javax.swing.*;

import org.apache.commons.lang.NotImplementedException;

import java.sql.*;

import com.pacytology.pcs.ui.PcsFrame;
import com.pacytology.pcs.ui.Square;

public class CommentForm extends PcsFrame
{

	public JTextArea parentText = new javax.swing.JTextArea();
	Login dbLogin;
	int labNumber;
	boolean canUpdateDB = false;
    
	public CommentForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setResizable(false);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		getContentPane().setBackground(new java.awt.Color(204,204,204));
		setSize(359,218);
		setVisible(false);
		commentPane.setOpaque(true);
		getContentPane().add(commentPane);
		commentPane.setBounds(10,34,338,172);
		commentText.setLineWrap(true);
		commentText.setWrapStyleWord(true);
		commentText.setEditable(false);
		commentText.setEnabled(false);
		commentPane.getViewport().add(commentText);
		commentText.setFont(new Font("SansSerif", Font.BOLD, 12));
		commentText.setBounds(0,0,335,169);
		getContentPane().add(F9sq);
		F9sq.setBounds(216,6,20,20);
		F9lbl.setRequestFocusEnabled(false);
		F9lbl.setText("F9");
		getContentPane().add(F9lbl);
		F9lbl.setForeground(java.awt.Color.black);
		F9lbl.setFont(new Font("SansSerif", Font.BOLD, 10));
		F9lbl.setBounds(220,6,20,20);
		F9action.setHorizontalTextPosition(javax.swing.SwingConstants.LEFT);
		F9action.setText("Exit");
		getContentPane().add(F9action);
		F9action.setForeground(java.awt.Color.black);
		F9action.setBounds(188,8,25,16);
		commentLbl.setText("Internal Comments Log");
		getContentPane().add(commentLbl);
		commentLbl.setBounds(12,8,154,14);
		//}}
		
		getContentPane().setBackground((Color.red).darker());
        commentLbl.setFont(new Font("Dialog", Font.BOLD, 12));
        F9action.setFont(new Font("Dialog", Font.BOLD, 12));
        F9lbl.setFont(new Font("SansSerif", Font.BOLD, 10));
		commentLbl.setForeground(Color.white);
		F9sq.setForeground((Color.yellow).brighter());
		F9lbl.setForeground((Color.yellow).brighter());
		F9action.setForeground((Color.yellow).brighter());
		this.repaint();

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		//}}
		
		setupKeyPressMap();
	}
	/**
	 * Not implemented
	 */
	public void queryActions() {
		throw new NotImplementedException("Not implemented for this CommentForm");
	} ; 
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();

		AbstractAction closeAction = new AbstractAction() {

			public void actionPerformed(ActionEvent e) {
				closingActions();
			}
		};

		rp.getActionMap().put("F9", closeAction);
		rp.getActionMap().put("ESC", closeAction);
		return rp;
	}
	public CommentForm(String title, JTextArea parentText, boolean isUpdatable)
	{
		this();
		this.canUpdateDB=false;
		this.parentText=parentText;
		setTitle(title);
		this.commentText.setText(parentText.getText());
		this.commentText.setEnabled(isUpdatable);
		this.commentText.setEditable(isUpdatable);
	}
	
	public CommentForm(Login dbLogin, int labNumber)
	{
		this();
		this.canUpdateDB=true;
		setTitle("LAB #"+labNumber);
		this.commentText.setEnabled(true);
		this.commentText.setEditable(true);
		this.dbLogin=dbLogin;
		this.labNumber=labNumber;
        getComments();
	}
	
	public CommentForm(int labNumber)
	{
		this();
		this.canUpdateDB=true;
		setTitle("LAB #"+labNumber);
		this.commentText.setEnabled(true);
		this.commentText.setEditable(true);
		this.labNumber=labNumber;
        getComments();
	}
	
	public void setVisible(boolean b)
	{
		if (b) setLocation(50,50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new CommentForm()).setVisible(true);
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
	javax.swing.JScrollPane commentPane = new javax.swing.JScrollPane();
	javax.swing.JTextArea commentText = new javax.swing.JTextArea();
	Square F9sq = new Square();
	javax.swing.JLabel F9lbl = new javax.swing.JLabel();
	javax.swing.JLabel F9action = new javax.swing.JLabel();
	javax.swing.JLabel commentLbl = new javax.swing.JLabel();
	//}}

	//{{DECLARE_MENUS
	//}}


	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == CommentForm.this)
				CommentForm_keyPressed(event);
		}
	}

	void CommentForm_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_F9
		    ||event.getKeyCode()==event.VK_ESCAPE) 
	    {
		    closingActions();
		}
	}
	
	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == CommentForm.this)
				CommentForm_windowOpened(event);
		}

		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == CommentForm.this)
				CommentForm_windowClosing(event);
		}
	}

	void CommentForm_windowClosing(java.awt.event.WindowEvent event)
	{
	    closingActions();
	}
	
	void closingActions()
	{
        try { parentText.setText(commentText.getText()); }
        catch (Exception e) { }
        if (canUpdateDB) updateComments();
        this.dispose();
	}

	void CommentForm_windowOpened(java.awt.event.WindowEvent event)
	{
	    this.toFront();
		if (commentText.isEnabled() && commentText.isEditable())
		    commentText.requestFocus();
	}
	
    public void getComments()  
    {
        try  {
            String SQL = 
                "SELECT comment_text \n"+
                "FROM pcs.lab_req_comments \n"+
                "WHERE lab_number="+labNumber+" \n";
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next())  {
                String s = rs.getString(1);
                commentText.setText(s);
            }                
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { System.out.println(e.toString()); }                
            catch (Exception e) { System.out.println(e); }
        }
        catch (SQLException e) { System.out.println(e.toString()); }
        catch (Exception e) { System.out.println(e); }
    }
    
    public void updateComments()  
    {
        String ctxt = null;
        String SQL = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try { ctxt = commentText.getText(); }
        catch (NullPointerException e) { 
            try {
            SQL = 
                "DELETE FROM pcs.lab_req_comments WHERE lab_number = ? \n";
            pstmt=dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,labNumber);
            pstmt.executeUpdate();
            	rs.close(); pstmt.close(); }
            catch (SQLException f) { System.out.println("[U01] "+f.toString()); }
            catch (Exception f) { System.out.println("[U02] "+f); }
            return;
        }
        catch (Exception e) { System.out.println("[U03] "+e); return; }
        try  {
            SQL = 
                "SELECT count(*) FROM pcs.lab_req_comments \n"+
                "WHERE lab_number = ? \n";
            pstmt=dbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,labNumber);
            rs = pstmt.executeQuery();
            int rCount = 0;
            while (rs.next()) { rCount=rs.getInt(1); }
            try { rs.close(); pstmt.close(); }
            catch (SQLException e) { System.out.println("[U04 ]"+e.toString()); }
            catch (Exception e) { System.out.println("[U05] "+e); }
            if (rCount==0) { 
                SQL = 
                    "INSERT INTO pcs.lab_req_comments (comment_text,lab_number) \n"+
                    "VALUES (?,?) \n";
            }
            else {
                SQL = 
                    "UPDATE pcs.lab_req_comments \n"+
                    "SET comment_text = ? WHERE lab_number = ? \n";
            }
            pstmt=dbConnection.process().prepareStatement(SQL);
            pstmt.setString(1,ctxt);
            pstmt.setInt(2,labNumber);
            pstmt.executeUpdate();
            try { rs.close(); pstmt.close(); }
            catch (SQLException e) { System.out.println("[U07] "+e.toString()); }                
            catch (Exception e) { System.out.println("[U08] "+e.toString()); }
        }
        catch (SQLException e) { System.out.println("[U09] "+e.toString()); }
        catch (Exception e) { System.out.println("[U10] "+e.toString()); }
    }
    /**
     * Not Implemented
     */
	@Override
	public void addActions() {
		throw new NotImplementedException();
	}
	/**
     * Not Implemented
     */
	@Override
	public void updateActions() {
		throw new NotImplementedException();
		
	}
	/** 
	 * Not Implemented
	 */
	@Override
	public void finalActions() {
		throw new NotImplementedException();
	}
	
}