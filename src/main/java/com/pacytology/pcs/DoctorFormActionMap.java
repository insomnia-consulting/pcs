package com.pacytology.pcs;

import com.pacytology.pcs.actions.BillingFormActionMap;
import com.pacytology.pcs.actions.PcsActionMap;

public class DoctorFormActionMap extends PcsActionMap {

	public DoctorFormActionMap(Object parentFrame) {
		super(parentFrame);

	}

	@Override
	public void finalAction() {
		DoctorForm form = (DoctorForm) DoctorFormActionMap.this.parentFrame;
		if ((form.currMode==Lab.ADD)||(form.currMode==Lab.UPDATE||form.currMode==Lab.MERGE)) { 
            form.finalActions();
            if (form.origin==DoctorForm.LAB) {
                form.parent2.setEnabled(true);
                form.dispose();
                form.parent2.toFront();

            }
        }
	}
	
	

}
