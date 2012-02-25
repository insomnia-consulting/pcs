package com.pacytology.pcs;public class Lab{    /*  Lab preparations    */    final public static int PREPARATION = 17;         // Detail code for preparation    final public static int EXPIRED = 0;              // New, added 10/5/2005    final public static int CONVENTIONAL = 1;    final public static int THIN_LAYER = 2;    final public static int PAP_NET = 3;              // Note: PapNet no longer used    final public static int CYT_NON_PAP = 4;    final public static int HPV_ONLY = 5;             // New, added 7/13/2005    final public static int SURGICAL = 6;             // New, added 10/26/2005    final public static int IMAGED_SLIDE = 7;         // New, added 2/5/2008        /*  Billing choices    */    final public static int DB = 121;     // DIRECT BILLING    final public static int DOC = 122;    // PHYSICIAN ACCOUNT    final public static int DPA = 123;    // MEDICAL ASSISTANCE    final public static int BS = 124;     // BLUE SHIELD    final public static int MED = 125;    // MEDICARE    final public static int OI = 126;     // OTHER INSURANCE    final public static int PRC = 127;    // PROFESSIONAL COURTESY    final public static int PPN = 141;    // PAPNET (no longer used; inactive billing type)    final public static int PPD = 161;    // PREPAID                                                                          A        /*  Database modes    */    final public static int FATAL=99;    final public static int IDLE=100;    final public static int QUERY=101;    final public static int ADD=102;    final public static int UPDATE=103;    final public static int DELETE=104;    final public static int CURRENT=105;    final public static int MERGE=106;    final public static int QUERY_FOR_ADD=107;    final public static int RELEASE=108;    final public static int HOLD=109;    final public static int UPDATE_ID=110;        /*  Insurance claim actions    */    final public static int REBILL_ADD=111;    final public static int CLAIM_QUERY=112;    final public static int CLAIM_UPDATE=113;    final public static int CLAIM_ADD=114;    final public static int REBILL=115;    final public static int REBILL_UPDATE=116;    final public static int CLAIM=117;    final public static int REWORK=118;    final public static int REWORK_ADD=119;    final public static int PATIENT_UPDATE=120;    final public static int REVERSE_PAYMENT=121;        final public static int QUEUE=122;    final public static int QUEUE_UPDATE=123;    final public static int TISSUE_CODES=124;    final public static int REQ_CODES=125;        /*  Report modes    */    final public static int NO_PRINT=0;        // do not print    final public static int CURR_DRAFT=1;      // currently queued draft reports    final public static int CURR_FINAL=2;      // currently queued final reports    final public static int DRAFT=3;           // non-queued request for draft report(s)    final public static int FINAL=4;           // non-queued request for final report(s)    final public static int HOLD_HPV=5;        // queued until HPV results available    final public static int CURR_HPV=6;        // current with HPV results available     /*  Export modes for file formatting    */    final public static int HL7 = 501;    final public static int CYTOPATHOLOGY_REPORTS = 502;    final public static int HPV_REPORTS = 503;        /*  Values for finished field in lab_requisitions    */    final public static int NO_VALUE = -2;    final public static int EXPIRED_SPECIMEN = -1;    final public static int RESULTS_PENDING = 0;    final public static int BILLING_QUEUE = 1;    final public static int SUBMITTED = 2;    final public static int PENDING = 3;    final public static int FINISHED = 4;    final public static int FIRST_DATA_CONVERSION = 100;    final public static int SECOND_DATA_CONVERSION = 200;    final public static int THIRD_DATA_CONVERSION = 300;    final public static int FOURTH_DATA_CONVERSION = 400;        /* Miscellaneous    */    final public static int HPV = 2981;             // cytotech for code 2981 = 'HPV'    final public static int NON_GYNE = 10;          // PAP class corresponds to PREP #4    final public static int CURR_WKS = 0;           // current history worksheets    final public static int COPY_WKS = 1;           // copy history worksheets    final public static int HPV_PENDING = 600;    final public static int UNKNOWN = 601;    final public static int UNUSED = 602;    final public static int FAX_QUEUE = 603;    }
