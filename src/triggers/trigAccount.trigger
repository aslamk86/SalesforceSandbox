trigger trigAccount on Account (after update,before delete) {

    List<Account> tobeUpdatedListOld = new List<Account>();
    List<Account> tobeUpdatedListNew = new List<Account>();
    Map<id,Account> tobeUpdatedMapOld = new Map<id,Account>();
    Map<id,Account> tobeUpdatedMapNew = new Map<id,Account>();
    
    if(trigger.IsAfter){        
        if(trigger.IsUpdate ){
            for(Account acc : Trigger.oldMap.values()){
            
                if(Trigger.newMap.get(acc.id).recordtypeid!=Trigger.OldMap.get(acc.id).recordtypeid){
                system.debug('@@in update of accnt');
                tobeUpdatedMapOld.put(acc.id,acc);
                tobeUpdatedListOld.add(acc);
                }
            }         
            for(Account acc : Trigger.newMap.values()){
                if(Trigger.newMap.get(acc.id).recordtypeid!=Trigger.OldMap.get(acc.id).recordtypeid){
                       tobeUpdatedMapNew.put(acc.id,acc);   
                       tobeUpdatedListNew.add(acc); 
                       }            
            }
            if(tobeUpdatedMapOld.size()>0)
            UpdateNPEAccnt.UpdateNPECount(tobeUpdatedMapOld ,tobeUpdatedMapNew,tobeUpdatedListOld,tobeUpdatedListNew,'update');            
        }
    }
    
    if(trigger.IsBefore){
        if(trigger.IsDelete){
            UpdateNPEAccnt.UpdateNPECount(trigger.OldMap,null,trigger.old,null,'delete');
        }
    }                     
    
}