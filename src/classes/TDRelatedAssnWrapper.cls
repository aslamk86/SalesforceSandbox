public class TDRelatedAssnWrapper {

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
        public Integer assignment_id{get;set;}
        public Integer frame_number{get;set;}
        public String reel_frame{get;set;}
        public Integer reel_number{get;set;}
        public String time_added{get;set;}
        public String transaction_id{get;set;}
    }

    
    public static TDRelatedAssnWrapper parse(String json) {
        return (TDRelatedAssnWrapper) System.JSON.deserialize(json, TDRelatedAssnWrapper.class);
    }
    
    /*static testMethod void testParse() {
        String json = '{\"response\":[{\"assignment_id\":44453827,\"frame_number\":621,\"reel_frame\":\"32827/621\",\"reel_number\":32827,\"time_added\":\"0001-01-01T00:00:00Z\",\"transaction_id\":\"101668\"},{\"assignment_id\":44453850,\"frame_number\":614,\"reel_frame\":\"32829/614\",\"reel_number\":32829,\"time_added\":\"0001-01-01T00:00:00Z\",\"transaction_id\":\"101668\"}],\"count\":2,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":2,\"pages\":1}}';
        TDRelatedAssnWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}