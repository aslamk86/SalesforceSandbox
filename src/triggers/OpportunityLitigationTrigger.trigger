/*
    Trigger :OpportunityLitigitionTrigger
    Description :Used To insert Acquisition_Opportunity_Defendant__c on event(Insert ,Delete) of Opportunity Litigition.
    Created By : Bharti (Appirio Offshore)
    Last Modified date : Feb 8,2012
*/
trigger OpportunityLitigationTrigger on Opportunity_Litigation__c (after insert,after delete,after update) {
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            OpportunityLitigationManagement.afterOpportunityLitigationInsert(trigger.newMap);
        }
        
        if(Trigger.isDelete) {
		      OpportunityLitigationManagement.afterOpportunityLitigationDelete(trigger.oldMap);
		    }
		    
		    if(Trigger.isUpdate) {
		    	OpportunityLitigationManagement.afterOpportunityLitigationUpdate(trigger.oldMap,trigger.newMap);
		    }
    
    }
    
    //Set of all litigitions Id ;
    Set<Id> litigitionIds = new Set<Id>();
    Set<Id> defendantIds = new Set<Id>();
    Set<Id> acqOppIds = new Set<Id>();
    Set<Id> openAcqOppIds = getOpenAcquisitionOpportunityIds();
    //Acquisition Opportunity Defendant List To be insert
    List<Acquisition_Opportunity_Defendant__c> listAOD = new List<Acquisition_Opportunity_Defendant__c>();
    
    if(Trigger.isUpdate || Trigger.isDelete){
        set<Id> updatedLitigitionIds = new Set<Id>();
        Set<Id> acqOppUpdatesIds = new Set<Id>();
        for(Opportunity_Litigation__c oppLitigition :Trigger.old){
            if((Trigger.isUpdate && (oppLitigition.Acquisition_Opportunity__c != Trigger.newMap.get(oppLitigition.Id).Acquisition_Opportunity__c || oppLitigition.Litigation__c != Trigger.newMap.get(oppLitigition.Id).Litigation__c)) || Trigger.isDelete){
                updatedLitigitionIds.add(oppLitigition.Litigation__c);
                acqOppUpdatesIds.add(oppLitigition.Acquisition_Opportunity__c);
            }
        }
        Map<Id,Litigation__c> mapLitigition = new Map<Id,Litigation__c>([Select (Select Name From Defendants__r) From Litigation__c where Id IN :updatedLitigitionIds]);
        for(Id litigitionId :mapLitigition.keySet()){
            for(Defendant__c defendant :mapLitigition.get(litigitionId).Defendants__r){
                defendantIds.add(defendant.Id);
            }
        }
        delete [Select Id  From Acquisition_Opportunity_Defendant__c where Acquisition_Opportunity__c IN :acqOppUpdatesIds AND Defendant__c IN :defendantIds];
    
    }
    if(Trigger.isInsert || Trigger.isUpdate){
        for(Opportunity_Litigation__c oppLitigition : Trigger.New){
            if(oppLitigition.Acquisition_Opportunity__c!= null && openAcqOppIds.contains(oppLitigition.Acquisition_Opportunity__c) && (Trigger.isInsert || (Trigger.isUpdate && (oppLitigition.Acquisition_Opportunity__c != Trigger.oldMap.get(oppLitigition.Id).Acquisition_Opportunity__c || oppLitigition.Litigation__c != Trigger.oldMap.get(oppLitigition.Id).Litigation__c)) && oppLitigition.Litigation__c != null && oppLitigition.Acquisition_Opportunity__c != null)){
                litigitionIds.add(oppLitigition.Litigation__c);
            }
        }
        Map<Id,Litigation__c> mapLitigition = new Map<Id,Litigation__c>([Select (Select Name From Defendants__r) From Litigation__c where Id IN :litigitionIds]);
        for(Opportunity_Litigation__c oppLitigition : Trigger.New){
            if(oppLitigition.Litigation__c != null && oppLitigition.Acquisition_Opportunity__c!= null && mapLitigition.containsKey(oppLitigition.Litigation__c) && openAcqOppIds.contains(oppLitigition.Acquisition_Opportunity__c)){
                for(Defendant__c defendant :mapLitigition.get(oppLitigition.Litigation__c).Defendants__r){
                    //Create a Acquisition Opportunity Defendant record;
                    Acquisition_Opportunity_Defendant__c objectAOD = new Acquisition_Opportunity_Defendant__c();
                    objectAOD.Acquisition_Opportunity__c = oppLitigition.Acquisition_Opportunity__c;
                    objectAOD.Defendant__c = defendant.Id;
                    objectAOD.Defendant_Status__c = 'Open';
                    listAOD.add(objectAOD);
                }
            }
        }
        //Insert Acquisition Opportunity Defendant List
        insert listAOD; 
    }
    
// --- START REPLACED BY NEW VERSION ----------------------------------------------
//
// Martin Sieler: replaced by new version that also includes Closed Lost and 
// Closed Won acquisitions
//
/*
    public Set<Id> getOpenAcquisitionOpportunityIds(){
        if(Trigger.new != null){
            Set<Id> acqOpportunityIds = new Set<Id>();
            // Set<String> stages = new Set<String>{'Closed Lost','Closed Won'};
            for(Opportunity_Litigation__c oppLitigition : Trigger.new){
                if(Trigger.isInsert || (Trigger.isUpdate && oppLitigition.Acquisition_Opportunity__c != Trigger.oldMap.get(oppLitigition.Id).Acquisition_Opportunity__c)){
                    acqOpportunityIds.add(oppLitigition.Acquisition_Opportunity__c);
                }
            }
            return new Map<Id,Acquisition_Opportunity__c>([Select Id from Acquisition_Opportunity__c where ID IN :acqOpportunityIds AND StageName__c Not IN : stages AND ClonedFrom__c = null]).keyset();
        }
        return new Set<Id>();
    }
 */

//
// --- START OF NEW VERSION -------------------------------------------------------
//

		private Set<Id> getOpenAcquisitionOpportunityIds()
			{
			if(Trigger.new != null)
				{
				Set<Id> acqOpportunityIds = new Set<Id>();

				for(Opportunity_Litigation__c oppLitigition : Trigger.new)
					{
					if(Trigger.isInsert || (Trigger.isUpdate && oppLitigition.Acquisition_Opportunity__c != Trigger.oldMap.get(oppLitigition.Id).Acquisition_Opportunity__c))
						{
						acqOpportunityIds.add(oppLitigition.Acquisition_Opportunity__c);
						}
					}
				
				return new Map<Id,Acquisition_Opportunity__c>([Select Id from Acquisition_Opportunity__c where ID IN :acqOpportunityIds AND ClonedFrom__c = null]).keyset();
        }
        
			return new Set<Id>();
			}

// --- END REPLACED BY NEW VERSION ------------------------------------------------



}