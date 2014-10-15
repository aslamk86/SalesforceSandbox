/****************************************************
   
    PATENTS MANAGEMENT CLASS
    
    Created by Appirio.
    Last updated 10/23/2013 by Hank Ryan Thompson.
    
    This class contains all of the code to power the
    patents trigger.
    
    NOTE: The testMethods for this class are
    contained in SyncEngineTests.cls and
    TestPatentManagement.cls.
    
****************************************************/

public without sharing class PatentManagement {
    
    
    /*=== UTILITY FUNCTIONS ===*/
    
    
    public static void updateFields(Map<Id, Patent__c> oldPatentMap, List<Patent__c> lstPatents) {
        // Populate Assignment_Note_by__c and Assignment_Note_Date__c
        // if Assigned_to__c is changed.
        
        for (Patent__c patent : lstPatents) {
            if (patent.Assigned_to__c != null && patent.Assigned_to__c != oldPatentMap.get(patent.Id).Assigned_to__c) {
                patent.Assignment_Note_by__c = UserInfo.getUserId();
                patent.Assignment_Note_Date__c = DateTime.now();
            }
        }
    }
    
    
    
    /*=== TRIGGER FUNCTIONS ===*/
    
    
    public static void linkTechTags_AfterInsert(Map<Id, Patent__c> newPatentMap) {
        // This function checks to see if any tech tags already exist with this new patent's key
        // If so, they are linked to the patent record.
         
        system.debug('###linkTechTags_AfterInsert(): Entering function.###');
        
        Set<String> countryPatentNumbers = new Set<String>();
        Map<String, Id> patentIdMap = new Map<String, Id>(); // maps from country patent number to patent record id
        portfolio2product__c[] relatedTechTags; portfolio2product__c[] techTagsToUpdate = new portfolio2product__c[]{};
        
        // First build the key list & map
        for (Patent__c p:newPatentMap.values())
            if (p.Country_Patent_Number__c != null) {
                countryPatentNumbers.add(p.Country_Patent_Number__c);
                patentIdMap.put(p.Country_Patent_Number__c, p.Id);
            }
        
        // Now query the related tech tags, then run back through and link them
        if (countryPatentNumbers.size() > 0) {
	        relatedTechTags = [select Id, Patent__c, Core_Patent_Key__c from portfolio2product__c where Core_Patent_Key__c in :countryPatentNumbers];
	        for (portfolio2product__c tt:relatedTechTags)
	           if (patentIdMap.get(tt.Core_Patent_Key__c) != null) {
	               tt.Patent__c = patentIdMap.get(tt.Core_Patent_Key__c);
	               techTagsToUpdate.add(tt);
	           }
        }
        
        // Do the dml
        if (techTagsToUpdate.size() > 0)
            update techTagsToUpdate;
        
        system.debug('###linkTechTags_AfterInsert(): Exiting function.###');
    }
    
    public static void processChanges_LeavingPatentFamilies(Map<Id, Patent__c> oldPatentMap, Map<Id, Patent__c> newPatentMap) {
        // This function checks for patents which are LEAVING their patent families and processes the changes.
        // NOTE: This function should be called from the AFTER UPDATE trigger BEFORE the EnteringPatentFamilies function.
         
        system.debug('###processChanges_LeavingPatentFamilies(): Entering function.###');
        
        Set<Id> dejoiningPatentIds = new Set<Id>();
        Map<Id, Set<Id>> dejoiningChildPatentIdMap = new Map<Id, Set<Id>>(); //maps from patent family id to a set of the patents leaving it 
        Patent__c[] dejoiningPatents = new Patent__c[]{};
        Set<Id> dejoinedPatentFamilyIds = new Set<Id>();
        Patent__c[] remainingChildPatents;
        Map<Id, Boolean> patentFamilyHasChildrenMap = new Map<Id, Boolean>(); //maps from patent family id to boolean indicating whether it has remaining children
        Set<Id> emptyPatentFamilyIds = new Set<Id>();
        Assets__c[] emptyPatentFamiliesToDelete = new Assets__c[]{};
        Patents_in_Suit__c [] pisRecordsToProcess;  Map<Id, Patents_in_Suit__c> pisMap = new Map<Id, Patents_in_Suit__c>(); // Patents in Suit collections
        OMA_Patent__c [] omapRecordsToProcess;  Map<Id, OMA_Patent__c> omapMap = new Map<Id, OMA_Patent__c>(); // OMA Patent collections
        portfolio2product__c[] p2pRecordsToProcess; // Patent Family to Product Map collection
        Id oldPFId;
        
        // First run through and create a list of patents that have a changed value for patent family AND where the old patent family value was non-null
        // These patents are "dejoining" their families so their families will all have to be examined for potential removal of *some* of their join records.
        // The dejoined families will also need to be checked to see if they have any children left (if not they should be deleted)
        for (Patent__c p:newPatentMap.values())
            if (oldPatentMap.containsKey(p.Id) && (oldPatentMap.get(p.Id).Patent_Family__c != p.Patent_Family__c) && (oldPatentMap.get(p.Id).Patent_Family__c != null)) {
                dejoiningPatents.add(p);
                dejoiningPatentIds.add(p.Id);
                
                oldPFId = oldPatentMap.get(p.Id).Patent_Family__c;
                
                dejoinedPatentFamilyIds.add(oldPFId);
                patentFamilyHasChildrenMap.put(oldPFId, false);
                if (dejoiningChildPatentIdMap.containsKey(oldPFId)) dejoiningChildPatentIdMap.get(oldPFId).add(p.Id);
                else dejoiningChildPatentIdMap.put(oldPFId, new Set<Id>{p.Id});
            }
        
        // First process the join records
        if (dejoiningPatents.size() > 0) {
            //system.debug('###processChanges_LeavingPatentFamilies(): Entering processing branch with patentsDejoiningFamilies = ' + dejoiningPatents + '.###');
            
            // We can't just go and blanket delete all the patent family join records because there could be remaining child patents
            // that make some of those join records still valid.  The only way to figure out which is which is to go through and inspect everything.
            // Instead of doing that here we are going to make use of the logic in the afterDelete or beforeUpdate functions of the following target objects.
            // TARGET OBJECTS: Patents_in_Suit__c, OMA_Patent__c, portfolio2product__c 
            // Basically we'll just query the target objects and then pass their mapified versions to the appropriate _____Management function.
            
            pisRecordsToProcess = [select Id, Name, Litigation__c, Patent__c from Patents_in_Suit__c where Patent__c in :dejoiningPatentIds];
            if (pisRecordsToProcess.size() > 0) { 
                //system.debug(LoggingLevel.ERROR, '###processChanges_LeavingPatentFamilies(): Done querying pisRecordsToProcess, passing them to PatentsInSuitManagement...###');
                for (Patents_in_Suit__c pis:pisRecordsToProcess) pisMap.put(pis.Id, pis); //mapify them
                PatentsInSuitManagement.afterPatentsInSuitDelete(pisMap);
            }
            
            omapRecordsToProcess = [select Id, Name, Acquisition_Opportunity__c, Patent__c from OMA_Patent__c where Patent__c in :dejoiningPatentIds];
            if (omapRecordsToProcess.size() > 0) { 
                //system.debug(LoggingLevel.ERROR, '###processChanges_LeavingPatentFamilies(): Done querying omapRecordsToProcess, passing them to OMAPatentManagement...###');
                for (OMA_Patent__c omap:omapRecordsToProcess) omapMap.put(omap.Id, omap); //mapify them
                OMAPatentManagement.afterOMAPatentDelete(omapMap);
            }
            
            p2pRecordsToProcess = [select Id, Name, Portfolio__c, Patent__c from portfolio2product__c where Patent__c in :dejoiningPatentIds];
            if (p2pRecordsToProcess.size() > 0) { 
                //system.debug(LoggingLevel.ERROR, '###processChanges_LeavingPatentFamilies(): Done querying p2pRecordsToProcess, passing them to portfolio2ProductManagement...###');
                portfolio2ProductManagement.updateFields(p2pRecordsToProcess, true); // forceUpdate = true
                update p2pRecordsToProcess; // we used a beforeUpdate function so it didn't commit the changes to the db
            }
        }
        
        // Now check to see if any patent families need deleting
        if (dejoinedPatentFamilyIds.size() > 0) {
            // First query for remaining child patents
            remainingChildPatents = [select Patent_Family__c from Patent__c where Patent_Family__c in :dejoinedPatentFamilyIds];
            for (Patent__c p:remainingChildPatents)
                if (!dejoiningChildPatentIdMap.get(p.Patent_Family__c).contains(p.Id)) // filter out the currently departing patents for this family
                    patentFamilyHasChildrenMap.put(p.Patent_Family__c, true);
            
            // Now run back through the map and delete any patent families that don't have children
            for (Id pfId:dejoinedPatentFamilyIds)
                if (!patentFamilyHasChildrenMap.get(pfId))
                    emptyPatentFamilyIds.add(pfId);
            
            //system.debug(LoggingLevel.ERROR, '###processChanges_LeavingPatentFamilies(): remainingChildPatents = ' + remainingChildPatents + ', \n\n\n emptyPatentFamiliesToDelete = ' + emptyPatentFamiliesToDelete + ', \n\n\n patentFamilyHasChildrenMap = ' + patentFamilyHasChildrenMap + '.###');
            if (emptyPatentFamilyIds.size() > 0) {
                // First we need to requery to make sure we don't double delete anything. (NOTE: I'm not sure how this happened, but without this extra step the code was sometimes getting an ENTITY_IS_DELETED error.)
                emptyPatentFamiliesToDelete = [select id from Assets__c where IsDeleted=false and Id in :emptyPatentFamilyIds];
                if (emptyPatentFamiliesToDelete.size() > 0) delete emptyPatentFamiliesToDelete;
            }
        }
        
        system.debug('###processFamilyChanges_BeforeUpdate(): Exiting function.###');
    }
    
    
    public static void processChanges_EnteringPatentFamilies(Map<Id, Patent__c> oldPatentMap, Map<Id, Patent__c> newPatentMap) {
        // This function checks for patents which are ENTERING different patent families and processes the changes.
        // NOTE: This function should be called from the AFTER UPDATE trigger AFTER the LeavingPatentFamilies function.
         
        system.debug('###processChanges_EnteringPatentFamilies(): Entering function.###');
        
        Set<Id> joiningPatentIds = new Set<Id>();
        Patent__c[] joiningPatents = new Patent__c[]{};
        Patents_in_Suit__c [] pisRecordsToProcess;  Map<Id, Patents_in_Suit__c> pisMap = new Map<Id, Patents_in_Suit__c>(); // Patents in Suit collections
        OMA_Patent__c [] omapRecordsToProcess;  Map<Id, OMA_Patent__c> omapMap = new Map<Id, OMA_Patent__c>(); // OMA Patent collections
        portfolio2product__c[] p2pRecordsToProcess; // Patent Family to Product Map collection
        
        // First run through and create a list of patents that have a changed value for patent family AND where the new patent family value was non-null
        // These patents are "joining" their families so their families will all have to be examined for potential insertion of *some* new join records.
        for (Patent__c p:newPatentMap.values())
            if (oldPatentMap.containsKey(p.Id) && (oldPatentMap.get(p.Id).Patent_Family__c != p.Patent_Family__c) && (p.Patent_Family__c != null)) {
                joiningPatents.add(p);
                joiningPatentIds.add(p.Id);
            }
        
        if (joiningPatents.size() > 0) {
            //system.debug(LoggingLevel.ERROR, '###processChanges_EnteringPatentFamilies(): Entering processing branch with joiningPatents = ' + joiningPatents + '.###');
            
            // As in beforePatentUpdate() above, we're going to make use of the logic in the afterInsert or beforeUpdate functions of the following target objects.
            // TARGET OBJECTS: Patents_in_Suit__c, OMA_Patent__c, portfolio2product__c 
            // Basically we'll just query the target objects and then pass their mapified versions to the appropriate _____Management function.
            
            pisRecordsToProcess = [select Id, Name, Litigation__c, Patent__c from Patents_in_Suit__c where Patent__c in :joiningPatentIds];
            if (pisRecordsToProcess.size() > 0) { 
                //system.debug(LoggingLevel.ERROR, '###processChanges_EnteringPatentFamilies(): Done querying pisRecordsToProcess, passing them to PatentsInSuitManagement...###');
                for (Patents_in_Suit__c pis:pisRecordsToProcess) pisMap.put(pis.Id, pis); //mapify them
                PatentsInSuitManagement.afterPatentsInSuitInsert(pisMap);
            }
            
            omapRecordsToProcess = [select Id, Name, Acquisition_Opportunity__c, Patent__c from OMA_Patent__c where Patent__c in :joiningPatentIds];
            if (omapRecordsToProcess.size() > 0) { 
                //system.debug(LoggingLevel.ERROR, '###processChanges_EnteringPatentFamilies(): Done querying omapRecordsToProcess, passing them to OMAPatentManagement...###');
                for (OMA_Patent__c omap:omapRecordsToProcess) omapMap.put(omap.Id, omap); //mapify them
                OMAPatentManagement.afterOMAPatentInsert(omapMap);
            }
            
            p2pRecordsToProcess = [select Id, Name, Portfolio__c, Patent__c from portfolio2product__c where Patent__c in :joiningPatentIds];
            if (p2pRecordsToProcess.size() > 0) { 
                //system.debug(LoggingLevel.ERROR, '###processChanges_EnteringPatentFamilies(): Done querying p2pRecordsToProcess, passing them to portfolio2ProductManagement...###');
                portfolio2ProductManagement.updateFields(p2pRecordsToProcess, true); // forceUpdate = true
                update p2pRecordsToProcess; // we used a beforeUpdate function so it didn't commit the changes to the db
            }
        }
        
        system.debug( '###processChanges_EnteringPatentFamilies(): Exiting function.###');
    }
    
    public static void rollupPatentFamilyAnnotations(Map<Id, Patent__c> oldPatentMap, Map<Id, Patent__c> newPatentMap) {
        // First checks to see if the Characterization of Claims, Representative Claims or Summary have changed.
        // If so, then the function updates the rolled up fields on the parent patent families
        // NOTE: This should be called from the AFTER UPDATE and AFTER INSERT triggers
        
        system.debug( '###rollupPatentFamilyAnnotations(): Entering function.###');
        
        Set<Id> patentFamilyIds = new Set<Id>();
        Patent__c[] allChildPatents;
        Assets__c[] patentFamiliesToUpdate = new Assets__c[]{};
        Map<Id, Assets__c> patentFamilyMap = new Map<Id, Assets__c>(); // maps from patent family id to the patent family record
        Patent__c oldPatent; Assets__c patentFamily; Patent__c blankPatent = new Patent__c();
        
        String PATENT_HEADER_SEPERATOR = ': '; // goes in between the patent number and the patent annotation text
        String PATENT_SEPERATOR = '\n\n'; // goes in between the child patents
        
        // First collect the patent family ids of all new patents OR all patents with updated annotation fields
        if  (oldPatentMap == null) oldPatentMap = new Map<Id, Patent__c>(); // keeps the code below from erroring out in an insert trigger
        for (Patent__c newPatent:newPatentMap.values()) 
            if ((newPatent.Patent_Family__c != null) && !patentFamilyIds.contains(newPatent.Patent_Family__c))  {
                if (oldPatentMap.containsKey(newPatent.Id)) oldPatent = oldPatentMap.get(newPatent.Id);
                else oldPatent = blankPatent; // This way only inserted patents with NON-NULL annotation will get through the filter
                 
                if ((newPatent.Characterization_of_Claims__c != oldPatent.Characterization_of_Claims__c)
                    || (newPatent.Representative_Claims__c != oldPatent.Representative_Claims__c)
                    || (newPatent.Summary__c != oldPatent.Summary__c)) {
                        patentFamilyIds.add(newPatent.Patent_Family__c);
                }
            }
        
        // Now query for all of the child patents, then run through and summarize their annotation info
        if (patentFamilyIds.size() > 0) {
	        allChildPatents = [select Id, Patent_No__c, Patent_Family__c, Characterization_of_Claims__c, Representative_Claims__c, Summary__c from Patent__c where Patent_Family__c in :patentFamilyIds and IsDeleted=false order by Patent_No__c ASC];
	        for (Patent__c childPatent:allChildPatents) {
	            // First, get the patent family (initialize if necessary)
	            patentFamily = patentFamilyMap.get(childPatent.Patent_Family__c);
	            if (patentFamily == null) {
	                patentFamily = new Assets__c(Id=childPatent.Patent_Family__c, Info_Pulled_from_Patents_on__c=DateTime.now(), Characterization_of_Claims__c = '', Representative_Claims__c = '', Summary__c = '');
	                patentFamiliesToUpdate.add(patentFamily);
	                patentFamilyMap.put(patentFamily.Id, patentFamily);
	            }
	            
	            if (childPatent.Characterization_of_Claims__c != null) {
	                if (patentFamily.Characterization_of_Claims__c != null) patentFamily.Characterization_of_Claims__c += PATENT_SEPERATOR;
	                patentFamily.Characterization_of_Claims__c += childPatent.Patent_No__c + PATENT_HEADER_SEPERATOR + childPatent.Characterization_of_Claims__c;
	            }
	
	            if (childPatent.Representative_Claims__c != null) {
	                if (patentFamily.Representative_Claims__c != null) patentFamily.Representative_Claims__c += PATENT_SEPERATOR;
	                patentFamily.Representative_Claims__c += childPatent.Patent_No__c + PATENT_HEADER_SEPERATOR + childPatent.Representative_Claims__c;
	            }
	
	            if (childPatent.Summary__c != null) {
	                if (patentFamily.Summary__c != null) patentFamily.Summary__c += PATENT_SEPERATOR;
	                patentFamily.Summary__c += childPatent.Patent_No__c + PATENT_HEADER_SEPERATOR + childPatent.Summary__c;
	            }
	        }
        }
        
        // Now do the dml (if needed)
        if (patentFamiliesToUpdate.size() > 0) { 
            // First run through and clip the fields if needed (So they are not over the maximum text field length)
            for (Assets__c pf:patentFamiliesToUpdate) {
                if ((pf.Characterization_of_Claims__c != null) && (pf.Characterization_of_Claims__c.length() > 32768)) pf.Characterization_of_Claims__c = pf.Characterization_of_Claims__c.substring(0, 32768);
                if ((pf.Representative_Claims__c != null) && (pf.Representative_Claims__c.length() > 32768)) pf.Representative_Claims__c = pf.Representative_Claims__c.substring(0, 32768);
                if ((pf.Representative_Claims__c != null) && (pf.Summary__c.length() > 32768)) pf.Summary__c = pf.Summary__c.substring(0, 32768);
            }
            
            // Now commit the update to the DB
            update patentFamiliesToUpdate;
        }
        
        system.debug( '###rollupPatentFamilyAnnotations(): Entering function.###');
    }
    
}