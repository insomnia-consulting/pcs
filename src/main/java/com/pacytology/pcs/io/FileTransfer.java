package com.pacytology.pcs.io;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.OutputStream;

import org.rev6.scf.ScpDownload;
import org.rev6.scf.ScpFile;
import org.rev6.scf.ScpInput;
import org.rev6.scf.ScpOutput;
import org.rev6.scf.ScpUpload;
import org.rev6.scf.SshConnection;
import org.rev6.scf.SshException;

import com.pacytology.pcs.Utils;

public class FileTransfer {
	
	/**
	 * Using https://github.com/akinsgre/securechannelfacade to transfer files
	 * 
	 * @param sourceFileName
	 * @param destFilename
	 */
	public static void sendFile(String sourceFileName, String destFilename) {
		String host = Utils.HOST_IP;
		String username = "oracle";
		String password = Utils.HOST_PWD;

		SshConnection ssh = null;

		try {
			ssh = new SshConnection(host, username, password);
			ssh.setPort(Integer.parseInt(Utils.HOST_PORT));
			ssh.connect();
			ScpFile scpFile = new ScpFile(new File(sourceFileName),
					destFilename);
			ssh.executeTask(new ScpUpload(scpFile));
		} catch (SshException e) {
			e.printStackTrace();
		} finally {
			if (ssh != null) {
				ssh.disconnect();
			}
		}
	}
	
	/**
	 * Send a byte[] to the destination computer, where it will be saved as destFilename
	 * 
	 * Using https://github.com/akinsgre/securechannelfacade to transfer files
	 * 
	 * @param sourceFileName
	 * @param destFilename
	 */
	public static void sendFile(byte[] byteArray, String destFilename) {
		String host = Utils.HOST_IP;
		String username = "oracle";
		String password = Utils.HOST_PWD;

		SshConnection ssh = null;

		try {
			ssh = new SshConnection(host, username, password);
			ssh.setPort(Integer.parseInt(Utils.HOST_PORT));
			ssh.connect();
			 ScpFile scpFile = new ScpInput(byteArray, destFilename);

			ssh.executeTask(new ScpUpload(scpFile));
		} catch (SshException e) {
			e.printStackTrace();
		} finally {
			if (ssh != null) {
				ssh.disconnect();
			}
		}
	}
	/**
	 * Using https://github.com/akinsgre/securechannelfacade/ to transfer files
	 * 
	 * @param remotePath
	 */
	public static OutputStream getOutputStream(String remotePath) {

		String host = Utils.HOST_IP;
		String username = "oracle";
		String password = Utils.HOST_PWD;

		SshConnection ssh = null;
		OutputStream out = null ; 

		try {
			ssh = new SshConnection(host, username, password);
			ssh.setPort(Integer.parseInt(Utils.HOST_PORT));
			ssh.connect();
			ScpFile scpFile = new ScpOutput(remotePath);
			ssh.executeTask(new ScpDownload(scpFile));
			out = scpFile.getOutputStream();
		} catch (SshException e) {
			
			e.printStackTrace();
		} finally {
			if (ssh != null) {
				ssh.disconnect();
			}
		}
		return out;
	}
	/**
	 * Using https://github.com/akinsgre/securechannelfacade/ to transfer files
	 * 
	 * @param remotePath	 
	 */
	public static File getFile(String localPath, String remotePath, String fileName) {

		String host = Utils.HOST_IP;
		String username = "oracle";
		String password = Utils.HOST_PWD;

		SshConnection ssh = null;
		OutputStream out = null ; 

		try {
			ssh = new SshConnection(host, username, password);
			ssh.setPort(Integer.parseInt(Utils.HOST_PORT));
			ssh.connect();
			ScpDownload download = new ScpDownload(
        			new ScpFile(new File(localPath + fileName),  remotePath + fileName)
        				);
			ssh.executeTask(download);
			File file = new File(localPath + fileName);
			if (file != null && file.isFile()) return file;
			else throw new FileNotFoundException();	
		} catch (FileNotFoundException fnf){

			fnf.printStackTrace();
		} catch (SshException e) {
			
			e.printStackTrace();
		} finally {
			if (ssh != null) {
				ssh.disconnect();
			}
		}
		return null;
		
	}
}
