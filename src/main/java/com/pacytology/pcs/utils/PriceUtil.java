package com.pacytology.pcs.utils;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;

import org.apache.commons.lang.time.DateUtils;
import org.apache.ibatis.session.ResultContext;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.SqlSession;
import org.joda.time.MutableDateTime;

import com.pacytology.pcs.DbConnection;

public class PriceUtil {
	private static Connection conn;

	private static void openDB() throws Exception
	{
		conn=DriverManager.getConnection
				("jdbc:oracle:thin:@127.0.0.1:1521:pcsdev",
						"pcs",
						"ahb21");
	}


	public static void closeDB() throws Exception
	{
		conn.close();
	}

	static SimpleDateFormat spFormat=new SimpleDateFormat("yyyy-MM-dd");

	public static class PriceMonthInfo
	{
		Integer[]range;
		private Set<String[]> pricesAndProcedures;


		public PriceMonthInfo(Integer[] range, Set<String[]>pricesAndProcedures) {
			super();
			this.range = range;
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
		public SortedSet<PriceChange> getAllPriceChanges(int cycle, String program) throws Exception 
		{
			SortedSet<PriceChange> all = new TreeSet();

			for (String priceAndProcedure[] : this.getPricesAndProcedures())
			{
				List<PriceChange> current = getPriceChanges(priceAndProcedure[0],priceAndProcedure[1],
						range[0],range[1],
						true,cycle,null,program);
				all.addAll(current);
			}
			return all;
		}
	}

	//87621 88142
	public static void main(String args[]) throws Exception
	{
		openDB();
		try {
			boolean findChanges=false;
			boolean full=true;
			Map<String,Float>expectedChanges=null;

			if (full)
			{
				String month="201311";
				String program="FPP";

				PriceMonthInfo priceInfo=getRangeForMonth(month);

				int cycle=2;
				Integer[] range = priceInfo.getRange();

				SortedSet<PriceChange> all = priceInfo.getAllPriceChanges(cycle,program);

				System.out.println("Number of changes: "+all.size()+"\n"+all);

				Integer i_month=Integer.parseInt(month);

				if (all.size()==0)
				{
					callWVInvoiceSumm(i_month,cycle,program,range[0],range[1],1,1);
				} else
				{
					Integer from=range[0];
					int counter=0;
					for (PriceChange cur : all)
					{
						Integer to = cur.getLab();
						callWVInvoiceSumm(i_month,cycle,program,from,to,counter+1,all.size()+1);
						from=to;
						counter++;
					}

					callWVInvoiceSumm(i_month,cycle,program,from,range[1]+1,counter+1,all.size()+1);
				}

			}
		} catch (Throwable t)
		{
			t.printStackTrace();;
		}
		finally 
		{
			closeDB();
		}
	}


	public static void callWVInvoiceSumm_9(Integer month, int cycle,
			String pgm) throws Exception 
	{
		CallableStatement statement=prepareCall(
				"{call pcs.build_WV_invoice_summary_1(?,?,?)}");
		
		statement.setInt(1,month);
		statement.setInt(2,cycle);
		statement.setString(3,pgm);
	}
	
	public static void callWVInvoiceSumm(Integer month, int cycle,
			String pgm, Integer from, Integer to, int index, int total) throws Exception 
	{
		CallableStatement statement;
		statement=prepareCall(
				"{call pcs.build_WV_invoice_summary_1(?,?,?,?,?,?,?)}");

		String all="S_MONTH := "+month+";\n"+
				"CYCLE := "+cycle+";\n"+
				"PGM :='"+pgm+"';\n"+ 
				"FROMLAB := "+from+";\n"+
				"TOLABEXCLUSIVE := "+to+";\n"+
				"CURINDEX :="+index+";\n"+ 
				"TOTAL := "+total+";\n";

		System.out.println("all: \n"+all);

		statement.setInt(1,month);
		statement.setInt(2,cycle);
		statement.setString(3,pgm);
		statement.setInt(4,from);
		statement.setInt(5,to);
		statement.setInt(6,index);
		statement.setInt(7,total);

		statement.execute();
		statement.close();
			}




	public static PriceMonthInfo getRangeForMonth(String month) throws Exception 
	{
		Set<String[]> pricesAndProcedures=new HashSet();

		String sql=
				"select ps.lab_number, pr.price_code, ps.procedure_code  \n"+
						"from pcs.practice_statement_labs ps  \n"+
						"inner join pcs.practices pr on pr.practice=ps.practice where \n"+ 
						"ps.statement_id='"+month+"'  \n"+
						"order by ps.lab_number asc";
		//"select ps.lab_number, ps.price_code, ps.procedure_code from pcs.practice_statement_labs ps where statement_id='"+month+"' order by ps.lab_number asc";

		Statement statement =
				getStatement();

		ResultSet rs = statement.executeQuery(sql);


		Integer[] labs=null;
		while (rs.next())
		{
			Integer lab=rs.getInt(1);
			String[] priceAndProcedure=new String[2];
			priceAndProcedure[0]=rs.getString(2);
			priceAndProcedure[1]=rs.getString(3);

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
		}


		PriceMonthInfo ret=new PriceMonthInfo(labs,pricesAndProcedures);
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
				"from price_code_details where procedure_code='"+procedureCode+"'\n"+
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

		String programSql = " pr.program= '"+program+"' ";

		String addl=combineWhereExpressions(practiceTypeSql,procedures,prices,
				cycleSql,labFromSql,labToSql,fromQuery,toQuery,programSql);

		String query="select lr.receive_date, ps.date_collected,\n"+
				" ps.item_amount, ps.lab_number from \n"+
				"pcs.practice_statement_labs ps, pcs.lab_requisitions lr, pcs.practices pr \n"+
				"where pr.practice=ps.practice and pr.practice_type='WV' and lr.lab_number=ps.lab_number and \n"+
				addl+
				" order by ps.lab_number";

		Statement statement = 
				getStatement();

		ResultSet rs = statement.executeQuery(query);

		int counter=0;

		Float prev=null;
		while (rs.next())
		{
			Date received=rs.getDate(1);
			Date collected=rs.getDate(2);
			Float price=rs.getFloat(3);
			Integer lab=rs.getInt(4);
			//String l_priceCode=rs.getString(6);

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
			Integer fromLabNumber, Integer toLabNumber, Boolean exclusiveTo, boolean update) throws Exception 
			{		

		String select="select ps.item_amount from pcs.practice_statement_labs ps \n"+
				"inner join pcs.practices pr on pr.practice=ps.practice where \n"+
				"pr.price_code='"+priceCode+"' and ps.lab_number>="+fromLabNumber+" TO_LAB \n"+
				"and ps.procedure_code='"+procedureCode+"' and ps.item_amount=PRICE_AMT";

		if (toLabNumber!=null)
		{
			select=select.replace("TO_LAB"," and ps.lab_number "+(exclusiveTo?"<":"<=")+" "+toLabNumber+" ");
		} else
		{
			select=select.replace("TO_LAB","");
		}

		String selectDiscount=select.replace("PRICE_AMT",""+previousDiscount);
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




}
