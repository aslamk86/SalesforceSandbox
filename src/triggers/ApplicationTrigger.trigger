/*
    Trigger : ApplicationTrigger
    Description : - Used to send the agreement for echoSign when the stauts of 
                  - Application changed to "Completed Application" 
    Created By : Prakash
    Created Date : Sep 24th,2014
*/
trigger ApplicationTrigger on Application__c (after update) {
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            if((Trigger.New[0].Status__c != Trigger.Old[0].Status__c) &&Trigger.New[0].Status__c =='Completed Application'){
              ApplicationTriggerHandler.afterUpdate(Trigger.new[0].Id);
        }
    } 
  }
}