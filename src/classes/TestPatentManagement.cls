/****************************************************
   
    TEST PATENT MANAGEMENT CLASS
    
    Created by Appirio.
    Last updated 10/23/2013 by Hank Ryan Thompson.
    
    This class tests the patent triggers.
    
****************************************************/

@isTest
private class TestPatentManagement {
    
    static testMethod void testPatentTrigger_DeleteEmptyPatentFamily() {
        // Test that when a patent is moved out of a patent family, the patent family is deleted if it's now empty
        
        system.debug('###testPatentTrigger_DeleteEmptyPatentFamily(): Entering function.###' );
        
        // Create test records
        Assets__c testPatentFamilyEmpty = new Assets__c(Name='testPatentFamilyEmpty', Core_Patent_Family_Id__c=-4440); // this should get deleted later
        Assets__c testPatentFamilyNotEmpty = new Assets__c(Name='testPatentFamilyNotEmpty', Core_Patent_Family_Id__c=-4441); // this should get deleted later
        Assets__c testPatentFamilyNew = new Assets__c(Name='testPatentFamilyNew', Core_Patent_Family_Id__c=-4442); // this should get deleted later
        insert new Assets__c[]{testPatentFamilyEmpty, testPatentFamilyNotEmpty, testPatentFamilyNew};
        Patent__c testPatentA = new Patent__c(Name='testPatentA', Title__c='testPatentA', Patent_Family__c=testPatentFamilyEmpty.Id, Core_DB_Patent_Id__c=-401);
        Patent__c testPatentB1 = new Patent__c(Name='testPatentB1', Title__c='testPatentB1', Patent_Family__c=testPatentFamilyNotEmpty.Id, Core_DB_Patent_Id__c=-9999921);
        Patent__c testPatentB2 = new Patent__c(Name='testPatentB2', Title__c='testPatentB2', Patent_Family__c=testPatentFamilyNotEmpty.Id, Core_DB_Patent_Id__c=-9999922);
        insert new Patent__c[]{testPatentA, testPatentB1, testPatentB2};
        
        Test.startTest();
        
        testPatentA.Patent_Family__c = testPatentFamilyNew.Id;
        testPatentB1.Patent_Family__c = testPatentFamilyNew.Id;
        update new Patent__c[]{testPatentA, testPatentB1}; // this will fire the trigger which should end up deleting the empty patent family
        
        Test.stopTest();
        
        Integer emptyCount; Integer nonEmptyCount;
        emptyCount = [select count() from Assets__c where id=:testPatentFamilyEmpty.Id];
        nonEmptyCount = [select count() from Assets__c where id=:testPatentFamilyNotEmpty.Id];
        
        system.assertEquals(0, emptyCount); // this should've been deleted since it is now empty
        system.assertEquals(1, nonEmptyCount); // this should NOT be deleted since it still has testPatentB2
        
        system.debug('###testPatentTrigger_DeleteEmptyPatentFamily(): Exiting function.###' );
        
    }
    
    static testMethod void testPatentAssignmentNoteUpdate() {
        Account acct = TestUtil.createAccount(true);
        Patent__c patent = TestUtil.createPatent(false);
	    patent.Assigned_to__c = null;
	    patent.Assignment_Note_by__c = null;
	    patent.Assignment_Note_Date__c = null;
	    insert patent;
    
	    System.assertEquals(1, 
	        [Select count()
	         From Patent__c 
	         Where id = :patent.Id
	         And Assigned_to__c = null
	         And Assignment_Note_by__c = null
	         And Assignment_Note_Date__c = null]);
	      
	      patent.Assigned_to__c = acct.Id;
	      update patent;
	      
	      patent = [Select id, Assignment_Note__c, 
	                       Assignment_Note_by__c, Assignment_Note_Date__c 
	                From Patent__c 
	                Where id = :patent.Id][0];  
	      
	      System.assertNotEquals(null, patent.Assignment_Note_Date__c);
	      System.assertEquals(UserInfo.getUserId(), patent.Assignment_Note_by__c);  
    }
    
    static testMethod void testPatentTrigger_AnnotationRollup() {
        // Test that the Characterization of Claims, Representative Claims and Summary fields on the patent are rolled up to the patent family
        
        system.debug('###testPatentTrigger_AnnotationRollup(): Entering function.###' );
        
        // Create test records
        Assets__c testPatentFamilyA = new Assets__c(Name='testPatentFamilyA', Core_Patent_Family_Id__c=-1111); // patents will have annotation on insert
        Assets__c testPatentFamilyB = new Assets__c(Name='testPatentFamilyB', Core_Patent_Family_Id__c=-2222); // patents will have (some) annotation updated after insert
        insert new Assets__c[]{testPatentFamilyA, testPatentFamilyB};
        
        Patent__c testPatentA1 = new Patent__c(Name='testPatentA1', Title__c='testPatentA1', Patent_Family__c=testPatentFamilyA.Id, Core_DB_Patent_Id__c=-111101, Patent_No__c='111101', Characterization_of_Claims__c='CoC A1', Representative_Claims__c='RC A1', Summary__c='Summary A1');
        Patent__c testPatentA2 = new Patent__c(Name='testPatentA2', Title__c='testPatentA2', Patent_Family__c=testPatentFamilyA.Id, Core_DB_Patent_Id__c=-111102, Patent_No__c='111102', Characterization_of_Claims__c='CoC A2', Representative_Claims__c='RC A2', Summary__c='Summary A2');
        Patent__c testPatentA3 = new Patent__c(Name='testPatentA3', Title__c='testPatentA3', Patent_Family__c=testPatentFamilyA.Id, Core_DB_Patent_Id__c=-111103, Patent_No__c='111103', Characterization_of_Claims__c='CoC A3', Representative_Claims__c='RC A3', Summary__c='Summary A3');
        Patent__c testPatentB1 = new Patent__c(Name='testPatentB1', Title__c='testPatentB1', Patent_Family__c=testPatentFamilyB.Id, Core_DB_Patent_Id__c=-222201, Patent_No__c='222201', Characterization_of_Claims__c='CoC B1', Representative_Claims__c='RC B1', Summary__c='Summary B1');
        Patent__c testPatentB2 = new Patent__c(Name='testPatentB2', Title__c='testPatentB2', Patent_Family__c=testPatentFamilyB.Id, Core_DB_Patent_Id__c=-222202, Patent_No__c='222202');
        Patent__c testPatentB3 = new Patent__c(Name='testPatentB3', Title__c='testPatentB3', Patent_Family__c=testPatentFamilyB.Id, Core_DB_Patent_Id__c=-222203, Patent_No__c='222203');
        
        Acquisition_Opportunity__c testAcquisition = New Acquisition_Opportunity__c(StageName__c='Closed Won', Name='testAcquisition', Probability__c='25', CloseDate__c=Date.today(), Amount_for_Pipeline__c=50, Purchase_Date__c = Date.today());
        RecordType[] rts = [select id, name, developername from recordtype where SObjectType = 'Acquisition_Opportunity__c' and DeveloperName='OMA'];
        if (rts.size() > 0) testAcquisition.RecordTypeId = rts[0].Id; 
        insert testAcquisition;
        
        Test.startTest();
        
        // Fire the insert trigger
        insert new Patent__c[]{testPatentA1, testPatentA2, testPatentA3, testPatentB1, testPatentB2, testPatentB3};
        
        // Link the patents (and thus the patent families) to the acquisition        
        OMA_Patent__c omapA1 = new OMA_Patent__c(Patent__c=testPatentA1.Id, Acquisition_Opportunity__c=testAcquisition.Id);
        OMA_Patent__c omapB1 = new OMA_Patent__c(Patent__c=testPatentB1.Id, Acquisition_Opportunity__c=testAcquisition.Id);
        insert new OMA_Patent__c[]{omapA1, omapB1};
        
        // Fire the update trigger
        testPatentB2.Characterization_of_Claims__c = 'CoC B2'; testPatentB2.Representative_Claims__c = 'RC B2'; testPatentB2.Summary__c = 'Summary B2';
		testPatentB3.Characterization_of_Claims__c = 'CoC B3'; testPatentB3.Representative_Claims__c = 'RC B3'; testPatentB3.Summary__c = 'Summary B3';
		update new Patent__c[]{testPatentB2, testPatentB3};
        
        Test.stopTest();
        
        // Make assumptions... the patent family fields should contain all of the desired child patent fields
        testPatentFamilyA = [select Id, Name, Characterization_of_Claims__c, Representative_Claims__c, Summary__c from Assets__c where Id=:testPatentFamilyA.Id];
        testPatentFamilyB = [select Id, Name, Characterization_of_Claims__c, Representative_Claims__c, Summary__c from Assets__c where Id=:testPatentFamilyB.Id];
        
        // PATENT FAMILY A 
        
        system.assert(testPatentFamilyA.Characterization_of_Claims__c != null);
        system.assert(testPatentFamilyA.Characterization_of_Claims__c.contains(testPatentA1.Patent_No__c));
        system.assert(testPatentFamilyA.Characterization_of_Claims__c.contains(testPatentA1.Characterization_of_Claims__c));
        system.assert(testPatentFamilyA.Characterization_of_Claims__c.contains(testPatentA2.Patent_No__c));
        system.assert(testPatentFamilyA.Characterization_of_Claims__c.contains(testPatentA2.Characterization_of_Claims__c));
        system.assert(testPatentFamilyA.Characterization_of_Claims__c.contains(testPatentA3.Patent_No__c));
        system.assert(testPatentFamilyA.Characterization_of_Claims__c.contains(testPatentA3.Characterization_of_Claims__c));
        
        system.assert(testPatentFamilyA.Representative_Claims__c != null);
        system.assert(testPatentFamilyA.Representative_Claims__c.contains(testPatentA1.Patent_No__c));
        system.assert(testPatentFamilyA.Representative_Claims__c.contains(testPatentA1.Representative_Claims__c));
        system.assert(testPatentFamilyA.Representative_Claims__c.contains(testPatentA2.Patent_No__c));
        system.assert(testPatentFamilyA.Representative_Claims__c.contains(testPatentA2.Representative_Claims__c));
        system.assert(testPatentFamilyA.Representative_Claims__c.contains(testPatentA3.Patent_No__c));
        system.assert(testPatentFamilyA.Representative_Claims__c.contains(testPatentA3.Representative_Claims__c));

        system.assert(testPatentFamilyA.Summary__c != null);
        system.assert(testPatentFamilyA.Summary__c.contains(testPatentA1.Patent_No__c));
        system.assert(testPatentFamilyA.Summary__c.contains(testPatentA1.Summary__c));
        system.assert(testPatentFamilyA.Summary__c.contains(testPatentA2.Patent_No__c));
        system.assert(testPatentFamilyA.Summary__c.contains(testPatentA2.Summary__c));
        system.assert(testPatentFamilyA.Summary__c.contains(testPatentA3.Patent_No__c));
        system.assert(testPatentFamilyA.Summary__c.contains(testPatentA3.Summary__c));

        // PATENT FAMILY B

        system.assert(testPatentFamilyB.Characterization_of_Claims__c != null);
        system.assert(testPatentFamilyB.Characterization_of_Claims__c.contains(testPatentB1.Patent_No__c));
        system.assert(testPatentFamilyB.Characterization_of_Claims__c.contains(testPatentB1.Characterization_of_Claims__c));
        system.assert(testPatentFamilyB.Characterization_of_Claims__c.contains(testPatentB2.Patent_No__c));
        system.assert(testPatentFamilyB.Characterization_of_Claims__c.contains(testPatentB2.Characterization_of_Claims__c));
        system.assert(testPatentFamilyB.Characterization_of_Claims__c.contains(testPatentB3.Patent_No__c));
        system.assert(testPatentFamilyB.Characterization_of_Claims__c.contains(testPatentB3.Characterization_of_Claims__c));
        
        system.assert(testPatentFamilyB.Representative_Claims__c != null);
        system.assert(testPatentFamilyB.Representative_Claims__c.contains(testPatentB1.Patent_No__c));
        system.assert(testPatentFamilyB.Representative_Claims__c.contains(testPatentB1.Representative_Claims__c));
        system.assert(testPatentFamilyB.Representative_Claims__c.contains(testPatentB2.Patent_No__c));
        system.assert(testPatentFamilyB.Representative_Claims__c.contains(testPatentB2.Representative_Claims__c));
        system.assert(testPatentFamilyB.Representative_Claims__c.contains(testPatentB3.Patent_No__c));
        system.assert(testPatentFamilyB.Representative_Claims__c.contains(testPatentB3.Representative_Claims__c));

        system.assert(testPatentFamilyB.Summary__c != null);
        system.assert(testPatentFamilyB.Summary__c.contains(testPatentB1.Patent_No__c));
        system.assert(testPatentFamilyB.Summary__c.contains(testPatentB1.Summary__c));
        system.assert(testPatentFamilyB.Summary__c.contains(testPatentB2.Patent_No__c));
        system.assert(testPatentFamilyB.Summary__c.contains(testPatentB2.Summary__c));
        system.assert(testPatentFamilyB.Summary__c.contains(testPatentB3.Patent_No__c));
        system.assert(testPatentFamilyB.Summary__c.contains(testPatentB3.Summary__c));
        
        // Now test the rollup to the acquisition summary fields
        // (Note: This is handled by PortfolioManagement & AcquisitionOpportunityUtility and thus is slightly outside of the scope of this test class, but it's still helpful to test here.)
        testAcquisition = [select Id, Name, Characterization_of_Claims__c, Representative_Claims__c, Summary__c from Acquisition_Opportunity__c where Id = :testAcquisition.Id];
        
        system.assert(testAcquisition.Characterization_of_Claims__c != null);
        system.assert(testAcquisition.Characterization_of_Claims__c.contains(testPatentFamilyA.Characterization_of_Claims__c));
        system.assert(testAcquisition.Characterization_of_Claims__c.contains(testPatentFamilyB.Characterization_of_Claims__c));
        
        system.assert(testAcquisition.Representative_Claims__c != null);
        system.assert(testAcquisition.Representative_Claims__c.contains(testPatentFamilyA.Representative_Claims__c));
        system.assert(testAcquisition.Representative_Claims__c.contains(testPatentFamilyB.Representative_Claims__c));
        
        system.assert(testAcquisition.Summary__c != null);
        system.assert(testAcquisition.Summary__c.contains(testPatentFamilyA.Summary__c));
        system.assert(testAcquisition.Summary__c.contains(testPatentFamilyB.Summary__c));
        
        system.debug('###testPatentTrigger_AnnotationRollup(): Exiting function.###' );
        
    }
    
    static testMethod void testPatentTrigger_AnnotationRollupWithReallyLongText() {
        // This tests the edge case that occurs when the rolled up patent fields produce more than 32,768 characters
        
        system.debug('###testPatentTrigger_AnnotationRollupWithReallyLongText(): Entering function.###' );
        
        // Create test patent family
        Assets__c testPatentFamily = new Assets__c(Name='testPatentFamily', Core_Patent_Family_Id__c=-1111); // patents will have annotation on insert
        insert testPatentFamily;
        
        // Build test patents but don't insert
        String reallyLongTextValueA = 'a'.repeat(20000); // 20000*2 > 32768
        String reallyLongTextValueB = 'b'.repeat(20000); // 20000*2 > 32768
        Patent__c testPatentA = new Patent__c(Name='testPatentA', Title__c='testPatentA', Patent_Family__c=testPatentFamily.Id, Core_DB_Patent_Id__c=-111101, Patent_No__c='111101', Characterization_of_Claims__c='aaa', Representative_Claims__c=reallyLongTextValueA, Summary__c=reallyLongTextValueA);
        Patent__c testPatentB = new Patent__c(Name='testPatentB', Title__c='testPatentB', Patent_Family__c=testPatentFamily.Id, Core_DB_Patent_Id__c=-111102, Patent_No__c='111102', Characterization_of_Claims__c='bbb', Representative_Claims__c=reallyLongTextValueB, Summary__c=reallyLongTextValueB);
        
        Test.startTest();
        
        // Fire the insert trigger (causing an error if edge case is not cared for)
        insert new Patent__c[]{testPatentA, testPatentB};
        
        // Stop the test
        Test.stopTest();
        
        // Assert that there was no error and that the rollup fields were combined 
        // system.assert(!errorOccured); >> if the insert errors out then it's more descriptive to let the error come through, rather than catching it and asserting against the boolean
        testPatentFamily = [select Id, Name, Summary__c, Representative_Claims__c, Characterization_of_Claims__c from Assets__c where id=:testPatentFamily.Id]; 
        system.assert(testPatentFamily.Summary__c.contains('a'));
        system.assert(testPatentFamily.Summary__c.contains('b'));
        system.assert(testPatentFamily.Representative_Claims__c.contains('a'));
        system.assert(testPatentFamily.Representative_Claims__c.contains('b'));
        system.assert(testPatentFamily.Characterization_of_Claims__c.contains('a'));
        system.assert(testPatentFamily.Characterization_of_Claims__c.contains('b'));
        
        system.debug('###testPatentTrigger_AnnotationRollup(): Exiting function.###' );
        
    }
       
}