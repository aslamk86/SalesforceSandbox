public class TDRelatedAcqsWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        //public Object previous{get;set;}
        public integer next{get;set;}
        public Integer current{get;set;}
        public Integer per_page{get;set;}
        public Integer count{get;set;}
        public Integer pages{get;set;}
    }

    public class Response {
        public String acq_name{get;set;}
        public String acquisition_id{get;set;}
    }

    
    public static TDRelatedAcqsWrapper parse(String json) {
        return (TDRelatedAcqsWrapper) System.JSON.deserialize(json, TDRelatedAcqsWrapper.class);
    }
    
  /*  static testMethod void testParse() {
        String json = '{\"response\":[{\"acq_name\":\"Samplify Measurement - OMA\",\"acquisition_id\":\"a054000000AxilxAAB\"},{\"acq_name\":\"Samplify Data Converter - OMA\",\"acquisition_id\":\"a054000000Axik0AAB\"},{\"acq_name\":\"Samplify APAX - OMA\",\"acquisition_id\":\"a054000000BlpSWAAZ\"},{\"acq_name\":\"Samplify Port Concentrator - OMA\",\"acquisition_id\":\"a054000000BWuWVAA1\"}],\"count\":4,\"pagination\":{\"previous\":null,\"next\":null,\"current\":1,\"per_page\":10,\"count\":4,\"pages\":1}}';
        TDRelatedAcqsWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}