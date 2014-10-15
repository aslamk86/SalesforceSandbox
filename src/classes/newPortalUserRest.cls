@RestResource(urlMapping='/NewPortalUser/*')
global with sharing class newPortalUserRest {
    
    
    global class Result {
        global String status{get;set;}
    }
    
    @HttpPost
    global static Result doPost(String contactId){
        Profile pf = [Select id,name from Profile where name ='Customer Community Login User' limit 1];      
                        
        Contact contact = [select id,email,lastname,firstname,name from contact where id=:contactId];
        
        List<User> existingUser = [select id from user where username=:contact.email];
        
        Result r = new Result();        
        
        if(existingUser.size()==0){
        
            User commUser = new User(contactId=contact.id, username=contact.Email, firstname=contact.FirstName,
                lastname=contact.LastName, email=contact.Email,
                communityNickname = contactId.substring(10,18),
                alias = contactId.substring(10,18),profileid = pf.Id, emailencodingkey='UTF-8',
                languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles',
                AutoCreated__c=true);   
        
            
            insert commUser;
            r.status= commUser.username;
        }
        else r.status= contact.email;
        
        /*
        try{
            insert commUser;
            r.status= commUser.username;
        }
        catch(Exception e){
            r.status=e.getDmlType(0).name();
        }
        */
         
        return r;
    }
}