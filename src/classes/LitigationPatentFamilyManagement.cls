public without sharing class LitigationPatentFamilyManagement {
  
   public static void afterLitigationPatentFamilyDelete(Map<Id, Litigation_Patent_Family__c> oldLitPfMap) {
   	
    Set<Id> litigationIds = new Set<Id> ();
    for (Litigation_Patent_Family__c litPf : oldLitPfMap.values()) {
      litigationIds.add(litPf.Litigation__c);
    }
    Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForLitigation(litigationIds);
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
  }
  
  public static void afterLitigationPatentFamilyInsert(List<Litigation_Patent_Family__c> lstLitPatentFamilies) {
    Set<Id> litigationIds = new Set<Id>();
    for (Litigation_Patent_Family__c litPf : lstLitPatentFamilies) {
      litigationIds.add(litPf.Litigation__c);
    }
    Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForLitigation(litigationIds);
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
  }
  
  public static void afterLitigationPatentFamilyUpdate(List<Litigation_Patent_Family__c> lstLitPatentFamilies, Map<Id, Litigation_Patent_Family__c> mapOldLitigationFamilies) {
    Set<Id> litigationIds = new Set<Id>();
    for (Litigation_Patent_Family__c litPf : lstLitPatentFamilies) {
    	if(litPf.Litigation__c != mapOldLitigationFamilies.get(litPf.Id).Litigation__c) {
    		if(litPf.Litigation__c != null) {
          litigationIds.add(litPf.Litigation__c);
    		}
        if(mapOldLitigationFamilies.get(litPf.Id).Litigation__c != null) {
          litigationIds.add(mapOldLitigationFamilies.get(litPf.Id).Litigation__c);
        }
    	}
    }
    Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForLitigation(litigationIds);
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
  }
  
}