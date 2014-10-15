public class RelatedCompanyWrapper {

    public List<Response> response;
    public Integer count;

    public class Response {
        public Integer id{get; set;}
        public String parent_company_name{get; set;}
        public String parent_company{get; set;}
        public String relevant_company_name{get; set;}
        public String relevant_company{get; set;}
        public Integer overall_similarity{get; set;}
        public Integer litigation_similarity{get; set;}
        public Integer portfolio_similarity{get; set;}
        
        public Boolean IncludeInThisEcoSystem{get; set;}
        public Boolean PastEcoSystem{get; set;}
        public Boolean inThisDraft {get; set;}
    }

    
    public static RelatedCompanyWrapper parse(String json) {
        return (RelatedCompanyWrapper) System.JSON.deserialize(json, RelatedCompanyWrapper.class);
    }
    
    /*static testMethod void testParse() {
        String json = '{\"response\":[{\"id\":1,\"parent_company_name\":\"\",\"parent_company\":\"0014000000KaG2dAAF\",\"relevant_company_name\":\"\",\"relevant_company\":\"0014000000KaG4hAAF\",\"overall_similarity\":45,\"litigation_similarity\":5,\"portfolio_similarity\":22},{\"id\":2,\"parent_company_name\":\"\",\"parent_company\":\"0014000000KaG2dAAF\",\"relevant_company_name\":\"\",\"relevant_company\":\"0014000000KaG25AAF\",\"overall_similarity\":40,\"litigation_similarity\":0,\"portfolio_similarity\":17}],\"count\":2}';
        RelatedCompanyWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
    }