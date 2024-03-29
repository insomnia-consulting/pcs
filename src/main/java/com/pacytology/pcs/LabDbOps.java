package com.pacytology.pcs;

/*
 PENNSYLVANIA CYTOLOGY SERVICES
 LABORATORY INFORMATION SYSTEM V1.0
 Copyright (C) 2001 by John Cardella
 All Rights Reserved

 File:       LabDbOps.java
 Created By: John Cardella, Software Engineer

 Function:   Database operations for lab form. Implemented as
 a runnable interface. Add and update operations into Oracle
 are handled as threads. Only one add/update thread may be 
 running while user is entering next set of data.

 MODIFICATIONS ------------------------------------------------------------------
 Date           Description:
 09/17           Changed db access in all methods to use dbConnection class
 connection rather than having separate a separate 
 java.sql.Connection for each class needing one.
 */

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import org.apache.ibatis.session.SqlSession;

import com.pacytology.pcs.models.LabRequisition;

public class LabDbOps implements Runnable {
	Thread dbThread;
	int tLab;
	int tMode;
	LabForm parent;
	LabRec tLabRec;
	DetailCodeRec[] tDetRec;
	final int INIT = (-1);
	final int DIAG_LETTER = 89;
	final int BLANK_LETTER = 90;
	final int BILLING = 91;
	final int PREV_LAB = 92;
	final int FAX = 93;
	final int LAB_NUM = 94;
	final int PATIENT = 95;
	final int ZIP = 96;
	final int CARRIERS = 97;
	final int DOCTORS = 98;
	final int PRACTICES = 99;
	private String drtxt = new String();

	public LabDbOps(LabForm p) {
		parent = p;
		parent.log.write("Database connection opened");
	}

	public synchronized void run() {
		processRequest(tMode);
	}

	private void processRequest(int mode) {
		String methodName = null;
		try {
			switch (mode) {
			case Lab.ADD:
				methodName = "addPatient";
				addPatient();
				methodName = "add";
				add();
				if (tLabRec.preparation == Lab.HPV_ONLY) {
					createIndexFile();
				}
				break;
			case INIT:
				methodName = "queryDetailCodes";
				queryDetailCodes();
				methodName = "queryDiagnosisCodes";
				queryDiagnosisCodes();
				methodName = "queryFaxLetters";
				queryFaxLetters();
				if (parent.currMode != Lab.FATAL) {
					parent.resetLabForm();
					tLabRec = new LabRec();
					tDetRec = new DetailCodeRec[parent.MAX_DET_CODES];
					for (int i = 0; i < parent.MAX_DET_CODES; i++)
						tDetRec[i] = new DetailCodeRec();
				}
				break;
			case Lab.TISSUE_CODES:
				methodName = "queryTissueDetailCodes";
				queryTissueDetailCodes();
				if (parent.currMode != Lab.FATAL) {
					// parent.resetLabForm();
					tLabRec = new LabRec();
					tDetRec = new DetailCodeRec[parent.MAX_DET_CODES];
					for (int i = 0; i < parent.MAX_DET_CODES; i++)
						tDetRec[i] = new DetailCodeRec();
				}
				break;
			case Lab.REQ_CODES:
				methodName = "queryDetailCodes";
				queryDetailCodes();
				break;
			case FAX:
				methodName = "queryFaxLetters";
				queryFaxLetters();
				break;
			case PRACTICES:
				methodName = "queryPracticeInfo";
				boolean rv = queryPracticeInfo(parent.labRec.practice);
				if (rv) {
					methodName = "queryDoctorInfo";
					if (parent.labRec.practice > 0)
						queryDoctorInfo(parent.labRec.practice);
				} else {
					Utils.createErrMsg("Practice #"
							+ (String) parent.labPractice.getText()
							+ " does not exist");
					parent.labPractice.setText(null);
					parent.labPracticeName.setText(null);
					parent.labRec.practice = (-1);
					parent.labRec.pat.practice = (-1);
					parent.labPractice.requestFocus();
				}
				if (!Utils.isNull(drtxt)) {
					parent.doctorText.setText(drtxt);
					drtxt = new String();
				}
				break;
			case DOCTORS:
				methodName = "queryDoctorInfo";
				queryDoctorInfo(parent.labRec.practice);
				break;
			case Lab.UPDATE:
				methodName = "updatePatient";
				updatePatient();
				methodName = "update";
				update();
				break;
			case PATIENT:
				methodName = "updatePatient";
				break;
			case ZIP:
				String zip5 = parent.labZip.getText().substring(0, 5);
				methodName = "queryZip";
				queryZip(zip5);
				break;
			case CARRIERS:
				methodName = "queryCarrier";
				queryCarrier();
				parent.carrierChanged = false;
				if (parent.carrierVect.size() == 1) {
					parent.labOtherInsurance.setText(parent.labRec.name);
					parent.labPayerID.setText(parent.labRec.payer_id);
					parent.labPCSID.setText(Integer
							.toString(parent.labRec.pcs_payer_id));
					parent.checkCarrier = false;
				}
				break;
			case LAB_NUM:
				methodName = "queryLabNumber";
				queryLabNumber();
				break;
			case Lab.QUERY:
				methodName = "query";
				query();
				break;
			case PREV_LAB:
				methodName = "queryLastLab";
				queryLastLab();
				break;
			case BILLING:
				methodName = "checkBillingInfo";
				checkBillingInfo();
				break;
			case BLANK_LETTER:
				methodName = "buildBlankLetter";
				buildBlankLetter();
				break;
			case DIAG_LETTER:
				methodName = "buildDiagnosisLetter";
				buildDiagnosisLetter();
				break;
			}
		} catch (SQLException e) {
			parent.log.write("SQL ERROR: " + methodName);
			parent.log.write(e);
			e.printStackTrace();
			Utils.createErrMsg(e.toString(), "ERROR: " + methodName);
		} catch (Exception e) {
			parent.log.write("ERROR: " + methodName);
			parent.log.write(e);
			e.printStackTrace();
			Utils.createErrMsg(e.toString(), "ERROR: " + methodName);
		} finally {
			parent.msgLabel.setText(null);
			parent.dbThreadRunning = false;
		}
	}

	public void labFormInit() {
		parent.msgLabel.setText("INITIALIZING ...");
		tMode = INIT;
		parent.dbThreadRunning = true;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MAX_PRIORITY);
		dbThread.start();
	}

	public void getDetailCodes() {
		tMode = Lab.REQ_CODES;
		parent.dbThreadRunning = true;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MAX_PRIORITY);
		dbThread.start();
	}

	public void getTissueDetailCodes() {
		tMode = Lab.TISSUE_CODES;
		parent.dbThreadRunning = true;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MAX_PRIORITY);
		dbThread.start();
	}

	public void getZipInfo() {
		tMode = ZIP;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MIN_PRIORITY);
		dbThread.start();
	}

	public void updatePatientData() {
		tMode = PATIENT;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MIN_PRIORITY);
		dbThread.start();
	}

	public void getPracticeInfo() {
		tMode = PRACTICES;
		parent.dbThreadRunning = true;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MAX_PRIORITY);
		dbThread.start();
	}

	public void getPracticeInfo(String d) {
		drtxt = d;
		getPracticeInfo();
	}

	public void getDoctorInfo() {
		tMode = DOCTORS;
		parent.dbThreadRunning = true;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MAX_PRIORITY);
		dbThread.start();
	}

	public void getCarrierInfo() {
		tMode = CARRIERS;
		parent.dbThreadRunning = true;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MAX_PRIORITY);
		dbThread.start();
	}

	public void checkLabNumber(int labNumber) {
		tMode = LAB_NUM;
		tLab = labNumber;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MIN_PRIORITY);
		dbThread.start();
	}

	public void getFaxLetters() {
		tMode = FAX;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MIN_PRIORITY);
		dbThread.start();
	}

	synchronized void DB_action() {
		tMode = parent.currMode;
		copyLabData();
		parent.dbThreadRunning = true;
		dbThread = new Thread(this);
		dbThread.setPriority(Thread.MAX_PRIORITY);
		dbThread.start();
	}

	public void getLastLab() {
		processRequest(PREV_LAB);
	}

	public void checkBilling() {
		processRequest(BILLING);
	}

	public void getRequisition() {
		processRequest(Lab.QUERY);
	}

	public void blankLetter() {
		processRequest(BLANK_LETTER);
	}

	public void diagnosisLetter() {
		processRequest(DIAG_LETTER);
	}

	private void queryFaxLetters() throws SQLException, Exception {
		int rowsReturned = 0;
		String SQL = "SELECT lab_number,letter_type,in_queue,TO_CHAR(date_sent,'MM/DD/YYYY') \n"
				+ "FROM pcs.fax_letters WHERE origin=1 ORDER BY lab_number";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(SQL);
		while (rs.next()) {
			FaxLetters faxLetter = new FaxLetters();
			faxLetter.lab_number = rs.getInt(1);
			faxLetter.letter_type = rs.getString(2);
			faxLetter.in_queue = rs.getInt(3);
			faxLetter.date_sent = rs.getString(4);
			parent.faxLetterQueue.addElement(faxLetter);
		}
		rs.close();
		stmt.close();
	}

	private void queryDiagnosisCodes() throws SQLException, Exception {
		Vector v = new Vector();
		String SQL = "SELECT diagnosis_code,description \n"
				+ "FROM pcs.diagnosis_codes \n" + "WHERE active_status='A' \n"
				+ "ORDER BY diagnosis_code";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(SQL);
		while (rs.next()) {
			DiagnosisCodeRec dRec = new DiagnosisCodeRec();
			dRec.diagnosis_code = rs.getString(1);
			dRec.description = rs.getString(2);
			dRec.formattedString = dRec.diagnosis_code;
			for (int i = dRec.formattedString.length(); i < 6; i++)
				dRec.formattedString = dRec.formattedString + " ";
			dRec.formattedString = dRec.formattedString + "  "
					+ dRec.description;
			v.addElement(dRec);
		}
		rs.close();
		stmt.close();
		if (v.size() > 0) {
			parent.MAX_DIAG_CODES = v.size();
			parent.labDiagnosisCodes = new DiagnosisCodeRec[v.size()];
			parent.diagnosisCodeList = new String[v.size()];
			for (int i = 0; i < v.size(); i++) {
				DiagnosisCodeRec dRec = (DiagnosisCodeRec) v.elementAt(i);
				parent.labDiagnosisCodes[i] = dRec;
				parent.diagnosisCodeList[i] = dRec.diagnosis_code;
			}
		}
	}

	private void queryDetailCodes() throws SQLException, DataNotFoundException,
			Exception {
		Vector v = new Vector();
		String SQL = "SELECT detail_code,description,additional_info \n"
				+ "FROM pcs.detail_codes \n"
				+ "WHERE is_tissue<>'T' AND is_tissue<>'H' \n"
				+ "ORDER BY detail_code \n";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(SQL);
		while (rs.next()) {
			DetailCodeRec d = new DetailCodeRec();
			d.detail_code = rs.getInt(1);
			d.description = rs.getString(2);
			d.additional_info = rs.getString(3);
			v.addElement(d);
		}
		if (v.size() == 0) {
			stmt.close();
			rs.close();
			parent.currMode = Lab.FATAL;
			throw new DataNotFoundException("queryDetailCodes()");
		}
		parent.MAX_DET_CODES = v.size();
		parent.detailRec = new DetailCodeRec[v.size()];
		parent.selectedDetCodes = new int[v.size()];
		parent.resetSelectedDetails() ; 
		parent.detCodeDisp = new String[v.size()];
		String[] s = new String[v.size()];
		for (int i = 0; i < v.size(); i++) {
			DetailCodeRec d = (DetailCodeRec) v.elementAt(i);
			parent.detailRec[i] = d;
			s[i] = Integer.toString(d.detail_code) + " " + d.description;
		}
		parent.labDetailList.setListData(s);
		parent.labDetailList.revalidate();
		parent.labDetailList.repaint();
		stmt.close();
		rs.close();
	}

	private void queryLastLab() throws SQLException, DataNotFoundException,
			Exception {
		int labNum = (int) Integer.parseInt(parent.labPrevLabNum.getText());
		int patient = 0;
		String preLookup = "SELECT patient FROM pcs.lab_requisitions \n"
				+ "WHERE lab_number = " + labNum + " \n";
		String SQL = "SELECT \n" + "   pat.patient, \n" + /* 01 */
		"   pat.lname, \n" + /* 02 */
		"   pat.fname, \n" + /* 03 */
		"   pat.ssn, \n" + /* 04 */
		"   pat.address1, \n" + /* 05 */
		"   pat.city, \n" + /* 06 */
		"   pat.state, \n" + /* 07 */
		"   pat.zip, \n" + /* 08 */
		"   TO_CHAR(pat.dob,'MMDDYYYY'), \n" + /* 09 */
		"   labs.practice, \n" + /* 10 */
		"   prac.stop_code, \n" + /* 11 */
		"   labs.doctor, \n" + /* 12 */
		"   labs.billing_choice, \n" + /* 13 */
		"   prac.client_notes, \n" + /* 14 */
		"   prac.name, \n" + /* 15 */
		"   prac.patient_cards, \n" + "   labs.doctor_text, \n"
				+ "   prac.active_status, \n" + "   pat.phone, \n"
				+ "   pat.last_lab, \n" + "   pat.mi, \n" + "   pat.race \n"
				+ "FROM \n" + "   pcs.patients pat, \n"
				+ "   pcs.lab_requisitions labs, \n"
				+ "   pcs.practices prac \n" + "WHERE \n"
				+ "   pat.patient=labs.patient and \n"
				+ "   labs.practice=prac.practice and \n"
				+ "   pat.last_lab=labs.lab_number and \n";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(preLookup);
		while (rs.next()) {
			patient = rs.getInt(1);
		}
		if (patient > 0) {
			preLookup = "SELECT last_lab FROM pcs.patients \n"
					+ "WHERE patient = " + patient + " \n";
			rs = stmt.executeQuery(preLookup);
			while (rs.next()) {
				labNum = rs.getInt(1);
			}
		}
		SQL += "   pat.last_lab=" + labNum + " \n";
		rs = stmt.executeQuery(SQL);
		int rowsReturned = 0;
		parent.labRec.fillClientNotes = false;
		String cl_notes = " ";
		while (rs.next()) {
			rowsReturned++;
			parent.labRec.pat.patient = rs.getInt(1);
			parent.labRec.pat.lname = rs.getString(2);
			if (!rs.wasNull())
				parent.labRec.pat.pNameFmt = parent.labRec.pat.lname.trim();
			parent.labRec.pat.fname = rs.getString(3);
			if (!rs.wasNull())
				parent.labRec.pat.pNameFmt = parent.labRec.pat.pNameFmt + ", "
						+ parent.labRec.pat.fname.trim();
			parent.labRec.pat.ssn = rs.getString(4);
			parent.labRec.pat.address1 = rs.getString(5);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.address1.trim();
			parent.labRec.pat.city = rs.getString(6);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.pAddrFmt + ", "
						+ parent.labRec.pat.city.trim();
			parent.labRec.pat.state = rs.getString(7);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.pAddrFmt + ", "
						+ parent.labRec.pat.state.trim();
			parent.labRec.pat.zip = rs.getString(8);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.pAddrFmt + " "
						+ parent.labRec.pat.zip.trim();
			parent.labRec.pat.dob = rs.getString(9);
			parent.labRec.pat.practice = rs.getInt(10);
			parent.labRec.stop_code = rs.getString(11);
			parent.labRec.doctor = rs.getInt(12);
			parent.originalBillingChoice = parent.labRec.billing_choice = rs
					.getInt(13);
			cl_notes = rs.getString(14);
			parent.labRec.practice_name = rs.getString(15);
			parent.labRec.patient_cards = rs.getString(16);
			parent.labRec.doctor_text = rs.getString(17);
			parent.labRec.prac_status = rs.getString(18);
			parent.labRec.pat.phone = rs.getString(19);
			parent.labRec.pat.mi = rs.getString(21);
			parent.labRec.pat.race = rs.getString(22);
		}
		if (rowsReturned > 0) {
			parent.labRec.pat.last_lab = labNum;
			parent.labPrevLabNum.setText(Integer
					.toString(parent.labRec.pat.last_lab));
			parent.labRec.practice = parent.labRec.pat.practice;
			parent.msgLabel.setText("Previous Lab Located");
			parent.labPracticeName.setText(parent.labRec.practice_name);
			if (cl_notes.compareTo("Y") == 0) {
				parent.labRec.fillClientNotes = true;
			} else {
				parent.labRec.fillClientNotes = false;
			}
			SQL = "SELECT \n" + "   a.carrier_id,a.id_number, \n"
					+ "   a.group_number,a.subscriber,a.sub_lname, \n"
					+ "   a.sub_fname,a.medicare_code, \n"
					+ "   a.rebilling,c.name,c.state,a.billing_choice, \n"
					+ "   c.payer_id,NVL(c.id_number,0) \n" + "FROM \n"
					+ "   pcs.billing_details a, \n"
					+ "   pcs.lab_requisitions b, \n" + "   pcs.carriers c \n"
					+ "WHERE \n" + "   a.lab_number=" + labNum + " and \n"
					+ "   a.lab_number=b.lab_number and \n"
					+ "   a.carrier_id=c.carrier_id(+) and \n"
					+ "   a.rebilling=0 \n";
			rs = stmt.executeQuery(SQL);
			rowsReturned = 0;
			while (rs.next()) {
				rowsReturned++;
				parent.labRec.carrier_id = rs.getInt(1);
				parent.labRec.id_number = rs.getString(2);
				parent.labRec.group_number = rs.getString(3);
				parent.labRec.subscriber = rs.getString(4);
				if (rs.wasNull())
					parent.labRec.subscriber = " ";
				parent.labRec.sub_lname = rs.getString(5);
				parent.labRec.sub_fname = rs.getString(6);
				parent.labRec.medicare_code = rs.getString(7);
				parent.labRec.rebilling = rs.getInt(8);
				parent.labRec.name = rs.getString(9);
				parent.labRec.state = rs.getString(10);
				parent.labRec.billing_choice = rs.getInt(11);
				parent.labRec.payer_id = rs.getString(12);
				parent.labRec.pcs_payer_id = rs.getInt(13);
			}
			if (rowsReturned > 0)
				parent.foundPrevLab = true;
			else
				parent.foundPrevLab = false;
		}
	}

	private void query() throws SQLException, DataNotFoundException, Exception {
		ResultSet rs = null;
		Statement stmt = null;
		int labNum = (int) Integer.parseInt(parent.labNumber.getText());
		String SQL = "SELECT \n"
				+ "   lab.patient, \n"
				+ // 01
				"   lab.practice,\n"
				+ // 02
				"   lab.doctor, \n"
				+ // 03
				"   lab.patient_id, \n"
				+ // 04
				"   lab.slide_qty, \n"
				+ // 05
				"   TO_CHAR(lab.date_collected,'MMDDYYYY'), \n"
				+ // 06
				"   lab.lmp, \n"
				+ // 07
				"   lab.rush, \n"
				+ // 08
				"   bd.billing_choice, \n"
				+ // 09
				"   lab.finished, \n"
				+ // 10
				"   NULL, \n"
				+ // 11
				"   bd.carrier_id, \n"
				+ // 12
				"   bd.id_number, \n"
				+ // 13
				"   bd.group_number, \n"
				+ // 14
				"   bd.subscriber, \n"
				+ // 15
				"   bd.sub_lname, \n"
				+ // 16
				"   bd.sub_fname, \n"
				+ // 17
				"   TO_CHAR(bd.sign_date,'MMDDYYYY'), \n"
				+ // 18
				"   bd.medicare_code, \n"
				+ // 19
				"   bd.rebilling, \n"
				+ // 20
				"   pat.lname, \n"
				+ // 21
				"   pat.fname, \n"
				+ // 22
				"   pat.address1, \n"
				+ // 23
				"   pat.city, \n"
				+ // 24
				"   pat.state, \n"
				+ // 25
				"   pat.zip, \n"
				+ // 26
				"   pat.ssn, \n"
				+ // 27
				"   TO_CHAR(pat.dob,'MMDDYYYY'), \n"
				+ // 28
				"   cn.client_notes, \n"
				+ // 29
				"   c.name, \n"
				+ // 30
				"   c.state, \n"
				+ // 31
				"   lab.age, \n"
				+ // 32
				"   lab.preparation, \n"
				+ // 33
				"   c.payer_id, \n"
				+ // 34
				"   NVL(c.id_number,0), \n"
				+ // 35
				"   pat.last_lab, \n"
				+ // 36
				"   lab.previous_lab, \n"
				+ // 37
				"   ppd.check_number, \n"
				+ // 38
				"   ppd.payment_amount, \n"
				+ // 39
				"   ppd.additional_info, \n"
				+ // 40
				"   lab.doctor_text, \n"
				+ // 41
				"   TO_CHAR(bd.datestamp,'MM/DD/YY HH:Mi'), \n"
				+ // 42
				"   bd.sys_user, \n"
				+ // 43
				"   TO_CHAR(bd.change_date,'MM/DD/YY HH:Mi'), \n"
				+ // 44
				"   bd.change_user, \n"
				+ // 45
				"   pr.active_status, \n"
				+ // 46
				"   TO_CHAR(lab.receive_date,'MMDDYYYY'), \n"
				+ // 47
				"   pat.phone, \n"
				+ // 48
				"   pat.mi, \n"
				+ // 49
				"   pat.race, \n"
				+ // 50
				"   pr.parent_account, \n"
				+ // 51
				"   pr.program, \n"
				+ // 52
				"   pr.e_reporting, \n"
				+ // 53
				"   pr.practice_type \n"
				+ // 54
				"FROM \n" + "   pcs.lab_requisitions lab, \n"
				+ "   pcs.billing_details bd, \n" + "   pcs.carriers c, \n"
				+ "   pcs.patients pat, \n"
				+ "   pcs.lab_req_client_notes cn, \n"
				+ "   pcs.prepaid_labs ppd, \n" + "   pcs.practices pr \n"
				+ "WHERE \n" + "   lab.lab_number=cn.lab_number(+) and \n"
				+ "   lab.lab_number=ppd.lab_number(+) and \n"
				+ "   lab.lab_number=bd.lab_number and \n"
				+ "   lab.practice=pr.practice and \n"
				+ "   bd.carrier_id=c.carrier_id(+) and \n"
				+ "   lab.patient=pat.patient and \n" + "   lab.lab_number="
				+ labNum + " and \n" + "   bd.rebilling IN \n"
				+ "       (SELECT max(rebilling) \n"
				+ "        FROM pcs.billing_details \n"
				+ "        WHERE lab_number=" + labNum
				+ " AND billing_level<>'PRT') \n";

		stmt = DbConnection.process().createStatement();
		rs = stmt.executeQuery(SQL);
		int rowsReturned = 0;
		while (rs.next()) {
			rowsReturned++;
			parent.labRec.patient = rs.getInt(1);
			parent.labRec.practice = rs.getInt(2);
			parent.labRec.doctor = rs.getInt(3);
			parent.labRec.patient_id = rs.getString(4);
			parent.labRec.slide_qty = rs.getInt(5);
			parent.labRec.date_collected = rs.getString(6);
			parent.labRec.lmp = rs.getString(7);
			parent.labRec.rush = rs.getString(8);
			parent.originalBillingChoice = parent.labRec.billing_choice = rs
					.getInt(9);
			parent.labRec.finished = rs.getInt(10);
			parent.labRec.lab_comments = rs.getString(11);
			parent.labRec.carrier_id = rs.getInt(12);
			parent.labRec.id_number = rs.getString(13);
			parent.labRec.group_number = rs.getString(14);
			parent.labRec.subscriber = rs.getString(15);
			parent.labRec.sub_lname = rs.getString(16);
			parent.labRec.sub_fname = rs.getString(17);
			parent.labRec.sign_date = rs.getString(18);
			parent.labRec.medicare_code = rs.getString(19);
			parent.labRec.rebilling = rs.getInt(20);
			parent.labRec.pat.lname = rs.getString(21);
			if (!rs.wasNull())
				parent.labRec.pat.pNameFmt = parent.labRec.pat.lname.trim();
			parent.labRec.pat.fname = rs.getString(22);
			if (!rs.wasNull())
				parent.labRec.pat.pNameFmt = parent.labRec.pat.pNameFmt + ", "
						+ parent.labRec.pat.fname.trim();
			parent.labRec.pat.address1 = rs.getString(23);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.address1.trim();
			parent.labRec.pat.city = rs.getString(24);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.pAddrFmt + ", "
						+ parent.labRec.pat.city.trim();
			parent.labRec.pat.state = rs.getString(25);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.pAddrFmt + ", "
						+ parent.labRec.pat.state.trim();
			parent.labRec.pat.zip = rs.getString(26);
			if (!rs.wasNull())
				parent.labRec.pat.pAddrFmt = parent.labRec.pat.pAddrFmt + " "
						+ parent.labRec.pat.zip.trim();
			parent.labRec.pat.ssn = rs.getString(27);
			parent.labRec.pat.dob = rs.getString(28);
			parent.labRec.client_note_text = rs.getString(29);
			parent.labRec.name = rs.getString(30);
			parent.labRec.state = rs.getString(31);
			parent.labRec.age = rs.getInt(32);
			parent.labRec.preparation = rs.getInt(33);
			parent.labRec.payer_id = rs.getString(34);
			parent.labRec.pcs_payer_id = rs.getInt(35);
			parent.labRec.pat.last_lab = rs.getInt(36);
			parent.labRec.previous_lab = rs.getInt(37);
			parent.labRec.check_number = rs.getInt(38);
			if (parent.labRec.check_number < 0)
				parent.labRec.payment_type = "CASH";
			else
				parent.labRec.payment_type = "CHECK";
			parent.labRec.payment_amount = rs.getDouble(39);
			parent.labRec.payment_info = rs.getString(40);
			parent.labRec.doctor_text = rs.getString(41);
			parent.labRec.create_date = rs.getString(42);
			int uid = rs.getInt(43);
			parent.labRec.create_user = parent.dbLogin.getUserName(uid);
			parent.labRec.change_date = rs.getString(44);
			uid = rs.getInt(45);
			parent.labRec.change_user = parent.dbLogin.getUserName(uid);
			parent.labRec.prac_status = rs.getString(46);
			parent.labRec.receive_date = rs.getString(47);
			parent.labRec.pat.phone = rs.getString(48);
			parent.labRec.pat.mi = rs.getString(49);
			parent.labRec.pat.race = rs.getString(50);
			parent.labRec.parent_account = rs.getInt(51);
			parent.labRec.program = rs.getString(52);
			parent.labRec.e_reporting = rs.getString(53);
			parent.labRec.prac.practice_type = rs.getString(54);
		}
		rs.close();
		stmt.close();
		if (rowsReturned > 0) {
			parent.labRec.lab_number = labNum;
			parent.labRec.pat.patient = parent.labRec.patient;
			parent.labRec.pat.practice = parent.labRec.practice;
			int currDetail;
			String currComments;
			SQL = "SELECT \n" + "   ld.detail_code, \n"
					+ "   ldc.comment_text \n" + "FROM \n"
					+ "   pcs.lab_req_details ld, \n"
					+ "   pcs.lab_req_details_additional ldc \n" + "WHERE \n"
					+ "   ld.detail_id=ldc.detail_id(+) and \n"
					+ "   ld.lab_number=" + labNum + " \n"
					+ "ORDER BY ld.detail_code \n";
			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(SQL);
			while (rs.next()) {
				currDetail = rs.getInt(1);
				currComments = rs.getString(2);
				if (currDetail == 98)
					parent.labRec.hpv.hpvSource = "P";
				else if (currDetail == 99)
					parent.labRec.hpv.hpvSource = "V";
				else {
					for (int i = 0; i < parent.MAX_DET_CODES; i++) {
						
						try {
							if (currDetail == parent.detailRec[i].detail_code) {
								parent.selectedDetCodes[i] = i;
								parent.detailRec[i].isSelected = true;
								if (!rs.wasNull())
									parent.detailRec[i].textEntered = new String(
											currComments);
								break;
							} else if (parent.selectedDetCodes[i] < 0)
								parent.selectedDetCodes[i] = (-1);
						} catch (Exception e) {
							e.printStackTrace();
							parent.log.write("***************************************************");
							parent.log.write("Error while viewing detail codes: " + e.getMessage());
							parent.log.write("currDetail was " + currDetail);
							parent.log.write("parent was " + parent.toString());
							parent.log.write("parent.detailRec was " + parent.detailRec.toString());
							parent.log.write("parent.detailRec[i] was " + parent.detailRec[i].toString());
							parent.log.write("***************************************************");
						}
					}
				}
			}
			rs.close();
			stmt.close();
			SQL = "SELECT d_seq,diagnosis_code \n"
					+ "FROM pcs.lab_req_diagnosis \n" + "WHERE lab_number="
					+ labNum + " \n" + "AND rebilling="
					+ parent.labRec.rebilling + " \n" + "ORDER BY d_seq";
			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(SQL);
			while (rs.next()) {
				int d_seq = rs.getInt(1);
				String d_code = rs.getString(2);
				if (parent.labRec.billing_choice == Lab.MED) {
					if (d_code.equals("V72.6"))
						d_code = Utils.LAB_MED_DIAGCODE;
				}
				if (d_seq == 1)
					parent.labRec.diagnosis_code = d_code;
				else if (d_seq == 2)
					parent.labRec.diagnosis_code2 = d_code;
				else if (d_seq == 3)
					parent.labRec.diagnosis_code3 = d_code;
				else if (d_seq == 4)
					parent.labRec.diagnosis_code4 = d_code;
			}
			rs.close();
			stmt.close();
			SQL = "SELECT letter_type,in_queue, \n"
					+ "   TO_CHAR(date_sent,'MMDDYYYY'),origin \n"
					+ "FROM pcs.fax_letters \n" + "WHERE lab_number=" + labNum
					+ " \n";
			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(SQL);
			while (rs.next()) {
				parent.labRec.billing.letter_type = rs.getString(1);
				parent.labRec.billing.in_queue = rs.getInt(2);
				parent.labRec.billing.date_sent = rs.getString(3);
				parent.labRec.billing.origin = rs.getInt(4);
			}
			rs.close();
			stmt.close();
		} else
			throw new DataNotFoundException("Lab #" + labNum);
		if (rowsReturned > 0) {
			int inQueue = 0;
			switch (parent.labRec.finished) {
			case -1:
				if (parent.labRec.preparation == Lab.EXPIRED)
					parent.currArea = Lab.EXPIRED_SPECIMEN;
				else
					parent.currArea = Lab.UNUSED;
				break;
			case 0:
				parent.currArea = Lab.RESULTS_PENDING;
				break;
			case 1:
				SQL = "SELECT count(*) FROM pcs.billing_queue \n"
						+ "WHERE lab_number=" + labNum + " \n";
				stmt = DbConnection.process().createStatement();
				rs = stmt.executeQuery(SQL);
				while (rs.next()) {
					inQueue = rs.getInt(1);
				}
				if (inQueue > 0)
					parent.currArea = Lab.BILLING_QUEUE;
				else
					parent.currArea = Lab.UNKNOWN;
				break;
			case 2:
				parent.currArea = Lab.SUBMITTED;
				break;
			case 3:
				parent.currArea = Lab.PENDING;
				break;
			case 4:
				parent.currArea = Lab.FINISHED;
				break;
			}
			rs.close();
			stmt.close();
			if (!Utils.isNull(parent.labRec.billing.letter_type))
				parent.currArea = Lab.FAX_QUEUE;
			else if (parent.currArea == Lab.IDLE)
				parent.currArea = Lab.UNKNOWN;
			if (parent.labRec.preparation == Lab.THIN_LAYER
					|| parent.labRec.preparation == Lab.HPV_ONLY
					|| parent.labRec.preparation == Lab.IMAGED_SLIDE) {
				SQL = "SELECT test_sent,test_results, \n"
						+ "   TO_CHAR(results_received,'MMDDYYYY'), \n"
						+ "   comment_text,TO_CHAR(datestamp,'MMDDYYYY'), \n"
						+ "   hpv_code, \n" + "   hpv_lab \n"
						+ "FROM pcs.hpv_requests \n" + "WHERE lab_number = "
						+ parent.labRec.lab_number + " \n";
				stmt = DbConnection.process().createStatement();
				rs = stmt.executeQuery(SQL);
				parent.labRec.hpv.requested = "N";
				while (rs.next()) {
					parent.labRec.hpv.requested = "Y";
					parent.labRec.hpv.test_sent = rs.getString(1);
					parent.labRec.hpv.test_results = rs.getString(2);
					parent.labRec.hpv.results_received = rs.getString(3);
					parent.labRec.hpv.comment_text = rs.getString(4);
					parent.labRec.hpv.datestamp = rs.getString(5);
					parent.labRec.hpv.hpv_code = rs.getString(6);
					parent.labRec.hpv.hpv_lab = rs.getString(7);
				}
				// parent.labRec.hpv.setMsg();
				if (parent.labRec.hpv.requested.equals("Y")) {
					if (Utils.isNull(parent.labRec.hpv.test_sent)
							|| parent.labRec.hpv.test_sent.equals("R")
							|| parent.labRec.hpv.test_sent.equals("P")) {
						parent.currArea = Lab.HPV_PENDING;
					}
				}
				rs.close();
				stmt.close();
			}
			SQL = "SELECT ADPH_program from pcs.adph_lab_whp \n"
					+ "WHERE lab_number = " + parent.labRec.lab_number + " \n";
			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(SQL);
			while (rs.next()) {
				parent.labRec.ADPH_program = rs.getString(1);
			}
			rs.close();
			stmt.close();
			SQL = "SELECT statement_id||practice||'-'||billing_cycle \n"
					+ "FROM pcs.practice_statement_labs A, pcs.billing_queue B \n"
					+ "WHERE A.lab_number=B.lab_number \n"
					+ "AND B.lab_number=" + parent.labRec.lab_number + " \n"
					+ "AND A.practice=" + parent.labRec.practice + " \n";
			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(SQL);
			while (rs.next()) {
				parent.labRec.invoice = rs.getString(1);
			}
			rs.close();
			stmt.close();
		}
		queryPracticeInfo(parent.labRec.practice);
		queryDoctorInfo(parent.labRec.practice);
		parent.labRec.hpv.setMsg();
	}

	public boolean add() {
		CallableStatement cstmt = null;
		boolean exitStatus = true;
		try {
			cstmt = DbConnection
					.process()
					.prepareCall(
							"{call pcs.lab_reqs_add(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)}");
			cstmt.setInt(1, tLabRec.lab_number);
			cstmt.setInt(2, tLabRec.patient);
			cstmt.setInt(3, tLabRec.practice);
			cstmt.setInt(4, tLabRec.doctor);
			cstmt.setString(5, tLabRec.patient_id);
			cstmt.setString(6, tLabRec.diagnosis_code);
			cstmt.setString(7, tLabRec.diagnosis_code2);
			cstmt.setString(8, tLabRec.diagnosis_code3);
			cstmt.setString(9, tLabRec.diagnosis_code4);
			cstmt.setInt(10, tLabRec.slide_qty);
			cstmt.setString(11, tLabRec.date_collected);
			cstmt.setString(12, tLabRec.lmp);
			cstmt.setString(13, tLabRec.rush);
			cstmt.setInt(14, tLabRec.billing_choice);
			cstmt.setInt(15, tLabRec.carrier_id);
			cstmt.setString(16, tLabRec.id_number);
			cstmt.setString(17, tLabRec.group_number);
			cstmt.setString(18, tLabRec.subscriber);
			cstmt.setString(19, tLabRec.sub_lname);
			cstmt.setString(20, tLabRec.sub_fname);
			cstmt.setString(21, tLabRec.sign_date); 
			cstmt.setString(22, tLabRec.medicare_code);
			cstmt.setString(23, tLabRec.client_note_text);
			cstmt.setString(24, tLabRec.lab_comments);
			cstmt.setInt(25, tLabRec.age);
			cstmt.setInt(26, tLabRec.preparation);
			cstmt.setInt(27, tLabRec.previous_lab);
			cstmt.setInt(28, tLabRec.check_number);
			cstmt.setDouble(29, tLabRec.payment_amount);
			cstmt.setString(30, tLabRec.payment_info);
			cstmt.setString(31, tLabRec.doctor_text);
			cstmt.setString(32, tLabRec.receive_date);
			cstmt.setString(33, tLabRec.hpv.hpv_code);
			cstmt.setString(34, tLabRec.ADPH_program);
			cstmt.executeUpdate();
			while (cstmt.getMoreResults()) {
				try {
					(cstmt.getResultSet()).close();
				} catch (SQLException e) {
				}
			}
			for (int i = 0; i < parent.MAX_DET_CODES; i++) {
				if (tDetRec[i].isSelected) {

					cstmt.close();
					cstmt = DbConnection.process().prepareCall(
							"{call pcs.lab_req_detail_add(?,?,?)}");
					cstmt.setInt(1, tLabRec.lab_number);
					cstmt.setInt(2, tDetRec[i].detail_code);
					cstmt.setString(3, tDetRec[i].textEntered);
					cstmt.executeUpdate();
					while (cstmt.getMoreResults()) {
						try {
							(cstmt.getResultSet()).close();
						} catch (SQLException e) {
						}
					}

				}
			}
			if (tLabRec.preparation == Lab.HPV_ONLY) {
				int detail_code = 99;
				if (tLabRec.hpv.hpvSource.equals("P"))
					detail_code = 98;
				cstmt = DbConnection.process().prepareCall(
						"{call pcs.lab_req_detail_add(?,?,?)}");
				cstmt.setInt(1, tLabRec.lab_number);
				cstmt.setInt(2, detail_code);
				cstmt.setString(3, null);
				cstmt.executeUpdate();

			}
			while (cstmt.getMoreResults()) {
				try {
					(cstmt.getResultSet()).close();
				} catch (SQLException e) {
				}
			}
			

		} catch (Exception e) {
			e.printStackTrace(System.err);
			parent.log.write("ERROR add\n" + e);
			exitStatus = false;
			String msg = "Add Operation failed on Lab #" + tLabRec.lab_number;
			Utils.createErrMsg(msg);
		}
		try {
			cstmt.close();
		} catch (SQLException e) {
			parent.log.write("SQL ERROR add\n" + e);
			exitStatus = false;
		}
		return (exitStatus);
	}

	public boolean queryPracticeInfo(int pr) {
		Statement stmt = null;
		ResultSet rs = null;
		boolean exitStatus = true;
		try {
			String query = "SELECT stop_code,client_notes,name,patient_cards, \n"
					+ "   active_status,block_patient,std_clinic, \n"
					+ "   hpv_testing,TO_CHAR(practice,'009'), \n"
					+ "   practice_type,hpv_permission, \n"
					+ "   hpv_regardless,imaged,parent_account,program,e_reporting \n"
					+ "FROM pcs.practices \n" + "WHERE practice=" + pr + " \n";

			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(query);
			int rowsReturned = 0;
			String f2 = " ";
			while (rs.next()) {
				rowsReturned++;
				parent.labRec.stop_code = rs.getString(1);
				f2 = rs.getString(2);
				parent.labRec.practice_name = rs.getString(3);
				parent.labRec.patient_cards = rs.getString(4);
				parent.labRec.prac_status = rs.getString(5);
				parent.labRec.prac.block_patient = rs.getString(6);
				parent.labRec.prac.std_clinic = rs.getString(7);
				parent.labRec.prac.hpv_testing = rs.getString(8);
				parent.labRec.prac.practice_id = rs.getString(9);
				parent.labRec.prac.practice_type = rs.getString(10);
				parent.labRec.prac.hpv_permission = rs.getString(11);
				parent.labRec.prac.hpv_regardless = rs.getString(12);
				parent.labRec.prac.imaged = rs.getString(13);
				parent.labRec.prac.parent_account = rs.getInt(14);
				parent.labRec.prac.program = rs.getString(15);
				parent.labRec.prac.e_reporting = rs.getString(16);
			}
			if (parent.labRec.prac.practice_type.equals("WV"))
				parent.pgmLabel.setText(parent.labRec.prac.program);
			if (parent.currMode == Lab.ADD) {
				if (parent.defaultPrep.equals("C")
						&& Utils.equals(parent.labRec.prac.practice_type,
								"ADPH")) {
					Utils.createErrMsg("CONVENTIONAL not a valid Preparation for ADPH Accounts");
					parent.labRec.prac.practice = 0;
					parent.labPractice.setText(null);
					parent.labPractice.requestFocus();
					return (true);
				} else if (parent.defaultPrep.equals("T")
						&& Utils.equals(parent.labRec.prac.imaged, "Y")) {
					Utils.createErrMsg("THINPREP not a valid Preparation for IMAGED account.");
					parent.labRec.prac.practice = 0;
					parent.labPractice.setText(null);
					parent.labPractice.requestFocus();
					return (true);
				} else if (parent.defaultPrep.equals("I")
						&& Utils.equals(parent.labRec.prac.imaged, "N")) {
					Utils.createErrMsg("IMAGED not a valid Preparation for this account.");
					parent.labRec.prac.practice = 0;
					parent.labPractice.setText(null);
					parent.labPractice.requestFocus();
					return (true);
				}
			}
			if (rowsReturned > 0) {
				if (f2.equals("Y")) {
					parent.labRec.fillClientNotes = true;
				} else {
					parent.labRec.fillClientNotes = false;
				}
				if (parent.labRec.stop_code.equals("D")) {
					parent.labBillingIDLbl.setText("Account#");
					parent.labBillingChoice.setText("DOC");
					parent.labBillingID.setText((String) parent.labPractice
							.getText());
					parent.CarrierNameLbl.setText("Physician Account");
				}
				if (!Utils.isNull(parent.labRec.prac.practice_type)) {
					if (parent.labRec.prac.practice_type.equals("ADPH")) {
						parent.labRec.prac.ADPH_programs = new Vector();
						parent.labRec.prac.ADPH_program_descr = new Vector();
						query = "SELECT adph_program,description \n"
								+ "FROM pcs.ADPH_programs \n";
						stmt = DbConnection.process().createStatement();
						rs = stmt.executeQuery(query);
						while (rs.next()) {
							parent.labRec.prac.ADPH_programs.addElement(rs
									.getString(1));
							parent.labRec.prac.ADPH_program_descr.addElement(rs
									.getString(2));
						}
					}
				}
				parent.labRec.practice = pr;
				parent.labRec.parent_account = parent.labRec.prac.parent_account;
				if (parent.labRec.parent_account > 0)
					parent.labParent.setText(Integer
							.toString(parent.labRec.parent_account));
				parent.labPracticeName.setText(parent.labRec.practice_name);
				if (parent.currMode != Lab.QUERY
						&& parent.labRec.prac_status.equals("I")) {
					String acct = Integer.toString(pr);
					if (pr < 10)
						acct = "00" + acct;
					else if (pr < 100)
						acct = "0" + acct;
					parent.labPractice.setText(null);
					parent.labPracticeName.setText("Account #" + acct
							+ " is INACTIVE - " + "Enter new account");
					parent.labRec.practice = -1;
					parent.labPractice.requestFocus();
				}
			} else {
				exitStatus = false;
			}
		} catch (Exception e) {
			parent.log.write("ERROR query practice\n" + e);
			exitStatus = false;
			parent.msgLabel.setText("Operation Failed");
		}
		try {
			rs.close();
			stmt.close();
		} catch (SQLException e) {
			parent.log.write("SQL ERROR query practice\n" + e);
			exitStatus = false;
		}
		return (exitStatus);
	}

	public boolean queryDoctorInfo(int pr) throws SQLException,
			DataNotFoundException, Exception {
		Statement stmt = null;
		ResultSet rs = null;
		boolean exitStatus = true;
		String SQL = "SELECT doctor,lname,fname,title,mi,upin,license, \n"
				+ "   alt_license,alt_state,active_status \n"
				+ "FROM pcs.doctors \n" + "WHERE practice=" + pr
				+ " and active_status='A' \n"
				+ "ORDER BY primary DESC,lname \n";

		stmt = DbConnection.process().createStatement();
		rs = stmt.executeQuery(SQL);
		parent.doctorVect = new Vector();
		int rowsReturned = 0;
		while (rs.next()) {
			DoctorRec dRec = new DoctorRec();
			dRec.practice = pr;
			dRec.doctor = rs.getInt(1);
			dRec.lname = rs.getString(2);
			dRec.fname = rs.getString(3);
			dRec.title = rs.getString(4);
			dRec.mi = rs.getString(5);
			dRec.upin = rs.getString(6);
			dRec.license = rs.getString(7);
			dRec.alt_license = rs.getString(8);
			dRec.alt_state = rs.getString(9);
			dRec.active_status = rs.getString(10);
			parent.doctorVect.addElement(dRec);
			if (rowsReturned == 0 || parent.labRec.doctor == (-1)) {
				parent.doctorText.setText(Utils.doctorName(dRec));
				parent.labRec.doctor = dRec.doctor;
			}
			rowsReturned++;
		}
		if (parent.doctorVect.size() > 0) {
			if (parent.labRec.doctor > 0) {
				for (int i = 0; i < parent.doctorVect.size(); i++) {
					DoctorRec dRec = (DoctorRec) parent.doctorVect.elementAt(i);
					if (dRec.doctor == parent.labRec.doctor) {
						if (parent.currMode != Lab.UPDATE)
							parent.doctorText.setText(Utils.doctorName(dRec));
						break;
					}
				}
			}
		} else
			throw new DataNotFoundException("DOCTORS");
		rs.close();
		stmt.close();
		return (exitStatus);
	}

	public boolean queryCarrier() throws SQLException, DataNotFoundException,
			Exception {
		Statement stmt = null;
		ResultSet rs = null;
		boolean exitStatus = true;
		String choiceCode = (String) parent.labBillingChoice.getText().trim();
		if (choiceCode.equals("DB") || choiceCode.equals("DOC")
				|| choiceCode.equals("PRC") || choiceCode.equals("PPN")
				|| choiceCode.equals("PPD")) {
			parent.labRec.carrier_id = (-1);
			parent.labRec.name = null;
			parent.labRec.payer_id = null;
			parent.labRec.pcs_payer_id = 0;
			parent.checkCarrier = false;
			return (exitStatus);
		}
		String SQL = null;
		String pcsID = parent.labPCSID.getText();
		String payerID = parent.labPayerID.getText();
		String othName = parent.labOtherInsurance.getText();
		SQL = "SELECT c.carrier_id,c.name,c.payer_id,c.id_number, \n"
				+ "   b.billing_choice,cc.comment_text, \n"
				+ "   SUBSTR(c.address1,1,16)||', '||SUBSTR(c.city,1,16)||', '||c.state, \n"
				+ "   c.address1 \n"
				+ "FROM pcs.carriers c, pcs.billing_choices b, pcs.carrier_comments cc \n"
				+ "WHERE c.billing_choice=b.billing_choice and \n"
				+ "   c.carrier_id=cc.carrier_id(+) and \n"
				+ "   c.active_status='A' and \n" + "   b.choice_code='"
				+ choiceCode + "'";
		if (!Utils.isNull(pcsID))
			SQL += "\n   and c.id_number=" + pcsID;
		if (!Utils.isNull(payerID))
			SQL += "\n   and c.payer_id='" + payerID + "'";
		if (!Utils.isNull(othName))
			SQL += "\n   and c.name LIKE '" + othName + "%'";
		SQL += " ORDER BY c.name \n";
		stmt = DbConnection.process().createStatement();
		rs = stmt.executeQuery(SQL);
		parent.carrierVect = new Vector();
		String buf1[] = null;
		String buf2[] = null;
		String caddr = null;
		while (rs.next()) {
			CarrierRec cRec = new CarrierRec();
			parent.labRec.carrier_id = cRec.carrier_id = rs.getInt(1);
			parent.labRec.name = cRec.name = rs.getString(2);
			parent.labRec.payer_id = cRec.payer_id = rs.getString(3);
			parent.labRec.pcs_payer_id = cRec.id_number = rs.getInt(4);
			cRec.billing_choice = rs.getInt(5);
			parent.labRec.carrier_comments = cRec.comment_text = rs
					.getString(6);
			caddr = rs.getString(8);
			if (!Utils.isNull(caddr))
				cRec.caddr = rs.getString(7);
			parent.carrierVect.addElement(cRec);
		}
		if (parent.carrierVect.size() > 0) {
			parent.checkCarrier = false;
			if (parent.carrierVect.size() > 1
					&& parent.labBillingChoice.getText().equals("OI")) {
				buf1 = new String[parent.carrierVect.size()];
				buf2 = new String[parent.carrierVect.size()];
				for (int i = 0; i < parent.carrierVect.size(); i++) {
					CarrierRec cRec = new CarrierRec();
					cRec = (CarrierRec) parent.carrierVect.elementAt(i);
					if (!Utils.isNull(cRec.payer_id)) {
						buf1[i] = cRec.name;
						if (!Utils.isNull(cRec.caddr))
							buf1[i] += ", " + cRec.caddr;
						buf1[i] += " [Payer #" + cRec.payer_id + "]";
					} else {
						buf1[i] = cRec.name;
						if (!Utils.isNull(cRec.caddr))
							buf1[i] += ", " + cRec.caddr;
						buf1[i] += " [ID #" + cRec.id_number + "]";
					}
					buf2[i] = Integer.toString(cRec.id_number);
				}
				parent.labOtherInsurance.setText(null);
				parent.labPayerID.setText(null);
				parent.labPCSID.setText(null);
				parent.labPCSID.requestFocus();
				parent.checkCarrier = true;
				(new PickList("Select ONE payer from list", 100, 100, 540, 290,
						parent.carrierVect.size(), buf1, buf2, parent.labPCSID))
						.setVisible(true);
			}
		} else {
			if (parent.currentSection == 2) {
				parent.labOtherInsurance.requestFocus();
				parent.labOtherInsurance.setText(null);
				parent.labPayerID.setText(null);
				parent.labPCSID.setText(null);
			}
			exitStatus = false;
			throw new DataNotFoundException("Payer");
		}
		rs.close();
		stmt.close();
		return (exitStatus);
	}

	public void update() throws SQLException, DataNotFoundException, Exception {
		// must check for pending letter before AND after update
		int nLettersBefore = DbConnection.getRowCount("PCS.FAX_LETTERS",
				"LAB_NUMBER=" + tLabRec.lab_number);
		// check whether in billing queue prior to update
		boolean inBillQ = DbConnection.inBillingQueue(tLabRec.lab_number);
		CallableStatement cstmt = null;
		cstmt = DbConnection
				.process()
				.prepareCall(
						"{call pcs.lab_reqs_update(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)}");
		cstmt.setInt(1, tLabRec.lab_number);
		cstmt.setInt(2, tLabRec.patient);
		cstmt.setInt(3, tLabRec.practice);
		cstmt.setInt(4, tLabRec.doctor);
		cstmt.setString(5, tLabRec.patient_id);
		cstmt.setString(6, tLabRec.diagnosis_code);
		cstmt.setString(7, tLabRec.diagnosis_code2);
		cstmt.setString(8, tLabRec.diagnosis_code3);
		cstmt.setString(9, tLabRec.diagnosis_code4);
		cstmt.setInt(10, tLabRec.slide_qty);
		cstmt.setString(11, tLabRec.date_collected);
		cstmt.setString(12, tLabRec.lmp);
		cstmt.setString(13, tLabRec.rush);
		cstmt.setInt(14, tLabRec.billing_choice);
		cstmt.setInt(15, tLabRec.carrier_id);
		cstmt.setString(16, tLabRec.id_number);
		cstmt.setString(17, tLabRec.group_number);
		cstmt.setString(18, tLabRec.subscriber);
		cstmt.setString(19, tLabRec.sub_lname);
		cstmt.setString(20, tLabRec.sub_fname);
		cstmt.setString(21, tLabRec.sign_date);
		cstmt.setString(22, tLabRec.medicare_code);
		cstmt.setString(23, tLabRec.client_note_text);
		cstmt.setString(24, tLabRec.lab_comments);
		cstmt.setInt(25, tLabRec.age);
		cstmt.setInt(26, tLabRec.preparation);
		cstmt.setInt(27, tLabRec.check_number);
		cstmt.setDouble(28, tLabRec.payment_amount);
		cstmt.setString(29, tLabRec.payment_info);
		cstmt.setString(30, tLabRec.doctor_text);
		cstmt.setString(31, tLabRec.receive_date);
		cstmt.setString(32, tLabRec.hpv.hpv_code);
		cstmt.setString(33, tLabRec.ADPH_program);
		int returnVal = cstmt.executeUpdate();
		parent.log.write("----->RETURN VALUE ON update.executeUpdate() = "
				+ returnVal + "<-----");

		for (int i = 0; i < parent.MAX_DET_CODES; i++) {
			if (tDetRec[i].isSelected) {
				cstmt = DbConnection.process().prepareCall(
						"{call pcs.lab_req_detail_add(?,?,?)}");
				cstmt.setInt(1, tLabRec.lab_number);
				cstmt.setInt(2, tDetRec[i].detail_code);
				cstmt.setString(3, tDetRec[i].textEntered);
				cstmt.executeUpdate();
			}
		}
		if (tLabRec.preparation == Lab.HPV_ONLY) {
			int detail_code = 99;
			if (tLabRec.hpv.hpvSource.equals("P"))
				detail_code = 98;
			cstmt = DbConnection.process().prepareCall(
					"{call pcs.lab_req_detail_add(?,?,?)}");
			cstmt.setInt(1, tLabRec.lab_number);
			cstmt.setInt(2, detail_code);
			cstmt.setString(3, null);
			cstmt.executeUpdate();
		}
		cstmt.close();
		/*
		 * Requisition data has been updated after results have been entered;
		 * the lab already has charges but they may change; the lab will in
		 * either the billing queue or the fax letter queue; will not change
		 * billing on a lab marked as finished. DISABLED: 04/26/2005 ENABLED:
		 * 05/09/2005 to add_cost when there was letter pending
		 */
		int nLettersAfter = DbConnection.getRowCount("PCS.FAX_LETTERS",
				"LAB_NUMBER=" + tLabRec.lab_number);
		boolean hadLetters = false;
		if (nLettersBefore > 0 && nLettersAfter == 0)
			hadLetters = true;
		if (tLabRec.finished >= 1 && tLabRec.finished < 4
				&& (hadLetters || inBillQ))
			add_cost();
	}

	public void add_cost() throws SQLException, DataNotFoundException,
			Exception {
		CallableStatement cstmt = null;
		cstmt = DbConnection.process().prepareCall(
				"{call pcs.calculate_cost(?)}");
		cstmt.setInt(1, tLabRec.lab_number);
		cstmt.executeUpdate();
		cstmt.close();
	}

	public void copyLabData() {
		tLabRec.patient = parent.labRec.patient;
		tLabRec.lab_number = parent.labRec.lab_number;
		tLabRec.practice = parent.labRec.practice;
		tLabRec.parent_account = parent.labRec.parent_account;
		tLabRec.program = parent.labRec.program;
		tLabRec.e_reporting = parent.labRec.e_reporting;
		tLabRec.prac.imaged = parent.labRec.prac.imaged;
		tLabRec.doctor = parent.labRec.doctor;
		tLabRec.patient_id = parent.labRec.patient_id;
		tLabRec.diagnosis_code = parent.labRec.diagnosis_code;
		tLabRec.diagnosis_code2 = parent.labRec.diagnosis_code2;
		tLabRec.diagnosis_code3 = parent.labRec.diagnosis_code3;
		tLabRec.diagnosis_code4 = parent.labRec.diagnosis_code4;
		tLabRec.slide_qty = parent.labRec.slide_qty;
		tLabRec.date_collected = parent.labRec.date_collected;
		tLabRec.lmp = parent.labRec.lmp;
		tLabRec.age = parent.labRec.age;
		tLabRec.rush = parent.labRec.rush;
		tLabRec.billing_choice = parent.labRec.billing_choice;
		tLabRec.carrier_id = parent.labRec.carrier_id;
		tLabRec.carrier_comments = parent.labRec.carrier_comments;
		tLabRec.id_number = parent.labRec.id_number;
		tLabRec.group_number = parent.labRec.group_number;
		tLabRec.subscriber = parent.labRec.subscriber;
		tLabRec.sub_lname = parent.labRec.sub_lname;
		tLabRec.sub_fname = parent.labRec.sub_fname;
		tLabRec.sign_date = parent.labRec.sign_date;
		tLabRec.medicare_code = parent.labRec.medicare_code;
		tLabRec.description = parent.labRec.description;
		tLabRec.name = parent.labRec.name;
		tLabRec.state = parent.labRec.state;
		tLabRec.stop_code = parent.labRec.stop_code;
		tLabRec.patient_cards = parent.labRec.patient_cards;
		tLabRec.lab_comments = parent.labRec.lab_comments;
		tLabRec.client_note_text = parent.labRec.client_note_text;
		tLabRec.rebilling = parent.labRec.rebilling;
		tLabRec.fillClientNotes = parent.labRec.fillClientNotes;
		tLabRec.finished = parent.labRec.finished;
		tLabRec.preparation = parent.labRec.preparation;
		tLabRec.previous_lab = parent.labRec.previous_lab;
		tLabRec.check_number = parent.labRec.check_number;
		tLabRec.payment_amount = parent.labRec.payment_amount;
		tLabRec.payment_info = parent.labRec.payment_info;
		tLabRec.doctor_text = parent.labRec.doctor_text;
		tLabRec.receive_date = parent.labRec.receive_date;
		tLabRec.pat.patient = parent.labRec.pat.patient;
		tLabRec.pat.lname = parent.labRec.pat.lname;
		tLabRec.pat.fname = parent.labRec.pat.fname;
		tLabRec.pat.mi = parent.labRec.pat.mi;
		tLabRec.pat.address1 = parent.labRec.pat.address1;
		tLabRec.pat.city = parent.labRec.pat.city;
		tLabRec.pat.state = parent.labRec.pat.state;
		tLabRec.pat.zip = parent.labRec.pat.zip;
		tLabRec.pat.ssn = parent.labRec.pat.ssn;
		tLabRec.pat.dob = parent.labRec.pat.dob;
		tLabRec.pat.phone = parent.labRec.pat.phone;
		tLabRec.pat.newPatientAdd = parent.labRec.pat.newPatientAdd;
		tLabRec.pat.race = parent.labRec.pat.race;
		tLabRec.hpv.requested = parent.labRec.hpv.requested;
		tLabRec.hpv.test_sent = parent.labRec.hpv.test_sent;
		tLabRec.hpv.test_results = parent.labRec.hpv.test_results;
		tLabRec.hpv.results_received = parent.labRec.hpv.results_received;
		tLabRec.hpv.comment_text = parent.labRec.hpv.comment_text;
		tLabRec.hpv.hpv_code = parent.labRec.hpv.hpv_code;
		tLabRec.hpv.hpv_lab = parent.labRec.hpv.hpv_lab;
		tLabRec.hpv.hpvSource = parent.labRec.hpv.hpvSource;
		tLabRec.ADPH_program = parent.labRec.ADPH_program;
		for (int i = 0; i < parent.MAX_DET_CODES; i++) {
			tDetRec[i].detail_code = parent.detailRec[i].detail_code;
			tDetRec[i].description = parent.detailRec[i].description;
			tDetRec[i].additional_info = parent.detailRec[i].additional_info;
			tDetRec[i].isSelected = parent.detailRec[i].isSelected;
			tDetRec[i].textEntered = parent.detailRec[i].textEntered;
		}
	}

	public void queryZip(String zip5) throws SQLException,
			DataNotFoundException, Exception {
		Statement stmt = null;
		ResultSet rs = null;
		String SQL = "SELECT city,state FROM pcs.zipcodes WHERE zip='" + zip5
				+ "' \n";
		stmt = DbConnection.process().createStatement();
		rs = stmt.executeQuery(SQL);
		int rcnt = 0;
		while (rs.next()) {
			parent.labCity.setText(rs.getString(1));
			parent.labState.setText(rs.getString(2));
			rcnt++;
		}
		if (rcnt == 0) {
			parent.getFocusOwner().transferFocus();
			parent.labCity.requestFocus();
			throw new DataNotFoundException("City/State not found for " + zip5);
		} else {
			parent.labRec.pat.zip = Utils.stripZipMask(parent.labZip.getText());
			parent.labRec.pat.city = parent.labCity.getText();
			parent.labRec.pat.state = parent.labState.getText();
		}
		rs.close();
		stmt.close();
	}

	private void queryLabNumber() throws SQLException, InvalidDataException,
			Exception {
		Statement stmt = null;
		ResultSet rs = null;
		String SQL = "SELECT lab_number FROM pcs.lab_requisitions WHERE lab_number="
				+ tLab + " \n";
		stmt = DbConnection.process().createStatement();
		rs = stmt.executeQuery(SQL);
		int rcnt = 0;
		while (rs.next()) {
			rcnt = rs.getInt(1);
		}
		stmt.close();
		rs.close();
		if (rcnt > 0) {
			parent.currentSection = 3;
			parent.gotoNextSection();
			parent.labNumber.setText(null);
			parent.labNumber.requestFocus();
			throw new InvalidDataException("Lab Number " + tLab
					+ " already exists");
		}
	}

	public void queryLabNumber(int labNum) {
		Statement stmt = null;
		ResultSet rs = null;
		String SQL = "SELECT lab_number FROM pcs.lab_requisitions WHERE lab_number="
				+ labNum + " \n";
		try {
			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(SQL);
			int rcnt = 0;
			while (rs.next()) {
				rcnt = rs.getInt(1);
			}
			stmt.close();
			rs.close();
			if (rcnt > 0) {
				parent.currentSection = 3;
				parent.gotoNextSection();
				parent.labNumber.setText(null);
				parent.labNumber.requestFocus();
			}
		} catch (SQLException e) {
		} catch (Exception e) {
		}
	}

	private void updatePatient() throws SQLException, DataNotFoundException,
			Exception {
		String SQL = "UPDATE pcs.patients SET \n" + "   address1 = ?, \n"
				+ "   city = ?, \n" + "   state = ?, \n" + "   zip = ?, \n"
				+ "   phone = ?, \n" + "   ssn = ?, \n"
				+ "   dob = TO_DATE(?,'MMDDYYYY'), \n" + "   lname = ?, \n"
				+ "   fname = ?, \n" + "   mi = ?, \n" + "   race = ? \n"
				+ "WHERE patient = ? \n";
		PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
		pstmt.setString(1, tLabRec.pat.address1);
		pstmt.setString(2, tLabRec.pat.city);
		pstmt.setString(3, tLabRec.pat.state);
		pstmt.setString(4, tLabRec.pat.zip);
		pstmt.setString(5, tLabRec.pat.phone);
		pstmt.setString(6, tLabRec.pat.ssn);
		pstmt.setString(7, tLabRec.pat.dob);
		pstmt.setString(8, tLabRec.pat.lname);
		pstmt.setString(9, tLabRec.pat.fname);
		pstmt.setString(10, tLabRec.pat.mi);
		pstmt.setString(11, tLabRec.pat.race);
		pstmt.setInt(12, tLabRec.patient);
		int returnVal = pstmt.executeUpdate();
		parent.log
				.write("----->RETURN VALUE ON updatePatient.executeUpdate() = "
						+ returnVal + "<-----");
		pstmt.close();
	}

	private void addPatient() throws SQLException, Exception {
		String tBuf = null;
		int nextPatientNumber = 0;
		String query = "INSERT INTO pcs.patients \n"
				+ "   (patient,lname,fname,ssn,dob,address1,city,state,zip,phone,mi,race,sex,last_lab) \n"
				+ "VALUES (?,?,?,?,to_date(?,'MMDDYYYY'),?,?,?,?,?,?,?,?,?) \n";
		PreparedStatement pstmt = DbConnection.process()
				.prepareStatement(query);
		tLabRec.patient = Utils.getNextPatient();
		pstmt.setInt(1, tLabRec.patient);
		pstmt.setString(2, tLabRec.pat.lname);
		pstmt.setString(3, tLabRec.pat.fname);
		pstmt.setString(4, tLabRec.pat.ssn);
		pstmt.setString(5, tLabRec.pat.dob);
		pstmt.setString(6, tLabRec.pat.address1);
		pstmt.setString(7, tLabRec.pat.city);
		pstmt.setString(8, tLabRec.pat.state);
		pstmt.setString(9, tLabRec.pat.zip);
		pstmt.setString(10, tLabRec.pat.phone);
		pstmt.setString(11, tLabRec.pat.mi);
		pstmt.setString(12, tLabRec.pat.race);
		pstmt.setString(13, "F");
		pstmt.setInt(14, tLabRec.lab_number);
		pstmt.executeUpdate();
		pstmt.close();
	}

	private void buildDiagnosisLetter() throws SQLException, Exception {
		CallableStatement cstmt = null;
		cstmt = DbConnection.process().prepareCall(
				"{call pcs.build_diagnosis_letter(?,?,?)}");
		cstmt.setInt(1, parent.labRec.lab_number);
		cstmt.setInt(2, -1);
		cstmt.setInt(3, 1);
		cstmt.executeUpdate();
		cstmt.close();
	}

	private void buildBlankLetter() throws SQLException, Exception {
		CallableStatement cstmt = null;
		cstmt = DbConnection.process().prepareCall(
				"{call pcs.build_blank_letter(?,?)}");
		cstmt.setInt(1, parent.labRec.lab_number);
		cstmt.setInt(2, 1);
		cstmt.executeUpdate();
		cstmt.close();
	}

	private void checkBillingInfo() throws SQLException, Exception {
		CallableStatement cstmt = null;
		cstmt = DbConnection.process().prepareCall(
				"{call pcs.check_billing_info(?,?,?,?)}");
		cstmt.setInt(1, parent.labRec.lab_number);
		cstmt.setInt(2, parent.labRec.rebilling);
		cstmt.setInt(3, -1);
		cstmt.setInt(4, 1);
		cstmt.executeUpdate();
		cstmt.close();
	}

	private boolean patientExists(int patient) throws SQLException, Exception {
		boolean exists = false;
		String SQL = "SELECT patient FROM pcs.patients WHERE patient="
				+ patient + " \n";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(SQL);
		while (rs.next()) {
			exists = true;
		}
		rs.close();
		stmt.close();
		return (exists);
	}

	public boolean queryPatientLabs(int pat, Vector resultList) {
		boolean exitStatus = true;
		int lab = 0;
		int previousLab = 0;
		try {
			String SQL = "SELECT MAX(lab_number) \n"
					+ "FROM pcs.lab_requisitions " + "WHERE patient=" + pat
					+ " \n";
			Statement stmt = DbConnection.process().createStatement();
			ResultSet rs = stmt.executeQuery(SQL);
			while (rs.next()) {
				previousLab = rs.getInt(1);
			}
			try {
				rs.close();
				stmt.close();
			} catch (SQLException e) {
				parent.log.write(e.toString());
				exitStatus = false;
			} catch (Exception e) {
				parent.log.write(e.toString());
				exitStatus = false;
			}
			while (previousLab != 0 && previousLab != lab) {
				SQL = "SELECT lab_number,practice, \n"
						+ "   TO_CHAR(date_collected,'MM/DD/YYYY'), \n"
						+ "   TO_CHAR(datestamp,'MM/DD/YYYY'), \n"
						+ "   finished,previous_lab \n"
						+ "FROM pcs.lab_requisitions " + "WHERE lab_number="
						+ previousLab + " \n";
				stmt = DbConnection.process().createStatement();
				rs = stmt.executeQuery(SQL);
				while (rs.next()) {
					lab = rs.getInt(1);
					int practice = rs.getInt(2);
					String dc = rs.getString(3);
					String ds = rs.getString(4);
					int f = rs.getInt(5);
					previousLab = rs.getInt(6);
					String state = " ";
					if (f == 1)
						state = "SCREENING";
					else if (f == 2)
						state = "RESULTS";
					else if (f == 3)
						state = "BILLED";
					else if (f > 3)
						state = "PAID";
					String p_txt = Integer.toString(practice);
					if (practice < 100)
						p_txt = "0" + p_txt;
					resultList.addElement(lab + "  " + p_txt + "  " + dc + "  "
							+ ds + "  " + state);
				}
				try {
					rs.close();
					stmt.close();
				} catch (SQLException e) {
					parent.log.write(e.toString());
					exitStatus = false;
				} catch (Exception e) {
					parent.log.write(e);
					exitStatus = false;
				}
			}
			try {
				rs.close();
				stmt.close();
			} catch (SQLException e) {
				parent.log.write(e.toString());
				exitStatus = false;
			}
		} catch (Exception e) {
			parent.log.write(e);
			exitStatus = false;
			parent.msgLabel.setText("Operation Failed");
		}
		return (exitStatus);
	}

	public boolean hasLabComments(int labNum) {
		boolean hasComments = false;
		try {
			String query = "SELECT comment_text \n"
					+ "FROM pcs.lab_req_comments " + "WHERE lab_number="
					+ labNum + " \n";
			Statement stmt = DbConnection.process().createStatement();
			ResultSet rs = stmt.executeQuery(query);
			while (rs.next()) {
				hasComments = true;
			}
			try {
				rs.close();
				stmt.close();
			} catch (SQLException e) {
				parent.log.write(e);
			}
		} catch (Exception e) {
			parent.log.write(e);
		}
		return (hasComments);
	}

	public void queryTissueDetailCodes() throws SQLException,
			DataNotFoundException, Exception {
		Vector v = new Vector();
		String SQL = "SELECT detail_code,description,additional_info \n"
				+ "FROM pcs.detail_codes WHERE is_tissue='Y' OR is_tissue='T' \n"
				+ "ORDER BY detail_code \n";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(SQL);
		while (rs.next()) {
			DetailCodeRec d = new DetailCodeRec();
			d.detail_code = rs.getInt(1);
			d.description = rs.getString(2);
			d.additional_info = rs.getString(3);
			v.addElement(d);
		}
		if (v.size() == 0) {
			stmt.close();
			rs.close();
			parent.currMode = Lab.FATAL;
			throw new DataNotFoundException("FATAL");
		}
		parent.MAX_DET_CODES = v.size();
		parent.detailRec = new DetailCodeRec[v.size()];
		parent.selectedDetCodes = new int[v.size()];
		parent.detCodeDisp = new String[v.size()];
		String[] s = new String[v.size()];
		for (int i = 0; i < v.size(); i++) {
			DetailCodeRec d = (DetailCodeRec) v.elementAt(i);
			parent.detailRec[i] = d;
			s[i] = Integer.toString(d.detail_code) + " " + d.description;
		}
		parent.labDetailList.setListData(s);
		parent.labDetailList.revalidate();
		parent.labDetailList.repaint();
		stmt.close();
		rs.close();
	}

	public boolean isIBC(String prefix) throws SQLException,
			DataNotFoundException, Exception {
		boolean result = false;
		String SQL = "SELECT count(*) \n" + "FROM pcs.ibc_prefixes \n"
				+ "WHERE prefix = '" + prefix + "' \n";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(SQL);
		int rcnt = 0;
		while (rs.next()) {
			rcnt = rs.getInt(1);
		}
		if (rcnt > 0)
			result = true;
		stmt.close();
		rs.close();
		return (result);
	}

	public void createIndexFile() {
		LabReportRec r = new LabReportRec();
		r.pat_lname = tLabRec.pat.lname;
		r.pat_fname = tLabRec.pat.fname;
		r.pat_dob = Utils.addDateMask(tLabRec.pat.dob);
		r.doctor_text = tLabRec.doctor_text;
		r.lab_number = tLabRec.lab_number;
		r.pat_ssn = tLabRec.pat.ssn;
		r.date_collected = Utils.addDateMask(tLabRec.date_collected);
		r.receive_date = Utils.addDateMask(tLabRec.receive_date);
		r.datestamp = Utils.addDateMask(DbConnection.getDate());
		r.parent_account = tLabRec.parent_account;
		r.practice = tLabRec.practice;
		r.program = tLabRec.program;
		Export eFile = new Export(Lab.HPV_ONLY, r);
		eFile.write();
	}

	public static LabRequisition getLabRequisition(int labNumber) {

		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();

		LabRequisition labReq = session.selectOne("com.pacytology.pcs.sqlmaps.LabRequisitionMapper.selectLabRequisition", labNumber); 
		return labReq ; 
		
	}
	public static List<LabRequisition> getLabRequisitions(int startingLabNumber, int endingLabNumber) {

		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();
		Map<String, Integer> labNumberRange = new HashMap<String, Integer>();
		labNumberRange.put("startingLabNumber", new Integer(startingLabNumber));
		labNumberRange.put("endingLabNumber", new Integer(endingLabNumber));
		List<LabRequisition> labReqs = session.selectList("com.pacytology.pcs.sqlmaps.LabRequisitionMapper.selectLabRequisitions", labNumberRange); 
		return labReqs ; 
		
	}

}
