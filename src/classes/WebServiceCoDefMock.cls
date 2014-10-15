@isTest
global class WebServiceCoDefMock implements HttpCalloutMock {
   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');        
        res.setBody('{"response":[{"company_name":"Cisco Systems Incorporated","percentage":"0","account_type":"manual","ent_id":65806,"salesforce_id":"0014000000KaG34AAF","co_defendant_name":"Adimos Incorporated","ent_id_codef":50591,"salesforce_id_codef":"0014000000fkYjHAAU","relevant_company":"0014000000fkYjHAAU","num_overlapping_camps":1,"percent_sim":"1.2","portal_search":"https://portal.rpxcorp.com/advanced_search/search_litigations#utf8=%E2%9C%93&searchq=defendant_all%3A(%22Cisco+Systems+Incorporated%22+or+%22Adimos+Incorporated%22)&grouped=true","primary_market_sector":"Networking"}]}');
        res.setStatusCode(200);
        return res;
    }
}