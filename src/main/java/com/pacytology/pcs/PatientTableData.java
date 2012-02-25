package com.pacytology.pcs;

import javax.swing.table.*;
import java.util.Vector;
import javax.swing.*;

class PatientTableData extends AbstractTableModel
{
    
    private StringUtils format = new StringUtils();
    
    static final public ColumnData columns[] = {
        new ColumnData("LAST",82,JLabel.LEFT),
        new ColumnData("FIRST",61,JLabel.LEFT),
        new ColumnData("SSN",75,JLabel.CENTER),
        new ColumnData("DOB",68,JLabel.CENTER),
        new ColumnData("LAST LAB",70,JLabel.CENTER),
        new ColumnData("PRAC",35,JLabel.CENTER),
        new ColumnData("ADDRESS",148,JLabel.LEFT),
        new ColumnData("CITY",72,JLabel.LEFT),
        new ColumnData("ST",20,JLabel.CENTER),
        new ColumnData("ZIP",58,JLabel.CENTER)
    };

    public Vector pVect;

    public PatientTableData() { 
        pVect = new Vector();
        initData();
    }
    
    public void initData() {
        pVect.removeAllElements();
        for (int i=0;i<80;i++) 
            pVect.addElement(new PatientData(" ", " ", " ", " ", " ", " ", " ", " ", " ", " "));
    }

    public void setValueAt(Object value, int row, int column) {
        PatientData pRow = (PatientData)pVect.elementAt(row);
        String s = null;
        switch (column) {
            case 0: pRow.lname=(String)value;break;
            case 1: pRow.fname=(String)value;break;
            case 2: s=format.addSSNMask((String)value);
                    pRow.ssn=s;
                    break;
            case 3: s=format.addDateMask((String)value);
                    pRow.dob=s;
                    break;
            case 4: pRow.last_lab=(String)value;break;
            case 5: pRow.practice=(String)value;break;
            case 6: pRow.address=(String)value;break;
            case 7: pRow.city=(String)value;break;
            case 8: pRow.state=(String)value;break;
            case 9: pRow.zip=(String)value;break;
        }
        pVect.setElementAt(pRow,row);
    }

    public Object getValueAt(int row, int column) { 
        if (row<0 || row>=getRowCount()) return "";
        PatientData pRow = (PatientData)pVect.elementAt(row);
        switch (column) {
            case 0: return pRow.lname;
            case 1: return pRow.fname;
            case 2: return pRow.ssn;
            case 3: return pRow.dob;
            case 4: return pRow.last_lab;
            case 5: return pRow.practice;
            case 6: return pRow.address;
            case 7: return pRow.city;
            case 8: return pRow.state;
            case 9: return pRow.zip;
        }
        return "";
    }
    
    public int getRowCount() { return 80; }
    public int getColumnCount() { return columns.length; }
    public boolean isCellEditable(int row, int column) { return (true); }
    public String getColumnName(int column) { return columns[column].title; }
}
