package com.pacytology.pcs;import java.lang.*;import java.sql.*;import java.io.*;public class TechDbOps{    TechForm parent;        public TechDbOps(TechForm p) {         parent = p;		//{{INIT_CONTROLS		//}}	}    public boolean queryAllTechs()  {        boolean exitStatus=true;        try  {            String query =                 "SELECT cytotech,lname,fname,mi,rtrim(cytotech_code),active_status \n"+                "FROM pcs.cytotechs ORDER BY lname,fname \n";                            System.out.println(query);                            Statement stmt = DbConnection.process().createStatement();            ResultSet rs = stmt.executeQuery(query);            int rowsReturned=0;            while (rs.next()) { rowsReturned++; }            if (rowsReturned>0) {                parent.MAX_TECHS=rowsReturned;                parent.cTechRec=new TechRec[parent.MAX_TECHS];                int ndx=0;                rs = stmt.executeQuery(query);                while (rs.next()) {                    parent.cTechRec[ndx]=new TechRec();                    parent.cTechRec[ndx].cytotech=rs.getInt(1);                    parent.cTechRec[ndx].lname=rs.getString(2);                    parent.cTechRec[ndx].fname=rs.getString(3);                    parent.cTechRec[ndx].mi=rs.getString(4);                    parent.cTechRec[ndx].cytotech_code=rs.getString(5);                    parent.cTechRec[ndx].active_status=rs.getString(6);                    ndx++;                                    }                   }            else { exitStatus=false; }            try { rs.close(); stmt.close(); }            catch (SQLException e) { exitStatus=false; }                        }        catch( Exception e ) {            System.out.println(e+" queryAllTechs");            exitStatus=false;            parent.msgLabel.setText("Operation Failed");        }        return(exitStatus);                }    public boolean add()  {        boolean exitStatus=true;        try  {            String query =                 "INSERT INTO pcs.cytotechs \n"+                "   (cytotech,lname,fname,mi,cytotech_code,active_status) \n"+                "VALUES \n"+                "   (pcs.tech_seq.nextval,?,?,?,?,?) \n";                            PreparedStatement pstmt = DbConnection.process().prepareStatement(query);            pstmt.setString(1,parent.ctLName.getText());            pstmt.setString(2,parent.ctFName.getText());            pstmt.setString(3,parent.ctMI.getText());            pstmt.setString(4,parent.ctCode.getText());            pstmt.setString(5,parent.ctStatus.getText());            System.out.println(query);                            int rs = pstmt.executeUpdate();            try { pstmt.close(); }            catch (SQLException e) { exitStatus=false; }                            if (rs>0) {                queryAllTechs();                for (int i=0;i<parent.MAX_TECHS;i++) {                    if (parent.cTechRec[i].cytotech>parent.currNdx) {                        parent.currNdx=i;                        break;                    }                }            }            else { exitStatus=false; }        }        catch( Exception e ) {            System.out.println(e+" addTechs");            exitStatus=false;            parent.msgLabel.setText("Operation Failed");        }        return(exitStatus);                }    public boolean update(int ct)  {        boolean exitStatus=true;        try  {            String query =                 "UPDATE pcs.cytotechs SET \n"+                "   lname = ?, \n"+                "   fname = ?, \n"+                "   mi = ?, \n"+                "   active_status = ? \n"+                "WHERE cytotech="+ct+" \n";                            System.out.println(query);                            PreparedStatement pstmt = DbConnection.process().prepareStatement(query);            pstmt.setString(1,parent.ctLName.getText());            pstmt.setString(2,parent.ctFName.getText());            pstmt.setString(3,parent.ctMI.getText());            pstmt.setString(4,parent.ctStatus.getText());            System.out.println(query);                            int rs = pstmt.executeUpdate();            if (rs<1) { exitStatus=false; }            try { pstmt.close(); }            catch (SQLException e) { exitStatus=false; }                        }        catch( Exception e ) {            System.out.println(e+" addTechs");            exitStatus=false;            parent.msgLabel.setText("Operation Failed");        }        return(exitStatus);                }        void printTechList()    {        File f = null;        FileWriter fw = null;        String fileName = parent.tLogin.userName+"_tmp"+".cyt";	    try {            f = new File(Utils.ROOT_DIR,fileName);            fw = new FileWriter(f);        }        catch (IOException e) {  }        try  {            String fName=null;            String query =                 "SELECT RPAD(NVL(lname,' '),32), \n"+                "   RPAD('  '||fname||' '||mi,14), \n"+                "   RPAD('      '||cytotech_code,12),active_status \n"+                "FROM pcs.cytotechs ORDER BY lname,fname \n";            Statement stmt = DbConnection.process().createStatement();            ResultSet rs = stmt.executeQuery(query);            int page = 0;            int line = 62;            String margin = "          ";            while (rs.next()) {                 if (++line==63) {                     if (page>0) fw.write("\n\n\n\n");                    line=1;                     page++;                     fw.write("\n\n"+margin+                        "------------------------------------------------------------\n");                    fw.write(margin+"CYTOTECHNOLOGIST LISTING\n");                    fw.write(margin+"Page: "+page+"\n\n");                    fw.write(margin+"LAST NAME:                        FIRST MI          CODE\n");                    fw.write(margin+"------------------------------------------------------------\n");                    line=9;                }                TechRec t = new TechRec();                t.lname=rs.getString(1);                t.fname=rs.getString(2);                t.cytotech_code=rs.getString(3);                t.active_status=rs.getString(4);                String currLine="          "+t.lname+t.fname+                    t.cytotech_code+t.active_status+"\n";                fw.write(currLine);            }            try { rs.close(); stmt.close(); }            catch (SQLException e) {  }                            try { fw.close(); }            catch (IOException e) {  }            genericPrint(fileName,false);            try { f.delete(); }            catch (SecurityException e) { System.out.println(e); }        }        catch( Exception e ) {  }    }    	void genericPrint(String fileName, boolean forcePage)	{        File f;        File f2;        FileInputStream fIN;        FileOutputStream fOUT;        f = new File(Utils.ROOT_DIR,fileName);        f2 = new File("c:\\","lpt1");        if (f.exists()) {            long fLen = f.length();            if (fLen>0) {                 try {                    fIN = new FileInputStream(f);                    fOUT = new FileOutputStream(f2);                    for (;;) {                        int x = fIN.read();                        if (x==-1) break;                        char c = (char)x;                        fOUT.write(x);                    }                    if (forcePage) fOUT.write(12);                    fIN.close();                    fOUT.close();                }                catch (Exception e) {  }            }	            }		else (new ErrorDialog("Cannot locate report")).setVisible(true); 	}		void close() {}    	//{{DECLARE_CONTROLS	//}}}
