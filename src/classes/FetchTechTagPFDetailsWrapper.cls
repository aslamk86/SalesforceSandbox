public class FetchTechTagPFDetailsWrapper {

    public List<Response> response;
    public Integer count;
    public Pagination pagination;

    public class Pagination {
       // public Object previous{get;set;}
        public Integer next{get;set;}
        public Integer current{get;set;}
        public Integer per_page{get;set;}
        public Integer count{get;set;}
        public Integer pages{get;set;}
    }

    public class Response {
        public String patent_family_name{get;set;}
        public String patent_number{get;set;}
        public String theory_of_relevance{get;set;}
        public String free_form_tags{get;set;}
        public Integer tier{get;set;}
    }

    
    public static FetchTechTagPFDetailsWrapper parse(String json) {
        return (FetchTechTagPFDetailsWrapper) System.JSON.deserialize(json, FetchTechTagPFDetailsWrapper.class);
    }
    
   /* static testMethod void testParse() {
        String json = '{\"response\":[{\"patent_family_name\":\"09/851,006 US6732103B1 (1 US Patent)\",\"patent_number\":\"US6732103B1\",\"theory_of_relevance\":\"invitation software\",\"free_form_tags\":\"\",\"tier\":1},{\"patent_family_name\":\"11/821,771 US7941092B2 (15 US Patents)\",\"patent_number\":\"US8285196B2\",\"theory_of_relevance\":\"online surveys for mobile devices\",\"free_form_tags\":\"\",\"tier\":1},{\"patent_family_name\":\"12/024,764 US7698425B2 (5 US Patents)\",\"patent_number\":\"US8005970B2\",\"theory_of_relevance\":\"\",\"free_form_tags\":\"\",\"tier\":1},{\"patent_family_name\":\"12/024,764 US7698425B2 (5 US Patents)\",\"patent_number\":\"US7698425B2\",\"theory_of_relevance\":\"\",\"free_form_tags\":\"\",\"tier\":1},{\"patent_family_name\":\"12/024,764 US7698425B2 (5 US Patents)\",\"patent_number\":\"US7747746B2\",\"theory_of_relevance\":\"\",\"free_form_tags\":\"\",\"tier\":1},{\"patent_family_name\":\"12/024,764 US7698425B2 (5 US Patents)\",\"patent_number\":\"US7698426B2\",\"theory_of_relevance\":\"\",\"free_form_tags\":\"\",\"tier\":1},{\"patent_family_name\":\"12/024,764 US7698425B2 (5 US Patents)\",\"patent_number\":\"US7840690B2\",\"theory_of_relevance\":\"\",\"free_form_tags\":\"\",\"tier\":1},{\"patent_family_name\":\"12/991,233 US8417941B2 (1 US Patent)\",\"patent_number\":\"US8417941B2\",\"theory_of_relevance\":\"\",\"free_form_tags\":\"\",\"tier\":2},{\"patent_family_name\":\"09/865,414 US6539884B1 (4 US Patents)\",\"patent_number\":\"US6761123B2\",\"theory_of_relevance\":\"This is a PB edit for TT TOR made at 6:45PM 12-17 for US6761123B2\\nSoftware_Web Hosting \\n\\nNL\\n\\n\\nNL*2\",\"free_form_tags\":\"This is a PB edit for TT FFT made at 6:45PM 12-17 for US6761123B2\\nSoftware_Web Hosting \\n\\nNL\\n\\n\\nNL*2\",\"tier\":2},{\"patent_family_name\":\"10/838,471 US7158181B2 (3 US Patents)\",\"patent_number\":\"US7158181B2\",\"theory_of_relevance\":\"This is a PB edit for TT TOR for Patent US7158181B2 made at 6:53PM 12-17 \\nSoftware_Web Hosting \\n\\nNL\\n\\n\\nNL*2\",\"free_form_tags\":\"This is a PB edit for TT FFT for Patent US7158181B2 made at 6:53PM 12-17 \\nSoftware_Web Hosting \\n\\nNL\\n\\n\\nNL*2\",\"tier\":1}],\"count\":10,\"pagination\":{\"previous\":null,\"next\":2,\"current\":1,\"per_page\":10,\"count\":92,\"pages\":10}}';
        FetchTechTagPFDetailsWrapper obj = parse(json);
        System.assert(obj != null);
    }*/
}