package com.pacytology.pcs.db;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.Date;

import org.apache.ibatis.session.SqlSession;
import org.joda.time.DateTime;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.PCSLabEntry;
import com.pacytology.pcs.models.HpvRequest;
import com.pacytology.pcs.models.LabRequisition;
import com.pacytology.pcs.models.Patient;
import com.pacytology.pcs.models.Practice;

public class HpvRequestDbOps {
	public static void set_hpv(int labNumber) {
		CallableStatement cstmt = null;
		try {
			cstmt = DbConnection.process().prepareCall("{call pcs.set_hpv(?)}" );
			cstmt.setInt(1, labNumber);
			cstmt.executeUpdate() ; 

		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				cstmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}			
		}
		
		//Alabama had requested some additional criteria.. but this is on hold.  It was never completed.
		//setAscusHpv(labNumber); 
	}
	
	/**
	 * 
	 * @param labNumber
	 * 
	 * If HPV Request is 'N', '19', or '20':
	 *    - If the patient age >= 21 and a result code of 827 exists, then HPV is No
	 *    - If the patient age >= 25 and result codes contain (92, 96, 98 or 100) and do not contain (827) HPV is Yes
	 */
	public static void setAscusHpv(int labNumber) {

		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();

		LabRequisition labReq = session
				.selectOne(
						"com.pacytology.pcs.sqlmaps.LabRequisitionMapper.selectLabRequisition",
						labNumber);
		Patient patient = labReq.getPatient();
		Practice practice = labReq.getPractice() ; 
		// if not ADPH or age < 21 return 
		if ( !("ADPH".equals(practice.getPractice_type()) ) || 
				patient.getAge() < 21 ) {
			return;
		} else {
			// patient is in the age range for ASCUS criteria
			if (labReq.getLabResult().getDetailCodes().contains("827")) {
				delete(labReq.getHpvRequest());
			}
			else {
				if (patient.getAge() >= 25 && containsAscusCodes(labReq) && labReq.getHpvRequest() == null) {
					HpvRequest hpvRequest = new HpvRequest() ; 
					hpvRequest.setLab_number(labNumber) ;
					Date date = new DateTime().toDate() ;
					hpvRequest.setDatestamp(date) ; 
					hpvRequest.setComment_text("This HPV Test Request was added per ADPH/ASCUS Rules." ) ; 
					insert(hpvRequest) ;
					
				}
			}
				

		}
	}
	private static boolean containsAscusCodes(LabRequisition labReq) {
		//This should be a lookup against the bethesda codes xref table
		return (labReq.getLabResult().getDetailCodes().contains("092") ||
				labReq.getLabResult().getDetailCodes().contains("096") ||
				labReq.getLabResult().getDetailCodes().contains("098") ||
				labReq.getLabResult().getDetailCodes().contains("100") ) ; 



	}

	public static boolean delete(HpvRequest hpvRequest) {
		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();
		int results = session.delete("com.pacytology.pcs.sqlmaps.HpvRequestMapper.deleteHpvRequest", hpvRequest) ;
		if (results != 1) {
			session.rollback() ;
			return false ; 
		}
		else {
			session.commit(); 
			return true ; 
		}
	}
	public static boolean insert(HpvRequest hpvRequest) {
		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();
		int results = session.insert("com.pacytology.pcs.sqlmaps.HpvRequestMapper.insertHpvRequest", hpvRequest) ;
		if (results != 1) {
			session.rollback() ;
			return false ; 
		}
		else {
			session.commit(); 
			return true ; 
		}
		
	}

	public static boolean isHpv(int labNumber) {
		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();
		HpvRequest request =  session.selectOne("com.pacytology.pcs.sqlmaps.HpvRequestMapper.selectHpvRequest", labNumber);
		boolean isHpv ;
		if (request == null) { 
			isHpv = false ; 
		}
		else {
			isHpv = request.isHpv() ;
		}
		return isHpv ; 
		
	}
}
