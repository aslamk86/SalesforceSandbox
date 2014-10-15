/*
    Trigger : CaptureLastManualUpdate 
    Description :  Used to Update Last Update Time field from Current Time and Last Modified By field from Current User Name.
    Developed by : Bharti Mehta
    Last Modified Date : January 5, 2012
*/

trigger CaptureLastManualUpdate on Account (before update,before insert) {    
    String profileName = getUserProfileName();
    Boolean isManualCommentRequired = !Label.ProfilesNotFillManualComment.toLowerCase().contains(profileName.toLowerCase());
    
    system.debug('====' + isManualCommentRequired);
    
    //Iterate For all accounts in those updation Performed. 
    for(Account account : Trigger.New){
        //Iterate to check Updation in fields those contain by Custom setting.
        for(AccountFields__c field : AccountFields__c.getAll().values()){
            //check Updation Performed or not in defined field
            
            if((Trigger.isInsert && account.get(field.Name) != null ) ||(Trigger.isUpdate && Trigger.oldMap.get(account.Id).get(field.Name)!=Trigger.newMap.get(account.Id).get(field.Name))){
                    
                account.Rate_Last_Updated_Manual__c = system.today();
                account.Rate_Last_Updated_By_Manual__c = UserInfo.getName();  
                
                //Update Last Updated Time and Last Modified By fied.
                if(account.Financial_Data_Source_Type__c != null && account.Financial_Data_Source_Type__c != ''){
                    if(account.Financial_Data_Source_Type__c.equals('Thomson')){
                        account.Rate_Last_Updated__c = account.Rate_Last_Updated_Thomson__c;
                        account.Rate_Last_Update_By__c = 'Thomson';
                    }
                    else{
                        if(isManualCommentRequired && (account.Rate_Comments_Manual__c == null || account.Rate_Comments_Manual__c == ''))
                            account.addError('Rate Comments (Manual) is required if any of the income information changes.');
                            account.Rate_Last_Updated__c = system.today();
                            account.Rate_Last_Update_By__c = UserInfo.getName();
                    }      
                }     
                                      
                break;
                
            }
        }
        
    }
    
    //to get profile name of the logged in user
    private String getUserProfileName(){
        for(User usr : [Select Profile.Name From User Where Id = :UserInfo.getUserId()]){
            return usr.Profile.Name;
        }
        
        return '';
    }
}