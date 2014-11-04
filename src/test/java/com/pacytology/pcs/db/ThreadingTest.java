package com.pacytology.pcs.db;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.mockito.Mockito;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.*;

import java.util.Vector;

import junit.framework.TestCase;
import net.sourceforge.groboutils.junit.v1.MultiThreadedTestRunner;
import net.sourceforge.groboutils.junit.v1.TestRunnable;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import com.pacytology.pcs.Export;
import com.pacytology.pcs.HPVDbOps;
import com.pacytology.pcs.HPVReport;
import com.pacytology.pcs.Lab;

@RunWith(PowerMockRunner.class)
@PrepareForTest({ Export.class })
public class ThreadingTest extends TestCase {
	private TestRunnable testRunnable;

	private class ExportTest extends TestRunnable {

		private String name;

		private ExportTest(String name) {

			this.name = name;
		}

		public void runTest() throws Throwable {
			
			Vector eReports = mock(Vector.class);
			Export export = mock(Export.class);
			PowerMockito.whenNew(Export.class).withArguments(Lab.HPV_REPORTS).thenReturn(export);
			Mockito.doAnswer(new Answer<Void>() {
			    public Void answer(InvocationOnMock invocation) {
			    	System.out.println("#### You are a fucking bitch");
			        try {
			        	long l;
						l = Math.round(2 + Math.random() * 5);

						// Sleep between 2-5 seconds
						Thread.sleep(l * 1000);
					} catch (InterruptedException e) {
						fail("Thread.sleep died");
					}
			        System.out.println("#### Do you kiss your momma with that mouth?");
			        return null;
			     }
			 }).when(export).write(eReports);
			
			export.write(eReports);
		}
	
	}
	
	private class ReportTest extends TestRunnable {

		private String name;

		private ReportTest(String name) {

			this.name = name;
		}

		public void runTest() throws Throwable {
			long l;
			l = Math.round(2 + Math.random() * 3);

			// Sleep between 2-5 seconds
			Thread.sleep(l * 1000);
			System.out.println("Delayed Hello World " + name);
		}
	}

	/**
	 * You use the MultiThreadedTestRunner in your test cases. The MTTR takes an
	 * array of TestRunnable objects as parameters in its constructor.
	 * 
	 * After you have built the MTTR, you run it with a call to the
	 * runTestRunnables() method.
	 */
	@Test
	public void testExampleThread() throws Throwable {

		// instantiate the TestRunnable classes
		TestRunnable tr1, tr2, tr3;
		tr1 = new ExportTest("1");
		tr2 = new ReportTest("2");

		// pass that instance to the MTTR
		TestRunnable[] trs = { tr1, tr2 };
		MultiThreadedTestRunner mttr = new MultiThreadedTestRunner(trs);

		// kickstarts the MTTR & fires off threads
		mttr.runTestRunnables();
	}

}
