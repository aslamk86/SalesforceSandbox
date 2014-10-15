public class TDRelatedPatentsWrapper {

    public List<String> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
        //public Object previous;
        public Integer next{get;set;}
        public Integer current{get;set;}
        public Integer per_page{get;set;}
        public Integer count{get;set;}
        public Integer pages{get;set;}
    }

    
    public static TDRelatedPatentsWrapper parse(String json) {
        return (TDRelatedPatentsWrapper) System.JSON.deserialize(json, TDRelatedPatentsWrapper.class);
    }
    
  /*  static testMethod void testParse() {
        String json = '{\"response\":[\"US7541950B2\",\"US7642939B2\",\"US7973682B2\",\"US7893852B2\",\"US7071852B1\",\"US7486205B2\",\"US7088276B1\",\"US7394410B1\",\"US7649484B1\",\"US7009533B1\"],\"count\":10,\"pagination\":{\"previous\":null,\"next\":2,\"current\":1,\"per_page\":10,\"count\":20,\"pages\":2}}';
        TDRelatedPatentsWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}