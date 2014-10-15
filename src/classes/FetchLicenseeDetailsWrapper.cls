public class FetchLicenseeDetailsWrapper {

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
        public String patent_family_id{get;set;}
        public String patent_family_name{get;set;}
        public String patent_id{get;set;}
        public String patent_number{get;set;}
        public String company_name{get;set;}
        public String licensee_id{get;set;}
        public String expiry_date{get;set;}
        public String analyst_notes{get;set;}
    }

    
    public static FetchLicenseeDetailsWrapper parse(String json) {
        return (FetchLicenseeDetailsWrapper) System.JSON.deserialize(json, FetchLicenseeDetailsWrapper.class);
    }
    
    /*static testMethod void testParse() {
        String json = '{\"response\":[{\"patent_family_id\":\"203091\",\"patent_family_name\":\"09/865,414 US6539884B1 (4 US Patents)\",\"patent_id\":\"4377357\",\"licensee_id\":\"20618\",\"expiry_date\":\"2013-12-27\",\"analyst_notes\":\"CAR \\n\\nBEST\\n\\nAWESOME\\n\\nMOBILE\\n\\nMODERN\\n FEATURE\"},{\"patent_family_id\":\"158582715\",\"patent_family_name\":\"11/444,930 US8571980B1 (1 US Patent)\",\"patent_id\":\"9230656\",\"licensee_id\":\"20638\",\"expiry_date\":null,\"analyst_notes\":\"\"}],\"count\":2,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":2,\"pages\":1}}';
        FetchLicenseeDetailsWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}