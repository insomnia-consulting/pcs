package com.pacytology.pcs.util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class Utility {
	public final static SimpleDateFormat yearMonthDayHourMinuteSecond_noSpaces=new SimpleDateFormat(
			"yyyy-MM-dd_HH-mm-ss");
	
	public static String currentTimeFormattedForFileSystems() {
		Date current=new Date(System.currentTimeMillis());
		return yearMonthDayHourMinuteSecond_noSpaces.format(current);
	}
}
