public class TechTagMatchedAcqWrapper {

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
        public String product_name{get;set;}
        public String acquisition_id{get;set;}
        public String acquisition_name{get;set;}
        public String acquisition_type{get;set;}
        public string created_date{get;set;}
        public String stage{get;set;}
        public String seller_broker_name{get;set;}
        public string last_stage_change{get;set;}        
        public string createddateValFormat{get;set;}
        public date stageddateValFormat{get;set;}
        
    }

    
    public static TechTagMatchedAcqWrapper parse(String json) {
        return (TechTagMatchedAcqWrapper) System.JSON.deserialize(json, TechTagMatchedAcqWrapper.class);
    }
    
   /* static testMethod void testParse() {
        String json = '{\"response\":[{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCr9AAG\",\"acquisition_name\":\"OT ICAP Spring 11 - Lot 16 - Journyx 1 - Acq\",\"acquisition_type\":\"OMA\",\"created_date\":\"2011-02-25 21:23:18\",\"stage\":\"Rejected\",\"seller_broker_name\":\"ICAP OT Auctions\"}],\"count\":1,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":100,\"count\":1,\"pages\":1}}';
        TechTagMatchedAcqWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}