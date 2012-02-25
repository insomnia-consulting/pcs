package com.pacytology.pcs;

/*
    PathRec.java
    Software Engineer: Jon Cardella
    
    Function: Holds data from pathologists table.
*/
public class PathRec
{
    int pathologist;
    String lname;
    String fname;
    String mi;
    String address1;
    String city;
    String state;
    String zip;
    String phone;
    String pathologist_code;
    String title;
    String degree;
    
    public PathRec()  { this.reset(); }
    
    public void reset()  {
        pathologist=0;
        lname=null;
        fname=null;
        address1=null;
        city=null;
        state=null;
        zip=null;
        phone=null;
        pathologist_code=null;
    }        
	//{{DECLARE_CONTROLS
	//}}
}
