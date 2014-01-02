package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       dbConnection.java
    Created By: John Cardella, Software Engineer
    
    Function:   Static database connection class.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.io.File;
import java.sql.*;
import java.util.Vector;

public class DbConnection
{
    private static Connection dbProc;
    private static Login dbLogin;
    private static int resetCounter;
    private final static int MAX = 50;
    final static int INTEGER = -1;
    final static int STRING = -2;
    final static int DOUBLE = -3;
    private static LogFile log;
    
    public DbConnection(Login dbLogin)
    {
        this.dbLogin=dbLogin;
        this.resetCounter=0;
        this.openDB();
        this.log = new LogFile(
            getLogPath(),"dbConnection",getDate(),getUser());
    }
    
    /*
    public static synchronized Connection process()
    {
        log.write("resetCounter: "+resetCounter);
        log.write(dbProc.toString());
        resetCounter++;
        if (resetCounter==MAX) { 
            log.write("RESETTING DATABASE CONNECTION ["+MAX+"]");
            closeDB(); 
            openDB(); 
        }
        return (dbProc);
    }
    */
    
    public static synchronized Connection process() { 
    		return (dbProc); 
    } 
    
    private static void openDB()
    {
        try {
            Class.forName(dbLogin.driver);
            dbProc=DriverManager.getConnection
                                (dbLogin.URL,
                                 dbLogin.userName,
                                 dbLogin.userPassword);
        }
        catch (SQLException e) {
        	e.printStackTrace();
        	log.write(e.toString());	
        }
        catch (Exception e) { log.write(e); }
    }
    
    public static synchronized void change(String SQL, Vector paramList)
    {
        PreparedStatement pstmt = null;
        try {
            pstmt=dbProc.prepareStatement(SQL);
            for (int i=0; i<paramList.size(); i++) {
                SQLValue p = (SQLValue)paramList.elementAt(i);
                switch (p.dataType) {
                    case INTEGER:
                        pstmt.setInt(i+1,p.iValue);
                        break;
                    case STRING:
                        pstmt.setString(i+1,p.sValue);
                        break;
                    case DOUBLE:
                        pstmt.setDouble(i+1,p.dValue);
                        break;
                }
            }
            pstmt.executeUpdate();
            pstmt.close();
        }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
    }
    
    public static synchronized void call(String procName, Vector paramList)
    {
        CallableStatement cstmt = null;
        String callString = null;
        try {
            callString="{call "+procName+"(";
            if (paramList.size()>1) {
                for (int i=0; i<paramList.size()-1; i++) 
                    callString+="?,";
            }
            callString+="?)}";
            cstmt=dbProc.prepareCall(callString);
            for (int i=0; i<paramList.size(); i++) {
                SQLValue p = (SQLValue)paramList.elementAt(i);
                switch (p.dataType) {
                    case INTEGER:
                        cstmt.setInt(i+1,p.iValue);
                        break;
                    case STRING:
                        cstmt.setString(i+1,p.sValue);
                        break;
                    case DOUBLE:
                        cstmt.setDouble(i+1,p.dValue);
                        break;
                }
            }
            cstmt.executeUpdate();
            cstmt.close();
        }
        catch (SQLException e) { 
            log.write(e.toString()); 
            Utils.createErrMsg(e.toString());
        }
        catch (Exception e) { 
            log.write(e); 
            Utils.createErrMsg(e.toString());
        }
    }
    
    public static synchronized Vector query(String SQL, Vector resultList)
    {
        Vector p = new Vector();
        return (query(SQL,p,resultList));
    }
    
    public static synchronized Vector query(
    String SQL, Vector paramList, Vector resultList)
    {
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector resultValues = new Vector();
        try {
            pstmt=dbProc.prepareStatement(SQL);
            for (int i=0; i<paramList.size(); i++) {
                SQLValue p = (SQLValue)paramList.elementAt(i);
                switch (p.dataType) {
                    case INTEGER:   pstmt.setInt(i+1,p.iValue); break;
                    case STRING:    pstmt.setString(i+1,p.sValue); break;
                    case DOUBLE:    pstmt.setDouble(i+1,p.dValue); break;
                }
            }
            rs=pstmt.executeQuery();
            while (rs.next()) {
                Vector v = new Vector();
                for (int i=0; i<resultList.size(); i++) {
                    SQLValue r = (SQLValue)resultList.elementAt(i);
                    SQLValue x = new SQLValue();
                    switch (r.dataType) {
                        case INTEGER:   x.setInt(rs.getInt(i+1)); break;
                        case STRING:    x.setString(rs.getString(i+1)); break;
                        case DOUBLE:    x.setDouble(rs.getDouble(i+1)); break;
                    }
                    v.addElement(x);
                }
                resultValues.addElement(v);
            }
            rs.close(); pstmt.close();
        }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
        return (resultValues);
    }
    
    public static synchronized int getRowCount(String table, String clause)
    {
        Statement stmt = null;
        ResultSet rs = null;
        int count = -1;
        try {
            String SQL = "SELECT count(*) FROM "+table;
            if (!Utils.isNull(clause)) SQL+=" WHERE "+clause;
            stmt=dbProc.createStatement();
            rs=stmt.executeQuery(SQL);
            while (rs.next()) { count=rs.getInt(1); }
            rs.close(); stmt.close();
        }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
        return (count);
    }
    
    public static synchronized boolean inBillingQueue(int lab_number)
    {
        Statement stmt = null;
        ResultSet rs = null;
        int count = -1;
        boolean inQueue = false;
        try {
            String SQL = "SELECT count(*) FROM pcs.billing_queue \n"+
                         "WHERE lab_number = "+lab_number+" \n";
            stmt=dbProc.createStatement();
            rs=stmt.executeQuery(SQL);
            while (rs.next()) { count=rs.getInt(1); }
            rs.close(); stmt.close();
        }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
        if (count>0) inQueue=true;
        return (inQueue);
    }
    
    public static synchronized int getMax(
    String table, String field, String clause)
    {
        Statement stmt = null;
        ResultSet rs = null;
        int max = -1;
        try {
            String SQL = "SELECT NVL(MAX("+field+"),-1) FROM "+table;
            if (!Utils.isNull(clause)) SQL+=" WHERE "+clause;
            stmt=dbProc.createStatement();
            rs=stmt.executeQuery(SQL);
            while (rs.next()) { max=rs.getInt(1); }
            rs.close(); stmt.close();
        }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
        return (max);
    }
    
    public static synchronized int getNextTissueNumber()
    {
        Statement stmt = null;
        ResultSet rs = null;
        int nextLab = -1;
        try {
            String SQL = "SELECT job_status FROM pcs.job_control "+
                "WHERE job_descr='TISSUE PATHOLOGY' \n";
            stmt=dbProc.createStatement();
            rs=stmt.executeQuery(SQL);
            while (rs.next()) { nextLab=rs.getInt(1); }
            rs.close(); stmt.close();
        }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
        return (nextLab);
    }
    
    public static synchronized int getNextHPVNumber()
    {
        Statement stmt = null;
        ResultSet rs = null;
        int nextLab = -1;
        try {
            String SQL = "SELECT job_status FROM pcs.job_control "+
                "WHERE job_descr='HPV ONLY' \n";
            stmt=dbProc.createStatement();
            rs=stmt.executeQuery(SQL);
            while (rs.next()) { nextLab=rs.getInt(1); }
            rs.close(); stmt.close();
        }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
        return (nextLab);
    }

    private static void closeDB()
    {
        try { dbProc.close(); }
        catch (SQLException e) { log.write(e.toString()); }
        catch (Exception e) { log.write(e); }
        log.stop();
    }
    
    public static String getDate() { return dbLogin.dateToday; }
    public static String getUser() { return dbLogin.userName; }
    public static String getLogPath() {
    	String path ; 
    		if (dbLogin.logPath != null) {
    			path = dbLogin.logPath;
    		}
    		else {
    			path =  new File(".").getAbsolutePath() ; 
    		}
    		return path ; 
    }
    public static String getUserName(int uid) { return dbLogin.getUserName(uid); }
    
    public static int getTime(String mask) { return dbLogin.getNumericDate(mask); }
    public static void close() { closeDB(); }
    
	public static long getTime(int format)
	{
	    Statement stmt = null;
	    ResultSet rs = null;
	    long answer = 0;
	    String SQL = null;
	    try {
	        if (format==1) {
	            SQL =
	                "SELECT TO_NUMBER(TO_CHAR(SysDate,'YYYYMMDDHH24')) \n"+
	                "FROM DUAL\n";
	        }
	        else if (format==2) {
	            SQL =
	                "SELECT TO_NUMBER(TO_CHAR(SysDate,'YYYYMMDDHH24MMSS')) \n"+
	                "FROM DUAL\n";
	        }
	        stmt = dbProc.createStatement();
	        rs = stmt.executeQuery(SQL);
	        while (rs.next()) { 
	            answer=rs.getLong(1);
	        }
	        rs.close(); stmt.close();
	    }
	    catch (Exception e) { System.out.println(e); }
	    return (answer);
	}
	
	public static int getPreviousLab(int labNumber)
	{
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    int previous = 0;
	    String SQL = null;
	    try {
            SQL =
	           "SELECT previous_lab \n"+
	           "FROM pcs.lab_requisitions \n"+
	           "WHERE lab_number = ? \n";
            pstmt=dbProc.prepareStatement(SQL);
            pstmt.setInt(1,labNumber);
	        rs = pstmt.executeQuery();
	        while (rs.next()) { 
	            previous=rs.getInt(1);
	        }
	        rs.close(); pstmt.close();
	    }
	    catch (Exception e) { System.out.println(e); }
	    return (previous);
	}

	public static void updatePreviousLab(int labNumber, int previous)
	{
	    PreparedStatement pstmt = null;
	    String SQL = null;
	    try {
            SQL =
	           "UPDATE pcs.lab_requisitions \n"+
	           "SET previous_lab = ? \n"+
	           "WHERE lab_number = ? \n";
            pstmt=dbProc.prepareStatement(SQL);
            pstmt.setInt(1,previous);
            pstmt.setInt(2,labNumber);
	        pstmt.executeUpdate();
	        pstmt.close();
	    }
	    catch (Exception e) { System.out.println(e); }
	}

	public static double getCurrentBalance(int labNumber)
	{
	    PreparedStatement pstmt = null;
	    ResultSet rs = null;
	    double balance = 0;
	    String SQL = null;
	    try {
            SQL =
	           "SELECT pcs.get_current_balance(?) \n"+
	           "FROM DUAL\n";
            pstmt=dbProc.prepareStatement(SQL);
            pstmt.setInt(1,labNumber);
	        rs = pstmt.executeQuery();
	        while (rs.next()) { 
	            balance=rs.getDouble(1);
	        }
	        rs.close(); pstmt.close();
	    }
	    catch (Exception e) { System.out.println(e); }
	    return (balance);
	}
	
}
