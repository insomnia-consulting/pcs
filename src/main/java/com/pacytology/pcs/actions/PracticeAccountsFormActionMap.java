package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.PracticeAccountsForm;
import com.pacytology.pcs.actions.PcsActionMap;
import com.pacytology.pcs.ui.PcsFrame;
import javax.swing.JTextField;

public class PracticeAccountsFormActionMap extends PcsActionMap {

	public PracticeAccountsFormActionMap(PcsFrame parentFrame) {
		super(parentFrame);
	}
	@Override
	public void f4Action(ActionEvent e) {
		//Just ignore on this form
	}
	@Override
	public void f5Action(ActionEvent e) {
		PracticeAccountsForm form = (PracticeAccountsForm)parentFrame;
		form.displayStatement();
	}
	@Override
	public void closeAction() {
		PracticeAccountsForm form = (PracticeAccountsForm) parentFrame;
		form.dbOps.close();
		form.dispose();
	}
	@Override
	public void controlAction() {
		PracticeAccountsForm form = (PracticeAccountsForm) parentFrame;
		((JTextField)form.getFocusOwner()).setText(null);
		form.dFlag = false ;
	}
}
