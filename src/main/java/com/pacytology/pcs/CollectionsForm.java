/*
    CollectiosForm.java
    Software Engineer: Jon Cardella
    
    Function: Used to manage collections data and
    print various collections reports.
*/

import java.awt.*;
import javax.swing.*;
import Square;
import java.util.Vector;

public class CollectionsForm extends javax.swing.JFrame
{
    /* SEND MODES (Oracle IN PARAM for pcs.build_collection_file */
    final int PENDING = -2;
    final int DEQUEUE = -1;
    final int QUEUE = 0;
    final int PRIOR_BATCH = 1;
    final int NOTIFY = 2;
    final int NOTIFIED = 3;
    
    protected int screenMode;
    private int rowCount = -1;
    private Vector accountData;
    private int[] accountList;
    private String[] createDates;
    private String[] changeDates;
    private Vector commentIndexes;
    private Vector commentText;
    private int currNdx;
    Login dbLogin;
    
	public CollectionsForm()
	{
		// This code is automatically generated by Visual Cafe when you add
		// components to the visual environment. It instantiates and initializes
		// the components. To modify the code, only use code syntax that matches
		// what Visual Cafe can generate, or Visual Cafe may be unable to back
		// parse your Java file into its visual environment.
		//{{INIT_CONTROLS
		setTitle("Collections");
		setDefaultCloseOperation(javax.swing.JFrame.DISPOSE_ON_CLOSE);
		getContentPane().setLayout(null);
		setSize(808,580);
		setVisible(false);
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
		F9sq.setBounds(283,6,20,20);
		F9lbl.setRequestFocusEnabled(false);
		F9lbl.setText("F9");
		getContentPane().add(F9lbl);
		F9lbl.setForeground(java.awt.Color.black);
		F9lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F9lbl.setBounds(287,6,20,20);
		F1action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F1action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F1action.setText("Dequeue");
		getContentPane().add(F1action);
		F1action.setForeground(java.awt.Color.black);
		F1action.setBounds(10,30,70,16);
		F2action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F2action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F2action.setText("Called");
		getContentPane().add(F2action);
		F2action.setForeground(java.awt.Color.black);
		F2action.setBounds(72,30,70,16);
		F3action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F3action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F3action.setText("Comment");
		getContentPane().add(F3action);
		F3action.setForeground(java.awt.Color.black);
		F3action.setBounds(134,30,70,16);
		F4action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F4action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F4action.setText("Report");
		getContentPane().add(F4action);
		F4action.setForeground(java.awt.Color.black);
		F4action.setBounds(196,30,70,16);
		F9action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F9action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F9action.setText("Exit");
		getContentPane().add(F9action);
		F9action.setForeground(java.awt.Color.black);
		F9action.setBounds(258,30,70,16);
		getContentPane().add(F11sq);
		F11sq.setBounds(345,6,20,20);
		F11lbl.setRequestFocusEnabled(false);
		F11lbl.setText("F11");
		getContentPane().add(F11lbl);
		F11lbl.setForeground(java.awt.Color.black);
		F11lbl.setFont(new Font("SansSerif", Font.PLAIN, 10));
		F11lbl.setBounds(346,6,20,20);
		F11action.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
		F11action.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);
		F11action.setText("Billing");
		getContentPane().add(F11action);
		F11action.setForeground(java.awt.Color.black);
		F11action.setBounds(320,30,70,16);
		getContentPane().add(msgLabel);
		msgLabel.setForeground(java.awt.Color.red);
		msgLabel.setFont(new Font("Dialog", Font.BOLD, 12));
		msgLabel.setBounds(26,52,360,14);
		internalComment.setLineWrap(true);
		internalComment.setWrapStyleWord(true);
		internalComment.setEnabled(false);
		getContentPane().add(internalComment);
		internalComment.setFont(new Font("DialogInput", Font.PLAIN, 12));
		internalComment.setBounds(404,20,384,120);
		JLabel1.setText("Internal Comments:");
		getContentPane().add(JLabel1);
		JLabel1.setBounds(404,6,120,12);
		recordPane.setOpaque(true);
		recordPane.setEnabled(false);
		getContentPane().add(recordPane);
		recordPane.setBounds(8,170,790,380);
		recordList.setEnabled(false);
		recordPane.getViewport().add(recordList);
		recordList.setFont(new Font("DialogInput", Font.PLAIN, 10));
		recordList.setBounds(0,0,787,377);
		JLabel2.setText("Lab Number");
		getContentPane().add(JLabel2);
		JLabel2.setBounds(10,156,80,12);
		JLabel3.setText("Name");
		getContentPane().add(JLabel3);
		JLabel3.setBounds(96,156,80,12);
		JLabel4.setText("Address");
		getContentPane().add(JLabel4);
		JLabel4.setBounds(248,156,80,12);
		JLabel5.setText("Phone");
		getContentPane().add(JLabel5);
		JLabel5.setBounds(524,156,80,12);
		JLabel6.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		JLabel6.setText("Amount");
		getContentPane().add(JLabel6);
		JLabel6.setBounds(700,156,80,12);
		JLabel7.setText("Completed");
		getContentPane().add(JLabel7);
		JLabel7.setBounds(633,156,80,12);
		confirmQueue.setOptionType(javax.swing.JOptionPane.YES_NO_OPTION);
		//$$ confirmQueue.move(0,563);
		collectionDateLbl.setRequestFocusEnabled(false);
		collectionDateLbl.setText("To collection on:");
		getContentPane().add(collectionDateLbl);
		collectionDateLbl.setBounds(18,84,100,12);
		collectionDate.setEnabled(false);
		getContentPane().add(collectionDate);
		collectionDate.setFont(new Font("DialogInput", Font.PLAIN, 12));
		collectionDate.setBounds(116,82,76,20);
		JLabel8.setRequestFocusEnabled(false);
		JLabel8.setText("Updated on:");
		getContentPane().add(JLabel8);
		JLabel8.setBounds(18,106,100,12);
		changeDate.setEnabled(false);
		getContentPane().add(changeDate);
		changeDate.setFont(new Font("DialogInput", Font.PLAIN, 12));
		changeDate.setBounds(116,104,76,20);
		batchNumber.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		batchNumber.setEnabled(false);
		getContentPane().add(batchNumber);
		batchNumber.setFont(new Font("DialogInput", Font.PLAIN, 12));
		batchNumber.setBounds(320,82,30,20);
		JLabel9.setRequestFocusEnabled(false);
		JLabel9.setText("Batch Number:");
		getContentPane().add(JLabel9);
		JLabel9.setBounds(226,84,90,12);
		rowCountLbl.setRequestFocusEnabled(false);
		rowCountLbl.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
		rowCountLbl.setText("0 of 0");
		getContentPane().add(rowCountLbl);
		rowCountLbl.setBounds(658,552,130,12);
		//$$ confirmSecondary.move(0,563);
		//}}

		//{{INIT_MENUS
		//}}
	
		//{{REGISTER_LISTENERS
		SymWindow aSymWindow = new SymWindow();
		this.addWindowListener(aSymWindow);
		SymKey aSymKey = new SymKey();
		this.addKeyListener(aSymKey);
		internalComment.addKeyListener(aSymKey);
		batchNumber.addKeyListener(aSymKey);
		//}}
	}
	
	public CollectionsForm(int screenMode)
	{
	    this();
	    this.screenMode=screenMode;
	    resetForm();
	}
	
	public CollectionsForm(int screenMode, Login dbLogin)
	{
	    this();
	    this.dbLogin=dbLogin;
	    this.screenMode=screenMode;
	    resetForm();
	}

	public CollectionsForm(String sTitle)
	{
		this();
		setTitle(sTitle);
	}

	public void setVisible(boolean b)
	{
		if (b) setLocation(0,0);
		super.setVisible(b);
	}

	static public void main(String args[])
	{
		(new CollectionsForm()).setVisible(true);
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
	javax.swing.JLabel F1action = new javax.swing.JLabel();
	javax.swing.JLabel F2action = new javax.swing.JLabel();
	javax.swing.JLabel F3action = new javax.swing.JLabel();
	javax.swing.JLabel F4action = new javax.swing.JLabel();
	javax.swing.JLabel F9action = new javax.swing.JLabel();
	Square F11sq = new Square();
	javax.swing.JLabel F11lbl = new javax.swing.JLabel();
	javax.swing.JLabel F11action = new javax.swing.JLabel();
	javax.swing.JLabel msgLabel = new javax.swing.JLabel();
	javax.swing.JTextArea internalComment = new javax.swing.JTextArea();
	javax.swing.JLabel JLabel1 = new javax.swing.JLabel();
	javax.swing.JScrollPane recordPane = new javax.swing.JScrollPane();
	javax.swing.JList recordList = new javax.swing.JList();
	javax.swing.JLabel JLabel2 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel3 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel4 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel5 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel6 = new javax.swing.JLabel();
	javax.swing.JLabel JLabel7 = new javax.swing.JLabel();
	javax.swing.JOptionPane confirmQueue = new javax.swing.JOptionPane();
	javax.swing.JLabel collectionDateLbl = new javax.swing.JLabel();
	javax.swing.JTextField collectionDate = new javax.swing.JTextField();
	javax.swing.JLabel JLabel8 = new javax.swing.JLabel();
	javax.swing.JTextField changeDate = new javax.swing.JTextField();
	javax.swing.JTextField batchNumber = new javax.swing.JTextField();
	javax.swing.JLabel JLabel9 = new javax.swing.JLabel();
	javax.swing.JLabel rowCountLbl = new javax.swing.JLabel();
	//}}

	//{{DECLARE_MENUS
	//}}
	
	private void resetForm()
	{
	    resetColors();
	    clearRecordList();
	    internalComment.setText(null);
	    collectionDate.setText(null);
	    changeDate.setText(null);
	    batchNumber.setText(null);
	    if (screenMode==DEQUEUE) F1action.setText("Queue");
	    else F1action.setText("Dequeue");
	}
	
	private void resetColors()
	{
        Utils.setColors(this.getContentPane());
        msgLabel.setForeground(Color.green.brighter());
        recordList.setFont(new Font("MonoSpaced",Font.PLAIN,11));
        recordList.setBackground(Color.black);
        recordList.setForeground(Color.white);
	    rowCountLbl.setForeground(Color.white);
	}

	class SymWindow extends java.awt.event.WindowAdapter
	{
		public void windowOpened(java.awt.event.WindowEvent event)
		{
			Object object = event.getSource();
			if (object == CollectionsForm.this)
				CollectionsForm_windowOpened(event);
		}
	}

	void CollectionsForm_windowOpened(java.awt.event.WindowEvent event)
	{
		openingActions();
	}
	
	void openingActions()
	{
	    switch (screenMode) {
	        case DEQUEUE:  
	            msgLabel.setText(
	                "Accounts DEQUEUED from current collections list.");
	            break;
	        case QUEUE:
	            msgLabel.setText(
	                "Accounts currently QUEUED for collections.");
	            break;
	        case PRIOR_BATCH:
	            msgLabel.setText("Prior collections report - ENTER BATCH NUMBER");
	            batchNumber.setEnabled(true);
	            batchNumber.requestFocus();
	            break;
	        case NOTIFY:
	            msgLabel.setText(
	                "Accounts taken out of collections; must notify agency.");
	            break;
	    }
	    rowCount = dbConnection.getRowCount(
	        "pcs.patient_accounts_in_collection",
	        "sent = "+screenMode);
	    if (screenMode!=PRIOR_BATCH) {
	        if (rowCount<=0) {
	            Utils.createErrMsg("NO DATA MEETS CRITERIA: "+msgLabel.getText());
	            closingActions();
	        }
	        else {
	            getData();
	            fillRecordList();
	        }
	    }
	}
	
	void closingActions()
	{
	    this.dispose();
	}
	
	void getData()
	{
	    // there are (9) data elements in this sql-statement
	    String SQL =
	        "SELECT a.lab_number, "+
	        "   RPAD(SUBSTR(p.lname||', '||p.fname||' '||p.mi,1,20),22), \n"+
            "   RPAD(SUBSTR(p.address1||', '||p.city||' '||p.state||' '||SUBSTR(p.zip,1,5),1,37),39), \n"+
            "   NVL(p.phone,'0000000000'),TO_CHAR(r.date_completed,'MMDDYYYY'), \n"+
            "   TO_CHAR(a.outstanding_balance,'9990.00'), \n"+
            "   c.comment_text,TO_CHAR(a.create_date,'MM/DD/YYYY'), \n"+
            "   TO_CHAR(a.change_date,'MM/DD/YYYY') \n"+
            "FROM pcs.patient_accounts_in_collection a, \n"+
            "   pcs.patients p, pcs.lab_results r, pcs.lab_req_comments c, \n"+
            "   pcs.lab_requisitions q \n"+
            "WHERE a.lab_number=q.lab_number and q.lab_number=r.lab_number and \n"+
            "   a.lab_number=c.lab_number(+) and q.patient=p.patient and \n"+
            "   a.sent = "+screenMode+" ";
        if (screenMode==PRIOR_BATCH) {
            SQL += "and a.batch_number = "+batchNumber.getText()+" \n";
            SQL += "ORDER BY a.lab_number \n";
        }
        else SQL += "\nORDER BY a.create_date DESC \n";
        Vector resultList = new Vector();
        for (int i=0; i<9; i++) {
            if (i==0) resultList.addElement(new SQLValue(dbConnection.INTEGER));
            else resultList.addElement(new SQLValue(dbConnection.STRING));
        }
        Vector resultTable = dbConnection.query(SQL,resultList);
        accountData = new Vector();
        commentIndexes = new Vector();
        commentText = new Vector();
        accountList = new int[resultTable.size()];
        createDates = new String[resultTable.size()];
        changeDates = new String[resultTable.size()];
        for (int i=0; i<resultTable.size(); i++) {
            Vector v = (Vector)resultTable.elementAt(i);
            accountList[i]=((SQLValue)v.elementAt(0)).iValue;
            String s = ((SQLValue)v.elementAt(0)).iValue+"  "+
                ((SQLValue)v.elementAt(1)).sValue+
                ((SQLValue)v.elementAt(2)).sValue+
                Utils.addPhoneMask(((SQLValue)v.elementAt(3)).sValue)+"  "+
                Utils.addDateMask(((SQLValue)v.elementAt(4)).sValue)+"  "+
                ((SQLValue)v.elementAt(5)).sValue;
            accountData.addElement(s);
            s=((SQLValue)v.elementAt(6)).sValue;
            if (!Utils.isNull(s)) {
                commentText.addElement(s);
                commentIndexes.addElement(new Integer(i));
            }
            createDates[i]=((SQLValue)v.elementAt(7)).sValue;
            changeDates[i]=((SQLValue)v.elementAt(8)).sValue;
        }
	}
	
	void fillRecordList()
	{
	    clearRecordList();
	    recordList.setListData(accountData);
        recordList.clearSelection();
        recordList.setSelectionInterval(currNdx,currNdx);
        recordList.ensureIndexIsVisible(currNdx);
        rowCountLbl.setText((currNdx+1)+" of "+rowCount);
        fillComments();
        fillForm();
	}
	
	void fillForm()
	{
	    collectionDate.setText(createDates[currNdx]);
	    changeDate.setText(changeDates[currNdx]);
	}
	
    void clearRecordList()
    {
        String[] x = new String[1];
        recordList.setListData(x);
        recordList.repaint();
        recordList.revalidate();
        currNdx=0;
    }
    
    public void increment()
    {
        if (currNdx==accountData.size()-1) return;
        currNdx++;
        recordList.clearSelection();
        recordList.setSelectionInterval(currNdx,currNdx);
        recordList.ensureIndexIsVisible(currNdx);
        rowCountLbl.setText((currNdx+1)+" of "+rowCount);
        fillComments();
        fillForm();
    }
    
    public void decrement()
    {
        if (currNdx==0) return;
        currNdx--;
        recordList.clearSelection();
        recordList.setSelectionInterval(currNdx,currNdx);
        recordList.ensureIndexIsVisible(currNdx);
        rowCountLbl.setText((currNdx+1)+" of "+rowCount);
        fillComments();
        fillForm();
    }
    
    public void fillComments()
    {
        int ndx = commentIndexes.indexOf(new Integer(currNdx));
        String s = null;
        if (ndx>=0) s=(String)commentText.elementAt(ndx);
        try { internalComment.setText(s); }
        catch (NullPointerException n) { }
    }
    
    public void updateComments()
    {
        String s = internalComment.getText();
        int ndx = commentIndexes.indexOf(new Integer(currNdx));
        if (Utils.isNull(s) && ndx>=0) {
            commentIndexes.removeElementAt(ndx);
            commentText.removeElementAt(ndx);
        }
        else if (ndx == -1) { 
            commentIndexes.addElement(new Integer(currNdx));
            commentText.addElement(s);
        }
        else commentText.setElementAt(s,ndx);
        updateInternalComment();
    }

	class SymKey extends java.awt.event.KeyAdapter
	{
		public void keyTyped(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == internalComment)
				internalComment_keyTyped(event);
			else if (object == batchNumber)
				batchNumber_keyTyped(event);
		}

		public void keyPressed(java.awt.event.KeyEvent event)
		{
			Object object = event.getSource();
			if (object == CollectionsForm.this)
				CollectionsForm_keyPressed(event);
			else if (object == batchNumber)
				batchNumber_keyPressed(event);
		}
	}

	void CollectionsForm_keyPressed(java.awt.event.KeyEvent event)
	{
		int key = event.getKeyCode();
		switch (key) {
		    case event.VK_F1:
		        if (screenMode==QUEUE || screenMode==DEQUEUE) changeQueueStatus();
		        break;
		    case event.VK_F2:
		        if (screenMode==NOTIFY) changeQueueStatus();
		        break;
		    case event.VK_F4:
		        String rName=getReport();
		        if (!Utils.isNull(rName))  {
		            viewReport(rName);
		            if (screenMode==QUEUE && !rName.equals("PENDING.col")) 
		                closingActions();
		        }
	            break;
		    case event.VK_DOWN:
		        if (rowCount>0) increment();
		        break;
		    case event.VK_UP:
		        if (rowCount>0) decrement();
		        break;
		    case event.VK_F9:
		        closingActions();
		        break;
		    case event.VK_ESCAPE:
		        resetForm();
		        openingActions();
		        break;
		    case event.VK_F3:
		        if (internalComment.isEnabled()) {
		            internalComment.setEnabled(false);
		            msgLabel.requestFocus();
		            updateComments();
		        }
		        else {
		            internalComment.setEnabled(true);
		            internalComment.requestFocus();
		        }
		        break;
            case event.VK_F11:
                if (currNdx>=0 && currNdx<rowCount) {
                    setCursor(new java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));
                    (new BillingForm(
                        dbLogin,accountList[currNdx])).setVisible(true);
                    setCursor(new java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));
                }
                break;
		}
	}
	
	public void changeQueueStatus()
	{
	    String msg = null;
	    String title = null;
	    switch (screenMode) {
	        case DEQUEUE:
	            msg="Put back in Collection Queue?";
	            title="DEQUEUE";
	            break;
	        case QUEUE:
	            msg="Dequeue from Collection Queue?";
	            title="QUEUE";
	            break;
	        case NOTIFY:
	            msg="Collection Agency has been notified?";
	            title="NOTIFY";
	            break;
	        default:
	            Utils.createErrMsg("Invalid Option");
	            return;
	    }
        int rv = confirmQueue.showConfirmDialog(
            this,msg,title,confirmQueue.YES_NO_OPTION,
		            confirmQueue.QUESTION_MESSAGE);
        if (rv==confirmQueue.YES_OPTION) { 
            removeFromList(); 
            resetForm();
            openingActions();
        }
    }

	void internalComment_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceUpper(event);
	}
	
	void updateInternalComment()
	{
	    String s = internalComment.getText();
	    if (currNdx<0 || currNdx>accountData.size()) {
	        Utils.createErrMsg("List index out of bounds");
	        return;
	    }
	    int labNumber = accountList[currNdx];    
	    int rcnt = dbConnection.getRowCount(
	        "pcs.lab_req_comments","lab_number="+labNumber);
	    String SQL = null;
	    Vector p = new Vector();
	    if (!Utils.isNull(s)) {
	        if (rcnt==0) {
	            SQL = 
	                "INSERT INTO pcs.lab_req_comments (lab_number,comment_text) \n"+
	                "VALUES (?,?) \n";
	            p.addElement(new SQLValue(dbConnection.INTEGER,labNumber));
	            p.addElement(new SQLValue(s));
	        }
	        else { 
	            SQL =
	                "UPDATE pcs.lab_req_comments \n"+
	                "SET comment_text = ? \n"+
	                "WHERE lab_number = ? \n";
                p.addElement(new SQLValue(s));
	            p.addElement(new SQLValue(dbConnection.INTEGER,labNumber));
	        }
	    }
	    else if (rcnt>0) {
            SQL = 
                "DELETE FROM pcs.lab_req_comments \n"+
	            "WHERE lab_number = ? \n";
            p.addElement(new SQLValue(dbConnection.INTEGER,labNumber));
	    }
	    if (!Utils.isNull(SQL)) dbConnection.change(SQL,p);
	}
	
	void removeFromList()
	{
	    if (currNdx<0 || currNdx>accountData.size()) {
	        Utils.createErrMsg("List index out of bounds");
	        return;
	    }
	    int labNumber = accountList[currNdx];    
	    String SQL = 
	        "UPDATE pcs.patient_accounts_in_collection \n"+
	        "SET sent = ?,change_date=SysDate WHERE lab_number = ?";
	    Vector p = new Vector();
	    switch (screenMode) {
	        case DEQUEUE:
	            p.addElement(new SQLValue(dbConnection.INTEGER,QUEUE));
	            break;
	        case QUEUE:
	            p.addElement(new SQLValue(dbConnection.INTEGER,DEQUEUE));
	            break;
	        case NOTIFY:
	            p.addElement(new SQLValue(dbConnection.INTEGER,NOTIFIED));
	            break;
	    }
	    p.addElement(new SQLValue(dbConnection.INTEGER,labNumber));
	    dbConnection.change(SQL,p);
	}

	void batchNumber_keyTyped(java.awt.event.KeyEvent event)
	{
		Utils.forceDigits(event);
	}

	void batchNumber_keyPressed(java.awt.event.KeyEvent event)
	{
		if (event.getKeyCode()==event.VK_ENTER) {
		    if (Utils.required(batchNumber,"Collection Batch Number")) {
		        getData();
		        if (accountData.size()==0) {
		            Utils.createErrMsg("Collections Report - Batch #"+
		                batchNumber.getText()+" does not exist.");
		            resetForm();
                    openingActions();		                
		        }
		        else {
		            fillRecordList();
		            batchNumber.setEnabled(false);
		            msgLabel.setText("Prior collections report");
		            msgLabel.requestFocus();
		        }
		    }
		}
	}
	
	public String getReport()
	{
	    String reportName = null;
	    Vector p = new Vector();
	    int sent_mode = screenMode;
	    if (screenMode==QUEUE) {
	        if (!verifyNewBatch()) sent_mode=PENDING;
	    }
	    p.addElement(new SQLValue(dbConnection.INTEGER,sent_mode));
	    dbConnection.call("pcs.build_collection_file",p);
	    switch (sent_mode) {
	        case PENDING:
	            reportName="PENDING.col";
	            break;
	        case DEQUEUE:
	            reportName="DEQUEUE.col"; 
	            break;
	        case QUEUE:
	            int batch = dbConnection.getMax(
	                "pcs.patient_accounts_in_collection",
	                "batch_number",null);
	            reportName=Utils.lpad(Integer.toString(batch),6,"0")+".col";
	            break;
	        case PRIOR_BATCH:   
	            reportName=Utils.lpad(batchNumber.getText(),6,"0")+".col";
	            break;
	        case NOTIFY:        
	            reportName="NOTIFY.col"; 
	            break;
	        case NOTIFIED:      
	            reportName="NOTIFIED.col"; 
	            break;
	    }
	    return (reportName);
	}
	
	void viewReport(String reportName)
	{
	    Vector printerCodes = new Vector();
	    if (screenMode!=PRIOR_BATCH && screenMode!=QUEUE && !reportName.equals("PENDING.col"))
	        printerCodes.addElement(Utils.CONDENSED);
	    else
	        printerCodes.addElement(Utils.EMPHASIZED);
	    (new ReportViewer(
	        reportName,"Collections Report",printerCodes)).setVisible(true);
	}
	
	boolean verifyNewBatch()
	{
	    boolean createNewBatch = false;
	    String msg = "Create new batch report for Collection Agency?";
	    String title = "Batch Collection Report";
        int rv = confirmQueue.showConfirmDialog(
            this,msg,title,confirmQueue.YES_NO_OPTION,
		            confirmQueue.QUESTION_MESSAGE);
        if (rv==confirmQueue.YES_OPTION) createNewBatch=true;
        return (createNewBatch);
	}
	
}
