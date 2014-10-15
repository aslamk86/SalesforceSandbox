/****************************************************************************************************************************
 * Name             : DefendantManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Apr, 2012.
 * Purpose          : Management Class for Defendant Trigger
****************************************************************************************************************************/

public without sharing class DefendantManagement {

// --- START NO LONGER NEEDED AUG 09, 2012 ----------------------------------------------
//
// Martin Sieler: no longer needed! New functionality for Litigation Count on Accounts
//

	public static void DoNothing()
		{
		integer i = 77;
		}

/*
    
  //-------------------------------------------------------------------------------------------------------------------------
  //Roll Up Litigation counts on Account
  //-------------------------------------------------------------------------------------------------------------------------
  public static void updateLitRollupFieldsOnAccount(List<Defendant__c> lstDefendant) {
    //Create set of all account Ids
    Set<Id> accIds = new Set<Id>();
    for(Defendant__c defendant : lstDefendant) {
      if(defendant.Account__c != null && defendant.Account__c != null) {
        accIds.add(defendant.Account__c);
      }
    }
    
    //prepare list of accounts to update
    Map<Id, Account> mapAccount = new Map<Id, Account> ();
    Set<String> uniqueAccLitKeys = new Set<String> ();
    for (Defendant__c defendant : [  Select id, Litigation_ID__r.Active_or_Closed__c, Litigation_ID__r.Filed__c, 
                                                                                    Date_Terminated__c, Account__c
                                    From Defendant__c 
                                    Where Account__c in :accIds 
                                    And Litigation_ID__r.Filed__c != null 
                                    AND Litigation_ID__c != null 
                                    AND Account__c != null
                                    Order by Filed__c desc]) {
        
      if(!mapAccount.containsKey(defendant.Account__c)) {
        mapAccount.put(defendant.Account__c, new Account(id = defendant.Account__c));
      }
      String key = defendant.Account__c + '~' + defendant.Litigation_ID__c;
      if(!uniqueAccLitKeys.contains(key)) {
        //Update count fields
        updateAccountFieldCount(mapAccount.get(defendant.Account__c), defendant);
        uniqueAccLitKeys.add(key);
      }
    }
    
    //Update account with counts
    if (!mapAccount.values().isEmpty()) {
      update mapAccount.values();
    }
      
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Updates Litigation Field count based on Litigation Filed_Date__c.
  //-------------------------------------------------------------------------------------------------------------------------
  private static void updateAccountFieldCount(Account account, Defendant__c defendant) {
      checkAccountFieldsForNulls(account);
      
      //# of litigation fileds this year (number of litigations where the account in view was a defendant this year)
      if(defendant.Litigation_ID__r.Filed__c.year() == Date.Today().year()) {
        account.Lits_filed_this_calendar_years__c += 1;  
      }
      
      //# of litigations filed last year (this calendar year - 1) (number of litigations where the account in view was a defendant last year)
      if(defendant.Litigation_ID__r.Filed__c.year() == Date.Today().year() - 1) {
        account.Lits_filed_last_years__c += 1;  
      }
      
      //# of litigations filed 2 years ago (this calendar year - 2) (number of litigations where the account in view was a defendant 2 years ago)
      if(defendant.Litigation_ID__r.Filed__c.year() == Date.Today().year() - 2) {
        account.Lits_filed_2_years_ago__c += 1;  
      }
      
      //# of litigations filed 3 years ago (this calendar year - 3) (number of litigations where the account in view was a defendant 3 years ago)
      if(defendant.Litigation_ID__r.Filed__c.year() == Date.Today().year() - 3) {
        account.Lits_filed_3_years_ago__c += 1;  
      }
      
      //# of litigations filed 4 years ago (this calendar year - 4)  (number of litigations where the account in view was a defendant 4 years ago)
      if(defendant.Litigation_ID__r.Filed__c.year() == Date.Today().year() - 4) {
        account.Lits_filed_4_years_ago__c += 1;  
      }
      
      //# of litigations filed 5 years ago (this calendar year - 5) (number of litigations where the account in view was a defendant 5 years ago
      if(defendant.Litigation_ID__r.Filed__c.year() == Date.Today().year() - 5) {
        account.Lits_filed_5_years_ago__c += 1;  
      }
      
      //# of litigations filed last 5 years (number of litigations where the account in view was a defendant within the last 5 years)
      if(defendant.Litigation_ID__r.Filed__c.year() >= (Date.Today().year() - 5)) {
          account.Lits_filed_within_last_5_years_all__c += 1;
        //# of ACTIVE litigations filed during last 5 years - number of litigations during the last 5 years and litigation.Active_or_Closed__c = Active defendant.Date_Terminated__c is null
        if(defendant.Date_Terminated__c == null && defendant.Litigation_ID__r.Active_or_Closed__c == 'Active') {
            account.Lits_filed_within_last_5_years_active__c += 1;  
        }
      }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Initialize Litigation Count fields to 0, if their previous vlaues are null. 
  //-------------------------------------------------------------------------------------------------------------------------
  private static void checkAccountFieldsForNulls(Account account) {
    account.Lits_filed_this_calendar_years__c  = (account.Lits_filed_this_calendar_years__c == null ? 0 : account.Lits_filed_this_calendar_years__c);
    account.Lits_filed_last_years__c  = (account.Lits_filed_last_years__c == null ? 0 : account.Lits_filed_last_years__c);
    account.Lits_filed_2_years_ago__c  = (account.Lits_filed_2_years_ago__c == null ? 0 : account.Lits_filed_2_years_ago__c);
    account.Lits_filed_3_years_ago__c  = (account.Lits_filed_3_years_ago__c == null ? 0 : account.Lits_filed_3_years_ago__c);
    account.Lits_filed_4_years_ago__c  = (account.Lits_filed_4_years_ago__c == null ? 0 : account.Lits_filed_4_years_ago__c);
    account.Lits_filed_5_years_ago__c = (account.Lits_filed_5_years_ago__c == null ? 0 : account.Lits_filed_5_years_ago__c);
    account.Lits_filed_within_last_5_years_all__c = (account.Lits_filed_within_last_5_years_all__c == null ? 0 : account.Lits_filed_within_last_5_years_all__c);
    account.Lits_filed_within_last_5_years_active__c  = (account.Lits_filed_within_last_5_years_active__c == null ? 0 : account.Lits_filed_within_last_5_years_active__c);
  }

*/    
// --- END NO LONGER NEEDED -------------------------------------------------------------

}