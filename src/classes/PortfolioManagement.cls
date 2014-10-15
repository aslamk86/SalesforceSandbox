/*****************************************************************************
 * Name             : PortfolioManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Jan, 2012.
 * Purpose          : Class contains trigger functions for Portfolio(Assets__c) Object
 *                    T-21599
*****************************************************************************/
public without sharing class PortfolioManagement {
  
  //-------------------------------------------------------------------------------------------------------------------------------
  //Executes After Patent Family Update
  //-------------------------------------------------------------------------------------------------------------------------------
  public static void afterPortfolioUpdate(Map<Id,Assets__c> portfolioMap,Map<Id,Assets__c> oldPortfolioMap) {
    updatePatentsAssignmentNote(portfolioMap, oldPortfolioMap);
    updateRelatedAcqOppRollupFields(portfolioMap, oldPortfolioMap);
    
    updateAcqOppSummaryFields(portfolioMap, oldPortfolioMap);
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------
  //Executes Before Patent Family Update
  //-------------------------------------------------------------------------------------------------------------------------------
  public static void beforePortfolioDelete(Map<Id,Assets__c> ptFamilyOldMap) {
  	Set<Id> patentFamilyIds = ptFamilyOldMap.keySet();
    Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForPatentFamily(patentFamilyIds);
    AcquisitionPatentFamilyManagement.updateRollUpFields(acqIds, ptFamilyOldMap.keySet());
    AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, patentFamilyIds);
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------
  // Update the Assignment Note on all Patents associated to that Portfolio 
  // if the “Populate on All Patents in Portfolio” is checked, 
  // and the user changes “Assignment Note” on Portfolio.
  //-------------------------------------------------------------------------------------------------------------------------------
  private static void updatePatentsAssignmentNote(Map<Id,Assets__c> portfolioMap, Map<Id,Assets__c> oldPortfolioMap) {
    Set<Id> assetIdsToUpdt = new Set<Id>();
    for (Assets__c asset : portfolioMap.Values()) {
      
      if(asset.Populate_on_All_Patents_in_Portfolio__c 
        && (AcquisitionOpportunityUtility.isNewOrChanged(asset, oldPortfolioMap, 'Populate_on_All_Patents_in_Portfolio__c') 
            ||AcquisitionOpportunityUtility.isNewOrChanged(asset, oldPortfolioMap, 'Assignment_Note__c')
           )  
        ) {
        assetIdsToUpdt.add(asset.Id);
      }
    }
    
    List<Patent__c> lstPatentsToUpdt = new List<Patent__c>(); 
    for (Patent__c  pt : [Select Id, Patent_Family__c 
										      From Patent__c 
										      Where Patent_Family__c in :assetIdsToUpdt]) {
      Assets__c pf = portfolioMap.get(pt.Patent_Family__c); 
      Patent__c patent = new Patent__c(Id = pt.Id);
      patent.Assignment_Note__c = pf.Assignment_Note__c;
      patent.Assignment_Note_by__c = UserInfo.getUserId();
      patent.Assignment_Note_Date__c = DateTime.now();
      lstPatentsToUpdt.add(patent);
    }
    update lstPatentsToUpdt;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------
  //UpdateAcquisitionSummaryFields
  //-------------------------------------------------------------------------------------------------------------------------------
  private static void updateAcqOppSummaryFields(Map<Id,Assets__c> ptFamilyMap, Map<Id,Assets__c> ptFamilyOldMap) {
  	Set<Id> patentFamilyIds = new Set<Id>();
  	Assets__c blankPatentFamily = new Assets__c();
  	Assets__c oldPatentFamily;
  	
  	for (Assets__c pf:ptFamilyMap.values()) {
  	  oldPatentFamily = ptFamilyOldMap.get(pf.Id);
  	  if (oldPatentFamily == null) oldPatentFamily = blankPatentFamily;
  	  
      if ( (pf.Summary__c != oldPatentFamily.Summary__c)
        || (pf.Representative_Claims__c != oldPatentFamily.Representative_Claims__c)
        || (pf.Earliest_priority__c != oldPatentFamily.Earliest_priority__c)
        || (pf.Expiration_Date__c != oldPatentFamily.Expiration_Date__c)
        || (pf.Characterization_of_Claims__c != oldPatentFamily.Characterization_of_Claims__c)
        )
  	  	      patentFamilyIds.add(pf.Id);
  	}
  	//fetch relatedAcquisition Opportunities
  	if (patentFamilyIds.size() > 0) {
	  	Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForPatentFamily(patentFamilyIds);
	  	AcquisitionOpportunityUtility.updateAcquisitionSummaryFields(acqIds, null);
  	}
  }
  
  //-------------------------------------------------------------------------------------------------------------------------------
  //Update Acquisition Opportunity Roll up Fields
  //-------------------------------------------------------------------------------------------------------------------------------
  private static void updateRelatedAcqOppRollupFields(Map<Id,Assets__c> ptFamilyMap, Map<Id,Assets__c> ptFamilyOldMap) {
    Set<Id> patentFamilyIds = new Set<Id>();
    for (Assets__c pf : ptFamilyMap.values()) {
      if ( AcquisitionOpportunityUtility.isNewOrChanged(pf, ptFamilyOldMap, 'No_of_Non_US_Patents__c')
        || AcquisitionOpportunityUtility.isNewOrChanged(pf, ptFamilyOldMap, 'No_of_Non_U_S_Applications__c')
        || AcquisitionOpportunityUtility.isNewOrChanged(pf, ptFamilyOldMap, 'Number_of_US_Patents__c')
        || AcquisitionOpportunityUtility.isNewOrChanged(pf, ptFamilyOldMap, 'Number_of_US_Applications__c')
        ) {
        patentFamilyIds.add(pf.Id);
      }
    }
    //fetch relatedAcquisition Opportunities
    if (patentFamilyIds.size() > 0) {
	    Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForPatentFamily(patentFamilyIds);
	    AcquisitionPatentFamilyManagement.updateRollUpFields(acqIds, null);
    }
  }
  
}