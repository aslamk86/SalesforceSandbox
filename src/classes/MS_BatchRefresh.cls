/*
    Class        : MS_BatchRefresh
    Description  : Non-destructively update / set Refresh flag for various objects
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

global class MS_BatchRefresh implements Database.Batchable<sObject>, Database.Stateful
	{
	//-------------------------------------------------------------------------------------------------------------------------
	// add objects with a "Refresh" field below
	//-------------------------------------------------------------------------------------------------------------------------
  private static final Set<String> ObjectsWithRefresh = new Set<String>
  	{
  	'account',
  	'acquisition_opportunity__c',
  	'litigation__c'
  	};

	private integer i;
  private String  sObjectName;

	//-------------------------------------------------------------------------------------------------------------------------
	// MS_BatchRefresh - constructor
	//-------------------------------------------------------------------------------------------------------------------------
  global MS_BatchRefresh(String sObjectName)
  	{
  	System.debug(MS_Tools.Debug, 'MS_BatchRefresh - Batch Process Starting (' + sObjectName + ')');
  	
		i = 0;
		this.sObjectName = sObjectName;
  	}
 
	//-------------------------------------------------------------------------------------------------------------------------
	// start
	//-------------------------------------------------------------------------------------------------------------------------
  global Database.QueryLocator start(Database.BatchableContext BC)
  	{
  	String query;

		if (ObjectsWithRefresh.contains(sObjectName.toLowerCase()))
	    query = 'SELECT Id, Refresh__c FROM ' + sObjectName;
		else
	    query = 'SELECT Id FROM ' + sObjectName;

    return Database.getQueryLocator(query);  
  	}
 
	//-------------------------------------------------------------------------------------------------------------------------
	// execute
	//-------------------------------------------------------------------------------------------------------------------------
  global void execute(Database.BatchableContext BC, List<sObject> scope)
  	{
    System.debug(MS_Tools.Debug, 'MS_BatchRefresh - Batch Process Updating ' + scope.Size() + ' \'' + sObjectName + '\' objects');
		this.i += scope.Size();

		if (ObjectsWithRefresh.contains(sObjectName.toLowerCase()))
			{
			for (sObject s : scope)
				s.put('Refresh__c', true);
			}

		update scope;    
		}
 
	//-------------------------------------------------------------------------------------------------------------------------
	// finish
	//-------------------------------------------------------------------------------------------------------------------------
  global void finish(Database.BatchableContext BC)
  	{
    System.debug(MS_Tools.Debug, 'MS_BatchRefresh - Batch Process Complete (' + this.i + ' \'' + sObjectName + '\' objects refreshed)');
    
		// Get the ID of the AsyncApexJob representing this batch job 
		// from Database.BatchableContext. 
		// Query the AsyncApexJob object to retrieve the current job's information. 
    
		AsyncApexJob a = [SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed,
		                  TotalJobItems, CreatedBy.Email
		                  FROM AsyncApexJob WHERE Id = :BC.getJobId()];

		// Send an email to the Apex job's submitter notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('MS_BatchRefresh (' + sObjectName + '): ' + a.Status);
		mail.setPlainTextBody
			('The batch Apex job processed ' + a.TotalJobItems +
			' batches ' + '(' + i + ' \'' + sObjectName + '\' objects) with '+ a.NumberOfErrors + ' failures.' +
			'\n\n' + a);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

/*

To run the code, open up the Debug Log and run this...
	
MS_BatchRefresh batch = new MS_BatchRefresh(<object name>);
Id batchId = Database.executeBatch(batch);

*/