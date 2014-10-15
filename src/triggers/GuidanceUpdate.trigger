/*****************************************************************

Description : Trigger to update the rate on Acquisition 
    based on the value in the Valuation record.
    It also updates the NPE on the Acquisition based on the 
    Bidder type on the Valuation record of type Bid Notifications

*****************************************************************/


trigger GuidanceUpdate on Valuation_Tracking__c (after insert,after update) {
    
    List<Id> valuationToBeUpdated = new List<Id>();
    
    List<Acquisition_Opportunity__c> listAcq = new List<Acquisition_Opportunity__c>();
    
    Map<Id,RecordType> rt = new Map<Id,RecordType>([select Id,Name from RecordType where (Name = 'Guidance' or Name ='Bid Notifications') and SobjectType = 'Valuation_Tracking__c']);    
    
    for(Valuation_Tracking__c vt:Trigger.new){    
           valuationToBeUpdated.add(vt.Acquisition__c);
    }
        
    if(valuationToBeUpdated.size()>0){
        Map<Id,Acquisition_Opportunity__c> acqList = new Map<Id,Acquisition_Opportunity__c>([select id, Amount_for_Pipeline__c,NPE_Offer__c,Most_Recent_Valuation_Tracking__c,Valuation_Date__c   from Acquisition_opportunity__c where id in:valuationToBeUpdated]);           
        for(Valuation_Tracking__c vt:Trigger.new){
                Acquisition_Opportunity__c tempAcq = acqList.get(vt.Acquisition__c);
                
                if(rt.get(vt.RecordTypeId).Name=='Guidance'){
                    if(tempAcq.Most_Recent_Valuation_Tracking__c!=null && tempAcq.Valuation_Date__c <= vt.Date_Received__c){
                        tempAcq.Amount_for_Pipeline__c = vt.Valuation_in_000s__c;
                        tempAcq.Most_Recent_Valuation_Tracking__c = vt.id;
                    }               
                    else if(tempAcq.Most_Recent_Valuation_Tracking__c==null){
                        tempAcq.Amount_for_Pipeline__c = vt.Valuation_in_000s__c;
                        tempAcq.Most_Recent_Valuation_Tracking__c = vt.id;
                    }
                }
                else if(rt.get(vt.RecordTypeId).Name=='Bid Notifications'){
                    if(vt.Bidder_Type__c == 'NPE' && tempAcq.NPE_Offer__c == false){
                        tempAcq.NPE_Offer__c = true;
                    }
                }
                if(tempAcq.id!=null)
                    listAcq.add(tempAcq);        
        }
        if(listAcq.size()>0)
            update listAcq;    
    }

}