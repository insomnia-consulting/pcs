package com.pacytology.pcs;

import java.awt.*;
import javax.swing.*;
import java.util.Vector;
import javax.swing.table.*;
import com.pacytology.pcs.ui.Square;
import com.pacytology.pcs.utils.StringUtils;

import java.sql.*;
import java.io.*;



class PendingPaymentTableData extends AbstractTableModel
{
    static final public ColumnData columns[] = {
        new ColumnData("ID",5,JLabel.LEFT,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("CODE",4,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("ACCT",5,JLabel.LEFT,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("TYPE",10,JLabel.LEFT,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("CHECK",5,JLabel.LEFT,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("AMOUNT",10,JLabel.RIGHT,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("ENTERED",10,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("RECEIVED",10,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("COMMENT",20,JLabel.LEFT,(new Font("DialogInput",Font.PLAIN,12)))
    };

    private Vector rVect;
    private StringUtils format = new StringUtils();
    public PendingPaymentTableData() {rVect = new Vector(); 
		//{{INIT_CONTROLS
		//}}
	}

    public void addRow(int payment_id, String choice_code, int account_id,
        String payment_type, int check_number, String payment_amount,
        String date_entered, String date_received, String adjust_reason) {
        rVect.addElement(new PendingPaymentData(payment_id,choice_code,account_id,
            payment_type,check_number,payment_amount,date_entered,
            date_received,adjust_reason));
    }

    public void setValueAt(Object value, int row, int column) {
        PendingPaymentData cRow = (PendingPaymentData)rVect.elementAt(row);
        switch (column) {
            case 0: cRow.payment_id=((Integer)value).intValue(); break;  
            case 1: cRow.choice_code=(String)value; break;
            case 2: cRow.account_id=((Integer)value).intValue(); break;
            case 3: cRow.payment_type=(String)value; break;
            case 4: cRow.check_number=((Integer)value).intValue(); break;
            case 5: cRow.payment_amount=(String)value; break;
            case 6: cRow.date_entered=(String)value; break;
            case 7: cRow.date_received=(String)value; break;
            case 8: cRow.adjust_reason=(String)value; break;
        }
        rVect.setElementAt(cRow,row);
    }

    public Object getValueAt(int row, int column) { 
        if (row<0 || row>=getRowCount()) return "";
        PendingPaymentData cRow = (PendingPaymentData)rVect.elementAt(row);
        switch (column) {
            case 0: return (new Integer(cRow.payment_id));   
            case 1: return cRow.choice_code;
            case 2: return (new Integer(cRow.account_id));
            case 3: return cRow.payment_type;
            case 4: return (new Integer(cRow.check_number));
            case 5: return cRow.payment_amount;
            case 6: return cRow.date_entered;
            case 7: return cRow.date_received;
            case 8: return cRow.adjust_reason;
        }
        return "";
    }
    
    public int getRowCount() { return rVect.size(); }
    public int getColumnCount() { return columns.length; }
    public boolean isCellEditable(int row, int column) { return (true); }
    public String getColumnName(int column) { return columns[column].title; }
    
	//{{DECLARE_CONTROLS
	//}}
}
