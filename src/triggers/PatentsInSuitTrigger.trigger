/****************************************************
    Built by Hank Ryan Thompson.
    Created 4/25/20013.
    Last updated 4/25/2013 by Hank.
    
    Business logic for triggers is contained in
    PatentsInSuitManagement.cls
****************************************************/

trigger PatentsInSuitTrigger on Patents_in_Suit__c (after delete, after insert) {
    
    system.debug('###PatentsInSuitTrigger: Entering trigger.###');
    
    if(trigger.isAfter) {  
        if(trigger.isInsert) { 
            PatentsInSuitManagement.afterPatentsInSuitInsert(Trigger.newMap);
        }
        if(trigger.isDelete){
            PatentsInSuitManagement.afterPatentsInSuitDelete(Trigger.oldMap);
        }
    }
    
    system.debug('###PatentsInSuitTrigger: Exiting trigger.###');
    
}