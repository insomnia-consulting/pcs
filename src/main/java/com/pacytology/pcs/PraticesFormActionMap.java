package com.pacytology.pcs;

import com.pacytology.pcs.actions.PcsActionMap;

public class PraticesFormActionMap extends PcsActionMap {

	public PraticesFormActionMap(Object parentFrame) {
		super(parentFrame);
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
