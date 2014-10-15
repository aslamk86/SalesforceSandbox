@isTest
global class WebServiceCommUserSuccess implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        system.debug('@@req in mockwebservice'+req);
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        res.setBody('{"response":[{"patent_family_id":"203091","patent_family_name":"09/865,414 US6539884B1 (4 US Patents)","patent_id":"4377357","patent_number":"US6761123B2","company_name":"Volkswagen AG","licensee_id":"20618","expiry_date":"2013-12-27","analyst_notes":"CAR"}],"count":2,"pagination":{"previous":null,"next":null,"current":1,"per_page":10,"count":2,"pages":2}}');
        res.setStatusCode(200);
        system.debug('@@res in mockwebservice'+res);
        system.debug('@@response in mockwebservice'+res.getBody());
        return res;
    }
}