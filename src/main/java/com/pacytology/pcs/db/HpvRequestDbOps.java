package com.pacytology.pcs.db;

import java.sql.CallableStatement;
import java.sql.SQLException;

import org.apache.ibatis.session.SqlSession;

import com.pacytology.pcs.DbConnection;
import com.pacytology.pcs.PCSLabEntry;
import com.pacytology.pcs.models.HpvRequest;
import com.pacytology.pcs.models.Patient;
import com.pacytology.pcs.models.PatientRec;
import com.pacytology.pcs.sqlmaps.HpvRequestMapper;
import com.pacytology.pcs.sqlmaps.PatientMapper;

public class HpvRequestDbOps {
	public static void set_hpv(int labNumber) throws SQLException {
		CallableStatement cstmt = DbConnection.process().prepareCall(
				"{call pcs.set_hpv(?)}");
		cstmt.setInt(1, labNumber);
		cstmt.executeUpdate();
		cstmt.close();
		
		setAscusHpv(labNumber); 
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
		// if age < 21 return
		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();
		PatientMapper mapper = session.getMapper(PatientMapper.class);
		PatientRec patientRec = new PatientRec() ; 
		Patient patient = mapper.selectPatient(2423468);
		if (patient.getAge() < 21) {
			return ; 
		}
		else {
			
		}
	}

	public static boolean isHpv(int labNumber) {
		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();
		HpvRequestMapper mapper = session.getMapper(HpvRequestMapper.class);
		HpvRequest request = mapper.selectHpvRequest(labNumber);
		return request.isHpv() ; 
		
		
	}
}
