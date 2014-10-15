public class FetchTechTagDetailsWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        //public Object previous;
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
        public String tech_tag_name{get;set;}
        public String tech_tag_salesforce_id{get;set;}
        public string theory_of_relevance{get;set;}
        public string free_form_tags{get;set;}
    }

    
    public static FetchTechTagDetailsWrapper parse(String json) {
        return (FetchTechTagDetailsWrapper) System.JSON.deserialize(json, FetchTechTagDetailsWrapper.class);
    }
    
    /*static testMethod void testParse() {
        String json = '{\"response\":[{\"patent_id\":\"6622364\",\"patent_number\":\"US5265562A1\",\"patent_family_id\":\"4911723\",\"patent_family_name\":\"07/919,916 US5265562A (5 US Patents)\",\"tech_tag_name\":\"Hardware_Automotive\",\"theory_of_relevance\":null,\"free_form_tags\":null},{\"patent_id\":\"5634912\",\"patent_number\":\"US6058904A1\",\"patent_family_id\":\"4911723\",\"patent_family_name\":\"07/919,916 US5265562A (5 US Patents)\",\"tech_tag_name\":\"Hardware_Automotive\",\"theory_of_relevance\":null,\"free_form_tags\":null},{\"patent_id\":\"5129638\",\"patent_number\":\"US6405704B2\",\"patent_family_id\":\"4911723\",\"patent_family_name\":\"07/919,916 US5265562A (5 US Patents)\",\"tech_tag_name\":\"Hardware_Automotive\",\"theory_of_relevance\":null,\"free_form_tags\":null}],\"count\":3,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":3,\"pages\":1}}';
        FetchTechTagDetailsWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}