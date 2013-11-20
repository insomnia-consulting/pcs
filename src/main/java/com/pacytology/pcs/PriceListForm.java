package com.pacytology.pcs;

import java.awt.*;
import java.awt.event.ActionEvent;

import javax.swing.*;

import com.pacytology.pcs.actions.LabFormActionMap;
import com.pacytology.pcs.actions.PriceListFormActionMap;
import com.pacytology.pcs.ui.PcsFrame;
import com.pacytology.pcs.ui.Square;
import java.sql.*;
import java.util.Vector;


public class PriceListForm extends PcsFrame
{
    public Login dbLogin;
    public int MAX_PRICE_CODES=0;
    public PriceArray[] priceCodes;
    public int MAX_PROC_CODES=0;
    public ProcedureCodeRec[] procedureCodes;
    /*
    final int IDLE=100;
    final int QUERY=101;
    final int ADD=102;
    final int UPDATE=103;
    final int DELETE=104;
    */
    public int currMode=Lab.IDLE;    
    final int CODES_PER_SCREEN=15;
    public int rowID=1;
    public int priceNdx=0;
    private int priceSwitch=0;
    
    
	public PriceListForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Pricing Maintenance");
		setResizable(false);
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(600,426);
		setVisible(false);
		codePane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		codePane.setOpaque(true);
		codePane.setEnabled(false);
		getContentPane().add(codePane);
		codePane.setBounds(30,150,90,258);
		codeList.setEnabled(false);
		codePane.getViewport().add(codeList);
		codeList.setFont(new Font("MonoSpaced", Font.PLAIN, 12));
		codeList.setBounds(0,0,87,255);
		getContentPane().add(F1sq);
		F1sq.setBounds(35,6,20,20);
		F1lbl.setRequestFocusEnabled(false);
		F1lbl.setText("F1");
		getContentPane().add(F1lbl);
		F1lbl.setForeground(java.awt.Color.black);
		F1lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F1lbl.setBounds(39,6,20,20);
		getContentPane().add(F2sq);
		F2sq.setBounds(97,6,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F2");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(101,6,20,20);
		getContentPane().add(F3sq);
		F3sq.setBounds(159,6,20,20);
		F3lbl.setRequestFocusEnabled(false);
		F3lbl.setText("F3");
		getContentPane().add(F3lbl);
		F3lbl.setForeground(java.awt.Color.black);
		F3lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F3lbl.setBounds(163,6,20,20);
		getContentPane().add(F4sq);
		F4sq.setBounds(221,6,20,20);
		F4lbl.setRequestFocusEnabled(false);
		F4lbl.setText("F4");
		getContentPane().add(F4lbl);
		F4lbl.setForeground(java.awt.Color.black);
		F4lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F4lbl.setBounds(225,6,20,20);
		getContentPane().add(F9sq);
		F9sq.setBounds(345,6,20,20);
		F9lbl.setRequestFocusEnabled(false);
		F9lbl.setText("F9");
		getContentPane().add(F9lbl);
		F9lbl.setForeground(java.awt.Color.black);
		F9lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F9lbl.setBounds(349,6,20,20);
		F5lbl.setRequestFocusEnabled(false);
		F5lbl.setText("F5");
		getContentPane().add(F5lbl);
		F5lbl.setForeground(java.awt.Color.black);
		F5lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F5lbl.setBounds(287,6,20,20);
		getContentPane().add(F12sq);
		F12sq.setBounds(407,6,20,20);
		getContentPane().add(F5sq);
		F5sq.setBounds(283,6,20,20);
		F12lbl.setRequestFocusEnabled(false);
		F12lbl.setText("F12");
		getContentPane().add(F12lbl);
		F12lbl.setForeground(java.awt.Color.black);
		F12lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F12lbl.setBounds(408,6,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Add");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(72,30,70,16);
		F3action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F3action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F3action.setText("Update");
		getContentPane().add(F3action);
		F3action.setForeground(java.awt.Color.black);
		F3action.setBounds(134,30,70,16);
		F4action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F4action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F4action.setText("Status");
		getContentPane().add(F4action);
		F4action.setForeground(java.awt.Color.black);
		F4action.setBounds(196,30,70,16);
		F9action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F9action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F9action.setText("Exit");
		getContentPane().add(F9action);
		F9action.setForeground(java.awt.Color.black);
		F9action.setBounds(320,30,70,16);
		F12action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F12action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F12action.setText("Submit");
		getContentPane().add(F12action);
		F12action.setForeground(java.awt.Color.black);
		F12action.setBounds(382,30,70,16);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		msgLabel.setBounds(44,52,372,20);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Query");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,70,16);
		procCode.setEnabled(false);
		getContentPane().add(procCode);
		procCode.setFont(new Font("DialogInput", Font.PLAIN, 12));
		procCode.setBounds(30,116,90,20);
		basePrice.setEnabled(false);
		getContentPane().add(basePrice);
		basePrice.setFont(new Font("DialogInput", Font.PLAIN, 12));
		basePrice.setBounds(128,116,60,20);
		JLabel2.setText("Code");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(30,102,96,12);
		JLabel3.setText("Base Price");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(128,102,78,12);
		JLabel1.setText("Active Status");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(144,78,78,12);
		codeStatus.setEnabled(false);
		getContentPane().add(codeStatus);
		codeStatus.setBounds(228,76,30,20);
		priceCode.setEnabled(false);
		getContentPane().add(priceCode);
		priceCode.setBounds(102,76,30,20);
		JLabel4.setText("Price Code");
		getContentPane().add(JLabel4);
		JLabel4.setBounds(30,78,64,12);
		basePane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		basePane.setOpaque(true);
		basePane.setEnabled(false);
		getContentPane().add(basePane);
		basePane.setBounds(130,150,60,258);
		baseList.setEnabled(false);
		basePane.getViewport().add(baseList);
		baseList.setFont(new Font("MonoSpaced", Font.PLAIN, 12));
		baseList.setBounds(0,0,57,255);
		discountPane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		discountPane.setOpaque(true);
		discountPane.setEnabled(false);
		getContentPane().add(discountPane);
		discountPane.setBounds(200,150,60,258);
		discountList.setEnabled(false);
		discountPane.getViewport().add(discountList);
		discountList.setFont(new Font("MonoSpaced", Font.PLAIN, 12));
		discountList.setBounds(0,0,57,255);
		discountPrice.setEnabled(false);
		getContentPane().add(discountPrice);
		discountPrice.setFont(new Font("DialogInput", Font.PLAIN, 12));
		discountPrice.setBounds(198,116,60,20);
		JLabel5.setText("Physican Price");
		getContentPane().add(JLabel5);
		JLabel5.setBounds(200,102,88,12);
		descPane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		descPane.setOpaque(true);
		descPane.setEnabled(false);
		getContentPane().add(descPane);
		descPane.setBounds(270,150,316,258);
		descList.setEnabled(false);
		descPane.getViewport().add(descList);
		descList.setFont(new Font("MonoSpaced", Font.PLAIN, 12));
		descList.setBounds(0,0,313,255);
		JLabel6.setText("Procedure Code Description");
		getContentPane().add(JLabel6);
		JLabel6.setBounds(272,132,180,12);
		priceChangeConfirm.setWantsInput(true);
		priceChangeConfirm.setMessageType(javax.swing.JOptionPane.QUESTION_MESSAGE);
		priceChangeConfirm.setVisible(false);
		priceChangeConfirm.setOptionType(javax.swing.JOptionPane.YES_NO_OPTION);
		//$$ priceChangeConfirm.move(0,427);
		F5action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F5action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F5action.setText("Practices");
		getContentPane().add(F5action);
		F5action.setForeground(java.awt.Color.black);
		F5action.setBounds(258,30,70,16);
		//$$ JOptionPane1.move(0,427);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymMouse aSymMouse = new SymMouse();
		codeList.addMouseListener(aSymMouse);
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		procCode.addKeyListener(aSymKey);
		basePrice.addKeyListener(aSymKey);
		priceCode.addKeyListener(aSymKey);
		//}}
		
		actionMap = new PriceListFormActionMap(this);
		setupKeyPressMap();
	}
	protected JRootPane setupKeyPressMap() {
		JRootPane rp = super.setupKeyPressMap();
		rp.getActionMap().put("VK_UP", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				increment();
			}
		});
		rp.getActionMap().put("VK_DOWN", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				decrement();
			}
		});
		rp.getActionMap().put("VK_LEFT", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				left();
			}
		});
		rp.getActionMap().put("VK_RIGHT", new AbstractAction() {
			public void actionPerformed(ActionEvent e) {
				right();
			}
		});
		
		return rp;
	}
	protected void left() {
		msgLabel.setText(null);
        priceNdx--;
        if (priceNdx<0) priceNdx=0;
        else displayList(0,priceNdx);
	}
	protected void right() {
		msgLabel.setText(null);
        priceNdx++;
        if (priceNdx>=MAX_PRICE_CODES) priceNdx--;
        else displayList(0,priceNdx);
	}
	protected void decrement() {
		int ndx = 0;
		if (currMode==Lab.IDLE) {
            msgLabel.setText(null);
            ndx=descList.getSelectedIndex();
            ndx+=1;
            if (ndx>=MAX_PROC_CODES) ndx=MAX_PROC_CODES-1;
            displayList(ndx,priceNdx);
            setEntryFields();
            }
	        
		
	}
	protected void increment() {
		int ndx = 0;
		if (currMode==Lab.IDLE) {
            msgLabel.setText(null);
	        if ((codeList.getSelectedIndex()==(-1))
	         || (descList.getSelectedIndex()==(-1)))
	        {
	            ndx=0;
	        }
	        else ndx=descList.getSelectedIndex()-1;
            if (ndx==(-1)) ndx=0;
            displayList(ndx,priceNdx);
            setEntryFields();
	        }
	        
		
	}
	public PriceListForm(String sTitle)
	{
		this();
		setTitle(sTitle);
	}

    public PriceListForm(Login dbLogin) {
        this();
        this.dbLogin=dbLogin;
        this.getProcedureCodes();
        this.getPricing();
        this.displayList(0,priceNdx);
        this.resetForm();
    }

	public void setVisible(boolean b)
	{
		if (b) setLocation(50, 50);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new PriceListForm()).setVisible(true);
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
	javax.swing.JScrollPane codePane = new javax.swing.JScrollPane();
	javax.swing.JList codeList = new javax.swing.JList();
	Square F1sq = new Square();
	javax.swing.JLabel F1lbl = new javax.swing.JLabel();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	Square F3sq = new Square();
	javax.swing.JLabel F3lbl = new javax.swing.JLabel();
	Square F4sq = new Square();
	javax.swing.JLabel F4lbl = new javax.swing.JLabel();
	Square F9sq = new Square();
	javax.swing.JLabel F9lbl = new javax.swing.JLabel();
	javax.swing.JLabel F5lbl = new javax.swing.JLabel();
	Square F12sq = new Square();
	Square F5sq = new Square();
	javax.swing.JLabel F12lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F3action = new javax.swing.JLabel();
	javax.swing.JLabel F4action = new javax.swing.JLabel();
	javax.swing.JLabel F9action = new javax.swing.JLabel();
	javax.swing.JLabel F12action = new javax.swing.JLabel();
	
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JTextField procCode = new javax.swing.JTextField();
	javax.swing.JTextField basePrice = new javax.swing.JTextField();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JTextField codeStatus = new javax.swing.JTextField();
	public JTextField priceCode = new javax.swing.JTextField();
	javax.swing.JLabel JLabel4 = new javax.swing.JLabel();
	javax.swing.JScrollPane basePane = new javax.swing.JScrollPane();
	javax.swing.JList baseList = new javax.swing.JList();
	javax.swing.JScrollPane discountPane = new javax.swing.JScrollPane();
	javax.swing.JList discountList = new javax.swing.JList();
	javax.swing.JTextField discountPrice = new javax.swing.JTextField();
	javax.swing.JLabel JLabel5 = new javax.swing.JLabel();
	javax.swing.JScrollPane descPane = new javax.swing.JScrollPane();
	javax.swing.JList descList = new javax.swing.JList();
	javax.swing.JLabel JLabel6 = new javax.swing.JLabel();
	javax.swing.JOptionPane priceChangeConfirm = new javax.swing.JOptionPane();
	javax.swing.JLabel F5action = new javax.swing.JLabel();
	//}}

	//{{DECLARE_MENUS
	//}}

    public void getProcedureCodes()  {
        try  {
            String query =
                "SELECT count(*) \n"+
                "FROM pcs.procedure_codes \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) MAX_PROC_CODES=rs.getInt(1);
            query = 
                "SELECT procedure_code,description \n"+
                "FROM pcs.procedure_codes \n"+
                "ORDER BY procedure_code";
            procedureCodes=new ProcedureCodeRec[MAX_PROC_CODES];
            int ndx=0;
            rs=stmt.executeQuery(query);
            while (rs.next()) {
                procedureCodes[ndx] = new ProcedureCodeRec();
                procedureCodes[ndx].procedure_code=rs.getString(1);
                procedureCodes[ndx].description=rs.getString(2);
                ndx++;
            }     
            if (MAX_PROC_CODES>0)  { }                
        }
        catch( Exception e ) {
            System.out.println(e);
        }
    }

    public void displayList(int ndx, int pNdx) {
        Vector<String> cVect=new Vector<String>();
        Vector dVect=new Vector();
        Vector bVect=new Vector();
        Vector pVect=new Vector();
        for (int i=0;i<MAX_PROC_CODES;i++) {
            cVect.addElement(procedureCodes[i].procedure_code);
            dVect.addElement(procedureCodes[i].description);
            String buf=Double.toString(priceCodes[pNdx].pricing[i].base_price);
            int x=buf.indexOf(".");
            String buf2=" ";
            if (x!=(-1)) {
                buf2=(buf.substring(x));
                if (buf2.length()==1)
                    buf=(buf+"00");
                else if (buf2.length()==2)
                    buf=(buf+"0");
            }
            else buf=(buf+".00");
            bVect.addElement(buf);
            buf=Double.toString(priceCodes[pNdx].pricing[i].discount_price);
            x=buf.indexOf(".");
            if (x!=(-1)) {
                buf2=(buf.substring(x));
                if (buf2.length()==1)
                    buf=(buf+"00");
                else if (buf2.length()==2)
                    buf=(buf+"0");
            }
            else buf=(buf+".00");
            pVect.addElement(buf);
        }
        codeList.setListData(cVect);
        codeList.revalidate();
        descList.setListData(dVect);
        descList.revalidate();
        baseList.setListData(bVect);
        baseList.revalidate();
        discountList.setListData(pVect);
        discountList.revalidate();
        codeList.setSelectedIndex(ndx);
        codeList.ensureIndexIsVisible(ndx);
        descList.setSelectedIndex(ndx);
        descList.ensureIndexIsVisible(ndx);
        baseList.setSelectedIndex(ndx);
        baseList.ensureIndexIsVisible(ndx);
        discountList.setSelectedIndex(ndx);
        discountList.ensureIndexIsVisible(ndx);
        priceCode.setText(priceCodes[pNdx].priceCode);
        codeStatus.setText(priceCodes[pNdx].activeStatus);
        procCode.setText(priceCodes[pNdx].pricing[ndx].procedure_code);
        basePrice.setText((String)baseList.getSelectedValue());
        discountPrice.setText((String)discountList.getSelectedValue());
    }

	class SymMouse extends java.awt.event.MouseAdapter
	{
		public void mouseClicked(java.awt.event.MouseEvent event)
		{
		}
	}

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == procCode)
				procCode_keyTyped(event);
			else if (object == basePrice)
				basePrice_keyTyped(event);
			else if (object == priceCode)
				priceCode_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == PriceListForm.this)
				PriceListForm_keyPressed(event);
		}
	}

	void PriceListForm_keyPressed(java.awt.event.KeyEvent event)
	{
		int ndx;
		int key=event.getKeyCode();
        if ((key!=java.awt.event.KeyEvent.VK_HOME)&&
            (key!=java.awt.event.KeyEvent.VK_END)) priceSwitch=0;
		switch (key) {
		    
            

//            case java.awt.event.KeyEvent.VK_PAGE_DOWN:
//                if (currMode==Lab.IDLE) {
//                msgLabel.setText(null);
//                ndx=descList.getSelectedIndex();
//                ndx+=CODES_PER_SCREEN+1;
//                if (ndx>=MAX_PROC_CODES) ndx=MAX_PROC_CODES-1;
//                displayList(ndx,priceNdx);
//                setEntryFields();
//                }
//		        break; 
//            case java.awt.event.KeyEvent.VK_PAGE_UP:
//                if (currMode==Lab.IDLE) {
//                msgLabel.setText(null);
//                ndx=descList.getSelectedIndex();
//                ndx-=CODES_PER_SCREEN-1;
//                if (ndx<0) ndx=0;
//                displayList(ndx,priceNdx);
//                setEntryFields();
//                }
//		        break; 
            case java.awt.event.KeyEvent.VK_HOME:
                if (currMode==Lab.IDLE) {
                    msgLabel.setText(null);
                    if (priceSwitch==1) {
                        priceSwitch=0;
                        priceNdx=0;
                    }
                    else priceSwitch=1;
                    displayList(0,priceNdx);
                    setEntryFields();
                    priceSwitch=1;
                }
		        break; 
            case java.awt.event.KeyEvent.VK_END:
                if (currMode==Lab.IDLE) {
                    msgLabel.setText(null);
                    if (priceSwitch==2) {
                        priceSwitch=0;
                        priceNdx=MAX_PRICE_CODES-1;
                    }
                    else priceSwitch=2;
                    displayList(MAX_PROC_CODES-1,priceNdx);
                    setEntryFields();
                }
		        break; 

            
		}
	}
	
	public void queryActions() {
	    currMode=Lab.QUERY;
	    fKeys.off();
	    fKeys.keyOn(FunctionKeyControl.F12);
	    fKeys.keyOn(FunctionKeyControl.F9);
	    priceCode.setText(null);
	    codeStatus.setText(null);
	    procCode.setText(null);
	    procCode.setText(null);
	    basePrice.setText(null);
	    priceCode.setEnabled(true);
	    priceCode.requestFocus();
	}
	
	public void finalActions() {
	    if (currMode==Lab.QUERY) {
	        boolean codeFound=false;
	        for (int i=0;i<MAX_PRICE_CODES;i++) {
	            String buf=(String)codeList.getSelectedValue();
	            if (priceCodes[i].priceCode.compareTo(priceCode.getText())==0) {
	                priceNdx=i;
	                displayList(0,priceNdx);
	                setEntryFields();
	                codeFound=true;
	                break;
	            }
	        }
	        currMode=Lab.IDLE;
	        priceCode.setEnabled(false);
	        msgLabel.requestFocus();
	        if (codeFound==false) {
	            resetForm();
	            msgLabel.setText("Price Code Not Found");
	        }
            fKeys.off();
	        fKeys.keyOn(FunctionKeyControl.F1);
	        fKeys.keyOn(FunctionKeyControl.F2);
	        fKeys.keyOn(FunctionKeyControl.F3);
	        fKeys.keyOn(FunctionKeyControl.F4);
	        fKeys.keyOn(FunctionKeyControl.F9);
	    }
	    else if (currMode==Lab.ADD) {
	        boolean codeExists=false;
	        for (int i=0;i<MAX_PRICE_CODES;i++) {
	            if (priceCodes[i].priceCode.compareTo(priceCode.getText())==0) {
	                priceCode.setEnabled(false);
	                msgLabel.requestFocus();
	                priceNdx=i;
	                codeExists=true;
	                currMode=Lab.IDLE;
	                break;
	            }
	        }
	        if (codeExists==true) {
	            int xPriceNdx=priceNdx;
	            resetForm();
	            priceNdx=xPriceNdx;
                msgLabel.setText("Price code already exists");
	        }
	        else if (priceCode.getText().length()<1) {
	            int xPriceNdx=priceNdx;
	            resetForm();
	            priceNdx=xPriceNdx;
	            msgLabel.setText("No price code entered - Add Operation Aborted");
	        }
	        else  {
	            boolean rv=add();
	            if (rv==true) msgLabel.setText("Operation Succeeded");
	        }
            displayList(0,0);
	        displayList(0,priceNdx);
	        priceCode.setEnabled(false);
	        msgLabel.requestFocus();
	        currMode=Lab.IDLE;
            fKeys.off();
	        fKeys.keyOn(FunctionKeyControl.F1);
	        fKeys.keyOn(FunctionKeyControl.F2);
	        fKeys.keyOn(FunctionKeyControl.F3);
	        fKeys.keyOn(FunctionKeyControl.F4);
	        fKeys.keyOn(FunctionKeyControl.F9);
	    }
	    
	    else if (currMode==Lab.DELETE) {
	        String code=priceCode.getText();
	        String status=codeStatus.getText();
            if (status.compareTo("I")==0)
                status="A";
            else status="I";                
	        boolean rv=inactivateCode(code,status);
	        if (rv==true) {
	            if (priceCodes[priceNdx].activeStatus.compareTo("A")==0)
	                msgLabel.setText("Price Code Activated");
	            else msgLabel.setText("Price Code Inactiviated");
	            codeStatus.setText(priceCodes[priceNdx].activeStatus);
	        }
	        currMode=Lab.IDLE;
	        msgLabel.requestFocus();
            fKeys.off();
            fKeys.keyOn(FunctionKeyControl.F1);
	        fKeys.keyOn(FunctionKeyControl.F2);
	        fKeys.keyOn(FunctionKeyControl.F3);
	        fKeys.keyOn(FunctionKeyControl.F4);
	        fKeys.keyOn(FunctionKeyControl.F9);
	    }
	    
	    else if (currMode==Lab.UPDATE) {
	        String code=priceCode.getText();
	        String base=(String)baseList.getSelectedValue();
	        String discount=(String)discountList.getSelectedValue();
	        if (basePrice.getText().length()<1) basePrice.setText(base);
	        if (discountPrice.getText().length()<1) discountPrice.setText(discount);
	        if ((base.compareTo(basePrice.getText())==0)&&
	            (discount.compareTo(discountPrice.getText())==0)) {
                int currPriceNdx=priceNdx;
                int currRow=codeList.getSelectedIndex();
                resetForm();
                priceNdx=currPriceNdx;
                displayList(currRow,priceNdx);
                msgLabel.setText("Update Aborted - No Change Indicated");
                return;
            }    
            if (base.compareTo(basePrice.getText())!=0) {
                String msg = "Update Price Code "+
                    priceCodes[priceNdx].priceCode+
                    " Procedure "+
                    priceCodes[priceNdx].pricing[baseList.getSelectedIndex()].procedure_code+
                    " - Base Price FROM "+base+
                    " TO "+basePrice.getText();
                int result = JOptionPane.showConfirmDialog(this,msg);
                if (result!=JOptionPane.YES_OPTION) {
                    basePrice.setText((String)baseList.getSelectedValue());
                }
            }
            if (discount.compareTo(discountPrice.getText())!=0) {
                String msg = "Update Price Code "+
                    priceCodes[priceNdx].priceCode+
                    " Procedure "+
                    priceCodes[priceNdx].pricing[discountList.getSelectedIndex()].procedure_code+
                    " - Physician Price FROM "+discount+
                    " TO "+discountPrice.getText();
                int result = JOptionPane.showConfirmDialog(this,msg);
                if (result!=JOptionPane.YES_OPTION) {
                    discountPrice.setText((String)discountList.getSelectedValue());
                }
            }
            
            String labNumber="";
            
            do {
            	labNumber=JOptionPane.showInputDialog("What lab number is associated\nwith this price change?");
            } while (!labNumber.matches("[0-9]+"));
            
            Integer i_labNumber=Integer.parseInt(labNumber);
            
            boolean rv=updatePricing(codeList.getSelectedIndex(),priceNdx, i_labNumber);
            if (rv==true) {
                priceCodes[priceNdx].pricing[baseList.getSelectedIndex()].base_price =
                    Double.valueOf(basePrice.getText()).doubleValue();
                priceCodes[priceNdx].pricing[discountList.getSelectedIndex()].discount_price =
                    Double.valueOf(discountPrice.getText()).doubleValue();
            }
            displayList(codeList.getSelectedIndex(),priceNdx);
	        currMode=Lab.IDLE;
	        basePrice.setEnabled(false);
	        discountPrice.setEnabled(false);
	        msgLabel.requestFocus();
            fKeys.off();
            fKeys.keyOn(FunctionKeyControl.F1);
	        fKeys.keyOn(FunctionKeyControl.F2);
	        fKeys.keyOn(FunctionKeyControl.F3);
	        fKeys.keyOn(FunctionKeyControl.F4);
	        fKeys.keyOn(FunctionKeyControl.F9);
	    }
	}

	public void setEntryFields() {
	    int ndx=codeList.getSelectedIndex();
	    procCode.setText(procedureCodes[ndx].procedure_code);
	    rowID=ndx+1;
	}
	
	public void addActions() {
	    currMode=Lab.ADD;
	    fKeys.off();
	    fKeys.keyOn(FunctionKeyControl.F12);
	    fKeys.keyOn(FunctionKeyControl.F9);
	    Vector v = new Vector();
	    v.addElement("  ");
	    baseList.setListData(v);
	    discountList.setListData(v);
	    priceCode.setText(null);
	    codeStatus.setText("I");
	    procCode.setText(null);
	    basePrice.setText(null);
	    discountPrice.setText(null);
	    priceCode.setEnabled(true);
	    priceCode.requestFocus();
	}
	
	public boolean add() {
        boolean exitStatus=true;
        try  {
            DbConnection.process().setAutoCommit(false);
            String pCode=(String)priceCode.getText();
            String query = 
                "INSERT INTO pcs.price_codes \n"+
                "   (price_code,active_status,comment_text,datestamp,sys_user) \n"+
                "VALUES \n"+
                "   ('"+pCode+"', 'I', NULL, SysDate, UID) \n";
                
            System.out.println(query);                
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(query);
            if (rs>0) {
                query = 
                    "INSERT INTO pcs.price_code_details \n"+
                    "SELECT \n"+
                    "   '"+pCode+"',procedure_code,0,0,SysDate,UID \n"+
                    "FROM pcs.procedure_codes \n";
                rs = stmt.executeUpdate(query);
                if (rs>0) {
                    DbConnection.process().commit();
                    DbConnection.process().setAutoCommit(true);
                    for (int i=0;i<MAX_PRICE_CODES;i++) {
                        for (int j=0;j<MAX_PROC_CODES;j++)
                            priceCodes[i].pricing[j]=null;
                        priceCodes[i]=null;
                    }
                    priceCodes=null;
                    MAX_PRICE_CODES=0;
                    getPricing();
                    resetForm();
                    for (int i=0;i<MAX_PRICE_CODES;i++) {
                        if (priceCodes[i].priceCode.compareTo(pCode)==0) {
                            priceNdx=i;
                            break;
                        }
                    }
                }
                else { 
                    DbConnection.process().rollback();
                    DbConnection.process().setAutoCommit(true);
                    exitStatus=false;
                }
            }
            else {
                DbConnection.process().rollback();
                DbConnection.process().setAutoCommit(true);
                exitStatus=false;
            }
        }
        catch( Exception e ) {
            System.out.println(e+" addPriceCode");
            exitStatus=false;
            msgLabel.setText("Operation Failed");
        }

        return(exitStatus);            
    }
    
	public void forceUpper(java.awt.event.KeyEvent event) {
	    msgLabel.setText(null);
        try {
	        char key=event.getKeyChar();
	        if ( (key>='a')&&(key<='z') ) 
	            event.setKeyChar((char)(key-32));
        }
        catch (Exception e)  {
            System.out.println(e);                
        }            
    }	    
    

	void procCode_keyTyped(java.awt.event.KeyEvent event)
	{
		forceUpper(event);
	}

	void basePrice_keyTyped(java.awt.event.KeyEvent event)
	{
		forceUpper(event);
	}
	
	public void deleteActions() {
	    currMode=Lab.DELETE;
	    fKeys.off();
	    fKeys.keyOn(FunctionKeyControl.F12);
	    fKeys.keyOn(FunctionKeyControl.F9);
	    finalActions();
	}
	
	public boolean inactivateCode(String code, String status) {
        boolean exitStatus=true;
        try  {
            String query = 
                "UPDATE pcs.price_codes \n"+
                "SET active_status='"+status+"' \n"+
                "WHERE price_code='"+code+"'\n";
                
            System.out.println(query);                
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(query);
            if (rs>0) {
                priceCodes[priceNdx].activeStatus=status;               
            }
            else {
                exitStatus=false;
            }
        }
        catch( Exception e ) {
            System.out.println(e+" changePriceCodeActiveStatus");
            exitStatus=false;
            msgLabel.setText("Operation Failed");
        }
        
        return(exitStatus);            
    }
	
	public void resetForm() {
	    resetColors();
	    msgLabel.setText(null);
	    msgLabel.requestFocus();
	    priceCode.setEnabled(false);
	    procCode.setEnabled(false);
	    basePrice.setEnabled(false);
	    discountPrice.setEnabled(false);
	    fKeys.off();
	    fKeys.keyOn(FunctionKeyControl.F1);
	    fKeys.keyOn(FunctionKeyControl.F2);
	    fKeys.keyOn(FunctionKeyControl.F3);
	    fKeys.keyOn(FunctionKeyControl.F4);
	    fKeys.keyOn(FunctionKeyControl.F9);
	    priceNdx=0;
	}
	
	public void updateActions() {
	    if (priceCodes[priceNdx].activeStatus.compareTo("I")==0) {
	        resetForm();
	        msgLabel.setText("Cannot Update Inactive Pricing");
	        return;
	    }
	    currMode=Lab.UPDATE;
	    fKeys.off();
	    fKeys.keyOn(FunctionKeyControl.F12);
	    fKeys.keyOn(FunctionKeyControl.F9);
	    basePrice.setText(null);
	    discountPrice.setText(null);
        basePrice.setEnabled(true);
        discountPrice.setEnabled(true);
        basePrice.requestFocus();
	}
	
    public void getPricing()  {

        try  {
            int rowsReturned=0;
            String query = "SELECT count(*) from pcs.price_codes \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) rowsReturned=rs.getInt(1);
            if (rowsReturned>0) {
                query = 
                    "SELECT \n"+
                    "   a.price_code,a.procedure_code, \n"+
                    "   NVL(a.base_price,0), \n"+
                    "   NVL(a.discount_price,0), \n"+
                    "   b.active_status,b.comment_text \n"+
                    "FROM \n"+
                    "   pcs.price_code_details a, \n"+
                    "   pcs.price_codes b \n"+
                    "WHERE \n"+
                    "   a.price_code=b.price_code and \n"+
                    "   a.lab_number= (select max(lab_number) from  pcs.price_code_details c where c.price_code = b.price_code and c.procedure_code= a.procedure_code or c.lab_number=0) \n"+
                    "ORDER BY a.price_code,a.procedure_code";
                
                MAX_PRICE_CODES=rowsReturned;
                priceCodes = new PriceArray[MAX_PRICE_CODES];
                for (int i=0;i<MAX_PRICE_CODES;i++) {
                    priceCodes[i] = new PriceArray(MAX_PROC_CODES);
                }
                rs=stmt.executeQuery(query);
                for (int i=0;i<MAX_PRICE_CODES;i++) {
                    for (int j=0;j<MAX_PROC_CODES;j++) {
                        if (rs.next()) {
                            if (j==0) { 
                                priceCodes[i].priceCode=rs.getString(1);
                                priceCodes[i].activeStatus=rs.getString(5);                                
                                priceCodes[i].pricingComments=rs.getString(6);
                            }
                            priceCodes[i].pricing[j].procedure_code=rs.getString(2);
                            priceCodes[i].pricing[j].base_price=rs.getDouble(3);
                            priceCodes[i].pricing[j].discount_price=rs.getDouble(4);
                        }
                    }
                }
            }
        }
        catch( Exception e ) { System.out.println(e); }
    }
	

	void priceCode_keyTyped(java.awt.event.KeyEvent event)
	{
		forceUpper(event);
	}
	
	public boolean updatePricing(int procedure, int pNdx, int labNumber) {
        boolean exitStatus=true;
        try  {
            double base = Double.valueOf(basePrice.getText()).doubleValue();
            double discount = Double.valueOf(discountPrice.getText()).doubleValue();

            String insert="insert into pcs.price_code_details values "+
            		"('"+priceCodes[pNdx].priceCode+
            		"','"+priceCodes[pNdx].pricing[procedure].procedure_code+"',"+
            		base+","+discount+",SysDate,UID,"+labNumber+")";
            System.out.println("insert: "+insert);
            Statement stmt = DbConnection.process().createStatement();
            int rs = stmt.executeUpdate(insert);
            System.out.println("ROWS INSERTED: "+rs);
            if (rs<1) {
                exitStatus=false;
            }
        }
        catch( Exception e ) {
            System.out.println(e+" updatePricing");
            e.printStackTrace();
            exitStatus=false;
            msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
	}
	
	public void displayPractices(String pCode) {
	    Vector names = new Vector();
	    int rowsReturned=0;
	    String[] pList;
        try  {
            String query = 
                "SELECT practice,name \n"+
                "FROM pcs.practices \n"+
                "WHERE price_code='"+pCode+"' \n"+
                "ORDER BY name \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                rowsReturned++;
                int pr=rs.getInt(1);
                String name=rs.getString(2);
                if (pr<10) name="00"+Integer.toString(pr)+"  "+name;
                else if (pr<100) name="0"+Integer.toString(pr)+"  "+name;
                else name=Integer.toString(pr)+"  "+name;
                names.addElement(name);
            }
        }
        catch( Exception e ) { System.out.println(e); }
        if (rowsReturned>0) {
            pList = new String[rowsReturned];
            for (int i=0;i<rowsReturned;i++)
                pList[i]=(String)names.elementAt(i);
            (new PickList("Practices",340,100,290,200,
                rowsReturned,pList)).setVisible(true);
            
        }
	}
	
    public void resetColors()  
    {
        Utils.setColors(this.getContentPane());
        msgLabel.setForeground(Color.green.brighter());
    }

	@Override
	public void resetActions() {
		// TODO Auto-generated method stub
		
	}        
	
}
