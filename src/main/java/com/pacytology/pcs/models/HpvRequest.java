package com.pacytology.pcs.models;

import java.util.Date;

public class HpvRequest {
	/*
	 * LAB_NUMBER								       NOT NULL NUMBER(11)
 	 * DATESTAMP										DATE
 	 * TEST_SENT										CHAR(1)
 	* TEST_RESULTS										CHAR(1)
 	* RESULTS_RECEIVED									DATE
 	* COMMENT_TEXT										VARCHAR2(512)
 	* HPV_CODE										VARCHAR2(2)
 	* HPV_LAB										VARCHAR2(48)
 	* NEEDS_PERMISSION									CHAR(1)
 	* DEQUEUED										DATE
 	* CYTOTECH										NUMBER(6)
	 */
	
	private int lab_number ; 
	private Date datestamp ; 
	private String test_sent ; 
	private String test_results ; 
	private Date results_received ; 
	private String comment_text ; 
	private String hpv_code ; 
	private String hpv_lab ; 
	private String needs_permission ; 
	/**
	 * Reports whether the test_sent field is 'R' which means a test is required.  
	 * 
	 * Once the test is Pending, or already processed, 
	 * it will not have an R anymore.. meaning this 
	 * field will return false for historic tests.
	 * 
	 * @return boolean 
	 */
	public boolean isHpv() {
		return "R".equals(this.getTest_sent()) ; 
	}
	public int getLab_number() {
		return lab_number;
	}
	public void setLab_number(int lab_number) {
		this.lab_number = lab_number;
	}
	public Date getDatestamp() {
		return datestamp;
	}
	public void setDatestamp(Date datestamp) {
		this.datestamp = datestamp;
	}
	public String getTest_sent() {
		return test_sent;
	}
	public void setTest_sent(String test_sent) {
		this.test_sent = test_sent;
	}
	public String getTest_results() {
		return test_results;
	}
	public void setTest_results(String test_results) {
		this.test_results = test_results;
	}
	public Date getResults_received() {
		return results_received;
	}
	public void setResults_received(Date results_received) {
		this.results_received = results_received;
	}
	public String getComment_text() {
		return comment_text;
	}
	public void setComment_text(String comment_text) {
		this.comment_text = comment_text;
	}
	public String getHpv_code() {
		return hpv_code;
	}
	public void setHpv_code(String hpv_code) {
		this.hpv_code = hpv_code;
	}
	public String getHpv_lab() {
		return hpv_lab;
	}
	public void setHpv_lab(String hpv_lab) {
		this.hpv_lab = hpv_lab;
	}
	public String getNeeds_permission() {
		return needs_permission;
	}
	public void setNeeds_permission(String needs_permission) {
		this.needs_permission = needs_permission;
	}
	
	

}
