class ResultCodeData 
{
    public String bethesda_code;
    public String description;
    public String path_needed;
    public String category;
    public String papclass;
    public String active_status;
    public String biopsy_request;
    
    public ResultCodeData(String bethesda_code, String description, String path_needed, 
        String category, String papclass, String biopsy_request, String active_status)
    {
        this.bethesda_code=bethesda_code;
        this.description=description;
        this.path_needed=path_needed;
        this.category=category;
        this.papclass=papclass;
        this.active_status=active_status;
        this.biopsy_request=biopsy_request;
    
		//{{INIT_CONTROLS
		//}}
	}
    
	//{{DECLARE_CONTROLS
	//}}
}    
