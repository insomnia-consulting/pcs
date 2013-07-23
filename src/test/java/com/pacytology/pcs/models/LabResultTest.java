package com.pacytology.pcs.models;

import static org.junit.Assert.*;

import java.util.Properties;

import org.junit.Test;

import com.pacytology.pcs.LabDbOps;
import com.pacytology.pcs.PCSLabEntry;
import com.pacytology.pcs.db.ResultDbOps;

public class LabResultTest {

	@Test
	public void testGetLabResult() {
		Properties props = new Properties();
		props.put("username", "pcs");
		props.put("password", "ahb21");
		props.put("jdbc.connection", "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev"); 
		PCSLabEntry.sqlSessionFactory(props) ;  
		LabResult labResult = ResultDbOps.getLabResult(2013001269) ;  
		assertNotNull(labResult) ;
		assertEquals(6, labResult.getDetailCodes().size()) ; 

	}

}
