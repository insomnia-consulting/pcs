import java.awt.*;
import javax.swing.*;
import java.util.Vector;
import javax.swing.table.*;
import Square;
import java.sql.*;
import java.io.*;





class PendingPaymentData 
{
    public int payment_id;
    public String choice_code;
    public int account_id;
    public String payment_type;
    public int check_number;
    public String payment_amount;
    public String date_entered; /* payment_date */
    public String date_received;
    public String adjust_reason;
    
    public PendingPaymentData(int payment_id, String choice_code, int account_id,
        String payment_type, int check_number, String payment_amount,
        String date_entered, String date_received, String adjust_reason)
    {
        this.payment_id=payment_id;
        this.choice_code=choice_code;
        this.account_id=account_id;
        this.payment_type=payment_type;
        this.check_number=check_number;
        this.payment_amount=payment_amount;
        this.date_entered=date_entered;
        this.date_received=date_received;
        this.adjust_reason=adjust_reason;
    
		//{{INIT_CONTROLS
		//}}
	}
    
	//{{DECLARE_CONTROLS
	//}}
}    
