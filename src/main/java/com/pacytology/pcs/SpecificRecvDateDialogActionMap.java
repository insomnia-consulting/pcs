package com.pacytology.pcs;

import com.pacytology.pcs.actions.PcsActionMap;

public class SpecificRecvDateDialogActionMap extends PcsActionMap {

	public SpecificRecvDateDialogActionMap(Object parentFrame) {
		super(parentFrame);
	}

	@Override
	public void finalAction() {
		SpecificRecvDateDialog dialog = (SpecificRecvDateDialog)this.parentDialog;
		if (!Utils.isNull(dialog.startingLab.getText())
			    || !Utils.isNull(dialog.endingLab.getText())
			    || !Utils.isNull(dialog.receiveDate.getText())) {
			        if (dialog.canUpdate()) dialog.updateReceiveDates();
			        else dialog.clearAll();
			    }
	}

	@Override
	public void closeAction() {
		SpecificRecvDateDialog dialog = (SpecificRecvDateDialog)this.parentDialog;
		dialog.dispose();
	}

	@Override
	public void resetAction() {
		SpecificRecvDateDialog dialog = (SpecificRecvDateDialog)this.parentDialog;
		dialog.clearAll();
	}
	
	

}
