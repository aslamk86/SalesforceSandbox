/*
    Trigger :DefendantTrigger
    Description :Used To insert or delete Acquisition_Opportunity_Defendant__c on event(Insert ,Delete) of Defendant.
    Created By : Bharti (Appirio Offshore)
    Last Modified date : Feb 7,2012
                                         : APR 12,2012 (Added logic to populate Litigation Rollup Fields on Account)
*/
trigger DefendantTrigger on Defendant__c (after insert,before delete, after delete, after update) {
    
    
    Set<String> stages = new Set<String>{'Closed Lost','Closed Won'};
    //Code execute On insert of defendant.
    if(Trigger.isAfter && Trigger.isInsert){
        Set<Id> litigitionId = new Set<Id>();
        for(Defendant__c defendant :Trigger.new){
            litigitionId.add(defendant.Litigation_ID__c);
        }
        //Acquisition Opportunity Defendant List To be insert
        List<Acquisition_Opportunity_Defendant__c> listAOD = new List<Acquisition_Opportunity_Defendant__c>();
        // 06122012-JYW for SFDC-875:Commenting out this line which excludes AODs of certain stages and replacing with one that does not look at AOD stage
        //List<Opportunity_Litigation__c> OppLitigitionList = [Select Litigation__c, Acquisition_Opportunity__c From Opportunity_Litigation__c where Acquisition_Opportunity__r.StageName__c Not IN : stages And Litigation__c IN :litigitionId];     
        List<Opportunity_Litigation__c> OppLitigitionList = [Select Litigation__c, Acquisition_Opportunity__c From Opportunity_Litigation__c where Litigation__c IN :litigitionId];     
        
        Map<Id,Opportunity_Litigation__c> mapLitigition = new Map<Id,Opportunity_Litigation__c>();
        for(Opportunity_Litigation__c oppLitigition :OppLitigitionList){
            if(!mapLitigition.containsKey(oppLitigition.Litigation__c)){
                mapLitigition.put(oppLitigition.Litigation__c,oppLitigition);
            }
        }
    for(Defendant__c defendant :Trigger.new){
            if(mapLitigition.containsKey(defendant.Litigation_ID__c)){
                //Create a Acquisition Opportunity Defendant record;
            Acquisition_Opportunity_Defendant__c objectAOD = new Acquisition_Opportunity_Defendant__c();
            objectAOD.Acquisition_Opportunity__c = mapLitigition.get(defendant.Litigation_ID__c).Acquisition_Opportunity__c;
            objectAOD.Defendant__c = defendant.Id;
            objectAOD.Defendant_Status__c = 'Open';
            listAOD.add(objectAOD);
            }
    }
    //Insert Acquisition Opportunity Defendant List
    insert listAOD;
    
    }else if(Trigger.isBefore && Trigger.isDelete){
        //Code execute on delete of defendant
    delete [Select Id From Acquisition_Opportunity_Defendant__c where Defendant__c IN :Trigger.old];
    }

// --- START NO LONGER NEEDED AUG 09, 2012-----------------------------------------------
//
// Martin Sieler: no longer needed! New functionality for Litigation Count on Accounts
//
/*

    //Added by Neeraj 04/12
    if(Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            //Update Litigation Roll Up Fields on Account
        DefendantManagement.updateLitRollupFieldsOnAccount(Trigger.New);
        }
        if(Trigger.isDelete) {
            DefendantManagement.updateLitRollupFieldsOnAccount(Trigger.old);
        }
    }

*/    
// --- END NO LONGER NEEDED -------------------------------------------------------------

}