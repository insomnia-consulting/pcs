package com.pacytology.pcs;

/*
 PENNSYLVANIA CYTOLOGY SERVICES
 LABORATORY INFORMATION SYSTEM V1.0
 Copyright (C) 2001 by John Cardella
 All Rights Reserved

 File:       HPVReport.java
 Created By: John Cardella, Software Engineer

 Function:   Screen for printing HPV reports.

 MODIFICATIONS ----------------------------------
 Date/Staff      Description:
 */

import java.awt.Dimension;
import java.awt.DisplayMode;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Insets;
import java.awt.PrintJob;
import java.util.Properties;
import java.util.Vector;

import javax.swing.JPanel;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;

import com.pacytology.pcs.db.ExportDbOps;
import com.pacytology.pcs.models.ExportError;

public class HPVReport extends javax.swing.JFrame {
	public Login dbLogin; // database user and general info
	private int startingLabNumber; // starting and ending values used
	private int endingLabNumber; // for non-queued print requests
	private Vector labReportVect = new Vector(); // vector of labReport objects
	public int NUM_REPORTS = 0; // number of reports to be printed
	public int maxY = 0; // vertical place holder
	public String reportDate; // current date
	final int MAX_SOURCE = 29; // max number of source details
	final int MAX_CONDITION = 44; // max number of condition details
	public boolean hasFaxFinals = false;

	private int printMode = Lab.NO_PRINT; // print mode selected
	int numFinals = 0; // number of FINAL reports queued
	private int queueSize = 0; // total reports queued for printing
	private HPVDbOps dbOps; // database operations for this screen
	private LogFile log; // log file for this screen

	/*
	 * Default constructor; builds screen based on values and layout as
	 * indicated using the Visual Cafe form editor.
	 */
	public HPVReport() {
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		// {{INIT_CONTROLS
		setTitle("HPV Reports");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(385, 188);
		setVisible(false);
		startingLab.setEnabled(false);
		getContentPane().add(startingLab);
		startingLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		startingLab.setBounds(138, 38, 90, 20);
		endingLab.setEnabled(false);
		getContentPane().add(endingLab);
		endingLab.setFont(new Font("SansSerif", Font.BOLD, 12));
		endingLab.setBounds(138, 64, 90, 20);
		JLabel1.setText("Starting Lab Number");
		getContentPane().add(JLabel1);
		JLabel1.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel1.setBounds(14, 40, 126, 14);
		JLabel2.setText("Ending Lab Number");
		getContentPane().add(JLabel2);
		JLabel2.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel2.setBounds(14, 66, 126, 14);
		printButton.setText("Retrieve");
		printButton.setActionCommand("Print");
		printButton.setEnabled(false);
		getContentPane().add(printButton);
		printButton.setFont(new Font("Dialog", Font.BOLD, 12));
		printButton.setBounds(60, 94, 82, 24);
		cancelButton.setText("Cancel");
		cancelButton.setActionCommand("Cancel");
		cancelButton.setEnabled(false);
		getContentPane().add(cancelButton);
		cancelButton.setFont(new Font("Dialog", Font.BOLD, 12));
		cancelButton.setBounds(144, 94, 82, 24);
		msgLabel.setText("PLACE HOLDER");
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		msgLabel.setBounds(16, 160, 300, 14);
		printModePanel.setLayout(null);
		getContentPane().add(printModePanel);
		printModePanel.setBounds(252, 42, 124, 90);
		currentFinals.setText("Current Finals");
		currentFinals.setActionCommand("Current Finals");
		printModePanel.add(currentFinals);
		currentFinals.setFont(new Font("Dialog", Font.BOLD, 12));
		currentFinals.setBounds(6, 0, 108, 18);
		finalCopy.setText("Final");
		finalCopy.setActionCommand("jradioButton");
		printModePanel.add(finalCopy);
		finalCopy.setFont(new Font("Dialog", Font.BOLD, 12));
		finalCopy.setBounds(6, 20, 108, 18);
		JLabel3.setText("Select Print Mode:");
		getContentPane().add(JLabel3);
		JLabel3.setFont(new Font("Dialog", Font.BOLD, 12));
		JLabel3.setBounds(256, 20, 126, 14);
		finalsLbl.setText("FINALS:");
		getContentPane().add(finalsLbl);
		finalsLbl.setForeground(java.awt.Color.black);
		finalsLbl.setFont(new Font("Dialog", Font.BOLD, 10));
		finalsLbl.setBounds(290, 138, 50, 14);
		finalPrints.setText("0");
		finalPrints.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		finalPrints.setEnabled(false);
		getContentPane().add(finalPrints);
		finalPrints.setBackground(java.awt.Color.white);
		finalPrints.setFont(new Font("DialogInput", Font.PLAIN, 10));
		finalPrints.setBounds(340, 138, 24, 14);
		titledBorder1.setTitle("COVER SHEETS");
		// $$ titledBorder1.move(72,353);
		// $$ printerConfirm.move(96,353);
		// $$ JOptionPane1.move(96,353);
		// }}

		// {{INIT_MENUS
		// }}

		// {{REGISTER_LISTENERS
		SymAction lSymAction = new SymAction();
		printButton.addActionListener(lSymAction);
		SymFocus aSymFocus = new SymFocus();
		endingLab.addFocusListener(aSymFocus);
		SymKey aSymKey = new SymKey();
		startingLab.addKeyListener(aSymKey);
		endingLab.addKeyListener(aSymKey);
		cancelButton.addActionListener(lSymAction);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		currentFinals.addActionListener(lSymAction);
		finalCopy.addActionListener(lSymAction);
		this.addKeyListener(aSymKey);
		// }}
	}

	/*
	 * Main constructor for the HPV Reports screen; the Login object passed in
	 * holds database user and other misc. data.
	 */
	public HPVReport(Login dbLogin) {
		this();
		setTitle("HPV Reports");
		this.dbLogin = dbLogin;
		// instansiate LogFile object
		this.setLog(new LogFile(dbLogin.logPath, "HPVReport",
				dbLogin.dateToday, dbLogin.userName));
		// instansiate database operations object; takes this object as a param.
		this.setDbOps(new HPVDbOps(this));
		this.resetForm();
		this.setQueueSize(getDbOps().checkQueue());
		this.finalPrints.setText(Integer.toString(numFinals));
	}

	public void setVisible(boolean b) {
		if (b)
			setLocation(50, 50);
		super.setVisible(b);
	}

	static public void main(String args[]) {
		(new HPVReport()).setVisible(true);
	}

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
	javax.swing.JTextField startingLab = new javax.swing.JTextField();
	javax.swing.JTextField endingLab = new javax.swing.JTextField();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JButton printButton = new javax.swing.JButton();
	javax.swing.JButton cancelButton = new javax.swing.JButton();
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	JPanel printModePanel = new JPanel();
	javax.swing.JRadioButton currentFinals = new javax.swing.JRadioButton();
	javax.swing.JRadioButton finalCopy = new javax.swing.JRadioButton();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JLabel finalsLbl = new javax.swing.JLabel();
	javax.swing.JTextField finalPrints = new javax.swing.JTextField();
	javax.swing.border.TitledBorder titledBorder1 = new javax.swing.border.TitledBorder(
			"");
	javax.swing.JOptionPane printerConfirm = new javax.swing.JOptionPane();
	// }}
	private Export eFile;

	// {{DECLARE_MENUS
	// }}

	/*
	 * Method that controls printing of the reports
	 */
	public void hpvReport() throws Exception {
		PrintJob pjob;
		Properties p = new java.util.Properties();
		Graphics pgraphics;
		String name = new String("HPV Report");
		String logMsg = null;
		boolean gotFirstFax = true;
		int x, y;
		if (!verifyReports(getLabReportVect())) {
			Utils.createErrMsg("Insufficent data for HPV report(s)");
			return;
		}

		// set a log file message to indicate print mode selected
		switch (getPrintMode()) {
		case Lab.CURR_FINAL:
			logMsg = "CURR_FINAL";
			break;
		case Lab.FINAL:
			logMsg = "FINAL";
			break;
		case Lab.NO_PRINT:
			logMsg = "NO_PRINT";
			break;
		default:
			logMsg = " ";
		}
		getLog().write("PRINT MODE = " + logMsg);
		getLog().write("REPORTS    = " + getLabReportVect().size());
		boolean displayErrorMsg = false;

		pjob = getToolkit().getPrintJob(this, name, p);
		Vector<LabReportRec> eReports = new Vector<LabReportRec>();
		for (int i = 0; i < getLabReportVect().size(); i++) {
			boolean canPrint = true;
			LabReportRec labReport = (LabReportRec) getLabReportVect()
					.elementAt(i);

			if (labReport.getE_reporting().equals("Y")
					|| labReport.getE_reporting().equals("B")) {
				this.getLog()
						.write("HPV Electronic report being created...  "
								+ DateTime
										.now()
										.toString(
												DateTimeFormat
														.forPattern("dd-MMM-yy hh.mm.ss aa")));
				getLog().write("--------------------");
				getLog().write("LAB:  " + labReport.lab_number);
				getLog().write(
						labReport.prac_name + " (" + labReport.practice + ")");
				getLog().write(
						labReport.pat_lname + ", " + labReport.pat_fname
								+ " : " + labReport.doctor_text);
				eReports.add(labReport);

			}

			if (pjob != null) {
				if (!labReport.getE_reporting().equals("Y")) {
					this.getLog()
							.write("HPV Electronic report printing...  "
									+ DateTime
											.now()
											.toString(
													DateTimeFormat
															.forPattern("dd-MMM-yy hh.mm.ss aa")));
					getLog().write("--------------------");
					getLog().write("LAB:  " + labReport.lab_number);
					getLog().write(
							labReport.prac_name + " (" + labReport.practice
									+ ")");
					getLog().write(
							labReport.pat_lname + ", " + labReport.pat_fname
									+ " : " + labReport.doctor_text);
					if (hasFaxFinals && labReport.send_fax.equals("Y")
							&& gotFirstFax) {
						gotFirstFax = false;
						pgraphics = pjob.getGraphics();
						if (pgraphics != null) {
							getLog().write("PRINTING faxHeader");
							faxHeader(pgraphics);
							pgraphics.dispose();
						}
					}
					/*
					 * Default copies to 1 for HPV reports
					 */
					labReport.report_copies = 1;
					/*
					 * In Current Finals mode if the report is to sent
					 * electronically, then no hard copy; all other modes the
					 * report will get printed to the printer.
					 */
					if (getPrintMode() == Lab.CURR_FINAL) {
						if (labReport.getE_reporting().equals("Y"))
							canPrint = false;
					}
					// for (int j=0;j<labReport.report_copies;j++) {
					if (canPrint) {
						pgraphics = pjob.getGraphics();
						if (pgraphics != null) {
							PCSHeader(pgraphics, labReport); // header part of
																// report
							try {
								labData(pgraphics, labReport);
							} catch (Exception e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
								throw e;
							} // requisition data
							resultsData(pgraphics, labReport); // result data
							pgraphics.dispose();
						}
					}
					// }
					if (hasFaxFinals && i == getLabReportVect().size() - 1) {
						pgraphics = pjob.getGraphics();
						if (pgraphics != null) {
							getLog().write("PRINTING faxTrailer");
							faxTrailer(pgraphics);
							pgraphics.dispose();
						}
					}
				}

				// dequeue the current lab number from the print queue
				// join the export thread before executing getDbOps()

				pjob.end();

			}

		}
		geteFile().write(eReports);
		this.geteFile().getFileExportThread().join();
		if (this.geteFile().getErrors().size() > 0) {

			for (ExportError error : this.geteFile().getErrors()) {
				getLog().write(error.getError());
				for (int i = 0; i < getLabReportVect().size(); i++) {
					if (((LabReportRec) getLabReportVect().elementAt(i)).lab_number == error
							.getLab_number()) {
						getLabReportVect().removeElementAt(i);
					}
				}
				ExportDbOps.insert(error);
				displayErrorMsg = true;
			}
		}
		if (displayErrorMsg) {
			Utils.createErrMsg("Some of the HPVs didn't transmit correctly.  Refer to EXPORT_ERRORS for more information");
		}
		for (int i = 0; i < getLabReportVect().size(); i++) {
			LabReportRec labReport = (LabReportRec) getLabReportVect()
					.elementAt(i);
			getDbOps().dequeue(labReport.lab_number);
		}

	}

	class SymAction implements java.awt.event.ActionListener {
		public void actionPerformed(java.awt.event.ActionEvent event) {
			Object object = event.getSource();
			if (object == printButton)
				printButton_actionPerformed(event);
			else if (object == cancelButton)
				cancelButton_actionPerformed(event);
			if (object == currentFinals)
				currentFinals_actionPerformed(event);
			if (object == finalCopy)
				finalCopy_actionPerformed(event);

		}
	}

	void printButton_actionPerformed(java.awt.event.ActionEvent event) {
		if (printButtonCheck())
			printButtonActions();
	}

	/*
	 * If in a non-queue print mode, make sure that a staring lab number has
	 * been entered; an ending lab number is not required.
	 */
	public boolean printButtonCheck() {
		boolean status = true;
		if (getPrintMode() == Lab.FINAL) {
			if (Utils.isNull(startingLab.getText())) {
				Utils.createErrMsg("Error: Missing Starting Lab");
				startingLab.requestFocus();
				status = false;
			}
		}
		return (status);
	}

	/*
	 * Based on which radio button was selected (which sets the printMode
	 * variable appropriately), convert the starting and ending lab numbers to
	 * values if needed; finally, call the database operation to retrieve data.
	 */
	public void printButtonActions() {
		/*
		 * For non-queue requests must get the values for the range of lab
		 * numbers to print reports for.
		 */
		if (getPrintMode() == Lab.FINAL) {
			setStartingLabNumber((int) Integer.parseInt(startingLab.getText()));
			/*
			 * If there is no ending lab number entered, set the value of the
			 * ending lab to the starting lab; i.e. request was for one report
			 * only.
			 */
			if (Utils.isNull(endingLab.getText()))
				setEndingLabNumber(getStartingLabNumber());
			else {
				/*
				 * If an ending lab number was entered, make sure that the end
				 * value entered is larger than the start value; otherwise
				 * display an error message.
				 */
				setEndingLabNumber((int) Integer.parseInt(endingLab.getText()));
				if (getEndingLabNumber() - getStartingLabNumber() < 0) {
					Utils.createErrMsg("Error: Ending lab less then staring lab");
					endingLab.requestFocus();
					return;
				}
			}
		}
		/*
		 * Database operations object method that retrieves data for the current
		 * set of reports requested
		 */
		getLog().stamp("Calling dbOps.getReports()");
		getDbOps().getReports();
		getLog().stamp("Return dbOps.getReports()");
	}

	/*
	 * Prints the heading section of the report
	 */
	public void PCSHeader(Graphics pgraphics, LabReportRec labReport) {
		int x = 30, y = 46;
		int saveY = y;
		/*
		 * If the type of report is a draft the word "DRAFT" is printed in large
		 * type across the top of the report
		 */
		if ((getPrintMode() == Lab.DRAFT) || (getPrintMode() == Lab.CURR_DRAFT)) {
			x += 75;
			y += 40;
			pgraphics.setFont(new Font("SansSerif", Font.BOLD, 30));
			pgraphics.drawString("*  *  *  *  D  R  A  F  T  *  *  *  *", x, y);
			y += 54;
			pgraphics.drawLine(30, y, 574, y);
			maxY = y;
			return;
		}
		/*
		 * Otherwise format and print the heading information on the report.
		 */
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 14));
		saveY = y;
		pgraphics.drawString("PENNSYLVANIA CYTOLOGY SERVICES", x, y);
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 12));
		y += 14;
		pgraphics.drawString("339 Old Haymaker Road", x, y);
		y += 12;
		pgraphics.drawString("Parkway Building, Suite 1700", x, y);
		y += 12;
		pgraphics.drawString("Monroeville, PA  15146", x, y);
		y += 12;
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 10));
		pgraphics.drawString("Phone: 412.373.8300   Fax: 412.373.7027", x, y);
		x = 499;
		y = saveY;
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 9));
		pgraphics.drawString("CLIA: 39D0656968", x, y);
		x = 409;
		y += 10;
		pgraphics.drawString("Pennsylvania State Laboratory Code: 331", x, y);
		x = 400;
		y += 10;
		pgraphics
				.drawString("College of American Pathologists: 41911-01", x, y);
		x = 388;
		y += 18;
		pgraphics.drawString("Laboratory Director: " + labReport.director_name,
				x, y);
		y += 12;
		pgraphics.drawLine(30, y, 574, y);
		maxY = y;
	}

	class SymFocus extends java.awt.event.FocusAdapter {
		public void focusGained(java.awt.event.FocusEvent event) {
			Object object = event.getSource();
			if (object == endingLab)
				endingLab_focusGained(event);
		}
	}

	void endingLab_focusGained(java.awt.event.FocusEvent event) {
		if (Utils.isNull(startingLab.getText())) {
			Utils.createErrMsg("Error: Missing Starting Lab");
			startingLab.requestFocus();
		}
	}

	class SymKey extends java.awt.event.KeyAdapter {
		public void keyPressed(java.awt.event.KeyEvent event) {
			Object object = event.getSource();
			if (object == HPVReport.this)
				HPVReport_keyPressed(event);
			else if (object == startingLab)
				startingLab_keyPressed(event);
			else if (object == endingLab)
				endingLab_keyPressed(event);

		}

		public void keyTyped(java.awt.event.KeyEvent event) {
			Object object = event.getSource();
			if (object == startingLab)
				startingLab_keyTyped(event);
			else if (object == endingLab)
				endingLab_keyTyped(event);

		}
	}

	void startingLab_keyTyped(java.awt.event.KeyEvent event) {
		msgLabel.setText(null);
		Utils.forceDigits(event);
	}

	void endingLab_keyTyped(java.awt.event.KeyEvent event) {
		Utils.forceDigits(event);
	}

	/*
	 * Formats and prints selected data from the requisition on the report.
	 */
	public void labData(Graphics pgraphics, LabReportRec labReport)
			throws Exception {
		int x, y;
		int gap;
		int saveY = 0;
		int slen;
		StringBuffer buf = new StringBuffer();
		StringBuffer buf2 = new StringBuffer();
		StringBuffer buf3 = new StringBuffer();
		DetailCodeRec dCodeRec = null;

		boolean test = true;

		x = 30;
		y = maxY + 20;
		saveY = y;

		/* PATIENT NAME */
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 10));
		pgraphics.drawString("NAME:", x, y);
		if (!Utils.isNull(labReport.pat_lname))
			buf.append(labReport.pat_lname.trim());
		else
			buf.append("MISSING");
		buf.append(", ");
		if (!Utils.isNull(labReport.pat_fname))
			buf.append(labReport.pat_fname.trim());
		else
			buf.append("MISSING");
		if (!Utils.isNull(labReport.pat_mi))
			buf.append(" " + labReport.pat_mi);
		gap = 86;
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 12));
		pgraphics.drawString(buf.toString(), x + gap, y);

		/* PATIENT SSN */
		/*
		 * Utils.addShortSSN prints only the last four digits of the patient's
		 * SSN, and left pads with pound signs
		 */
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 10));
		if (!Utils.isNull(labReport.pat_ssn)) {
			// if (labReport.practice_type.equals("ADPH"))
			buf = new StringBuffer(Utils.addShortSSN(labReport.pat_ssn));
			// else
			// buf = new StringBuffer(Utils.addSSNMask(labReport.pat_ssn));
			y += 10;
			pgraphics.drawString("SSN:", x, y);
			pgraphics.drawString(buf.toString(), x + gap, y);
		}

		/* PATIENT ID */
		if (!Utils.isNull(labReport.patient_id)) {
			y += 10;
			pgraphics.drawString("PATIENT ID:", x, y);
			pgraphics.drawString(labReport.patient_id, x + gap, y);
		}

		/* PATIENT DOB */
		if (!Utils.isNull(labReport.pat_dob)) {
			y += 10;
			pgraphics.drawString("DOB:", x, y);
			pgraphics.drawString(labReport.pat_dob, x + gap, y);
		}

		/* ACCOUNT NUMBER */
		maxY = y;
		x = 340;
		y = saveY;
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 12));
		if (labReport.practice < 100)
			buf = new StringBuffer("ACCOUNT #0"
					+ Integer.toString(labReport.practice));
		else
			buf = new StringBuffer("ACCOUNT #"
					+ Integer.toString(labReport.practice));
		pgraphics.drawString(buf.toString(), x, y);

		/* PRACTICE NAME */
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 10));
		y += 10;
		gap = 86;
		pgraphics.drawString(labReport.prac_name, x, y);

		/* PRACTICE ADDRESS */
		y += 10;
		if (!Utils.isNull(labReport.prac_address1))
			pgraphics.drawString(labReport.prac_address1, x, y);
		if (!Utils.isNull(labReport.prac_address2)) {
			y += 10;
			pgraphics.drawString(labReport.prac_address2, x, y);
		}

		/* PRACTICE CSZ */
		y += 10;
		if (!Utils.isNull(labReport.prac_city))
			buf2 = new StringBuffer(labReport.prac_city);
		else
			buf2 = new StringBuffer(" ");
		if (!Utils.isNull(labReport.prac_state))
			buf = new StringBuffer(buf2.toString() + ", "
					+ labReport.prac_state);
		else
			buf = new StringBuffer(buf2.toString());
		if (!Utils.isNull(labReport.prac_zip))
			buf2 = new StringBuffer(buf.toString() + " "
					+ Utils.addZipMask(labReport.prac_zip));
		else
			buf2 = new StringBuffer(buf.toString());
		buf = new StringBuffer(buf2.toString());
		pgraphics.drawString(buf.toString(), x, y);

		/* PHYSICIAN */
		y += 14;
		pgraphics.drawString("PHYSICIAN:  ", x, y);
		try {
			slen = labReport.doctor_text.length();
		} catch (Exception e) {
			slen = 0;
		}
		buf = new StringBuffer();
		if (slen > 24)
			buf.append(labReport.doctor_text.substring(0, 24));
		else
			buf.append(labReport.doctor_text);
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 12));
		pgraphics.drawString(buf.toString(), 400, y);

		/* DRAW LINE */
		if (y > maxY)
			maxY = y;
		maxY += 10;
		pgraphics.drawLine(30, maxY, 574, maxY);

		/* LAB DETAILS */
		y = maxY;
		x = 30;
		y += 18;
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 12));
		buf = new StringBuffer("LAB #" + labReport.lab_number);
		/*
		 * switch (labReport.preparation) { case Lab.CONVENTIONAL:
		 * buf.append("    CONVENTIONAL PAP SMEAR"); break; case Lab.THIN_LAYER:
		 * buf.append("   LIQUID BASED PAP TEST (ThinPrep)"); break; case
		 * Lab.CYT_NON_PAP: buf.append("   CYTOLOGY NON-PAP"); break; case
		 * Lab.IMAGED_SLIDE: pgraphics.setFont(new
		 * Font("SansSerif",Font.BOLD,11));
		 * buf.append("   THINPREP PAP TEST WITH IMAGING SYSTEM DUAL REVIEW");
		 * break; }
		 */
		pgraphics.drawString(buf.toString(), x, y);

		/* DATE COLLECTED */
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 9));
		x = 464;
		buf = new StringBuffer("COLLECTED:");
		pgraphics.drawString(buf.toString(), x, y - 4);
		pgraphics.drawString(labReport.date_collected, x + 66, y - 4);

		/* DATE RECEIVED */
		buf = new StringBuffer("RECEIVED:");
		pgraphics.drawString(buf.toString(), x, y + 5);
		if (labReport.receive_date == null) {
			throw new Exception("Lab: " + labReport.lab_number
					+ " does not have a receive date");
		}

		pgraphics.drawString(labReport.receive_date, x + 66, y + 5);

		/* DATE REPORTED */
		buf = new StringBuffer("REPORTED:");
		pgraphics.drawString(buf.toString(), x, y + 14);
		pgraphics.drawString(labReport.date_reported, x + 66, y + 14);

		/* SOURCE INFO */
		int detailY = y + 18;
		saveY = y;
		if (labReport.numSources > 0) {
			x = 30;
			y += 18;
			// saveY=y;
			pgraphics.setFont(new Font("SansSerif", Font.BOLD, 11));
			pgraphics.drawString("SOURCE:", x, y);
			y += 10;
			pgraphics.setFont(new Font("MonoSpaced", Font.PLAIN, 9));
			for (int i = 0; i < labReport.detailVect.size(); i++) {
				dCodeRec = (DetailCodeRec) labReport.detailVect.elementAt(i);
				if (dCodeRec.detail_type.equals("SOURCE")) {
					pgraphics.drawString(dCodeRec.description, x, y);
					y += 10;
				}
			}
		}

		/* SAMPLING DEVICE INFO */
		if (labReport.numDevices > 0) {
			if (labReport.numSources == 0)
				y += 18;
			else
				y += 8;
			x = 30;
			pgraphics.setFont(new Font("SansSerif", Font.BOLD, 11));
			pgraphics.drawString("SAMPLING DEVICE:", x, y);
			y += 10;
			pgraphics.setFont(new Font("MonoSpaced", Font.PLAIN, 9));
			for (int i = 0; i < labReport.detailVect.size(); i++) {
				dCodeRec = (DetailCodeRec) labReport.detailVect.elementAt(i);
				if (dCodeRec.detail_type.equals("DEVICE")) {
					pgraphics.drawString(dCodeRec.description, x, y);
					y += 10;
				}
			}
		}

		/* OTHER INFO */
		if (labReport.numOthers > 0) {
			if (labReport.numSources == 0 && labReport.numDevices == 0)
				y += 18;
			else
				y += 8;
			x = 30;
			pgraphics.setFont(new Font("SansSerif", Font.BOLD, 11));
			pgraphics.drawString("OTHER INFORMATION:", x, y);
			y += 10;
			pgraphics.setFont(new Font("MonoSpaced", Font.PLAIN, 9));
			for (int i = 0; i < labReport.detailVect.size(); i++) {
				dCodeRec = (DetailCodeRec) labReport.detailVect.elementAt(i);
				if (dCodeRec.detail_type.equals("OTHER")) {
					buf = new StringBuffer(dCodeRec.description);
					if (dCodeRec.additional_info.equals("Y")) {
						buf.append(": ");
						buf.append(dCodeRec.textEntered);
					}
					pgraphics.drawString(buf.toString(), x, y);
					y += 10;
				}
			}
		}

		/* CONDITIONS */
		maxY = y;
		if (labReport.numConditions > 0) {
			x = 340;
			y = detailY;
			pgraphics.setFont(new Font("SansSerif", Font.BOLD, 11));
			pgraphics.drawString("CONDITIONS:", x, y);
			y += 12;
			pgraphics.setFont(new Font("MonoSpaced", Font.PLAIN, 9));
			for (int i = 0; i < labReport.detailVect.size(); i++) {
				dCodeRec = (DetailCodeRec) labReport.detailVect.elementAt(i);
				if (dCodeRec.detail_type.equals("CONDITION")) {
					pgraphics.drawString(dCodeRec.description, x, y);
					y += 10;
				}
			}
		}

		/* PATIENT HISTORY */
		if (y >= maxY)
			maxY = y;
		else
			y = maxY;
		x = 30;
		if (labReport.numHistory > 0) {
			if (y < detailY)
				y = detailY;
			if (labReport.numSources == 0 && labReport.numDevices == 0
					&& labReport.numOthers == 0)
				y += 18;
			else
				y += 8;
			pgraphics.setFont(new Font("SansSerif", Font.BOLD, 11));
			pgraphics.drawString("PATIENT HISTORY:", x, y);
			y += 10;
			pgraphics.setFont(new Font("MonoSpaced", Font.PLAIN, 9));
			if (labReport.pat_last_lab > 0) {
				buf = new StringBuffer("PREVIOUS LAB #"
						+ Integer.toString(labReport.pat_last_lab));
				pgraphics.drawString(buf.toString(), x, y);
				y += 10;
			}
			for (int i = 0; i < labReport.detailVect.size(); i++) {
				dCodeRec = (DetailCodeRec) labReport.detailVect.elementAt(i);
				if (dCodeRec.detail_type.equals("HISTORY")) {
					buf = new StringBuffer(dCodeRec.description.trim() + ": "
							+ dCodeRec.textEntered.trim());
					if (Utils.length(buf.toString()) > 100) {
						buf2 = new StringBuffer(buf.toString());
						int endNdx = 0;
						while (Utils.length(buf2.toString()) > 100) {
							for (int j = 0; j < 100; j++) {
								if (buf2.charAt(j) == ' ')
									endNdx = j;
							}
							buf = new StringBuffer(buf2.toString().substring(0,
									endNdx));
							buf3 = new StringBuffer(buf2.toString()
									.substring(endNdx).trim());
							pgraphics.drawString(buf.toString(), x, y);
							buf2 = new StringBuffer("   " + buf3.toString());
							y += 10;
						}
						if (!Utils.isNull(buf2.toString())) {
							pgraphics.drawString(buf2.toString(), x, y);
							y += 10;
						}
					} else {
						pgraphics.drawString(buf.toString(), x, y);
						y += 10;
					}
				}
			}
		}

		/* CLIENT NOTES */
		if (!Utils.isNull(labReport.client_notes)) {
			if (labReport.numSources == 0 && labReport.numDevices == 0
					&& labReport.numOthers == 0 && labReport.numHistory == 0)
				y += 18;
			else
				y += 8;
			pgraphics.setFont(new Font("SansSerif", Font.BOLD, 11));
			pgraphics.drawString("CLIENT NOTES:", x, y);
			y += 10;
			pgraphics.setFont(new Font("MonoSpaced", Font.PLAIN, 9));
			buf = new StringBuffer(labReport.client_notes.trim());
			if (Utils.length(buf.toString()) > 100) {
				buf2 = new StringBuffer(buf.toString());
				int endNdx = 0;
				while (buf2.length() > 100) {
					for (int j = 0; j < 100; j++) {
						if (buf2.charAt(j) == ' ')
							endNdx = j;
					}
					buf = new StringBuffer(buf2.toString().substring(0, endNdx));
					buf2 = new StringBuffer(buf2.toString().substring(endNdx)
							.trim());
					pgraphics.drawString(buf.toString(), x, y);
					buf2 = new StringBuffer("   " + buf2.toString());
					y += 10;
				}
				if (!Utils.isNull(buf2.toString())) {
					pgraphics.drawString(buf2.toString(), x, y);
					y += 10;
				}
			} else {
				pgraphics.drawString(buf.toString(), x, y);
				y += 10;
			}
		}
		if (labReport.numDetails == 0)
			y += 26;
		maxY = y;
		pgraphics.drawLine(30, maxY, 574, maxY);
	}

	/*
	 * Format and print the actual CytoPathology Report section of the report;
	 * includes test results and staff that performed the test.
	 */
	public void resultsData(Graphics pgraphics, LabReportRec labReport) {
		int x, y;
		y = maxY + 26;
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 16));
		pgraphics.drawString("DIGENE HYBRID CAPTURE II HPV TEST", 30, y);
		y += 20;
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 12));
		pgraphics.drawString("Results:", 30, y);
		y += 30;
		String buf = " ";
		String buf2 = " ";

		pgraphics.drawString("High Risk", 30, y);
		String HPVtext = null;
		if (!Utils.isNull(labReport.test_sent)) {
			if (labReport.test_sent.equals("Q")) {
				HPVtext = "Q U A N T I T Y   N O T   S U F F I C I E N T";
			} else if (!Utils.isNull(labReport.test_results)) {
				if (labReport.test_results.equals("+")) {
					HPVtext = "P O S I T I V E";
				} else if (labReport.test_results.equals("-")) {
					HPVtext = "N E G A T I V E";
				}
			}
		}
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 14));
		pgraphics.drawString(HPVtext, 240, y);
		y += 15;
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 12));
		pgraphics.drawString("(HPV types 16, 18, 31, 33", 30, y);
		y += 15;
		pgraphics.drawString("35, 39, 45, 51, 52, 56, 58", 30, y);
		y += 15;
		pgraphics.drawString("59, 68)", 30, y);

		y += 20;
		pgraphics.drawString("Reference Interval: Negative", 30, y);
		y += 20;

		String cytotech = new String("CYTOTECHNOLOGIST:    "
				+ labReport.getCytotech_code().trim());
		if (!Utils.isNull(labReport.qc_cytotech_code))
			cytotech = new String(cytotech + "/" + labReport.qc_cytotech_code);
		pgraphics.setFont(new Font("SansSerif", Font.PLAIN, 10));
		pgraphics.drawString(cytotech, 30, y);
		y += 20;
		pgraphics.drawLine(30, y, 574, y);

	}

	void cancelButton_actionPerformed(java.awt.event.ActionEvent event) {
		getDbOps().kill();
		closingActions();
	}

	class SymWindow extends java.awt.event.WindowAdapter {
		public void windowClosing(java.awt.event.WindowEvent event) {
			Object object = event.getSource();
			if (object == HPVReport.this)
				HPVReport_windowClosing(event);
		}
	}

	void HPVReport_windowClosing(java.awt.event.WindowEvent event) {
		closingActions();
	}

	void currentFinals_actionPerformed(java.awt.event.ActionEvent event) {
		printModeButtonActions();
	}

	void finalCopy_actionPerformed(java.awt.event.ActionEvent event) {
		printModeButtonActions();
	}

	/*
	 * Determines screen flow based on which radio button has been selected.
	 */
	public void printModeButtonActions() {
		currentFinals.setEnabled(false);
		finalCopy.setEnabled(false);
		printModePanel.setEnabled(false);
		if (currentFinals.isSelected() == true) {
			if (numFinals > 0) {
				setPrintMode(Lab.CURR_FINAL);
				startingLab.setEnabled(false);
				endingLab.setEnabled(false);
				cancelButton.setEnabled(true);
				printButton.setEnabled(true);
				printButton.requestFocus();
			} else {
				resetForm();
				Utils.createErrMsg("No HPV Reports to Print!");
				getLog().write("NO HPV REPORTS TO PRINT");
			}
		} else if (finalCopy.isSelected() == true) {
			setPrintMode(Lab.FINAL);
			startingLab.setEnabled(true);
			endingLab.setEnabled(true);
			printButton.setEnabled(true);
			cancelButton.setEnabled(true);
			startingLab.requestFocus();
		}

	}

	void HPVReport_keyPressed(java.awt.event.KeyEvent event) {
		int key = event.getKeyCode();
		if (key == java.awt.event.KeyEvent.VK_ESCAPE) {
			resetForm();
		} else if (key == java.awt.event.KeyEvent.VK_F9) {
			closingActions();
		}
	}

	/*
	 * Resets the HPVReport screen
	 */
	public void resetForm() {
		startingLab.setText(null);
		endingLab.setText(null);
		msgLabel.setText(null);
		startingLab.setEnabled(false);
		endingLab.setEnabled(false);
		printButton.setEnabled(false);
		cancelButton.setEnabled(false);
		printModePanel.setEnabled(true);
		currentFinals.setEnabled(true);
		finalCopy.setEnabled(true);
		setPrintMode(Lab.NO_PRINT);
		NUM_REPORTS = 0;
		maxY = 0;
		reportDate = new String();
	}

	void startingLab_keyPressed(java.awt.event.KeyEvent event) {
		if (event.getKeyCode() == event.VK_ENTER) {
			if (Utils.required(startingLab, "Start Lab")) {
				// startingLab.transferFocus();
				endingLab.setEnabled(false);
				if (printButtonCheck()) {
					printButton.requestFocus();
					printButtonActions();
				}
			}
		}
	}

	void endingLab_keyPressed(java.awt.event.KeyEvent event) {
		if (event.getKeyCode() == event.VK_ENTER) {
			if (printButtonCheck()) {
				printButton.requestFocus();
				printButtonActions();
			}
		}
	}

	/*
	 * Actions performed when screen is terminated; close log file, close
	 * database connection.
	 */
	void closingActions() {
		getLog().stop();
		getDbOps().close();
		this.dispose();
	}

	public boolean verifyReports(Vector v) {
		boolean status = true;
		for (int i = 0; i < v.size(); i++) {
			LabReportRec labReport = (LabReportRec) v.elementAt(i);
			if (!Utils.isNull(labReport.test_sent)) {
				if (!labReport.test_sent.equals("Q")) {
					if (Utils.isNull(labReport.test_results)) {
						status = false;
					}
				}
			} else {
				status = false;
			}
			if (!status)
				break;
		}
		return (status);
	}

	/*
	 * Format and print sheet that indicates the beginning of one or more
	 * reports that must be faxed.
	 */
	public void faxHeader(Graphics pgraphics) {
		int x = 105, y = 105;
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 30));
		pgraphics.drawString("*  *  *  *  B  E  G  I  N  *  *  *  *", x, y);
		y += 54;
		pgraphics.drawString("*  *  *  *  F  A  X  E  S  *  *  *  *", x, y);
	}

	/*
	 * Format and print sheet that indicates the end of the reports that must be
	 * faxed.
	 */
	public void faxTrailer(Graphics pgraphics) {
		int x = 105, y = 105;
		pgraphics.setFont(new Font("SansSerif", Font.BOLD, 30));
		pgraphics.drawString("*  *  *  *  *  E  N  D  *  *  *  *  *", x, y);
		y += 54;
		pgraphics.drawString("*  *  *  *  F  A  X  E  S  *  *  *  *", x, y);
	}

	public int getPrintMode() {
		return printMode;
	}

	public void setPrintMode(int printMode) {
		this.printMode = printMode;
	}

	public int getStartingLabNumber() {
		return startingLabNumber;
	}

	public void setStartingLabNumber(int startingLabNumber) {
		this.startingLabNumber = startingLabNumber;
	}

	public int getEndingLabNumber() {
		return endingLabNumber;
	}

	public void setEndingLabNumber(int endingLabNumber) {
		this.endingLabNumber = endingLabNumber;
	}

	public Vector getLabReportVect() {
		return labReportVect;
	}

	public void setLabReportVect(Vector labReportVect) {
		this.labReportVect = labReportVect;
	}

	LogFile getLog() {
		return log;
	}

	void setLog(LogFile log) {
		this.log = log;
	}

	int getQueueSize() {
		return queueSize;
	}

	void setQueueSize(int queueSize) {
		this.queueSize = queueSize;
	}

	public Export geteFile() {
		return eFile;
	}

	public void seteFile(Export eFile) {
		this.eFile = eFile;
	}

	public HPVDbOps getDbOps() {
		return dbOps;
	}

	public void setDbOps(HPVDbOps dbOps) {
		this.dbOps = dbOps;
	}

}
