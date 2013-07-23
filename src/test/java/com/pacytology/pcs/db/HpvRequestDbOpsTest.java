package com.pacytology.pcs.db;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.util.Properties;

import org.joda.time.DateTime;
import org.junit.Before;
import org.junit.Test;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.Login;
import com.pacytology.pcs.PCSLabEntry;

public class HpvRequestDbOpsTest {
	Properties props = new Properties();
	@Before
	public void setUp() {
		Login dbLogin = new Login() ;
		dbLogin.dateToday = DateTime.now().toString() ; 
		dbLogin.driver = "oracle.jdbc.driver.OracleDriver" ; 
		dbLogin.URL = "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev" ;
		dbLogin.userName = "pcs"; 
		dbLogin.userPassword = "ahb21" ; 
		props.put("username", dbLogin.userName);
		props.put("password", dbLogin.userPassword);
		props.put("jdbc.connection", dbLogin.URL);

		
		new DbConnection(dbLogin);

	}
	
	@Test
	public void testAscusUnder21() {
		
		PCSLabEntry.sqlSessionFactory(props) ;  
		int labNumber = 2013011927 ; 
		try {
			HpvRequestDbOps.set_hpv(labNumber) ;
		} catch (SQLException e) {
			fail();
		}
		boolean hpv = HpvRequestDbOps.isHpv(labNumber) ;
		assertFalse(hpv);

	}
	
	@Test
	public void testAscusOver21With827ResultAlreadyN() {
		
		PCSLabEntry.sqlSessionFactory(props) ;  
		int labNumber = 2013008599 ; 
		try {
			HpvRequestDbOps.set_hpv(labNumber) ;
		} catch (SQLException e) {
			fail();
		}
		boolean hpv = HpvRequestDbOps.isHpv(labNumber) ;
		assertFalse(hpv);

	}
	
	@Test
	public void testAscusOver21With827ResultButNotN() {
		
		PCSLabEntry.sqlSessionFactory(props) ;  
		int labNumber = 2013009156 ; 
		try {
			HpvRequestDbOps.set_hpv(labNumber) ;
		} catch (SQLException e) {
			fail(e.getMessage());
			
		}
		boolean hpv = HpvRequestDbOps.isHpv(labNumber) ;
		assertFalse(hpv);
	}

}
