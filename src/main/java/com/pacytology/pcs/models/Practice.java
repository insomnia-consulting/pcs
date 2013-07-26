package com.pacytology.pcs.models;

import java.io.Serializable;

public class Practice implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4941221795245920902L;

	
	/*
	 * PRACTICE								       NOT NULL NUMBER(6)
 NAME											VARCHAR2(64)
 ADDRESS1										VARCHAR2(64)
 ADDRESS2										VARCHAR2(64)
 CITY											VARCHAR2(32)
 STATE											CHAR(2)
 ZIP											VARCHAR2(9)
 CONTACT										VARCHAR2(64)
 PHONE											CHAR(10)
 FAX											CHAR(10)
 STOP_CODE								       NOT NULL CHAR(1)
 PRICE_CODE								       NOT NULL VARCHAR2(2)
 PATIENT_CARDS										CHAR(1)
 REPORT_COPIES										NUMBER(2)
 CLIENT_NOTES										CHAR(1)
 DATE_ADDED										DATE
 SYS_USER										NUMBER(38)
 PRINT_DOCTORS										CHAR(1)
 DEFAULT_DOCTOR 									NUMBER
 ACTIVE_STATUS										CHAR(1)
 BLOCK_PATIENT										CHAR(1)
 STD_CLINIC										CHAR(1)
 HPV_TESTING										CHAR(1)
 STATEMENT_COPIES									NUMBER(2)
 PRACTICE_TYPE										VARCHAR2(32)
 HPV_PERMISSION 									CHAR(1)
 HOLD_FINAL										CHAR(1)
 VERIFY_DOCTOR										CHAR(1)
 COVER_SHEET										CHAR(1)
 ATTN_MESSAGE										VARCHAR2(64)
 BLOCK_MID_MONTH									CHAR(1)
 HPV_REGARDLESS 									CHAR(1)
 IMAGED 										CHAR(1)
 SEND_FAX										CHAR(1)
 HPV_ON_SUMMARY 									CHAR(1)
 E_REPORTING										CHAR(1)
 PARENT_ACCOUNT 									NUMBER(6)
 PROGRAM										VARCHAR2(16)
	 */
	private int practice;
	private String practiceType ; 
	private String address1 ; 
	private String address2 ; 


	public int getPractice() {
		return practice;
	}


	public void setPractice(int practice) {
		this.practice = practice;
	}


	public String getPractice_type() {
		return practiceType;
	}


	public void setPractice_type(String practiceType) {
		this.practiceType = practiceType;
	}


	public String getAddress1() {
		return address1;
	}


	public void setAddress1(String address1) {
		this.address1 = address1;
	}


	public String getAddress2() {
		return address2;
	}


	public void setAddress2(String address2) {
		this.address2 = address2;
	} 
	
}
