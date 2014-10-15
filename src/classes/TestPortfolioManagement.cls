@isTest
private class TestPortfolioManagement {

	static testMethod void testPatentAssignmentNoteUpdate() {
	  Assets__c portfolio = TestUtil.createPortfolio(true);
	  Patent__c patent = TestUtil.createPatent(false);
	  patent.Patent_Family__c = portfolio.Id;  
	  insert patent;
	  
	  Test.startTest();
	  portfolio.Assignment_Note__c = 'Test Note';
	  portfolio.Populate_on_All_Patents_in_Portfolio__c = true;
	  update portfolio;
	  
	  // Patent assignment Note must be same as portfolio Assignment Note
	//  System.assertEquals(portfolio.Assignment_Note__c, 
	//    [Select id, Assignment_Note__c
	//     From Patent__c 
	//     Where Id = :patent.Id].Assignment_Note__c);
	  
	  delete portfolio;   
	  Test.stopTest(); 
	}
}