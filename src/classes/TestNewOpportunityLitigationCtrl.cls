/*******************************************************************************
 * Name             : TestNewOpportunityLitigationCtrl
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 15 Mar, 2012.
 * Purpose          : Test class for NewOpportunityLitigationCtrl
 *                    T-36662 
 ******************************************************************************/
@isTest
private with sharing class TestNewOpportunityLitigationCtrl {
  static testMethod void testNewOpportunityLitigationCtrl() {
  	Account acct = TestUtil.createAccount(true);
  	Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test', true);
  	List<Litigation__c> lstLitigation = new List<Litigation__c> ();
  	lstLitigation.add(TestUtil.createLitigation(false));
  	lstLitigation.add(TestUtil.createLitigation(false));
  	lstLitigation.add(TestUtil.createLitigation(false));
  	for(Litigation__c litigation : lstLitigation) {
      litigation.case_key__c = 'caseKey';
    }
  	insert lstLitigation;
  	
  	List<Patent__c> lstPatents = new List<Patent__c> ();
  	lstPatents.add(TestUtil.createPatent(false));
  	lstPatents.add(TestUtil.createPatent(false));
  	lstPatents.add(TestUtil.createPatent(false));
  	insert lstPatents;
  	
  	List<Patents_in_Suit__c> lstPatentsInSuit = new List<Patents_in_Suit__c> ();
  	lstPatentsInSuit.add(TestUtil.createPatentInSuit(lstPatents[0].Id, lstLitigation[0].Id, false));
  	lstPatentsInSuit.add(TestUtil.createPatentInSuit(lstPatents[1].Id, lstLitigation[0].Id, false));
  	lstPatentsInSuit.add(TestUtil.createPatentInSuit(lstPatents[2].Id, lstLitigation[0].Id, false));
  	insert lstPatentsInSuit;
  	
  	TestUtil.createOpportunityLitigation(acqOpp.Id, lstLitigation[1].Id, true);
  	
  	Test.startTest();
  	Test.setCurrentPage(Page.NewOpportunityLitigation);
  	Map<String,String> pageParams = ApexPages.currentPage().getParameters();
  	pageParams.put('acqId', acqOpp.Id);
  	
  	NewOpportunityLitigationCtrl controller = new NewOpportunityLitigationCtrl();

// --- START REMOVED ----------------------------------------------
//
// Martin Sieler: search without any criteria will search for litigations
//                with same patents as currently added litigations
//
/*
  	//Search without any criteria
  	controller.search();
  	System.assertEquals(Label.Search_Criteria_Required, ApexPages.getMessages()[0].getDetail());
*/
// --- END REMOVED ------------------------------------------------

  	//search from patent Number
  	controller.patentNumToSearch = String.valueOf(lstPatents[0].Patent_No__c);
  	controller.search();
  	System.assertEquals(1,controller.lstLitWrapper.size());
  	
  	//create opportunity litigation record
  	controller.lstLitWrapper[0].isSelected = true;
  	controller.createOpportunityLitigations();
  	System.assertEquals(1, [Select count() 
  	                        From Opportunity_Litigation__c
  	                        Where Acquisition_Opportunity__c = :acqOpp.Id
  	                        And Litigation__c = :lstLitigation[0].Id]);
  	
  	//this time there will be an existing opportunity litigation record
  	controller = new NewOpportunityLitigationCtrl();
  	//Cancel should return back to acquisitio opportunity
  	PageReference pg = controller.cancel();
  	System.assertEquals(pg.getURL(), '/' + acqOpp.Id);
  	
  	//search through case key
  	controller.CaseKeyToSrch = 'caseKey'; 
  	controller.search();
  	System.assertEquals(3,controller.lstLitWrapper.size());
  	
  	//create opportunity litigation record
    controller.lstLitWrapper[0].isSelected = true;
    controller.lstLitWrapper[1].isSelected = true;
    controller.lstLitWrapper[2].isSelected = true;
    controller.createOpportunityLitigations();
    System.assertEquals(3, [Select count() 
                            From Opportunity_Litigation__c
                            Where Acquisition_Opportunity__c = :acqOpp.Id]);
  	
  	//No Record Found
  	controller = new NewOpportunityLitigationCtrl();
  	controller.patentNumToSearch = 'abc';
  	controller.search();
//  	System.assertEquals(Label.No_Record_Found, ApexPages.getMessages()[1].getDetail());
  	Test.stopTest();
  	
  }
}