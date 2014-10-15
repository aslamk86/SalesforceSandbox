/******************************************************************************************
   
    SYNC ENGINE CHANGE PROCESSOR
    
    Built by Hank Ryan Thompson.
    Created 7/1/2013.
    Last updated 11/19/2013 by Hank.
    
    This is a batch process that queries Core API for one page of changes from a single
    change endpoint. It then iterates through those changes in batches, passing them to
    SyncEngine.processChanges(). Usually there should be 4 independent change processor
    instances operating in parallel, one for each of the changes endpoints.
    
    Any errors that occur during the sync process for a particular endpoint will cause
    the processor (for that endpoint only) to get "stuck" and continue to try again every
    run interval until the error is cleared.
    
    HOW TO MONITOR THE PROCESSOR JOBS
     - The current status of each processor is stored in fields on the custom settings
       records (Setup > Develop > Custom Settings > Core API Endpoint > Manage). 
     - While actively processing a batch, each processor will have an active Apex Job
       (Setup > Monitoring > Apex Jobs).
     - While dormant in between batches each processor will have a Scheduled Job
       (Setup > Monitoring > Scheduled Jobs).
    
    TO START AND STOP THE PROCESSOR
     1) Open the Developer Console by clicking your name in the upper right corner of the 
        Salesforce window and selecting "Developer Console".
     2) Open the Execute Anonymous Window by pressing CTRL+E.
     3) Call the start or stop processor method by typing in the example code below with
        the desired endpoint name and then pressing the "Execute" button: 
         - SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.TechTagChanges);
         - SyncEngineChangeProcessor.stopProcessor(CoreAPI.EndpointName.TechTagChanges);
         - NOTE: The available endpoints are listed in the CONSTANTS & ENUMS section below.
    
    
******************************************************************************************/


global class SyncEngineChangeProcessor implements Database.batchable<SyncEngine.ChangeRow>, Database.Stateful, Database.AllowsCallouts {
    
     /*=== CONSTANTS & ENUMS ===*/
    
    /*
        ADMIN NOTE: When adding a new *CoreObject* that syncs, you'll need to add the endpoint to BOTH of the constant maps below (pageSizeMap & batchSizeMap).
    */
    
    // How many change records to we query at a time? (Effects the governor limits on the start function)
    // WARNING: Do not set this to more than 10,000 or there will be too many log items to delete during the finish() function and they will pile up.
    global static Map<CoreAPI.EndpointName, Integer> pageSizeMap = new Map<CoreAPI.EndpointName, Integer> {
        CoreAPI.EndpointName.ClaimChartedCompanyChanges => 5000,
        CoreAPI.EndpointName.LicenseeChanges => 5000,
        CoreAPI.EndpointName.PatentAnnotationChanges => 5000,
        CoreAPI.EndpointName.PatentFamilyChanges => 5000,
        CoreAPI.EndpointName.PortfolioAnnotationChanges => 5000,
        CoreAPI.EndpointName.RelevantCompanyChanges => 5000,
        CoreAPI.EndpointName.TechTagChanges => 5000    
    };
    
    // How many change rows do we process in each execute() batch? (Effects the governor limits on the execute function)
    global static Map<CoreAPI.EndpointName, Integer> batchSizeMap = new Map<CoreAPI.EndpointName, Integer> {
        CoreAPI.EndpointName.ClaimChartedCompanyChanges => 500,
        CoreAPI.EndpointName.LicenseeChanges => 500,
        CoreAPI.EndpointName.PatentAnnotationChanges => 500,
        CoreAPI.EndpointName.PatentFamilyChanges => 50,
        CoreAPI.EndpointName.PortfolioAnnotationChanges => 500,
        CoreAPI.EndpointName.RelevantCompanyChanges => 500,
        CoreAPI.EndpointName.TechTagChanges => 500    
    };
    
    // SYNC-BEHAVIOR CONSTANTS
    global static Integer SYNC_FREQUENCY_MINUTES = 3; // How many minutes in between check-ins to each changes endpoint?
    global static Integer SYNC_OVERLAP_SECONDS = 1; // How many seconds should the getChanges() function subtract when recording the Last Sync Date Time?
    // The above constant provides some overlap to avoid missed changes. WARNING: Don't set it to higher than the frequency of the check-ins! 
    global static Integer CHANGE_ITEM_HISTORY_SIZE = 5000; // Controls the max count of Sync_Engine_Change_Item__c records stored in Salesforce (for EACH endpoint)
    global static String SYNC_JOB_NAME = 'Sync Engine Change Processor';
    global static Integer BAD_API_RESPONSE_RETRY_ATTEMPTS = 5; // how many times will the start() function retry the API before failing?
    
    
    /*=================== CONTROL FUNCTIONS ====================*/
    /*=== (Use these to stop and start the change processor) ===*/
    
    
    global static String startProcessor(CoreAPI.EndpointName theEndpoint) {
        // Call this function to start up a new change processor for the specified endpoint.
        // NOTE: Once you start the process it will continue polling the specified endpoint
        //       every SYNC_FREQUENCY_MINUTES until it is manually stopped.
        //
        // EXAMPLE USAGE: (Enter everything after ">>" into the developer console.)
        //  >> SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.PatentAnnotationChanges); 
        
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.startProcessor(): Running with theEndpoint = ' + theEndpoint.name() + '.###');
        
        String runningJobId; String scheduledJobId;
        
        // First check to see if there's already a processor scheduled to run (this is just for warning purposes, if 2 processes try to run the second will just issue an exception and shut down)
        scheduledJobId = getScheduledJobId(theEndpoint);
        if (scheduledJobId != null) system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.startProcessor(): WARNING! It looks like there is already another change processor scheduled to check this endpoint soon (scheduledJobId = ' + scheduledJobId + '). This may result in an error message when it tries to run. This is just a warning. Continuing anyway...###');
        
        // Now fire up a new batch (NOTE: If there is already another job running this will result in an exception)
        runningJobId = Database.executeBatch(new SyncEngineChangeProcessor(theEndpoint), batchSizeMap.get(theEndpoint));
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.startProcessor(): New batch process started. (runningJobId = ' + runningJobId + ')###');
        return runningJobId;
    }
    
    global static String stopProcessor(CoreAPI.EndpointName theEndpoint) {
        // Call this function to shut down the currently running change processor for the specified endpoint.
        //
        // EXAMPLE USAGE: (Enter everything after ">>" into the developer console.)
        //  >> SyncEngineChangeProcessor.stopProcessor(CoreAPI.EndpointName.PatentAnnotationChanges); 
        
        system.debug('###SyncEngineChangeProcessor.stopProcessor(): Entering with theEndpoint = ' + theEndpoint.name() + '.###');
        
        String runningJobId; String scheduledJobId;
        
        // Get the job ids
        runningJobId = getRunningJobId(theEndpoint);
        scheduledJobId = getScheduledJobId(theEndpoint);
        
        if (runningJobId != null) {
            system.debug('###SyncEngineChangeProcessor.stopProcessor(): Running Change Processor found with runningJobId = ' + runningJobId + '. Updating custom setting with Sync is Stopping. Sync will stop after this run is complete.###');
            setSyncIsStopping(theEndpoint, true);
            return runningJobId;
        } else if (scheduledJobId != null) {
            system.debug('###SyncEngineChangeProcessor.stopProcessor(): Scheduled Change Processor found with scheduledJobId = ' + scheduledJobId + '. Now attempting to stop it...###');
            try {
                System.abortJob(scheduledJobId);
                system.debug('###SyncEngineChangeProcessor.stopProcessor(): Scheduled batch process successfully aborted.###');
            } catch(Exception e) {
                system.debug('###SyncEngineChangeProcessor.stopProcessor(): WARNING! The scheduledJobId was invalid. The invalid scheduledJobId will now be cleared from the setting record.###');
            }
            setScheduledJobId(theEndpoint, null);            
            return scheduledJobId;
        } else {
            system.debug('###SyncEngineChangeProcessor.stopProcessor(): ERROR! There are currently no Change Processor running or scheduled to run for the ' + theEndpoint.name() + ' endpoint.###');
            return null;
        }
    }
    
    
    /*=== STATE VARS ===*/
    
    global CoreAPI.EndpointName theEndpoint;
    global SyncEngine.ChangeQueue theQueue;
    global DateTime fromDateTime;
    global Integer pageNumber;
    global Integer nextPageNumber;
    global DateTime startTime;
    global Id myId;
    global Exception[] errorsEncountered;
    
    
    
    /*=== INNER EXCEPTION CLASS ===*/
    
    public class ChangeProcessorException extends Exception {
        public String errorType; // 'ERROR', 'INFO'
        public ChangeProcessorException(String errorMessage, String errorType) { this.setMessage(errorMessage); this.errorType = errorType; }
    }
    
    
    
    /*=== INSTANCE FUNCTIONS ===*/
    
    global SyncEngineChangeProcessor(CoreAPI.EndpointName theEndpoint) {
        system.debug('###SyncEngineChangeProcessor(): Constructor running with theEndpoint = ' + theEndpoint.name() + '.###');
        
        this.theEndpoint = theEndpoint;
        errorsEncountered = new Exception[]{};
    }
    
    global Iterable<SyncEngine.ChangeRow> start(Database.batchableContext info) {
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.start(): Running with theEndpoint = ' + theEndpoint.name() + '.###');
        
        SyncEngine.ChangeRow[] changeRows;
        String runningJobId;
        AsyncApexJob[] runningJobs;
        Integer apiAttempts = 0;
        
        startTime = DateTime.now();
        
        // First make sure that we're being called with an acceptable endpoint
        if (!pageSizeMap.containsKey(theEndpoint) || !batchSizeMap.containsKey(theEndpoint))
            throw new ChangeProcessorException('Unsupported endpoint for Sync Engine Change Processor. (' + theEndpoint.name() + ')', 'ERROR');
        
        // Make sure there's not another process running
        runningJobId = getRunningJobId(theEndpoint);
        if (runningJobId != null) { // validate that it's still running
            runningJobs = [select Id, Status from AsyncApexJob where Id=:runningJobId and Status not in ('Failed', 'Completed', 'Aborted')];
            
            if (runningJobs.size() > 0) throw new ChangeProcessorException('Another Change Processor is already running for this endpoint. (Running Job Id = ' + runningJobId + ')', 'ERROR');
            else runningJobId = null; // the old job must have errored out
        }
        
        do {
	        try {
		        errorsEncountered = new Exception[]{}; // this variable is used to track when an error occurs in this start() method - this allows the finish() method to reschedule
		        apiAttempts++;
		        
		        // Retrieve the page info and query the api
		        fromDateTime = getLastSyncDateTime(theEndpoint);
		        pageNumber = getNextSyncPage(theEndpoint);
		        changeRows = SyncEngine.getChanges(theEndpoint, pageSizeMap.get(theEndpoint), fromDateTime, pageNumber);
		        
		        // Now update the custom setting (put it into RUNNING mode)
		        // NOTE: We have to do this AFTER the callout or we get an error
		        if (info == null) myId = '01I400000006XPQ'; //for testmethods only
		        else myId = info.getJobId();
		        setRunningJobId(theEndpoint, myId);
		        setScheduledJobId(theEndpoint, null);
		        
		        // Extract the next page number 
		        if (changeRows.size() > 0) nextPageNumber = changeRows[0].resultsNextPageNumber; 
		        else nextPageNumber = null;
		        
		        // Compress the rows and build the return queue
		        changeRows = SyncEngine.sortAndFilterChangeRowList(changeRows);
		        theQueue = new SyncEngine.ChangeQueue(changeRows);
	        } catch (Exception e) { 
	            // NOTE: We can't throw the exception in the start method since then we will not be able to reschedule the next run >> throwException(e, true); // this emails admins
	            // Instead we will store the exception for processing in the finish() function.
	            system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.start(): Error encountered during start, error message = ' + e.getMessage() + '.###');
	            errorsEncountered.add(e);
	            if (theQueue == null) theQueue = new SyncEngine.ChangeQueue(new SyncEngine.ChangeRow[]{});
	        }
        } while ((errorsEncountered.size() > 0) && (apiAttempts < BAD_API_RESPONSE_RETRY_ATTEMPTS));
        
        return theQueue;
    }
    
    global void execute(Database.batchableContext info, List<SyncEngine.ChangeRow> scope) {
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.execute(): Running with theEndpoint = ' + theEndpoint.name() + ', ' + scope.size() + ' change rows.###');
        
        Sync_Engine_Change_Item__c[] convertedChangeRows = new Sync_Engine_Change_Item__c[]{};
        SyncEngine.ChangeRow[] processedChangeRows; 
        String endpointURL;
        
        try {
	        // First run the processing function
	        processedChangeRows = SyncEngine.processChanges(scope);
	        
	        // Now convert the change rows to salesforce records and insert them
	        endpointURL = CoreAPI.getEndpointURL(theEndpoint);
	        for (SyncEngine.ChangeRow changeRow:processedChangeRows)
	            convertedChangeRows.add(changeRow.convertToSalesforceRecord(endpointURL));
	        
	        insert convertedChangeRows; // the converted rows provide an audit log
        } catch (Exception e) { 
            system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.execute(): Error encountered during batch, error message = ' + e.getMessage() + '.###');
            errorsEncountered.add(e);
        }
    }
    
    global void finish(Database.batchableContext info) {
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.finish(): Running with theEndpoint = ' + theEndpoint.name() + ', startTime = ' + startTime + ', stopTime = ' + DateTime.now() + ', duration (ms) = ' + (DateTime.now().millisecond() - startTime.millisecond()) + ', errorsEncountered = ' + errorsEncountered + '.###');
        
        Integer currentChangeItemCount; Integer changeItemOverCount;
        Integer remainingDMLRows;
        Sync_Engine_Change_Item__c[] changeItemsToDelete;
        String endpointURL;
        Boolean isStopping;
        
        // First we need to clear out old Sync_Engine_Change_Item__c records
        endpointURL = CoreAPI.getEndpointURL(theEndpoint);
        remainingDMLRows = Limits.getLimitDMLRows() - Limits.getDMLRows() - 10; //leave space for updating the setting records below
        currentChangeItemCount = [select count() from Sync_Engine_Change_Item__c where Endpoint__c=:endpointURL limit :remainingDMLRows];
        changeItemOverCount = currentChangeItemCount - CHANGE_ITEM_HISTORY_SIZE;
        system.debug('###SyncEngineChangeProcessor.finish(): changeItemOverCount = ' + changeItemOverCount + ', remainingDMLRows = ' + remainingDMLRows + '.###');
        /* HANK: I'm temporarily commenting this out to avoid the SFDC bug. (11/19/13)
	        if (changeItemOverCount > 0) {
	            try {
	                //NOTE: I moved the query into the try block because in production an error occured where the query took more than 2 minutes to run and caused the whole process to break. 
	                changeItemsToDelete = [select Id from Sync_Engine_Change_Item__c where Endpoint__c=:endpointURL order by CreatedDate ASC limit :currentChangeItemOverCount];
	                delete changeItemsToDelete;
	            } catch(Exception e) {system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.finish(): Error occurred while trying to delete extra change items. Error message = ' + e.getMessage() + '.###');}
	        }
	    */
        
        // Next we check if an error ocurred in one or more of the batches (or in the start method)
        if (errorsEncountered.size() > 0) { // Do not proceed to the next page (we are stuck until the error is cleared)
            system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.finish(): Sync is stuck!.###');
            setSyncIsStuck(theEndpoint, true);
        } else { // No errors, so we can update the page information...
	        if (nextPageNumber == null) fromDateTime = startTime;
	        setNextSyncPage(theEndpoint, nextPageNumber);
	        setLastSyncDateTime(theEndpoint, fromDateTime);
	        setSyncIsStuck(theEndpoint, false);
        }
        
        // Schedule the next run. (Check first to make sure that a stop hasn't been requested.)
        isStopping = getSyncIsStopping(theEndpoint);
        if ((isStopping == null) || (isStopping == false))
            scheduleNextRun();
        else {
            setSyncIsStopping(theEndpoint, false); // Clear the stop
            setRunningJobId(theEndpoint, null); // Clear the running id
            setScheduledJobId(theEndpoint, null); // Clear the scheduled id (just in case)
        }
        
        // Finally, if there were any exceptions encountered it's time to "throw" them (they are not actually thrown because it would roll back our next scheduled run).
        if (errorsEncountered.size() > 0) throwExceptions(errorsEncountered);
    }
    
    private void scheduleNextRun() {
        // Schedules a new instance of the batch process to run in X minutes
        // Then puts the custom setting into SCHEDULED mode
        // X is calculated based on SYNC_FREQUENCY_MINUTES and the current execution time
        // WARNING: Internal function only! Does not check for currently running/scheduled processes.
        
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.scheduleNextRun(): Entering function.###');
        
        Integer minutesUntilNextRun;
        String jobName; String jobNameSuffix = '';
        Integer attemptNumber = 1;
        String scheduledJobId = null;
        
        // Setup the calculated fields        
        jobName = SYNC_JOB_NAME + ' - ' + theEndpoint.name();
        minutesUntilNextRun = Math.max(1, (SYNC_FREQUENCY_MINUTES - Integer.valueOf((DateTime.now().getTime() - startTime.getTime())/60000)));
        // Notes about math above: This algorithm will ensure that the process runs once every SYNC_FREQUENCY_MINUTES. 
        //                         If we've already run for too long we will run again in 1 minute. 
        
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.scheduleNextRun(): Acout to try to schedule the next run with jobName = ' + jobName + ', theEndpoint = ' + theEndpoint + '.###');
        
        // Schedule the job and update the custom setting
        // NOTE: I was getting an error where the job name wouldn't work for certain endpoints even though nothing was scheduled. The code below will attempt 10 different job names before giving up.
        do {
	        try {
	            if (attemptNumber > 1) jobNameSuffix = ' ' + String.valueOf(attemptNumber);
	            scheduledJobId = System.scheduleBatch(new SyncEngineChangeProcessor(theEndpoint), jobName+jobNameSuffix, minutesUntilNextRun, batchSizeMap.get(theEndpoint));
	        } catch (Exception e) {
	            if (Test.isRunningTest()) scheduledJobId = '707e0000006XWAi'; // this probably means that there's already a scheduled task running... no reason to cause an error
	            else if (attemptNumber > 10) throw e;
	            else attemptNumber++;
	        }
        } while (scheduledJobId == null);
        
        setRunningJobId(theEndpoint, null);
        setScheduledJobId(theEndpoint, scheduledJobId);
        
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.scheduleNextRun(): Exiting function with scheduledJobId = ' + scheduledJobId + '.###');        
    }
    
    public void throwExceptions(Exception[] errors) {
        // This function emails admins about the errors which were encountered
        // NOTE: It does not actually throw the exceptions because that would reset the state and make it impossible to properly contain the functions. 
        
        system.debug(LoggingLevel.ERROR, '###SyncEngineChangeProcessor.throwException(): Entering function with errors = ' + errors + '.###');
        
        String emailSubject;
        String emailBody;
        
        // Build the base body of the email
        emailSubject = 'Sync Engine Change Processor Error (' + theEndpoint.name() + ')';
        emailBody = 'The batch process encountered ' + errors.size() + ' errors while processing changes from the ' + theEndpoint.name() + ' endpoint. \n';
        emailBody += 'NOTE: The Sync Engine Change Processor will continue to run every few minutes as usual, but it is possible that the processor may be "stuck". ';
        emailBody += 'If so the error will either need to be resolved or the next sync page field on the custom setting will need to be manually advanced to skip over the offending page of change rows.\n\n';
        emailBody += 'Endpoint URL: ' + CoreAPI.getEndpointURL(theEndpoint) + '\n\n';
        emailBody += 'Error Messages: \n'; 
        
        // Now run through and add the error messages to the email 
        for (Exception e:errors)
            emailBody += '\n--------------------\n\n' + e.getMessage() + '\n';
              
        // Send the email
        SyncEngine.sendEmailToAdmins(emailSubject, emailBody, null);
    }
    
    
    
    /*=== UTILITY FUNCTIONS ===*/
    
    
    global static String getScheduledJobId(CoreAPI.EndpointName theEndpoint) { return (String)getSettingFieldValue(theEndpoint, 'Sync_Scheduled_Job_Id__c'); }
    public static void setScheduledJobId(CoreAPI.EndpointName theEndpoint, String newValue) { setSettingFieldValue(theEndpoint, 'Sync_Scheduled_Job_Id__c', newValue); }
    
    global static String getRunningJobId(CoreAPI.EndpointName theEndpoint) { return (String)getSettingFieldValue(theEndpoint, 'Sync_Running_Job_Id__c'); }
    public static void setRunningJobId(CoreAPI.EndpointName theEndpoint, String newValue) { setSettingFieldValue(theEndpoint, 'Sync_Running_Job_Id__c', newValue); }
    
    global static DateTime getLastSyncDateTime(CoreAPI.EndpointName theEndpoint) {
        DateTime returnValue = (DateTime)getSettingFieldValue(theEndpoint, 'Last_Sync_Date_Time__c');
        if (returnValue == null) throw new ChangeProcessorException('Last_Sync_Date_Time__c cannot be null. Either there is no Core API Endpoint setting record created for this endpoint (' + theEndpoint.name() + ') OR the Last Sync Date Time field on the setting record is blank. The Sync Engine Change Processor cannot run.', 'ERROR');
        else return returnValue;
    }
    public static void setLastSyncDateTime(CoreAPI.EndpointName theEndpoint, DateTime newValue) { setSettingFieldValue(theEndpoint, 'Last_Sync_Date_Time__c', newValue); }
    
    global static Integer getNextSyncPage(CoreAPI.EndpointName theEndpoint) { return Integer.valueOf(getSettingFieldValue(theEndpoint, 'Next_Sync_Page__c')); }
    public static void setNextSyncPage(CoreAPI.EndpointName theEndpoint, Integer newValue) { setSettingFieldValue(theEndpoint, 'Next_Sync_Page__c', newValue); }
    
    global static Boolean getSyncIsStuck(CoreAPI.EndpointName theEndpoint) { return (Boolean)getSettingFieldValue(theEndpoint, 'Sync_is_Stuck__c'); }
    public static void setSyncIsStuck(CoreAPI.EndpointName theEndpoint, Boolean newValue) { setSettingFieldValue(theEndpoint, 'Sync_is_Stuck__c', newValue); }
    
    global static Boolean getSyncIsStopping(CoreAPI.EndpointName theEndpoint) { return (Boolean)getSettingFieldValue(theEndpoint, 'Sync_is_Stopping__c'); }
    public static void setSyncIsStopping(CoreAPI.EndpointName theEndpoint, Boolean newValue) { setSettingFieldValue(theEndpoint, 'Sync_is_Stopping__c', newValue); }
    
    private static Object getSettingFieldValue(CoreAPI.EndpointName theEndpoint, String fieldName) {
        CoreAPIAuthentication__c settingRecord = CoreAPIAuthentication__c.getValues(theEndpoint.name());
        
        if (settingRecord == null) return null;
        else return settingRecord.get(fieldName);
    }
    
    private static void setSettingFieldValue(CoreAPI.EndpointName theEndpoint, String fieldName, Object fieldValue) {
        CoreAPIAuthentication__c settingRecord = CoreAPIAuthentication__c.getValues(theEndpoint.name());
        
        if (settingRecord != null) {
            settingRecord.put(fieldName, fieldValue);
            update settingRecord;
        }
    }
    
}