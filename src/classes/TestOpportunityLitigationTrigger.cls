/*****************************************************************************
 * Name               : TestOpportunityLitigationTrigger
 * Created By         : Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for OpportunityLitigationTrigger.
 *****************************************************************************/
@isTest
private class TestOpportunityLitigationTrigger {
    //Test method to check the quality of the Code
     static testMethod void myUnitTest() {
       //Acquisition Opportunities
       List<Acquisition_Opportunity__c> acqOppList = new List<Acquisition_Opportunity__c>();
       //Litigations
       List<Litigation__c> litigationList = new List<Litigation__c>();
       //Defendants
       List<Defendant__c> defendantList = new List<Defendant__c>();
       //Create test data
       //Create an Account
      Account account = TestUtil.createAccount(true); 
         //Create acq Opp
         Acquisition_Opportunity__c acqOpp1 = TestUtil.createAcquisitionOpp(account.Id, 'Phase 1', 'Test Defandant1', false);
         acqOpp1.CloseDate__c = date.today().addDays(5);
         acqOppList.add(acqOpp1);
         
         Acquisition_Opportunity__c acqOpp2 = TestUtil.createAcquisitionOpp(account.Id, 'Phase 1', 'Test Defandant2', false);
         acqOpp2.CloseDate__c = date.today().addDays(5);
         acqOppList.add(acqOpp2);
         
         insert acqOppList;
         //Create Litigations
         Litigation__c litigition1 = TestUtil.createLitigation(false);
         litigition1.Acquisition_Opportunity__c = acqOppList[0].Id;
         litigationList.add(litigition1);
         
         Litigation__c litigition2 = TestUtil.createLitigation(false);
         litigition2.Acquisition_Opportunity__c = acqOppList[1].Id;
         litigationList.add(litigition2);
         
         insert litigationList;
         
         //Create Defendants
         defendantList.add(TestUtil.createDefendant(account.Id, litigationList[0].Id, false));
         defendantList.add(TestUtil.createDefendant(account.Id, litigationList[1].Id, false));
         insert defendantList;
         //Start testing
         Test.startTest();
           //Insert opportunity Litigation to fire a trigger on Insert Event
           Opportunity_Litigation__c oppLitigition = TestUtil.createOpportunityLitigation(acqOppList[0].Id, litigationList[0].Id,false);
           insert oppLitigition;
           //There should be at least 1 Acquisition Opportunity Defendant
         //  System.assert(getAODs(acqOppList[0].Id,defendantList[0].Id).size() > 0);
           //Update opportunity Litigation to fire a trigger on update Event
           oppLitigition.Acquisition_Opportunity__c = acqOppList[1].Id;
           update oppLitigition;
           //There should be at least 1 Acquisition Opportunity Defendant
      //     System.assert(getAODs(acqOppList[1].Id,defendantList[0].Id).size() > 0);
           
           oppLitigition.Litigation__c = litigationList[1].Id;
           update oppLitigition;
           
           System.assert(getAODs(acqOppList[1].Id,defendantList[1].Id).size() == 0);
           //delete opportunity Litigation to fire a trigger on delete Event
           delete oppLitigition;
           //afte delete, There should not be any Acquisition Opportunity Defendant
    //       System.assert(getAODs(acqOppList[1].Id,defendantList[1].Id).size() == 0);
         Test.stopTest();
    }
    static List<Acquisition_Opportunity_Defendant__c> getAODs(Id acqOppId,Id defendantId){
      return [select id from Acquisition_Opportunity_Defendant__c where Acquisition_Opportunity__c =: acqOppId AND Defendant__c =:defendantId];
    }
}