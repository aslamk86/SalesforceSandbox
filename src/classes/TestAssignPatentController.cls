/*****************************************************************************
 * Name             : TestAssignPatentController
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 06 Feb, 2012.
 * Last Modified    : 10/24/2013 by Hank Ryan Thompson
 * Purpose          : Test class for AssignPatentController
 *                    T-24262  
*****************************************************************************/
@isTest
private class TestAssignPatentController {

    static testMethod void testAssignPatent() {
	    
	    system.debug('###testAssignPatent(): Entering function...###');
	    
	    // First create test patents & families that match up with the mocked web service output
	    Map<String, Object> testRecordMap = SyncEngineTests.createAPITestRecords();
	    Patent__c testPatent201 = (Patent__c)testRecordMap.get('testPatent201');
	    Patent__c testPatent202 = (Patent__c)testRecordMap.get('testPatent202');
	    Patent__c testPatent301 = (Patent__c)testRecordMap.get('testPatent301');
	    Assets__c testPatentFamily2 = (Assets__c)testRecordMap.get('testPatentFamily2');
	    Assets__c testPatentFamily3 = (Assets__c)testRecordMap.get('testPatentFamily3');
	    Acquisition_Opportunity__c testAcquisition1 = (Acquisition_Opportunity__c)testRecordMap.get('testAcquisition1');
	    
	    // Start the test (set the appropriate web service mock)
	    Test.startTest();
	    Test.setMock(HttpCalloutMock.class, new CoreAPIMockResponseGenerator());
	    
	    // Instantiate the controller
	    ApexPages.currentPage().getParameters().put('relatedRecordId', testAcquisition1.Id);
	    AssignPatentController controller = new AssignPatentController();
	    controller.searchPatents(); // test coverage: trigger error
	    
	    // Search for the patents. NOTE: The actual search text will not effect the results (since the response is mocked), but will help test the code
	    controller.srchPatentNum = 'US0000202; 0000302,  US0000402 \n123\nUS0000501'; // (note: our mock patent numbers are not "valid" based on the regexes)
	    controller.searchPatents();
	    
	    // get the resultRows and make sure they match our expectation
	    Set<String> disabledPatentRows = new Set<String>();
	    Set<String> selectedPatentRows = new Set<String>();
	    Map<String, AssignPatentController.ResultRow> rowMap = new Map<String, AssignPatentController.ResultRow>(); //maps from patent name to patent row 
	    for (AssignPatentController.ResultRow pfRow:controller.resultRows)
	        for (AssignPatentController.ResultRow pRow:pfRow.children) {
		        rowMap.put(pRow.patent.Name, pRow);
		        if (pRow.isDisabled) disabledPatentRows.add(pRow.patent.Name);
	        }
	    
	    system.assertEquals(1, disabledPatentRows.size());
	    system.assert(disabledPatentRows.contains('US0000201A1'));
	    
	    // select the ones we want to select
	    system.assert(rowMap.containsKey('US0000202A1'));
	    system.assert(rowMap.containsKey('US0000302A1'));
	    system.assert(rowMap.containsKey('US0000402A1'));
	    system.assert(rowMap.containsKey('US0000501A1'));
        
        // test that the searchPatents() function automatically selected the right patents
        system.assert(rowMap.get('US0000202A1').isSelected);
        system.assert(rowMap.get('US0000302A1').isSelected);
        system.assert(rowMap.get('US0000402A1').isSelected);
        system.assert(rowMap.get('US0000501A1').isSelected);
	    
	    // now click the associate button & stop the test (we're done with everything except assertions)
	    controller.createMappingRecords();
	    Test.stopTest();
	    
	    // first assert that the the selected patents & families made it in
	    Assets__c[] patentFamilies = [select Id, Name, Core_Patent_Family_Id__c from Assets__c where Core_Patent_Family_Id__c in (-111, -222, -333, -444)];
	    Patent__c[] patents = [select Id, Name, Patent_Family__c from Patent__c where Name in ('US0000101A1', 'US0000201A1', 'US0000202A1', 'US0000301A1', 'US0000302A1', 'US0000303A1', 'US0000401A1', 'US0000402A1', 'US0000403A1', 'US0000404A1', 'US0000501A1')];
	    Map<String, Assets__c> patentFamilyMap = new Map<String, Assets__c>(); //maps from primary patent family key to patent family record
	    Map<String, Patent__c> patentMap = new Map<String, Patent__c>(); //maps from primary patent key to patent record
	    for (Assets__c pf:patentFamilies) patentFamilyMap.put(SyncEngine.getPrimaryKey(pf), pf);
	    for (Patent__c p:patents) patentMap.put(SyncEngine.getPrimaryKey(p), p);
	    
	    system.debug('###testAssignPatent(): patentFamilies = ' + patentFamilies + '###');
	    
	    system.assertEquals(3, patentFamilies.size());
	    system.assert(patentFamilyMap.containsKey('-222'));
	    system.assert(patentFamilyMap.containsKey('-333'));
	    system.assert(patentFamilyMap.containsKey('-444'));
	    system.assertEquals(6, patents.size());
	    system.assert(patentMap.containsKey('US0000201A1'));
	    system.assert(patentMap.containsKey('US0000202A1'));
	    system.assert(patentMap.containsKey('US0000301A1'));
	    system.assert(patentMap.containsKey('US0000302A1'));
	    system.assert(patentMap.containsKey('US0000402A1'));
        system.assert(patentMap.containsKey('US0000501A1'));
	    
	    //now assert that the new patents are correctly parented
	    system.assertEquals(testPatentFamily2.Id, patentMap.get('US0000202A1').Patent_Family__c );
	    system.assertEquals(testPatentFamily3.Id, patentMap.get('US0000302A1').Patent_Family__c );
	    system.assertEquals(patentFamilyMap.get('-444').Id, patentMap.get('US0000402A1').Patent_Family__c );
	    system.assertEquals(null, patentMap.get('US0000501A1').Patent_Family__c ); //this one should NOT have a patent family
	    
	    // Finally confirm that the oma_patent__c records are present
	    OMA_Patent__c[] omapRecords = [select Patent__c, Acquisition_Opportunity__c from OMA_Patent__c where Acquisition_Opportunity__c = :testAcquisition1.Id];
	    Set<Id> linkedPatentIds = new Set<Id>();
	    for (OMA_Patent__c omap:omapRecords )
	        linkedPatentIds.add(omap.Patent__c);
	    
	    system.assertEquals(5, omapRecords.size());
	    system.assert(linkedPatentIds.contains(testPatent201.Id));
	    system.assert(linkedPatentIds.contains(patentMap.get('US0000202A1').Id));
	    system.assert(linkedPatentIds.contains(patentMap.get('US0000302A1').Id));
	    system.assert(linkedPatentIds.contains(patentMap.get('US0000402A1').Id));
        system.assert(linkedPatentIds.contains(patentMap.get('US0000501A1').Id));
	    
	    // Done!
	    system.debug('###testAssignPatent(): Exiting function.###');
    }
}