package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       BuildClaimDialog.java
    Created By: John Cardella, Software Engineer
    
    Function:   Screen for building electronic claim files
    to be sent to a third pary processor.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Frame;
import java.awt.Insets;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.commons.io.FileSystemUtils;
import org.apache.commons.io.IOUtils;

import com.pacytology.pcs.io.FileTransfer;
import com.pacytology.pcs.ui.PcsDialog;
import com.pacytology.pcs.ui.PcsFrame;

public class BuildClaimDialog extends PcsDialog
{

	
	Login dbLogin;
    TppRec[] tppRec;
    int MAX_TPPS=0;
    boolean fileBuilt=false;
    LogFile log;
    
	public BuildClaimDialog(PcsFrame parent)
	{
		super();
		
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Build Claim File");
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(323,168);
		setVisible(false);
		getContentPane().add(tpps);
		tpps.setBackground(new java.awt.Color(204,204,204));
		tpps.setForeground(java.awt.Color.black);
		tpps.setFont(new Font("Dialog", Font.BOLD, 12));
		tpps.setBounds(20,32,282,20);
		JLabel11.setText("Electronic Claims Processor");
		getContentPane().add(JLabel11);
		JLabel11.setBounds(20,16,180,14);
		JLabel1.setText("Type of Claims:");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(20,58,100,14);
		claimTypeLbl.setText("Electronic Claims Processor");
		getContentPane().add(claimTypeLbl);
		claimTypeLbl.setForeground(java.awt.Color.black);
		claimTypeLbl.setBounds(124,58,180,14);
		buildButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		buildButton.setText("Build File");
		buildButton.setActionCommand("Build File");
		getContentPane().add(buildButton);
		buildButton.setBackground(new java.awt.Color(204,204,204));
		buildButton.setForeground(java.awt.Color.black);
		buildButton.setFont(new Font("Dialog", Font.BOLD, 12));
		buildButton.setBounds(20,120,84,22);
		cancelButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		cancelButton.setText("Cancel");
		cancelButton.setActionCommand("Cancel");
		getContentPane().add(cancelButton);
		cancelButton.setBackground(new java.awt.Color(204,204,204));
		cancelButton.setForeground(java.awt.Color.black);
		cancelButton.setFont(new Font("Dialog", Font.BOLD, 12));
		cancelButton.setBounds(212,120,84,22);
		JLabel2.setText("File Name:");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(20,74,100,14);
		getContentPane().add(fnameLbl);
		fnameLbl.setForeground(java.awt.Color.black);
		fnameLbl.setBounds(124,74,180,14);
		doneButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		doneButton.setText("Done");
		doneButton.setActionCommand("Done");
		getContentPane().add(doneButton);
		doneButton.setBackground(new java.awt.Color(204,204,204));
		doneButton.setForeground(java.awt.Color.black);
		doneButton.setFont(new Font("Dialog", Font.BOLD, 12));
		doneButton.setBounds(116,120,84,22);
		msgLabel.setOpaque(true);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setBounds(24,146,240,14);
		isResend.setHorizontalTextPosition(javax.swing.SwingConstants.LEFT);
		isResend.setText("Rebuild Batch");
		getContentPane().add(isResend);
		isResend.setBounds(20,94,100,20);
		batchNumber.setEnabled(false);
		getContentPane().add(batchNumber);
		batchNumber.setFont(new Font("DialogInput", Font.PLAIN, 12));
		batchNumber.setBounds(120,94,80,20);
		isTestFile.setHorizontalTextPosition(javax.swing.SwingConstants.LEFT);
		isTestFile.setText("Test File");
		getContentPane().add(isTestFile);
		isTestFile.setBounds(230,94,80,20);
		//}}
		
		//setBounds(100,100,323,140);
		
		//{{REGISTER_LISTENERS
		SymAction lSymAction = new SymAction();
		buildButton.addActionListener(lSymAction);
		cancelButton.addActionListener(lSymAction);
		tpps.addActionListener(lSymAction);
		doneButton.addActionListener(lSymAction);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		isResend.addActionListener(lSymAction);
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		//}}
	}

	public BuildClaimDialog()
	{
		this((PcsFrame)null);
	}

	public BuildClaimDialog(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public BuildClaimDialog(Frame parent,Login dbLogin) {
	    this();
	    this.dbLogin=dbLogin;
        this.log = new LogFile(
            dbLogin.logPath,"BuildClaimDialog",dbLogin.dateToday,dbLogin.userName);
	    this.getTPPS();
	    for (int i=0;i<this.MAX_TPPS;i++) {
	        this.tpps.insertItemAt(tppRec[i].tpp+"  "+tppRec[i].tpp_name,i);
        }
        Utils.setColors(this.getContentPane());
        (this.getContentPane()).setBackground((Color.red).darker());
        claimTypeLbl.setForeground(Color.white);
        fnameLbl.setForeground(Color.white);
        msgLabel.setForeground((Color.green).brighter());
        msgLabel.setBackground((Color.red).darker());
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(100,100);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new BuildClaimDialog()).setVisible(true);
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
	javax.swing.JComboBox tpps = new javax.swing.JComboBox();
	javax.swing.JLabel JLabel11 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel claimTypeLbl = new javax.swing.JLabel();
	javax.swing.JButton buildButton = new javax.swing.JButton();
	javax.swing.JButton cancelButton = new javax.swing.JButton();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JLabel fnameLbl = new javax.swing.JLabel();
	javax.swing.JButton doneButton = new javax.swing.JButton();
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	javax.swing.JCheckBox isResend = new javax.swing.JCheckBox();
	javax.swing.JTextField batchNumber = new javax.swing.JTextField();
	javax.swing.JCheckBox isTestFile = new javax.swing.JCheckBox();
	//}}

    void getTPPS() {
        try  {
            String query = "SELECT * from pcs.tpps";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            tppRec = new TppRec[5];
            tppRec[0] = new TppRec();
            tppRec[0].tpp="MAKE SELECTION";
            tppRec[0].tpp_name="   ";
            tppRec[0].claim_format="   ";
            tppRec[0].claim_type="   ";
            int rowsReturned=1;
            while (rs.next()) { 
                tppRec[rowsReturned] = new TppRec();
                tppRec[rowsReturned].tpp=rs.getString(1);
                tppRec[rowsReturned].tpp_name=rs.getString(2);
                tppRec[rowsReturned].phone=rs.getString(3);
                tppRec[rowsReturned].file_name=rs.getString(4);
                tppRec[rowsReturned].dir_name=rs.getString(5);
                tppRec[rowsReturned].claim_format=rs.getString(6);
                tppRec[rowsReturned].claim_type=rs.getString(7);
                rowsReturned++;
            }       
            MAX_TPPS=rowsReturned;
        }
        catch( Exception e ) { log.write(e); }
    }

    public class TppRec {
        String tpp;
        String tpp_name;
        String phone;
        String file_name;
        String dir_name;
        String claim_format;
        String claim_type;
        public TppRec() { this.init(); }   
        void init() {
            tpp=null;
            tpp_name=null;
            phone=null;
            file_name=null;
            dir_name=null;
            claim_format=null;
            claim_type=null;
        }
    }

	class SymAction implements java.awt.event.ActionListener
	{
		public void actionPerformed(java.awt.event.ActionEvent event)
		{
			Object object = event.getSource();
			if (object == buildButton)
				buildButton_actionPerformed(event);
			else if (object == cancelButton)
				cancelButton_actionPerformed(event);
			else if (object == tpps)
				tpps_actionPerformed(event);
			else if (object == doneButton)
				doneButton_actionPerformed(event);
			else if (object == isResend)
				isResend_actionPerformed(event);
		}
	}

	void buildButton_actionPerformed(java.awt.event.ActionEvent event)
	{
	    int ndx = tpps.getSelectedIndex();
	    if (ndx==0) Utils.createErrMsg("Claims processor not selected.");
		else buildActions(ndx);
	}

	void cancelButton_actionPerformed(java.awt.event.ActionEvent event)
	{
		try { if (!fileBuilt) closingActions(); } 
		catch (Exception e) { log.write(e); }
	}
	
	void tpps_actionPerformed(java.awt.event.ActionEvent event)
	{
		int ndx = tpps.getSelectedIndex();
		claimTypeLbl.setText(tppRec[ndx].claim_type);
	}
	
	void buildActions(int ndx) {
	    if (ndx==0) {
	        Utils.createErrMsg("No TPP selected");
	        return;
	    }
	    String fileType = "P";
	    if (isTestFile.isSelected()) fileType="T";
	    int batch = 0;
	    if (isResend.isSelected())
	        batch=(int)Integer.parseInt(batchNumber.getText());
	    if (tppRec[ndx].tpp.equals("ENV")) buildHCFA1500(ndx);
	    else if (tppRec[ndx].tpp.equals("DAS")) buildDAS(ndx,fileType,batch);
	    else if (tppRec[ndx].tpp.equals("HGS")) buildHGS(ndx,fileType,batch);
	    batchNumber.setEnabled(false);
	}

    void buildHCFA1500(int ndx) {
        this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
        String fName = null;
        try  {
            CallableStatement cstmt;
	        cstmt=DbConnection.process().prepareCall(
	            "{call pcs.build_1500_claim_forms(?,?,?)}");
            cstmt.setString(1,tppRec[ndx].dir_name);
            cstmt.setString(2,tppRec[ndx].file_name);
            cstmt.setString(3,tppRec[ndx].tpp);
            cstmt.executeUpdate();
            String query=
                "SELECT max(batch_number) FROM pcs.claim_batches \n"+
                "WHERE tpp='"+tppRec[ndx].tpp+"' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            int batchClaimID=0;
            while (rs.next()) batchClaimID=rs.getInt(1);   
            File f = FileTransfer.getFile(Utils.TMP_DIR, Utils.SERVER_DIR, "env_clm");
            fName = "env"+batchClaimID;
            try { 
            	FileTransfer.sendFile(f, Utils.SERVER_DIR + fName);
            }
            catch (SecurityException e) { log.write(e); }
            fnameLbl.setText(fName);
            fileBuilt=true;
        }
        catch (Exception e) { log.write(e+" build HCFA1500"); }
        log.write("HCFA 1500 FILE: "+fName);
        this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
    }
    
    void buildDAS(int ndx, String fileType, int batch) {
        this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
        String fName = null;
        String SQL = null;
        int nClaims = 0;
        try  {
            if (batch>0) {
                SQL =
                    "SELECT number_of_claims FROM pcs.claim_batches \n"+
                    "WHERE batch_number = ? and tpp = ? \n";
                PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
                pstmt.setInt(1,batch);
                pstmt.setString(2,tppRec[ndx].tpp);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) { nClaims = rs.getInt(1); }
                if (nClaims==0) {
                    Utils.createErrMsg(
                        "Batch #"+batch+" does not exist for "+tppRec[ndx].tpp);
                }
                else {
                        SQL =
                            "INSERT INTO pcs.billing_queue \n"+
                            "   (lab_number,billing_route,datestamp,rebilling) \n"+
                            "SELECT C.lab_number,'RSN',SysDate,L.rebilling \n"+
                            "FROM pcs.lab_claims C, pcs.lab_billings L \n"+
                            "WHERE C.lab_number = L.lab_number \n"+
                            "AND C.batch_number = ? \n";
                        pstmt = DbConnection.process().prepareStatement(SQL);
                        pstmt.setInt(1,batch);
                        nClaims=pstmt.executeUpdate();
                }
                try { pstmt.close(); } 
                catch (SQLException e) { log.write(e); }
                catch (Exception e) { log.write(e); }
                if (nClaims==0) { return; }
            }
            else {
                SQL =
                    "SELECT count(*) FROM pcs.billing_queue \n"+
                    "WHERE billing_route = ? \n";
                PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
                pstmt.setString(1,tppRec[ndx].tpp);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) { nClaims = rs.getInt(1); }
                if (nClaims==0) {
                    Utils.createErrMsg(
                        "No claims to process for "+tppRec[ndx].tpp);
                    
                    return;
                }
            }

            String bRoute = tppRec[ndx].tpp;
            if (batch>0) bRoute="RSN";
            
            CallableStatement cstmt;
	        cstmt=DbConnection.process().prepareCall(
	            "{call pcs.build_bs_x12_file(?,?,?,?,?)}");
            cstmt.setString(1,tppRec[ndx].dir_name);
            cstmt.setString(2,tppRec[ndx].file_name);
            cstmt.setString(3,bRoute);
            cstmt.setInt(4,batch);
            cstmt.setString(5,fileType);
            cstmt.executeUpdate();
            SQL =
                "SELECT file_name FROM pcs.tpps \n"+
                "WHERE tpp = '"+tppRec[ndx].tpp+"' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { fName=rs.getString(1); }
            String extn = "das";
            
            stripReturns(fName, extn);

            fnameLbl.setText(fName+extn);
            fileBuilt=true;
        }
        catch (Exception e) { 
        	log.write(e+" build DAS"); 
        	}
        log.write("CLAIM FILE: "+fName+".x12");
        this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
    }

	private void stripReturns(String fName, String extn)
			throws FileNotFoundException, IOException {
		File f = FileTransfer.getFile(Utils.TMP_DIR, Utils.SERVER_DIR, fName);
		File fn = stripReturns(f,extn);
		
		InputStream fileInputStream = new FileInputStream(fn);
		byte[] fileBytes = IOUtils.toByteArray(fileInputStream);
		FileTransfer.sendFile(fileBytes, Utils.SERVER_DIR + fName + "." + extn);
	}
	private File stripReturns(File f, String extn)
	{

        long fLen = f.length();
        File nf = null;
        if (fLen>0) {
            try {
                String newFName=f.getName()+"."+extn;
                nf = new File(Utils.TMP_DIR,newFName);
                FileReader fr = new FileReader(f);
                FileWriter fw = new FileWriter(nf);
                for (;;) {
                    int c = fr.read();
                    if (c==(-1)) break;
                    if ((char)c!='\n' && (char)c!='\r') { 
                    	fw.write((int)c);
                    }
                    else {
                    	System.out.println("We found a line ending");
                    }
                 
                }
                fr.close();
                fw.close();

            }
            catch (FileNotFoundException e) { log.write(e); return null; }
            catch (IOException e) { log.write(e); return null ; }
        }
		return nf;
	}
    void buildHGS(int ndx, String fileType, int batch) {
    	this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
        String fName = null;
        String SQL = null;
        int nClaims = 0;
        try  {
            if (batch>0) {
                SQL =
                    "SELECT number_of_claims FROM pcs.claim_batches \n"+
                    "WHERE batch_number = ? and tpp = ? \n";
                PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
                pstmt.setInt(1,batch);
                pstmt.setString(2,tppRec[ndx].tpp);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) { nClaims = rs.getInt(1); }
                if (nClaims==0) {
                    Utils.createErrMsg(
                        "Batch #"+batch+" does not exist for "+tppRec[ndx].tpp);
                }
                else {
                        SQL =
                            "INSERT INTO pcs.billing_queue \n"+
                            "   (lab_number,billing_route,datestamp,rebilling) \n"+
                            "SELECT C.lab_number,'RSN',SysDate,L.rebilling \n"+
                            "FROM pcs.lab_claims C, pcs.lab_billings L \n"+
                            "WHERE C.lab_number = L.lab_number \n"+
                            "AND C.batch_number = ? \n";
                        pstmt = DbConnection.process().prepareStatement(SQL);
                        pstmt.setInt(1,batch);
                        nClaims=pstmt.executeUpdate();
                    }
            }
            else {
                SQL =
                    "SELECT count(*) FROM pcs.billing_queue \n"+
                    "WHERE billing_route = ? \n";
                PreparedStatement pstmt = DbConnection.process().prepareStatement(SQL);
                pstmt.setString(1,tppRec[ndx].tpp);
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) { nClaims = rs.getInt(1); }
                if (nClaims==0) {
                    Utils.createErrMsg(
                        "No claims to process for "+tppRec[ndx].tpp);
                    this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
                    return;
                }
            }

            String bRoute = tppRec[ndx].tpp;
            if (batch>0) bRoute="RSN";
            
            CallableStatement cstmt;
	        cstmt=DbConnection.process().prepareCall(
	            "{call pcs.build_med_x12_file(?,?,?,?,?)}");
            cstmt.setString(1,tppRec[ndx].dir_name);
            cstmt.setString(2,tppRec[ndx].file_name);
            cstmt.setString(3,bRoute);
            cstmt.setInt(4,batch);
            cstmt.setString(5,fileType);
            cstmt.executeUpdate();
            SQL =
                "SELECT file_name FROM pcs.tpps \n"+
                "WHERE tpp = '"+tppRec[ndx].tpp+"' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            while (rs.next()) { fName=rs.getString(1); }
            String extn = "hgs";
            stripReturns(fName, extn);
            fnameLbl.setText(fName+extn);
            fileBuilt=true;
        }
        catch (Exception e) { log.write(e+" build HGS"); }
        log.write("CLAIM FILE: "+fName+".hgs");
        this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
    }
    
    void buildPA_DPA() {    }

	void doneButton_actionPerformed(java.awt.event.ActionEvent event)
	{
		try { if (fileBuilt) closingActions(); } 
		catch (Exception e) { log.write(e); }
	}
	
	
	
	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == BuildClaimDialog.this)
				BuildClaimDialog_windowClosing(event);
		}
	}

	void BuildClaimDialog_windowClosing(java.awt.event.WindowEvent event)
	{
		closingActions();
	}
	
	void closingActions()
	{
	    log.stop();
	    this.dispose();
	}

	void isResend_actionPerformed(java.awt.event.ActionEvent event)
	{
		if (isResend.isSelected()) {
		    batchNumber.setEnabled(true);
		    batchNumber.requestFocus();
		}
		else {
		    batchNumber.setEnabled(false);
		    batchNumber.setText(null);
		}
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == BuildClaimDialog.this)
				BuildClaimDialog_keyPressed(event);
		}
	}

	void BuildClaimDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		int key = event.getKeyCode();
		switch (key) {
		    case KeyEvent.VK_F9:
		        closingActions();
		        break;
		    case KeyEvent.VK_ESCAPE:
		        tpps.setSelectedIndex(0);
		        claimTypeLbl.setText(null);
		        fnameLbl.setText(null);
		        isResend.setSelected(false);
		        isTestFile.setSelected(false);
		        batchNumber.setText(null);
		        batchNumber.setEnabled(false);
		        claimTypeLbl.requestFocus();
		        break;
		}
	}

	@Override
	public void queryActions() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void addActions() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void updateActions() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void finalActions() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void resetActions() {
		// TODO Auto-generated method stub
		
	}
	
}


