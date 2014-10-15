trigger LitigationPatentFamilyTrigger on Litigation_Patent_Family__c (after delete, after insert, after update, 
before delete, before insert, before update) {
  //;
  if(trigger.isBefore){
      if(trigger.isInsert){
        //LitigationPatentFamilyManagement.afterLitigationPatentFamilyInsert(Trigger.new);
      }
      if(trigger.isUpdate){
        //LitigationPatentFamilyManagement.afterLitigationPatentFamilyInsert (Trigger.new, Trigger.old);
      }
  }else{
      if(trigger.isInsert){ 
          LitigationPatentFamilyManagement.afterLitigationPatentFamilyInsert(Trigger.new);
      }
      if(trigger.isUpdate){
        LitigationPatentFamilyManagement.afterLitigationPatentFamilyUpdate (Trigger.new, Trigger.oldMap);
      }
      if(trigger.isDelete) {
      	LitigationPatentFamilyManagement.afterLitigationPatentFamilyDelete(Trigger.oldMap);
      }
  }
}