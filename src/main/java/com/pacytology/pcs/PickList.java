package com.pacytology.pcs;

/*
    PENNSYLVANIA CYTOLOGY SERVICES
    LABORATORY INFORMATION SYSTEM V1.0
    Copyright (C) 2001 by John Cardella
    All Rights Reserved
    
    File:       PickList.java
    Created By: John Cardella, Software Engineer
    
    Function:   A generic container used to display a picklist
    of information, or to display some type of static information.
    Note there are a number of different constructors.
    
    MODIFICATIONS ----------------------------------
    Date/Staff      Description:
*/

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;

import javax.swing.*;

import com.pacytology.pcs.ui.Square;
import java.io.File;
import java.io.FileOutputStream;

public class PickList extends javax.swing.JDialog
{
    private final int xGap=22;
    private final int yGap=49;
    private final int xPane=12;
    private final int yPane=40;
    private final int msgLblGap=16;
    private final int NEW_PAGE=12;
    private int height=520;
    private int width=0;
    private int x;
    private int y;
    private int MAX_ITEMS;
    public String[] formattedList;
    public String[] actualList;
    public JTextField pickListField;
    public JTextArea pickListText;
    boolean infoOnly = false;
    boolean isText = false;

	public PickList()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setResizable(false);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(310,276);
		setVisible(false);
		ListPane.setOpaque(true);
		getContentPane().add(ListPane);
		ListPane.setBounds(18,84,276,174);
		ListPane.getViewport().add(ItemList);
		ItemList.setFont(new Font("MonoSpaced", Font.PLAIN, 11));
		ItemList.setBounds(0,0,273,171);
		getContentPane().add(F9sq);
		F9sq.setBounds(88,6,20,20);
		F9lbl.setRequestFocusEnabled(false);
		F9lbl.setText("F9");
		getContentPane().add(F9lbl);
		F9lbl.setForeground(java.awt.Color.black);
		F9lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F9lbl.setBounds(92,6,20,20);
		getContentPane().add(F11sq);
		F11sq.setBounds(148,6,20,20);
		F11lbl.setRequestFocusEnabled(false);
		F11lbl.setText("F11");
		getContentPane().add(F11lbl);
		F11lbl.setForeground(java.awt.Color.black);
		F11lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F11lbl.setBounds(149,6,20,20);
		F9action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F9action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F9action.setText("Exit");
		getContentPane().add(F9action);
		F9action.setForeground(java.awt.Color.black);
		F9action.setBounds(64,25,70,16);
		F11action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F11action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F11action.setText("Select");
		getContentPane().add(F11action);
		F11action.setForeground(java.awt.Color.black);
		F11action.setBounds(124,25,70,16);
		printerConfirm.setMessageType(javax.swing.JOptionPane.QUESTION_MESSAGE);
		//$$ printerConfirm.move(0,277);
		getContentPane().add(F1sq);
		F1sq.setBounds(28,6,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F1");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(32,6,20,20);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Print");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(4,25,70,16);
		ItemList.setSelectedIndex(0);
		//}}

        this.setModal(true);
        Utils.setColors(this.getContentPane());
		this.getContentPane().setBackground((Color.red).darker());
		ItemList.setFont(new Font("MonoSpaced", Font.PLAIN, 10));
		this.repaint();

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		//}}
		JRootPane rp = this.setupKeyPressMap();
		rp.getActionMap().put("F1", new AbstractAction() {

			public void actionPerformed(ActionEvent e) {
				if (verifyPrinter()) genericPrint(true);	
			}
		});
		rp.getActionMap().put("F9", new AbstractAction() {

			public void actionPerformed(ActionEvent e) {
				if (!infoOnly) pickListField.setText(null);
				Component comp = (Component) e.getSource();
				Window window = SwingUtilities.windowForComponent(comp);
				if(window instanceof Dialog){
					window.dispose();
				}	
			}
		});
		AbstractAction exitAction = new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				if (ItemList.getSelectedIndex()!=(-1))  {
	                if (isText) {
	                    pickListText.append(actualList[ItemList.getSelectedIndex()]);
	                    pickListText.requestFocus();
	                }
	                else {
	                    pickListField.setText(actualList[ItemList.getSelectedIndex()]);
	                    pickListField.requestFocus();
	                }
	            }
	            PickList.this.dispose();

			}			
		};
		rp.getActionMap().put("F11",exitAction);
		rp.getActionMap().put("ENTER",exitAction);
	}

	public JRootPane setupKeyPressMap() {
		JRootPane rp = getRootPane();
		KeyStroke f1 = KeyStroke.getKeyStroke(KeyEvent.VK_F1, 0, false);
		KeyStroke f9 = KeyStroke.getKeyStroke(KeyEvent.VK_F9, 0, false);
		KeyStroke f11 = KeyStroke.getKeyStroke(KeyEvent.VK_F11, 0, false);
		KeyStroke enter = KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, 0, false);

		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f1, "F1");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f9, "F9");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(f11, "F11");
		rp.getInputMap(JComponent.WHEN_IN_FOCUSED_WINDOW).put(enter, "ENTER");

		return rp;
	}
    public PickList(String sTitle,int x,int y,int width,int items,
                    String[] formattedList,
                    String[] actualList,
                    JTextField pickListField)
    {
        this();
        setTitle(sTitle);
        this.pickListField=pickListField;
        this.x=x;
        this.y=y;
        this.width=width;
        this.MAX_ITEMS=items;
        this.setSize(this.width,this.height);
        this.ListPane.setSize(this.width-xGap,this.height-yGap);
        this.formattedList=formattedList;
        this.actualList=actualList;
        this.ListPane.setBounds(xPane,yPane,this.width-xGap,this.height-yGap);
        this.ItemList.setBounds(0,0,this.ListPane.getX()-3,
                                    this.ListPane.getY()-3);
        this.ItemList.setListData(this.formattedList);
        this.ItemList.ensureIndexIsVisible(0);            
        this.ItemList.setSelectedIndex(0);
        this.ItemList.repaint();
        this.ItemList.revalidate();
    }                

    public PickList(String sTitle,int x,int y,int width,int height,
                    int items,String[] formattedList,
                    String[] actualList,
                    JTextField pickListField)
    {
        this();
        setTitle(sTitle);
        this.pickListField=pickListField;
        this.x=x;
        this.y=y;
        this.width=width;
        this.height=height;
        this.MAX_ITEMS=items;
        this.setSize(this.width,this.height);
        this.ListPane.setSize(this.width-xGap,this.height-yGap);
        this.formattedList=formattedList;
        this.actualList=actualList;
        this.ListPane.setBounds(xPane,yPane,this.width-xGap,this.height-yGap);
        this.ItemList.setBounds(0,0,this.ListPane.getX()-3,
                                    this.ListPane.getY()-3);
        this.ItemList.setListData(this.formattedList);
        this.ItemList.ensureIndexIsVisible(0);            
        this.ItemList.setSelectedIndex(0);
        this.ItemList.repaint();
        this.ItemList.revalidate();
    }                

    public PickList(String sTitle,int x,int y,int width,int height,
                    int items,String[] formattedList,
                    String[] actualList,
                    JTextArea pickListText)
    {
        this();
        setTitle(sTitle);
        this.isText=true;
        this.pickListText=pickListText;
        this.x=x;
        this.y=y;
        this.width=width;
        this.height=height;
        this.MAX_ITEMS=items;
        this.setSize(this.width,this.height);
        this.ListPane.setSize(this.width-xGap,this.height-yGap);
        this.formattedList=formattedList;
        this.actualList=actualList;
        this.ListPane.setBounds(xPane,yPane,this.width-xGap,this.height-yGap);
        this.ItemList.setBounds(0,0,this.ListPane.getX()-3,
                                    this.ListPane.getY()-3);
        this.ItemList.setListData(this.formattedList);
        this.ItemList.ensureIndexIsVisible(0);            
        this.ItemList.setSelectedIndex(0);
        this.ItemList.repaint();
        this.ItemList.revalidate();
    }                

    /*
        information list only; nothing to pick from
    */
    public PickList(String sTitle,int x,int y,int width,int height,
                    int items,String[] formattedList)
    {
        this();
        setTitle(sTitle);
        this.pickListField=null;
        this.x=x;
        this.y=y;
        this.width=width;
        this.height=height;
        this.MAX_ITEMS=items;
        this.setSize(this.width,this.height);
        this.ListPane.setSize(this.width-xGap,this.height-yGap);
        this.formattedList=formattedList;
        this.actualList=formattedList;
        this.ListPane.setBounds(xPane,yPane,this.width-xGap,this.height-yGap);
        this.ItemList.setBounds(0,0,this.ListPane.getX()-3,
                                    this.ListPane.getY()-3);
        this.ItemList.setListData(this.formattedList);
        for (int i=0;i<items;i++)
            this.ItemList.ensureIndexIsVisible(i);
        this.ItemList.ensureIndexIsVisible(0);            
        this.ItemList.setSelectedIndex(0);
        this.F11action.setVisible(false);
        this.F11sq.setVisible(false);
        this.F11lbl.setVisible(false);
        this.infoOnly=true;
    }                

	public void setVisible(boolean b)
	{
		if (b) setLocation(x,y);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new PickList()).setVisible(true);
	}

	public void addNotify()
	{
		// Record the size of the window prior to calling parents addNotify.
		Dimension size = getSize();

		super.addNotify();

		if (frameSizeAdjusted)
			return;
		frameSizeAdjusted = true;

		// Adjust size of frame according to the insets and menu bar
		Insets insets = getInsets();
		javax.swing.JMenuBar menuBar = getRootPane().getJMenuBar();
		int menuBarHeight = 0;
		if (menuBar != null)
			menuBarHeight = menuBar.getPreferredSize().height;
		setSize(insets.left + insets.right + size.width, insets.top + insets.bottom + size.height + menuBarHeight);
	}

	// Used by addNotify
	boolean frameSizeAdjusted = false;

	//{{DECLARE_CONTROLS
	javax.swing.JScrollPane ListPane = new javax.swing.JScrollPane();
	javax.swing.JList ItemList = new javax.swing.JList();
	Square F9sq = new Square();
	javax.swing.JLabel F9lbl = new javax.swing.JLabel();
	Square F11sq = new Square();
	javax.swing.JLabel F11lbl = new javax.swing.JLabel();
	javax.swing.JLabel F9action = new javax.swing.JLabel();
	javax.swing.JLabel F11action = new javax.swing.JLabel();
	javax.swing.JOptionPane printerConfirm = new javax.swing.JOptionPane();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	//}}

	//{{DECLARE_MENUS
	//}}


	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == PickList.this)
				PickList_keyPressed(event);
		}
	}

    void addInterval()
    {
        int anchor = ItemList.getAnchorSelectionIndex();
        int lead = ItemList.getLeadSelectionIndex()+1;
        if (lead>=MAX_ITEMS) lead=MAX_ITEMS-1;
        ItemList.addSelectionInterval(anchor,lead);
    }
    
    void subtractInterval()
    {
        int anchor = ItemList.getAnchorSelectionIndex();
        int lead = ItemList.getLeadSelectionIndex()-1;
        if (lead<0) lead=0;
        ItemList.clearSelection();
        ItemList.addSelectionInterval(anchor,lead);
    }

    void incrementList() {
        if (ItemList.getSelectedIndex()==(-1))
            ItemList.setSelectedIndex(0);
        else if (ItemList.getSelectedIndex()!=(MAX_ITEMS-1)) {
            ItemList.setSelectedIndex(ItemList.getSelectedIndex()+1);
            ItemList.ensureIndexIsVisible(ItemList.getSelectedIndex()+1);
        }
    }
    
    void decrementList() {
        if (ItemList.getSelectedIndex()==(-1))
            ItemList.setSelectedIndex(0);
        else if (ItemList.getSelectedIndex()!=0) {
            ItemList.setSelectedIndex(ItemList.getSelectedIndex()-1);
            ItemList.ensureIndexIsVisible(ItemList.getSelectedIndex()-1);
        }
    }

	void PickList_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==java.awt.event.KeyEvent.VK_DOWN)  {
		    if (event.isShiftDown()) addInterval();
		    else incrementList();
        }		        
		else if (event.getKeyCode()==java.awt.event.KeyEvent.VK_UP)  {
		    if (event.isShiftDown()) subtractInterval();
		    else decrementList();
        }		        
        else if (event.getKeyCode()==event.VK_F1) {
            
        }
        else if (event.getKeyCode()==java.awt.event.KeyEvent.VK_F9)  {
            
        }            
        else if (event.getKeyCode()==event.VK_ESCAPE) {
            this.dispose();
        }
        /*
            If a row of data can be selected, pressing either of these
            keys sets the data in the associated JTextField to the
            value in the actualList array that corresponds to the 
            formatted data that is selected in the JList
        */
        else if (event.getKeyCode()==java.awt.event.KeyEvent.VK_F11 ||
                 event.getKeyCode()==java.awt.event.KeyEvent.VK_ENTER)  {
            
        }            
        else if (event.getKeyCode()==event.VK_PAGE_DOWN) {
            int rows=ItemList.getVisibleRowCount();
            int next=ItemList.getSelectedIndex()+rows;
            if (next<MAX_ITEMS+1) {
                ItemList.setSelectedIndex(next);
                ItemList.ensureIndexIsVisible(next);
            }
        }
        else if (event.getKeyCode()==event.VK_PAGE_UP) {
            int rows=ItemList.getVisibleRowCount();
            int next=ItemList.getSelectedIndex()-rows;
            if (next>0) {
                ItemList.setSelectedIndex(next);
                ItemList.ensureIndexIsVisible(next);
            }
        }
        else if (event.getKeyCode()==event.VK_END) {
            ItemList.setSelectedIndex(MAX_ITEMS-1);
            ItemList.ensureIndexIsVisible(MAX_ITEMS-1);
        }
        else if (event.getKeyCode()==event.VK_HOME) {
            ItemList.setSelectedIndex(0);
            ItemList.ensureIndexIsVisible(0);
        }
	}
	
	int getMaxLine()
	{
	    int maxLength = 0;
	    for (int i=0; i<MAX_ITEMS; i++) {
	        String s = formattedList[i];
	        if (s.length()>maxLength)
	            maxLength=s.length();
	    }
	    return maxLength;
	}
	
	void genericPrint(boolean forcePage)
	{
        File f;
        FileOutputStream fOUT;
        f = new File("c:\\","lpt1");
        int maxLen = getMaxLine();
        if (maxLen>130) { if (!verifyPaper()) return; }
        int page = 1;
        int startNdx = ItemList.getAnchorSelectionIndex();
        int endNdx = ItemList.getLeadSelectionIndex();
        if (endNdx-startNdx==0) {
            startNdx=0;
            endNdx=MAX_ITEMS;
        }
        else endNdx++;
        String margin = "     ";
        try {
            fOUT = new FileOutputStream(f);
            for (int i=startNdx, line=0; i<endNdx; i++) {
                String s = null;
                if (line==0) {
                    if (i==startNdx) {
                        // initialize Epson printer
                        fOUT.write(27);
                        fOUT.write(64);
                        // set to pica
                        if (maxLen<=70) {
                            fOUT.write(27);
                            fOUT.write(80);
                        }
                        // set to elite
                        else if (maxLen>70 && maxLen<=100) {
                            fOUT.write(27);
                            fOUT.write(77);
                        }
                        // set to condensed
                        else {
                            fOUT.write(27);
                            fOUT.write(15);
                        }
                    }
                    fOUT.write((int)'\n'); line++;
                    s=margin+this.getTitle();
                    for (int j=0; j<s.length(); j++) {
                        char c = s.charAt(j);
                        fOUT.write((int)c);
                    }
                    fOUT.write((int)'\n'); line++;
                    s=margin+"Page "+page;
                    for (int j=0; j<s.length(); j++) {
                        char c = s.charAt(j);
                        fOUT.write((int)c);
                    }
                    fOUT.write((int)'\n'); line++;
                    fOUT.write((int)'\n'); line++;
                }
                s = margin+formattedList[i];
                for (int j=0; j<s.length(); j++) {
                    char c = s.charAt(j);
                    fOUT.write((int)c);
                }
                fOUT.write((int)'\n'); line++;
                if (line==60) { 
                    line=0;
                    page++;
                    fOUT.write(NEW_PAGE);
                }
            }
            if (forcePage) fOUT.write(NEW_PAGE);
            fOUT.close();
        }
        catch (Exception e) { /*log.write(e);*/ }
	}

	boolean verifyPrinter()
	{
	    boolean status = false;
		int rv = printerConfirm.showConfirmDialog(this,"Make sure printer is ready. \nPrint data now?",
		    this.getTitle(),printerConfirm.YES_NO_OPTION,printerConfirm.QUESTION_MESSAGE);
		if (rv==printerConfirm.YES_OPTION) {
		    status=true;
		}
		return (status);
	}
	
	boolean verifyPaper()
	{
	    boolean status = false;
		int rv = printerConfirm.showConfirmDialog(this,"Wide paper is required. \nContinue print job?",
		    this.getTitle(),printerConfirm.YES_NO_OPTION,printerConfirm.QUESTION_MESSAGE);
		if (rv==printerConfirm.YES_OPTION) {
		    status=true;
		}
		return (status);
	}
	
}
