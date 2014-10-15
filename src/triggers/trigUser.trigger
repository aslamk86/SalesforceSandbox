trigger trigUser on User (before insert,after insert) {
    if(trigger.isInsert){

        List<user>newUserList = new List<user>();  
        set<id> contactIdSet = new set<Id>(); 
        set<id>accountIdSet = new set<id>(); 
        set<id> userIdSet = new set<id>();     
                                       
        for(user u:trigger.new){                                                    
              if(u.profileId==label.Customer_Community_Login_User_ProfileId){
                  newUserList.add(u);            
                  contactIdSet.add(u.contactId); 
                  accountIdSet.add(u.accountId); 
                  if(u.id!=null){
                      userIdSet.add(u.id);
                    }
               }
            
        }
        
        if(trigger.IsAfter){
            userHandler.assignPermissionSet(newUserList);
            userHandler.updateInsAppCon(contactIdSet);
            userHandler.createPortalAccount(userIdSet,accountIdSet); 
        }
    }
}