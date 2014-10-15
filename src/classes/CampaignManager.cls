public class CampaignManager {
    
    public Account acc{get; set;}
    public List<CampaignLitWrapper.response> wrap {get; set;}
    public List<Defendant_History__c> defHistory {get; set;}
    public List<Defendant_History__c> existingDefendantHistory {get; set;}
    private Integer pageNumber;
                
    public CampaignManager(ApexPages.StandardController controller) {
        acc = (Account) controller.getRecord();
        pageNumber=1;
        existingDefendantHistory = [select id,campaign_name__c,Campaign_Id__c,Case_Name__c,
                                    File_date__c,Resolve_date__c,Parent_Plaintiff__c,Defendant_names__c,Exists__c
                                    from defendant_history__c where Account__c =:acc.id order by File_date__c asc];
    }
    
    public void fetchCampaigns(){
    
         Http h = new Http();
            
         // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
         HttpRequest req = new HttpRequest();
         req.setEndpoint(EcoSystemAPI__c.getValues('Campaign').Endpoint__c+''+acc.Entity_ID__c+'&page='+pageNumber+'&per_page=30');
         req.setMethod('GET');
         req.setHeader('Authorization', 'Token token="'+EcoSystemAPI__c.getValues('Campaign').Token__c+'"');
         req.setTimeout(120000);
         // Send the request, and return a response
         HttpResponse res = h.send(req);
         
         wrap = new List<CampaignLitWrapper.response>();
         defHistory = new List<Defendant_History__c>();
            try{
                wrap = CampaignLitWrapper.parse(res.getBody()).response;     
                if(wrap!=null && wrap.size()>0){                                                      
                    for(CampaignLitWrapper.response wrapTemp:wrap){
                           defHistory.add(new Defendant_History__c(
                                      Campaign_Id__c=wrapTemp.campaign_id,
                                      campaign_name__c=wrapTemp.campaign_name,
                                      Case_Name__c=wrapTemp.case_name,
                                      File_date__c=wrapTemp.file_date,
                                      Resolve_date__c=wrapTemp.resolve_date,
                                      Parent_Plaintiff__c = wrapTemp.plaintiff_parent,
                                      Defendant_names__c = wrapTemp.defendant_names,
                                      Account__c = acc.id,
                                      Exists__c = false
                                   ));                    
                    }
                }                
            }
            catch(System.CalloutException e){
                String error = e.getMessage();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
            }
        }              
        

public void addCampaignToSalesforce(){
    List<Defendant_History__c> defToBeInserted = new List<Defendant_History__c>();
    for(Defendant_History__c defTemp:defHistory){
        if(defTemp.Exists__c){
            for(Defendant_History__c defTempInner:existingDefendantHistory){
                if(defTemp.Campaign_Id__c==defTempInner.Campaign_Id__c){
                    defTemp.id=defTempInner.id;
                    break;
                }
            }
                defTemp.Exists__c=false;
                defToBeInserted.add(defTemp);
        }
    }
    
    upsert defToBeInserted;
    
    existingDefendantHistory = [select id,campaign_name__c,Campaign_Id__c,Case_Name__c,
                                    File_date__c,Resolve_date__c,Parent_Plaintiff__c,Defendant_names__c,Exists__c 
                                    from defendant_history__c where Account__c =:acc.id];
    
}        

public void removeFromSalesforce(){
    List<Defendant_History__c> defToBeRemoved = new List<Defendant_History__c>();
    for(Defendant_History__c defTemp:existingDefendantHistory){
        if(defTemp.Exists__c){
            defTemp.Exists__c=false;
            defToBeRemoved.add(defTemp);
        }
    }
    
    delete defToBeRemoved;
    
    existingDefendantHistory = [select id,campaign_name__c,Campaign_Id__c,Case_Name__c,
                                    File_date__c,Resolve_date__c,Parent_Plaintiff__c,Defendant_names__c,Exists__c 
                                    from defendant_history__c where Account__c =:acc.id];
}

public void saveEdits(){

    update existingDefendantHistory;
}
        
}