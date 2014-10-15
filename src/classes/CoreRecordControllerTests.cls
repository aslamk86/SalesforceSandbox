/****************************************************
    
    CORE RECORD CONTROLLER TESTS
    
    Built by Hank Ryan Thompson.
    Created 6/5/2013.
    Last updated 6/5/2013 by Hank.
    
    This class contains testMethods to test the
    functionality of CoreRecordController.  It is
    only designed to achieve test coverage since
    most of the underlying functionality is already
    tested in SyncEngineTests.
     
****************************************************/

@isTest
public class CoreRecordControllerTests {
      
    public static testMethod void testCoreRecordController_Standard() {
        // This tests the standard invocation method
        
        system.debug('###testCoreRecordController_Standard(): Entering function.###' );
        
        CoreRecordController controller;
        
        // Start the test
        Test.startTest();
        
        // Invoke controller with no key
        controller = new CoreRecordController();
        
        // Invoke the controller with a key
        ApexPages.currentPage().getParameters().put('key', '1234567');
        controller = new CoreRecordController();
        
        // Stop the test
        Test.stopTest();
        
        system.debug('###testCoreRecordController_Standard(): Exiting function.###' );
    }
    
    public static testMethod void testCoreRecordController_Extension() {
        // This tests the standard invocation method
        
        system.debug('###testCoreRecordController_Extension(): Entering function.###' );
        
        CoreRecordController controller;
        ApexPages.StandardController patentController;
        ApexPages.StandardController patentFamilyController;
        ApexPages.StandardController accountController;
        
        // First create some test records
        Map<String, Object> testRecordMap = SyncEngineTests.createAPITestRecords();
        Patent__c testPatent201 = (Patent__c)testRecordMap.get('testPatent201');
        Patent__c testPatent301 = (Patent__c)testRecordMap.get('testPatent301');
        Assets__c testPatentFamily2 = (Assets__c)testRecordMap.get('testPatentFamily3');
        Assets__c testPatentFamily3 = (Assets__c)testRecordMap.get('testPatentFamily3');
        Account testAccount = new Account();
        
        // The twos will be errors (with missing primary keys)... so we need to clear out their keys
        testPatent201.put(SyncEngine.PrimaryKey_Salesforce.get(SyncEngine.CoreObject.Patent), null);
        testPatentFamily2.put(SyncEngine.PrimaryKey_Salesforce.get(SyncEngine.CoreObject.PatentFamily), null);
        
        // Start the test
        Test.startTest();
        
        // Invoke with an invalid object
        accountController = new ApexPages.StandardController(testAccount);
        controller = new CoreRecordController(accountController);
        controller.getPatent();
        controller.getPatentDetailURL();
        controller.getPatentFamily();
        controller.getPatentFamilyDetailURL();
        
        // Invoke controller with no key for each object type
        patentController = new ApexPages.StandardController(testPatent201);
        patentFamilyController = new ApexPages.StandardController(testPatentFamily2);
        controller = new CoreRecordController(patentController);
        controller = new CoreRecordController(patentFamilyController);
        
        // Invoke the controller with a key for each object type
        patentController = new ApexPages.StandardController(testPatent301);
        patentFamilyController = new ApexPages.StandardController(testPatentFamily3);
        controller = new CoreRecordController(patentController);
        controller = new CoreRecordController(patentFamilyController);
        
        // More test coverage
        controller.getPatent();
        controller.getPatentDetailURL();
        controller.getPatentFamily();
        controller.getPatentFamilyDetailURL();
        controller.setPatent(testPatent301);
        controller.setPatentFamily(testPatentFamily3);
        controller.getIsError();
        
        CoreRecordController.ChildPatentRow cpr = new CoreRecordController.ChildPatentRow(testPatent201);
        cpr.getPatentDetailURL();
        cpr.patent = null;
        cpr.getPatentDetailURL();
        cpr.getIsInSalesforce();
        
        // Stop the test
        Test.stopTest();
        
        system.debug('###testCoreRecordController_Extension(): Exiting function.###' );
    }
    
}