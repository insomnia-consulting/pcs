package com.pacytology.pcs.exceptions;

import org.rev6.scf.SshException;

public class TransferException extends SshException {


	private static final long serialVersionUID = 6501702088262838763L;
	private int labNumber ; 

	public TransferException(String message, Throwable e, int labNumber) {
		super(message, e);
		this.setLabNumber(labNumber);
	}

	public int getLabNumber() {
		return labNumber;
	}

	public void setLabNumber(int labNumber) {
		this.labNumber = labNumber;
	}

}
