/*
    Class : AcquisitionOpportunityManagment
    Description : Helper class For Trigger AcquisitionOpportunityManagement
    Created By: Bharti Bhandari
    Create Date : January 17,2012
    Update Date:  Dec 02,2013
    Update by:    Sharmila Jeevarakshgan
    Details:      Adding action to update content associated with highly confidential OMA/ OMA with NDAs to Portal Visible false.
            Added logic to send email to Confidentiality Approver on Assigned Analyst field change.
*/
public without sharing class AcquisitionOpportunityManagement {
        static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
        static Map<String,DefaultProbabilityForOMA_Acquisition__c> mapOfOMA_probability;
        static{
            Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
      rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
            mapOfOMA_probability = DefaultProbabilityForOMA_Acquisition__c.getAll();
        }
    public static void updateProbability(List<Acquisition_Opportunity__c> listAcqOppty){
        //Perform for all records those will be updated or inserted
        for(Acquisition_Opportunity__c acqOpportunity : listAcqOppty){
                if(mapOfOMA_probability.containsKey(acqOpportunity.StageName__c) && acqOpportunity.RecordTypeId == rtMapByNameForAcqOpp.get(mapOfOMA_probability.get(acqOpportunity.StageName__c).Record_Type__c).getRecordTypeId()){
                    acqOpportunity.Probability__c = mapOfOMA_probability.get(acqOpportunity.StageName__c).Probability__c;
                }       
        }
    }
    public static void updateProbabilityOnUpdate(Map<Id,Acquisition_Opportunity__c> newMap,Map<Id,Acquisition_Opportunity__c> oldMap){
        List<Acquisition_Opportunity__c> acqOpptyList = new List<Acquisition_Opportunity__c>();
        for(Acquisition_Opportunity__c acqOpp :newMap.values()){
            if(newMap.get(acqOpp.Id).StageName__c != oldMap.get(acqOpp.Id).StageName__c){
                acqOpptyList.add(acqOpp);
            }
        }
        updateProbability(acqOpptyList);
    }
    public static void performCloneOperation(List<Acquisition_Opportunity__c> listAcqOppty){
        List<Acquisition_Opportunity__c> acqOppList = new List<Acquisition_Opportunity__c>();
        Set<Id> sourceAcqOpptyIds = new Set<Id>();
        Set<Id> defendantAccountIds = new Set<Id>();
        Set<Id> acqOppdefendantIds = new Set<Id>();
        //List To be insert
        List<Acquisition_Opportunity_Defendant__c> acqOppDefendentList = new List<Acquisition_Opportunity_Defendant__c>();
        //List to be insert
        List<Non_Party_Entity__c> acqOppNonPartyEntityList = new List<Non_Party_Entity__c>();
        List<Opportunity_Litigation__c> oppLitigitionList = new List<Opportunity_Litigation__c>();
        List<BarkerModelCalculation__c> barkerModelCalculationList = new List<BarkerModelCalculation__c>();
        Map<Id,BarkerModel__c> oldBarkerModelIdMap = new Map<Id,BarkerModel__c>();
        for(Acquisition_Opportunity__c acqOpp :listAcqOppty){
            if(acqOpp.ClonedFrom__c != null){
                sourceAcqOpptyIds.add(acqOpp.ClonedFrom__c);
            }
        }
        Map<Id,Acquisition_Opportunity__c> acqOppMap = new Map<Id,Acquisition_Opportunity__c>([Select (Select Name, Opportunity__c, Litigation__c 
                                                    From Opportunity_Litigation__r),(Select Name,Defendant__r.Account__c,Defendant__c,Account__c, Defendant_Status__c From 
                                                    Acquisition_Opportunity_Defendants__r where Defendant_Status__c = 'Open'),(Select Name, 
                                                    Average_Discount_to_the_Rate_Card__c, Target_Margin_Members__c, 
                                                    Target_Margin_Prospects__c, Credit_Toggle__c, RPX_Value_Multiplier__c, Max_Credit_from_Current_Members__c, 
                                                    Implied_maximum_Bid__c, Adj_Credit_from_Current_Members__c, Max_cash_from_prospects__c From BarkerModels__r),
                                                    (Select Account__c,Acquisition_Opportunity__c,Notes__c,Opportunity__c,Source__c From Non_Party_Entities__r)  
                                                    From Acquisition_Opportunity__c where Id IN : sourceAcqOpptyIds]);
        
        for(Acquisition_Opportunity__c acqOpp : listAcqOppty){
            if(acqOpp.ClonedFrom__c != null){
                for(Acquisition_Opportunity_Defendant__c acqOppDefendant :acqOppMap.get(acqOpp.ClonedFrom__c).Acquisition_Opportunity_Defendants__r){
                    Acquisition_Opportunity_Defendant__c cloneAcqOppDefendant = acqOppDefendant.clone(false);
                    cloneAcqOppDefendant.Acquisition_Opportunity__c = acqOpp.Id;
                    acqOppDefendentList.add(cloneAcqOppDefendant);
                    //acqOppdefendantIds.add(acqOppDefendant.Id);
                    defendantAccountIds.add(acqOppDefendant.Defendant__r.Account__c);
                }   
                for(Opportunity_Litigation__c oppLiti :acqOppMap.get(acqOpp.ClonedFrom__c).Opportunity_Litigation__r){
                    Opportunity_Litigation__c cloneOppLiti = oppLiti.clone(false);
                    cloneOppLiti.Acquisition_Opportunity__c = acqOpp.Id;
                    oppLitigitionList.add(cloneOppLiti);
                }
                for(BarkerModel__c barkerModel :acqOppMap.get(acqOpp.ClonedFrom__c).BarkerModels__r){
                    BarkerModel__c cloneBarkerModel = barkerModel.clone(false);
                    cloneBarkerModel.AcquisitionOpportunity__c = acqOpp.Id;
                    oldBarkerModelIdMap.put(barkerModel.Id,cloneBarkerModel);
                }
                
                for(Non_Party_Entity__c thirdParty :acqOppMap.get(acqOpp.ClonedFrom__c).Non_Party_Entities__r){
                    Non_Party_Entity__c clonethirdParty = thirdParty.clone(false);
                    clonethirdParty.Acquisition_Opportunity__c = acqOpp.Id;
                    acqOppNonPartyEntityList.add(clonethirdParty);
                }               
            }           
        }
        insert acqOppDefendentList;
        insert acqOppNonPartyEntityList;
        insert oldBarkerModelIdMap.values();
        List<BarkerModel__c> barkerModelAndCalculationList = [Select Id,(Select Renewal_Date__c, RPX_Value_Credit_Portfolio__c, 
                                                                        Prospect_Rate_Card__c, Prospect_RPX_target_margin_by_problem_ty__c,
                                                                        Prospect_Probability_w_In_24_months__c, Prospect_Max_Expected_Cash__c,
                                                                        Prospect_Margin_adjusted_max_cash__c, Prospect_Expected_Fee__c, 
                                                                        Prospect_Expected_Cash_w_In_24_months__c, Probability__c, 
                                                                        Probability_Weighting__c, Potential_Avoided_Cost__c, Note__c, 
                                                                        Name, Member_RPX_Value_Remaining_by_Company__c, 
                                                                        Member_RPX_Target_Margin_problem_type__c,Member_Max_RPX_Value_Credit_applicable__c, 
                                                                        Member_Margin_Adjusted_Credit__c,Id, HeatMap_Color__c, 
                                                                        HeatMapScore__c, Default_RPX_Credit_remaining_by_company__c, 
                                                                        Current_RPX_Credit_remaining_by_Company__c, Closed_Quarter__c, 
                                                                        BarkerModel__r.AcquisitionOpportunity__c,Account__c 
                                                                        From BarkerModelCalculations__r  where Account__c IN :defendantAccountIds) From BarkerModel__c where Id IN:oldBarkerModelIdMap.keySet()];
        
        for(BarkerModel__c barkerModel :barkerModelAndCalculationList){
            for(BarkerModelCalculation__c bmcObj : barkerModel.BarkerModelCalculations__r){
                BarkerModelCalculation__c clonedBmc = bmcObj.clone(false);
                clonedBmc.BarkerModel__c = oldBarkerModelIdMap.get(barkerModel.Id).Id;  
                barkerModelCalculationList.add(clonedBmc);
            }
        }
        insert barkerModelCalculationList;
        insert oppLitigitionList;
    }
    
    public static void afterUpdateAcquisitionOpportunity(Map<Id, Acquisition_Opportunity__c> newMap, Map<Id, Acquisition_Opportunity__c> oldMap) {
        updateBarkerModelRecordType(newMap, oldMap);
        //updateContentForConfidentialOMA (newMap.values());
         if(SellerBrokerEmail__c.getInstance()!=null && SellerBrokerEmail__c.getInstance().Send_Email__c==true)
            emailConfidentialityApprover(newMap, oldMap);
    }
    
    //Update BarkerModel and BarkerModelCalculation Record type to closed if 
    //Acquisition Opportunity stage is closed
    public static void  updateBarkerModelRecordType(
      Map<Id, Acquisition_Opportunity__c> newMap, 
      Map<Id, Acquisition_Opportunity__c> oldMap) {
        
        Set<Id> closedAcqOppIds = new Set<Id>(); 
        Set<Id> openAcqOppIds = new Set<Id> ();
        
        String closedStages = Label.ClosedAcquisitionOpportunityStages;
        for(Acquisition_Opportunity__c acqOpp : newMap.values()) {
            if(acqOpp.StageName__c != null 
            && acqOpp.StageName__c != oldMap.get(acqOpp.Id).StageName__c
            && closedStages != null) {
                    
                    String previousStage = '';
                if (oldMap.get(acqOpp.Id).StageName__c != null) {
                    previousStage = oldMap.get(acqOpp.Id).StageName__c.toLowerCase();
                }
                
                //check if opportunity stage is changed to closed from any other stage
                if (closedStages.toLowerCase().contains(acqOpp.StageName__c.toLowerCase())) {
                    closedAcqOppIds.add(acqOpp.Id);
                }
                
                //If opportunity stage is changed from closed to any other stage.
                if( (closedStages.toLowerCase().contains(previousStage)
                   && ! closedStages.toLowerCase().contains(acqOpp.StageName__c.toLowerCase()))
                ) {
                openAcqOppIds.add(acqOpp.Id);
              }
            }
        }
        
        Map<String, Id> bmRecTypes = TestUtil.getRecordType('BarkerModel__c');
        Id bmRecTypeId = bmRecTypes.get('Close');
        
        Map<String, Id> bmcRecTypes = TestUtil.getRecordType('BarkerModelCalculation__c');
        Id bmcRecTypeId = bmcRecTypes.get('Close');
        
        List<BarkerModel__c> lstBarkerModelToUpdt = new List<BarkerModel__c>();
        List<BarkerModelCalculation__c> lstBarkerModelCalToUpdt = new List<BarkerModelCalculation__c>(); 
        
        for(BarkerModel__c bm : [ Select id, RecordTypeId, AcquisitionOpportunity__c,
                                         (Select id, RecordTypeId
                                          From BarkerModelCalculations__r) 
                                  From BarkerModel__c
                                  Where AcquisitionOpportunity__c in : closedAcqOppIds
                                  or AcquisitionOpportunity__c in :openAcqOppIds]) {
      
      //If stage is changed to closed
      if(closedAcqOppIds.contains(bm.AcquisitionOpportunity__c)) {
          if (bm.RecordTypeId != bmRecTypeId) {
            bm.RecordTypeId = bmRecTypeId;
            bm.State__c = 'Closed';
            lstBarkerModelToUpdt.add(bm);
          }
          
          for (BarkerModelCalculation__c bmc : bm.BarkerModelCalculations__r) {
            if(bmc.RecordTypeId != bmRecTypeId) {
                bmc.RecordTypeId = bmcRecTypeId;
                //Kala - Added to populate the Checkbox for "Include in Cheat sheet" when the record type is set to close ;
                 bmc.Include_in_Cheatsheet__c=False ;
                lstBarkerModelCalToUpdt.add(bmc);
            }
          }
      
      } 
      //If opportunity stage is changed from closed to any other stage.
      if (openAcqOppIds.contains(bm.AcquisitionOpportunity__c)) {
        //If stage is changed from closed to any other stage
        if (bm.RecordTypeId != bmRecTypes.get('Open')) {
          bm.RecordTypeId = bmRecTypes.get('Open');
          //Kala - Changed the value from blank to Completed. ;
          //bm.State__c = '';
          bm.State__c = 'Completed' ;
          lstBarkerModelToUpdt.add(bm);
        }
        
        for (BarkerModelCalculation__c bmc : bm.BarkerModelCalculations__r) {
          if(bmc.RecordTypeId != bmcRecTypes.get('Open')) {
            bmc.RecordTypeId = bmcRecTypes.get('Open');
            lstBarkerModelCalToUpdt.add(bmc);
          }
        }
      }
      
    }
    update lstBarkerModelToUpdt;
    update lstBarkerModelCalToUpdt;
  }
   
  
  public static void emailConfidentialityApprover(Map<Id, Acquisition_Opportunity__c> newMap, Map<Id, Acquisition_Opportunity__c> oldMap){
      
      List<Id> acqIdsWithChangedAnalyst = new List<Id>();
      List<Id> analystIds = new List<Id>();
      //Get all the acquisitions for which the Analyst has changed or updated
      for(Id acqId:newMap.keyset()){
        if(newMap.get(acqId).Analysis_Assigned_to__c != oldMap.get(acqId).Analysis_Assigned_to__c && newMap.get(acqId).Analysis_Assigned_to__c!=null){
          acqIdsWithChangedAnalyst.add(acqId);
          analystIds.add(newMap.get(acqId).Analysis_Assigned_to__c);
        }
      }
      
      //Get All the contents for thos acquisitions
      list <ContentVersion> porVsblDocs = [select id, Review_Status__c,Acquisition__c,Title from ContentVersion where Review_Status__c='Confidentiality Review' and Acquisition__c in :acqIdsWithChangedAnalyst];
      Map<Id,List<ContentVersion>> acqContentVersionMap =  new Map<Id,List<ContentVersion>>();
      
      Map<Id,User> analystUsers = new Map<Id,User>([select id,email from User where id in:analystIds]);
      
      //put those contents in map with the acquisition as key, so that it is easier to access them later
      for(ContentVersion cvTemp:porVsblDocs){
        if(acqContentVersionMap.containsKey(cvTemp.Acquisition__c)){
          acqContentVersionMap.get(cvTemp.Acquisition__c).add(cvTemp);
        }
        else{
          acqContentVersionMap.put(cvTemp.Acquisition__c,new List<ContentVersion>{cvTemp});
        }        
      }
      
      String envURL  =  System.URL.getSalesforceBaseUrl().getHost();
        
      
      
      //loop through the set of acquistions, and prepare the email
      for(Id acqId:acqContentVersionMap.keySet()){
        //Messaging.reserveSingleEmailCapacity(10);
          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
          email.setToAddresses(new String[] {analystUsers.get(newMap.get(acqId).Analysis_Assigned_to__c).email});
          email.setReplyTo('do-not-reply@rpxcorp.com');
          email.setSenderDisplayName('Seller Document Approval Process');
        
          email.setSubject(newMap.get(acqID).Name+'- Document(s) waiting your approval');
          
          String URLLink = '<a href=https://' + envURL + '/' +newMap.get(acqID).Id+'>' ;
          String URLLink2 = '<a href=https://' + envURL + '/apex/ManageContent?id='+ newMap.get(acqID).Id+ '&field=Acquisition__c>' ;
          //email.setPlainTextBody();
          String emailContent = 'Your Approval is needed for the following documents related to Acquisition Opportunity : ' + URLLink + newMap.get(acqID).Name + '</a><br><br>';
          for(ContentVersion cv : acqContentVersionMap.get(acqId)){
            emailContent = emailContent + URLLink2  + cv.Title + '</a><br/>';
          }
          
          email.setHtmlBody(emailContent);
          
          if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) 
                    {
                        if (!Test.isRunningTest()) 
                        {
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                        system.debug('###sendNotificationEmails(): Sent an email###' );
                        }
                    }
          
          
      }  
  }
  
}