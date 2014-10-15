public class AcquisitionsCheatSheetController {
    
    public List<Acquisition_Opportunity__c> acquisitions{get;set;}
    public List<Product_or_Service__c> psList{get;set;}
    public String filter{get;set;}
    
    public AcquisitionsCheatSheetController(){
        acquisitions = new List<Acquisition_Opportunity__c>();
        psList = new List<Product_or_Service__c>();
        filter = ApexPages.currentPage().getParameters().get('filter');
        
        String id=ApexPages.currentPage().getParameters().get('id');
        if(id!=null){
            List<String> idList = new List<String>();
            for(String s : id.split(';')){
                idList.add(s);
            }
            String query = ' Select Id, Name, StageName__c,CreatedDate, Probability__c, CloseDate__c, Last_Significant_Update_by_Acq__c, ' 
              + ' Summary__c, RecordType.Name, Account__c, Primary_Market_Sector__c, Seller_claims_charts__c, Theories_of_Relevance__c, Patent_Portfolio_Summary__c'
              + ' From Acquisition_Opportunity__c'
              + ' Where id in :idList';
            acquisitions = Database.query(query);
            
            for(Acquisition_Opportunity__c acq : acquisitions){
                if(acq.Patent_Portfolio_Summary__c!=null){
                    acq.Patent_Portfolio_Summary__c = acq.Patent_Portfolio_Summary__c.replace('<div>','').replace('</div>','<br>');
                }
           }
        }
        
        if(acquisitions.size()==0){
            acquisitions.add(new Acquisition_Opportunity__c(StageName__c=''));
        }
        
        String psId=ApexPages.currentPage().getParameters().get('psId');
        if(psId!=null){
            List<String> psIdList = new List<String>();
            for(String s : psId.split(';')){
                psIdList.add(s);
            }
            String query = ' Select Id, Name from Product_or_Service__c Where id in :psIdList';
            psList = Database.query(query);
            
        }
        
    }
}