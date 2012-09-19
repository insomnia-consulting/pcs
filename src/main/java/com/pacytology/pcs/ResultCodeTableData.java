package com.pacytology.pcs;

import java.awt.*;
import javax.swing.*;
import javax.swing.table.*;

import com.pacytology.pcs.utils.StringUtils;

import java.util.Vector;

class ResultCodeTableData extends AbstractTableModel
{
    static final public ColumnData columns[] = {
        new ColumnData("CODE",20,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("DESCRIPTION",200,JLabel.LEFT,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("PATH",18,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("CAT",18,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,10))),
        new ColumnData("PAP",18,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,10))),
        new ColumnData("BIO",18,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,10))),
        new ColumnData("ST",18,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,10)))
    };

    private Vector dVect;
    private StringUtils format = new StringUtils();

    public ResultCodeTableData() { 
        dVect = new Vector();
    
		//{{INIT_CONTROLS
		//}}
	}
    
    public void addRow(String bethesda_code, String description, String path_needed, 
        String category, String papclass, String biopsy_request, String active_status) {
        dVect.addElement(new ResultCodeData(bethesda_code,description,path_needed,
            category,papclass,biopsy_request,active_status));
    }

    public void removeRow(int nRow) {
        dVect.removeElementAt(nRow);
    }
    
    public void removeAllRows() {
        dVect.removeAllElements();
    }
    
    public void setValueAt(Object value, int row, int column) {
        ResultCodeData cRow = (ResultCodeData)dVect.elementAt(row);
        switch (column) {
            case 0: cRow.bethesda_code=(String)value;break;
            case 1: cRow.description=(String)value;break;
            case 2: cRow.path_needed=(String)value;break;
            case 3: cRow.category=(String)value;break;
            case 4: cRow.papclass=(String)value;break;
            case 5: cRow.biopsy_request=(String)value;break;
            case 6: cRow.active_status=(String)value;break;
        }
        dVect.setElementAt(cRow,row);
    }

    public Object getValueAt(int row, int column) { 
        if (row<0 || row>=getRowCount()) return "";
        ResultCodeData cRow = (ResultCodeData)dVect.elementAt(row);
        switch (column) {
            case 0: return cRow.bethesda_code;
            case 1: return cRow.description;
            case 2: return cRow.path_needed;
            case 3: return cRow.category;
            case 4: return cRow.papclass;            
            case 5: return cRow.biopsy_request;        
            case 6: return cRow.active_status;        
        }
        return "";
    }
    
    public int getRowCount() { return dVect.size(); }
    public int getColumnCount() { return columns.length; }
    public boolean isCellEditable(int row, int column) { return (true); }
    public String getColumnName(int column) { return columns[column].title; }
    
	//{{DECLARE_CONTROLS
	//}}
}
