/****************************************************
   
    LICENSEE MANAGEMENT CLASS
    
    Created 10/29/2013 by Hank Ryan Thompson.
    Last updated 10/29/2013 by Hank Ryan Thompson.
    
    This class contains all of the code to power the
    Licensee trigger.
    
    NOTE: The testMethods for this class are
    contained in SyncEngineTests.cls.
    
****************************************************/

public without sharing class LicenseeManagement {
    
    
    /*=== UTILITY FUNCTIONS ===*/
    
    
    public static void updatePatentFamilies(Licensees__c[] licenseeRecords) {
        // Meant to be called from a BEFORE update or insert
        // Accepts a list of Licensee records (either newly inserted with non-blank Core Patent Family Ids or with changed CPFamilyIds).
        // Looks for patent family records with matching CPFamilyIds.
        //  > If Found: Updates Patent_Family__c on the PRC records
        //  > If NOT Found: Adds an error to the problematic rows in [licenseeRecords]
        
        system.debug('###LicenseeManagement.updatePatentFamilies(): Entering function.###');
        
        Set<String> patentFamilyPrimaryKeys = new Set<String>();
        Map<String, Licensees__c[]> licenseeMap = new Map<String, Licensees__c[]>(); // maps from patent family primary key to list of related PRCs
        Map<String, String> patentFamilyFieldMap;
        Assets__c[] patentFamilies;
        String primaryKey;
        Set<String> matchedPrimaryKeys = new Set<String>();
        
        // Build out key set and map and do the query
        for (Licensees__c licensee:licenseeRecords) {
            primaryKey = SyncEngine.cleanPrimaryKey(licensee.Core_Patent_Family_Id__c);
            patentFamilyPrimaryKeys.add(primaryKey);
            if (licenseeMap.containsKey(primaryKey)) licenseeMap.get(primaryKey).add(licensee);
            else licenseeMap.put(primaryKey, new Licensees__c[]{licensee});
        } 
        patentFamilyFieldMap = new Map<String, String>{
            SyncEngine.PrimaryKey_Salesforce.get(SyncEngine.CoreObject.PatentFamily) => null
        }; // NOTE: Only the keys need to be present for queryRecords() to work.
        patentFamilies = SyncEngine.queryRecords(SyncEngine.CoreObject.PatentFamily, patentFamilyFieldMap, null, patentFamilyPrimaryKeys);
        //system.debug('###LicenseeManagement.updatePatentFamilies(): Done querying patentFamilies = ' + patentFamilies + ', licenseeMap = ' + licenseeMap + '.###');
        
        // Run through and update the licenseeRecords as needed
        for (Assets__c pf:patentFamilies) {
            primaryKey = SyncEngine.getPrimaryKey(pf);
            matchedPrimaryKeys.add(primaryKey); //store this so we can find the error rows later
            if (licenseeMap.containsKey(primaryKey)) 
                for (Licensees__c licensee:licenseeMap.get(primaryKey))
                    licensee.Patent_Family__c = pf.Id;
        }
        
        // Finally run back through and give unmatched PRC rows an error
        for (Licensees__c licensee:licenseeRecords)
            if (!matchedPrimaryKeys.contains(SyncEngine.cleanPrimaryKey(licensee.Core_Patent_Family_Id__c)))
                licensee.addError('Could not find Patent Family with Core Id = "' + licensee.Core_Patent_Family_Id__c + '".');
        
        system.debug('###LicenseeManagement.updatePatentFamilies(): Exiting function.###');
    }
    
}