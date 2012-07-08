package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

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
	public void addAction(ActionEvent e) {
		PClassActionMap.this.parentFrame.msgLabel.setText("Add option not implemented");
	}

	@Override
	public void updateAction(ActionEvent e) {
		PClassActionMap.this.parentFrame.msgLabel.setText("Update option not implemented");
	}
	
	
	
}
