/* Trigger mainly updates a field on Acquisition based on the number of documents in Confidentiality Review */

Trigger ContentVersionAfter on ContentVersion (after insert, after update) {

    System.debug('##Entered Trigger');
    List<Id> acqList= new List<Id>();
    List<Acquisition_Opportunity__c> acqOpptyForUpdate =  new List<Acquisition_Opportunity__c>();
    Map<Id,Integer> numberInConfidentialityReview = new Map<Id,Integer>();
    Map<Id,Integer> numberBeyondConfidentialityReview = new Map<Id,Integer>();
    Map<Id,Integer> numberBeforeConfidentialityReview = new Map<Id,Integer>();
    Map<Id,Integer> numberTotalDocs = new Map<Id,Integer>();

    for(ContentVersion cvListTemp:Trigger.New){
        if(cvListTemp.Acquisition__c!=null)
            acqList.add(cvListTemp.Acquisition__c); //List of Acquistion Ids
    }
    List<ContentVersion> getAllContentForTheAcqs = [SELECT ID,Review_Status__c,Acquisition__c from contentversion where Acquisition__c in: acqList];
    System.debug('##List size '+getAllContentForTheAcqs.size());
    for(ContentVersion cvListTemp:getAllContentForTheAcqs){
        if(cvListTemp.Review_Status__c == 'Confidentiality Review'){
            if(numberInConfidentialityReview.get(cvListTemp.Acquisition__c)==null)
                numberInConfidentialityReview.put(cvListTemp.Acquisition__c, 1);
            else numberInConfidentialityReview.put(cvListTemp.Acquisition__c, numberInConfidentialityReview.get(cvListTemp.Acquisition__c) + 1);
        }
        else if(cvListTemp.Review_Status__c == 'Publication Denied - Confidentiality Review' || 
                cvListTemp.Review_Status__c == 'Editorial Review' ||
                cvListTemp.Review_Status__c == 'Publication Denied' ||
                cvListTemp.Review_Status__c == 'Publication Approved' ||
                cvListTemp.Review_Status__c == 'Publication Denied - Editorial Review'){
            if(numberBeyondConfidentialityReview.get(cvListTemp.Acquisition__c)==null)
                numberBeyondConfidentialityReview.put(cvListTemp.Acquisition__c, 1);
            else numberBeyondConfidentialityReview.put(cvListTemp.Acquisition__c, numberBeyondConfidentialityReview.get(cvListTemp.Acquisition__c) + 1);
        }
        else if(cvListTemp.Review_Status__c == 'Publication Denied - Primary Review' || cvListTemp.Review_Status__c == 'Not Submitted'){
            if(numberBeforeConfidentialityReview.get(cvListTemp.Acquisition__c)==null)
                numberBeforeConfidentialityReview.put(cvListTemp.Acquisition__c, 1);
            else numberBeforeConfidentialityReview.put(cvListTemp.Acquisition__c, numberBeforeConfidentialityReview.get(cvListTemp.Acquisition__c) + 1);
        }
           
        if(numberTotalDocs.get(cvListTemp.Acquisition__c)==null)
            numberTotalDocs.put(cvListTemp.Acquisition__c, 1);
        else numberTotalDocs.put(cvListTemp.Acquisition__c, numberTotalDocs.get(cvListTemp.Acquisition__c) + 1);
        
    }
    System.debug('##Conf Rev List size '+numberInConfidentialityReview.size());
    
    for(Id AcqId:numberTotalDocs.keySet()){
        System.debug('##Total : '+numberTotalDocs.get(AcqId));
        System.debug('##Number in Conf Review : '+numberInConfidentialityReview.get(AcqId));
        System.debug('##Number beyond Conf Review: '+numberBeyondConfidentialityReview.get(AcqId));
        Acquisition_Opportunity__c acqTemp = new Acquisition_Opportunity__c(Id = AcqId);
        Integer numberInConfReview = 0;
        Integer numberBeforeConfReview = 0;
        if(numberInConfidentialityReview.get(AcqId)!=null)
            numberInConfReview = numberInConfidentialityReview.get(AcqId);
        if(numberBeforeConfidentialityReview.get(AcqId)!=null)
            numberBeforeConfReview = numberBeforeConfidentialityReview.get(AcqId);
            
        if(numberInConfidentialityReview.get(AcqId) == null || numberInConfidentialityReview.get(AcqId) == 0)
            acqTemp.Color_Code__c='G';                   
        else if(numberTotalDocs.get(AcqId) == numberInConfReview + numberBeforeConfReview )
            acqTemp.Color_Code__c='R';
        else acqTemp.Color_Code__c='Y';
            
        acqOpptyForUpdate.add(acqTemp);
        
    }  
    if(acqOpptyForUpdate.size()>0)
        update acqOpptyForUpdate;
}