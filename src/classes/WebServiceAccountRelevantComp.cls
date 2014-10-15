@isTest
global class WebServiceAccountRelevantComp implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
       system.debug('@@req in mockwebservice'+req);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        res.setBody('{"{"response":[{"product_name":"Software_Instant Messaging (IM)","acquisition_id":"a0540000008GCh8AAG","acquisition_name":"Baugh - Acq","acquisition_type":"OMA","created_date":"2009-06-05 18:23:53","stage":"Closed Won","seller_broker_name":"Acorn Technologies Inc.","last_stage_change":null}],"count":2,"pagination":{"previous":null,"next":null,"current":1,"per_page":10,"count":2,"pages":2}}');
        res.setStatusCode(200);
        system.debug('@@res in mockwebservice'+res);
         system.debug('@@response in mockwebservice'+res.getBody());
        return res;        
    }
}