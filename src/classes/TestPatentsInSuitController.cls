/*****************************************************************************
 * Name             : TestPatentsInSuitController
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 03 Feb, 2012.
 * Purpose          : Test Class for RelevantLitigationPatentsExt
 * Task             : T-24261
*****************************************************************************/
@isTest
private class TestPatentsInSuitController{

    static testMethod void testRelevantLitigationPatents() {
        
        Account acct = TestUtil.createAccount(true);
        Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test Opp', false);
        acqOpp.RecordTypeId = [Select id 
                               From RecordType 
                               Where SobjectType = 'Acquisition_Opportunity__c'
                               And Name = 'Litigations'
                               Limit 1][0].Id;
        insert acqOpp;
        
        //Create litigation and patents
        Litigation__c litigation = TestUtil.createLitigation(true);
        Patent__c pt1 = TestUtil.createPatent(true);
        Patent__c pt2 = TestUtil.createPatent(true);
        
        //associate 2 patent in litigation
        List<Patents_in_Suit__c> lstPtinSuit = new List<Patents_in_Suit__c>();
        lstPtInSuit.add(TestUtil.createPatentInSuit(pt1.Id, litigation.Id, false));
        lstPtInSuit.add(TestUtil.createPatentInSuit(pt2.Id, litigation.Id, false));
        insert lstPtinSuit; 
        
        //Create Litigation OLI for Acquisition Opportunity.
        Opportunity_Litigation__c oli = TestUtil.createOpportunityLitigation(acqOpp.Id, litigation.Id, true);
        
        Test.startTest();
        Test.setCurrentPage(Page.PatentsInSuit);
        Map <String, String> pageParams = ApexPages.currentPage().getParameters();
        pageParams.put('Id', acqOpp.Id);
        
        ApexPages.Standardcontroller stdCtrl = new ApexPages.Standardcontroller(acqOpp); 
        
        PatentsinSuitController ext = new PatentsinSuitController(stdCtrl);
        System.assertEquals(2, ext.lstPatentsInSuit.size(),'There must be 2 patents in Acquisition Opportunity.');
        
        delete lstPtinSuit;
        ext = new PatentsinSuitController(stdCtrl);
        System.assertEquals(0, ext.lstPatentsInSuit.size(),'There is no patent in Acquisition Opportunity.');
        
        
        Test.stopTest(); 
    }
}