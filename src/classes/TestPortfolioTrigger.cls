/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestPortfolioTrigger {
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
        rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    }
    static Id getRecortdTypeIdForAcqOpp(String recordType){
        return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
    }
    static testMethod void myUnitTest() {
        List<Acquisition_Patent_Families__c> listAcqPatentFamily = new List<Acquisition_Patent_Families__c>();
        List<Acquisition_Opportunity__c> listAcqOpp = new List<Acquisition_Opportunity__c>();
        List<Assets__c> listpatentFamilies = new List<Assets__c>();
        Account acc = TestUtil.createAccount(true);
       
        Acquisition_Opportunity__c acqOpp1 = TestUtil.createAcquisitionOpp(acc.Id, 'Hold','TestAcqOptyForPortfolioTrigger1', false);
        acqOpp1.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
        listAcqOpp.add(acqOpp1);
        
        Acquisition_Opportunity__c acqOpp2 = TestUtil.createAcquisitionOpp(acc.Id, 'Hold','TestAcqOptyForPortfolioTrigger2', false);
        acqOpp2.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
        acqOpp2.Earliest_priority__c = date.today().addDays(6);
        acqOpp2.Expiration_Date__c = date.today().addDays(7);
        listAcqOpp.add(acqOpp2);
        insert listAcqOpp;
        
       
        
        Test.startTest();
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
            
            Patent__c patent = TestUtil.createPatent(false);
            patent.Patent_Family__c = listpatentFamilies[0].Id;
            insert patent;
            
            listAcqPatentFamily.add(TestUtil.createAcqOppFamily(listAcqOpp[0].Id, listpatentFamilies[0].Id, false));     
            listAcqPatentFamily.add(TestUtil.createAcqOppFamily(listAcqOpp[0].Id, listpatentFamilies[0].Id, false));
            listAcqPatentFamily.add(TestUtil.createAcqOppFamily(listAcqOpp[1].Id, listpatentFamilies[1].Id, false));
            insert listAcqPatentFamily;
            
            listpatentFamilies[0].Assignment_Note__c = 'Assignment';
            listpatentFamilies[0].Summary__c = 'summary1';
            listpatentFamilies[0].Populate_on_All_Patents_in_Portfolio__c = true;
            listpatentFamilies[0].Representative_Claims__c = 'Claim'; 
            
            listpatentFamilies[1].Populate_on_All_Patents_in_Portfolio__c = true;

            
            update listpatentFamilies;
            
        Test.stopTest();
    }
}