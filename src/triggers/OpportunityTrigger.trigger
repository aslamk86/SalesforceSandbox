trigger OpportunityTrigger on Opportunity (after insert, after update, before insert, 
before update) {
  
  if(trigger.isAfter){ 
  	if(trigger.isInsert){
      OpportunityManagement.afterOpportunityInsert(Trigger.new);
    }
    if(trigger.isUpdate){
      OpportunityManagement.afterOpportunityUpdate (Trigger.newMap, Trigger.oldMap);
    }
  }
  
	//===START SFDC-1181 - Added by Tu Dao===
	if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
	    AutoFollowUtils.updateAutoFollowOpps(Trigger.new);
	}
	//===END SFDC-1181 - Added by Tu Dao===
  
}