/****************************************************************************************************************************
 * Name             : AcquisitionOpportunityUtility
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 10 Jan, 2012.
 * Purpose          : Utility Class used by other classes 
 * Last Updated     : 10/23/13 by Hank Ryan Thompson
****************************************************************************************************************************/

public without sharing class AcquisitionOpportunityUtility {
    private static String RECORD_TYPE_OMA = 'OMA';
    private static String RECORD_TYPE_LITIGATION = 'Litigations';
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Ligitagions ids related to given Patent Families
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> getLitigationForPTFamilies(Set<Id> ptFamilyIds) {
        Set<Id> litigationIds = new Set<Id>();
        for (Litigation_Patent_Family__c lPF : [Select Litigation__c, Patent_Family__c 
                                                From Litigation_Patent_Family__c 
                                                Where Patent_Family__c in :ptFamilyIds and Litigation__c != null]) {
            litigationIds.add(lPF.Litigation__c);                                                                            
        }
        return litigationIds;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Acquisition Opportunity ids related to given Litigations
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> getAcqOppForLitigation(Set<Id> litigationIds) {
        Set<Id> acqIds = new Set<Id>();
         //Find the Litigations for Acquisition Opportunities
        for (Opportunity_Litigation__c oppLitigation : [Select id, Litigation__c, Acquisition_Opportunity__c 
                                                        From Opportunity_Litigation__c 
                                                        Where Litigation__c IN :litigationIds And Acquisition_Opportunity__c != null]) {
            acqIds.add(oppLitigation.Acquisition_Opportunity__c);
        }
        return acqIds;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Acquisition Opportunity ids related to given Litigations
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id,Set<Id>> getAcqOppLitigationMap(Set<Id> litigationIds) {
        Map<Id,Set<Id>> acqOppLitigationMap = new Map<Id,Set<Id>>();
         //Find the Litigations for Acquisition Opportunities
        for (Opportunity_Litigation__c oppLitigation : [Select id, Litigation__c, Acquisition_Opportunity__c 
                                                        From Opportunity_Litigation__c 
                                                        Where Litigation__c IN :litigationIds
                                                        And Litigation__r.Active_or_Closed__c = 'Active' And Acquisition_Opportunity__c != null]) {
                                                                                                            
                                    
            if(!acqOppLitigationMap.containsKey(oppLitigation.Acquisition_Opportunity__c)){
                acqOppLitigationMap.put(oppLitigation.Acquisition_Opportunity__c,new Set<Id>());
            }
            acqOppLitigationMap.get(oppLitigation.Acquisition_Opportunity__c).add(oppLitigation.Litigation__c);
        }
        return acqOppLitigationMap;
    }
    
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Return Acquisition Opportunity Ids related to given patent families
    //-------------------------------------------------------------------------------------------------------------------------------
    public static set<Id> getAcqOppForPatentFamily(Set<Id> patentFamilyIds) {
        Set<Id> acqIds = new Set<Id>();
        
        for (Acquisition_Patent_Families__c acqPf : [ Select Acquisition_Opportunity__c, Patent_Family__c 
	                                                    From Acquisition_Patent_Families__c 
	                                                    Where Patent_Family__c in :patentFamilyIds And Acquisition_Opportunity__c != null]) {
            acqIds.add(acqPf.Acquisition_Opportunity__c);
        }
        Set<Id> litigationIds = getLitigationForPTFamilies(patentFamilyIds);
        Set<Id> litAcqIds = getAcqOppForLitigation(litigationIds);
        acqIds.addAll(litAcqIds);
        return acqIds;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Return Acquisition Opportunity Ids related to given products
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> getAcqOppForProducts(Set<Id> productIds) {
        Set<Id> acqIds = new Set<Id>();
        Set<Id> prodFamilyIds = new Set<Id>();
        
        //Fetch patent Families that are associated with given products
        for (portfolio2product__c familyToProduct : [ Select Portfolio__c 
	                                                    From portfolio2product__c 
	                                                    Where Product_or_Service__c in :productIds And portfolio__c != null] ) {
            prodFamilyIds.add(familyToProduct.Portfolio__c);
        }
        acqIds = getAcqOppForPatentFamily(prodFamilyIds);
        return acqIds;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns accountsIds related to products 
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> getAccountIdsForProducts(Set<Id> prodIds) {
        Set<Id> accIds = new Set<Id>();
        for(account2product__c acc2p: [ Select id, Account__c 
                                        From account2product__c 
                                        Where Product_or_Service__c in : prodIds And Account__c != null]) {
            accIds.add(acc2p.Account__c);
        }
        return accIds;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Patent Family ids related to Ligitagions
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id,Set<Id>> getLitigationAndPTFamily(Set<Id> litigationIds) {
        Map<Id, Set<Id>> litigationAndFamilyMap = new Map<Id, Set<Id>>(); 
        //Find the Litigations for Acquisition Opportunities
        for (Litigation_Patent_Family__c lPF :  [   Select Patent_Family__c, Litigation__c 
                                                    From Litigation_Patent_Family__c 
                                                    Where Litigation__c in :litigationIds And Patent_Family__c != null 
                                                    Order by LastModifiedDate desc]) {
            if(!litigationAndFamilyMap.containsKey(lPF.Litigation__c)) {
                litigationAndFamilyMap.put(lPF.Litigation__c, new Set<Id>());
            }
            litigationAndFamilyMap.get(lPF.Litigation__c).add(lPF.Patent_Family__c);
        }
        return litigationAndFamilyMap;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Return Acquisition Opportunity and Patent Map only for OMA Opportunities
    //-------------------------------------------------------------------------------------------------------------------------------   
    public static Map<Id, List<Patent__c>> getOMAAcqOppAndPatentMap (Set<Id> acqOppIds) {
        Set<Id> allFamilyIds = new Set<Id>();
        Map<Id, List<Patent__c>> acqOppAndPatentMap = new Map<Id, List<Patent__c>>();
        
        //fetch all families related to given acq oppty.
        Map<Id, Set<Id>> acqOppFamilyMap = getOMAAcqOppFamilyMap(acqOppIds);
        
        for(Set<Id> familyIds : acqOppFamilyMap.values()) {
            allFamilyIds.addAll(familyIds);
        } 
        
        //get family patent map for families
        Map<id,List<Patent__c>> familyPatentMap = getFamilyPatentMap(allFamilyIds);
        for(Id acqOppId : acqOppFamilyMap.keySet()) {
            for(Id familyId : acqOppFamilyMap.get(acqOppId)) {
                if(familyPatentMap.containsKey(familyId)) {
                    if(!acqOppAndPatentMap.containsKey(acqOppId)) {
                        acqOppAndPatentMap.put(acqOppId, new List<Patent__c> ());
                    }
                    acqOppAndPatentMap.get(acqOppId).addAll(familyPatentMap.get(familyId));
                }
            }
        }
        return acqOppAndPatentMap;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns AcquisitonOpportunity Family Map for OMA Record Type
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id, Set<Id>> getOMAAcqOppFamilyMap(Set<Id> acqOppIds) {
        Map<Id, Set<Id>> acqOppFamilyMap = new Map<Id, Set<Id>>();
        //Fetch OMA Opportunities that have the Patent Families associated to the patent families.  
        for (Acquisition_Patent_Families__c acqOppFamily : [Select Acquisition_Opportunity__c, Patent_Family__c 
                                                            From Acquisition_Patent_Families__c 
                                                            Where Acquisition_Opportunity__c in :acqOppIds And Patent_Family__c != null]) {
            if(!acqOppFamilyMap.containsKey(acqOppFamily.Acquisition_Opportunity__c)) {
                acqOppFamilyMap.put(acqOppFamily.Acquisition_Opportunity__c, new Set<Id>());
            }
            acqOppFamilyMap.get(acqOppFamily.Acquisition_Opportunity__c).add(acqOppFamily.Patent_Family__c);
        }
        return acqOppFamilyMap;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Return Patent Family and Patents Map
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<id,List<Patent__c>> getFamilyPatentMap(Set<Id> familyIds) {
        Map<id,List<Patent__c>> familyAndPatentMap = new Map<id,List<Patent__c>>();
        for (Patent__c patent : [Select id, Name, Patent_Family__c
                                                         From Patent__c
                                                         Where Patent_Family__c in : familyIds]) {
            
            if(!familyAndPatentMap.containsKey(patent.Patent_Family__c)) {                          
                familyAndPatentMap.put(patent.Patent_Family__c, new List<Patent__c>());
            }
            familyAndPatentMap.get(patent.Patent_Family__c).add(patent);
        }
        return familyAndPatentMap;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Map of Litigation And Related Patent
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id, List<Patent__c>> getLitigationWithPatents (Set<Id> litIds) {
     Map<Id, Set<Id>> litigationAndFamilyMap = getLitigationAndPTFamily(litIds);
     Set<Id> allFamilies = new Set<Id>(); 
     for(Set<Id> familyIds : litigationAndFamilyMap.values()) {
         allFamilies.addAll(familyIds);
     }
     
     Map<id,List<Patent__c>> familyAndPatentMap = getFamilyPatentMap(allFamilies);
     Map<Id, List<Patent__c>> litigationPatentMap = new Map<Id, List<Patent__c>>();
     for(Id litId : litigationAndFamilyMap.keySet()) {
         if(litigationAndFamilyMap.containsKey(litId)) {
             for(Id pfId : litigationAndFamilyMap.get(litId)) {
                 if(!litigationPatentMap.containsKey(litId)) {
                     litigationPatentMap.put(litId, new List<Patent__c>());
                 }
                 if(familyAndPatentMap.containsKey(pfId)) {
                     litigationPatentMap.get(litId).addAll(familyAndPatentMap.get(pfId));
                 }
             }
         }
     }
     return litigationPatentMap;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Litigation ids related to Acquisition Opportunity
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id,Set<Id>> getLitAndAcqOppMap(Set<Id> acqOppIds) {
        Map<Id, Set<Id>> litigationAndAcqMap = new Map<Id,Set<Id>>();
        //Find the Litigations for Acquisition Opportunities
        for (Opportunity_Litigation__c oppLitigation : [Select id, Litigation__c, Acquisition_Opportunity__c
                                                        From Opportunity_Litigation__c
                                                        Where Acquisition_Opportunity__c in :acqOppIds And Litigation__c != null]) {
            if(!litigationAndAcqMap.containsKey(oppLitigation.Litigation__c)) {
                litigationAndAcqMap.put(oppLitigation.Litigation__c, new Set<Id> ());
            }
            litigationAndAcqMap.get(oppLitigation.Litigation__c).add(oppLitigation.Acquisition_Opportunity__c);
        }
        return litigationAndAcqMap;
    }
     
     
     //-------------------------------------------------------------------------------------------------------------------------
  //Returns Set of Litigation Ids related to acquisition opportunity
  //-------------------------------------------------------------------------------------------------------------------------
  public static Set<Id> getLitigationsForAcquisition(Set<Id> acqIds) {
    Set<Id> litigationIds = new Set<Id> ();
    for (Opportunity_Litigation__c oppLitigation : [Select id, Litigation__c
                                                    From Opportunity_Litigation__c
                                                    Where Acquisition_Opportunity__c in :acqIds And Litigation__c != null]) {
      litigationIds.add(oppLitigation.Litigation__c);
    }
    return litigationIds;
  }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Litigation ids related to Acquisition Opportunity 
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id,Set<Id>> getAcqOppAndLitigationMap(Set<Id> litigationIds) {
        //Set<Id> litigationIds = new Set<Id>();
        Map<Id, Set<Id>> acqAndlitigationMap = new Map<Id,Set<Id>>();

        //Find the Litigations for Acquisition Opportunities
        for (Opportunity_Litigation__c oppLitigation : [Select id, Litigation__c, Acquisition_Opportunity__c
                                                        From Opportunity_Litigation__c
                                                        Where Litigation__c in :litigationIds And Acquisition_Opportunity__c != null]) {
            
            if(!acqAndlitigationMap.containsKey(oppLitigation.Acquisition_Opportunity__c)) {
                    acqAndlitigationMap.put(oppLitigation.Acquisition_Opportunity__c, new Set<Id> ());
            }
         acqAndlitigationMap.get(oppLitigation.Acquisition_Opportunity__c).add(oppLitigation.Litigation__c);
        
        }
        return acqAndlitigationMap;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
        //Returns Map of Family and Related Acquisition Opportunity
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id, Set<Id>> getfamilyAndAcqOppMap(Set<Id> acqOppId) {
        Set<Id> litOppIds = new Set<Id> ();
        Map<Id, Set<Id>> mapPFAndAcqOpp = new Map<Id,Set<Id>>();
        
        List<Acquisition_Opportunity__c> lstAcqOpp = [Select id, Primary_Market_Sector__c, Name, RecordType.Name,   
                                                                        (Select Patent_Family__c, Acquisition_Opportunity__c
                                                                        From Acquisition_Opportunity_Patent_Families__r
                                                                        Where Patent_Family__c != null 
                                                                        Order by LastModifiedDate desc)
                                                        From Acquisition_Opportunity__c
                                                        Where id in :acqOppId];
                                                        
        for (Acquisition_Opportunity__c acqOpp : lstAcqOpp) {
            //IF Litigation
            if (acqOpp.RecordType.Name.equalsIgnoreCase(RECORD_TYPE_LITIGATION)) {
                litOppIds.add(acqOpp.Id);
            }
            //IF Others
            else{               
                for (Acquisition_Patent_Families__c acqPTFamily : acqOpp.Acquisition_Opportunity_Patent_Families__r) {
                    if(acqPTFamily.Patent_Family__c != null){
                        if (!mapPFAndAcqOpp.containsKey(acqPTFamily.Patent_Family__c) ) {
                            mapPFAndAcqOpp.put(acqPTFamily.Patent_Family__c, new Set<Id>());
                        }
                        mapPFAndAcqOpp.get(acqPTFamily.Patent_Family__c).add(acqOpp.Id);
                    }
                }
            }
        }
        
        Map<Id, Set<Id>> mapLitigationAndAcqOpp = new Map<Id, Set<Id>>(); 
        Map<Id, Set<Id>> mapLitAndFamilyIds = new Map<Id, Set<Id>>();
        
        mapLitigationAndAcqOpp = getLitAndAcqOppMap(litOppIds);
        mapLitAndFamilyIds = getLitigationAndPTFamily(mapLitigationAndAcqOpp.keySet());
        
        for(Id litId : mapLitAndFamilyIds.keySet()) {
            for (Id acqId : mapLitigationAndAcqOpp.get(litId)) {
                for(Id familyId : mapLitAndFamilyIds.get(litId)) {
                    if(familyId != null){
                        if(!mapPFAndAcqOpp.containsKey(familyId)) {
                            mapPFAndAcqOpp.put(familyId, new Set<Id>());
                        }
                        mapPFAndAcqOpp.get(familyId).add(acqId);
                    }
                }
            }
        }
        return mapPFAndAcqOpp;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns all acquisition Opportunities related to given Barker Model Account.AccountId
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> fetchAcqOppRelatedToBarkerModelAccount(Id accountId, Boolean includeInCheatSheet, String acqOppRecType, String acqOppStageName) {
        Set<Id> acqOppIds = new Set<Id> ();
        for(BarkerModelCalculation__c barkModel : 
            [Select b.Name, b.Include_in_Cheatsheet__c, b.Id, b.BarkerModel__r.AcquisitionOpportunity__c,
                            b.BarkerModel__r.AcquisitionOpportunity__r.name,BarkerModel__r.name,b.BarkerModel__r.AcquisitionOpportunity__r.Current_Status__c,
                            b.BarkerModel__r.AcquisitionOpportunity__r.Current_Status_SA__c 
             From BarkerModelCalculation__c b   
             Where Account__c = : accountId 
             And Include_in_Cheatsheet__c = :includeInCheatSheet 
             And BarkerModel__r.AcquisitionOpportunity__r.RecordType.Name = :acqOppRecType
             And BarkerModel__r.AcquisitionOpportunity__r.StageName__c != :acqOppStageName
             order by b.BarkerModel__r.AcquisitionOpportunity__r.name]){
                
                if(barkModel.BarkerModel__r.AcquisitionOpportunity__c != null) {
                    acqOppIds.add(barkModel.BarkerModel__r.AcquisitionOpportunity__c);
                }
            }
        return acqOppIds;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns all NPE Acquisition Opportunities related to given Barker Model Account.AccountId
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> fetchNPEAcquisitionOpportunity(Id accountId) {
        Set<Id> acqOppIds = new Set<Id> ();
        for(Non_Party_Entity__c npe : [Select Account__r.Name, Acquisition_Opportunity__c
                                                                     From Non_Party_Entity__c
                                                                     Where Account__c = :accountId And Acquisition_Opportunity__c != null]) {
            acqOppIds.add(npe.Acquisition_Opportunity__c);
        }
        return acqOppIds;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Litigations associated to given account through defendants.
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> getLitigationsForAccount(Id accountId) {
        Set<Id> litigationIds = new Set<Id>();
        
        for(Defendant__c defendant : [Select Id, Name, Litigation_ID__c, Date_Terminated__c, Defendant_Name__c
                                        From Defendant__c
                                        Where Account__c = :accountId
                                        And Litigation_ID__c != null
                                        ]) {
            litigationIds.add(defendant.litigation_Id__c);
        }
        return litigationIds; 
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Litigation Defendant Map for given Account
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id, List<Defendant__c>> getLitigationDefendantMap(Id accountId) {
        Set<Id> litigationIds = getLitigationsForAccount(accountId);
        Map<Id, List<Defendant__c>> litigationDefendantMap = new Map<Id, List<Defendant__c>>();
        for(Defendant__c defendant : [Select Id, Name, Litigation_ID__c, Date_Terminated__c, Defendant_Name__c, Account__r.Name
                                        From Defendant__c
                                        Where Litigation_ID__c in :litigationIds
                                        And Litigation_ID__r.Active_or_Closed__c = 'Active'
                                        And Date_Terminated__c = null
                                        And Account__c != null
                                        Order by Date_Terminated__c, Defendant_Name__c
                                        ]) {
            if(!litigationDefendantMap.containsKey(defendant.Litigation_ID__c)) {
                litigationDefendantMap.put(defendant.Litigation_ID__c, new List<Defendant__c>());
            }
            litigationDefendantMap.get(defendant.Litigation_ID__c).add(defendant);
        }
        return litigationDefendantMap;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Litigations Map
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id, Litigation__c> getLitigationMap(Set<Id> litIds) {
        Map<Id, Litigation__c> maplitigation = new Map<Id, Litigation__c>(); 
        for (Litigation__c litigation : [   Select Lead_Counsel_Firm__c, Filed__c, Acquisition_Opportunity__c, Docket_Number__c, Court__c, Case_Status__c, Case_Name__c,Case_Phase__c,
                                                    (Select id, Patent__r.Name, Patent__r.Title__c, Patent__r.Patent_No__c
                                                     From Patents_in_Suit__r)   
                                                    From Litigation__c
                                                    Where id in : litIds
                                                    Order by Court__c asc]) {
            maplitigation.put(litigation.Id, litigation);
        }
        return maplitigation;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Acquisition Opportunity 
    //-------------------------------------------------------------------------------------------------------------------------------
    public static List<Acquisition_Opportunity__c> getAcqusitionOpportunity(Set<Id> acqIds) {
        return [Select a.Who_cares__c, a.Summary__c, a.StageName__c, a.Source__c,a.Source__r.Name, a.SellersExplicitExpectation__c,
                             a.Scariness__c, a.Priority__c, a.Phase_0_Comments__c, a.NextStep__c, a.Name,   
                             a.Degree_of_Dialogue__c, a.Deal_Probability__c, a.Deal_Notes__c, a.Current_Status__c, a.Analysis_explanation__c,Suit_Ranking__c,
                             a.Account__c,recordtype.name,Quick_opinion__c ,Account__r.Name,
                             (Select id, Patent__r.Name,Patent__r.Title__c, Patent__r.Patent_No__c
                                From OMA_Patents__r
                                Order by Patent__r.Patent_No__c, Patent__r.Title__c),
                             (Select Date_Terminated__c, Defendant_Name__c 
                                From Defendants__r
                                Where Account__c != null Order by Date_Terminated__c, Defendant_Name__c)
                From Acquisition_Opportunity__c a 
                Where id in : acqIds
                Order by Name];
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Return all related family ids
    //-------------------------------------------------------------------------------------------------------------------------------
    public static set<Id> getPatentFamiliesForAcqOppty(Id acqOppId) {
        Map<Id, Set<Id>> familyAndAcqMap = getfamilyAndAcqOppMap(new Set<Id>{acqOppId});
        if(familyAndAcqMap != null) {
         return familyAndAcqMap.keySet();
        } 
        return null;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    // Returns Patent Family and Latest Summary Update Date 
    //-------------------------------------------------------------------------------------------------------------------------------
    public static List<AggregateResult> getPatentFamilySummaryHistory(Set<Id> patentFamilyIds) {
        List<AggregateResult> lstPFSummaryHistory = 
            [ Select a.ParentId, Max(CreatedDate) latestHistoryDate
                From Assets__History a
                Where parentId in : patentFamilyIds
                And Field = 'Summary__c'
                group by ParentId
                Order by Max(CreatedDate)];
        
        return lstPFSummaryHistory;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    // Returns Patent Family Representative_Claims__c latest update history
    //-------------------------------------------------------------------------------------------------------------------------------
    public static List<AggregateResult> getPatentFamilyRepClaimHistory(Set<Id> patentFamilyIds) {
        List<AggregateResult> lstPFSummaryHistory = 
            [ Select a.ParentId, Max(CreatedDate) latestHistoryDate
                From Assets__History a
                Where parentId in : patentFamilyIds
                And Field = 'Representative_Claims__c'
                group by ParentId
                Order by Max(CreatedDate)];
        
        return lstPFSummaryHistory;
    }
    
    
    //-------------------------------------------------------------------------------------------------------------------------------
    // Returns Patent Family Representative_Claims__c latest update history
    //-------------------------------------------------------------------------------------------------------------------------------
    public static List<AggregateResult> getPatentFamilyCharClaimHistory(Set<Id> patentFamilyIds) {
        List<AggregateResult> lstPFSummaryHistory = 
            [ Select a.ParentId, Max(CreatedDate) latestHistoryDate
                From Assets__History a
                Where parentId in : patentFamilyIds
                And Field = 'Characterization_of_Claims__c'
                group by ParentId
                Order by Max(CreatedDate)];
        
        return lstPFSummaryHistory;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Family Map
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<Id, Assets__c> getPatentFamilyMap(Set<Id> allFamilyIds) {
        return new Map<Id, Assets__c>([Select  Id, Earliest_priority__c, Expiration_Date__c, LastModifiedBy.Name,Name,
                                        Summary__c, Representative_Claims__c, LastModifiedDate,
                                        No_of_Non_US_Patents__c, No_of_Non_U_S_Applications__c,
                                        Number_of_US_Patents__c, Number_of_US_Applications__c,
                                        Characterization_of_Claims__c
                                        From Assets__c
                                        Where Id in :allFamilyIds
                                        Order by LastModifiedDate desc]
                                      );
    }   
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Return list of litigation along with defandents in ascending order of name
    //-------------------------------------------------------------------------------------------------------------------------------
    public static List<Litigation__c> getLitigationWithDefendant(Set<Id> litIds){
        return [Select l.Lead_Counsel_Firm__c, l.Filed__c, l.Docket_Number__c, l.Court__c,
                            l.Case_Status__c, l.Case_Name__c,Case_Phase__c, 
                            (Select Date_Terminated__c, Defendant_Name__c 
                             From Defendants__r 
                             Order by Defendant_Name__c)
                    From Litigation__c l 
                    where id in : litIds
                    Order by Court__c asc];
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Return Ids of open Acquisition Opportunities
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Set<Id> getOpenAcquisitionIds(Set<Id> acqIds) {
        Set<Id> openAcqIds = new Set<Id> ();
        List<String> closedStages = Label.ClosedAcquisitionOpportunityStages.split(',');
        for(Acquisition_Opportunity__c acqOpp : [Select id From Acquisition_Opportunity__c Where id in:acqIds and StageName__c not in :closedStages]) {
            openAcqIds.add(acqOpp.Id);
        }
        return openAcqIds;
    }
    
    //--------------------------------------------------------------------------------------------------------------------------------------------------
    // NOTE: This function will generally be called as future because history will be created after completion of trigger execution.
    //       But if called from a batch (or future) context, the function will be executed now, since firing future functions will result in an error.
    //       >> Updates made by Hank Thompson on 7/30/13 as part of SyncEngineChangeProcessor.
    //--------------------------------------------------------------------------------------------------------------------------------------------------
    public static void updateAcquisitionSummaryFields(Set<Id> acqIds, Set<Id> pfIdsToExclude) {
        //We only need to update Open Acquisition Opportunities
        //Commented by Neeraj 04 May 2012, As per Katy's email we need to update all acquisition regardless of their stage.
        //acqIds = getOpenAcquisitionIds(acqIds);
        // This function was updated by Hank Ryan Thompson on 9/12/13
        
        //Fetch all acquisition Opportunity along with all their families
        Map<Id,Set<Id>> patentFamilyAcquisitionIdMap = getfamilyAndAcqOppMap(acqIds); // maps from pf id to set of related acquisition ids
        Map<Id,Set<Id>> acquisitionPatentFamilyIdMap = new Map<Id,Set<Id>>(); //
        
        for (Id pfId : patentFamilyAcquisitionIdMap.keySet()) {
            for(Id acqId : patentFamilyAcquisitionIdMap.get(pfId)) {
                if (!acquisitionPatentFamilyIdMap.containsKey(acqId)) {                
                    acquisitionPatentFamilyIdMap.put(acqId, new Set<Id>());
                }
                acquisitionPatentFamilyIdMap.get(acqId).add(pfId);
            }
        }
        
        //system.debug(LoggingLevel.ERROR, '###updateAcquisitionSummaryFields(): Entering with acqIds = ' + acqIds + ', acquisitionPatentFamilyIdMap = ' + acquisitionPatentFamilyIdMap + ', patentFamilyAcquisitionIdMap = ' + patentFamilyAcquisitionIdMap + ', pfIdsToExclude = ' + pfIdsToExclude + '.###');
        
        Map<Id, Assets__c> mapPatentFamily = getPatentFamilyMap(patentFamilyAcquisitionIdMap.keySet());
        Map<Id, Acquisition_Opportunity__c> acquisitionsToUpdateMap = new Map<Id, Acquisition_Opportunity__c>();
        
        buildSummaryField('Summary__c', getPatentFamilySummaryHistory(patentFamilyAcquisitionIdMap.keySet()), patentFamilyAcquisitionIdMap, mapPatentFamily, pfIdsToExclude, acquisitionsToUpdateMap);
        buildSummaryField('Representative_Claims__c', getPatentFamilyRepClaimHistory(patentFamilyAcquisitionIdMap.keySet()), patentFamilyAcquisitionIdMap, mapPatentFamily, pfIdsToExclude, acquisitionsToUpdateMap);
        buildSummaryField('Characterization_of_Claims__c', getPatentFamilyCharClaimHistory(patentFamilyAcquisitionIdMap.keySet()), patentFamilyAcquisitionIdMap, mapPatentFamily, pfIdsToExclude, acquisitionsToUpdateMap);
        updateAcqOppDateFields(acquisitionPatentFamilyIdMap, mapPatentFamily, pfIdsToExclude, acquisitionsToUpdateMap);
        
        if (!acquisitionsToUpdateMap.isEmpty()) { 
            // First run through and clip the fields if needed (So they are not over the maximum text field length)
            for (Acquisition_Opportunity__c a:acquisitionsToUpdateMap.values()) {
                if ((a.Characterization_of_Claims__c != null) && (a.Characterization_of_Claims__c.length() > 32768)) a.Characterization_of_Claims__c = a.Characterization_of_Claims__c.substring(0, 32768);
                if ((a.Representative_Claims__c != null) && (a.Representative_Claims__c.length() > 32768)) a.Representative_Claims__c = a.Representative_Claims__c.substring(0, 32768);
                if ((a.Summary__c != null) && (a.Summary__c.length() > 32768)) a.Summary__c = a.Summary__c.substring(0, 32768);
            }
            
            // Now commit the update to the DB
            update acquisitionsToUpdateMap.values();
        }
        
        //system.debug(LoggingLevel.ERROR, '###updateAcquisitionSummaryFields(): Done updating acquisitionsToUpdateMap  = ' + acquisitionsToUpdateMap + '.###');
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //update Summary field for Acquisition Opportunity 
    //-------------------------------------------------------------------------------------------------------------------------------
    public static void buildSummaryField(String summaryFieldName, List<AggregateResult> fieldHistory, Map<Id,Set<Id>> patentFamilyAcquisitionIdMap, Map<Id,Assets__c> mapPatentFamily, Set<Id> pfIdsToExclude, Map<Id, Acquisition_Opportunity__c> acquisitionsToUpdateMap) {
        // Builds the specified summary field on the acquisition by concatenating the values of the same field on the related patent family records.
        //     [fieldHistory] should be the appropriate list of aggregated history results (grouped by parentid, ordered by max createddate)
        //     [summaryFieldName] should be the name of the summary field on both the acquisition AND patent family records
        // REBUILT by Hank Ryan Thompson on 9/12/13
        
        Id patentFamilyId;
        Acquisition_Opportunity__c acquisition;
        Assets__c patentFamily;
        Map<Id, Date> latestHistoryDateMap = new Map<Id, Date>(); // maps from patent family id to the latest update date from the patentFamilyHistory
        Date latestHistoryDate;
        
        //system.debug(LoggingLevel.ERROR, '###buildSummaryField(): Entering with patentFamilyAcquisitionIdMap  = ' + patentFamilyAcquisitionIdMap + ', mapPatentFamily  = ' + mapPatentFamily + ', fieldHistory  = ' + fieldHistory + ', summaryFieldName = ' + summaryFieldName + '.###');
        
        // First let's run through the patent family history and extract the date information (which is the only reason we're using the history)
        // NOTE: The history information may be MISSING for items which were updated in this transaction, in that case we'll sub in today's date
        for (AggregateResult patentFamilyHistory:fieldHistory) {
            patentFamilyId = (Id)truncateTofifteenDigit(patentFamilyHistory.get('parentId'));
            latestHistoryDateMap.put(patentFamilyId, Date.valueOf(patentFamilyHistory.get('latestHistoryDate')));
        }

        // Now run through all of the patent families in the map and build out the summary field
        for (Id pfId:mapPatentFamily.keySet()) 
            if ((pfIdsToExclude == null) || !pfIdsToExclude.contains(pfId)) {
                for (Id acqId:patentFamilyAcquisitionIdMap.get(pfId)) {
                    if (!acquisitionsToUpdateMap.containsKey(acqId)) acquisitionsToUpdateMap.put(acqId, new Acquisition_Opportunity__c(Id = acqId, Summary_fields_Updated__c = Date.today()));
                    acquisition = acquisitionsToUpdateMap.get(acqId);
                    patentFamily = mapPatentFamily.get(pfId);
                    latestHistoryDate = latestHistoryDateMap.get(pfId);
                    if (latestHistoryDate == null) latestHistoryDate = Date.today();

                    if (acquisition.get(summaryFieldName) == null) acquisition.put(summaryFieldName, '');
                    if (patentFamily.get(summaryFieldName) != null) {
	                    // Append the current summary to the existing value
	                    acquisition.put(summaryFieldName, createSummaryMessage(patentFamily.Name, (String)patentFamily.get(summaryFieldName), latestHistoryDate, patentFamily.LastModifiedBy.Name) + acquisition.get(summaryFieldName));
                    }
                }
            }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Creates Summary Message Format
    //-------------------------------------------------------------------------------------------------------------------------------
    public static String createSummaryMessage(String pfName, String pfFieldValue, Date latModifiedDate, String lastModifiedBy) {
        if(!pfFieldValue.equals('') || pfFieldValue != null){
            String summaryStr = latModifiedDate.format() + ' - ' + lastModifiedBy + '\n\n'
                             + 'Patent Family ' + pfName + ' \n ' + pfFieldValue + '\n\n'
                             + '-------------------------------------------\n\n';
            return summaryStr;
        }
        return '';
    }
    
    //----------------------------------------------------------------------------------
    //Update Earliest_priority__c & Expiration_Date__c field for Acquisition Opportunity
    //----------------------------------------------------------------------------------
    public static void updateAcqOppDateFields(Map<Id,Set<Id>> AcqOppAndPFIdsMap,
                                                Map<Id,Assets__c> mapPatentFamily,
                                                Set<Id> pfIdsToExclude,
                                                Map<Id, Acquisition_Opportunity__c> mapAcqOppToUpdt) {
        //For Date Fields
        for(Id acqId : AcqOppAndPFIdsMap.keySet()) {
            if(!mapAcqOppToUpdt.containsKey(acqId)) {
                mapAcqOppToUpdt.put(acqId, new Acquisition_Opportunity__c(Id = acqId));
            }
            Acquisition_Opportunity__c acqOpp = mapAcqOppToUpdt.get(acqId);
            
            Date earliestPriority;
            Date expDate;
            for(Id patentFamilyId : AcqOppAndPFIdsMap.get(acqId)) {
                if(pfIdsToExclude != null && pfIdsToExclude.contains(patentFamilyId)) {
                     continue;  
                }
                if(mapPatentFamily.containsKey(patentFamilyId)) {
	                Assets__c pf = mapPatentFamily.get(patentFamilyId);
	                //Earliest_priority__c
	                if (pf.Earliest_priority__c != null) {
	                    if (earliestPriority == null) {
	                        earliestPriority = pf.Earliest_priority__c;
	                    } else if(earliestPriority > pf.Earliest_priority__c) {
	                        earliestPriority = pf.Earliest_priority__c;
	                    }
	                }
	                //Expiration Date
	                if (pf.Expiration_Date__c != null) {
	                    if (expDate == null) {
	                        expDate = pf.Expiration_Date__c;
	                    } else if(expDate < pf.Expiration_Date__c) {
	                        expDate = pf.Expiration_Date__c;
	                    }
	                }
                }
            }
            acqOpp.Expiration_Date__c = expDate;
            acqOpp.Earliest_priority__c = earliestPriority;
        }                                                                                               
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Truncate Ids to 15 digit
    //-------------------------------------------------------------------------------------------------------------------------------
    public static String truncateTofifteenDigit(Object id) {
        String parentId = String.valueOf(id);
        if(parentId.length() == 18) {
            parentId = parentId.substring(0, 15);
        }
        return parentId;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns true if field value is changed
    //-------------------------------------------------------------------------------------------------------------------------------
    public static boolean isNewOrChanged(sObject newRecord, Map<Id, sObject> oldMap, String fieldName) {
        // if no old map or no corresponding value in old map, return true
        if (oldMap == null || !oldMap.containsKey(newRecord.Id))
        return true;
        
        // check for changed value
        return (
        oldMap.get(newRecord.Id).get(fieldName) != newRecord.get(fieldName));
    }
    
    //-------------------------------------------------------------------------------------------------------------------------------
    //Returns Map of Record Types for given object
    //-------------------------------------------------------------------------------------------------------------------------------
    public static Map<String, Id> getRecordType(String objectName) {
        Map<String,Id> recType = new Map<String,Id>();
        for (RecordType rType : [Select Id, Name
                                 From RecordType
                                 Where SobjectType = :objectName]) {
            recType.put(rType.Name, rType.Id);
        }
        return recType;
     }
    
}