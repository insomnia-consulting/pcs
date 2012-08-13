package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.JTextField;

import com.pacytology.pcs.FunctionKeyControl;
import com.pacytology.pcs.ui.PcsFrame;

import com.pacytology.pcs.ui.PcsDialog;
import java.awt.Window;

public class PcsActionMap {
	protected PcsFrame parentFrame ;
	protected PcsDialog parentDialog ;
	
	public Object getParent() {
		return (parentFrame != null) ? parentFrame : parentDialog;
	}

	public PcsActionMap(Object parentFrame) {
		if (parentFrame instanceof PcsFrame) {
			this.parentFrame = (PcsFrame)parentFrame;
		}
		else if (parentFrame instanceof PcsDialog){
			this.parentDialog = (PcsDialog)parentFrame;
		}
	}
	public final Action resetAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.resetAction();
		}
	};

	public final Action closeAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.closeAction();
		}
	};
	public void closeAction() {
		((Window)PcsActionMap.this.getParent()).dispose();
	}
	
	public  Action queryAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.queryAction();
		}
	};
	public void resetAction() {
		PcsActionMap.this.parentFrame.resetActions();
	}
	public void queryAction()  {
		PcsActionMap.this.parentFrame.msgLabel.setText(null);
        if ( PcsActionMap.this.parentFrame.fKeys.isOn(FunctionKeyControl.F1) ) {
        	PcsActionMap.this.parentFrame.queryActions();
        }
        else PcsActionMap.this.parentFrame.msgLabel.setText("Query option not available");
	}
	
	public final Action addAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.addAction(e);
		}
	};
	public void addAction(ActionEvent e) {
		PcsActionMap.this.parentFrame.msgLabel.setText(null);
        if (PcsActionMap.this.parentFrame.fKeys.isOn(PcsActionMap.this.parentFrame.fKeys.F2)==true) {
        	PcsActionMap.this.parentFrame.addActions();
        }
        else PcsActionMap.this.parentFrame.msgLabel.setText("Query option not available");
	}
	public final Action updateAction = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.updateAction(e);
		}
	};

	public void updateAction(ActionEvent e) {
		if (PcsActionMap.this.parentFrame.fKeys.isOn(PcsActionMap.this.parentFrame.fKeys.F3)==true) {
        	PcsActionMap.this.parentFrame.updateActions();
        }
	}
	public final Action f4Action = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.f4Action(e);
		}
	};
	public void f4Action(ActionEvent e) {

	}
	public final Action f5Action = new AbstractAction() {
		public void actionPerformed(ActionEvent e) {
			PcsActionMap.this.f5Action(e);
		}
	};
	public void f5Action(ActionEvent e) {
		
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
			PcsActionMap.this.controlAction() ;
		}
	};
	
	public void controlAction() {
		if (PcsActionMap.this.parentFrame.getFocusOwner() instanceof JTextField) {
			((JTextField)PcsActionMap.this.parentFrame.getFocusOwner()).setText(null);
		}

	}
	
	



}
