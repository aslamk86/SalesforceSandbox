/****************************************************************************************************************************
 * Name             : LitigationManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 13 Apr, 2012.
 * Purpose          : Management class for Litigation Trigger
****************************************************************************************************************************/

public without sharing class LitigationManagement {

// --- START NO LONGER NEEDED AUG 09, 2012 ----------------------------------------------
//
// Martin Sieler: no longer needed! New functionality for Litigation Count on Accounts
//

	public static void DoNothing()
		{
		integer i = 77;
		}

/*

	//-------------------------------------------------------------------------------------------------------------------------
	//Executes after update of Litigation
	//-------------------------------------------------------------------------------------------------------------------------
	public static void afterLitigationUpdate(List<Litigation__c> lstLitigation, Map<Id, Litigation__c> oldMap) {
		updateLitRollupFieldsOnAccount(lstLitigation, oldMap);
	}
	
	//-------------------------------------------------------------------------------------------------------------------------
	//Updating defendants related to litigation and this will update counts on Account (Defendent Trigger)
	//-------------------------------------------------------------------------------------------------------------------------
	public static void updateLitRollupFieldsOnAccount(List<Litigation__c> lstLitigation, Map<Id, Litigation__c> oldMap) {
		//preparing set of litigationIds that have modified value in Filed__c field.
		Set<Id> litigationIds = new Set<Id>();
 		for(Litigation__c lit : lstLitigation) {
 			if(AcquisitionOpportunityUtility.isNewOrChanged(lit, oldMap, 'Filed__c')) {
 				litigationIds.add(lit.Id);
 			}
		}
		
		//fetching all defendants related to litigations
		List<Defendant__c> lstDefendants = [Select id from Defendant__c Where litigation_ID__c in :litigationIds];
		if(!lstDefendants.isEmpty()) {
			//updating defendant will update litigaiton counts on Account.
			update lstDefendants;
		}
	}

*/    
// --- END NO LONGER NEEDED -------------------------------------------------------------

}