package com.pacytology.pcs.db;

import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

public class PriceUtil {
	//87621 88142
	public static void main(String args[]) throws Exception
	{
		Map<String,Float>expectedChanges=null;
		//Map<String,Float>expectedChanges=new TreeMap();
		//expectedChanges.put("87621",28.0F);
		List<PriceChange> all = getPriceChanges("02012001", "03012013", true, 2, expectedChanges, "87621","88142");

		System.out.println("Number of changes: "+all.size()+"\n"+all);
	}

	private static class PriceChange
	{
		Date received;
		Integer lab;
		Float from;
		Float to;
		private String proc;
		public PriceChange(String proc, Date received, Integer lab, Float from, Float to) {
			super();
			this.proc=proc;
			this.received = received;
			this.lab = lab;
			this.from = from;
			this.to = to;
		}
		public Date getReceived() {
			return received;
		}
		public Integer getLab() {
			return lab;
		}
		public Float getFrom() {
			return from;
		}
		public Float getTo() {
			return to;
		}
		public String getProc() {
			return proc;
		}
		@Override
		public String toString() {
			return "DateChange [received=" + received + ", lab=" + lab
					+ ", from=" + from + ", to=" + to + ", proc=" + proc + "]";
		}

	}

	/**
	 * from and to are formatted MMDDYYYY
	 * 
	 * Set expectedChanges limits the results to certain changes.  Ignored if null.
	 */
	private static List<PriceChange> getPriceChanges(String from, String to, boolean exclusiveTo, int cycle, Map<String,Float>expectedChanges, String...limitToProcedures) throws Exception 
	{
		List<PriceChange> ret=new ArrayList();
		SimpleTestUtil.openDB();
		String procedures="";

		if (limitToProcedures!=null)
		{
			for (String proc : limitToProcedures)
			{
				if (procedures.length()>0)
				{
					procedures+=", ";
				}

				procedures+="'"+proc+"'";
			}

			procedures=" ps.procedure_code in ("+procedures+") and ";
		}

		String fromQuery=" lr.receive_date >= to_date('"+from+"','MMDDYYYY')";
		String toQuery=" lr.receive_date "+(exclusiveTo?"<":"<=")+" to_date('"+to+"','MMDDYYYY')";

		String query="select lr.receive_date, ps.date_collected,\n"+
				"ps.procedure_code, ps.item_amount, ps.lab_number from \n"+
				"pcs.practice_statement_labs ps, pcs.lab_requisitions lr, practices pr \n"+
				"where pr.practice=ps.practice and pr.practice_type='WV' and "+procedures +" ps.billing_cycle="+cycle+" and lr.lab_number=ps.lab_number and \n"+
				fromQuery+" and "+toQuery+" \n"+
				"order by ps.lab_number";

		Statement statement = SimpleTestUtil.getStatement();
		ResultSet rs = statement.executeQuery(query);

		int counter=0;

		Map<String,Float>prices=new TreeMap();

		while (rs.next())
		{
			Date received=rs.getDate(1);
			Date collected=rs.getDate(2);
			String proc=rs.getString(3);
			Float price=rs.getFloat(4);
			Integer lab=rs.getInt(5);

			Float prev = prices.get(proc);

			if (prev==null)
			{
				prices.put(proc,price);
			} else
			{
				priceTest:
				if (!prev.equals(price) && !price.equals(0F))
				{
					if (expectedChanges!=null)
					{
						Float expected = expectedChanges.get(proc);

						if (!price.equals(expected))
						{
							break priceTest;
						}
					}
					
					System.out.println(received+" "+prev+" "+proc+"  price "+price);
					prices.put(proc,price);

					ret.add(new PriceChange(proc,received,lab,prev,price));
				}
			}

			if (counter%100==0)
			{
				//System.out.println(counter+" "+received+" "+lab+" "+proc+" "+price);
			}
			//System.out.println(counter+" "+received+" "+proc+" "+price+" "+lab);
			counter++;
		}

		SimpleTestUtil.closeDB();


		return ret;
	}

}
