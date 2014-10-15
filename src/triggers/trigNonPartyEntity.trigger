trigger trigNonPartyEntity on Non_Party_Entity__c (after insert,after update,after delete) {
public static boolean trigRec =true;
    NonPartyEntityHandler nph= new NonPartyEntityHandler();
    List<Non_Party_Entity__c> tobeInsertedList = new list<Non_Party_Entity__c>();
    List<Non_Party_Entity__c> tobeDeletedList = new list<Non_Party_Entity__c>();
    if(Trigger.IsAfter){  
        if(trigRec){
            trigRec=false;
            if(Trigger.IsInsert){
                for(Non_Party_Entity__c npe : Trigger.newMap.values()){
                    if(Trigger.newMap.get(npe.id).Acquisition_opportunity__c!=null){
                        tobeInsertedList.add(npe);                    
                    }
                }   
                if(tobeInsertedList.size()>0)
                nph.UpdateCountOnAcquisition(tobeInsertedList,null);            
            }
                
            if(Trigger.IsUpdate){
                for(Non_Party_Entity__c npe : Trigger.newMap.values()){                    
                       nph.UpdateCountOnAcquisition(trigger.new,trigger.old);                 
                }
            } 
            
            if(Trigger.IsDelete) {
                for(Non_Party_Entity__c npe : Trigger.oldMap.values()){
                    if(Trigger.oldMap.get(npe.id).Acquisition_opportunity__c!=null){
                        tobeDeletedList.add(npe);                   
                    }
                }
                if(tobeDeletedList.size()>0)
                nph.UpdateCountOnAcquisition(null,tobeDeletedList);                   
            }
        }
    }
    
}