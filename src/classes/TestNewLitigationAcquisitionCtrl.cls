/*****************************************************************************
 * Name             : TestNewLitigationAcquisitionCtrl
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 15 Mar, 2012.
 * Purpose          : Test Class for NewLitigationAcquisitionCtrl
 *                    T-36662  
 *****************************************************************************/
@isTest
private class TestNewLitigationAcquisitionCtrl {
	static testMethod void testNewLitigationAcquisition() {
    Account acct = TestUtil.createAccount(true);
    //Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test', true);
    Litigation__c litigation = TestUtil.createLitigation(true);
    
    Test.startTest();
    Test.setCurrentPage(Page.NewLitigationAcquisition);
    Map<String, String> pageParams = ApexPages.currentPage().getParameters();
    pageParams.put('lid', litigation.Id);
    
    NewLitigationAcquisitionCtrl controller = new NewLitigationAcquisitionCtrl();
    controller.acqOpp.ContractEffectiveDate__c = Date.today();
    controller.acqopp.Name = 'Test Acq';
    controller.acqopp.Account__c = acct.Id;
    controller.acqopp.StageName__c = 'Closed Won';
    controller.acqopp.Amount_for_Pipeline__c = 10;
    
    controller.save();
    
    System.assertNotEquals(null, controller.acqOpp.Id);
    System.assertEquals(1, [Select count() 
                            From Opportunity_Litigation__c
                            Where Acquisition_Opportunity__c = :controller.acqOpp.Id
                            And Litigation__c = :litigation.Id]);
    
    PageReference pg = controller.cancel();
    
    System.assertEquals(pg.getURL(), '/' + litigation.Id);
    Test.stopTest();
  }
}