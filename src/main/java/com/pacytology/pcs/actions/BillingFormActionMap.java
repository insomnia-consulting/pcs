package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.BillingDetails;
import com.pacytology.pcs.BillingForm;
import com.pacytology.pcs.DBCommentDialog;
import com.pacytology.pcs.FunctionKeyControl;
import com.pacytology.pcs.Lab;
import com.pacytology.pcs.PatientAccountsForm;
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
	public void f5Action(ActionEvent e) {
		BillingForm form = (BillingForm) BillingFormActionMap.this.parentFrame;
		form.statusReset.setEnabled(false);
        if (form.globalFinished>=BillingForm.FINISHED)
            Utils.createErrMsg("(1) No action permitted on finished work");
        else form.invokePatientForm();
	}

	@Override
	public void altf5Action(ActionEvent e) {
		BillingForm form = (BillingForm) BillingFormActionMap.this.parentFrame;
		form.statusReset.setEnabled(false);

            BillingDetails bd = 
                (BillingDetails)form.labRec.billing.details.elementAt(form.currNdx);
            if (bd.billing_choice==Lab.DB) 
                (new PatientAccountsForm(
                    form.dbLogin,form.labRec.lab_number)).setVisible(true);
	}

	@Override
	public void shiftf5Action(ActionEvent e) {
		BillingForm form = (BillingForm) BillingFormActionMap.this.parentFrame;
		form.statusReset.setEnabled(false);
		if (form.labRec.lab_number>0) {
            String s = form.labBillingChoice.getText();
            String c = Utils.isNull(form.claimStatus.getText()," ");
            if (c.equals("D")||c.equals("R")||c.equals("PP")||c.equals("N")
            ||c.equals("I")||(!Utils.isNull(s) && s.equals("DB")))
                (new DBCommentDialog(form.dbComments)).setVisible(true);
            else
                Utils.createErrMsg(
                    "Claim status is (D,R,PP,N,I) or billing choice is (DB)"+
                    " for direct bill comments");
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
