public class SourceVerification {

    public List<Response> response{get; set;}
    public Integer count;

    public class Response {
        public String related_id;
        public Decimal percentage;
        public String account_type;
    }

    
    public static SourceVerification parse(String json) {
        return (SourceVerification) System.JSON.deserialize(json, SourceVerification.class);
    }
}