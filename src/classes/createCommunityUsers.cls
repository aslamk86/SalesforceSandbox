public class createCommunityUsers{
    public static set<id>errContactIdSet = new set<id>();
    //inviteReqUtil iru = new inviteReqUtil();
    public static list<inviteReqUtil.jsonWrap> jsonWrapList = new List<inviteReqUtil.jsonWrap>();
    public static string jsonConErrorStr;
    public static Map<id,String> conErrorMap = new Map<id,string>();
    
    public void createCommUser(){
        List<InviteRequest__c> invReqList = new List<InviteRequest__c>();
        //query all the invite Requests which are Invite Pending
        invReqList = [select id,name,contact__c from inviteRequest__c where status__c='Invite Pending' and contact__c!=null limit 5];
        system.debug('@@invReqList'+invReqList);
        set<id>conIdSet = new set<id>();
        for(inviteRequest__c ir:invReqList){
            conIdSet.add(ir.contact__c);
        }
        system.debug('@@conIdSet'+conIdSet);
        Profile pf = [Select id,name from Profile where name ='Customer Community Login User' limit 1];         
        List<user> userList = new List<user>();     
        userList = [select id,name,contactid from user where contactId IN:conIdSet and profileid=:pf.id];
        system.debug('@@userList'+userList);
        set<id>finalConIdSet = new set<id>();
        //Filter out the contacts for which Community User has already been created
        if(!userList.isEmpty()){
            for(user u:userList){
                for(id conId:conIdSet){
                    if(u.contactId !=conId){
                        finalConIdSet.add(conId);
                    }                    
                }
            }
        }
        if(userList.isEmpty()){
            finalConIdSet.addall(conIdSet);
        }
        system.debug('@@finalConIdSet'+finalConIdSet);
        List<contact> conList = [select id,email,lastname,firstname,name from contact where id in:finalConIdSet ];
        List<user>finalUserList = new List<User>();
        Map<id,string>conNameMap = new Map<id,string>();
        system.debug('@@conList'+conList);
        for(contact con: conList){
            conNameMap.put(con.id,con.name);
             User commUser = new User(contactId=con.id, username=con.Email, firstname=con.FirstName,
                lastname=con.LastName, email=con.Email,communityNickname = con.Email,alias = string.valueof(con.FirstName.substring(0,1) + con.LastName.substring(0,1)), profileid = pf.Id, emailencodingkey='UTF-8',
                languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');                 
                system.debug('@@commUser'+commUser.username);
            finalUserList.add(commUser);
        }
        //insert the Community Users
        //insert finalUserList;
               
        // DML statement
        Database.SaveResult[] srList= Database.insert(finalUserList, false);
        system.debug('@@srList'+srList);
        //system.debug('@@srList'+srList[0].contactId);
        string body;
        // Iterate through each returned result
        for(integer i=0;i<srList.size();i++){
            if(srList[i].isSuccess()){
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted User. Account ID: ' + srList[i].getId());
            }
            else{
                 // Operation failed, so get all errors                
                for(Database.Error err : srList[i].getErrors()) {
                system.debug('@@ in else message'+err.getMessage());
                system.debug('@@ in else statuscode'+err.getStatusCode());
                system.debug('@@ in else fields'+err.getFields());
                    errContactIdSet.add(finalUserList[i].contactId);
                    //conErrorMap.put(finalUserList[i].contactId,err.getMessage());
                    inviteReqUtil irutil = new inviteReqUtil();
                    inviteReqUtil.jsonWrap jw= new inviteReqUtil.jsonWrap(finalUserList[i].contactId,err.getMessage());
                    jsonWrapList.add(jw);
                    jsonConErrorStr = JSON.serialize(jsonWrapList);
                    string firstLine = 'The following error has occurred for the Contact :'+conNameMap.get(finalUserList[i].contactId)+'<br/>';
                    if(body==null){
                        body=firstLine;
                        body=body+err.getStatusCode() + ': ' + err.getMessage()+'<br/>';                           
                    }   
                    else{
                        body=body+'<br/><br/>'+firstLine;
                        body=body+err.getStatusCode() + ': ' + err.getMessage()+'<br/>';                           
                    }   
                }
            }
        }
               
        // Define the email
        if(body!=null){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

            String[] toAddresses = new List<String>();
            string toEmail= Insurance_APP__c.getValues('Notify Community User Creation Failure').Notification_Email__c;
            toAddresses.add(toEmail);
            
            // Sets the paramaters of the email
            email.setSubject( 'Community Users Creation Failure' );
            email.setToAddresses( toAddresses );
            email.setHtmlBody( body );
        
            // Sends the email
            Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  
        }   
        if(errContactIdSet.size()>0 && jsonConErrorStr!=null)
        callInvReqUtil(errContactIdSet,jsonConErrorStr);
    }
    
    @future
    public static void callInvReqUtil(set<id>conIdSet,string ConErrorStr){
        inviteReqUtil.callUpdateReq(conIdSet,ConErrorStr);
    }
    

}