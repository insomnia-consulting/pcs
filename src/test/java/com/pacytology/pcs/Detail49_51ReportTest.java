package com.pacytology.pcs;

import static org.junit.Assert.*;

import java.sql.Connection;
import java.util.Properties;

import org.apache.commons.lang.StringUtils;
import org.joda.time.DateTime;
import org.junit.Before;
import org.junit.Test;

public class Detail49_51ReportTest {
	Properties props = new Properties();
	Connection connection ;
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
		connection = DbConnection.process();

	}
	@Test
	public void testGetCommentText() {
		Detail49_51Report report = new Detail49_51Report() ;
		assertNotNull(report) ; 
		try {
			
			String text = report.getCommentText(connection, 2014003571, 51) ;
			assertTrue(StringUtils.isNotBlank(text)) ; 
			
		} catch (Exception e) {
			e.printStackTrace();
			fail(e.getMessage()); 
		}
	}

}
