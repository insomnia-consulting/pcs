package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import javax.swing.JTextField;

import com.pacytology.pcs.TissuePathologyForm;
import com.pacytology.pcs.Utils;

public class TissuePathologyFormActionMap extends PcsActionMap {

	public TissuePathologyFormActionMap(Object parentFrame) {
		super(parentFrame);

	}
	@Override
	public void f5Action(ActionEvent e) {
		TissuePathologyForm form = (TissuePathologyForm)this.parentFrame;
		if (!form.resRemarks.isEnabled()) {
            form.resRemarks.setEnabled(true);
            if (form.textItemsList.getSelectedIndex()<0)
                form.textItemsList.setSelectedIndex(0);
            String s =
                form.textBuffer[form.textItemsList.getSelectedIndex()];
            if (!Utils.isNull(s)) form.resRemarks.setText(s);
            form.resRemarks.requestFocus();
        }
        else {
            form.resRemarks.setEnabled(false);
            form.textBuffer[form.textItemsList.getSelectedIndex()]=form.resRemarks.getText();
            //resRemarks.setText(null);
            //resRemarks.transferFocus();
            form.resCompleted.requestFocus();
        }
	}
	
	@Override
	public void resetAction() {
		TissuePathologyForm form = (TissuePathologyForm)this.parentFrame;
		form.resetActions();
	}
	@Override
	public void controlAction() {
		TissuePathologyForm form = (TissuePathologyForm)this.parentFrame;
		((JTextField)form.getFocusOwner()).setText(null);
	}
	

}
