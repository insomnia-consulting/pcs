package com.pacytology.pcs;

/*
    PathRec.java
    Software Engineer: Jon Cardella
    
    Function: Holds data from pathologists table.
*/
public class PathRec
{
	public int pathologist;
	public String lname;
	public String fname;
	public String mi;
	public String address1;
	public String city;
	public String state;
	public String zip;
	public String phone;
	public String pathologist_code;
	public String title;
	public String degree;
    
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
