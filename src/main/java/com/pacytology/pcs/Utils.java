package com.pacytology.pcs;

/*
 PENNSYLVANIA CYTOLOGY SERVICES
 LABORATORY INFORMATION SYSTEM V1.0
 Copyright (C) 2001 by John Cardella
 All Rights Reserved

 File:       Utils.java
 Created By: John Cardella, Software Engineer

 Function:   A random collection of utilities used to format
 and verify data and options in the data entry forms of the 
 application.  

 MODIFICATIONS ----------------------------------
 Date/Staff      Description:
 */

import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Font;
import java.awt.Insets;
import java.awt.print.Printable;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.MessageFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.print.PrintException;
import javax.print.PrintService;
import javax.print.PrintServiceLookup;
import javax.print.attribute.AttributeSet;
import javax.print.attribute.HashPrintRequestAttributeSet;
import javax.print.attribute.PrintRequestAttributeSet;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JList;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.text.JTextComponent;

import org.apache.commons.io.FileUtils;

import com.pacytology.pcs.io.FileTransfer;
import com.pacytology.pcs.ui.Square;

public class Utils {

	// Printer orientation for java.printer
	final public static boolean LANDSCAPE = false;
	final public static boolean PORTRAIT = true;

	final public static Color FORM_BACKGROUND = Color.blue.darker();
	final public static Color CARET = Color.green.brighter();
	final public static Color DISABLED = Color.white;
	final public static Color TEXT_FOREGROUND = Color.green;
	final public static Color TEXT_BACKGROUND = Color.black;
	final public static Color LABEL_FOREGROUND = Color.yellow.brighter();
	final public static Color LIST_FOREGROUND = Color.black;
	final public static Color LIST_BACKGROUND = Color.white;
	final public static Color SELECTED_FOREGROUND = Color.black;
	final public static Color SELECTED_BACKGROUND = Color.yellow;
	final public static Color TABLE_FOREGROUND = Color.black;
	final public static Color TABLE_BACKGROUND = Color.white;
	final public static Color SQUARE = Color.yellow.brighter();
	final public static Color MENU_FOREGROUND = Color.white;
	final public static Color MENU_BACKGROUND = Color.black.darker();
	final public static Color BUTTON_FOREGROUND = Color.BLACK;

	final private static Integer INIT = new Integer(64);
	final private static Integer MASTER_SELECT = new Integer(33);
	final public static Integer PICA = new Integer(80);
	final public static Integer ELITE = new Integer(77);
	final public static Integer COMPRESSED = new Integer(48);
	final public static Integer CONDENSED = new Integer(15);
	final public static Integer EMPHASIZED = new Integer(69);
	public static final String TMP_DIR = System.getProperty("java.io.tmpdir");
	public static final String UTL_FILE_DIR = "REPORTS_DIR";

	public static final String SERVER_DIR = (System.getProperty("server.dir") != null) ? System	
			.getProperty("server.dir") : "/uTest/reports/";
	public static final String LOG_PATH = (System.getProperty("log.dir") != null) ? System
			.getProperty("log.dir") : new File(".").getAbsolutePath();
	public static final String RESOURCE_DIR = (System.getProperty("resource.dir") != null) ? System 
			.getProperty("resource.dir") : new File(".").getAbsolutePath();
	public static final String HOST_IP = (System.getProperty("host.ip") != null) ? System
			.getProperty("host.ip") : "192.168.1.110";
	public static final String HOST_PORT = (System.getProperty("host.port") != null) ? System
			.getProperty("host.port") : "22";
	public static final String HOST_PWD = (System.getProperty("host.pwd") != null) ? System
			.getProperty("host.pwd") : "xxxxx";
	public static final String DOT_MATRIX_PRINTER = (System
			.getProperty("dotmatrix.printer") != null) ? System
			.getProperty("dotmatrix.printer") : "CUPS_PDF";
	public static final String PRINTER = (System.getProperty("printer") != null) ? System
			.getProperty("printer") : "CUPS_PDF";
	public static final String LAB_MED_DIAGCODE = "V72.62";

	public Utils() {
	}

	public static String doctorName(DoctorRec dRec) {
		StringBuffer dName = new StringBuffer();
		if (!isNull(dRec.fname)) {
			dName.append(dRec.fname);
			dName.append(" ");
		}
		if (!isNull(dRec.mi)) {
			dName.append(dRec.mi);
			dName.append(" ");
		}
		dName.append(dRec.lname);
		if (!isNull(dRec.title))
			dName.append(" " + dRec.title.trim());
		return (dName.toString());
	}

	public static String doctorName(DoctorRec dRec, boolean startWithLname) {
		if (!startWithLname)
			return doctorName(dRec);
		StringBuffer dName = new StringBuffer();
		dName.append(dRec.lname);
		if (!isNull(dRec.fname)) {
			dName.append(", ");
			dName.append(dRec.fname);
			dName.append(" ");
		}
		if (!isNull(dRec.mi)) {
			dName.append(dRec.mi);
			dName.append(" ");
		}
		if (!isNull(dRec.title))
			dName.append(" " + dRec.title.trim());
		return (dName.toString());
	}

	public static String addPhoneMask(String inputString) {
		if (isNull(inputString))
			return null;
		String outputString = "(" + inputString.substring(0, 3) + ") "
				+ inputString.substring(3, 6) + "-" + inputString.substring(6);
		return (outputString);
	}

	public static String stripPhoneMask(String inputString) {
		int slen = inputString.length();
		if (slen == 0)
			return null;
		String outputString = inputString.substring(1, 4)
				+ inputString.substring(6, 9) + inputString.substring(10);
		return (outputString);
	}

	public static void buildPhoneMask(JTextField phoneField) {
		String buf = phoneField.getText();
		if (buf.length() == 1) {
			buf = "(" + buf;
			phoneField.setText(buf);
		} else if (buf.length() == 4) {
			buf = buf + ") ";
			phoneField.setText(buf);
		} else if (buf.length() == 9) {
			buf = buf + "-";
			phoneField.setText(buf);
		} else if (buf.length() > 13) {
			buf = buf.substring(0);
			phoneField.setText(buf);
		}
	}

	public static void buildPhoneMask(java.awt.event.KeyEvent event) {
		if (event.getKeyChar() == '\r' || event.getKeyChar() == '\b')
			return;
		forceDigits(event, 14);
		StringBuffer field = new StringBuffer();
		field.append(((JTextField) event.getComponent()).getText());

		if (length(field.toString()) == 1)
			field.insert(0, "(");
		else if (length(field.toString()) == 4)
			field.append(") ");
		else if (length(field.toString()) == 9)
			field.append('-');
		((JTextField) event.getComponent()).setText(field.toString());
	}

	public static String addZipMask(String inputString) {
		if (isNull(inputString))
			return null;
		int slen = 0;
		String outputString = null;
		try {
			slen = inputString.length();
		} catch (Exception e) {
			System.out.println(e + " addZipMask");
		}
		if (slen >= 5) {
			outputString = inputString.substring(0, 5);
			if (slen > 5)
				outputString = outputString + "-" + inputString.substring(5);
		} else
			outputString = null;
		return (outputString);
	}

	public static String stripZipMask(String inputString) {
		int slen = inputString.length();
		if (slen == 0)
			return null;
		String outputString = null;
		if (slen > 5) {
			outputString = inputString.substring(0, 5)
					+ inputString.substring(6);
		} else
			outputString = inputString;
		return (outputString);
	}

	public static void buildZipMask(JTextField zipField) {
		String buf = zipField.getText();
		if (buf.length() == 5) {
			buf = buf + "-";
			zipField.setText(buf);
		} else if (buf.length() > 9) {
			buf = buf.substring(0);
			zipField.setText(buf);
		}
	}

	public static void buildZipMask(java.awt.event.KeyEvent event) {
		if (event.getKeyChar() == '\r' || event.getKeyChar() == '\b')
			return;
		forceDigits(event, 10);
		StringBuffer field = new StringBuffer();
		field.append(((JTextField) event.getComponent()).getText());
		if (length(field.toString()) == 5)
			field.append('-');
		((JTextField) event.getComponent()).setText(field.toString());
	}

	public static String addSSNMask(String inputString) {
		if (isNull(inputString))
			return null;
		int slen = 0;
		String outputString = null;
		try {
			slen = inputString.length();
		} catch (Exception e) {
			System.out.println(e + " addSSNMask");
		}
		if (slen > 0) {
			outputString = inputString.substring(0, 3) + "-"
					+ inputString.substring(3, 5) + "-"
					+ inputString.substring(5);
		}
		return (outputString);
	}

	public static String stripSSNMask(String inputString) {
		int slen = inputString.length();
		if (slen == 0)
			return null;
		String outputString = null;
		outputString = inputString.substring(0, 3)
				+ inputString.substring(4, 6) + inputString.substring(7);
		return (outputString);
	}

	public static String addShortSSN(String inputString) {
		if (isNull(inputString))
			return null;
		int slen = 0;
		String outputString = null;
		try {
			slen = inputString.length();
		} catch (Exception e) {
			System.out.println(e + " addShortSSN");
		}
		if (slen > 0) {
			outputString = "###-##-" + inputString.substring(5);
		}
		return (outputString);
	}

	public static void buildSSNMask(JTextField ssnField) {
		String buf = ssnField.getText();
		if (buf.length() == 3) {
			buf = buf + "-";
			ssnField.setText(buf);
		} else if (buf.length() == 6) {
			buf = buf + "-";
			ssnField.setText(buf);
		} else if (buf.length() > 10) {
			buf = buf.substring(0);
			ssnField.setText(buf);
		}
	}

	public static void buildSSNMask(java.awt.event.KeyEvent event) {
		if (event.getKeyChar() == '\r' || event.getKeyChar() == '\b')
			return;
		forceDigits(event, 11);
		StringBuffer field = new StringBuffer();
		field.append(((JTextField) event.getComponent()).getText());
		if (length(field.toString()) == 3 || length(field.toString()) == 6)
			field.append('-');
		((JTextField) event.getComponent()).setText(field.toString());
	}

	public static String addDateMask(String inputString) {
		if (isNull(inputString))
			return null;
		int slen = 0;
		String outputString = null;
		try {
			slen = inputString.length();
		} catch (Exception e) {
			System.out.println(e + " addDateMask");
		}
		if (slen > 0) {
			outputString = inputString.substring(0, 2) + "/"
					+ inputString.substring(2, 4) + "/"
					+ inputString.substring(4);
		}
		return (outputString);
	}

	public static String stripDateMask(String inputString) {
		int slen = inputString.length();
		String outputString = null;
		if (slen == 0)
			return null;
		else if (slen < 8)
			outputString = inputString;
		else {
			outputString = inputString.substring(0, 2)
					+ inputString.substring(3, 5) + inputString.substring(6);
		}
		return (outputString);
	}

	public static void buildDateMask(JTextField dateField) {
		String buf = dateField.getText();
		if (buf.length() == 2) {
			buf = buf + "/";
			dateField.setText(buf);
		} else if (buf.length() == 5) {
			buf = buf + "/";
			dateField.setText(buf);
		} else if (buf.length() > 9) {
			buf = buf.substring(0);
			dateField.setText(buf);
		}
	}

	public static void buildDateMask(java.awt.event.KeyEvent event) {
		if (event.getKeyChar() == '\r' || event.getKeyChar() == '\b')
			return;
		forceDigits(event, 10);
		StringBuffer field = new StringBuffer();
		field.append(((JTextField) event.getComponent()).getText());
		if (length(field.toString()) == 2 || length(field.toString()) == 5)
			field.append('/');
		((JTextField) event.getComponent()).setText(field.toString());
	}

	public static int length(String s) {
		int slen = 0;
		try {
			slen = s.length();
		} catch (Exception e) {
		}
		return (slen);
	}

	public static boolean isNull(String s) {
		int slen = 0;
		boolean rv = false;
		try {
			slen = s.length();
		} catch (Exception e) {
		}
		if (slen == 0)
			rv = true;
		return (rv);
	}

	public static String isNull(String candidate, String alternate) {
		if (isNull(candidate))
			return alternate;
		else
			return candidate;
	}

	public static boolean equals(String theString, String compareValue) {
		boolean areEqual = false;
		if (isNull(theString)) {
			if (isNull(compareValue))
				areEqual = true;
			else
				areEqual = false;
		} else if (isNull(compareValue))
			areEqual = false;
		else if (theString.equals(compareValue))
			areEqual = true;
		return (areEqual);
	}

	public static boolean requiredField(JTextField field, String s) {
		boolean rv = true;
		if (isNull(field.getText())) {
			createErrMsg("Required Field: [" + s + "]");
			rv = false;
		}
		return (rv);
	}

	public static boolean required(JTextField field, String s) {
		boolean rv = true;
		if (isNull(field.getText())) {
			createErrMsg("Required Field: [" + s + "]");
			rv = false;
		}
		return (rv);
	}

	public static void deselect(java.awt.event.FocusEvent event) {
		JTextComponent t = (JTextComponent) event.getSource();
		if (!isNull(t.getText())) {
			t.select(0, 0);
			t.setCaretPosition(length(t.getText()));
		}

	}

	public static void createErrMsg(String msg) {
		(new ErrorDialog(msg)).setVisible(true);
	}

	public static void createRedErrMsg(String msg) {
		(new ErrorDialog(msg, true)).setVisible(true);
	}

	public static void createErrMsg(String msg, String loc) {
		(new ErrorDialog(msg, loc)).setVisible(true);
	}

	public static boolean dateVerify(JTextField field) {
		String sDate = stripDateMask(field.getText());
		if (isNull(sDate))
			return (true);
		int year, month, day;
		String buf;
		boolean status = true;
		if (length(sDate) != 8) {
			String msg = sDate + " is not a valid date";
			createErrMsg(msg);
			field.setText(null);
			return false;
		}
		buf = sDate.substring(0, 2);
		month = Integer.parseInt(buf);
		buf = sDate.substring(2, 4);
		day = Integer.parseInt(buf);
		buf = sDate.substring(4, 8);
		year = Integer.parseInt(buf);
		if ((month < 1) || (month > 12)) {
			status = false;
			String msg = "Invalid month entered [" + month + "]";
			createErrMsg(msg);
		} else {
			switch (month) {
			case 1:
			case 3:
			case 5:
			case 7:
			case 8:
			case 10:
			case 12:
				if ((day < 1) || (day > 31)) {
					status = false;
					String msg = "Invalid Day [" + day + "] for Month ["
							+ month + "]";
					createErrMsg(msg);
				}
				break;
			case 2:
				if ((day < 1) || (day > 29)) {
					status = false;
					String msg = "Invalid Day [" + day + "] for Month ["
							+ month + "]";
					createErrMsg(msg);
				}
				if ((day == 29) && ((year % 4) != 0)) {
					status = false;
					String msg = "Invalid Leap Year [" + year + "]";
					createErrMsg(msg);
				}
				break;
			case 4:
			case 6:
			case 9:
			case 11:
				if ((day < 1) || (day > 30)) {
					status = false;
					String msg = "Invalid Day [" + day + "] for Month ["
							+ month + "]";
					createErrMsg(msg);
				}
				break;
			}
		}
		if ((year < 1800) || (year > 2100)) {
			status = false;
			String msg = "Invalid Year [" + year + "]";
			createErrMsg(msg);
		}

		if (!status)
			field.setText(null);
		return (status);
	}

	public static void forceUpper(java.awt.event.KeyEvent event) {
		try {
			char key = event.getKeyChar();
			if ((key >= 'a') && (key <= 'z'))
				event.setKeyChar((char) (key - 32));
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	public static void forceUpper(java.awt.event.KeyEvent event, int size) {
		if (length(((JTextField) event.getComponent()).getText()) > (size - 1))
			event.consume();
		else {
			try {
				char key = event.getKeyChar();
				if ((key >= 'a') && (key <= 'z'))
					event.setKeyChar((char) (key - 32));
			} catch (Exception e) {
				System.out.println(e);
			}
		}
	}

	public static void forceDigits(java.awt.event.KeyEvent event) {
		try {
			char key = event.getKeyChar();
			if (((key < '0') || (key > '9')) && key != '\b')
				event.consume();
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	public static void forceDigits(java.awt.event.KeyEvent event, int size) {
		if (length(((JTextField) event.getComponent()).getText()) > (size - 1))
			event.consume();
		else {
			try {
				char key = event.getKeyChar();
				if (((key < '0') || (key > '9')) && key != '\b')
					event.consume();
			} catch (Exception e) {
				System.out.println(e);
			}
		}
	}

	public static String blankString(int sz) {
		StringBuffer s = new StringBuffer();
		for (int i = 0; i < sz; i++) {
			s.append(' ');
		}
		return s.toString();
	}

	public static String removeSpaces(String old) {
		StringBuffer s = new StringBuffer();
		for (int i = 0; i < old.length(); i++) {
			char c = old.charAt(i);
			if (i != ' ')
				s.append(c);
		}
		return (s.toString());
	}

	public static String rpad(String s, int sz) {
		return (rpad(s, sz, " "));
	}

	public static String rpad(String s, int sz, String c) {
		if (isNull(s))
			return blankString(sz);
		int len = s.length();
		if (len <= 0)
			return null;
		else if (len >= sz)
			return s.substring(0, sz);
		StringBuffer ns = new StringBuffer(s);
		for (int i = len; i < sz; i++)
			ns.append(c);
		return ns.toString();
	}

	public static String lpad(String s, int sz) {
		return (lpad(s, sz, " "));
	}

	public static String lpad(String s, int sz, String c) {
		if (isNull(s))
			return blankString(sz);
		int len = s.length();
		if (len <= 0)
			return null;
		else if (len >= sz)
			return s.substring(0, sz);
		StringBuffer ns = new StringBuffer();
		for (int i = 0; i < (sz - len); i++)
			ns.append(c);
		ns.append(s);
		return ns.toString();
	}

	public static String dblToString(double d) {
		String s = (new Double(d)).toString();
		StringBuffer sb = new StringBuffer();
		int j = 0;
		boolean dec = false;
		for (int i = 0; i < s.length(); i++) {
			if (s.charAt(i) == '.')
				dec = true;
			if (dec)
				j++;
			sb.append(s.charAt(i));
			if (j == 3)
				break;
		}
		return (sb.toString());
	}

	public static String random() {
		int x = (new Random()).nextInt();
		if (x < 0)
			x *= (-1);
		return Integer.toString(x);
	}

	public static void setColors(Container c) {
		int count = c.getComponentCount();
		c.setBackground(FORM_BACKGROUND);
		for (int i = 0; i < count; i++) {
			try {
				Component obj = c.getComponent(i);
				setComponent(obj);
				obj.repaint();
			} catch (Exception e) {
				System.out.println(e);
			}
		}
	}

	public static void setComponent(Component obj) {
		try {
			String s = obj.getClass().getName();
			if (s.equals("javax.swing.JTextField")) {
				obj.setBackground(TEXT_BACKGROUND);
				obj.setForeground(TEXT_FOREGROUND);
				((JTextComponent) obj).setDisabledTextColor(DISABLED);
				((JTextComponent) obj).setCaretColor(CARET);
				((JTextComponent) obj).setFont(new Font("SansSerif", Font.BOLD,
						12));
			}
			if (s.equals("javax.swing.JTextArea")) {
				obj.setBackground(TEXT_BACKGROUND);
				obj.setForeground(TEXT_FOREGROUND);
				((JTextComponent) obj).setDisabledTextColor(DISABLED);
				((JTextComponent) obj).setCaretColor(CARET);
				((JTextComponent) obj).setFont(new Font("SansSerif", Font.BOLD,
						12));
			} else if (s.equals("javax.swing.JCheckBox")) {
				obj.setBackground(FORM_BACKGROUND);
				obj.setForeground(LABEL_FOREGROUND);
				((JCheckBox) obj).setFont(new Font("SansSerif", Font.BOLD, 12));
			} else if (s.equals("javax.swing.JButton")) {
				obj.setForeground(BUTTON_FOREGROUND);
				((JButton) obj).setFont(new Font("SansSerif", Font.BOLD, 12));
			} else if (s.equals("javax.swing.JLabel")) {
				obj.setForeground(LABEL_FOREGROUND);
				obj.setFont(new Font("Dialog", Font.BOLD, 12));
			} else if (s.equals("javax.swing.JList")) {
				obj.setBackground(LIST_BACKGROUND);
				obj.setForeground(LIST_FOREGROUND);
				((JList) obj).setFont(new Font("SansSerif", Font.BOLD, 9));
				((JList) obj).setSelectionBackground(SELECTED_BACKGROUND);
				((JList) obj).setSelectionForeground(SELECTED_FOREGROUND);
			} else if (s.equals("javax.swing.JTable")) {
				obj.setBackground(TABLE_BACKGROUND);
				obj.setForeground(TABLE_FOREGROUND);
				((JTable) obj).setSelectionBackground(SELECTED_BACKGROUND);
				((JTable) obj).setSelectionForeground(SELECTED_FOREGROUND);
			} else if (s.equals("javax.swing.JPanel")) {
				setColors((Container) obj);
			} else if (s.equals("javax.swing.JScrollPane")) {
				setColors((Container) obj);
			} else if (s.equals("javax.swing.JViewport")) {
				setColors((Container) obj);
			} else if (obj instanceof Square) {
				obj.setForeground(SQUARE);
			} else if (s.equals("javax.swing.JMenuBar")) {
				setColors((Container) obj);
			} else if (s.equals("javax.swing.JMenu")) {
				obj.setBackground(MENU_BACKGROUND);
				obj.setForeground(MENU_FOREGROUND);
			}
		} catch (Exception e) {
			;
			System.out.println(e);
		}
	}

	/*
	 * Tests the date sent in (format = MM/DD/YYYY); time is default to midnight
	 * of the day sent in. The result is:
	 * 
	 * FALSE if the date sent in is the same as or before today's date
	 * 
	 * TRUE if the date sent in is after today's date
	 */
	public static boolean afterToday(String date) {
		String sDate = stripDateMask(date);
		if (isNull(sDate))
			return (false);
		int year, month, day;
		String buf;
		if (length(sDate) != 8)
			return (false);
		buf = sDate.substring(0, 2);
		month = Integer.parseInt(buf);
		buf = sDate.substring(2, 4);
		day = Integer.parseInt(buf);
		buf = sDate.substring(4, 8);
		year = Integer.parseInt(buf);
		Date testDate = new Date(year - 1900, month - 1, day);
		Date rightNow = new Date();
		return (testDate.after(rightNow));
	}

	public static boolean beforeDate(String date, int days) {
		boolean result = false;
		String sDate = stripDateMask(date);
		if (isNull(sDate))
			return (false);
		String buf;
		if (length(sDate) != 8)
			return (false);
		buf = sDate.substring(4, 8) + sDate.substring(0, 2)
				+ sDate.substring(2, 4);
		Calendar rightNow = Calendar.getInstance();
		rightNow.add(rightNow.DATE, (days * (-1)));
		String buf2 = Integer.toString(rightNow.get(Calendar.YEAR));
		int month = rightNow.get(Calendar.MONTH) + 1;
		if (month < 10)
			buf2 = buf2 + "0";
		buf2 = buf2 + Integer.toString(month);
		int day = rightNow.get(Calendar.DAY_OF_MONTH);
		if (day < 10)
			buf2 = buf2 + "0";
		buf2 = buf2 + Integer.toString(day);
		int testDate = (int) Integer.parseInt(buf);
		int earlyDate = (int) Integer.parseInt(buf2);
		if (testDate < earlyDate)
			result = true;
		return (result);
	}

	public static void genericPrint(String output, String defaultPrinterName) {
		genericPrint(output, new MessageFormat(""), new MessageFormat(""),
				defaultPrinterName);
	}

	public static void genericPrint(String output) {
		genericPrint(output, new MessageFormat(""), new MessageFormat(""), null);
	}

	public static void genericPrint(String output, MessageFormat title,
			MessageFormat footerMsg, boolean orientation) {

		JTextArea area51 = new JTextArea();
		area51.setLineWrap(true);
		area51.setWrapStyleWord(true);
		Font font = new Font("Arial", Font.PLAIN, 10);
		area51.setFont(font);
		area51.setText(output);

		Printer.print(area51.getPrintable(title, footerMsg), orientation,
				new Insets(10, 10, 10, 10), null);

	}

	public static void largePrint(String output, MessageFormat title,
			MessageFormat footerMsg) {

		JTextArea area51 = new JTextArea();
		area51.setLineWrap(true);
		area51.setWrapStyleWord(true);
		Font font = new Font("Monospaced", Font.PLAIN, 10);
		area51.setFont(font);

		area51.setText(output);
		boolean portrait = true;
		Printer.print(area51.getPrintable(title, footerMsg), portrait,
				new Insets(10, 10, 10, 10), null, 377.825F, 279.4F);

	}

	public static void genericPrint(String output, MessageFormat title,
			MessageFormat footerMsg) {

		JTextArea area51 = new JTextArea();
		area51.setLineWrap(true);
		area51.setWrapStyleWord(true);
		Font font = new Font("Arial", Font.PLAIN, 10);
		area51.setFont(font);
		String[] pages = output.split("\f");
		for (String page : pages) {
			area51.setText(page);
			boolean portrait = false;
			Printer.print(area51.getPrintable(title, footerMsg), portrait,
					new Insets(10, 10, 10, 10), null);
		}

	}

	public static void genericPrint(String output, MessageFormat title,
			MessageFormat footerMsg, String defaultPrinterName) {

		JTextArea area51 = new JTextArea();
		area51.setLineWrap(true);
		area51.setWrapStyleWord(true);
		Font font = new Font("Arial", Font.PLAIN, 10);
		area51.setFont(font);
		String[] pages = output.split("\f");
		for (String page : pages) {
			area51.setText(page);
			Printer.print(area51.getPrintable(title, footerMsg), true,
					new Insets(10, 10, 10, 10), defaultPrinterName);
		}

	}
	public static void genericPrint(String filePath, String fileName,
			boolean forcePage) {
		File f = FileTransfer.getFile(Utils.TMP_DIR, filePath, fileName);
		
		if (f.exists()) {
			long fLen = f.length();
			if (fLen > 0) {
				String output = "";
				try {
					output = FileUtils.readFileToString(f);
				} catch (IOException e) {
					e.printStackTrace();
				}
				Utils.genericPrint(output);
			}
		} else
			createErrMsg("Cannot locate report: " + fileName);
	}
	public static void genericPrint(String filePath, String fileName,
			boolean forcePage, String defaultPrinterName) {
		File f = FileTransfer.getFile(Utils.TMP_DIR, filePath, fileName);
		
		if (f.exists()) {
			long fLen = f.length();
			if (fLen > 0) {
				String output = "";
				try {
					output = FileUtils.readFileToString(f);
				} catch (IOException e) {
					e.printStackTrace();
				}
				Utils.genericPrint(output, defaultPrinterName);
			}
		} else
			createErrMsg("Cannot locate report: " + fileName);
	}

	public static void genericPrint(String filePath, String fileName,
			boolean forcePage, Vector printerCodes) {
		File f;
		File f2;
		FileInputStream fIN;
		FileOutputStream fOUT;
		f = new File(filePath, fileName);
		f2 = new File("c:\\", "lpt1");
		if (f.exists()) {
			long fLen = f.length();
			if (fLen > 0) {
				try {
					fIN = new FileInputStream(f);
					fOUT = new FileOutputStream(f2);
					setPrinterCode(fOUT, INIT);
					for (int ndx = 0; ndx < printerCodes.size(); ndx++)
						setPrinterCode(fOUT,
								(Integer) printerCodes.elementAt(ndx));
					int size = (int) fLen;
					if (forcePage)
						fLen -= 2;
					for (int k = 0; k < fLen; k++) {
						// for (;;) {
						int x = fIN.read();
						if (x == (-1))
							break;
						fOUT.write(x);
					}
					// if (forcePage) fOUT.write(12);
					fIN.close();
					fOUT.close();
				} catch (Exception e) {
					System.out.println(e);
				}
			}
		} else
			createErrMsg("Cannot locate report: " + fileName);
	}

	private static void setPrinterCode(FileOutputStream fOUT,
			Integer printerCode) {
		try {
			fOUT.write(27);
			fOUT.write(printerCode.intValue());
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	

	public static String getMonthName(int m) {
		String monthName = null;
		switch (m) {
		case 1:
			monthName = "JANUARY";
			break;
		case 2:
			monthName = "FEBRUARY";
			break;
		case 3:
			monthName = "MARCH";
			break;
		case 4:
			monthName = "APRIL";
			break;
		case 5:
			monthName = "MAY";
			break;
		case 6:
			monthName = "JUNE";
			break;
		case 7:
			monthName = "JULY";
			break;
		case 8:
			monthName = "AUGUST";
			break;
		case 9:
			monthName = "SEPTEMBER";
			break;
		case 10:
			monthName = "OCTOBER";
			break;
		case 11:
			monthName = "NOVEMBER";
			break;
		case 12:
			monthName = "DECEMBER";
			break;
		}
		return (monthName);
	}

	/***********************************************************************
	 * CODE PUT IN TO READ DATA FROM INVOICE OR INVOICE DATA FILES ASSUMES
	 * READING FROM G:\ DRIVE
	 **********************************************************************/
	public static void readAccountFile(String fName, int yearMonth) {
		File f = null;
		FileInputStream fIN = null;
		f = FileTransfer.getFile(Utils.TMP_DIR, Utils.SERVER_DIR, fName);
		boolean digits = false;
		if (f.exists() && f.length() > 0) {
			StringBuffer s = new StringBuffer();
			try {
				fIN = new FileInputStream(f);
				for (;;) {
					int x = fIN.read();
					if (x == -1)
						break;
					System.out.print(".");
					if (x >= '0' && x <= '9') {
						digits = true;
						s.append((char) x);
					} else {
						digits = false;
						if (s.length() == 10) {
							String y = new String(s.toString().substring(0, 4));
							if (y.equals("2002") || y.equals("2003")
									|| y.equals("2004")) {
								insert(s.toString(), fName, yearMonth);
							}
						}
						s = new StringBuffer();
					}
				}
				fIN.close();
			} catch (Exception e) {
			}
		}
	}

	private static void insert(String labNum, String fileName, int yearMonth) {
		String SQL = "INSERT into pcs.acct_diagnostic \n"
				+ "   (lab_number,file_name,practice,year_month) \n"
				+ "SELECT TO_NUMBER(?),?,practice,? \n"
				+ "FROM pcs.lab_requisitions \n"
				+ "WHERE lab_number = TO_NUMBER(?) \n";
		try {
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setString(1, labNum);
			pstmt.setString(2, fileName);
			pstmt.setInt(3, yearMonth);
			pstmt.setString(4, labNum);
			pstmt.execute();
			pstmt.close();
		} catch (Exception e) {
		}
	}

	public static int getAge(String birthDate) {
		int age = 0;
		if (isNull(birthDate))
			age = (-1);
		else {
			String today = DbConnection.getDate();
			age = getAge(birthDate, today);
		}
		return (age);
	}

	public static int getAge(String birthDate, String targetDate) {
		final int CENTURY = 10000;
		int yearsOld = -1;
		int DOB = 0;
		int comparisonDate = 0;
		String bDate = birthDate.substring(4) + birthDate.substring(0, 2)
				+ birthDate.substring(2, 4);
		String tDate = targetDate.substring(4) + targetDate.substring(0, 2)
				+ targetDate.substring(2, 4);
		try {
			DOB = (int) Integer.parseInt(bDate);
			comparisonDate = (int) Integer.parseInt(tDate);
		} catch (Exception e) {
		}
		yearsOld = (int) Math.ceil((double) ((comparisonDate - DOB) / CENTURY));
		return (yearsOld);
	}

	// Not yet implemented
	public static Vector getLabResults(int labNumber) {
		Vector labResults = new Vector();
		return (labResults);
	}

	public static Vector getLabResults(String labNumber) {
		int lab = (int) Integer.parseInt(labNumber);
		return (getLabResults(lab));
	}

	public static boolean hasResults(int labNumber) {
		boolean resultsExist = false;
		int rcnt = 0;
		String SQL = "SELECT count(*) \n" + "FROM pcs.lab_results \n"
				+ "WHERE lab_number = ? \n";
		try {
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setInt(1, labNumber);
			ResultSet rs = pstmt.executeQuery();
			while (rs.next()) {
				rcnt = rs.getInt(1);
			}
			rs.close();
			pstmt.close();
		} catch (Exception e) {
			System.out.println(e + " [" + labNumber + "]");
		}
		if (rcnt > 0)
			resultsExist = true;
		return (resultsExist);
	}

	// Assumes file name is NoProgram.csv on C:\[root]
	// Assumes file is in correct format:
	// Each line of file contains three data elements
	// (1) Account number (not used)
	// (2) Lab number
	// (3) Program name (valid value from PCS.ADPH_PROGRAMS)
	// Each data element is separated by a comma
	public static void processNPfile() {
		File f = new File(RESOURCE_DIR, "NoProgram.csv");
		if (f.exists()) {
			long fLen = f.length();
			if (fLen > 0) {
				try {
					FileInputStream fIN = new FileInputStream(f);
					StringBuffer s = new StringBuffer();
					for (int k = 0; k < fLen - 2; k++) {
						int x = fIN.read();
						if (x == -1)
							break;
						char c = (char) x;
						if (c == '\n') {
							String token = ",";
							StringTokenizer st = new StringTokenizer(
									s.toString(), token, false);
							int labNumber = 0;
							String programName = null;
							for (int j = 0; j < 3; j++) {
								String t = st.nextToken();
								if (j == 1)
									labNumber = (int) Integer.parseInt(t);
								else if (j == 2)
									programName = t;
							}
							updateProgram(labNumber, programName);
							s = new StringBuffer();
						} else {
							if (c != '\r') s.append(c);
						}
					}
					fIN.close();
				} catch (Exception e) {
					System.out.println(e.getMessage());
					e.printStackTrace();
					createErrMsg("The file (:  " + RESOURCE_DIR + "NoProgram.csv) is not formatted correctly.");
				}
			}
		} else
			createErrMsg("Cannot locate NP file:  " + RESOURCE_DIR + "NoProgram.csv");
	}

	public static void updateReceiveDate(int labNumber, String receiveDate) {
		String SQL = "UPDATE pcs.lab_requisitions \n"
				+ "SET receive_date = TO_DATE(?,'MMDDYYYY') \n"
				+ "WHERE lab_number = ? \n";
		try {
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setString(1, receiveDate);
			pstmt.setInt(2, labNumber);
			pstmt.execute();
			pstmt.close();
		} catch (Exception e) {
			System.out.println(e + " [" + labNumber + "]");
		}
	}

	private static void updateProgram(int labNumber, String programName) {
		String SQL = "UPDATE pcs.adph_lab_whp \n"
				+ "SET adph_program = ?, \n"
				+ "    np_process_date=TO_DATE(TO_CHAR(SysDate,'MMDDYYYY'),'MMDDYYYY') \n"
				+ "WHERE lab_number = ? \n";
		try {
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setString(1, programName.toUpperCase());
			pstmt.setInt(2, labNumber);
			pstmt.execute();
			pstmt.close();
			SQL = "SELECT count(*) \n" + "FROM pcs.lab_req_comments \n"
					+ "WHERE lab_number = ? \n";
			pstmt = DbConnection.process().prepareStatement(SQL);
			pstmt.setInt(1, labNumber);
			ResultSet rs = pstmt.executeQuery();
			int rcnt = 0;
			while (rs.next()) {
				rcnt = rs.getInt(1);
			}
			rs.close();
			pstmt.close();
			String msg = "ADPH PROGRAM UPDATED [" + programName.toUpperCase()
					+ "] ";
			if (rcnt == 0) {
				SQL = "INSERT INTO pcs.lab_req_comments (lab_number,comment_text) \n"
						+ "VALUES (?,'" + msg + "'||SysDate)";
				pstmt = DbConnection.process().prepareStatement(SQL);
				pstmt.setInt(1, labNumber);
				pstmt.execute();
				pstmt.close();
			} else {
				SQL = "UPDATE pcs.lab_req_comments \n"
						+ "SET comment_text=comment_text||'; " + msg
						+ " '||SysDate \n" + "WHERE lab_number = ? \n";
				pstmt = DbConnection.process().prepareStatement(SQL);
				pstmt.setInt(1, labNumber);
				pstmt.execute();
				pstmt.close();
			}
		} catch (Exception e) {
			System.out.println(e + " [" + labNumber + "]");
		}
	}

	public static int getNextPatient() {
		int nextPatient = 0;
		try {
			String SQL = "SELECT pcs.patient_seq.nextval FROM dual";
			Statement stmt = DbConnection.process().createStatement();
			ResultSet rs = stmt.executeQuery(SQL);
			while (rs.next())
				nextPatient = rs.getInt(1);
			try {
				rs.close();
				stmt.close();
			} catch (SQLException e) {
				System.out.println(e);
			} catch (Exception e) {
				System.out.println(e);
			}
		} catch (SQLException e) {
			System.out.println(e);
		} catch (Exception e) {
			System.out.println(e);
		}
		return (nextPatient);
	}

	public static String getFinishedDesc(int finished) {
		String finishedDesc = null;
		switch (finished) {
		case Lab.NO_VALUE:
			finishedDesc = "NO VALUE";
			break;
		case Lab.EXPIRED_SPECIMEN:
			finishedDesc = "EXPIRED SPECIMEN";
			break;
		case Lab.RESULTS_PENDING:
			finishedDesc = "RESULTS PENDING";
			break;
		case Lab.BILLING_QUEUE:
			finishedDesc = "BILLING QUEUE 1";
			break;
		case Lab.SUBMITTED:
			finishedDesc = "BILLED, NO RESPONSE";
			break;
		case Lab.PENDING:
			finishedDesc = "BILLING RESPONSE, NOT FINISHED";
			break;
		case Lab.FINISHED:
			finishedDesc = "FINISHED";
			break;
		case Lab.FIRST_DATA_CONVERSION:
			finishedDesc = "DATA CONV 1";
			break;
		case Lab.SECOND_DATA_CONVERSION:
			finishedDesc = "DATA CONV 2";
			break;
		case Lab.THIRD_DATA_CONVERSION:
			finishedDesc = "DATA CONV 3";
			break;
		case Lab.FOURTH_DATA_CONVERSION:
			finishedDesc = "DATA CONV 4";
			break;
		default:
			finishedDesc = "INVALID VALUE FOR FINISHED";
		}
		return (finishedDesc);
	}

	public static String getPatientName(int labNum) {
		String pName = "ERROR!!";
		try {
			String SQL = "SELECT RTRIM(lname)||', '||RTRIM(fname) \n"
					+ "FROM pcs.patients \n" + "WHERE last_lab = ? \n";
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setInt(1, labNum);
			ResultSet rs = pstmt.executeQuery();
			while (rs.next())
				pName = rs.getString(1);
			try {
				rs.close();
				pstmt.close();
			} catch (SQLException e) {
				System.out.println(e);
			} catch (Exception e) {
				System.out.println(e);
			}
		} catch (SQLException e) {

			e.printStackTrace();
			System.out.println(e);
		} catch (Exception e) {
			System.out.println(e);
		}
		return (pName);
	}

	public static int getCytotech(String cytotech_code) {
		int cytotech = (-1);
		try {
			String SQL = "SELECT cytotech \n" + "FROM pcs.cytotechs \n"
					+ "WHERE cytotech_code = ? \n";
			PreparedStatement pstmt = DbConnection.process().prepareStatement(
					SQL);
			pstmt.setString(1, cytotech_code);
			ResultSet rs = pstmt.executeQuery();
			while (rs.next())
				cytotech = rs.getInt(1);
			try {
				rs.close();
				pstmt.close();
			} catch (SQLException e) {
				System.out.println(e);
			} catch (Exception e) {
				System.out.println(e);
			}
		} catch (SQLException e) {
			System.out.println(e);
		} catch (Exception e) {
			System.out.println(e);
		}
		return (cytotech);
	}

	public static String formatPractice(int p) {
		String acct = null;
		if (p < 10)
			acct = "00" + p;
		else if (p < 100)
			acct = "0" + p;
		else
			acct = (String) Integer.toString(p);
		return (acct);
	}

	static public void print(final Printable printable) {
		print(printable, true);
	}

	static public void print(final Printable printable, final boolean portrait) {
		print(printable, portrait, new Insets(10, 10, 10, 10));
	}

	/**
	 * Set defaultPrinterName using string from 'Devices and Printers'
	 * 
	 * @param printable
	 * @param portrait
	 * @param insets
	 * @param defaultPrinterName
	 */
	static public void print(final Printable printable, final boolean portrait,
			final Insets insets) {
		Printer.print(printable, portrait, insets, null);

	}

	public static void dotMatrixPrint(byte[] bArr)
			throws FileNotFoundException, PrintException, IOException {
		System.out.println("Starting dot matrix print");
		javax.print.DocPrintJob job ;
		PrintService printService ; 
		try {
			
			
			InputStream finalFile = addPrintCharTo(bArr);
			
			AttributeSet pras = new HashPrintRequestAttributeSet();
			
			javax.print.DocFlavor flavor = javax.print.DocFlavor.INPUT_STREAM.AUTOSENSE;		
			printService = getPrintService(flavor, pras,
					Utils.DOT_MATRIX_PRINTER);
			if (printService == null) {
				throw new PrintException("Configured Printer doesn't exist.. check runpcs.bat");
			}
			job = printService.createPrintJob();

			javax.print.attribute.DocAttributeSet das = new javax.print.attribute.HashDocAttributeSet();
 
			javax.print.Doc doc = new javax.print.SimpleDoc(finalFile, flavor, das);
			job.print(doc, (PrintRequestAttributeSet) pras);
		} catch (PrintException pe) {
			pe.printStackTrace();
			throw pe ; 
		}
		
		System.out.println("Finished with dot matrix print");
	}
	public static void dotMatrixPrint(InputStream file)
			throws FileNotFoundException, PrintException, IOException {
		System.out.println("Starting dot matrix print");
		javax.print.DocPrintJob job ;
		PrintService printService ; 
		try {
			
			
			InputStream finalFile = addPrintCharTo(file);
			
			AttributeSet pras = new HashPrintRequestAttributeSet();
			
			javax.print.DocFlavor flavor = javax.print.DocFlavor.INPUT_STREAM.AUTOSENSE;		
			printService = getPrintService(flavor, pras,
					Utils.DOT_MATRIX_PRINTER);
			if (printService == null) {
				throw new PrintException("Configured Printer doesn't exist.. check runpcs.bat");
			}
			job = printService.createPrintJob();

			javax.print.attribute.DocAttributeSet das = new javax.print.attribute.HashDocAttributeSet();
 
			javax.print.Doc doc = new javax.print.SimpleDoc(finalFile, flavor, das);
			job.print(doc, (PrintRequestAttributeSet) pras);
		} catch (PrintException pe) {
			pe.printStackTrace();
			throw pe ; 
		}
		
		System.out.println("Finished with dot matrix print");
	}

	private static InputStream addPrintCharTo(InputStream file)
			throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		byte[ ] buffer = new byte[1024*16];
		int size = 0;
		out.write(INIT);
		//	out.write(CONDENSED);
		//	out.write(PICA);
		out.write(MASTER_SELECT);
		out.write(new Integer(0));
		while ((size = file.read(buffer)) != -1) {
			out.write(buffer, 0, size) ;
		}
		byte[] bArr = out.toByteArray();

		InputStream finalFile = new ByteArrayInputStream(bArr);
		return finalFile;
	}
	private static InputStream addPrintCharTo(byte[]  bArr)
			throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		out.write(INIT);
		//	out.write(CONDENSED);
		//	out.write(PICA);
		out.write(MASTER_SELECT);
		out.write(new Integer(0));
		for (int i = 0; i<bArr.length; i++) {
			out.write(new byte[]{bArr[i]}, 0, 1) ;
			
		}
		byte[] outArr = out.toByteArray();

		InputStream finalFile = new ByteArrayInputStream(outArr);
		return finalFile;
	}

	public static PrintService getPrintService(javax.print.DocFlavor flavor,
			javax.print.attribute.AttributeSet pras, String printerName) {
		PrintService[] printServices = PrintServiceLookup.lookupPrintServices(
				flavor, pras);
		PrintService printService = null;
		for (PrintService ps : printServices) {
			System.out.println("Searching for " + printerName + " from " + ps.getName()) ; 
			if (ps.getName().equals(printerName)) {
				System.out.println("Found .. " + printerName + " for " + ps.getName()) ; 
				printService = ps;
			}
		}
		return printService;
	}
	public static byte[] concatenate(List<File> files, int filenameIndicator) throws FileNotFoundException, IOException {
		PrintWriter pw = new PrintWriter(new FileOutputStream(Utils.TMP_DIR + "concat"+filenameIndicator+".txt"));
		
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        for (File file : files) {
                System.out.println("Processing " + file.getPath() + "... ");
                BufferedReader br = new BufferedReader(new FileReader(file.getPath()));
            	String line = br.readLine();
                while (line != null) {
                	out.write(line.getBytes());
                	String newline = System.getProperty("line.separator");
                	out.write(newline.getBytes());
                	line = br.readLine();
                }

                br.close();
        }
        byte[] bArr = out.toByteArray();
        //pw is just for saving the concatenated results.. temp for debugging
        pw.write(out.toString());
        pw.flush();
        pw.close();
        return bArr ;
	}

}
