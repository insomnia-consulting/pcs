package com.pacytology.pcs;public class LabBillingRec{    final int MAX_ITEMS=20;    int carrier_id;    String id_number;    String group_number;    String subscriber;    String sub_lname;    String sub_fname;    String sign_date;    String medicare_code;    int rebilling;    int billing_choice;    String choice_code;    String DPA_state;    String name;    int ttl_items;    double[] item_prices;    String[] item_codes;    String[] item_descr;    double bill_total;    String datestamp;    String payer_id;    int pcs_id;        public LabBillingRec() {        item_prices = new double [MAX_ITEMS];        item_codes = new String [MAX_ITEMS];         item_descr = new String [MAX_ITEMS];        ttl_items=0;        bill_total=0;    }}
