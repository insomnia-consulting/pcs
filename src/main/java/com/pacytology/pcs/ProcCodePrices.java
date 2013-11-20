package com.pacytology.pcs;

import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Insets;
import java.awt.event.KeyEvent;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Vector;

import com.pacytology.pcs.ui.Square;

public class ProcCodePrices extends javax.swing.JFrame
{

    public ProcedureCodeForm parent;
    public String procedureCode;
    public Login dbLogin;
    public int MAX_PRICE_CODES=0;
    public PriceArray[] priceCodes;
    /*
    final int IDLE=100;
    final int QUERY=101;
    final int ADD=102;
    final int UPDATE=103;
    final int DELETE=104;
    */
    public int currMode=Lab.IDLE;    
    final int CODES_PER_SCREEN=15;
    public Vector priceLimitVect = new Vector();
    
	public ProcCodePrices()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Charges");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(384,418);
		setVisible(false);
		codePane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		codePane.setOpaque(true);
		codePane.setEnabled(false);
		getContentPane().add(codePane);
		codePane.setBounds(30,150,40,258);
		codeList.setEnabled(false);
		codePane.getViewport().add(codeList);
		codeList.setFont(new Font("DialogInput", Font.PLAIN, 12));
		codeList.setBounds(0,0,37,255);
		basePane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		basePane.setOpaque(true);
		basePane.setEnabled(false);
		getContentPane().add(basePane);
		basePane.setBounds(142,150,60,258);
		baseList.setEnabled(false);
		basePane.getViewport().add(baseList);
		baseList.setFont(new Font("DialogInput", Font.PLAIN, 12));
		baseList.setBounds(0,0,57,255);
		getContentPane().add(F9sq);
		F9sq.setBounds(35,6,20,20);
		F9lbl.setRequestFocusEnabled(false);
		F9lbl.setText("F2");
		getContentPane().add(F9lbl);
		F9lbl.setForeground(java.awt.Color.black);
		F9lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F9lbl.setBounds(39,6,20,20);
		F9action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F9action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F9action.setText("U&C");
		getContentPane().add(F9action);
		F9action.setForeground(java.awt.Color.black);
		F9action.setBounds(10,30,70,16);
		discountPane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		discountPane.setOpaque(true);
		discountPane.setEnabled(false);
		getContentPane().add(discountPane);
		discountPane.setBounds(80,150,60,258);
		discountList.setEnabled(false);
		discountPane.getViewport().add(discountList);
		discountList.setFont(new Font("DialogInput", Font.PLAIN, 12));
		discountList.setBounds(0,0,57,255);
		JLabel1.setText("Price");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(30,118,40,12);
		JLabel2.setText("Code");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(30,132,40,12);
		JLabel3.setText("Physician");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(80,132,60,12);
		JLabel4.setText("Other");
		getContentPane().add(JLabel4);
		JLabel4.setBounds(146,132,64,12);
		procCodeLbl.setText("PROCEDURE CODE:");
		getContentPane().add(procCodeLbl);
		procCodeLbl.setBounds(24,60,200,12);
		getContentPane().add(procDescLbl);
		procDescLbl.setBounds(24,78,216,12);
		JLabel5.setText("Billing Code");
		getContentPane().add(JLabel5);
		JLabel5.setBounds(230,152,74,12);
		JLabel6.setText("U & C");
		getContentPane().add(JLabel6);
		JLabel6.setBounds(230,176,74,12);
		billingCode.setEnabled(false);
		getContentPane().add(billingCode);
		billingCode.setFont(new Font("DialogInput", Font.PLAIN, 12));
		billingCode.setBounds(310,150,52,20);
		chargeLimit.setEnabled(false);
		getContentPane().add(chargeLimit);
		chargeLimit.setFont(new Font("DialogInput", Font.PLAIN, 12));
		chargeLimit.setBounds(310,174,52,20);
		JLabel7.setText("Usual and Customary");
		getContentPane().add(JLabel7);
		JLabel7.setBounds(230,208,144,16);
		JLabel8.setText("Charges by Billing Types");
		getContentPane().add(JLabel8);
		JLabel8.setBounds(230,220,144,16);
		limitPane.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER);
		limitPane.setOpaque(true);
		limitPane.setEnabled(false);
		getContentPane().add(limitPane);
		limitPane.setBounds(230,240,132,96);
		limitList.setEnabled(false);
		limitPane.getViewport().add(limitList);
		limitList.setFont(new Font("DialogInput", Font.PLAIN, 12));
		limitList.setBounds(0,0,129,93);
		getContentPane().add(F2sq);
		F2sq.setBounds(97,6,20,20);
		F2lbl.setRequestFocusEnabled(false);
		F2lbl.setText("F9");
		getContentPane().add(F2lbl);
		F2lbl.setForeground(java.awt.Color.black);
		F2lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F2lbl.setBounds(101,6,20,20);
		getContentPane().add(F3sq);
		F3sq.setBounds(159,6,20,20);
		F3lbl.setRequestFocusEnabled(false);
		F3lbl.setText("F12");
		getContentPane().add(F3lbl);
		F3lbl.setForeground(java.awt.Color.black);
		F3lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F3lbl.setBounds(160,6,20,20);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Exit");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(72,30,70,16);
		F3action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F3action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F3action.setText("Submit");
		getContentPane().add(F3action);
		F3action.setForeground(java.awt.Color.black);
		F3action.setBounds(134,30,70,16);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		billingCode.addKeyListener(aSymKey);
		chargeLimit.addKeyListener(aSymKey);
		SymFocus aSymFocus = new SymFocus();
		//}}
		
        // Add focus listener to all text fields
		for (int i=0; i<this.getContentPane().getComponentCount(); i++) {
		    Component c = this.getContentPane().getComponent(i);
		    String s = c.getClass().getName();
		    if (s.equals("javax.swing.JTextField")
		    || s.equals("javax.swing.JTextArea")) {
		        c.addFocusListener(aSymFocus);
		    }
		    else if (s.equals("javax.swing.JPanel")) {
		        for (int j=0; j<((Container)c).getComponentCount(); j++) {
		            Component d = ((Container)c).getComponent(j);
		            String t = d.getClass().getName();
		            if (t.equals("javax.swing.JTextField")
		            || t.equals("javax.swing.JTextArea")) {
		                d.addFocusListener(aSymFocus);
		            }
		        }
		    }
		}
		
	}

	public ProcCodePrices(String sTitle)
	{
		this();
		setTitle(sTitle);
	}

    public ProcCodePrices(ProcedureCodeForm p) {
        this();
        this.dbLogin=p.dbLogin;
        this.parent=p;
        int ndx=this.parent.codeList.getSelectedIndex();
        this.procedureCode=this.parent.procedureCodes[ndx].procedure_code;
        this.procCodeLbl.setText("PROCEDURE CODE: "+procedureCode);
        this.procDescLbl.setText(this.parent.procedureCodes[ndx].description);
        boolean rv=this.getPrices();
        if (rv==true) {
            this.displayList(0);
            this.parent.setEnabled(false);
            resetColors();
        }
        else this.dispose();
    }

	public void setVisible(boolean b)
	{
		if (b) setLocation(60,60);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new ProcCodePrices()).setVisible(true);
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
	javax.swing.JScrollPane basePane = new javax.swing.JScrollPane();
	javax.swing.JList baseList = new javax.swing.JList();
	Square F9sq = new Square();
	javax.swing.JLabel F9lbl = new javax.swing.JLabel();
	javax.swing.JLabel F9action = new javax.swing.JLabel();
	javax.swing.JScrollPane discountPane = new javax.swing.JScrollPane();
	javax.swing.JList discountList = new javax.swing.JList();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel4 = new javax.swing.JLabel();
	javax.swing.JLabel procCodeLbl = new javax.swing.JLabel();
	javax.swing.JLabel procDescLbl = new javax.swing.JLabel();
	javax.swing.JLabel JLabel5 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel6 = new javax.swing.JLabel();
	javax.swing.JTextField billingCode = new javax.swing.JTextField();
	javax.swing.JTextField chargeLimit = new javax.swing.JTextField();
	javax.swing.JLabel JLabel7 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel8 = new javax.swing.JLabel();
	javax.swing.JScrollPane limitPane = new javax.swing.JScrollPane();
	javax.swing.JList limitList = new javax.swing.JList();
	Square F2sq = new Square();
	javax.swing.JLabel F2lbl = new javax.swing.JLabel();
	Square F3sq = new Square();
	javax.swing.JLabel F3lbl = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F3action = new javax.swing.JLabel();
	//}}

	//{{DECLARE_MENUS
	//}}

    public boolean getPrices()  {
        boolean exitStatus=true;
        try  {
            String query =
                "SELECT count(*) \n"+
                "FROM pcs.price_codes \n"+
                "WHERE active_status='A' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) MAX_PRICE_CODES=rs.getInt(1);
            if (MAX_PRICE_CODES>0) {
            query = 
                "SELECT \n"+
                "   a.price_code,a.procedure_code, \n"+
                "   a.base_price,a.discount_price \n"+
                "FROM \n"+
                "   pcs.price_code_details a, \n"+
                "   pcs.price_codes b \n"+
                "WHERE \n"+
                "   a.price_code=b.price_code and \n"+
                "   b.active_status='A' and \n"+
                "   a.procedure_code='"+procedureCode+"' and \n"+
                "   a.lab_number= (select max(lab_number) from  price_code_details c where c.price_code = b.price_code and c.procedure_code= a.procedure_code or c.lab_number=0) \n"+
                "ORDER BY b.price_code";
            int ndx=0;
            rs=stmt.executeQuery(query);
            priceCodes = new PriceArray[MAX_PRICE_CODES];
            while (rs.next()) {
                priceCodes[ndx] = new PriceArray(1);
                priceCodes[ndx].priceCode=rs.getString(1);
                priceCodes[ndx].pricing[0].procedure_code=rs.getString(2);
                priceCodes[ndx].pricing[0].base_price=rs.getDouble(3);
                priceCodes[ndx].pricing[0].discount_price=rs.getDouble(4);
                priceCodes[ndx].activeStatus="A";
                ndx++;
            }     
            query = 
                "SELECT RPAD(B.choice_code,8)||TO_CHAR(P.limit_amount,'990.99'), \n"+
                "   B.billing_choice,B.choice_code \n"+
                "FROM pcs.billing_choices B, pcs.procedure_code_limits P \n"+
                "WHERE P.procedure_code='"+procedureCode+"' \n"+
                "AND P.billing_choice=B.billing_choice \n"+
                "ORDER BY B.choice_code \n";
            rs=stmt.executeQuery(query);
            while (rs.next()) {
                BillingCodeRec bRec = new BillingCodeRec();
                bRec.formattedString=rs.getString(1);
                bRec.billing_choice=rs.getInt(2);
                bRec.choice_code=rs.getString(3);
                priceLimitVect.addElement(bRec);
            }
            }
            else exitStatus=false;
        }
        catch( Exception e ) {
            System.out.println(e);
            exitStatus=false;
        }
        return exitStatus;
    }

    public void displayList(int ndx) {
        Vector cVect=new Vector();
        Vector bVect=new Vector();
        Vector dVect=new Vector();
        for (int i=0;i<MAX_PRICE_CODES;i++) {
            cVect.addElement(priceCodes[i].priceCode);
            String buf=Double.toString(priceCodes[i].pricing[0].base_price);
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
            buf2=Utils.lpad(buf,6);
            bVect.addElement(buf2);
            buf=Double.toString(priceCodes[i].pricing[0].discount_price);
            x=buf.indexOf(".");
            if (x!=(-1)) {
                buf2=(buf.substring(x));
                if (buf2.length()==1)
                    buf=(buf+"00");
                else if (buf2.length()==2)
                    buf=(buf+"0");
            }
            else buf=(buf+".00");
            buf2=Utils.lpad(buf,6);
            dVect.addElement(buf2);
        }
        codeList.setListData(cVect);
        codeList.revalidate();
        baseList.setListData(bVect);
        baseList.revalidate();
        discountList.setListData(dVect);
        discountList.revalidate();
        codeList.setSelectedIndex(ndx);
        codeList.ensureIndexIsVisible(ndx);
        baseList.setSelectedIndex(ndx);
        baseList.ensureIndexIsVisible(ndx);
        discountList.setSelectedIndex(ndx);
        discountList.ensureIndexIsVisible(ndx);
        if (priceLimitVect.size()>0) {
            Vector tVect = new Vector();
            for (int i=0; i<priceLimitVect.size(); i++) {
                BillingCodeRec bRec = (BillingCodeRec)priceLimitVect.elementAt(i);
                tVect.addElement(bRec.formattedString);
            }
            limitList.setListData(tVect);
        }
    }

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == billingCode)
				billingCode_keyTyped(event);
			else if (object == chargeLimit)
				chargeLimit_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == ProcCodePrices.this)
				ProcCodePrices_keyPressed(event);
			else if (object == billingCode)
				billingCode_keyPressed(event);
			else if (object == chargeLimit)
				chargeLimit_keyPressed(event);
		}
	}

	void ProcCodePrices_keyPressed(java.awt.event.KeyEvent event)
	{
		int ndx;
		int key=event.getKeyCode();
		switch (key) {
		    case java.awt.event.KeyEvent.VK_DOWN:
		        if (currMode==Lab.IDLE) {
		        if ((codeList.getSelectedIndex()==(-1))
		         || (baseList.getSelectedIndex()==(-1))
		         || (discountList.getSelectedIndex()==(-1)))
		        {
		            ndx=0;
		        }
		        else ndx=baseList.getSelectedIndex()+1;
                if (ndx==MAX_PRICE_CODES) ndx--;
                displayList(ndx);
		        }
		        break;
            case java.awt.event.KeyEvent.VK_UP:
                if (currMode==Lab.IDLE) {
		        if ((codeList.getSelectedIndex()==(-1))
		         || (baseList.getSelectedIndex()==(-1))
		         || (discountList.getSelectedIndex()==(-1)))
		        {
		            ndx=0;
		        }
		        else ndx=baseList.getSelectedIndex()-1;
                if (ndx==(-1)) ndx=0;
                displayList(ndx);
		        }
		        break;
            case java.awt.event.KeyEvent.VK_PAGE_DOWN:
                if (currMode==Lab.IDLE) {
                ndx=baseList.getSelectedIndex();
                ndx+=CODES_PER_SCREEN+1;
                if (ndx>=MAX_PRICE_CODES) ndx=MAX_PRICE_CODES-1;
                displayList(ndx);
                }
		        break; 
            case java.awt.event.KeyEvent.VK_PAGE_UP:
                if (currMode==Lab.IDLE) {
                ndx=baseList.getSelectedIndex();
                ndx-=CODES_PER_SCREEN-1;
                if (ndx<0) ndx=0;
                displayList(ndx);
                }
		        break; 
            case java.awt.event.KeyEvent.VK_HOME:
                if (currMode==Lab.IDLE) {
                displayList(0);
                }
		        break; 
            case java.awt.event.KeyEvent.VK_END:
                if (currMode==Lab.IDLE) {
                displayList(MAX_PRICE_CODES-1);
                }
		        break; 
            case java.awt.event.KeyEvent.VK_F9:
                this.parent.setEnabled(true);
                this.dispose();
                break;
            case KeyEvent.VK_F2:
                billingCode.setEnabled(true);
                chargeLimit.setEnabled(true);
                billingCode.requestFocus();
                break;
            case KeyEvent.VK_ESCAPE:
                billingCode.setText(null);
                chargeLimit.setText(null);
                billingCode.setEnabled(false);
                chargeLimit.setEnabled(false);
                procCodeLbl.requestFocus();
                break;
            case KeyEvent.VK_F12:
                if (updateLimit()) refresh();
                billingCode.setText(null);
                chargeLimit.setText(null);
                billingCode.setEnabled(false);
                chargeLimit.setEnabled(false);
                procCodeLbl.requestFocus();
                break;
		}
	}

	void billingCode_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event,3);
	}

	void billingCode_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(billingCode,"Billing Choice")) {
		        chargeLimit.requestFocus(); 
		    }
		}
	}

	void chargeLimit_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    //if (Utils.required(chargeLimit,"Limit Amount")) {
		        if (Utils.isNull(chargeLimit.getText()))
		            chargeLimit.setText("0");
		        String s = chargeLimit.getText();
		        try { 
		            double d = (new Double(s)).doubleValue(); 
		            billingCode.requestFocus();
                }
		        catch (NumberFormatException e) {
		            Utils.createErrMsg("Value ["+s+"] is not a number");
		        }
		    //}
		}
	}

	void chargeLimit_keyTyped(java.awt.event.KeyEvent event)
	{
		// to do: code goes here.
	}
	
    public boolean updateLimit()  {
        boolean exitStatus=true;
        int rowsUpdated = 0;
        double d = (-1);
        try { d = (new Double(chargeLimit.getText())).doubleValue(); }
        catch (NumberFormatException e) { }
        currMode=Lab.IDLE;
        String bCode = billingCode.getText();
        for (int i=0; i<priceLimitVect.size(); i++) {
            BillingCodeRec bRec = (BillingCodeRec)priceLimitVect.elementAt(i);
            if (bRec.choice_code.equals(bCode)) {
                currMode=Lab.UPDATE;
                break;
            }
        }
        if (currMode==Lab.UPDATE && d<=0) currMode=Lab.DELETE;
        else if (currMode==Lab.IDLE && d>0) currMode=Lab.ADD;
        if (currMode==Lab.IDLE) return false;
        try  {
            int bChoice = 0;
            String query =
                "SELECT billing_choice \n"+
                "FROM pcs.billing_choices \n"+
                "WHERE choice_code='"+bCode+"' \n";
            Statement stmt = DbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) bChoice=rs.getInt(1);
            if (bChoice<=0) {
                Utils.createErrMsg("Billing Choice ["+bCode+"] does not exist");
                exitStatus=false;
            }
            else {
                if (currMode==Lab.DELETE) {
                    query =
                        "DELETE FROM pcs.procedure_code_limits \n"+
                        "WHERE procedure_code='"+procedureCode+"' \n"+
                        "AND billing_choice="+bChoice+" \n";
                }
                else if (currMode==Lab.UPDATE) {
                    query =
                        "UPDATE pcs.procedure_code_limits \n"+
                        "SET limit_amount="+d+" \n"+
                        "WHERE procedure_code='"+procedureCode+"' \n"+
                        "AND billing_choice="+bChoice+" \n";
                }
                else if (currMode==Lab.ADD) {
                    query = 
                        "INSERT INTO pcs.procedure_code_limits \n"+
                        "(procedure_code,billing_choice,limit_amount) \n"+
                        "VALUES ('"+procedureCode+"',"+bChoice+","+d+") \n";
                }
                rowsUpdated = stmt.executeUpdate(query);
            }
        }
        catch( Exception e ) {
            System.out.println(e);
            exitStatus=false;
        }
        return exitStatus;
    }

	private void refresh()
	{
	    priceLimitVect = new Vector();
	    codeList.removeAll();
	    baseList.removeAll();
	    discountList.removeAll();
	    limitList.removeAll();
	    codeList.setListData(priceLimitVect);
	    baseList.setListData(priceLimitVect);
	    discountList.setListData(priceLimitVect);
	    limitList.setListData(priceLimitVect);
	    codeList.revalidate();
	    baseList.revalidate();
	    discountList.revalidate();
	    limitList.revalidate();
	    codeList.repaint();
	    baseList.repaint();
	    discountList.repaint();
	    limitList.repaint();
        boolean rv=getPrices();
        if (rv) { displayList(0); }
        else this.dispose();
	}

	class SymFocus extends java.awt.event.FocusAdapter
	{
		public void focusGained(java.awt.event.FocusEvent event)
		{
			Object object = event.getSource();
			Utils.deselect(event);
		}
	}
	
	void resetColors()
	{
	    Utils.setColors(this.getContentPane());
	    procDescLbl.setForeground(Color.white);
	    discountList.setFont(new Font("MonoSpaced", Font.PLAIN, 12));
	    baseList.setFont(new Font("MonoSpaced", Font.PLAIN, 12));
	    codeList.setFont(new Font("MonoSpaced", Font.PLAIN, 12));
	    limitList.setFont(new Font("MonoSpaced", Font.PLAIN, 11));
	}


}
