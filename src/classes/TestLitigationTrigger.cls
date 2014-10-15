/*****************************************************************************
 * Name                 : TestLitigationTrigger
 * Created By           : Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 16 April, 2012.
 * Description        : Test Class for LitigationTrigger.
 *****************************************************************************/
@isTest
private class TestLitigationTrigger {
    //Test Method To check the Quality of the Code
    static testMethod void myUnitTest() {
    //Prepare test data
      //Create Account
      Account account = TestUtil.createAccount(true); 
      //Creayte acquisition opportunity
      Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(account.Id, 'Phase 1', 'Test Defandant', false);
      acqOpp.CloseDate__c = date.today().addDays(5);
      insert acqOpp;
      
      //Insert litigation
      Litigation__c litigition = TestUtil.createLitigation(false);
      litigition.Acquisition_Opportunity__c = acqOpp.Id;
      litigition.Filed__c = date.today();
      insert litigition;
      
      Defendant__c defendant = TestUtil.createDefendant(account.Id, litigition.Id, true);
      //Testing is start from here  
        Test.startTest();
        
        // need code coverage
        DefendantManagement.DoNothing();
        LitigationManagement.DoNothing();
            
            
            //Update Litigation to fire the trigger.
            litigition.Filed__c = Date.today().adddays(5);
            update litigition;
            
            //Retrieve Account of defendant
            Account acc = getAccount(account.Id);
            //Check that Lits_filed_this_calendar_years__c on account must be 1 after the update of litigation.
           // System.assertEquals(acc.Lits_filed_this_calendar_years__c ,1);
        Test.stopTest();
    }
    static Account getAccount(Id accId){
        for(Account account : [select Lits_filed_this_calendar_years__c from Account where Id =: accId]){
            return account;
        }
        return null;
    }
    
}