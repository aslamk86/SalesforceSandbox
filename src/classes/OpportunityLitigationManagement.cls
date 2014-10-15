public without sharing class OpportunityLitigationManagement {
	/*
	Fetch related litigation and fetch all families related to litigation
	
	*/
  public static void afterOpportunityLitigationInsert(Map<Id, Opportunity_Litigation__c> mapOppLitigation) {
    Set<Id> acqIds = new Set<Id>();
    for (Opportunity_Litigation__c oppLit : mapOppLitigation.values()) {
    	acqIds.add(oppLit.Acquisition_Opportunity__c);
    }
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
    
  }
  
  public static void afterOpportunityLitigationUpdate(Map<Id, Opportunity_Litigation__c> mapOldOppLitigation, Map<Id, Opportunity_Litigation__c> mapOppLitigation) {
    Set<Id> litigationIds = new Set<Id>();
    Set<Id> acqIds = new Set<Id> ();
    for (Opportunity_Litigation__c oppLit : mapOppLitigation.values()) {
    	if(oppLit.Litigation__c != null && oppLit.Litigation__c != mapOldOppLitigation.get(oppLit.Id).Litigation__c ) {
        litigationIds.add(oppLit.Litigation__c);
      }
      
      if(oppLit.Acquisition_Opportunity__c != mapOldOppLitigation.get(oppLit.Id).Acquisition_Opportunity__c ) {
        if(oppLit.Acquisition_Opportunity__c != null) {
          acqIds.add(oppLit.Acquisition_Opportunity__c);
        }
        if(mapOldOppLitigation.get(oppLit.Id).Acquisition_Opportunity__c != null) {
        	acqIds.add(mapOldOppLitigation.get(oppLit.Id).Acquisition_Opportunity__c);
        }
      }
    }
    acqIds.addAll(AcquisitionOpportunityUtility.getAcqOppForLitigation(litigationIds));
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
  }
  
  public static void afterOpportunityLitigationDelete(Map<Id, Opportunity_Litigation__c> mapOppLitigation) {
    Set<Id> acqIds = new Set<Id>();
    for (Opportunity_Litigation__c oppLit : mapOppLitigation.values()) {
      acqIds.add(oppLit.Acquisition_Opportunity__c);
    }
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
  } 
  
}