package com.pacytology.pcs;/*    PENNSYLVANIA CYTOLOGY SERVICES    LABORATORY INFORMATION SYSTEM V1.0    Copyright (C) 2001 by John Cardella    All Rights Reserved        File:       LabRec.java    Created By: John Cardella, Software Engineer        Function:   Class used to hold data from the Oracle    table that stores data about a lab requisition. Use    is with the LabForm and the BillingForm.        MODIFICATIONS -------------------------------------------------------------------    Date          Description:*/import java.lang.*;import java.sql.*;import java.util.Vector;public class LabRec{    PatientRec pat;    PracticeRec prac;    DoctorRec doc;    BillingRec billing;    Vector claimHistoryVect;        /*        Oracle Table:  pcs.lab_requisitions; alias=LR        Note: Where fields names are commone among more than        one table the alias followed by an under score is        used.             */    int lab_number;    int req_number;    int patient;    int practice;    int parent_account;    String program;    String e_reporting;    int doctor;    String patient_id;    int slide_qty;    int preparation;    String date_collected;    String lmp;    int age;    String rush;    int billing_choice;    int finished;    String LR_datestamp;    int LR_sys_user;    int previous_lab;    String receive_date;    String doctor_text;        /*        Oracle Table: pcs.lab_req_diagnosis    */    String diagnosis_code;    String diagnosis_code2;    String diagnosis_code3;    String diagnosis_code4;        /*        Oracle Table: pcs.lab_req_client_notes        There will be zero or one record per lab_number        in this table. The value of client_note_text will        hold the actual text.  The value of fillClientNotes        will be true if the associated practice has this        fields as required; false otherwise.    */    String client_note_text;    boolean fillClientNotes;        /*        Oracle Table: pcs.lab_req_comments    */    String lab_comments;        /*        Oracle Table:  pcs.lab_results        Needed for pap class to display if unsat    */    int pap_class;        int carrier_id;    String id_number;    String group_number;    String subscriber;    String sub_lname;    String sub_fname;    String sign_date;    String medicare_code;    String description;    String name;    String state;    String stop_code;    int rebilling;    int pcs_payer_id;    String payer_id;    String practice_name;    String prac_status;    String carrier_comments;    int check_number;    double payment_amount;    String payment_type;    String payment_info;    String bill_date;    String bill_amount;    String balance;    String billing_level;    String amount_due;    String this_balance;    String rebill_code;    String rebill_descr;    boolean isPartial;    String patient_cards;    /* VARS for claims */    String claim_status;    String create_date;    String create_user;    String change_date;    String change_user;        String invoice;        HPVRec hpv;        String ADPH_program;        public LabRec() { this.reset(); }		public void reset()  {	    pat = new PatientRec();	    doc = new DoctorRec();	    prac = new PracticeRec();	    hpv = new HPVRec();	    billing = new BillingRec();	    claimHistoryVect = new Vector();	    isPartial=false;	    billing_level=null;	    amount_due=null;	    this_balance=null;	    rebill_code=null;	    rebill_descr=null;	    pap_class=0;	    check_number=(-1);	    payment_amount=(-1);	    payment_info=null;        lab_number=(-1);        previous_lab=(-1);        req_number=(-1);        patient=(-1);        practice=(-1);        doctor=(-1);        patient_id=null;        slide_qty=(-1);        date_collected=null;        lmp=null;        rush=null;        billing_choice=(-1);        carrier_id=(-1);        id_number=null;        group_number=null;        subscriber=null;        sub_lname=null;        sub_fname=null;        sign_date=null;        medicare_code=null;        description=null;        name=null;        state=null;        stop_code=null;        rebilling=0;        fillClientNotes=false;        finished=Lab.NO_VALUE;        lab_comments=null;        client_note_text=null;        preparation=Lab.CONVENTIONAL;        pcs_payer_id=0;        payer_id=null;        practice_name=null;        carrier_comments=null;        bill_date=null;        bill_amount=null;        balance=null;    }	            public String toString()    {        String s =            "\nLAB:       "+lab_number+            "\nPREV LAB:  "+previous_lab+            "\nPATIENT:   "+patient+            "\nPRACTICE:  "+practice+            "\nDOCTOR:    "+doctor+            "\nSLIDES:    "+slide_qty+            "\nCOLLECTED: "+date_collected+            "\nRUSH:      "+rush+            "\nBILLING:   "+billing_choice+            "\nCARRIER:   "+carrier_id+            "\nSTOP:      "+stop_code+            "\nREBILL:    "+rebilling+            "\nPREP:      "+preparation+            "\nLEVEL:     "+finished;        return s;                }    }
