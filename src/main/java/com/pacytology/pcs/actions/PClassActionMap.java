package com.pacytology.pcs.actions;

import com.pacytology.pcs.ui.PcsFrame;

public class PClassActionMap extends PcsActionMap {

	public PClassActionMap(PcsFrame parentFrame) {
		super(parentFrame);
	}

	@Override
	public void queryAction() {
		PClassActionMap.this.parentFrame.msgLabel.setText("Query option not implemented");

	}

	@Override
	public void addAction() {
		PClassActionMap.this.parentFrame.msgLabel.setText("Add option not implemented");
	}

	@Override
	public void updateAction() {
		PClassActionMap.this.parentFrame.msgLabel.setText("Update option not implemented");
	}
	
	
	
}
