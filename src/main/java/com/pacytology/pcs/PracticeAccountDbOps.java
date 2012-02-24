import java.lang.*;
import java.sql.*;
import java.util.Vector;

public class PracticeAccountDbOps
{
    public PracticeAccountsForm parent;

    public PracticeAccountDbOps(PracticeAccountsForm p) 
    { 
        parent=p; 
    }

    public void getPaymentTypes() {
        try  {
            String query = 
                "SELECT payment_code,payment_type \n"+
                "FROM pcs.payment_types \n"+
                "WHERE payment_code<>'B' \n"+
                "ORDER BY payment_type \n";
                
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                parent.paymentCodeVect.addElement(rs.getString(1));
                parent.paymentTypeVect.addElement(rs.getString(2));
            }       
            try { rs.close(); stmt.close(); }
            catch (Exception e) { }
        }
        catch( Exception e ) {
            System.out.println(e+" getPaymentTypes.query");
            parent.msgLabel.setText("Operation Failed");
        }
    }
    
    public boolean query(int practice)  {
        boolean exitStatus=true;
        try  {
            String query = 
                "SELECT \n"+
                "   p.name,\n"+           
                "   p.address1, \n"+        
                "   p.address2, \n"+         
                "   p.city, \n"+
                "   p.state, \n"+          
                "   p.zip, \n"+       
                "   p.contact, \n"+             
                "   p.phone, \n"+             
                "   p.fax, \n"+          
                "   p.stop_code, \n"+              
                "   p.price_code, \n"+             
                "   pc.comment_text, \n"+               
                "   TO_CHAR(pa.curr_balance-NVL(ps.total_plus,0)+NVL(ps.total_minus,0),'999990.99'), \n"+
                "   TO_CHAR(pa.over30_balance,'999990.99'), \n"+
                "   TO_CHAR(pa.over60_balance,'999990.99'), \n"+
                "   TO_CHAR(pa.over90_balance,'999990.99'), \n"+
                "   TO_CHAR(pa.total_balance,'999990.99'), \n"+
                "   TO_CHAR(NVL(ps.total_plus,0),'999990.99'), \n"+
                "   TO_CHAR(NVL(ps.total_minus,0),'99990.99'), \n"+
                "   TO_CHAR(ps.datestamp,'MM/DD/YYYY') \n"+
                "FROM \n"+
                "   pcs.practices p, \n"+
                "   pcs.practice_accounts pa, \n"+
                "   pcs.practice_comments pc, \n"+
                "   pcs.practice_statements ps \n"+
                "WHERE \n"+
                "   p.practice=pa.practice and \n"+
                "   p.practice=pc.practice(+) and \n"+
                "   pa.curr_statement_id=ps.statement_id(+) and \n"+
                "   p.practice="+practice+" \n";
                
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            int rowsReturned=0;
            while (rs.next()) {
                rowsReturned++;
                parent.practiceRec.practice=practice;
                parent.practiceRec.name=rs.getString(1);
                parent.practiceRec.address1=rs.getString(2);
                parent.practiceRec.address2=rs.getString(3);
                parent.practiceRec.city=rs.getString(4);
                parent.practiceRec.state=rs.getString(5);
                parent.practiceRec.zip=rs.getString(6);
                parent.practiceRec.contact=rs.getString(7);
                parent.practiceRec.phone=rs.getString(8);
                parent.practiceRec.fax=rs.getString(9);
                parent.practiceRec.stop_code=rs.getString(10);
                parent.practiceRec.price_code=rs.getString(11);
                parent.practiceRec.comment_text=rs.getString(12);
                parent.currBal.setText(rs.getString(13));
                parent.past30Bal.setText(rs.getString(14));
                parent.past60Bal.setText(rs.getString(15));
                parent.past90Bal.setText(rs.getString(16));
                parent.totalBal.setText(rs.getString(17));
                parent.lastPlus.setText(rs.getString(18));
                parent.lastMinus.setText(rs.getString(19));
                parent.practiceRec.last_statement=rs.getString(20);
            }       
            if (rowsReturned>0) { 
                query=
                    "SELECT \n"+
                    "   TO_CHAR(SUM(bill_amount),'999990.99'), \n"+
                    "   NVL(SUM(bill_amount),0) \n"+
                    "FROM \n"+
                    "   pcs.lab_requisitions lr, \n"+
                    "   pcs.lab_billings lb, \n"+
                    "   pcs.billing_queue bq \n"+
                    "WHERE \n"+
                    "   bq.lab_number=lb.lab_number and \n"+
                    //"   bq.rebilling=lb.rebilling and \n"+
                    "   bq.billing_route='PRA' and \n"+
                    "   lb.lab_number=lr.lab_number and \n"+
                    "   lr.practice="+practice+" \n";
                double rTtl=0;
                rs = stmt.executeQuery(query);
                while (rs.next()) {
                    rTtl=rs.getDouble(2);
                    if (rTtl>0)
                       parent.runningTotal.setText(rs.getString(1));
                    else parent.runningTotal.setText("0.00");
                }
            
                query = 
                    "SELECT \n"+
                    "   NVL(SUM(payment_amount),0),payment_type, \n"+
                    "   TO_CHAR(NVL(SUM(payment_amount),0),'999990.99') \n"+
                    "FROM pcs.payments \n"+
                    "WHERE account_id="+practice+" and billing_choice=122 and \n"+
                    "   TO_NUMBER(TO_CHAR(payment_date,'YYYYMM')) = \n"+
                    "   TO_NUMBER(TO_CHAR(SysDate,'YYYYMM')) \n"+
                    "GROUP BY payment_type \n";
                double payTtl=0;
                double payTtl2=0;
                double mAdj=0;
                double pAdj=0;
                rs = stmt.executeQuery(query);
                while (rs.next()) {
                    double nextSum=rs.getDouble(1);
                    String nextType=rs.getString(2);
                    if (nextType.equals("PLUS ADJUST")) {
                        payTtl-=nextSum;
                        //parent.plusAdjusts.setText(rs.getString(3));
                        pAdj+=nextSum;
                    }
                    else if (nextType.equals("MINUS ADJUST")) {
                        //parent.minusAdjusts.setText(rs.getString(3));
                        payTtl+=nextSum;
                        mAdj+=nextSum;
                    }
                    else { 
                        payTtl+=nextSum;
                        payTtl2+=nextSum;
                    }
                }
                
                query="SELECT TO_CHAR("+payTtl2+",'999990.99'), \n"+
                    "TO_CHAR("+pAdj+",'999990.99'), \n"+
                    "TO_CHAR("+mAdj+",'999990.99') \n"+
                    "FROM dual \n";
                rs = stmt.executeQuery(query);
                while (rs.next()) { 
                    parent.currentPayments.setText(rs.getString(1));
                    parent.plusAdjusts.setText(rs.getString(2));
                    parent.minusAdjusts.setText(rs.getString(3));
                }
                query=
                    "SELECT TO_CHAR(total_balance+"+rTtl+"-("+payTtl+"),'999990.99') \n"+
                    "FROM pcs.practice_accounts \n"+
                    "WHERE practice="+practice+" \n";
                rs=stmt.executeQuery(query);
                while (rs.next()) { parent.actualTotal.setText(rs.getString(1)); }
                query=
                    "SELECT count(*) from pcs.payments \n"+
                    "WHERE account_id="+practice+" and billing_choice=122 \n";
                rs=stmt.executeQuery(query);
                while (rs.next()) { parent.numPayments=rs.getInt(1); }
            }
            else {
                exitStatus=false;
                parent.msgLabel.setText("No Data Returned");
            }
            try { rs.close(); stmt.close(); }
            catch (Exception e) { exitStatus=false; }
        }
        catch( Exception e ) {
            System.out.println(e+" practiceAccounts.query");
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }
    
    public boolean queryPaymentTotal(int practice,double rTtl) {
        boolean exitStatus=true;
        try  {
            String query = 
                "SELECT \n"+
                "   NVL(SUM(payment_amount),0),payment_type, \n"+
                "   TO_CHAR(NVL(SUM(payment_amount),0),'999990.99') \n"+
                "FROM pcs.payments \n"+
                "WHERE account_id="+practice+" and and billing_choice=122 and \n"+
                "   TO_NUMBER(TO_CHAR(payment_date,'YYYYMM')) = \n"+
                "   TO_NUMBER(TO_CHAR(SysDate,'YYYYMM')) \n"+
                "GROUP BY payment_type \n";
            double payTtl=0;
            double payTtl2=0;
            double mAdj=0;
            double pAdj=0;
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            while (rs.next()) {
                double nextSum=rs.getDouble(1);
                String nextType=rs.getString(2);
                if (nextType.compareTo("PLUS ADJUST")==0) {
                    payTtl-=nextSum;
                    //parent.plusAdjusts.setText(rs.getString(3));
                    pAdj+=nextSum;
                }
                else if (nextType.compareTo("MINUS ADJUST")==0) {
                    //parent.minusAdjusts.setText(rs.getString(3));
                    payTtl+=nextSum;
                    mAdj+=nextSum;
                }
                else { 
                    payTtl+=nextSum;
                    payTtl2+=nextSum;
                }
            }
                
            query="SELECT TO_CHAR("+payTtl2+",'999990.99'), \n"+
                    "TO_CHAR("+pAdj+",'999990.99'), \n"+
                    "TO_CHAR("+mAdj+",'999990.99') \n"+
                    "FROM dual \n";
            rs = stmt.executeQuery(query);
            while (rs.next()) { 
                parent.currentPayments.setText(rs.getString(1));
                parent.plusAdjusts.setText(rs.getString(2));
                parent.minusAdjusts.setText(rs.getString(3));
            }
                
            query=
                "SELECT TO_CHAR(total_balance+"+rTtl+"-("+payTtl+"),'999990.99') \n"+
                "FROM pcs.practice_accounts \n"+
                "WHERE practice="+practice+" \n";
            rs=stmt.executeQuery(query);
            while (rs.next()) { parent.actualTotal.setText(rs.getString(1)); }
            try { rs.close(); stmt.close(); }
            catch (Exception e) { exitStatus=false; }
        }
        catch( Exception e ) {
            System.out.println(e+" paymentTotal");
            exitStatus=false;
            parent.msgLabel.setText("Operation Failed");
        }
        return(exitStatus);            
    }

    public void getPaymentData(int practice) {
        try  {
            String query = 
                "SELECT \n"+
                "   TO_CHAR(p.receive_date,'MM/DD/YYYY'),\n"+           
                "   p.payment_type, \n"+
                "   RTRIM(TO_CHAR(p.check_number)), \n"+        
                "   TO_CHAR(p.payment_amount,'999990.99'), \n"+         
                "   adj.adjust_reason \n"+
                "FROM pcs.payments p, pcs.payment_adjust_reasons adj \n"+
                "WHERE account_id="+practice+" and billing_choice=122 and \n"+
                "   p.payment_id=adj.payment_id(+) \n"+
                "ORDER BY payment_date DESC \n";
                
            Statement stmt = dbConnection.process().createStatement();
            ResultSet rs = stmt.executeQuery(query);
            int ndx=0;
            while (rs.next()) {
                String payDate=rs.getString(1);
                String payType=rs.getString(3);
                if (rs.wasNull()==false) payType=rs.getString(2)+" [#"+payType+"]";
                else payType=rs.getString(2);
                String payAmount=rs.getString(4);
                String adjust_reason=rs.getString(5);
                if (rs.wasNull()) adjust_reason=" ";
                parent.pData.payAdjustReasons.addElement(adjust_reason);
                parent.pData.addRow(payDate,payType,payAmount,adjust_reason);
                /*                
                parent.PaymentTable.setValueAt(rs.getString(1),ndx,0);
                parent.PaymentTable.setValueAt(rs.getString(4),ndx,2);
                String buf = rs.getString(3);
                if (rs.wasNull()==false) buf=rs.getString(2)+" [#"+buf+"]";
                else buf=rs.getString(2);
                parent.PaymentTable.setValueAt(buf,ndx,1);
                ndx++;
                */
            }       
            try { rs.close(); stmt.close(); }
            catch (Exception e) { }
        }
        catch( Exception e ) {
            System.out.println(e+" getPaymentData.query");
            parent.msgLabel.setText("Operation Failed");
        }
        
    }

    public boolean add(int practice) {
        boolean exitStatus=true;
        try  {
            String payment_type=parent.payCodeLbl.getText();
            String payment_amount=parent.paymentAmount.getText();
            String check_number=parent.checkNumber.getText();
            String receive_date=Utils.stripDateMask(parent.dateReceived.getText());
            try { int x = Integer.parseInt(check_number); }
            catch (Exception e) { check_number="null"; }
           
            String query = 
                "INSERT INTO pcs.payments \n"+
                "   (payment_id,billing_choice,account_id,payment_type, \n"+
                "    payment_amount,payment_date,check_number,sys_user,receive_date) \n"+
                "SELECT \n"+
                "   pcs.payments_seq.nextval,billing_choice,"+practice+", \n"+
                "   '"+payment_type+"',"+payment_amount+",SysDate, \n"+
                "  "+check_number+",UID,TO_DATE('"+receive_date+"','MMDDYYYY') \n"+
                "FROM pcs.billing_choices \n"+
                "WHERE choice_code='DOC' \n";
                
            Statement stmt = dbConnection.process().createStatement();
            int rs = stmt.executeUpdate(query);
            if ((payment_type.compareTo("PLUS ADJUST")==0)||
                (payment_type.compareTo("MINUS ADJUST")==0)) {
                query = 
                    "SELECT MAX(payment_id) \n"+
                    "FROM pcs.payments \n"+
                    "WHERE account_id="+practice+" and billing_choice=122 \n";
                int paymentID=0;
                ResultSet rs2 = stmt.executeQuery(query);
                while (rs2.next()) { paymentID=rs2.getInt(1); }
                if (paymentID>0) {
                    query = 
                        "INSERT INTO pcs.payment_adjust_reasons \n"+
                        "VALUES ("+paymentID+",'"+
                         parent.adjustReason.getText()+"') \n";
                    rs=stmt.executeUpdate(query);                         
                }
            }
            try { stmt.close(); }
            catch (Exception e) { exitStatus=false; }
        }
        catch( Exception e ) {
            System.out.println(e+" payments.add");
            parent.msgLabel.setText("Operation Failed");
            exitStatus=false;
        }
        return exitStatus;
        
    }
    
    public void close() {}
    
	//{{DECLARE_CONTROLS
	//}}
}
