package com.pacytology.pcs.db;

import static org.junit.Assert.*;

import java.sql.SQLException;
import java.util.Properties;

import org.junit.Test;

import com.pacytology.pcs.Login;
import com.pacytology.pcs.PCSLabEntry;

public class HypRequestDbOpsTest {

	@Test
	public void testAscusUnder21() {
		Properties props = new Properties();
		props.put("username", "pcs");
		props.put("password", "ahb21");
		props.put("jdbc.connection", "jdbc:oracle:thin:@10.211.55.18:1521:pcsdev"); 
		PCSLabEntry.sqlSessionFactory(props) ;  
		HpvRequestDbOps.setAscusHpv(2013012693) ;
		boolean hpv = HpvRequestDbOps.isHpv(2013012693) ;
		assertFalse(hpv);

	}

}
