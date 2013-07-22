package com.pacytology.pcs.sqlmaps;

import org.apache.ibatis.annotations.Select;

import com.pacytology.pcs.models.Patient;

public interface PatientMapper {
	@Select("SELECT * FROM patients WHERE patient = #{id}")
	Patient selectPatient(int id);
}
