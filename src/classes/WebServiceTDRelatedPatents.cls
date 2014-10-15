@isTest
global class WebServiceTDRelatedPatents implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        res.setBody('{"response":["US6321281B1","US6697054B1","US6934850B2","US6907077B2","US6691189B2","US5493345A1","US6263305B1","US6898424B2","US7254123B2","US6226740B1"],"count":10,"pagination":{"previous":null,"next":2,"current":1,"per_page":10,"count":31,"pages":4}}');       
        res.setStatusCode(200);
        return res;
    }
}