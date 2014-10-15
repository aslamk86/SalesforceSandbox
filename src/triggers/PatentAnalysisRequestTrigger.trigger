/*
  Apex Trigger :PatentAnalysisRequestTrigger
  Description: 
  Created By : Bharti(Appirio offshore)
  Last Modified Date : 18th Feb 2012
  Last Modified Date: 27th Feb 2014
  Modification - Accomodated Prior Art Request type being handled in a seperate queue
*/


trigger PatentAnalysisRequestTrigger on Patent_Analysis_Request__c (before insert,before update) {
  
  Decimal maxPatentRanking = 0;
  if(trigger.isBefore && trigger.isInsert){
    for(Patent_Analysis_Request__c request : [Select Id,Ranking__c 
                                              From Patent_Analysis_Request__c 
                                              Where Analysis_Type__c != 'Prior Art Pilot Program'
                                              Order by Ranking__c desc NULLS Last limit 1]){
      maxPatentRanking = (request.Ranking__c == null ? 1 : request.Ranking__c.intValue()) * 1.000;
    }
  }

  Decimal maxPriorArtRanking = 0;
  if(trigger.isBefore && trigger.isInsert){
    for(Patent_Analysis_Request__c request : [Select Id,Ranking__c 
                                              From Patent_Analysis_Request__c 
                                              Where Analysis_Type__c = 'Prior Art Pilot Program'
                                              Order by Ranking__c desc NULLS Last limit 1]){
      maxPriorArtRanking = (request.Ranking__c == null ? 1 : request.Ranking__c.intValue()) * 1.000;
    }
  }
  
  if(trigger.isBefore){
    for(Patent_Analysis_Request__c request : trigger.New){
          request.Requested_By__c = request.Requested_By__c == null ? UserInfo.getUserId() : request.Requested_By__c;
          
          if(request.Assigned_To__c != null && ( Trigger.isInsert || request.Assigned_To__c != trigger.oldMap.get(request.Id).Assigned_To__c)){
            request.SendAssignmentNotification__c = true;
          }
          if(trigger.isInsert)
          {
            if (request.Analysis_Type__c != 'Prior Art Pilot Program')
              maxPatentRanking++;
            else
              maxPriorArtRanking++;
		
              Decimal maxRanking = 0;
              if (request.Analysis_Type__c != 'Prior Art Pilot Program')
                  maxRanking= maxPatentRanking;
              else
                  maxRanking= maxPriorArtRanking;
        request.Ranking__c = maxRanking;
      }          
    }
  }
  
  
}