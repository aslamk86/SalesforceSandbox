/****************************************************
    Built by Hank Ryan Thompson.
    Created 10/29/2013.
    Last updated 10/29/2013 by Hank.
   
    Business logic for triggers is contained in
    RelevantCompanyManagement.cls
****************************************************/

trigger PotentiallyRelevantCompanyTrigger on Potentially_Relevant_Company__c (before insert, before update) {
   
    system.debug( '###PotentiallyRelevantCompanyTrigger: Entering trigger.###' );
    
    Potentially_Relevant_Company__c[] prcRecordsWithChangedFamilies = new Potentially_Relevant_Company__c[]{};
    
    if (trigger.isBefore) { 
        if (trigger.isInsert)
            for (Potentially_Relevant_Company__c prc:Trigger.new)
                if (prc.Core_Patent_Family_Id__c != null)
                    prcRecordsWithChangedFamilies.add(prc);
        
        if (trigger.isUpdate) 
            for (Potentially_Relevant_Company__c prc:Trigger.new)
                if ((prc.Core_Patent_Family_Id__c != null) && Trigger.oldMap.containsKey(prc.Id) && (Trigger.oldMap.get(prc.Id).Core_Patent_Family_Id__c != prc.Core_Patent_Family_Id__c))
                    prcRecordsWithChangedFamilies.add(prc);
    }
    
    if (prcRecordsWithChangedFamilies.size() > 0)
        RelevantCompanyManagement.updatePatentFamilies(prcRecordsWithChangedFamilies);
   
    system.debug( '###PotentiallyRelevantCompanyTrigger: Exiting trigger.###' );
   
}