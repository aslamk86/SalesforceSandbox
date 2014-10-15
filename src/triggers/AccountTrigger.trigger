/*
    Trigger : AccountTrigger
    Description : - Used to update RPX rate on Account ,if changes occur 
                  - Updates Opportunities related to Accounts
    Created By : Bharti(Offshore)
    Created Date : April 11th,2012
*/
trigger AccountTrigger on Account (after update, before insert, before update) {
    if(Trigger.isAfter) {
    	if(Trigger.isUpdate) {
    	AccountManagement.afterInsertUpdate(Trigger.newMap, Trigger.oldMap);
    	}
    } else if(Trigger.isBefore) {
    	if(Trigger.isInsert || Trigger.isUpdate) {
    		AccountManagement.beforeInsertUpdate(Trigger.new); 
    	}
    }
}