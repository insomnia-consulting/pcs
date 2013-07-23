package com.pacytology.pcs.models;

import static org.junit.Assert.*;

import java.util.Properties;

import org.junit.Test;

import com.pacytology.pcs.LabDbOps;
import com.pacytology.pcs.PCSLabEntry;

public class LabRequisitionTest {

	@Test
	public void testGetPatient() {
		Properties props = new Properties();
		props.put("username", "pcs");
		props.put("password", "ahb21");
		props.put("jdbc.connection", "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev"); 
		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013000868) ; 
		Patient patient = labReq.getPatient() ;
		assertNotNull(patient) ;
		 assertEquals(2409511, patient.getPatient()) ;
	}
	@Test
	public void testGetHpvRequest() {
		Properties props = new Properties();
		props.put("username", "pcs");
		props.put("password", "ahb21");
		props.put("jdbc.connection", "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev"); 
		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012694) ; 
		HpvRequest hpvRequest= labReq.getHpvRequest() ;
		assertNotNull(hpvRequest) ;
		 
	}
	@Test
	public void testAscusRules() {
		Properties props = new Properties();
		props.put("username", "pcs");
		props.put("password", "ahb21");
		props.put("jdbc.connection", "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev"); 
		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012694) ;
		LabResult labResult = labReq.getLabResult() ;
		assertNotNull(labResult) ;
		

		 
	}
	

}
