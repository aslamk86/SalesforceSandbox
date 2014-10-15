public class FetchRelCompDetailsWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
      //  public Object previous{get;set;}
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
        public String relevant_company_name{get;set;}
        public String analyst_notes{get;set;}
        public String entity_salesforce_id{get;set;}
    }

    
    public static FetchRelCompDetailsWrapper parse(String json) {
        return (FetchRelCompDetailsWrapper) System.JSON.deserialize(json, FetchRelCompDetailsWrapper.class);
    }
    
    //static testMethod void testParse() {
        //String json = ('{"response":[{"patent_family_id":"203091","patent_family_name":"09/865,414 US6539884B1 (4 US Patents)","patent_id":"4377357","patent_number":"US6761123B2","company_name":"Volkswagen AG","licensee_id":"20618","expiry_date":"2013-12-27","analyst_notes":"CAR \n\nBEST\n\nAWESOME\n\nMOBILE\n\nMODERN\n FEATURE"}]}');
        //FetchRelCompDetailsWrapper obj = parse(json);
        //System.assert(obj != null);
    //}
}