package com.pacytology.pcs;


/*
    PathDbOps.java
    Software Engineer: Jon Cardella
    
    Function: Database operations for pathologist form.
*/

import java.lang.*;
import java.sql.*;
import java.sql.Types;

public class PathDbOps
{
    PathologistForm parent;
    public PathDbOps(PathologistForm p) {  parent = p; }

    public boolean queryAllPaths()  {
        boolean exitStatus=true;
        try  {
            String query = 
                "SELECT \n"+
                "   pathologist,lname,fname,address1,city, \n"+
                "   state,zip,phone,pathologist_code,mi, \n"+
                "   title,degree \n"+
                "FROM \n"+
                "   pcs.pathologists \n"+
                "ORDER BY \n"+
                "   lname,fname \n";
                
            System.out.println(query);                
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            int rowsReturned=0;
            while (rs.next()) {
                rowsReturned++;
            }
            if (rowsReturned>0) {
                parent.MAX_PATHS=rowsReturned;
                parent.paths=new PathRec[parent.MAX_PATHS];
                String ctItem=" ";
                int ndx=0;
                rs = stmt.executeQuery(query);
                while (rs.next()) {
                    parent.paths[ndx]=new PathRec();
                    parent.paths[ndx].pathologist=rs.getInt(1);
                    parent.paths[ndx].lname=rs.getString(2);
                    parent.paths[ndx].fname=rs.getString(3);
                    parent.paths[ndx].address1=rs.getString(4);
                    parent.paths[ndx].city=rs.getString(5);
                    parent.paths[ndx].state=rs.getString(6);
                    parent.paths[ndx].zip=rs.getString(7);
                    parent.paths[ndx].phone=rs.getString(8);
                    parent.paths[ndx].pathologist_code=rs.getString(9);
                    parent.paths[ndx].mi=rs.getString(10);
                    parent.paths[ndx].title=rs.getString(11);
                    parent.paths[ndx].degree=rs.getString(12);
                    ndx++;                    
                }       
            }
            else { exitStatus=false; }
        }
        catch( Exception e ) {
            System.out.println(e+" queryAllPaths");
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

    public boolean add()  {
        boolean exitStatus=true;
        try  {
            String query = 
                "INSERT INTO pcs.pathologists \n"+
                "   (pathologist,lname,fname,address1,city, \n"+
                "    state,zip,phone,pathologist_code,active_status,mi, \n"+
                "    title,degree) \n"+
                "VALUES (pcs.tech_seq.nextval,?,?,?,?,?,?,?,?,?,?,?,?) \n";
            PreparedStatement pstmt = dbConnection.process().prepareStatement(query);
            pstmt.setString(1,parent.pathLName.getText());
            pstmt.setString(2,parent.pathFName.getText());
            pstmt.setNull(3,java.sql.Types.VARCHAR);
            pstmt.setNull(4,java.sql.Types.VARCHAR);
            pstmt.setNull(5,java.sql.Types.VARCHAR);
            pstmt.setNull(6,java.sql.Types.VARCHAR);
            pstmt.setNull(7,java.sql.Types.VARCHAR);
            pstmt.setString(8,parent.pathCode.getText());
            pstmt.setString(9,"A");
            pstmt.setString(10,parent.pathMI.getText());
            pstmt.setString(11,parent.pathTitle.getText());
            pstmt.setString(12,parent.pathDegree.getText());
            System.out.println(query);                
            int rs = pstmt.executeUpdate();
            if (rs>0) {
                queryAllPaths();
                for (int i=0;i<parent.MAX_PATHS;i++) {
                    if (parent.paths[i].pathologist>parent.currNdx) {
                        parent.currNdx=i;
                        break;
                    }
                }
            }
            else { exitStatus=false; }
        }
        catch( Exception e ) {
            System.out.println(e+" addPaths");
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }
    
    
	//{{DECLARE_CONTROLS
	//}}
}
