/****************************************************************************************************************************
 * Name             : TestAcqOppForPatentFamilyController
 * Created By       : Neeraj(Appirio Offshore)
 * Created Date     : 18 April, 2012.
 * Purpose          : Test Class for AcqOppForPatentFamilyController 
 ****************************************************************************************************************************/
 @isTest
private class TestAcqOppForPatentFamilyController {
  static testMethod void testAcqOppForPatentFamilies() {
    //Test Data Creation
    Account acct = TestUtil.createAccount(true);
    Map<String, Id> recTypeMap = TestUtil.getRecordType('Acquisition_Opportunity__c');
    
    //Create PatentFamily
    Assets__c patentFamily = TestUtil.createPortfolio(true);
    
    Patent__c patent = TestUtil.createPatent(patentFamily.Id, true);
    
    //creating OMA Acquisition Opportunity
    Acquisition_Opportunity__c omaAcqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed', 'TestOptyForAcqOppForPatentFamilyController1 ', false);
    omaAcqOpp.RecordTypeId = recTypeMap.get('OMA');
    insert omaAcqOpp;
    
    //Creating Acquisition Patent Family for OMA Acquisition Opportunity
    Acquisition_Patent_Families__c apf = TestUtil.createAcqOppFamily(omaAcqOpp.Id, patentFamily.Id, true);
    
    //Creating Litigation Acquisition Opportunity
    Acquisition_Opportunity__c litAcqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed', 'TestOptyForAcqOppForPatentFamilyController2', false);
    litAcqOpp.RecordTypeId = recTypeMap.get('Litigations');
    insert litAcqOpp;
    
    //Creating Litigaiton
    Litigation__c litigation = TestUtil.createLitigation(true);
    
    //Creating opportunity litigation
    Opportunity_Litigation__c oppLitigation = TestUtil.createOpportunityLitigation(litAcqOpp.Id, litigation.Id, true);
    
    //Creating LitigationPatentFamily
    Litigation_Patent_Family__c lpf = TestUtil.createLitigationPatentFamily(PatentFamily.Id, litigation.Id, true);
    
    Test.startTest();
    //Test if accessed from Patent Family inline page
    Test.setCurrentPage(Page.AcqOppForPatentFamily);
    Map<String, String> pageParams = ApexPages.currentPage().getParameters();
    pageParams.put('Id', patentFamily.Id);
    
    //creating standard controller with patent family
    ApexPages.Standardcontroller stdCntrl = new Apexpages.Standardcontroller(patentFamily);
    AcqOppForPatentFamilyController controller = new AcqOppForPatentFamilyController(stdCntrl);
    //there must be 2 acquisition opportunity related to patent Family
    System.assertEquals(2, controller.lstAcqOpp.size());
    
    //Test if accessed from Patent Inline page
    Test.setCurrentPage(Page.AcqOppForPatent);
    pageParams = ApexPages.currentPage().getParameters();
    pageParams.put('Id', patent.Id);
    stdCntrl = new Apexpages.Standardcontroller(patent);
    controller = new AcqOppForPatentFamilyController(stdCntrl);
    //there must be 2 acquisition opportunity related to patent
    System.assertEquals(2, controller.lstAcqOpp.size());
    Test.stopTest();
  }
}