// This Wrapper Class is common for both Account and Acquisition transactions
public class FetchAcqOrAccTransactionWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        public Integer previous{get;set;}
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
        public String seller_alias{get;set;}
        public String seller_account_id{get;set;}
        public String seller_type{get;set;}
        public String buyer_entity{get;set;}
        public String buyer_alias{get;set;}
        public String buyer_account_id{get;set;}
        public String buyer_type{get;set;}
        public Decimal purchase_price{get;set;}
        public Integer assets_count{get;set;}
        public String overlap{get;set;}
        public String similarity{get;set;}
        public String deal_match{get;set;}
    }

    
    public static FetchAcqOrAccTransactionWrapper parse(String json) {
        return (FetchAcqOrAccTransactionWrapper) System.JSON.deserialize(json, FetchAcqOrAccTransactionWrapper.class);
    }
    /*
    static testMethod void testParse() {
        String json = '{\"response\":[{\"patnum\":\"US7575154B2\",\"patent_number\":\"7575154\",\"transaction_id\":\"100188\",\"transaction_date\":\"2011-09-01\",\"seller_entity\":\"Reagan Inventions LLC\",\"seller_type\":\"Operating Company\",\"buyer_entity\":\"Clayco Research Limited Liability Company\",\"buyer_type\":\"NPE\",\"purchase_price\":null,\"assets_count\":7,\"overlap\":\"5\",\"similarity\":\"50.00\",\"deal_match\":\"Yes\"},{\"patnum\":\"US7575154B2\",\"patent_number\":\"7575154\",\"transaction_id\":\"100188\",\"transaction_date\":\"2011-09-01\",\"seller_entity\":\"Reagan Inventions LLC\",\"seller_type\":\"Operating Company\",\"buyer_entity\":\"Clayco Research Limited Liability Company\",\"buyer_type\":\"NPE\",\"purchase_price\":null,\"assets_count\":7,\"overlap\":\"5\",\"similarity\":\"50.00\",\"deal_match\":\"Yes\"},{\"patnum\":\"US7896242B2\",\"patent_number\":\"7896242\",\"transaction_id\":\"100188\",\"transaction_date\":\"2011-09-01\",\"seller_entity\":\"Reagan Inventions LLC\",\"seller_type\":\"Operating Company\",\"buyer_entity\":\"Clayco Research Limited Liability Company\",\"buyer_type\":\"NPE\",\"purchase_price\":null,\"assets_count\":7,\"overlap\":\"5\",\"similarity\":\"50.00\",\"deal_match\":\"Yes\"},{\"patnum\":\"US7896242B2\",\"patent_number\":\"7896242\",\"transaction_id\":\"100188\",\"transaction_date\":\"2011-09-01\",\"seller_entity\":\"Reagan Inventions LLC\",\"seller_type\":\"Operating Company\",\"buyer_entity\":\"Clayco Research Limited Liability Company\",\"buyer_type\":\"NPE\",\"purchase_price\":null,\"assets_count\":7,\"overlap\":\"5\",\"similarity\":\"50.00\",\"deal_match\":\"Yes\"}],\"count\":4,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":4,\"pages\":1}}';
        FetchAcqOrAccTransactionWrapper obj = parse(json);
        System.assert(obj != null);
    }
    */
}