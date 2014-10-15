trigger OMAPatentTrigger on OMA_Patent__c (before insert, after delete, after insert, after update) {
    
    system.debug('###OMAPatentTrigger: Entering trigger.###');
    
    if(Trigger.isBefore) {
        if(trigger.isInsert){
            OMAPatentManagement.beforeOMAPatentInsert(Trigger.new);
        }
    }
    
    if(Trigger.isAfter) {  
        if(trigger.isInsert) { 
            OMAPatentManagement.afterOMAPatentInsert(Trigger.newMap);
        }
        if(trigger.isDelete){
            OMAPatentManagement.afterOMAPatentDelete(Trigger.oldMap);
        }
    }
    
    system.debug('###OMAPatentTrigger: Exiting trigger.###');
    
}