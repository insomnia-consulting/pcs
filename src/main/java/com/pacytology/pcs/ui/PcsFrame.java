package com.pacytology.pcs.ui;

import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;

import javax.swing.AbstractAction;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JRootPane;
import javax.swing.KeyStroke;

public abstract class PcsFrame extends JFrame {
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = getRootPane();
		KeyStroke f1 = KeyStroke.getKeyStroke(KeyEvent.VK_F1, 0, false);
		KeyStroke f2 = KeyStroke.getKeyStroke(KeyEvent.VK_F2, 0, false);
		KeyStroke f3 = KeyStroke.getKeyStroke(KeyEvent.VK_F3, 0, false);
		KeyStroke f4 = KeyStroke.getKeyStroke(KeyEvent.VK_F4, 0, false);
		KeyStroke f5 = KeyStroke.getKeyStroke(KeyEvent.VK_F5, 0, false);
		KeyStroke f6 = KeyStroke.getKeyStroke(KeyEvent.VK_F6, 0, false);
		KeyStroke f7 = KeyStroke.getKeyStroke(KeyEvent.VK_F7, 0, false);
		KeyStroke f8 = KeyStroke.getKeyStroke(KeyEvent.VK_F8, 0, false);
		KeyStroke f9 = KeyStroke.getKeyStroke(KeyEvent.VK_F9, 0, false);
		KeyStroke f10 = KeyStroke.getKeyStroke(KeyEvent.VK_F10, 0, false);
		KeyStroke f11 = KeyStroke.getKeyStroke(KeyEvent.VK_F11, 0, false);
		KeyStroke f12 = KeyStroke.getKeyStroke(KeyEvent.VK_F12, 0, false);		
		KeyStroke esc = KeyStroke.getKeyStroke(KeyEvent.VK_ESCAPE, 0, false);		
		KeyStroke insert= KeyStroke.getKeyStroke(KeyEvent.VK_INSERT, 0, false);		
		KeyStroke vk_i= KeyStroke.getKeyStroke(KeyEvent.VK_I, 0, false);		
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f1, "F1");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f2, "F2");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f3, "F3");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f4, "F4");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f5, "F5");
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
		
		
		return rp;
	}

}
