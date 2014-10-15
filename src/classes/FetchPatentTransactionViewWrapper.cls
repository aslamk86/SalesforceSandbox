public class FetchPatentTransactionViewWrapper {

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
        public String patnum{get;set;}
        public String patent_number{get;set;}
        public String transaction_id{get;set;}
        public String transaction_date{get;set;}
        public String seller_entity{get;set;}
        public String seller_type{get;set;}
        public String buyer_entity{get;set;}
        public String buyer_type{get;set;}
        public string purchase_price{get;set;}
        public Integer assets_count{get;set;}
    }

    
    public static FetchPatentTransactionViewWrapper parse(String json) {
        system.debug('@@JSON string'+json);
        return (FetchPatentTransactionViewWrapper) System.JSON.deserialize(json, FetchPatentTransactionViewWrapper.class);
    }
    
  /*  static testMethod void testParse() {
        String json = '{\"response\":[{\"patnum\":\"US6712628B2\",\"patent_number\":\"6712628\",\"transaction_id\":\"101336\",\"date\":\"2013-02-26\",\"seller_entity\":\"Flextronics International Limited\",\"seller_type\":\"Operating Company\",\"buyer_entity\":\"DRNC Holdings Incorporated\",\"buyer_type\":\"NPE\",\"purchase_price\":null,\"assets_count\":87},{\"patnum\":\"US6712628B2\",\"patent_number\":\"6712628\",\"transaction_id\":\"100287\",\"date\":\"2011-02-17\",\"seller_entity\":\"IPG Electronics 504 Limited\",\"seller_type\":\"NPE\",\"buyer_entity\":\"Flextronics Innovative Development Limited\",\"buyer_type\":\"Operating Company\",\"purchase_price\":null,\"assets_count\":82}],\"count\":2,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":2,\"pages\":1}}';
        FetchPatentTransactionViewWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}