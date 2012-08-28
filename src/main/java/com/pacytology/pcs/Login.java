package com.pacytology.pcs;/*    Login.java    Software Engineer: Jon Cardella        Function: Maintains general information needed for various functions    within the application as follows:    (1) User/password for connecting to Oracle;    (2) Driver and URL information needed to connect to Oracle;    (3) Date information such as the current date, number of days        so far in the year, and day of the week;    (4) Whether the most recent receiving date (day mail comes into        the facility) has been entered;    (5) Path where log files should be stored (currently set up to        be stored on each individual client PC);    (6) Vectors that are used to hold various lists of data.            */import java.awt.Color;import java.sql.Connection;import java.sql.DriverManager;import java.sql.PreparedStatement;import java.sql.ResultSet;import java.sql.SQLException;import java.sql.Statement;import java.util.Vector;import org.apache.commons.lang.StringUtils;public class Login{    public String userName;        String userPassword;    public String getUserPassword() {		return userPassword;	}	public void setUserPassword(String userPassword) {		this.userPassword = userPassword;	}	public String driver = "oracle.jdbc.driver.OracleDriver";	//The default jdbc connection is in PA Cytology's office; otherwise, pass a string from the command line	public String URL = StringUtils.isBlank(System.getProperty("jdbc.connection")) ? 				"jdbc:oracle:thin:@192.168.1.110:1521:pcs" : System.getProperty("jdbc.connection") ;    public String dateToday;    public String dayNumber;    public String dayOfWeek;    public String yearToday;    public String monthToday;    public String latestRecvDate;    public String currentMessage;    public int messageBackground = (Color.blue.darker()).getRGB();    public int messageForeground = Color.white.getRGB();    public boolean hasLatestRecvDate;    boolean loginEstablished=false;    public boolean isLoginEstablished() {		return loginEstablished;	}	public void setLoginEstablished(boolean loginEstablished) {		this.loginEstablished = loginEstablished;	}	public String logPath = Utils.LOG_PATH;      // DATA VECTORS        static public Vector billingCodeVect;    /*  Codes and IDs for the billing types used by the system;         for example OI (Other Insurance), BS (Blue Shield), etc.    */            static public Vector tppVect;    /*  Third Party Processors (TPPs) used for electronic billing    */    static public Vector nonOtherCarrierVect;    /*  Used to hold data about payers that are not commercial         insurance (Blue Shield, DPAs, Medicare)    */            static public Vector userVect;    /*  List of all database users and their UIDs    */    static public Vector restrictionsVect;    /*  Holds information used to restrict menu access based on        preconfigured setup by management    */        public Login() { /*no action taken when instantiated*/  }        /*        Sequence of methods called when the application is        first started up; returns true if application is ready        to run, false otherwise    */    public boolean initializeApplication() {        billingCodeVect = new Vector();        tppVect = new Vector();        nonOtherCarrierVect = new Vector();        userVect = new Vector();        boolean exitStatus = true;        try  {            Class.forName(driver);            Connection dbProc = DriverManager.getConnection(                URL,userName,userPassword);            exitStatus=queryBillingCodes(dbProc);            if (exitStatus) exitStatus=queryTpps(dbProc);            if (exitStatus) exitStatus=queryUsers(dbProc);            if (exitStatus) exitStatus=queryMessage(dbProc);            if (exitStatus) {                for (int i=0; i<billingCodeVect.size(); i++) {                    BillingCodeRec billingCode =                         (BillingCodeRec)billingCodeVect.elementAt(i);                    if (billingCode.choice_code.equals("DPA")                    || billingCode.choice_code.equals("BS")                     || billingCode.choice_code.equals("MED")) {                        exitStatus=getCarriersForBillingCode(                            billingCode.choice_code);                        if (!exitStatus) break;                    }                }            }            hasLatestRecvDate=checkLatestRecvDate(dbProc);            try { dbProc.close(); }            catch (SQLException e) { exitStatus=false; }                        }        catch( Exception e ) {            System.out.println(e+"\nERROR Initializing Application");            exitStatus=false;        }        return(exitStatus);                }        public boolean queryUsers(Connection dbProc)  {        boolean exitStatus = true;        try  {            String SQL =                 "SELECT user_id,username FROM all_users ORDER BY username \n";            Statement stmt = dbProc.createStatement();            ResultSet rs = stmt.executeQuery(SQL);            while (rs.next())  {                UserRec userRec = new UserRec();                userRec.user_id=rs.getInt(1);                userRec.username=rs.getString(2);                userVect.addElement(userRec);                /*                    As the list of users is being loaded into the application,                    if we are on the THIS user's copy of the application,                    get the list of any options they are restricted from                */                if (userName.toUpperCase().trim().equals(userRec.username.trim()))                    restrictionsVect=getRestrictions(dbProc,userRec.user_id);            }              try { rs.close(); stmt.close(); }            catch (Exception e) {                 System.out.println("Login.queryUsers \n"+e);                 exitStatus=false;            }        }        catch(Exception e) {             System.out.println("Login.queryUsers \n"+e);             exitStatus=false;        }        return (exitStatus);    }        public String getUserName(int uid)    {        String s = null;        for (int i=0; i<userVect.size(); i++) {            UserRec userRec = (UserRec)userVect.elementAt(i);            if (userRec.user_id==uid) {                s=userRec.username;                break;            }        }        return (s);    }     public boolean queryBillingCodes(Connection dbProc)  {        boolean exitStatus = true;        try  {            String query =                 "SELECT billing_choice,choice_code,description \n"+                "FROM pcs.billing_choices \n"+                "WHERE active_status='A' \n"+                "ORDER BY description";            Statement stmt = dbProc.createStatement();            ResultSet rs = stmt.executeQuery(query);            while (rs.next())  {                BillingCodeRec billingCode = new BillingCodeRec();                billingCode.billing_choice=rs.getInt(1);                billingCode.choice_code=rs.getString(2);                billingCode.description=rs.getString(3);                String buf = new String(billingCode.description+                    "  ["+billingCode.choice_code+"]");                billingCode.formattedString=buf;                String subQuery = "SELECT count(*) from pcs.carriers \n"+                        "WHERE billing_choice="+billingCode.billing_choice+" \n";                Statement subStmt = dbProc.createStatement();                ResultSet rs2 = subStmt.executeQuery(subQuery);                while (rs2.next()) { billingCode.carrier_count=rs2.getInt(1); }                billingCodeVect.addElement(billingCode);            }              try { rs.close(); stmt.close(); }            catch (SQLException e) { }        }        catch( Exception e ) {             System.out.println(e);             exitStatus=false;        }        return exitStatus;    }    public boolean queryTpps(Connection dbProc)  {        boolean exitStatus = true;        try  {            String query =                 "SELECT tpp,tpp_name,phone,file_name,dir_name,claim_format,claim_type \n"+                "FROM pcs.tpps ORDER BY tpp";            Statement stmt = dbProc.createStatement();            ResultSet rs = stmt.executeQuery(query);            while (rs.next())  {                TppRec tpp = new TppRec();                tpp.tpp=rs.getString(1);                tpp.tpp_name=rs.getString(2);                tpp.phone=rs.getString(3);                tpp.file_name=rs.getString(4);                tpp.dir_name=rs.getString(5);                tpp.claim_format=rs.getString(6);                tpp.claim_type=rs.getString(7);                tppVect.addElement(tpp);            }                            try { rs.close(); stmt.close(); }            catch (SQLException e) { }        }        catch( Exception e ) {             System.out.println(e);             exitStatus=false;        }        return exitStatus;    }        public boolean queryMessage(Connection dbProc)  {        boolean exitStatus = true;        try  {            String query =                 "SELECT current_message, message_background, message_foreground \n"+                "FROM pcs.business_info WHERE current_message is NOT NULL \n";            Statement stmt = dbProc.createStatement();            ResultSet rs = stmt.executeQuery(query);            while (rs.next()) {                 currentMessage=rs.getString(1);                 messageBackground=rs.getInt(2);                messageForeground=rs.getInt(3);            }            try { rs.close(); stmt.close(); }            catch (SQLException e) { exitStatus=false; }        }        catch( Exception e ) {             System.out.println(e);             exitStatus=false;        }        return exitStatus;    }    public int billingCodeCount(String billingChoice) {        int rv = 0;        for (int i=0;i<billingCodeVect.size();i++) {            BillingCodeRec bc = new BillingCodeRec();                   bc = (BillingCodeRec)billingCodeVect.elementAt(i);            if (bc.choice_code.equals(billingChoice)==true) {                rv = bc.carrier_count;                break;            }        }        return (rv);    }        private boolean getCarriersForBillingCode(String bChoice) {        boolean exitStatus=true;        try  {            Class.forName(driver);            Connection dbProc=DriverManager.getConnection(URL,userName,userPassword);            String query =                "SELECT c.carrier_id,c.name,c.state,c.id_number, \n"+                "   c.payer_id,cc.comment_text,c.billing_choice \n"+                "FROM pcs.carriers c, pcs.billing_choices bc, pcs.carrier_comments cc \n"+                "WHERE c.billing_choice=bc.billing_choice \n"+                "AND c.carrier_id=cc.carrier_id(+) \n"+                "AND c.active_status<>'I' \n"+                "AND bc.choice_code='"+bChoice+"' \n"+                "ORDER BY c.id_number \n";            Statement stmt = dbProc.createStatement();            ResultSet rs = stmt.executeQuery(query);            while (rs.next()) {                CarrierRec cRec = new CarrierRec();                cRec.carrier_id=rs.getInt(1);                cRec.name=rs.getString(2);                cRec.state=rs.getString(3);                cRec.id_number=rs.getInt(4);                cRec.payer_id=rs.getString(5);                cRec.comment_text=rs.getString(6);                cRec.billing_choice=rs.getInt(7);                nonOtherCarrierVect.addElement(cRec);            }               try {                 rs.close();                stmt.close();                dbProc.close();             }            catch (SQLException e) { exitStatus=false; }                        }        catch( Exception e ) {            System.out.println(e+" getCarrierBC");            exitStatus=false;        }        return(exitStatus);                }    public int getBillingChoice(String choiceCode) {        int billingChoice = -1;        for (int i=0; i<billingCodeVect.size(); i++) {            BillingCodeRec billingCode =                 (BillingCodeRec)billingCodeVect.elementAt(i);            if (billingCode.choice_code.equals(choiceCode)) {                billingChoice = billingCode.billing_choice;                break;            }        }        return(billingChoice);    }        public String getBillingDescription(int billingChoice)    {        String billingDescription = null;        for (int i=0; i<billingCodeVect.size(); i++) {            BillingCodeRec billingCode =                 (BillingCodeRec)billingCodeVect.elementAt(i);            if (billingCode.billing_choice==billingChoice) {                billingDescription = billingCode.description;                break;            }        }        return(billingDescription);    }        public Vector getCarrierVect(String choiceCode) {        Vector cVect = new Vector();        for (int i=0; i<nonOtherCarrierVect.size(); i++) {            CarrierRec cRec = (CarrierRec)nonOtherCarrierVect.elementAt(i);            if (cRec.billing_choice==getBillingChoice(choiceCode))                cVect.addElement(cRec);        }        return(cVect);    }        public String getBillingChoiceCode(int billingChoice)    {        String choiceCode = null;        for (int i=0; i<billingCodeVect.size(); i++) {            BillingCodeRec billingCode =                 (BillingCodeRec)billingCodeVect.elementAt(i);            if (billingCode.billing_choice==billingChoice) {                choiceCode = billingCode.choice_code;                break;            }        }        return(choiceCode);    }        public Vector getCarrierVect(int billingChoice) {        Vector cVect = new Vector();        for (int i=0; i<nonOtherCarrierVect.size(); i++) {            CarrierRec cRec = (CarrierRec)nonOtherCarrierVect.elementAt(i);            if (cRec.billing_choice==billingChoice)                cVect.addElement(cRec);        }        return(cVect);    }        public boolean checkLatestRecvDate(Connection dbProc)    {        boolean exitStatus = true;        try  {            String SQL1 = null;            String SQL2 = null;            int count = 0;            if (dayOfWeek.equals("SAT")) {                SQL1 =                     "SELECT TO_CHAR(start_date,'DY MM/DD/YYYY') \n"+                    "FROM pcs.receive_dates \n"+                    "WHERE start_date = TO_DATE(TO_CHAR(SysDate,'MMDDYYYY'),'MMDDYYYY')-1";            }            else if (dayOfWeek.equals("SUN")) {                SQL1 =                    "SELECT TO_CHAR(start_date,'DY MM/DD/YYYY') \n"+                    "FROM pcs.receive_dates \n"+                    "WHERE start_date = TO_DATE(TO_CHAR(SysDate,'MMDDYYYY'),'MMDDYYYY')-2";            }            else {                SQL1 =                    "SELECT TO_CHAR(start_date,'DY MM/DD/YYYY') \n"+                    "FROM pcs.receive_dates \n"+                    "WHERE start_date = TO_DATE(TO_CHAR(SysDate,'MMDDYYYY'),'MMDDYYYY')";            }            if (dayOfWeek.equals("MON")) {                SQL2 =                    "SELECT TO_CHAR(TO_DATE(TO_CHAR( \n"+                    "   SysDate,'MMDDYYYY'),'MMDDYYYY')-3,'DY MM/DD/YYYY') FROM DUAL \n";            }            else if (dayOfWeek.equals("SUN")) {                SQL2 =                    "SELECT TO_CHAR(TO_DATE(TO_CHAR( \n"+                    "   SysDate,'MMDDYYYY'),'MMDDYYYY')-2,'DY MM/DD/YYYY') FROM DUAL \n";            }            else {                SQL2 =                    "SELECT TO_CHAR(TO_DATE(TO_CHAR( \n"+                    "   SysDate,'MMDDYYYY'),'MMDDYYYY')-1,'DY MM/DD/YYYY') FROM DUAL \n";            }                        Statement stmt = dbProc.createStatement();            ResultSet rs = stmt.executeQuery(SQL1);            while (rs.next()) { count++; }            rs=stmt.executeQuery(SQL2);            while (rs.next()) { latestRecvDate=rs.getString(1); }            if (count<1) exitStatus=false;            try { rs.close(); stmt.close(); }            catch (SQLException e) { }        }        catch( Exception e ) {             System.out.println(e);             exitStatus=false;        }        return exitStatus;    }    	Vector getRestrictions(Connection dbProc, int uid)	{	    Vector v = new Vector();	    try {	        String SQL =	            "SELECT object_name FROM pcs.user_restrictions \n"+	            "WHERE user_id = ? ORDER BY object_name \n";            PreparedStatement pstmt = dbProc.prepareStatement(SQL);            pstmt.setInt(1,uid);            ResultSet rs = pstmt.executeQuery();            while (rs.next()) { v.addElement(rs.getString(1)); }            try { rs.close(); pstmt.close(); }            catch (Exception e) { }	    }	    catch (Exception e) { }	    return (v);	}		public boolean hasRestriction(String objectName)	{	    boolean restricted = false;	    for (int i=0; i<restrictionsVect.size(); i++) {	        String oName = (String)restrictionsVect.elementAt(i);	        if (oName.trim().equals(objectName.trim())) {	            restricted=true;	            break;	        }	    }	    return (restricted);	}		public static String getCurrentDateTime()	{	    String currentTime = null;	    Statement stmt = null;	    ResultSet rs = null;	    try {	        String SQL =	            "SELECT RTRIM(LTRIM(TO_CHAR(SysDate,'MM/DD/YYYY HH24:Mi'))) \n"+	            "FROM DUAL\n";	        stmt = DbConnection.process().createStatement();	        rs = stmt.executeQuery(SQL);	        while (rs.next()) { currentTime = rs.getString(1); }	        rs.close(); stmt.close();	    }	    catch (Exception e) { System.out.println(e); }	    return currentTime;	}		public static String getAlphaDate(String mask)	{        int numericDate = -1;	    boolean wantsYear = false;	    boolean wantsMonth = false;	    boolean wantsDay = false;	    boolean wantsTime = false;	    String YYYY = null;	    String MM = null;	    String DD = null;	    String TT = null;	    String buf0 = "NULL";	    String buf1 = "NULL";	    String buf2 = "NULL";	    String buf3 = "NULL";	    StringBuffer alphaDate = new StringBuffer("0");	    int maskLength = mask.length();	    switch (maskLength) {	        case 2:	            if (mask.equals("MM")) wantsMonth=true;	            else if (mask.equals("DD")) wantsDay=true;	            else if (mask.equals("TT")) wantsTime=true;	            break;	        case 4:	            if (mask.equals("YYYY")) wantsYear=true;	            else {	                buf1=mask.substring(0,2);	                buf2=mask.substring(2,4);	            }	            break;	        case 6:	            buf0=mask.substring(0,4);	            if (buf0.equals("YYYY")) {	                wantsYear=true;	                buf1=mask.substring(4);	            }	            else {	                buf1=mask.substring(0,2);	                buf2=mask.substring(2,4);	                buf3=mask.substring(4);	            }	            break;	        case 8:	            buf0=mask.substring(0,4);	            if (buf0.equals("YYYY")) {	                wantsYear=true;	                buf1=mask.substring(4,6);	                buf2=mask.substring(6);	            }	            break;	        case 10:	            buf0=mask.substring(0,4);	            if (buf0.equals("YYYY")) {	                wantsYear=true;	                buf1=mask.substring(4,6);	                buf2=mask.substring(6,8);	                buf3=mask.substring(8);	            }	            break;	        default:	    }	    Statement stmt = null;	    ResultSet rs = null;	    try {	        String SQL =	            "SELECT TO_CHAR(SysDate,'YYYY'), \n"+	            "   TO_CHAR(SysDate,'MM'), \n"+	            "   TO_CHAR(SysDate,'DD'), \n"+	            "   TO_CHAR(SysDate,'HH24') \n"+	            "FROM DUAL\n";	        stmt = DbConnection.process().createStatement();	        rs = stmt.executeQuery(SQL);	        while (rs.next()) { 	            YYYY=rs.getString(1).trim(); 	            MM=rs.getString(2).trim();	            DD=rs.getString(3).trim();	            TT=rs.getString(4).trim();	        }	        rs.close(); stmt.close();	    }	    catch (Exception e) { System.out.println(e); }	    if (buf1.equals("MM")) wantsMonth=true;	    else if (buf1.equals("DD")) wantsDay=true;	    else if (buf1.equals("TT")) wantsTime=true;	    if (buf2.equals("MM")) wantsMonth=true;	    else if (buf2.equals("DD")) wantsDay=true;	    else if (buf2.equals("TT")) wantsTime=true;	    if (buf3.equals("MM")) wantsMonth=true;	    else if (buf3.equals("DD")) wantsDay=true;	    else if (buf3.equals("TT")) wantsTime=true;	    if (wantsYear) alphaDate.append(YYYY);	    if (wantsMonth) alphaDate.append(MM);	    if (wantsDay) alphaDate.append(DD);	    if (wantsTime) alphaDate.append(TT);	    try {	        numericDate = (int)Integer.parseInt(alphaDate.toString());	    }	    catch (Exception e) { }	    return (alphaDate.toString());	}		public static int getNumericDate(String mask)	{	    String alphaDate = getAlphaDate(mask);	    int numericDate = -1;	    try {	        numericDate = (int)Integer.parseInt(alphaDate);	    }	    catch (Exception e) { }	    return (numericDate);	}	}  
