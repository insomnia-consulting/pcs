package com.pacytology.pcs.models;

import java.io.Serializable;
import java.util.Date;

import org.joda.time.DateTime;
import org.joda.time.LocalDate;
import org.joda.time.Years;

public class Patient implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4723265865114906222L;

	public int patient;
    public String lname;
    public String fname;
    public String mi;
    public String ssn;
    public String address1;
    public String address2;
    public String city;
    public String state;
    public String zip;
    public String phone;
    public Date dob;
    public String comment_text;
    public int last_lab;
    public int practice;
    public String prac_status;
    public String pNameFmt;
    public String pAddrFmt;
    public boolean newPatientAdd;
    public String race;
    public String sex;
    public int lab_number;
    
    public int getAge() {
    	Years age = Years.yearsBetween(new LocalDate(this.getDob()), new LocalDate());
    	return age.getYears() ;
    	
    }
    public int getPatient() {
		return patient;
	}

	public void setPatient(int patient) {
		this.patient = patient;
	}

	public String getLname() {
		return lname;
	}

	public void setLname(String lname) {
		this.lname = lname;
	}

	public String getFname() {
		return fname;
	}

	public void setFname(String fname) {
		this.fname = fname;
	}

	public String getMi() {
		return mi;
	}

	public void setMi(String mi) {
		this.mi = mi;
	}

	public String getSsn() {
		return ssn;
	}

	public void setSsn(String ssn) {
		this.ssn = ssn;
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

	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getZip() {
		return zip;
	}

	public void setZip(String zip) {
		this.zip = zip;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public Date getDob() {
		return dob;
	}

	public void setDob(Date dob) {
		this.dob = dob;
	}

	public String getComment_text() {
		return comment_text;
	}

	public void setComment_text(String comment_text) {
		this.comment_text = comment_text;
	}

	public int getLast_lab() {
		return last_lab;
	}

	public void setLast_lab(int last_lab) {
		this.last_lab = last_lab;
	}

	public int getPractice() {
		return practice;
	}

	public void setPractice(int practice) {
		this.practice = practice;
	}

	public String getPrac_status() {
		return prac_status;
	}

	public void setPrac_status(String prac_status) {
		this.prac_status = prac_status;
	}

	public String getpNameFmt() {
		return pNameFmt;
	}

	public void setpNameFmt(String pNameFmt) {
		this.pNameFmt = pNameFmt;
	}

	public String getpAddrFmt() {
		return pAddrFmt;
	}

	public void setpAddrFmt(String pAddrFmt) {
		this.pAddrFmt = pAddrFmt;
	}

	public boolean isNewPatientAdd() {
		return newPatientAdd;
	}

	public void setNewPatientAdd(boolean newPatientAdd) {
		this.newPatientAdd = newPatientAdd;
	}

	public String getRace() {
		return race;
	}

	public void setRace(String race) {
		this.race = race;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public int getLab_number() {
		return lab_number;
	}

	public void setLab_number(int lab_number) {
		this.lab_number = lab_number;
	}

	
}
