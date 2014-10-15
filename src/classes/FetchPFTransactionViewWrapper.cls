public class FetchPFTransactionViewWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        //public Object previous{get;set;}
        public Integer next{get;set;}
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
        public String purchase_price{get;set;}
        public Integer assets_count{get;set;}
    }

    
    public static FetchPFTransactionViewWrapper parse(String json) {
        return (FetchPFTransactionViewWrapper) System.JSON.deserialize(json, FetchPFTransactionViewWrapper.class);
    }

}