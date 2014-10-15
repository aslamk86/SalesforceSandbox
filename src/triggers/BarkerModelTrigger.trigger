/*
    Trigger : BarkerModelTrigger
    Description : - Used to update the "Member Credit used for pending deals" on Account ,if changes occur in Credit Toogle
                  - Default insert of Barker Model Details - all defendants for all litigations related to that Litigation Acquisition Opportunity when the new Barker Model is created
    Created By : Bharti(Offshore)
    Created Date : January 20th,2012
*/
trigger BarkerModelTrigger on BarkerModel__c (after insert , after update,before delete,after undelete) {
    if(Trigger.isInsert) {
        BarkerModelmanagement.createDefaultCalculations(Trigger.new);
    }
    else {
        BarkerModelmanagement.updateMemberCreditOnAccount(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
    	BarkerModelmanagement.copyTarget_MarginOfBarkerModelAccount(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isBefore && Trigger.isDelete) {
        BarkerModelmanagement.beforeDeleteBarkerModel(Trigger.old);
    }
}