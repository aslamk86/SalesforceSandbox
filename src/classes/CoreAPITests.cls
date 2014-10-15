/****************************************************
   
    CORE API TESTS
   
    Built by Hank Ryan Thompson.
    Created 6/24/2013.
    Last updated 10/17/2103 by Hank.
   
    This class contains testMethods that test the
    functionality of the CoreAPI class.
    
****************************************************/

@isTest(SeeAllData=true)
public class CoreAPITests {
    
    /*=== FUNCTIONAL TESTING ===*/
    
    public static testMethod void testCoreAPI_Parsing() {
        // This tests the ability of CoreAPI to parse JSON text into ResponseRows
        
        system.debug('###testCoreAPI_Parsing(): Entering function.###');
        
        // Start the test and setMock (which mosk the responses to the http callouts) 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        String[] patentNumbers = new String[]{'1234567', '2345678'}; //doesn't matter, response is mocked
        
        // Run the live test. Since this is a testMethod the httpCallouts will be mocked
        CoreAPI.ResponseRow[] responseRows_Patents = CoreAPI.getPatents(patentNumbers, true, true, true);
        CoreAPI.ResponseRow[] responseRows_PatentFamilies = CoreAPI.getPatentFamilies(null, null, null, patentNumbers, true, true, true, true, true, true);
        
        //Finally make some basic assertions
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_PATENT_ROWS, responseRows_Patents.size());
        system.assert(responseRows_Patents[0].hasSingleChildren() == true);
        system.assert(responseRows_Patents[0].singleChildren.get('patent_family') != null);
        system.assert(responseRows_Patents[0].hasListChildren() == true);
        system.assert(responseRows_Patents[0].listChildren.get('most_recent_assignees') != null);
        system.assertEquals(2, responseRows_Patents[0].listChildren.get('most_recent_assignees').size()); //the mocked response rows have exactly two of these
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_PATENT_FAMILY_ROWS, responseRows_PatentFamilies.size());
        
        // And that's it.
        Test.stopTest();
        system.debug('###testCoreAPI_Parsing(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_FieldFlattening() {
        // This tests that the CoreAPI.ResponseRow.refreshFlattenedFields() function works as designed
        
        system.debug('###testCoreAPI_FieldFlattening(): Entering function.###');
        
        // Start the test and setMock (which mosk the responses to the http callouts) 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // First get the mocked patent response and assert that there is at least one row 
        CoreAPI.ResponseRow[] rr = CoreAPI.getPatents(new String[]{}, true, true, true); //parameters don't matter since this will be mocked
        system.assert(rr.size() > 0);
        
        // Now create pull the first response row and assert that it has 2 most recent assignees and a patent family 
        CoreAPI.ResponseRow r = rr[0];
        system.assert(r.listChildren.get('most_recent_assignees') != null);
        system.assertEquals(2, r.listChildren.get('most_recent_assignees').size());
        system.assert(r.singleChildren.containsKey('patent_family'));
        
        // Finally we flatten the fields and make sure it worked
        r.refreshFlattenedValues(null);
        String expectedValue = String.join(new String[]{'item1', 'item2'}, CoreAPI.LIST_JOIN_STRING);
        system.assertEquals(expectedValue, r.allFlattenedValues.get('most_recent_assignees'));
        system.assert(r.allFlattenedValues.get('patent_family') != null);
        
        // And that's it.
        Test.stopTest();
        system.debug('###testCoreAPI_FieldFlattening(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_Pagination() {
        // This tests that pagination works properly
        
        system.debug('###testCoreAPI_Pagination(): Entering function.###');
        
        // Start the test and setMock (which mosk the responses to the http callouts) 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // First get the mocked patent response and assert that there is at least one row 
        DateTime fromDateTime = DateTime.now().addDays(-1); // doesn't really matter what this is, response is mocked
        
        system.debug('###testCoreAPI_Pagination(): FIRSTPAGERESPONSE.###');
        CoreAPI.PaginatedResponse firstPageResponse = CoreAPI.getPatentFamilyChanges(fromDateTime, 1, null);
        system.debug('###testCoreAPI_Pagination(): SECONDPAGERESPONSE.###');
        CoreAPI.PaginatedResponse secondPageResponse = CoreAPI.getPatentFamilyChanges(fromDateTime, 2, null);
        system.debug('###testCoreAPI_Pagination(): LASTPAGERESPONSE.###');
        CoreAPI.PaginatedResponse lastPageResponse = CoreAPI.getPatentFamilyChanges(fromDateTime, CoreAPIMockResponseGenerator.NUMBER_OF_PAGES, null);
        
        // Stop the test and make assertions
        Test.stopTest();
        
        system.assertEquals(CoreAPIMockResponseGenerator.NUMBER_OF_PAGES, firstPageResponse.pageCount);
        system.assertEquals(CoreAPI.PAGE_SIZE, firstPageResponse.perPage);
        //system.assertEquals(CoreAPI.PAGE_SIZE*CoreAPIMockResponseGenerator.NUMBER_OF_PAGES, firstPageResponse.itemCount); // >> silly to test this
        
        system.assertEquals(1, firstPageResponse.currentPage);
        system.assertEquals(2, firstPageResponse.nextPage);
        system.assertEquals(null, firstPageResponse.previousPage);
        
        system.assertEquals(2, secondPageResponse.currentPage);
        system.assertEquals(3, secondPageResponse.nextPage);
        system.assertEquals(1, secondPageResponse.previousPage);
        
        system.assertEquals(CoreAPIMockResponseGenerator.NUMBER_OF_PAGES, lastPageResponse.currentPage);
        system.assertEquals(null, lastPageResponse.nextPage);
        system.assertEquals(CoreAPIMockResponseGenerator.NUMBER_OF_PAGES-1, lastPageResponse.previousPage);
        
        // That's it!
        system.debug('###testCoreAPI_Pagination(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_LongURLs() {
        // This tests the bounds around log query URLs
        
        system.debug('###testCoreAPI_LongURLs(): Entering function.###');
        
        
        // First build out two lists of patent numbers
        String patentNumber = '1234567';
        Integer patentNumberLength = '&stripped_patnum=1234567'.length(); // note: this will be inexact due to the other parameters
        
        String[] longPatentNumberList = new String[]{}; // this will be long enough to require 2 queries
        String[] reallyLongPatentNumberList = new String[]{}; // this will be long enough to require more than 10 queries (thus hiting the upper limit for callouts)
        
        Integer longLength = Integer.valueOf((CoreAPI.MAX_URL_LENGTH*1.5)/patentNumberLength);
        Integer reallyLongLength = longLength*10;
        
        for (Integer i=0; i<longLength; i++) longPatentNumberList.add(patentNumber);
        for (Integer i=0; i<reallyLongLength; i++) reallyLongPatentNumberList.add(patentNumber);
        
        // Start the test and setMock (which mocks the responses to the http callouts) 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        CoreAPI.ResponseRow[] responseRows_Long;
        CoreAPI.ResponseRow[] responseRows_ReallyLong;
        Boolean isError_Long = false;
        Boolean isError_ReallyLong = false;
        
        try {
            responseRows_Long = CoreAPI.getPatents(longPatentNumberList, false, false, false);
        } catch(Exception e) {
            isError_Long = true;
        }
        
        try {
            responseRows_ReallyLong = CoreAPI.getPatents(reallyLongPatentNumberList, false, false, false);
        } catch(Exception e) {
            isError_ReallyLong = true;
        }
        
        
        // Stop the test and make assertions
        Test.stopTest();
        
        // The long one should have NOT had an error, it should've run twice (remember that the mock response is fixed regardless of the query)
        system.assertEquals(false, isError_Long);
        system.assert(responseRows_Long != null);
        system.assertEquals(CoreAPIMockResponseGenerator.NUM_PATENT_ROWS*2, responseRows_Long.size());
        
        // The really long one should have errored out (by running out of web service callouts)
        system.assertEquals(true, isError_ReallyLong);
        
        // That's it!
        system.debug('###testCoreAPI_LongURLs(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_MockResponseIdInsertion() {
        // Tests that the mock response generator is properly inserting salesforce ids (this test is very meta)
        
        system.debug('###testCoreAPI_MockResponseIdInsertion(): Entering function.###');
        
        // Start the test and setMock (which mosk the responses to the http callouts) 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        String[] acquisitionIds = new String[]{'1234567', '2345678'}; //doesn't matter, response is mocked
        
        // Run the live test. Since this is a testMethod the httpCallouts will be mocked
        CoreAPI.ResponseRow[] responseRows = CoreAPI.getPortfolios(acquisitionIds);
        
        // Stop the test and make assertions
        Test.stopTest();
        
        system.assert(responseRows.size() > 0);
        Boolean responseRowsHaveValidIds;
        try {
            Id acquisitionId = (Id)responseRows[0].singleValues.get('id');
            Acquisition_Opportunity__c acquisition = [select Id from Acquisition_Opportunity__c where Id=:acquisitionId];
            responseRowsHaveValidIds = (acquisition != null);
        } catch(Exception e) {
            responseRowsHaveValidIds = false;
        }
        
        Acquisition_Opportunity__c[] acquisitions = [select Id from Acquisition_Opportunity__c limit 1];
        Boolean thereAreAcquisitionsInTheDatabase = (acquisitions.size() > 0); // we might be running in a database without data
        
        system.assert(responseRowsHaveValidIds == thereAreAcquisitionsInTheDatabase);
        
        // Done!
        system.debug('###testCoreAPI_MockResponseIdInsertion(): Exiting function.###');
    }
    
    
    
    /*=== ENDPOINT TESTING / COVERAGE ===*/
    
    public static testMethod void testCoreAPI_GeneralCoverage() {
        // This is the standard apex test coverage method.
        // It is essentially a shell for the testCoreAPI_Live() function, but with mocked http callouts.
        
        system.debug('###testCoreAPI_GeneralCoverage(): Entering function.###');
        
        // Start the test and setMock (which mosk the responses to the http callouts) 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        
        // Run the live test. Since this is a testMethod the httpCallouts will be mocked
        CoreAPI.testCoreAPI_Live();
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.PatentFamilyChanges);
        
        // More test coverage
        CoreAPI.ResponseRow rr = new CoreAPI.ResponseRow();
        //CoreAPI.PaginatedResponse pr = new CoreAPI.PaginatedResponse();
        rr.hasListChildren();
        rr.hasSingleChildren();
        
        // And that's it.
        Test.stopTest();
        system.debug('###testCoreAPI_GeneralCoverage(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_ClaimChartedCompanies() {
        system.debug('###testCoreAPI_Licensees(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.ClaimChartedCompanies);
        Test.stopTest();
        system.debug('###testCoreAPI_Licensees(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_Licensees() {
        system.debug('###testCoreAPI_Patents(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.Licensees);
        Test.stopTest();
        system.debug('###testCoreAPI_Patents(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_Patents() {
        system.debug('###testCoreAPI_Patents(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.Patents);
        Test.stopTest();
        system.debug('###testCoreAPI_Patents(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_PatentAnnotations() {
        system.debug('###testCoreAPI_PatentAnnotations(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.PatentAnnotations);
        Test.stopTest();
        system.debug('###testCoreAPI_PatentAnnotations(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_PatentFamilies() {
        system.debug('###testCoreAPI_PatentFamilies(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.PatentFamilies);
        Test.stopTest();
        system.debug('###testCoreAPI_PatentFamilies(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_Portfolios() {
        system.debug('###testCoreAPI_Portfolios(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.Portfolios);
        Test.stopTest();
        system.debug('###testCoreAPI_Portfolios(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_RelevantCompanies() {
        system.debug('###testCoreAPI_RelevantCompanies(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.RelevantCompanies);
        Test.stopTest();
        system.debug('###testCoreAPI_RelevantCompanies(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_TechTags() {
        system.debug('###testCoreAPI_TechTags(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.TechTags);
        Test.stopTest();
        system.debug('###testCoreAPI_TechTags(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_ClaimChartedCompanyChanges() {
        system.debug('###testCoreAPI_ClaimChartedCompanyChanges(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.ClaimChartedCompanyChanges);
        Test.stopTest();
        system.debug('###testCoreAPI_ClaimChartedCompanyChanges(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_LicenseeChanges() {
        system.debug('###testCoreAPI_LicenseeChanges(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.LicenseeChanges);
        Test.stopTest();
        system.debug('###testCoreAPI_LicenseeChanges(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_PatentAnnotationChanges() {
        system.debug('###testCoreAPI_PatentAnnotationChanges(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.PatentAnnotationChanges);
        Test.stopTest();
        system.debug('###testCoreAPI_PatentAnnotationChanges(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_PatentFamilyChanges() {
        system.debug('###testCoreAPI_PatentFamilyChanges(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.PatentFamilyChanges);
        Test.stopTest();
        system.debug('###testCoreAPI_PatentFamilyChanges(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_PortfolioAnnotationChanges() {
        system.debug('###testCoreAPI_PortfolioAnnotationChanges(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.PortfolioAnnotationChanges);
        Test.stopTest();
        system.debug('###testCoreAPI_PortfolioAnnotationChanges(): Exiting function.###');
    }
    
    public static testMethod void testCoreAPI_RelevantCompanyChanges() {
        system.debug('###testCoreAPI_RelevantCompanyChanges(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.RelevantCompanyChanges);
        Test.stopTest();
        system.debug('###testCoreAPI_RelevantCompanyChanges(): Exiting function.###');
    }

    public static testMethod void testCoreAPI_TechTagChanges() {
        system.debug('###testCoreAPI_TechTagChanges(): Entering function.###');
        Test.startTest(); Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
        CoreAPI.testCoreAPI_Live(CoreAPI.EndpointName.TechTagChanges);
        Test.stopTest();
        system.debug('###testCoreAPI_TechTagChanges(): Exiting function.###');
    }
    
    
   
}