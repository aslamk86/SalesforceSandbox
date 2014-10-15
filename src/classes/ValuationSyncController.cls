/**********************************************************

Controller for page that fetches all the Valuation records
and syncs the most recent one with the acquisition.

***********************************************************/

public class ValuationSyncController {
    
    Acquisition_Opportunity__c acq{get; set;}
    

    public ValuationSyncController(ApexPages.StandardController controller) {
        acq = (Acquisition_Opportunity__c)controller.getRecord();
    }
    
    public PageReference SyncValuations(){
        
        List<Valuation_Tracking__c> valuations = [select id,Date_Received__c,Valuation_in_000s__c from Valuation_Tracking__c
                                                  where Acquisition__c =: acq.id and RecordType.DeveloperName = 'Guidance'];
        
        Date maxDate;
        
        for(Valuation_Tracking__c vTemp:valuations){
            if(maxDate==null)
                maxDate = vTemp.Date_Received__c;
            
            if(maxDate<=vTemp.Date_Received__c){
                System.debug('Inside if');
                acq.Most_Recent_Valuation_Tracking__c = vTemp.id;
                acq.Amount_for_Pipeline__c = vTemp.Valuation_in_000s__c;
                maxDate = vTemp.Date_Received__c;
            }
        }
        
        update acq;
        
        return new PageReference('/'+acq.id);
    }

}