public class CoDefendantWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        //public sObject previous{get; set;}
        public Integer next{get; set;}
        public Integer current{get; set;}
        public Integer per_page{get; set;}
        public Integer count{get; set;}
        public Integer pages{get; set;}
    }

    public class Response {
        public String company_name{get; set;}
        public Integer ent_id{get; set;}
        public String salesforce_id{get; set;}
        public String co_defendant_name{get; set;}
        public Integer ent_id_codef{get; set;}
        public String salesforce_id_codef{get; set;}
        public Integer num_overlapping_camps{get; set;}
        public Decimal percent_sim{get; set;}
        public String portal_search{get; set;}
        public String primary_market_sector {get; set;}
        public Boolean IncludeInThisEcoSystem{get; set;}
        public Boolean PastEcoSystem{get; set;}
        public Boolean InThisDraft{get; set;}
    }
    
    
    public static CoDefendantWrapper parse(String jsonStr) {
        return (CoDefendantWrapper) System.JSON.deserialize(jsonStr, CoDefendantWrapper.class);
    }
}