package com.pacytology.pcs;

import com.pacytology.pcs.actions.PcsActionMap;

public class LabChangeDialogActionMap extends PcsActionMap {

	public LabChangeDialogActionMap(Object parentFrame) {
		super(parentFrame);
	}
	public void resetAction() 
	{
		((LabChangeDialog)this.getParent()).resetForm();
	}

}
