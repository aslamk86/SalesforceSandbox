/************************************************************
 * Name             : TestSend_EmailNotification 
 * Created By       : Sreenivasulu Binkam
 * Created Date     : 4/25/2014 6:30 AM
 * Purpose          : Test Class for Send_EmailNotification 
 ***********************************************************/
@isTest
public class TestSend_EmailNotification{
      static testMethod void SendEmaiTestCases() {
      
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduser534@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5345@testorg.com');
      insert u;
      Account objAcc = new Account(name='test',Entity_ID__c=6878,Sector_Representative__c=u.id);
      insert objacc;
      Acquisition_Opportunity__c objAcquisition = new Acquisition_Opportunity__c(Account__c=objacc.id,Name ='test',StageName__c='No Outreach');
      insert objAcquisition;
      Non_Party_Entity__c npe = new Non_Party_Entity__c(Account__c=objacc.id,Acquisition_Opportunity__c=objAcquisition.id);
      insert npe;
    }
}