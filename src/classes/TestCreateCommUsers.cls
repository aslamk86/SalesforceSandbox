@isTest(seealldata =true)
public class TestCreateCommUsers{

    static testmethod void TestCreateCommUser(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            account acc = new account(name='Test Account');
            insert acc;
            contact con = new contact(accountid=acc.id,email='testemail@emailservice.com',firstname='Test',lastname='contact');
            insert con;
            
            inviteRequest__c inv = new inviteRequest__c(contact__c=con.id,account__c=acc.id,status__c='Invite Pending');
            insert inv;                        
             Test.setMock(HttpCalloutMock.class, new WebServiceCommUser());
            createCommunityUsers ccu = new createCommunityUsers();
            ccu.createCommUser();
        }
    }
     static testmethod void TestCreateCommUser2(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            account acc = new account(name='Test Account');
            insert acc;
            contact con = new contact(accountid=acc.id,firstname='Test',lastname='contact');
            insert con;
            
            inviteRequest__c inv = new inviteRequest__c(contact__c=con.id,account__c=acc.id,status__c='Invite Pending');
            insert inv;
            
            inviteRequest__c inv2 = new inviteRequest__c(contact__c=con.id,account__c=acc.id,status__c='Invite Pending');
            insert inv2;
            createCommunityUsers ccu = new createCommunityUsers();
            Test.setMock(HttpCalloutMock.class, new WebServiceCommUser2());
            ccu.createCommUser();
        }
    }
      static testmethod void TestCreateCommUser3(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.runas(thisUser){
            account acc = new account(name='Test Account');
            insert acc;
            contact con = new contact(accountid=acc.id,email='testemail@emailservice.com',firstname='Test',lastname='contact');
            insert con;
            
            inviteRequest__c inv = new inviteRequest__c(contact__c=con.id,account__c=acc.id,status__c='Invite Pending');
            insert inv;
            Profile pf = [Select id,name from Profile where name ='Customer Community Login User' limit 1];
             User commUser = new User(contactId=con.id, username=con.Email, firstname=con.FirstName,
                lastname=con.LastName, email=con.Email,communityNickname = con.Email,alias = string.valueof(con.FirstName.substring(0,1) + con.LastName.substring(0,1)), profileid = pf.Id, emailencodingkey='UTF-8',
                languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');                 
                
            insert commUser;
            createCommunityUsers ccu = new createCommunityUsers();
            Test.setMock(HttpCalloutMock.class, new WebServiceCommUser2());
            ccu.createCommUser();
        }
    }
       
}