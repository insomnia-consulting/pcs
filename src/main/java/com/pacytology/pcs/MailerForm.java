package com.pacytology.pcs;

/*
		A basic implementation of the JFrame class.
*/

import java.awt.*;
import javax.swing.*;
import java.sql.*;
import java.util.Vector;

public class MailerForm extends javax.swing.JFrame
{
    
    Login dbLogin;
    Connection dbProc;
    Vector addrVect;
    boolean saveFlag;
    
	public MailerForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Addresses");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(472,422);
		setVisible(false);
		pNameLbl.setText("Name");
		getContentPane().add(pNameLbl);
		pNameLbl.setBounds(24,24,48,12);
		getContentPane().add(pName);
		pName.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pName.setBounds(96,24,356,20);
		pAddressLbl.setText("Address");
		getContentPane().add(pAddressLbl);
		pAddressLbl.setBounds(24,48,48,12);
		getContentPane().add(pAddress1);
		pAddress1.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pAddress1.setBounds(96,48,356,20);
		getContentPane().add(pAddress2);
		pAddress2.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pAddress2.setBounds(96,72,356,20);
		pZipLbl.setText("Zip");
		getContentPane().add(pZipLbl);
		pZipLbl.setBounds(24,96,24,14);
		getContentPane().add(pZip);
		pZip.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pZip.setBounds(96,96,80,20);
		pCityLbl.setText("City");
		getContentPane().add(pCityLbl);
		pCityLbl.setBounds(190,96,38,14);
		getContentPane().add(pCity);
		pCity.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pCity.setBounds(216,96,165,20);
		pStateLbl.setText("State");
		getContentPane().add(pStateLbl);
		pStateLbl.setBounds(396,96,30,14);
		getContentPane().add(pState);
		pState.setFont(new Font("DialogInput", Font.PLAIN, 12));
		pState.setBounds(428,96,24,20);
		addrPane.setOpaque(true);
		getContentPane().add(addrPane);
		addrPane.setBounds(24,126,430,282);
		addrPane.getViewport().add(addrList);
		addrList.setFont(new Font("DialogInput", Font.PLAIN, 12));
		addrList.setBounds(0,0,427,279);
		confirmDelete.setMessageType(javax.swing.JOptionPane.QUESTION_MESSAGE);
		confirmDelete.setOptionType(javax.swing.JOptionPane.YES_NO_OPTION);
		//$$ confirmDelete.move(0,423);
		//$$ JOptionPane1.move(0,423);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		pName.addKeyListener(aSymKey);
		pAddress1.addKeyListener(aSymKey);
		pAddress2.addKeyListener(aSymKey);
		pZip.addKeyListener(aSymKey);
		pCity.addKeyListener(aSymKey);
		pState.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		this.addKeyListener(aSymKey);
		//}}
	}

	public MailerForm(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
    public MailerForm(Login dbLogin)
    {
        this();
        saveFlag=false;
        this.dbLogin=dbLogin;
        try {
            Class.forName(dbLogin.driver);
            this.dbProc=DriverManager.getConnection
                                (dbLogin.URL,
                                 dbLogin.userName,
                                 dbLogin.userPassword);
        }
        catch (SQLException e) {  }
        catch (Exception e) {  }
        addrVect = new Vector();
        Utils.setColors(this.getContentPane());
        getData();
    }

	public void setVisible(boolean b)
	{
		if (b) setLocation(50,50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new MailerForm()).setVisible(true);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted)
			return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets and menu bar
		Insets insets = getInsets();
		javax.swing.JMenuBar menuBar = getRootPane().getJMenuBar();
		int menuBarHeight = 0;
		if (menuBar != null)
			menuBarHeight = menuBar.getPreferredSize().height;
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height + menuBarHeight);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	//{{DECLARE_CONTROLS
	javax.swing.JLabel pNameLbl = new javax.swing.JLabel();
	javax.swing.JTextField pName = new javax.swing.JTextField();
	javax.swing.JLabel pAddressLbl = new javax.swing.JLabel();
	javax.swing.JTextField pAddress1 = new javax.swing.JTextField();
	javax.swing.JTextField pAddress2 = new javax.swing.JTextField();
	javax.swing.JLabel pZipLbl = new javax.swing.JLabel();
	javax.swing.JTextField pZip = new javax.swing.JTextField();
	javax.swing.JLabel pCityLbl = new javax.swing.JLabel();
	javax.swing.JTextField pCity = new javax.swing.JTextField();
	javax.swing.JLabel pStateLbl = new javax.swing.JLabel();
	javax.swing.JTextField pState = new javax.swing.JTextField();
	javax.swing.JScrollPane addrPane = new javax.swing.JScrollPane();
	javax.swing.JList addrList = new javax.swing.JList();
	javax.swing.JOptionPane confirmDelete = new javax.swing.JOptionPane();
	//}}

	//{{DECLARE_MENUS
	//}}


	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == pZip)
				pZip_keyTyped(event);
			else if (object == pState)
				pState_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == pName)
				pName_keyPressed(event);
			else if (object == pAddress1)
				pAddress1_keyPressed(event);
			else if (object == pAddress2)
				pAddress2_keyPressed(event);
			else if (object == pZip)
				pZip_keyPressed(event);
			else if (object == pCity)
				pCity_keyPressed(event);
			else if (object == pState)
				pState_keyPressed(event);
			else if (object == MailerForm.this)
				MailerForm_keyPressed(event);
		}
	}

	void pName_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(pName,"Name")) pName.transferFocus();
		}
	}

	void pAddress1_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(pAddress1,"Address")) pAddress1.transferFocus();
		}
	}

	void pAddress2_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
		    pAddress2.transferFocus();
		}
	}

	void pZip_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_ENTER) {
	        if (Utils.required(pZip,"Zip Code")) {
                if (!Utils.isNull(pZip.getText()) &&
                    Utils.isNull(pCity.getText()) &&
                    Utils.isNull(pState.getText())) { 
                    if (queryZip(pZip.getText())) insertData();
                    else pZip.transferFocus();
                }
            }
        }
	}

	void pCity_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(pCity,"City")) pCity.transferFocus();
		}
	}

	void pState_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(pState,"State")) {
		        insertData();
		    }
		}
	}
	
	void insertData()
	{
	    Address a = new Address(pName.getText(),pAddress1.getText(),
	        pAddress2.getText(), pCity.getText(), pState.getText(), pZip.getText());    
        Vector tVect = new Vector();
        tVect.addElement(a);
        for (int i=0; i<addrVect.size(); i++) {
            Address b = (Address)addrVect.elementAt(i);
            tVect.addElement(b);
        }
        addrVect=tVect;
        tVect = new Vector();
        for (int i=0; i<addrVect.size(); i++) {
            Address b = (Address)addrVect.elementAt(i);
            String s = b.name+", "+b.addr1;
            if (!Utils.isNull(b.addr2)) s+=", "+b.addr2;
            s+=", "+b.city+", "+b.state+" "+b.zip;
            tVect.addElement(s);
        }
        addrList.removeAll();
        addrList.setListData(tVect);
        addrList.revalidate();
        addrList.repaint();
        pName.setText(null);
        pAddress1.setText(null);
        pAddress2.setText(null);
        pCity.setText(null);
        pState.setText(null);
        pZip.setText(null);
        pName.requestFocus();
	}
	
	void getData()
	{
        try  {
            String SQL = 
                "SELECT * FROM pcs.mailer ORDER BY name \n";
            Statement stmt = dbProc.createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            addrVect = new Vector();
            while (rs.next()) {
                Address a = new Address();
                a.name=rs.getString(1);
                a.addr1=rs.getString(2);
                a.addr2=rs.getString(3);
                a.city=rs.getString(4);
                a.state=rs.getString(5);
                a.zip=rs.getString(6);
                addrVect.addElement(a);
            }       
            try { rs.close(); stmt.close(); }
            catch (SQLException e) {  }                
        }
        catch(SQLException e) {  }
        catch(Exception e) {  }
        if (addrVect.size()>0) {
            Vector tVect = new Vector();
            for (int i=0; i<addrVect.size(); i++) {
                Address b = (Address)addrVect.elementAt(i);
                String s = b.name+", "+b.addr1;
                if (!Utils.isNull(b.addr2)) s+=", "+b.addr2;
                s+=", "+b.city+", "+b.state+" "+b.zip;
                tVect.addElement(s);
            }
            addrList.removeAll();
            addrList.setListData(tVect);
            addrList.revalidate();
            addrList.repaint();
        }
	}
	
    public boolean queryZip(String zip5) {
        boolean exitStatus=true;
        try  {
            String SQL = 
                "SELECT initcap(lower(city)),state FROM pcs.zipcodes WHERE zip='"+zip5+"' \n";
            Statement stmt = dbProc.createStatement();
            ResultSet rs = stmt.executeQuery(SQL);
            int rcnt=0;
            while (rs.next()) {
                pCity.setText(rs.getString(1));
                pState.setText(rs.getString(2));
                rcnt++;
            }       
            if (rcnt==0) { 
                pCity.requestFocus();
                exitStatus=false; 
            }
            try { rs.close(); stmt.close(); }
            catch (SQLException e) { exitStatus=false;  }                
        }
        catch(SQLException e) { exitStatus=false; }
        catch(Exception e) { exitStatus=false; }
        return(exitStatus);            
    }

	void pZip_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,5);
	}

	void pState_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event,2);
	}
	
	private class Address
	{
	    String name;
	    String addr1;
	    String addr2;
	    String city;
	    String state;
	    String zip;
	    
	    public Address() { }
	    public Address(String name, String addr1, String addr2,
	        String city, String state, String zip)
        {   
            this();
            this.name=name;
            this.addr1=addr1;
            this.addr2=addr2;
            this.city=city;
            this.state=state;
            this.zip=zip;
        }
	}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == MailerForm.this)
				MailerForm_windowClosing(event);
		}

		public void windowActivated(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == MailerForm.this)
				MailerForm_windowActivated(event);
		}
	}

	void MailerForm_windowActivated(java.awt.event.WindowEvent event)
	{
		pName.requestFocus();
	}

	void MailerForm_windowClosing(java.awt.event.WindowEvent event)
	{
	    if (!saveFlag) saveData();
        try { dbProc.close(); }
	    catch (Exception e) { }
	    this.dispose();
	}

	void MailerForm_keyPressed(java.awt.event.KeyEvent event)
	{
	    if (event.getKeyCode()==event.VK_F12) {
	        saveData();
	        saveFlag=true;
	        try { dbProc.close(); }
	        catch (Exception e) { }
	        this.dispose();
	    }
	    else if (event.getKeyCode()==event.VK_F9) {
	        if (event.isControlDown()) {
		        int rv = confirmDelete.showConfirmDialog(this,
		            "All data will be lost!. \nDelete all addresses?",
		            "Mailer Addresses",confirmDelete.YES_NO_OPTION,
		            confirmDelete.QUESTION_MESSAGE);
		        if (rv==confirmDelete.YES_OPTION) {
                    deleteData();
	                saveFlag=true;
	            }
	            try { dbProc.close(); }
	            catch (Exception e) { }
	        }
            this.dispose();
	    }
		else if (event.getKeyCode()==event.VK_F11) {
		    if (addrVect.size()>0) {
		        Vector tVect = new Vector();
		        for (int i=1; i<addrVect.size(); i++) {
		            Address b = (Address)addrVect.elementAt(i);
		            tVect.addElement(b);
		        }
		        addrVect=tVect;
                if (addrVect.size()>0) {
                    tVect = new Vector();
                    for (int i=0; i<addrVect.size(); i++) {
                        Address b = (Address)addrVect.elementAt(i);
                        String s = b.name+", "+b.addr1;
                        if (!Utils.isNull(b.addr2)) s+=", "+b.addr2;
                        s+=", "+b.city+", "+b.state+" "+b.zip;
                        tVect.addElement(s);
                    }
                    addrList.removeAll();
                    addrList.setListData(tVect);
                    addrList.revalidate();
                    addrList.repaint();
                }
		    }
		}
	}
	
	void saveData()
	{
        try  {
            String SQL = 
                "INSERT INTO pcs.mailer (name,address1,address2,city,state,zip) \n"+
                " VALUES (?,?,?,?,?,?) \n";
            Statement stmt = dbProc.createStatement();
            stmt.executeUpdate("delete from pcs.mailer");
            PreparedStatement pstmt = null; 
            for (int i=0; i<addrVect.size(); i++) {
                Address a = (Address)addrVect.elementAt(i);
                pstmt = dbProc.prepareStatement(SQL);
                pstmt.setString(1,a.name);
                pstmt.setString(2,a.addr1);
                pstmt.setString(3,a.addr2);
                pstmt.setString(4,a.city);
                pstmt.setString(5,a.state);
                pstmt.setString(6,a.zip);
                pstmt.executeUpdate();
            }
            try { pstmt.close(); stmt.close(); }
            catch (SQLException e) {  }                
        }
        catch(SQLException e) {  }
        catch(Exception e) {  }
	}
	
	void deleteData()
	{
        try  {
            Statement stmt = dbProc.createStatement();
            stmt.executeUpdate("delete from pcs.mailer");
            try { stmt.close(); }
            catch (SQLException e) {  }                
        }
        catch(SQLException e) {  }
        catch(Exception e) {  }
	}
	
}