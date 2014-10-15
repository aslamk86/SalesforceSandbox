@isTest(seealldata =true)
public class TestUserHandler{
    
    static testmethod void TestCommunityUserCreation(){ 
        
        account acc = new account(name='Test Account');
        insert acc;
        contact con = new contact(accountid=acc.id,email='testemail@emailservice.com',firstname='Test',lastname='contact');
        insert con;
        Profile pf = [Select id,name from Profile where name ='Customer Community Login User' limit 1]; 
        User commUser = new User(contactId=con.id, username=con.Email, firstname=con.FirstName,
                lastname=con.LastName, email=con.Email,communityNickname = con.Email,alias = string.valueof(con.FirstName.substring(0,1) + con.LastName.substring(0,1)), profileid = pf.Id, emailencodingkey='UTF-8',
                languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Test.setMock(HttpCalloutMock.class, new WebServiceCommUserSuccess());
        System.runAs (thisUser) {
            //Test.startTest();
                insert commUser;    
            //Test.startTest();         
        }       
    }
       static testmethod void TestCommunityUserCreation2(){ 
        
        account acc = new account(name='Test Account');
        insert acc;
        contact con = new contact(accountid=acc.id,email='testemail@emailservice.com',firstname='Test',lastname='contact');
        insert con;
        Profile pf = [Select id,name from Profile where name ='Customer Community Login User' limit 1]; 
        User commUser = new User(contactId=con.id, username=con.Email, firstname=con.FirstName,
                lastname=con.LastName, email=con.Email,communityNickname = con.Email,alias = string.valueof(con.FirstName.substring(0,1) + con.LastName.substring(0,1)), profileid = pf.Id, emailencodingkey='UTF-8',
                languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles');
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Test.setMock(HttpCalloutMock.class, new WebServiceCommUserFailure());
        System.runAs (thisUser) {
            //Test.startTest();
                insert commUser;    
            //Test.startTest();         
        }       
    }

}