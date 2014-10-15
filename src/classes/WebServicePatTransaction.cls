@isTest
global class WebServicePatTransaction implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        res.setBody('{"response":[{"patnum":"US6712628B2","patent_number":"6712628","transaction_id":"101336","transaction_date":"2013-02-26","seller_entity":"Flextronics International Limited","seller_type":"Operating Company","buyer_entity":"DRNC Holdings Incorporated","buyer_type":"NPE","purchase_price":null,"assets_count":87}],"count":2,"pagination":{"previous":null,"next":null,"current":1,"per_page":10,"count":2,"pages":1}}');
        res.setStatusCode(200);
        return res;
    }
}