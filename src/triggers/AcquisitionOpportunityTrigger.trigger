/*
    Trigger : AcquisitionOpportunityTrigger
    Description : update Probability and Forecast Category Name automatically when record ll be insert and update
    Created By: Bharti Bhandari
    Last Modified Date : January 17,2012
*/
trigger AcquisitionOpportunityTrigger on Acquisition_Opportunity__c (before insert, before update,after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AcquisitionOpportunityManagement.updateProbability(Trigger.new);
        }else{
            AcquisitionOpportunityManagement.updateProbabilityOnUpdate(Trigger.newMap,Trigger.oldMap);
      }
    }else if(Trigger.isAfter && Trigger.isInsert){
        //under dev
        AcquisitionOpportunityManagement.performCloneOperation(Trigger.new);
    }
    
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        AcquisitionOpportunityManagement.afterUpdateAcquisitionOpportunity(Trigger.newMap, Trigger.oldMap);
    }
    
}