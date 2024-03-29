package com.pacytology.pcs;
 
/*    PENNSYLVANIA CYTOLOGY SERVICES    
LABORATORY INFORMATION SYSTEM V1.0    
Copyright (C) 2001 by John Cardella    
All Rights Reserved        
File:       Export.java
    Created By: John Cardella, Software Engineer
    
    Function:   Class used to export final report data
    to a file that is sent for HL7 processing.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
    07/02/2009      Created
*/
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import org.joda.time.DateTime;
import org.rev6.scf.SshException;

import com.pacytology.pcs.io.FileTransfer;
import com.pacytology.pcs.models.ExportError;

public class Export implements Runnable
{
	Thread fileExportThread;
	Vector data;
	String fileName;
	String filePath = "c:\\";
	private List<ExportError> errors = new ArrayList<ExportError>();
	/*
	 * static final int HL7 = 101; static final int TEXT = 102;
	 */
	int exportMode;

	/*
	 * final int CONVENTIONAL=1; // CONVENTIONAL preparation final int
	 * THIN_LAYER=2; // LIQUID-BASED preparation final int PAP_NET=3; // PAPNet
	 * testing (not used) final int CYT_NON_PAP=4; // Not a PAP smear final int
	 * HPV_ONLY=5; // HPV test only (no draft/final) final int IMAGED=7; //
	 * ThinPrep with Imaging
	 */

	final int BLANK = 0;
	final int SSN = 1;
	final int PAT_ID = 2;
	final int DOB = 3;
	final int PRAC = 4;
	final int ADDR1 = 5;
	final int ADDR2 = 6;
	final int CSZ = 7;

	int conditionsPrinted = 0;
	boolean conditionHeader = false;
	boolean clientNoteHeader = false;
	Vector amendedCodes = new Vector();
	LabReportRec labReportRec;

	public Export(int exportMode, Vector v) {
		this.exportMode = exportMode;
		this.amendedCodes = v;
	}

	public Export(int exportMode) {
		this.exportMode = exportMode;
	}

	public Export(int exportMode, LabReportRec r) {
		this.exportMode = exportMode;
		this.labReportRec = r;
	}

	/****************************************************************************
	 * THREADING METHODS FOR FILE EXPORT OPERATIONS
	 ****************************************************************************/
	public void kill() {
		try {
			fileExportThread.stop();
		} catch (Exception e) {
		}
	}

	public void write(Vector v, String f) {
		data = v;
		fileName = f;
		fileExportThread = new Thread(this);
		fileExportThread.setPriority(Thread.MAX_PRIORITY);
		fileExportThread.start();
	}

	public void write(Vector v) {
		data = v;
		fileExportThread = new Thread(this);
		fileExportThread.setPriority(Thread.MAX_PRIORITY);
		fileExportThread.start();
	}

	public void write() {
		fileExportThread = new Thread(this);
		fileExportThread.setPriority(Thread.MAX_PRIORITY);
		fileExportThread.start();
	}

	public synchronized void run() {
		if (exportMode == Lab.HL7) {
			createHL7File();
		} else if (exportMode == Lab.CYTOPATHOLOGY_REPORTS) {
			createCytopathologyFiles();
		} else if (exportMode == Lab.HPV_ONLY) {
			createIndexFile(labReportRec);
		} else if (exportMode == Lab.HPV_REPORTS) {
			createHPVfiles();
		}
	}

	/***************************************************************************/

	/***************************************************************************/
	/* METHODS FOR CREATING HL7 FILE */
	/***************************************************************************/
	private void createHL7File() {
		try {
			PrintWriter fOUT = new PrintWriter(new BufferedOutputStream(
					new FileOutputStream(filePath.trim() + fileName, false)),
					true);
			for (int i = 0; i < data.size(); i++) {
				LabReportRec labReport = (LabReportRec) data.elementAt(i);
				writeRecord(labReport, fOUT);
				fOUT.write("\n");
			}
			fOUT.close();
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	private void writeRecord(LabReportRec labReport, PrintWriter fOUT) {
		fOUT.write(labReport.lab_number + "|");
		fOUT.write(labReport.pat_lname + "|");
		fOUT.write(labReport.pat_fname + "|");
		fOUT.write(Utils.isNull(labReport.pat_mi, "") + "|");
		fOUT.write(Utils.isNull(labReport.pat_ssn, "") + "|");
		fOUT.write(Utils.isNull(labReport.pat_dob, "") + "|");
		fOUT.write(Utils.isNull(labReport.patient_id, "") + "|");
		fOUT.write(labReport.practice + "|");
		fOUT.write(labReport.prac_name + "|");
		fOUT.write(Utils.isNull(labReport.prac_address1, "") + "|");
		fOUT.write(Utils.isNull(labReport.prac_address2, "") + "|");
		fOUT.write(Utils.isNull(labReport.prac_city, "") + "|");
		fOUT.write(Utils.isNull(labReport.prac_state, "") + "|");
		fOUT.write(Utils.isNull(labReport.prac_zip, "") + "|");
		fOUT.write(Utils.isNull(labReport.doctor_text, "") + "|");
		fOUT.write(Utils.isNull(labReport.client_notes, "") + "|");
		String prepLbl = null;
		switch (labReport.preparation) {
		case 1:
			prepLbl = "CONVENTIONAL PAP SMEAR";
			break;
		case 2:
			prepLbl = "LIQUID BASED PAP TEST (ThinPrep)";
			break;
		case 4:
			prepLbl = "CYTOLOGY NON-PAP";
			break;
		case 7:
			prepLbl = "THINPREP PAP TEST WITH IMAGING SYSTEM DUAL REVIEW";
			break;
		}
		fOUT.write(prepLbl + "|");
		if (labReport.pat_last_lab > 0)
			fOUT.write(labReport.pat_last_lab + "|");
		else
			fOUT.write("|");
		fOUT.write("_D3_" + labReport.detailVect.size() + "|");
		for (int i = 0; i < labReport.detailVect.size(); i++) {
			DetailCodeRec d = (DetailCodeRec) labReport.detailVect.elementAt(i);
			fOUT.write(d.detail_type + "~");
			fOUT.write(d.description + "~");
			fOUT.write(d.textEntered.trim());
			if (i == labReport.detailVect.size() - 1)
				fOUT.write("|");
			else
				fOUT.write("~");
		}
		fOUT.write(labReport.getCytotech_code() + "|");
		fOUT.write(Utils.isNull(labReport.qc_cytotech_code, "") + "|");
		fOUT.write(Utils.isNull(labReport.superficial, "") + "|");
		fOUT.write(Utils.isNull(labReport.intermediate, "") + "|");
		fOUT.write(Utils.isNull(labReport.parabasal, "") + "|");
		fOUT.write(Utils.isNull(labReport.path_lname, "") + "|");
		fOUT.write(Utils.isNull(labReport.path_fname, "") + "|");
		fOUT.write(Utils.isNull(labReport.path_mi, "") + "|");
		fOUT.write(Utils.isNull(labReport.path_degree, "") + "|");
		fOUT.write(Utils.isNull(labReport.path_title, "") + "|");
		fOUT.write(Utils.isNull(labReport.verified_on, "") + "|");
		fOUT.write(Utils.isNull(labReport.verified_by, "") + "|");
		fOUT.write("_R3_" + labReport.resultVect.size() + "|");
		for (int i = 0; i < labReport.resultVect.size(); i++) {
			ResultCodeRec r = (ResultCodeRec) labReport.resultVect.elementAt(i);
			fOUT.write(r.bethesda_code + "~");
			if (r.category.equals("S"))
				fOUT.write("SPECIMEN ADEQUACY" + "~");
			else if (r.category.equals("G"))
				fOUT.write("GENERAL CATEGORIZATION" + "~");
			else if (r.category.equals("D"))
				fOUT.write("DESCRIPTION" + "~");
			else if (r.category.equals("R"))
				fOUT.write("REMARKS" + "~");
			fOUT.write(r.description);
			if (i == labReport.resultVect.size() - 1)
				fOUT.write("|");
			else
				fOUT.write("~");
		}
		fOUT.write("_A1_" + labReport.remarksVect.size() + "|");
		for (int i = 0; i < labReport.remarksVect.size(); i++) {
			String s = (String) labReport.remarksVect.elementAt(i);
			fOUT.write(s);
			if (i == labReport.remarksVect.size() - 1)
				fOUT.write("|");
			else
				fOUT.write("~");
		}
		fOUT.write(labReport.date_collected + "|");
		fOUT.write(labReport.receive_date + "|");
		fOUT.write(labReport.date_reported);
	}

	/***************************************************************************/

	/***************************************************************************/
	/* METHODS FOR CREATING INDIVIDUAL CYTOPATHOLOGY TEXT FILES */
	/***************************************************************************/
	private void createCytopathologyFiles() {
		String fileName = null;
		String reportName = null;
		String filePath = Utils.TMP_DIR ; 
		try {
			for (int i = 0; i < data.size(); i++) {
				fileName = null;
				reportName = null;
				conditionsPrinted = 0;
				conditionHeader = false;
				clientNoteHeader = false;
				LabReportRec labReport = (LabReportRec) data.elementAt(i);
				String webID = null;
				if (labReport.parent_account > 0)
					webID = Utils.formatPractice(labReport.parent_account);
				else
					webID = Utils.formatPractice(labReport.practice);
				reportName = (String) Integer.toString(labReport.lab_number)
						+ "_" + webID;
				fileName = reportName + ".txt";
				PrintWriter fOUT = new PrintWriter(
						new BufferedOutputStream(new FileOutputStream(
								filePath.trim() + fileName, false)), true);
				PCSHeader(labReport, fOUT);
				labPatient(labReport, fOUT);
				labDetails(labReport, fOUT);
				labResults(labReport, fOUT);
				fOUT.close();
				
				FileTransfer.sendFile(filePath.trim() + fileName, Utils.SERVER_DIR + 
						"LabInfoSystem" + "/" + 
						"ElectronicReporting" + "/" + fileName);
				fileName = reportName + ".rtf";
				fOUT = new PrintWriter(
						new BufferedOutputStream(new FileOutputStream(
								filePath.trim() + fileName, false)), true);
				writeIndexFile(labReport, fOUT);
				fOUT.close();
				FileTransfer.sendFile(filePath.trim() + fileName, Utils.SERVER_DIR + 
						"LabInfoSystem" + "/" + 
						"ElectronicReporting" + "/" + fileName);
			}
		} catch (Exception e) {
			System.out.println(e);
		}
	}

	private void PCSHeader(LabReportRec labReport, PrintWriter fOUT) {
		fOUT.write(Utils.rpad("PENNSYLVANIA CYTOLOGY SERVICES", 73)
				+ "CLIA: 39D0656968\n");
		fOUT.write(Utils.rpad("339 PARKWAY BUILDING, SUITE 1700", 50)
				+ "PENNSYLVANIA STATE LABORATORY CODE: 331\n");
		fOUT.write(Utils.rpad("MONROEVILLE, PA  15146", 47)
				+ "COLLEGE OF AMERICAN PATHOLOGISTS: 41911-01\n");
		fOUT.write("PHONE: 412.373.8300  FAX: 412.373.7027\n");
		fOUT.write(Utils.lpad("LABORATORY DIRECTOR: ROBERT H. SWEDARSKY, MD",
				89) + "\n");
		fOUT.write("-----------------------------------------------------------------------------------------\n");
	}

	void labPatient(LabReportRec labReport, PrintWriter fOUT) {
		int col1[] = { BLANK, BLANK, BLANK, BLANK };
		int col2[] = { BLANK, BLANK, BLANK, BLANK };
		StringBuffer s = new StringBuffer();
		s.append(labReport.pat_lname.trim());
		s.append(", ");
		s.append(labReport.pat_fname.trim());
		if (!Utils.isNull(labReport.pat_mi))
			s.append(" " + labReport.pat_mi);
		fOUT.write(Utils.rpad("NAME:", 14) + Utils.rpad(s.toString(), 36)
				+ "ACCOUNT #" + Utils.formatPractice(labReport.practice) + "\n");
		initPatientData(labReport, col1, col2);
		for (int i = 0; i < 4; i++) {
			String line = getPatientLine(labReport, col1[i], col2[i]);
			if (col1[i] != BLANK || col2[i] != BLANK)
				fOUT.write(line + "\n");
		}
		fOUT.write("\n");
		s = new StringBuffer();
		s.append(Utils.rpad(" ", 50));
		s.append("PHYSICIAN: ");
		int slen = 0;
		try {
			slen = labReport.doctor_text.length();
		} catch (Exception e) {
			slen = 0;
		}
		if (slen > 27)
			s.append(labReport.doctor_text.substring(0, 27));
		else
			s.append(labReport.doctor_text);
		fOUT.write(s.toString() + "\n");
		fOUT.write("-----------------------------------------------------------------------------------------\n");
	}

	void labDetails(LabReportRec labReport, PrintWriter fOUT) {
		StringBuffer s = new StringBuffer();
		DetailCodeRec dCodeRec = null;
		s.append("LAB #" + labReport.lab_number);
		if (exportMode != Lab.HPV_REPORTS) {
			switch (labReport.preparation) {
			case Lab.CONVENTIONAL:
				s.append(Utils.rpad(" CONVENTIONAL PAP SMEAR", 53));
				break;
			case Lab.THIN_LAYER:
				s.append(Utils.rpad(" LIQUID BASED PAP TEST (THINPREP)", 53));
				break;
			case Lab.CYT_NON_PAP:
				s.append(Utils.rpad(" CYTOLOGY NON-PAP", 53));
				break;
			case Lab.IMAGED_SLIDE:
				s.append(Utils.rpad(
						" THINPREP PAP TEST WITH IMAGING SYSTEM DUAL REVIEW",
						53));
				break;
			}
		} else
			s.append(Utils.rpad(" ", 53));
		s.append("COLLECTED: " + labReport.date_collected);
		fOUT.write(s.toString() + "\n");
		s = new StringBuffer();
		s.append(Utils.rpad(" ", 68));
		s.append("RECEIVED:  " + labReport.receive_date);
		fOUT.write(s.toString() + "\n");
		s = new StringBuffer();
		s.append(Utils.rpad(" ", 68));
		s.append("REPORTED:  " + labReport.date_reported);
		fOUT.write(s.toString() + "\n");
		int sourcesPrinted = 0;
		int devicesPrinted = 0;
		int othersPrinted = 0;
		int historyPrinted = 0;
		conditionsPrinted = 0;
		Vector sourceVect = extractDetails("SOURCE", labReport.detailVect);
		Vector deviceVect = extractDetails("DEVICE", labReport.detailVect);
		Vector otherVect = extractDetails("OTHER", labReport.detailVect);
		Vector conditionVect = extractDetails("CONDITION", labReport.detailVect);
		Vector historyVect = extractDetails("HISTORY", labReport.detailVect);
		
			writeSources(sourceVect, conditionVect, fOUT, "SOURCE:");
			s = new StringBuffer();
			s.append(Utils.rpad(" ", 50));
			if (conditionVect.size() > 0
					&& conditionsPrinted < conditionVect.size()) {
				dCodeRec = (DetailCodeRec) conditionVect
						.elementAt(conditionsPrinted++);
				s.append(dCodeRec.description);
				fOUT.write(s.toString() + "\n");
			} else
				fOUT.write("\n");
		
		s = new StringBuffer();
		if (labReport.numDevices > 0) {
			writeDetails(deviceVect, conditionVect, fOUT, "SAMPLING DEVICE:");
			s = new StringBuffer();
			s.append(Utils.rpad(" ", 50));
			if (conditionVect.size() > 0
					&& conditionsPrinted < conditionVect.size()) {
				dCodeRec = (DetailCodeRec) conditionVect
						.elementAt(conditionsPrinted++);
				s.append(dCodeRec.description);
				fOUT.write(s.toString() + "\n");
			} else
				fOUT.write("\n");
		}
		s = new StringBuffer();
		if (labReport.numOthers > 0) {
			writeDetails(otherVect, conditionVect, fOUT, "OTHER INFORMATION:");
			s = new StringBuffer();
			s.append(Utils.rpad(" ", 50));
			if (conditionVect.size() > 0
					&& conditionsPrinted < conditionVect.size()) {
				dCodeRec = (DetailCodeRec) conditionVect
						.elementAt(conditionsPrinted++);
				s.append(dCodeRec.description);
				fOUT.write(s.toString() + "\n");
			} else
				fOUT.write("\n");
		}
		s = new StringBuffer();
		if (labReport.numHistory > 0)
			writeHistory(historyVect, fOUT, labReport.pat_last_lab);
		s = new StringBuffer();
		if (!Utils.isNull(labReport.client_notes)) {
			fOUT.write("\n");
			writeNotes(labReport.client_notes, fOUT);
		}
		fOUT.write("-----------------------------------------------------------------------------------------\n");
	}

	private void labResults(LabReportRec labReport, PrintWriter fOUT) {
		StringBuffer s = new StringBuffer();
		StringBuffer t = new StringBuffer();
		StringBuffer descr = new StringBuffer();
		boolean remarksPrinted = false;
		boolean negativeMessage = false;
		boolean printCategory = false;
		t.append("CYTOPATHOLOGY REPORT");
		if (isAmendedReport(labReport.resultVect))
			t.append(" - AMENDED");
		if (labReport.HPVmessage) {
			s.append(Utils.rpad(t.toString(), 69));
			s.append("HPV REPORT TO FOLLOW");
		} else
			s.append(t.toString());
		fOUT.write(s.toString() + "\n");
		fOUT.write("THE BETHESDA REPORTING SYSTEM\n");
		fOUT.write("\n");
		s = new StringBuffer();
		t = new StringBuffer();
		if (labReport.iDatestamp >= 20090407)
			negativeMessage = true;
		Vector adequacy = extractResults("S", labReport.resultVect);
		Vector general = extractResults("G", labReport.resultVect);
		Vector description = extractResults("D", labReport.resultVect);
		Vector remark = extractResults("R", labReport.resultVect);
		for (int i = 0; i < labReport.numResults; i++) {
			ResultCodeRec cRec = (ResultCodeRec) labReport.resultVect
					.elementAt(i);
			if (cRec.bethesda_code.equals("014")
					|| cRec.bethesda_code.equals("011")
					|| cRec.bethesda_code.equals("013")
					|| cRec.bethesda_code.equals("13R")) {
				negativeMessage = true;
			}
		}
		if (adequacy.size() > 0) {
			writeResult(adequacy, "SPECIMEN ADEQUACY: ", fOUT);
			fOUT.write("\n");
		}
		if (general.size() > 0) {
			writeResult(general, "GENERAL CATEGORIZATION: ", fOUT);
			fOUT.write("\n");
		}
		if (description.size() > 0) {
			writeResult(description, "DESCRIPTION: ", fOUT);
			fOUT.write("\n");
		}
		if (remark.size() > 0) {
			writeResult(remark, "REMARKS: ", fOUT);
			remarksPrinted = true;
			if (labReport.remarksVect.size() > 0) {
				writeRemarks(labReport.remarksVect, false, fOUT);
			}
		} else if (labReport.remarksVect.size() > 0) {
			writeRemarks(labReport.remarksVect, true, fOUT);
		}
		fOUT.write("\n");
		if (labReport.sumMatNdx > 0) {
			s = new StringBuffer();
			s.append(Utils.rpad("MATURATION INDEX:", 26));
			s.append(Utils.rpad("SUPERFICIAL", 17));
			s.append(labReport.superficial);
			fOUT.write(s.toString() + "\n");
			s = new StringBuffer();
			s.append(Utils.rpad(" ", 26));
			s.append(Utils.rpad("INTERMEDIATE", 17));
			s.append(labReport.intermediate);
			fOUT.write(s.toString() + "\n");
			s = new StringBuffer();
			s.append(Utils.rpad(" ", 26));
			s.append(Utils.rpad("PARABASAL", 17));
			s.append(labReport.parabasal);
			fOUT.write(s.toString() + "\n\n");
		}
		fOUT.write("\n");
		if (labReport.iDatestamp >= 20050726 && negativeMessage
				&& labReport.pap_class != Lab.NON_GYNE) {
			fOUT.write("CERVICAL CYTOLOGY IS A SCREENING TEST WITH LIMITED "
					+ "SENSITIVITY AND AN IRREDUCIBLE FALSE\n");
			fOUT.write("NEGATIVE RATE.  REGULAR SCREENING IS CRITICAL FOR CANCER "
					+ "PREVENTION.  PAP TESTS ARE\n");
			fOUT.write("DESIGNED FOR THE DETECTION OF SQUAMOUS CELL CARCINOMA AND "
					+ "ITS PRECURSORS, NOT\n");
			fOUT.write("ADENOCARCINOMAS OR OTHER CANCERS.\n\n");
		}
		s = new StringBuffer();
		s.append("CYTOTECHNOLOGIST:  " + labReport.getCytotech_code().trim());
		if (!Utils.isNull(labReport.qc_cytotech_code))
			s.append("/" + labReport.qc_cytotech_code);
		fOUT.write(s.toString() + "\n");
		if (!Utils.isNull(labReport.verified_on)) {
			s = new StringBuffer();
			s.append("VERIFIED BY: " + labReport.verified_by + ", "
					+ labReport.verified_on);
			fOUT.write(s.toString() + "\n\n");
		} else
			fOUT.write("\n");
		if (!Utils.isNull(labReport.pathologist_code)) {
			s = new StringBuffer();
			s.append(labReport.path_fname + " ");
			if (!Utils.isNull(labReport.path_mi)) {
				s.append(labReport.path_mi + " ");
			}
			s.append(labReport.path_lname);
			if (!Utils.isNull(labReport.path_degree)) {
				s.append(", " + labReport.path_degree);
			}
			fOUT.write(s.toString() + "\n");
			fOUT.write(labReport.path_title + "\n\n");
			fOUT.write("ELECTRONIC SIGNATURE" + "\n");
			fOUT.write("MY ELECTRONIC SIGNATURE IS ATTESTATION "
					+ "THAT I HAVE PERSONALLY REVIEWED THE SUBMITTED\n");
			fOUT.write("MATERIAL(S) AND THE FINAL RESULT REFLECTS THAT EVALUATION.\n");
		}
	}

	private Vector extractDetails(String detailType, Vector d) {
		Vector v = new Vector();
		for (int i = 0; i < d.size(); i++) {
			DetailCodeRec dCodeRec = (DetailCodeRec) d.elementAt(i);
			if (dCodeRec.detail_type.equals(detailType))
				v.addElement(dCodeRec);
		}
		return (v);
	}

	private Vector extractResults(String category, Vector r) {
		Vector v = new Vector();
		//description is descending by result code; remarks are ascending
		if (category.equals("R"))
		{
			r=sortResults(r,true);
		} else if (category.equals("D"))
		{
			r=sortResults(r,false);
		}
		
		
		for (int i = 0; i < r.size(); i++) {
			ResultCodeRec rCodeRec = (ResultCodeRec) r.elementAt(i);
			if (rCodeRec.category.equals(category))
				v.addElement(rCodeRec);
		}
		return (v);
	}
	public static Vector sortResults(Vector vector, final boolean ascending) {
		Vector ret=new Vector();
		ret.addAll(vector);
		Collections.sort(ret,new Comparator<ResultCodeRec>() {
			@Override
			public int compare(ResultCodeRec o1, ResultCodeRec o2) {
				//Replacing characters with 0s.  Not sure if that's correct, but it
				//keeps it from failing.
				String str1 = o1.bethesda_code;
				str1=str1.replaceAll("\\D","0");
				
				String str2 = o2.bethesda_code;
				str2=str2.replaceAll("\\D","0");
				
				Integer code1=Integer.parseInt(str1);
				Integer code2=Integer.parseInt(str2);

				if (code1<code2)
				{
					return ascending?-1:1;
				} else if (code1>code2)
				{
					return ascending?1:-1;
				}
				//If they're equal, just compare on hashcode
				return  Integer.valueOf(o1.hashCode()).compareTo(Integer.valueOf(o2.hashCode())) ; 

			}
		});
		return ret;
	}

	/**
	 * This code is the same as @see writeDetail() 
	 * Except it won't print the SOURCE header if one doesn't exist 
	 * 
	 * @param src
	 * @param cnd
	 * @param fOUT
	 * @param hdr
	 */
	private void writeSources(Vector src, Vector cnd, PrintWriter fOUT,
			String hdr) {
		StringBuffer s = new StringBuffer();
		DetailCodeRec dCodeRec = null;
		if (src.size() < 1) {
			hdr = Utils.rpad("", 50);
		}
		s.append(Utils.rpad(hdr, 50));
		if (cnd.size() > 0 && !conditionHeader) {
			s.append("CONDITIONS:");
			conditionHeader = true;
		} else {
			if (cnd.size() > 0 && conditionsPrinted < cnd.size()) {
				dCodeRec = (DetailCodeRec) cnd.elementAt(conditionsPrinted++);
				s.append(dCodeRec.description);
			}
		}
		fOUT.write(s.toString() + "\n");
		s = new StringBuffer();
		for (int i = 0; i < src.size(); i++) {
			dCodeRec = (DetailCodeRec) src.elementAt(i);
			StringBuffer t = new StringBuffer(dCodeRec.description);
			if (dCodeRec.additional_info.equals("Y")) {
				t.append(": ");
				t.append(dCodeRec.textEntered);
			}
			s.append(Utils.rpad(t.toString(), 50));
			if (cnd.size() > 0 && conditionsPrinted < cnd.size()) {
				dCodeRec = (DetailCodeRec) cnd.elementAt(conditionsPrinted++);
				s.append(dCodeRec.description);
			}
			fOUT.write(s.toString() + "\n");
			s = new StringBuffer();
		}
	}
	private void writeDetails(Vector src, Vector cnd, PrintWriter fOUT,
			String hdr) {
		StringBuffer s = new StringBuffer();
		DetailCodeRec dCodeRec = null;
		s.append(Utils.rpad(hdr, 50));
		if (cnd.size() > 0 && !conditionHeader) {
			s.append("CONDITIONS:");
			conditionHeader = true;
		} else {
			if (cnd.size() > 0 && conditionsPrinted < cnd.size()) {
				dCodeRec = (DetailCodeRec) cnd.elementAt(conditionsPrinted++);
				s.append(dCodeRec.description);
			}
		}
		fOUT.write(s.toString() + "\n");
		s = new StringBuffer();
		for (int i = 0; i < src.size(); i++) {
			dCodeRec = (DetailCodeRec) src.elementAt(i);
			StringBuffer t = new StringBuffer(dCodeRec.description);
			if (dCodeRec.additional_info.equals("Y")) {
				t.append(": ");
				t.append(dCodeRec.textEntered);
			}
			s.append(Utils.rpad(t.toString(), 50));
			if (cnd.size() > 0 && conditionsPrinted < cnd.size()) {
				dCodeRec = (DetailCodeRec) cnd.elementAt(conditionsPrinted++);
				s.append(dCodeRec.description);
			}
			fOUT.write(s.toString() + "\n");
			s = new StringBuffer();
		}
	}

	private void writeHistory(Vector src, PrintWriter fOUT, int lastLab) {
		StringBuffer s = new StringBuffer();
		DetailCodeRec dCodeRec = null;
		s.append(Utils.rpad("PATIENT HISTORY:", 50));
		fOUT.write(s.toString() + "\n");
		s = new StringBuffer();
		if (lastLab > 0) {
			String t = "PREVIOUS LAB #" + Integer.toString(lastLab);
			s.append(Utils.rpad(t, 50));
			fOUT.write(s.toString() + "\n");
			s = new StringBuffer();
		}
		for (int i = 0; i < src.size(); i++) {
			dCodeRec = (DetailCodeRec) src.elementAt(i);
			StringBuffer t = new StringBuffer(dCodeRec.description.trim()
					+ ": " + dCodeRec.textEntered.trim());
			if (Utils.length(t.toString()) > 88) {
				StringBuffer t2 = new StringBuffer(t.toString());
				int endNdx = 0;
				while (Utils.length(t2.toString()) > 88) {
					for (int j = 0; j < 88; j++) {
						if (t2.charAt(j) == ' ')
							endNdx = j;
					}
					t = new StringBuffer(t2.toString().substring(0, endNdx));
					StringBuffer t3 = new StringBuffer(t2.toString()
							.substring(endNdx).trim());
					s.append(t.toString());
					fOUT.write(s.toString() + "\n");
					s = new StringBuffer();
					t2 = new StringBuffer("   " + t3.toString());
				}
				s = new StringBuffer();
				if (!Utils.isNull(t2.toString())) {
					s.append(t2.toString());
					fOUT.write(s.toString() + "\n");
					s = new StringBuffer();
				}
			} else {
				s.append(t.toString());
				fOUT.write(s.toString() + "\n");
			}
			s = new StringBuffer();
		}
	}

	private void writeNotes(String s, PrintWriter fOUT) {
		StringBuffer t = new StringBuffer(s.trim());
		StringBuffer notes = new StringBuffer();
		if (!clientNoteHeader) {
			fOUT.write("CLIENT NOTES:\n");
			clientNoteHeader = false;
		}
		if (Utils.length(t.toString()) > 88) {
			StringBuffer t2 = new StringBuffer(t.toString());
			int endNdx = 0;
			while (Utils.length(t2.toString()) > 88) {
				for (int j = 0; j < 88; j++) {
					if (t2.charAt(j) == ' ')
						endNdx = j;
				}
				t = new StringBuffer(t2.toString().substring(0, endNdx));
				StringBuffer t3 = new StringBuffer(t2.toString()
						.substring(endNdx).trim());
				notes.append(t.toString());
				fOUT.write(notes.toString() + "\n");
				notes = new StringBuffer();
				t2 = new StringBuffer("   " + t3.toString());
			}
			notes = new StringBuffer();
			if (!Utils.isNull(t2.toString())) {
				notes.append(t2.toString());
				fOUT.write(notes.toString() + "\n");
				notes = new StringBuffer();
			}
		} else {
			notes.append(t.toString());
			fOUT.write(notes.toString() + "\n");
		}
	}

	private boolean isAmendedReport(Vector codes) {
		boolean hasAmendedCode = false;
		for (int i = 0; i < codes.size(); i++) {
			ResultCodeRec r = (ResultCodeRec) codes.elementAt(i);
			if (amendedCodes.contains(r.bethesda_code)) {
				hasAmendedCode = true;
				break;
			}
		}
		return (hasAmendedCode);
	}

	private void writeResult(Vector v, String hdr, PrintWriter fOUT) {
		boolean categoryPrinted = false;
		StringBuffer s = new StringBuffer();
		for (int i = 0; i < v.size(); i++) {
			ResultCodeRec r = (ResultCodeRec) v.elementAt(i);
			if (!categoryPrinted) {
				s.append(Utils.rpad(hdr, 26));
				categoryPrinted = true;
			} else
				s.append(Utils.rpad(" ", 26));
			String x = new String(r.description);
			String y = null;
			boolean firstLine = true;
			if (Utils.length(x) > 63) {
				y = new String(x);
				int endNdx = 0;
				while (Utils.length(y) > 63) {
					for (int k = 0; k < 60; k++) {
						if (y.charAt(k) == ' ')
							endNdx = k;
					}
					x = new String(y.substring(0, endNdx));
					y = new String(y.substring(endNdx).trim());
					if (firstLine) {
						s.append(x);
						firstLine = false;
					} else {
						s.append(Utils.rpad(" ", 26));
						s.append(x);
					}
					fOUT.write(s.toString() + "\n");
					s = new StringBuffer();
				}
				if (!Utils.isNull(y)) {
					if (firstLine) {
						s.append(y);
						firstLine = false;
					} else {
						s.append(Utils.rpad(" ", 26));
						s.append(y);
					}
					fOUT.write(s.toString() + "\n");
					s = new StringBuffer();
				}
			} else {
				if (firstLine) {
					s.append(x);
					firstLine = false;
				} else {
					s.append(Utils.rpad(" ", 26));
					s.append(x);
				}
				fOUT.write(s.toString() + "\n");
				s = new StringBuffer();
			}
		}
	}

	private void writeRemarks(Vector v, boolean printCategory, PrintWriter fOUT) {
		StringBuffer s = new StringBuffer();
		boolean firstLine = false;
		if (printCategory) {
			s.append(Utils.rpad("REMARKS:", 26));
			firstLine = true;
		} else
			s.append(Utils.rpad(" ", 26));
		for (int i = 0; i < v.size(); i++) {
			String x = new String((String) v.elementAt(i));
			String y = null;
			if (Utils.length(x) > 63) {
				y = new String(x);
				int endNdx = 0;
				while (Utils.length(y) > 63) {
					for (int k = 0; k < 60; k++) {
						if (y.charAt(k) == ' ')
							endNdx = k;
					}
					x = new String(y.substring(0, endNdx));
					y = new String(y.substring(endNdx).trim());
					if (firstLine) {
						s.append(x);
						firstLine = false;
					} else {
						s.append(Utils.rpad(" ", 26));
						s.append(x);
					}
					fOUT.write(s.toString() + "\n");
					s = new StringBuffer();
				}
				if (!Utils.isNull(y)) {
					if (firstLine) {
						s.append(y);
						firstLine = false;
					} else {
						s.append(Utils.rpad(" ", 26));
						s.append(y);
					}
					fOUT.write(s.toString() + "\n");
				}
			} else {
				s.append(x);
				if (firstLine)
					firstLine = false;
				fOUT.write(s.toString() + "\n");
			}
			s = new StringBuffer();
		}
	}

	public void createIndexFile(LabReportRec r) {
		/*
		 * GAK 7/19/2012 Modify this to create the file locally and send to the
		 * server.
		 */
		String filePath = Utils.TMP_DIR;

		String webID = null;
		String reportName = null;
		String fileName = null;
		if (r.parent_account > 0)
			webID = Utils.formatPractice(r.parent_account);
		else
			webID = Utils.formatPractice(r.practice);
		reportName = (String) Integer.toString(r.lab_number) + "_" + webID;
		fileName = reportName + ".rtf";
		PrintWriter fOUT = null;
		try {
			fOUT = new PrintWriter(new BufferedOutputStream(
					new FileOutputStream(filePath.trim() + fileName, false)),
					true);
		} catch (Exception e) {
			System.out.println(e);
		}
		writeIndexFile(r, fOUT);
		fOUT.close();
		// Send that file to the server
		try {
			FileTransfer.sendFile(filePath.trim() + fileName, Utils.SERVER_DIR + fileName);
		} catch (SshException e) {
			e.printStackTrace();
		}

	}

	private void writeIndexFile(LabReportRec r, PrintWriter fOUT) {
		fOUT.write(r.pat_lname + "\n");
		fOUT.write(r.pat_fname + "\n");
		fOUT.write(Utils.isNull(r.pat_dob, " ") + "\n");
		fOUT.write(Utils.isNull(r.doctor_text, " ") + "\n");
		fOUT.write(r.lab_number + "\n");
		fOUT.write(Utils.isNull(Utils.addSSNMask(r.pat_ssn), " ") + "\n");
		fOUT.write(r.date_collected + "\n");
		fOUT.write(r.receive_date + "\n");
		fOUT.write(r.datestamp + "\n");
		if (r.parent_account > 0)
			fOUT.write(Utils.formatPractice(r.parent_account) + "\n");
		else
			fOUT.write(Utils.formatPractice(r.practice) + "\n");
		fOUT.write(Utils.isNull(r.program, " ") + "\n");
	}

	private void initPatientData(LabReportRec r, int col1[], int col2[]) {
		/* LINE 1 */
		if (!Utils.isNull(r.pat_ssn))
			col1[0] = SSN;
		else if (!Utils.isNull(r.patient_id))
			col1[0] = PAT_ID;
		else if (!Utils.isNull(r.pat_dob))
			col1[0] = DOB;
		else
			col1[0] = BLANK;
		col2[0] = PRAC;
		/* LINE 2 */
		if (col1[0] == SSN) {
			if (!Utils.isNull(r.patient_id))
				col1[1] = PAT_ID;
			else if (!Utils.isNull(r.pat_dob))
				col1[1] = DOB;
		} else if (col1[0] == PAT_ID) {
			if (!Utils.isNull(r.pat_dob))
				col1[1] = DOB;
		} else if (col1[0] == DOB) {
			col1[1] = BLANK;
		} else
			col1[0] = BLANK;
		col2[1] = ADDR1;
		/* LINE 3 */
		if (col1[1] == PAT_ID) {
			if (!Utils.isNull(r.pat_dob))
				col1[2] = DOB;
		} else if (col1[1] == DOB) {
			col1[2] = BLANK;
		} else
			col1[2] = BLANK;
		if (!Utils.isNull(r.prac_address2))
			col2[2] = ADDR2;
		else
			col2[2] = CSZ;
		/* LINE 4 */
		if (col2[2] == ADDR2)
			col2[3] = CSZ;
		else
			col2[3] = BLANK;
	}

	private String getPatientLine(LabReportRec r, int c1, int c2) {
		StringBuffer s = new StringBuffer();
		switch (c1) {
		case SSN:
			s.append(Utils.rpad("SSN:", 14)
					+ Utils.rpad(Utils.addSSNMask(r.pat_ssn), 36));
			break;
		case PAT_ID:
			s.append(Utils.rpad("PATIENT ID:", 14)
					+ Utils.rpad(r.patient_id, 36));
			break;
		case DOB:
			s.append(Utils.rpad("DOB:", 14) + Utils.rpad(r.pat_dob, 36));
			break;
		case BLANK:
			s.append(Utils.rpad(" ", 50));
			break;
		}
		switch (c2) {
		case PRAC:
			String t = null;
			if (Utils.length(r.prac_name) > 39)
				t = r.prac_name.substring(0, 39);
			else
				t = r.prac_name;
			s.append(t);
			break;
		case ADDR1:
			s.append(r.prac_address1);
			break;
		case ADDR2:
			s.append(r.prac_address2);
			break;
		case CSZ:
			s.append(r.prac_city + ", ");
			s.append(r.prac_state + " ");
			s.append(Utils.addZipMask(r.prac_zip));
			break;
		}
		return (s.toString());
	}

	/***************************************************************************/
	/* METHODS FOR CREATING INDIVIDUAL HPV TEXT FILES */
	/***************************************************************************/
	private void createHPVfiles() {
		
		String fileName = null;
		String reportName = null;
		String filePath = Utils.TMP_DIR;
		String destPath = Utils.SERVER_DIR
				+ "LabInfoSystem"+
				"/"+
				"ElectronicReporting"+
				"/";
		LabReportRec labReport = null; 
		List<FileMap<String, String, Integer>> files = new ArrayList<FileMap<String, String, Integer>>();
		try {
			for (int i = 0; i < data.size(); i++) {
				fileName = null;
				reportName = null;
				conditionsPrinted = 0;
				conditionHeader = false;
				clientNoteHeader = false;
				labReport = (LabReportRec) data.elementAt(i);
				String webID = null;
				if (labReport.parent_account > 0)
					webID = Utils.formatPractice(labReport.parent_account);
				else
					webID = Utils.formatPractice(labReport.practice);
				reportName = (String) Integer.toString(labReport.lab_number)
						+ "_" + webID;
				fileName = reportName + ".hpv";
				PrintWriter fOUT = new PrintWriter(
						new BufferedOutputStream(new FileOutputStream(
								filePath.trim() + fileName, false)), true);
				PCSHeader(labReport, fOUT);
				labPatient(labReport, fOUT);
				labDetails(labReport, fOUT);
				hpvResults(labReport, fOUT);
				fOUT.close();
				FileMap<String, String, Integer> fileMap1 = new FileMap<String, String, Integer>(
						filePath + fileName, destPath+fileName, labReport.lab_number) ;
				files.add(fileMap1) ; 
				fileName = reportName + ".rtf";
				fOUT = new PrintWriter(
						new BufferedOutputStream(new FileOutputStream(
								filePath.trim() + fileName, false)), true);
				writeIndexFile(labReport, fOUT);
				fOUT.close();
				FileMap<String, String, Integer> fileMap2 = new FileMap<String, String, Integer>(
						filePath + fileName, destPath+fileName, labReport.lab_number) ;
				files.add(fileMap2) ; 
			}
			FileTransfer.sendFiles(files) ;
		} catch (Exception e) {
			System.out.println(e.getMessage());
			e.printStackTrace();
			String errMsg = "Error occurred while creating HPV Report for Lab Number " + labReport.lab_number + ".  " + e.getMessage() ; 

			ExportError expError = new ExportError();
			expError.setLab_number(labReport.lab_number);
			expError.setDatestamp(DateTime.now().toDate());
			expError.setError(errMsg);
			getErrors().add(expError);
			
		}
	}

	void hpvResults(LabReportRec labReport, PrintWriter fOUT) {
		StringBuffer s = new StringBuffer();
		StringBuffer t = new StringBuffer();
		StringBuffer descr = new StringBuffer();
		boolean remarksPrinted = false;
		boolean negativeMessage = false;
		boolean printCategory = false;
		s.append("DIGENE HYBRID CAPTURE II HPV TEST");
		fOUT.write(s.toString() + "\n\n");
		fOUT.write("RESULTS:\n\n\n");
		s = new StringBuffer();
		s.append("HIGH RISK                           ");
		if (!Utils.isNull(labReport.test_sent)) {
			if (labReport.test_sent.equals("Q")) {
				s.append("Q U A N T I T Y   N O T   S U F F I C I E N T");
			} else if (!Utils.isNull(labReport.test_results)) {
				if (labReport.test_results.equals("+")) {
					s.append("P O S I T I V E");
				} else if (labReport.test_results.equals("-")) {
					s.append("N E G A T I V E");
				}
			}
		}
		fOUT.write(s.toString() + "\n");
		fOUT.write("(HPV TYPES 16, 18, 31, 33\n");
		fOUT.write("35, 39, 45, 51, 52, 56, 58\n");
		fOUT.write("59, 68)\n\n");
		fOUT.write("Reference Interval: NEGATIVE\n");
		fOUT.write("\n\n\n\n\n\n");
		s = new StringBuffer();
		s.append("CYTOTECHNOLOGIST:  ");
		s.append(labReport.getCytotech_code().trim());
		fOUT.write(s.toString() + "\n\n\n");
		fOUT.write("-----------------------------------------------------------------------------------------\n");
	}

	public Thread getFileExportThread() {
		return this.fileExportThread;
	}

	List<ExportError> getErrors() {
		return errors;
	}

	void setErrors(List<ExportError> errors) {
		this.errors = errors;
	}
	
	
}
    
     
