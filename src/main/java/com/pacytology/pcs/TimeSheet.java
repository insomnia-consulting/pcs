package com.pacytology.pcs;

/*
		A basic implementation of the JFrame class.
*/

import java.awt.*;
import javax.swing.*;
import java.sql.*;

public class TimeSheet extends javax.swing.JFrame
{
    private Login dbLogin;
    int currInvoice;
    
	public TimeSheet()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(189,178);
		setVisible(false);
		getContentPane().add(startDate);
		startDate.setFont(new Font("DialogInput", Font.PLAIN, 12));
		startDate.setBounds(16,24,76,20);
		startHour.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		getContentPane().add(startHour);
		startHour.setFont(new Font("DialogInput", Font.PLAIN, 12));
		startHour.setBounds(104,24,28,20);
		startMinute.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		getContentPane().add(startMinute);
		startMinute.setFont(new Font("DialogInput", Font.PLAIN, 12));
		startMinute.setBounds(144,24,28,20);
		getContentPane().add(endDate);
		endDate.setFont(new Font("DialogInput", Font.PLAIN, 12));
		endDate.setBounds(16,48,76,20);
		endHour.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		getContentPane().add(endHour);
		endHour.setFont(new Font("DialogInput", Font.PLAIN, 12));
		endHour.setBounds(104,48,28,20);
		endMinute.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		getContentPane().add(endMinute);
		endMinute.setFont(new Font("DialogInput", Font.PLAIN, 12));
		endMinute.setBounds(144,48,28,20);
		getContentPane().add(description);
		description.setFont(new Font("DialogInput", Font.PLAIN, 12));
		description.setBounds(16,80,156,20);
		cummHours.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		getContentPane().add(cummHours);
		cummHours.setFont(new Font("DialogInput", Font.PLAIN, 12));
		cummHours.setBounds(16,112,76,20);
		cummAmount.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		getContentPane().add(cummAmount);
		cummAmount.setFont(new Font("DialogInput", Font.PLAIN, 12));
		cummAmount.setBounds(96,112,76,20);
		addHours.setText("Hours");
		addHours.setActionCommand("Hours");
		getContentPane().add(addHours);
		addHours.setBounds(16,144,74,20);
		createInvoice.setText("Invoice");
		createInvoice.setActionCommand("Invoice");
		getContentPane().add(createInvoice);
		createInvoice.setBounds(96,144,74,20);
		getContentPane().add(invNumber);
		invNumber.setBounds(16,4,130,14);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymAction lSymAction = new SymAction();
		addHours.addActionListener(lSymAction);
		createInvoice.addActionListener(lSymAction);
		//}}
	}

	public TimeSheet(String sTitle)
	{
		this();
		setTitle(sTitle);
	}
	
	public TimeSheet(Login dbLogin)
	{
	    this();
	    this.dbLogin=dbLogin;
	    getTotals();
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(50, 50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new TimeSheet()).setVisible(true);
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
	javax.swing.JTextField startDate = new javax.swing.JTextField();
	javax.swing.JTextField startHour = new javax.swing.JTextField();
	javax.swing.JTextField startMinute = new javax.swing.JTextField();
	javax.swing.JTextField endDate = new javax.swing.JTextField();
	javax.swing.JTextField endHour = new javax.swing.JTextField();
	javax.swing.JTextField endMinute = new javax.swing.JTextField();
	javax.swing.JTextField description = new javax.swing.JTextField();
	javax.swing.JTextField cummHours = new javax.swing.JTextField();
	javax.swing.JTextField cummAmount = new javax.swing.JTextField();
	javax.swing.JButton addHours = new javax.swing.JButton();
	javax.swing.JButton createInvoice = new javax.swing.JButton();
	javax.swing.JLabel invNumber = new javax.swing.JLabel();
	//}}

	//{{DECLARE_MENUS
	//}}
	
    void getTotals()
    {
        String hoursWorked = null;
        String dollarsMade = null;
        String query = null;
        try {
            query="select min(inv_id) from pcs.jc_invoice";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs=stmt.executeQuery(query);
            while (rs.next()) { currInvoice=rs.getInt(1); }
            currInvoice*=(-1);
            query =
            "select to_char(sum(hours_worked),'90.9999'),"+
            "to_char(sum(dollars_made),'9990.99') from pcs.jc_invoice "+
            "where abs(inv_id)="+currInvoice+" ";
            rs = stmt.executeQuery(query);
            while (rs.next()) { 
                hoursWorked=rs.getString(1);
                dollarsMade=rs.getString(2);
            }
            cummHours.setText(hoursWorked);
            cummAmount.setText(dollarsMade);
            invNumber.setText("INVOICE #"+currInvoice);
            rs.close();
            stmt.close();
        }
        catch (Exception e) { System.out.println(e); }
    }
    
    void addTime()
    {
        String beginTime = 
            startDate.getText()+" "+startHour.getText()+":"+startMinute.getText();
        String endTime = 
            endDate.getText()+" "+endHour.getText()+":"+endMinute.getText();
        String query = 
            "insert into jc_invoice values ("+currInvoice+",to_date('"+beginTime+"','MM/DD/YYYY HH24:MI'),"+
            "to_date('"+endTime+"','MM/DD/YYYY HH24:MI'),'"+description.getText()+"',null,null)";
        try {
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(query);
            query = 
                "update jc_invoice set hours_worked = "+
                "(end_time-start_time)*24, dollars_made = "+
                "((end_time-start_time)*24)*40 where "+
                "hours_worked is null and dollars_made is null";
            rs=stmt.executeUpdate(query);
            stmt.close();
            getTotals();
        }
        catch (Exception e) { System.out.println(e); }
        startDate.setText(null); startHour.setText(null); startMinute.setText(null);
        endDate.setText(null); endHour.setText(null); endMinute.setText(null);
        description.setText(null);
            
    }
    
	class SymAction implements java.awt.event.ActionListener
	{
		public void actionPerformed(java.awt.event.ActionEvent event)
		{
			Object object = event.getSource();
			if (object == addHours)
				addHours_actionPerformed(event);
			else if (object == createInvoice)
				createInvoice_actionPerformed(event);
		}
	}

	void addHours_actionPerformed(java.awt.event.ActionEvent event)
	{
		addTime();
	}

	void createInvoice_actionPerformed(java.awt.event.ActionEvent event)
	{
        try  {
            CallableStatement cstmt;
	        cstmt=DbConnection.process().prepareCall(
	            "{call make_jc_invoice(?,?)}");
            cstmt.setInt(1,currInvoice);
            cstmt.setInt(2,1);
            cstmt.executeUpdate();
            cstmt.close();
        }
        catch( Exception e ) { System.out.println(e); }
	}
	
}
