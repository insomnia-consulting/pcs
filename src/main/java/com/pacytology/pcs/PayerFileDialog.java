package com.pacytology.pcs;

/*
		A basic implementation of the JDialog class.
*/

import java.awt.*;
import java.awt.event.KeyEvent;
import java.sql.*;
import javax.swing.*;
import java.util.StringTokenizer;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.util.Vector;
import com.pacytology.pcs.ui.Square;

public class PayerFileDialog extends javax.swing.JDialog
{
    Login dbLogin;
    final int NEW_FLAG = 0;
    final int NAME = 1;
    final int PAYER = 2;
    final int CARD = 3;
    final int ENROLL = 4;
    final int SERVICE = 5;
    final int COMMENT = 6;
    final int ADD = -101;
    final int NO_ADD = -102;
    final int PENDING = -103;
    final int EXISTS = -104;
    public Vector pendingVect = new Vector();
    int currNdx = -1;
    
	public PayerFileDialog(Frame parent)
	{
		super(parent);
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Process Payer File");
		getContentPane().setLayout(null);
		setSize(474,382);
		setVisible(false);
		JLabel1.setText("File Name");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(20,80,60,12);
		fileName.setEnabled(false);
		getContentPane().add(fileName);
		fileName.setFont(new Font("DialogInput", Font.PLAIN, 12));
		fileName.setBounds(90,78,200,20);
		getContentPane().add(F1sq);
		F1sq.setBounds(35,6,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F1");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(39,6,20,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(97,6,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F2");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(101,6,20,20);
		getContentPane().add(F3sq);
		F3sq.setBounds(159,6,20,20);
		F3lbl.setRequestFocusEnabled(false);
		F3lbl.setText("F3");
		getContentPane().add(F3lbl);
		F3lbl.setForeground(java.awt.Color.black);
		F3lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F3lbl.setBounds(163,6,20,20);
		getContentPane().add(F4sq);
		F4sq.setBounds(221,6,20,20);
		F4lbl.setRequestFocusEnabled(false);
		F4lbl.setText("F4");
		getContentPane().add(F4lbl);
		F4lbl.setForeground(java.awt.Color.black);
		F4lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F4lbl.setBounds(225,6,20,20);
		getContentPane().add(F9sq);
		F9sq.setBounds(345,6,20,20);
		F9lbl.setRequestFocusEnabled(false);
		F9lbl.setText("F10");
		getContentPane().add(F9lbl);
		F9lbl.setForeground(java.awt.Color.black);
		F9lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F9lbl.setBounds(346,6,20,20);
		getContentPane().add(F12sq);
		F12sq.setBounds(407,6,20,20);
		F12lbl.setRequestFocusEnabled(false);
		F12lbl.setText("F12");
		getContentPane().add(F12lbl);
		F12lbl.setForeground(java.awt.Color.black);
		F12lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F12lbl.setBounds(408,6,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Add");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(72,30,70,16);
		F3action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F3action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F3action.setText("Update");
		getContentPane().add(F3action);
		F3action.setForeground(java.awt.Color.black);
		F3action.setBounds(134,30,70,16);
		F4action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F4action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F4action.setText("Delete");
		getContentPane().add(F4action);
		F4action.setForeground(java.awt.Color.black);
		F4action.setBounds(196,30,70,16);
		F9action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F9action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F9action.setText("Edit");
		getContentPane().add(F9action);
		F9action.setForeground(java.awt.Color.black);
		F9action.setBounds(320,30,70,16);
		F12action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F12action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F12action.setText("Submit");
		getContentPane().add(F12action);
		F12action.setForeground(java.awt.Color.black);
		F12action.setBounds(382,30,74,18);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Process");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,70,16);
		getContentPane().add(F5sq);
		F5sq.setBounds(283,6,20,20);
		F5lbl.setRequestFocusEnabled(false);
		F5lbl.setText("F9");
		getContentPane().add(F5lbl);
		F5lbl.setForeground(java.awt.Color.black);
		F5lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F5lbl.setBounds(287,6,20,20);
		F5action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F5action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F5action.setText("Exit");
		getContentPane().add(F5action);
		F5action.setForeground(java.awt.Color.black);
		F5action.setBounds(258,30,70,16);
		JLabel2.setText("Payer Name");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(20,130,78,12);
		payerName.setEnabled(false);
		getContentPane().add(payerName);
		payerName.setFont(new Font("DialogInput", Font.PLAIN, 12));
		payerName.setBounds(108,128,350,20);
		JLabel3.setText("Payer ID");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(20,180,78,12);
		JLabel4.setText("Card Type");
		getContentPane().add(JLabel4);
		JLabel4.setBounds(20,206,78,12);
		JLabel5.setText("Status");
		getContentPane().add(JLabel5);
		JLabel5.setBounds(20,232,78,12);
		JLabel6.setText("Additional Information");
		getContentPane().add(JLabel6);
		JLabel6.setBounds(20,270,130,12);
		pndComments.setLineWrap(true);
		pndComments.setWrapStyleWord(true);
		pndComments.setEnabled(false);
		getContentPane().add(pndComments);
		pndComments.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pndComments.setBounds(20,288,440,60);
		pndPayerID.setEnabled(false);
		getContentPane().add(pndPayerID);
		pndPayerID.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pndPayerID.setBounds(108,178,100,20);
		pndCardType.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		pndCardType.setEnabled(false);
		getContentPane().add(pndCardType);
		pndCardType.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pndCardType.setBounds(108,204,30,20);
		pndStatus.setEnabled(false);
		getContentPane().add(pndStatus);
		pndStatus.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pndStatus.setBounds(108,230,100,20);
		payerID.setEnabled(false);
		getContentPane().add(payerID);
		payerID.setFont(new Font("DialogInput", Font.PLAIN, 12));
		payerID.setBounds(360,178,100,20);
		cardType.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		cardType.setEnabled(false);
		getContentPane().add(cardType);
		cardType.setFont(new Font("DialogInput", Font.PLAIN, 12));
		cardType.setBounds(360,204,30,20);
		carrierID.setEnabled(false);
		getContentPane().add(carrierID);
		carrierID.setFont(new Font("DialogInput", Font.PLAIN, 12));
		carrierID.setBounds(360,230,100,20);
		JLabel7.setText("Old Payer ID");
		getContentPane().add(JLabel7);
		JLabel7.setBounds(264,180,78,12);
		JLabel8.setText("Old Card Type");
		getContentPane().add(JLabel8);
		JLabel8.setBounds(264,206,80,12);
		JLabel9.setText("Record No.");
		getContentPane().add(JLabel9);
		JLabel9.setBounds(264,232,80,12);
		recLbl.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		getContentPane().add(recLbl);
		recLbl.setForeground(java.awt.Color.black);
		recLbl.setFont(new Font("Dialog", Font.BOLD, 11));
		recLbl.setBounds(358,358,100,12);
		//}}
	
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		fileName.addKeyListener(aSymKey);
		//}}
	}

	public PayerFileDialog()
	{
		this((Frame)null);
	}

	public PayerFileDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public PayerFileDialog(Login dbLogin)
	{
		this();
		this.dbLogin=dbLogin;
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(100,100);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new PayerFileDialog()).setVisible(true);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted)
			return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets
		Insets insets = getInsets();
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	//{{DECLARE_CONTROLS
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JTextField fileName = new javax.swing.JTextField();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	Square F3sq = new Square();
	javax.swing.JLabel F3lbl = new javax.swing.JLabel();
	Square F4sq = new Square();
	javax.swing.JLabel F4lbl = new javax.swing.JLabel();
	Square F9sq = new Square();
	javax.swing.JLabel F9lbl = new javax.swing.JLabel();
	Square F12sq = new Square();
	javax.swing.JLabel F12lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F3action = new javax.swing.JLabel();
	javax.swing.JLabel F4action = new javax.swing.JLabel();
	javax.swing.JLabel F9action = new javax.swing.JLabel();
	javax.swing.JLabel F12action = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	Square F5sq = new Square();
	javax.swing.JLabel F5lbl = new javax.swing.JLabel();
	javax.swing.JLabel F5action = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JTextField payerName = new javax.swing.JTextField();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel4 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel5 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel6 = new javax.swing.JLabel();
	javax.swing.JTextArea pndComments = new javax.swing.JTextArea();
	javax.swing.JTextField pndPayerID = new javax.swing.JTextField();
	javax.swing.JTextField pndCardType = new javax.swing.JTextField();
	javax.swing.JTextField pndStatus = new javax.swing.JTextField();
	javax.swing.JTextField payerID = new javax.swing.JTextField();
	javax.swing.JTextField cardType = new javax.swing.JTextField();
	javax.swing.JTextField carrierID = new javax.swing.JTextField();
	javax.swing.JLabel JLabel7 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel8 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel9 = new javax.swing.JLabel();
	javax.swing.JLabel recLbl = new javax.swing.JLabel();
	//}}


	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == PayerFileDialog.this)
				PayerFileDialog_windowOpened(event);
		}
	}

	void PayerFileDialog_windowOpened(java.awt.event.WindowEvent event)
	{
        //fileName.setEnabled(true);
        //fileName.requestFocus();
        F5action.requestFocus();
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == fileName)
				fileName_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == PayerFileDialog.this)
				PayerFileDialog_keyPressed(event);
			else if (object == fileName)
				fileName_keyPressed(event);
		}
	}

	void PayerFileDialog_keyPressed(java.awt.event.KeyEvent event)
	{
	    int key = event.getKeyCode();
	    switch (key) {
	        case KeyEvent.VK_F9:
		        this.dispose();
		        break;
            case KeyEvent.VK_F1:	
                disableAllFields();
                clearAllFields();
	            fileName.setEnabled(true);
		        fileName.requestFocus();
		        break;
            case KeyEvent.VK_F10:
                this.setCursor(new java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
                getPending();
                this.setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
                break;
            case KeyEvent.VK_DOWN:
                currNdx++;
                displayRec();
                break;
            case KeyEvent.VK_UP:
                currNdx--;
                displayRec();
                break;
            case KeyEvent.VK_ESCAPE:
                pendingVect = new Vector();
                disableAllFields();
                clearAllFields();
                break;
            case KeyEvent.VK_F2:
                if (!Utils.isNull(pndStatus.getText())) {
                    CarrierRec cRec = (CarrierRec)pendingVect.elementAt(currNdx);
                    if (pndStatus.getText().equals("PENDING")) 
                        cRec.status_pnd="ADD";
                    else if (!pndStatus.getText().equals("EXISTS"))
                        cRec.status_pnd=cRec.orig_status_pnd;
                    pndStatus.setText(cRec.status_pnd);
                }
                break;
            case KeyEvent.VK_F3:
                if (!Utils.isNull(pndStatus.getText())) {
                    CarrierRec cRec = (CarrierRec)pendingVect.elementAt(currNdx);
                    if (pndStatus.getText().equals("EXISTS"))
                        cRec.status_pnd="UPDATE";
                    else if (!pndStatus.getText().equals("PEMDING")) 
                        cRec.status_pnd=cRec.orig_status_pnd;
                    pndStatus.setText(cRec.status_pnd);
                }
                break;
            case KeyEvent.VK_F4:
                if (!Utils.isNull(pndStatus.getText())) {
                    CarrierRec cRec = (CarrierRec)pendingVect.elementAt(currNdx);
                    if (pndStatus.getText().equals("EXISTS")
                    || pndStatus.getText().equals("PENDING"))
                        cRec.status_pnd="DELETE";
                    else 
                        cRec.status_pnd=cRec.orig_status_pnd;
                    pndStatus.setText(cRec.status_pnd);
                }
                break;
            case KeyEvent.VK_F12:
                finalActions();
                break;
		}
	}

	void fileName_keyTyped(java.awt.event.KeyEvent event)
	{
	}

	void fileName_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(fileName,"File Name"))
		        processFile(fileName.getText());
		}
	}
	
	void processFile(String fileName)
	{
        File f2;
        f2 = new File("c:\\","test");
        File f;
        FileInputStream fIN = null;
        FileWriter fOUT = null;
        f = new File(fileName);
        if (f.exists()) {
            long fLen = f.length();
            if (fLen>0) { 
                StringBuffer s = new StringBuffer();
                try {
                    fIN = new FileInputStream(f);
                    fOUT = new FileWriter(f2);
                    for (;;) {
                        int x = fIN.read();
                        if (x==-1) break;
                        char c = (char)x;
                        if (c=='\n') {
                            processPayer(s,fOUT);
                            s = new StringBuffer();
                        }
                        else s.append(c);
                    }
                    fIN.close();
                    fOUT.close();
                }
                catch (Exception e) { 
                    System.out.println(e); 
                    try {
                        fIN.close();
                        fOUT.close();
                    }
                    catch (Exception e2) { System.out.println(e); }
                }
            }	    
        }
		else (new ErrorDialog("Cannot locate file")).setVisible(true); 
		disableAllFields();
		clearAllFields();
	}
	
    void processPayer(StringBuffer s, FileWriter fOUT)
    throws Exception
    {
        StringTokenizer st = new StringTokenizer(s.toString(),"\t",false);
        int element = 0;
        int status = ADD;
        String flag = null;
        String name = null;
        String payer = null;
        String cardType = null;
        String comment = null;
        while (st.hasMoreTokens()) {
            String t = st.nextToken().trim();
            switch (element) {
                case NEW_FLAG:
                  flag=t;
                  if (!flag.equals("?")) {
                    element++;
                    flag="";
                    fOUT.write("flag: "+flag+"\n");
                    //status=false;
                  }
                  else {
                    fOUT.write("flag: "+flag+"\n");
                    break;
                  }
                case NAME:
                  name=t;
                  fOUT.write("name: "+name+"\n");
                  break;
                case PAYER:
                  payer=t;
                  fOUT.write("payer: "+payer+"\n");
                  if (payer.toLowerCase().equals("pilot")
                  || (payer.toLowerCase().equals("call")))
                    status=NO_ADD;
                  break;
                case CARD:
                  cardType=t;
                  fOUT.write("card: "+cardType+"\n");
                  break;
                case ENROLL:
                  if (t.equals("Y")) status=NO_ADD;
                  fOUT.write("status: "+status+"\n");
                  break;
                case SERVICE:
                  if (!t.toLowerCase().equals("claims")) status=NO_ADD;
                  fOUT.write("status: "+status+"\n");
                  break;
                case COMMENT:
                  comment=t;
                  if (!Utils.isNull(t)) { 
                    if (status!=NO_ADD) status=PENDING;
                  }
                  //if (status) addPayer(name,payer,cardType);
                  //else writeToFile(t+"\n");
                  fOUT.write("comment: "+comment+"\n");
                  fOUT.write("status: "+status+"\n");
                  break;
            }
            element++;
        }
        fOUT.write("name/status: "+name+"/"+status+"\n");            
        if (status!=NO_ADD) insertPayer(name.toUpperCase(),cardType.toUpperCase(),
            payer.toUpperCase(),comment,status);
    }
    
    boolean insertPayer(String name, String card_type, 
        String payer_id, String comment, int status)
    {
        boolean exitStatus=true;
        try  {
            CallableStatement cstmt;
	        cstmt=dbConnection.process().prepareCall(
	            "{call pcs.e_payer_insert(?,?,?,?,?)}");
            cstmt.setString(1,name);
            cstmt.setString(2,card_type);
            cstmt.setString(3,payer_id);
            cstmt.setString(4,comment);
            cstmt.setInt(5,status);
            cstmt.executeUpdate();
            try { cstmt.close(); }
            catch (SQLException e) { 
                exitStatus=false; 
            }                
        }
        catch( Exception e ) {
            exitStatus=false;
        }
        return(exitStatus);            
    }        
    
    boolean getPending()
    {
        boolean exitStatus = true;
        try  {
            String SQL = 
                "SELECT name,payer_id,card_type,comment_text,is_accepted \n"+
                "FROM pcs.pending_carriers ORDER BY name \n";
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            pendingVect = new Vector();
            while (rs.next()) {
                CarrierRec cRec = new CarrierRec();
                cRec.name_pnd=rs.getString(1);
                cRec.payer_id_pnd=rs.getString(2);
                cRec.card_type_pnd=rs.getString(3);
                cRec.comment_pnd=rs.getString(4);
                int status = rs.getInt(5);
                if (status==PENDING) cRec.status_pnd="PENDING";
                else if (status==EXISTS) cRec.status_pnd="EXISTS";
                cRec.orig_status_pnd = new String(cRec.status_pnd);
                pendingVect.addElement(cRec);
            }
            if (pendingVect.size()>0) {
                currNdx=0;
                for (int ndx=0; ndx<pendingVect.size(); ndx++) {
                    CarrierRec cRec = (CarrierRec)pendingVect.elementAt(ndx);
                    if (cRec.status_pnd.equals("EXISTS")) {
                        SQL = 
                            "SELECT C.carrier_id,C.payer_id,C.card_type,N.comment_text \n"+
                            "FROM pcs.carriers C, pcs.carrier_comments N \n"+
                            "WHERE C.carrier_id=N.carrier_id(+) and \n"+
                            "   name='"+cRec.name_pnd+"' \n";
                        int carrier_id = 0;
                        String payer_id = null;
                        String card_type = null;
                        String comment_text = null;
                        rs=stmt.executeQuery(SQL);
                        while (rs.next()) {
                            carrier_id=rs.getInt(1);
                            payer_id=rs.getString(2);
                            card_type=rs.getString(3);
                            comment_text=rs.getString(4);
                        }
                        cRec.carrier_id=carrier_id;
                        cRec.payer_id=payer_id;
                        cRec.card_type=card_type;
                        cRec.comment_text=comment_text;
                    }
                }
                displayRec();
            }
            try { stmt.close(); rs.close(); }
            catch (SQLException e) { 
                exitStatus=false; 
            }                
        }
        catch( Exception e ) {
            exitStatus=false;
        }
        return(exitStatus);            
    }
    
    public void disableAllFields()
    {
        fileName.setEnabled(false);
        pndPayerID.setEnabled(false);
        pndCardType.setEnabled(false);
        pndStatus.setEnabled(false);
        payerID.setEnabled(false);
        cardType.setEnabled(false);
        carrierID.setEnabled(false);
        pndComments.setEnabled(false);
        payerName.setEnabled(false);
        F5action.requestFocus();
    }
    
    public void clearAllFields()
    {
        fileName.setText(null);
        pndPayerID.setText(null);
        pndCardType.setText(null);
        pndStatus.setText(null);
        payerID.setText(null);
        cardType.setText(null);
        carrierID.setText(null);
        pndComments.setText(null);
        payerName.setText(null);
        recLbl.setText(null);
        currNdx=-1;
    }
    
    public void displayRec()
    {
        if (pendingVect.size()==0) return;
        if (currNdx<0) currNdx=0;
        else if (currNdx>=pendingVect.size()) currNdx=pendingVect.size()-1;
        CarrierRec cRec = (CarrierRec)pendingVect.elementAt(currNdx);
        payerName.setText(cRec.name_pnd);
        pndPayerID.setText(cRec.payer_id_pnd);
        pndCardType.setText(cRec.card_type_pnd);
        pndStatus.setText(cRec.status_pnd);
        payerID.setText(cRec.payer_id);
        cardType.setText(cRec.card_type);
        if (cRec.carrier_id!=cRec.NULLVAL)
            carrierID.setText(Integer.toString(cRec.carrier_id));
        else carrierID.setText(null);
        pndComments.setText(cRec.comment_pnd);
        recLbl.setText((currNdx+1)+" of "+pendingVect.size());
    }
    
    void finalActions()
    {
        Vector newVect = new Vector();
        for (int ndx=0; ndx<pendingVect.size(); ndx++) {
            CarrierRec cRec = (CarrierRec)pendingVect.elementAt(ndx);
            if (cRec.status_pnd.equals("ADD")) {
                addCarrier(cRec);
                deleteCarrier(cRec);
            }
            else if (cRec.status_pnd.equals("UPDATE")) {
                updateCarrier(cRec);
                deleteCarrier(cRec);
            }
            else if (cRec.status_pnd.equals("DELETE")) {
                deleteCarrier(cRec);
            }
            else newVect.addElement(cRec);
        }
        pendingVect = new Vector();
        pendingVect=newVect;
        if (pendingVect.size()>0) {
            currNdx=0;
            displayRec();
        }
        else {
            disableAllFields();
            clearAllFields();
        }
    }
    
    boolean addCarrier(CarrierRec cRec)
    {
        boolean exitStatus = true;
        try  {
            String SQL = 
                "INSERT INTO pcs.carriers (carrier_id,name,billing_choice, \n"+
                "   e_billing,id_number,tpp,card_type,payer_id) \n"+
                "VALUES (pcs.carriers_seq.nextval,?,126,'Y', \n"+
                "   pcs.pcs_payer_seq.nextval,'ENV',?,?) \n";
            PreparedStatement pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setString(1,cRec.name_pnd);
            pstmt.setString(2,cRec.card_type_pnd);
            pstmt.setString(3,cRec.payer_id_pnd);
            pstmt.executeUpdate();
            if (!Utils.isNull(cRec.comment_pnd)) {
                SQL = 
                    "INSERT INTO pcs.carrier_comments (carrier_id,comment_text) \n"+
                    "VALUES (pcs.carriers_seq.currval,?) \n";
                pstmt=dbConnection.process().prepareStatement(SQL);
                pstmt.setString(1,cRec.comment_pnd);
                pstmt.executeUpdate();
            }
            try { pstmt.close(); }
            catch (SQLException e) { 
                exitStatus=false; 
            }                
        }
        catch( Exception e ) {
            exitStatus=false;
        }
        return(exitStatus);            
    }

    boolean updateCarrier(CarrierRec cRec)
    {
        boolean exitStatus = true;
        try  {
            String SQL = 
                "UPDATE pcs.carriers SET \n"+
                "   payer_id = ?, \n"+
                "   card_type = ?, \n"+
                "   e_billing = 'Y', \n"+
                "   tpp = 'ENV' \n"+
                "WHERE carrier_id = ? \n";
            PreparedStatement pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setString(1,cRec.payer_id_pnd);
            pstmt.setString(2,cRec.card_type_pnd);
            pstmt.setInt(3,cRec.carrier_id);
            pstmt.executeUpdate();
            if (!Utils.isNull(cRec.comment_pnd)) {
                if (Utils.isNull(cRec.comment_text)) {
                    SQL = 
                        "INSERT INTO pcs.carrier_comments (carrier_id,comment_text) \n"+
                        "VALUES (pcs.carriers_seq.currval,?) \n";
                }
                else {
                    SQL = 
                        "UPDATE pcs.carrier_comments SET \n"+
                        "   comment_text = ? \n"+
                        "WHERE carrier_id="+cRec.carrier_id+" \n";
                }
                pstmt=dbConnection.process().prepareStatement(SQL);
                pstmt.setString(1,cRec.comment_pnd);
                pstmt.executeUpdate();
            }
            try { pstmt.close(); }
            catch (SQLException e) { 
                exitStatus=false; 
            }                
        }
        catch( Exception e ) {
            exitStatus=false;
        }
        return(exitStatus);            
    }

    boolean deleteCarrier(CarrierRec cRec)
    {
        boolean exitStatus = true;
        try  {
            String SQL = 
                "DELETE FROM pcs.pending_carriers \n"+
                "WHERE name = ? and payer_id = ? \n";
            PreparedStatement pstmt = dbConnection.process().prepareStatement(SQL);
            pstmt.setString(1,cRec.name_pnd);
            pstmt.setString(2,cRec.payer_id_pnd);
            pstmt.executeUpdate();
            try { pstmt.close(); }
            catch (SQLException e) { 
                exitStatus=false; 
            }                
        }
        catch( Exception e ) {
            exitStatus=false;
        }
        return(exitStatus);            
    }
    
	
}
