package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       PracticeDbOps.java
    Created By: John Cardella, Software Engineer
    
    Function:   Database operations for practices form.

    MODIFICATIONS ----------------------------------
    Date:         Description:
    09/17         Changed db access in all methods to use dbConnection class
                  connection rather than having a separate java.sql.Connection
                  for each class needing one. (12/9/09, would have been nice
                  if I had put the year on this comment!)
    12/09/09      Changes to accomodate new field e_reporting on practices table;
                  pStatements was used for obsolete field statement_copies so has
                  been "recycled" to be used with e_reporting.
*/

import java.lang.*;
import java.sql.*;
import java.util.Vector;

public class PracticeDbOps implements Runnable
{
    Thread dbThread;
    PracticesForm parent;
    final int INIT=(-1);
    final int ZIP=96;
    public int tMode;
    
    public PracticeDbOps(PracticesForm p) { 
        parent = p; 
    }
    
    public synchronized void run() {
        if (tMode==ZIP) {
            String zip5 = parent.pZip.getText().substring(0,5);
            queryZip(zip5);
        }
        else if (tMode==INIT) {
            parent.setCursor(new java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
            getPriceCodes();
            parent.setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
        }
    }
    
    public void practiceFormInit() {
        parent.msgLabel.setText("INITIALIZING ...");
        tMode=INIT;
        dbThread = new Thread(this);
        dbThread.setPriority(Thread.MAX_PRIORITY);
        dbThread.start();
    }
    
    public void getZipInfo() {
        tMode=ZIP;
        dbThread = new Thread(this);
        dbThread.setPriority(Thread.MIN_PRIORITY);
        dbThread.start();
    }
    
    public void getPriceCodes()  {
        try  {
            String SQL = 
                "SELECT price_code FROM pcs.price_codes \n"+
                "WHERE active_status='A' ORDER BY price_code \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { parent.pPriceCodes.addElement(rs.getString(1)); }            
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); }                
        
        }
        catch(SQLException e) { parent.log.write(e); }
        catch( Exception e ) { parent.log.write(e); }
    }
    
    public boolean queryZip(String zip5) {
        boolean exitStatus=true;
        try  {
            String SQL = 
                "SELECT city,state FROM pcs.zipcodes WHERE zip='"+zip5+"' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            int rcnt=0;
            while (rs.next()) {
                parent.pCity.setText(rs.getString(1));
                parent.pState.setText(rs.getString(2));
                rcnt++;
            }       
            if (rcnt==0) { 
                Utils.createErrMsg("City/State not found for "+zip5);
                parent.pCity.requestFocus();
                exitStatus=false; 
            }
            else {  
                parent.practiceRec.zip=Utils.stripZipMask(parent.pZip.getText());
                parent.practiceRec.city=parent.pCity.getText();
                parent.practiceRec.state=parent.pState.getText();
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }                
        }
        catch(SQLException e) { exitStatus=false; parent.log.write(e); }
        catch(Exception e) { exitStatus=false; parent.log.write(e); }
        return(exitStatus);            
    }
    
    public boolean add() 
    {
        boolean exitStatus = true;
        CallableStatement cstmt;
        try { 
            cstmt=DbConnection.process().prepareCall(
		        "{call pcs.practices_add(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)}");
            cstmt.setInt(1,parent.practiceRec.practice);
            cstmt.setString(2,parent.practiceRec.name);
            cstmt.setString(3,parent.practiceRec.address1);
            cstmt.setString(4,parent.practiceRec.address2);
            cstmt.setString(5,parent.practiceRec.city);
            cstmt.setString(6,parent.practiceRec.state);
            cstmt.setString(7,parent.practiceRec.zip);
            cstmt.setString(8,parent.practiceRec.contact);
            cstmt.setString(9,parent.practiceRec.phone);
            cstmt.setString(10,parent.practiceRec.fax);
            cstmt.setString(11,parent.practiceRec.stop_code);
            cstmt.setString(12,parent.practiceRec.price_code);
            cstmt.setString(13,parent.practiceRec.patient_cards);
            cstmt.setInt(14,parent.practiceRec.report_copies);
            cstmt.setString(15,parent.practiceRec.client_notes);
            cstmt.setString(16,parent.practiceRec.comment_text);
            cstmt.setString(17,parent.practiceRec.print_doctors);
            cstmt.setString(18,parent.practiceRec.block_patient);
            cstmt.setString(19,parent.practiceRec.std_clinic);
            cstmt.setString(20,parent.practiceRec.hpv_testing);
            cstmt.setInt(21,parent.practiceRec.statement_copies);
            cstmt.setString(22,parent.practiceRec.practice_type);
            cstmt.setString(23,parent.practiceRec.hpv_permission);
            cstmt.setString(24,parent.practiceRec.attn_message);
            cstmt.setString(25,parent.practiceRec.hold_final);
            cstmt.setString(26,parent.practiceRec.verify_doctor);
            cstmt.setString(27,parent.practiceRec.cover_sheet);
            cstmt.setString(28,parent.practiceRec.block_mid_month);
            cstmt.setString(29,parent.practiceRec.hpv_regardless);
            cstmt.setString(30,parent.practiceRec.imaged);
            cstmt.setString(31,parent.practiceRec.send_fax);
            cstmt.setString(32,parent.practiceRec.hpv_on_summary);
            cstmt.setString(33,parent.practiceRec.e_reporting);
            cstmt.setInt(34,parent.practiceRec.parent_account);
            cstmt.setString(35,parent.practiceRec.program);
            cstmt.executeUpdate();
            try { cstmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }
            catch (Exception e) { parent.log.write(e); exitStatus=false; }
        }
        catch (SQLException e) { parent.log.write(e); exitStatus=false; }
        catch (Exception e) { parent.log.write(e); exitStatus=false; }
        return exitStatus;
    }
     
     
    public boolean query()
    {
        boolean exitStatus=true;
        int rowsReturned=0;
        try { 
            String SQL=
                "SELECT \n"+ 
                "   a.practice, \n"+                        // 1
                "   a.name, \n"+                            // 2
                "   a.address1, \n"+                        // 3
                "   a.address2, \n"+                        // 4
                "   a.city, \n"+                            // 5
                "   a.state, \n"+                           // 6
                "   a.zip, \n"+                             // 7
                "   a.contact, \n"+                         // 8
                "   a.phone, \n"+                           // 9
                "   a.fax, \n"+                             // 10
                "   a.stop_code, \n"+                       // 11
                "   a.price_code, \n"+                      // 12
                "   NVL(a.patient_cards,'N'), \n"+          // 13
                "   a.report_copies, \n"+                   // 14
                "   NVL(a.client_notes,'N'), \n"+           // 15
                "   b.comment_text, \n"+                    // 16
                "   a.print_doctors, \n"+                   // 17
                "   a.default_doctor, \n"+                  // 18
                "   a.active_status, \n"+                   // 19
                "   a.block_patient, \n"+                   // 20
                "   a.std_clinic, \n"+                      // 21
                "   a.hpv_testing, \n"+                     // 22
                "   a.statement_copies, \n"+                // 23
                "   TO_CHAR(a.date_added,'MM/DD/YYYY'),\n"+ // 24
                "   a.practice_type, \n"+                   // 25
                "   a.hpv_permission, \n"+                  // 26
                "   a.attn_message, \n"+                    // 27
                "   a.hold_final, \n"+                      // 28
                "   a.verify_doctor, \n"+                   // 29
                "   a.cover_sheet, \n"+                     // 30
                "   a.block_mid_month, \n"+                 // 31
                "   a.hpv_regardless, \n"+                  // 32
                "   a.imaged, \n"+                          // 33
                "   a.send_fax, \n"+                        // 34
                "   a.hpv_on_summary, \n"+                  // 35
                "   a.e_reporting, \n"+                     // 36
                "   a.parent_account, \n"+                  // 37
                "   a.program \n"+                          // 38
                "from pcs.practices a, pcs.practice_comments b "+
                "where a.practice=b.practice(+)";                                               
            if (!Utils.isNull(parent.pName.getText())) 
                    SQL=SQL.concat(" and a.name like '"+parent.pName.getText()+"' ");
            if (!Utils.isNull(parent.pAcctNum.getText())) 
                SQL=SQL.concat(" and a.practice = "+
                    Integer.parseInt(parent.pAcctNum.getText()));
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next())  {
                rowsReturned++;
                parent.practiceRec.practice = rs.getInt(1);
                parent.practiceRec.name = rs.getString(2);
                parent.practiceRec.address1 = rs.getString(3);
                parent.practiceRec.address2 = rs.getString(4);
                parent.practiceRec.city = rs.getString(5);
                parent.practiceRec.state = rs.getString(6);
                parent.practiceRec.zip = rs.getString(7);
                parent.practiceRec.contact = rs.getString(8);
                parent.practiceRec.phone = rs.getString(9);
                parent.practiceRec.fax = rs.getString(10);
                parent.practiceRec.stop_code = rs.getString(11);
                parent.practiceRec.price_code = rs.getString(12);
                parent.practiceRec.patient_cards = rs.getString(13);
                parent.practiceRec.report_copies = rs.getInt(14);
                parent.practiceRec.client_notes = rs.getString(15);
                parent.practiceRec.comment_text = rs.getString(16);
                parent.practiceRec.print_doctors=rs.getString(17);
                parent.practiceRec.default_doctor=rs.getInt(18);
                parent.practiceRec.active_status=rs.getString(19);
                parent.practiceRec.block_patient=rs.getString(20);
                parent.practiceRec.std_clinic=rs.getString(21);
                parent.practiceRec.hpv_testing=rs.getString(22);
                parent.practiceRec.statement_copies=rs.getInt(23);
                parent.practiceRec.date_added=rs.getString(24);
                parent.practiceRec.practice_type=rs.getString(25);
                parent.practiceRec.hpv_permission=rs.getString(26);
                parent.practiceRec.attn_message=rs.getString(27);
                parent.practiceRec.hold_final=rs.getString(28);
                parent.practiceRec.verify_doctor=rs.getString(29);
                parent.practiceRec.cover_sheet=rs.getString(30);
                parent.practiceRec.block_mid_month=rs.getString(31);
                parent.practiceRec.hpv_regardless=rs.getString(32);
                parent.practiceRec.imaged=rs.getString(33);
                parent.practiceRec.send_fax=rs.getString(34);
                parent.practiceRec.hpv_on_summary=rs.getString(35);
                parent.practiceRec.e_reporting=rs.getString(36);
                parent.practiceRec.parent_account=rs.getInt(37);
                parent.practiceRec.program=rs.getString(38);
                getDoctors(parent.practiceRec.practice);
                if (parent.practiceRec.parent_account>0
                &&parent.practiceRec.practice==parent.practiceRec.parent_account)
                    getLinks(parent.practiceRec.parent_account);
            }       
            if (rowsReturned<1) exitStatus=false;
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { 
            	parent.log.write(e); 
            	exitStatus=false; 
            	}
        }
        catch (SQLException e) { parent.log.write(e); exitStatus=false; }
        catch (Exception e) { 
        	e.printStackTrace();
        	parent.log.write(e); 
        	exitStatus=false; 
        }
        return exitStatus;
    }

    public boolean getLinks(int parent_account)
    {
        boolean exitStatus=true;
        int rowsReturned=0;
        try { 
            String SQL=
                "SELECT TO_CHAR(practice,'009') \n"+  
                "FROM pcs.practices \n"+
                "WHERE practice<>parent_account \n"+
                "AND parent_account = ? \n";                                               
            PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,parent_account);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next())  {
                rowsReturned++;
                String s = rs.getString(1);
                parent.practiceRec.parent_links.addElement(s);
            }       
            if (rowsReturned<1) exitStatus=false;
            try { rs.close(); pstmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }
        }
        catch (SQLException e) { parent.log.write("getLinks: "+e); exitStatus=false; }
        catch (Exception e) { parent.log.write("getLinks: "+e); exitStatus=false; }
        return exitStatus;
    }
                
    public boolean update() 
    {
        boolean exitStatus = true;
        CallableStatement cstmt;
        try { 
            cstmt=DbConnection.process().prepareCall(
		        "{call pcs.practices_update(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)}");
            cstmt.setInt(1,parent.practiceRec.practice);
            cstmt.setString(2,parent.practiceRec.name);
            cstmt.setString(3,parent.practiceRec.address1);
            cstmt.setString(4,parent.practiceRec.address2);
            cstmt.setString(5,parent.practiceRec.city);
            cstmt.setString(6,parent.practiceRec.state);
            cstmt.setString(7,parent.practiceRec.zip);
            cstmt.setString(8,parent.practiceRec.contact);
            cstmt.setString(9,parent.practiceRec.phone);
            cstmt.setString(10,parent.practiceRec.fax);
            cstmt.setString(11,parent.practiceRec.stop_code);
            cstmt.setString(12,parent.practiceRec.price_code);
            cstmt.setString(13,parent.practiceRec.patient_cards);
            cstmt.setInt(14,parent.practiceRec.report_copies);
            cstmt.setString(15,parent.practiceRec.client_notes);
            cstmt.setString(16,parent.practiceRec.comment_text);
            cstmt.setString(17,parent.practiceRec.print_doctors);
            cstmt.setInt(18,parent.practiceRec.default_doctor);
            cstmt.setString(19,parent.practiceRec.active_status);
            cstmt.setString(20,parent.practiceRec.block_patient);
            cstmt.setString(21,parent.practiceRec.std_clinic);
            cstmt.setString(22,parent.practiceRec.hpv_testing);
            cstmt.setInt(23,parent.practiceRec.statement_copies);
            cstmt.setString(24,parent.practiceRec.practice_type);
            cstmt.setString(25,parent.practiceRec.hpv_permission);
            cstmt.setString(26,parent.practiceRec.attn_message);
            cstmt.setString(27,parent.practiceRec.hold_final);
            cstmt.setString(28,parent.practiceRec.verify_doctor);
            cstmt.setString(29,parent.practiceRec.cover_sheet);
            cstmt.setString(30,parent.practiceRec.block_mid_month);
            cstmt.setString(31,parent.practiceRec.hpv_regardless);
            cstmt.setString(32,parent.practiceRec.imaged);
            cstmt.setString(33,parent.practiceRec.send_fax);
            cstmt.setString(34,parent.practiceRec.hpv_on_summary);
            cstmt.setString(35,parent.practiceRec.e_reporting);
            cstmt.setInt(36,parent.practiceRec.parent_account);
            cstmt.setString(37,parent.practiceRec.program);
            cstmt.executeUpdate();
            try { cstmt.close(); }
            catch (SQLException e) { parent.log.write(e); exitStatus=false; }
            catch (Exception e) { parent.log.write(e); exitStatus=false; }
        }                      
        catch( SQLException e ) { parent.log.write(e); exitStatus=false; }
        catch (Exception e) { parent.log.write(e); exitStatus=false; }
        return exitStatus;
    }
    
    public void mailerAdd()
    {
        PreparedStatement pstmt = null;
        try {
            String name = parent.pName.getText();
            String address1 = parent.pAddress1.getText();
            String address2 = parent.pAddress2.getText();
            String city = parent.pCity.getText();
            String state = parent.pState.getText();
            String zip = parent.pZip.getText();
            String SQL = 
                "insert into pcs.mailer values (?,?,?,?,?,?,'N') \n";
            pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setString(1,name);
            pstmt.setString(2,address1);
            pstmt.setString(3,address2);
            pstmt.setString(4,city);
            pstmt.setString(5,state);
            pstmt.setString(6,zip);
            pstmt.executeUpdate();
            pstmt.close();
        }
        catch (Exception e) {  }
    }
    
    public Vector mailerData()
    {
        Vector v = new Vector();
        try {
            String SQL = "select * from pcs.mailer order by name \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) {
                String name = rs.getString(1);
                String address1 = rs.getString(2);
                String address2 = rs.getString(3);
                String city = rs.getString(4);
                String state = rs.getString(5);
                String zip = rs.getString(6);
                if (!Utils.isNull(name)) {
                    v.addElement(name);
                    if (!Utils.isNull(address1)) v.addElement(address1);
                    if (!Utils.isNull(address2)) v.addElement(address2);
                    String csz = city+", "+state+"  "+zip;
                    v.addElement(csz);
                    v.addElement("   ");
                }
            }
            rs.close();
            stmt.close();
        }
        catch (Exception e) { }
        return (v);
    }
    
    
 	public void getDoctors(int practice_id)  {
        PreparedStatement pstmt;
        int rowsReturned=0;
        try  {
            String SQL =
                    "SELECT \n"+
                    "   doctor,lname,fname,mi,upin,license,primary, \n"+
                    "   active_status,title,alt_license,alt_state,bs_provider,npi \n"+
                    "FROM pcs.doctors WHERE practice = ? ORDER by lname,fname";
            pstmt = DbConnection.process().prepareStatement(SQL);
            pstmt.setInt(1,practice_id);
            ResultSet rs = pstmt.executeQuery();
            parent.doctorVect = new Vector();
            while (rs.next())  {
                DoctorRec d = new DoctorRec();
                d.doctor=rs.getInt(1);
                d.lname=rs.getString(2);
                d.fname=rs.getString(3);
                d.mi=rs.getString(4);
                d.upin=rs.getString(5);
                d.license=rs.getString(6);
                d.primary=rs.getInt(7);
                d.active_status=rs.getString(8);
                d.title=rs.getString(9);
                d.alt_license=rs.getString(10);
                d.alt_state=rs.getString(11);
                d.bs_provider=rs.getString(12);
                d.NPI=rs.getString(13);
                d.state=parent.practiceRec.state;
                parent.doctorVect.addElement(d);
                rowsReturned++;
            }       
            if (rowsReturned>0) {
                parent.DoctorTable.clearSelection();
                parent.DoctorTable.getSelectionModel().setSelectionInterval(0, 0);
                parent.DoctorTable.revalidate();
                parent.DoctorTable.repaint();
                parent.log.write("Doctors returned ["+rowsReturned+"]");
            }
            else { 
            	parent.log.write("No doctors returned for "+practice_id); 
            }
            try {  
            		rs.close(); 
            		pstmt.close(); 
            }
            catch (SQLException e) { parent.log.write(e); }
        }
        catch (SQLException e) { 
        	e.printStackTrace();
        	parent.log.write(e); }
    }        	    
    
    public void close() { }
    
}
