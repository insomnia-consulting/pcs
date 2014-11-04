package com.pacytology.pcs.db;

import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Date;
import java.util.Properties;

import org.joda.time.DateTime;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.Login;

public class HpvTest {
	
	
	private static DbConnection conn;


	public static void main(String args[]) throws Exception
	{
		setUpDatabase();
		
		//All labs that are billed as not DOC
		String sql="select lr.lab_number " +
				"from pcs.billing_choices bc,pcs.lab_billings lb, pcs.lab_requisitions lr, pcs.hpv_request hpv " +
				"where "+ 
				"hpv.lab_number = lr.lab_number " +
				"and bc.billing_choice=lb.billing_choice " +
				"and bc.choice_code!='DOC' " +
				"and lb.lab_number = lr.lab_number " +
				"order by lab_number ";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(sql);
		
		int notDocCounter=0;
		int numRebilledAsDoc=0;
		int hpvSentCounter=0;
		
		while (rs.next())
		{
			notDocCounter++;
			int lab = rs.getInt(1);
			
			
			
			//All of those that were rebilled as doc
			
			String billingSQL = "select bd.rebilling " +
					" from billing_details bd, billing_choices bc " +
					" where bd.lab_number = "+lab+
					" and bd.billing_choice = bc.billing_choice and bc.choice_code='DOC' ";
			
			Statement billingStat = DbConnection.process().createStatement();
			ResultSet billingRs = billingStat.executeQuery(billingSQL);
			
			while (billingRs.next())
			{
				int num = billingRs.getInt(1);
				numRebilledAsDoc++;
				System.out.println("notDocCounter: "+notDocCounter+" numRebilledAsDoc: "+numRebilledAsDoc+" lab: "+lab);
			}
			billingStat.close();
			billingRs.close();
			System.out.println("notDocCounter: "+notDocCounter+" hpvSentCounter: "+hpvSentCounter+" numRebilledAsDoc: "+numRebilledAsDoc+" lab: "+lab);

		}
		
		System.out.println("Total notDocCounter: "+notDocCounter);
		rs.close();
	}
	

	public static DbConnection setUpDatabase() throws Exception 
	{
		Properties props = new Properties();
		System.out.println("Setting up...");
		Login dbLogin = new Login();
 		dbLogin.dateToday = DateTime.now().toString();
		dbLogin.driver = "oracle.jdbc.driver.OracleDriver";
		
		dbLogin.userName = "pcs";
		dbLogin.userPassword = "abh21";
		props.put("username", dbLogin.userName);
		props.put("password", dbLogin.userPassword);
		props.put("jdbc.connection", dbLogin.URL);

		conn=new DbConnection(dbLogin);

		System.out.println("Set up finished");
		return conn;
	}
}
