public class FetchCCCompDetailsWrapper {

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
        public String patent_id{get;set;}
        public String patent_number{get;set;}
        public String patent_family_id{get;set;}
        public String patent_family_name{get;set;}
        public String company_name{get;set;}
        public String analyst_notes{get;set;}
        public String entity_salesforce_id{get;set;}
    }

    
    public static FetchCCCompDetailsWrapper parse(String json) {
        return (FetchCCCompDetailsWrapper) System.JSON.deserialize(json, FetchCCCompDetailsWrapper.class);
    }
    
   /* static testMethod void testParse() {
        String json = '{\"response\":[{\"patent_id\":\"2653006\",\"patent_number\":\"US7158181B2\",\"patent_family_id\":\"146686306\",\"patent_family_name\":\"10/838,471 US7158181B2 (3 US Patents)\",\"company_name\":\"Macy\'s Incorporated\",\"analyst_notes\":\"A1\",\"entity_salesforce_id\":\"0014000000OnpMOAAZ\"}],\"count\":1,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":1,\"pages\":1}}';
        FetchCCCompDetailsWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}