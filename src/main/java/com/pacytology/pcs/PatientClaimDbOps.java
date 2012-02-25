package com.pacytology.pcs;

import java.lang.*;
import java.sql.*;
import java.util.Vector;
import java.awt.Cursor;

public class PatientClaimDbOps implements Runnable
{
    PatientClaimForm parent;
    private int rowsReturned;
    private int currRow; 
    Thread dbThread;
    StringUtils format = new StringUtils();
    
    public PatientClaimDbOps(PatientClaimForm p) { 
        this.parent=p; 
		//{{INIT_CONTROLS
		//}}
	}

    public synchronized void run() {
        boolean b = query();
        parent.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
        parent.parent.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
        if (b) {
            parent.updatePatientTable();
            parent.PatientTable.addRowSelectionInterval(0,0);
            parent.PatientTable.repaint();
            parent.PatientTable.revalidate();
            if (parent.patQuerySize>0) parent.fillForm(0);
        }
        
        /*
        int practice=0;
        try {
            practice = (int)Integer.parseInt(parent.paPractice.getText());
        }
        catch (Exception e) { }
        boolean rv = queryPractice(practice);
        if (rv==false) {
		    parent.createErrMsg("Practice #"+practice+" does not exist");
            parent.paPractice.requestFocus();
            parent.paPractice.setText(null);
        }
        parent.msgLabel.setText(null);
        */
    }

    public void queryPatients()
    {
        dbThread = new Thread(this);
        dbThread.setPriority(Thread.MAX_PRIORITY);
        dbThread.start();
    }

    public boolean query() {
        boolean exitStatus=true;
        int rowsReturned = 0;
        try  {
            parent.billingVect = new Vector();
            String query = 
                "SELECT \n"+
                "   a.patient,a.lname,a.fname,a.mi,a.ssn, \n"+
                "   a.address1,a.address2,a.city,a.state, \n"+
                "   a.zip,a.phone,TO_CHAR(a.dob,'MMDDYYYY'), \n"+
                "   null, \n"+
                "   a.last_lab,d.practice, \n"+
                "   bc.choice_code, \n"+
                "   c.name, \n"+
                "   bd.id_number, \n"+
                "   bd.group_number, \n"+
                "   lc.claim_status, \n"+
                "   TO_CHAR(NVL(lc.amount_paid,0),'990.99'), \n"+
                "   TO_CHAR(lc.allowance,'990.99'), \n"+
                "   TO_CHAR(lb.balance,'990.99'), \n"+
                "   lc.alt_id, \n"+
                "   TO_CHAR(lc.datestamp, 'MM/DD/YYYY'), \n"+
                "   lc.claim_comment \n"+
                "FROM \n"+
                "   pcs.patients a, \n"+
                "   pcs.lab_requisitions d, \n"+
                "   pcs.billing_choices bc, \n"+
                "   pcs.carriers c, \n"+
                "   pcs.billing_details bd, \n"+
                "   pcs.lab_claims lc, \n"+
                "   pcs.lab_billings lb \n"+
                "WHERE \n"+
                "   a.patient=d.patient and \n"+
                "   a.last_lab=d.lab_number and \n"+
                "   d.lab_number=lb.lab_number and \n"+
                "   lb.lab_number=bd.lab_number and \n"+
                "   bd.claim_id=lc.claim_id(+) and \n"+
                "   bd.rebilling=lb.rebilling and \n"+
                "   bd.carrier_id=c.carrier_id(+) and \n"+
                "   lb.billing_choice=bc.billing_choice ";
                
            if (format.length(parent.queryRec.lname)>0)
                query=query.concat(" and \n   a.lname like '"+ 
                parent.queryRec.lname + "%' ");
            if (format.length(parent.queryRec.fname)>0)
                query=query.concat(" and \n   a.fname like '"+ 
                parent.queryRec.fname + "%' ");
            if (format.length(parent.queryRec.ssn)>0)
                query=query.concat(" and \n   a.ssn = '"+ 
                parent.queryRec.ssn + "' ");
            if (format.length(parent.queryRec.dob)>0)
                query=query.concat(" and \n   a.dob = TO_DATE('"+ 
                parent.queryRec.dob + "','MMDDYYYY')");
            query=query+"\nORDER by a.lname,a.fname,a.address1 \n";
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            rowsReturned=0;
            int currCol=0;
            int currRow=0;
            while (rs.next()) {
                rowsReturned++;
                if (rowsReturned==parent.paMaxRecs) break;
                BillingDetails bd = new BillingDetails();
                currCol=0;
                parent.paRec[currRow].patient=rs.getInt(1);
                parent.paRec[currRow].lname=rs.getString(2);
                parent.paRec[currRow].fname=rs.getString(3);
                parent.paRec[currRow].pNameFmt =
                    rs.getString(2)+", "+rs.getString(3);
                parent.paRec[currRow].mi=rs.getString(4);
                parent.paRec[currRow].ssn=rs.getString(5);
                parent.paRec[currRow].address1=rs.getString(6);
                if (rs.wasNull()==true) parent.paRec[currRow].pAddrFmt=" ";
                else parent.paRec[currRow].pAddrFmt=rs.getString(6);
                parent.paRec[currRow].city=rs.getString(8);
                if (rs.wasNull()==false)
                    parent.paRec[currRow].pAddrFmt =
                        parent.paRec[currRow].pAddrFmt+", "+rs.getString(8);
                parent.paRec[currRow].state=rs.getString(9);
                if (rs.wasNull()==false)
                    parent.paRec[currRow].pAddrFmt =
                        parent.paRec[currRow].pAddrFmt+", "+rs.getString(9);
                parent.paRec[currRow].zip=rs.getString(10);
                if (rs.wasNull()==false)
                    parent.paRec[currRow].pAddrFmt =
                        parent.paRec[currRow].pAddrFmt+"  "+parent.format.addZipMask(rs.getString(10));
                parent.paRec[currRow].phone=rs.getString(11);
                parent.paRec[currRow].dob=rs.getString(12);
                parent.paRec[currRow].comment_text=rs.getString(13);
                parent.paRec[currRow].last_lab=rs.getInt(14);
                parent.paRec[currRow].practice=rs.getInt(15);
                bd.choice_code=rs.getString(16);
                bd.payer.name=rs.getString(17);
                bd.id_number=rs.getString(18);
                bd.group_number=rs.getString(19);
                bd.claim_status=rs.getString(20);
                bd.amount_paid=rs.getString(21);
                bd.allowance=rs.getString(22);
                //this field just used to hold the balance of the lab charges
                bd.subscriber=rs.getString(23);
                bd.alt_id=rs.getString(24);
                bd.LC_datestamp=rs.getString(25);
                bd.claim_comment=rs.getString(26);
                parent.billingVect.addElement(bd);
                currRow++;
            }       
            parent.patQuerySize=rowsReturned;
            if (rowsReturned>0) {
                parent.msgLabel.setText("Operation Succeeded");
            }
            else {
                exitStatus=false;
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) {
                exitStatus=false;
                Utils.createErrMsg("FATAL ERROR");
            }          
        }
        catch( Exception e ) {
            parent.log.write(e);
            exitStatus=false;
            Utils.createErrMsg("FATAL ERROR");
        }
        if (rowsReturned<1) {
            Utils.createErrMsg("Patient not found");
	        parent.noDataFound();
	    }
        return(exitStatus);            
    }

    public boolean add() {
        boolean exitStatus=true;            
        return(exitStatus);            
    }

    public boolean update(int index) {
        boolean exitStatus=true;            
        return(exitStatus);            
    }

    public boolean queryPatientLabs(int pat, Vector resultList) 
    {
        boolean exitStatus=true;
        int lab = 0;
        int previousLab = 0;
        try  {
            String SQL = 
                "SELECT MAX(lab_number) \n"+
                "FROM pcs.lab_requisitions "+
                "WHERE patient="+pat+" \n";
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { previousLab=rs.getInt(1); }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { 
                parent.log.write(e.toString());
                exitStatus=false; 
            }                
            catch (Exception e) {
                parent.log.write(e.toString());
                exitStatus=false; 
            }
            while (previousLab!=0 && previousLab!=lab) {
                SQL = 
                    "SELECT lab_number,practice, \n"+
                    "   TO_CHAR(date_collected,'MM/DD/YYYY'), \n"+
                    "   TO_CHAR(datestamp,'MM/DD/YYYY'), \n"+
                    "   finished,previous_lab \n"+
                    "FROM pcs.lab_requisitions "+
                    "WHERE lab_number="+previousLab+" \n";
                stmt=dbConnection.process().createStatement();
                rs=stmt.executeQuery(SQL);
                while (rs.next()) {
                    lab = rs.getInt(1);
                    int practice = rs.getInt(2);
                    String dc = rs.getString(3);
                    String ds = rs.getString(4); 
                    int f = rs.getInt(5);
                    previousLab=rs.getInt(6);
                    String state=" ";
                    if (f==1) state="SCREENING";
                    else if (f==2) state="RESULTS";
                    else if (f==3) state="BILLED";
                    else if (f>3) state="PAID";
                    String p_txt = Integer.toString(practice);
                    if (practice<100) p_txt="0"+p_txt;
                    resultList.addElement(lab+"  "+p_txt+"  "+dc+"  "+ds+"  "+state);
                }
                try { rs.close(); stmt.close(); }
                catch (SQLException e) { 
                    parent.log.write(e.toString());
                    exitStatus=false; 
                }                
                catch (Exception e) {
                    parent.log.write(e);
                    exitStatus=false;
                }
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { 
                parent.log.write(e.toString());
                exitStatus=false; 
            }                
        }
        catch (Exception e) {
            parent.log.write(e);
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

    public boolean queryZip(String zip5) {
        boolean exitStatus=true;
        return(exitStatus);            
    }

    int length(String s) {
        int len;
        try { len=s.length(); }
        catch (Exception e) { len=0; }
        return len;
    }
    
	//{{DECLARE_CONTROLS
	//}}
}
