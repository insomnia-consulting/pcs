package com.pacytology.pcs;

import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.awt.event.KeyAdapter;
import java.util.SortedSet;

import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JTextField;

import com.pacytology.pcs.utils.PriceUtil;
import com.pacytology.pcs.utils.PriceUtil.PriceChange;
import com.pacytology.pcs.utils.PriceUtil.PriceMonthInfo;

public class GenerateMonthlyReptDialog extends javax.swing.JDialog
{
	public static enum WvInvoiceSummaryVariant {One,Nine};
	
	String reportName;
	JTextField statementMonth = new javax.swing.JTextField();
	JTextField statementYear = new javax.swing.JTextField();
	JLabel monthLabel = new javax.swing.JLabel();
	JLabel yearLabel = new javax.swing.JLabel();
	private WvInvoiceSummaryVariant variant;
	int cycle=2;
	
	public GenerateMonthlyReptDialog(WvInvoiceSummaryVariant variant)
	{
		this.variant=variant;
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
	}

	public GenerateMonthlyReptDialog(String reportName,WvInvoiceSummaryVariant variant)
	{
		this(variant);
		this.reportName=reportName;
		
		String num=variant==WvInvoiceSummaryVariant.One?"(1)":"(9)";
		
		if (reportName.equals("BCCSP")) {
			setTitle("WV BCCSP INV SUM "+num);
		}
		else if (reportName.equals("FPP")) {
			setTitle("WV FPP INV SUM"+num);
		}
	}

	boolean frameSizeAdjusted = false;
	
	@Override
	public void addNotify()
	{
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted) 
		{
			return;
		}
		frameSizeAdjusted = true;

		Insets insets = getInsets();
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height);
	}

	class SymKey extends KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == statementMonth)
			{
				statementMonth_keyTyped(event);
			}
			else if (object == statementYear)
			{
				statementYear_keyTyped(event);
			}
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();

			if (object == statementMonth)
			{
				statementMonth_keyPressed(event);
			}
			else if (object == statementYear)
			{
				statementYear_keyPressed(event);
			}
		}
	}

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
					if (variant==WvInvoiceSummaryVariant.One)
					{
						generateReport_1();
					} else if (variant==WvInvoiceSummaryVariant.Nine)
					{
						generateReport_9();
					}
				} catch (Exception e)
				{
					e.printStackTrace();
				} finally
				{
					this.dispose();
				}
			}
		}
	}

	private String getMonth()
	{
		String month=statementYear.getText()+statementMonth.getText();
		return month;
	}
	
	private void generateReport_9() throws Exception 
	{
		String month=getMonth();
		Integer i_month=Integer.parseInt(month);
		PriceUtil.callWVInvoiceSumm_9(i_month,cycle,reportName);
		
	}

	private void generateReport_1() throws Exception 
	{
		String month=getMonth();
		PriceMonthInfo priceInfo=PriceUtil.getRangeForMonth(month);
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
}

