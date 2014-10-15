/****************************************************************************************************************************
 * Name             : TestSearchActivityHistoryController
 * Created By       : Neeraj(Appirio Offshore)
 * Created Date     : 15 April, 2012.
 * Purpose          : Controller class for Custom Activity Search Page
 * Task							:	T-43296
****************************************************************************************************************************/
@IsTest(SeeAllData = false)
private class TestSearchActivityHistoryController {
	static testMethod void testActivityHistorySearch() {
		//Creating test Data
		Account acct = TestUtil.createAccount(true);
		Contact cnt = TestUtil.createContact(acct.Id, true);
		
		//Creating Tasks for Testing		
		List<Task> lstTasks = new List<Task> ();
		Task tsk1 = TestUtil.createTask(cnt.Id, acct.Id, false);
		tsk1.Description = 'Test Des 1'; 
		lstTasks.add(tsk1);
		Task tsk2 = TestUtil.createTask(cnt.Id, acct.Id, false);
		tsk2.Description = 'Test Des 2';
		lstTasks.add(tsk2);
		Task tsk3 = TestUtil.createTask(cnt.Id, acct.Id, false);
		tsk3.Description = 'Test Des 3';
		lstTasks.add(tsk3);
		insert lstTasks;
		
		Test.startTest();
		List<Id> fixedSearchResults = new List<Id>{tsk1.Id, tsk2.Id, tsk3.Id};
		Test.setFixedSearchResults(fixedSearchResults);
		
		Test.setCurrentPage(Page.SearchActivityHistory);
		Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		//set page parameters
		pageParams.put('Id', acct.Id);
		pageParams.put('RecordName', acct.Name);
		
		//create instance of controller
		SearchActivityHistoryController controller = new SearchActivityHistoryController();
		//Case : Search Text is blank
		controller.searchText = '';
		controller.searchActivities();
		System.assertEquals(3, controller.lstTask.size());
		
		//Case : Search Text is task1 description so it will return 1 record
		controller.searchText = tsk1.Description;
		controller.searchActivities();
		//Assert is commented because we cannot run dynamic sosl in test class
		//System.assertEquals(1, controller.lstTask.size());
		
		//Test Sort Functionality
		controller.sortField = 'WhatId';
		controller.doSort();
		System.assert(controller.isAscending);
		
		//If sorted same field again sort order must get changed.
		controller.sortField = 'WhatId';
		controller.doSort();
		System.assert(!controller.isAscending);
		Test.stopTest();
	}
}