public class UpdateNPEAccnt {
    public static boolean prevRecurs = true;
    public static List<Non_Party_Entity__c> NPEList;
    public static List<Acquisition_Opportunity__c> acqList;
    public static void UpdateNPECount(Map<id,Account>OldAccntMap,Map<id,Account>NewAccntMap,List<Account>OldAccntList,List<Account>NewAccntList,string event ){
        
        if(prevRecurs ==true){
            if(!test.IsRunningtest())
            prevRecurs =false; 
            Set<id> AccntIds = new Set<Id>();
            for(Account a:OldAccntList ){
               AccntIds.add(a.id);
            }
            system.debug('@@AccntIds'+AccntIds);
            NPEList = new List<Non_Party_Entity__c>();
            NPEList =[select id,Account__c,Acquisition_Opportunity__c from Non_Party_Entity__c where Account__c in:AccntIds];
            system.debug('@@NPEList'+NPEList);
            Map<string,Integer>CurrentTotalCountMap = new Map<string,Integer>();
            Map<string,Integer>CurrentMembCountMap = new Map<string,Integer>();
            Map<string,Integer>CurrentProsCountMap = new Map<string,Integer>();
            Map<string,Integer>CurrentOtherCountMap = new Map<string,Integer>();
        
            Map<Id,String> AccntRTypeMap = new Map<Id,String>();
            Map<Id,String> OldAccntRTypeMap = new Map<Id,String>();
            Map<Id,String> NewAccntRTypeMap = new Map<Id,String>();
            set<id>tempset = new set<id>();
            set<id>tempset2 = new set<id>();
            set<id> acqIdSet = new set<id>();
            acqList = new List<Acquisition_Opportunity__c> ();             
            for(Non_Party_Entity__c npe:NPEList){
                acqIdSet.add(npe.Acquisition_Opportunity__c);
            }    
            acqList = [select id,No_of_Non_Party_Entity_Records__c,No_of_Non_Party_Entity_Records_Member__c,No_of_Non_Party_Entity_Records_Prospect__c,No_of_Non_Party_Entity_Records_Other__c from Acquisition_Opportunity__c where id in :acqIdSet];            
            system.debug('@@acqList'+acqList);
            for(Acquisition_Opportunity__c ac:AcqList){
                CurrentTotalCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records__c);
                CurrentMembCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records_Member__c);
                CurrentProsCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records_Prospect__c);
                CurrentOtherCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records_Other__c);
            }       
            system.debug('@@CurrentMembCountMap initial'+CurrentMembCountMap);
            system.debug('@@CurrentTotalCountMap initial'+CurrentTotalCountMap);
            system.debug('@@CurrentProsCountMap initial'+CurrentProsCountMap);
            if(OldAccntList!=null){                    
                for(Non_Party_Entity__c npe:NPEList){
                    for(account a :oldAccntList){
                        if(a.id==npe.account__c){
                            if(!tempSet.contains(a.id)){
                                OldAccntRTypeMap.put(npe.id,OldAccntMap.get(a.id).recordtypeid);
                                tempset.add(a.id);
                            }
                        }                   
                    }
                    if(newAccntList!=null){
                        for(account a :newAccntList){
                            if(a.id==npe.account__c){
                                if(!tempSet2.contains(a.id)){
                                    NewAccntRTypeMap.put(npe.id,NewAccntMap.get(a.id).recordtypeid);
                                    tempset2.add(a.id);
                                }
                            }                   
                        }
                    }
                }
                for(Non_Party_Entity__c npe:NPEList){
                    system.debug('in npe loop@@ old map'+OldAccntRTypeMap.get(npe.id));
                    system.debug('in npe loop@@ label'+label.AccntProspRecTypeId);
                    system.debug('in npe loop@@ new mP'+NewAccntRTypeMap.get(npe.id));
                    system.debug('in npe loop@@'+label.AccntMemberRecTypeId);
                    if(OldAccntRTypeMap.get(npe.id)!=null){
                        if(CurrentTotalCountMap.get(npe.Acquisition_opportunity__c)!=null){
                            if(OldAccntRTypeMap.get(npe.id)==label.AccntMemberRecTypeId){
                               CurrentMembCountMap.put(npe.Acquisition_Opportunity__c,CurrentTotalCountMap.get(npe.Acquisition_opportunity__c)-1);               
                            }
                        }
                        
                        if(CurrentProsCountMap.get(npe.Acquisition_opportunity__c)!=null){
                            if(OldAccntRTypeMap.get(npe.id)==label.AccntProspRecTypeId){                    
                                system.debug('@@Countin Pros update old'+CurrentProsCountMap.get(npe.Acquisition_opportunity__c));
                                CurrentProsCountMap.put(npe.Acquisition_Opportunity__c,CurrentProsCountMap.get(npe.Acquisition_opportunity__c)-1);               
                            }
                        } 
                        
                        if(OldAccntRTypeMap.get(npe.id)!=label.AccntMemberRecTypeId && OldAccntRTypeMap.get(npe.id)!=label.AccntProspRecTypeId){
                            CurrentOtherCountMap.put(npe.Acquisition_Opportunity__c,CurrentOtherCountMap.get(npe.Acquisition_opportunity__c)-1);    
                        }   
                    }
                    if(NewAccntRTypeMap.get(npe.id)!=null){
                        if(CurrentMembCountMap.get(npe.Acquisition_opportunity__c)!=null){
                            if(NewAccntRTypeMap.get(npe.id)==label.AccntMemberRecTypeId){
                                system.debug('@@Countin member update'+CurrentMembCountMap.get(npe.Acquisition_opportunity__c));
                                CurrentMembCountMap.put(npe.Acquisition_Opportunity__c,CurrentMembCountMap.get(npe.Acquisition_opportunity__c)+1);               
                            }
                        }
                        if(CurrentProsCountMap.get(npe.Acquisition_opportunity__c)!=null){
                            if(NewAccntRTypeMap.get(npe.id)==label.AccntProspRecTypeId){
                               system.debug('@@ in pros update new');
                               CurrentProsCountMap.put(npe.Acquisition_Opportunity__c,CurrentProsCountMap.get(npe.Acquisition_opportunity__c)+1);               
                            } 
                        }                   
                        if(NewAccntRTypeMap.get(npe.id)!=null){
                            if(NewAccntRTypeMap.get(npe.id)!=label.AccntMemberRecTypeId && NewAccntRTypeMap.get(npe.id)!=label.AccntProspRecTypeId){
                                CurrentOtherCountMap.put(npe.Acquisition_Opportunity__c,CurrentOtherCountMap.get(npe.Acquisition_opportunity__c)+1);    
                            }
                        }
                    }                                                                                                  
                }  
                for(Acquisition_Opportunity__c acq:acqList){   
                   if(event=='update'){                                    
                        if(CurrentTotalCountMap.get(acq.id)!=null)
                        acq.No_of_Non_Party_Entity_Records__c=CurrentTotalCountMap.get(acq.id);
                    }
                    if(event=='delete'){
                       if(CurrentTotalCountMap.get(acq.id)!=null)
                        acq.No_of_Non_Party_Entity_Records__c=CurrentTotalCountMap.get(acq.id)-1;
                    }                                      
                    if(CurrentMembCountMap.get(acq.id)!=null){
                    system.debug('@@CurrentMembCountMap in final loop'+CurrentMembCountMap.get(acq.id));
                    acq.No_of_Non_Party_Entity_Records_Member__c=CurrentMembCountMap.get(acq.id);                          
                    }
                               
                    if(CurrentProsCountMap.get(acq.id)!=null)
                    acq.No_of_Non_Party_Entity_Records_Prospect__c=CurrentProsCountMap.get(acq.id);                          
                            
                    if(CurrentOtherCountMap.get(acq.id)!=null)
                    acq.No_of_Non_Party_Entity_Records_Other__c=CurrentOtherCountMap.get(acq.id);
                }
               
            }           
            update acqList;                            
        }
    }
}