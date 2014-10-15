public class inviteReqUtil{
  
    public static void callUpdateReq(set<id>contactIdSet,string ConErrorStr){
        List<InviteRequest__c> invReqList = new List<InviteRequest__c>();
        List<InviteRequest__c> updateInvReqList = new List<InviteRequest__c>();
        List<jsonWrap> jsonErrWrapList = new List<jsonWrap>();
        jsonErrWrapList= (List<jsonWrap>)JSON.deserialize(ConErrorStr,list<jsonWrap>.class);
        if(contactIdSet.size()>0)
        invReqList = [select id,status__c,contact__c,Account__c from InviteRequest__c where status__c='Invite Pending' and contact__c in:contactIdSet];
        system.debug('@@invReqList'+invReqList);
        system.debug('@@jsonErrWrapList'+jsonErrWrapList);
        Map<id,id> accntContactmap  = new Map<id,id>();
            if(invReqList.size()>0){            
                for(inviteRequest__c inv: invReqList){   
                    for(jsonWrap j:jsonErrWrapList){
                        if(inv.contact__c == j.conId){
                            inv.status__c='Invite Failed';
                            inv.Error_Description__c=j.errorDesc;
                            updateInvReqList.add(inv);
                        }
                    }                   
                }
            }               
        update updateInvReqList;
    }
    
    public class jsonWrap{
        public id conId;
        public string errorDesc;
        
        public jsonWrap(id ConId,string ErrorDesc){
            this.conId = ConId;
            this.errorDesc = ErrorDesc;
        }
    }

}