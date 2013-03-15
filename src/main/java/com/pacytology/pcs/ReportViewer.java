package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       ReportViewer.java
    Created By: John Cardella, Software Engineer
    
    Function:   Form to view and print reports.
    
    MODIFICATIONS ----------------------------------------------------------------
    Date/Staff:   Description:
*/

import java.awt.*;
import java.awt.event.ActionEvent;

import javax.print.PrintException;
import javax.print.attribute.standard.MediaSize;
import javax.swing.*;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import com.pacytology.pcs.actions.LabFormActionMap;
import com.pacytology.pcs.actions.ReportViewerActionMap;
import com.pacytology.pcs.io.FileTransfer;
import com.pacytology.pcs.ui.PcsFrame;
import com.pacytology.pcs.ui.Square;

import java.text.MessageFormat;
import java.util.Vector;

public class ReportViewer extends PcsFrame
{
    String fileName;
    String dir = Utils.SERVER_DIR;
    File f;
    FileInputStream fIN;
    Vector printerCodes = new Vector();
    
	public ReportViewer()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(772,500);
		setVisible(false);
		JScrollPane1.setOpaque(true);
		JScrollPane1.setEnabled(false);
		getContentPane().add(JScrollPane1);
		JScrollPane1.setBounds(8,56,752,430);
		reportText.setEnabled(false);
		JScrollPane1.getViewport().add(reportText);
		reportText.setFont(new Font("MonoSpaced", Font.PLAIN, 11));
		reportText.setBounds(0,0,749,427);
		getContentPane().add(F1sq);
		F1sq.setBounds(35,6,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F1");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(39,6,20,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(97,6,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F9");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(101,6,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Exit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(72,30,70,16);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Print");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,70,16);
		printerConfirm.setMessageType(javax.swing.JOptionPane.QUESTION_MESSAGE);
		//$$ printerConfirm.move(0,608);
		//$$ pprClaimOption.move(0,608);
		//}}
		
		Utils.setColors(this.getContentPane());
		reportText.setFont(new Font("MonoSpaced", Font.PLAIN, 11));
		
		//{{INIT_MENUS
		//}}
	

		actionMap = new ReportViewerActionMap(this);
		setupKeyPressMap();
	}
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();

		rp.getActionMap().put("F1", new AbstractAction() { 
			public void actionPerformed(ActionEvent e) { 
				if (verifyPrinter()) {
			        ReportViewer.this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
			        if ("whp".equals(ReportViewer.this.getTitle())
			        	|| "is1".equals(ReportViewer.this.getTitle())
			        	|| "is2".equals(ReportViewer.this.getTitle())
			        	|| "pth".equals(ReportViewer.this.getTitle())
			        	|| "cyt".equals(ReportViewer.this.getTitle())
			        	|| "uns".equals(ReportViewer.this.getTitle())
			        	|| "ahp".equals(ReportViewer.this.getTitle())
			        	|| "sbt".equals(ReportViewer.this.getTitle())
			        	|| "rfb".equals(ReportViewer.this.getTitle())
			        	|| "rbl".equals(ReportViewer.this.getTitle())) {
			        	
			        	try {
			        		FileInputStream stream = new FileInputStream(ReportViewer.this.fileName);
							Utils.dotMatrixPrint(stream);
						} catch (FileNotFoundException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						} catch (PrintException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						} catch (IOException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
			        }
			        else {
			        	Utils.largePrint(ReportViewer.this.reportText.getText(), new MessageFormat(""), new MessageFormat(""));
			        }
			        ReportViewer.this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
			    }
			}
		});

		return rp;
	}
	public ReportViewer(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public ReportViewer(String fileName, String sTitle)
	{
	    this();
	    this.setTitle(sTitle);
	    this.fileName=fileName;
        f = new File(fileName);
        
        if (f.exists()) {
            long fLen = f.length();
            if (fLen>0) { 
                StringBuffer s = new StringBuffer();
                try {
                    fIN = new FileInputStream(f);
                    for (;;) {
                        int x = fIN.read();
                        if (x==-1) break;
                        char c = (char)x;
                        if (x==(int)('\n')) s.append(c);
                        else if (x>31) s.append(c);
                    }
                    fIN.close();
                }
                catch (Exception e) { }
                reportText.setText(s.toString());
            }	    
        }
		else reportText.setText("Cannot locate report for "+fileName+"!!  Press F9 to Exit");
	}
	
	public static ReportViewer create(String text, String title) {
		ReportViewer viewer = new ReportViewer();
		viewer.setTitle(title);
		viewer.reportText.setText(text);

		return viewer;
	}
	
	public ReportViewer(String fileName, String sTitle, Vector printerCodes)
	{
	    this();
	    this.setTitle(sTitle);
	    this.printerCodes=printerCodes;
	    this.fileName=fileName;
        f = FileTransfer.getFile(Utils.TMP_DIR, Utils.SERVER_DIR, fileName);
        if (f.exists()) {
            long fLen = f.length();
            if (fLen>0) { 
                StringBuffer s = new StringBuffer();
                try {
                    fIN = new FileInputStream(f);
                    for (;;) {
                        int x = fIN.read();
                        if (x==-1) break;
                        char c = (char)x;
                        if (x==(int)('\n')) s.append(c);
                        else if (x>31) s.append(c);
                    }
                    fIN.close();
                }
                catch (Exception e) { }
                reportText.setText(s.toString());
            }	    
        }
		else reportText.setText("Cannot locate report for "+fileName+"!!  Press F9 to Exit");
	}

	public ReportViewer(String fileName, String dir, String sTitle, Vector printerCodes)
	{
	    this();
	    this.setTitle(sTitle);
	    this.printerCodes=printerCodes;
	    this.fileName=fileName;
	    this.dir=Utils.TMP_DIR+dir;
        f = new File(this.dir,fileName);
        if (f.exists()) {
            long fLen = f.length();
            if (fLen>0) { 
                StringBuffer s = new StringBuffer();
                try {
                    fIN = new FileInputStream(f);
                    for (;;) {
                        int x = fIN.read();
                        if (x==-1) break;
                        char c = (char)x;
                        if (x==(int)('\n')) s.append(c);
                        else if (x>31) s.append(c);
                    }
                    fIN.close();
                }
                catch (Exception e) { }
                reportText.setText(s.toString());
            }	    
        }
		else reportText.setText("Cannot locate report for "+fileName+"!!  Press F9 to Exit");
	}
	
	
	public void setVisible(boolean b)
	{
		if (b) setLocation(0,0);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new ReportViewer()).setVisible(true);
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
	javax.swing.JScrollPane JScrollPane1 = new javax.swing.JScrollPane();
	javax.swing.JTextArea reportText = new javax.swing.JTextArea();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JOptionPane printerConfirm = new javax.swing.JOptionPane();
	//}}

	//{{DECLARE_MENUS
	//}}


	


	
	boolean verifyPrinter()
	{
	    boolean status = false;
		int rv = printerConfirm.showConfirmDialog(this,"Make sure printer is ready. \nPrint report now?",
		    this.getTitle(),printerConfirm.YES_NO_OPTION,printerConfirm.QUESTION_MESSAGE);
		if (rv==printerConfirm.YES_OPTION) {
		    status=true;
		}
		return (status);
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
