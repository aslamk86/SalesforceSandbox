/****************************************************
    Last updated 4/26/2013 by Hank.
    
    Business logic for triggers is contained in
    PatentManagement.cls
****************************************************/

trigger PatentTrigger on Patent__c (before update, after update, after insert) {
    
    system.debug('###PatentTrigger: Entering trigger.###');
    
    if (trigger.isBefore) {  
        if (trigger.isUpdate) { 
            PatentManagement.updateFields(Trigger.oldMap, trigger.new);
        }
    }
    
    if (trigger.isAfter) {  
        if (trigger.isUpdate) { 
            PatentManagement.processChanges_LeavingPatentFamilies(trigger.oldMap, trigger.newMap);
            PatentManagement.processChanges_EnteringPatentFamilies(trigger.oldMap, trigger.newMap);
            PatentManagement.rollupPatentFamilyAnnotations(trigger.oldMap, trigger.newMap);
        }
        if (trigger.isInsert) {
            PatentManagement.linkTechTags_AfterInsert(trigger.newMap);
            PatentManagement.rollupPatentFamilyAnnotations(trigger.oldMap, trigger.newMap);
        }
    }
    
    system.debug('###PatentTrigger: Exiting trigger.###');
    
}