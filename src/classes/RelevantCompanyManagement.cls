/****************************************************
   
    RELEVANT COMPANY MANAGEMENT CLASS
    
    Created 10/29/2013 by Hank Ryan Thompson.
    Last updated 10/29/2013 by Hank Ryan Thompson.
    
    This class contains all of the code to power the
    PotentialRelevance trigger.
    
    NOTE: The testMethods for this class are
    contained in SyncEngineTests.cls.
    
****************************************************/

public without sharing class RelevantCompanyManagement {
    
    
    /*=== UTILITY FUNCTIONS ===*/
    
    
    public static void updatePatentFamilies(Potentially_Relevant_Company__c[] prcRecords) {
        // Meant to be called from a BEFORE update or insert
        // Accepts a list of PRC records (either newly inserted with non-blank Core Patent Family Ids or with changed CPFamilyIds).
        // Looks for patent family records with matching CPFamilyIds.
        //  > If Found: Updates Patent_Family__c on the PRC records
        //  > If NOT Found: Adds an error to the problematic rows in [prcRecords]
        
        system.debug('###RelevantCompanyManagement.updatePatentFamilies(): Entering function.###');
        
        Set<String> patentFamilyPrimaryKeys = new Set<String>();
        Map<String, Potentially_Relevant_Company__c[]> prcMap = new Map<String, Potentially_Relevant_Company__c[]>(); // maps from patent family primary key to list of related PRCs
        Map<String, String> patentFamilyFieldMap;
        Assets__c[] patentFamilies;
        String primaryKey;
        Set<String> matchedPrimaryKeys = new Set<String>();
        
        // Build out key set and map and do the query
        for (Potentially_Relevant_Company__c prc:prcRecords) {
            primaryKey = SyncEngine.cleanPrimaryKey(prc.Core_Patent_Family_Id__c);
            patentFamilyPrimaryKeys.add(primaryKey);
            if (prcMap.containsKey(primaryKey)) prcMap.get(primaryKey).add(prc);
            else prcMap.put(primaryKey, new Potentially_Relevant_Company__c[]{prc});
        } 
        patentFamilyFieldMap = new Map<String, String>{
            SyncEngine.PrimaryKey_Salesforce.get(SyncEngine.CoreObject.PatentFamily) => null
        }; // NOTE: Only the keys need to be present for queryRecords() to work.
        patentFamilies = SyncEngine.queryRecords(SyncEngine.CoreObject.PatentFamily, patentFamilyFieldMap, null, patentFamilyPrimaryKeys);
        //system.debug('###RelevantCompanyManagement.updatePatentFamilies(): Done querying patentFamilies = ' + patentFamilies + ', prcMap = ' + prcMap + '.###');
        
        // Run through and update the prcRecords as needed
        for (Assets__c pf:patentFamilies) {
            primaryKey = SyncEngine.getPrimaryKey(pf);
            matchedPrimaryKeys.add(primaryKey); //store this so we can find the error rows later
            if (prcMap.containsKey(primaryKey)) 
                for (Potentially_Relevant_Company__c prc:prcMap.get(primaryKey))
                    prc.Patent_Family__c = pf.Id;
        }
        
        // Finally run back through and give unmatched PRC rows an error
        for (Potentially_Relevant_Company__c prc:prcRecords)
            if (!matchedPrimaryKeys.contains(SyncEngine.cleanPrimaryKey(prc.Core_Patent_Family_Id__c)))
                prc.addError('Could not find Patent Family with Core Id = "' + prc.Core_Patent_Family_Id__c + '".');
        
        system.debug('###RelevantCompanyManagement.updatePatentFamilies(): Exiting function.###');
    }
    
}