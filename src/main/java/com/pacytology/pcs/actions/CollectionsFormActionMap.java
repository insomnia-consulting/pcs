package com.pacytology.pcs.actions;

import java.awt.event.ActionEvent;

import com.pacytology.pcs.CollectionsForm;
import com.pacytology.pcs.Utils;
import com.pacytology.pcs.ui.PcsFrame;

public class CollectionsFormActionMap extends PcsActionMap {

	public CollectionsFormActionMap(Object parentFrame) {
		super(parentFrame);
	}
	@Override
	public void queryAction()  {
		if (parentFrame instanceof PcsFrame) {  
        	((PcsFrame)parentFrame).queryActions();
		} 

	}
	@Override
	public void addAction(ActionEvent e) {
		if (parentFrame instanceof PcsFrame) {  
        	((PcsFrame)parentFrame).addActions();
		}
    
	}
	@Override
	public void updateAction(ActionEvent e) {
		if (parentFrame instanceof PcsFrame) {  
        	((PcsFrame)parentFrame).updateActions();
		}
	}
	@Override
	public void f4Action(ActionEvent e) {
		CollectionsForm frame = null ;
		if (parentFrame instanceof CollectionsForm) {  
        	frame = (CollectionsForm)parentFrame;
		}
		String rName=frame.getReport();
        if (!Utils.isNull(rName))  {
            frame.viewReport(rName);
            if (frame.screenMode==frame.QUEUE && !rName.equals("PENDING.col")) 
                frame.closingActions();
        }
	}

}
