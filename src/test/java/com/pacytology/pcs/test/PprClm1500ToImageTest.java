package com.pacytology.pcs.test;

import java.sql.CallableStatement;
import java.sql.Connection;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.TestUtils;
import com.pacytology.pcs.util.TextImageOverlay;
import com.pacytology.pcs.util.Utility;

public class PprClm1500ToImageTest {
	public static void main(String args[]) throws Exception
	{
		//Run the report--doesn't work I don't think
		boolean newReport=false;
		
		boolean newForm=true;
		
		if (newReport)
		{
			Connection proc1 = DbConnection.process();
            CallableStatement cstmt;
	        cstmt=DbConnection.process().prepareCall(
	            "{call pcs.build_1500_claim_forms(?,?,?)}");
            cstmt.setString(1,"REPORTS_DIR");
            cstmt.setString(2,"ppr_clm");
            cstmt.setString(3,"PPR");
            cstmt.executeUpdate();
		}	
		
		//TODO copy the report to the below location and strip it of all but one
		//page, or add multi-page functionality.
		boolean grid=false;
		boolean markedUp=false;
		
		String single=
				"/u01/reports/ppr_clm";
				//"/home/oracle/reports/ppr_single.txt";
		
		if (grid)
		{
			single="/home/oracle/Desktop/notes/scratch/162/ppr_clm_grid.txt";
		}
		
		if (markedUp)
		{
			single="/home/oracle/Desktop/notes/scratch/162/ppr_clm_marked_up";
		}
		

		
		//Superimpose the report to the form.
		String cms1500=getCmsForm(newForm);
		
		String fileName;
		
		if (markedUp)
		{
			fileName="MARKED_UP.png";
		} else
		if (grid)
		{
			fileName="GRID.png";
		} else
		{
			fileName=(newForm?"NEW":"OLD")+"_cms1500_"+Utility.currentTimeFormattedForFileSystems()+".png";
		}
		String destImage="/home/oracle/reports/"+fileName;
		
		TextImageOverlay.superimposeTextOnImage(single,
				cms1500,
				destImage,1000);

		TextImageOverlay.popupChrome(destImage);
	}

	private static String getCmsForm(boolean newCms) {
		String cms1500=
				newCms?"/home/oracle/reports/cms_new.png"
						:"/home/oracle/reports/cms_old.png";
		
		return cms1500;
	}
	
}
