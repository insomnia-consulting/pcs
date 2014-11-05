package com.pacytology.pcs.models;

import java.util.Date;

public class ExportError {
	private int lab_number ; 
	private Date datestamp ; 
	private String error ;
	
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
	public String getError() {
		return error;
	}
	public void setError(String error) {
		this.error = error;
	} 
	

}
