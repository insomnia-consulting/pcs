package com.pacytology.pcs.sqlmaps;

import org.apache.ibatis.annotations.Select;

import com.pacytology.pcs.models.HpvRequest;

public interface HpvRequestMapper {
	@Select("SELECT * FROM hpv_requests WHERE lab_number = #{id}")
	HpvRequest selectHpvRequest(int labNumber) ; 
}
