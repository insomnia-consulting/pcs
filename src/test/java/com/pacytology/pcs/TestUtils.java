package com.pacytology.pcs;

import org.apache.commons.lang.StringUtils;

public class TestUtils 
{
	public static String URL;
	
	static {
		URL = System.getProperty("jdbc.connection");
		
		if (StringUtils.isBlank(URL))
		{
			System.out.println("jdbc.connection not defined.  Using default");
			URL="jdbc:oracle:thin:@localhost:1521:pcsdev";
		}

		System.out.println("URL: "+URL);
	}
}
