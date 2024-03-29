package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       DiagCodeForm.java
    Created By: John Cardella, Software Engineer
    
    Function:   Used to maintain ICD9 diagnosis codes.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import java.awt.event.ActionEvent;

import javax.swing.*;

import com.pacytology.pcs.actions.PcsActionMap;
import com.pacytology.pcs.ui.PcsFrame;
import com.pacytology.pcs.ui.Square;
import java.sql.*;
import java.util.Vector;

public class DiagCodeForm extends PcsFrame
{
    public Login dbLogin;
    public int MAX_DIAG_CODES=0;
    public Vector diagCodeVect = new Vector();
    /*
    final int IDLE=100;
    final int QUERY=101;
    final int ADD=102;
    final int UPDATE=103;
    final int DELETE=104;
    */
    public int currMode=Lab.IDLE;    
    final int CODES_PER_SCREEN=15;
    public int rowID=1;
    public FunctionKeyControl fKeys = new FunctionKeyControl();
    public LogFile log;
    
	public DiagCodeForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Diagnosis Code Maintenance");
		setResizable(false);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(454,426);
		setVisible(false);
		codePane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		codePane.setOpaque(true);
		codePane.setEnabled(false);
		getContentPane().add(codePane);
		codePane.setBounds(30,150,90,258);
		codeList.setEnabled(false);
		codePane.getViewport().add(codeList);
		codeList.setFont(new Font("DialogInput", Font.PLAIN, 12));
		codeList.setBounds(0,0,87,255);
		descPane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		descPane.setOpaque(true);
		descPane.setEnabled(false);
		getContentPane().add(descPane);
		descPane.setBounds(128,150,306,258);
		descList.setEnabled(false);
		descPane.getViewport().add(descList);
		descList.setFont(new Font("DialogInput", Font.PLAIN, 12));
		descList.setBounds(0,0,303,255);
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
		F9sq.setBounds(283,6,20,20);
		F9lbl.setRequestFocusEnabled(false);
		F9lbl.setText("F9");
		getContentPane().add(F9lbl);
		F9lbl.setForeground(java.awt.Color.black);
		F9lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F9lbl.setBounds(287,6,20,20);
		getContentPane().add(F12sq);
		F12sq.setBounds(345,6,20,20);
		F12lbl.setRequestFocusEnabled(false);
		F12lbl.setText("F12");
		getContentPane().add(F12lbl);
		F12lbl.setForeground(java.awt.Color.black);
		F12lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F12lbl.setBounds(346,6,20,20);
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
		F4action.setText("Status");
		getContentPane().add(F4action);
		F4action.setForeground(java.awt.Color.black);
		F4action.setBounds(196,30,70,16);
		F9action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F9action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F9action.setText("Exit");
		getContentPane().add(F9action);
		F9action.setForeground(java.awt.Color.black);
		F9action.setBounds(258,30,70,16);
		F12action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F12action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F12action.setText("Submit");
		getContentPane().add(F12action);
		F12action.setForeground(java.awt.Color.black);
		F12action.setBounds(320,30,70,16);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		msgLabel.setBounds(44,52,372,20);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Query");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,70,16);
		diagCode.setEnabled(false);
		getContentPane().add(diagCode);
		diagCode.setFont(new Font("DialogInput", Font.PLAIN, 12));
		diagCode.setBounds(30,90,90,20);
		diagCodeDesc.setEnabled(false);
		getContentPane().add(diagCodeDesc);
		diagCodeDesc.setFont(new Font("DialogInput", Font.PLAIN, 12));
		diagCodeDesc.setBounds(128,90,306,20);
		codeStatus.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		codeStatus.setEnabled(false);
		getContentPane().add(codeStatus);
		codeStatus.setBounds(404,114,30,20);
		JLabel1.setText("Active Status");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(320,116,78,12);
		JLabel2.setText("Diagnosis Code");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(30,76,96,12);
		JLabel3.setText("Description");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(128,76,78,12);
		getContentPane().add(rowNumber);
		rowNumber.setForeground(java.awt.Color.black);
		rowNumber.setFont(new Font("SansSerif", Font.BOLD, 10));
		rowNumber.setBounds(410,410,32,12);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymMouse aSymMouse = new SymMouse();
		codeList.addMouseListener(aSymMouse);
		descList.addMouseListener(aSymMouse);
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		diagCode.addKeyListener(aSymKey);
		diagCodeDesc.addKeyListener(aSymKey);
		SymFocus aSymFocus = new SymFocus();
		diagCodeDesc.addFocusListener(aSymFocus);
		codeStatus.addKeyListener(aSymKey);
		diagCode.addFocusListener(aSymFocus);
		codeStatus.addFocusListener(aSymFocus);
		//}}
		actionMap = new PcsActionMap(this);
		this.setupKeyPressMap();
	}
	
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();
		rp.getActionMap().put("F1", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				msgLabel.setText(null);
                if (fKeys.isOn(fKeys.F1)==true) queryActions();
                else msgLabel.setText("Query option not available");
			}
		});
		rp.getActionMap().put("F2", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				msgLabel.setText(null);
                if (fKeys.isOn(fKeys.F2)==true) addActions();
                else msgLabel.setText("Add option not available");
			}
		});
		rp.getActionMap().put("F3", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				msgLabel.setText(null);
                if (fKeys.isOn(fKeys.F3)==true) updateActions();
                else msgLabel.setText("Update option not available");
			}
		});
		rp.getActionMap().put("F4", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				msgLabel.setText(null);
                if (fKeys.isOn(fKeys.F4)==true) deleteActions();
                else msgLabel.setText("Status change option not available");
			}
		});

		rp.getActionMap().put("F12", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				msgLabel.setText(null);
                if (fKeys.isOn(fKeys.F12)==true) finalActions();
                else msgLabel.setText("Finalize option not available");
			}
		});
		rp.getActionMap().put("ESC", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				currMode=Lab.IDLE;
                resetForm();
                displayList(0);
                //setEntryFields();
                setSelectedFields();
			}
		});
		rp.getActionMap().put("VK_DOWN", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				int ndx ; 
				if (currMode==Lab.IDLE) {
	                msgLabel.setText(null);
			        if ((codeList.getSelectedIndex()==(-1))
			         || (descList.getSelectedIndex()==(-1)))
			        {
			            ndx=0;
			        }
			        else ndx=descList.getSelectedIndex()+1;
	                if (ndx==diagCodeVect.size()) ndx--;
	                codeList.setSelectedIndex(ndx);
			        descList.setSelectedIndex(ndx);
			        codeList.ensureIndexIsVisible(ndx);
			        descList.ensureIndexIsVisible(ndx);
	                codeList.revalidate();
			        descList.revalidate();
			        setSelectedFields();
			        }
			}
		});
		rp.getActionMap().put("VK_UP", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				int ndx;
				if (currMode==Lab.IDLE) {
	                msgLabel.setText(null);
			        if ((codeList.getSelectedIndex()==(-1))
			         || (descList.getSelectedIndex()==(-1)))
			        {
			            ndx=0;
			        }
			        else ndx=descList.getSelectedIndex()-1;
	                if (ndx==(-1)) ndx=0;
	                codeList.setSelectedIndex(ndx);
			        descList.setSelectedIndex(ndx);
			        codeList.ensureIndexIsVisible(ndx);
			        descList.ensureIndexIsVisible(ndx);
	                codeList.revalidate();
			        descList.revalidate();
			        setSelectedFields();
			        }
			}
		});
		rp.getActionMap().put("VK_PAGE_DOWN", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				int ndx;
				if (currMode==Lab.IDLE) {
	                msgLabel.setText(null);
	                ndx=descList.getSelectedIndex();
	                ndx+=CODES_PER_SCREEN+1;
	                if (ndx>=diagCodeVect.size()) ndx=diagCodeVect.size()-1;
	                codeList.setSelectedIndex(ndx);
	                descList.setSelectedIndex(ndx);
	                codeList.ensureIndexIsVisible(ndx);
	                descList.ensureIndexIsVisible(ndx);
	                codeList.revalidate();
	                descList.revalidate();
	                //setEntryFields();
	                setSelectedFields();
	                }
			}
		});
		rp.getActionMap().put("VK_PAGE_UP", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				int ndx;
				 if (currMode==Lab.IDLE) {
		                msgLabel.setText(null);
		                ndx=descList.getSelectedIndex();
		                ndx-=CODES_PER_SCREEN-1;
		                if (ndx<0) ndx=0;
		                codeList.setSelectedIndex(ndx);
		                descList.setSelectedIndex(ndx);
		                codeList.ensureIndexIsVisible(ndx);
		                descList.ensureIndexIsVisible(ndx);
		                codeList.revalidate();
		                descList.revalidate();
		                //setEntryFields();
		                setSelectedFields();
		                }
			}
		});
		rp.getActionMap().put("VK_HOME", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				 if (currMode==Lab.IDLE) {
		                msgLabel.setText(null);
		                codeList.setSelectedIndex(0);
		                descList.setSelectedIndex(0);
		                codeList.ensureIndexIsVisible(0);
		                descList.ensureIndexIsVisible(0);
		                codeList.revalidate();
		                descList.revalidate();
		                //setEntryFields();
		                setSelectedFields();
		                }
			}
		});
		rp.getActionMap().put("VK_END", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				 if (currMode==Lab.IDLE) {
		                msgLabel.setText(null);
		                codeList.setSelectedIndex(diagCodeVect.size()-1);
		                descList.setSelectedIndex(diagCodeVect.size()-1);
		                codeList.ensureIndexIsVisible(diagCodeVect.size()-1);
		                descList.ensureIndexIsVisible(diagCodeVect.size()-1);
		                codeList.revalidate();
		                descList.revalidate();
		                //setEntryFields();
		                setSelectedFields();
		                }
			}
		});
		
		return rp;
	}
	public DiagCodeForm(String sTitle)
	{
		this();
		setTitle(sTitle);
	}

    public DiagCodeForm(Login dbLogin) {
        this();
        this.dbLogin=dbLogin;
        this.log = new LogFile(
            dbLogin.logPath,"DiagCodeForm",dbLogin.dateToday,dbLogin.userName);
        this.getDiagnosisCodes();
        this.displayList(0);
        this.resetForm();
    }

	public void setVisible(boolean b)
	{
		if (b) setLocation(50, 50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new DiagCodeForm()).setVisible(true);
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
	javax.swing.JScrollPane codePane = new javax.swing.JScrollPane();
	javax.swing.JList codeList = new javax.swing.JList();
	javax.swing.JScrollPane descPane = new javax.swing.JScrollPane();
	javax.swing.JList descList = new javax.swing.JList();
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
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JTextField diagCode = new javax.swing.JTextField();
	javax.swing.JTextField diagCodeDesc = new javax.swing.JTextField();
	javax.swing.JTextField codeStatus = new javax.swing.JTextField();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JLabel rowNumber = new javax.swing.JLabel();
	//}}

	//{{DECLARE_MENUS
	//}}

    public void getDiagnosisCodes()  {
        try  {
            String query = 
                "SELECT diagnosis_code,description,active_status \n"+
                "FROM pcs.diagnosis_codes \n"+
                "ORDER BY diagnosis_code";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            diagCodeVect = new Vector();
            rs=stmt.executeQuery(query);
            while (rs.next()) {
                DiagnosisCodeRec d = new DiagnosisCodeRec();
                d.diagnosis_code=rs.getString(1);
                d.description=rs.getString(2);
                d.active_status=rs.getString(3);
                diagCodeVect.addElement(d);
            }     
        }
        catch (Exception e) { log.write(e); }
    }

    public void displayList(int ndx) {
        rowID=ndx+1;
        Vector cVect=new Vector();
        Vector dVect=new Vector();
        for (int i=0; i<diagCodeVect.size(); i++) {
            DiagnosisCodeRec d = (DiagnosisCodeRec)diagCodeVect.elementAt(i);
            cVect.addElement(d.diagnosis_code);
            dVect.addElement(d.description);
        }
        codeList.setListData(cVect);
        codeList.revalidate();
        descList.setListData(dVect);
        descList.revalidate();
        codeList.setSelectedIndex(ndx);
        codeList.ensureIndexIsVisible(ndx);
        descList.setSelectedIndex(ndx);
        descList.ensureIndexIsVisible(ndx);
        setSelectedFields();
    }
    
    void setSelectedFields()
    {
        int ndx = codeList.getSelectedIndex();
        DiagnosisCodeRec d = (DiagnosisCodeRec)diagCodeVect.elementAt(ndx);
        diagCode.setText(d.diagnosis_code);
        diagCodeDesc.setText(d.description);
        codeStatus.setText(d.active_status);
	    rowID=ndx+1;
	    rowNumber.setText(Integer.toString(rowID));
    }

	class SymMouse extends java.awt.event.MouseAdapter
	{
		public void mouseClicked(java.awt.event.MouseEvent event)
		{
			Object object = event.getSource();
			if (object == descList)
				descList_mouseClicked(event);
		}
	}

	void descList_mouseClicked(java.awt.event.MouseEvent event)
	{
        if (currMode==Lab.IDLE) {
		    int ndx=descList.getSelectedIndex();
		    codeList.setSelectedIndex(ndx);
		    codeList.ensureIndexIsVisible(ndx);
		    codeList.revalidate();
		}
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == diagCode)
				diagCode_keyTyped(event);
			else if (object == diagCodeDesc)
				diagCodeDesc_keyTyped(event);
			else if (object == codeStatus)
				codeStatus_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == diagCode)
				diagCode_keyPressed(event);
			else if (object == diagCodeDesc)
				diagCodeDesc_keyPressed(event);
			else if (object == codeStatus)
				codeStatus_keyPressed(event);
		}
	}

	
	
	public void queryActions() {
	    currMode=Lab.QUERY;
	    fKeys.off();
	    fKeys.keyOn(fKeys.F12);
	    fKeys.keyOn(fKeys.F9);
	    diagCode.setEnabled(true);
	    diagCode.setText(null);
	    diagCodeDesc.setText(null);
	    codeStatus.setText(null);
	    diagCode.requestFocus();
	}
	
	public void finalActions() {
	    if (currMode==Lab.QUERY) {
	        boolean codeFound=false;
	        for (int i=0;i<diagCodeVect.size();i++) {
	            codeList.setSelectedIndex(i);
	            descList.setSelectedIndex(i);
	            String buf=(String)codeList.getSelectedValue();
	            if (buf.compareTo(diagCode.getText())==0) {
	                codeList.ensureIndexIsVisible(i);
	                descList.ensureIndexIsVisible(i);
	                codeList.revalidate();
	                descList.revalidate();
	                //setEntryFields();
	                setSelectedFields();
	                codeFound=true;
	                break;
	            }
	        }
	        currMode=Lab.IDLE;
	        diagCode.setEnabled(false);
	        msgLabel.requestFocus();
	        if (codeFound==false) {
	            resetForm();
	            msgLabel.setText("Code Not Found");
	        }
            fKeys.off();
	        fKeys.keyOn(fKeys.F1);
	        fKeys.keyOn(fKeys.F2);
	        fKeys.keyOn(fKeys.F3);
	        fKeys.keyOn(fKeys.F4);
	        fKeys.keyOn(fKeys.F9);
	    }
	    else if (currMode==Lab.ADD) {
	        boolean codeExists=false;
	        for (int i=0;i<diagCodeVect.size();i++) {
	            codeList.setSelectedIndex(i);
	            descList.setSelectedIndex(i);
	            String buf=(String)codeList.getSelectedValue();
	            if (buf.compareTo(diagCode.getText())==0) {
	                codeList.ensureIndexIsVisible(i);
	                descList.ensureIndexIsVisible(i);
	                codeList.revalidate();
	                descList.revalidate();
	                //setEntryFields();
	                setSelectedFields();
	                diagCode.setEnabled(false);
	                diagCodeDesc.setEnabled(false);
	                msgLabel.requestFocus();
	                msgLabel.setText("Diagnosis Code already exists");
	                codeExists=true;
	                currMode=Lab.IDLE;
	                break;
	            }
	        }
	        if (codeExists==false)  {
	            boolean rv=addDiagCode();
	            if (rv==true) msgLabel.setText("Operation Succeeded");
	        }
	        diagCode.setEnabled(false);
	        diagCodeDesc.setEnabled(false);
	        msgLabel.requestFocus();
	        currMode=Lab.IDLE;
            fKeys.off();
	        fKeys.keyOn(fKeys.F1);
	        fKeys.keyOn(fKeys.F2);
	        fKeys.keyOn(fKeys.F3);
	        fKeys.keyOn(fKeys.F4);
	        fKeys.keyOn(fKeys.F9);
	    }
	    
	    else if (currMode==Lab.DELETE) {
	        String code=diagCode.getText();
	        String status=codeStatus.getText();
	        boolean rv=inactivateCode(code,status);
	        if (rv==true) msgLabel.setText("Operation Succeeded");
	        currMode=Lab.IDLE;
	        msgLabel.requestFocus();
            fKeys.off();
            fKeys.keyOn(fKeys.F1);
	        fKeys.keyOn(fKeys.F2);
	        fKeys.keyOn(fKeys.F3);
	        fKeys.keyOn(fKeys.F4);
	        fKeys.keyOn(fKeys.F9);
	    }
	    
	    else if (currMode==Lab.UPDATE) {
	        String code=diagCode.getText();
	        String desc=diagCodeDesc.getText();
	        boolean rv=updateCodeDesc(code,desc);
	        if (rv==true) { 
	            msgLabel.setText("Operation Succeeded");
	            displayList(rowID-1);
	        }
	        currMode=Lab.IDLE;
	        msgLabel.requestFocus();
	        diagCodeDesc.setEnabled(false);
            fKeys.off();
            fKeys.keyOn(fKeys.F1);
	        fKeys.keyOn(fKeys.F2);
	        fKeys.keyOn(fKeys.F3);
	        fKeys.keyOn(fKeys.F4);
	        fKeys.keyOn(fKeys.F9);
	    }
	}

	public void addActions() {
	    currMode=Lab.ADD;
	    fKeys.off();
	    fKeys.keyOn(fKeys.F12);
	    fKeys.keyOn(fKeys.F9);
	    diagCode.setText(null);
	    diagCodeDesc.setText(null);
	    codeStatus.setText("A");
        diagCode.setEnabled(true);
        diagCodeDesc.setEnabled(true);
	    diagCode.requestFocus();
	}
	
	public boolean addDiagCode() {
        boolean exitStatus=true;
        try  {
            String query = 
                "INSERT INTO pcs.diagnosis_codes VALUES (?,?,'A') \n";
                
            PreparedStatement pstmt = DbConnection.process().prepareStatement(query);
            pstmt.setString(1,diagCode.getText());
            pstmt.setString(2,diagCode.getText());
            int rs = pstmt.executeUpdate();
            if (rs>0) {
                getDiagnosisCodes();
                displayList(0);
            }
        }
        catch (Exception e) {
            log.write(e);
            exitStatus=false;
            msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }
    
	void diagCode_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}

	void diagCodeDesc_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}
	
	public void deleteActions() {
	    currMode=Lab.DELETE;
	    fKeys.off();
	    fKeys.keyOn(fKeys.F12);
	    fKeys.keyOn(fKeys.F9);
	    if (codeStatus.getText().compareTo("A")==0) {
	        codeStatus.setText("I");
	        msgLabel.setText("Code Inactivated - Press F12 to Finalize");
	    }
	    else {
	        codeStatus.setText("A");
	        msgLabel.setText("Code Reactivated - Press F12 to Finalize");
	    }
	}
	
	public boolean inactivateCode(String code, String status) {
        boolean exitStatus=true;
        try  {
            String query = 
                "UPDATE pcs.diagnosis_codes \n"+
                "SET active_status='"+status+"' \n"+
                "WHERE diagnosis_code='"+code+"'\n";
                
            System.out.println(query);                
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(query);
            if (rs>0) {
                DiagnosisCodeRec d = (DiagnosisCodeRec)diagCodeVect.elementAt(rowID-1);
                d.active_status=status;
            }
            else { exitStatus=false; }
        }
        catch (Exception e) {
            log.write(e);
            exitStatus=false;
            msgLabel.setText("Operation Failed");
        }
        
        return(exitStatus);            
    }
	
	public void resetForm() {
	    resetColors();
	    msgLabel.setText(null);
	    msgLabel.requestFocus();
	    diagCode.setEnabled(false);
	    diagCodeDesc.setEnabled(false);
	    fKeys.off();
	    fKeys.keyOn(fKeys.F1);
	    fKeys.keyOn(fKeys.F2);
	    fKeys.keyOn(fKeys.F3);
	    fKeys.keyOn(fKeys.F4);
	    fKeys.keyOn(fKeys.F9);
	}
	
	public void updateActions() {
	    currMode=Lab.UPDATE;
	    fKeys.off();
	    fKeys.keyOn(fKeys.F12);
	    fKeys.keyOn(fKeys.F9);
        diagCodeDesc.setEnabled(true);
        diagCodeDesc.requestFocus();
	}
	
	public boolean updateCodeDesc(String code, String desc) {
        boolean exitStatus=true;
        try  {
            String query = 
                "UPDATE pcs.diagnosis_codes \n"+
                "SET description='"+desc+"' \n"+
                "WHERE diagnosis_code='"+code+"'\n";
                
            System.out.println(query);                
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(query);
            if (rs>0) {
                DiagnosisCodeRec d = (DiagnosisCodeRec)diagCodeVect.elementAt(rowID-1);
                d.description=desc;
            }
            else { exitStatus=false; }
        }
        catch (Exception e) {
            log.write(e);
            exitStatus=false;
            msgLabel.setText("Operation Failed");
        }
        
        return(exitStatus);            
	}

	class SymFocus extends java.awt.event.FocusAdapter
	{
		public void focusGained(java.awt.event.FocusEvent event)
		{
			Object object = event.getSource();
			if (object == diagCodeDesc)
				diagCodeDesc_focusGained(event);
			else if (object == diagCode)
				diagCode_focusGained(event);
			else if (object == codeStatus)
				codeStatus_focusGained(event);
		}
	}

	void diagCodeDesc_focusGained(java.awt.event.FocusEvent event)
	{
	    Utils.deselect(event);
	}

	void diagCode_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(diagCode,"ICD9 Code"))
		        diagCode.transferFocus();
		}
	}

	void diagCodeDesc_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(diagCodeDesc,"ICD9 Code Description"))
		        diagCodeDesc.transferFocus();
		}
	}

	void codeStatus_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}

	void codeStatus_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(codeStatus,"Active Status"))
		        codeStatus.transferFocus();
		}
	}
	
	void resetColors()
	{
	    Utils.setColors(this.getContentPane());
	    msgLabel.setForeground(Color.green);
		rowNumber.setFont(new Font("SansSerif", Font.BOLD, 10));
	    rowNumber.setForeground(Color.white);
	    this.repaint();
	}
	

	void diagCode_focusGained(java.awt.event.FocusEvent event)
	{
		Utils.deselect(event);
	}

	void codeStatus_focusGained(java.awt.event.FocusEvent event)
	{
		Utils.deselect(event);
	}

	@Override
	public void resetActions() {
		// TODO Auto-generated method stub
		
	}
	
}
