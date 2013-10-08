package com.pacytology.pcs.ui;

import java.awt.event.ActionEvent;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;

import javax.swing.*;

import com.pacytology.pcs.FunctionKeyControl;
import com.pacytology.pcs.actions.PcsActionMap;

public abstract class PcsFrame extends JFrame {
	protected PcsActionMap actionMap;
	public JLabel msgLabel = new javax.swing.JLabel();
	public FunctionKeyControl fKeys = new FunctionKeyControl();

	public abstract void queryActions();

	public abstract void addActions();

	public abstract void updateActions();

	public abstract void finalActions();

	public abstract void resetActions();

	protected JRootPane setupKeyPressMap() {
		JRootPane rp = getRootPane();
		KeyStroke f1 = KeyStroke.getKeyStroke(KeyEvent.VK_F1, 0, false);
		KeyStroke shiftf1 = KeyStroke.getKeyStroke(KeyEvent.VK_F1, ActionEvent.SHIFT_MASK, false);
		KeyStroke f2 = KeyStroke.getKeyStroke(KeyEvent.VK_F2, 0, false);
		KeyStroke f3 = KeyStroke.getKeyStroke(KeyEvent.VK_F3, 0, false);
		KeyStroke shiftf3 = KeyStroke.getKeyStroke(KeyEvent.VK_F3, ActionEvent.SHIFT_MASK, false);
		KeyStroke f4 = KeyStroke.getKeyStroke(KeyEvent.VK_F4, 0, false);
		KeyStroke f5 = KeyStroke.getKeyStroke(KeyEvent.VK_F5, 0, false);
		KeyStroke shiftf5 = KeyStroke.getKeyStroke(KeyEvent.VK_F5, ActionEvent.SHIFT_MASK, false);
		KeyStroke altf5 = KeyStroke.getKeyStroke(KeyEvent.VK_F5, ActionEvent.ALT_MASK, false);
		KeyStroke f6 = KeyStroke.getKeyStroke(KeyEvent.VK_F6, 0, false);
		KeyStroke f7 = KeyStroke.getKeyStroke(KeyEvent.VK_F7, 0, false);
		KeyStroke f8 = KeyStroke.getKeyStroke(KeyEvent.VK_F8, 0, false);
		KeyStroke f9 = KeyStroke.getKeyStroke(KeyEvent.VK_F9, 0, false);
		KeyStroke f10 = KeyStroke.getKeyStroke(KeyEvent.VK_F10, 0, false);
		KeyStroke f11 = KeyStroke.getKeyStroke(KeyEvent.VK_F11, 0, false);
		KeyStroke f12 = KeyStroke.getKeyStroke(KeyEvent.VK_F12, 0, false);
		KeyStroke esc = KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0, false);
		KeyStroke insert = KeyStroke.getKeyStroke(KeyEvent.VK_INSERT, 0, false);
		KeyStroke vk_i = KeyStroke.getKeyStroke(KeyEvent.VK_I, 0, false);
		KeyStroke down = KeyStroke.getKeyStroke(KeyEvent.VK_DOWN, 0, false);
		KeyStroke up = KeyStroke.getKeyStroke(KeyEvent.VK_UP, 0, false);
		KeyStroke left = KeyStroke.getKeyStroke(KeyEvent.VK_LEFT, 0, false);
		KeyStroke right = KeyStroke.getKeyStroke(KeyEvent.VK_RIGHT, 0, false);
		KeyStroke page_down = KeyStroke.getKeyStroke(KeyEvent.VK_PAGE_DOWN, 0,
				false);
		KeyStroke page_up = KeyStroke.getKeyStroke(KeyEvent.VK_PAGE_UP, 0,
				false);
		KeyStroke home = KeyStroke.getKeyStroke(KeyEvent.VK_HOME, 0, false);
		KeyStroke end = KeyStroke.getKeyStroke(KeyEvent.VK_END, 0, false);
		KeyStroke ctrl = KeyStroke.getKeyStroke(KeyEvent.VK_CONTROL,
				InputEvent.CTRL_DOWN_MASK, false);
		KeyStroke vk_enter = KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, 0, false);
		
		if (actionMap == null) {
			actionMap = new PcsActionMap(PcsFrame.this) {
			};
		}
		
		rp.getActionMap().put("F1", actionMap.queryAction);
		rp.getActionMap().put("shiftF1", actionMap.shiftf1Action);
		rp.getActionMap().put("F2", actionMap.addAction);
		rp.getActionMap().put("F3", actionMap.updateAction);
		rp.getActionMap().put("shiftF3", actionMap.shiftf3Action);
		rp.getActionMap().put("F4", actionMap.f4Action);
		rp.getActionMap().put("F5", actionMap.f5Action);
		rp.getActionMap().put("shiftF5", actionMap.shiftf5Action);
		rp.getActionMap().put("altF5", actionMap.altf5Action);
		rp.getActionMap().put("F9", actionMap.closeAction);
		rp.getActionMap().put("F12", actionMap.finalAction);
		rp.getActionMap().put("ESC", actionMap.resetAction);
		rp.getActionMap().put("VK_CONTROL", actionMap.controlAction);
		
		
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f1, "F1");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(shiftf1, "shiftF1");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f2, "F2");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f3, "F3");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(shiftf3, "shiftF3");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f4, "F4");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f5, "F5");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(shiftf5, "shiftF5");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(altf5, "altF5");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f6, "F6");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f7, "F7");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f8, "F8");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f9, "F9");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f10, "F10");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f11, "F11");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f12, "F12");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(esc, "ESC");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(insert, "INSERT");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(vk_i, "VK_I");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(down, "VK_DOWN");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(up, "VK_UP");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(left, "VK_LEFT");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(right, "VK_RIGHT");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(page_down,
				"VK_PAGE_DOWN");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(page_up,
				"VK_PAGE_UP");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(home, "VK_HOME");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(end, "VK_END");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(ctrl,
				"VK_CONTROL");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(vk_enter, "VK_ENTER");
		

		/*
		 * actionMap is assigned a actionMap that matches the form ie., LabFor
		 * => LabFormActionMap This only needs to happen if the actionMap has
		 * specific behaviors; if the default behaviors are sufficient, the we
		 * can create an anonymous ActionMap for this case
		 */
		
		return rp;
	}

    /**
     * Convenience method for adding keymappings for Mac OSX.
     *
     * If the OS is not an OSX vairant the method returns without adding anything.
     * @param keyName
     * @param action
     */
    protected void addMacKeyMapping(String keyName, AbstractAction action) {
        String osName = System.getProperty("os.name").toLowerCase();
        boolean isMacOs = osName.startsWith("mac os x");
		if (!isMacOs) {
            return;
        }
        JRootPane rp = getRootPane();
		rp.getActionMap().put(keyName, action);
    }
}
