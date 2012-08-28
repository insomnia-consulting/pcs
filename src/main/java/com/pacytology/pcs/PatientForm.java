package com.pacytology.pcs;
/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       PatientForm.java
    Created By: John Cardella, Software Engineer
    
    Function:   Patient lookup table for lab screen.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import javax.swing.*;
import com.pacytology.pcs.ui.Square;
import java.util.Vector;
import java.io.*;
import javax.swing.table.*;

public class PatientForm extends javax.swing.JFrame
{
    public LabForm parent;
    final int paMaxRecs = 80;
    final int pTblCols = 10;
    /*
    final int IDLE = 100;
    final int QUERY = 101;
    final int ADD = 102;
    final int UPDATE = 103;
    final int DELETE = 104;
    */
    public int currMode = Lab.IDLE;
    protected PatientDbOps paDbOps;
    protected int patQuerySize = 0;
    protected PatientRec[] paRec = new PatientRec[paMaxRecs];
    public PatientRec queryRec = new PatientRec();
    boolean autoQuery = false;
    public int updateRow=(-1);
    public int patNdx=0;
    public LogFile log;
    public PatientTableData pData;
    public JTable PatientTable; 
    
    public boolean flag = false;

	public PatientForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Patient Lookup Table");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(810,280);
		setVisible(false);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		msgLabel.setBounds(184,10,372,14);
		getContentPane().add(F1sq);
		F1sq.setBounds(35,6,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F5");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(39,6,20,20);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Labs");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,70,18);
		getContentPane().add(paPracNameLbl);
		paPracNameLbl.setBounds(336,86,250,16);
		getContentPane().add(patientID);
		patientID.setForeground(java.awt.Color.darkGray);
		patientID.setBounds(38,402,48,16);
		getContentPane().add(F2sq);
		F2sq.setBounds(97,6,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F9");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(101,6,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Exit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(72,30,70,18);
		//}}

		pData = new PatientTableData();
		PatientTable = new JTable();
		PatientTable.setEnabled(false);
		PatientTable.setAutoCreateColumnsFromModel(false);
		PatientTable.setModel(pData);

		for (int k=0;k<PatientTableData.columns.length;k++) {
		    DefaultTableCellRenderer renderer = new
		        DefaultTableCellRenderer();
            renderer.setHorizontalAlignment(
                PatientTableData.columns[k].alignment);
            TableColumn column = new TableColumn(k,
                PatientTableData.columns[k].width,renderer,null);
            PatientTable.addColumn(column);
		}
		
		JTableHeader header = PatientTable.getTableHeader();
        header.setFont(new Font("Dialog", Font.BOLD, 11));
	
		JScrollPane paTblScrollPane = new JScrollPane();
		paTblScrollPane.getViewport().add(PatientTable);
		getContentPane().add(paTblScrollPane);
		paTblScrollPane.setBounds(16,50,774,198);
        paTblScrollPane.setAutoscrolls(true);
		
		PatientTable.setFont(new Font("SansSerif", Font.PLAIN, 11));
		PatientTable.setBounds(0,0,775,195);
        PatientTable.setRowHeight(11);
        PatientTable.setCellSelectionEnabled(false);
        PatientTable.setRowSelectionAllowed(true);
        
        for (int i=0;i<paMaxRecs;i++)  { paRec[i] = new PatientRec(); }            

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		//}}
	}

	public PatientForm(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	

    public PatientForm(LabForm p)  
    {
        this();
        this.parent = p;
        this.currMode=Lab.QUERY;
        this.log = parent.log;
        Utils.setColors(this.getContentPane());
        this.clearPatientTable();
        this.PatientTable.repaint();
        this.PatientTable.revalidate();
        paDbOps = new PatientDbOps(this);
        this.flag=true;
        msgLabel.setForeground(Color.green);
    }        
    
    void retrieveData()
    {
        currMode=Lab.QUERY;
        setCursor(new Cursor(Cursor.WAIT_CURSOR));
        parent.setCursor(new Cursor(Cursor.WAIT_CURSOR));
        this.clearPatientTable();
        this.queryRec = new PatientRec();
        this.queryRec.lname=parent.labPatientLastName.getText();
        this.queryRec.fname=parent.labPatientFirstName.getText();
        this.queryRec.mi=parent.labPatientMI.getText();
        this.queryRec.ssn=Utils.stripSSNMask(parent.labSSN.getText());
        this.queryRec.address1=parent.labPaAddress.getText();
        this.queryRec.city=parent.labCity.getText();
        this.queryRec.state=parent.labState.getText();
        this.queryRec.zip=Utils.stripZipMask(parent.labZip.getText());
        this.queryRec.phone=Utils.stripPhoneMask(parent.labPhone.getText());
        this.queryRec.dob=Utils.stripDateMask(parent.labDOB.getText());
        if (!Utils.isNull(parent.labPrevLabNum.getText()))
            this.queryRec.last_lab=(int)Integer.parseInt(parent.labPrevLabNum.getText());
        if (!Utils.isNull(parent.labPractice.getText()))
            this.queryRec.practice=(int)Integer.parseInt(parent.labPractice.getText());
        this.paDbOps.queryPatients();
    }

	public void setVisible(boolean b)
	{
		if (b) setLocation(0,0/*1,260*/);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new PatientForm()).setVisible(true);
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
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JLabel paPracNameLbl = new javax.swing.JLabel();
	javax.swing.JLabel patientID = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	//}}
	
	//javax.swing.JScrollPane paTblScrollPane = new javax.swing.JScrollPane();
	//javax.swing.JTable PatientTable = new javax.swing.JTable(data,colHeader);
	//javax.swing.JTable PatientTable = new javax.swing.JTable();
	
	//{{DECLARE_MENUS
	//}}


	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == PatientForm.this)
				PatientForm_keyPressed(event);
		}

		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
		}
	}
	
	void PatientForm_keyPressed(java.awt.event.KeyEvent event)
	{
        // DOWN ARROW KEY PRESSED
        if (event.getKeyCode()==event.VK_DOWN)
        {
            if (patQuerySize>1 && currMode==Lab.QUERY) {
            msgLabel.setText(null);
            patNdx=PatientTable.getSelectedRow();
            if (patNdx<0) patNdx=0;
            else if (patNdx<patQuerySize-2) patNdx++;
            else { 
                patNdx=patQuerySize-1;
                msgLabel.setText("Bottom of List");
            }
            PatientTable.clearSelection();
            PatientTable.addRowSelectionInterval(patNdx,patNdx);
            PatientTable.scrollRectToVisible
                (PatientTable.getCellRect(patNdx,0,true));
            fillForm(patNdx);
            }
        }            
        else if (event.getKeyCode()==event.VK_F9) {
            noDataFound();
        }        
        // UP ARROW KEY PRESSED
        else if (event.getKeyCode()==event.VK_UP)
        {
            if (patQuerySize>1 && currMode==Lab.QUERY) {
            msgLabel.setText(null);
            patNdx=PatientTable.getSelectedRow();
            if (patNdx>patQuerySize) patNdx=patQuerySize-1;
            else if (patNdx>1) patNdx--;
            else {
                patNdx=0;
                msgLabel.setText("Top of List");
            }
            PatientTable.clearSelection();
            PatientTable.addRowSelectionInterval(patNdx,patNdx);
            PatientTable.scrollRectToVisible
                (PatientTable.getCellRect(patNdx,0,true));
            fillForm(patNdx);
            }
        }
        else if (event.getKeyCode()==event.VK_ENTER) {
            if (patQuerySize>0) selectActions();
        }
        else if (event.getKeyCode()==event.VK_F5) {
            if ((patQuerySize>0)&&(patNdx>=0)&&(patNdx<patQuerySize)) {
                this.setCursor(new Cursor(Cursor.WAIT_CURSOR));
                Vector resultList = new Vector();
                int patNum = paRec[patNdx].patient;
                paDbOps.queryPatientLabs(patNum,resultList);
                int listSize=resultList.size()+1;
                String[] labList = new String[listSize];
                labList[0]="LAB:        PR:  COLLECTED:  ENTERED:    STATE:";
                for (int i=1;i<listSize;i++) {
                    labList[i]=(String)resultList.elementAt(i-1);
                }
                String plTitle="Labs for: "+paRec[patNdx].lname+", "+paRec[patNdx].fname;
                this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));
                (new PickList(plTitle,270,80,364,130,
                              listSize,labList)).setVisible(true);
            }
        }
            
	}
	
	public void noDataFound()
	{
        log.write("Returning from patient lookup - no data found/selected");
        parent.resetColors();
        parent.clearForm();
        parent.currentSection=1;
        //paRec[0].patient=paDbOps.getNextPatient();
        paRec[0].patient=0;
        parent.labRec.pat.patient=paRec[0].patient;
        parent.labRec.pat.newPatientAdd=true;
        parent.labRec.patient=paRec[0].patient;
        parent.labPatientFirstName.setText(queryRec.fname);
        parent.labPatientLastName.setText(queryRec.lname);
        parent.labPatientMI.setText(queryRec.mi);
        parent.labSSN.setText(Utils.addSSNMask(queryRec.ssn));
        parent.labDOB.setText(Utils.addDateMask(queryRec.dob));
        parent.setEnablePatientFields(true);
        parent.labPrevLabNum.setEnabled(false);
        parent.labPrevLabNum.setText("0");
        parent.labRec.pat.patient=paRec[0].patient;
        parent.labRec.pat.newPatientAdd=true;
        parent.patientQuery=false;
        parent.labPatientNumber.setText(Integer.toString(paRec[0].patient));
        parent.labNumber.requestFocus();
        this.dispose();
	}

    public void selectActions() {
        if (patQuerySize>0) {
            msgLabel.setText(null);
            int returnRow=PatientTable.getSelectedRow();
            if (returnRow==(-1)) { 
                Utils.createErrMsg("No data selected!");
                return;
            }
            else  {
                parent.resetLabForm();
                parent.currMode=Lab.ADD;
                parent.labPrevLabNum.setText(Integer.toString(paRec[returnRow].last_lab));
                parent.findLastLab();
            }                
        }
        else {
            log.write("Returning from patient lookup - no data found");
            parent.resetColors();
            parent.clearForm();
            parent.currentSection=1;
            //paRec[0].patient=paDbOps.getNextPatient();
            paRec[0].patient=0;
            parent.labPatientFirstName.setText(queryRec.fname);
            parent.labPatientLastName.setText(queryRec.lname);
            parent.labPatientMI.setText(queryRec.mi);
            parent.labSSN.setText(queryRec.ssn);
            parent.labDOB.setText(queryRec.dob);
            parent.setEnablePatientFields(true);
            parent.labPrevLabNum.setEnabled(false);
            parent.labPrevLabNum.setText("0");
            parent.labRec.pat.patient=paRec[0].patient;
            parent.labRec.pat.newPatientAdd=true;
            parent.labPatientNumber.setText(Integer.toString(paRec[0].patient));
            parent.labNumber.requestFocusInWindow();
        }
        
        parent.patientQuery=false;
        this.dispose();
    }        

    public void updatePatientTable() 
    {
        for (int row=0;row<patQuerySize;row++) {
            fillPatientTableRow(row);
        }
        PatientTable.selectAll();
        PatientTable.clearSelection();
        PatientTable.revalidate();
        PatientTable.repaint();
    }

    void clearPatientTable()  
    {
        for (int row=0;row<paMaxRecs;row++) {
            for (int column=0;column<pTblCols;column++) {
                PatientTable.setValueAt(null,row,column);
            }                
        }            
        PatientTable.selectAll();
        PatientTable.clearSelection();
        PatientTable.revalidate();
        PatientTable.repaint();
    }            

    void fillForm(int index)  
    {
        String buf="";
        parent.clearForm();
        parent.labPrevLabNum.setText(Integer.toString(paRec[index].last_lab));
        parent.labPractice.setText(Integer.toString(paRec[index].practice));
        if (DbConnection.getUser().toUpperCase().equals("ACHIODA"))
            parent.labPractice.setText(null);
        parent.labPatientLastName.setText(paRec[index].lname);
        parent.labPatientFirstName.setText(paRec[index].fname);
        parent.labPatientMI.setText(paRec[index].mi);
        parent.labPaAddress.setText(paRec[index].address1);
        parent.labCity.setText(paRec[index].city);
        parent.labState.setText(paRec[index].state);
        parent.labZip.setText(Utils.addZipMask(paRec[index].zip));
        parent.labPhone.setText(Utils.addPhoneMask(paRec[index].phone));
        parent.labDOB.setText(Utils.addDateMask(paRec[index].dob));
        parent.labSSN.setText(Utils.addSSNMask(paRec[index].ssn));
        if (paRec[index].practice<100)
            buf="0"+Integer.toString(paRec[index].practice);
        else buf=Integer.toString(paRec[index].practice);
        parent.labPatientNumber.setText(Integer.toString(paRec[index].patient));
    }        

    public void clearPatientRecs()  
    {
        for (int i=0;i<paMaxRecs;i++)
            paRec[i].reset();
    }        
    
	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == PatientForm.this)
				PatientForm_windowOpened(event);
		}

	}

	public void fillPatientTableRow(int row) 
	{
        PatientTable.setValueAt(paRec[row].lname,row,0);
        PatientTable.setValueAt(paRec[row].fname,row,1);
        PatientTable.setValueAt(paRec[row].ssn,row,2);
        PatientTable.setValueAt(paRec[row].dob,row,3);
        PatientTable.setValueAt(Integer.toString(paRec[row].last_lab),row,4);
        String buf = Integer.toString(paRec[row].practice);
        if (paRec[row].practice<100) buf=("0"+buf);
        PatientTable.setValueAt(buf,row,5);
        PatientTable.setValueAt(paRec[row].address1,row,6);
        PatientTable.setValueAt(paRec[row].city,row,7);
        PatientTable.setValueAt(paRec[row].state,row,8);
        PatientTable.setValueAt(paRec[row].zip,row,9);
	}

	void PatientForm_windowOpened(java.awt.event.WindowEvent event)
	{
	    for (;;) { if (flag) break; }
	    retrieveData();
	}
	
}

