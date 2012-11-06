package com.pacytology.pcs;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.actions.PcsActionMap;

public class PathHoldsFormActionMap extends PcsActionMap {

	public PathHoldsFormActionMap(Object parentFrame) {
		super(parentFrame);
	}
	@Override
	public void finalAction() {
		PathHoldsForm form = (PathHoldsForm)this.parentFrame;

		if (form.NUM_HOLDS>0) {
            form.setCursor(new java.awt.Cursor(
                java.awt.Cursor.WAIT_CURSOR));
            form.updatePathHolds();
            form.queryPathHolds();
            form.setCursor(new java.awt.Cursor(
                java.awt.Cursor.DEFAULT_CURSOR));
            form.refreshHoldList();
            if (form.NUM_HOLDS>0) { 
                form.displayResultCodes(0);
                form.pHoldList.setSelectedIndex(0);
                form.resultCode.requestFocus();
            }
        }
	}
    @Override
	public void addAction(ActionEvent e) {
    	PathHoldsForm form = (PathHoldsForm)this.parentFrame;
		boolean canProceed = true;
		int ndx = 0;
		if (!form.firstRelease && !form.hasVerification) {
            form.firstRelease=true;
            if (!form.confirmVerified()) {
                form.verifiedOn.requestFocus();	
                canProceed=false;
            }
        }
        if (canProceed) {
        if (form.NUM_HOLDS>0) { 
            ndx=form.pHoldList.getSelectedIndex();
            if (ndx>=0) {
                if (!form.pathHolds[ndx].resultsChanged) {
                    form.releaseMode=true;
                    form.releaseHold();
                    if (!Utils.isNull(form.pathHolds[ndx].released)) {
                        form.resultCode.setEnabled(false);
                        form.msgLabel.requestFocus();
                    }
                }
                else Utils.createErrMsg(
                    "Cannot release because result codes where changed");
                form.increment();
            }
        }
        }
	}
	@Override
	public void resetAction() {
		PathHoldsForm form = (PathHoldsForm)this.parentFrame;
		if (form.NUM_HOLDS>0) {
            for (int i=0;i<form.NUM_HOLDS;i++) {
                form.pathHolds[i].released=null;
            }
            form.setCursor(new java.awt.Cursor(
                java.awt.Cursor.WAIT_CURSOR));
            form.queryPathHolds();
            form.setCursor(new java.awt.Cursor(
                java.awt.Cursor.DEFAULT_CURSOR));
            form.refreshHoldList();
            form.displayResultCodes(0);
            form.pHoldList.setSelectedIndex(0);
            //resultCode.requestFocus();
            form.hasVerification=false;
            form.firstRelease=false;
            form.enableVerified();
        }
	}
	@Override
	public void controlAction() {
		PathHoldsForm form = (PathHoldsForm)this.parentFrame;
		form.resultCode.setText(null);
	}

}
