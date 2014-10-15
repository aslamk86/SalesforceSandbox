/****************************************************************************************************************************
 * Name             : LitigationTrigger
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 13 Apr, 2012.
 * Purpose          : LitigationTrigger
****************************************************************************************************************************/
trigger LitigationTrigger on Litigation__c (after update) {

// --- START NO LONGER NEEDED AUG 09, 2012 ----------------------------------------------
//
// Martin Sieler: no longer needed! New functionality for Litigation Count on Accounts
//
/*

    if(Trigger.isAfter && Trigger.isUpdate)
    	{
      LitigationManagement.afterLitigationUpdate(Trigger.new, Trigger.oldMap); 
    	}

*/    
// --- END NO LONGER NEEDED -------------------------------------------------------------

	// we need test coverage for deployment
	integer i = Trigger.new.Size();

}