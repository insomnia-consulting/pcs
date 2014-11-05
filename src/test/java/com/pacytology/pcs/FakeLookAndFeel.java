package com.pacytology.pcs;

import javax.swing.plaf.basic.BasicLookAndFeel;

public class FakeLookAndFeel extends BasicLookAndFeel {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
    public String getName() {
        return "FakeLookAndFill";
    }

    @Override
    public String getID() {
        return "FakeLookAndFill";
    }

    @Override
    public String getDescription() {
        return "FakeLookAndFill";
    }

    @Override
    public boolean isNativeLookAndFeel() {
        return false;
    }

    @Override
    public boolean isSupportedLookAndFeel() {
        //note it returns true
        return true;
    }
}
