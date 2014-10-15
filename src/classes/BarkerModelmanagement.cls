/*****************************************************************************
 * Name             : BarkerModelmanagement
 * Created By       : Bharti(Appirio Offshore)
 * Created Date     : 20 Jan, 2012.
 * Purpose          : Helper class for BarkerModelTrigger
*****************************************************************************/
public without sharing class BarkerModelmanagement {
   static Set<String> acqOppStages = AcqOpptyStagesForBarkerModelCalculation__c.getAll().keySet();
   static List<String> acqOppRecordTypes = Label.AcqOpptyRecordTypesForBarkerModelCalculation != null ? Label.AcqOpptyRecordTypesForBarkerModelCalculation.split(',') : new List<String>();
   static Set<String> accountRecotdTypes = new Set<String>{'Member','Prospect'};
		
  //------------------------------------------------
  //Recalculate memberCreditForPendingDeals for all accounts those are linked to the modified Barker model and save.
  //------------------------------------------------
	public static void updateMemberCreditOnAccount(Map<Id,BarkerModel__c> newMap,Map<Id,BarkerModel__c> oldMap){
		boolean isDelete = newMap == null;
		boolean isInsert = oldMap == null;
		
		
		//this method should fire only when a barker model is updated
		if(isInsert || isDelete) return;
				
	    //prepares list of models ids for those credit toggle is changed
		Set<Id> barkerModelIds = new Set<Id>();
		for(BarkerModel__c barkerModel:newMap.values()){
			if(barkerModel.Credit_Toggle__c != oldMap.get(barkerModel.Id).Credit_Toggle__c || barkerModel.Exclude_Pre_Contract_Credit__c != oldMap.get(barkerModel.Id).Exclude_Pre_Contract_Credit__c){
				barkerModelIds.add(barkerModel.Id);
			}
		}
		system.debug('Barker Model Ids ===='+barkerModelIds);
		//pull account and their all calculations records those are linked to the modified Barker model
		//recalculate memberCreditForPendingDeals for all account and save
		List<Account> accountsToUpdate = new List<Account>();
		for(Account parent : [Select (Select Name,Default_RPX_Credit_remaining_by_company__c,BarkerModel__r.Credit_Toggle__c,RPX_Value_Credit_Portfolio__c From Barker_Model_Calculations__r where BarkerModel__r.AcquisitionOpportunity__r.StageName__c Not IN :acqOppStages AND Do_not_Include_in_Calculations__c = false),
	                         Id, Remaining_Credit__c,Member_Credit_Remaining_No_Pre_Contrac__c From Account 
	                         where Id IN (Select Account__c From BarkerModelCalculation__c where BarkerModel__c IN :barkerModelIds And BarkerModel__r.AcquisitionOpportunity__r.StageName__c Not IN :acqOppStages And BarkerModel__r.AcquisitionOpportunity__r.RecordType.Name IN : acqOppRecordTypes)]){        
	        Decimal memberCreditForPendingDeals = 0;
	        Decimal remainingCredit = 0;
	        for(BarkerModelCalculation__c child : parent.Barker_Model_Calculations__r){
	        	remainingCredit = (newMap.containsKey(child.BarkerModel__c) && newMap.get(child.BarkerModel__c).Exclude_Pre_Contract_Credit__c ) ? parent.Member_Credit_Remaining_No_Pre_Contrac__c : parent.Remaining_Credit__c;
						memberCreditForPendingDeals += BarkerModelCalculationManagement.calculateMaxRPXValue(newMap.containsKey(child.BarkerModel__c)?newMap.get(child.BarkerModel__c).Credit_Toggle__c : child.BarkerModel__r.Credit_Toggle__c, child.RPX_Value_Credit_Portfolio__c ,remainingCredit , child.Default_RPX_Credit_remaining_by_company__c);
	        	system.debug('MemberCredit '+parent.Id+'***'+child.Name+'===='+memberCreditForPendingDeals);
	        }     
	        accountsToUpdate.add(new Account(Id = parent.Id, Member_Credit_used_for_pending_deals__c = memberCreditForPendingDeals));
	        
	    }
	    system.debug('Account to be update '+accountsToUpdate);
		if(accountsToUpdate.size()>0)
		   	update accountsToUpdate; 
	}
	
  //------------------------------------------------
  //Default insert of Barker Model Details - all defendants for all litigations related to that Litigation Acquisition Opportunity when the new Barker Model is created
  //------------------------------------------------
	public static void createDefaultCalculations(List<BarkerModel__c> newList){
		//Set of Acquisition Opportunities.
		Set<Id> acquisitionOpptyIds = new Set<Id>();
		//Populate the set of acq Opp Ids through barker models.
		for(BarkerModel__c barkerModel : newList){
			acquisitionOpptyIds.add(barkerModel.AcquisitionOpportunity__c);
		}
		//Map of Licensee's Accounts For the Outer Map key as acq Opp Id and value is another map(i.e. Map of account where kes as account Id and value as Account).
		Map<Id,Map<Id,Account>> mapLicenseeAccounts = new Map<Id,Map<Id,Account>>();
		//Map of Defendant's Accounts For the Outer Map key as acq Opp Id and value is another map(i.e. Map of account where kes as account Id and value as Account).
		Map<Id,Map<Id,Account>> mapDefendentAccounts = new Map<Id,Map<Id,Account>>();		
		//Map of Non Party Entity's Accounts For the Outer Map key as acq Opp Id and value is another map(i.e. Map of account where kes as account Id and value as Account).
		Map<Id,Map<Id,Account>> mapNonPartyAccounts = new Map<Id,Map<Id,Account>>();
		//Map of Potentially Relvent companies's Accounts For the Outer Map key as acq Opp Id and value is another map(i.e. Map of account where kes as account Id and value as Account).
		Map<Id,Map<Id,Account>> mapPotentiallyRelAccounts = new Map<Id,Map<Id,Account>>();
		//Method call to collect all relevent accounts of acq Opp to barker model
		collectAllRelevantAccounts(mapLicenseeAccounts,mapDefendentAccounts,mapNonPartyAccounts,mapPotentiallyRelAccounts,acquisitionOpptyIds);
		//All barker model Accounts to be create.
		Map<Id,BarkerModelCalculation__c> newBarkerModelCalculations = new Map<Id,BarkerModelCalculation__c> ();
		for(BarkerModel__c barkerModel : newList){
			createBarkerModelCalculationRecords(barkerModel,newBarkerModelCalculations,mapLicenseeAccounts,'Licensee');
			createBarkerModelCalculationRecords(barkerModel,newBarkerModelCalculations,mapDefendentAccounts,'Defendant');
			createBarkerModelCalculationRecords(barkerModel,newBarkerModelCalculations,mapNonPartyAccounts,'Non Party Entity');
			createBarkerModelCalculationRecords(barkerModel,newBarkerModelCalculations,mapPotentiallyRelAccounts,'Potentially Relevant Company');
		}
		//Fire Dml to Insert Barker Model Accounts.
		insert newBarkerModelCalculations.values();
		
	}
	//A method to collect all relevent accounts of acq Opp to barker model
	private static void collectAllRelevantAccounts(Map<Id,Map<Id,Account>> mapLicenseeAccounts,Map<Id,Map<Id,Account>> mapDefendentAccounts,
												   Map<Id,Map<Id,Account>> mapNonPartyAccounts,Map<Id,Map<Id,Account>> mapPotentiallyRelAccounts,
												   Set<Id> acquisitionOpptyIds){
		//Initialize all map's with the acquistion.
		for(Id acqOpptyId : acquisitionOpptyIds){
			mapLicenseeAccounts.put(acqOpptyId,new Map<Id,Account>());
			mapDefendentAccounts.put(acqOpptyId,new Map<Id,Account>());
			mapNonPartyAccounts.put(acqOpptyId,new Map<Id,Account>());
			mapPotentiallyRelAccounts.put(acqOpptyId,new Map<Id,Account>());
		}
		Map<Id,Set<Id>> mapAcqOpptyAssociatedToLit = new Map<Id,Set<Id>>();
		for(Acquisition_Opportunity__c acquisition : [Select Id,(Select Litigation__c From Opportunity_Litigation__r where Litigation__c != null),
													 (Select Account__c,Account__r.RecordTypeName__c From Non_Party_Entities__r where Account__c != null And Account__r.RecordTypeName__c IN : accountRecotdTypes)
													  From Acquisition_Opportunity__c Where Id IN :acquisitionOpptyIds AND recordType.Name = 'Litigations']){
			//Get all relevent account of Non party Entity relevent to acquisition.
			for(Non_Party_Entity__c nonParty : acquisition.Non_Party_Entities__r){
				mapNonPartyAccounts.get(acquisition.Id).put(nonParty.Account__c,nonParty.Account__r);
			}	
			//Iterate all opportunity Litigation to retrieve all associated Litigation to acquisition 
			for(Opportunity_Litigation__c litigation : acquisition.Opportunity_Litigation__r){
				if(!mapAcqOpptyAssociatedToLit.containsKey(litigation.Litigation__c))
					mapAcqOpptyAssociatedToLit.put(litigation.Litigation__c,new Set<Id>());
				mapAcqOpptyAssociatedToLit.get(litigation.Litigation__c).add(acquisition.Id);
			}												  	
		}		
		
		Map<Id,Set<Id>> mapLitAssociatedToPatentfamily = new Map<Id,Set<Id>>();
		//Iterate on all Associated Litigation to retrieve defendent accounts and relevent Patent family.
		for(Litigation__c litigation : [Select Id,(Select Account__c,Account__r.RecordTypeName__c From Defendants__r where Account__c != null And Account__r.RecordTypeName__c IN : accountRecotdTypes),
									   (Select Patent_Family__c From Litigation_Patent_Families__r ) 
									    From Litigation__c where Id IN : mapAcqOpptyAssociatedToLit.keyset()]){
			Map<Id,Account> mapAccount = new Map<Id,Account>();
			for(Defendant__c defendant : litigation.Defendants__r){
				mapAccount.put(defendant.Account__c,defendant.Account__r);
			}
			
			for(Id acqOpptyIds : mapAcqOpptyAssociatedToLit.get(litigation.Id)){
				mapDefendentAccounts.get(acqOpptyIds).putAll(mapAccount);
			}
			//Iterate Litigation_Patent_Family__c for Patent Families
			for(Litigation_Patent_Family__c litPatentfamily : litigation.Litigation_Patent_Families__r){
				if(!mapLitAssociatedToPatentfamily.containsKey(litPatentfamily.Patent_Family__c))
					mapLitAssociatedToPatentfamily.put(litPatentfamily.Patent_Family__c,new Set<Id>());
				mapLitAssociatedToPatentfamily.get(litPatentfamily.Patent_Family__c).add(litigation.Id);
			}			
		}
		//Iterate on Patent Family To retrieve all licensee's accounts and relevent companies's Accounts
		for(Assets__c patentfamily : [Select Id,(Select Account__c,Account__r.RecordTypeName__c From Licensees__r where Account__r.RecordTypeName__c IN : accountRecotdTypes),
									(Select Account__c,Account__r.RecordTypeName__c From Potentially_Relevant_Companies__r where Account__r.RecordTypeName__c IN : accountRecotdTypes) 
		 							 From Assets__c Where Id IN : mapLitAssociatedToPatentfamily.keyset()]){
		 	
		 	Map<Id,Account> mapLicensees = new Map<Id,Account>();
		 	//Iterate for all relevent Licensee's Accounts
			for(Licensees__c licensee : patentfamily.Licensees__r){
				mapLicensees.put(licensee.Account__c,licensee.Account__r);
			}
			
			Map<Id,Account> mapPotentiallyRelCompanies = new Map<Id,Account>();
			for(Potentially_Relevant_Company__c potentiallyRelAcc : patentfamily.Potentially_Relevant_Companies__r){
				mapPotentiallyRelCompanies.put(potentiallyRelAcc.Account__c,potentiallyRelAcc.Account__r);
			}
			//Iterate for all relevent Companies's Accounts
			for(Id litigationId : mapLitAssociatedToPatentfamily.get(patentfamily.Id)){
		 		for(Id acqId : mapAcqOpptyAssociatedToLit.get(litigationId)){
		 			mapLicenseeAccounts.get(acqId).putAll(mapLicensees);
		 			mapPotentiallyRelAccounts.get(acqId).putAll(mapPotentiallyRelCompanies);
		 		}
		 	}
			
		}
	}
	//A method to create Barker Model Accounts Record.
	private static void createBarkerModelCalculationRecords(BarkerModel__c barkerModel,Map<Id,BarkerModelCalculation__c> newBarkerModelCalculations,Map<Id,Map<Id,Account>> mapAccounts,String accType){		
		if(mapAccounts.containsKey(barkerModel.AcquisitionOpportunity__c)){
			for(Account acc : mapAccounts.get(barkerModel.AcquisitionOpportunity__c).values()){
				if(!newBarkerModelCalculations.containsKey(acc.Id)){
					if(acc.RecordTypeName__c == 'Member'){
						newBarkerModelCalculations.put(acc.Id,new BarkerModelCalculation__c(BarkerModel__c = barkerModel.Id,Account__c = acc.Id,Type__c = accType, Member_RPX_Target_Margin_problem_type__c = barkerModel.Target_Margin_Members__c));
					}else if(acc.RecordTypeName__c == 'Prospect'){
						newBarkerModelCalculations.put(acc.Id,new BarkerModelCalculation__c(BarkerModel__c = barkerModel.Id,Account__c = acc.Id,Type__c = accType, Prospect_RPX_target_margin_by_problem_ty__c = barkerModel.Target_Margin_Prospects__c));
					}
				}				
			}
		}		
	}
	
	/*
	Neeraj [02/23] : Barker model with Parent Acquisition Stage Closed Cannot be deleted
	Ref. Task : T-33392
	*/
	public static void beforeDeleteBarkerModel(List<BarkerModel__c> lstBM) {
    Set<Id> acqOppIds = new Set<Id> ();
    for (BarkerModel__c bm : lstBM) {
      acqOppIds.add(bm.AcquisitionOpportunity__c);
    }
    
    String closedStages = Label.ClosedAcquisitionOpportunityStages;
    Set<String> closedStagesSet = new Set<String>();
    for(String stage : closedStages.split(',')) {
    	closedStagesSet.add(stage.trim());
    }
    
    Map<Id, Acquisition_Opportunity__c> mapAcqOpp = new Map<Id, Acquisition_Opportunity__c> (
      [Select id, StageName__c 
       From Acquisition_Opportunity__c
       Where id in :acqOppIds
       And StageName__c in :closedStagesSet]);
    
    
    for (BarkerModel__c bm : lstBM) {
      if(mapAcqOpp.containsKey(bm.AcquisitionOpportunity__c)) {
      	bm.AcquisitionOpportunity__c.addError(Label.Cannot_Delete_Barker_Model);
        bm.addError(Label.Cannot_Delete_Barker_Model);
      }
    }
    
  }
	
	/*
	 * This Method is used to copy Target Margin of barker model to barker model Account's Target Margin.
	 * If Do not Allow Override from Header is false. 
	 */
	public static void copyTarget_MarginOfBarkerModelAccount(Map<Id,BarkerModel__c> newMap ,Map<Id,BarkerModel__c> oldMap){
		boolean isDelete = newMap == null;
		boolean isInsert = oldMap == null;
		//Prepare the set of barkermodel Ids
		set<Id> barkerModelIds = new Set<Id>();
		for(BarkerModel__c barkerModel:newMap.values()){
			if(barkerModel.Target_Margin_Members__c != oldMap.get(barkerModel.Id).Target_Margin_Members__c || barkerModel.Target_Margin_Prospects__c != oldMap.get(barkerModel.Id).Target_Margin_Prospects__c ){
				barkerModelIds.add(barkerModel.Id);
			}
		}
		//Prepare the list of barker models those to be update
		List<BarkerModelCalculation__c> listOfBMC = new List<BarkerModelCalculation__c>();
		for(BarkerModelCalculation__c barkerModelAccount : [select Id,BarkerModel__c,Account__r.RecordTypeName__c,Member_RPX_Target_Margin_problem_type__c,Prospect_RPX_target_margin_by_problem_ty__c from BarkerModelCalculation__c where Do_not_Allow_Override_from_Header__c = false AND BarkerModel__c IN : barkerModelIds]){
			if(barkerModelAccount.Account__r.RecordTypeName__c == 'Member'){
				listOfBMC.add(new BarkerModelCalculation__c(Id = barkerModelAccount.Id , Member_RPX_Target_Margin_problem_type__c = newMap.get(barkerModelAccount.BarkerModel__c).Target_Margin_Members__c));
			}else if(barkerModelAccount.Account__r.RecordTypeName__c == 'Prospect'){
				listOfBMC.add(new BarkerModelCalculation__c(Id = barkerModelAccount.Id ,Prospect_RPX_target_margin_by_problem_ty__c = newMap.get(barkerModelAccount.BarkerModel__c).Target_Margin_Prospects__c));
			}
				
		}
		update listOfBMC;
	}	
}