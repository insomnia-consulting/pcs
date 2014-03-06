package com.pacytology.pcs;

import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.JobAttributes;
import java.awt.PageAttributes;
import java.awt.PageAttributes.OrientationRequestedType;
import java.awt.PrintJob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import java.util.Properties;

import javax.swing.JFrame;

import com.pacytology.pcs.utils.PriceUtil;

public class Detail49_51Report extends AbsractMonthlyReptDialog
{


	private String getCommentText(Connection connection, long lab) throws Exception {
		String sql="select comment_text from lab_req_comments where lab_number="+lab;
		PreparedStatement stat = connection.prepareStatement(sql);
		ResultSet res=null;
		try {
			res = stat.executeQuery(sql);

			if (res.next())
			{
				return res.getString(1);
			}
		} finally
		{
			stat.close();

			if (res!=null)
			{
				res.close();
			}
		}
		return null;
	}

	private void getData(PrintJob printJob, Connection connection, int year, int month) throws Exception
	{
		Dimension dimension = printJob.getPageDimension();

		int endData=(int) (dimension.getHeight()-40);

		String sql=
				"  select lr.lab_number,  RPAD(pt.lname||', '||pt.fname,30), pt.mi, lr.patient,\n"+
						"ld.detail_code\n"+
						"from lab_requisitions lr, lab_req_details ld, patients pt\n"+
						"  where lr.lab_number = ld.lab_number\n"+
						"        and pt.patient= lr.patient\n"+
						"        and (ld.detail_code=49 or ld.detail_code=51)\n"+
						"        and "+super.getMonthClause("lr", formatYearMonth(year,month))+"\n"+
						"  order by lr.lab_number asc";

		PreparedStatement stat = connection.prepareStatement(sql);
		ResultSet res =null;
		try {
			res = stat.executeQuery(sql);

			int counter=0;
			
			long start=System.currentTimeMillis();
			Integer lastY=null;
			while (res.next())
			{
				lastY=processNext(printJob,dimension,counter,connection,res,lastY);
				counter++;
			}

			g.dispose();
		} finally
		{
			stat.close();

			if (res!=null)
			{
				res.close();
			}
		}
	}

	private int processNext(PrintJob printJob, Dimension dimension, int counter,
			Connection connection, ResultSet res, Integer lastY) throws Exception
	{
		final int labX=20;
		final int nameX=110;
		final int detailX=380;
		final int commentX=465;
		final int pageX=725;
		
		final int commentColumnLength=45;

		final int rowHeight=16;
		final int startData=60;
		
		List<Integer>positions=PriceUtil.makeList(labX,nameX,detailX,commentX);
		List<String>header=PriceUtil.makeList("Lab #","Name","Detail Code","Comment");
		
		setSansSerif(g,11,Font.BOLD);
		
		int detailLabelY=startData-(5+rowHeight*2);
		writeLine(g,startData-(5+rowHeight),positions,header);
		
		writeLine(g,detailLabelY,pageX,"Page "+page);

		int yPos=advanceRow(g,lastY,startData,rowHeight,dimension,printJob);

		long lab = res.getLong(1);
		String name=res.getString(2);
		Integer detailCode = res.getInt(5);
		String commentText=getCommentText(connection,lab);

		setSansSerif(g,11,Font.PLAIN);

		g.drawString(""+lab,labX,yPos);
		g.drawString(name,nameX,yPos);
		
		g.drawString(""+detailCode,detailX,yPos);

		int lastCommentPosition=0;

		if (commentText!=null)
		{
 			boolean end=false;
			do
			{
				int endCommentPosition=lastCommentPosition+commentColumnLength;
				
				if (endCommentPosition>=commentText.length())
				{
					end=true;
					endCommentPosition=commentText.length();
				}
				
				String currentComment = commentText.substring(lastCommentPosition,endCommentPosition);
				lastCommentPosition=endCommentPosition;

				g.drawString(currentComment,commentX,yPos);

				lastY=yPos;
				
				end=lastCommentPosition>=commentText.length();
				
				if (!end)
				{
					yPos=advanceRow(g,lastY,startData,rowHeight,dimension,printJob);
				}
			} while (!end);
		}

		return yPos;
	}

	public void generateReport(int year, int month, Connection connection) throws Exception
	{
		getData(printJob, connection, year, month);

		printJob.end();
	}



}
