package com.pacytology.pcs.models;

public class LabRequisition {
	/*
	 * LAB_NUMBER								       NOT NULL NUMBER(11)
	 REQ_NUMBER								       NOT NULL NUMBER(11)
	 PATIENT								       NOT NULL NUMBER(8)
	 PRACTICE								       NOT NULL NUMBER(6)
	 DOCTOR 										NUMBER(6)
	 PATIENT_ID										VARCHAR2(16)
	 SLIDE_QTY										NUMBER(1)
	 PREPARATION										NUMBER(1)
	 DATE_COLLECTED 							       NOT NULL DATE
	 LMP											VARCHAR2(16)
	 AGE											NUMBER(3)
	 RUSH											CHAR(1)
	 BILLING_CHOICE 							       NOT NULL NUMBER(3)
	 FINISHED								       NOT NULL NUMBER(3)
	 DATESTAMP										DATE
	 SYS_USER										NUMBER(4)
	 PREVIOUS_LAB										NUMBER(11)
	 RECEIVE_DATE										DATE
	 DOCTOR_TEXT										VARCHAR2(128)
	 */

	private int lab_number ;
	private Patient patient ;
	private Practice practice ; 
	private HpvRequest hpvRequest ; 
	private LabResult labResult ; 
	
	public int getLab_number() {
		return lab_number;
	}

	public void setLab_number(int lab_number) {
		this.lab_number = lab_number;
	} 
	public void setPatient(Patient patient) {
		this.patient = patient ; 
	}
	public Patient getPatient() {
		return this.patient ; 
	}

	public HpvRequest getHpvRequest() {
		return hpvRequest;
	}

	public void setHpvRequest(HpvRequest hpvRequest) {
		this.hpvRequest = hpvRequest;
	}

	public LabResult getLabResult() {
		return labResult;
	}

	public void setLabResult(LabResult labResult) {
		this.labResult = labResult;
	}

	public Practice getPractice() {
		return practice;
	}

	public void setPractice(Practice practice) {
		this.practice = practice;
	}


	
	
}
