/*****************************************************************************
 * Name             : portfolio2ProductManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Jan, 2012.
 * Purpose          : populate patentFamily if patent is selected.
 *
 * Modified         : Hank Ryan Thompson, 4/2013. Changes marked "HRT.4.13"
 *                    Hank Ryan Thompson, 8/2013. Changes marked "HRT.8.13"
 *
*****************************************************************************/
public without sharing class portfolio2ProductManagement {
    
    public static void beforePortfolio2ProductInsert(List<portfolio2product__c> pf2prodMap) {
        linkToPatent(pf2prodMap); // NOTE: It's important to run this FIRST since it may end up setting the Patent__c lookup
        updateFields(pf2prodMap, false);
    }
    
    public static void beforePortfolio2ProductUpdate(List<portfolio2product__c> pf2prodMap) {
        updateFields(pf2prodMap, false);
    }
    
    public static void updateFields (List<portfolio2product__c> p2pRecords, Boolean forceUpdate) {
        // Updates the patent family field if it is blank
        //    [forceUpdate] forces the patent family field to be requeried and updated
        // 
        // HRT.4.13: Added forceUpdate argument and debug messages, cleaned up formatting.
        
        
        system.debug('###updateFields(): Entering with p2pRecords = ' + p2pRecords + '.###');
        
        Set<Id> patentIds = new Set<Id>();
        Map<Id, Id> patentFamilyIdMap = new Map<Id, Id> (); //maps patent id to patent family id
        
        // First build a list of p2ps that are missing families (or if we're forcing an update just add them all)
        for (portfolio2product__c p2p:p2pRecords)
            if ((p2p.Patent__c != null) && (p2p.Portfolio__c == null || forceUpdate))
                patentIds.add(p2p.Patent__c);
        
        // Now query the patents and map them to their families
        for (Patent__c pt:[Select id, Patent_Family__c From Patent__c Where id in:patentIds])
            patentFamilyIdMap.put(pt.Id, pt.Patent_Family__c);
        
        // Finally run through and update the patent families on the p2pRecords
        for (portfolio2product__c p2p:p2pRecords)
            if ((p2p.Patent__c != null) && (p2p.Portfolio__c == null || forceUpdate))
                p2p.Portfolio__c = patentFamilyIdMap.get(p2p.Patent__c);
        
        system.debug('###updateFields(): Exiting with p2pRecords = ' + p2pRecords + '.###');
    }
    
    public static void linkToPatent(portfolio2product__c[] p2pRecords) {
        // This function was added by Hank (HRT.8.13) 
        // This function links all of the passed p2precords to their parent patents (if present)
        //    Parent patents are found by matching Patent__c.Country_Patent_Number__c with Core_Patent_Key__c
        // NOTE: This function is currently written only to run on BEFORE INSERT. 
        
        system.debug('###linkToPatent(): Entering with p2pRecords = ' + p2pRecords + '.###');
        
        Set<String> corePatentKeys = new Set<String>(); Set<String> strippedPatentNumbers = new Set<String>();
        Map<String, portfolio2product__c[]> p2pMap = new Map<String, portfolio2product__c[]>(); // maps from core patent key to a list of child p2precords 
        Patent__c[] patentRecords;
        
        // Build the map and key set
        for (portfolio2product__c p2p:p2pRecords) 
            if (p2p.Core_Patent_Key__c != null) {
	            corePatentKeys.add(p2p.Core_Patent_Key__c);
	            strippedPatentNumbers.add(p2p.Core_Patent_Key__c.substring(2));
	            if (p2pMap.containsKey(p2p.Core_Patent_Key__c)) p2pMap.get(p2p.Core_Patent_Key__c).add(p2p);
	            else p2pMap.put(p2p.Core_Patent_Key__c, new portfolio2product__c[]{p2p});
	        }
	        
        // Query the records, then run back through and link the children
        if (corePatentKeys.size() > 0) {
	        // NOTE: The next query specifically includes stripped patnum because otherwise you get a non-selective query error (since formula fields aren't indexed)
	        patentRecords = [select Id, Country_Patent_Number__c from Patent__c where Patent_No__c in :strippedPatentNumbers and Country_Patent_Number__c in :corePatentKeys];
	        for (Patent__c p:patentRecords)
	            if (p2pMap.get(p.Country_Patent_Number__c) != null)
	                for (portfolio2product__c p2p:p2pMap.get(p.Country_Patent_Number__c))
	                    p2p.Patent__c = p.Id;
        }
        
        // Done!
        system.debug('###linkToPatent(): Exiting with p2pRecords = ' + p2pRecords + '.###');
    }
  
}