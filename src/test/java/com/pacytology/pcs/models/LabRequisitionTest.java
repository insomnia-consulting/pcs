package com.pacytology.pcs.models;

import static org.junit.Assert.*;

import java.util.List;
import java.util.Properties;

import org.junit.Before;
import org.junit.Test;

import com.pacytology.pcs.LabDbOps;
import com.pacytology.pcs.PCSLabEntry;
import com.pacytology.pcs.TestUtils;

public class LabRequisitionTest {
	Properties props = new Properties();

@Before
public void setup() {
	
	props.put("username", "pcs");
	props.put("password", "abh21");
	props.put("jdbc.connection", TestUtils.URL); 
}
@Test
public void testGetPatient() {

	PCSLabEntry.sqlSessionFactory(props) ;  
	LabRequisition labReq = LabDbOps.getLabRequisition(2013000868) ; 
	Patient patient = labReq.getPatient() ;
	assertNotNull(patient) ;
	 assertEquals(2409511, patient.getPatient()) ;
	 assertEquals("LAWANDA", patient.getLname()) ; 
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
		LabRequisition labReq = LabDbOps.getLabRequisition(2009073630) ; 
		HpvRequest hpvRequest= labReq.getHpvRequest() ;
		assertNotNull(hpvRequest) ;
		 
	}
	@Test
	public void testAscusRules() {

		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012687) ;
		LabResult labResult = labReq.getLabResult() ;
		assertNotNull(labResult) ;

	}
	@Test
	public void testGetLabResult() {

		PCSLabEntry.sqlSessionFactory(props) ;  
		LabRequisition labReq = LabDbOps.getLabRequisition(2013012687) ;
		assertNotNull(labReq.getLabResult()) ; 
		assertNotNull(labReq.getLabResult().getDetailCodes()) ; 
	}
	
	@Test
	public void testGetLabRequisitions() {
		PCSLabEntry.sqlSessionFactory(props) ;  
		List<LabRequisition> labReqs = LabDbOps.getLabRequisitions(2013011664, 2013012687);
		assertNotNull(labReqs);
		assertTrue(labReqs.get(0).getLabResult().getLabNumber() >= 2013011664 && labReqs.get(0).getLabResult().getLabNumber() <= 2013012687);
		
	}

}
