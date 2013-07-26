package com.pacytology.pcs.db;

import static org.junit.Assert.*;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;

import java.sql.SQLException;
import java.util.Date;
import java.util.Properties;

import org.joda.time.DateTime;
import org.junit.Before;
import org.junit.Test;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.LabDbOps;
import com.pacytology.pcs.Login;
import com.pacytology.pcs.PCSLabEntry;
import com.pacytology.pcs.models.HpvRequest;
import com.pacytology.pcs.models.LabRequisition;

public class HpvRequestDbOpsTest {
	Properties props = new Properties();

	@Before
	public void setUp() {
		Login dbLogin = new Login();
		dbLogin.dateToday = DateTime.now().toString();
		dbLogin.driver = "oracle.jdbc.driver.OracleDriver";
		dbLogin.URL = "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev";
		dbLogin.userName = "pcs";
		dbLogin.userPassword = "ahb21";
		props.put("username", dbLogin.userName);
		props.put("password", dbLogin.userPassword);
		props.put("jdbc.connection", dbLogin.URL);

		new DbConnection(dbLogin);

	}

	@Test
	public void testAscusUnder21() {

		PCSLabEntry.sqlSessionFactory(props);
		int labNumber = 2013011947;

		HpvRequestDbOps.set_hpv(labNumber);

		boolean hpv = HpvRequestDbOps.isHpv(labNumber);
		assertFalse(hpv);

	}

	@Test
	public void testAscusOver21With827ResultAlreadyN() {

		PCSLabEntry.sqlSessionFactory(props);
		int labNumber = 2013008599;

		HpvRequestDbOps.set_hpv(labNumber);

		boolean hpv = HpvRequestDbOps.isHpv(labNumber);
		assertFalse(hpv);

	}

	@Test
	public void testAscusOver21With827ResultButNotN() {

		PCSLabEntry.sqlSessionFactory(props);
		int labNumber = 2013009156;

		HpvRequestDbOps.set_hpv(labNumber);

		boolean hpv = HpvRequestDbOps.isHpv(labNumber);
		assertFalse(hpv);
	}
	
	@Test
	public void testDeleteHpvRequest() {
		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012213) ; 
		HpvRequest hpvRequest= labReq.getHpvRequest() ;
		assertNotNull(hpvRequest) ;
		boolean deleted = HpvRequestDbOps.delete(hpvRequest) ;
		assertTrue(deleted) ;
		HpvRequestDbOps.insert(hpvRequest);
	}
	public void testInsertHpvRequest() {
		PCSLabEntry.sqlSessionFactory(props) ;  
		HpvRequest hpvRequest = new HpvRequest() ; 
		hpvRequest.setLab_number(2050000007) ;
		hpvRequest.setHpv_code("N") ; 
		Date date = new DateTime().toDate() ;
		hpvRequest.setDatestamp(date) ; 
		boolean inserted = HpvRequestDbOps.insert(hpvRequest) ;
		assertTrue(inserted); 
		boolean deleted = HpvRequestDbOps.delete(hpvRequest) ;
	}

}
