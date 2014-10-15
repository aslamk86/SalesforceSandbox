/****************************************************************************************************************************
 * Name             : TestLitAcquisitionPatentFamiliesCtrl
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Apr, 2012.
 * Purpose          : Test class for LitAcquisitionPatentFamiliesController
 * Task             : T-42964
****************************************************************************************************************************/
@isTest
private class TestLitAcquisitionPatentFamiliesCtrl {

	static testMethod void testLitigationPatentFamily() {
 		//Test Data Creation
 		Account acct = TestUtil.createAccount(true);
    Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test Opp', false);
    Map<String,Id> recTypeMap = Testutil.getRecordType('Acquisition_Opportunity__c');
    acqOpp.RecordTypeId = recTypeMap.get('Litigations');
    insert acqOpp;
    
    //Create litigation 
    Litigation__c litigation = TestUtil.createLitigation(true);
    
    //Create Patent Family
    Assets__c patentFamily = TestUtil.createPortfolio(true);
    Patent__c patent = TestUtil.createPatent(false);
    patent.Patent_Family__c = patentFamily.Id;
    insert patent;
    
    //Link Patent To litigation
    List<Patents_in_Suit__c> lstPtinSuit = new List<Patents_in_Suit__c>();
    lstPtInSuit.add(TestUtil.createPatentInSuit(patent.Id, litigation.Id, false));
    insert lstPtinSuit; 
    
    //Link litigation to acquisition.
		Opportunity_Litigation__c oli = TestUtil.createOpportunityLitigation(acqOpp.Id, litigation.Id, true);
        
    //Test Verification Starts
    Test.startTest();
    ApexPages.Standardcontroller std = new Apexpages.Standardcontroller(acqOpp);
    LitAcquisitionPatentFamiliesController ctrl = new LitAcquisitionPatentFamiliesController(std);
    System.assertEquals(1, ctrl.lstPatentFamilies.size(), 'There must be one patent family related to Acquisition Opportunity.');
    
    //Case when no patent in suit exists
    delete lstPtinSuit;
    ctrl = new LitAcquisitionPatentFamiliesController(std);
    System.assertEquals(0, ctrl.lstPatentFamilies.size());
    
    Test.stopTest();
        
	}
}