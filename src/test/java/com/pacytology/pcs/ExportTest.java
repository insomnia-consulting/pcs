package com.pacytology.pcs;

import static org.mockito.Matchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;

import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.mockito.Spy;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.pacytology.pcs.io.FileTransfer;

@RunWith(PowerMockRunner.class)
@PrepareForTest({ FileTransfer.class, Export.class })
public class ExportTest {

	@Spy Export export = new Export(Lab.HPV_REPORTS); ; 
	@Test
	public void testExport() throws Throwable {
		
		doNothing().when(export).labPatient(any(LabReportRec.class), any(PrintWriter.class)) ; 
		doNothing().when(export).labDetails(any(LabReportRec.class), any(PrintWriter.class)) ; 
		doNothing().when(export).hpvResults(any(LabReportRec.class), any(PrintWriter.class)) ; 
		PowerMockito.mockStatic(FileTransfer.class);
		Mockito.when(FileTransfer.sendFiles(any(Map.class))).thenReturn(Boolean.TRUE);

		Vector<LabReportRec> labs = new Vector<LabReportRec>();
		LabReportRec rec1 = new LabReportRec();
		LabReportRec rec2 = new LabReportRec();
		labs.add(rec1);
		labs.add(rec2);
		export.data = labs;
		export.run();
		
	}

}
