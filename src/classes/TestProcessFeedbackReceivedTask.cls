/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestProcessFeedbackReceivedTask {

   /* static testMethod void myUnitTest() {
        Test.startTest();
            Account account = createAccount();
            insert account;
            
            Contact contact = createContact(account.Id);
            insert contact;
            
            Acquisition_Opportunity__c acqOpportunity = createAcquisitionOpportunity(true,account.Id);
            
            Task task = createTask(false);
            task.WhatId = acqOpportunity.Id;
            task.WhoId = contact.Id;
            task.Status = 'Completed';
            insert task;
            Acquisition_Opportunity__c retrievedAcqOpportunity = retrieveAcquisitionOpportunity(acqOpportunity.Id);
            system.assertEquals(task.WhoId,retrievedAcqOpportunity.LastFeedbackReceivedFrom__c);
            system.assertEquals(task.ActivityDate,retrievedAcqOpportunity.LastFeedbackReceived__c);
            system.assertEquals(task.OwnerId,retrievedAcqOpportunity.LastFeedbackReceivedBy__c);
            system.assertEquals(task.FeedbackBurden__c,retrievedAcqOpportunity.FeedbackBurden__c);
            system.assertEquals(task.DepthOfFeedback__c,retrievedAcqOpportunity.DepthOfFeedback__c);
        Test.stopTest();
        
    }
    static Acquisition_Opportunity__c retrieveAcquisitionOpportunity(Id acqOpportunityId){
        for(Acquisition_Opportunity__c acqOpportunity : [Select LastFeedbackReceived__c, LastFeedbackReceivedFrom__c, LastFeedbackReceivedBy__c, FeedbackBurden__c, DepthOfFeedback__c From Acquisition_Opportunity__c where Id =: acqOpportunityId]){
            return acqOpportunity;
        }
        return null;
    }
    static Task createTask(Boolean isInsert){
        Task task = new Task();
        task.OwnerId = UserInfo.getUserId();
        task.Subject = 'Test';
        task.Type = 'Feedback Received';
        task.ActivityDate = Date.today().addYears(1);
        task.DepthOfFeedback__c = '1';
        task.FeedbackBurden__c = '1';
        task.Quality_of_Conversation__c = '1';
        if(isInsert)
            insert task;
        return task;
    }
    static Acquisition_Opportunity__c createAcquisitionOpportunity(Boolean isInsert,Id accountId){
        Acquisition_Opportunity__c opportunity = new Acquisition_Opportunity__c();
        opportunity.Account__c= accountId;
        opportunity.Name='Test Opportunity';
        opportunity.CloseDate__c = Date.today();
        opportunity.StageName__c = 'Prospect 1';
        opportunity.Amount__c = 100000;
        if(isInsert)
            insert opportunity;
        return opportunity;
    }
    public static Account createAccount(){
        Account account = new Account();
        account.Name='Test Account';
        account.Rating = '1';
        account.Phone = '011-111111';
        account.BillingCountry = 'India';
        account.BillingCity = 'sometown';
        account.BillingStreet = 'TestStreet';
        account.Entity_ID__c = 121212311;
        return account;
    }
    
    public static Contact createContact(String accountId){
        Contact cont = new Contact();
        cont.AccountId = accountId;
        cont.LastName = 'Test Last';
        cont.Email = 'abc@gmail.com';
        cont.Phone = '011-111111';
        cont.Birthdate = Date.today().addYears(-20);        
        return cont;        
    }*/
}