package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.Action;

import com.pacytology.pcs.ui.PcsFrame;

public class PcsActionMap {
	private PcsFrame parentFrame ;
	
	public PcsActionMap(PcsFrame parentFrame) {
		this.parentFrame = parentFrame;
	}
	
	public final Action closeAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.parentFrame.dispose();
		}
	};
	


	


}
