package com.pacytology.pcs.ui;
/*
		A basic implementation of the JDialog class.
*/

import java.awt.Component;
import java.awt.Dimension;
import java.awt.Frame;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Point;
import java.awt.Rectangle;

import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.SwingConstants;

public class JAboutDialog extends JDialog
{
	private static final long serialVersionUID = 6387826078611336864L;

	public JAboutDialog(Frame parentFrame)
	{
		super(parentFrame);
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Pennsylvania Cytology Services");
		setModal(true);
		getContentPane().setLayout(new GridBagLayout());
		setSize(248,94);
		setVisible(false);
		aboutLabel.setHorizontalAlignment(SwingConstants.CENTER);
		aboutLabel.setText("A JFC Application");
		getContentPane().add(aboutLabel, new GridBagConstraints(0,0,3,1,1.0,1.0,java.awt.GridBagConstraints.CENTER,java.awt.GridBagConstraints.BOTH,new Insets(0,0,0,0),0,0));
		aboutLabel.setBounds(0,0,248,94);
		//}}

        aboutLabel.setText("Laboratory Information System");

		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymAction lSymAction = new SymAction();
		//}}
	}

	public void setVisible(boolean b)
	{
	    if (b)
	    {
    		Rectangle bounds = (getParent()).getBounds();
    		Dimension size = getSize();
    		setLocation(bounds.x + (bounds.width - size.width)/2,
    			        bounds.y + (bounds.height - size.height)/2);
	    }

		super.setVisible(b);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension d = getSize();

		super.addNotify();

		if (fComponentsAdjusted)
			return;
		// Adjust components according to the insets
		Insets insets = getInsets();
		setSize(insets.left + insets.right + d.width, insets.top + insets.bottom + d.height);
		Component components[] = getContentPane().getComponents();
		for (int i = 0; i < components.length; i++)
		{
			Point p = components[i].getLocation();
			p.translate(insets.left, insets.top);
			components[i].setLocation(p);
		}
		fComponentsAdjusted = true;
	}

	// Used for addNotify check.
	boolean fComponentsAdjusted = false;

	//{{DECLARE_CONTROLS
	JLabel aboutLabel = new JLabel();
	//}}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowClosing(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == JAboutDialog.this)
				jAboutDialog_windowClosing(event);
		}
	}

	void jAboutDialog_windowClosing(java.awt.event.WindowEvent event)
	{
		// to do: code goes here.
			 
		jAboutDialog_windowClosing_Interaction1(event);
	}

	void jAboutDialog_windowClosing_Interaction1(java.awt.event.WindowEvent event) {
		try {
			// JAboutDialog Hide the JAboutDialog
			this.setVisible(false);
		} catch (Exception e) {
		}
	}
	
	class SymAction implements java.awt.event.ActionListener
	{
	public void actionPerformed(java.awt.event.ActionEvent event)
		{
		}
	}
}
