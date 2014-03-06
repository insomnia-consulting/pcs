package com.pacytology.pcs.utils;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

import com.pacytology.pcs.DbConnection;

public class PriceUtil {
	private static final long MS_PER_DAY = 86400000L;
	private static Connection conn;

	public static void closeDB() throws Exception
	{
		conn.close();
	}

	static SimpleDateFormat spFormat=new SimpleDateFormat("yyyy-MM-dd");

	public static class PriceMonthInfo
	{
		Integer[]range;
		private Set<String[]> pricesAndProcedures;
		private Date[] receivedRange;

		public PriceMonthInfo(Integer[] range, Date []receivedRange, Set<String[]>pricesAndProcedures) {
			super();
			this.range = range;
			this.receivedRange= receivedRange;
			this.pricesAndProcedures = pricesAndProcedures;
		}
		public Integer[] getRange() {
			return range;
		}
		public Set<String[]> getPricesAndProcedures() {
			return pricesAndProcedures;
		}

		public String toString()	
		{
			String ret="Range: "+range[0]+" to "+range[1]+"\n";

			for (String[] priceAndProc : pricesAndProcedures)
			{
				ret+=priceAndProc[0]+" "+priceAndProc[1]+"\n";
			}
			return ret;
		}
		public static boolean contains(Set<String[]> pricesAndProcedures,
				String[] priceAndProcedure) {

			for (String [] cur : pricesAndProcedures)
			{
				if (cur[0].equals(priceAndProcedure[0]) && cur[1].equals(priceAndProcedure[1]))
				{
					return true;
				}
			}
			return false;
		}
		public SortedSet<PriceChange> getAllPriceChanges(int cycle, String program, String month) throws Exception 
		{
			SortedSet<PriceChange> all = new TreeSet();

			for (String priceAndProcedure[] : this.getPricesAndProcedures())
			{
				List<PriceChange> current = getPriceChanges(priceAndProcedure[0],priceAndProcedure[1],
						null,null,true,cycle,null,month,program);

				all.addAll(current);
			}
			return all;
		}
		public Date[] getReceivedRange() {
			return receivedRange;
		}
	}

	public static void callWVInvoiceSumm_9(Integer month, int cycle,
			String pgm) throws Exception 
	{
		CallableStatement statement=prepareCall(
				"{call pcs.build_WV_invoice_summary_9(?,"
						+ ""
						+ "?,?)}");
		try {

			statement.setInt(1,month);
			statement.setInt(2,cycle);
			statement.setString(3,pgm);
			statement.execute();
		} finally
		{
			statement.close();
		}
	}

	public static void callWVInvoiceSumm(Integer month, int cycle,
			String pgm, Date from, Date toDate, boolean toDateInclusive, int index, int total) throws Exception 
	{
		CallableStatement statement;
		statement=prepareCall(
				"{call pcs.build_WV_invoice_summary_1(?,?,?,?,?,?,?)}");

		
		if (toDateInclusive)
		{
			toDate=new Date(toDate.getTime()+MS_PER_DAY);
		}

		String all="S_MONTH := "+month+";\n"+
				"CYCLE := "+cycle+";\n"+
				"PGM :='"+pgm+"';\n"+ 
				"FROMRECEIVED := TO_DATE('"+spFormat.format(from)+"','YYYY-MM-DD');\n"+
				"TORECEIVED := TO_DATE('"+spFormat.format(toDate)+"','YYYY-MM-DD');\n"+
				"CURINDEX :="+index+";\n"+ 
				"TOTAL := "+total+";\n";

		System.out.println("all: \n"+all);

		statement.setInt(1,month);
		statement.setInt(2,cycle);
		statement.setString(3,pgm);
		statement.setDate(4,new java.sql.Date(from.getTime()));
		statement.setDate(5,new java.sql.Date(toDate.getTime()));
		statement.setInt(6,index);
		statement.setInt(7,total);

		statement.execute();
		statement.close();
	}

	public static PriceMonthInfo getRangeForMonth(String month) throws Exception 
	{
		Set<String[]> pricesAndProcedures=new HashSet();

		String sql=
				"select ps.lab_number, pr.price_code, ps.procedure_code, lr.receive_date  \n"+
						"from pcs.practice_statement_labs ps, pcs.practices pr, pcs.lab_requisitions lr  \n"+
						"where  pr.practice=ps.practice and \n"+
						"lr.lab_number=ps.lab_number and \n"+
						"ps.statement_id='"+month+"'  \n"+
						"order by lr.receive_date asc";

		Statement statement =
				getStatement();

		ResultSet rs = statement.executeQuery(sql);

		//TODO this could be more efficient
		Integer[] labs=null;
		Date[] dates=null;
		while (rs.next())
		{
			Integer lab=rs.getInt(1);
			java.sql.Date date = rs.getDate(4);
			String[] priceAndProcedure=new String[2];
			priceAndProcedure[0]=rs.getString(2);
			priceAndProcedure[1]=rs.getString(3);

			if (dates==null)
			{
				dates=new Date[2];
				dates[0]=new Date(date.getTime());
				dates[1]=new Date(date.getTime());
			}
			
			if (labs==null)
			{
				labs=new Integer[2];
				labs[0]=lab;
				labs[1]=lab;
			} 

			if (!PriceMonthInfo.contains(pricesAndProcedures,priceAndProcedure))
			{
				pricesAndProcedures.add(priceAndProcedure);
			}
			labs[1]=lab;
			dates[1]=new Date(date.getTime());
		}


		PriceMonthInfo ret=new PriceMonthInfo(labs,dates,pricesAndProcedures);
		return ret;
	}

	public static class PriceChange implements Comparable<PriceChange>
	{
		Date received;
		Integer lab;
		Float from;
		Float to;
		private String proc;
		private String priceCode;
		public PriceChange(String price, String proc, Date received, Integer lab, Float from, Float to) {
			super();
			this.proc=proc;
			this.priceCode=price;
			this.received = received;
			this.lab = lab;
			this.from = from;
			this.to = to;
		}

		@Override
		public int compareTo(PriceChange priceChange) {
			int rec=received.compareTo(priceChange.received);
			
			if (rec!=0)
			{
				return rec;
			}
			
			int time=lab.compareTo(priceChange.lab);

			if (time!=0)
			{
				return time;
			}

			int ret=proc.compareTo(priceChange.proc);

			if (ret!=0)
			{
				return ret;
			}
			ret=priceCode.compareTo(priceChange.priceCode);

			return ret;
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

	public static String combineWhereExpressions(String...expressions)
	{
		StringBuffer ret=new StringBuffer();
		for (String cur : expressions)
		{
			if (ret.length()>0 && cur!=null && cur.length()>0)
			{
				ret.append(" and ");
			}

			ret.append(cur);
		}

		return ret.toString();
	}

	public static class PriceCodeDetails
	{
		String priceCode;
		String procedureCode;
		Double basePrice;
		Double discountPrice;
		Date dateStamp;
		Integer labNumber;

		public PriceCodeDetails(String priceCode, String procedureCode,
				Double basePrice, Double discountPrice, Date dateStamp,
				Integer labNumber) {
			super();
			this.priceCode = priceCode;
			this.procedureCode = procedureCode;
			this.basePrice = basePrice;
			this.discountPrice = discountPrice;
			this.dateStamp = dateStamp;
			this.labNumber = labNumber;
		}
		public String getPriceCode() {
			return priceCode;
		}
		public String getProcedureCode() {
			return procedureCode;
		}
		public Double getBasePrice() {
			return basePrice;
		}
		public Double getDiscountPrice() {
			return discountPrice;
		}
		public Date getDateStamp() {
			return dateStamp;
		}
		public Integer getLabNumber() {
			return labNumber;
		}
		@Override
		public String toString() {
			return "PriceCodeDetails [priceCode=" + priceCode
					+ ", procedureCode=" + procedureCode + ", basePrice="
					+ basePrice + ", discountPrice=" + discountPrice
					+ ", dateStamp=" + dateStamp + ", labNumber=" + labNumber
					+ "]";
		}
	}

	//we need all the prices above a labFrom until the end, or until the next change.
	public static List<PriceCodeDetails> getPriceCodeDetails(Integer labFrom, String priceCode, String procedureCode) throws Exception
	{
		String query="select PRICE_CODE, PROCEDURE_CODE, BASE_PRICE, DISCOUNT_PRICE, DATESTAMP, LAB_NUMBER \n"+
				"from pcs.price_code_details where procedure_code='"+procedureCode+"'\n"+
				"and price_code='"+priceCode+"' and lab_number>="+labFrom+" order by lab_number asc";

		Statement statement = 
				getStatement();
		ResultSet rs = statement.executeQuery(query);

		List<PriceCodeDetails> ret=new ArrayList();
		while (rs.next())
		{
			ret.add(new PriceCodeDetails(rs.getString(1),
					rs.getString(2),rs.getDouble(3),rs.getDouble(4),
					rs.getDate(5),rs.getInt(6)));
		}

		return ret;
	}

	/**
	 * from and to are formatted MMDDYYYY
	 * 
	 * Set expectedChanges limits the results to certain changes.  Ignored if null.
	 */
	public static List<PriceChange> getPriceChanges(
			String priceCode,
			String procCode,
			Integer labFrom,
			Integer labTo,
			boolean exclusiveTo,
			Integer cycle, 
			Map<String,Float>expectedChanges,
			String month,
			String program) throws Exception 
	{
		List<PriceChange> ret=new ArrayList();

		String practiceTypeSql="";
		String procedures="";
		String prices="";
		String labFromSql="";
		String labToSql="";
		String cycleSql="";
		String fromQuery="";
		String toQuery="";
		String monthSql="";

		procedures=" ps.procedure_code = '"+procCode+"'  ";

		prices=" pr.price_code = '"+priceCode+"'  ";

		if (labFrom!=null)
		{
			labFromSql=" lr.lab_number >= "+labFrom+" ";
		}

		if (labTo!=null)
		{
			labToSql=" lr.lab_number "+(exclusiveTo?"<":"<=")+" "+labTo+" ";
		}

		if (cycle!=null)
		{
			cycleSql=" ps.billing_cycle="+cycle+" ";
		}

		if (month!=null)
		{
			monthSql=" ps.statement_id='"+month+"' ";
		}

		String programSql = " pr.program= '"+program+"' ";

		String addl=combineWhereExpressions(practiceTypeSql,procedures,prices,
				cycleSql,labFromSql,labToSql,fromQuery,toQuery,programSql,monthSql);

		String query="select lr.receive_date, ps.item_amount, ps.lab_number from \n"+
				"pcs.practice_statement_labs ps, pcs.lab_requisitions lr, pcs.practices pr \n"+
				"where pr.practice=ps.practice and pr.practice_type='WV' and lr.lab_number=ps.lab_number and \n"+
				addl+
				" order by lr.receive_date";

		Statement statement = 
				getStatement();

		ResultSet rs = statement.executeQuery(query);

		int counter=0;

		Float prev=null;
		while (rs.next())
		{
			Date received=rs.getDate(1);
			Float price=rs.getFloat(2);
			Integer lab=rs.getInt(3);

			if (prev==null)
			{
				if (!price.equals(0F))
				{
					prev=price;
				}
			} else
			{
				priceTest:
					if (!prev.equals(price) && !price.equals(0F))
					{
						if (expectedChanges!=null)
						{
							Float expected = expectedChanges.get(procCode);

							if (!price.equals(expected))
							{
								break priceTest;
							}
						}

						System.out.println(received+" "+prev+" "+procCode+"  price "+price);

						ret.add(new PriceChange(priceCode, procCode,received,lab,prev,price));
						prev=price;
					}
			}

			counter++;
		}

		return ret;
	}

	static boolean testMode=true;

	private static CallableStatement prepareCall(String sql)  throws Exception
	{
		if (conn!=null)
		{
			return conn.prepareCall(sql);
		} else
		{
			return DbConnection.process().prepareCall(sql);
		}
	}

	private static Statement getStatement() throws Exception
	{
		if (conn!=null)
		{
			return conn.createStatement();
		} 

		return DbConnection.process().createStatement();
	}


	public static int getStatementCount(String priceCode, String procedureCode,
			Integer fromLabNumber, Integer toLabNumber, Boolean exclusiveTo) throws Exception 
	{
		String countSql=
				"select count(*) from "+getStatementQuery(priceCode,procedureCode,
						fromLabNumber,toLabNumber,exclusiveTo);

		Statement count = 
				getStatement();

		ResultSet countRes = count.executeQuery(countSql);
		countRes.next();
		int ret=countRes.getInt(1);
		return ret;
	}


	private static String getStatementQuery(String priceCode,
			String procedureCode, Integer fromLabNumber, Integer toLabNumber,
			Boolean exclusiveTo) 
	{
		String toSql="";

		if (toLabNumber!=null)
		{
			toSql=" and ps.lab_number "+(exclusiveTo?"<":"<=")+ " "+toLabNumber;
		}

		String ret=" pcs.practice_statement_labs ps \n"+
				"inner join practices pr on pr.practice=ps.practice \n"+
				"where pr.price_code='"+priceCode+"' and ps.procedure_code='"+procedureCode+"' \n"+
				"and ps.lab_number>="+fromLabNumber+toSql;
		return ret;
	}

	public static int updatePrices(double previousBase, double previousDiscount, double newBase, double newDiscount, String priceCode, String procedureCode,
			Integer fromLabNumber, Integer toLabNumber, Boolean exclusiveTo, Timestamp receiveDate, boolean update,
			boolean SPECIAL_CASE_REMOVE_AFTER_SINGLE_USE_is_lab_2013057609) throws Exception 
	{
		String formattedDate=
				formatTimestamp(receiveDate);

		String select="select ps.item_amount from pcs.practice_statement_labs ps, pcs.practices pr, pcs.lab_requisitions lr \n"+
				"  where \n"+
				"pr.practice=ps.practice and lr.lab_number = ps.lab_number and pr.price_code='"+priceCode+"'\n"+
				" FROM_LAB \n TO_LAB \n"+
				"and ps.procedure_code='"+procedureCode+"' and ps.item_amount=PRICE_AMT \n"+
				"and lr.receive_date >= TO_DATE('"+formattedDate+"','DD-MM-YY')";

		if (fromLabNumber!=null)
		{
			select=select.replace("FROM_LAB"," and ps.lab_number>="+fromLabNumber);
		} else
		{
			select=select.replace("FROM_LAB","");
		}

		if (toLabNumber!=null)
		{
			select=select.replace("TO_LAB"," and ps.lab_number "+(exclusiveTo?"<":"<=")+" "+toLabNumber+" ");
		} else
		{
			select=select.replace("TO_LAB","");
		}

		//Special case for a bug.  As the variable name suggests,
		//this can be removed after being run once.
		String selectDiscount;
		if (SPECIAL_CASE_REMOVE_AFTER_SINGLE_USE_is_lab_2013057609)
		{
			selectDiscount=select.replace("ps.item_amount=PRICE_AMT","(ps.item_amount=12.85 or ps.item_amount=11.95)");
		} else
		{
			selectDiscount=select.replace("PRICE_AMT",""+previousDiscount);
		}

		String selectBase=select.replace("PRICE_AMT",""+previousBase);
	
		if (update)
		{
			String updateDiscount = "update ("+selectDiscount+") i set i.item_amount = "+newDiscount;
			String updateBase = "update ("+selectBase+") i set i.item_amount = "+newBase;
			
			Statement statement = 
					getStatement();
			statement.executeUpdate(updateDiscount);
			statement.close();
			
			statement = 
					getStatement();
			statement = 
					getStatement();
			statement.executeUpdate(updateBase);
			statement.close();
			return 0;
		} else
		{
			selectDiscount=selectDiscount.replace("select ps.item_amount", "select count(*) ");
			selectBase=selectBase.replace("select ps.item_amount", "select count(*) ");

			Statement statement =
					getStatement();

			ResultSet rsDiscount = statement.executeQuery(selectDiscount);
			rsDiscount.next();
			int discount = rsDiscount.getInt(1);
			rsDiscount.close();

			ResultSet rsBase = statement.executeQuery(selectBase);
			rsBase.next();
			int base = rsBase.getInt(1);
			rsBase.close();;

			return discount+base;
		}
	}

	static SimpleDateFormat dayMonthYear=new SimpleDateFormat("dd-MM-yy"); 
	private static String formatTimestamp(Timestamp ts) 
	{
		Date date=new Date(ts.getTime());
		return dayMonthYear.format(date);
	}


	public static Object getSingleValue(String table, String col,
			String selectCol, Object selectVal) throws Exception
	{
		ResultSet rs =null;
		Statement statement =
				getStatement();
		Object ret=null;

		try {
			if (selectVal instanceof String)
			{
				selectVal="'"+selectVal+"'";
			}

			String query="select "+col+" from "+table+" where "+selectCol+" = "+selectVal;
			rs = statement.executeQuery(query);

			if (rs.next())
			{
				ret=rs.getObject(1);
			}
		} finally
		{
			statement.close();

			if (rs!=null)
			{
				rs.close();;
			}
		}

		return ret;
	}
	
	public static Integer safeParseInteger(String str)
	{
		try {
			return Integer.parseInt(str);
		} catch (NumberFormatException e)
		{
			return null;
		}
	}

	public static List makeList(Object...obj) {
		List ret=new ArrayList();
		
		for (Object cur : obj)
		{
			ret.add(cur);
		}
		return ret;
	}
}
