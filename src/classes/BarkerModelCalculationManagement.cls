/*****************************************************************************
 * Name             : BarkerModelCalculationManagement
 * Created By       : Bharti(Appirio Offshore)
 * Created Date     : 17 Jan, 2012.
 * Purpose          : Helper class for BarkerModelCalculationTrigger
*****************************************************************************/
public without sharing class BarkerModelCalculationManagement {
    static Set<String> acqOppStages;
    static List<String> acqOppRecordTypes;
    
    static {
        acqOppRecordTypes = Label.AcqOpptyRecordTypesForBarkerModelCalculation != null ? Label.AcqOpptyRecordTypesForBarkerModelCalculation.split(',') : new List<String>();
    }
    
    public static void beforeInsertUpdateDelete(List<BarkerModelCalculation__c> newList,Map<Id,BarkerModelCalculation__c> oldMap){
        Boolean isInsert = oldMap == null;
        boolean isUpdate = (oldMap != null & newList != null);
        
        Boolean isDelete = newList == null;
        
        if(!isDelete){
            setDefaultRPXCreditRemainingByCompany(newList,oldMap);
            checkPopulatedFieldForSelectedAccount(newList,oldMap);      
            checkIfAccountAlreadyAssociatedToModel(newList,oldMap);
        }
    }
    
    public static void afterInsertUpdateDelete(Map<Id,BarkerModelCalculation__c> newMap,Map<Id,BarkerModelCalculation__c> oldMap){
        UpdateAccountMemberCredit(newMap,oldMap);
        updateBarkerModelRollupFields(newMap,oldMap);
    }
    
  //-----------------------------------------------------------------------------------------------------------
    //Adj Credit from Current Members (Rollup of “Member Margin-Adjusted Credit” from Barker Model Calculation”) 
  //Max cash from prospects (Rollup of “Prospect Margin adjusted max cash “ from Barker Model Calculation)
  //----------------------------------------------------------------------------------------------------------- 
    public static void updateBarkerModelRollupFields(Map<Id,BarkerModelCalculation__c> newMap,Map<Id,BarkerModelCalculation__c> oldMap) {
        
      Set<Id> bmIds = new Set<Id>();
        
      List<BarkerModelCalculation__c> newList = newMap == null? oldMap.values() : newMap.values();
      for (BarkerModelCalculation__c bmc : newList) {
            bmIds.add(bmc.BarkerModel__c);
      }
        
      Map<Id, AggregateResult> bmIdAndRollupValues = new Map<Id, AggregateResult>();
      for ( AggregateResult aResult : 
        [ Select BarkerModel__c, Sum(Member_Margin_Adjusted_Credit__c) SumAdjCredit, 
                 Sum(Prospect_Margin_adjusted_max_cash__c) SumMaxCash
          From BarkerModelCalculation__c
          Where BarkerModel__c in :bmIds AND Do_not_Include_in_Calculations__c = false
          Group by BarkerModel__c
        ]) {
                
        bmIdAndRollupValues.put(String.valueOf(aResult.get('BarkerModel__c')), aResult);
      } 
        
            Map<Id, BarkerModel__c> bmListToUpdate = new Map<Id, BarkerModel__c>(); 
            
            for (Id barkerModelId : bmIds) {
              if(bmIdAndRollupValues.containsKey(barkerModelId) && (!bmListToUpdate.containsKey(barkerModelId))) {
                AggregateResult aResult = bmIdAndRollupValues.get(barkerModelId);
                Decimal sumAdjCredit = 0;
                Decimal sumMaxCash = 0;
                        if( aResult.get('SumAdjCredit') != null) {
                        sumAdjCredit = Decimal.valueOf(String.valueOf(aResult.get('SumAdjCredit')));
                    }
                        if( aResult.get('SumMaxCash') != null) {
                        sumMaxCash = Decimal.valueOf(String.valueOf(aResult.get('SumMaxCash')));
                    }
                bmListToUpdate.put(barkerModelId, new BarkerModel__c(id = barkerModelId,Max_cash_from_prospects__c = sumMaxCash,Adj_Credit_from_Current_Members__c = sumAdjCredit));
              }else{
                bmListToUpdate.put(barkerModelId, new BarkerModel__c(id = barkerModelId,Adj_Credit_from_Current_Members__c = 0,Max_cash_from_prospects__c = 0));
              }
            }
      update bmListToUpdate.values();      
        
    }
    
    
  //------------------------------------------------
  //Duplicate fields populated according to selected account's record type
  //------------------------------------------------
   public static void checkPopulatedFieldForSelectedAccount(List<BarkerModelCalculation__c> newList,Map<Id,BarkerModelCalculation__c> oldMap){
        if(Label.BarkerModelCalculation_FieldsForSelectedAccountTypeErrorMsg == null || Label.BarkerModelCalculation_FieldsForSelectedAccountTypeErrorMsg == '')
            return;
            
        Boolean isInsert = oldMap == null;
        
        Set<Id> accountIds = new Set<Id>();
        for(BarkerModelCalculation__c bmc : newList){
            if(bmc.Account__c != null){
                accountIds.add(bmc.Account__c);
            }
        }
        
        Map<Id,Account> mapAccounts = new Map<Id,Account>([Select RecordType.DeveloperName, Id From Account Where Id IN : accountIds]);
        for(BarkerModelCalculation__c bmc : newList){
            if(bmc.Account__c != null && mapAccounts.containsKey(bmc.Account__c)){system.debug('Bharti -- ' + bmc);
                if((mapAccounts.get(bmc.Account__c).RecordType.DeveloperName != 'Member' && (bmc.Member_RPX_Target_Margin_problem_type__c != null))
                || (mapAccounts.get(bmc.Account__c).RecordType.DeveloperName != 'Prospect' && (bmc.Prospect_Probability_w_In_24_months__c != null || bmc.Prospect_RPX_target_margin_by_problem_ty__c != null))){
                    bmc.addError(Label.BarkerModelCalculation_FieldsForSelectedAccountTypeErrorMsg);
                }
            }
        }
   }
  
  //------------------------------------------------
  //Duplicate account on the Barker Model.Please select any other account.
  //------------------------------------------------
   public static void checkIfAccountAlreadyAssociatedToModel(List<BarkerModelCalculation__c> newList,Map<Id,BarkerModelCalculation__c> oldMap){
        if(Label.BarkerModelCalculation_DuplicateAccountErrorMsg == null || Label.BarkerModelCalculation_DuplicateAccountErrorMsg == '')
            return;
        Boolean isInsert = oldMap == null;          
        Set<Id> accountIds = new Set<Id>();
        Set<Id> modelIds = new Set<Id>();
        for(BarkerModelCalculation__c bmc : newList){
            if(bmc.Account__c != null && (isInsert || bmc.Account__c != oldMap.get(bmc.id).Account__c)){
                accountIds.add(bmc.Account__c);
                modelIds.add(bmc.BarkerModel__c);
            }
        }
        
        if(modelIds.size() == 0) return;
        
        Map<Id,BarkerModel__c> mapBarkerModels = new Map<Id,BarkerModel__c>([Select Id,(Select Account__c,Id From BarkerModelCalculations__r Where Account__c IN : accountIds And Id Not IN : newList) From BarkerModel__c Where Id IN : modelIds]);
        for(BarkerModelCalculation__c bmc : newList){
            if(bmc.Account__c != null && (isInsert || bmc.Account__c != oldMap.get(bmc.id).Account__c)){
                for(BarkerModelCalculation__c exisitngBMC : mapBarkerModels.get(bmc.BarkerModel__c).BarkerModelCalculations__r){
                    if(exisitngBMC.Account__c == bmc.Account__c){
                        bmc.Account__c.addError(Label.BarkerModelCalculation_DuplicateAccountErrorMsg);
                        break;
                    }
                }
            }
        }
   }
   
   
   //------------------------------------------------
  //Pull DefaultRPXCreditRemainingByCompany from account and set in the calculation record
  //------------------------------------------------
    public static void setDefaultRPXCreditRemainingByCompany(List<BarkerModelCalculation__c> newList,Map<Id,BarkerModelCalculation__c> oldMap){      
        Boolean isInsert = oldMap == null;
                
        Set<Id> accountIds = new Set<Id>();
        Set<Id> barkerModelIds = new Set<Id>();
        
        for(BarkerModelCalculation__c bmc : newList){
            if(bmc.Account__c != null)
                accountIds.add(bmc.Account__c);
             barkerModelIds.add(bmc.BarkerModel__c);
        }
        
        Map<Id,Account> mapAccounts = new Map<Id,Account>([Select Member_RPX_Credit_remaining_by_company__c,recordType.Name,RPX_RCRate__c,(Select Actual_Rate__c,Probability,Close_Quarter__c From Opportunities Where ForecastCategory Not IN ('Omitted','Closed') And RecordType.Name = 'Membership' limit 1) from Account where Id IN : accountIds]);
        Map<Id,BarkerModel__c> mapBarkerModels = new Map<Id,BarkerModel__c>([Select Target_Margin_Members__c,Target_Margin_Prospects__c from BarkerModel__c where Id IN : barkerModelIds]);
        for(BarkerModelCalculation__c bmc : newList){
            if(bmc.Account__c != null && mapAccounts.containsKey(bmc.Account__c)){
                Account acc = mapAccounts.get(bmc.Account__c); 
                if(acc.recordType.Name == 'Prospect'){
                    if(acc.Opportunities != null && acc.Opportunities.size() > 0){
                        bmc.Probability__c = acc.Opportunities[0].Probability;
                        bmc.Closed_Quarter__c = acc.Opportunities[0].Close_Quarter__c;   
                    }
                    bmc.Prospect_Rate_Card__c = (acc.Opportunities != null && acc.Opportunities.size() > 0 && acc.Opportunities.get(0).Actual_Rate__c != null)? acc.Opportunities.get(0).Actual_Rate__c : acc.RPX_RCRate__c!=null ? acc.RPX_RCRate__c*1000 : acc.RPX_RCRate__c;
                    
                    if(isInsert){
                        bmc.Prospect_RPX_target_margin_by_problem_ty__c = mapBarkerModels.get(bmc.BarkerModel__c).Target_Margin_Prospects__c;
                    }
                }else if(isInsert && acc.recordType.Name == 'Member'){
                    bmc.Default_RPX_Credit_remaining_by_company__c = acc.Member_RPX_Credit_remaining_by_company__c;
                    bmc.Member_RPX_Target_Margin_problem_type__c = mapBarkerModels.get(bmc.BarkerModel__c).Target_Margin_Members__c;
                }
            }
                
        }
    }
    
  //------------------------------------------------
  //Recalculate memberCreditForPendingDeals for all accounts those are linked to the modified Barker model Calculations and save.
  //------------------------------------------------
    public static void UpdateAccountMemberCredit(Map<Id,BarkerModelCalculation__c> newMap,Map<Id,BarkerModelCalculation__c> oldMap){
        boolean isDelete = newMap == null;
        boolean isInsert = oldMap == null;
        boolean isUpdate = (oldMap != null & newMap != null) ;
        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> barkerModelIds = new Set<Id>();
        Map<Id,List<BarkerModelCalculation__c>> mapBarkerModelCalculations = new  Map<Id,List<BarkerModelCalculation__c>>();
        acqOppStages = AcqOpptyStagesForBarkerModelCalculation__c.getAll().keySet();
        if(isDelete || isUpdate){
            //prepare set of bmcs need to recalculate
            for(BarkerModelCalculation__c bmc : oldMap.values()){        
                //handle old parent in update and parent in delete
                if(((isUpdate && (newMap.get(bmc.Id).Do_not_Include_in_Calculations__c != bmc.Do_not_Include_in_Calculations__c || newMap.get(bmc.Id).Account__c != bmc.Account__c || newMap.get(bmc.Id).Probability_Weighting__c != bmc.Probability_Weighting__c || newMap.get(bmc.Id).Potential_Avoided_Cost__c != bmc.Potential_Avoided_Cost__c)) || isDelete)
                  && bmc.Account__c != null && bmc.Probability_Weighting__c!= null && bmc.Potential_Avoided_Cost__c!= null ){
                    accountIds.add(bmc.Account__c);
                    barkerModelIds.add(bmc.BarkerModel__c);
                }
            }
        }     
        
        if(isInsert || isUpdate){
            for(BarkerModelCalculation__c bmc :newMap.values()){       
                //handle parent in insert , update and delete
                //prepare set of bmcs need to recalculate
                if(isInsert || (isUpdate && (oldMap.get(bmc.Id).Do_not_Include_in_Calculations__c != bmc.Do_not_Include_in_Calculations__c || oldMap.get(bmc.Id).Account__c != bmc.Account__c || oldMap.get(bmc.Id).Probability_Weighting__c != bmc.Probability_Weighting__c || oldMap.get(bmc.Id).Potential_Avoided_Cost__c != bmc.Potential_Avoided_Cost__c)) && bmc.Account__c!= null && bmc.Probability_Weighting__c!= null && bmc.Potential_Avoided_Cost__c!= null){                
                     accountIds.add(bmc.Account__c);                     
                     barkerModelIds.add(bmc.BarkerModel__c);
                }                   
            }
        }
        //A Map to fetch Barker Model
        Map<Id,BarkerModel__c> mapBarkerModels = new Map<Id,BarkerModel__c>([Select Id,Credit_Toggle__c,Exclude_Pre_Contract_Credit__c From BarkerModel__c where Id IN:barkerModelIds And AcquisitionOpportunity__r.StageName__c Not IN :acqOppStages And AcquisitionOpportunity__r.RecordType.Name IN : acqOppRecordTypes]);
        if(isInsert || isUpdate){
             Set<Id> barkerModelsIdForCloseOpptys = mapBarkerModels.keySet();
            //prepare map of available childs
            for(BarkerModelCalculation__c bmc :newMap.values()){             
                if(!bmc.Do_not_Include_in_Calculations__c && bmc.Account__c != null && barkerModelsIdForCloseOpptys.contains(bmc.BarkerModel__c)){
                    if(!mapBarkerModelCalculations.containsKey(bmc.Account__c))
                        mapBarkerModelCalculations.put(bmc.Account__c,new List<BarkerModelCalculation__c>());
                    mapBarkerModelCalculations.get(bmc.Account__c).add(bmc);
                }  
            }
        }
        //A Map to fetch Account
        //Map<Id,Account> mapOfAccount = new Map<Id,Account>([select Id,Remaining_Credit__c ,Member_RPX_Credit_remaining_by_company__c from Account where Id IN:accountIds]);
        List<BarkerModelCalculation__c> listToExclude = isDelete ? new List<BarkerModelCalculation__c>() : newMap.values();     
        
        List<Account> accountsToUpdate = new List<Account>();
        //Code Commented By Sudhir Kumar Jagetiya
        
        //for(Account parent : [Select (Select Id,Probability_Weighting__c,Potential_Avoided_Cost__c,BarkerModel__c,BarkerModel__r.Credit_Toggle__c,Member_Max_RPX_Value_Credit_applicable__c,Default_RPX_Credit_remaining_by_company__c From Barker_Model_Calculations__r where Id not IN : listToExclude And BarkerModel__r.AcquisitionOpportunity__r.CloseDate__c >= Today),
          //                   Id, Member_Credit_used_for_pending_deals__c,Remaining_Credit__c From Account where Id IN : accountIds]){
        for(Account parent : [Select (Select Id,Probability_Weighting__c,Potential_Avoided_Cost__c,BarkerModel__c,BarkerModel__r.Credit_Toggle__c,Member_Max_RPX_Value_Credit_applicable__c,Default_RPX_Credit_remaining_by_company__c From Barker_Model_Calculations__r where Id not IN : listToExclude And BarkerModel__r.AcquisitionOpportunity__r.StageName__c Not IN :acqOppStages AND Do_not_Include_in_Calculations__c = false),
                             Id, Member_Credit_used_for_pending_deals__c,Remaining_Credit__c,Member_Credit_Remaining_No_Pre_Contrac__c From Account where Id IN : accountIds]){
            List<BarkerModelCalculation__c> children = mapBarkerModelCalculations.containsKey(parent.Id)? mapBarkerModelCalculations.get(parent.Id) : new List<BarkerModelCalculation__c>();
            children.addAll(parent.Barker_Model_Calculations__r);
                        
            Decimal memberCreditForPendingDeals = 0;
            Decimal creditPortfolio = 0;
            Decimal remainingCredit = 0;
            for(BarkerModelCalculation__c child : children){
                if(child.Probability_Weighting__c!= null && child.Potential_Avoided_Cost__c!= null){
                    creditPortfolio = calculateCreditPortfolio(Decimal.ValueOf(child.Probability_Weighting__c), child.Potential_Avoided_Cost__c);
                    remainingCredit = (mapBarkerModels.containsKey(child.BarkerModel__c) && mapBarkerModels.get(child.BarkerModel__c).Exclude_Pre_Contract_Credit__c ) ? parent.Member_Credit_Remaining_No_Pre_Contrac__c : parent.Remaining_Credit__c;
                    memberCreditForPendingDeals += calculateMaxRPXValue(mapBarkerModels.containsKey(child.BarkerModel__c)?mapBarkerModels.get(child.BarkerModel__c).Credit_Toggle__c : child.BarkerModel__r.Credit_Toggle__c, creditPortfolio, remainingCredit, child.Default_RPX_Credit_remaining_by_company__c);//2;//child.Member_Max_RPX_Value_Credit_applicable__c != null? child.Member_Max_RPX_Value_Credit_applicable__c : 0;
                }
            }       
            accountsToUpdate.add(new Account(Id = parent.Id, Member_Credit_used_for_pending_deals__c = memberCreditForPendingDeals));
        }
       update accountsToUpdate; 
        
    }
    
    
  //------------------------------------------------
  //Calculates and returns MemberMaxRPXValueCreditApplicable
  //------------------------------------------------
    public static Decimal calculateMaxRPXValue(String creditToogle ,Decimal MemberRPX_ValueCreditPortfolio,Decimal MemberRPX_ValueRemainingByCompany,Decimal MemberRPX_CreditRemainingByCompany){
        Decimal maxRPX_Value = 0;
        
        if(creditToogle.equals('0 – Credit Remaining')){
            maxRPX_Value = MemberRPX_ValueCreditPortfolio == null || MemberRPX_ValueRemainingByCompany == null? 0 : math.min(MemberRPX_ValueCreditPortfolio ,math.max(0.0,MemberRPX_ValueRemainingByCompany));
        }
        else if(creditToogle.equals('1 - Exclude Pending Deals')){
            maxRPX_Value = MemberRPX_ValueCreditPortfolio == null || MemberRPX_CreditRemainingByCompany == null? 0 : math.min(MemberRPX_ValueCreditPortfolio,math.max(0.0,MemberRPX_CreditRemainingByCompany));
        }
        else{
            maxRPX_Value = MemberRPX_ValueCreditPortfolio == null ? 0 : MemberRPX_ValueCreditPortfolio;
        }
        return maxRPX_Value;
    } 
    
  //------------------------------------------------
  //Calculates and returns MemberRPXValueCreditPortfolio
  //------------------------------------------------
    public static Decimal calculateCreditPortfolio(Decimal MemberProbabilityWeighting,Decimal MemberPotentialAvoidedCost){
        if(MemberProbabilityWeighting == null || MemberPotentialAvoidedCost == null) return 0.0;
        
        return MemberProbabilityWeighting * MemberPotentialAvoidedCost * 0.01;
    }
  
  //
  //Neeraj [02/23] : Barker model with Parent Acquisition Stage Closed Cannot be deleted
  //Ref. Task : T-33392
  
  public static void beforeBarkerModelCalculationDelete(List<BarkerModelCalculation__c> lstBMC) {
    Set<Id> bmIds = new Set<Id> ();
    
    for (BarkerModelCalculation__c bmc : lstBMC) {
        bmIds.add(bmc.BarkerModel__c);
    }
    
    String closedStages = Label.ClosedAcquisitionOpportunityStages;
    Set<String> closedStagesSet = new Set<String>();
    for(String stage : closedStages.split(',')) {
      closedStagesSet.add(stage.trim());
    }
    
    //Set<Id> closedAcqOppIds = new Set<Id> ();
    Set<Id> closedBM = new Set<Id> ();
    for (BarkerModel__c bm : [Select AcquisitionOpportunity__c, Id
                                                        From BarkerModel__c
                                                        Where id in :bmIds
                                                        And AcquisitionOpportunity__c != null
                                                        And AcquisitionOpportunity__r.StageName__c in (:closedStages)]) {
          //closedAcqOppIds.add(bm.AcquisitionOpportunity__c);
          closedBM.add(bm.Id);
    }
    
    for (BarkerModelCalculation__c bmc : lstBMC) {
      if(closedBM.contains(bmc.BarkerModel__c)) {
        bmc.BarkerModel__c.addError(Label.Cannot_Delete_Barker_Model_Account);
        bmc.addError(Label.Cannot_Delete_Barker_Model_Account);
      }
    }
    
  }   
}