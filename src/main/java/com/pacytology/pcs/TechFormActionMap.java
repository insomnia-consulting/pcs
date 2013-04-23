package com.pacytology.pcs;

import com.pacytology.pcs.actions.PcsActionMap;

public class TechFormActionMap extends PcsActionMap {

	public TechFormActionMap(Object parentFrame) {
		super(parentFrame);
	}
	@Override
	public void finalAction() {
		TechForm form = (TechForm)this.parentFrame;
		form.finalActions();
	}
	
}
