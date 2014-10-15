/**************************************************************
* Name             : AutoFollowUtils
* Created By       : Tu Dao
* Created Date     : Oct 8, 2012.
* Purpose          : Utility methods used in Auto Follow Triggers
**************************************************************/
public class AutoFollowUtils {
    /*
    
    public static void updateAutoFollowAcquisitions(Set<Id> userIds){
        
        List<Acquisition_Opportunity_Defendant__c> aodToProcess = [
            SELECT Id, Account_Lookup__c, Acquisition_Opportunity__c, Account_Lookup__r.Owner.Id, Case_Status__c,Date_Terminated__c 
            FROM Acquisition_Opportunity_Defendant__c
            WHERE Account_Lookup__r.Owner.Id IN :userIds
            AND Account_Lookup__c != null
            AND Acquisition_Opportunity__c != null
            AND Case_Status__c != 'Closed'
            AND Date_Terminated__c = null
        ];
        
        Map<String, String> userAcqIds = new Map<String,String>();
        //Map of User Id & Accquisition Id
        //Map<Id,Id> userAcqIdMap = new Map<Id,Id>();
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> acqIds = new Set<Id>();
        //Find unique User - Acquisition pair
        for(Acquisition_Opportunity_Defendant__c aod : aodToProcess){
            String s = String.valueOf(aod.Account_Lookup__r.Owner.Id) + '_' +  String.valueOf(aod.Acquisition_Opportunity__c);
            if(!userAcqIds.containsKey(s)){
                userAcqIds.put(s, String.valueOf(aod.Acquisition_Opportunity__c));
                ownerIds.add(aod.Account_Lookup__r.Owner.Id);
                acqIds.add(aod.Acquisition_Opportunity__c);
                //userAcqIdMap.put(aod.Account_Lookup__r.Owner.Id, aod.Acquisition_Opportunity__c);
            }
        }
        Map<String,String> originalUserAcqIds = userAcqIds.clone();
        //check if subscription exists
        List<EntitySubscription> oldSubs = [
            SELECT Id, SubscriberId, ParentId
            FROM EntitySubscription 
            WHERE SubscriberId = :userIds AND ParentId = :acqIds
        ];
        
        //Existing subs map
        Map<Id, Id> oldSubMap = new Map<Id,Id>();
        for(EntitySubscription es : oldSubs){
            String s = String.valueOf(es.SubscriberId) + '_' + String.valueOf(es.ParentId);
            if(userAcqIds.containsKey(s)){
                userAcqIds.remove(s);
            }
        }
        
        //Insert new subscription
        List<EntitySubscription> subsToInsert = new List<EntitySubscription>();
        for(String userAcqId : userAcqIds.keySet()){
            subsToInsert.add(new EntitySubscription(SubscriberId=userAcqId.split('_')[0], ParentId=userAcqId.split('_')[1]));
        }
        
        insert subsToInsert;
        //if the Acquisition Opportunity Defendant field “Case Status” is changed to Closed OR there is a value in the “Date Terminated” field, then the user auto-unfollows that Acquisition record
        Set<Id> unfollows = new Set<Id>();
        List<EntitySubscription> subsToDelete = new List<EntitySubscription>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        String acqOppKeyPrefix = gd.get('Acquisition_Opportunity__c').getDescribe().getKeyPrefix();
        String query = 'SELECT Id, SubscriberId, ParentId FROM EntitySubscription WHERE SubscriberId IN :userIds';
        List<EntitySubscription> relatedSubs = Database.query(query);
        
        for(EntitySubscription es : relatedSubs){
            if(String.valueOf(es.ParentId).indexOf(acqOppKeyPrefix)==0 && !originalUserAcqIds.containsKey(String.valueOf(es.SubscriberId) + '_' + String.valueOf(es.ParentId))){
                subsToDelete.add(es);
            }
        }
        delete subsToDelete;
        
    }*
    
    /*
* Update Acquisition Subscriptions(follow/unfollow) when a list of Defendant are updated/deleted.
*//*
    public static void handleDefendantsChange(List<Defendant__c> dfList){
        List<Acquisition_Opportunity_Defendant__c> aodToProcess = [
            SELECT Id, Account_Lookup__r.Owner.Id 
            FROM Acquisition_Opportunity_Defendant__c
            WHERE Account_Lookup__c != null
            AND Defendant__c IN :(new Map<Id,Defendant__c>(dfList).keySet())];
        
        Set<Id> userIds = new Set<Id>();
        for(Acquisition_Opportunity_Defendant__c aod : aodToProcess){
            userIds.add(aod.Account_Lookup__r.Owner.Id);
        }
        
        Set<Id> autoFollowUserIds = getAutoFollowUsers(userIds);
        updateAutoFollowAcquisitions(autoFollowUserIds);
    }
    *
    /*
* Update Acquisition Subscriptions(follow/unfollow) when a list of Acquisition Opportunity are updated/deleted.
*//*
    public static void handleLitigationChange(List<Litigation__c> lgList){
        
        List<Acquisition_Opportunity_Defendant__c> aodToProcess = [
            SELECT Id, Account_Lookup__r.Owner.Id 
            FROM Acquisition_Opportunity_Defendant__c
            WHERE Defendant__c != null
            AND Defendant__r.Litigation_ID__c != null
            AND Account_Lookup__c != null
            AND Defendant__r.Litigation_ID__c IN :(new Map<Id,Litigation__c>(lgList).keySet())];
        
        Set<Id> userIds = new Set<Id>();
        for(Acquisition_Opportunity_Defendant__c aod : aodToProcess){
            userIds.add(aod.Account_Lookup__r.Owner.Id);
        }
        
        Set<Id> autoFollowUserIds = getAutoFollowUsers(userIds);
        updateAutoFollowAcquisitions(autoFollowUserIds);
        
    }
    */
    /*
* Update Acquisition Subscriptions(follow/unfollow) when a list of Acquisition Opportunity Defendant are inserted/deleted.
*//*
    public static void handleAcqOppDefendantsChange(List<Acquisition_Opportunity_Defendant__c> aodList){
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Acquisition_Opportunity_Defendant__c aod : aodList){
            if(aod.Account_Lookup__c != null){
                accountIds.add(aod.Account_Lookup__c);
            }
        }
        for(Account acc : [SELECT Id, OwnerId, Name FROM Account WHERE Id IN :accountIds]){
            userIds.add(acc.OwnerId);
        }
        
        Set<Id> autoFollowUserIds = getAutoFollowUsers(userIds);
        updateAutoFollowAcquisitions(autoFollowUserIds);   
        
    }
    */
    /*
* Get users in Auto Follow List
*//*
    public static Set<Id> getAutoFollowUsers(Set<Id> userIds){
        Set<Id> autoFollowUserIds = new Set<Id>();
        for(User usr : [SELECT Id, Auto_Follow_Acquisition__c, Name FROM User WHERE Id IN :userIds AND Auto_Follow_Acquisition__c=true]){
            autoFollowUserIds.add(usr.Id);
        }
        return autoFollowUserIds;
    }*/
    
    public static String OPP_INSURANCE_RECORD_TYPE = 'Insurance';
    
    /*
* Update Opp Subscriptions when a list of Opportunity are updated
*/
    public static void updateAutoFollowOpps(List<Opportunity> oppList){
        Set<String> oppStage = getOppLateStages();
        List<Opportunity> followedOpps = new List<Opportunity>();
        List<Opportunity> unfollowedOpps = new List<Opportunity>();
        //Create follow & unfollow list
        for(Opportunity opp : oppList){
            if(opp.RecordType__c==OPP_INSURANCE_RECORD_TYPE && (oppStage.contains(opp.StageName) || (opp.StageName == 'Initial Reach Out' && opp.Probability >= 11))){
                followedOpps.add(opp);
            }else if(opp.RecordType__c==OPP_INSURANCE_RECORD_TYPE){
                unfollowedOpps.add(opp);
            }
        }
        //Get users in auto follow list
        List<User> userList = [SELECT Id FROM User WHERE Auto_Follow_Opportunity__c=true];
        Set<Id> userIds = (new Map<Id, User>(userList)).keySet();
        
        List<EntitySubscription> subsToInsert = new List<EntitySubscription>();
        //Get existing list
        List<EntitySubscription> esList = [SELECT SubscriberId, ParentId FROM EntitySubscription WHERE ParentId IN :new Map<Id, SObject>(followedOpps).KeySet() AND SubscriberId IN :userIds];
        Map<Id, Set<Id>> existingList = new Map<Id, Set<Id>>();
            
        for(EntitySubscription item: esList){
            if(existingList.ContainsKey(item.SubscriberId)){
                existingList.Get(item.SubscriberId).Add(item.ParentId);
            }
            else{
                existingList.Put(item.SubscriberId, new Set<Id>{item.ParentId});
            }
        }
        //
        for(Id uId : userIds){
            for(Opportunity opp : followedOpps){
                if(!existingList.ContainsKey(uId) || !existingList.Get(uId).Contains(opp.Id)){
                    subsToInsert.add(new EntitySubscription(parentId = opp.Id, SubscriberId = uId));
                }
            }
        }
        upsert subsToInsert;
        
        List<EntitySubscription> subsToDelete = [
            SELECT Id 
            FROM EntitySubscription 
            WHERE ParentId IN :(new Map<Id,Opportunity>(unfollowedOpps)).keySet()
                AND SubscriberId IN :userIds
        ];
        delete subsToDelete;
    }
    /*
* Get Opportunity's late stages
*/
    public static Set<String> getOppLateStages(){
        Set<String> oppStage = new Set<String>();
        oppStage.add('Intro Meeting Scheduled');
        oppStage.add('Intro Meeting Held');
        oppStage.add('Application Pending');
        oppStage.add('Pricing & Underwriting');
        oppStage.add('Premium Quoting');
        oppStage.add('Pricing Meeting Held');
        oppStage.add('Pricing Indication Pending');
        return oppStage;
    }
}