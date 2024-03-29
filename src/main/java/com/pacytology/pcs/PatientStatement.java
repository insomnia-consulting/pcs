package com.pacytology.pcs;

/*
 PENNSYLVANIA CYTOLOGY SERVICES
 LABORATORY INFORMATION SYSTEM V1.0
 Copyright (C) 2001 by John Cardella
 All Rights Reserved

 File:       PatientStatement.java
 Created By: John Cardella, Software Engineer

 Function:   This class retrieves data for patient statements
 (i.e. direct bills), formats the data, and then prints the
 statements via a Windows print job.

 MODIFICATIONS ----------------------------------------------------------
 Date/Staff    Description:
 12/02/2009    Exclude line items that have a zero amount
 09/23/2010    Added query to retrieve PPD payments as now a PPD lab is
 not necessarily a finished lab
 10/20/2010    Added verification code for credit card trx
 01/12/2012    Minor changes for itemized statements
 */

import java.awt.*;
import java.sql.*;
import javax.swing.*;

import com.pacytology.pcs.utils.StringUtils;

import java.awt.Toolkit;
import java.awt.Window;
import java.awt.Graphics;
import java.util.Properties;
import java.awt.PrintJob;
import java.text.DecimalFormat;
import java.text.FieldPosition;

public class PatientStatement {
	Frame parent;
	public Login dbLogin;
	public PrintJob pjob;
	public String lname;
	public String fname;
	public String mi;
	public String stmtDate;
	public String collectDate;
	public int labNum = (-1);
	public String address;
	public String city;
	public String state;
	public String zip;
	public double amount;
	public int finished;
	public double bill_amount;
	public double allow;
	public String strAmount;
	public String pname;
	public String dTitle;
	public String rebill;
	public String billing_type;
	public int patient;
	public int rebilling;
	public String rebillCode;
	public boolean pastDue;
	public double payments;
	public String[] procCodes = new String[20];
	public String[] procDescr = new String[20];
	public double[] itemAmts = new double[20];
	public String[] strItemAmts = new String[20];
	private int numItems = 0;
	private int numReports = 0;
	private int timesPrinted = 0;
	Graphics pgraphics;
	String name = "Patient Statement";
	DecimalFormat df = new DecimalFormat("###0.00");
	final int INT_LEN = 4;
	final int QUEUE = 101;
	final int COPY = 102;
	public int printMode;
	public StringUtils format = new StringUtils();
	int statementID = 0;
	String commentText;
	boolean hasSecondPage = false;
	int globalCounter = 0;
	boolean finalNotice;
	public LogFile log;

	public PatientStatement() {
	}

	public PatientStatement(Login dbLogin, PrintJob pjob) {
		this();
		this.pjob = pjob;
		this.dbLogin = dbLogin;
		this.printMode = this.QUEUE;
		this.log = new LogFile(dbLogin.logPath, "PatientStatement",
				dbLogin.dateToday, dbLogin.userName);
	}

	public PatientStatement(Login dbLogin, PrintJob pjob, int labNum) {
		this();
		this.pjob = pjob;
		this.dbLogin = dbLogin;
		this.labNum = labNum;
		this.printMode = this.COPY;
		this.log = new LogFile(dbLogin.logPath, "PatientStatement",
				dbLogin.dateToday, dbLogin.userName);
	}

	public void printStatements() {
		queryPrint();
	}

	private boolean queryPrint() {
		boolean exitStatus = true;
		Statement stmt = null;
		Statement subStmt = null;
		ResultSet rs = null;
		ResultSet subRs = null;
		try {
			String SQL = new String();
			if (printMode == QUEUE) {
				SQL = "SELECT \n"
						+ "   TO_CHAR(SysDate,'fmMONTH dd, YyyY'), \n"
						+ "   l.lab_number,nvl(p.lname,'MISSING'),nvl(p.fname,'MISSING'),nvl(p.mi,' '), \n"
						+ "   nvl(p.address1,' '),nvl(p.city,' '), \n"
						+ "   nvl(p.state,' '),nvl(p.zip,' '), \n"
						+ "   TO_CHAR(l.date_collected,'fmMONTH dd, YyyY'), \n"
						+ "   d.name,lb.balance, \n"
						+ "   rc.description,bq.billing_type, \n"
						+ "   l.patient,bq.rebilling,bq.rebill_code,lb.bill_amount, \n"
						+ "   null,NVL(lb.allowance,0),l.finished \n"
						+ "FROM \n"
						+ "   pcs.lab_requisitions l, pcs.patients p, \n"
						+ "   pcs.practices d, pcs.lab_billings lb, \n"
						+ "   pcs.billing_queue bq, pcs.rebill_codes rc \n"
						+ "WHERE \n" + "   l.lab_number=lb.lab_number and \n"
						+ "   l.practice=d.practice and \n"
						+ "   bq.rebill_code=rc.rebill_code(+) and \n"
						+ "   l.patient=p.patient and \n"
						+ "   lb.lab_number=bq.lab_number and \n"
						+ "   bq.billing_route='PAT' \n"
						+ "ORDER BY p.lname,p.fname,l.lab_number \n";
			} else if (printMode == COPY) {
				SQL = "SELECT \n"
						+ "   TO_CHAR(SysDate,'fmMONTH dd, YyyY'), \n"
						+ "   l.lab_number,p.lname,p.fname,nvl(p.mi,' '), \n"
						+ "   nvl(p.address1,' '),nvl(p.city,' '), \n"
						+ "   nvl(p.state,' '),nvl(p.zip,' '), \n"
						+ "   TO_CHAR(l.date_collected,'fmMONTH dd, YyyY'), \n"
						+ "   d.name,lb.balance, \n"
						+ "   rc.description,ps.billing_type,l.patient, \n"
						+ "   ps.statement_id,ps.rebill_code,lb.bill_amount, \n"
						+ "   ps.printed,NVL(lb.allowance,0),l.finished \n"
						+ "FROM \n"
						+ "   pcs.lab_requisitions l, pcs.patients p, \n"
						+ "   pcs.practices d, pcs.lab_billings lb, \n"
						+ "   pcs.patient_statements ps, pcs.rebill_codes rc \n"
						+ "WHERE \n" + "   l.lab_number=lb.lab_number and \n"
						+ "   l.practice=d.practice and \n"
						+ "   ps.rebill_code=rc.rebill_code(+) and \n"
						+ "   l.patient=p.patient and \n"
						+ "   lb.lab_number=ps.lab_number and \n"
						+ "   l.lab_number=" + labNum + "  \n";
			}

			stmt = DbConnection.process().createStatement();
			rs = stmt.executeQuery(SQL);
			numReports = 0;
			while (rs.next()) {
				String n = rs.getString(3) + ", " + rs.getString(4);
				labNum = rs.getInt(2);
				String INS = "insert into pcs.db_verify values(?,?,?,to_char(sysdate,'MMDDYYYY'))";
				PreparedStatement pstmt = DbConnection.process()
						.prepareStatement(INS);
				pstmt.setInt(1, numReports);
				pstmt.setString(2, n);
				pstmt.setInt(3, labNum);
				pstmt.executeUpdate();
				try {
					pstmt.close();
				} catch (SQLException e) {
					log.write(e);
					log.write("Lab #" + labNum);
					return false;
				} catch (Exception e) {
					log.write("Lab #" + labNum);
					log.write(e);
				}
				CallableStatement cstmt;
				cstmt = DbConnection.process().prepareCall(
						"{call pcs.calculate_balances_2(?)}");
				cstmt.setInt(1, labNum);
				cstmt.executeUpdate();
				numReports++;
				try {
					cstmt.close();
				} catch (SQLException e) {
					log.write(e);
					log.write("Lab #" + labNum);
					return false;
				} catch (Exception e) {
					log.write("Lab #" + labNum);
					log.write(e);
				}
			}
			try {
				rs.close();
			} catch (SQLException e) {
				log.write(e);
			} catch (Exception e) {
				log.write(e);
			}
			if (numReports > 0) {
				rs = stmt.executeQuery(SQL);
				if (pjob != null) {
					while (rs.next()) {
						payments = 0;
						stmtDate = rs.getString(1);
						labNum = rs.getInt(2);
						lname = rs.getString(3);
						fname = rs.getString(4);
						mi = rs.getString(5);
						address = rs.getString(6);
						city = rs.getString(7);
						state = rs.getString(8);
						zip = rs.getString(9);
						collectDate = rs.getString(10);
						pname = rs.getString(11);
						amount = rs.getDouble(18);
						rebill = rs.getString(13);
						billing_type = rs.getString(14);
						patient = rs.getInt(15);
						rebilling = rs.getInt(16);
						rebillCode = rs.getString(17);
						bill_amount = rs.getDouble(18);
						allow = rs.getDouble(20);
						finished = rs.getInt(21);
						if (finished >= 4) {
							amount = 0;
						}
						pastDue = false;
						finalNotice = false;
						if (!Utils.isNull(billing_type)) {
							if (billing_type.charAt(2) != '0')
								pastDue = true;
							if (billing_type.charAt(2) == '9') {
								pastDue = false;
								finalNotice = true;
							}
						}
						String subQuery = null;
						subQuery = "SELECT bi.item_amount, \n"
								+ "   p.description, p.procedure_code \n"
								+ "FROM pcs.lab_billing_items bi, \n"
								+ "   pcs.procedure_codes p \n"
								+ "WHERE bi.lab_number=" + labNum + " \n"
								+ "AND bi.procedure_code=p.procedure_code \n"
								+ "AND bi.item_amount>0 \n"
								+ "ORDER BY p.p_seq \n";
						subStmt = DbConnection.process().createStatement();
						subRs = subStmt.executeQuery(subQuery);
						numItems = 0;
						while (subRs.next()) {
							itemAmts[numItems] = subRs.getDouble(1);
							procDescr[numItems] = subRs.getString(2);
							procCodes[numItems] = subRs.getString(3);
							numItems++;
						}
						try {
							subRs.close();
							subStmt.close();
						} catch (SQLException e) {
							log.write(e);
							log.write("Lab #" + labNum + "[3]");
							return false;
						} catch (Exception e) {
							log.write("Lab #" + labNum);
							log.write(e);
						}
						timesPrinted = 0;
						subStmt = DbConnection.process().createStatement();
						subQuery = "SELECT printed FROM pcs.patient_statements \n"
								+ "WHERE lab_number=" + labNum + " \n";
						subRs = subStmt.executeQuery(subQuery);
						while (subRs.next()) {
							timesPrinted = subRs.getInt(1);
						}
						try {
							subRs.close();
							subStmt.close();
						} catch (SQLException e) {
							log.write(e);
							log.write("Lab #" + labNum + "[4]");
							return false;
						} catch (Exception e) {
							log.write("Lab #" + labNum);
							log.write(e);
						}
						timesPrinted++;
						subQuery = "SELECT NVL(amount_paid,0),NVL(allowance,0) \n"
								+ "FROM pcs.lab_claims \n"
								+ "WHERE lab_number="
								+ labNum
								+ " \n"
								+ "ORDER BY claim_id \n";
						boolean foundAllowance = false;
						subStmt = DbConnection.process().createStatement();
						subRs = subStmt.executeQuery(subQuery);
						while (subRs.next()) {
							double paid = subRs.getDouble(1);
							// double allow = subRs.getDouble(2);
							if (allow > 0 && allow < bill_amount
									&& !foundAllowance) {
								itemAmts[numItems] = allow;
								procDescr[numItems] = "ALLOWANCE BY INSURANCE";
								procCodes[numItems] = "     ";
								numItems++;
								foundAllowance = true;
							}
							if (paid > 0) {
								// amount-=paid;
								itemAmts[numItems] = paid * (-1);
								procDescr[numItems] = "PAID BY INSURANCE";
								procCodes[numItems] = "     ";
								numItems++;
							}
						}
						try {
							subRs.close();
							subStmt.close();
						} catch (SQLException e) {
							log.write(e);
							log.write("Lab #" + labNum + "[5]");
							return false;
						} catch (Exception e) {
							log.write("Lab #" + labNum);
							log.write(e);
						}
						subQuery = "SELECT \n"
								+ "   P.payment_amount, \n"
								+ "   TO_CHAR(NVL(P.receive_date,P.payment_date),'MM/DD/YYYY'), \n"
								+ "   P.payment_type, \n"
								+ "   P.check_number, \n"
								+ "   SUBSTR(R.adjust_reason,1,26) \n"
								+ "FROM \n" + "   pcs.payments P, \n"
								+ "   pcs.lab_requisitions L, \n"
								+ "   pcs.payment_adjust_reasons R, \n"
								+ "   pcs.billing_choices B \n" + "WHERE \n"
								+ "   P.billing_choice=B.billing_choice and \n"
								+ "   B.choice_code='DB' and \n"
								+ "   P.payment_id=R.payment_id(+) and \n"
								+ "   P.lab_number=L.lab_number and \n"
								+ "   P.billing_choice=121 and \n"
								+ "   L.lab_number=" + labNum + " \n";
						subStmt = DbConnection.process().createStatement();
						subRs = subStmt.executeQuery(subQuery);
						while (subRs.next()) {
							itemAmts[numItems] = subRs.getDouble(1);
							procDescr[numItems] = "PAYMENT - "
									+ subRs.getString(2);
							String ptype = subRs.getString(3);
							int cNum = subRs.getInt(4);
							if (ptype.equals("CHECK")) {
								procDescr[numItems] += " (CK #" + cNum + ")";
								// amount-=itemAmts[numItems];
							} else if (ptype.equals("PLUS ADJUST")) {
								procDescr[numItems] = "PLUS ADJUSTMENT:  "
										+ subRs.getString(5);
								// amount+=itemAmts[numItems];
							} else if (ptype.equals("MINUS ADJUST")) {
								procDescr[numItems] = "MINUS ADJUSTMENT: "
										+ subRs.getString(5);
								// amount-=itemAmts[numItems];
							} else
								procDescr[numItems] += " (" + ptype + ")";
							procCodes[numItems] = "     ";
							if (ptype.equals("PLUS ADJUST")) {
								payments -= itemAmts[numItems];
							} else {
								payments += itemAmts[numItems];
								itemAmts[numItems] *= (-1);
							}
							numItems++;
						}
						// if (allow>0 && (amount<0 || amount>allow))
						// amount=allow;
						try {
							subRs.close();
							subStmt.close();
						} catch (SQLException e) {
							log.write(e);
							log.write("Lab #" + labNum + "[6A]");
							return false;
						} catch (Exception e) {
							log.write("Lab #" + labNum);
							log.write(e);
						}

						/****************************************************/
						/* ADDED FOR PREPAID LABS */
						/****************************************************/
						subQuery = "SELECT payment_amount  \n"
								+ "FROM pcs.prepaid_labs  \n"
								+ "WHERE lab_number=" + labNum + " \n";
						subStmt = DbConnection.process().createStatement();
						subRs = subStmt.executeQuery(subQuery);
						while (subRs.next()) {
							itemAmts[numItems] = subRs.getDouble(1);
							procDescr[numItems] = "PAYMENT - PREPAID AMOUNT";
							// amount-=itemAmts[numItems];
							procCodes[numItems] = "     ";
							payments += itemAmts[numItems];
							itemAmts[numItems] *= (-1);
							numItems++;
						}
						try {
							subRs.close();
							subStmt.close();
						} catch (SQLException e) {
							log.write(e);
							log.write("Lab #" + labNum + "[6B]");
							return false;
						} catch (Exception e) {
							log.write("Lab #" + labNum);
							log.write(e);
						}
						/****************************************************/

						subQuery = "SELECT comment_text FROM pcs.db_comments \n"
								+ "WHERE lab_number=" + labNum + " \n";
						subStmt = DbConnection.process().createStatement();
						subRs = subStmt.executeQuery(subQuery);
						commentText = new String();
						while (subRs.next()) {
							commentText = subRs.getString(1);
						}
						try {
							subRs.close();
							subStmt.close();
						} catch (SQLException e) {
							log.write(e);
							log.write("Lab #" + labNum + "[7]");
							return false;
						} catch (Exception e) {
							log.write("Lab #" + labNum);
							log.write(e);
						}
						subQuery = "SELECT total_balance FROM pcs.patient_accounts \n"
								+ "WHERE lab_number=" + labNum + " \n";
						subStmt = DbConnection.process().createStatement();
						subRs = subStmt.executeQuery(subQuery);
						while (subRs.next()) {
							amount = subRs.getDouble(1);
						}
						try {
							subRs.close();
							subStmt.close();
						} catch (SQLException e) {
							log.write(e);
							log.write("Lab #" + labNum + "[8]");
							return false;
						} catch (Exception e) {
							log.write("Lab #" + labNum);
							log.write(e);
						}
						amount = DbConnection.getCurrentBalance(labNum);
						boolean doPrint = true;
						if (pastDue && printMode == QUEUE && amount < 5)
							doPrint = false;
						if (doPrint) {
							pgraphics = pjob.getGraphics();
							if (pgraphics != null) {
								printStatement(pgraphics);
								pgraphics.dispose();
							}
							if (hasSecondPage) {
								pgraphics = pjob.getGraphics();
								if (pgraphics != null) {
									printSecondPage(pgraphics);
									pgraphics.dispose();
									hasSecondPage = false;
								}
							}
						}
						if (!billing_type.equals("IS00"))
							dequeue(labNum);
					}
					pjob.end();
				}
			} else {
				(new ErrorDialog("No Data Found")).setVisible(true);
				if (pjob != null)
					pjob.end();
				exitStatus = false;
			}
		} catch (SQLException e) {
			log.write(e);
			log.write("Lab #" + labNum + "[10]");
			return false;
		} catch (Exception e) {
			log.write("Lab #" + labNum);
			log.write(e);
			if (pjob != null)
				pjob.end();
			exitStatus = false;
		}
		if (pjob != null)
			pjob.end();
		return exitStatus;
	}

	public void printStatement(Graphics pgraphics) {
		int x, y;
		String dashedLine = "----------------------------------"
				+ "------------------------------------";

		x = 278;
		y = 34;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
		pgraphics.drawString("STATEMENT", x, y);
		x = 198;
		y += 16;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 12));
		pgraphics.drawString("PENNSYLVANIA CYTOLOGY SERVICES", x, y);
		x = 242;
		y += 7;
		pgraphics.setFont(new Font("Monospaced", Font.ITALIC, 8));
		pgraphics.drawString("Suite 1700 Parkway Building", x, y);
		x = 254;
		y += 8;
		pgraphics.drawString("339 Old Haymaker Road", x, y);
		x = 252;
		y += 8;
		pgraphics.drawString("Monroeville, PA  15146", x, y);
		x = 254;
		y += 8;
		pgraphics.drawString("Phone: (412) 373-8300", x, y);

		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
		x = 340;
		y = 101;
		pgraphics.drawString("Statement Date:   " + stmtDate, x, y);
		x = 30;
		pgraphics.drawString("Patient: ", x, y);
		x = 103;
		pgraphics.drawString(lname.trim() + ", " + fname.trim(), x, y);
		y += 12;
		pgraphics.drawString(address.trim(), x, y);
		x = 340;
		pgraphics.drawString("Lab Number:       " + labNum, x, y);
		x = 104;
		y += 12;
		pgraphics.drawString(city.trim() + ", " + state.trim() + "  " + zip, x,
				y);
		// x=340;
		// pgraphics.drawString("Patient ID:       "+patient,x,y);
		x = 30;
		y += 15;
		pgraphics.drawString("Referring", x, y);
		y += 9;
		pgraphics.drawString("Physician:", x, y);
		x = 103;
		pgraphics.drawString(pname, x, y);
		x = 340;
		pgraphics.drawString("Date of Service:  " + collectDate.trim(), x, y);
		x = 118;
		y += 22;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
		pgraphics.drawString("THE FOLLOWING LABORATORY TEST WAS"
				+ " FORWARDED TO US FOR ANALYSIS", x, y);
		if (pastDue) {
			x = 206;
			y += 20;
			pgraphics.setFont(new Font("Monospaced", Font.BOLD, 14));
			pgraphics.drawString("YOUR ACCOUNT IS NOW DUE", x, y);
		}
		if (finalNotice) {
			x = 206;
			y += 20;
			pgraphics.setFont(new Font("Monospaced", Font.BOLD, 14));
			pgraphics.drawString("**** FINAL NOTICE ****", x, y);
		}
		x = 74;
		y += 16;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 10));
		pgraphics.drawString("PLEASE SEND REMITTANCE WITH CHECK "
				+ "PAYABLE TO:  Pennsylvania Cytology Services", x, y);
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 10));
		// x=166;y+=22;
		// pgraphics.drawString("TEST:",x,y);
		x = 96;
		y += 22;
		pgraphics.drawString("TEST   DESCRIPTION ", x, y);
		// x=402;
		// pgraphics.drawString("BALANCE DUE:",x,y);
		x = 402;
		pgraphics.drawString("  AMOUNT ", x, y);
		x = 96;
		y += 12;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
		pgraphics.drawString(dashedLine, x, y);
		/*
		 * if (!format.isNull(rebill) && !rebillCode.equals("CP")) { x=96;y+=6;
		 * pgraphics.setFont(new Font("Monospaced",Font.PLAIN,8));
		 * pgraphics.drawString("STATUS:",x,y-2); pgraphics.setFont(new
		 * Font("Monospaced",Font.PLAIN,10));
		 * pgraphics.drawString(rebill,x+42,y); }
		 */
		FieldPosition pos = new FieldPosition(df.INTEGER_FIELD);
		for (int i = 0; i < numItems; i++) {
			x = 96;
			y += 12;
			pgraphics.drawString(procCodes[i] + "  " + procDescr[i], x, y);
			x = 406;
			StringBuffer buf = new StringBuffer();
			StringBuffer buf2 = new StringBuffer();
			df.format(itemAmts[i], buf, pos);
			buf2.append(" $");
			for (int j = 0; j < INT_LEN - pos.getEndIndex(); j++)
				buf2.append(' ');
			buf2.append(buf.toString());
			pgraphics.drawString(buf2.toString(), x, y);
		}
		x = 96;
		y += 12;
		pgraphics.drawString(dashedLine, x, y);
		x = 226;
		y += 18;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 10));
		if (!billing_type.equals("IS00"))
			pgraphics.drawString("TOTAL DUE UPON RECEIPT ----> ", x, y);
		else
			pgraphics.drawString("TOTAL CURRENT BALANCE -----> ", x, y);
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
		x = 406;
		StringBuffer buf = new StringBuffer();
		StringBuffer buf2 = new StringBuffer();
		if (finished >= 4)
			amount = 0;
		df.format(amount, buf, pos);
		buf2.append(" $");
		for (int j = 0; j < INT_LEN - pos.getEndIndex(); j++)
			buf2.append(' ');
		buf2.append(buf.toString());
		pgraphics.drawString(buf2.toString(), x, y);
		x = 96;
		y += 15;
		pgraphics.drawString(dashedLine, x, y);
		if (finalNotice) {
			x = 97;
			y += 8;
			pgraphics.setFont(new Font("Monospaced", Font.BOLD, 8));
			pgraphics
					.drawString(
							"If we do not receive payment within 10"
									+ " days, your account will be placed for collection",
							x, y);
			x = 156;
			y += 9;
			pgraphics.drawString("and any additional charges by them"
					+ " will be your responsibility.", x, y);
			x = 96;
			y += 8;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
			pgraphics.drawString(dashedLine, x, y);
		}
		x = 204;
		y += 8;
		buf = new StringBuffer();
		buf.append("PLEASE INCLUDE LAB # ");
		buf.append(Integer.toString(labNum));
		buf.append(" ON YOUR CHECK");
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 9));
		// pgraphics.drawString("PLEASE INCLUDE LAB NUMBER ON YOUR CHECK",x,y);
		if (!billing_type.equals("IS00"))
			pgraphics.drawString(buf.toString(), x, y);

		if (!format.isNull(rebill) && !rebillCode.equals("CP")) {
			x = 30;
			y += 24;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
			pgraphics.drawString("Insurance", x, y);
			y += 9;
			pgraphics.drawString("Status:", x, y);
			x = 103;
			pgraphics.setFont(new Font("Monospaced", Font.BOLD, 10));
			pgraphics.drawString(rebill, x, y);
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
		}

		if (!format.isNull(commentText)) {
			x = 30;
			y += 24;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
			pgraphics.drawString("Comment: ", x, y);
			x = 103;
			pgraphics.setFont(new Font("Monospaced", Font.BOLD, 10));
			pgraphics.drawString(commentText, x, y);
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 10));
		}

		if (y >= 390)
			hasSecondPage = true;
		else {
			x = 30;
			y = 400;
			pgraphics.setFont(new Font("Monospaced", Font.BOLD, 9));
			pgraphics.drawString("COMPLETE TO PAY BY CREDIT CARD", x, y);
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
			x = 230;
			y -= 2;
			pgraphics.setColor(java.awt.Color.lightGray.darker());
			pgraphics.drawRect(x, y - 6, 8, 8);
			pgraphics.drawRect(x + 74, y - 6, 8, 8);
			pgraphics.drawRect(x + 148, y - 6, 8, 8);
			pgraphics.drawRect(x + 247, y - 6, 8, 8);
			pgraphics.setColor(java.awt.Color.black);
			Point point =  this.printCcInfo(pgraphics, x, y) ;
			y = point.y ; 
			x = 406;
			y += 7;
			pgraphics.setFont(new Font("Monospaced", Font.ITALIC, 6));
			pgraphics.drawString("(three digit code on the back of the card)",
					x, y);
			x = 30;
			y += 17;
			pgraphics.setFont(new Font("Monospaced", Font.BOLD, 9));
			pgraphics
					.drawString(
							"PLEASE COMPLETE IF WE HAVE NOT ALREADY SUBMITTED THIS CLAIM TO YOUR INSURANCE",
							x, y);
			y += 13;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
			pgraphics
					.drawString(
							"Reason for PAP smear __________________________ "
									+ "Signature ________________________ Date signed _______________",
							x, y);
			y += 20;
			pgraphics
					.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
			pgraphics.drawString("BLUE SHIELD", x, y);
			x = 88;
			y -= 2;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
			pgraphics
					.drawString(
							"(You MUST include ALPHA prefix with the agreement number)",
							x, y);
			x = 30;
			y += 13;
			pgraphics.drawString(
					"Agreement # _________________________ Group # _______________________ "
							+ "Patient's date of birth ________________", x, y);
			y += 13;
			pgraphics
					.drawString(
							"Subscriber ____________________________________________ "
									+ "Relationship to subscriber ___________________________",
							x, y);
			y += 20;
			pgraphics
					.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
			pgraphics.drawString("MEDICARE", x, y);
			y += 11;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
			pgraphics
					.drawString(
							"Health Insurance Claim Number (including the letter) "
									+ "_________________________________________________________",
							x, y);
			y += 13;
			pgraphics
					.drawString(
							"Patient's date of birth __________________ "
									+ "Phone _________________________ Marital status ____________________",
							x, y);
			y += 20;
			pgraphics
					.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
			pgraphics.drawString("MEDICAL ASSISTANCE", x, y);
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
			y += 11;
			pgraphics
					.drawString(
							"Please complete for proper state only. "
									+ "If your state is not listed we are unable to submit your claim.",
							x, y);
			y += 11;
			int save_y = y + 9;
			x = 240;
			pgraphics.setColor(java.awt.Color.lightGray.darker());
			for (int i = 0; i < 10; i++, x += 22)
				pgraphics.drawRect(x, y, 13, 13);
			x = 240;
			y += 20;
			for (int i = 0; i < 12; i++, x += 22)
				pgraphics.drawRect(x, y, 13, 13);
			x = 240;
			y += 20;
			for (int i = 0; i < 11; i++, x += 22)
				pgraphics.drawRect(x, y, 13, 13);
			x = 30;
			y = save_y;
			pgraphics.setColor(java.awt.Color.black);
			pgraphics.drawString("  Pennsylvania 10-digit Access Recipient #",
					x, y);
			y += 20;
			pgraphics.drawString("                  Ohio 12-digit Medicaid #",
					x, y);
			y += 20;
			pgraphics.drawString("         West Virginia 11-digit Medicaid #",
					x, y);
			y += 20;
			pgraphics
					.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
			pgraphics.drawString("OTHER/COMMERCIAL INSURANCE", x, y);
			y += 11;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
			pgraphics.drawString(
					"If you have an insurance form please complete your "
							+ "part and forward with this statement to us.", x,
					y);
			y += 13;
			pgraphics
					.drawString(
							"Insurance ID # ______________________________________ "
									+ "Employer/Group # _______________________________________ ",
							x, y);
			y += 13;
			pgraphics
					.drawString(
							"Subscriber ____________________________________________ "
									+ "Relationship to subscriber ___________________________",
							x, y);
			y += 13;
			pgraphics
					.drawString(
							"Insurance company name/address"
									+ "                                         Patient's date of birth _______________",
							x, y);
			y += 13;
			pgraphics
					.drawString(
							"________________________________________________________"
									+ "______________________________________________________",
							x, y);
			y += 10;
			pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
			buf = new StringBuffer();
			buf.append(labNum + "-" + patient);
			if (printMode == QUEUE)
				buf.append("-Q" + timesPrinted);
			else if (printMode == COPY)
				buf.append("-C" + timesPrinted);
			globalCounter++;
			buf.append("-" + globalCounter);
			pgraphics.drawString(buf.toString(), x, y);
		}
		x = 172;
		y = 759;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 12));
		pgraphics.drawString("YOUR PROMPT ATTENTION IS APPRECIATED", x, y);
		x = 78;
		y = 767;
		pgraphics.setFont(new Font("Monospaced", Font.ITALIC, 6));
		pgraphics
				.drawString(
						"Pennsylvania Cytology Services * Suite 1700 Parkway Building * "
								+ "339 Old Haymaker Road * Monroeville, PA 15146 * (412) 373-8300",
						x, y);
	}

	public Point printCcInfo(Graphics pgraphics, int x, int y) {
		Point point = new Point() ; 
		pgraphics.drawString("AMEX", x + 12, y);
		pgraphics.drawString("VISA", x + 86, y);
		pgraphics.drawString("MASTERCARD", x + 160, y);
		pgraphics.drawString("DISCOVER", x + 259, y);
		x = 30;
		y += 14;
		pgraphics
				.drawString(
						"Cardholder name ____________________________________"
								+ " Exp date _________________ Phone ________________________",
						x, y);
		y += 13;
		pgraphics
				.drawString(
						"Account number _____________________________________"
								+ "________________________ Verification Code _______________",
						x, y);
		point.x = x; 
		point.y = y ; 
		return point ;
		
	}

	public void dequeue(int labNum) {
		String query = null;
		PreparedStatement pstmt = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			if (printMode == QUEUE) {
				query = "SELECT NVL(MAX(statement_id),0) \n"
						+ "FROM pcs.patient_statements where patient="
						+ patient + " \n" + "AND lab_number=" + labNum + " \n";
				stmt = DbConnection.process().createStatement();
				rs = stmt.executeQuery(query);
				while (rs.next()) {
					statementID = rs.getInt(1);
				}
				try {
					rs.close();
					stmt.close();
				} catch (SQLException e) {
					log.write(e);
					log.write("Lab #" + labNum + "[11]");
				} catch (Exception e) {
					log.write("Lab #" + labNum);
					log.write(e);
				}
				if (statementID == 0) {
					query = "SELECT pcs.patient_statements_seq.nextval FROM DUAL \n";
					stmt = DbConnection.process().createStatement();
					rs = stmt.executeQuery(query);
					while (rs.next()) {
						statementID = rs.getInt(1);
					}
					try {
						rs.close();
						stmt.close();
					} catch (SQLException e) {
						log.write(e);
						log.write("Lab #" + labNum + "[12]");
					} catch (Exception e) {
						log.write("Lab #" + labNum);
						log.write(e);
					}
					query = "INSERT INTO pcs.patient_statements \n"
							+ "   (statement_id,lab_number,patient,billing_type, \n"
							+ "    datestamp,printed,rebilling,rebill_code,comment_text) \n"
							+ "VALUES (?,?,?,?,SysDate,1,?,?,NULL) \n";
					pstmt = DbConnection.process().prepareStatement(query);
					pstmt.setInt(1, statementID);
					pstmt.setInt(2, labNum);
					pstmt.setInt(3, patient);
					pstmt.setString(4, billing_type);
					pstmt.setInt(5, rebilling);
					pstmt.setString(6, rebillCode);
					// pstmt.setString(7,commentText);
					pstmt.executeUpdate();
					try {
						pstmt.close();
					} catch (SQLException e) {
						log.write(e);
						log.write("Lab #" + labNum + "[13]");
					} catch (Exception e) {
						log.write("Lab #" + labNum);
						log.write(e);
					}

				} else {
					query = "UPDATE pcs.patient_statements SET \n"
							+ "   billing_type = ?, \n"
							+ "   datestamp = SysDate, \n"
							+ "   printed = printed+1, \n"
							+ "   rebilling = ?, \n" + "   rebill_code = ?, \n"
							+ "   comment_text = ? \n"
							+ "WHERE statement_id = ? \n";
					pstmt = DbConnection.process().prepareStatement(query);
					pstmt.setString(1, billing_type);
					pstmt.setInt(2, rebilling);
					pstmt.setString(3, rebillCode);
					pstmt.setString(4,/* commentText */null);
					pstmt.setInt(5, statementID);
					pstmt.executeUpdate();
					try {
						pstmt.close();
					} catch (SQLException e) {
						log.write(e);
						log.write("Lab #" + labNum + "[14]");
					} catch (Exception e) {
						log.write("Lab #" + labNum);
						log.write(e);
					}
				}
			} else if (printMode == COPY) {
				query = "SELECT MAX(statement_id) \n"
						+ "FROM pcs.patient_statements where patient="
						+ patient + " \n";
				stmt = DbConnection.process().createStatement();
				rs = stmt.executeQuery(query);
				while (rs.next()) {
					statementID = rs.getInt(1);
				}
				try {
					rs.close();
					stmt.close();
				} catch (SQLException e) {
					log.write(e);
					log.write("Lab #" + labNum + "[15]");
				} catch (Exception e) {
					log.write("Lab #" + labNum);
					log.write(e);
				}
				query = "UPDATE pcs.patient_statements \n"
						+ "SET printed=printed+1, comment_text = ? \n"
						+ "WHERE statement_id = ? \n";
				pstmt = DbConnection.process().prepareStatement(query);
				pstmt.setString(1,/* commentText */null);
				pstmt.setInt(2, rebilling);
				pstmt.executeUpdate();
			}
			if (printMode == QUEUE) {
				query = "DELETE FROM pcs.billing_queue \n"
						+ "WHERE lab_number = ? and billing_route='PAT' \n";
				pstmt = DbConnection.process().prepareStatement(query);
				pstmt.setInt(1, labNum);
				pstmt.executeUpdate();
				query = "SELECT past_due FROM pcs.patient_accounts \n"
						+ "WHERE lab_number=" + labNum + " \n";
				stmt = DbConnection.process().createStatement();
				rs = stmt.executeQuery(query);
				int pflag = (999);
				while (rs.next()) {
					pflag = rs.getInt(1);
				}
				try {
					rs.close();
					pstmt.close();
					stmt.close();
				} catch (SQLException e) {
					log.write(e);
					log.write("Lab #" + labNum + "[16]");
				} catch (Exception e) {
					log.write("Lab #" + labNum);
					log.write(e);
				}
				if (pflag == (999)) {
					query = "INSERT INTO pcs.patient_accounts (patient,lab_number, \n"
							+ "   create_date,total_balance,past_due,total_charges,due_date_start) \n"
							+ "VALUES (?,?,SysDate,?,0,?,SysDate) \n";
					pstmt = DbConnection.process().prepareStatement(query);
					pstmt.setInt(1, patient);
					pstmt.setInt(2, labNum);
					pstmt.setDouble(3, amount);
					pstmt.setDouble(4, amount);
					pstmt.executeUpdate();
				} else {
					query = "UPDATE pcs.patient_statements \n"
							+ "SET printed=printed+1, comment_text = ? \n"
							+ "WHERE statement_id = ? \n";
					pstmt = DbConnection.process().prepareStatement(query);
					pstmt.setString(1,/* commentText */null);
					pstmt.setInt(2, statementID);
					pstmt.executeUpdate();
					try {
						pstmt.close();
					} catch (SQLException e) {
						log.write(e);
						log.write("Lab #" + labNum + "[17]");
					} catch (Exception e) {
						log.write("Lab #" + labNum);
						log.write(e);
					}
					query = "UPDATE pcs.patient_accounts \n"
							+ "SET due_date_start = SysDate \n"
							+ "WHERE patient = ? and lab_number = ? and past_due=0 \n";
					pstmt = DbConnection.process().prepareStatement(query);
					pstmt.setInt(1, patient);
					pstmt.setInt(2, labNum);
					pstmt.executeUpdate();
				}
				try {
					pstmt.close();
				} catch (SQLException e) {
					log.write(e);
					log.write("Lab #" + labNum + "[18]");
				} catch (Exception e) {
					log.write("Lab #" + labNum);
					log.write(e);
				}
				query = "UPDATE pcs.lab_requisitions SET finished=2 \n"
						+ "WHERE lab_number = ? and finished<2 \n";
				pstmt = DbConnection.process().prepareStatement(query);
				pstmt.setInt(1, labNum);
				pstmt.executeUpdate();
			}
			try {
				pstmt.close();
			} catch (SQLException e) {
				log.write(e);
				log.write("Lab #" + labNum + "[19]");
			} catch (Exception e) {
				log.write("Lab #" + labNum);
				log.write(e);
			}
			query = "INSERT into pcs.patient_statement_history \n"
					+ "   (statement_id,patient,billing_type,datestamp,rebill_code,comment_text) \n"
					+ "VALUES (?,?,?,SysDate,?,?) \n";
			pstmt = DbConnection.process().prepareStatement(query);
			pstmt.setInt(1, statementID);
			pstmt.setInt(2, patient);
			pstmt.setString(3, billing_type);
			pstmt.setString(4, rebillCode);
			pstmt.setString(5, commentText);
			pstmt.executeUpdate();
			try {
				pstmt.close();
			} catch (SQLException e) {
				log.write(e);
				log.write("Lab #" + labNum + "[20]");
			} catch (Exception e) {
				log.write("Lab #" + labNum);
				log.write(e);
			}
			query = "DELETE FROM pcs.db_comments WHERE lab_number = ? \n";
			pstmt = DbConnection.process().prepareStatement(query);
			pstmt.setInt(1, labNum);
			pstmt.executeUpdate();
			try {
				pstmt.close();
			} catch (SQLException e) {
				log.write(e);
				log.write("Lab #" + labNum + "[21]");
			} catch (Exception e) {
				log.write("Lab #" + labNum);
				log.write(e);
			}
		} catch (SQLException e) {
			log.write(e);
			log.write("Lab #" + labNum + "[22]");
		} catch (Exception e) {
			log.write("Lab #" + labNum);
			log.write(e);
		}
	}

	public void printSecondPage(Graphics pgraphics) {
		StringBuffer buf;
		int x, y;

		x = 198;
		y = 50;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 12));
		pgraphics.drawString("* * *  P A G E  T W O  * * *", x, y);
		x = 30;
		y += 50;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 9));
		pgraphics.drawString("COMPLETE TO PAY BY CREDIT CARD", x, y);
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
		x = 230;
		y -= 2;
		pgraphics.setColor(java.awt.Color.lightGray.darker());
		pgraphics.drawRect(x, y - 6, 8, 8);
		pgraphics.drawRect(x + 74, y - 6, 8, 8);
		pgraphics.drawRect(x + 148, y - 6, 8, 8);
		pgraphics.drawRect(x + 247, y - 6, 8, 8);
		pgraphics.setColor(java.awt.Color.black);

		Point point =  this.printCcInfo(pgraphics, x, y) ;
		y = point.y ; 
		x = point.x ; 
		y += 24;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 9));
		pgraphics
				.drawString(
						"PLEASE COMPLETE IF WE HAVE NOT ALREADY SUBMITTED THIS CLAIM TO YOUR INSURANCE",
						x, y);
		y += 13;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
		pgraphics
				.drawString(
						"Reason for PAP smear __________________________ "
								+ "Signature ________________________ Date signed _______________",
						x, y);
		y += 20;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
		pgraphics.drawString("BLUE SHIELD", x, y);
		x = 88;
		y -= 2;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
		pgraphics.drawString(
				"(You MUST include ALPHA prefix with the agreement number)", x,
				y);
		x = 30;
		y += 13;
		pgraphics.drawString(
				"Agreement # _________________________ Group # _______________________ "
						+ "Patient's date of birth ________________", x, y);
		y += 13;
		pgraphics
				.drawString(
						"Subscriber ____________________________________________ "
								+ "Relationship to subscriber ___________________________",
						x, y);
		y += 20;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
		pgraphics.drawString("MEDICARE", x, y);
		y += 11;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
		pgraphics
				.drawString(
						"Health Insurance Claim Number (including the letter) "
								+ "_________________________________________________________",
						x, y);
		y += 13;
		pgraphics
				.drawString(
						"Patient's date of birth __________________ "
								+ "Phone _________________________ Marital status ____________________",
						x, y);
		y += 20;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
		pgraphics.drawString("MEDICAL ASSISTANCE", x, y);
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
		y += 11;
		pgraphics
				.drawString(
						"Please complete for proper state only. "
								+ "If your state is not listed we are unable to submit your claim.",
						x, y);
		y += 11;
		int save_y = y + 9;
		x = 240;
		pgraphics.setColor(java.awt.Color.lightGray.darker());
		for (int i = 0; i < 10; i++, x += 22)
			pgraphics.drawRect(x, y, 13, 13);
		x = 240;
		y += 20;
		for (int i = 0; i < 12; i++, x += 22)
			pgraphics.drawRect(x, y, 13, 13);
		x = 240;
		y += 20;
		for (int i = 0; i < 11; i++, x += 22)
			pgraphics.drawRect(x, y, 13, 13);
		x = 30;
		y = save_y;
		pgraphics.setColor(java.awt.Color.black);
		pgraphics
				.drawString("  Pennsylvania 10-digit Access Recipient #", x, y);
		y += 20;
		pgraphics
				.drawString("                  Ohio 12-digit Medicaid #", x, y);
		y += 20;
		pgraphics
				.drawString("         West Virginia 11-digit Medicaid #", x, y);
		y += 20;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD + Font.ITALIC, 8));
		pgraphics.drawString("OTHER/COMMERCIAL INSURANCE", x, y);
		y += 11;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
		pgraphics.drawString(
				"If you have an insurance form please complete your "
						+ "part and forward with this statement to us.", x, y);
		y += 13;
		pgraphics
				.drawString(
						"Insurance ID # ______________________________________ "
								+ "Employer/Group # _______________________________________ ",
						x, y);
		y += 13;
		pgraphics
				.drawString(
						"Subscriber ____________________________________________ "
								+ "Relationship to subscriber ___________________________",
						x, y);
		y += 13;
		pgraphics
				.drawString(
						"Insurance company name/address"
								+ "                                         Patient's date of birth _______________",
						x, y);
		y += 13;
		pgraphics
				.drawString(
						"________________________________________________________"
								+ "______________________________________________________",
						x, y);
		y += 10;
		pgraphics.setFont(new Font("Monospaced", Font.PLAIN, 8));
		buf = new StringBuffer();
		buf.append(labNum + "-" + patient);
		if (printMode == QUEUE)
			buf.append("-Q" + timesPrinted);
		else if (printMode == COPY)
			buf.append("-C" + timesPrinted);
		pgraphics.drawString(buf.toString(), x, y);
		x = 172;
		y = 759;
		pgraphics.setFont(new Font("Monospaced", Font.BOLD, 12));
		pgraphics.drawString("YOUR PROMPT ATTENTION IS APPRECIATED", x, y);
		x = 78;
		y = 767;
		pgraphics.setFont(new Font("Monospaced", Font.ITALIC, 6));
		pgraphics
				.drawString(
						"Pennsylvania Cytology Services * Suite 1700 Parkway Building * "
								+ "339 Old Haymaker Road * Monroeville, PA 15146 * (412) 373-8300",
						x, y);
	}

}
