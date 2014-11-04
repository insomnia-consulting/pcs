package com.pacytology.pcs;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;
import static org.mockito.Matchers.anyInt;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.Vector;

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

@RunWith(PowerMockRunner.class)
@PrepareForTest({ HPVReport.class, HPVDbOps.class, Export.class })
public class HPVDbOpsTest {
	 DateTime writeOutStamp;
	 DateTime hpvReportOutStamp;
	@Spy
	HPVDbOps dbSpy = new HPVDbOps();

	@Before
	public void setup() {
		MockitoAnnotations.initMocks(this);
	}

	@Test
	public void hpvReportTest() throws Throwable {
		
		
		
		HPVReport report = mock(HPVReport.class);
		Vector labReportVector = mock(Vector.class);
		Vector eReportVector = mock(Vector.class);
		LabReportRec labReport = mock(LabReportRec.class);
		dbSpy.parent = report;
		when(report.getPrintMode()).thenReturn(Lab.FINAL);
		when(report.getStartingLabNumber()).thenReturn(2014035573);
		when(report.getLabReportVect()).thenReturn(labReportVector);
		when(labReportVector.elementAt(0)).thenReturn(labReport);
		when(labReport.getCytotech_code()).thenReturn("SEC");
		doReturn(true).when(dbSpy).query(anyInt(), anyInt());
		doReturn(eReportVector).when(dbSpy).extractElectronicReports(
				labReportVector);
		when(eReportVector.size()).thenReturn(1);
		Export export = mock(Export.class);
		// when(export.write(eReportVector)
		// ).withArguments(anyObject()).thenReturn(null);
		PowerMockito.whenNew(Export.class).withArguments(Lab.HPV_REPORTS)
				.thenReturn(export);
		Mockito.doAnswer(new Answer<Void>() {
			public Void answer(InvocationOnMock invocation) {
				System.out.println("#### Calling parent.hpvReport()");
				try {
					
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					fail("Thread1.sleep died");
				}
				hpvReportOutStamp = DateTime.now();
				System.out.println("#### Done calling parent.hpvReport()");
				return null;
			}
		}).when(report).hpvReport();
		Mockito.doAnswer(new Answer<Void>() {
			public Void answer(InvocationOnMock invocation) {
				System.out.println("#### Calling Export.write()");

				Thread t = new Thread() {
					public void run() {

						try {
							Thread.sleep(5000);
						} catch (InterruptedException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						System.out.println("blah");
						writeOutStamp = DateTime.now();
					}
				};
				t.start();
				
				
				System.out.println("#### Done calling Export.write()");
				return null;
			}
		}).when(export).write(eReportVector);

		dbSpy.run();
		assertNotNull(hpvReportOutStamp) ; 
		assertNotNull(writeOutStamp) ; 
		if (hpvReportOutStamp.isBefore(writeOutStamp)) fail("The report completed before the export could finish") ;  
			
		// Need to verify that hpvReport doesn't complete before export.write
		// assertThat(new Export("random string").check(), equalTo("test"));

	}

}
