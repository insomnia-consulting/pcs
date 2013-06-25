package com.pacytology.pcs;
/*

    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       ReceiveDateForm.java
    Created By: John Cardella, Software Engineer
    
    Function:   Form for entering requisition 
    receive dates.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
 */

import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.swing.AbstractAction;
import javax.swing.JOptionPane;
import javax.swing.JRootPane;

import org.apache.commons.lang.NotImplementedException;

import com.pacytology.pcs.ui.HorizontalLine;
import com.pacytology.pcs.ui.Square;
import com.pacytology.pcs.ui.PcsFrame;

public class ReceiveDateForm extends PcsFrame {
	private Login dbLogin;
	private int iDate;
	private String sDate;
	/*
	 * final int IDLE = 100; final int QUERY = 101; final int CURRENT = 102;
	 * final int UPDATE = 103;
	 */
	int currMode = Lab.IDLE;
	int saveLab;

	public ReceiveDateForm() {
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		// {{INIT_CONTROLS
		setTitle("Receive Dates");
		getContentPane().setLayout(null);
		setSize(346, 299);
		setVisible(false);
		rDay01.setEnabled(false);
		getContentPane().add(rDay01);
		rDay01.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay01.setBounds(44, 120, 76, 20);
		rBegin01.setEnabled(false);
		getContentPane().add(rBegin01);
		rBegin01.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin01.setBounds(126, 120, 80, 20);
		rEnd01.setEnabled(false);
		getContentPane().add(rEnd01);
		rEnd01.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd01.setBounds(210, 120, 80, 20);
		rTtl01.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl01.setEnabled(false);
		getContentPane().add(rTtl01);
		rTtl01.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl01.setBounds(294, 120, 40, 20);
		rDay02.setEnabled(false);
		getContentPane().add(rDay02);
		rDay02.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay02.setBounds(44, 144, 76, 20);
		rBegin02.setEnabled(false);
		getContentPane().add(rBegin02);
		rBegin02.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin02.setBounds(126, 144, 80, 20);
		rEnd02.setEnabled(false);
		getContentPane().add(rEnd02);
		rEnd02.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd02.setBounds(210, 144, 80, 20);
		rTtl02.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl02.setEnabled(false);
		getContentPane().add(rTtl02);
		rTtl02.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl02.setBounds(294, 144, 40, 20);
		rDay03.setEnabled(false);
		getContentPane().add(rDay03);
		rDay03.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay03.setBounds(44, 168, 76, 20);
		rBegin03.setEnabled(false);
		getContentPane().add(rBegin03);
		rBegin03.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin03.setBounds(126, 168, 80, 20);
		rEnd03.setEnabled(false);
		getContentPane().add(rEnd03);
		rEnd03.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd03.setBounds(210, 168, 80, 20);
		rTtl03.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl03.setEnabled(false);
		getContentPane().add(rTtl03);
		rTtl03.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl03.setBounds(294, 168, 40, 20);
		rDay04.setEnabled(false);
		getContentPane().add(rDay04);
		rDay04.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay04.setBounds(44, 192, 76, 20);
		rBegin04.setEnabled(false);
		getContentPane().add(rBegin04);
		rBegin04.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin04.setBounds(126, 192, 80, 20);
		rEnd04.setEnabled(false);
		getContentPane().add(rEnd04);
		rEnd04.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd04.setBounds(210, 192, 80, 20);
		rTtl04.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl04.setEnabled(false);
		getContentPane().add(rTtl04);
		rTtl04.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl04.setBounds(294, 192, 40, 20);
		rDay05.setEnabled(false);
		getContentPane().add(rDay05);
		rDay05.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay05.setBounds(44, 216, 76, 20);
		rBegin05.setEnabled(false);
		getContentPane().add(rBegin05);
		rBegin05.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin05.setBounds(126, 216, 80, 20);
		rEnd05.setEnabled(false);
		getContentPane().add(rEnd05);
		rEnd05.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd05.setBounds(210, 216, 80, 20);
		rTtl05.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl05.setEnabled(false);
		getContentPane().add(rTtl05);
		rTtl05.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl05.setBounds(294, 216, 40, 20);
		rDay06.setEnabled(false);
		getContentPane().add(rDay06);
		rDay06.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay06.setBounds(44, 240, 76, 20);
		rBegin06.setEnabled(false);
		getContentPane().add(rBegin06);
		rBegin06.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin06.setBounds(126, 240, 80, 20);
		rEnd06.setEnabled(false);
		getContentPane().add(rEnd06);
		rEnd06.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd06.setBounds(210, 240, 80, 20);
		rTtl06.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl06.setEnabled(false);
		getContentPane().add(rTtl06);
		rTtl06.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl06.setBounds(294, 240, 40, 20);
		rDay07.setEnabled(false);
		getContentPane().add(rDay07);
		rDay07.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay07.setBounds(44, 264, 76, 20);
		rBegin07.setEnabled(false);
		getContentPane().add(rBegin07);
		rBegin07.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin07.setBounds(126, 264, 80, 20);
		rEnd07.setEnabled(false);
		getContentPane().add(rEnd07);
		rEnd07.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd07.setBounds(210, 264, 80, 20);
		rTtl07.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl07.setEnabled(false);
		getContentPane().add(rTtl07);
		rTtl07.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl07.setBounds(294, 264, 40, 20);
		rDay00.setEnabled(false);
		getContentPane().add(rDay00);
		rDay00.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rDay00.setBounds(44, 88, 76, 20);
		rBegin00.setEnabled(false);
		getContentPane().add(rBegin00);
		rBegin00.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rBegin00.setBounds(126, 88, 80, 20);
		rEnd00.setEnabled(false);
		getContentPane().add(rEnd00);
		rEnd00.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rEnd00.setBounds(210, 88, 80, 20);
		getContentPane().add(F1sq);
		F1sq.setBounds(25, 4, 20, 20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F1");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(29, 4, 20, 20);
		getContentPane().add(F2sq);
		F2sq.setBounds(87, 4, 20, 20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F4");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(91, 4, 20, 20);
		getContentPane().add(F3sq);
		F3sq.setBounds(149, 4, 20, 20);
		F3lbl.setRequestFocusEnabled(false);
		F3lbl.setText("F9");
		getContentPane().add(F3lbl);
		F3lbl.setForeground(java.awt.Color.black);
		F3lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F3lbl.setBounds(153, 4, 20, 20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Delete");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(62, 28, 70, 16);
		F3action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F3action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F3action.setText("Exit");
		getContentPane().add(F3action);
		F3action.setForeground(java.awt.Color.black);
		F3action.setBounds(124, 28, 70, 16);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Query");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(0, 28, 70, 18);
		rTtl00.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rTtl00.setEnabled(false);
		getContentPane().add(rTtl00);
		rTtl00.setFont(new Font("DialogInput", Font.PLAIN, 12));
		rTtl00.setBounds(294, 88, 40, 20);
		confirmDelete.setMessageType(javax.swing.JOptionPane.QUESTION_MESSAGE);
		confirmDelete.setOptionType(javax.swing.JOptionPane.YES_NO_OPTION);
		// $$ confirmDelete.move(0,300);
		JLabel1.setText("Lab Number");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(126, 72, 78, 12);
		dateLbl.setText("Receive Date");
		getContentPane().add(dateLbl);
		dateLbl.setBounds(10, 72, 90, 12);
		JLabel2.setText("Lab Number");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(210, 72, 78, 12);
		JLabel4.setText("Starting");
		getContentPane().add(JLabel4);
		JLabel4.setBounds(126, 60, 78, 12);
		JLabel5.setText("Ending");
		getContentPane().add(JLabel5);
		JLabel5.setBounds(210, 60, 78, 12);
		JLabel6.setText("Total");
		getContentPane().add(JLabel6);
		JLabel6.setBounds(294, 72, 40, 12);
		getContentPane().add(horizontalLine1);
		horizontalLine1.setForeground(java.awt.Color.white);
		horizontalLine1.setBounds(10, 112, 326, 2);
		d00.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d00.setEnabled(false);
		getContentPane().add(d00);
		d00.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d00.setBounds(10, 88, 32, 20);
		d01.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d01.setEnabled(false);
		getContentPane().add(d01);
		d01.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d01.setBounds(10, 120, 32, 20);
		d02.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d02.setEnabled(false);
		getContentPane().add(d02);
		d02.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d02.setBounds(10, 144, 32, 20);
		d03.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d03.setEnabled(false);
		getContentPane().add(d03);
		d03.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d03.setBounds(10, 168, 32, 20);
		d04.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d04.setEnabled(false);
		getContentPane().add(d04);
		d04.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d04.setBounds(10, 192, 32, 20);
		d05.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d05.setEnabled(false);
		getContentPane().add(d05);
		d05.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d05.setBounds(10, 216, 32, 20);
		d06.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d06.setEnabled(false);
		getContentPane().add(d06);
		d06.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d06.setBounds(10, 240, 32, 20);
		d07.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		d07.setEnabled(false);
		getContentPane().add(d07);
		d07.setFont(new Font("DialogInput", Font.PLAIN, 12));
		d07.setBounds(10, 264, 32, 20);
		getContentPane().add(F4sq);
		F4sq.setBounds(221, 4, 20, 20);
		F4lbl.setRequestFocusEnabled(false);
		F4lbl.setText("F12");
		getContentPane().add(F4lbl);
		F4lbl.setForeground(java.awt.Color.black);
		F4lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F4lbl.setBounds(222, 4, 20, 20);
		F4action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F4action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F4action.setText("Submit");
		getContentPane().add(F4action);
		F4action.setForeground(java.awt.Color.black);
		F4action.setBounds(196, 28, 70, 16);
		// $$ JOptionPane1.move(0,300);
		// }}

		// {{INIT_MENUS
		// }}

		// {{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		rDay00.addKeyListener(aSymKey);
		rEnd00.addKeyListener(aSymKey);
		this.addKeyListener(aSymKey);
		SymFocus aSymFocus = new SymFocus();
		rDay00.addFocusListener(aSymFocus);
		rEnd00.addFocusListener(aSymFocus);
		rBegin01.addKeyListener(aSymKey);
		rBegin01.addFocusListener(aSymFocus);
		// }}

		setupKeyPressMap();
		Utils.setColors(this.getContentPane());
		this.repaint();
	}
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();
		rp.getActionMap().put("F1", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				currMode = Lab.QUERY;
				rDay00.setText(null);
				rBegin00.setText(null);
				rEnd00.setText(null);
				rTtl00.setText(null);
				startingActions();
				rEnd00.setEnabled(false);
			}
		});
		rp.getActionMap().put("F4", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				if (currMode != Lab.CURRENT) {
					Utils.createErrMsg("Cannot delete old receive date");
					return;
				}
				int rv = JOptionPane.showConfirmDialog(ReceiveDateForm.this,
						"Delete current receive date", "Delete Rec'v Date",
						JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE);
				if (rv == JOptionPane.YES_OPTION) {
					int maxLab = 0;
					try {
						maxLab = Integer.parseInt(rBegin00.getText());
					} catch (Exception ex) {
						maxLab = 0;
					}
					if (maxLab > 0) {
						try {
							deleteReceiveDate(maxLab);
						} catch (Exception e1) {

							e1.printStackTrace();
						}
						rDay00.setText(null);
						rBegin00.setText(null);
						rEnd00.setText(null);
						rTtl00.setText(null);
						getDates();
						rDay00.requestFocus();
					}
				}
			}
		});
		rp.getActionMap().put("F9", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				closingActions();
			}
		});
		rp.getActionMap().put("F12", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				finalActions();
			}
		});
		return rp;
		
	}
	public ReceiveDateForm(String sTitle) {
		this();
		setTitle(sTitle);
	}

	public ReceiveDateForm(Login dbLogin) {
		this();
		this.dbLogin = dbLogin;
		getDates();
	}

	@Override
	public void setVisible(boolean b) {
		if (b)
			setLocation(50, 50);
		super.setVisible(b);
	}

	static public void main(String args[]) {
		(new ReceiveDateForm()).setVisible(true);
	}

	@Override
	public void addNotify() {
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
		setSize(insets.left + insets.right + size.width, insets.top
				+ insets.bottom + size.height + menuBarHeight);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	// {{DECLARE_CONTROLS
	javax.swing.JTextField rDay01 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin01 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd01 = new javax.swing.JTextField();
	javax.swing.JTextField rTtl01 = new javax.swing.JTextField();
	javax.swing.JTextField rDay02 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin02 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd02 = new javax.swing.JTextField();
	javax.swing.JTextField rTtl02 = new javax.swing.JTextField();
	javax.swing.JTextField rDay03 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin03 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd03 = new javax.swing.JTextField();
	javax.swing.JTextField rTtl03 = new javax.swing.JTextField();
	javax.swing.JTextField rDay04 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin04 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd04 = new javax.swing.JTextField();
	javax.swing.JTextField rTtl04 = new javax.swing.JTextField();
	javax.swing.JTextField rDay05 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin05 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd05 = new javax.swing.JTextField();
	javax.swing.JTextField rTtl05 = new javax.swing.JTextField();
	javax.swing.JTextField rDay06 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin06 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd06 = new javax.swing.JTextField();
	javax.swing.JTextField rTtl06 = new javax.swing.JTextField();
	javax.swing.JTextField rDay07 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin07 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd07 = new javax.swing.JTextField();
	javax.swing.JTextField rTtl07 = new javax.swing.JTextField();
	javax.swing.JTextField rDay00 = new javax.swing.JTextField();
	javax.swing.JTextField rBegin00 = new javax.swing.JTextField();
	javax.swing.JTextField rEnd00 = new javax.swing.JTextField();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	Square F3sq = new Square();
	javax.swing.JLabel F3lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F3action = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JTextField rTtl00 = new javax.swing.JTextField();
	javax.swing.JOptionPane confirmDelete = new javax.swing.JOptionPane();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel dateLbl = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel4 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel5 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel6 = new javax.swing.JLabel();
	HorizontalLine horizontalLine1 = new HorizontalLine();
	javax.swing.JTextField d00 = new javax.swing.JTextField();
	javax.swing.JTextField d01 = new javax.swing.JTextField();
	javax.swing.JTextField d02 = new javax.swing.JTextField();
	javax.swing.JTextField d03 = new javax.swing.JTextField();
	javax.swing.JTextField d04 = new javax.swing.JTextField();
	javax.swing.JTextField d05 = new javax.swing.JTextField();
	javax.swing.JTextField d06 = new javax.swing.JTextField();
	javax.swing.JTextField d07 = new javax.swing.JTextField();
	Square F4sq = new Square();
	javax.swing.JLabel F4lbl = new javax.swing.JLabel();
	javax.swing.JLabel F4action = new javax.swing.JLabel();

	// }}

	// {{DECLARE_MENUS
	// }}

	private void getDates() {
		try {
			String SQL = "SELECT TO_CHAR(start_date,'MM/DD/YYYY'), start_lab_number, \n"
					+ "   TO_NUMBER(TO_CHAR(start_date,'YYYYMMDD')), \n"
					+ "   TO_CHAR(start_date,'DY'), TO_CHAR(start_date,'MMDD') \n"
					+ "FROM pcs.receive_dates ORDER BY start_date DESC \n";
			Statement stmt = DbConnection.process().createStatement();
			ResultSet rs = stmt.executeQuery(SQL);
			int ndx = 0;
			int e_lab = 0;
			int b_lab = 0;
			String b_date = null;
			while (rs.next() && ndx < 8) {
				b_lab = rs.getInt(2);
				b_date = rs.getString(5);
				switch (ndx) {
				case 0:
					sDate = rs.getString(1);
					rDay00.setText(sDate);
					rBegin00.setText(Integer.toString(b_lab));
					iDate = rs.getInt(3);
					d00.setText(rs.getString(4));
					break;
				case 1:
					rDay01.setText(rs.getString(1));
					rBegin01.setText(Integer.toString(b_lab));
					rEnd01.setText(Integer.toString(e_lab));
					rTtl01.setText(Integer.toString(e_lab - b_lab));
					d01.setText(rs.getString(4));
					break;
				case 2:
					rDay02.setText(rs.getString(1));
					rBegin02.setText(Integer.toString(b_lab));
					rEnd02.setText(Integer.toString(e_lab));
					rTtl02.setText(Integer.toString(e_lab - b_lab));
					d02.setText(rs.getString(4));
					break;
				case 3:
					rDay03.setText(rs.getString(1));
					rBegin03.setText(Integer.toString(b_lab));
					rEnd03.setText(Integer.toString(e_lab));
					rTtl03.setText(Integer.toString(e_lab - b_lab));
					d03.setText(rs.getString(4));
					break;
				case 4:
					rDay04.setText(rs.getString(1));
					rBegin04.setText(Integer.toString(b_lab));
					rEnd04.setText(Integer.toString(e_lab));
					rTtl04.setText(Integer.toString(e_lab - b_lab));
					d04.setText(rs.getString(4));
					break;
				case 5:
					rDay05.setText(rs.getString(1));
					rBegin05.setText(Integer.toString(b_lab));
					rEnd05.setText(Integer.toString(e_lab));
					rTtl05.setText(Integer.toString(e_lab - b_lab));
					d05.setText(rs.getString(4));
					break;
				case 6:
					rDay06.setText(rs.getString(1));
					rBegin06.setText(Integer.toString(b_lab));
					rEnd06.setText(Integer.toString(e_lab));
					rTtl06.setText(Integer.toString(e_lab - b_lab));
					d06.setText(rs.getString(4));
					break;
				case 7:
					rDay07.setText(rs.getString(1));
					rBegin07.setText(Integer.toString(b_lab));
					rEnd07.setText(Integer.toString(e_lab));
					rTtl07.setText(Integer.toString(e_lab - b_lab));
					d07.setText(rs.getString(4));
					break;
				}
				e_lab = b_lab - 1;
				if (!b_date.equals("0101"))
					ndx++;
			}
			currMode = Lab.CURRENT;
			try {
				rs.close();
				stmt.close();
			} catch (SQLException e) {
				currMode = Lab.IDLE;
			}
		} catch (SQLException e) {
			currMode = Lab.IDLE;
		}
	}

	private void getDates(String qDate) {
		try {
			String SQL = "SELECT TO_CHAR(start_date,'MM/DD/YYYY'), start_lab_number, \n"
					+ "   TO_NUMBER(TO_CHAR(start_date,'YYYYMMDD')), \n"
					+ "   TO_CHAR(start_date,'DY'), TO_CHAR(start_date,'MMDD') \n"
					+ "FROM pcs.receive_dates \n"
					+ "WHERE start_date<=TO_DATE('"
					+ qDate
					+ "','MMDDYYYY')+1 \n" + "ORDER BY start_date DESC \n";
			Statement stmt = DbConnection.process().createStatement();
			ResultSet rs = stmt.executeQuery(SQL);
			int ndx = 0;
			int e_lab = 0;
			int b_lab = 0;
			String b_date = null;
			while (rs.next() && ndx < 8) {
				b_lab = rs.getInt(2);
				b_date = rs.getString(5);
				switch (ndx) {
				case 1:
					rDay01.setText(rs.getString(1));
					rBegin01.setText(Integer.toString(b_lab));
					rEnd01.setText(Integer.toString(e_lab));
					rTtl01.setText(Integer.toString(e_lab - b_lab));
					d01.setText(rs.getString(4));
					break;
				case 2:
					rDay02.setText(rs.getString(1));
					rBegin02.setText(Integer.toString(b_lab));
					rEnd02.setText(Integer.toString(e_lab));
					rTtl02.setText(Integer.toString(e_lab - b_lab));
					d02.setText(rs.getString(4));
					break;
				case 3:
					rDay03.setText(rs.getString(1));
					rBegin03.setText(Integer.toString(b_lab));
					rEnd03.setText(Integer.toString(e_lab));
					rTtl03.setText(Integer.toString(e_lab - b_lab));
					d03.setText(rs.getString(4));
					break;
				case 4:
					rDay04.setText(rs.getString(1));
					rBegin04.setText(Integer.toString(b_lab));
					rEnd04.setText(Integer.toString(e_lab));
					rTtl04.setText(Integer.toString(e_lab - b_lab));
					d04.setText(rs.getString(4));
					break;
				case 5:
					rDay05.setText(rs.getString(1));
					rBegin05.setText(Integer.toString(b_lab));
					rEnd05.setText(Integer.toString(e_lab));
					rTtl05.setText(Integer.toString(e_lab - b_lab));
					d05.setText(rs.getString(4));
					break;
				case 6:
					rDay06.setText(rs.getString(1));
					rBegin06.setText(Integer.toString(b_lab));
					rEnd06.setText(Integer.toString(e_lab));
					rTtl06.setText(Integer.toString(e_lab - b_lab));
					d06.setText(rs.getString(4));
					break;
				case 7:
					rDay07.setText(rs.getString(1));
					rBegin07.setText(Integer.toString(b_lab));
					rEnd07.setText(Integer.toString(e_lab));
					rTtl07.setText(Integer.toString(e_lab - b_lab));
					d07.setText(rs.getString(4));
					break;
				}
				e_lab = b_lab - 1;
				if (!b_date.equals("0101"))
					ndx++;
			}
			currMode = Lab.QUERY;
			try {
				rs.close();
				stmt.close();
			} catch (SQLException e) {
				currMode = Lab.IDLE;
				System.out.println(e);
			}
		} catch (SQLException e) {
			currMode = Lab.IDLE;
			System.out.println(e);
		}
	}

	public class RecvDateRec {
		String receive_date;
		int begin_lab;
		int end_lab;
		int total_reqs;

		public RecvDateRec() {
			begin_lab = 0;
			end_lab = 0;
			total_reqs = 0;
		}
	}

	class SymWindow extends java.awt.event.WindowAdapter {
		@Override
		public void windowOpened(java.awt.event.WindowEvent event) {
			Object object = event.getSource();
			if (object == ReceiveDateForm.this)
				ReceiveDateForm_windowOpened(event);
		}

		@Override
		public void windowClosing(java.awt.event.WindowEvent event) {
			Object object = event.getSource();
			if (object == ReceiveDateForm.this)
				ReceiveDateForm_windowClosing(event);
		}
	}

	void ReceiveDateForm_windowClosing(java.awt.event.WindowEvent event) {
		closingActions();
	}

	void closingActions() {
		this.dispose();
	}

	void startingActions() {
		rDay00.setEnabled(true);
		rEnd00.setEnabled(true);
		rDay00.requestFocus();
	}

	void ReceiveDateForm_windowOpened(java.awt.event.WindowEvent event) {
		startingActions();
	}

	class SymKey extends java.awt.event.KeyAdapter {
		@Override
		public void keyPressed(java.awt.event.KeyEvent event) {
			Object object = event.getSource();
			if (object == rDay00)
				rDay00_keyPressed(event);
			else if (object == rEnd00)
				rEnd00_keyPressed(event);
			else if (object == ReceiveDateForm.this)
				ReceiveDateForm_keyPressed(event);
			else if (object == rBegin01)
				rBegin01_keyPressed(event);
		}

		@Override
		public void keyTyped(java.awt.event.KeyEvent event) {
			Object object = event.getSource();
			if (object == rDay00)
				rDay00_keyTyped(event);
			else if (object == rEnd00)
				rEnd00_keyTyped(event);
			else if (object == rBegin01)
				rBegin01_keyTyped(event);
		}
	}

	void rDay00_keyTyped(java.awt.event.KeyEvent event) {
		Utils.buildDateMask(event);
	}

	void rDay00_keyPressed(java.awt.event.KeyEvent event) {
		if (event.getKeyCode() == KeyEvent.VK_ENTER) {
			if (Utils.required(rDay00, "Receive Date")) {
				if (Utils.dateVerify(rDay00)) {
					String s1 = Utils.stripDateMask(rDay00.getText());
					String s2 = s1.substring(4) + s1.substring(0, 2)
							+ s1.substring(2, 4);
					int d = Integer.parseInt(s2);
					if (d >= iDate)
						rDay00.transferFocus();
					else {
						rDay00.setText(sDate);
						Utils.createErrMsg("New date cannot be earlier than "
								+ sDate);
					}
				}
			}
		}
	}

	void rEnd00_keyTyped(java.awt.event.KeyEvent event) {
		Utils.forceDigits(event);
	}

	void rEnd00_keyPressed(java.awt.event.KeyEvent event) {
		if (event.getKeyCode() == KeyEvent.VK_ENTER) {
			if (Utils.required(rEnd00, "Ending Lab Number")) {
				int b = Integer.parseInt(rBegin00.getText());
				int e = Integer.parseInt(rEnd00.getText());
				if (e - b > 0) {
					rTtl00.setText(Integer.toString(e - b));
					rEnd00.transferFocus();
				} else {
					rEnd00.setText(null);
					Utils.createErrMsg("Ending lab must be greater than beginning lab");
				}
			}
		}
	}
	@Override
	public void finalActions() {
		if (currMode == Lab.QUERY) {
			getDates(Utils.stripDateMask(rDay00.getText()));
			d00.setText(null);
			rDay00.setText(null);
			rBegin00.setText(null);
			rEnd00.setText(null);
			rTtl00.setText(null);
			rDay00.setEnabled(false);
			rEnd00.setEnabled(false);
			dateLbl.requestFocus();
		} else if (currMode == Lab.UPDATE) {
			try {
				int newLab = Integer.parseInt(rBegin01.getText());
				editReceiveDate(saveLab, newLab);
				getDates(Utils.stripDateMask(rDay01.getText()));
				d00.setText(null);
				rDay00.setText(null);
				rBegin00.setText(null);
				rEnd00.setText(null);
				rTtl00.setText(null);
				rDay00.setEnabled(false);
				rEnd00.setEnabled(false);
				rBegin01.setEnabled(false);
				dateLbl.requestFocus();
				currMode = Lab.QUERY;
			} catch (Exception e) {
				System.out.println(e.toString());
			}
		} else {
			updateReceiveDates();
			rDay00.setText(null);
			rBegin00.setText(null);
			rEnd00.setText(null);
			rTtl00.setText(null);
			getDates();
			rDay00.requestFocus();
		}
	}

	void ReceiveDateForm_keyPressed(java.awt.event.KeyEvent event) {
		int key = event.getKeyCode();
		switch (key) {
		case KeyEvent.VK_F9:
			
			break;
		case KeyEvent.VK_F12:
			finalActions();
			break;
		case KeyEvent.VK_F3:
			if (currMode != Lab.QUERY) {
				Utils.createErrMsg("Cannot update current receive date");
				return;
			}
			try {
				currMode = Lab.UPDATE;
				saveLab = Integer.parseInt(rBegin01.getText());
				rBegin01.setEnabled(true);
				rBegin01.requestFocus();
			} catch (Exception e) {
			}
			break;
		
		case KeyEvent.VK_ESCAPE:
			currMode = Lab.IDLE;
			rBegin01.setEnabled(false);
			getDates();
			startingActions();
			break;
		}
	}

	void updateReceiveDates() {
		String dayAfterNewYears = null; // Next receive date after NYD
		String nextYear = null; // Next year (YYYY)
		setCursor(new java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
		try {
			int endingLab = Integer.parseInt(rEnd00.getText());
			String SQL = "UPDATE pcs.receive_dates \n"
					+ "SET start_date = TO_DATE(?,'MM/DD/YYYY'), \n"
					+ "   end_lab_number = ? \n"
					+ "WHERE start_lab_number = ? \n";
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setString(1, rDay00.getText());
			pstmt.setInt(2, endingLab);
			pstmt.setInt(3, Integer.parseInt(rBegin00.getText()));
			pstmt.executeUpdate();
			int inc = 1;
			int nextStartingLab = Integer.parseInt(rEnd00.getText()) + 1;
			/*
			 * If the current day is a Friday, then the next day to enter a
			 * receive date will be on a Monday, or (3) days from the current
			 * date (hence inc=3)
			 */
			if (d00.getText().equals("FRI"))
				inc = 3;
			/*
			 * Check for special situation: whether there will be a cross-over
			 * from one year to the next
			 */
			boolean isNewYear = false; // Year is changing?
			String newYear = null; // New Years Day date
			String newYearsDay = null; // Day of week for NYD
			SQL = "SELECT TO_CHAR(MAX(start_date)+?,'MMDD'), \n"
					+ "TO_CHAR(MAX(start_date)+?,'YYYY'), \n"
					+ "TO_CHAR(MAX(start_date)+?,'DY') \n"
					+ "FROM pcs.receive_dates \n";
			for (int i = 1; i <= inc; i++) {
				pstmt = DbConnection.process().prepareStatement(SQL);
				pstmt.setInt(1, i);
				pstmt.setInt(2, i);
				pstmt.setInt(3, i);
				ResultSet rs = pstmt.executeQuery();
				while (rs.next()) {
					String s = rs.getString(1); // Date in MMDD format
					if (s.equals("0101")) {
						isNewYear = true;
						nextYear = rs.getString(2);
						newYearsDay = rs.getString(3);
					}
				}
				try {
					rs.close();
					pstmt.close();
				} catch (SQLException e) {
					System.out.println(e);
					setCursor(new java.awt.Cursor(
							java.awt.Cursor.DEFAULT_CURSOR));
				}
				if (isNewYear) {
					// If NYD falls on a Friday, then next business day is 01/04
					if (newYearsDay.equals("FRI")) {
						dayAfterNewYears = "0104" + nextYear;
					}
					// If NYD falls on a Saturday, then next business day is
					// 01/03
					else if (newYearsDay.equals("SAT")) {
						dayAfterNewYears = "0103" + nextYear;
					}
					// If NYD falls on a Sunday, then Monday is holiday to, and
					// next business day is 01/03
					else if (newYearsDay.equals("SUN")) {
						dayAfterNewYears = "0103" + nextYear;
					}
					// Otherwise next business day is 01/02
					else {
						dayAfterNewYears = "0102" + nextYear;
					}
					newYear = "0101" + nextYear;
					break;
				}
			}
			if (isNewYear) {
				/*
				 * Insert an entry into the receive_dates table that has NYD as
				 * the date, and completes the range from the highest lab to the
				 * zero lab number of the next year; this is considered a
				 * "dummy" entry in the table.
				 */
				SQL = "INSERT INTO pcs.receive_dates \n"
						+ "(start_date,start_lab_number,end_lab_number) \n"
						+ "VALUES \n"
						+ "(TO_DATE(?,'MMDDYYYY'),?,TO_NUMBER(?)) \n";
				pstmt = DbConnection.process().prepareStatement(SQL);
				pstmt.setString(1, newYear);
				pstmt.setInt(2, nextStartingLab);
				pstmt.setString(3, nextYear + "000000");
				pstmt.executeUpdate();
				try {
					pstmt.close();
				} catch (SQLException e) {
					System.out.println("pstmt.close: " + e);
					setCursor(new java.awt.Cursor(
							java.awt.Cursor.DEFAULT_CURSOR));
				}
				/*
				 * Insert the first entry in the receive_dates table for the new
				 * year with the appropriate date, and the first lab number of
				 * the year (i.e. YYYY000001).
				 */
				SQL = "INSERT INTO pcs.receive_dates (start_date,start_lab_number) \n"
						+ "VALUES (TO_DATE(?,'MMDDYYYY'),TO_NUMBER(?)) \n";
				pstmt = DbConnection.process().prepareStatement(SQL);
				pstmt.setString(1, dayAfterNewYears);
				pstmt.setString(2, nextYear + "000001");
				pstmt.executeUpdate();
				try {
					pstmt.close();
				} catch (SQLException e) {
					System.out.println("pstmt.close(2): " + e);
					setCursor(new java.awt.Cursor(
							java.awt.Cursor.DEFAULT_CURSOR));
				}
			} else {
				SQL = "INSERT INTO pcs.receive_dates (start_date,start_lab_number) \n"
						+ "   SELECT MAX(start_date)+"
						+ inc
						+ ",? FROM pcs.receive_dates \n";
				pstmt = DbConnection.process().prepareStatement(SQL);
				pstmt.setInt(1, nextStartingLab);
				pstmt.executeUpdate();
				try {
					pstmt.close();
				} catch (SQLException e) {
					System.out.println(e);
					setCursor(new java.awt.Cursor(
							java.awt.Cursor.DEFAULT_CURSOR));
				}
			}
			CallableStatement cstmt;
			cstmt = DbConnection.process().prepareCall(
					"{call pcs.update_receive_dates()}");
			cstmt.executeUpdate();
			try {
				cstmt.close();
			} catch (SQLException e) {
				System.out.println("cstmt.close: " + e);
				setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
			}
		} catch (SQLException e) {
			System.out.println("dayAfterNewYears: " + dayAfterNewYears
					+ " nextYear: " + nextYear + "  " + e);
			setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
		}
		setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
	}

	void deleteReceiveDate(int maxLab) throws Exception {

		try {
			String SQL = "DELETE FROM pcs.receive_dates WHERE start_lab_number = ? \n";
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setInt(1, maxLab);
			pstmt.executeUpdate();
			String year = ("" + maxLab).substring(0, 4) ;
			SQL = "UPDATE pcs.lab_requisitions SET receive_date = NULL \n"
					+ "WHERE lab_number >= ? and lab_number < ?\n";
			pstmt = DbConnection.process().prepareStatement(SQL);
			pstmt.setInt(1, maxLab);
			pstmt.setString(2, year+"800000");
			pstmt.executeUpdate();
			try {
				pstmt.close();
			} catch (SQLException e) {
				System.out.println(e);
			}
		} catch (SQLException e) {
			System.out.println(e);
		}
	}

	void editReceiveDate(int oldLab, int newLab) {
		setCursor(new java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
		try {
			CallableStatement cstmt;
			cstmt = DbConnection.process().prepareCall(
					"{call pcs.edit_receive_date(?,?)}");
			cstmt.setInt(1, oldLab);
			cstmt.setInt(2, newLab);
			cstmt.executeUpdate();
			try {
				cstmt.close();
			} catch (SQLException e) {
				System.out.println(e);
				setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
			}
		} catch (SQLException e) {
			System.out.println(e);
			setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
		}
		setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
	}

	class SymFocus extends java.awt.event.FocusAdapter {
		@Override
		public void focusGained(java.awt.event.FocusEvent event) {
			Object object = event.getSource();
			if (object == rDay00)
				rDay00_focusGained(event);
			else if (object == rEnd00)
				rEnd00_focusGained(event);
			else if (object == rBegin01)
				rBegin01_focusGained(event);
		}
	}

	void rDay00_focusGained(java.awt.event.FocusEvent event) {
		Utils.deselect(event);
	}

	void rEnd00_focusGained(java.awt.event.FocusEvent event) {
		Utils.deselect(event);
	}

	void rBegin01_keyTyped(java.awt.event.KeyEvent event) {
		Utils.forceDigits(event);
	}

	void rBegin01_keyPressed(java.awt.event.KeyEvent event) {
		// to do: code goes here.
	}

	void rBegin01_focusGained(java.awt.event.FocusEvent event) {
		Utils.deselect(event);
	}
	/**
	 * Not Implemented
	 */
	@Override
	public void queryActions() {
		throw new NotImplementedException("Not implemented for ReceivedDateForm");
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
	@Override
	public void resetActions() {
		// TODO Auto-generated method stub
		
	}

}
