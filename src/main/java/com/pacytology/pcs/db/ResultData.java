package com.pacytology.pcs.db;

/* Class that displays the table on the Results Form
*/
public class ResultData 
{
    public String result_code;
    public String qc_result_code;
    public String path_result_code;
    public String description;
    
    public ResultData(String result_code, String qc_result_code, 
        String path_result_code, String description)
    {
        this.result_code=result_code;
        this.qc_result_code=qc_result_code;
        this.path_result_code=path_result_code;
        this.description=description;
    }
    
}    