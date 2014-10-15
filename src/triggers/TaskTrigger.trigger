trigger TaskTrigger on Task (before insert, before update) {
if(Trigger.isBefore) {
      if(Trigger.isInsert || Trigger.isUpdate)
      {
       taskmanagement.beforeInsertUpdate(trigger.new);
      }//end if insert update
    }// end if before
}// end trigger