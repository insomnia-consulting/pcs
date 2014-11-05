package com.pacytology.pcs.db;

import org.apache.ibatis.session.SqlSession;

import com.pacytology.pcs.PCSLabEntry;
import com.pacytology.pcs.models.ExportError;

public class ExportDbOps {
	public static boolean insert(ExportError exportError) {
		SqlSession session = PCSLabEntry.sqlSessionFactory(null).openSession();
		int results = session.insert("com.pacytology.pcs.sqlmaps.ExportErrorMapper.insertExportError", exportError) ;
		if (results != 1) {
			session.rollback() ;
			return false ; 
		}
		else {
			session.commit(); 
			return true ; 
		}
		
	}
}
