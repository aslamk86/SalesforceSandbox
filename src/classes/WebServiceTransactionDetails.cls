@isTest
global class WebServiceTransactionDetails implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        res.setBody('{"response":[{"patnum":"US7541950B2","patent_number":"7541950","transaction_id":"101668","transaction_date":"2014-04-02","seller_entity":null,"seller_type":"Operating Company","buyer_entity":"Altera Corporation","buyer_type":"Operating Company","purchase_price":null,"assets_count":34,"related_opportunities":[{"acq_name":"Samplify Measurement - OMA","acquisition_id":"a054000000AxilxAAB"},{"acq_name":"Samplify Data Converter - OMA","acquisition_id":"a054000000Axik0AAB"},{"acq_name":"Samplify APAX - OMA","acquisition_id":"a054000000BlpSWAAZ"},{"acq_name":"Samplify Port Concentrator - OMA","acquisition_id":"a054000000BWuWVAA1"}],"related_patents":["US7541950B2","US7642939B2","US7973682B2","US7893852B2","US7071852B1","US7486205B2","US7088276B1","US7394410B1","US7649484B1","US7009533B1","US7876252B1","US7650249B2","US7522074B2","US7292164B1","US7477999B2","US7558685B2","US7796078B2","US8301803B2","US7791508B2","US5839100A1"],"related_assignments":[{"assignment_id":44453850,"frame_number":614,"reel_frame":"32829/614","reel_number":32829,"time_added":"0001-01-01T00:00:00Z","transaction_id":"101668"},{"assignment_id":44453827,"frame_number":621,"reel_frame":"32827/621","reel_number":32827,"time_added":"0001-01-01T00:00:00Z","transaction_id":"101668"}]}],"count":1,"pagination":{"previous":null,"next":null,"current":1,"per_page":10,"count":1,"pages":1}}');       
        res.setStatusCode(200);
        return res;
    }
}