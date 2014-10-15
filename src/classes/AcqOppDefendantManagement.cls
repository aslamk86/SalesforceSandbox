/*****************************************************************************
 * Name             : AcqOppDefendantManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 05 Apr, 2012.
 * Purpose          : AcquisitionOpportunityDefendantTrigger Management Class
*****************************************************************************/
public with sharing class AcqOppDefendantManagement {
	
	//--------------------------------------------------------------------------------------------------------------
	//Execute before insert of Acquisition_Opportunity_Defendant__c record.
	//--------------------------------------------------------------------------------------------------------------
	public static void beforeAcqOppDefendantInsert(List<Acquisition_Opportunity_Defendant__c> lstAcqOppDefendants) {
		populateAccountLookupField(lstAcqOppDefendants);
	}
	
	//--------------------------------------------------------------------------------------------------------------
	//Execute before update of Acquisition_Opportunity_Defendant__c record.
	//--------------------------------------------------------------------------------------------------------------
	public static void beforeAcqOppDefendantUpdate(List<Acquisition_Opportunity_Defendant__c> lstAcqOppDefendants) {
		populateAccountLookupField(lstAcqOppDefendants);
	}
	
	
	//----------------------------------Utility Methods------------------------------------------------
	
	//-------------------------------------------------------------------------------------------------
	//Set Defendant's Account value in Account Lookup Field   
	//-------------------------------------------------------------------------------------------------
	private static void populateAccountLookupField(List<Acquisition_Opportunity_Defendant__c> lstAcqOppDefendants) {
		Set<Id> defendantIds = new Set<Id> ();
		for (Acquisition_Opportunity_Defendant__c acqOppDef : lstAcqOppDefendants) {
			if(acqOppDef.Defendant__c != null) {
				defendantIds.add(acqOppDef.Defendant__c);
			}
		}
		Map<Id, Defendant__c> mapDefendant = getDefendantMap(defendantIds);
		for (Acquisition_Opportunity_Defendant__c acqOppDef : lstAcqOppDefendants) {
			if(acqOppDef.Defendant__c != null && mapDefendant.containsKey(acqOppDef.Defendant__c)) {
				acqOppDef.Account_Lookup__c = mapDefendant.get(acqOppDef.Defendant__c).Account__c;
			} else {
				acqOppDef.Account_Lookup__c = null;
			}
		}
	}
	
	//-------------------------------------------------------------------------------------------------
	//Returns Defendant Map as per given defendant ids
	//-------------------------------------------------------------------------------------------------
	private static Map<Id, Defendant__c> getDefendantMap(Set<Id> defendantIds) {
		//Query Defendant Account Name
		return (new Map<Id, Defendant__c> ([ Select id, Account__c From Defendant__c Where id in : defendantIds]));
	}
	
}