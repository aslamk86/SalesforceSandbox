/****************************************************
    
    SYNC ENGINE TESTS
    
    Built by Hank Ryan Thompson.
    Created 4/18/20013.
    Last updated 10/24/2013 by Hank.
    
    This class contains testMethods that test the
    functionality of the Sync Engine as well as the
    underlying functionality on which the Sync Engine
    depends (such as the triggers).
     
****************************************************/

@isTest
public class SyncEngineTests {
    
    /*=== CHANGE SYNC TEST FUNCTIONS ===*/
    
    public static testMethod void testSyncEngine_ProcessLongPatentNumbers() {
        // This makes sure that the object id on change rows is properly filtered for patents
        
        system.debug('###testSyncEngine_ProcessLongPatentNumbers(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        
        SyncEngine.ChangeRow[] rawChangeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PatentFamilyChanges, 'added', SyncEngine.CoreObject.Patent, 'US0000201A1', DateTime.now(), 1, 2)
        };
                
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        SyncEngine.ChangeRow[] changeRows = SyncEngine.sortAndFilterChangeRowList(rawChangeRows);
        SyncEngine.processChanges(changeRows);
        
        // Stop test and make assertions
        Test.stopTest();
        
        // Assert that the patent family matches
        system.assertEquals('Changes Synced', changeRows[0].processingResult);
        
        system.debug('###testSyncEngine_ProcessLongPatentNumbers(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_ProcessClaimChartedCompanyChanges() {
        system.debug('###testSyncEngine_ProcessClaimChartedCompanyChanges(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Account relatedAccount1 = (Account)testRecordMap.get('relatedAccount1');
        Patent__c relatedPatent2 = (Patent__c)testRecordMap.get('relatedPatent2');
        Patent__c relatedPatent3 = (Patent__c)testRecordMap.get('relatedPatent3');
        Accounts_with_Claim_Charts__c testClaimChartedCompanyA = (Accounts_with_Claim_Charts__c)testRecordMap.get('testClaimChartedCompanyA');
        Accounts_with_Claim_Charts__c testClaimChartedCompanyB = (Accounts_with_Claim_Charts__c)testRecordMap.get('testClaimChartedCompanyB');
        Accounts_with_Claim_Charts__c testClaimChartedCompanyC; // doesn't exist yet
        
        // Create change rows (this simulates the starting point since we can't do both callouts in one testmethod)
        SyncEngine.ChangeRow[] changeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.ClaimChartedCompanyChanges, 'changed', SyncEngine.CoreObject.ClaimChartedCompany, '-992011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.ClaimChartedCompanyChanges, 'deleted', SyncEngine.CoreObject.ClaimChartedCompany, '-992013', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.ClaimChartedCompanyChanges, 'inserted', SyncEngine.CoreObject.ClaimChartedCompany, '-993011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.ClaimChartedCompanyChanges, 'deleted', SyncEngine.CoreObject.ClaimChartedCompany, '-994014', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.ClaimChartedCompanyChanges, 'deleted', SyncEngine.CoreObject.ClaimChartedCompany, '-9999999', DateTime.now().addDays(-14), 1, 2)
        }; 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        SyncEngine.processChanges(changeRows);
        
        // Stop the test and make assertions
        Test.stopTest();
        Accounts_with_Claim_Charts__c[] claimChartedCompanies = [select Id, Patent__c, Core_Claim_Charted_Company_Id__c, Account__c from Accounts_with_Claim_Charts__c where Core_Claim_Charted_Company_Id__c in ('-992011', '-992013', '-993011', '-994014', '-9999999') and IsDeleted=false]; 
        Map<String, Accounts_with_Claim_Charts__c> claimChartedCompanyMap = new Map<String, Accounts_with_Claim_Charts__c>();
        for (Accounts_with_Claim_Charts__c ccc:claimChartedCompanies)
            claimChartedCompanyMap.put(ccc.Core_Claim_Charted_Company_Id__c, ccc);
        
        system.assertEquals(2, claimChartedCompanies.size()); // Only items -992011 and -993011 should be present
        system.assert(claimChartedCompanyMap.containsKey(testClaimChartedCompanyA.Core_Claim_Charted_Company_Id__c)); // should've been "updated" (though there are no fields to update)
        system.assert(!claimChartedCompanyMap.containsKey(testClaimChartedCompanyB.Core_Claim_Charted_Company_Id__c)); // should've bee deleted
        system.assert(claimChartedCompanyMap.containsKey('-993011')); // should've been inserted
        
        // Assert that the related field values made it over (from the mock)
        testClaimChartedCompanyA = claimChartedCompanyMap.get(testClaimChartedCompanyA.Core_Claim_Charted_Company_Id__c);
        testClaimChartedCompanyC = claimChartedCompanyMap.get('-993011');
        system.assertEquals(relatedPatent2.Id, testClaimChartedCompanyA.Patent__c);
        system.assertEquals(relatedAccount1.Id, testClaimChartedCompanyA.Account__c);
        system.assertEquals(relatedPatent3.Id, testClaimChartedCompanyC.Patent__c);
        system.assertEquals(relatedAccount1.Id, testClaimChartedCompanyC.Account__c);
        
        // one last chunk of assertions: make sure that the change summaries are correct
        //system.debug(LoggingLevel.ERROR, '###testSyncEngine_ProcessClaimChartedCompanyChanges(): About to assert with changeRows = ' + changeRows + '.###' );
        system.assert(changeRows[0].processingResult.contains('No Changes'));
        system.assert(changeRows[1].processingResult.contains('Record Deleted'));
        system.assert(changeRows[2].processingResult.contains('Record Inserted'));
        system.assert(changeRows[3].processingResult.contains('No Salesforce Match to Delete'));
        system.assert(changeRows[4].processingResult.contains('No Salesforce Match to Delete'));
        
        // Done!
        system.debug('###testSyncEngine_ProcessClaimChartedCompanyChanges(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_ProcessLicenseeChanges() {
        system.debug('###testSyncEngine_ProcessLicenseeChanges(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Account relatedAccount1 = (Account)testRecordMap.get('relatedAccount1');
        Patent__c relatedPatent2 = (Patent__c)testRecordMap.get('relatedPatent2');
        Patent__c relatedPatent3 = (Patent__c)testRecordMap.get('relatedPatent3');
        Licensees__c testLicenseeA = (Licensees__c)testRecordMap.get('testLicenseeA');
        Licensees__c testLicenseeB = (Licensees__c)testRecordMap.get('testLicenseeB');
        Licensees__c testLicenseeC; // doesn't exist yet
        
        // Create change rows (this simulates the starting point since we can't do both callouts in one testmethod)
        SyncEngine.ChangeRow[] changeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.LicenseeChanges, 'changed', SyncEngine.CoreObject.Licensee, '-992011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.LicenseeChanges, 'deleted', SyncEngine.CoreObject.Licensee, '-992013', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.LicenseeChanges, 'inserted', SyncEngine.CoreObject.Licensee, '-993011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.LicenseeChanges, 'deleted', SyncEngine.CoreObject.Licensee, '-994014', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.LicenseeChanges, 'deleted', SyncEngine.CoreObject.Licensee, '-9999999', DateTime.now().addDays(-14), 1, 2)
        }; 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        SyncEngine.processChanges(changeRows);
        
        // Stop the test and make assertions
        Test.stopTest();
        Licensees__c[] licensees = [select Id, Patent__c, Core_Licensee_Id__c, Account__c from Licensees__c where Core_Licensee_Id__c in ('-992011', '-992013', '-993011', '-994014', '-9999999') and IsDeleted=false]; 
        Map<String, Licensees__c> licenseeMap = new Map<String, Licensees__c>();
        for (Licensees__c l:licensees)
            licenseeMap.put(l.Core_Licensee_Id__c, l);
        
        system.assertEquals(2, licensees.size()); // Only items -992011 and -993011 should be present
        system.assert(licenseeMap.containsKey(testLicenseeA.Core_Licensee_Id__c)); // should've been "updated" (though there are no fields to update)
        system.assert(!licenseeMap.containsKey(testLicenseeB.Core_Licensee_Id__c)); // should've bee deleted
        system.assert(licenseeMap.containsKey('-993011')); // should've been inserted
        
        // Assert that the related field values made it over (from the mock)
        testLicenseeA = licenseeMap.get(testLicenseeA.Core_Licensee_Id__c);
        testLicenseeC = licenseeMap.get('-993011');
        system.assertEquals(relatedPatent2.Id, testLicenseeA.Patent__c);
        system.assertEquals(relatedAccount1.Id, testLicenseeA.Account__c);
        system.assertEquals(relatedPatent3.Id, testLicenseeC.Patent__c);
        system.assertEquals(relatedAccount1.Id, testLicenseeC.Account__c);
        
        // one last chunk of assertions: make sure that the change summaries are correct
        //system.debug(LoggingLevel.ERROR, '###testSyncEngine_ProcessLicenseeChanges(): About to assert with changeRows = ' + changeRows + '.###' );
        system.assert(changeRows[0].processingResult.contains('No Changes'));
        system.assert(changeRows[1].processingResult.contains('Record Deleted'));
        system.assert(changeRows[2].processingResult.contains('Record Inserted'));
        system.assert(changeRows[3].processingResult.contains('No Salesforce Match to Delete'));
        system.assert(changeRows[4].processingResult.contains('No Salesforce Match to Delete'));
        
        // Done!
        system.debug('###testSyncEngine_ProcessLicenseeChanges(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_ProcessPatentAnnotationChanges() {
        system.debug('###testSyncEngine_GetPatentAnnotationChanges(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Patent__c testPatent201 = (Patent__c)testRecordMap.get('testPatent201');
        Patent__c testPatent202 = (Patent__c)testRecordMap.get('testPatent202');
        
        // Start out with an assertion. We're going to make sure this field changes.
        system.assertEquals(null, testPatent201.Summary__c); 
        system.assertEquals(null, testPatent202.Summary__c); 
        
        // Create change rows (this simulates the starting point since we can't do both callouts in one testmethod)
        SyncEngine.ChangeRow[] changeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PatentAnnotationChanges, 'changed', SyncEngine.CoreObject.Patent, 'US0000201', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PatentAnnotationChanges, 'changed', SyncEngine.CoreObject.Patent, 'US0000202', DateTime.now().addDays(-14), 1, 2)
        }; 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        SyncEngine.processChanges(changeRows);
        
        // Stop the test and make assertions
        Test.stopTest();
        
        testPatent201 = [select Id, Name, Summary__c from Patent__c where Id = :testPatent201.Id];
        testPatent202 = [select Id, Name, Summary__c from Patent__c where Id = :testPatent202.Id];
        
        system.assertEquals('summary of patent 201', testPatent201.Summary__c);
        system.assertEquals('summary of patent 202', testPatent202.Summary__c); 
        
        // Done!
        system.debug('###testSyncEngine_GetPatentAnnotationChanges(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_ProcessAcquisitionChanges() {
        system.debug('###testSyncEngine_ProcessAcquisitionChanges(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Acquisition_Opportunity__c testAcquisition1 = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisition1');
        Acquisition_Opportunity__c testAcquisition2 = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisition2');
        
        // Create change rows (this simulates the starting point since we can't do both callouts in one testmethod)
        SyncEngine.ChangeRow[] changeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PortfolioAnnotationChanges, 'changed', SyncEngine.CoreObject.Acquisition, testAcquisition1.Id, DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PortfolioAnnotationChanges, 'changed', SyncEngine.CoreObject.Acquisition, testAcquisition2.Id, DateTime.now().addDays(-14), 1, 2)
        }; 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        SyncEngine.processChanges(changeRows);
        
        // Stop the test
        Test.stopTest();
        
        // Assert that the notes synced over
        //system.debug(LoggingLevel.ERROR, '###testSyncEngine_ProcessAcquisitionChanges(): About to assert with changeRows = ' + changeRows + '.###' );
        testAcquisition1 = [select Id, Name, Analysis_Notes__c from Acquisition_Opportunity__c where Id = :testAcquisition1.Id];
        testAcquisition2 = [select Id, Name, Analysis_Notes__c from Acquisition_Opportunity__c where Id = :testAcquisition2.Id];
        system.assertEquals('important notes', testAcquisition1.Analysis_Notes__c);
        system.assertEquals('important notes', testAcquisition2.Analysis_Notes__c);
        
        // one last chunk of assertions: make sure that the change summaries are correct
        system.assert(changeRows[0].processingResult.contains('Changes Synced'));
        system.assert(changeRows[1].processingResult.contains('Changes Synced'));
        
        // Done!
        system.debug('###testSyncEngine_ProcessAcquisitionChanges(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_ProcessRelevantCompanyChanges() {
        system.debug('###testSyncEngine_ProcessRelevantCompanyChanges(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Account relatedAccount1 = (Account)testRecordMap.get('relatedAccount1');
        Patent__c relatedPatent2 = (Patent__c)testRecordMap.get('relatedPatent2');
        Patent__c relatedPatent3 = (Patent__c)testRecordMap.get('relatedPatent3');
        Potentially_Relevant_Company__c testRelevantCompanyA = (Potentially_Relevant_Company__c)testRecordMap.get('testRelevantCompanyA');
        Potentially_Relevant_Company__c testRelevantCompanyB = (Potentially_Relevant_Company__c)testRecordMap.get('testRelevantCompanyB');
        Potentially_Relevant_Company__c testRelevantCompanyC; // doesn't exist yet
        
        // Create change rows (this simulates the starting point since we can't do both callouts in one testmethod)
        SyncEngine.ChangeRow[] changeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.RelevantCompanyChanges, 'changed', SyncEngine.CoreObject.RelevantCompany, '-992011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.RelevantCompanyChanges, 'deleted', SyncEngine.CoreObject.RelevantCompany, '-992013', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.RelevantCompanyChanges, 'inserted', SyncEngine.CoreObject.RelevantCompany, '-993011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.RelevantCompanyChanges, 'deleted', SyncEngine.CoreObject.RelevantCompany, '-994014', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.RelevantCompanyChanges, 'deleted', SyncEngine.CoreObject.RelevantCompany, '-9999999', DateTime.now().addDays(-14), 1, 2)
        }; 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        SyncEngine.processChanges(changeRows);
        
        // Stop the test and make assertions
        Test.stopTest();
        Potentially_Relevant_Company__c[] relevantCompanies = [select Id, Patent__c, Core_Relevant_Company_Id__c, Account__c from Potentially_Relevant_Company__c where Core_Relevant_Company_Id__c in ('-992011', '-992013', '-993011', '-994014', '-9999999') and IsDeleted=false]; 
        Map<String, Potentially_Relevant_Company__c> relevantCompanyMap = new Map<String, Potentially_Relevant_Company__c>();
        for (Potentially_Relevant_Company__c rc:relevantCompanies)
            relevantCompanyMap.put(rc.Core_Relevant_Company_Id__c, rc);
        
        system.assertEquals(2, relevantCompanies.size()); // Only items -992011 and -993011 should be present
        system.assert(relevantCompanyMap.containsKey(testRelevantCompanyA.Core_Relevant_Company_Id__c)); // should've been "updated" (though there are no fields to update)
        system.assert(!relevantCompanyMap.containsKey(testRelevantCompanyB.Core_Relevant_Company_Id__c)); // should've bee deleted
        system.assert(relevantCompanyMap.containsKey('-993011')); // should've been inserted
        
        // Assert that the related field values made it over (from the mock)
        testRelevantCompanyA = relevantCompanyMap.get(testRelevantCompanyA.Core_Relevant_Company_Id__c);
        testRelevantCompanyC = relevantCompanyMap.get('-993011');
        system.assertEquals(relatedPatent2.Id, testRelevantCompanyA.Patent__c);
        system.assertEquals(relatedAccount1.Id, testRelevantCompanyA.Account__c);
        system.assertEquals(relatedPatent3.Id, testRelevantCompanyC.Patent__c);
        system.assertEquals(relatedAccount1.Id, testRelevantCompanyC.Account__c);
        
        // one last chunk of assertions: make sure that the change summaries are correct
        //system.debug(LoggingLevel.ERROR, '###testSyncEngine_ProcessRelevantCompanyChanges(): About to assert with changeRows = ' + changeRows + '.###' );
        system.assert(changeRows[0].processingResult.contains('No Changes'));
        system.assert(changeRows[1].processingResult.contains('Record Deleted'));
        system.assert(changeRows[2].processingResult.contains('Record Inserted'));
        system.assert(changeRows[3].processingResult.contains('No Salesforce Match to Delete'));
        system.assert(changeRows[4].processingResult.contains('No Salesforce Match to Delete'));
        
        // Done!
        system.debug('###testSyncEngine_ProcessRelevantCompanyChanges(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_ProcessTechTagChanges() {
        system.debug('###testSyncEngine_ProcessTechTagChanges(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Patent__c testPatent201 = (Patent__c)testRecordMap.get('testPatent201');
        Patent__c testPatent301 = (Patent__c)testRecordMap.get('testPatent301');
        portfolio2product__c testTechTagA = (portfolio2product__c)testRecordMap.get('testTechTagA');
        portfolio2product__c testTechTagB = (portfolio2product__c)testRecordMap.get('testTechTagB');
        portfolio2product__c testTechTag3; // doesn't exist yet
        
        // Start out with an assertion. We're going to make sure this field changes. (only to prove that it is synching the field values)
        system.assertEquals(null, testTechTagA.Core_Patent_Key__c); 
        
        // Create change rows (this simulates the starting point since we can't do both callouts in one testmethod)
        SyncEngine.ChangeRow[] changeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.TechTagChanges, 'changed', SyncEngine.CoreObject.TechTag, '-992011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.TechTagChanges, 'deleted', SyncEngine.CoreObject.TechTag, '-992013', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.TechTagChanges, 'inserted', SyncEngine.CoreObject.TechTag, '-993011', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.TechTagChanges, 'deleted', SyncEngine.CoreObject.TechTag, '-994014', DateTime.now().addDays(-14), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.TechTagChanges, 'deleted', SyncEngine.CoreObject.TechTag, '-9999999', DateTime.now().addDays(-14), 1, 2)
        }; 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        SyncEngine.processChanges(changeRows);
        
        // Stop the test and make assertions
        Test.stopTest();
        portfolio2product__c[] techTags = [select Id, Name, Patent__c, Core_Patent_Key__c from portfolio2product__c where Patent__c in :(new Id[]{testPatent201.Id, testPatent301.Id}) and IsDeleted=false]; 
        Map<Id, portfolio2product__c> techTagMap = new Map<Id, portfolio2product__c>();
        for (portfolio2product__c tt:techTags) {
            techTagMap.put(tt.Id, tt);
            if (tt.Patent__c == testPatent301.Id) testTechTag3 = tt;
        }
        
        system.assertEquals(2, techTags.size()); // There should be one tech tag for each patent in the database
        system.assert(techTagMap.containsKey(testTechTagA.Id));
        system.assert(!techTagMap.containsKey(testTechTagB.Id));
        system.assert(testTechTag3 != null);
        
        testTechTagA = techTagMap.get(testTechTagA.Id);
        system.assertEquals('US0000201', testTechTagA.Core_Patent_Key__c); // this should've been updated during the sync process
        
        // one last chunk of assertions: make sure that the change summaries are correct
        //system.debug(LoggingLevel.ERROR, '###testSyncEngine_ProcessTechTagChanges(): About to assert with changeRows = ' + changeRows + '.###' );
        system.assert(changeRows[0].processingResult.contains('Changes Synced'));
        system.assert(changeRows[1].processingResult.contains('Record Deleted'));
        system.assert(changeRows[2].processingResult.contains('Record Inserted'));
        system.assert(changeRows[3].processingResult.contains('No Salesforce Match to Delete'));
        system.assert(changeRows[4].processingResult.contains('No Salesforce Match to Delete'));
        
        // Done!
        system.debug('###testSyncEngine_ProcessTechTagChanges(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_ProcessPatentFamilyChanges() {
        system.debug('###testSyncEngine_ProcessPatentFamilyChanges(): Entering function.###' );
        
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords(); 
        Patent__c testPatent301 = (Patent__c)testRecordMap.get('testPatent301');
        Patent__c testPatent401 = new Patent__c(Name='US0000401A1', Title__c='testPatent401', Country__c='US', Patent_No__c='0000401', Core_DB_Patent_ID__c=(-401));
        insert testPatent401;
        Assets__c testPatentFamily2 = (Assets__c)testRecordMap.get('testPatentFamily2');
        Assets__c testPatentFamily3 = (Assets__c)testRecordMap.get('testPatentFamily3');
        Assets__c testPatentFamily4; // Doesn't exist yet.
        
        // Change the patent family for 301 so that it incorrectly points to patent family 2 (we will check afterwards that this is fixed)
        testPatent301.Patent_Family__c = testPatentFamily2.Id;
        update testPatent301; //NOTE: There is still one patent left in the family (302) so this will NOT cause testPatentFamily3 to be deleted
        
        // Create change rows (this simulates the starting point since we can't do both callouts in one testmethod)
        SyncEngine.ChangeRow[] changeRows = new SyncEngine.ChangeRow[]{
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PatentFamilyChanges, 'added', SyncEngine.CoreObject.Patent, 'US0000301', DateTime.now(), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PatentFamilyChanges, 'added', SyncEngine.CoreObject.Patent, 'US0000401', DateTime.now(), 1, 2),
            new SyncEngine.ChangeRow(CoreAPI.EndpointName.PatentFamilyChanges, 'added', SyncEngine.CoreObject.Patent, 'US0000402', DateTime.now(), 1, 2)
        }; 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        SyncEngine.processChanges(changeRows);
        
        // Stop the test and make assertions
        Test.stopTest();
        Integer theCount;
        
        theCount = [select count() from Assets__c where Core_Patent_Family_Id__c=-444];
        testPatent301 = [select Id, Name, Patent_Family__c from Patent__c where Id=:testPatent301.Id];
        testPatent401 = [select Id, Name, Patent_Family__c from Patent__c where Id=:testPatent401.Id];
        
        Assets__c tp3parent = [select Id, Name, Core_Patent_Family_Id__c from Assets__c where Id=:testPatent301.Patent_Family__c];
        //system.debug(LoggingLevel.ERROR, '###testSyncEngine_ProcessPatentFamilyChanges(): Done processing changes... test patent 3 parent pfam = ' + tp3parent + ', testPatentFamily3 = ' + testPatentFamily3 + '.###' );
        
        system.assertEquals(1, theCount); // testPatentFamily4 should have been inserted by processChanges()
        system.assertEquals(testPatentFamily3.Id, testPatent301.Patent_Family__c);
        testPatentFamily4 = [select Id, Name from Assets__c where Core_Patent_Family_Id__c=-444];
        system.assertEquals(testPatentFamily4.Id, testPatent401.Patent_Family__c);
        
        // one last chunk of assertions: make sure that the change summaries are correct
        system.assert(changeRows[0].processingResult.contains('Changes Synced'));
        system.assert(!changeRows[0].changeSummary.contains('INSERTED MISSING PARENT')); // the parent already existed
        system.assert(changeRows[1].processingResult.contains('Changes Synced'));
        system.assert(changeRows[1].changeSummary.contains('INSERTED MISSING PARENT')); // the parent was missing
        system.assert(changeRows[2].processingResult.contains('No Salesforce Match')); // this row wasn't found
        
        // Done!
        system.debug('###testSyncEngine_ProcessPatentFamilyChanges(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_GetAndSortChanges() {
        // This tests the getChanges() and sortAndFilterChanges() functions
        
        system.debug('###testSyncEngine_GetChanges(): Entering function.###' );
        
        SyncEngine.ChangeRow[] rawChangeRows;
        SyncEngine.ChangeRow[] compressedChangeRows;
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Process the changes
        rawChangeRows = SyncEngine.getChanges(CoreAPI.EndpointName.PatentAnnotationChanges, 100, DateTime.now().addDays(-14), 1);
        compressedChangeRows = SyncEngine.sortAndFilterChangeRowList(rawChangeRows);
        
        // Stop the test and make assertions
        Test.stopTest();
        
        system.assertEquals(90, rawChangeRows.size()); // 1 row is invalid (multiplied by 10)
        system.assertEquals(5, compressedChangeRows.size()); // 1 row is invalid
        
        // build a map
        Map<String, SyncEngine.ChangeRow> changeRowMap = new Map<String, SyncEngine.ChangeRow>();
        for (SyncEngine.ChangeRow changeRow:compressedChangeRows)
            changeRowMap.put(changeRow.objectId, changeRow);
            
        system.assert(changeRowMap.containsKey('US0000303'));
        
        SyncEngine.ChangeRow testRow = changeRowMap.get('US0000303');
        system.assertEquals(CoreAPI.EndpointName.PatentAnnotationChanges, testRow.theEndpoint);
        system.assertEquals(SyncEngine.CoreObject.Patent, testRow.objectType);
        system.assertEquals(1, testRow.resultsPageNumber);
        system.assertEquals(2, testRow.resultsNextPageNumber);
        
        // String actionMash = String.join(new String[]{'changed', 'changed', 'changed'}, CoreAPI.LIST_JOIN_STRING);
        //system.assert(testRow.action.length() >= actionMash.length());
        //system.assertEquals(actionMash, testRow.action.substring(0, actionMash.length()));
        
        // Done!
        system.debug('###testSyncEngine_GetChanges(): Exiting function.###' );
    }
    
    
    
    /*=== SYNC FIELD INTEGRITY TEST FUNCTIONS ===*/
    
    
    public static testMethod void testSyncEngine_BadSFField() {
        // This tests a search engine field that points to a non-existent salesforce field 
        // What should happen: Everything should move forward as usual, not a mission critical error. An error email will be sent.
        
        system.debug('###testSyncEngine_BadSFField(): Entering function.###' );
       
        // First insert the test records
        SyncEngineField__c sef = new SyncEngineField__c(Name='zzztestsef564327', Object__c='PatentFamily', Core_Field_Name__c='name', Salesforce_Field_Name__c='Invalid_Field_XX1sf3__c');
        insert sef;
                
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        SyncEngine.ConvertedResponseRow[] responseRows = SyncEngine.getPatentFamilies(null, null, null, new String[]{'US0000101'}, false);
        
        // Stop test and make assertions
        Test.stopTest();
        
        //That's it!  There's not much to assert... we're just trying to run the code that fires when a bad field is encountered
        // Let's just assert that all of the response rows made it through (except patent family 1)
        
        system.assertEquals(3, responseRows.size());
        
        system.debug('###testSyncEngine_BadSFField(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_BadAPIField() {
        // This tests a search engine field that points to a non-existent api field
        // What should happen: All of the returned rows should be filtered out since they are missing the bad field. 
        //                     This IS a mission critical error because a missing field value could result in overriding SFDC data with blanks.
        
        system.debug('###testSyncEngine_BadAPIField(): Entering function.###' );
       
        // First insert the test records
        SyncEngineField__c sef = new SyncEngineField__c(Name='zzztestsef564327', Object__c='PatentFamily', Core_Field_Name__c='non_existent_field_92543', Salesforce_Field_Name__c='Name');
        insert sef;
                
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        SyncEngine.ConvertedResponseRow[] responseRows = SyncEngine.getPatentFamilies(null, null, null, new String[]{'US0000101'}, false);
        
        // Stop test and make assertions
        Test.stopTest();
        
        // All of the patent families should've been filtered out since all of their patents were invalid data (missing the bad field.)
        system.assertEquals(0, responseRows.size());
        
        system.debug('###testSyncEngine_BadAPIField(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_BadAPIField_Optional() {
        // This tests a search engine field that points to a non-existent api field (but the sync field mapping is marked as OPTIONAL)
        // What should happen: The response row should NOT be filtered out since the field is explicitly marked as optional.
        
        system.debug('###testSyncEngine_BadAPIField_Optional(): Entering function.###' );
       
        // First insert the test records
        SyncEngineField__c sef = new SyncEngineField__c(Name='zzztestsef564327', Object__c='PatentFamily', Core_Field_Name__c='non_existent_field_92543', Salesforce_Field_Name__c='Name', Allow_Field_to_be_Missing__c=true);
        insert sef;
                
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        SyncEngine.ConvertedResponseRow[] responseRows = SyncEngine.getPatentFamilies(null, null, null, new String[]{'US0000101'}, false);
        
        // Stop test and make assertions
        Test.stopTest();
        
        // NONE of the patent families should've been filtered out since the bad field was optional.
        system.assertEquals(3, responseRows.size());
        
        system.debug('###testSyncEngine_BadAPIField_Optional(): Exiting function.###' );
    }
    
    
    public static testMethod void testSyncEngine_NullValuesShouldSync() {
        // This tests whether null and blank values from the API record overwrite the Salesforce record during change syncing 
        // What should happen: They SHOULD override... otherwise blank fields in patent blaster will never sync over. 
        
        system.debug('###testSyncEngine_NullValuesShouldSync(): Entering function.###' );
       
        // First create the test records
        SyncEngineField__c sef = new SyncEngineField__c(Name='zzztestsef564327', Object__c='Patent', Core_Field_Name__c='summary', Salesforce_Field_Name__c='Summary__c');
        insert sef;
        
        Map<String, String> fieldMap = SyncEngine.getFieldMappings(SyncEngine.CoreObject.Patent, SyncEngine.Direction.FromSalesforceToCore, false);
        
        Patent__c apiPatent_Null = new Patent__c();
        Patent__c apiPatent_Blank = new Patent__c(Summary__c = '');
        Patent__c salesforcePatent_Null = new Patent__c(Summary__c = 'Not a null value.');
        Patent__c salesforcePatent_Blank = new Patent__c(Summary__c = 'Not a blank value.');
                
        // Start the test
        Test.startTest();
        
        SyncEngine.syncRecords(salesforcePatent_Null, apiPatent_Null, SyncEngine.CoreObject.Patent, fieldMap);
        SyncEngine.syncRecords(salesforcePatent_Blank, apiPatent_Blank, SyncEngine.CoreObject.Patent, fieldMap);
        
        // Stop test and make assertions
        Test.stopTest();
        
        // The null and blank values from the api records should've overwritten the existing salesforce values 
        system.assertEquals(null, salesforcePatent_Null.Summary__c);
        system.assertEquals('', salesforcePatent_Blank.Summary__c);
        
        system.debug('###testSyncEngine_NullValuesShouldSync(): Exiting function.###' );
    }
    
    
    
    /*=== ENDPOINT TEST FUNCTIONS ===*/
    
    
    public static testMethod void testSyncEngine_GetClaimChartedCompanies() {
        system.debug('###testSyncEngine_GetClaimChartedCompanies(): Entering function.###' );
        
        // First create the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Accounts_with_Claim_Charts__c testClaimChartedCompanyA = (Accounts_with_Claim_Charts__c)testRecordMap.get('testClaimChartedCompanyA');
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the api get function 
        SyncEngine.ConvertedResponseRow[] convertedRows = SyncEngine.getClaimChartedCompanies(new String[]{'abc123'}, null, null); // the search parameters don't matter since the response is mocked
         
        // Stop the test and make assertions
        Test.stopTest();
        
        // Assert that -992011 was returned in the converted response and that it got linked to testClaimChartedCompanyA
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_CLAIM_CHARTED_COMPANY_ROWS, convertedRows.size());
        system.assert(convertedRows[1].claimChartedCompany != null); // hard coding the index of -992011 based on the mock response order
        system.assertEquals(SyncEngine.getPrimaryKey(testClaimChartedCompanyA), SyncEngine.getPrimaryKey(convertedRows[1].claimChartedCompany));
        system.assertEquals(testClaimChartedCompanyA.Id, convertedRows[1].claimChartedCompany.Id);
        
        system.debug('###testSyncEngine_GetClaimChartedCompanies(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_GetLicensees() {
        system.debug('###testSyncEngine_GetLicensees(): Entering function.###' );
        
        // First create the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Licensees__c testLicenseeA = (Licensees__c)testRecordMap.get('testLicenseeA');
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the api get function 
        SyncEngine.ConvertedResponseRow[] convertedRows = SyncEngine.getLicensees(new String[]{'abc123'}, null, null); // the search parameters don't matter since the response is mocked
         
        // Stop the test and make assertions
        Test.stopTest();
        
        // Assert that -992011 was returned in the converted response and that it got linked to testClaimChartedCompanyA
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_LICENSEE_ROWS, convertedRows.size());
        system.assert(convertedRows[1].licensee != null); // hard coding the index of -992011 based on the mock response order
        system.assertEquals(SyncEngine.getPrimaryKey(testLicenseeA), SyncEngine.getPrimaryKey(convertedRows[1].licensee));
        system.assertEquals(testLicenseeA.Id, convertedRows[1].licensee.Id);
        
        system.debug('###testSyncEngine_GetLicensees(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_GetPatents() {
        system.debug('###testSyncEngine_GetPatents(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Patent__c testPatent201;
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the api get function 
        SyncEngine.ConvertedResponseRow[] convertedRows = SyncEngine.getPatentsWithPatentFamilies(new String[]{'abc123'}); // the search parameters don't matter since the response is mocked
         
        // Now we make basic assertions
        system.assertEquals(10, convertedRows.size()); // There should be 9 valid rows and 2 errors (101 is missing primary key, 501 has annotation info hard coded in there)
        SyncEngine.ConvertedResponseRow firstRow = convertedRows[0];
        String expectedAssignees = String.join(new String[]{'item1', 'item2'}, CoreAPI.LIST_JOIN_STRING);
        system.assert(firstRow.patent != null);
        system.assertEquals(expectedAssignees, firstRow.patent.Current_Assignees_as_Listed__c); // Confirm that this field mapping made it through (also confirms field flattening)
        
        // Stop the test and make assertions
        Test.stopTest();
        
        // build a map of all of the patents/families
        Map<String, Id> matchedPatentMap = new Map<String, Id>(); //maps from patent primary field to salesforce record id of the patent record
        Map<String, Id> matchedPatentFamilyMap = new Map<String, Id>(); //maps from patent primary field to salesforce record id of the patent family record
        Map<String, Id> patentFamilyLookupMap = new Map<String, Id>(); //maps from patent primary field to salesforce record id of the Patent_Family__c lookup field on the patent record
        for (SyncEngine.ConvertedResponseRow crr:convertedRows) {
            if (crr.patent != null) { 
                if (crr.patent.Name == 'US0000201A1') testPatent201 = crr.patent;
                
                if (crr.patent.Id != null)
                    matchedPatentMap.put(crr.patent.Name, crr.patent.Id);
                if ((crr.patentFamily != null) && (crr.patentFamily.Id != null))
                    matchedPatentFamilyMap.put(crr.patent.Name, crr.patentFamily.Id);
                if (crr.patent.Patent_Family__c != null)
                    patentFamilyLookupMap.put(crr.patent.Name, crr.patent.Patent_Family__c);
            }
        }
        
        // PATENT ASSERTIONS: the only rows with record matches should be 201, 202 & 301
        system.assert(matchedPatentMap.containsKey('US0000201A1'));
        system.assertEquals(((Patent__c)testRecordMap.get('testPatent201')).Id, matchedPatentMap.get('US0000201A1'));
        system.assert(matchedPatentMap.containsKey('US0000202A1'));
        system.assertEquals(((Patent__c)testRecordMap.get('testPatent202')).Id, matchedPatentMap.get('US0000202A1'));
        system.assert(matchedPatentMap.containsKey('US0000301A1'));
        system.assertEquals(((Patent__c)testRecordMap.get('testPatent301')).Id, matchedPatentMap.get('US0000301A1'));
        
        // PATENT FAMILY ASSERTIONS: all of the pfamily 2 & 3 rows should be matched 
        system.assert(matchedPatentFamilyMap.containsKey('US0000201A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily2')).Id, matchedPatentFamilyMap.get('US0000201A1'));
        system.assert(matchedPatentFamilyMap.containsKey('US0000202A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily2')).Id, matchedPatentFamilyMap.get('US0000202A1'));
        system.assert(matchedPatentFamilyMap.containsKey('US0000301A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, matchedPatentFamilyMap.get('US0000301A1'));
        system.assert(matchedPatentFamilyMap.containsKey('US0000302A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, matchedPatentFamilyMap.get('US0000302A1'));
        system.assert(matchedPatentFamilyMap.containsKey('US0000303A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, matchedPatentFamilyMap.get('US0000303A1'));
        
        // PATENT FAMILY LOOKUP ASSERTIONS: all of the pfamily 2 & 3 rows should have the id of the patent family stored in their lookup field 
        system.assert(patentFamilyLookupMap.containsKey('US0000201A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily2')).Id, patentFamilyLookupMap.get('US0000201A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000202A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily2')).Id, patentFamilyLookupMap.get('US0000202A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000301A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, patentFamilyLookupMap.get('US0000301A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000302A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, patentFamilyLookupMap.get('US0000302A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000303A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, patentFamilyLookupMap.get('US0000303A1'));
        
        // TEST THE FIELDS THAT ARE MERGED IN FROM OTHER ENDPOINTS
        system.assertEquals('summary of patent 201', testPatent201.Summary__c); // from the mock responses
        
        // Done!
        system.debug('###testSyncEngine_GetPatents(): Exiting function.###' );
    }
    
    
    public static testMethod void testSyncEngine_GetPatentFamilies() {
        system.debug('###testSyncEngine_GetPatentFamilies(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the api get function 
        SyncEngine.ConvertedResponseRow[] convertedRows = SyncEngine.getPatentFamiliesWithPatents(new String[]{'abc123'}, null, null, null); // the search parameters don't matter since the response is mocked
         
        // Assert that there are 4 valid rows (3 patent families + 1 "no patent famiy" row) and 1 error
        system.assertEquals(4, convertedRows.size());
        
        // build a map of all of the patents/families
        Map<String, Id> matchedPatentMap = new Map<String, Id>(); //maps from patent primary field to salesforce record id of the patent record
        Map<String, Id> matchedPatentFamilyMap = new Map<String, Id>(); //maps from patent family primary field to salesforce record id of the patent family record
        Map<String, Id> patentFamilyLookupMap = new Map<String, Id>(); //maps from patent primary field to salesforce record id of the Patent_Family__c lookup field on the patent record
        SyncEngine.ConvertedResponseRow blankPatentFamilyRow = null;
        String pfKey;
        Patent__c matchedPatent201;
        for (SyncEngine.ConvertedResponseRow crr:convertedRows) {
            if ((crr.patentFamily != null) && (crr.patentFamily.Id != null) && (crr.patentFamily.Core_Patent_Family_Id__c != null)) {
                pfKey = SyncEngine.getPrimaryKey(crr.patentFamily);
                matchedPatentFamilyMap.put(pfKey, crr.patentFamily.Id);
            } else if ((crr.patentFamily != null) && (crr.patentFamily.Id == null) && (crr.patentFamily.Core_Patent_Family_Id__c == 0))
                blankPatentFamilyRow = crr;
            for (Patent__c patent:crr.childPatents)
                if (patent != null) { 
                    if (patent.Id != null)
                        matchedPatentMap.put(patent.Name, patent.Id);
                    if (patent.Patent_Family__c != null)
                        patentFamilyLookupMap.put(patent.Name, patent.Patent_Family__c);
                    if (patent.Name == 'US0000201A1')
                        matchedPatent201 = patent;
                }
        }
        
        system.debug('###testSyncEngine_GetPatentFamilies(): matchedPatentMap = ' + matchedPatentMap + ', matchedPatentFamilyMap = ' + matchedPatentFamilyMap + '.###' );
        
        // PATENT ASSERTIONS: the only rows with record matches should be 201, 202 & 301
        system.assert(matchedPatentMap.containsKey('US0000201A1'));
        system.assertEquals(((Patent__c)testRecordMap.get('testPatent201')).Id, matchedPatentMap.get('US0000201A1'));
        system.assert(matchedPatentMap.containsKey('US0000202A1'));
        system.assertEquals(((Patent__c)testRecordMap.get('testPatent202')).Id, matchedPatentMap.get('US0000202A1'));
        system.assert(matchedPatentMap.containsKey('US0000301A1'));
        system.assertEquals(((Patent__c)testRecordMap.get('testPatent301')).Id, matchedPatentMap.get('US0000301A1'));
        
        // MERGED PATENT ASSERTIONS: the most_recent_assignees value should be available (it should be merged in from the patents endpoint)
        system.assert(matchedPatent201.Current_Assignees_as_Listed__c != null);
        system.assertEquals('summary of patent 201', matchedPatent201.Summary__c); // from the mock responses
        
        
        // PATENT FAMILY ASSERTIONS: only pfamily 2 & 3 should be matched, null patent family should be present
        system.assert(matchedPatentFamilyMap.containsKey('-222'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily2')).Id, matchedPatentFamilyMap.get('-222'));
        system.assert(matchedPatentFamilyMap.containsKey('-333'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, matchedPatentFamilyMap.get('-333'));
        system.assert(blankPatentFamilyRow != null);
        system.assertEquals(1, blankPatentFamilyRow.childPatents.size()); // one child patent = US0000501A1
        
        // PATENT FAMILY LOOKUP ASSERTIONS: all of the pfamily 2 & 3 rows should have the id of the patent family stored in their lookup field 
        system.assert(patentFamilyLookupMap.containsKey('US0000201A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily2')).Id, patentFamilyLookupMap.get('US0000201A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000202A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily2')).Id, patentFamilyLookupMap.get('US0000202A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000301A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, patentFamilyLookupMap.get('US0000301A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000302A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, patentFamilyLookupMap.get('US0000302A1'));
        system.assert(patentFamilyLookupMap.containsKey('US0000303A1'));
        system.assertEquals(((Assets__c)testRecordMap.get('testPatentFamily3')).Id, patentFamilyLookupMap.get('US0000303A1'));
        
        // And that's it.
        Test.stopTest();
        system.debug('###testSyncEngine_GetPatentFamilies(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_GetAcquisitions() {
        system.debug('###testSyncEngine_GetAcquisitions(): Entering function.###' );
        
        // First create the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Acquisition_Opportunity__c testAcquisition1 = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisition1');
        String recordKey = SyncEngine.getPrimaryKey(testAcquisition1); 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the api get function 
        SyncEngine.ConvertedResponseRow[] convertedRows = SyncEngine.getAcquisitions(new String[]{'abc123'}); // the search parameters don't matter since the response is mocked
         
        // Stop the test and make assertions
        Test.stopTest();
         
        Map<String, Acquisition_Opportunity__c> acquisitionMap = new Map<String, Acquisition_Opportunity__c>(); 
        for (SyncEngine.ConvertedResponseRow row:convertedRows)
            if (row.acquisition != null)
                acquisitionMap.put(SyncEngine.getPrimaryKey(row.acquisition), row.acquisition); 
        
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_PORTFOLIO_ROWS, convertedRows.size());
        system.assert(acquisitionMap.containsKey(recordKey));
        system.assertEquals(testAcquisition1.Id, acquisitionMap.get(recordKey).Id);
        
        system.debug('###testSyncEngine_GetAcquisitions(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_GetRelevantCompanies() {
        system.debug('###testSyncEngine_GetRelevantCompanies(): Entering function.###' );
        
        // First create the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Potentially_Relevant_Company__c testRelevantCompanyA = (Potentially_Relevant_Company__c)testRecordMap.get('testRelevantCompanyA');
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the api get function 
        SyncEngine.ConvertedResponseRow[] convertedRows = SyncEngine.getRelevantCompanies(new String[]{'abc123'}, null, null); // the search parameters don't matter since the response is mocked
         
        // Stop the test and make assertions
        Test.stopTest();
        
        // Assert that -992011 was returned in the converted response and that it got linked to testClaimChartedCompanyA
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_RELEVANT_COMPANY_ROWS, convertedRows.size());
        system.assert(convertedRows[1].relevantCompany != null); // hard coding the index of -992011 based on the mock response order
        system.assertEquals(SyncEngine.getPrimaryKey(testRelevantCompanyA), SyncEngine.getPrimaryKey(convertedRows[1].relevantCompany));
        system.assertEquals(testRelevantCompanyA.Id, convertedRows[1].relevantCompany.Id);
        
        system.debug('###testSyncEngine_GetRelevantCompanies(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_GetTechTags() {
        system.debug('###testSyncEngine_GetTechTags(): Entering function.###' );
        
        // First create the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        portfolio2product__c testTechTagA = (portfolio2product__c)testRecordMap.get('testTechTagA');
        String ttKey1 = SyncEngine.cleanPrimaryKey(testTechTagA.Core_Tech_Tag_Id__c); 
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the api get function 
        SyncEngine.ConvertedResponseRow[] convertedRows = SyncEngine.getTechTags(new String[]{'abc123'}, null); // the search parameters don't matter since the response is mocked
         
        // Stop the test and make assertions
        Test.stopTest();
         
        Map<String, portfolio2product__c> techTagMap = new Map<String, portfolio2product__c>(); 
        for (SyncEngine.ConvertedResponseRow row:convertedRows)
            if (row.techTag != null)
                techTagMap.put(SyncEngine.getPrimaryKey(row.techTag), row.techTag); 
        
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_TECH_TAG_ROWS, convertedRows.size());
        system.assert(techTagMap.containsKey(ttKey1));
        system.assertEquals(testTechTagA.Id, techTagMap.get(ttKey1).Id);
        
        system.debug('###testSyncEngine_GetTechTags(): Exiting function.###' );
    }
    
    
    public static testMethod void testSyncEngine_GetCoreRecord_Patent() {
        // This tests the generic get core record function with both patent and patent family
        
        system.debug('###testSyncEngine_GetCoreRecord_Patent(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Patent__c testPatent303 = (Patent__c)testRecordMap.get('testPatent303');
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the function with objectType = Patent
        SyncEngine.ConvertedResponseRow patentMatchRow = SyncEngine.getCoreRecord(SyncEngine.CoreObject.Patent, 'US0000303A1');
                
        // Stop test and make assertions
        Test.stopTest();
        
        // Assert that the patent matches
        system.assert(patentMatchRow != null);
        system.assert(patentMatchRow.patent != null);
        system.assertEquals('US0000303A1', patentMatchRow.patent.Name);
        
        system.debug('###testSyncEngine_GetCoreRecord_Patent(): Exiting function.###' );
    }
    
    public static testMethod void testSyncEngine_GetCoreRecord_PatentFamily() {
        // This tests the generic get core record function with both patent and patent family
        
        system.debug('###testSyncEngine_GetCoreRecord_PatentFamily(): Entering function.###' );
       
        // First insert the test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Assets__c testPatentFamily3 = (Assets__c)testRecordMap.get('testPatentFamily3');
        
        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Call the function with objectType = PatentFamily
        SyncEngine.ConvertedResponseRow patentFamilyMatchRow = SyncEngine.getCoreRecord(SyncEngine.CoreObject.PatentFamily, '-333');
        
        // Stop test and make assertions
        Test.stopTest();
        
        // Assert that the patent family matches
        system.assert(patentFamilyMatchRow != null);
        system.assert(patentFamilyMatchRow.patentFamily != null);
        system.assertEquals('-333', SyncEngine.getPrimaryKey(patentFamilyMatchRow.patentFamily));
        
        system.debug('###testSyncEngine_GetCoreRecord_PatentFamily(): Exiting function.###' );
    }
    
    
    
    public static Map<String, Object> createAPITestRecords() {
        // Inserts sample records that match up with the mocked responses from the api endpoints
        // Refer to CoreAPIMockResponseGenerator.cls comments for more info
        
        /* === EXPLANATION OF WHAT THIS METHOD CREATES & RETURNS ==
        
            INSERTS SYNC OBJECT RECORDS
                > Patent Family 2 = Fully inserted into salesforce
                > Patent Family 3 = Partially inserted into salesforce (patents 301, 302 and the family are present)
                > Patent Family 4 = Empty (no records in salesforce)
                > Acquisition 1&2 = Linked to relatedAccount1&2 >> NOTE: Acquisition 1 is linked to testPatent201 via an OMAPatent record
                > Tech Tag A&B = For testPatent201 with idA = -992011 (matches mock), idB = -992019 (doesn't match mock, to test deletion)
                > Claim Charted Company A&B, Licensee A&B, Relevant Company A&B
                    >> These are all structured the same:
                        A = relatedPatent2 & relatedAccount1, id = -992011 (matches mock)
                        B = relatedPatent2 & relatedAccount3, id = -992013 (doesn't match mock, to test deletion)
                
            INSERTS RELATED OBJECT RECORDS - For certain responses, CoreAPIMockResponseGenerator requires that the SFDC database
            contain at least a certain number of related records so that it can insert their ids into the mocked response. 
                > Account 1, 2, 3, 4 >> Needed for ClaimChartedCompany, Licensee & RelevantCompany (along with the patents in the next line)
                > Patent 1, 2, 3, 4 >> NOTE: These are the same patents created for the patent/pfamily endpoints, but for the
                                             CCC, L & RC endpoints the ORDER of the patents is important and may be different.
                > Product Service 1, 2, 3 & 4 >> Needed for TechTag  
         
            INSERTS FIELD MAPPINGS - Inserts field mapping setting records for various fields. (Refer to the FIELD MAPPINGS section below for specifics.)
        
            RETURN MAP KEYS
                SIMPLE SYNC RECORDS (No SFDC ids):
                    > Patent Families = testPatentFamily2, testPatentFamily3
                    > Patents = testPatent201, testPatent202, testPatent301, testPatent302
                RELATED RECORDS:
                    >> NOTE 1: relatedObjectX corresponds to insert_object_idX in the mock response template (The templates are contained in CoreAPIMockResponseGenerator.cls) 
                    >> NOTE 2: Only the Id field will be populated on these records in the returnMap. 
                    > Accounts = relatedAccount1, relatedAccount2, relatedAccount3, relatedAccount4
                    > Patents = relatedPatent1, relatedPatent2, relatedPatent3, relatedPatent4
                    > Product or Service = relatedProduct1, relatedProduct2, relatedProduct3, relatedProduct4 
                LINKED SYNC RECORDS (Inserted SFDC ids):
                    > Acquisition = testAcquisition1, testAcquisition2 >> NOTE: There's no reason to create all 10, so we'll just create one odd and one even one.
                    > Claim Charted Company = testClaimChartedCompanyA, testClaimChartedCompanyB
                    > Licensee = testLicenseeA, testLicenseeB
                    > Relevant Company = testRelevantCompanyA, testRelevantCompanyB
                    > Tech Tag = testTechTagA, testTechTagB 
             
        */
          
        
        // === STEP 1: FIELD MAPPINGS ===
        
        
        SyncEngineField__c sef1 = new SyncEngineField__c(Name='zzztestsef564301', Object__c='Patent', Core_Field_Name__c='most_recent_assignees', Salesforce_Field_Name__c='Current_Assignees_as_Listed__c');
        SyncEngineField__c sef2 = new SyncEngineField__c(Name='zzztestsef564302', Object__c='Patent', Core_Field_Name__c='id', Salesforce_Field_Name__c='Core_DB_Patent_ID__c');
        SyncEngineField__c sef3 = new SyncEngineField__c(Name='zzztestsef564303', Object__c='Patent', Core_Field_Name__c='summary', Salesforce_Field_Name__c='Summary__c');
        SyncEngineField__c sef4 = new SyncEngineField__c(Name='zzztestsef564304', Object__c='Acquisition', Core_Field_Name__c='analyst_notes', Salesforce_Field_Name__c='Analysis_Notes__c');
        SyncEngineField__c sef5 = new SyncEngineField__c(Name='zzztestsef564305', Object__c='Patent', Core_Field_Name__c='patent_family', Salesforce_Field_Name__c='Core_Patent_Family_Id__c');
        SyncEngineField__c sef6 = new SyncEngineField__c(Name='zzztestsef564306', Object__c='TechTag', Core_Field_Name__c='patent_key', Salesforce_Field_Name__c='Core_Patent_Key__c');
        SyncEngineField__c sef7 = new SyncEngineField__c(Name='zzztestsef564307', Object__c='Patent', Core_Field_Name__c='stripped_patnum', Salesforce_Field_Name__c='Patent_No__c');
        SyncEngineField__c sef8 = new SyncEngineField__c(Name='zzztestsef564308', Object__c='Patent', Core_Field_Name__c='country', Salesforce_Field_Name__c='Country__c');
        SyncEngineField__c sef9 = new SyncEngineField__c(Name='zzztestsef564309', Object__c='TechTag', Core_Field_Name__c='product_service_sfdc_id', Salesforce_Field_Name__c='Product_or_Service__c');
        SyncEngineField__c sef10 = new SyncEngineField__c(Name='zzztestsef564310', Object__c='ClaimChartedCompany', Core_Field_Name__c='pat_salesforce_id', Salesforce_Field_Name__c='Patent__c');
        SyncEngineField__c sef11 = new SyncEngineField__c(Name='zzztestsef564311', Object__c='ClaimChartedCompany', Core_Field_Name__c='ent_salesforce_id', Salesforce_Field_Name__c='Account__c');
        SyncEngineField__c sef12 = new SyncEngineField__c(Name='zzztestsef564312', Object__c='Licensee', Core_Field_Name__c='pat_salesforce_id', Salesforce_Field_Name__c='Patent__c');
        SyncEngineField__c sef13 = new SyncEngineField__c(Name='zzztestsef564313', Object__c='Licensee', Core_Field_Name__c='ent_salesforce_id', Salesforce_Field_Name__c='Account__c');
        SyncEngineField__c sef14 = new SyncEngineField__c(Name='zzztestsef564314', Object__c='RelevantCompany', Core_Field_Name__c='pat_salesforce_id', Salesforce_Field_Name__c='Patent__c');
        SyncEngineField__c sef15 = new SyncEngineField__c(Name='zzztestsef564315', Object__c='RelevantCompany', Core_Field_Name__c='ent_salesforce_id', Salesforce_Field_Name__c='Account__c');
        insert new SyncEngineField__c[]{sef1, sef2, sef3, sef4, sef5, sef6, sef7, sef8, sef9, sef10, sef11, sef12, sef13, sef14, sef15};
        
        
        // === STEP 2: SIMPLE SYNC RECORDS (No SFDC ids) ===
        
        
        // Patent Families 
        Assets__c testPatentFamily2 = new Assets__c(Name='testPatentFamily2', Core_Patent_Family_Id__c=-222);
        Assets__c testPatentFamily3 = new Assets__c(Name='testPatentFamily3', Core_Patent_Family_Id__c=-333);
        insert new Assets__c[]{testPatentFamily2, testPatentFamily3};
        //system.debug('###createAPITestRecords(): Done inserting testPatentFamily2 = ' + testPatentFamily2 + ', testPatentFamily3 = ' + testPatentFamily3 + '.###');
        
        // Patents
        Patent__c testPatent201 = new Patent__c(Name='US0000201A1', Title__c='testPatent201', Country__c='US', Patent_No__c='0000201', Patent_Family__c=testPatentFamily2.Id, Core_DB_Patent_ID__c=(-99201));
        Patent__c testPatent202 = new Patent__c(Name='US0000202A1', Title__c='testPatent202', Country__c='US', Patent_No__c='0000202', Patent_Family__c=testPatentFamily2.Id, Core_DB_Patent_ID__c=(-99202));
        Patent__c testPatent301 = new Patent__c(Name='US0000301A1', Title__c='testPatent301', Country__c='US', Patent_No__c='0000301', Patent_Family__c=testPatentFamily3.Id, Core_DB_Patent_ID__c=(-99301));
        Patent__c testPatent302 = new Patent__c(Name='US0000302A1', Title__c='testPatent302', Country__c='US', Patent_No__c='0000302', Patent_Family__c=testPatentFamily3.Id, Core_DB_Patent_ID__c=(-99302));
        insert new Patent__c[]{testPatent302, testPatent301, testPatent202, testPatent201}; // inserting them backwards might get the order to line up with the semantics of the mock response helping with debugging.
        
        
        // === STEP 3: RELATED OBJECT RECORDS === 
        
        
        // Accounts
        Account testAccount1 = new Account(Name = 'testAccount1', Rate_Comments__c = 'test', Applicable_Segment_Revenue_Manual__c = 100, Fiscal_Year_Close_Manual__c = Date.today(), Operating_Income_Y1_Manual__c = 10, Operating_Income_Y2_Manual__c = 20, Operating_Income_Y3_Manual__c = 30, 
                              Rate_Comments_Manual__c = 'Test Comment', Rate_Last_Updated_By_Manual__c = 'Test Manual Update', Rate_Last_Updated_Manual__c = Date.today(), Revenue_Current_Year_Manual__c = 40, Entity_ID__c = 500000 + Math.Rint(Math.random()*250000));
        Account testAccount2 = new Account(Name = 'testAccount2', Rate_Comments__c = 'test', Applicable_Segment_Revenue_Manual__c = 100, Fiscal_Year_Close_Manual__c = Date.today(), Operating_Income_Y1_Manual__c = 10, Operating_Income_Y2_Manual__c = 20, Operating_Income_Y3_Manual__c = 30, 
                              Rate_Comments_Manual__c = 'Test Comment', Rate_Last_Updated_By_Manual__c = 'Test Manual Update', Rate_Last_Updated_Manual__c = Date.today(), Revenue_Current_Year_Manual__c = 40, Entity_ID__c = 500000 + Math.Rint(Math.random()*250000));
        Account testAccount3 = new Account(Name = 'testAccount3', Rate_Comments__c = 'test', Applicable_Segment_Revenue_Manual__c = 100, Fiscal_Year_Close_Manual__c = Date.today(), Operating_Income_Y1_Manual__c = 10, Operating_Income_Y2_Manual__c = 20, Operating_Income_Y3_Manual__c = 30, 
                              Rate_Comments_Manual__c = 'Test Comment', Rate_Last_Updated_By_Manual__c = 'Test Manual Update', Rate_Last_Updated_Manual__c = Date.today(), Revenue_Current_Year_Manual__c = 40, Entity_ID__c = 500000 + Math.Rint(Math.random()*250000));
        Account testAccount4 = new Account(Name = 'testAccount4', Rate_Comments__c = 'test', Applicable_Segment_Revenue_Manual__c = 100, Fiscal_Year_Close_Manual__c = Date.today(), Operating_Income_Y1_Manual__c = 10, Operating_Income_Y2_Manual__c = 20, Operating_Income_Y3_Manual__c = 30, 
                              Rate_Comments_Manual__c = 'Test Comment', Rate_Last_Updated_By_Manual__c = 'Test Manual Update', Rate_Last_Updated_Manual__c = Date.today(), Revenue_Current_Year_Manual__c = 40, Entity_ID__c = 500000 + Math.Rint(Math.random()*250000));
        insert new Account[]{testAccount4, testAccount3, testAccount2, testAccount1}; // inserting them backwards might get the order to line up with the semantics of the mock response helping with debugging.                              
        Account[] relatedAccounts = new Account[]{};
        for (Id i:CoreAPIMockResponseGenerator.getTestRecordIds_Account())
            relatedAccounts.add(new Account(Id = i)); // this makes sure to get them in the exact same order as the mock response generator uses
        
        // Patents (We just need to rebuild a list of these in the same order as the mock response)
        Patent__c[] relatedPatents = new Patent__c[]{};
        for (Id i:CoreAPIMockResponseGenerator.getTestRecordIds_Patent())
            relatedPatents.add(new Patent__c(Id = i)); // this makes sure to get them in the exact same order as the mock response generator uses
        
        // Product or Service Records
        Product_or_Service__c testProduct1 = new Product_or_Service__c(Name='testProduct1');
        Product_or_Service__c testProduct2 = new Product_or_Service__c(Name='testProduct2');
        Product_or_Service__c testProduct3 = new Product_or_Service__c(Name='testProduct3');
        Product_or_Service__c testProduct4 = new Product_or_Service__c(Name='testProduct4');
        insert new Product_or_Service__c[]{testProduct4, testProduct3, testProduct2, testProduct1}; // inserting them backwards might get the order to line up with the semantics of the mock response helping with debugging.
        Product_or_Service__c[] relatedProducts = new Product_or_Service__c[]{};
        for (Id i:CoreAPIMockResponseGenerator.getTestRecordIds_Product())
            relatedProducts.add(new Product_or_Service__c(Id = i)); // this makes sure to get them in the exact same order as the mock response generator uses
        
        
        // === STEP 4: SIMPLE SYNC RECORDS (SFDC ids inserted in mock) ===
        
        
        // Acquisitions & Related OMA Patent
        Acquisition_Opportunity__c testAcquisition1 = New Acquisition_Opportunity__c(Name='testAcquisition1', Account__c=relatedAccounts[0].Id, StageName__c='Closed Won', Probability__c='25', CloseDate__c=Date.today(), Amount_for_Pipeline__c=50, Purchase_Date__c = Date.today());
        Acquisition_Opportunity__c testAcquisition2 = New Acquisition_Opportunity__c(Name='testAcquisition2', Account__c=relatedAccounts[1].Id, StageName__c='Closed Won', Probability__c='25', CloseDate__c=Date.today(), Amount_for_Pipeline__c=50, Purchase_Date__c = Date.today());
        RecordType[] rts = [select id, name, developername from recordtype where SObjectType = 'Acquisition_Opportunity__c' and DeveloperName='OMA'];
        if (rts.size() > 0)  {
            testAcquisition1.RecordTypeId = rts[0].Id;
            testAcquisition2.RecordTypeId = rts[0].Id;
        } 
        insert new Acquisition_Opportunity__c[]{testAcquisition2, testAcquisition1}; // inserting them backwards might get the order to line up with the semantics of the mock response helping with debugging
        // Link testPatent201 to the acquisition 1
        OMA_Patent__c omap201 = new OMA_Patent__c(Patent__c=testPatent201.Id, Acquisition_Opportunity__c=testAcquisition1.Id);
        insert omap201;
        
        // Claim Charted Companies
        Accounts_with_Claim_Charts__c testClaimChartedCompanyA = new Accounts_with_Claim_Charts__c(Core_Claim_Charted_Company_Id__c = '-992011', Patent__c = relatedPatents[1].Id, Account__c = relatedAccounts[0].Id);
        Accounts_with_Claim_Charts__c testClaimChartedCompanyB = new Accounts_with_Claim_Charts__c(Core_Claim_Charted_Company_Id__c = '-992013', Patent__c = relatedPatents[1].Id, Account__c = relatedAccounts[2].Id);
        insert new Accounts_with_Claim_Charts__c[]{testClaimChartedCompanyA, testClaimChartedCompanyB};
        
        // Licensees
        Licensees__c testLicenseeA = new Licensees__c(Core_Licensee_Id__c = '-992011', Patent__c = relatedPatents[1].Id, Account__c = relatedAccounts[0].Id);
        Licensees__c testLicenseeB = new Licensees__c(Core_Licensee_Id__c = '-992013', Patent__c = relatedPatents[1].Id, Account__c = relatedAccounts[2].Id);
        insert new Licensees__c[]{testLicenseeA, testLicenseeB};
        
        // Relevant Companies
        Potentially_Relevant_Company__c testRelevantCompanyA = new Potentially_Relevant_Company__c(Core_Relevant_Company_Id__c = '-992011', Patent__c = relatedPatents[1].Id, Account__c = relatedAccounts[0].Id);
        Potentially_Relevant_Company__c testRelevantCompanyB = new Potentially_Relevant_Company__c(Core_Relevant_Company_Id__c = '-992013', Patent__c = relatedPatents[1].Id, Account__c = relatedAccounts[2].Id);
        insert new Potentially_Relevant_Company__c[]{testRelevantCompanyA, testRelevantCompanyB};
        
        // Tech Tags
        portfolio2product__c testTechTagA = new portfolio2product__c(Core_Tech_Tag_Id__c = -992011, Patent__c = testPatent201.Id, Portfolio__c = testPatentFamily2.Id, Product_or_Service__c = relatedProducts[0].Id);
        portfolio2product__c testTechTagB = new portfolio2product__c(Core_Tech_Tag_Id__c = -992013, Patent__c = testPatent201.Id, Portfolio__c = testPatentFamily2.Id, Product_or_Service__c = relatedProducts[2].Id);
        insert new portfolio2product__c[]{testTechTagA, testTechTagB};
         
        
        // Added 9/5/13 to prevent mysterious callout error that occurs only when deploying to production. - HRT
        // NOTE: This will have the effect of decreasing the test coverage's ability to detect DML callout conflicts, so
        //       it's probably a good idea to make sure that the test coverage works even with the next line commented out.
        SyncEngine.setDoNotCallout(true);
        
        
        // === STEP 5: BUILD RETURN MAP ===
        
        
        return new Map<String, Object>{
            'testPatentFamily2' => testPatentFamily2,
            'testPatentFamily3' => testPatentFamily3,
            'testPatent201' => testPatent201,
            'testPatent202' => testPatent202,
            'testPatent301' => testPatent301,
            'testPatent302' => testPatent302,
            'relatedAccount1' => relatedAccounts[0],
            'relatedAccount2' => relatedAccounts[1],
            'relatedAccount3' => relatedAccounts[2],
            'relatedAccount4' => relatedAccounts[3],
            'relatedPatent1' => relatedPatents[0],
            'relatedPatent2' => relatedPatents[1],
            'relatedPatent3' => relatedPatents[2],
            'relatedPatent4' => relatedPatents[3],
            'relatedProduct1' => relatedProducts[0],
            'relatedProduct2' => relatedProducts[1],
            'relatedProduct3' => relatedProducts[2],
            'relatedProduct4' => relatedProducts[3],
            'testAcquisition1' => testAcquisition1,
            'testAcquisition2' => testAcquisition2,
            'testClaimChartedCompanyA' => testClaimChartedCompanyA,
            'testClaimChartedCompanyB' => testClaimChartedCompanyB,
            'testLicenseeA' => testLicenseeA,
            'testLicenseeB' => testLicenseeB,
            'testRelevantCompanyA' => testRelevantCompanyA,
            'testRelevantCompanyB' => testRelevantCompanyB,
            'testTechTagA' => testTechTagA,
            'testTechTagB' => testTechTagB
        };
    }
    
    
    
    /*=== TRIGGER TEST FUNCTIONS ===*/
    
    
    public static testMethod void testTechTagTrigger_InsertLinkedToPatent() {
        // This is the standard apex test coverage method.
        
        system.debug('###testTechTagTrigger_InsertLinkedToPatent(): Entering function.###' );
        
        // First create test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Assets__c testPatentFamily2 = (Assets__c)testRecordMap.get('testPatentFamily2');
        Patent__c testPatent201 = (Patent__c)testRecordMap.get('testPatent201');
        Product_or_Service__c relatedProduct1 = (Product_or_Service__c)testRecordMap.get('relatedProduct1');
        Product_or_Service__c relatedProduct2 = (Product_or_Service__c)testRecordMap.get('relatedProduct2');
        
        // Start the test
        Test.startTest();
        
        // Now insert two tech tags (A should end up linked to 201, B should stay blank)
        portfolio2product__c testTechTagA = new portfolio2product__c(Core_Tech_Tag_Id__c = -992017, Product_or_Service__c = relatedProduct1.Id, Core_Patent_Key__c='US0000201');
        portfolio2product__c testTechTagB = new portfolio2product__c(Core_Tech_Tag_Id__c = -992018, Product_or_Service__c = relatedProduct2.Id, Core_Patent_Key__c='US0000299');
        insert new portfolio2product__c[]{testTechTagA, testTechTagB};
        
        // Stop the test and make assertions
        Test.stopTest();
        
        // Query the records and assert that tech tag A is linked, B is not) 
        testTechTagA = [select Id, Core_Patent_Key__c, Patent__c, Portfolio__c from portfolio2product__c where Id=:testTechTagA.Id];
        testTechTagB = [select Id, Core_Patent_Key__c, Patent__c, Portfolio__c from portfolio2product__c where Id=:testTechTagB.Id];
        
        system.assertEquals(testPatent201.Id, testTechTagA.Patent__c);
        system.assertEquals(testPatentFamily2.Id, testTechTagA.Portfolio__c);
        system.assertEquals(null, testTechTagB.Patent__c);
        system.assertEquals(null, testTechTagB.Portfolio__c);
        
        // And that's it.
        system.debug('###testTechTagTrigger_InsertLinkedToPatent(): Exiting function.###' );
    }
    
    public static testMethod void testPatentTrigger_InsertLinkedToTechTags() {
        // This is the standard apex test coverage method.
        
        system.debug('###testPatentTrigger_InsertLinkedToTechTags(): Entering function.###' );
        
        // First create (standard) test records
        Map<String, Object> testRecordMap = createAPITestRecords();
        Assets__c testPatentFamily2 = (Assets__c)testRecordMap.get('testPatentFamily2');
        Product_or_Service__c relatedProduct1 = (Product_or_Service__c)testRecordMap.get('relatedProduct1');
        Product_or_Service__c relatedProduct2 = (Product_or_Service__c)testRecordMap.get('relatedProduct2');
        
        // Now create custom test records - 3 tech tags... 2 of which (A & B) should end up linked by the patent trigger
        portfolio2product__c testTechTagA = new portfolio2product__c(Core_Tech_Tag_Id__c = -992016, Product_or_Service__c = relatedProduct1.Id, Core_Patent_Key__c='US0000299');
        portfolio2product__c testTechTagB = new portfolio2product__c(Core_Tech_Tag_Id__c = -992017, Product_or_Service__c = relatedProduct2.Id, Core_Patent_Key__c='US0000299');
        portfolio2product__c testTechTagC = new portfolio2product__c(Core_Tech_Tag_Id__c = -992018, Product_or_Service__c = relatedProduct1.Id, Core_Patent_Key__c='US0000298');
        insert new portfolio2product__c[]{testTechTagA, testTechTagB, testTechTagC};
        
        // Start the test
        Test.startTest();
        
        // Now insert the patent for tech tags A & B)
        Patent__c testPatent299= new Patent__c(Name='US0000299A1', Title__c='testPatent299', Country__c='US', Patent_No__c='0000299', Patent_Family__c=testPatentFamily2.Id, Core_DB_Patent_ID__c=(-99299));
        insert testPatent299;        
        
        // Stop the test and make assertions
        Test.stopTest();
        
        // Query the records and assert that tech tag A is linked, B is not) 
        testTechTagA = [select Id, Core_Patent_Key__c, Patent__c, Portfolio__c from portfolio2product__c where Id=:testTechTagA.Id];
        testTechTagB = [select Id, Core_Patent_Key__c, Patent__c, Portfolio__c from portfolio2product__c where Id=:testTechTagB.Id];
        testTechTagC = [select Id, Core_Patent_Key__c, Patent__c, Portfolio__c from portfolio2product__c where Id=:testTechTagC.Id];
        
        system.assertEquals(testPatent299.Id, testTechTagA.Patent__c);
        system.assertEquals(testPatentFamily2.Id, testTechTagA.Portfolio__c);
        system.assertEquals(testPatent299.Id, testTechTagB.Patent__c);
        system.assertEquals(testPatentFamily2.Id, testTechTagB.Portfolio__c);
        system.assertEquals(null, testTechTagC.Patent__c);
        system.assertEquals(null, testTechTagC.Portfolio__c);
        
        // And that's it.
        system.debug('###testPatentTrigger_InsertLinkedToTechTags(): Exiting function.###' );
    }
    
    
    public static testMethod void testPatentsInSuitTrigger_LitigationPatentFamilyCreated() {
        // This is the standard apex test coverage method.
        
        system.debug('###testPatentsInSuitTrigger_LitigationPatentFamilyCreated(): Entering function.###' );
        
        //First create the records
        Map<String, Object> testRecordMap = createTriggerTestRecords();
        
        // Start the test
        Test.startTest();
        
        // createTriggerTestRecords() already inserted the patents in suit so we just have to verify that 
        // the Litigation_Patent_Family__c records were created between testLitigationA/B and testPatentFamilyA/B
         
        // First pull the records out of the map
        Litigation__c testLitigationA = (Litigation__c)testRecordMap.get('testLitigationA');
        Litigation__c testLitigationB = (Litigation__c)testRecordMap.get('testLitigationB');
        Assets__c testPatentFamilyA = (Assets__c)testRecordMap.get('testPatentFamilyA');
        Assets__c testPatentFamilyB = (Assets__c)testRecordMap.get('testPatentFamilyB');
         
        // Now query the join records (actually we'll just query for integer counts)
        Integer litPatentFamilyAA = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer litPatentFamilyAB = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyB.Id];
        Integer litPatentFamilyBA = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer litPatentFamilyBB = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyB.Id];
        
        // Now assert that there is one of each
        system.assertEquals(1, litPatentFamilyAA);
        system.assertEquals(1, litPatentFamilyAB);
        system.assertEquals(1, litPatentFamilyBA);
        system.assertEquals(1, litPatentFamilyBB);
        
        // Now let's make sure that inserting another Patent in Suit for patent family a doesn't create a duplicate
        Patent__c testPatentA3 = new Patent__c(Name='testPatentA2', Title__c='testPatentA3', Patent_Family__c=testPatentFamilyA.Id, Core_DB_Patent_ID__c=(-987654313));
        insert testPatentA3;
        Patents_in_Suit__c litPatentAA3 = new Patents_in_Suit__c(Litigation__c=testLitigationA.Id, Patent__c=testPatentA3.Id);
        insert litPatentAA3;
        
        //there should still only be one linker record
        litPatentFamilyAA = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        system.assertEquals(1, litPatentFamilyAA);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testPatentsInSuitTrigger_LitigationPatentFamilyCreated(): Exiting function.###' );
    }
    
    public static testMethod void testPatentsInSuitTrigger_LitigationPatentFamilyDeleted() {
        // This is the standard apex test coverage method.
        
        system.debug('###testPatentsInSuitTrigger_LitigationPatentFamilyDeleted(): Entering function.###' );
        
        //First create the records
        Map<String, Object> testRecordMap = createTriggerTestRecords();
        
        // Start the test
        Test.startTest();
        
        // createTriggerTestRecords() already inserted the patents in suit so we first have to verify that 
        // the Litigation_Patent_Family__c records were created between testLitigationA/B and testPatentFamilyA/B
        // then we have to delete some of the patent in suit records 
        // and verify that the Litigation_Patent_Family__c records are no longer present
         
        // First pull the records out of the map
        Litigation__c testLitigationA = (Litigation__c)testRecordMap.get('testLitigationA');
        Litigation__c testLitigationB = (Litigation__c)testRecordMap.get('testLitigationB');
        Assets__c testPatentFamilyA = (Assets__c)testRecordMap.get('testPatentFamilyA');
        Assets__c testPatentFamilyB = (Assets__c)testRecordMap.get('testPatentFamilyB');
        Patents_in_Suit__c litPatentAA1 = (Patents_in_Suit__c)testRecordMap.get('litPatentAA1');
        Patents_in_Suit__c litPatentAB1 = (Patents_in_Suit__c)testRecordMap.get('litPatentAB1');
        Patents_in_Suit__c litPatentBA1 = (Patents_in_Suit__c)testRecordMap.get('litPatentBA1');
        Patents_in_Suit__c litPatentBB1 = (Patents_in_Suit__c)testRecordMap.get('litPatentBB1');
        
        // Now query the join records (actually we'll just query for integer counts)
        Integer litPatentFamilyAA = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer litPatentFamilyAB = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyB.Id];
        Integer litPatentFamilyBA = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer litPatentFamilyBB = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyB.Id];
        
        // Now assert that there is one of each
        system.assertEquals(1, litPatentFamilyAA);
        system.assertEquals(1, litPatentFamilyAB);
        system.assertEquals(1, litPatentFamilyBA);
        system.assertEquals(1, litPatentFamilyBB);
        
        
        // Next we delete the patent in suit records for patents A1 & B1 from both litigations
        // This should result in patentFamilyB being de-joined from litigationA (since only B1 was present)
        // and patentFamilyA being de-joined from litigationB (since only A1 was present)
        // In both cases, the other patent family should remain joined.
        
        delete new Patents_in_Suit__c[]{litPatentAA1, litPatentAB1, litPatentBA1, litPatentBB1};
        
        // requery the record counts
        litPatentFamilyAA = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        litPatentFamilyAB = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyB.Id];
        litPatentFamilyBA = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyA.Id];
        litPatentFamilyBB = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyB.Id];
        
        // Now assert that only the same-lettered patent families remain joined to the litigations
        system.assertEquals(1, litPatentFamilyAA);
        system.assertEquals(0, litPatentFamilyAB);
        system.assertEquals(0, litPatentFamilyBA);
        system.assertEquals(1, litPatentFamilyBB);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testPatentsInSuitTrigger_LitigationPatentFamilyDeleted(): Exiting function.###' );
    }
    
    public static testMethod void testPatentTriggers_PatentFamilyUpdatePropogated() {
        // This is the standard apex test coverage method.
        
        system.debug('###testPatentTriggers_PatentFamilyUpdatePropogated(): Entering function.###' );
        
        //First create the records
        Map<String, Object> testRecordMap = createTriggerTestRecords();
        
        
        // createTriggerTestRecords() already inserted the testPatentC and linked it to all of the records  
        // we just need to create a testPatentFamilyC and verify that all of the join records get created
        // then we need to create another testPatentFamilyD, change the patentFamily
        // and assert that the old join records were deleted and new records inserted 
         
        // First pull the records out of the map
        Patent__c testPatentC = (Patent__c)testRecordMap.get('testPatentC');
        Litigation__c testLitigationA = (Litigation__c)testRecordMap.get('testLitigationA');
        Litigation__c testLitigationB = (Litigation__c)testRecordMap.get('testLitigationB');
        Acquisition_Opportunity__c testAcquisitionA = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisitionA');
        Acquisition_Opportunity__c testAcquisitionB = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisitionB');
        portfolio2product__c p2ProductC = (portfolio2product__c)testRecordMap.get('p2ProductC');
        
        // Now insert the new patent family and update the patent record
        Assets__c testPatentFamilyC = new Assets__c(Name='testPatentFamilyC');
        insert testPatentFamilyC;
        testPatentC.Patent_Family__c = testPatentFamilyC.Id;
        update testPatentC;
        
        // Now query the join record counts (all of these should've been created by the PatentTrigger when we updated the patent)
        Integer litPatentFamilyAC = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyC.Id];
        Integer litPatentFamilyBC = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyC.Id];
        Integer omaPatentFamilyAC = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyC.Id];
        Integer omaPatentFamilyBC = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyC.Id];
        // The portfolio to product record just needs to be re-queried to make sure that the patent family field (portfolio) got updated
        p2ProductC = [select Id, Name, Portfolio__c from portfolio2product__c where Id=:p2ProductC.Id];
        
        // Now assert that there is one of each
        system.assertEquals(1, litPatentFamilyAC);
        system.assertEquals(1, litPatentFamilyBC);
        system.assertEquals(1, omaPatentFamilyAC);
        system.assertEquals(1, omaPatentFamilyBC);
        // Finally assert that the portfolio2product got updated correctly
        system.assertEquals(testPatentFamilyC.Id, p2ProductC.Portfolio__c);
        
        // Start the test (NOTE: I moved this to here in order to tactically reset the governor limits and avoid a SOQL query limit. - Hank)
        Test.startTest();
        
        // Next we insert another new patent family and update the patent record again
        Assets__c testPatentFamilyD = new Assets__c(Name='testPatentFamilyD');
        insert testPatentFamilyD;
        testPatentC.Patent_Family__c = testPatentFamilyD.Id;
        update testPatentC;
        testPatentFamilyD = [select Id, Name from Assets__c where Id=:testPatentFamilyD.Id];
        testPatentC = [select Id, Name, Patent_Family__c from Patent__c where Id=:testPatentC.Id];
        
        // Now query the join record counts of both the old and new patent family
        Integer litPatentFamilyAD = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyD.Id];
        Integer litPatentFamilyBD = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyD.Id];
        Integer omaPatentFamilyAD = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyD.Id];
        Integer omaPatentFamilyBD = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyD.Id];
        litPatentFamilyAC = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationA.Id and Patent_Family__c=:testPatentFamilyC.Id];
        litPatentFamilyBC = [select count() from Litigation_Patent_Family__c where Litigation__c=:testLitigationB.Id and Patent_Family__c=:testPatentFamilyC.Id];
        omaPatentFamilyAC = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyC.Id];
        omaPatentFamilyBC = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyC.Id];
        // The portfolio to product record just needs to be re-queried to make sure that the patent family field (portfolio) got updated
        p2ProductC = [select Id, Name, Portfolio__c from portfolio2product__c where Id=:p2ProductC.Id];
        
        // Now assert that there is one of each for the new patent family (D) ...
        system.assertEquals(1, litPatentFamilyAD);
        system.assertEquals(1, litPatentFamilyBD);
        system.assertEquals(1, omaPatentFamilyAD);
        system.assertEquals(1, omaPatentFamilyBD);
        // ... and none of each for the old patent family (C)
        system.assertEquals(0, litPatentFamilyAC);
        system.assertEquals(0, litPatentFamilyBC);
        system.assertEquals(0, omaPatentFamilyAC);
        system.assertEquals(0, omaPatentFamilyBC);
        
        // Finally assert that the portfolio2product got updated correctly
        system.assertEquals(testPatentFamilyD.Id, p2ProductC.Portfolio__c);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testPatentTriggers_PatentFamilyUpdatePropogated(): Exiting function.###' );
    }
    
    public static testMethod void testOMAPatentTriggers_AcquisitionPatentFamilyCreated() {
        // This is the standard apex test coverage method.
        
        system.debug('###testOMAPatentTriggers_AcquisitionPatentFamilyCreated(): Entering function.###' );
        
        //First create the records
        Map<String, Object> testRecordMap = createTriggerTestRecords();
        
        // Start the test
        Test.startTest();
        
        // createTriggerTestRecords() already inserted the oma patent records so we just have to verify that 
        // the Acquisition_Patent_Families__c  records were created between testAcquisitionA/B and testPatentFamilyA/B
         
        // First pull the records out of the map
        Acquisition_Opportunity__c testAcquisitionA = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisitionA');
        Acquisition_Opportunity__c testAcquisitionB = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisitionB');
        Assets__c testPatentFamilyA = (Assets__c)testRecordMap.get('testPatentFamilyA');
        Assets__c testPatentFamilyB = (Assets__c)testRecordMap.get('testPatentFamilyB');
         
        // Now query the join record counts
        Integer omaPatentFamilyAA = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer omaPatentFamilyAB = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyB.Id];
        Integer omaPatentFamilyBA = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer omaPatentFamilyBB = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyB.Id];
        
        // Now assert that there is one of each
        system.assertEquals(1, omaPatentFamilyAA);
        system.assertEquals(1, omaPatentFamilyAB);
        system.assertEquals(1, omaPatentFamilyBA);
        system.assertEquals(1, omaPatentFamilyBB);
        
        // Now let's make sure that inserting another OMA Patent for patent family A doesn't create a duplicate
        Patent__c testPatentA3 = new Patent__c(Name='testPatentA2', Title__c='testPatentA3', Patent_Family__c=testPatentFamilyA.Id, Core_DB_Patent_ID__c=(-987654313));
        insert testPatentA3;
        OMA_Patent__c omaPatentAA3 = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionA.Id, Patent__c=testPatentA3.Id);
        insert omaPatentAA3;
        
        //there should still only be one linker record
        omaPatentFamilyAA = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        system.assertEquals(1, omaPatentFamilyAA);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testOMAPatentTriggers_AcquisitionPatentFamilyCreated(): Exiting function.###' );
    }
    
    public static testMethod void testOMAPatentTriggers_AcquisitionPatentFamilyDeleted() {
        // This is the standard apex test coverage method.
        
        system.debug('###testOMAPatentTriggers_AcquisitionPatentFamilyDeleted(): Entering function.###' );
        
        //First create the records
        Map<String, Object> testRecordMap = createTriggerTestRecords();
        
        // Start the test
        Test.startTest();
        
        // createTriggerTestRecords() already inserted the oma patent records so we first have to verify that 
        // the Acquisition_Patent_Families__c  records were created between testAcquisitionA/B and testPatentFamilyA/B
        // then we have to delete some of the oma patent records 
        // and verify that the corresponding Acquisition_Patent_Families__c records are no longer present
         
        // First pull the records out of the map
        Acquisition_Opportunity__c testAcquisitionA = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisitionA');
        Acquisition_Opportunity__c testAcquisitionB = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisitionB');
        Assets__c testPatentFamilyA = (Assets__c)testRecordMap.get('testPatentFamilyA');
        Assets__c testPatentFamilyB = (Assets__c)testRecordMap.get('testPatentFamilyB');
        OMA_Patent__c omaPatentAA1 = (OMA_Patent__c)testRecordMap.get('omaPatentAA1');
        OMA_Patent__c omaPatentAB1 = (OMA_Patent__c)testRecordMap.get('omaPatentAB1');
        OMA_Patent__c omaPatentBA1 = (OMA_Patent__c)testRecordMap.get('omaPatentBA1');
        OMA_Patent__c omaPatentBB1 = (OMA_Patent__c)testRecordMap.get('omaPatentBB1');
        
        // Now query the join record counts
        Integer omaPatentFamilyAA = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer omaPatentFamilyAB = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyB.Id];
        Integer omaPatentFamilyBA = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyA.Id];
        Integer omaPatentFamilyBB = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyB.Id];
        
        // Now assert that there is one of each
        system.assertEquals(1, omaPatentFamilyAA);
        system.assertEquals(1, omaPatentFamilyAB);
        system.assertEquals(1, omaPatentFamilyBA);
        system.assertEquals(1, omaPatentFamilyBB);
        
        
        // Next we delete the oma patent records for patents A1 & B1 from both acquisitions
        // This should result in patentFamilyB being de-joined from acquisitionA (since only B1 was present)
        // and patentFamilyA being de-joined from acquisitionB (since only A1 was present)
        // In both cases, the other patent family should remain joined.
        
        delete new OMA_Patent__c[]{omaPatentAA1, omaPatentAB1, omaPatentBA1, omaPatentBB1};
        
        // requery the record counts
        omaPatentFamilyAA = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyA.Id];
        omaPatentFamilyAB = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionA.Id and Patent_Family__c=:testPatentFamilyB.Id];
        omaPatentFamilyBA = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyA.Id];
        omaPatentFamilyBB = [select count() from Acquisition_Patent_Families__c where Acquisition_Opportunity__c=:testAcquisitionB.Id and Patent_Family__c=:testPatentFamilyB.Id];
        
        // Now assert that only the same-lettered patent families remain joined to the litigations
        system.assertEquals(1, omaPatentFamilyAA);
        system.assertEquals(0, omaPatentFamilyAB);
        system.assertEquals(0, omaPatentFamilyBA);
        system.assertEquals(1, omaPatentFamilyBB);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testOMAPatentTriggers_AcquisitionPatentFamilyDeleted(): Exiting function.###' );
    }
    
    public static testMethod void testPRCTrigger_LinkPatentFamily() {
        // This is the standard apex test coverage method.
        
        system.debug('###testPRCTrigger_LinkPatentFamily(): Entering function.###' );
        
        //First create the records
        Map<String, Object> testRecordMap = createTriggerTestRecords();
        Patent__c testPatentA1 = (Patent__c)testRecordMap.get('testPatentA1');
        Patent__c testPatentB1 = (Patent__c)testRecordMap.get('testPatentB1');
        Assets__c testPatentFamilyA = (Assets__c)testRecordMap.get('testPatentFamilyA');
        Assets__c testPatentFamilyB = (Assets__c)testRecordMap.get('testPatentFamilyB');
        Account testAccount = (Account)testRecordMap.get('testAccount');
        
        // Start the test
        Test.startTest();
        
        // Insert a PRC and assert that the insert trigger works
        Potentially_Relevant_Company__c prc = new Potentially_Relevant_Company__c(Account__c = testAccount.Id, Patent__c = testPatentA1.Id, Core_Patent_Family_Id__c = testPatentFamilyA.Core_Patent_Family_Id__c);
        insert prc;
        prc = [select Id, Core_Patent_Family_Id__c, Patent_Family__c from Potentially_Relevant_Company__c where Id=:prc.Id];
        system.assertEquals(testPatentFamilyA.Id, prc.Patent_Family__c);
        
        // Then update it and assert that the update trigger works
        prc.Core_Patent_Family_Id__c = testPatentFamilyB.Core_Patent_Family_Id__c;
        update prc;
        prc = [select Id, Core_Patent_Family_Id__c, Patent_Family__c from Potentially_Relevant_Company__c where Id=:prc.Id];
        system.assertEquals(testPatentFamilyB.Id, prc.Patent_Family__c);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testPRCTrigger_LinkPatentFamily(): Exiting function.###' );
    }
    
    public static testMethod void testLicenseeTrigger_LinkPatentFamily() {
        // This is the standard apex test coverage method.
        
        system.debug('###testLicenseeTrigger_LinkPatentFamily(): Entering function.###' );
        
        //First create the records
        Map<String, Object> testRecordMap = createTriggerTestRecords();
        Patent__c testPatentA1 = (Patent__c)testRecordMap.get('testPatentA1');
        Patent__c testPatentB1 = (Patent__c)testRecordMap.get('testPatentB1');
        Assets__c testPatentFamilyA = (Assets__c)testRecordMap.get('testPatentFamilyA');
        Assets__c testPatentFamilyB = (Assets__c)testRecordMap.get('testPatentFamilyB');
        Account testAccount = (Account)testRecordMap.get('testAccount');
        
        // Start the test
        Test.startTest();
        
        // Insert a PRC and assert that the insert trigger works
        Licensees__c licensee = new Licensees__c(Account__c = testAccount.Id, Patent__c = testPatentA1.Id, Core_Patent_Family_Id__c = testPatentFamilyA.Core_Patent_Family_Id__c);
        insert licensee;
        licensee = [select Id, Core_Patent_Family_Id__c, Patent_Family__c from Licensees__c where Id=:licensee.Id];
        system.assertEquals(testPatentFamilyA.Id, licensee.Patent_Family__c);
        
        // Then update it and assert that the update trigger works
        licensee.Core_Patent_Family_Id__c = testPatentFamilyB.Core_Patent_Family_Id__c;
        update licensee;
        licensee = [select Id, Core_Patent_Family_Id__c, Patent_Family__c from Licensees__c where Id=:licensee.Id];
        system.assertEquals(testPatentFamilyB.Id, licensee.Patent_Family__c);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testLicenseeTrigger_LinkPatentFamily(): Exiting function.###' );
    }
    
    
    public static Map<String, Object> createTriggerTestRecords() {
        // Inserts sample records for trigger testMethods
        // Returns a map from the string name listed below to the salesforce record
        //     > Account w/Names = testAccount (is seller/broker for acquisitions)
        //     > Litigations w/Names = testLitigationA, testLitigationB 
        //     > OMA Acquisition Opps w/Names = testAcquisitionA, testAcquisitionB
        //     > Patent Families w/Names = testPatentFamilyA, testPatentFamilyB
        //     > Patents w/Names = testPatentA1, testPatentA1, testPatentB1, testPatentB2, testPatentC (with blank patent family)
        //     > OMA Patents w/Keys = omaPatentAA1 (links testAcquisitionA with testPatentA1), omaPatentAA2, omaPatentAB1, omaPatentAC, omaPatentBA1, omaPatentBB1, omaPatentBB2, omaPatentBC
        //     > Patents in Suit w/Keys = litPatentAA1 (links testLitigationA with testPatentA1), litPatentAA2, litPatentAB1, litPatentAC, litPatentBA1, litPatentBB1, litPatentBB2, litPatentBC
        //     > Product or Service w/Name = testProduct (used for portfolio2products)
        //     > Portfolio to Product Mappings w/Keys = p2ProductA1 (links testProduct with testPatentA1), p2ProductA2, p2ProductB1, p2ProductB2, p2ProductC
        
        Map<String, Object> testRecordMap = new Map<String, Object>();
        
        system.debug('###createTriggerTestRecords(): Entering function.###');
        
        //Insert the records group by group, adding each record to the map
        
        // > Account w/Names = testAccount (is seller/broker for acquisitions)
        Account testAccount = new Account(Name='testAccount', Entity_ID__c=(-123456789));
        insert testAccount;
        testRecordMap.put('testAccount', testAccount);
        
        // > Litigations w/Names = testLitigationA, testLitigationB
        Litigation__c testLitigationA = new Litigation__c(Name='testLitigationA');
        Litigation__c testLitigationB = new Litigation__c(Name='testLitigationB');
        insert new Litigation__c[]{testLitigationA, testLitigationB};
        testRecordMap.put('testLitigationA', testLitigationA);
        testRecordMap.put('testLitigationB', testLitigationB); 
        
        // > OMA Acquisition Opps w/Names = testAcquisitionA, testAcquisitionB
        Id acquisitionRecordTypeId = [select Id from RecordType where sObjectType='Acquisition_Opportunity__c' and Name='OMA' limit 1][0].id; //this will error out if the OMA record type is changed
        Acquisition_Opportunity__c testAcquisitionA = new Acquisition_Opportunity__c(Name='testAcquisitionA', RecordTypeId=acquisitionRecordTypeId, Account__c=testAccount.Id, StageName__c='Phase 1', LegacyOpportunityID__c='zqzzz11111');
        Acquisition_Opportunity__c testAcquisitionB = new Acquisition_Opportunity__c(Name='testAcquisitionB', RecordTypeId=acquisitionRecordTypeId, Account__c=testAccount.Id, StageName__c='Phase 1', LegacyOpportunityID__c='zqzzz22222');
        insert new Acquisition_Opportunity__c[]{testAcquisitionA, testAcquisitionB};
        testRecordMap.put('testAcquisitionA', testAcquisitionA);
        testRecordMap.put('testAcquisitionB', testAcquisitionB); 
        
        // > Patent Families w/Names = testPatentFamilyA, testPatentFamilyB
        Assets__c testPatentFamilyA = new Assets__c(Name='testPatentFamilyA', Core_Patent_Family_Id__c = -99111);
        Assets__c testPatentFamilyB = new Assets__c(Name='testPatentFamilyB', Core_Patent_Family_Id__c = -99222);
        insert new Assets__c[]{testPatentFamilyA, testPatentFamilyB};
        testRecordMap.put('testPatentFamilyA', testPatentFamilyA);
        testRecordMap.put('testPatentFamilyB', testPatentFamilyB); 
        
        // > Patents w/Names = testPatentA1, testPatentA1, testPatentB1, testPatentB2, testPatentC (with blank patent family)
        Patent__c testPatentA1 = new Patent__c(Name='testPatentA1', Title__c='testPatentA1', Patent_Family__c=testPatentFamilyA.Id, Core_DB_Patent_ID__c=(-987654321));
        Patent__c testPatentA2 = new Patent__c(Name='testPatentA2', Title__c='testPatentA2', Patent_Family__c=testPatentFamilyA.Id, Core_DB_Patent_ID__c=(-987654322));
        Patent__c testPatentB1 = new Patent__c(Name='testPatentB1', Title__c='testPatentB1', Patent_Family__c=testPatentFamilyB.Id, Core_DB_Patent_ID__c=(-987654323));
        Patent__c testPatentB2 = new Patent__c(Name='testPatentB2', Title__c='testPatentB2', Patent_Family__c=testPatentFamilyB.Id, Core_DB_Patent_ID__c=(-987654324));
        Patent__c testPatentC = new Patent__c(Name='testPatentC', Title__c='testPatentC', Core_DB_Patent_ID__c=(-987654325));
        insert new Patent__c[]{testPatentA1, testPatentA2, testPatentB1, testPatentB2, testPatentC};
        testRecordMap.put('testPatentA1', testPatentA1);
        testRecordMap.put('testPatentA2', testPatentA2); 
        testRecordMap.put('testPatentB1', testPatentB1);
        testRecordMap.put('testPatentB2', testPatentB2);
        testRecordMap.put('testPatentC', testPatentC);
        
        // > OMA Patents w/Keys = omaPatentAA1 (links testAcquisitionA with testPatentA1), omaPatentAA2, omaPatentAB1, omaPatentAC, omaPatentBA1, omaPatentBB1, omaPatentBB2, omaPatentBC
        OMA_Patent__c omaPatentAA1 = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionA.Id, Patent__c=testPatentA1.Id);
        OMA_Patent__c omaPatentAA2 = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionA.Id, Patent__c=testPatentA2.Id);
        OMA_Patent__c omaPatentAB1 = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionA.Id, Patent__c=testPatentB1.Id);
        OMA_Patent__c omaPatentAC = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionA.Id, Patent__c=testPatentC.Id);
        OMA_Patent__c omaPatentBA1 = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionB.Id, Patent__c=testPatentA1.Id);
        OMA_Patent__c omaPatentBB1 = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionB.Id, Patent__c=testPatentB1.Id);
        OMA_Patent__c omaPatentBB2 = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionB.Id, Patent__c=testPatentB2.Id);
        OMA_Patent__c omaPatentBC = new OMA_Patent__c(Acquisition_Opportunity__c=testAcquisitionB.Id, Patent__c=testPatentC.Id);
        insert new OMA_Patent__c[]{omaPatentAA1, omaPatentAA2, omaPatentAB1, omaPatentAC, omaPatentBA1, omaPatentBB1, omaPatentBB2, omaPatentBC};
        testRecordMap.put('omaPatentAA1', omaPatentAA1);
        testRecordMap.put('omaPatentAA2', omaPatentAA2);
        testRecordMap.put('omaPatentAB1', omaPatentAB1);
        testRecordMap.put('omaPatentAC', omaPatentAC);
        testRecordMap.put('omaPatentBA1', omaPatentBA1);
        testRecordMap.put('omaPatentBB1', omaPatentBB1);
        testRecordMap.put('omaPatentBB2', omaPatentBB2);
        testRecordMap.put('omaPatentBC', omaPatentBC);
        
        // > Patents in Suit w/Keys = litPatentAA1 (links testLitigationA with testPatentA1), litPatentAA2, litPatentAB1, litPatentAC, litPatentBA1, litPatentBB1, litPatentBB2, litPatentBC
        Patents_in_Suit__c litPatentAA1 = new Patents_in_Suit__c(Litigation__c=testLitigationA.Id, Patent__c=testPatentA1.Id);
        Patents_in_Suit__c litPatentAA2 = new Patents_in_Suit__c(Litigation__c=testLitigationA.Id, Patent__c=testPatentA2.Id);
        Patents_in_Suit__c litPatentAB1 = new Patents_in_Suit__c(Litigation__c=testLitigationA.Id, Patent__c=testPatentB1.Id);
        Patents_in_Suit__c litPatentAC = new Patents_in_Suit__c(Litigation__c=testLitigationA.Id, Patent__c=testPatentC.Id);
        Patents_in_Suit__c litPatentBA1 = new Patents_in_Suit__c(Litigation__c=testLitigationB.Id, Patent__c=testPatentA1.Id);
        Patents_in_Suit__c litPatentBB1 = new Patents_in_Suit__c(Litigation__c=testLitigationB.Id, Patent__c=testPatentB1.Id);
        Patents_in_Suit__c litPatentBB2 = new Patents_in_Suit__c(Litigation__c=testLitigationB.Id, Patent__c=testPatentB2.Id);
        Patents_in_Suit__c litPatentBC = new Patents_in_Suit__c(Litigation__c=testLitigationB.Id, Patent__c=testPatentC.Id);
        insert new Patents_in_Suit__c[]{litPatentAA1, litPatentAA2, litPatentAB1, litPatentAC, litPatentBA1, litPatentBB1, litPatentBB2, litPatentBC};
        testRecordMap.put('litPatentAA1', litPatentAA1);
        testRecordMap.put('litPatentAA2', litPatentAA2);
        testRecordMap.put('litPatentAB1', litPatentAB1);
        testRecordMap.put('litPatentAC', litPatentAC);
        testRecordMap.put('litPatentBA1', litPatentBA1);
        testRecordMap.put('litPatentBB1', litPatentBB1);
        testRecordMap.put('litPatentBB2', litPatentBB2);
        testRecordMap.put('litPatentBC', litPatentBC);
        
        // > Product or Service w/Name = testProduct (used for portfolio2products)
        Product_or_Service__c testProduct = new Product_or_Service__c(Name='testProduct');
        insert testProduct;
        testRecordMap.put('testProduct', testProduct);
        
        // > Portfolio to Product Mappings w/Keys = p2ProductA1 (links testProduct with testPatentA1), p2ProductA2, p2ProductB1, p2ProductB2, p2ProductC
        portfolio2product__c p2ProductA1 = new portfolio2product__c(Patent__c=testPatentA1.Id, Portfolio__c=testPatentFamilyA.Id, Product_or_Service__c=testProduct.Id, Tier__c='1');
        portfolio2product__c p2ProductA2 = new portfolio2product__c(Patent__c=testPatentA2.Id, Portfolio__c=testPatentFamilyA.Id, Product_or_Service__c=testProduct.Id, Tier__c='1');
        portfolio2product__c p2ProductB1 = new portfolio2product__c(Patent__c=testPatentB1.Id, Portfolio__c=testPatentFamilyB.Id, Product_or_Service__c=testProduct.Id, Tier__c='1');
        portfolio2product__c p2ProductB2 = new portfolio2product__c(Patent__c=testPatentB2.Id, Portfolio__c=testPatentFamilyB.Id, Product_or_Service__c=testProduct.Id, Tier__c='1');
        portfolio2product__c p2ProductC = new portfolio2product__c(Patent__c=testPatentC.Id, Product_or_Service__c=testProduct.Id, Tier__c='1');
        insert new portfolio2product__c[]{p2ProductA1, p2ProductA2, p2ProductB1, p2ProductB2, p2ProductC};
        testRecordMap.put('p2ProductA1', p2ProductA1);
        testRecordMap.put('p2ProductA2', p2ProductA2);
        testRecordMap.put('p2ProductB1', p2ProductB1);
        testRecordMap.put('p2ProductB2', p2ProductB2);
        testRecordMap.put('p2ProductC', p2ProductC);
        
        system.debug('###createTriggerTestRecords(): Exiting function.###');
        return testRecordMap;
    }
    
      
    private static testMethod void testSyncEngine_Coverage() {
    
        system.debug('###testSyncEngine_Coverage(): Exiting function.###');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        SyncEngine.testSyncEngine_Live();
        
        SyncEngine.mapToString(new Map<String, String>{'a'=>'1', 'b'=>'2'});
        SyncEngine.getDetailURL(new Patent__c());
        SyncEngine.getDetailURL(new Assets__c());
        Boolean exceptionEncountered = false;
        try {SyncEngine.getDetailURL(new Account());} catch(Exception e) {exceptionEncountered = true;}
        system.assertEquals(true, exceptionEncountered);
        
        Test.stopTest();
        
        system.debug('###testSyncEngine_Coverage(): Exiting function.###');
        
    }
    
      
}