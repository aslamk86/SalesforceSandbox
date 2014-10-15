/*************************************************************************************************
* Name          :    trigTask
* Description   :    Trigger on Task Object.
                     Used to invoke taskHankder class to copy the title field from associated name object onto task object
* Author        :    Vamsi Chinnam

Modification Log
----------------
Date             Version    Developer                Comments
---------------------------------------------------------------------------------------------------
07-Jul-2014          1.0     Vamsi Chinnam           Created
****************************************************************************************************/
trigger trigTask on Task (after insert,after update) {

List<task> taskList = new List<task>();
system.debug('@@'+taskHandler.firstRun);
    if(trigger.IsAfter && taskHandler.firstRun){
        if(trigger.IsInsert || trigger.IsUpdate){
            taskHandler.firstRun =false;
            for(task t:trigger.new){
                if(trigger.newMap.get(t.id).whoid!=null && trigger.newMap.get(t.id).recordtypeid==label.TaskAORRecTypeID){
                    taskList.add(t);
                }
            }
            
            if(taskList.size()>0){
                taskHandler.updateTitleOnTask(taskList);
            }
            
        }
    }
}