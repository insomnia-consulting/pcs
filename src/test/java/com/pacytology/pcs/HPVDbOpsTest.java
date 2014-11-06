package com.pacytology.pcs;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import java.awt.PrintJob;
import java.awt.Toolkit;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.Vector;

import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import org.joda.time.DateTime;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;
import org.powermock.core.classloader.annotations.PowerMockIgnore;

import com.pacytology.pcs.db.ExportDbOps;
import com.pacytology.pcs.models.ExportError;

@RunWith(PowerMockRunner.class)
@PrepareForTest({ HPVDbOps.class })
@PowerMockIgnore("javax.swing.*")
public class HPVDbOpsTest {
	DateTime writeOutStamp;
	DateTime hpvReportOutStamp;
	@Spy
	HPVDbOps dbSpy = new HPVDbOps();
	

	Vector labReportVector ;
	Vector eReportVector ; 
	LabReportRec labReport ;
	HPVReport reportSpy;
	Properties props = new Properties();

	@Before
	public void setup() throws UnsupportedLookAndFeelException {
		 labReportVector = mock(Vector.class);
		 eReportVector = mock(Vector.class);
		 labReport = mock(LabReportRec.class);
		 
		MockitoAnnotations.initMocks(this);
		UIManager.setLookAndFeel(new FakeLookAndFeel());
		HPVReport report = new HPVReport();
		reportSpy = PowerMockito.spy(report);
		Toolkit toolkit = mock(Toolkit.class);
		PrintJob pjob = mock(PrintJob.class);
		when(reportSpy.getToolkit()).thenReturn(toolkit);
		when(
				toolkit.getPrintJob(eq(reportSpy), Mockito.anyString(),
						Mockito.any(Properties.class))).thenReturn(pjob);
		when(reportSpy.getPrintMode()).thenReturn(Lab.CURR_FINAL);
		LogFile logFile = mock(LogFile.class);
		PrintWriter writer = mock(PrintWriter.class);
		
		when(reportSpy.getLog()).thenReturn(logFile);
		labReport = mock(LabReportRec.class);
		labReportVector = mock(Vector.class);
		eReportVector = mock(Vector.class);

		doReturn("Y").when(labReport).getE_reporting();
		dbSpy.parent = reportSpy;

		when(reportSpy.getPrintMode()).thenReturn(Lab.CURR_FINAL);
		when(reportSpy.getStartingLabNumber()).thenReturn(2014035573);
		when(reportSpy.getLabReportVect()).thenReturn(labReportVector);
		when(reportSpy.getQueueSize()).thenReturn(1);
		doReturn(true).when(reportSpy).verifyReports(any(Vector.class));

		when(labReportVector.elementAt(0)).thenReturn(labReport);
		when(labReport.getCytotech_code()).thenReturn("SEC");
		doReturn(true).when(dbSpy).query(anyInt(), anyInt());
		doReturn(true).when(dbSpy).queryQueue();
		doReturn(true).when(dbSpy).dequeue(anyInt());
		doReturn(eReportVector).when(dbSpy).extractElectronicReports(
				labReportVector);

		when(eReportVector.size()).thenReturn(1);
		when(labReportVector.size()).thenReturn(1);
		when(labReportVector.size()).thenReturn(1);
		
		// when(export.write(eReportVector)
		// ).withArguments(anyObject()).thenReturn(null);
		
		when(reportSpy.getDbOps()).thenReturn(dbSpy);
		Login dbLogin = new Login();
		dbLogin.dateToday = DateTime.now().toString();
		dbLogin.driver = "oracle.jdbc.driver.OracleDriver";
		dbLogin.URL = TestUtils.URL;
		dbLogin.userName = "pcs";
		dbLogin.userPassword = "abh21";
		props.put("username", dbLogin.userName);
		props.put("password", dbLogin.userPassword);
		props.put("jdbc.connection", dbLogin.URL);

	}

	@Test
	public void hpvReportTest() throws Throwable {
		
		final Export export = mock(Export.class);
		when(reportSpy.geteFile()).thenReturn(export);
		Answer exportWriteAnswer = new Answer<Void>() {
			public Void answer(InvocationOnMock invocation) {
				System.out.println("#### Calling Export.write()");

				Thread t = new Thread() {
					public void run() {

						try {
							System.out
									.println("Starting the mock export.write thread");
							Thread.sleep(5000);
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						System.out.println("Completed the thread");
						writeOutStamp = DateTime.now();
					}
				};
				doReturn(t).when(export).getFileExportThread();
				t.start();

				System.out.println("#### Done calling Export.write()");
				return null;
			}
		};
		Mockito.doAnswer(exportWriteAnswer).when(export)
				.write(any(Vector.class));

		dbSpy.run();

		assertNotNull(writeOutStamp);
		if (DateTime.now().isBefore(writeOutStamp))
			fail("The report completed before the export could finish");

		// Need to verify that hpvReport doesn't complete before export.write
		// assertThat(new Export("random string").check(), equalTo("test"));

	}
	@Test
	public void hpvReportTestWithExportError() throws Throwable {
		
		final Export export = mock(Export.class);
		when(reportSpy.geteFile()).thenReturn(export);
		Answer exportWriteAnswer = new Answer<Void>() {
			public Void answer(InvocationOnMock invocation) {
				System.out.println("#### Calling Export.write()");

				Thread t = new Thread() {
					public void run() {

						try {
							System.out
									.println("Starting the mock export.write thread");
							Thread.sleep(5000);
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						System.out.println("blah");
						writeOutStamp = DateTime.now();
					}
				};
				doReturn(t).when(export).getFileExportThread();
				t.start();

				System.out.println("#### Done calling Export.write()");
				return null;
			}
		};
		Mockito.doAnswer(exportWriteAnswer).when(export)
				.write(any(Vector.class));
		List<String> errorList = new ArrayList<String>();
		
		errorList.add("An error occurred") ;
		when(export.getErrors()).thenReturn(errorList);
		PCSLabEntry.sqlSessionFactory(props) ;  
		dbSpy.run();
		
		assertNotNull(writeOutStamp);
		if (DateTime.now().isBefore(writeOutStamp))
			fail("The report completed before the export could finish");

		verify(dbSpy, never()).dequeue(anyInt());
		
		
		// Need to verify that hpvReport doesn't complete before export.write
		// assertThat(new Export("random string").check(), equalTo("test"));

	}

}
