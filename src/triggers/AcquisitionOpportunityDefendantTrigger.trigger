/***********************************************************************************
Trigger : AcquisitionOpportunityDefendantTrigger 
Description :  This Trigger is Used to update Acquisition opportunity Field (Free_Options_Used__c) 
                             if defendant status is Closed - Free Option Used;
Developed by : sudhir Kumar Jagetiya
Created Date :  February 18, 2012
************************************************************************************/
trigger AcquisitionOpportunityDefendantTrigger on Acquisition_Opportunity_Defendant__c (before insert, before update, after delete, after insert, after undelete, after update) {
    
    if(trigger.isBefore) {
        if(trigger.isInsert) {
            AcqOppDefendantManagement.beforeAcqOppDefendantInsert(Trigger.New);
        } 
        if(trigger.isUpdate) {
            AcqOppDefendantManagement.beforeAcqOppDefendantUpdate(Trigger.New);
        }
    } 
    
    if(trigger.isAfter) {
        //a Set for all acquisition opportunity Id (associate with acquisition opportunity defendant )
    Set<Id> acquisitionOppIds = new Set<Id>();
    //A set of defendant status
    set<String> acqOppdefendantStatus = new Set<String>{'Closed - Free Option Used'};
    //If trigger fire on Insert ,undelete or update
    If(Trigger.IsInsert ||Trigger.isUnDelete || Trigger.isUpdate){
        for(Acquisition_Opportunity_Defendant__c acqOppdefendant : Trigger.New){
            if((Trigger.isInsert || Trigger.isUnDelete || (Trigger.isUpdate && (acqOppdefendant.Acquisition_Opportunity__c != Trigger.oldMap.get(acqOppdefendant.Id).Acquisition_Opportunity__c || acqOppdefendant.Defendant_Status__c != Trigger.oldMap.get(acqOppdefendant.Id).Defendant_Status__c))) && acqOppdefendant.Acquisition_Opportunity__c !=null){
                acquisitionOppIds.add(acqOppdefendant.Acquisition_Opportunity__c);
            }
        }
    }
    //If trigger fire on Insert or update
    if(Trigger.IsDelete || Trigger.isUpdate){
        for(Acquisition_Opportunity_Defendant__c acqOppdefendant : Trigger.Old){
            if((Trigger.IsDelete || (Trigger.isUpdate && (acqOppdefendant.Acquisition_Opportunity__c != Trigger.newMap.get(acqOppdefendant.Id).Acquisition_Opportunity__c || acqOppdefendant.Defendant_Status__c != Trigger.newMap.get(acqOppdefendant.Id).Defendant_Status__c))) && acqOppdefendant.Acquisition_Opportunity__c !=null){
                acquisitionOppIds.add(acqOppdefendant.Acquisition_Opportunity__c);
            }
        }
    }
    //all records those will be excluded except in case of delete
    List<Acquisition_Opportunity_Defendant__c> listToExclude = Trigger.isDelete ? new List<Acquisition_Opportunity_Defendant__c>() : Trigger.New; 
    Map<Id,Acquisition_Opportunity__c> acqOppMap = new Map<Id,Acquisition_Opportunity__c>();
    for(Acquisition_Opportunity__c acqOpp :[Select Free_Options_Used__c, Free_Options_Remaining__c, Free_Options_Negotiated__c ,(Select Id From Acquisition_Opportunity_Defendants__r where Defendant_Status__c IN : acqOppdefendantStatus AND Id Not IN : listToExclude) From Acquisition_Opportunity__c where Id IN : acquisitionOppIds]){
        acqOppMap.put(acqOpp.Id,new Acquisition_Opportunity__c(Id = acqOpp.Id,Free_Options_Used__c = acqOpp.Acquisition_Opportunity_Defendants__r.size()));
    }
    
    if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete){
            for(Acquisition_Opportunity_Defendant__c acqOppdefendant : trigger.new){
                if(acqOppMap.containsKey(acqOppdefendant.Acquisition_Opportunity__c) && acqOppdefendantStatus.contains(acqOppdefendant.Defendant_Status__c))
                    acqOppMap.get(acqOppdefendant.Acquisition_Opportunity__c).Free_Options_Used__c += 1;
            }
        }   
    //Update all updated acquisition opportunity ;
    update acqOppMap.values();
    }
}