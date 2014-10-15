/*****************************************************************************
 * Name                 : TestLitigationPatentFamilyTrigger
 * Created By           : Neeraj Gupta(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for LitigationPatentFamilyTrigger.
 *****************************************************************************/
@isTest
private class TestLitigationPatentFamilyTrigger {
    //A map that contains record type info of Acquisition_Opportunity__c
  static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
    Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
    rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    }
    //Method that is used to return the Id of record type of Acquisition_Opportunity__c 
    static Id getRecortdTypeIdForAcqOpp(String recordType){
      return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
  }
  //Test Method to check the quality of Code
    static testMethod void myUnitTest() {
        //Prepare test data
        //List of Acquisition_Patent_Families__c
    List<Acquisition_Patent_Families__c> listAcqPatentFamily = new List<Acquisition_Patent_Families__c>();
    //List of Acquisition_Opportunity__c
    List<Acquisition_Opportunity__c> listAcqOpp = new List<Acquisition_Opportunity__c>();
    //List of patent families
    List<Assets__c> listpatentFamilies = new List<Assets__c>();
    //Create Account
    Account acc = TestUtil.createAccount(true);
   //Insert Acq Opportunities
    Acquisition_Opportunity__c acqOpp1 = TestUtil.createAcquisitionOpp(acc.Id, 'Hold','TestAcqOptyForLitigationPatentFamilyTrigger1', false);
    acqOpp1.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
    listAcqOpp.add(acqOpp1);
    
    Acquisition_Opportunity__c acqOpp2 = TestUtil.createAcquisitionOpp(acc.Id, 'Hold','TestAcqOptyForLitigationPatentFamilyTrigger2', false);
    acqOpp2.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
    acqOpp2.Earliest_priority__c = date.today().addDays(6);
    acqOpp2.Expiration_Date__c = date.today().addDays(7);
    listAcqOpp.add(acqOpp2);
    insert listAcqOpp;
     
    //Insert patent families   
        Assets__c patentFamily1 = TestUtil.createPortfolio(false);
    patentFamily1.Summary__c = 'summary';
    patentFamily1.Earliest_priority__c = date.today().addDays(5);
    patentFamily1.Expiration_Date__c = date.today().addDays(10);
    patentFamily1.Assignment_Note__c = 'ABC';
    patentFamily1.Populate_on_All_Patents_in_Portfolio__c = false;
    listpatentFamilies.add(patentFamily1);
    
    Assets__c patentFamily2 = TestUtil.createPortfolio(false);
    patentFamily2.Summary__c = 'summary';
    patentFamily2.Earliest_priority__c = date.today().addDays(5);
    patentFamily2.Expiration_Date__c = date.today().addDays(10);
    listpatentFamilies.add(patentFamily2);
      insert listpatentFamilies;
    
    //Insert Litigation   
    Litigation__c litigation = TestUtil.createLitigation(true);
    //Testing is start from here
    Test.startTest();
        //Insert Litigation Patent Family to fire a trigger on Insert
        Litigation_Patent_Family__c litigationPF = TestUtil.createLitigationPatentFamily(listpatentFamilies[0].Id, litigation.Id, true);
       
        litigationPF.Litigation__c = TestUtil.createLitigation(true).Id;
        //update Litigation Patent Family to fire a trigger on update
        update litigationPF;
        //delete Litigation Patent Family to fire a trigger on delete
        delete litigationPF;
       
    Test.stopTest();
  }
}