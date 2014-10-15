public class userHandler{
    
    //public static list<inviteReqUtil.jsonWrap> jsonWrapList = new List<inviteReqUtil.jsonWrap>();
    //public static string jsonConErrorStr;
    //public static set<id>errContactIdSet = new set<id>();     
    
    
    public static void assignPermissionSet(List<User> userList){
        try{
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name =: label.Community_Permissionset_Name];
            list <PermissionSetAssignment> PSAssignments = new list <PermissionSetAssignment>();
            for(user u:userList){
               PSAssignments.add( new PermissionSetAssignment(AssigneeId = u.id,PermissionSetId = ps.ID ) );         
            }
            insert PSAssignments;
        }
        catch(exception e){
            system.debug('@@ in exception'+e.getMessage());
        }
    }
   
    @future
    public static void updateInsAppCon(set<Id> contactIdSet){
        try{
            List<contact> conList= new List<contact>();
            conList=[select id,Insurance_App_Contact__c from contact where id in:contactIdSet];
            for(contact c:conList){
                c.Insurance_App_Contact__c=true;
            }
            update conList;
        }
        catch(exception e){
            system.debug('@@ in exception'+e.getMessage());
        }
    }
    
    @future(callout=true)
    public static void createPortalAccount(set<id>userIdSet,set<id> accountIdSet){
        try{
            List<User> userList = new List<user>();
            userList = [select id,contactid,AccountId,email,username,firstname,lastname from user where id in:userIdSet];       
            List<Account>accountList = new List<Account>();
            accountList =[select id,name from account where id in:accountIdSet];
            Map<id,string>accountMap =new Map<id,string>();
            
            for(user u:userList){
                for(account  a:accountList){
                    if(u.accountId == a.id)
                    accountMap.put(a.id,a.name);
                }
            }
            
            system.debug('@@userList'+userList);
            system.debug('@@userList email'+userList[0].email);     
            List<userInfoJSONWrapper> userInfoJSONWrapperList;
            set<id> SuccessConIdSet = new set<id>();
            
            // Instantiate a new http object
            Http h = new Http();
            for(user u:userList){   
                userInfoJSONWrapperList = new List<userInfoJSONWrapper>();
                userInfoJSONWrapperList.add(new userInfoJSONWrapper(u.email,u.userName,u.firstname,u.lastname,accountMap.get(u.accountId)));
                system.debug('@@userInfoJSONWrapperList'+userInfoJSONWrapperList);
                String userInfo = JSON.serialize(userInfoJSONWrapperList);
                SYSTEM.DEBUG('@@ JSON UserInfo'+userInfo);
                userInfo = userInfo.substring(1, userInfo.length() - 1);
                SYSTEM.DEBUG('@@ JSON UserInfo after splitting'+userInfo);             
                string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('InsuranceApp Portal API').Authorization_Token__c;
                string EndPoint=API_ENDPOINT_URLS__c.getValues('InsuranceApp Portal API').ENDPOINT_URL__c; 
                system.debug('@@Authoriazation'+AuthorizationToken);
                system.debug('@@EndPoint'+EndPoint);
                
                // Instantiate a new HTTP request, specify the method (POST) as well as the endpoint
                HttpRequest req = new HttpRequest();
                req.setEndpoint(EndPoint);
                req.setMethod('POST');
                req.setHeader('Authorization', AuthorizationToken);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(userInfo);
                
                // Send the request, and return a response            
                HttpResponse res = h.send(req);
                system.debug('@@ response'+res);
                system.debug('@@ response body'+res.getBody());
                if(res.getStatus()=='OK'|| res.getStatusCode()==200){
                    SuccessConIdSet.add(u.contactId);
                    
                }
                else{                                
                    HttpResponse res2 = h.send(req);
                    system.debug('@@ response in else'+res2);
                    system.debug('@@ response body in else'+res2.getBody());
                    if(res2.getStatus()=='OK'|| res2.getStatusCode()==200){
                        SuccessConIdSet.add(u.contactId);                   
                    }
                    else{
                        //errContactIdSet.add(u.contactId);
                        // Define the email
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

                        String[] toAddresses = new List<String>();
                        string toEmail= Insurance_APP__c.getValues('Notify Community User Creation Failure').Notification_Email__c;
                        toAddresses.add(toEmail);
                        
                        // Sets the paramaters of the email
                        string body='The following error has occurred:'+'<br/>';
                        body=body+'Error Code: '+res2.getStatusCode() +'<br/>';
                        body = body+'Error Descrition: ' + res2.getStatus();                        
                        
                        email.setSubject( 'Failure of Portal Account Creation' );
                        email.setToAddresses( toAddresses );
                        email.setHtmlBody( body );
                        
                        // Sends the email
                        Messaging.SendEmailResult [] r = 
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                        //inviteReqUtil.jsonWrap jw= new inviteReqUtil.jsonWrap(u.contactId,res2.getStatus());
                        //jsonWrapList.add(jw);                       
                    }
                }           
            }
            
            //jsonConErrorStr = JSON.serialize(jsonWrapList);
            if(SuccessConIdSet.size()>0)
            InvReqAndSharingUpdate(SuccessConIdSet,userList);
            //if(errContactIdSet.size()>0)       
            //inviteReqUtil.callUpdateReq(errContactIdSet,jsonConErrorStr);        
           
        }
        catch(exception e){
             system.debug('@@ in finalexception'+e.getMessage());
        }
    }
    
    public static void InvReqAndSharingUpdate(set<id> contactIdSet,List<user> userList){
        try{
           /* List<InviteRequest__c> invReqList = new List<InviteRequest__c>();
            List<InviteRequest__c> updateInvReqList = new List<InviteRequest__c>();
            if(contactIdSet.size()>0)
            invReqList = [select id,status__c,contact__c,Account__c,error_description__c from InviteRequest__c where status__c='Invite Pending' and contact__c in:contactIdSet];
            Map<id,id> accntContactmap  = new Map<id,id>();
                if(invReqList.size()>0){            
                    for(inviteRequest__c inv: invReqList){                          
                        inv.status__c='Invited'; 
                        inv.error_description__c='';                       
                        updateInvReqList.add(inv);
                        accntContactmap.put(inv.contact__c,inv.Account__c);
                    }
                }               
            update updateInvReqList; */          
                List<customshare__c> custShareList = new List<customshare__c>();
                for(user u:userList){
                    //customshare__c cs = new customshare__c(user__c=u.id,account__c=accntContactmap.get(u.contactId));
                    customshare__c cs = new customshare__c(user__c=u.id,account__c=u.accountId);
                    custShareList.add(cs);
                }
                
                insert custShareList;           
        }
        catch(exception e){
            system.debug('@@ in finalexception'+e.getMessage());
        }     
    
    }
    private class userInfoJSONWrapper{
        string email;
        string user_status;
        string salesforce_username;
        string user_type;
        string first_name;
        string last_name;
        string company;
        public userInfoJSONWrapper(string email,string userName,string firstName,string lastName, string Company){
            this.email=email;
            this.user_status='true';
            this.salesforce_username=userName;
            this.user_type='ClientIS';
            this.first_name=firstName;
            this.last_name=LastName;
            this.company=Company;
        }
    
    }

}