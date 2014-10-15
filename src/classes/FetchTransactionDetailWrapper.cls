public class FetchTransactionDetailWrapper {

  public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        //public Object previous{get;set;}
        public integer next{get;set;}
        public Integer current{get;set;}
        public Integer per_page{get;set;}
        public Integer count{get;set;}
        public Integer pages{get;set;}
    }

    public class Response {
        public String transaction_id{get;set;}
        public String transaction_date{get;set;}
        public String seller_entity{get;set;}
        public String seller_type{get;set;}
        public String buyer_entity{get;set;}
        public String buyer_type{get;set;}
        public string purchase_price{get;set;}
        public Integer assets_count{get;set;}
    }

    
    public static FetchTransactionDetailWrapper parse(String json) {
        return (FetchTransactionDetailWrapper) System.JSON.deserialize(json, FetchTransactionDetailWrapper.class);
    }
    
   /* static testMethod void testParse() {
        String json = '{\"response\":[{\"transaction_id\":\"101668\",\"transaction_date\":\"2014-04-02\",\"seller_entity\":null,\"seller_type\":\"Operating Company\",\"buyer_entity\":\"Altera Corporation\",\"buyer_type\":\"Operating Company\",\"purchase_price\":null,\"assets_count\":34}],\"count\":1,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":1,\"pages\":1}}';
        FetchTransactionDetailWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}