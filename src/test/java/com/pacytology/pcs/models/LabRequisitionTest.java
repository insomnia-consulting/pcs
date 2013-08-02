package com.pacytology.pcs.models;

import static org.junit.Assert.*;

import java.util.Properties;

import org.junit.Before;
import org.junit.Test;

import com.pacytology.pcs.LabDbOps;
import com.pacytology.pcs.PCSLabEntry;

public class LabRequisitionTest {
	Properties props = new Properties();

@Before
public void setup() {
	
	props.put("username", "pcs");
	props.put("password", "ahb21");
	props.put("jdbc.connection", "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev");	
}
@Test
public void testGetPatient() {

	PCSLabEntry.sqlSessionFactory(props) ;  
	LabRequisition labReq = LabDbOps.getLabRequisition(2013000868) ; 
	Patient patient = labReq.getPatient() ;
	assertNotNull(patient) ;
	 assertEquals(2409511, patient.getPatient()) ;
	 assertEquals("DOLLIE", patient.getLname()) ; 
}
@Test
public void testGetPractice() {

	PCSLabEntry.sqlSessionFactory(props) ;  
	LabRequisition labReq = LabDbOps.getLabRequisition(2013000868) ; 
	Practice practice = labReq.getPractice() ;
	assertNotNull(practice) ;
	 assertEquals(801, practice.getPractice()) ;
	 assertEquals("ADPH", practice.getPractice_type()) ; 
}
	@Test
	public void testGetHpvRequest() {

		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012693) ; 
		HpvRequest hpvRequest= labReq.getHpvRequest() ;
		assertNotNull(hpvRequest) ;
		 
	}
	@Test
	public void testAscusRules() {

		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012694) ;
		LabResult labResult = labReq.getLabResult() ;
		assertNotNull(labResult) ;

	}
	@Test
	public void testGetLabResult() {

		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012694) ;
		assertNotNull(labReq.getLabResult()) ; 
		assertNotNull(labReq.getLabResult().getDetailCodes()) ; 
	}	

}
