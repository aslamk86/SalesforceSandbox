@isTest
global class WebServiceAccTransaction implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        res.setBody('{"response":[{"patnum":"US7428581B2","patent_number":"7428581","transaction_id":"101105","transaction_date":"2010-06-28","seller_entity":"Summit Data Systems LLC","seller_type":"NPE","buyer_entity":"RPX Corporation","buyer_type":"RPX","purchase_price":"2600000.00","assets_count":31,"overlap":null,"similarity":null,"deal_match":null}],"count":4,"pagination":{"previous":null,"next":null,"current":1,"per_page":10,"count":4,"pages":1}}');
        res.setStatusCode(200);
        return res;
    }
}