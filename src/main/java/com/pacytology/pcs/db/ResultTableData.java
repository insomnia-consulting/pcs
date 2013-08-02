package com.pacytology.pcs.db;

import java.awt.Font;
import java.util.Vector;

import javax.swing.JLabel;
import javax.swing.table.AbstractTableModel;

import com.pacytology.pcs.ColumnData;

public class ResultTableData extends AbstractTableModel
{
    /**
	 * 
	 */
	private static final long serialVersionUID = 767406169076352961L;

	static final public ColumnData columns[] = {
        new ColumnData("SCR",50,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("QC",50,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("PATH",50,JLabel.CENTER,(new Font("DialogInput",Font.PLAIN,12))),
        new ColumnData("DESCRIPTION",300,JLabel.LEFT,(new Font("DialogInput",Font.PLAIN,10)))
    };

    private Vector rVect;

    public ResultTableData() { 
        rVect = new Vector();
    }
    
    public boolean resultEntered(String bCode, int column)
    {
        boolean rv = false;
        for (int i=0; i<rVect.size(); i++) {
            String rCode = (String)getValueAt(i,column);
            try {
                if (rCode.equals(bCode)) {
                    rv=true;
                    break;
                }
            }
            catch (Exception e) { }
        }
        return (rv);
    }
    
    public void addRow(String result_code, String qc_result_code, String path_result_code, String description) {
        rVect.addElement(new ResultData(result_code,qc_result_code,path_result_code,description));
    }

    public void removeRow(int nRow) {
        rVect.removeElementAt(nRow);
    }
    
    public void removeAllRows() {
        rVect.removeAllElements();
    }
    
    public int removeSCR(String code, int max) 
    {
        Vector codes = new Vector();
        for (int i=0; i<rVect.size(); i++) {
            if (i==max) break;
            String bCode = (String)getValueAt(i,0);
            if (!bCode.equals(code)) 
                codes.addElement(bCode);
        }
        for (int i=0; i<codes.size(); i++) {
            setValueAt(codes.elementAt(i),i,0);
        }
        for (int i=codes.size(); i<rVect.size(); i++) {
            setValueAt(null,i,0);
        }
        return (codes.size());
    }
    
    public int removeQC(String code, int max) 
    {
        Vector codes = new Vector();
        for (int i=0; i<rVect.size(); i++) {
            if (i==max) break;
            String bCode = (String)getValueAt(i,1);
            try {
                if (!bCode.equals(code)) 
                    codes.addElement(bCode);
            }
            catch (Exception e) { }
        }
        for (int i=0; i<codes.size(); i++) {
            setValueAt(codes.elementAt(i),i,1);
        }
        for (int i=codes.size(); i<rVect.size(); i++) {
            setValueAt(null,i,1);
        }
        return (codes.size());
    }

    public int removePATH(String code, int max) 
    {
        Vector codes = new Vector();
        for (int i=0; i<rVect.size(); i++) {
            if (i==max) break;
            String bCode = (String)getValueAt(i,2);
            if (!bCode.equals(code)) 
                codes.addElement(bCode);
        }
        for (int i=0; i<codes.size(); i++) {
            setValueAt(codes.elementAt(i),i,2);
        }
        for (int i=codes.size(); i<rVect.size(); i++) {
            setValueAt(null,i,2);
        }
        return (codes.size());
    }
   
    @Override
	public void setValueAt(Object value, int row, int column) {
        ResultData cRow = (ResultData)rVect.elementAt(row);
        switch (column) {
            case 0: cRow.result_code=(String)value;break;
            case 1: cRow.qc_result_code=(String)value;break;
            case 2: cRow.path_result_code=(String)value;break;
            case 3: cRow.description=(String)value;break;
        }
        rVect.setElementAt(cRow,row);
    }

    @Override
	public Object getValueAt(int row, int column) { 
        if (row<0 || row>=getRowCount()) return "";
        ResultData cRow = (ResultData)rVect.elementAt(row);
        switch (column) {
            case 0: return cRow.result_code;
            case 1: return cRow.qc_result_code;
            case 2: return cRow.path_result_code;
            case 3: return cRow.description;
        }
        return "";
    }
    
    @Override
	public int getRowCount() { return rVect.size(); }
    @Override
	public int getColumnCount() { return columns.length; }
    @Override
	public boolean isCellEditable(int row, int column) { return (true); }
    @Override
	public String getColumnName(int column) { return columns[column].title; }
    
}