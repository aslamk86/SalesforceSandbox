/**********************************************************************************
   
    CORE API MOCK RESPONSE GENERATOR
   
    Built by Hank Ryan Thompson.
    Created 6/25/2013.
    Last updated 10/8/2013 by Hank.
   
    This class must be used by any test methods 
    which use the CoreAPI or SyncEngine. It mocks up
    the HTTP/JSON response returned by the API so
    that business logic and code coverage can be
    appropriately tested.
    
    NOTE: Some of the mock responses include actual salesforce record ids.
          To utilize these record ids in your test method you can use the
          appropriate getTestRecordIds_ObjectName() function.
    
    TO USE THIS CLASS
    Insert the following line of code into your test right after the start test call.
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
    
    
**********************************************************************************/


public class CoreAPIMockResponseGenerator implements HttpCalloutMock {
    
    /*
        HOW TO ADD A NEW CORE API ENDPOINT: Follow these instructions to add support for mocking the response of a new endpoint 
            1) First you will want to extract the current version of the mocked output from this file.
               Do this by copying-and-pasting the block comment at the bottom of this class file.
               That block comment contains all of the mocked response output (including documentation of all insert variables).
               Be sure to read through the existing responses before continuing to get an idea of how the existing responses are
               structured.
            2) Next you will need to design a high quality mockup of the response output for the new endpoint.
               The goal is to design some sample data structures that follow some sort of logical structure. In the existing
               sample data, there are often logical groups (patent family 1 has 1 member, pfamily 2 has 2 members, all the way 
               to pfamily 5). Usually group 1 represents some sort of bad or corrupt date, groups 2 through 4 represent normal 
               data and group 5 represents new data or a blank but valid edge case.
               >> Basically just be sure to follow the existing conventions and think about how the example data will be consumed
               within apex testmethods. Try to make useful data.
            3) Add your new mockup to the block comment version. Then create another version of the new response string(s) with
               all of the line breaks removed.  Insert the single line version into appropriately named and placed variables in 
               the RESPONSE STRINGS section just below this comment.  NOTE: Details endpoints are mostly static and so just have
               a single template string. Changes endpoints are paginated and so have EVEN and ODD pages.
            4) Search this class for "*EndpointName*"" (w/o the quotes) and make changes as instructed
            5) If adding a new details endpoint: Update SyncEngineTests.createAPITestRecords() by adding inserting some of the
               example responses into the Salesforce database so they can be matched. NOTE: Be sure not to insert any values
               into external id fields that might conflict with existing Salesforce data.
    */
    
    
    /*=== MERGE-FIELD VARIABLE NAMES ===*/
    
    // Note that the double quotes are replaced during the merge-process (relevant for string vs integer).
    public static String PAGINATION_FIELD = '"insert_pagination"';
    public static String PAGE_ITEM_COUNT_FIELD = '"insert_page_item_count"';
    public static String PREVIOUS_PAGE_FIELD = '"insert_previous_page"';
    public static String NEXT_PAGE_FIELD = '"insert_next_page"';
    public static String CURRENT_PAGE_FIELD = '"insert_current_page"';
    public static String PER_PAGE_FIELD = '"insert_per_page"';
    public static String ITEM_COUNT_FIELD = '"insert_item_count"';
    public static String PAGE_COUNT_FIELD = '"insert_page_count"';
    
    
    
    /*=== RESPONSE STRINGS ===*/
    /* 
        ADMIN NOTE: Apex doesn't allow block strings, so each of the response strings below is stored in two ways.
            1) As a single-line String variable below
            2) As a properly-indented multi-line block comment at the END OF THIS CLASS FILE.
        
        When you're making changes to the mock responses, it is recommended to begin by copying-and-pasting the
        multi-line block comment into a text editor. Then make your edits to that and update BOTH copies when you're finished.
    */ 
    
    // Static Responses (No Variables)
    public static String PATENT_RESPONSE_BODY = '{"response":[{"application_filing_date":"1997-05-01","publication_number":"US0000101A1","application_number":"US0000101","stripped_patnum":"0000101","title":"Test Patent 1.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-101","patent_family":{"id":-111,"name":"Test Patent Family 1  (1 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"1997-05-01","patnum":"US0000201A1","publication_number":"US0000201A1","application_number":"US0000201","stripped_patnum":"0000201","title":"Test Patent 2.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-201","patent_family":{"id":-222,"name":"Test Patent Family 2  (2 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"2000-09-26","patnum":"US0000202A1","publication_number":"US0000202A1","application_number":"US0000202","stripped_patnum":"0000202","title":"Test Patent 2.2","country":"US","execution_date":"2000-10-23","expire_date":"2020-09-26","issue_date":"2003-05-06","priority_date":"1999-03-02","id":"-202","patent_family":{"id":-222,"name":"Test Patent Family 2  (2 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"1997-05-01","patnum":"US0000301A1","publication_number":"US0000301A1","application_number":"US0000301","stripped_patnum":"0000301","title":"Test Patent 3.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-301","patent_family":{"id":-333,"name":"Test Patent Family 3  (3 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"2000-09-26","patnum":"US0000302A1","publication_number":"US0000302A1","application_number":"US0000302","stripped_patnum":"0000302","title":"Test Patent 3.2","country":"US","execution_date":"2000-10-23","expire_date":"2020-09-26","issue_date":"2003-05-06","priority_date":"1999-03-02","id":"-302","patent_family":{"id":-333,"name":"Test Patent Family 3  (3 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"1993-07-12","patnum":"US0000303A1","publication_number":"US0000303A1","application_number":"US0000303","stripped_patnum":"0000303","title":"Test Patent 3.3","country":"US","execution_date":null,"expire_date":"2013-07-12","issue_date":"1996-09-03","priority_date":"1993-07-12","id":"-303","patent_family":{"id":-333,"name":"Test Patent Family 3  (3 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"1997-05-01","patnum":"US0000401A1","publication_number":"US0000401A1","application_number":"US0000401","stripped_patnum":"0000401","title":"Test Patent 4.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-401","patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"2000-09-26","patnum":"US0000402A1","publication_number":"US0000402A1","application_number":"US0000402","stripped_patnum":"0000402","title":"Test Patent 4.2","country":"US","execution_date":"2000-10-23","expire_date":"2020-09-26","issue_date":"2003-05-06","priority_date":"1999-03-02","id":"-402","patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"1993-07-12","patnum":"US0000403A1","publication_number":"US0000403A1","application_number":"US0000403","stripped_patnum":"0000403","title":"Test Patent 4.3","country":"US","execution_date":null,"expire_date":"2013-07-12","issue_date":"1996-09-03","priority_date":"1993-07-12","id":"-403","patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"1997-05-01","patnum":"US0000404A1","publication_number":"US0000404A1","application_number":"US0000404","stripped_patnum":"0000404","title":"Test Patent 4.4","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-404","patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},    {"application_filing_date":"1997-05-01","patnum":"US0000501A1","publication_number":"US0000501A1","application_number":"US0000501","stripped_patnum":"0000501","title":"Test Patent 5.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-501","summary":"summary 501","patent_family":{"id":0,"name":null},"most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]}],"count":11}';
    public static String PATENT_FAMILY_RESPONSE_BODY = '{"response":[{"id":-111,"name":"Test Patent Family 1  (1 US Patents)","us_patents_count":1,"max_expire_date":"2017-01-31","min_priority_date":"1992-09-23","non_us_patents_count":7,"us_applications_count":0,"non_us_applications_count":0,"patents":[{"stripped_patnum":"0000101","title":"Test Patent 1.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-101"}]},    {"id":-222,"name":"Test Patent Family 2  (2 US Patents)","us_patents_count":2,"max_expire_date":"2020-09-26","min_priority_date":"1999-03-02","non_us_patents_count":6,"us_applications_count":0,"non_us_applications_count":0,"patents":[{"patnum":"US0000201A1","stripped_patnum":"0000201","title":"Test Patent 2.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-201"},{"patnum":"US0000202A1","stripped_patnum":"0000202","title":"Test Patent 2.2","application_filing_date":"1992-09-23","expire_date":"2012-09-23","country":"US","issue_date":"1997-02-04","id":"-202"}]},    {"id":-333,"name":"Test Patent Family 3  (3 US Patents)","us_patents_count":3,"us_applications_count":1,"max_expire_date":"2021-10-31","min_priority_date":"1994-02-15","non_us_patents_count":0,"non_us_applications_count":0,"patents":[{"patnum":"US0000301A1","stripped_patnum":"0000301","title":"Test Patent 3.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-301"},{"patnum":"US0000302A1","stripped_patnum":"0000302","title":"Test Patent 3.2","application_filing_date":"1992-09-23","expire_date":"2012-09-23","country":"US","issue_date":"1997-02-04","id":"-302"},{"patnum":"US0000303A1","stripped_patnum":"0000303","title":"Test Patent 3.3","application_filing_date":"1996-02-07","expire_date":"2016-02-07","country":"US","issue_date":"1998-05-05","id":"-303"}]},    {"id":-444,"name":"Test Patent Family 4  (4 US Patents)","us_patents_count":4,"max_expire_date":"2017-01-31","min_priority_date":"1992-09-23","non_us_patents_count":7,"us_applications_count":0,"non_us_applications_count":0,"patents":[{"patnum":"US0000401A1","stripped_patnum":"0000401","title":"Test Patent 4.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-401"},{"patnum":"US0000402A1","stripped_patnum":"0000402","title":"Test Patent 4.2","application_filing_date":"1992-09-23","expire_date":"2012-09-23","country":"US","issue_date":"1997-02-04","id":"-402"},{"patnum":"US0000403A1","stripped_patnum":"0000403","title":"Test Patent 4.3","application_filing_date":"1996-02-07","expire_date":"2016-02-07","country":"US","issue_date":"1998-05-05","id":"-403"},{"patnum":"US0000404A1","stripped_patnum":"0000404","title":"Test Patent 4.4","application_filing_date":"1997-01-31","expire_date":"2017-01-31","country":"US","issue_date":"1998-05-12","id":"-404"}]}],"count":4}';
    public static String PATENT_ANNOTATION_RESPONSE_BODY = '{"response":[{"patent_key":"US0000101","summary":null,"analyst_notes":null},{"patent_key":"US0000201","summary":"summary of patent 201","analyst_notes":"notes about patent 201"},{"patent_key":"US0000202","summary":"summary of patent 202","analyst_notes":"notes about patent 202"},{"patent_key":"US0000301","summary":"summary of patent 301","analyst_notes":"notes about patent 301"},{"patent_key":"US0000302","summary":"summary of patent 302","analyst_notes":"notes about patent 302"},{"patent_key":"US0000303","summary":"summary of patent 303","analyst_notes":"notes about patent 303"},{"patent_key":"US0000401","summary":"summary of patent 401","analyst_notes":"notes about patent 401"},{"patent_key":"US0000402","summary":"summary of patent 402","analyst_notes":"notes about patent 402"},{"patent_key":"US0000403","summary":"summary of patent 403","analyst_notes":"notes about patent 403"},{"patent_key":"US0000404","summary":"summary of patent 404","analyst_notes":"notes about patent 404"}],"count":10}';
    
    // Semi-Static Responses (Variables but no dynamic length)
    public static String CLAIM_CHARTED_COMPANY_RESPONSE_TEMPLATE = '{"response":[{"id":-991011,"pat_salesforce_id":"insert_patent_id1","ent_salesforce_id":null},{"id":-992011,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-992011},{"id":-992012,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-992012},{"id":-993011,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-993011},{"id":-993012,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-993012},{"id":-993013,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-993013},{"id":-994011,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-994011},{"id":-994012,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-994012},{"id":-994013,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-994013},{"id":-994014,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id4","analyst_notes":"notes here","claim_id":-994014}],"count":10}';
    public static String LICENSEE_RESPONSE_TEMPLATE = '{"response":[{"id":-991011,"pat_salesforce_id":"insert_patent_id1","ent_salesforce_id":null},{"id":-992011,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here"},{"id":-992012,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here"},{"id":-993011,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here"},{"id":-993012,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here"},{"id":-993013,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here"},{"id":-994011,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here"},{"id":-994012,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here"},{"id":-994013,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here"},{"id":-994014,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id4","analyst_notes":"notes here"}],"count":10}';
    public static String PORTFOLIO_RESPONSE_TEMPLATE = '{"response":[{"summary":null,"id":"insert_acquisition_id1","primary_market_sector":"Networking","name":"acquisition1","theory_of_relevance":"1 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},{"summary":null,"id":"insert_acquisition_id2","primary_market_sector":"Networking","name":"acquisition2","theory_of_relevance":"2 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},{"summary":null,"id":"insert_acquisition_id3","primary_market_sector":"Mobile Communications and Devices","name":"acquisition3","theory_of_relevance":"3 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},{"summary":null,"id":"insert_acquisition_id4","primary_market_sector":"undefined","name":"acquisition4","theory_of_relevance":"4 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},{"summary":null,"id":"insert_acquisition_id5","primary_market_sector":"Networking","name":"acquisition5","theory_of_relevance":"5 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},{"summary":null,"id":"insert_acquisition_id6","primary_market_sector":"Networking","name":"acquisition6","theory_of_relevance":"6 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},{"summary":null,"id":"insert_acquisition_id7","primary_market_sector":"Semiconductors","name":"acquisition7","theory_of_relevance":"7 good reasons","analyst_notes":"important notes","quick_recommendation":"ANALYSE"},{"summary":null,"id":"insert_acquisition_id8","primary_market_sector":"Mobile Communications and Devices","name":"acquisition8","theory_of_relevance":"8 good reasons","analyst_notes":"important notes","quick_recommendation":"HOLD"},{"summary":null,"id":"insert_acquisition_id9","primary_market_sector":"Networking","name":"acquisition9","theory_of_relevance":"9 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},{"summary":null,"id":"insert_acquisition_id10","primary_market_sector":"E-Commerce and Software","name":"acquisition10","theory_of_relevance":"10 good reasons","analyst_notes":"important notes","quick_recommendation":"PASS"}],"count":10}';
    public static String RELEVANT_COMPANY_RESPONSE_TEMPLATE = '{"response":[{"id":-991011,"pat_salesforce_id":"insert_patent_id1","ent_salesforce_id":null},{"id":-992011,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-992011},{"id":-992012,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-992012},{"id":-993011,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-993011},{"id":-993012,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-993012},{"id":-993013,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-993013},{"id":-994011,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-994011},{"id":-994012,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-994012},{"id":-994013,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-994013},{"id":-994014,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id4","analyst_notes":"notes here","claim_id":-994014}],"count":10}';
    public static String TECH_TAG_RESPONSE_TEMPLATE = '{"response":[{"id":-991011,"pat_id":-101,"product_service_sfdc_id":null,"name":null,"tier":null,"free_form_tags":null,"patent_key":"US0000101"},{"id":-992011,"pat_id":-201,"product_service_sfdc_id":"insert_product_service_id1","name":"Hardware_Networking_Switch/Router_Optical","tier":1,"free_form_tags":null,"patent_key":"US0000201"},{"id":-992012,"pat_id":-201,"product_service_sfdc_id":"insert_product_service_id2","name":"Semi_Fabrication_Process","tier":1,"free_form_tags":null,"patent_key":"US0000201"},{"id":-993011,"pat_id":-301,"product_service_sfdc_id":"insert_product_service_id1","name":"Hardware_Networking_Switch/Router_Optical","tier":1,"free_form_tags":null,"patent_key":"US0000301"},{"id":-993012,"pat_id":-301,"product_service_sfdc_id":"insert_product_service_id2","name":"Semi_Fabrication_Process","tier":1,"free_form_tags":null,"patent_key":"US0000301"},{"id":-993013,"pat_id":-301,"product_service_sfdc_id":"insert_product_service_id3","name":"Semi_Memory_NVM","tier":1,"free_form_tags":null,"patent_key":"US0000301"},{"id":-994011,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id1","name":"Hardware_Networking_Switch/Router_Optical","tier":1,"free_form_tags":null,"patent_key":"US0000401"},{"id":-994012,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id2","name":"Semi_Fabrication_Process","tier":1,"free_form_tags":null,"patent_key":"US0000401"},{"id":-994013,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id3","name":"Semi_Memory_NVM","tier":1,"free_form_tags":null,"patent_key":"US0000401"},{"id":-994014,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id4","name":"Semi_Imaging (CCD, CMOS, etc.)","tier":1,"free_form_tags":null,"patent_key":"US0000401"}],"count":10}';
    
    // Static Response Row Counts (Use these in test methods)
    public static Integer NUM_CLAIM_CHARTED_COMPANY_ROWS = 10;
    public static Integer NUM_LICENSEE_ROWS = 10;
    public static Integer NUM_PATENT_ROWS = 11;
    public static Integer NUM_PATENT_FAMILY_ROWS = 4;
    public static Integer NUM_PATENT_ANNOTATION_ROWS = 10;
    public static Integer NUM_PORTFOLIO_ROWS = 10; //controls the range variable maximum value
    public static Integer NUM_RELEVANT_COMPANY_ROWS = 10;
    public static Integer NUM_TECH_TAG_ROWS = 10; //controls the range variable maximum value
    public static Integer TEST_RECORD_IDS_NEEDED = 11; // set this to the largest of the above values
    
    // Pagination Template
    public static String PAGINATION_TEMPLATE = '{"previous":"insert_previous_page","next":"insert_next_page","current":"insert_current_page","per_page":"insert_per_page","count":"insert_item_count","pages":"insert_page_count"}';
    public static Integer NUMBER_OF_PAGES = 20;
    
    // Dynamic Responses (Variables & Pagination)
    public static String INNER_BODY_START = '\\['; //this string should occur only ONCE in the entire template (Regex format)
    public static String INNER_BODY_END = '\\]'; //this string should occur only ONCE in the entire template
    public static String INNER_BODY_START_CHAR = '['; //this should be the non-regex version of the other string
    public static String INNER_BODY_END_CHAR = ']';  //this should be the non-regex version of the other string
    public static Integer INNER_BODY_SIZE = 10; //number of items in the inner body
    
    /*
        ADMIN NOTE ABOUT DYNAMIC RESPONSES: The templates below are first selected based on whether the page number
        in the request URL is EVEN or ODD. The selected templated is then modified in three ways:
            1) The "inner body" of the response (as defined by the START & END strings above) is replicated to simulate
               a response the correct number of response rows as specified in the request URL. (Each template
               body is assumed to have exactly INNER_BODY_SIZE rows to begin with and the page size in the request URL is
               rounded to a multiple of INNER_BODY_SIZE.) 
            2) If PAGINATION_FIELD is present it is replaced with PAGINATION_TEMPLATE with the appropriate merge
               field variables inserted. (The current page is pulled from the request URL.)
            3) The PAGE_ITEM_COUNT_FIELD is replaced with the appropriate value.
    */
    
    public static String CLAIM_CHARTED_COMPANY_CHANGES_TEMPLATE_ODD = '{"response":[{"action":"added","obj_id":"-991011"},{"action":"changed","obj_id":"-992011","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-992021","obj_type":"pat_claim_charted_company"},{"action":"changed","obj_id":"-993011","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-993021","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-993031","obj_type":"pat_claim_charted_company"},{"action":"changed","obj_id":"-994011","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-994021","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-994031","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-994041","obj_type":"pat_claim_charted_company"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String CLAIM_CHARTED_COMPANY_CHANGES_TEMPLATE_EVEN = '{"response":[{"action":"changed","obj_id":"-992012","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-992022","obj_type":"pat_claim_charted_company"},{"action":"changed","obj_id":"-993012","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-993022","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-993032","obj_type":"pat_claim_charted_company"},{"action":"changed","obj_id":"-994012","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-994022","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-994032","obj_type":"pat_claim_charted_company"},{"action":"deleted","obj_id":"-994042","obj_type":"pat_claim_charted_company"},{"action":"changed","obj_id":"-994014","obj_type":"pat_claim_charted_company"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String LICENSEE_CHANGES_TEMPLATE_ODD = '{"response":[{"action":"added","obj_id":"-991011"},{"action":"changed","obj_id":"-992011","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-992021","obj_type":"pat_licensee"},{"action":"changed","obj_id":"-993011","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-993021","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-993031","obj_type":"pat_licensee"},{"action":"changed","obj_id":"-994011","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-994021","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-994031","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-994041","obj_type":"pat_licensee"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String LICENSEE_CHANGES_TEMPLATE_EVEN = '{"response":[{"action":"changed","obj_id":"-992012","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-992022","obj_type":"pat_licensee"},{"action":"changed","obj_id":"-993012","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-993022","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-993032","obj_type":"pat_licensee"},{"action":"changed","obj_id":"-994012","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-994022","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-994032","obj_type":"pat_licensee"},{"action":"deleted","obj_id":"-994042","obj_type":"pat_licensee"},{"action":"changed","obj_id":"-994014","obj_type":"pat_licensee"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String PATENT_ANNOTATION_CHANGES_TEMPLATE_ODD = '{"response":[{"action":"changed","obj_id":"US0000101"},{"action":"changed","obj_id":"US0000201","obj_type":"patent"},{"action":"changed","obj_id":"US0000301","obj_type":"patent"},{"action":"changed","obj_id":"US0000401","obj_type":"patent"},{"action":"changed","obj_id":"US0000303","obj_type":"patent"},{"action":"changed","obj_id":"US0000303","obj_type":"patent"},{"action":"changed","obj_id":"US0000303","obj_type":"patent"},{"action":"changed","obj_id":"US0000403","obj_type":"patent"},{"action":"changed","obj_id":"US0000403","obj_type":"patent"},{"action":"changed","obj_id":"US0000403","obj_type":"patent"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String PATENT_ANNOTATION_CHANGES_TEMPLATE_EVEN = '{"response":[{"action":"changed","obj_id":"US0000202","obj_type":"patent"},{"action":"changed","obj_id":"US0000302","obj_type":"patent"},{"action":"changed","obj_id":"US0000402","obj_type":"patent"},{"action":"changed","obj_id":"US0000202","obj_type":"patent"},{"action":"changed","obj_id":"US0000302","obj_type":"patent"},{"action":"changed","obj_id":"US0000402","obj_type":"patent"},{"action":"changed","obj_id":"US0000404","obj_type":"patent"},{"action":"changed","obj_id":"US0000404","obj_type":"patent"},{"action":"changed","obj_id":"US0000404","obj_type":"patent"},{"action":"changed","obj_id":"US0000404","obj_type":"patent"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String PATENT_FAMILY_CHANGES_TEMPLATE_ODD = '{"response":[{"action":"added","obj_id":"US0000101","obj_type":"patent"},{"action":"added","obj_id":"-111","obj_type":"pat_family"},{"action":"added","obj_id":"US0000201","obj_type":"patent"},{"action":"added","obj_id":"US0000301","obj_type":"patent"},{"action":"added","obj_id":"US0000401","obj_type":"patent"},{"action":"added","obj_id":"US0000303","obj_type":"patent"},{"action":"added","obj_id":"US0000303","obj_type":"patent"},{"action":"added","obj_id":"US0000403","obj_type":"patent"},{"action":"added","obj_id":"US0000403","obj_type":"patent"},{"action":"added","obj_id":"US0000403","obj_type":"patent"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String PATENT_FAMILY_CHANGES_TEMPLATE_EVEN = '{"response":[{"action":"deleted","obj_id":"US0000202","obj_type":"patent"},{"action":"deleted","obj_id":"US0000302","obj_type":"patent"},{"action":"deleted","obj_id":"US0000402","obj_type":"patent"},{"action":"deleted","obj_id":"US0000202","obj_type":"patent"},{"action":"deleted","obj_id":"US0000302","obj_type":"patent"},{"action":"deleted","obj_id":"US0000402","obj_type":"patent"},{"action":"deleted","obj_id":"US0000404","obj_type":"patent"},{"action":"deleted","obj_id":"US0000404","obj_type":"patent"},{"action":"deleted","obj_id":"US0000404","obj_type":"patent"},{"action":"deleted","obj_id":"-555","obj_type":"pat_family"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String PORTFOLIO_ANNOTATION_CHANGES_TEMPLATE_ODD = '{"response":[{"action":"changed","obj_id":"insert_acquisition_id1"},{"action":"changed","obj_id":"insert_acquisition_id3","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id5","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id7","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id9","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id1"},{"action":"changed","obj_id":"insert_acquisition_id3","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id5","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id7","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id9","obj_type":"portfolio"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String PORTFOLIO_ANNOTATION_CHANGES_TEMPLATE_EVEN = '{"response":[{"action":"changed","obj_id":"insert_acquisition_id2","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id4","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id6","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id8","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id10","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id2","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id4","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id6","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id8","obj_type":"portfolio"},{"action":"changed","obj_id":"insert_acquisition_id10","obj_type":"portfolio"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String RELEVANT_COMPANY_CHANGES_TEMPLATE_ODD = '{"response":[{"action":"added","obj_id":"-991011"},{"action":"changed","obj_id":"-992011","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-992021","obj_type":"pat_relevant_company"},{"action":"changed","obj_id":"-993011","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-993021","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-993031","obj_type":"pat_relevant_company"},{"action":"changed","obj_id":"-994011","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-994021","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-994031","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-994041","obj_type":"pat_relevant_company"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String RELEVANT_COMPANY_CHANGES_TEMPLATE_EVEN = '{"response":[{"action":"changed","obj_id":"-992012","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-992022","obj_type":"pat_relevant_company"},{"action":"changed","obj_id":"-993012","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-993022","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-993032","obj_type":"pat_relevant_company"},{"action":"changed","obj_id":"-994012","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-994022","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-994032","obj_type":"pat_relevant_company"},{"action":"deleted","obj_id":"-994042","obj_type":"pat_relevant_company"},{"action":"changed","obj_id":"-994014","obj_type":"pat_relevant_company"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String TECH_TAG_CHANGES_TEMPLATE_ODD = '{"response":[{"action":"inserted","obj_id":"-991011"},{"action":"changed","obj_id":"-992011","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-992021","obj_type":"tech_tag"},{"action":"changed","obj_id":"-993011","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-993021","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-993031","obj_type":"tech_tag"},{"action":"changed","obj_id":"-994011","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-994021","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-994031","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-994041","obj_type":"tech_tag"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';
    public static String TECH_TAG_CHANGES_TEMPLATE_EVEN = '{"response":[{"action":"changed","obj_id":"-992012","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-992022","obj_type":"tech_tag"},{"action":"changed","obj_id":"-993012","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-993022","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-993032","obj_type":"tech_tag"},{"action":"changed","obj_id":"-994012","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-994022","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-994032","obj_type":"tech_tag"},{"action":"deleted","obj_id":"-994042","obj_type":"tech_tag"},{"action":"changed","obj_id":"-994014","obj_type":"tech_tag"}],"pagination":"insert_pagination","count":"insert_page_item_count"}';  
    
    
    
    /*=== INNER EXCEPTION CLASS ===*/
    
    
    public class MockResponseException extends Exception {}
    
    
    
    /*=== TEST RECORD ID RETRIEVAL FUNCTIONS ===*/
    /*
        This functions in this section are used to retrieve record ids to insert into the response mock.
        They may be also used in test methods to get the ids in the same order as those returned in the mocked response.
        NOTE: The first record id will be that of the most recently created record.
    */
    
    public static String[] getTestRecordIds_Acquisition() {
        String[] idList = new String[]{};
        Acquisition_Opportunity__c[] acquisitions = [select Id from Acquisition_Opportunity__c order by CreatedDate desc limit :TEST_RECORD_IDS_NEEDED];
        for (Acquisition_Opportunity__c a:acquisitions) idList.add(a.Id);
        return idList;
    }
    
    public static String[] getTestRecordIds_Product() {
        String[] idList = new String[]{};
        Product_or_Service__c[] products = [select Id from Product_or_Service__c order by CreatedDate desc limit :TEST_RECORD_IDS_NEEDED];
        for (Product_or_Service__c p:products) idList.add(p.Id);
        return idList;
    }
    
    public static String[] getTestRecordIds_Account() {
        String[] idList = new String[]{};
        Account[] accounts = [select Id from Account order by CreatedDate desc limit :TEST_RECORD_IDS_NEEDED];
        for (Account a:accounts) idList.add(a.Id);
        return idList;
    }
    
    public static String[] getTestRecordIds_Patent() {
        String[] idList = new String[]{};
        Patent__c[] patents = [select Id from Patent__c order by CreatedDate desc limit :TEST_RECORD_IDS_NEEDED];
        for (Patent__c p:patents) idList.add(p.Id);
        //system.debug(LoggingLevel.ERROR, '###getTestRecordIds_Patent(): About to return idList = ' + idList + '.###');
        return idList;
    }
    
    
    
    /*=== RESPONSE-GENERATION FUNCTIONS ===*/
    
    
    public HTTPResponse respond(HttpRequest request) {
        //This function mocks a response to the web service calls made in the CoreAPI class.
            
        system.debug('###CoreAPIMockResponseGenerator.respond(): Entering function with request = ' + request + '.###');
        
        HTTPResponse response = new HTTPResponse();
        String endpointURL;
        CoreAPI.EndpointName theEndpoint;
        Map<String, String> urlParameters;
        Integer pageSize; Integer currentPage;
        
        //extract the endpoint and pagination parameters from the url
        endpointURL = request.getEndpoint();
        theEndpoint = getEndpointName(endpointURL);
        urlParameters = getURLParameters(endpointURL);
        if (urlParameters.containsKey(CoreAPI.PAGE_SIZE_PARAM)) pageSize = Integer.valueOf(urlParameters.get(CoreAPI.PAGE_SIZE_PARAM));
        if (pageSize == null) pageSize = 50;
        if (urlParameters.containsKey(CoreAPI.PAGE_NUMBER_PARAM)) currentPage = Integer.valueOf(urlParameters.get(CoreAPI.PAGE_NUMBER_PARAM));
        
        //configure the response
        response.setHeader('Content-Type', 'application/json');
        if (endpointURL.length() > CoreAPI.MAX_URL_LENGTH) {
            response.setStatusCode(502);
            response.setStatus('URL TOO LONG');
        } else {
	        response.setStatusCode(200);
	        response.setBody(generateResponseBody(theEndpoint, pageSize, currentPage));
        }
        
        system.debug('###CoreAPIMockResponseGenerator.respond(): Exiting function with response = ' + response + ', response body = ' + response.getBody() + '.###');
        return response;
    }
    
    private static Map<String, String> getURLParameters(String endpointURL) {
        // Returns all of the parameters from the url as a map
        
        system.debug('###CoreAPIMockResponseGenerator.getURLParameters(): Entering function with trimmed endpointURL = ' + endpointURL + '.###');
        
        String[] queryPairs = new String[]{};
        Map<String, String> returnMap = new Map<String, String>();
        String[] keyAndValue;
        
        if ((endpointURL != null) && endpointURL.contains('?')) queryPairs = endpointURL.split('\\?')[1].split('&'); // 'a=1&b=2&c'
        for (String queryPair:queryPairs)
            if (queryPair.contains('=')) { // 'a=1'
                keyAndValue = queryPair.split('=', 2);
                returnMap.put(keyAndValue[0], keyAndValue[1]);
            } else
                returnMap.put(queryPair, null); // 'c'
        
        system.debug('###CoreAPIMockResponseGenerator.getURLParameters(): Exiting function with returnMap = ' + returnMap + '.###');
        return returnMap;
    }
    
    private static CoreAPI.EndpointName getEndpointName(String endpointURL) {
        // Determines which endpoint is being requested.
        if ((endpointURL != null) && endpointURL.contains('?')) endpointURL = endpointURL.split('\\?')[0]; //grab just the first part of the url
        system.debug('###CoreAPIMockResponseGenerator.getEndpointName(): Entering function with trimmed endpointURL = ' + endpointURL + '.###');
        
        // ADMIN NOTE: When adding a new *EndpointName* add another logic branch below.
        if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.ClaimChartedCompanies, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.ClaimChartedCompanies, false)))
            return CoreAPI.EndpointName.ClaimChartedCompanies;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.Licensees, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.Licensees, false)))
            return CoreAPI.EndpointName.Licensees;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.Patents, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.Patents, false)))
            return CoreAPI.EndpointName.Patents;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentAnnotations, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentAnnotations, false)))
            return CoreAPI.EndpointName.PatentAnnotations;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentFamilies, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentFamilies, false)))
            return CoreAPI.EndpointName.PatentFamilies;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.Portfolios, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.Portfolios, false)))
            return CoreAPI.EndpointName.Portfolios;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.RelevantCompanies, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.RelevantCompanies, false)))
            return CoreAPI.EndpointName.RelevantCompanies;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.TechTags, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.TechTags, false)))
            return CoreAPI.EndpointName.TechTags;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.ClaimChartedCompanyChanges, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.ClaimChartedCompanyChanges, false)))
            return CoreAPI.EndpointName.ClaimChartedCompanyChanges;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.LicenseeChanges, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.LicenseeChanges, false)))
            return CoreAPI.EndpointName.LicenseeChanges;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentAnnotationChanges, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentAnnotationChanges, false)))
            return CoreAPI.EndpointName.PatentAnnotationChanges;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentFamilyChanges, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PatentFamilyChanges, false)))
            return CoreAPI.EndpointName.PatentFamilyChanges;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PortfolioAnnotationChanges, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.PortfolioAnnotationChanges, false)))
            return CoreAPI.EndpointName.PortfolioAnnotationChanges;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.RelevantCompanyChanges, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.RelevantCompanyChanges, false)))
            return CoreAPI.EndpointName.RelevantCompanyChanges;
        else if ((endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.TechTagChanges, true)) || (endpointURL == CoreAPI.getEndpointURL(CoreAPI.EndpointName.TechTagChanges, false)))
            return CoreAPI.EndpointName.TechTagChanges;
        else {
            Exception e = new MockResponseException('Unsupported endpoint type (url = ' + endpointURL + ')');
            throw e;
        }
    }
    
    private static String generateResponseBody(CoreAPI.EndpointName theEndpoint, Integer pageSize, Integer currentPage) {
        // Generates the JSON body of the response.
        //    [pageSize] specifieds the number of items per page specified in the request.
        //    [currentPage] specifies the current page of the pagination. (Defaults to one if null and pagination is present in the template.) 
        
        system.debug('###CoreAPIMockResponseGenerator.generateResponseBody(): Entering with theEndpoint = ' + theEndpoint + ', pageSize = ' + pageSize + ', currentPage = ' + currentPage + '.###');
        
        String responseBody = null;
        Boolean isOdd;
        String paginationValue;
        String[] idList; //used for portfolios and tech tags
        
        if (currentPage == null) currentPage = 1;
        isOdd = (Math.mod(currentPage, 2) > 0);
        
        // First retrieve the appropriate template
        // ADMIN NOTE: When adding a new *EndpointName* add another logic branch below.
        if (theEndpoint == CoreAPI.EndpointName.ClaimChartedCompanies) responseBody = CLAIM_CHARTED_COMPANY_RESPONSE_TEMPLATE;
        else if (theEndpoint == CoreAPI.EndpointName.Licensees) responseBody = LICENSEE_RESPONSE_TEMPLATE;
        else if (theEndpoint == CoreAPI.EndpointName.Patents) responseBody = PATENT_RESPONSE_BODY;
        else if (theEndpoint == CoreAPI.EndpointName.PatentAnnotations) responseBody = PATENT_ANNOTATION_RESPONSE_BODY;
        else if (theEndpoint == CoreAPI.EndpointName.PatentFamilies) responseBody = PATENT_FAMILY_RESPONSE_BODY;
        else if (theEndpoint == CoreAPI.EndpointName.Portfolios) responseBody = PORTFOLIO_RESPONSE_TEMPLATE;
        else if (theEndpoint == CoreAPI.EndpointName.RelevantCompanies) responseBody = RELEVANT_COMPANY_RESPONSE_TEMPLATE;
        else if (theEndpoint == CoreAPI.EndpointName.TechTags) responseBody = TECH_TAG_RESPONSE_TEMPLATE;
        else if (theEndpoint == CoreAPI.EndpointName.ClaimChartedCompanyChanges) {
            if (isOdd) responseBody = CLAIM_CHARTED_COMPANY_CHANGES_TEMPLATE_ODD;
            else responseBody = CLAIM_CHARTED_COMPANY_CHANGES_TEMPLATE_EVEN;
        } else if (theEndpoint == CoreAPI.EndpointName.LicenseeChanges) {
            if (isOdd) responseBody = LICENSEE_CHANGES_TEMPLATE_ODD;
            else responseBody = LICENSEE_CHANGES_TEMPLATE_EVEN;
        } else if (theEndpoint == CoreAPI.EndpointName.PatentAnnotationChanges) {
            if (isOdd) responseBody = PATENT_ANNOTATION_CHANGES_TEMPLATE_ODD;
            else responseBody = PATENT_ANNOTATION_CHANGES_TEMPLATE_EVEN;
        } else if (theEndpoint == CoreAPI.EndpointName.PatentFamilyChanges) {
            if (isOdd) responseBody = PATENT_FAMILY_CHANGES_TEMPLATE_ODD;
            else responseBody = PATENT_FAMILY_CHANGES_TEMPLATE_EVEN;
        } else if (theEndpoint == CoreAPI.EndpointName.PortfolioAnnotationChanges) {
            if (isOdd) responseBody = PORTFOLIO_ANNOTATION_CHANGES_TEMPLATE_ODD;
            else responseBody = PORTFOLIO_ANNOTATION_CHANGES_TEMPLATE_EVEN;
        } else if (theEndpoint == CoreAPI.EndpointName.RelevantCompanyChanges) {
            if (isOdd) responseBody = RELEVANT_COMPANY_CHANGES_TEMPLATE_ODD;
            else responseBody = RELEVANT_COMPANY_CHANGES_TEMPLATE_EVEN;
        } else if (theEndpoint == CoreAPI.EndpointName.TechTagChanges) {
            if (isOdd) responseBody = TECH_TAG_CHANGES_TEMPLATE_ODD;
            else responseBody = TECH_TAG_CHANGES_TEMPLATE_EVEN;
        }
        
        String innerBody; String preBody; String postBody; String[] innerBodyCopies = new String[]{}; Integer innerBodyCopyCount;
        Boolean isOutOfRange = false;
        Integer previousPage; Integer nextPage; Integer totalItemCount; Integer pageCount;
        
        // Next build out the range fields (only if needed)
        // ADMIN NOTE: When adding a new *EndpointName* with salesforce ids that need inserting, you will need to add another logic branch below.
        //             If you are grabbing a NEW object type you will also need to create a new getTestRecordIds_ObjectName() function.
        if ((theEndpoint == CoreAPI.EndpointName.Portfolios) || (theEndpoint == CoreAPI.EndpointName.PortfolioAnnotationChanges)) { 
            idList = getTestRecordIds_Acquisition();
            responseBody = insertVariableRange(responseBody, '"insert_acquisition_id#"', NUM_PORTFOLIO_ROWS, idList, true);
        } else if (theEndpoint == CoreAPI.EndpointName.TechTags) {
            idList = getTestRecordIds_Product();
            responseBody = insertVariableRange(responseBody, '"insert_product_service_id#"', NUM_TECH_TAG_ROWS, idList, true);
        } else if ((theEndpoint == CoreAPI.EndpointName.ClaimChartedCompanies) || (theEndpoint == CoreAPI.EndpointName.Licensees) || (theEndpoint == CoreAPI.EndpointName.RelevantCompanies)) {
            // NOTE: Since all three of these endpoints are structurally identical, I'm using the same row count variable.
            idList = getTestRecordIds_Account();
            responseBody = insertVariableRange(responseBody, '"insert_account_id#"', NUM_LICENSEE_ROWS, idList, true);
            idList = getTestRecordIds_Patent();
            responseBody = insertVariableRange(responseBody, '"insert_patent_id#"', NUM_LICENSEE_ROWS, idList, true);
        }
    
        // Now handle dynamic templates (if needed)
        if (responseBody.contains(PAGINATION_FIELD)) {
            
            // First build the innerBody
            preBody = responseBody.split(INNER_BODY_START, 2)[0];
            innerBody = responseBody.split(INNER_BODY_START, 2)[1].split(INNER_BODY_END, 2)[0];
            postBody = responseBody.split(INNER_BODY_START, 2)[1].split(INNER_BODY_END, 2)[1];
            
            isOutOfRange = ((currentPage < 1) || (currentPage > NUMBER_OF_PAGES));
            if (isOutOfRange) innerBodyCopyCount = 0; 
            else innerBodyCopyCount = Math.round(pageSize/INNER_BODY_SIZE);
            
            for (Integer i=0; i<innerBodyCopyCount; i++) innerBodyCopies.add(innerBody);
            responseBody = preBody + INNER_BODY_START_CHAR + String.join(innerBodyCopies, ',') + INNER_BODY_END_CHAR + postBody;
            
            // Next set the page item count variable
            if (isOutOfRange) responseBody = insertVariable(responseBody, PAGE_ITEM_COUNT_FIELD, 0, false);
            else responseBody = insertVariable(responseBody, PAGE_ITEM_COUNT_FIELD, pageSize, false);
            
            // Finally build the pagination section
            paginationValue = PAGINATION_TEMPLATE;
            
            if (currentPage > 1) previousPage = currentPage - 1;
            else previousPage = null;
            if (currentPage < NUMBER_OF_PAGES) nextPage = currentPage + 1;
            else nextPage = null;
            totalItemCount = pageSize * NUMBER_OF_PAGES;
            
            paginationValue = insertVariable(paginationValue, PREVIOUS_PAGE_FIELD, previousPage, false);
            paginationValue = insertVariable(paginationValue, NEXT_PAGE_FIELD, nextPage, false);
            paginationValue = insertVariable(paginationValue, CURRENT_PAGE_FIELD, currentPage, false);
            paginationValue = insertVariable(paginationValue, PER_PAGE_FIELD, pageSize, false);
            paginationValue = insertVariable(paginationValue, ITEM_COUNT_FIELD, totalItemCount, false);
            paginationValue = insertVariable(paginationValue, PAGE_COUNT_FIELD, NUMBER_OF_PAGES, false);
            
            responseBody = insertVariable(responseBody, PAGINATION_FIELD, paginationValue, false);
        }
        
        system.debug('###CoreAPIMockResponseGenerator.generateResponseBody(): Exiting with responseBody = ' + responseBody + '.###');
        return responseBody;
    }
    
    
    private static String insertVariable(String responseBody, String variable, Object value, Boolean includeQuotes) {
        // Finds all instances of the provided [variable] string (regular expression syntax) in [responseBody] and replaces it with [value]
        //     [includeQuotes] controls whether value is surrounded in double quotes.
        
        String stringValue;
        
        if (value == null)
            stringValue = 'null';
        else {
            stringValue = String.valueOf(value);
            if (includeQuotes) stringValue = '"' + stringValue + '"';
        }
        
        responseBody = responseBody.replaceAll(variable, stringValue);
        
        return responseBody;
    }
    
    private static String insertVariableRange(String responseBody, String variableTemplate, Integer maxValue, Object[] values, Boolean includeQuotes) {
        // Calls insertVariable() with a numeric range of variables. The range is constructed by inserting an integer into the variable template.
        //     [variableTemplate] should have a pound symbol in it (that will be replaced by the number). Example: "insert_variable#" => "insert_variable1", "insert_variable2", ...
        //     [maxValue] controls the range that is tried. (from 1 to maxValue)
        //     [values] is a list of objects corresponding to the values which should be inserted (salesforce ids for instance)
        //              >> If [values] does not have [maxValue] elements, any missing elements are substituted with NULL
        
        Object currentValue;
        String currentVariable;
        
        for (Integer i=1; i<=maxValue; i++) {
            currentVariable = variableTemplate.replaceAll('#', String.valueOf(i));
            if ((i-1) < values.size()) currentValue = values[i-1];
            else currentValue = null;
            responseBody = insertVariable(responseBody, currentVariable, currentValue, includeQuotes);
        }
        
        return responseBody;
    }
    
    
}


/******************************** MOCKED RESPONSE BODIES (PRETTY FORMATTING) ********************************
*********************************    Use this version when making edits.     ********************************

    === PAGINATION TEMPLATE ===
    ======= Variables (w/ quotes): "insert_previous_page", "insert_next_page", "insert_current_page", "insert_per_page", "insert_item_count", "insert_page_count" =======

    {"previous":"insert_previous_page","next":"insert_next_page","current":"insert_current_page","per_page":"insert_per_page","count":"insert_item_count","pages":"insert_page_count"}


    === CLAIM CHARTED COMPANY RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_patent_idX" (with x = 1-4), "insert_account_idX" (with x = 1-4) =======
    
    {"response":[
        {"id":-991011,"pat_salesforce_id":"insert_patent_id1","ent_salesforce_id":null},
        {"id":-992011,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-992011},
        {"id":-992012,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-992012},
        {"id":-993011,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-993011},
        {"id":-993012,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-993012},
        {"id":-993013,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-993013},
        {"id":-994011,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-994011},
        {"id":-994012,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-994012},
        {"id":-994013,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-994013},
        {"id":-994014,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id4","analyst_notes":"notes here","claim_id":-994014}
    ],"count":10}
    
    
    === LICENSEE RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_patent_idX" (with x = 1-4), "insert_account_idX" (with x = 1-4) =======
    
    {"response":[
        {"id":-991011,"pat_salesforce_id":"insert_patent_id1","ent_salesforce_id":null},
        {"id":-992011,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here"},
        {"id":-992012,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here"},
        {"id":-993011,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here"},
        {"id":-993012,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here"},
        {"id":-993013,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here"},
        {"id":-994011,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here"},
        {"id":-994012,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here"},
        {"id":-994013,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here"},
        {"id":-994014,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id4","analyst_notes":"notes here"}
    ],"count":10}
    
    
    === PATENT RESPONSE BODY ===
    
    {"response":[
        {"application_filing_date":"1997-05-01","publication_number":"US0000101A1","application_number":"US0000101","stripped_patnum":"0000101","title":"Test Patent 1.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-101",
            "patent_family":{"id":-111,"name":"Test Patent Family 1  (1 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"1997-05-01","patnum":"US0000201A1","publication_number":"US0000201A1","application_number":"US0000201","stripped_patnum":"0000201","title":"Test Patent 2.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-201",
            "patent_family":{"id":-222,"name":"Test Patent Family 2  (2 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"2000-09-26","patnum":"US0000202A1","publication_number":"US0000202A1","application_number":"US0000202","stripped_patnum":"0000202","title":"Test Patent 2.2","country":"US","execution_date":"2000-10-23","expire_date":"2020-09-26","issue_date":"2003-05-06","priority_date":"1999-03-02","id":"-202",
            "patent_family":{"id":-222,"name":"Test Patent Family 2  (2 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"1997-05-01","patnum":"US0000301A1","publication_number":"US0000301A1","application_number":"US0000301","stripped_patnum":"0000301","title":"Test Patent 3.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-301",
            "patent_family":{"id":-333,"name":"Test Patent Family 3  (3 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"2000-09-26","patnum":"US0000302A1","publication_number":"US0000302A1","application_number":"US0000302","stripped_patnum":"0000302","title":"Test Patent 3.2","country":"US","execution_date":"2000-10-23","expire_date":"2020-09-26","issue_date":"2003-05-06","priority_date":"1999-03-02","id":"-302",
            "patent_family":{"id":-333,"name":"Test Patent Family 3  (3 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"1993-07-12","patnum":"US0000303A1","publication_number":"US0000303A1","application_number":"US0000303","stripped_patnum":"0000303","title":"Test Patent 3.3","country":"US","execution_date":null,"expire_date":"2013-07-12","issue_date":"1996-09-03","priority_date":"1993-07-12","id":"-303",
            "patent_family":{"id":-333,"name":"Test Patent Family 3  (3 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"1997-05-01","patnum":"US0000401A1","publication_number":"US0000401A1","application_number":"US0000401","stripped_patnum":"0000401","title":"Test Patent 4.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-401",
            "patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"2000-09-26","patnum":"US0000402A1","publication_number":"US0000402A1","application_number":"US0000402","stripped_patnum":"0000402","title":"Test Patent 4.2","country":"US","execution_date":"2000-10-23","expire_date":"2020-09-26","issue_date":"2003-05-06","priority_date":"1999-03-02","id":"-402",
            "patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"1993-07-12","patnum":"US0000403A1","publication_number":"US0000403A1","application_number":"US0000403","stripped_patnum":"0000403","title":"Test Patent 4.3","country":"US","execution_date":null,"expire_date":"2013-07-12","issue_date":"1996-09-03","priority_date":"1993-07-12","id":"-403",
            "patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"1997-05-01","patnum":"US0000404A1","publication_number":"US0000404A1","application_number":"US0000404","stripped_patnum":"0000404","title":"Test Patent 4.4","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-404",
            "patent_family":{"id":-444,"name":"Test Patent Family 4  (4 US Patents)"},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]},
    
        {"application_filing_date":"1997-05-01","patnum":"US0000501A1","publication_number":"US0000501A1","application_number":"US0000501","stripped_patnum":"0000501","title":"Test Patent 5.1","country":"US","execution_date":null,"expire_date":"2017-05-01","issue_date":"2000-08-01","priority_date":"1994-02-15","id":"-501","summary":"summary 501",
            "patent_family":{"id":0,"name":null},
            "most_recent_assignees":[{"name":"item1"},{"name":"item2"}],"sponsoring_entities":[{"name":"item1"},{"name":"item2"}]}
    ],"count":11}
    

    === PATENT FAMILY RESPONSE BODY ===
    
    {"response":[
        {"id":-111,"name":"Test Patent Family 1  (1 US Patents)","us_patents_count":1,"max_expire_date":"2017-01-31","min_priority_date":"1992-09-23","non_us_patents_count":7,"us_applications_count":0,"non_us_applications_count":0,
            "patents":[
                {"stripped_patnum":"0000101","title":"Test Patent 1.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-101"}
            ]
        },
    
        {"id":-222,"name":"Test Patent Family 2  (2 US Patents)","us_patents_count":2,"max_expire_date":"2020-09-26","min_priority_date":"1999-03-02","non_us_patents_count":6,"us_applications_count":0,"non_us_applications_count":0,
            "patents":[
                {"patnum":"US0000201A1","stripped_patnum":"0000201","title":"Test Patent 2.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-201"},
                {"patnum":"US0000202A1","stripped_patnum":"0000202","title":"Test Patent 2.2","application_filing_date":"1992-09-23","expire_date":"2012-09-23","country":"US","issue_date":"1997-02-04","id":"-202"}
            ]
        },
    
        {"id":-333,"name":"Test Patent Family 3  (3 US Patents)","us_patents_count":3,"us_applications_count":1,"max_expire_date":"2021-10-31","min_priority_date":"1994-02-15","non_us_patents_count":0,"non_us_applications_count":0,
            "patents":[
                {"patnum":"US0000301A1","stripped_patnum":"0000301","title":"Test Patent 3.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-301"},
                {"patnum":"US0000302A1","stripped_patnum":"0000302","title":"Test Patent 3.2","application_filing_date":"1992-09-23","expire_date":"2012-09-23","country":"US","issue_date":"1997-02-04","id":"-302"},
                {"patnum":"US0000303A1","stripped_patnum":"0000303","title":"Test Patent 3.3","application_filing_date":"1996-02-07","expire_date":"2016-02-07","country":"US","issue_date":"1998-05-05","id":"-303"}
            ]
        },
    
        {"id":-444,"name":"Test Patent Family 4  (4 US Patents)","us_patents_count":4,"max_expire_date":"2017-01-31","min_priority_date":"1992-09-23","non_us_patents_count":7,"us_applications_count":0,"non_us_applications_count":0,
            "patents":[
                {"patnum":"US0000401A1","stripped_patnum":"0000401","title":"Test Patent 4.1","application_filing_date":"1993-07-12","expire_date":"2013-07-12","country":"US","issue_date":"1996-09-03","id":"-401"},
                {"patnum":"US0000402A1","stripped_patnum":"0000402","title":"Test Patent 4.2","application_filing_date":"1992-09-23","expire_date":"2012-09-23","country":"US","issue_date":"1997-02-04","id":"-402"},
                {"patnum":"US0000403A1","stripped_patnum":"0000403","title":"Test Patent 4.3","application_filing_date":"1996-02-07","expire_date":"2016-02-07","country":"US","issue_date":"1998-05-05","id":"-403"},
                {"patnum":"US0000404A1","stripped_patnum":"0000404","title":"Test Patent 4.4","application_filing_date":"1997-01-31","expire_date":"2017-01-31","country":"US","issue_date":"1998-05-12","id":"-404"}
            ]
        }
    ],"count":4}


    === PATENT ANNOTATION RESPONSE BODY ===

    {"response":[
        {"patent_key":"US0000101","summary":null,"analyst_notes":null},
        {"patent_key":"US0000201","summary":"summary of patent 201","analyst_notes":"notes about patent 201"},
        {"patent_key":"US0000202","summary":"summary of patent 202","analyst_notes":"notes about patent 202"},
        {"patent_key":"US0000301","summary":"summary of patent 301","analyst_notes":"notes about patent 301"},
        {"patent_key":"US0000302","summary":"summary of patent 302","analyst_notes":"notes about patent 302"},
        {"patent_key":"US0000303","summary":"summary of patent 303","analyst_notes":"notes about patent 303"},
        {"patent_key":"US0000401","summary":"summary of patent 401","analyst_notes":"notes about patent 401"},
        {"patent_key":"US0000402","summary":"summary of patent 402","analyst_notes":"notes about patent 402"},
        {"patent_key":"US0000403","summary":"summary of patent 403","analyst_notes":"notes about patent 403"},
        {"patent_key":"US0000404","summary":"summary of patent 404","analyst_notes":"notes about patent 404"}            
    ],"count":10}
    
    
    === PORTFOLIO RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_acquisition_idX" (with x = 1-10) =======

    {"response":[
        {"summary":null,"id":"insert_acquisition_id1","primary_market_sector":"Networking","name":"acquisition1","theory_of_relevance":"1 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},
        {"summary":null,"id":"insert_acquisition_id2","primary_market_sector":"Networking","name":"acquisition2","theory_of_relevance":"2 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},
        {"summary":null,"id":"insert_acquisition_id3","primary_market_sector":"Mobile Communications and Devices","name":"acquisition3","theory_of_relevance":"3 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},
        {"summary":null,"id":"insert_acquisition_id4","primary_market_sector":"undefined","name":"acquisition4","theory_of_relevance":"4 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},
        {"summary":null,"id":"insert_acquisition_id5","primary_market_sector":"Networking","name":"acquisition5","theory_of_relevance":"5 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},
        {"summary":null,"id":"insert_acquisition_id6","primary_market_sector":"Networking","name":"acquisition6","theory_of_relevance":"6 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},
        {"summary":null,"id":"insert_acquisition_id7","primary_market_sector":"Semiconductors","name":"acquisition7","theory_of_relevance":"7 good reasons","analyst_notes":"important notes","quick_recommendation":"ANALYSE"},
        {"summary":null,"id":"insert_acquisition_id8","primary_market_sector":"Mobile Communications and Devices","name":"acquisition8","theory_of_relevance":"8 good reasons","analyst_notes":"important notes","quick_recommendation":"HOLD"},
        {"summary":null,"id":"insert_acquisition_id9","primary_market_sector":"Networking","name":"acquisition9","theory_of_relevance":"9 good reasons","analyst_notes":"important notes","quick_recommendation":"undefined"},
        {"summary":null,"id":"insert_acquisition_id10","primary_market_sector":"E-Commerce and Software","name":"acquisition10","theory_of_relevance":"10 good reasons","analyst_notes":"important notes","quick_recommendation":"PASS"}
    ],"count":10}


    === RELEVANT COMPANY RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_patent_idX" (with x = 1-4), "insert_account_idX" (with x = 1-4) =======
    
    {"response":[
        {"id":-991011,"pat_salesforce_id":"insert_patent_id1","ent_salesforce_id":null},
        {"id":-992011,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-992011},
        {"id":-992012,"pat_salesforce_id":"insert_patent_id2","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-992012},
        {"id":-993011,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-993011},
        {"id":-993012,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-993012},
        {"id":-993013,"pat_salesforce_id":"insert_patent_id3","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-993013},
        {"id":-994011,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id1","analyst_notes":"notes here","claim_id":-994011},
        {"id":-994012,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id2","analyst_notes":"notes here","claim_id":-994012},
        {"id":-994013,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id3","analyst_notes":"notes here","claim_id":-994013},
        {"id":-994014,"pat_salesforce_id":"insert_patent_id4","ent_salesforce_id":"insert_account_id4","analyst_notes":"notes here","claim_id":-994014}
    ],"count":10}
    
    
    === TECH TAG RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_product_service_idX" (with x = 1-4) =======

    {"response":[
        {"id":-991011,"pat_id":-101,"product_service_sfdc_id":null,"name":null,"tier":null,"free_form_tags":null,"patent_key":"US0000101"},
        {"id":-992011,"pat_id":-201,"product_service_sfdc_id":"insert_product_service_id1","name":"Hardware_Networking_Switch/Router_Optical","tier":1,"free_form_tags":null,"patent_key":"US0000201"},
        {"id":-992012,"pat_id":-201,"product_service_sfdc_id":"insert_product_service_id2","name":"Semi_Fabrication_Process","tier":1,"free_form_tags":null,"patent_key":"US0000201"},
        {"id":-993011,"pat_id":-301,"product_service_sfdc_id":"insert_product_service_id1","name":"Hardware_Networking_Switch/Router_Optical","tier":1,"free_form_tags":null,"patent_key":"US0000301"},
        {"id":-993012,"pat_id":-301,"product_service_sfdc_id":"insert_product_service_id2","name":"Semi_Fabrication_Process","tier":1,"free_form_tags":null,"patent_key":"US0000301"},
        {"id":-993013,"pat_id":-301,"product_service_sfdc_id":"insert_product_service_id3","name":"Semi_Memory_NVM","tier":1,"free_form_tags":null,"patent_key":"US0000301"},
        {"id":-994011,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id1","name":"Hardware_Networking_Switch/Router_Optical","tier":1,"free_form_tags":null,"patent_key":"US0000401"},
        {"id":-994012,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id2","name":"Semi_Fabrication_Process","tier":1,"free_form_tags":null,"patent_key":"US0000401"},
        {"id":-994013,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id3","name":"Semi_Memory_NVM","tier":1,"free_form_tags":null,"patent_key":"US0000401"},
        {"id":-994014,"pat_id":-401,"product_service_sfdc_id":"insert_product_service_id4","name":"Semi_Imaging (CCD, CMOS, etc.)","tier":1,"free_form_tags":null,"patent_key":"US0000401"}
    ],"count":10}
    
    
    === CLAIM CHARTED COMPANY CHANGES RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_pagination", "insert_page_item_count" =======
    ======= Response Start (w/o quotes): "[" =======
    ======= Response End (w/o quotes): "]" =======

    =========== ODD PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"added","obj_id":"-991011"},
        {"action":"changed","obj_id":"-992011","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-992021","obj_type":"pat_claim_charted_company"},
        {"action":"changed","obj_id":"-993011","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-993021","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-993031","obj_type":"pat_claim_charted_company"},
        {"action":"changed","obj_id":"-994011","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-994021","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-994031","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-994041","obj_type":"pat_claim_charted_company"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    =========== EVEN PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"-992012","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-992022","obj_type":"pat_claim_charted_company"},
        {"action":"changed","obj_id":"-993012","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-993022","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-993032","obj_type":"pat_claim_charted_company"},
        {"action":"changed","obj_id":"-994012","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-994022","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-994032","obj_type":"pat_claim_charted_company"},
        {"action":"deleted","obj_id":"-994042","obj_type":"pat_claim_charted_company"},
        {"action":"changed","obj_id":"-994014","obj_type":"pat_claim_charted_company"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}
    
    
    === LICENSEE CHANGES RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_pagination", "insert_page_item_count" =======
    ======= Response Start (w/o quotes): "[" =======
    ======= Response End (w/o quotes): "]" =======

    =========== ODD PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"added","obj_id":"-991011"},
        {"action":"changed","obj_id":"-992011","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-992021","obj_type":"pat_licensee"},
        {"action":"changed","obj_id":"-993011","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-993021","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-993031","obj_type":"pat_licensee"},
        {"action":"changed","obj_id":"-994011","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-994021","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-994031","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-994041","obj_type":"pat_licensee"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    =========== EVEN PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"-992012","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-992022","obj_type":"pat_licensee"},
        {"action":"changed","obj_id":"-993012","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-993022","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-993032","obj_type":"pat_licensee"},
        {"action":"changed","obj_id":"-994012","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-994022","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-994032","obj_type":"pat_licensee"},
        {"action":"deleted","obj_id":"-994042","obj_type":"pat_licensee"},
        {"action":"changed","obj_id":"-994014","obj_type":"pat_licensee"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}
    
    
    === PATENT ANNOTATION CHANGES RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_pagination", "insert_page_item_count" =======
    ======= Response Start (w/o quotes): "[" =======
    ======= Response End (w/o quotes): "]" =======

    =========== ODD PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"US0000101"},
        {"action":"changed","obj_id":"US0000201","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000301","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000401","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000303","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000303","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000303","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000403","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000403","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000403","obj_type":"patent"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    =========== EVEN PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"US0000202","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000302","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000402","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000202","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000302","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000402","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000404","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000404","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000404","obj_type":"patent"},
        {"action":"changed","obj_id":"US0000404","obj_type":"patent"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}
    

    === PATENT FAMILY CHANGES RESPONSE BODY ===

    ======= Variables (w/ quotes): "insert_pagination", "insert_page_item_count" =======
    ======= Response Start (w/o quotes): "[" =======
    ======= Response End (w/o quotes): "]" =======

    =========== ODD PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"added","obj_id":"US0000101","obj_type":"patent"},
        {"action":"added","obj_id":"-111","obj_type":"pat_family"},
        {"action":"added","obj_id":"US0000201","obj_type":"patent"},
        {"action":"added","obj_id":"US0000301","obj_type":"patent"},
        {"action":"added","obj_id":"US0000401","obj_type":"patent"},
        {"action":"added","obj_id":"US0000303","obj_type":"patent"},
        {"action":"added","obj_id":"US0000303","obj_type":"patent"},
        {"action":"added","obj_id":"US0000403","obj_type":"patent"},
        {"action":"added","obj_id":"US0000403","obj_type":"patent"},
        {"action":"added","obj_id":"US0000403","obj_type":"patent"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    =========== EVEN PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"deleted","obj_id":"US0000202","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000302","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000402","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000202","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000302","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000402","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000404","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000404","obj_type":"patent"},
        {"action":"deleted","obj_id":"US0000404","obj_type":"patent"},
        {"action":"deleted","obj_id":"-555","obj_type":"pat_family"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    
    === PORTFOLIO ANNOTATION CHANGES RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_pagination", "insert_page_item_count", "insert_acquisition_idX" (with x = 1-10) =======
    ======= Response Start (w/o quotes): "[" =======
    ======= Response End (w/o quotes): "]" =======

    =========== ODD PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"insert_acquisition_id1"},
        {"action":"changed","obj_id":"insert_acquisition_id3","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id5","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id7","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id9","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id1"},
        {"action":"changed","obj_id":"insert_acquisition_id3","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id5","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id7","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id9","obj_type":"portfolio"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    =========== EVEN PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"insert_acquisition_id2","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id4","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id6","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id8","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id10","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id2","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id4","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id6","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id8","obj_type":"portfolio"},
        {"action":"changed","obj_id":"insert_acquisition_id10","obj_type":"portfolio"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}
    
    
    === RELEVANT COMPANY CHANGES RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_pagination", "insert_page_item_count" =======
    ======= Response Start (w/o quotes): "[" =======
    ======= Response End (w/o quotes): "]" =======

    =========== ODD PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"added","obj_id":"-991011"},
        {"action":"changed","obj_id":"-992011","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-992021","obj_type":"pat_relevant_company"},
        {"action":"changed","obj_id":"-993011","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-993021","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-993031","obj_type":"pat_relevant_company"},
        {"action":"changed","obj_id":"-994011","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-994021","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-994031","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-994041","obj_type":"pat_relevant_company"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    =========== EVEN PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"-992012","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-992022","obj_type":"pat_relevant_company"},
        {"action":"changed","obj_id":"-993012","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-993022","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-993032","obj_type":"pat_relevant_company"},
        {"action":"changed","obj_id":"-994012","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-994022","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-994032","obj_type":"pat_relevant_company"},
        {"action":"deleted","obj_id":"-994042","obj_type":"pat_relevant_company"},
        {"action":"changed","obj_id":"-994014","obj_type":"pat_relevant_company"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}
    
    
    === TECH TAG CHANGES RESPONSE BODY ===
    ======= Variables (w/ quotes): "insert_pagination", "insert_page_item_count" =======
    ======= Response Start (w/o quotes): "[" =======
    ======= Response End (w/o quotes): "]" =======

    =========== ODD PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"inserted","obj_id":"-991011"},
        {"action":"changed","obj_id":"-992011","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-992021","obj_type":"tech_tag"},
        {"action":"changed","obj_id":"-993011","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-993021","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-993031","obj_type":"tech_tag"},
        {"action":"changed","obj_id":"-994011","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-994021","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-994031","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-994041","obj_type":"tech_tag"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

    =========== EVEN PAGE (10 ITEMS) ===========

    {"response":[
        {"action":"changed","obj_id":"-992012","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-992022","obj_type":"tech_tag"},
        {"action":"changed","obj_id":"-993012","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-993022","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-993032","obj_type":"tech_tag"},
        {"action":"changed","obj_id":"-994012","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-994022","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-994032","obj_type":"tech_tag"},
        {"action":"deleted","obj_id":"-994042","obj_type":"tech_tag"},
        {"action":"changed","obj_id":"-994014","obj_type":"tech_tag"}
    ],
    "pagination":"insert_pagination",
    "count":"insert_page_item_count"}

************************************************************************************************/