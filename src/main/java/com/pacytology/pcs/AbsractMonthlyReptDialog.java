package com.pacytology.pcs;

import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.JobAttributes;
import java.awt.PageAttributes;
import java.awt.PrintJob;
import java.awt.PageAttributes.OrientationRequestedType;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.sql.Connection;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.text.Normalizer.Form;
import java.util.List;
import java.util.Properties;

import javax.swing.JFrame;
import javax.swing.text.SimpleAttributeSet;

import com.pacytology.pcs.MonthlyReptDialog.SymAction;
import com.pacytology.pcs.MonthlyReptDialog.SymKey;
import com.pacytology.pcs.MonthlyReptDialog.SymWindow;
import com.pacytology.pcs.utils.PriceUtil;

/**
 * This is similiar in appearance to MonthReptDialog, but requires
 * the override of the actual report generation
 */
public abstract class AbsractMonthlyReptDialog extends javax.swing.JDialog implements KeyListener
{
	javax.swing.JTextField month = new javax.swing.JTextField();
	javax.swing.JTextField year = new javax.swing.JTextField();
	javax.swing.JLabel monthLabel = new javax.swing.JLabel();
	javax.swing.JLabel yearLabel = new javax.swing.JLabel();

	protected Graphics g;
	protected int page=1;
	protected PrintJob printJob;
	
	public AbsractMonthlyReptDialog()
	{
		setResizable(false);
		setModal(true);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(207,88);
		setVisible(false);
		getContentPane().add(month);
		month.setFont(new Font("SansSerif", Font.BOLD, 12));
		month.setBounds(150,12,40,20);
		getContentPane().add(year);
		year.setFont(new Font("SansSerif", Font.BOLD, 12));
		year.setBounds(150,34,40,20);
		monthLabel.setText("Month (MM)");
		getContentPane().add(monthLabel);
		monthLabel.setForeground(java.awt.Color.black);
		monthLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		monthLabel.setBounds(20,14,88,14);
		yearLabel.setText("Year (YYYY)");
		getContentPane().add(yearLabel);
		yearLabel.setForeground(java.awt.Color.black);
		yearLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		yearLabel.setBounds(20,36,98,14);

		month.addKeyListener(this);
		year.addKeyListener(this);
	}

	@Override
	public void keyReleased(KeyEvent arg0) 
	{
		try {
		String curMonth = month.getText();
		String curYear = year.getText();
		
		if (arg0.getKeyCode()==KeyEvent.VK_ENTER)
		{
			Object source = arg0.getSource();

			if (source==year && curMonth.trim().length()>0 && curYear.trim().length()>0)
			{
				this.dispose();
				
				JFrame frame=new JFrame();
				Properties props = new java.util.Properties();

				String name = new String("49/51 Detail Report");
				int xPos;
				int yPos;
				boolean gotFirstFax = true;
				PageAttributes pageAttributes=new PageAttributes();
				pageAttributes.setOrientationRequested(OrientationRequestedType.LANDSCAPE);
				JobAttributes jobAttributes=new JobAttributes();
				this.printJob=getToolkit().getPrintJob(frame,name,jobAttributes,pageAttributes);

				this.g=printJob.getGraphics();
				generateReport(Integer.parseInt(curYear),Integer.parseInt(curMonth),DbConnection.process());
			
			} else if (source==month)
			{
				year.grabFocus();
			}
		}
		} catch (Exception e)
		{
			e.printStackTrace();
		}

	}

	protected abstract void generateReport(int year, int month, Connection connection) throws Exception;

	@Override
	public void keyPressed(KeyEvent arg0) {

	}

	@Override
	public void keyTyped(KeyEvent event) {
		if (event.getSource()==month)
		{
			Utils.forceDigits(event,2);
		} else 
		{
			Utils.forceDigits(event,4);	
		}
	}

	public String getMonthClause(String labColumn, String yearAndMonth) {
		return "to_date(to_char("+labColumn+".receive_date,'YYYYMM'),'YYYYMM') = to_date("+yearAndMonth+", 'YYYYMM')";
	}

	public void setSansSerif(Graphics g, int size) {
		setSansSerif(g,size,Font.PLAIN);
	}
	
	public void setSansSerif(Graphics g, int size, int format) {
	     g.setFont(new Font("SansSerif",format,size));
	}

	static SimpleDateFormat yyyyMMFormat=new SimpleDateFormat("yyyyMM");
	static SimpleDateFormat yyyy_MFormat=new SimpleDateFormat("yyyy M");
	public static String formatYearMonth(int year, int month) throws ParseException {
		return yyyyMMFormat.format(yyyy_MFormat.parse(year+" "+month));
	}
	
	public static void main(String args[]) throws ParseException
	{
		System.out.println("date: "+formatYearMonth(2012,2));
	}
	
	protected void writeLine(Graphics g, int yPos, int xPos, String text) {
		writeLine(g,yPos,PriceUtil.makeList(xPos),PriceUtil.makeList(text));
	}

	protected void writeLine(Graphics g, int yPos, List<Integer> positions,
			List<String> text) {
		for (int index=0;index<positions.size();index++)
		{
			Integer xPos=positions.get(index);
			String cur=text.get(index);
			g.drawString(cur,xPos,yPos);
		}
	}
	
	protected int advanceRow(Graphics g, Integer lastY, int startData,
			int rowHeight, Dimension dimension, PrintJob printJob) {
		int yPos=lastY==null?startData:lastY+rowHeight;

		if (yPos+rowHeight>dimension.height)
		{
			yPos=startData;
			this.g.dispose();
			this.g=printJob.getGraphics();
			page++;
		}
		return yPos;
	}
}
