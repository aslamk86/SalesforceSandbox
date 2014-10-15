/****************************************************
    Built by Hank Ryan Thompson.
    Created 10/29/2013.
    Last updated 10/29/2013 by Hank.
   
    Business logic for triggers is contained in
    LicenseeManagement.cls
****************************************************/

trigger LicenseeTrigger on Licensees__c (before insert, before update) {
   
    system.debug( '###LicenseeTrigger: Entering trigger.###' );
    
    Licensees__c[] licenseeRecordsWithChangedFamilies = new Licensees__c[]{};
    
    if (trigger.isBefore) { 
        if (trigger.isInsert)
            for (Licensees__c licensee:Trigger.new)
                if (licensee.Core_Patent_Family_Id__c != null)
                    licenseeRecordsWithChangedFamilies.add(licensee);
        
        if (trigger.isUpdate) 
            for (Licensees__c licensee:Trigger.new)
                if ((licensee.Core_Patent_Family_Id__c != null) && Trigger.oldMap.containsKey(licensee.Id) && (Trigger.oldMap.get(licensee.Id).Core_Patent_Family_Id__c != licensee.Core_Patent_Family_Id__c))
                    licenseeRecordsWithChangedFamilies.add(licensee);
    }
    
    if (licenseeRecordsWithChangedFamilies.size() > 0)
        LicenseeManagement.updatePatentFamilies(licenseeRecordsWithChangedFamilies);
   
    system.debug( '###LicenseeTrigger: Exiting trigger.###' );
   
}