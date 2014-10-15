/**
Class Name: BarkerModelCalculationTrigger
Description:  Used To update “Member Credit used for pending deals” on Account 
Created By:   Bharti Bhandari
Last Modification Date: january 17 , 2012

**/

trigger BarkerModelCalculationTrigger on BarkerModelCalculation__c (after delete, after insert, after undelete, 
after update,before insert,before update, before Delete) {
    
    if(Trigger.isBefore)
        BarkerModelCalculationManagement.beforeInsertUpdateDelete(Trigger.new, Trigger.oldMap);
    else
        BarkerModelCalculationManagement.afterInsertUpdateDelete(Trigger.newMap, Trigger.oldMap);
        
  if(Trigger.isBefore && Trigger.isDelete) {
    BarkerModelCalculationManagement.beforeBarkerModelCalculationDelete(Trigger.old); 
  }

}