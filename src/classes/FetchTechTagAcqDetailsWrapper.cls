public class FetchTechTagAcqDetailsWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
       // public Object previous{get;set;}
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
        public String created_date{get;set;}
        public String stage{get;set;}
        public String seller_broker_name{get;set;}
        public string createddateValFormat{get;set;}
    }

    
    public static FetchTechTagAcqDetailsWrapper parse(String json) {
        
        return (FetchTechTagAcqDetailsWrapper) System.JSON.deserialize(json, FetchTechTagAcqDetailsWrapper.class);
    }
    
  /*  static testMethod void testParse() {
        String json = '{\"response\":[{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008KN35AAG\",\"acquisition_name\":\"Augme - Lit\",\"stage\":\"Preliminary Discussion\",\"seller_broker_name\":\"Pepper Hamilton LLP\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCvnAAG\",\"acquisition_name\":\"Ingeniador - Lit\",\"stage\":\"Rejected\",\"seller_broker_name\":\"Patent Calls\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCu7AAG\",\"acquisition_name\":\"GraphOn - Litigation\",\"stage\":\"Rejected\",\"seller_broker_name\":\"Litigation Seller Tbd - Do Not Delete\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008KXswAAG\",\"acquisition_name\":\"TeliaSonera 2 - OMA\",\"stage\":\"Rejected\",\"seller_broker_name\":\"Iceberg Innovation\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCz1AAG\",\"acquisition_name\":\"Datamize - Litigation\",\"stage\":\"Rejected\",\"seller_broker_name\":\"Litigation Seller Tbd - Do Not Delete\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCzrAAG\",\"acquisition_name\":\"JuxtaComm - Litigation\",\"stage\":\"Initial Outreach\",\"seller_broker_name\":\"Litigation Seller Tbd - Do Not Delete\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCz8AAG\",\"acquisition_name\":\"Ganas - Lit\",\"stage\":\"Litgtn Discussion\",\"seller_broker_name\":\"Ronald William Burns , Jr\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCcNAAW\",\"acquisition_name\":\"Glow Designs - Acquisition\",\"stage\":\"Rejected\",\"seller_broker_name\":\"Lava Group\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCwEAAW\",\"acquisition_name\":\"Titanide Ventures / Prust - Litigation\",\"stage\":\"Phase 2\",\"seller_broker_name\":\"Banys PC\"},{\"product_name\":\"Software_Web Hosting\",\"acquisition_id\":\"a0540000008GCL1AAO\",\"acquisition_name\":\"Telecommunication Systems - Acq\",\"stage\":\"Rejected\",\"seller_broker_name\":\"TeleCommunication Systems Inc\"}],\"count\":10,\"pagination\":{\"previous\":null,\"next\":2,\"current\":1,\"per_page\":10,\"count\":35,\"pages\":4}}';
        FetchTechTagAcqDetailsWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}