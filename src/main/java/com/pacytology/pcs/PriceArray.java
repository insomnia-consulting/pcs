public class PriceArray{    public PriceCodeRec[] pricing;    public String priceCode;    public String activeStatus;    public String pricingComments;    private int SIZE;    public PriceArray(int s) {        this.SIZE=s;        pricing = new PriceCodeRec[SIZE];        for (int i=0;i<SIZE;i++)            pricing[i] = new PriceCodeRec();    }}
