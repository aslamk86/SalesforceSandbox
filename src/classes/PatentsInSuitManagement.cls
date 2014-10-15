/****************************************************
   
    PATENTS IN SUIT MANAGEMENT CLASS
    
    Created by Hank Ryan Thompson.
    Created 4/25/20013.
    Last updated 4/26/2013 by Hank.
    
    This class contains all of the code to power the
    patents in suit trigger.
    
    NOTE: The testMethods for this class are
    contained in SyncEngineTests.cls.
    
****************************************************/


public class PatentsInSuitManagement {
    
    
    /*=== TRIGGER FUNCTIONS ===*/
    
    
    public static void afterPatentsInSuitInsert(Map<Id, Patents_in_Suit__c> patentsInSuitMap) {
        // After patents are linked to a litigation, this function makes sure that their 
        // patent family records are also linked.
        
        system.debug('###afterPatentsInSuitInsert(): Entering function with patentsInSuitMap = ' + patentsInSuitMap + '.###');
        
        Set<Id> patentIds = new Set<Id>();
        Set<Id> targetPatentFamilyIds = new Set<Id>();
        Set<Id> litigationIds = new Set<Id>();
        Map<Id, Id> patentFamilyIdMap = new Map<Id, Id>(); // maps from patent id to patent family id
        Map<Id, Set<Id>> targetPatentFamilyIdMap = new Map<Id, Set<Id>>(); // maps from litigation id to set of patent family ids which SHOULD be present
        Map<Id, Set<Id>> existingPatentFamilyIdMap = new Map<Id, Set<Id>>(); // maps from litigation id to set of patent family ids which are CURRENTLY present in the db
        Patent__c[] patents;
        Litigation_Patent_Family__c[] existingLitigationPatentFamilies;
        Litigation_Patent_Family__c[] litigationPatentFamiliesToInsert = new Litigation_Patent_Family__c[]{};
        
        // first we build out the initial id sets and query for the patents (to get the patent family ids)
        for (Patents_in_Suit__c pis:patentsInSuitMap.values()) {
            patentIds.add(pis.Patent__c);
            litigationIds.add(pis.Litigation__c);
        }
        patents = [select Id, Name, Patent_Family__c from Patent__c where Id in :patentIds];
        
        //run through and map the patents to their families, then run back through and build out the target map
        for (Patent__c p:patents) {
            targetPatentFamilyIds.add(p.Patent_Family__c);
            patentFamilyIdMap.put(p.Id, p.Patent_Family__c);
        }
        for (Patents_in_Suit__c pis:patentsInSuitMap.values()) {
            if (!targetPatentFamilyIdMap.containsKey(pis.Litigation__c)) targetPatentFamilyIdMap.put(pis.Litigation__c, new Set<Id>());
            if (patentFamilyIdMap.get(pis.Patent__c) != null)
                targetPatentFamilyIdMap.get(pis.Litigation__c).add(patentFamilyIdMap.get(pis.Patent__c)); //add the family id of the current patent to the map 
        }
        system.debug('###afterPatentsInSuitInsert(): Finished building targetPatentFamilyIdMap = ' + targetPatentFamilyIdMap + '.###');
        
        //next query for the litigationPatentFamilies and build out the present map
        existingLitigationPatentFamilies = [select Id, Name, Litigation__c, Patent_Family__c from Litigation_Patent_Family__c where Litigation__c in :litigationIds and Patent_Family__c in :targetPatentFamilyIds];
        for (Litigation_Patent_Family__c lpf:existingLitigationPatentFamilies) {
            if (!existingPatentFamilyIdMap.containsKey(lpf.Litigation__c)) existingPatentFamilyIdMap.put(lpf.Litigation__c, new Set<Id>());
            existingPatentFamilyIdMap.get(lpf.Litigation__c).add(lpf.Patent_Family__c); //add the current family id to the map
        }
        system.debug('###afterPatentsInSuitInsert(): Finished building existingPatentFamilyIdMap = ' + existingPatentFamilyIdMap + '.###');
        
        //finally we can loop through litigations and check which patent families are MISSING
        Litigation_Patent_Family__c newLPF;
        for (Id litigationId:litigationIds)
            for (Id targetPatentFamilyId:targetPatentFamilyIdMap.get(litigationId))
                if (!existingPatentFamilyIdMap.containsKey(litigationId) || (existingPatentFamilyIdMap.containsKey(litigationId) && !existingPatentFamilyIdMap.get(litigationId).contains(targetPatentFamilyId))) { //this patent family is missing, so let's add it...
                    newLPF = new Litigation_Patent_Family__c();
                    newLPF.Litigation__c = litigationId;
                    newLPF.Patent_Family__c = targetPatentFamilyId;
                    litigationPatentFamiliesToInsert.add(newLPF);
                }
        
        //do the insertion (if needed)
        if (litigationPatentFamiliesToInsert.size() > 0) {
	        system.debug('###afterPatentsInSuitInsert(): About to insert litigationPatentFamiliesToInsert = ' + litigationPatentFamiliesToInsert + '.###');
	        insert litigationPatentFamiliesToInsert;
        }
        
        system.debug('###afterPatentsInSuitInsert(): Exiting function.###');
    }
    
    public static void afterPatentsInSuitDelete(Map<Id, Patents_in_Suit__c> patentsInSuitMap) {
        // When patents are de-linked from a litigation this function checks to see if their 
        // patent family records also require de-linking and if so deletes the Litigation_Patent_Family__c records.
        
        system.debug('###afterPatentsInSuitDelete(): Entering function with patentsInSuitMap = ' + patentsInSuitMap + '.###');
        
        Set<Id> dejoinedPatentIds = new Set<Id>();
        Set<Id> potentiallyDejoinedPatentFamilyIds = new Set<Id>();
        Set<Id> litigationIds = new Set<Id>();
        Map<Id, Set<Id>> litigationDejoinedPatentIdMap = new Map<Id, Set<Id>>(); // maps from litigation id to a set of the patent ids which are being dejoined 
        Map<Id, Set<Id>> litigationRemainingPatentFamilyMap = new Map<Id, Set<Id>>(); // maps from litigation id to a set of patent family ids with remaining children 
        Patent__c[] dejoinedPatents;
        Patents_in_Suit__c[] remainingPatentsInSuit;
        Litigation_Patent_Family__c[] litigationPatentFamilies;
        Litigation_Patent_Family__c[] litigationPatentFamiliesToDelete = new Litigation_Patent_Family__c[]{};
        
        // first we build out the initial id sets and query for the patents (to get the patent family ids)
        for (Patents_in_Suit__c pis:patentsInSuitMap.values()) {
            dejoinedPatentIds.add(pis.Patent__c);
            litigationIds.add(pis.Litigation__c);
            if (!litigationDejoinedPatentIdMap.containsKey(pis.Litigation__c)) litigationDejoinedPatentIdMap.put(pis.Litigation__c, new Set<Id>());
            litigationDejoinedPatentIdMap.get(pis.Litigation__c).add(pis.Patent__c); // we need to log this for later
        }
        dejoinedPatents = [select Id, Name, Patent_Family__c from Patent__c where Id in :dejoinedPatentIds];
        
        //build a list of pfamily ids and then query for the litigationPatentFamilies and the remainingPatentsInSuit for those families
        for (Patent__c p:dejoinedPatents)
            potentiallyDejoinedPatentFamilyIds.add(p.Patent_Family__c);
        litigationPatentFamilies = [select Id, Name, Litigation__c, Patent_Family__c from Litigation_Patent_Family__c where Litigation__c in :litigationIds and Patent_Family__c in :potentiallyDejoinedPatentFamilyIds];
        remainingPatentsInSuit = [select Id, Name, Litigation__c, Patent__c, Patent__r.Patent_Family__c from Patents_in_Suit__c where Litigation__c in :litigationIds and Patent__r.Patent_Family__c in :potentiallyDejoinedPatentFamilyIds];
        
        //now run through the remainingPatentsInSuit. Each one represents a patent family which should be preserved so we'll record that in a map
        for (Patents_in_Suit__c pis:remainingPatentsInSuit) {
            if (!litigationRemainingPatentFamilyMap.containsKey(pis.Litigation__c))
                litigationRemainingPatentFamilyMap.put(pis.Litigation__c, new Set<Id>());
            if (!litigationDejoinedPatentIdMap.get(pis.Litigation__c).contains(pis.Patent__c)) // NOTE: we only have to check for this because the PatentManagement class uses this same function in a BEFORE UDPATE trigger context 
                litigationRemainingPatentFamilyMap.get(pis.Litigation__c).add(pis.Patent__r.Patent_Family__c);
        }
        system.debug('###afterPatentsInSuitDelete(): Finished building litigationRemainingPatentFamilyMap = ' + litigationRemainingPatentFamilyMap + ', about to run through litigationPatentFamilies = ' + litigationPatentFamilies + '.###');
        
        //finally we can loop through litigationPatentFamilies and build our delete list
        for (Litigation_Patent_Family__c lpf:litigationPatentFamilies)
            if (!litigationRemainingPatentFamilyMap.containsKey(lpf.Litigation__c) || !litigationRemainingPatentFamilyMap.get(lpf.Litigation__c).contains(lpf.Patent_Family__c)) // then this pfamily has no remainin children in thisd litigation, so delete it!
                litigationPatentFamiliesToDelete.add(lpf);
        
        //do the deletion (if needed)
        if (litigationPatentFamiliesToDelete.size() > 0) {
            system.debug('###afterPatentsInSuitDelete(): About to delete litigationPatentFamiliesToDelete = ' + litigationPatentFamiliesToDelete + '.###');
            delete litigationPatentFamiliesToDelete;
        }
        
        system.debug('###afterPatentsInSuitDelete(): Exiting function.###');
    }

}