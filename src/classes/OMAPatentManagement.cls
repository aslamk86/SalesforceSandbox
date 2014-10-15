/*****************************************************************************
 * Name             : OMAPatentManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 06 Feb, 2012.
 * Purpose          : Contains OMA_Patent__c trigger methods
 *                    T-24262  
 *
 * Modified         : Hank Ryan Thompson, 4/2013. Changes marked "HRT.4.13"
 *
*****************************************************************************/

public without sharing class OMAPatentManagement {
  
  public static void beforeOMAPatentInsert(List<OMA_Patent__c> lstPT) {
  	Map<Id,Set<Id>> acqOppAndPatentMap = new Map<Id,Set<Id>>();
    Set<Id> acqOppIds = new Set<Id>(); 
    
    for (OMA_Patent__c pt : lstPT) {
      acqOppIds.add(pt.Acquisition_Opportunity__c);
    }
    
    for(OMA_Patent__c pt : [Select Acquisition_Opportunity__c, Patent__c 
	                          From OMA_Patent__c 
	                          Where Acquisition_Opportunity__c in :acqOppIds]) {
      if(!acqOppAndPatentMap.containsKey(pt.Acquisition_Opportunity__c)){
        acqOppAndPatentMap.put(pt.Acquisition_Opportunity__c, new Set<Id>());
      }                                     
      acqOppAndPatentMap.get(pt.Acquisition_Opportunity__c).add(pt.Patent__c);
    }
    
    for (OMA_Patent__c pt : lstPT) {
      if (acqOppAndPatentMap.containsKey(pt.Acquisition_Opportunity__c)) {
        if(acqOppAndPatentMap.get(pt.Acquisition_Opportunity__c).contains(pt.Patent__c)) {
          //pt.Patent__c.addError('Patent already exist in Portfolio. ');
          pt.addError('Patent already exist in Acquisition Opportunity. ');
        }
      }
    }
  }
  
    public static void afterOMAPatentInsert(Map<Id, OMA_Patent__c> ptMap) {
        // HRT.4.13: Added debug statements, cleaned up formatting.
        
        Set<Id> patentIds = new Set<Id>();
        Set<Id> acqOppIds = new Set<Id>();
        
        system.debug('###afterOMAPatentInsert(): Entering function with ptMap = ' + ptMap + '.###');
        
        for (OMA_Patent__c pt : ptMap.values()) {
            patentIds.add(pt.Patent__c);
            acqOppIds.add(pt.Acquisition_Opportunity__c );
        }
        
        Map<Id, Id> insertedPatentFamilyMap = fetchPatentAndFamily(patentIds);
        Map<Id, Set<Id>> alreadyExistingFamilies = fetchAcqOppAndFamily(acqOppIds);
        Set<Acquisition_Patent_Families__c> lstAcqPTFamilyToInsert = new Set<Acquisition_Patent_Families__c>();
        
        system.debug('###afterOMAPatentInsert(): About to run through loop. insertedPatentFamilyMap = ' + insertedPatentFamilyMap + ', alreadyExistingFamilies = ' + alreadyExistingFamilies + '.###');
        
        for (OMA_Patent__c pt : ptMap.values()) {
            Set<Id> patentFamilyIds = new Set<Id>();
            Set<Id> acqFamilyIds = new Set<Id>();
            
            if (alreadyExistingFamilies.containsKey(pt.Acquisition_Opportunity__c))
                acqFamilyIds.addAll(alreadyExistingFamilies.get(pt.Acquisition_Opportunity__c));
            
            //add family in acquisition opportunity only if family is not previously added. 
            if (insertedPatentFamilyMap.containsKey(pt.Patent__c)) {
                Id fId = insertedPatentFamilyMap.get(pt.Patent__c);
                if (fId != null && !acqFamilyIds.contains(fId)) {
                    Acquisition_Patent_Families__c apf = new Acquisition_Patent_Families__c();
                    apf.Acquisition_Opportunity__c = pt.Acquisition_Opportunity__c;
                    apf.Patent_Family__c = fId;
                    lstAcqPTFamilyToInsert.add(apf);
                }
            }
        }
        
        List<Acquisition_Patent_Families__c> lstToInsert = new List<Acquisition_Patent_Families__c>();
        lstToInsert.addAll(lstAcqPTFamilyToInsert);
        
        system.debug('###afterOMAPatentInsert(): Inserting lstToInsert = ' + lstToInsert + ', then exiting function.###');
        insert lstToInsert;    
    }
    
    
    // HRT.4.13: Replaced this next function with a different version.  See commented out area below for more info.
    
    public static void afterOMAPatentDelete(Map<Id, OMA_Patent__c> omaPatentMap) {
        // When patents are de-linked from a acquisition this function checks to see if their 
        // patent family records also require de-linking and if so deletes the Acquisition_Patent_Families__c records.
        
        system.debug('###afterOMAPatentDelete(): Entering function with omaPatentMap = ' + omaPatentMap + '.###');
        
        Set<Id> dejoinedPatentIds = new Set<Id>();
        Set<Id> potentiallyDejoinedPatentFamilyIds = new Set<Id>();
        Set<Id> acquisitionIds = new Set<Id>();
        Map<Id, Set<Id>> acquisitionDejoinedPatentIdMap = new Map<Id, Set<Id>>(); // maps from litigation id to a set of the patent ids which are being dejoined
        Map<Id, Set<Id>> acquisitionRemainingPatentFamilyMap = new Map<Id, Set<Id>>(); // maps from acquisition id to a set of patent family ids with remaining children 
        Patent__c[] dejoinedPatents;
        OMA_Patent__c[] remainingOMAPatents;
        Acquisition_Patent_Families__c[] acquisitionPatentFamilies;
        Acquisition_Patent_Families__c[] acquisitionPatentFamiliesToDelete = new Acquisition_Patent_Families__c[]{};
        
        // first we build out the initial id sets and query for the patents (to get the patent family ids)
        for (OMA_Patent__c omap:omaPatentMap.values()) {
            dejoinedPatentIds.add(omap.Patent__c);
            acquisitionIds.add(omap.Acquisition_Opportunity__c);
            if (!acquisitionDejoinedPatentIdMap.containsKey(omap.Acquisition_Opportunity__c)) acquisitionDejoinedPatentIdMap.put(omap.Acquisition_Opportunity__c, new Set<Id>());
            acquisitionDejoinedPatentIdMap.get(omap.Acquisition_Opportunity__c).add(omap.Patent__c); // we need to log this for later
        }
        dejoinedPatents = [select Id, Name, Patent_Family__c from Patent__c where Id in :dejoinedPatentIds];
        
        //build a list of pfamily ids and then query for the acquisitionPatentFamilies and the remainingOMAPatents for those families
        for (Patent__c p:dejoinedPatents)
            potentiallyDejoinedPatentFamilyIds.add(p.Patent_Family__c);
        acquisitionPatentFamilies = [select Id, Name, Acquisition_Opportunity__c, Patent_Family__c from Acquisition_Patent_Families__c where Acquisition_Opportunity__c in :acquisitionIds and Patent_Family__c in :potentiallyDejoinedPatentFamilyIds];
        remainingOMAPatents = [select Id, Name, Acquisition_Opportunity__c, Patent__c, Patent__r.Patent_Family__c from OMA_Patent__c where Acquisition_Opportunity__c in :acquisitionIds and Patent__r.Patent_Family__c in :potentiallyDejoinedPatentFamilyIds];
        
        //now run through the remainingOMAPatents. Each one represents a patent family which should be preserved so we'll record that in a map
        for (OMA_Patent__c omap:remainingOMAPatents) {
            if (!acquisitionRemainingPatentFamilyMap.containsKey(omap.Acquisition_Opportunity__c))
                acquisitionRemainingPatentFamilyMap.put(omap.Acquisition_Opportunity__c, new Set<Id>());
            if (!acquisitionDejoinedPatentIdMap.get(omap.Acquisition_Opportunity__c).contains(omap.Patent__c)) // NOTE: we only have to check for this because the PatentManagement class uses this same function in a BEFORE UDPATE trigger context
                acquisitionRemainingPatentFamilyMap.get(omap.Acquisition_Opportunity__c).add(omap.Patent__r.Patent_Family__c);
        }
        system.debug('###afterOMAPatentDelete(): Finished building acquisitionRemainingPatentFamilyMap = ' + acquisitionRemainingPatentFamilyMap + ', about to run through acquisitionPatentFamilies = ' + acquisitionPatentFamilies + '.###');
        
        //finally we can loop through acquisitionPatentFamilies and build our delete list
        for (Acquisition_Patent_Families__c apf:acquisitionPatentFamilies)
            if (!acquisitionRemainingPatentFamilyMap.containsKey(apf.Acquisition_Opportunity__c) || !acquisitionRemainingPatentFamilyMap.get(apf.Acquisition_Opportunity__c).contains(apf.Patent_Family__c)) // then this pfamily has no remainin children in thisd acquisition, so delete it!
                acquisitionPatentFamiliesToDelete.add(apf);
        
        //do the deletion (if needed)
        if (acquisitionPatentFamiliesToDelete.size() > 0) {
            system.debug('###afterOMAPatentDelete(): About to delete acquisitionPatentFamiliesToDelete = ' + acquisitionPatentFamiliesToDelete + '.###');
            delete acquisitionPatentFamiliesToDelete;
        }
        
        system.debug('###afterOMAPatentDelete(): Exiting function.###');
    }
    
    
    /*
    HRT.4.13 >> Decided to scrap the old version (below) of the function and copy my version (above) of the similar function from PatentsInSuitManagement.
                The version below will end up de-joining patent families from all acquisitions in the entire batch even if they should
                only be de-joined from one acquisition in the batch.
                
    public static void afterOMAPatentDelete(Map<Id, OMA_Patent__c> ptMap) {
        // After a patent is de-joined from an acquisition, this function checks 
        // for patent families that also need to be de-joined. 
        // HRT.4.13: Fixed record-deleting logic to make it bulk-compatible. Added debug statements, cleaned up formatting.
        
        Set<Id> deletedPatentIds = new Set<Id>();
        Set<Id> acqOppIds = new Set<Id>();
        
        for (OMA_Patent__c pt : ptMap.values()) {
            deletedPatentIds.add(pt.Patent__c);
            acqOppIds.add(pt.Acquisition_Opportunity__c );
        }
        
        //fetch deleted patents families
        Map<Id, Id> deletedPTFamilyMap = fetchPatentAndFamily(deletedPatentIds);
        
        //fetch other patents in AcqOpp
        Map<Id, Set<Id>> acqAndOtherPatentMap = fetchAcqPatents(acqOppIds, deletedPatentIds);
        
        //populate other patents Set
        Set<Id> otherPatentIds = new Set<Id>();
        for (Set<Id> patentIds : acqAndOtherPatentMap.values()) {
            otherPatentIds.addAll(patentIds);
        }
        
        Set<Id> acqToDelete = new Set<Id>();
        Set<Id> familiesToDelete = new Set<Id>();
        
        //fetch other Patent Families
        Map<Id, Id> OtrPTAndFamilyMap = fetchPatentAndFamily(otherPatentIds);
        
        for (OMA_Patent__c pt : ptMap.values()) {
            Set<Id> otherPtFamilyIds = new Set<Id>();
            Id familyId;
            
            //fetch families related to deleted patent
            if (deletedPTFamilyMap.containsKey(pt.Patent__c))
                familyId = deletedPTFamilyMap.get(pt.Patent__c);
            
            //fetch families related to other patents of acquisition
            if (acqAndOtherPatentMap.containsKey(pt.Acquisition_Opportunity__c))
                for (Id otrPatentId : acqAndOtherPatentMap.get(pt.Acquisition_Opportunity__c))
                    if (otrPTAndFamilyMap.containsKey(otrPatentId))
                        otherPtFamilyIds.add(OtrPTAndFamilyMap.get(otrPatentId));
            
            //delete family if no other patent contain it
            if (familyId != null && !otherPtFamilyIds.contains(familyId)) {
                //lstAcqFamiliesToDelete.add(new Acquisition_Patent_Families__c(Id = family));
                acqToDelete.add(pt.Acquisition_Opportunity__c);
                familiesToDelete.add(familyId);
            }
        }
        
        delete [Select id From Acquisition_Patent_Families__c Where Patent_Family__c in :familiesToDelete And Acquisition_Opportunity__c in :acqToDelete];
            
    }
    */
  
  //---------------Utility Methods-----------------------------------------
  
  //get Patent Ids from OMA Patent except given patentIds
  //Map<AcqOppId,Set<OtherPatentIds>>
  private static Map<Id, Set<Id>> fetchAcqPatents(Set<Id> acqIds, Set<Id> ptToExclude) {
  	Map<Id, Set<Id>> acqOppAndPatentMap = new Map<Id, Set<Id>>();
  	
  	for (OMA_Patent__c pt : [Select id, Patent__c, Acquisition_Opportunity__c
								  	         From OMA_Patent__c
								  	         Where Acquisition_Opportunity__c in :acqIds
								  	         And Patent__c not in :ptToExclude]) {
  		
  		if(!acqOppAndPatentMap.containsKey(pt.Acquisition_Opportunity__c)) {
  			acqOppAndPatentMap.put(pt.Acquisition_Opportunity__c, new Set<Id>());
  		}
  		
  		acqOppAndPatentMap.get(pt.Acquisition_Opportunity__c).add(pt.Patent__c);
  		
  	}
  	return acqOppAndPatentMap;
  }
  
  
  //Patent and Family Ids Map
  private static Map<Id, Id> fetchPatentAndFamily(Set<Id> patentIds) {
  	Map<Id, Id> patentFamilyMap = new Map<Id, Id>();
  	for (Patent__c pt : [Select id, Patent_Family__c
  	                     From Patent__c
  	                     Where Id in :patentIds]) {
  	  
  	  patentFamilyMap.put(pt.Id, pt.Patent_Family__c);
  		
  	}
    return patentFamilyMap;
  }
  
  //acqOpp and familyIds Map
  private static Map<Id, Set<Id>> fetchAcqOppAndFamily(Set<Id> acqOppIds) {
    Map<Id, Set<Id>> acqFamilyMap = new Map<Id, Set<Id>>();
    for (Acquisition_Patent_Families__c acqFamily : [Select id, Acquisition_Opportunity__c, Patent_Family__c
					                                           From Acquisition_Patent_Families__c
					                                           Where Acquisition_Opportunity__c in :acqOppIds]) {
      
      if(!acqFamilyMap.containsKey(acqFamily.Acquisition_Opportunity__c)) {
        acqFamilyMap.put(acqFamily.Acquisition_Opportunity__c, new Set<Id>());
      }
      acqFamilyMap.get(acqFamily.Acquisition_Opportunity__c).add(acqFamily.Patent_Family__c);
      
    }
    return acqFamilyMap;
  }

}