package com.pacytology.pcs;

import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.io.File;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.SortedSet;
import java.util.Vector;

import javax.swing.JOptionPane;

import com.pacytology.pcs.MonthlyReptDialog.SymAction;
import com.pacytology.pcs.MonthlyReptDialog.SymKey;
import com.pacytology.pcs.MonthlyReptDialog.SymWindow;
import com.pacytology.pcs.io.FileTransfer;
import com.pacytology.pcs.utils.PriceUtil;
import com.pacytology.pcs.utils.PriceUtil.PriceChange;
import com.pacytology.pcs.utils.PriceUtil.PriceMonthInfo;

public class GenerateMonthlyReptDialog extends javax.swing.JDialog
{
	String reportName;

	//String stp_name;
	//String report_title;
	//String auto_run;

	public GenerateMonthlyReptDialog()
	{
		setResizable(false);
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(217,62);
		setVisible(false);
		getContentPane().add(statementMonth);
		statementMonth.setFont(new Font("SansSerif", Font.BOLD, 12));
		statementMonth.setBounds(150,12,40,20);
		getContentPane().add(statementYear);
		statementYear.setFont(new Font("SansSerif", Font.BOLD, 12));
		statementYear.setBounds(150,34,40,20);
		monthLabel.setText("Month (MM)");
		getContentPane().add(monthLabel);
		monthLabel.setForeground(java.awt.Color.black);
		monthLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		monthLabel.setBounds(20,12,98,14);
		yearLabel.setText("Year (YYYY)");
		getContentPane().add(yearLabel);
		yearLabel.setForeground(java.awt.Color.black);
		yearLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		yearLabel.setBounds(20,34,98,14);

		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		statementMonth.addKeyListener(aSymKey);
		statementYear.addKeyListener(aSymKey);
	//	SymWindow aSymWindow = new SymWindow();
	//	this.addWindowListener(aSymWindow);
	}

	public GenerateMonthlyReptDialog(String reptName)
	{
		this();
		this.reportName=reptName;
		
		if (reptName.equals("BCC")) {
			setTitle("WV BCCSP INV SUM");
		}
		else if (reptName.equals("FPP")) {
			setTitle("WV FPP INV SUM");
		}
		
		/*
		this.printerCodes = new Vector();
		if (reptName.equals("age")) {
			setTitle("EOM Aging Report");
			printerCodes.addElement(Utils.ELITE);
			printerCodes.addElement(Utils.COMPRESSED);
		}
		else if (reptName.equals("due")) {
			setTitle("Past Due Account Report");
			printerCodes.addElement(Utils.ELITE);
			printerCodes.addElement(Utils.COMPRESSED);
		}
		else if (reptName.equals("sbt")) {
			setTitle("Summary of Billing Types");
			printerCodes.addElement(Utils.CONDENSED);
		}
		else if (reptName.equals("pth")) {
			setTitle("Slides by Pathologist");
			printerCodes.addElement(Utils.CONDENSED);
		}
		else if (reptName.equals("cyt")) {
			setTitle("Slides by Cytotech");
			printerCodes.addElement(Utils.CONDENSED);
		}
		else if (reptName.equals("rfb")) {
			setTitle("Biopsy Request Summary");
			printerCodes.addElement(Utils.CONDENSED);
		}
		else if (reptName.equals("pcd")) {
			setTitle("Patient Cards");
			printerCodes.addElement(Utils.COMPRESSED);
		}
		else if (reptName.equals("rbl"))
			setTitle("Biopsy Letters");
		else if (reptName.equals("uns"))
			setTitle("Unsatisfactory PAP Smear");
		else if (reptName.equals("pnd"))
			setTitle("Results Pending");
		else if (reptName.equals("cln"))
			setTitle("Clinic Cases");
		else if (reptName.equals("tat"))
			setTitle("Turn Around");
		else if (reptName.equals("ahp"))
			setTitle("ASCUS - HPV");
		else if (reptName.equals("whp"))
			setTitle("ADPH Summary");
		else if (reptName.equals("abn")) {
			setTitle("ADPH Summary of Abnormals");
			printerCodes.addElement(Utils.ELITE);
		}
		else if (reptName.equals("207")) {
			setTitle("ADPH ASC-H/HPV Results");
			printerCodes.addElement(Utils.ELITE);
		}
		else if (reptName.equals("is1")) {
			setTitle("ADPH INV SUM MID");
		}
		else if (reptName.equals("is2")) {
			setTitle("ADPH INV SUM EOM");
		}
		else if (reptName.equals("bc1")) {
			setTitle("WV BCCSP INV SUM");
		}
		else if (reptName.equals("fp1")) {
			setTitle("WV FPP INV SUM");
		}
		*/
	}

	boolean frameSizeAdjusted = false;
	
	@Override
	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted) return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets
		Insets insets = getInsets();
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height);
	}

	javax.swing.JTextField statementMonth = new javax.swing.JTextField();
	javax.swing.JTextField statementYear = new javax.swing.JTextField();
	javax.swing.JLabel monthLabel = new javax.swing.JLabel();
	javax.swing.JLabel yearLabel = new javax.swing.JLabel();
/*
	void viewReport()
	{
		if (Utils.isNull(statementMonth.getText()) || Utils.isNull(statementYear.getText())) 
		{
			Utils.createErrMsg("No Data Entered");
			return;
		}

		int month = Integer.parseInt(statementMonth.getText());

		if (month<1 || month>12)
		{
			Utils.createErrMsg("Month must be between 1 and 12");
			statementMonth.requestFocus();
			return;
		}
		
		String s_month=month<10?"0"+month:month+"";
	}
*/

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == statementMonth)
				statementMonth_keyTyped(event);
			else if (object == statementYear)
				statementYear_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();

			if (object == statementMonth)
				statementMonth_keyPressed(event);
			else if (object == statementYear)
				statementYear_keyPressed(event);

		}
	}
/*
	void MonthlyReptDialog_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_F9) this.dispose();
		else if (event.getKeyCode()==event.VK_ESCAPE) {
			statementMonth.setText(null);
			statementYear.setText(null);
			statementMonth.requestFocus();
		}
	}
*/
	void statementMonth_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
			if (Utils.required(statementMonth,"Month"))
				statementMonth.transferFocus();
		}
	}



	void statementYear_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
			if (Utils.required(statementYear,"Year")) {
				try {
				generateReport();
				} catch (Exception e)
				{
					e.printStackTrace();
				}
			}
		}
	}

	private void generateReport() throws Exception 
	{
		String month=statementYear.getText()+statementMonth.getText();
		PriceMonthInfo priceInfo=PriceUtil.getRangeForMonth(month);
		
		
		
		int cycle=2;
		SortedSet<PriceChange> all = priceInfo.getAllPriceChanges(cycle,this.reportName);

		Integer i_month=Integer.parseInt(month);

		Integer[] range = priceInfo.getRange();

		if (all.size()==0)
		{
			PriceUtil.callWVInvoiceSumm(i_month,cycle,reportName,range[0],range[1],1,1);
		} else
		{
			Integer from=range[0];
			int counter=0;
			for (PriceChange cur : all)
			{
				Integer to = cur.getLab();
				PriceUtil.callWVInvoiceSumm(i_month,cycle,reportName,from,to,counter+1,all.size()+1);
				from=to;
				counter++;
			}

			PriceUtil.callWVInvoiceSumm(i_month,cycle,reportName,from,range[1]+1,counter+1,all.size()+1);
		}
		
		int reports=all.size()+1;
		JOptionPane.showMessageDialog(null,reports+" report"+(reports==1?"":"s")+" created.","Information",JOptionPane.INFORMATION_MESSAGE);
	}

	void statementMonth_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,2);
	}
	
	void statementYear_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event,4);
	}
/*
	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == GenerateMonthlyReptDialog.this)
				MonthlyReptDialog_windowOpened(event);
		}
	}

	void MonthlyReptDialog_windowOpened(java.awt.event.WindowEvent event)
	{
		statementMonth.requestFocus();
	}
*/
	/*
	private boolean getReportInfo()  
	{
		boolean dataFound = false;        
		String SQL = 
				"SELECT stp_name, auto_run, report_title \n"+
						"FROM pcs.monthly_reports \n"+
						"WHERE file_ext = '"+reptName+"' \n";
		try {
			Statement stmt = DbConnection.process().createStatement();
			ResultSet rs = stmt.executeQuery(SQL);
			while (rs.next())  {
				stp_name = rs.getString(1);
				auto_run = rs.getString(2);
				report_title = rs.getString(3);
				dataFound=true;
			}                
			rs.close(); stmt.close();
		}
		catch (SQLException e) { System.out.println(e); }
		catch (Exception e) { System.out.println(e); }
		return (dataFound);
	}

	class SymAction implements java.awt.event.ActionListener
	{
		public void actionPerformed(java.awt.event.ActionEvent event)
		{
		}
	}
*/
}

