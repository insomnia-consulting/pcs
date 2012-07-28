package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;

import com.pacytology.pcs.CurrentMessageDialog;

public class CurrentMessageDialogActionMap extends PcsActionMap {

	public CurrentMessageDialogActionMap(Object parentFrame) {
		super(parentFrame);
	}

	AbstractAction closeAction = new AbstractAction() { 
		public void actionPerformed(ActionEvent e) {
			CurrentMessageDialogActionMap.this.closeAction();
		}
	};
	
	@Override
	public void closeAction() {
		// TODO Auto-generated method stub
		super.closeAction();
	}

	@Override
	public void resetAction() {
		CurrentMessageDialog dialog = (CurrentMessageDialog)parentDialog;
		dialog.messageText.setText(null);
	    dialog.fgColors.setSelectedIndex(1);
	    dialog.bgColors.setSelectedIndex(3);
	}

	@Override
	public void finalAction() {
		CurrentMessageDialog dialog = (CurrentMessageDialog)parentDialog;
		dialog.finalActions();
	    dialog.dispose();
	}

}
