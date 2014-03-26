package com.pacytology.pcs.db;

import java.awt.AWTEvent;
import java.awt.Component;
import java.awt.Label;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.Toolkit;
import java.awt.event.AWTEventListener;
import java.awt.event.ContainerEvent;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Scanner;
import java.util.Set;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Vector;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.imageio.ImageIO;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.text.JTextComponent;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.Detail49_51Report;
import com.pacytology.pcs.Login;
import com.pacytology.pcs.PCSLabEntry;
public class SimpleTestUtil
{
	static boolean outNoOthers=false;
	private static PrintStream m_out;

	private static DbConnection conn;



	public static void main(String args[]) throws Exception
	{
		if (false)
		{
			markUpSql();
			return;
		}
		
		if (false)
		{
			test4951();
			return;
		}
		
		if (false)
		{
			return;
		}

		if (false)
		{
			///bin/sh -c "mv /Desktop/Patient_Statement_namexzz.pdf ~/Desktop/reports/"
			//			Runtime.getRuntime().exec("/bin/sh -c \"mv /home/oracle/Desktop/Patient_Statement_namexzz.pdf /home/oracle/Desktop/reports/\"");

			Runtime.getRuntime().exec(new String[]{"mv","/home/oracle/Desktop/Patient_Statement_namexzz.pdf","/home/oracle/Desktop/reports/"});
			return;
		}

		if (false)
		{
			Thread.sleep(2000); 
			System.out.println("ok... KeyEvent.VK_LEFT: "+KeyEvent.VK_LEFT);
			Robot robot=new Robot();
			robot.keyPress(KeyEvent.VK_LEFT);
			robot.keyRelease(KeyEvent.VK_LEFT);
			if (true) return;
		}
		System.setProperty("jdbc.connection","jdbc:oracle:thin:@127.0.0.1:1521:pcsdev");
		System.setProperty("host.ip","127.0.0.1");
		System.setProperty("host.pwd","123456");
		System.setProperty("java.io.tmpdir","/tmp/");



		if (false)
		{
			issue77();
			return;
		}

		if (false)
		{
			new Thread()
			{
				public void run()
				{
					try {
						testPriceCodes();
					} catch (Exception e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}
			}.start();
		}

		if (true)
		{
			lookForPatientAccounts();
		}


		String e = System.getProperty("jdbc.connection");
		startGUIWatcher();
		mainApp();

		if (true)return;
		setUp();
	}

	/**
	 * Designed to put line numbers on the Xs in reports to make it easier
	 * to associate the output with its code. 
	 */
	
	private static void markUpSql() throws Exception {
		String file="/home/oracle/Desktop/notes/scratch/162/1500_pre_changes.txt";
		File out=new File("/home/oracle/Desktop/notes/scratch/162/1500_pre_changes_marked_up.txt");
		
		Scanner scanner=new Scanner(new File(file));
		writeFile(out,"",false);
		int counter=1;
		Pattern putf=Pattern.compile("(.*?UTL_FILE.PUTF\\()(.*?)(\\).*?)$");
		while (scanner.hasNextLine())
		{
			String line=scanner.nextLine();
			
			Matcher matcher=putf.matcher(line);
			if (matcher.find())
			{
				String start=matcher.group(1);
				String mid=matcher.group(2);
				
				String[] args = mid.split(",");
				
				mid="";
				
				for (int index=0;index<args.length;index++)
				{
					if (index!=0)
					{
						mid+=",";
					}
					
					String cur=args[index];

					if (index==args.length-1)
					{
						cur=cur+"||''||'("+counter+")'";
					}
					
					mid+=cur;
			
				}
				
				String end=matcher.group(3);
				
				line=start+mid+end;
			}
			writeFile(out,line,true);
			writeFile(out,"\n",true);
	

			// UTL_FILE.PUTF(label_file,'%s\n',curr_line);  
			/*
			line=line.replaceAll("'X'","'X"+counter+"'");
			writeFile(out,line,true);
			writeFile(out,"\n",true);
			*/
			counter++;
		}
		System.out.println("out: "+out);
	}

	private static void test4951() throws Exception {
		Detail49_51Report rep = new Detail49_51Report();
		DbConnection l_conn = setUp();
		try {
		
		new Thread()
		{
			public void run()
			{
				System.out.println("sleeping...");
				try {
					Thread.sleep(4000);
					System.out.println("Starting...");
					Robot robot = new Robot();
					robot.keyPress(KeyEvent.VK_ENTER);
					robot.keyRelease(KeyEvent.VK_ENTER);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			
		}.start();
		rep.generateReport(2012,2,l_conn.process());
		
		Runtime.getRuntime().exec("mv /home/oracle/Desktop/51_Detail_Report.pdf  /home/oracle/Desktop/reports/51_Detail_Report_"+System.currentTimeMillis()+".pdf");
		} finally
		{
			l_conn.close();
		}
	}

	private static void testPriceCodes() throws Exception 
	{
		while (true)
		{
			Connection proc1 = DbConnection.process();
			if (proc1!=null && !proc1.isClosed())
			{

				String sql="select  * from price_code_details order by price_code, procedure_code";

				Statement stmt = DbConnection.process().createStatement();
				ResultSet rs = stmt.executeQuery(sql);

				HashSet hash=new HashSet();
				while (rs.next())
				{
					String price=rs.getString("price_code");
					String proc=rs.getString("procedure_code");
					String cur=price+"_"+proc;

					System.out.println("cur: "+cur);
					if (hash.contains(cur))
					{
						System.out.println("dupe: "+cur);
						return;
					}
					hash.add(cur);

				}
			} else
			{
				Thread.sleep(25);
			}
		}
	}

	private static void issue77() throws Exception 
	{
		startConnection();

		if (true) throw new Exception("First, set up some method to copy anything from patient_accounts_in_coll_temp into patient_accounts_in_collection that isn't there."+
				"\n Then catalog how patient_accounts_in_collection (especially .sent) is populated");

		String sql="select count(*) from lab_requisitions";
		Statement stmt = DbConnection.process().createStatement();
		ResultSet rs = stmt.executeQuery(sql);
		System.out.println("rs: "+rs.next());

	}

	private static void startConnection() throws Exception
	{
		//Connection dbProc = DriverManager.getConnection(
		//       "jdbc:oracle:thin:@127.0.0.1:1521:pcsdev","pcs","ahb21");
		try {
			Login log = new Login();
			log.userName="pcs";
			log.userPassword="abh21";

			new DbConnection(log);
		} catch (Exception e)
		{
			//catching meaningless error
		}
	}

	protected static void update(String sql) throws Exception
	{
		Connection proc = DbConnection.process();

		Object ret=null;

		if (proc!=null && !proc.isClosed())
		{
			Statement stmt = DbConnection.process().createStatement();
			stmt.executeUpdate(sql);
			stmt.close();
		}
	}

	protected static Object singleValue(String sql, String col) throws Exception
	{
		Connection proc = DbConnection.process();

		Object ret=null;

		if (proc!=null && !proc.isClosed())
		{
			Statement stmt = DbConnection.process().createStatement();
			ResultSet rs = stmt.executeQuery(sql);

			if (rs.next())
			{
				ret=rs.getInt(col);
			}

			stmt.close();
			rs.close();
		} else
		{

		}
		return ret;
	}

	protected static Integer getHighestPatient() throws Exception
	{
		String sql = "select PATIENT from pcs.patient_statements order by datestamp desc";
		return (Integer) singleValue(sql,"PATIENT");
	}

	private static void lookForPatientAccounts() {
		new Thread()
		{
			public void run()
			{
				try {
					subRun();
				} catch (Exception e)
				{
					e.printStackTrace();
				}

			}

			public void subRun()
			{
				int cycleCounter=-1;
				int counter=0;
				//int num=-1;

				Map<String,Integer>mapOfInitialNums=new TreeMap();
				Map<String,List>mapOfAllNums=new TreeMap();


				Set<String>allSql=new TreeSet();
				String sql1=
						"select count(*) from pcs.patient_statements";

				//allSql.add(sql1);

			
				allSql.add("select count(*) from pcs.lab_requisitions");
				allSql.add("select count(*) from pcs.billing_queue");
				allSql.add("select count(*) from pcs.billing_details");
				
				allSql.add("select count(*) from pcs.lab_billings");
				allSql.add("select count(*) from pcs.patient_accounts");
				allSql.add("select count(*) from pcs.patient_statements");

				Integer highestPatientId=null;

				allSql.add("select count(*) from pcs.patients");

				/*
         select billing_type,rebill_code,rebilling 
         into P_bill_type,P_rebill_code,P_rebilling
         from pcs.patient_statements
         where patient=2423828 and lab_number=P_lab_num;				 
				 */



				Set<String>outOnce=new TreeSet();

				int connectedCounter=0;
				while(true)
				{
					cycleCounter++;

					//	"select count(*) from pcs.billing_queue";
					//"select count(*) from pcs.patient_accounts pa, pcs.lab_requisitions lb where pa.lab_number= lb.lab_number and pa.lab_number= lb.lab_number";
					//"select count(*) from lab_billings";
					//"select  count(*) from pcs.patient_accounts";


					try {

						Connection proc = DbConnection.process();


						if (proc!=null && !proc.isClosed())
						{
							if (connectedCounter==0)
							{
								//deleteAllCustomPrices();
							}

							//String sql="select  count(*) from pcs.patient_accounts";

							boolean firstNewVal=true;
							String add=null;
							String lastLab=
									null;
							//LabForm.lastLab_dontCommit;
							for (String cur : allSql)
							{
								highestPatientId=getHighestPatient();
								if (highestPatientId!=null && highestPatientId!=2409324 && 
										lastLab!=null && lastLab.length()==10)
								{

									add="select count(*) from pcs.patient_statements where patient=PATIENT_ID and lab_number="+lastLab;
									add=add.replace ("PATIENT_ID",highestPatientId+"");
								}

								Statement stmt = DbConnection.process().createStatement();
								ResultSet rs = stmt.executeQuery(cur);

								if (rs.next())
								{
									int val=rs.getInt(1);


									Integer num=mapOfInitialNums.get(cur);

									if (num==null)
									{
										num=val;
										mapOfInitialNums.put(cur,num);
										putToListOfValues(cur,num,mapOfAllNums);
									}


									List nums=mapOfAllNums.get(cur);

									boolean newVal=val!=((Integer)nums.get(nums.size()-1));


									if (newVal)
									{
										//	screenShot(cur);
										putToListOfValues(cur,val,mapOfAllNums);

									} 

									String out = counter+" "+cur+"; val: "+nums;

									if (newVal)
									{
										if (firstNewVal)
										{
											outNoOthers("--------------------------------------------------------");
										} 
										firstNewVal=false;

										outNoOthers(out);
									} 


									//else if (cycleCounter==0)
									else if (!outOnce.contains(cur))
									{
										outOnce.add(cur);
										outNoOthers(out);
										//System.out.println(out);
									}

									if (false && val!=num)
									{
										System.out.println("STOP "+val);
										//System.exit(0);
										pause(10000000);
										mapOfInitialNums.put(cur,val);
									}
								}
								rs.close();
								stmt.close();
							}
							if (add!=null)
							{
								allSql.add(add);
							}
							connectedCounter++;
						} else
						{
							System.out.println(counter+" ... no conn");
						}
					} catch (Exception e)
					{
						e.printStackTrace();
					} finally
					{
						try {
							Thread.sleep(200);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
						counter++;
					}
				}
			}
		}.start();
	}

	protected static void deleteAllCustomPrices() throws Exception 
	{
		update("delete from price_code_details where lab_number <> 0");
	}

	protected static void outNoOthers(Object out) 
	{
		outNoOthers(out,true);
	}

	protected static void outNoOthers(Object out, boolean enable) 
	{
		if (!enable || !outNoOthers)
		{
			System.out.println(out);
			return;
		}

		if (m_out==null)
		{
			m_out=System.out;

			OutputStream newOut=new OutputStream() {

				@Override
				public void write(int b) throws IOException {

				}
			};
			System.setOut(new PrintStream(newOut));
			System.setErr(System.out);
		}

		m_out.println(out);
	}
	protected static void pause(int i) {
		try {
			synchronized (stopMutex)
			{
				stopMutex.wait(i);
			}
			int x=1;
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	private static void mainApp() 
	{
		PCSLabEntry.main(null);
	}
	static Properties props = new Properties();


	public static DbConnection setUp() throws Exception 
	{
		System.out.println("Setting up...");
		Login dbLogin = new Login();
		dbLogin.dateToday = new Date().toString();
		dbLogin.driver = "oracle.jdbc.driver.OracleDriver";
		dbLogin.URL = "jdbc:oracle:thin:@localhost:1521:pcsdev";
		dbLogin.userName = "pcs";
		dbLogin.userPassword = "abh21";
		props.put("username", dbLogin.userName);
		props.put("password", dbLogin.userPassword);
		props.put("jdbc.connection", dbLogin.URL);

		conn=new DbConnection(dbLogin);

		Vector vect=new Vector();
		Vector params=new Vector();
		params.add(new com.pacytology.pcs.SQLValue(
				-2));
		
		System.out.println("Set up finished");
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

	static Set<Component>added=new HashSet();

	static int mouseCounter=0;

	static int curCounter=0;
	public static Object stopMutex=new Object();
	public static void add(Component comp)
	{
		if (added.contains(comp))
		{
			return;
		}
		added.add(comp);

		comp.addMouseListener(new MouseListener() {
			@Override
			public void mouseReleased(MouseEvent e)
			{
				curCounter--;

				if (curCounter==0)
				{
					System.out.println("****************************************\n");
				}


			}

			@Override
			public void mousePressed(MouseEvent e)
			{
				Component comp = (Component) e.getSource();

				boolean output=true;

				if (output)
				{
					System.out.println("------------- "+mouseCounter+" -----------\n"+e.getSource()+":\nbounds: "+comp.getBounds());

					String text=getText(comp);

					if (text!=null)
					{
						System.out.println("Text: '"+text+"'");
					}
				}
				mouseCounter++;

				curCounter++;

			}

			@Override
			public void mouseExited(MouseEvent e) {
			}

			@Override
			public void mouseEntered(MouseEvent e) {
			}

			@Override
			public void mouseClicked(MouseEvent e) {
			}
		});
	}

	protected static String getText(Component comp) 
	{
		if (comp instanceof JTextComponent)
		{
			return ((JTextComponent)comp).getText();
		}

		if (comp instanceof JLabel)
		{
			return ((JLabel)comp).getText();
		}

		if (comp instanceof JCheckBox)
		{
			return ((JCheckBox)comp).getText();
		}

		return null;

	}
	private static void startGUIWatcher()
	{
		long eventMask =
				AWTEvent.CONTAINER_EVENT_MASK;

		Toolkit.getDefaultToolkit().addAWTEventListener( new AWTEventListener()
		{
			public void eventDispatched(AWTEvent e)
			{
				if (!(e instanceof ContainerEvent))
				{
					return;
				}

				ContainerEvent ce=(ContainerEvent) e;
				Component child = ce.getChild();
				String str = e.paramString();
				int id = e.getID();
				Component source = (Component) e.getSource();
				//		                System.out.println(str+": "+source);

				if (str.contains("COMPONENT_ADDED"))
				{
					add(child);

					child.addMouseMotionListener(new MouseAdapter() 
					{
						@Override
						public void mouseMoved(MouseEvent e)
						{
							Component comp=(Component) e.getSource();

							if (comp instanceof JLabel)
							{
								JLabel label=(JLabel)comp;
								System.out.println("text: "+label.getText());
							}		
							if (comp instanceof Label)
							{
								Label label=(Label)comp;
								System.out.println("ltext: "+label.getText());
							}
						}
					});


					boolean lookingForSomething=true;

					if (lookingForSomething)
					{
						if (child.getX()==4 && child.getY()==405 && child.getWidth()==310 && child.getHeight()==44)
						{
							int x=1;
						}
					}
				} else if (str.contains("COMPONENT_REMOVED"))
				{
					added.remove(child);


				}
			}
		}, eventMask);    
	}


	public static List putToListOfValues(Object key, Object val,
			Map keysToListsOfValues) 
	{
		return putToListOfValues(key,val,keysToListsOfValues,false);
	}


	public static List putToListOfValues(Object key, Object val,
			Map keysToListsOfValues, boolean avoidDuplicates) {
		List list = (List) keysToListsOfValues.get(key);

		if (list == null) {
			list = new ArrayList();
			keysToListsOfValues.put(key, list);
		} else {
			if (avoidDuplicates)
			{
				if (list.contains(val))
				{
					return list;
				}
			}
		}
		list.add(val);

		return list;
	}

	public final static SimpleDateFormat yearMonthDayHourMinuteSecond=new SimpleDateFormat(
			"yyyy-MM-dd HH-mm-ss");

	static long start=System.currentTimeMillis();

	public static void screenShot(String append) throws Exception {

		Robot robot = new Robot();
		// Capture the screen shot of the area of the screen defined by the rectangle
		BufferedImage bi=robot.createScreenCapture(new Rectangle(1000,1000));

		String path="/home/oracle/Pictures/screenshots/";

		long time=System.currentTimeMillis();
		Date cur=new Date();

		String file=yearMonthDayHourMinuteSecond.format(cur)+"_"+((time-start)/1000)+" seconds "+append+".png";


		ImageIO.write(bi, "png", new File(path+file));

	}
	
	public static void writeFile(File file, String buff, boolean append)
			throws Exception {
			
			FileWriter fileWriter = new FileWriter(file, append);
			fileWriter.write(buff.toCharArray());
			fileWriter.flush();
			fileWriter.close();

	}

}
