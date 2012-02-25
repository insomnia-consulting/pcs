package com.pacytology.pcs;

class PatientData 
{
    public String lname;
    public String fname;
    public String ssn;
    public String dob;
    public String last_lab;
    public String practice;
    public String address;
    public String city;
    public String state;
    public String zip;

    public PatientData(String lname, String fname, String ssn,
     String dob, String last_lab, String practice, String address, 
     String city, String state, String zip) {
        this.lname=lname;
        this.fname=fname;
        this.ssn=ssn;
        this.dob=dob;
        this.last_lab=last_lab;
        this.practice=practice;
        this.address=address;
        this.city=city;
        this.state=state;
        this.zip=zip;
    }
    
    public PatientData() { }
}    
