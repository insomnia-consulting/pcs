package com.pacytology.pcs;/*    PENNSYLVANIA CYTOLOGY SERVICES    LABORATORY INFORMATION SYSTEM V1.0    Copyright (C) 2001 by John Cardella    All Rights Reserved        File:       DiagnosisCodeRec.java    Created By: John Cardella, Software Engineer        Function:   Holds data ICD9 data        MODIFICATIONS ----------------------------------    Date/Staff      Description:*/public class DiagnosisCodeRec{    public String diagnosis_code;    public String description;    public String formattedString;    public String active_status;        public DiagnosisCodeRec() { this.reset(); }        public void reset()  {        diagnosis_code=" ";        description=" ";        formattedString=" ";    }        }
