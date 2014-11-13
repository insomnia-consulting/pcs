package com.pacytology.pcs.io;

import static org.mockito.Matchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;
import org.rev6.scf.SshConnection;
import org.rev6.scf.SshException;
import org.rev6.scf.SshTask;

@RunWith(PowerMockRunner.class)
@PrepareForTest({ FileTransfer.class })
public class FileTransferTest {
	
	@Test	
	public void testSendFiles() throws Throwable  {
		SshConnection mockSsh = mock(SshConnection.class);
		PowerMockito.whenNew(SshConnection.class).withAnyArguments().thenReturn(mockSsh);

		Map<String, String> fileMap = new HashMap<String, String>() ;
		fileMap.put("test1", "test1") ; 
		fileMap.put("test2", "test2") ; 
		fileMap.put("test3", "test3") ; 
		FileTransfer.sendFiles(fileMap) ;
		verify(mockSsh, times(3)).executeTask(any(SshTask.class)) ; 
	}
	
	@Test(expected=SshException.class)
	public void testSendFilesException() throws Throwable {
		SshConnection mockSsh = mock(SshConnection.class);
		PowerMockito.whenNew(SshConnection.class).withAnyArguments().thenReturn(mockSsh);

		Map<String, String> fileMap = new HashMap<String, String>() ;
		fileMap.put("test1", "test1") ; 
		fileMap.put("test2", "test2") ; 
		fileMap.put("test3", "test3") ; 

		doThrow(new SshException("")).when(mockSsh).executeTask(any(SshTask.class)) ;
		
		FileTransfer.sendFiles(fileMap) ;
		
	}

}
