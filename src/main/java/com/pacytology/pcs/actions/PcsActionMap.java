package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.JTextField;

import com.pacytology.pcs.ui.PcsFrame;

public class PcsActionMap {
	protected PcsFrame parentFrame ;
	
	public PcsActionMap(PcsFrame parentFrame) {
		this.parentFrame = parentFrame;
	}
	
	public final Action closeAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.parentFrame.dispose();
		}
	};
	
	public  Action queryAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.queryAction();
		}
	};
	
	public void queryAction() {
		PcsActionMap.this.parentFrame.msgLabel.setText(null);
        if (PcsActionMap.this.parentFrame.fKeys.isOn(PcsActionMap.this.parentFrame.fKeys.F1)==true) {
        	PcsActionMap.this.parentFrame.queryActions();
        }
        else PcsActionMap.this.parentFrame.msgLabel.setText("Query option not available");
	}
	
	public final Action addAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.addAction();
		}
	};
	public void addAction() {
		PcsActionMap.this.parentFrame.msgLabel.setText(null);
        if (PcsActionMap.this.parentFrame.fKeys.isOn(PcsActionMap.this.parentFrame.fKeys.F2)==true) {
        	PcsActionMap.this.parentFrame.addActions();
        }
        else PcsActionMap.this.parentFrame.msgLabel.setText("Query option not available");
	}
	public final Action updateAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.updateAction();
		}
	};
	
	public void updateAction() {
		if (PcsActionMap.this.parentFrame.fKeys.isOn(PcsActionMap.this.parentFrame.fKeys.F3)==true) {
        	PcsActionMap.this.parentFrame.updateActions();
        }
	}
	
	public final Action finalAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.finalAction();
		}
	};
	public void finalAction() {
		PcsActionMap.this.parentFrame.msgLabel.setText(null);
		if (PcsActionMap.this.parentFrame.fKeys.isOn(PcsActionMap.this.parentFrame.fKeys.F12)==true) {
			PcsActionMap.this.parentFrame.finalActions();
		}
        else PcsActionMap.this.parentFrame.msgLabel.setText("Finalize option not available");
	}
	
	public final Action controlAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			((JTextField)PcsActionMap.this.parentFrame.getFocusOwner()).setText(null);
		}
	};
	
	



}
