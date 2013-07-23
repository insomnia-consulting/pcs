package com.pacytology.pcs.models;

import java.util.Date;
import java.util.List;

public class LabResult  {
	/*
	 LAB_NUMBER						 		       NOT NULL NUMBER(11)
	 DATE_COMPLETED 					 	       NOT NULL DATE
	 CYTOTECH							 	       NOT NULL NUMBER(6)
	 PATHOLOGIST									CHAR(3)
	 PAP_CLASS										NUMBER(2)
	 QC_STATUS										CHAR(1)
	 DATESTAMP										DATE
	 SYS_USER										NUMBER(4)
	 FIRST_PRINT									NUMBER(2)
	 PATH_STATUS									CHAR(1)
	 BIOPSY_CODE									VARCHAR2(3)
	 LIMITED										NUMBER(1)
	 CHANGE_DATE									DATE
	 CHANGE_USER									NUMBER(4)
	 */
	
	private int labNumber ;
	private Date dateCompleted ; 
	private int cytotech ; 
	private String pathologist ; 
	private int papClass ; 
	private String qc_status ; 
	private Date dateStamp ; 
	private int sysUser ; 
	private int firstPrint ; 
	private String pathStatus ; 
	private String biopsyCode ; 
	private int limited ; 
	private Date changeDate ; 
	private int changeUser ; 
	private List<String> detailCodes ; 
	
	public int getCytotech() {
		return cytotech;
	}

	public void setCytotech(int cytotech) {
		this.cytotech = cytotech;
	}

	public String getPathologist() {
		return pathologist;
	}

	public void setPathologist(String pathologist) {
		this.pathologist = pathologist;
	}

	public int getPapClass() {
		return papClass;
	}

	public void setPapClass(int papClass) {
		this.papClass = papClass;
	}

	public String getQc_status() {
		return qc_status;
	}

	public void setQc_status(String qc_status) {
		this.qc_status = qc_status;
	}

	public Date getDateStamp() {
		return dateStamp;
	}

	public void setDateStamp(Date dateStamp) {
		this.dateStamp = dateStamp;
	}

	public int getSysUser() {
		return sysUser;
	}

	public void setSysUser(int sysUser) {
		this.sysUser = sysUser;
	}

	public int getFirstPrint() {
		return firstPrint;
	}

	public void setFirstPrint(int firstPrint) {
		this.firstPrint = firstPrint;
	}

	public String getPathStatus() {
		return pathStatus;
	}

	public void setPathStatus(String pathStatus) {
		this.pathStatus = pathStatus;
	}

	public String getBiopsyCode() {
		return biopsyCode;
	}

	public void setBiopsyCode(String biopsyCode) {
		this.biopsyCode = biopsyCode;
	}

	public int getLimited() {
		return limited;
	}

	public void setLimited(int limited) {
		this.limited = limited;
	}

	public Date getChangeDate() {
		return changeDate;
	}

	public void setChangeDate(Date changeDate) {
		this.changeDate = changeDate;
	}

	public int getChangeUser() {
		return changeUser;
	}

	public void setChangeUser(int changeUser) {
		this.changeUser = changeUser;
	}

	

	public int getLabNumber() {
		return labNumber;
	}

	public void setLabNumber(int labNumber) {
		this.labNumber = labNumber;
	}

	public Date getDateCompleted() {
		return dateCompleted;
	}

	public void setDateCompleted(Date dateCompleted) {
		this.dateCompleted = dateCompleted;
	}

	public List<String> getDetailCodes() {
		return detailCodes;
	}

	public void setDetailCodes(List<String> detailCodes) {
		this.detailCodes = detailCodes;
	} 
	
	
	

}
