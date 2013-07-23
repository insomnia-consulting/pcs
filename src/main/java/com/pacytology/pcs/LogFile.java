package com.pacytology.pcs;import java.io.*;import java.util.Date;import java.sql.SQLException;import org.joda.time.DateTime;/*    The format of the log file is as follows:    <path><java class name><MMDDYYYY>.<Oracle user name>    Path must be full qualified with last character a slash*/public class LogFile {            public PrintWriter file;    public String fName;    private String path;    private String javaClass;    private String userName;    private String dateToday;    private boolean wasCreated;    private final int PURGE_AFTER = 42;    private final int PURGE_RANGE = 120;    LogFile(String fName)     {         this.fName=fName;         try { this.start(); }        catch (Exception e) { e.printStackTrace(); }    }        LogFile(String path,String javaClass,String dateToday,String userName)    {    	this.path=path;    	if (this.path == null) {    		this.path = new File(".").getAbsolutePath() ;     	}                        this.javaClass=javaClass;        this.dateToday=dateToday;        this.userName=userName;        this.fName =             this.path.trim()+javaClass.trim()+dateToday.trim()+"."+userName.trim();        this.wasCreated=fileExists(fName);        try {             this.start();             if (!wasCreated) {                this.write("--------------------------------------------------------------------------------");                this.write("LOG CREATED:  "+datestamp());                this.write("JAVA CLASS:   "+this.javaClass);                this.write("ORACLE USER:  "+this.userName);                this.write("--------------------------------------------------------------------------------");                purge();            }            else {                this.write("\nREENTER LOG:  "+datestamp());            }        }        catch (Exception e) { e.printStackTrace(); }    }            private void start() throws IOException {        file = new PrintWriter(                    new BufferedOutputStream(                        new FileOutputStream(fName,true)),true);    }        private boolean fileExists(String fName)    {        return ((new File(fName)).exists());    }        public void stop() {        try {             this.write("\nEXIT LOG AT:  "+datestamp());            this.write("--------------------------------------------------------------------------------\n");            file.close(); }        catch (Exception e) { e.printStackTrace(); }    }        public void write(String output) { file.println(output); }        public void write(Object output) { file.println(output); }        public void write(SQLException output)    {        file.println("\nSQL ERROR ---------------------------------------------");        file.println("State:       "+output.getSQLState());        file.println("Message:     "+output.getMessage());        file.println("Vendor code: "+output.getErrorCode());        file.println("-------------------------------------------------------");        output.printStackTrace(System.out);    }        public void write() { file.println(); }        public static String datestamp() { return (new Date()).toString(); }        public void stamp(String msg) { write(datestamp()+" "+msg); }                public void purge() {		write("\nPURGING OLD LOG FILES");		DateTime today = DateTime.parse(dateToday);		for (int i = 0; i < PURGE_AFTER; i++)			today = today.minusDays(1);		for (int i = 0; i < PURGE_RANGE; i++) {			today = today.minusDays(1);			String fName = path.trim() + javaClass.trim() + today.toString("MMDDYYYY") + "."					+ userName.trim();			File f = new File(fName);			if (f.exists()) {				try {					f.delete();					write("DELETING " + fName);				} catch (Exception e) {					e.printStackTrace();				}			}		}	}    } 
