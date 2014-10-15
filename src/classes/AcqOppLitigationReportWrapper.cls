public without sharing class AcqOppLitigationReportWrapper {
		public String acqOppId {get; set;}
		public String acqOppName {get;set;}
		public String PatentFamilyName {get; set;}
		public String Priority {get; set;}
		public String DealProbability {get; set;}
		public String DegreeofDialogue {get; set;}
		public String PrimaryMarketSector {get; set;}
		public String DocketNumber {get; set;}
		public String Filed {get; set;}
		public String ActiveOrClosed {get; set;}
		public String AccountName {get; set;}
		public String SellersExplicitExpectation {get; set;}
		public String CurrentStatus {get; set;}
		public String LastAction {get; set;}
		public String NextStep {get; set;}
		public String ActionItemAssignedTo {get; set;}
		public String DefendantOrNonPartyAccount {get; set;}
		public String DefendantOrNonPartyAccountRecordType {get; set;}
		public String DefendantAccount_TopProspectList {get; set;}
		public String DefendantDateTerminated {get; set;}
		public String RPX_Rate {get; set;}
		public String indicator {get; set;}
		public String SuitRanking {get; set;}
		public String oppStage {get; set;}
		public String NPEorDefendantFrom {get; set;}
		
		/*
		public AcqOppLitigationReportWrapper(Acquisition_Opportunity__c acqOpp,Opportunity_Litigation__c opplitigation){
			acqOppId = acqOpp.Id;
			acqOppName = acqOpp.Name;
			PatentFamilyName = acqOpp.Assets__r.Name;
			Priority = acqOpp.Priority__c;
			DealProbability = acqOpp.Deal_Probability__c;
			DegreeofDialogue = acqOpp.Degree_of_Dialogue__c;
			PrimaryMarketSector = acqOpp.Primary_Market_Sector__c;
			DocketNumber = opplitigation.Litigation__r.Docket_Number__c;
			Filed = String.ValueOf(opplitigation.Litigation__r.Filed__c);
			ActiveOrClosed = opplitigation.Litigation__r.Active_or_Closed__c;
			AccountName = acqOpp.Account__r.Name;
			SellersExplicitExpectation = acqOpp.SellersExplicitExpectation__c;
			CurrentStatus = acqOpp.Current_Status__c;
			LastAction = acqOpp.Last_Action__c;
			NextStep = acqOpp.NextStep__c;
			ActionItemAssignedTo = acqOpp.Action_Item_Assigned_To__c;
			DefendantOrNonPartyAccount = '';
			DefendantOrNonPartyAccountRecordType = '';
			DefendantAccount_TopProspectList = ''; 
			DefendantDateTerminated = ''; 
			RPX_Rate = ''; 
			indicator = '199'; 
			SuitRanking = acqOpp.Suit_Ranking__c;
			oppStage = '';
			NPEorDefendantFrom = 'NPE';
		}*/
		public AcqOppLitigationReportWrapper(Acquisition_Opportunity__c acqOpp,Non_Party_Entity__c nonPartyEntity){
			acqOppId = acqOpp.Id;
			acqOppName = acqOpp.Name;
			PatentFamilyName = acqOpp.Assets__r.Name;
			Priority = acqOpp.Priority__c;
			DealProbability = acqOpp.Deal_Probability__c;
			DegreeofDialogue = acqOpp.Degree_of_Dialogue__c;
			PrimaryMarketSector = acqOpp.Primary_Market_Sector__c;
			DocketNumber = '';
			Filed = '';
			ActiveOrClosed = '';
			AccountName = acqOpp.Account__r.Name;
			SellersExplicitExpectation = acqOpp.SellersExplicitExpectation__c;
			CurrentStatus = acqOpp.Current_Status__c;
			LastAction = acqOpp.Last_Action__c;
			NextStep = acqOpp.NextStep__c;
			ActionItemAssignedTo = acqOpp.Action_Item_Assigned_To__c;
			DefendantOrNonPartyAccount = nonPartyEntity.Account__r.Name;
			DefendantOrNonPartyAccountRecordType = nonPartyEntity.Account__r.RecordType.Name;
			DefendantAccount_TopProspectList = nonPartyEntity.Account__r.Top_Prospect_List__c; 
			DefendantDateTerminated = ''; 
			RPX_Rate = ''; 
			indicator = '1'; 
			SuitRanking = acqOpp.Suit_Ranking__c;
			oppStage = '';
			NPEorDefendantFrom = 'Non-Party Entities';			
		}
		public AcqOppLitigationReportWrapper(Acquisition_Opportunity__c acqOpp,Opportunity_Litigation__c opplitigation,Defendant__c defendant,Opportunity opp){
			acqOppId = acqOpp.Id;
			acqOppName = acqOpp.Name;
			PatentFamilyName = acqOpp.Assets__r.Name;
			Priority = acqOpp.Priority__c;
			DealProbability = acqOpp.Deal_Probability__c;
			DegreeofDialogue = acqOpp.Degree_of_Dialogue__c;
			PrimaryMarketSector = acqOpp.Primary_Market_Sector__c;
			DocketNumber = '\t' + (opplitigation.Litigation__r.Docket_Number__c != null ? opplitigation.Litigation__r.Docket_Number__c : '');
			Filed = String.ValueOf(opplitigation.Litigation__r.Filed__c); 
			ActiveOrClosed = opplitigation.Litigation__r.Active_or_Closed__c;
			AccountName = acqOpp.Account__r.Name;
			SellersExplicitExpectation = acqOpp.SellersExplicitExpectation__c;
			CurrentStatus = acqOpp.Current_Status__c;
			LastAction = acqOpp.Last_Action__c;
			NextStep = acqOpp.NextStep__c;
			ActionItemAssignedTo = acqOpp.Action_Item_Assigned_To__c;
			DefendantOrNonPartyAccount = defendant.Account__r.Name;
			DefendantOrNonPartyAccountRecordType = defendant.Account__r.RecordType.Name;
			DefendantAccount_TopProspectList = defendant.Account__r.Top_Prospect_List__c; 
			DefendantDateTerminated = String.ValueOf(defendant.Date_Terminated__c); 
			RPX_Rate = String.valueOf(defendant.RPX_Rate_del__c); 
			indicator = '99'; 
			SuitRanking = acqOpp.Suit_Ranking__c;
			oppStage = opp.StageName;
			NPEorDefendantFrom = 'Defendant';							
		}
}