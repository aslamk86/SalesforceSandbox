/*****************************************************************************
 * Name             : TestBatchPortfolioChatterFeed
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Jan, 2012.
 * Purpose          : Test class for BatchPortfolioChatterFeed
 *                    T-21599
*****************************************************************************/
@isTest
private class TestBatchPortfolioChatterFeed {
	
	static testMethod void testAssignmentNoteFeed() {
		
		String ASSIGNMENT_NOTE = 'Assignment_Note__c';
    String ASSIGNED_TO = 'Assigned_to__c';
    
    Account acct = TestUtil.createAccount(true);
    
    Assets__c portfolio = TestUtil.createPortfolio(true);
    List<Patent__c> lstPatent = new List<Patent__c>();
    lstPatent.add(TestUtil.createPatent(false));
    lstPatent.add(TestUtil.createPatent(false));
    lstPatent.add(TestUtil.createPatent(false));
    
    lstPatent[0].Patent_Family__c = portfolio.Id;
    lstPatent[1].Patent_Family__c = portfolio.Id;
    lstPatent[2].Patent_Family__c = portfolio.Id;
    insert lstPatent;
    
    Set<Id> patentIds = new Set<Id>();
    for (Patent__c patent : lstPatent) {
    	patentIds.add(patent.Id);
    }
    
    BatchPortfolioChatterFeed.testPortfolioId = portfolio.Id;
    //Update Assignment Note
    lstPatent[0].Assignment_Note__c = 'Test Note 1';
    lstPatent[1].Assignment_Note__c = 'Test Note 3';
    lstPatent[0].Assigned_To__c = acct.Id;
    update lstPatent;
    
    //Note: History is created in a future method by salesforce
    //So 2 history records are created Manually.
    List<Patent__History> pHistory = new List<Patent__History>(); 
    pHistory.add(TestUtil.createParentHistory(lstPatent[0].Id, 
      ASSIGNMENT_NOTE, false));
      
    pHistory.add(TestUtil.createParentHistory(lstPatent[1].Id, 
      ASSIGNMENT_NOTE, false));
    
    
    pHistory.add(TestUtil.createParentHistory(lstPatent[1].Id, 
      ASSIGNED_TO, false));
    
    
    insert pHistory;
    System.assertEquals(2, [Select Id 
										        From Patent__History 
										        Where Field = :ASSIGNMENT_NOTE
										        And parentId in :patentIds].size());
    
    Test.startTest();   
    //Run Batch
    database.executeBatch(new BatchPortfolioChatterFeed(),5);
    Test.stopTest();
    
    System.assertEquals(2, [Select Id,Body 
                            From FeedItem 
                            Where ParentId = :portfolio.Id].size());
	}
	
	
}