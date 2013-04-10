package com.pacytology.pcs;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.actions.PcsActionMap;

public class PraticesFormActionMap extends PcsActionMap {

	public PraticesFormActionMap(Object parentFrame) {
		super(parentFrame);
	}
	
	@Override	
	public void shiftf1Action(ActionEvent e) {
		PracticesForm form = (PracticesForm)this.parentFrame;
		if ((e.getModifiers() & ActionEvent.SHIFT_MASK) != 0) {
			 form.dateAddedList();
		}	
	}
	@Override
	public void finalAction() {
		PracticesForm form = (PracticesForm)this.parentFrame;
		form.msgLabel.setText(null);
		if (form.fKeys.isOn(form.fKeys.F12)==true) {
			form.finalActions();
		}
        else form.msgLabel.setText("Finalize option not available");

	}
}
