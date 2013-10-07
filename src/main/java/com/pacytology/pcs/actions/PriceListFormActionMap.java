package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.Lab;
import com.pacytology.pcs.PriceListForm;

public class PriceListFormActionMap extends PcsActionMap {

	@Override
	public void f5Action(ActionEvent e) {
		PriceListForm form = (PriceListForm)PriceListFormActionMap.this.parentFrame;
		form.displayPractices((String)form.priceCode.getText());
	}

	public PriceListFormActionMap(Object parentFrame) {
		super(parentFrame);
		// TODO Auto-generated constructor stub
	}

	@Override
	public void f4Action(ActionEvent e) {
		PriceListForm form = (PriceListForm)PriceListFormActionMap.this.parentFrame;
		form.msgLabel.setText(null);
	    form.deleteActions();
	}

	@Override
	public void resetAction() {
		PriceListForm form = (PriceListForm)PriceListFormActionMap.this.parentFrame;
		 form.currMode=Lab.IDLE;
         form.resetForm();
         form.displayList(0,form.priceNdx);
         form.setEntryFields();
         
         
	}

	@Override
	public void updateAction(ActionEvent e) {
		PriceListForm form = (PriceListForm)PriceListFormActionMap.this.parentFrame;
		form.updateActions() ; 
	}
	
	
	


}
