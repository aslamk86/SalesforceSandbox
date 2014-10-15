/*****************************************************************************
 * Name             	: TestDefandantTrigger
 * Created By       	: Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for DefandantTrigger.
 *****************************************************************************/
@isTest
private class TestDefandantTrigger {

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
      //Insert opportunity Litigation
      Opportunity_Litigation__c oppLitigition = TestUtil.createOpportunityLitigation(acqOpp.Id, litigition.Id, true);
      //Testing is start from here 	
    	Test.startTest();
    			//Insert a defendant to fire a trigger on insert
       		Defendant__c defendant = TestUtil.createDefendant(account.Id, litigition.Id, true);
       		
       		List<Acquisition_Opportunity_Defendant__c> listAODForInsert = [select id from Acquisition_Opportunity_Defendant__c where Acquisition_Opportunity__c =: litigition.Acquisition_Opportunity__c AND Defendant__c =:defendant.Id];
       		//Size of listAODForInsert must be greater than zero.
       //		System.assert(listAODForInsert.size() > 0); 
       		//delete a defendant to fire a trigger on delete
       		delete defendant;
       		List<Acquisition_Opportunity_Defendant__c> listAODForDelete = [select id from Acquisition_Opportunity_Defendant__c where Acquisition_Opportunity__c =: litigition.Acquisition_Opportunity__c AND Defendant__c =:defendant.Id];
       		//Size of listAODForDelete must be equal to zero.
       //		System.assert(listAODForDelete.size() == 0); 
       	Test.stopTest();
    }
    
}