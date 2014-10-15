/****************************************************
    
    SYNC ENGINE CHANGE PROCESSOR TESTS
    
    Built by Hank Ryan Thompson.
    Created 7/5/2013.
    Last updated 10/24/2013 by Hank.
    
    This class contains testMethods which test the
    various pieces of the batch process.
     
****************************************************/

@isTest
public class SyncEngineChangeProcessorTests {
    
    /*=== CHANGE SYNC TEST FUNCTIONS ===*/
    
    public static testMethod void testChangeProcessor_FieldSyncing() {
        // This tests getting patent annotation changes and actually syncing them
        
        system.debug('###testChangeProcessor_FieldSyncing(): Entering function.###' );
       
        String runningJobId; String scheduledJobId;
        CoreAPI.EndpointName theEndpoint = CoreAPI.EndpointName.PatentAnnotationChanges;
        DateTime originalSyncDateTime = DateTime.now().addDays(-1);
       
        // First insert the test records
        Map<String, Object> testRecordMap = SyncEngineTests.createAPITestRecords();
        Patent__c testPatent201 = (Patent__c)testRecordMap.get('testPatent201');
        Patent__c testPatent202 = (Patent__c)testRecordMap.get('testPatent202');
        Assets__c testPatentFamily2 = (Assets__c)testRecordMap.get('testPatentFamily2');
        Acquisition_Opportunity__c testAcquisition1 = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisition1');
        CoreAPIAuthentication__c settingRecord = new CoreAPIAuthentication__c(
            Name = theEndpoint.name(),
            URL__c = 'https://google.com',
            Staging_URL__c = 'https://google.com',
            Token__c = 'abc123',
			Staging_Token__c = 'abc123',
			Last_Sync_Date_Time__c = originalSyncDateTime
        );
        insert settingRecord;
        
        runningJobId = SyncEngineChangeProcessor.getRunningJobId(theEndpoint);
        system.assertEquals(null, runningJobId);
        
        // Start out with an assertion. We're going to check if this field changes.
        system.assertEquals(null, testPatent201.Summary__c); 
        system.assertEquals(null, testPatent202.Summary__c); 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Startup the change processor
        SyncEngine.setDoNotCallout(true);
        SyncEngineChangeProcessor.startProcessor(theEndpoint);
        
        // Now assert that it says that it's running 
        runningJobId = SyncEngineChangeProcessor.getRunningJobId(theEndpoint);
        //system.assert(runningJobId != null);
        // update: The above assertion is false because we have to wait for the start() function to finish asynchronously
        
        // Stop the test and make assertions
        Test.stopTest();
        
        // check the results
        testPatent201 = [select Id, Name, Summary__c from Patent__c where Id = :testPatent201.Id];
        testPatent202 = [select Id, Name, Summary__c from Patent__c where Id = :testPatent202.Id];
        system.assertEquals('summary of patent 201', testPatent201.Summary__c);
        system.assertEquals(null, testPatent202.Summary__c); // this is in the second page so it *should* be null
        
        // This next test was added 9/11/13 because of an error where summaries were rolling up to the patent family but NOT the acquisition.
        // The error ONLY happened when the batch process updated the patent summary, not when it was done manually in the UI.
        // So this test confirms that the summary fields on the patent family and on the acquisition records are updated.
        testPatentFamily2 = [select Id, Name, Summary__c from Assets__c where Id = :testPatentFamily2.Id];
        testAcquisition1 = [select Id, Name, Summary__c from Acquisition_Opportunity__c where Id = :testAcquisition1.Id];
        system.assert(testPatentFamily2.Summary__c != null);
        system.assert(testPatentFamily2.Summary__c.contains('summary of patent 201'));
        system.assert(testAcquisition1.Summary__c != null);
        system.assert(testAcquisition1.Summary__c.contains('summary of patent 201'));
        
        
        // now check the custom setting
        
        // It is no longer running...
        runningJobId = SyncEngineChangeProcessor.getRunningJobId(theEndpoint);
        scheduledJobId = SyncEngineChangeProcessor.getScheduledJobId(theEndpoint);
        Integer nextPage = SyncEngineChangeProcessor.getNextSyncPage(theEndpoint);
        system.assertEquals(null, runningJobId);
        system.assert(scheduledJobId <> null);
        system.assertEquals(2, nextPage);
        
        
        // Done!
        system.debug('###testChangeProcessor_FieldSyncing(): Exiting function.###' );
    }
    
    public static testMethod void testChangeProcessor_OverallFlow() {
        // This tests the flow of the overall process... especially whether errors cause the process to get "stuck" & whether non errors allow the process to continue
        // NOTE: In order to properly test the flow this method SIMULATES the running process by manually instantiating the class and calling the start(), execute() and finish() functions
        
        system.debug('###testChangeProcessor_OverallFlow(): Entering function.###' );
       
        DateTime originalSyncDateTime = DateTime.now().addDays(-1);
        CoreAPI.EndpointName theEndpoint = CoreAPI.EndpointName.PatentAnnotationChanges;
        SyncEngineChangeProcessor theProcessor;
        SyncEngine.ChangeQueue theQueue;
        
        // NOTE: The page & batch sizes have to be manually lowered in order to not hit governor limits (since we are *not* invoking the code in a batch context in this testmethod)
        Integer pageSize = 500;
        Integer batchSize = 50;
        SyncEngineChangeProcessor.pageSizeMap.put(theEndpoint, pageSize);
        SyncEngineChangeProcessor.batchSizeMap.put(theEndpoint, batchSize);
       
        // First insert the test records
        Map<String, Object> testRecordMap = SyncEngineTests.createAPITestRecords();
        Patent__c testPatent201 = (Patent__c)testRecordMap.get('testPatent201');
        Patent__c testPatent202 = (Patent__c)testRecordMap.get('testPatent202');
        CoreAPIAuthentication__c settingRecord = new CoreAPIAuthentication__c(
            Name = theEndpoint.name(),
            URL__c = 'https://google.com',
            Staging_URL__c = 'https://google.com',
            Token__c = 'abc123',
            Staging_Token__c = 'abc123',
            Last_Sync_Date_Time__c = originalSyncDateTime
        );
        insert settingRecord;
        
        system.assertEquals(null, SyncEngineChangeProcessor.getRunningJobId(theEndpoint));
        system.assertEquals(null, SyncEngineChangeProcessor.getScheduledJobId(theEndpoint));
        system.assertEquals(originalSyncDateTime, SyncEngineChangeProcessor.getLastSyncDateTime(theEndpoint));
        system.assertEquals(null, SyncEngineChangeProcessor.getNextSyncPage(theEndpoint));
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        SyncEngine.setDoNotCallout(true);
        
        // Simulate a starting up of the change processor
        theProcessor = new SyncEngineChangeProcessor(theEndpoint);
        theProcessor.start(null);
        theQueue = theProcessor.theQueue;
        system.assert(theQueue != null);
        system.assert(theQueue.changeRows != null);
        system.assertEquals(5, theQueue.changeRows.size()); // there are only 5 unique rows (due to compression)
        
        // Simulate a successful exection of a one batch cycle (and assert that the custom setting was updated correctly)
        theProcessor.execute(null, theQueue.changeRows);
        theProcessor.finish(null);
        system.assertEquals(originalSyncDateTime, SyncEngineChangeProcessor.getLastSyncDateTime(theEndpoint)); // same time
        system.assertEquals(2, SyncEngineChangeProcessor.getNextSyncPage(theEndpoint)); // we continued to page 2
        system.assertEquals(false, SyncEngineChangeProcessor.getSyncIsStuck(theEndpoint)); // we are not stuck
        system.assert(SyncEngineChangeProcessor.getScheduledJobId(theEndpoint) != null);
        
        // Now clear out the scheduled job created by the finish() function
        SyncEngineChangeProcessor.stopProcessor(theEndpoint);
        
        // Then simulate a failed second batch cycle (and assert that the custom setting was updated correctly)
        SyncEngine.setThrowTestError(true); // this will cause the processChanges() function to error out
        Boolean errorWasThrown = false;
        theProcessor.start(null);
        theQueue = theProcessor.theQueue;
        theProcessor.execute(null, theQueue.changeRows); // NOTE: An exception will be thrown, but caught and not passed up to us (because this is a testmethod context)
        theProcessor.finish(null);
        system.assertEquals(originalSyncDateTime, SyncEngineChangeProcessor.getLastSyncDateTime(theEndpoint)); // same time
        system.assertEquals(2, SyncEngineChangeProcessor.getNextSyncPage(theEndpoint)); // the page should stay the same as well
        system.assertEquals(true, SyncEngineChangeProcessor.getSyncIsStuck(theEndpoint)); // we should now be stuck
        system.assert(SyncEngineChangeProcessor.getScheduledJobId(theEndpoint) != null);
        
        // Now clear out the scheduled job created by the finish() function
        SyncEngineChangeProcessor.stopProcessor(theEndpoint);
        
        // Finally make sure that checking the SyncIsStopping checkbox actually works and that clearing the error also clears the stuck checkbox
        SyncEngine.setThrowTestError(false); // clear the error
        SyncEngineChangeProcessor.setSyncIsStopping(theEndpoint, true);
        theProcessor.start(null);
        theQueue = theProcessor.theQueue;
        theProcessor.execute(null, theQueue.changeRows); // NOTE: An exception will be thrown, but caught and not passed up to us (because this is a testmethod context)
        theProcessor.finish(null);
        system.assertEquals(originalSyncDateTime, SyncEngineChangeProcessor.getLastSyncDateTime(theEndpoint)); // same time
        system.assertEquals(3, SyncEngineChangeProcessor.getNextSyncPage(theEndpoint)); // next page
        system.assertEquals(false, SyncEngineChangeProcessor.getSyncIsStuck(theEndpoint)); // we should no longer be stuck
        system.assertEquals(null, SyncEngineChangeProcessor.getScheduledJobId(theEndpoint)); // the process should be stopped
        
        // Stop the test
        Test.stopTest();
        
        // Done!
        system.debug('###testChangeProcessor_OverallFlow(): Exiting function.###' );
    }
    
    public static testMethod void testChangeProcessor_Coverage() {
        // This tests getting patent annotation changes
        
        system.debug('###testChangeProcessor_Coverage(): Entering function.###' );
       
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Startup the change processor
        SyncEngine.setDoNotCallout(true);
        try {SyncEngineChangeProcessor.stopProcessor(CoreAPI.EndpointName.PatentAnnotationChanges);}
        catch(Exception e) {}
        SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.PatentAnnotationChanges);
        
        try {SyncEngineChangeProcessor.stopProcessor(CoreAPI.EndpointName.PatentAnnotationChanges);}
        catch(Exception e) {}
        
        // Stop the test and make assertions
        Test.stopTest();
        
        // Done!
        system.debug('###testChangeProcessor_Coverage(): Exiting function.###' );
    }
    
    public static testMethod void testChangeProcessor_ErrorDuringStart() {
        // An error occuring during start should result in the custom setting being marked as stuck and the processor being rescheduled.
        
        system.debug('###testChangeProcessor_ErrorDuringStart(): Entering function.###' );
       
        String runningJobId; String scheduledJobId;
        CoreAPI.EndpointName theEndpoint = CoreAPI.EndpointName.PatentAnnotationChanges;
        DateTime originalSyncDateTime = DateTime.now().addDays(-1);
       
        // First make sure there is a setting record
        CoreAPIAuthentication__c settingRecord = new CoreAPIAuthentication__c(
            Name = theEndpoint.name(),
            URL__c = 'https://google.com',
            Staging_URL__c = 'https://google.com',
            Token__c = 'abc123',
            Staging_Token__c = 'abc123',
            Last_Sync_Date_Time__c = originalSyncDateTime
        );
        insert settingRecord;
        
        // Make initial assumptions
        system.assertEquals(null, SyncEngineChangeProcessor.getRunningJobId(theEndpoint));
        system.assertEquals(null, SyncEngineChangeProcessor.getScheduledJobId(theEndpoint));
        system.assertEquals(false, SyncEngineChangeProcessor.getSyncIsStuck(theEndpoint));
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Startup the change processor
        SyncEngine.setThrowTestError(true); // this will cause an error during the start() method
        SyncEngine.setDoNotCallout(true); // this will keep us from hitting a callout limit
        SyncEngineChangeProcessor.startProcessor(theEndpoint);
        
        // Stop the test (this firing one round of the execute and finish methods) and make assumptions
        Test.stopTest();
        
        // now check the custom setting
        system.assertEquals(true, SyncEngineChangeProcessor.getSyncIsStuck(theEndpoint));
        system.assertEquals(null, SyncEngineChangeProcessor.getRunningJobId(theEndpoint));
        system.assert(SyncEngineChangeProcessor.getScheduledJobId(theEndpoint) != null);
        
        // Done!
        system.debug('###testChangeProcessor_ErrorDuringStart(): Exiting function.###' );
    }
    
}