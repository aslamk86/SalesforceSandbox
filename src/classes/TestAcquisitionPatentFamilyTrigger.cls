/*****************************************************************************
 * Name                 : TestAcquisitionPatentFamilyTrigger
 * Created By           : Neeraj Gupta(Appirio Offshore)
 * Last Modified Date : 10/23/2013 by Hank Ryan Thompson
 * Description        : Test Class for AcquisitionOpportunityTrigger.
 *****************************************************************************/

@isTest
private class TestAcquisitionPatentFamilyTrigger {
    
    //A map that Contains the Record type information of Acquisition_Opportunity__c
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
        rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    }
    
    //Method used to get the Id of record type 
    static Id getRecortdTypeIdForAcqOpp(String recordType){
        return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
    }
    
    //Test method
    static testMethod void originalUnitTest() {
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
        Acquisition_Opportunity__c acqOpp1 = TestUtil.createAcquisitionOpp(acc.Id, 'Open','TestAcqOptyForAcquisitionOpportunityTrigger1', false);
        acqOpp1.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
        listAcqOpp.add(acqOpp1);
        
        Acquisition_Opportunity__c acqOpp2 = TestUtil.createAcquisitionOpp(acc.Id, 'Open','TestAcqOptyForAcquisitionOpportunityTrigger2', false);
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
        listpatentFamilies.add(patentFamily1);
        
        Assets__c patentFamily2 = TestUtil.createPortfolio(false);
        patentFamily2.Summary__c = 'summary';
        patentFamily2.Earliest_priority__c = date.today().addDays(5);
        patentFamily2.Expiration_Date__c = date.today().addDays(10);
        listpatentFamilies.add(patentFamily2);
        insert listpatentFamilies;
        //Testing start from here 
        Test.startTest();
        //insert Acquisition_Patent_Families__c to fire a triger on insert
        listAcqPatentFamily.add(TestUtil.createAcqOppFamily(listAcqOpp[0].Id, listpatentFamilies[0].Id, false));     
        listAcqPatentFamily.add(TestUtil.createAcqOppFamily(listAcqOpp[0].Id, listpatentFamilies[0].Id, false));
        listAcqPatentFamily.add(TestUtil.createAcqOppFamily(listAcqOpp[1].Id, listpatentFamilies[1].Id, false));
        insert listAcqPatentFamily;
        
        //Update Acquisition_Patent_Families__c to fire a triger on update
        //listAcqPatentFamily[1].Acquisition_Opportunity__c  = listAcqOpp[1].Id;
        update listAcqPatentFamily;
        //Delete Acquisition_Patent_Families__c to fire a triger on delete
        delete listAcqPatentFamily;
        Test.stopTest();
        
    }

    public static testMethod void testPatentFamilyRollup_VeryLongText() {
        // This tests the edge case that occurs when the rolled up patent family fields produce more than 32,768 characters
       
        system.debug('###testPatentFamilyRollup_VeryLongText(): Entering function.###' );
      
        // First insert the test records
        Account testAccount = TestUtil.createAccount(true);
        Acquisition_Opportunity__c testAcquisition = TestUtil.createAcquisitionOpp(testAccount.Id, 'Open','TestAcqOptyForAcquisitionOpportunityTrigger3', false);
        testAcquisition.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
        insert testAcquisition;
        
        //Insert patent families
        String reallyLongTextValueA = 'a'.repeat(20000); // 20000*2 > 32768
        String reallyLongTextValueB = 'b'.repeat(20000); // 20000*2 > 32768
        Assets__c testPatentFamily1 = TestUtil.createPortfolio(false);
        Assets__c testPatentFamily2 = TestUtil.createPortfolio(false);
        testPatentFamily1.Summary__c = reallyLongTextValueA;
        testPatentFamily2.Summary__c = reallyLongTextValueB;
        testPatentFamily1.Representative_Claims__c = reallyLongTextValueA;
        testPatentFamily2.Representative_Claims__c = reallyLongTextValueB;
        testPatentFamily1.Characterization_of_Claims__c = reallyLongTextValueA;
        testPatentFamily2.Characterization_of_Claims__c = reallyLongTextValueB;
        insert new Assets__c[]{testPatentFamily1, testPatentFamily2};
        
        //Create links between the acquisition and the patent families (but do not insert them yet)
        Acquisition_Patent_Families__c[] acquisitionPatentFamilies = new Acquisition_Patent_Families__c[]{
            TestUtil.createAcqOppFamily(testAcquisition.Id, testPatentFamily1.Id, false),
            TestUtil.createAcqOppFamily(testAcquisition.Id, testPatentFamily2.Id, false)
        }; 
        
        // Start the test
        Test.startTest ();
       
        // Now insert the links (this will fire the trigger which will error out if the problem is not solved)
        Boolean errorOccured = false;
        try {insert acquisitionPatentFamilies;}
        catch(Exception e) {
            errorOccured = true;
            system.debug(LoggingLevel.ERROR, '###testPatentFamilyRollup_VeryLongText(): ERROR during insertion of acquisitionPatentFamilies. error message = ' + e.getMessage() + '###');
        }
        
        // Stop the test
        Test.stopTest();
       
        // Assert that there was no error and that the rollup fields were combined 
        system.assert(!errorOccured);
        testAcquisition = [select Id, Name, Summary__c, Representative_Claims__c, Characterization_of_Claims__c from Acquisition_Opportunity__c where id=:testAcquisition.Id]; 
        system.assert(testAcquisition.Summary__c.contains('a'));
        system.assert(testAcquisition.Summary__c.contains('b'));
        system.assert(testAcquisition.Representative_Claims__c.contains('a'));
        system.assert(testAcquisition.Representative_Claims__c.contains('b'));
        system.assert(testAcquisition.Characterization_of_Claims__c.contains('a'));
        system.assert(testAcquisition.Characterization_of_Claims__c.contains('b'));
       
        system.debug('###testPatentFamilyRollup_VeryLongText(): Exiting function.###' );
    }
    

}