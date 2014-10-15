@RestResource(urlMapping='/getEchoSignUpdate')
global class EchoSignCallBackURL{
    @HttpGet
    global static void doGet() {
    
        RestContext.response.addHeader('Content-Type', 'text/plain');
        
        String name = RestContext.request.params.get('name');
        String api_Key = EchoSign_API_Settings__c.getInstance('APIKEY').Value__c;
        echosign_dev1__SIGN_Agreement__c  agmt = NULL;        
        List<echosign_dev1__SIGN_Agreement__c>  agmtList ;
        
        if(RestContext.request.params.containsKey('documentKey') && RestContext.request.params.get('documentKey') != '') {
            agmtList  = [Select Id,Name,Application__c,echosign_dev1__Document_Key__c from echosign_dev1__SIGN_Agreement__c where echosign_dev1__Document_Key__c=:RestContext.request.params.get('documentKey')];
        }
        if(agmtList.size() >0 ){
            //update Agreement Record with latest Event and Status values        
            System.debug(LoggingLevel.INFO, 'RestContext.request.params = ' + RestContext.request.params);
            agmt = agmtList.get(0);
            if(agmt!=NULL){         
                agmt.Current_Status__c = RestContext.request.params.get('status');
                agmt.Event__c = RestContext.request.params.get('eventType');
                if(RestContext.request.params.get('status') == 'SIGNED'){
                    agmt.echosign_dev1__Status__c = 'Signed';
                }
                update agmt;
                
              //Attaching retrieved Signed Document to the Application record
                if(RestContext.request.params.get('status') == 'SIGNED'){
                    //Retrieve Signed Document from EchoSign with invocation through SOAP API
                    EchoSignHelper.SignedDocumentToProcess(agmt.Id,agmt.Name,agmt.echosign_dev1__Document_Key__c);
                }
            }
        }
    }
}