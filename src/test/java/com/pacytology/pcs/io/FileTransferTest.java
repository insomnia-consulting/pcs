package com.pacytology.pcs.io;

import static org.mockito.Matchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;
import org.rev6.scf.SshConnection;
import org.rev6.scf.SshException;
import org.rev6.scf.SshTask;

import com.pacytology.pcs.FileMap;

@RunWith(PowerMockRunner.class)
@PrepareForTest({ FileTransfer.class })
public class FileTransferTest {
	
	@Test	
	public void testSendFiles() throws Throwable  {
		SshConnection mockSsh = mock(SshConnection.class);
		PowerMockito.whenNew(SshConnection.class).withAnyArguments().thenReturn(mockSsh);

		FileMap<String, String, Integer> fileMap1 = new FileMap<String, String, Integer>("test1", "test1", 2014) ;
		FileMap<String, String, Integer> fileMap2 = new FileMap<String, String, Integer>("test1", "test1", 2014) ;
		FileMap<String, String, Integer> fileMap3 = new FileMap<String, String, Integer>("test1", "test1", 2014) ;
		List<FileMap<String, String, Integer>> fileList = new ArrayList<FileMap<String, String, Integer>>();
		fileList.add(fileMap1);
		fileList.add(fileMap2);
		fileList.add(fileMap3);
		FileTransfer.sendFiles(fileList) ;
		verify(mockSsh, times(3)).executeTask(any(SshTask.class)) ; 
	}
	
	@Test(expected=SshException.class)
	public void testSendFilesException() throws Throwable {
		SshConnection mockSsh = mock(SshConnection.class);
		PowerMockito.whenNew(SshConnection.class).withAnyArguments().thenReturn(mockSsh);

		
		FileMap<String, String, Integer> fileMap1 = new FileMap<String, String, Integer>("test1", "test1", 2014) ;
		FileMap<String, String, Integer> fileMap2 = new FileMap<String, String, Integer>("test1", "test1", 2014) ;
		FileMap<String, String, Integer> fileMap3 = new FileMap<String, String, Integer>("test1", "test1", 2014) ;
		List<FileMap<String, String, Integer>> fileList = new ArrayList<FileMap<String, String, Integer>>();
		fileList.add(fileMap1);
		fileList.add(fileMap2);
		fileList.add(fileMap3);
		
		doThrow(new SshException("")).when(mockSsh).executeTask(any(SshTask.class)) ;
		
		FileTransfer.sendFiles(fileList) ;
		
	}

}
