/*    PENNSYLVANIA CYTOLOGY SERVICES    LABORATORY INFORMATION SYSTEM V1.0    Copyright (C) 2001 by John Cardella    All Rights Reserved        File:       StringUtils.java    Created By: John Cardella, Software Engineer        Function:   A random collection of utilities used to format    and verify data and options in the data entry forms of the     application.  Note this class originally began as a collection    of string utilities but over time grew to include much more than    that.        MODIFICATIONS ----------------------------------    Date/Staff      Description:*/import java.lang.*;import java.awt.Color;import java.awt.Font;import java.awt.Container;import java.awt.Component;import javax.swing.*;import javax.swing.text.*;import javax.swing.border.*;import javax.swing.table.*;import java.util.Random;import java.awt.event.KeyEvent;import java.awt.event.FocusEvent;import javax.swing.JTextField;import javax.swing.border.TitledBorder;import Square;import java.util.Calendar;import java.util.Date;public class StringUtils {    final public Color queryColor =         (new Color(102,102,153)).brighter();    final public Color FORM_BACKGROUND = Color.blue.darker();    final public Color CARET = Color.yellow.brighter();    final public Color DISABLED = Color.white;    final public Color TEXT_FOREGROUND = Color.green;    final public Color TEXT_BACKGROUND = Color.black;    final public Color LABEL_FOREGROUND = Color.yellow.brighter();    final public Color LIST_FOREGROUND = Color.black;    final public Color LIST_BACKGROUND = Color.white;    final public Color SELECTED_FOREGROUND = Color.black;    final public Color SELECTED_BACKGROUND = Color.yellow;    final public Color TABLE_FOREGROUND = Color.black;    final public Color TABLE_BACKGROUND = Color.white;    final public Color SQUARE = Color.yellow.brighter();    final public Color MENU_FOREGROUND = Color.white;    final public Color MENU_BACKGROUND = Color.red.darker();    final public Color BUTTON_FOREGROUND = Color.white;       public StringUtils() { }        public String doctorName(DoctorRec dRec)    {        StringBuffer dName = new StringBuffer();        if (!isNull(dRec.fname)) {            dName.append(dRec.fname);            dName.append(" ");        }        if (!isNull(dRec.mi)) {            dName.append(dRec.mi);            dName.append(" ");        }        dName.append(dRec.lname);        if (!isNull(dRec.title))             dName.append(" "+dRec.title.trim());        return (dName.toString());                }    public String addPhoneMask(String inputString) {        if (isNull(inputString)) return null;        String outputString=            "("+inputString.substring(0,3)+            ") "+inputString.substring(3,6)+            "-"+inputString.substring(6);        return (outputString);    }    public String stripPhoneMask(String inputString) {        int slen = inputString.length();        if (slen==0) return null;        String outputString=            inputString.substring(1,4)+            inputString.substring(6,9)+            inputString.substring(10);        return (outputString);    }       public void buildPhoneMask(JTextField phoneField) {        String buf=phoneField.getText();        if (buf.length()==1) {            buf="("+buf;            phoneField.setText(buf);        }        else if (buf.length()==4) {            buf=buf+") ";            phoneField.setText(buf);        }        else if (buf.length()==9) {            buf=buf+"-";            phoneField.setText(buf);        }        else if (buf.length()>13) {            buf=buf.substring(0);            phoneField.setText(buf);        }    }	public void buildPhoneMask(java.awt.event.KeyEvent event) {	    if (event.getKeyChar()=='\r' || event.getKeyChar()=='\b') return;	    forceDigits(event,14);	    StringBuffer field = new StringBuffer();	    field.append(((JTextField)event.getComponent()).getText());	    if (length(field.toString())==0)	        field.append('(');	    else if (length(field.toString())==4)	        field.append(") ");	    else if (length(field.toString())==9)	        field.append('-');	    ((JTextField)event.getComponent()).setText(field.toString());	}        public String addZipMask(String inputString) {        if (isNull(inputString)) return null;        int slen=0;        String outputString=null;        try { slen=inputString.length(); }        catch (Exception e) { System.out.println(e+" addZipMask"); }        if (slen>0) {            outputString=inputString.substring(0,5);            if (slen>5)                outputString=outputString+                "-"+inputString.substring(5);        }        return (outputString);    }        public String stripZipMask(String inputString) {        int slen = inputString.length();        if (slen==0) return null;        String outputString=null;        if (slen>5) {            outputString=inputString.substring(0,5)+                inputString.substring(6);        }        else outputString=inputString;        return (outputString);    }    public void buildZipMask(JTextField zipField) {        String buf=zipField.getText();        if (buf.length()==5) {            buf=buf+"-";            zipField.setText(buf);        }        else if (buf.length()>9) {            buf=buf.substring(0);            zipField.setText(buf);        }    }	public void buildZipMask(java.awt.event.KeyEvent event) {	    if (event.getKeyChar()=='\r' || event.getKeyChar()=='\b') return;	    forceDigits(event,10);	    StringBuffer field = new StringBuffer();	    field.append(((JTextField)event.getComponent()).getText());	    if (length(field.toString())==5)	        field.append('-');	    ((JTextField)event.getComponent()).setText(field.toString());	}    public String addSSNMask(String inputString) {        if (isNull(inputString)) return null;        int slen=0;        String outputString=null;        try { slen=inputString.length(); }        catch (Exception e) { System.out.println(e+" addSSNMask"); }        if (slen>0) {            outputString=inputString.substring(0,3)+"-"+                inputString.substring(3,5)+"-"+                inputString.substring(5);        }        return (outputString);    }        public String stripSSNMask(String inputString) {        int slen = inputString.length();        if (slen==0) return null;        String outputString=null;        outputString=inputString.substring(0,3)+            inputString.substring(4,6)+            inputString.substring(7);        return (outputString);    }    public void buildSSNMask(JTextField ssnField) {        String buf=ssnField.getText();        if (buf.length()==3) {            buf=buf+"-";            ssnField.setText(buf);        }        else if (buf.length()==6) {            buf=buf+"-";            ssnField.setText(buf);        }        else if (buf.length()>10) {            buf=buf.substring(0);            ssnField.setText(buf);        }    }	public void buildSSNMask(java.awt.event.KeyEvent event) {	    if (event.getKeyChar()=='\r' || event.getKeyChar()=='\b') return;	    forceDigits(event,11);	    StringBuffer field = new StringBuffer();	    field.append(((JTextField)event.getComponent()).getText());	    if (length(field.toString())==3 || length(field.toString())==6)	        field.append('-');	    ((JTextField)event.getComponent()).setText(field.toString());	}    public String addDateMask(String inputString) {        if (isNull(inputString)) return null;        int slen=0;        String outputString=null;        try { slen=inputString.length(); }        catch (Exception e) { System.out.println(e+" addDateMask"); }        if (slen>0) {            outputString=inputString.substring(0,2)+"/"+                inputString.substring(2,4)+"/"+                inputString.substring(4);        }        return (outputString);    }        public String stripDateMask(String inputString) {        int slen = inputString.length();        if (slen==0) return null;        String outputString=null;        outputString=inputString.substring(0,2)+            inputString.substring(3,5)+            inputString.substring(6);        return (outputString);    }    public void buildDateMask(JTextField dateField) {        String buf=dateField.getText();        if (buf.length()==2) {            buf=buf+"/";            dateField.setText(buf);        }        else if (buf.length()==5) {            buf=buf+"/";            dateField.setText(buf);        }        else if (buf.length()>9) {            buf=buf.substring(0);            dateField.setText(buf);        }    }    	public void buildDateMask(java.awt.event.KeyEvent event) {	    if (event.getKeyChar()=='\r' || event.getKeyChar()=='\b') return;	    forceDigits(event,10);	    StringBuffer field = new StringBuffer();	    field.append(((JTextField)event.getComponent()).getText());	    if (length(field.toString())==2 || length(field.toString())==5)	        field.append('/');	    ((JTextField)event.getComponent()).setText(field.toString());	}        public int length(String s) {        int slen = 0;        try { slen=s.length(); }        catch (Exception e) { }        return (slen);    }        public boolean isNull(String s) {        int slen = 0;        boolean rv = false;        try { slen=s.length(); }        catch (Exception e) { }        if (slen==0) rv=true;        return (rv);    }        public String isNull(String candidate, String alternate)    {        if (isNull(candidate)) return alternate;        else return candidate;    }    	public boolean requiredField(JTextField field, String s)  {	    boolean rv = true;	    if (isNull(field.getText()))  {	        createErrMsg("Required Field: ["+s+"]");	        rv=false;        }	                return (rv);    }        	    	public boolean required(JTextField field, String s)  {	    boolean rv = true;	    if (isNull(field.getText()))  {	        createErrMsg("Required Field: ["+s+"]");	        rv=false;        }	                return (rv);    }        	        	void deselect(java.awt.event.FocusEvent event)	{	    JTextComponent t = (JTextComponent)event.getSource();	    if (!isNull(t.getText())) { 	        t.select(0,0);	        t.setCaretPosition(length(t.getText()));	    }	    	}	public void createErrMsg(String msg)  {        (new ErrorDialog(msg)).setVisible(true);    }	        	public boolean dateVerify(JTextField field)  {	    String sDate = stripDateMask(field.getText());	    if (isNull(sDate)) return (true);	    int year, month, day;	    String buf;	    boolean status=true;	    if (length(sDate)!=8)  {	        String msg = sDate+" is not a valid date";	        createErrMsg(msg);	        field.setText(null);	        return false;        }	        	    buf=sDate.substring(0,2);	    month=Integer.parseInt(buf);	    buf=sDate.substring(2,4);	    day=Integer.parseInt(buf);	    buf=sDate.substring(4,8);	    year=Integer.parseInt(buf);	    if ((month<1)||(month>12))  {	        status=false;	        String msg = "Invalid month entered ["+month+"]";	        createErrMsg(msg);        }	                else  {	                    switch (month)  {            case 1:             case 3:            case 5:            case 7:            case 8:            case 10:            case 12:    if ((day<1)||(day>31))  {                            status=false;                            String msg = "Invalid Day ["+day+"] for Month ["+month+"]";                            createErrMsg(msg);                        } break;            case 2:     if ((day<1)||(day>29))  {                            status=false;                            String msg = "Invalid Day ["+day+"] for Month ["+month+"]";                            createErrMsg(msg);                        }                                                if ((day==29)&&((year%4)!=0))  {                            status=false;                            String msg = "Invalid Leap Year ["+year+"]";                            createErrMsg(msg);                        } break;            case 4:               case 6:            case 9:            case 11:    if ((day<1)||(day>30))  {                            status=false;                            String msg = "Invalid Day ["+day+"] for Month ["+month+"]";                            createErrMsg(msg);                        } break;            }                                }                                if ((year<1800)||(year>2100))  {            status=false;            String msg = "Invalid Year ["+year+"]";            createErrMsg(msg);        }                if (!status) field.setText(null);	    return (status);    }       	public void forceUpper(java.awt.event.KeyEvent event) {        try {	        char key=event.getKeyChar();	        if ( (key>='a')&&(key<='z') ) 	            event.setKeyChar((char)(key-32));        }        catch (Exception e)  { System.out.println(e); }                }	    	public void forceUpper(java.awt.event.KeyEvent event, int size) {	    if ( length(((JTextField)event.getComponent()).getText())>(size-1) )	        event.consume();	    else {            try {	            char key=event.getKeyChar();	            if ( (key>='a')&&(key<='z') ) 	                event.setKeyChar((char)(key-32));            }            catch (Exception e) { System.out.println(e); }                    }    }	        	public void forceDigits(java.awt.event.KeyEvent event)  {	    try {	        char key=event.getKeyChar();	        if ( ((key<'0')||(key>'9')) && key!='\b' ) 	            event.consume();        }        catch (Exception e)  { System.out.println(e); }                }        	public void forceDigits(java.awt.event.KeyEvent event, int size)  {	    if ( length(((JTextField)event.getComponent()).getText())>(size-1) )	        event.consume();	    else {	        try {	            char key=event.getKeyChar();	            if ( ((key<'0')||(key>'9')) && key!='\b' ) 	                event.consume();            }            catch (Exception e)  { System.out.println(e); }                    }    }            public String blankString(int sz)    {        StringBuffer s = new StringBuffer();        for (int i=0; i<sz; i++) {            s.append(' ');        }        return s.toString();    }        public String rpad(String s, int sz)    {        return (rpad(s,sz," "));    }        public String rpad(String s, int sz, String c)    {        int len = s.length();        if (len<=0) return null;        else if (len>=sz) return s.substring(0,sz);        StringBuffer ns = new StringBuffer(s);        for (int i=len; i<sz; i++) ns.append(c);        return ns.toString();    }        public String lpad(String s, int sz)    {        return (lpad(s,sz," "));    }        public String lpad(String s, int sz, String c)    {        int len = s.length();        if (len<=0) return null;        else if (len>=sz) return s.substring(0,sz);        StringBuffer ns = new StringBuffer();        for (int i=0; i<(sz-len); i++) ns.append(c);        ns.append(s);        return ns.toString();    }        public String dblToString(double d)    {        String s = (new Double(d)).toString();        StringBuffer sb = new StringBuffer();        int j = 0;        boolean dec = false;        for (int i=0; i<s.length(); i++) {            if (s.charAt(i)=='.') dec=true;            if (dec) j++;            sb.append(s.charAt(i));            if (j==3) break;        }        return (sb.toString());    }        public String random()    {        int x = (new Random()).nextInt();        if (x<0) x*=(-1);        return Integer.toString(x);    }        public void setColors(Container c)    {        int count = c.getComponentCount();        c.setBackground(FORM_BACKGROUND);        for (int i=0; i<count; i++) {            try {                Component obj = c.getComponent(i);                setComponent(obj);                obj.repaint();            }            catch (Exception e) { System.out.println(e); }        }    }        public void setComponent(Component obj)    {        try {            String s = obj.getClass().getName();            if (s.equals("javax.swing.JTextField")) {                obj.setBackground(TEXT_BACKGROUND);                obj.setForeground(TEXT_FOREGROUND);                ((JTextComponent)obj).setDisabledTextColor(DISABLED);                ((JTextComponent)obj).setCaretColor(CARET);                ((JTextComponent)obj).setFont(new Font("SansSerif", Font.BOLD, 12));            }            if (s.equals("javax.swing.JTextArea")) {                obj.setBackground(TEXT_BACKGROUND);                obj.setForeground(TEXT_FOREGROUND);                ((JTextComponent)obj).setDisabledTextColor(DISABLED);                ((JTextComponent)obj).setCaretColor(CARET);                ((JTextComponent)obj).setFont(new Font("SansSerif", Font.BOLD, 12));            }            else if (s.equals("javax.swing.JCheckBox")) {                obj.setBackground(FORM_BACKGROUND);                obj.setForeground(LABEL_FOREGROUND);                ((JCheckBox)obj).setFont(new Font("SansSerif", Font.BOLD, 12));            }            else if (s.equals("javax.swing.JButton")) {                obj.setForeground(BUTTON_FOREGROUND);                ((JButton)obj).setFont(new Font("SansSerif", Font.BOLD, 12));            }            else if (s.equals("javax.swing.JLabel")) {                obj.setForeground(LABEL_FOREGROUND);                obj.setFont(new Font("Dialog", Font.BOLD, 12));            }            else if (s.equals("javax.swing.JList")) {                obj.setBackground(LIST_BACKGROUND);                obj.setForeground(LIST_FOREGROUND);                ((JList)obj).setFont(new Font("SansSerif", Font.BOLD, 9));                ((JList)obj).setSelectionBackground(SELECTED_BACKGROUND);                ((JList)obj).setSelectionForeground(SELECTED_FOREGROUND);                }            else if (s.equals("javax.swing.JTable")) {                obj.setBackground(TABLE_BACKGROUND);                obj.setForeground(TABLE_FOREGROUND);                ((JTable)obj).setSelectionBackground(SELECTED_BACKGROUND);                ((JTable)obj).setSelectionForeground(SELECTED_FOREGROUND);            }            else if (s.equals("javax.swing.JPanel")) {                setColors((Container)obj);            }            else if (s.equals("javax.swing.JScrollPane")) {                setColors((Container)obj);            }            else if (s.equals("javax.swing.JViewport")) {                setColors((Container)obj);            }            else if (s.equals("Square")) {                obj.setForeground(SQUARE);            }            else if (s.equals("javax.swing.JMenuBar")) {                setColors((Container)obj);            }            else if (s.equals("javax.swing.JMenu")) {                obj.setBackground(MENU_BACKGROUND);                obj.setForeground(MENU_FOREGROUND);            }        }        catch (Exception e) { System.out.println(e); }    }    /*        Tests the date sent in (format = MM/DD/YYYY); time is        default to midnight of the day sent in.        The result is:                    FALSE if the date sent in is the same as or before            today's date                        TRUE if the date sent in is after today's date    */    public boolean afterToday(String date)    { 	    String sDate = stripDateMask(date);	    if (isNull(sDate)) return (false);	    int year, month, day;	    String buf;	    if (length(sDate)!=8) return (false);	        	    buf=sDate.substring(0,2);	    month=Integer.parseInt(buf);	    buf=sDate.substring(2,4);	    day=Integer.parseInt(buf);	    buf=sDate.substring(4,8);	    year=Integer.parseInt(buf);	    Date testDate = new Date(year-1900,month-1,day);	    Date rightNow = new Date();	    return (testDate.after(rightNow));   }} 
