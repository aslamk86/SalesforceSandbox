/*****************************************************************************
 * Name             : OpportunityManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 16 Jan, 2012.
 * Purpose          : Management Class for Opportunity Trigger
*****************************************************************************/
public without sharing class OpportunityManagement {
  
  public static void afterOpportunityInsert(List<Opportunity> oppList) {
      updateAccountType(oppList, null);
  }
  
  public static void afterOpportunityUpdate(Map<Id,Opportunity> oppMap,
        Map<Id,Opportunity> oldoppMap) {
    
      updateAccountType(oppMap.values(), oldoppMap);
  }
  
  /*
  Update Account type to Member if "Membership" opportunity stage is changed 
  to closed won. 
  */
  private static void updateAccountType(List<Opportunity> oppList, Map<Id,Opportunity> oldMap) {
  	RecordType memberRecType;
  	for(RecordType rType : [Select id 
	  	                      From RecordType
	  	                      Where SObjectType = 'Account'
	  	                      And Name = 'Member'
	  	                      Limit 1]) {
      memberRecType = rType;
    }
    
  	List<Account> acctsToUpdate = new List<Account>();
  	for (Opportunity opp : oppList) {
  		
  		if(oldMap != null) {
  			if(opp.StageName == oldMap.get(opp.Id).StageName) {
          continue;
  			}
      }
  		
  		if(opp.RecordType__c == 'Membership'
  		  && opp.StageName != null 
  		  && opp.StageName == 'Closed Won'
  		  && opp.Win_Loss_Code__c != null
  		  && opp.Win_Loss_Code__c != ''
  		  && opp.AccountId != null
  		  && ( (opp.Discount__c > 0 && opp.Discount_Amount__c > 0)
  		      || opp.Discount__c == 0 || opp.Discount__c == null)
  		  ) {
  		  	
  		  	Account acct = new Account(Id = opp.AccountId, Type = 'Member');
  		  	//check if record type exist in org
  		  	if(memberRecType != null) {
  		  	 acct.RecordTypeId = memberRecType.Id;
  		  	}
  		  	acctsToUpdate.add(acct);
  		  }
  	}
  	
  	update acctsToUpdate;
  	
  } 
  
}