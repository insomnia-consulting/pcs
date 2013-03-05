package com.pacytology.pcs;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.actions.PcsActionMap;

public class PpdLabDialogActionMap extends PcsActionMap {

	public PpdLabDialogActionMap(Object parentFrame) {
		super(parentFrame);
	}
	@Override
	public void closeAction() {
		PpdLabDialog labDialog = (PpdLabDialog)this.parentDialog;
		 if (labDialog.formMode==labDialog.LAB) { 
			 labDialog.labParent.currentSection=1;
			 labDialog.labParent.gotoNextSection();
         }
		 labDialog.dispose();
	}
	
	@Override
	public void finalAction() {
		PpdLabDialog labDialog = (PpdLabDialog)this.parentDialog;
		labDialog.updateLab();
		 labDialog.dispose();
	}
	
	@Override 
	public void updateAction(ActionEvent e) {
		PpdLabDialog labDialog = (PpdLabDialog)this.parentDialog;
		if (labDialog.currMode==Lab.UPDATE) {
			labDialog.checkNumber.setEnabled(true);
			labDialog.paymentAmount.setEnabled(true);
			labDialog.prepayComments.setEnabled(true);
			labDialog.checkNumber.requestFocus();
        }
	}

}
