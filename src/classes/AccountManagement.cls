/*****************************************************************************
 * Name             : AccountManagement
 * Created By       : Bharti(Appirio Offshore)
 * Created Date     : 11 April, 2012.
 * Purpose          : Helper class for AccountTrigger
*****************************************************************************/
public without sharing class AccountManagement {

	public static void afterInsertUpdate(Map<Id, Account> newMap,Map<Id, Account> oldMap){
 		updateOpptyRpxRate(newMap,oldMap);
	}
	
	
	public static void beforeInsertUpdate(List<Account> lstAccounts){
 		updateCustomOwnerField(lstAccounts);
	} 
	
	//-------------------------------------------------------------------------------------------------------------------------
	//Update Custom Owner Field 
	//-------------------------------------------------------------------------------------------------------------------------
	private static void updateCustomOwnerField(List<Account> lstAccounts) {
		for(Account acct : lstAccounts) {
			acct.Owner_Lookup__c = acct.OwnerId;
		}
	}
	
  //------------------------------------------------
  // Update Accounts on the basis of RPX Rates  and Update Opportunities
  //------------------------------------------------
  
  private static void updateOpptyRpxRate(Map<Id, Account> newMap , Map<Id, Account> oldMap){
  	boolean isInsert = oldMap == null;    
  	if(isInsert)return;
    
    // allocate map by Account ID of updated RPX Rates
    Map<Id, Double> newRatesMap = new Map<Id, Double>();
  
  	// loop through the accounts and get the new and historical rates
    for (Account acct : newMap.values()) {
    	//commented this check becuase RPX_RCRate__c is being updated by a workflow field update again after this trigger fired which causes mismatch between oppty and acc rpx rate
    	//if(oldMap.get(acct.Id).RPX_RCRate__c != acct.RPX_RCRate__c){
    		newRatesMap.put(acct.Id, acct.RPX_RCRate__c != null? acct.RPX_RCRate__c : 0);
    	//}       
    }    
  	
    // get the List of opportunities we need to update that match the account IDs
    List<Opportunity> opptys = new List<Opportunity>();
                                
      // loop through the accounts and update the list of opportunities
      for (Opportunity oppty : [Select Id, AccountId, RPX_Rate_Card_From_Account__c, Historical_Rate__c, StageName From Opportunity 
      							Where AccountId in : newRatesMap.keySet() And StageName != 'Closed Won' And RecordType.Name IN ('Membership','Renewal')]) {
      	Decimal newRate = newRatesMap.get(oppty.AccountId) * 1000;
      	if(oppty.RPX_Rate_Card_From_Account__c != newRate){
      		oppty.RPX_Rate_Card_From_Account__c = newRate;
        	opptys.add(oppty);
      	}        
      }
      
      update opptys;
  }
     
}