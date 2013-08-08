package com.pacytology.pcs.db;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeSet;

public class SimpleTests
{
	private static Connection conn;

	public static void main(String args[]) throws Exception
	{
		conn = SimpleTestUtil.setUp().process();
		claims1500SQL();

		SimpleTestUtil.close();
	}

	private static void claims1500SQL() throws Exception 
	{

		//Get the billing queue
		SortedMap<Integer, SortedMap<String, Object>> billing = SimpleTestUtil.outputSql("select * from billing_queue where billing_route = 'PPR'");

		//see if anything in the billing queue equals the labs  we are interested in
		SortedMap<Integer, SortedMap<String, Object>> labs = getRelevantLabs(); 


		System.out.println("size of relevant labs: "+labs.size());
		if (labs.size()==0)
		{

			List<Integer>randomLabs=new ArrayList(getRandomLabNumbers(billing));
			//set some relevant labls
			//update billing_queue set lab_number = 2006041725 where lab_number = 2013009136;
			//update billing_queue set lab_number = 2008025065 where lab_number = 2013011625;

			SimpleTestUtil.executeUpdate("update billing_queue set lab_number = 2006041725 where lab_number = "+randomLabs.get(0));
			SimpleTestUtil.executeUpdate("update billing_queue set lab_number = 2008025065 where lab_number = "+randomLabs.get(1));
			labs = getRelevantLabs();
		}
		
		System.out.println("size of relevant labs: "+labs.size());
		
		SimpleTestUtil.executeUpdate("exec build_1500_claim_forms ('REPORTS_DIR','ppr_claim3.txt','PPR')");
		//SimpleTestUtil.executeUpdate("

	}

	private static SortedMap<Integer, SortedMap<String, Object>> getRelevantLabs() throws Exception {
		SortedMap<Integer, SortedMap<String, Object>> ret = SimpleTestUtil.outputSql("select * from billing_queue where lab_number = 2006041725 OR lab_number = 2006041725");
		return ret;
	}

	private static Set<BigDecimal> getRandomLabNumbers(
			SortedMap<Integer, SortedMap<String, Object>> billing) throws Exception 
			{
		Set<BigDecimal>ret=new TreeSet();
		for (Integer cur : billing.keySet())
		{
			SortedMap<String, Object> map = billing.get(cur);

			BigDecimal num=(BigDecimal) map.get("LAB_NUMBER");

			ret.add(num);

			if (ret.size()==2)
			{
				return ret;
			}
		}

		throw new Exception("not enough labs available for test");
			}
}
