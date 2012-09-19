package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import javax.swing.JTextField;

import com.pacytology.pcs.DBCommentDialog;
import com.pacytology.pcs.FunctionKeyControl;
import com.pacytology.pcs.Lab;
import com.pacytology.pcs.PatStmtCopyDialog;
import com.pacytology.pcs.PatientAccountsForm;
import com.pacytology.pcs.PracticeAccountsForm;
import com.pacytology.pcs.Utils;
import com.pacytology.pcs.ui.PcsFrame;

public class PatientAccountsFormActionMap extends PcsActionMap {

	public PatientAccountsFormActionMap(PcsFrame parentFrame) {
		super(parentFrame);
	}
	public void updateAction(ActionEvent e) {
		PatientAccountsForm form = (PatientAccountsForm)parentFrame;
		if (form.currMode!=Lab.IDLE) {
            if (form.pastDue==form.REBILL)
                Utils.createErrMsg("Lab has been rebilled - cannot update.");
            else if (form.pastDue==form.ACCOUNT_NOT_ACTIVATED)
                Utils.createErrMsg("Account not activated - cannot update.");
            else if (form.inBillingQueue)
                Utils.createErrMsg("Cannot update account with a "+
                    "statement in the billing queue.");
            else if (form.pastDue>form.PAID_IN_FULL)
                form.updateActions();
            else
                Utils.createErrMsg("Lab charges paid in full - cannot update.");
        }
	}
	@Override
	public void closeAction() {
		PatientAccountsForm form = (PatientAccountsForm) parentFrame;
		form.closingActions();
		form.dispose();
	}
	
	@Override
	public void f4Action(ActionEvent e) {
		PatientAccountsForm form = (PatientAccountsForm) parentFrame;
		if (!Utils.isNull(form.paLab.getText())) {
            if (form.inBillingQueue)
                Utils.createErrMsg(
                    "Cannot print a copy of statement "+
                    "that is in the billing queue.");
            else {
                if (form.currMode==Lab.QUERY || form.currMode==Lab.IDLE) {
                    String s = form.dbComments.getText();
                    if (!Utils.isNull(s)) form.dbOps.addComment(s);
                    form.dbComments.setText(null);
                }
	            (new PatStmtCopyDialog(
	                form,form.dbLogin,form.paLab.getText())).setVisible(true);
	        }
	    }
	}
	@Override 
	public void f5Action(ActionEvent e)	{
		PatientAccountsForm form = (PatientAccountsForm) parentFrame;
		if ((e.getModifiers() & e.ALT_MASK) != 0 && form.currLAB>0) {
            (new DBCommentDialog(form.dbComments)).setVisible(true);
	    }
	    else {
            if (form.inBillingQueue)
                Utils.createErrMsg("Cannot update account with a "+
                    "statement in the billing queue.");
            else if (form.pastDue>form.PAID_IN_FULL)
	            form.releaseActions();
            else 
                Utils.createErrMsg("Lab charges paid in full - cannot add release date");
        }
	}
	@Override
	public void controlAction() {
		PracticeAccountsForm form = (PracticeAccountsForm) parentFrame;
		((JTextField)form.getFocusOwner()).setText(null);
		form.dFlag = false ;
	}
	@Override
	public void queryAction()  {
		PatientAccountsFormActionMap.this.parentFrame.msgLabel.setText(null);
        PatientAccountsFormActionMap.this.parentFrame.queryActions();
        
	}

}
