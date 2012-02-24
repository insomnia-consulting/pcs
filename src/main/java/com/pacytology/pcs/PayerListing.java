/*    PENNSYLVANIA CYTOLOGY SERVICES    LABORATORY INFORMATION SYSTEM V1.0    Copyright (C) 2001 by John Cardella    All Rights Reserved        File:       PayerListing.java    Created By: John Cardella, Software Engineer        Function:   Prints all payers (ins. carriers) in    the database.        MODIFICATIONS ----------------------------------    Date/Staff      Description:*/import java.util.Vector;import java.sql.*;public class PayerListing{    public Login dbLogin;    public Vector payerVect;    Vector tVector;	String title;    public PayerListing() { payerVect = new Vector(); }        public PayerListing(Login dbLogin)    {        this();        this.dbLogin=dbLogin;        this.title="Insurance Payers";        boolean rv=this.query();        if (rv) displayList();    }        	static public void main(String args[])	{		new PayerListing();	}    public boolean query()  {        boolean exitStatus=true;        try  {            String query =                 "SELECT \n"+                "   name, address1, address2, city, \n"+                "   state, substr(zip,1,5), e_billing, id_number, \n"+                "   payer_id, choice_code \n"+                "FROM pcs.carriers p, pcs.billing_choices b  \n"+                "WHERE p.billing_choice=b.billing_choice \n"+                "ORDER BY choice_code, name \n";                            Statement stmt = dbConnection.process().createStatement();            ResultSet rs = stmt.executeQuery(query);            while (rs.next()) {                CarrierRec pRec = new CarrierRec();                pRec.name=rs.getString(1);                pRec.address1=rs.getString(2);                pRec.address2=rs.getString(3);                pRec.city=rs.getString(4);                pRec.state=rs.getString(5);                pRec.zip=rs.getString(6);                pRec.e_billing=rs.getString(7);                pRec.id_number=rs.getInt(8);                pRec.payer_id=rs.getString(9);                pRec.services=rs.getString(10);                payerVect.addElement(pRec);                            }               }        catch( Exception e ) {            System.out.println(e+" lab.query");            exitStatus=false;        }        return(exitStatus);                }    public void displayList() {        String[] s = new String[payerVect.size()*4];        for (int i=0; i<payerVect.size(); i++) {            int ndx = (i*4);            CarrierRec pRec = (CarrierRec)payerVect.elementAt(i);            String t1 = Utils.rpad(Integer.toString(pRec.id_number),10);            String t2 = Utils.rpad(pRec.name,98);            String currLine = t1+"  "+t2;            s[ndx]=currLine;            ndx++;            t1 = Utils.rpad(pRec.payer_id,10);            if (!Utils.isNull(pRec.address1)&&!Utils.isNull(pRec.address2))                t2=Utils.rpad(pRec.address1.trim()+" "+pRec.address2.trim(),98);            else if (!Utils.isNull(pRec.address1))                t2=Utils.rpad(pRec.address1,98);            else                t2=Utils.blankString(98);            currLine=t1+"  "+t2;            s[ndx]=currLine;            ndx++;            t1=Utils.rpad(pRec.services,4)+Utils.lpad(pRec.e_billing,6);            if (!Utils.isNull(pRec.city)) {                String t3 = pRec.city.trim()+", "+pRec.state.trim()+" "+pRec.zip;                t2=Utils.rpad(t3,98);            }            else                t2=Utils.blankString(98);            currLine=t1+"  "+t2;            s[ndx]=currLine;            ndx++;            t1=Utils.rpad("-",110,"-");            s[ndx]=t1;        }        (new PickList(title,0,0,800,550,            payerVect.size()*4,s)).setVisible(true);    }        }
