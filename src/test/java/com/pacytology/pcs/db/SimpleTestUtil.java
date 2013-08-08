package com.pacytology.pcs.db;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.util.Date;
import java.util.Properties;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Vector;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.Login;
import com.pacytology.pcs.PCSLabEntry;
public class SimpleTestUtil
{
	public static void main(String args[]) throws Exception
	{
		System.setProperty("jdbc.connection","jdbc:oracle:thin:@192.168.0.106:1521:pcsdev");
		String e = System.getProperty("jdbc.connection");
		mainApp();
		
		if (true)return;
		setUp();
	}
	 private static void mainApp() 
	 {
		PCSLabEntry.main(null);
	}
	static Properties props = new Properties();
	    private static DbConnection conn;
	    
	    public static DbConnection setUp() throws Exception 
	    {
	    
	        Login dbLogin = new Login();
	        dbLogin.dateToday = new Date().toString();
	        dbLogin.driver = "oracle.jdbc.driver.OracleDriver";
	        dbLogin.URL = "jdbc:oracle:thin:@192.168.0.103:1521:pcsdev";
	        dbLogin.userName = "pcs";
	        dbLogin.userPassword = "ahb21";
	        props.put("username", dbLogin.userName);
	        props.put("password", dbLogin.userPassword);
	        props.put("jdbc.connection", dbLogin.URL);

	        conn=new DbConnection(dbLogin);
	        System.out.println("conn: "+conn);
	        
	        Vector vect=new Vector();
	        Vector params=new Vector();
	        params.add(new com.pacytology.pcs.SQLValue(
	        		-2));
	        	//XXX not visible
	        		//DbConnection.STRING));
	        
	        //Vector vect2 = conn.query("select a.DOCTOR_TEXT from lab_requisitions a where rownum<10",params,vect);
	        
	        PreparedStatement stat = conn.process().prepareStatement("select DOCTOR_TEXT from lab_requisitions where rownum<10");
	        
	        ResultSet rs = stat.executeQuery();
	        return conn;
	    }
	    
	    public static void close()
	    {
	    	conn.close();
	    }
	    
	    public static SortedMap<Integer,SortedMap<String,Object>> mapRs(ResultSet rs) throws Exception 
	    {
	    	ResultSetMetaData rsmd = rs.getMetaData();

	    	int numCols = rsmd.getColumnCount();

	    	int counter=0;
	    	SortedMap<Integer, SortedMap<String, Object>> ret=new TreeMap();
			while (rs.next())
	    	{
	    		SortedMap<String,Object>current=new TreeMap();
	    		for (Integer col=0;col<numCols;col++)
	    		{
	    			Object ob = rs.getObject(col+1);
	    			String name = rsmd.getColumnName(col+1);
	    			current.put(name,ob);
	    		}
	    		ret.put(counter,current);
	    		
	    		counter++;
	    	}
	    	return ret;
		}

		public void testAscusUnder21() {
/*
	        PCSLabEntry.sqlSessionFactory(props);
	        int labNumber = 2013011947;

	        HpvRequestDbOps.set_hpv(labNumber);

	        boolean hpv = HpvRequestDbOps.isHpv(labNumber);
	        assertFalse(hpv);
*/
	    
	}
		public static SortedMap<Integer, SortedMap<String, Object>> outputSql(String sql) throws Exception {
			PreparedStatement stat = conn.process().prepareStatement(sql);
			ResultSet rs = stat.executeQuery();
			return outputRs(rs);
		}
		private static SortedMap<Integer, SortedMap<String, Object>> outputRs(ResultSet rs) throws Exception {
			SortedMap<Integer, SortedMap<String, Object>> map = mapRs(rs);
		 
			String str = rsToString(map);
			System.out.println("db: "+str);
			return map;
		}
		private static String rsToString(
				SortedMap<Integer, SortedMap<String, Object>> map) 
		{
			StringBuilder ret=new StringBuilder();
			for (Integer cur : map.keySet())
			{
				ret.append("********************* "+cur+" ***********************\n");
				SortedMap<String, Object> colsToObj = map.get(cur);
				
				for (String col : colsToObj.keySet())
				{
					Object obj=colsToObj.get(col);
					ret.append(col+"	->		"+obj+"\n");
					
				}
			}
			
			return ret.toString();
		}
		public static int executeUpdate(String sql) throws Exception
		{
			Statement state = conn.process().createStatement();
			return state.executeUpdate(sql);
		}
		public static DbConnection getConn() {
			return conn;
		}
		
		
}
