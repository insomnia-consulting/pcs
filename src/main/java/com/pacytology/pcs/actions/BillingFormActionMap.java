package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.BillingDetails;
import com.pacytology.pcs.BillingForm;
import com.pacytology.pcs.FunctionKeyControl;
import com.pacytology.pcs.Utils;

public class BillingFormActionMap extends PcsActionMap {

	public BillingFormActionMap(Object parentFrame) {
		super(parentFrame);
	}
 
	@Override
	public void queryAction() {
		BillingFormActionMap.this.parentFrame.msgLabel.setText(null);
		BillingFormActionMap.this.parentFrame.queryActions();
	}

	@Override
	public void addAction(ActionEvent e) {
		BillingForm form = (BillingForm) BillingFormActionMap.this.parentFrame;
		if ((e.getModifiers() & ActionEvent.ALT_MASK) != 0) {
			if (form.claimStatus.hasFocus()) {
				if (form.isClaimStatusLocked) {
					form.lockedClaimStatus = null;
					form.isClaimStatusLocked = false;
					form.lockLbl.setText(null);
				} else if (!Utils.isNull(form.claimStatus.getText())) {
					form.lockedClaimStatus = form.claimStatus.getText();
					form.isClaimStatusLocked = true;
					form.lockLbl.setText("LOCKED");
				} else
					Utils.createErrMsg("Cannot lock claim status");
			}
		} else {
			form.isClaimStatusLocked = false;
			form.lockedClaimStatus = null;
			form.lockLbl.setText(null);
			form.claimActions();
		}
	}

	@Override
	public void updateAction(ActionEvent e) {
		BillingForm form = (BillingForm) BillingFormActionMap.this.parentFrame;
		form.statusReset.setEnabled(false);
		if ((e.getModifiers() & ActionEvent.ALT_MASK) != 0) {
			if (form.labRec.lab_number >= 0) {
				form.patientActions();
			}
		} else {
			if (form.labRec.billing.origin == 1) {
				String msg = null;
				if (form.labRec.billing.in_queue == 1)
					msg = "Lab has a "
							+ form.labRec.billing.letter_type
							+ " letter not printed and created in Requisitions. "
							+ "Lab must be updated there.";
				else if (form.labRec.billing.in_queue == 0)
					msg = "Lab has a " + form.labRec.billing.letter_type
							+ " letter pending created in Requisitions. "
							+ "Lab must be updated there.";
				Utils.createErrMsg(msg);
			} else {
				form.updateActions();
			}
		}
	}

	@Override
	public void f4Action(ActionEvent e) {
		BillingForm form = (BillingForm) BillingFormActionMap.this.parentFrame;
		form.statusReset.setEnabled(false);
		boolean canRebill = true;
		if (form.inBillingQueue) {
			canRebill = false;
			Utils.createErrMsg("Cannot rebill lab in billing queue.");
			return;
		}
		if (form.hasLetter && canRebill) {
			if (form.labRec.billing.in_queue == 1) {
				canRebill = false;
				Utils.createErrMsg("Cannot rebill lab in fax letter queue.");
				return;
			}
		}
		String s = form.claimStatus.getText();
		if (form.inRework && canRebill) {
			if (s.equals("LT") || s.equals("MR"))
				canRebill = true;
			else {
				canRebill = false;
				Utils.createErrMsg("Cannot rebill this lab.");
				return;
			}
		}
		if (canRebill) {
			if (s.equals("P")) {
				Utils.createErrMsg("Cannot rebill claim status P.");
				return;
			}
			form.billingAdd = new BillingDetails();
			form.rebillActions(canRebill);
		}

	}
	

}
