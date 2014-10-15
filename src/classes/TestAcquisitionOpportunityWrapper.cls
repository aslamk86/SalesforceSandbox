/*******************************************************************************
 * Name             : TestAcquisitionOpportunityWrapper
 * Created By       : Neeraj Gupta(Appirio Offshore)
 * Created Date     : 25 Feb, 2012.
 * Purpose          : Test class for AcquisitionOpportunityWrapper. 
 * Task               T-34016  
 ******************************************************************************/
@isTest
private class TestAcquisitionOpportunityWrapper {

	static testMethod void TestOMAOpp() {
	  Account acct = TestUtil.createAccount(true);
	  Acquisition_Opportunity__c OMAAcqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test', false);
	  Map<String, Id> recTypes = TestUtil.getRecordType('Acquisition_Opportunity__c');
	  OMAAcqOpp.RecordTypeId = recTypes.get('OMA');
	  insert OMAAcqOpp;
	  
	  Patent__c patent = TestUtil.createPatent(true);
	  List<OMA_Patent__c> lstOMAPatent = new List<OMA_Patent__c>();
	  
	  lstOMAPatent.add(TestUtil.createOMAPatent(OMAAcqOpp.Id, patent.Id, false));
	  lstOMAPatent.add(TestUtil.createOMAPatent(OMAAcqOpp.Id, patent.Id, false));
	  lstOMAPatent.add(TestUtil.createOMAPatent(OMAAcqOpp.Id, patent.Id, false));
	  insert lstOMAPatent; 
	  
	  Test.startTest();
	  List<Acquisition_Opportunity__c> lstAcqOpp = AcquisitionOpportunityUtility.getAcqusitionOpportunity(new Set<Id>{OMAAcqOpp.Id});
	  AcquisitionOpportunityWrapper aow = new AcquisitionOpportunityWrapper(lstAcqOpp.get(0));
	  Test.stopTest();
	}
    
	static testMethod void TestLitigationOpp() {
	  Account acct = TestUtil.createAccount(true);
	  Acquisition_Opportunity__c litAcqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test', false);
	  Map<String, Id> recTypes = TestUtil.getRecordType('Acquisition_Opportunity__c');
	  litAcqOpp.RecordTypeId = recTypes.get('Litigations');
	  insert litAcqOpp;
	  
	  List<Litigation__c> lstLitigation = new List<Litigation__c>();
	  lstLitigation.add(TestUtil.createLitigation(false));
	  //lstLitigation.add(TestUtil.createLitigation(false));
	  //lstLitigation.add(TestUtil.createLitigation(false));
	  insert lstLitigation;
	  
	  Patent__c patent = TestUtil.createPatent(true);
	  List<Patents_in_Suit__c> lstPatentInSuit = new List<Patents_in_Suit__c>();
	  
	  lstPatentInSuit.add(TestUtil.createPatentInSuit(patent.Id, lstLitigation[0].Id, false)); 
	  lstPatentInSuit.add(TestUtil.createPatentInSuit(patent.Id, lstLitigation[0].Id, false));
	  lstPatentInSuit.add(TestUtil.createPatentInSuit(patent.Id, lstLitigation[0].Id, false));
	  insert lstPatentInSuit;
	  
	  List<Defendant__c> lstDefendant = new List<Defendant__c>();  
	  lstDefendant.add(TestUtil.createDefendant(acct.Id, lstLitigation[0].Id, false));
	  lstDefendant.add(TestUtil.createDefendant(acct.Id, lstLitigation[0].Id, false));
	  lstDefendant.add(TestUtil.createDefendant(acct.Id, lstLitigation[0].Id, false));
	  insert lstDefendant;
	  
	  lstDefendant = [Select Account__r.Name, Date_Terminated__c From Defendant__c Where id in :lstDefendant];
	  
	  Test.startTest();
	  List<Acquisition_Opportunity__c> lstAcqOpp = AcquisitionOpportunityUtility.getAcqusitionOpportunity(new Set<Id>{litAcqOpp.Id});
	  AcquisitionOpportunityWrapper aow = new AcquisitionOpportunityWrapper(lstAcqOpp.get(0), null, null, false);
	  
	  Map<Id, Litigation__c> mapLitigation = AcquisitionOpportunityUtility.getLitigationMap(new Set<Id>{lstLitigation[0].Id});
	  aow = new AcquisitionOpportunityWrapper(lstAcqOpp.get(0), lstDefendant  , mapLitigation.get(lstLitigation[0].Id), true);
	  Test.stopTest();
	}
}