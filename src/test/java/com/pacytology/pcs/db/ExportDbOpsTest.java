package com.pacytology.pcs.db;

import static org.junit.Assert.*;

import java.util.Date;
import java.util.Properties;

import org.joda.time.DateTime;
import org.junit.Before;
import org.junit.Test;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.Login;
import com.pacytology.pcs.PCSLabEntry;
import com.pacytology.pcs.TestUtils;
import com.pacytology.pcs.models.ExportError;
import com.pacytology.pcs.models.HpvRequest;

public class ExportDbOpsTest {

	Properties props = new Properties();

	@Before
	public void setUp() {
		Login dbLogin = new Login();
		dbLogin.dateToday = DateTime.now().toString();
		dbLogin.driver = "oracle.jdbc.driver.OracleDriver";
		dbLogin.URL = TestUtils.URL;
		dbLogin.userName = "pcs";
		dbLogin.userPassword = "abh21";
		props.put("username", dbLogin.userName);
		props.put("password", dbLogin.userPassword);
		props.put("jdbc.connection", dbLogin.URL);

		new DbConnection(dbLogin);

	}
	
	@Test
	public void testInsertErrorRecord() {
		PCSLabEntry.sqlSessionFactory(props) ;  
		ExportError exportError = new ExportError() ;  
		exportError.setLab_number(2050000007) ;
		Date date = new DateTime().toDate() ;
		exportError.setDatestamp(date) ;
		exportError.setError("This is an error") ; 
		boolean inserted = ExportDbOps.insert(exportError) ;
		assertTrue(inserted); 
		
	}

}

