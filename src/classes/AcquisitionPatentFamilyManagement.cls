//Purpose : update Summary Fields and rollup fields on Acquisition Opportunity.
public without sharing class AcquisitionPatentFamilyManagement {
  
  public static void afterAcquisitionPatentFamilyInsert(List<Acquisition_Patent_Families__c> lstAcqpf) {
    Set<Id> acqIds = new Set<Id> ();
    for (Acquisition_Patent_Families__c acqPf : lstAcqpf) {
      acqIds.add(acqPf.Acquisition_Opportunity__c);
    }
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
    updateRollUpFields(acqIds, null);
  }
  
  public static void afterAcquisitionPatentFamilyUpdate(Map<Id, Acquisition_Patent_Families__c> newAcqPfMap, Map<Id, Acquisition_Patent_Families__c> oldAcqPfMap) {
    Set<Id> acqIds = new Set<Id>();
    Set<Id> acqIdsfamilyChanged = new Set<Id> ();
    for (Acquisition_Patent_Families__c acqPf : newAcqPfMap.values()) {
      if(AcquisitionOpportunityUtility.isNewOrChanged(acqPf, oldAcqPfMap, 'Acquisition_Opportunity__c') 
        || AcquisitionOpportunityUtility.isNewOrChanged(acqPf, oldAcqPfMap, 'Patent_Family__c')) {
      	acqIds.add(acqPf.Acquisition_Opportunity__c);
      }
    }
    
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
    updateRollUpFields(acqIds, null);
  }
  
  public static void afterAcquisitionPatentFamilyDelete(Map<Id, Acquisition_Patent_Families__c> oldAcqPfMap) {
    Set<Id> acqIds = new Set<Id>();
    for (Acquisition_Patent_Families__c acqPf : oldAcqPfMap.values()) {
      acqIds.add(acqPf.Acquisition_Opportunity__c);
    }
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
    updateRollUpFields(acqIds, null);
  }
  
  //----------------------------------------------------------------------------
  //update Roll up fields on Acquisition Opportunity
  //----------------------------------------------------------------------------
  public static void updateRollUpFields(Set<Id> acqOppIds, Set<Id> pfToExclude) {//List<Acquisition_Patent_Families__c> lstAPF) {
  	Map<Id, Set<Id>> acqOppAndFamilyMap = AcquisitionOpportunityUtility.getOMAAcqOppFamilyMap(acqOppIds);
  	Set<Id> allFamilyIds = getAllFamilyIds(acqOppAndFamilyMap);
  	Map<Id, Assets__c> patentFamilyMap = AcquisitionOpportunityUtility.getPatentFamilyMap(allFamilyIds);
  	
  	//update Acquisition Opportunity rollup fields
  	List<Acquisition_Opportunity__c> lstAcqOppToUpdate = new List<Acquisition_Opportunity__c>();
  	
  	for(Id acqOppId : acqOppIds) {
  		
			Acquisition_Opportunity__c acqOpp = new Acquisition_Opportunity__c(id = acqOppId);
			
			Decimal No_of_US_Patents = 0;
			Decimal No_of_US_Applications = 0;
			Decimal No_of_Non_US_Patents = 0;
			Decimal No_of_Non_US_Applications = 0;
			
			if(acqOppAndFamilyMap.containsKey(acqOppId)) {
				for(Id pfId : acqOppAndFamilyMap.get(acqOppId)) {
					if(pfToExclude == null || !pfToExclude.contains(pfId)) {
						if(patentFamilyMap.containsKey(pfId)) {
							Assets__c pf = patentFamilyMap.get(pfId);
						  
						  No_of_US_Patents += (pf.Number_of_US_Patents__c == null ? 0 : pf.Number_of_US_Patents__c); 
		          		  No_of_US_Applications += (pf.Number_of_US_Applications__c == null ? 0 : pf.Number_of_US_Applications__c);
						  No_of_Non_US_Patents += (pf.No_of_Non_US_Patents__c == null ? 0 : pf.No_of_Non_US_Patents__c);
						  No_of_Non_US_Applications += (pf.No_of_Non_U_S_Applications__c == null ? 0 : pf.No_of_Non_U_S_Applications__c);
						}
					}
				}
			}
			acqOpp.No_of_US_Patents_Roll_Up__c = No_of_US_Patents;
      acqOpp.No_of_US_Applications_Roll_Up__c = No_of_US_Applications;
			acqOpp.No_of_Non_US_Patents_Roll_Up__c = No_of_Non_US_Patents;
			acqOpp.No_of_Non_US_Applications_Roll_Up__c = No_of_Non_US_Applications;
			 
			lstAcqOppToUpdate.add(acqOpp);
    }
  	update lstAcqOppToUpdate;
  }
  
  //----------------------------------------------------------------------------
  //Loop through map and return list of all patent families
  //----------------------------------------------------------------------------
  private static Set<Id> getAllFamilyIds(Map<Id, Set<Id>> acqOppAndFamilyMap) {
  	Set<Id> allFamilyIds = new Set<Id>();
  	for(Set<Id> familyIds : acqOppAndFamilyMap.values()) {
  		allFamilyIds.addAll(familyIds);
  	}
  	return allFamilyIds;
  }
  
}