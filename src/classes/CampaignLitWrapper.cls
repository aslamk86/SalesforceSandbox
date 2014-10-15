public class CampaignLitWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        //public Object previous;
        public Integer next {get; set;}
        public Integer current {get; set;}
        public Integer per_page {get; set;}
        public Integer count {get; set;}
        public Integer pages {get; set;}
    }

    public class Response {
        public Integer ent_id {get; set;}
        public String ent_name {get; set;}
        public String salesforce_id {get; set;}
        public Integer campaign_id {get; set;}
        public String campaign_name {get; set;}
        public String defendant_names {get; set;}
        public String file_date {get; set;}
        public String resolve_date {get; set;}
        public String case_type {get; set;}
        public String case_name {get; set;}
        public String plaintiff_parent {get; set;}
        
    }

    
    public static CampaignLitWrapper parse(String json) {
        return (CampaignLitWrapper) System.JSON.deserialize(json, CampaignLitWrapper.class);
    }
}