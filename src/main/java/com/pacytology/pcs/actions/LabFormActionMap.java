package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import javax.swing.JTextField;

import com.pacytology.pcs.FunctionKeyControl;
import com.pacytology.pcs.LabForm;

import com.pacytology.pcs.Utils;
import com.pacytology.pcs.ui.PcsFrame;

public class LabFormActionMap extends PcsActionMap {

	public LabFormActionMap(PcsFrame parentFrame) {
		super(parentFrame);
	}
	@Override
	public void addAction(ActionEvent e) {
		LabForm form = (LabForm)this.parentFrame;
		if (this.parentFrame.fKeys.isOn(FunctionKeyControl.F2)) {
            if (!form.prepFlag) {
            	form.setPreparation();
            }
            if (form.prepFlag) {
            	form.addActions();
            }
        }
        else Utils.createErrMsg("Add Option Not Available");

	}
	
	@Override
	public void controlAction() {
		LabForm form = (LabForm)this.parentFrame;		
		if (form.labRelCode.hasFocus()) return;
		if (form.getFocusOwner() instanceof JTextField) {
			((JTextField)form.getFocusOwner()).setText(null);
		} else {
			return;
		}

        if ((form.labOtherInsurance.hasFocus()) ||
            (form.labPayerID.hasFocus()) ||
            (form.labPCSID.hasFocus())) {
//        	form.labOtherInsurance.setText(null);
        	form.labPayerID.setText(null);
        	form.labPCSID.setText(null);
        }
        else if (form.labZip.hasFocus()) {
//        	form.labZip.setText(null);
        	form.labCity.setText(null);
        	form.labState.setText(null);
        }
		

	}
	@Override
	public void shiftf3Action(ActionEvent e) {

		LabForm form = (LabForm)this.parentFrame;
		form.updateHPV() ; 
	}
	
	
	

}
