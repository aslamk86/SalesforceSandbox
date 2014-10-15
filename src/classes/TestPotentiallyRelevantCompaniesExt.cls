@isTest
private class TestPotentiallyRelevantCompaniesExt{
  static testMethod void myUnitTest() {  
    Map<String,Id> oppRecType = TestUtil.getRecordType('Acquisition_Opportunity__c');
    Account acct = TestUtil.createAccount(true);
    
    //Creating OMA Acquisition Opportunity
    Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Prospect', 'Test', false);
    acqOpp.RecordTypeId = oppRecType.get('OMA');
    insert acqOpp;
    
    //Inserting patent Families;
    List<Assets__c> lstPatentFamily = new List<Assets__c> ();
    Assets__c patentFamily1 = TestUtil.createPortfolio(false);
    lstPatentFamily.add(patentFamily1);
    insert lstPatentFamily;
    
    List<Acquisition_Patent_Families__c> lstAcqPatentFamily = new List<Acquisition_Patent_Families__c>();
    lstAcqPatentFamily.add(TestUtil.createAcqOppFamily(acqOpp.Id, patentFamily1.Id, false));
    insert lstAcqPatentFamily;
    
    Potentially_Relevant_Company__c cwc = new Potentially_Relevant_Company__c();
    cwc.Account__c = acct.Id;
    cwc.Patent_Family__c = patentFamily1.Id;
    insert cwc;
    
    Test.startTest();
    ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(acqOpp);
    PotentiallyReleventCompaniesExt ext = new PotentiallyReleventCompaniesExt(controller);
    System.assertEquals(1,ext.lstCompaniesWhoCare.size());
    Test.stopTest();
    
  } 
}