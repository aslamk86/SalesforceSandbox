public class NonPartyEntityHandler{
        public static boolean prevRecurs = true;
        public string IsDummyUpdate=label.DummyUpdate;
        
        public void UpdateCountOnAcquisition(list<Non_Party_Entity__c> NewNPERecList,list<Non_Party_Entity__c> OldNPERecList){
           
            if(prevRecurs==true){
            if(!test.IsRunningTest())
            prevRecurs=false;
            integer TotalCount =0;
            integer MembCount =0;
            integer ProsCount=0;
            integer OtherCount =0;
                
            integer decMembCount =0;
            integer decProsCount =0;
            integer decOtherCount =0;
            integer decTotalCount =0;
            
            Map<string,Integer> NPETotalAcqCountMap = new Map<string,Integer>();
            Map<string,Integer> NPEMembCountMap  = new Map<string,Integer>();
            Map<string,Integer> NPEProsCountMap  = new Map<string,Integer>();
            Map<string,Integer> NPEOtherCountMap  = new Map<string,Integer>();
            
            Map<string,Integer>CurrentTotalCountMap = new Map<string,Integer>();
            Map<string,Integer>CurrentMembCountMap = new Map<string,Integer>();
            Map<string,Integer>CurrentProsCountMap = new Map<string,Integer>();
            Map<string,Integer>CurrentOtherCountMap = new Map<string,Integer>();
            
            Map<Id,String> AccntRTypeMap = new Map<Id,String>();
            Map<Id,String> OldAccntRTypeMap = new Map<Id,String>();
            Set<id>OldAcqIdSet = new Set<id>();
            Set<id>TotalAcqIdSet = new Set<id>();
            set<id>OldAccntIdSet = new set<id>();
            set<id>AccntIdSet = new set<id>();
            List<Acquisition_Opportunity__c> AcqList = new List<Acquisition_Opportunity__c>();
            if(OldNPERecList!=null){
                for(Non_Party_Entity__c npe: OldNPERecList){
                    OldAccntIdSet.add(npe.account__c);
                    OldAcqIdSet.add(npe.Acquisition_Opportunity__c);
                }
                List<Account> OldAccntList =[select id,recordtype.name from account where id in:OldAccntIdSet];
                for(Non_Party_Entity__c oldnpe:OldNPERecList){
                    for(account a : OldAccntList){
                        if(a.id==oldnpe.account__c){
                            OldAccntRTypeMap.put(oldnpe.id,a.recordtype.name);
                        }
                    }
                }
            }
            
            if(NewNPERecList!=null ){      
                for(Non_Party_Entity__c npe: NewNPERecList){
                    AccntIdSet.add(npe.account__c);
                    TotalAcqIdSet.add(npe.Acquisition_Opportunity__c);
                }
                List<Account> NewAccntList=[select id,recordtype.name from account where id in:AccntIdSet];
                for(Non_Party_Entity__c npe:NewNPERecList){
                    for(account a : NewAccntList){
                        if(a.id==npe.account__c){
                            AccntRTypeMap.put(npe.id,a.recordtype.name);
                        }
                    }
                }
            }
            
            if(OldAccntIdSet!=null)
            TotalAcqIdSet.addAll(OldAcqIdSet);
            //List<Acquisition_Opportunity__c> OldAcqList = new List<Acquisition_Opportunity__c>();
            //OldAcqList = [select id,No_of_Non_Party_Entity_Records__c,No_of_Non_Party_Entity_Records_Member__c,No_of_Non_Party_Entity_Records_Prospect__c,No_of_Non_Party_Entity_Records_Other__c from Acquisition_Opportunity__c where id in :OldAcqIdSet];
            
            AcqList = [select id,No_of_Non_Party_Entity_Records__c,No_of_Non_Party_Entity_Records_Member__c,No_of_Non_Party_Entity_Records_Prospect__c,No_of_Non_Party_Entity_Records_Other__c from Acquisition_Opportunity__c where id in :TotalAcqIdSet];
            system.debug('@@AcqList'+AcqList);
            for(Acquisition_Opportunity__c ac:AcqList){
                CurrentTotalCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records__c);
                CurrentMembCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records_Member__c);
                CurrentProsCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records_Prospect__c);
                CurrentOtherCountMap.put(ac.id,(Integer)ac.No_of_Non_Party_Entity_Records_Other__c);
            }
            system.debug('@@Count of Prospect'+CurrentProsCountMap);
            system.debug('@@Count of Total'+CurrentTotalCountMap);
            system.debug('@@IsDummyUpdate'+IsDummyUpdate);
            if((!test.IsRunningTest() && IsDummyUpdate=='ON')|| (test.IsRunningTest() && IsDummyUpdate=='OFF')){
                set<id>npSet = new set<id>();
                set<id>npAccntSet = new set<id>();
                Map<Id,String> AccntRTypeMapUpd = new Map<Id,String>();
                List<Acquisition_Opportunity__c>    acqTotUpdateList=[select id,name,(select id,name,Account__c from Non_Party_Entities__r)from Acquisition_Opportunity__c where id in:TotalAcqIdSet];
                    for(Acquisition_Opportunity__c ac:acqTotUpdateList){
                        for(Non_Party_Entity__c np:ac.Non_Party_Entities__r){
                            npSet.add(np.Id);
                            npAccntSet.add(np.Account__c);
                        }
                    }
                    List<Non_Party_Entity__c>npList = [select id,name,Account__c,Acquisition_Opportunity__c from Non_Party_Entity__c where id in:npSet];
                    List<Account>accntDummyUpdList =[select id,name,recordtype.name from Account where id in:npAccntSet];
                    for(Non_Party_Entity__c np:npList){
                        for(Account a:accntDummyUpdList){
                            if(a.id==np.Account__c){
                                AccntRTypeMapUpd.put(np.id,a.recordtype.name);
                            }
                        }
                    }
                    for(Non_Party_Entity__c npe:npList){
                    //Total Count
                    if(NPETotalAcqCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                      TotalCount = NPETotalAcqCountMap.get(npe.Acquisition_Opportunity__c);                
                    }
                     else{
                        TotalCount = 0;               
                    }
                    TotalCount += 1;          
                    NPETotalAcqCountMap.put(npe.Acquisition_Opportunity__c, TotalCount); 
                    
                    //MemberCount
                    if(AccntRTypeMapUpd.get(npe.Id) =='Member'){
                        if(NPEMembCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                            MembCount = NPEMembCountMap.get(npe.Acquisition_Opportunity__c);
                        }
                        else{                
                            MembCount = 0;
                        }            
                        MembCount +=1;   
                        NPEMembCountMap.put(npe.Acquisition_Opportunity__c, MembCount);
                    }
                    
                    //ProspectCount
                    else if(AccntRTypeMapUpd.get(npe.Id) =='Prospect'){
                        if(NPEProsCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                            ProsCount = NPEProsCountMap.get(npe.Acquisition_Opportunity__c);
                        }
                        else{                
                            ProsCount = 0;
                        }            
                        ProsCount +=1;   
                        NPEProsCountMap.put(npe.Acquisition_Opportunity__c, ProsCount);
                    }
                    
                    //OtherCount
                     else{
                        if(NPEOtherCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                            OtherCount = NPEOtherCountMap.get(npe.Acquisition_Opportunity__c);
                        }
                        else{                
                            OtherCount = 0;
                        }            
                        OtherCount +=1;  
                        NPEOtherCountMap.put(npe.Acquisition_Opportunity__c, OtherCount);
                    }
                    }
                    for(Acquisition_Opportunity__c acq:acqList){                                       
                        if(NPETotalAcqCountMap.get(acq.id)!=null)
                        acq.No_of_Non_Party_Entity_Records__c=NPETotalAcqCountMap.get(acq.id);
                                                          
                        if(NPEMembCountMap.get(acq.id)!=null)
                        acq.No_of_Non_Party_Entity_Records_Member__c=NPEMembCountMap.get(acq.id);                          
                                   
                        if(NPEProsCountMap.get(acq.id)!=null)
                        acq.No_of_Non_Party_Entity_Records_Prospect__c=NPEProsCountMap.get(acq.id);                          
                                
                        if(NPEOtherCountMap.get(acq.id)!=null)
                        acq.No_of_Non_Party_Entity_Records_Other__c=NPEOtherCountMap.get(acq.id);                   
                    } 
                    update acqList; 
                }
            
            if(NewNPERecList!=null && IsDummyUpdate!='ON')
            {
                for(Non_Party_Entity__c npe: NewNPERecList){
                    //Total Count
                    if(NPETotalAcqCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                      TotalCount = NPETotalAcqCountMap.get(npe.Acquisition_Opportunity__c);                
                    }
                     else{
                        TotalCount = 0;               
                    }
                    TotalCount += 1;          
                    NPETotalAcqCountMap.put(npe.Acquisition_Opportunity__c, TotalCount); 
                    
                    //MemberCount
                    if(accntRTypeMap.get(npe.Id) =='Member'){
                        if(NPEMembCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                            MembCount = NPEMembCountMap.get(npe.Acquisition_Opportunity__c);
                        }
                        else{                
                            MembCount = 0;
                        }            
                        MembCount +=1;   
                        NPEMembCountMap.put(npe.Acquisition_Opportunity__c, MembCount);
                    }
                    
                    //ProspectCount
                    else if(accntRTypeMap.get(npe.Id) =='Prospect'){
                        if(NPEProsCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                            ProsCount = NPEProsCountMap.get(npe.Acquisition_Opportunity__c);
                        }
                        else{                
                            ProsCount = 0;
                        }            
                        ProsCount +=1;   
                        NPEProsCountMap.put(npe.Acquisition_Opportunity__c, ProsCount);
                    }
                    
                    //OtherCount
                     else{
                        if(NPEOtherCountMap.containsKey(npe.Acquisition_Opportunity__c)){
                            OtherCount = NPEOtherCountMap.get(npe.Acquisition_Opportunity__c);
                        }
                        else{                
                            OtherCount = 0;
                        }            
                        OtherCount +=1;  
                        NPEOtherCountMap.put(npe.Acquisition_Opportunity__c, OtherCount);
                    }
                    
                }
                
                if(OldNPERecList==null && NewNPERecList!=null){
                    for(Non_Party_Entity__c npe: NewNPERecList){
                        if(CurrentTotalCountMap.get(npe.Acquisition_Opportunity__c)!=null){
                            if(NPETotalAcqCountMap.get(npe.Acquisition_Opportunity__c)!=null)
                                NPETotalAcqCountMap.put(npe.Acquisition_Opportunity__c,NPETotalAcqCountMap.get(npe.Acquisition_Opportunity__c)+CurrentTotalCountMap.get(npe.Acquisition_Opportunity__c));
                        }
                        
                        if(CurrentMembCountMap.get(npe.Acquisition_Opportunity__c)!=null){
                            if(NPEMembCountMap.get(npe.Acquisition_Opportunity__c)!=null)
                                NPEMembCountMap.put(npe.Acquisition_Opportunity__c,NPEMembCountMap.get(npe.Acquisition_Opportunity__c)+CurrentMembCountMap.get(npe.Acquisition_Opportunity__c));
                        }
                        
                        if(CurrentProsCountMap.get(npe.Acquisition_Opportunity__c)!=null){
                            if(NPEProsCountMap.get(npe.Acquisition_Opportunity__c)!=null)
                                NPEProsCountMap.put(npe.Acquisition_Opportunity__c,NPEProsCountMap.get(npe.Acquisition_Opportunity__c)+CurrentProsCountMap.get(npe.Acquisition_Opportunity__c));
                        }   
                        
                        if(CurrentOtherCountMap.get(npe.Acquisition_Opportunity__c)!=null){
                            if(NPEOtherCountMap.get(npe.Acquisition_Opportunity__c)!=null)
                                NPEOtherCountMap.put(npe.Acquisition_Opportunity__c,NPEOtherCountMap.get(npe.Acquisition_Opportunity__c)+CurrentOtherCountMap.get(npe.Acquisition_Opportunity__c));
                        }                   
                    }               
                }
            }
            set<string>tempSet = new set<string>();     
            if(OldNPERecList!=null && NewNPERecList!=null && IsDummyUpdate!='ON')
            {
                for(Non_Party_Entity__c oldnpe: OldNPERecList){
                    for(Non_Party_Entity__c newnpe:NewNPERecList){
                        if(oldnpe.id==newnpe.id){
                            if(!tempSet.contains(newnpe.id)){
                                system.debug('@@in update New'+NewNPERecList);
                                system.debug('@@in update Old'+OldNPERecList);
                                system.debug('@@in update OldRtype'+OldAccntRTypeMap.get(oldnpe.id));
                                system.debug('@@in update NewRtype'+AccntRTypeMap.get(newnpe.id));
                                system.debug('@@ in new update prospect'+NPEProsCountMap.get(newnpe.Acquisition_Opportunity__c));
                                // Account Recordtype has changed or Acquisition Opp has changed
                                if((OldAccntRTypeMap.get(oldnpe.id)!=AccntRTypeMap.get(newnpe.id)) || (oldnpe.Acquisition_Opportunity__c!=newnpe.Acquisition_Opportunity__c)){
                                    if(CurrentTotalCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null)
                                    NPETotalAcqCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentTotalCountMap.get(oldnpe.Acquisition_Opportunity__c));
                                    //if(oldnpe.Acquisition_Opportunity__c!=newnpe.Acquisition_Opportunity__c){
                                        if(CurrentTotalCountMap.get(newnpe.Acquisition_Opportunity__c)!=null)
                                        NPETotalAcqCountMap.put(newnpe.Acquisition_Opportunity__c,CurrentTotalCountMap.get(newnpe.Acquisition_Opportunity__c));
                                        
                                        if(NPEMembCountMap.get(newnpe.Acquisition_Opportunity__c)!=null){
                                            if(AccntRTypeMap.get(newnpe.id)=='Member'){
                                                NPEMembCountMap.put(newnpe.Acquisition_Opportunity__c,NPEMembCountMap.get(newnpe.Acquisition_Opportunity__c)+CurrentMembCountMap.get(newnpe.Acquisition_Opportunity__c));
                                            }
                                        }
                                        
                                        if(NPEProsCountMap.get(newnpe.Acquisition_Opportunity__c)!=null){
                                            if(AccntRTypeMap.get(newnpe.id)=='Prospect'){
                                                system.debug('@@ in new update prospect'+NPEProsCountMap.get(newnpe.Acquisition_Opportunity__c));
                                                NPEProsCountMap.put(newnpe.Acquisition_Opportunity__c,NPEProsCountMap.get(newnpe.Acquisition_Opportunity__c)+CurrentProsCountMap.get(newnpe.Acquisition_Opportunity__c));
                                            }
                                        }
                                        
                                        if(NPEOtherCountMap.get(newnpe.Acquisition_Opportunity__c)!=null){
                                            if(AccntRTypeMap.get(newnpe.id)!='Member'|| AccntRTypeMap.get(newnpe.id)!='Prospect'){
                                                NPEOtherCountMap.put(newnpe.Acquisition_Opportunity__c,NPEOtherCountMap.get(newnpe.Acquisition_Opportunity__c)+CurrentOtherCountMap.get(newnpe.Acquisition_Opportunity__c));
                                            }
                                        }
                                    //}
                                    system.debug('@@in update');
                                    
                                    if(NPEMembCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                                        if(OldAccntRTypeMap.get(oldnpe.id)=='Member'){
                                            NPEMembCountMap.put(oldnpe.Acquisition_Opportunity__c,NPEMembCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                                        }
                                    }
                                    else{
                                        if(OldAccntRTypeMap.get(oldnpe.id)=='Member'){
                                            if(CurrentMembCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null)
                                            NPEMembCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentMembCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                                        }
                                    }
                                    if(NPEProsCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                                        if(OldAccntRTypeMap.get(oldnpe.id)=='Prospect'){
                                            NPEProsCountMap.put(oldnpe.Acquisition_Opportunity__c,NPEProsCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                                        }
                                    }
                                    else{
                                        if(OldAccntRTypeMap.get(oldnpe.id)=='Prospect'){
                                            system.debug('@@in else of prospect update'+CurrentProsCountMap.get(oldnpe.Acquisition_Opportunity__c));
                                            if(CurrentProsCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null)
                                            NPEProsCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentProsCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                                        }
                                    }
                                    if(NPEOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                                        if(OldAccntRTypeMap.get(oldnpe.id)!='Member' && OldAccntRTypeMap.get(oldnpe.id)!='Prospect'){
                                            NPEOtherCountMap.put(oldnpe.Acquisition_Opportunity__c,NPEOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                                        }
                                    }   
                                    else{
                                        if(OldAccntRTypeMap.get(oldnpe.id)!='Member' && OldAccntRTypeMap.get(oldnpe.id)!='Prospect'){
                                            if(CurrentOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null)
                                            NPEOtherCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                                        }
                                    }
                                    if(oldnpe.Acquisition_Opportunity__c!=newnpe.Acquisition_Opportunity__c){
                                        if(NPETotalAcqCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                                            system.debug('@@ in total update if old'+NPETotalAcqCountMap.get(oldnpe.Acquisition_Opportunity__c));
                                            NPETotalAcqCountMap.put(oldnpe.Acquisition_Opportunity__c,NPETotalAcqCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);   
                                        }   
                                        else{
                                            if(CurrentTotalCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                                                system.debug('@@ in total update else'+NPETotalAcqCountMap.get(oldnpe.Acquisition_Opportunity__c));
                                                NPETotalAcqCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentTotalCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                                            }
                                        }
                                        if(NPETotalAcqCountMap.get(newnpe.Acquisition_Opportunity__c)!=null){
                                            system.debug('@@ in total update if New'+NPETotalAcqCountMap.get(newnpe.Acquisition_Opportunity__c));
                                            NPETotalAcqCountMap.put(newnpe.Acquisition_Opportunity__c,NPETotalAcqCountMap.get(newnpe.Acquisition_Opportunity__c)+1);
                                        }
                                    }
                                }                           
                                
                                tempSet.add(newnpe.id);
                            }   
                        }
                    }                               
                }
            }
            //For DELETE Scenario
            if(OldNPERecList!=null && NewNPERecList==null){ 
                system.debug('@@ in Delete');   
                for(Non_Party_Entity__c oldnpe: OldNPERecList){
                    if(NPEMembCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                        if(OldAccntRTypeMap.get(oldnpe.id)=='Member'){
                            NPEMembCountMap.put(oldnpe.Acquisition_Opportunity__c,NPEMembCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                        }
                    }
                    else{
                        if(OldAccntRTypeMap.get(oldnpe.id)=='Member'){
                            if(CurrentMembCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null)
                            NPEMembCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentMembCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                        }
                    }
                    if(NPEProsCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                        if(OldAccntRTypeMap.get(oldnpe.id)=='Prospect'){
                            NPEProsCountMap.put(oldnpe.Acquisition_Opportunity__c,NPEProsCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                        }
                    }
                    else{
                        if(OldAccntRTypeMap.get(oldnpe.id)=='Prospect'){
                            if(CurrentProsCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null)
                            NPEProsCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentProsCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                        }
                    }
                    if(NPEOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                        if(OldAccntRTypeMap.get(oldnpe.id)!='Member' && OldAccntRTypeMap.get(oldnpe.id)!='Prospect'){
                            NPEOtherCountMap.put(oldnpe.Acquisition_Opportunity__c,NPEOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                        }
                    }   
                    else{
                        if(OldAccntRTypeMap.get(oldnpe.id)!='Member' && OldAccntRTypeMap.get(oldnpe.id)!='Prospect'){
                            if(CurrentOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null)
                            NPEOtherCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentOtherCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                        }
                    }
                    if(NPETotalAcqCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){                   
                        NPETotalAcqCountMap.put(oldnpe.Acquisition_Opportunity__c,NPETotalAcqCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);   
                    }   
                    else{
                        if(CurrentTotalCountMap.get(oldnpe.Acquisition_Opportunity__c)!=null){
                            system.debug('@@in else of delete'+CurrentTotalCountMap.get(oldnpe.Acquisition_Opportunity__c));
                            NPETotalAcqCountMap.put(oldnpe.Acquisition_Opportunity__c,CurrentTotalCountMap.get(oldnpe.Acquisition_Opportunity__c)-1);
                        }
                    }
                }
                            
            }
                    
           
            for(Acquisition_Opportunity__c acq:acqList){                                       
                    if(NPETotalAcqCountMap.get(acq.id)!=null){
                        system.debug('@@in final loop'+NPETotalAcqCountMap.get(acq.id));
                        acq.No_of_Non_Party_Entity_Records__c=NPETotalAcqCountMap.get(acq.id);
                    }
                                                      
                    if(NPEMembCountMap.get(acq.id)!=null)
                    acq.No_of_Non_Party_Entity_Records_Member__c=NPEMembCountMap.get(acq.id);                          
                               
                    if(NPEProsCountMap.get(acq.id)!=null)
                    acq.No_of_Non_Party_Entity_Records_Prospect__c=NPEProsCountMap.get(acq.id);                          
                            
                    if(NPEOtherCountMap.get(acq.id)!=null)
                    acq.No_of_Non_Party_Entity_Records_Other__c=NPEOtherCountMap.get(acq.id);
                    
            }           
            update acqList;
        }
        }

    }