trigger updateOpptyRpxRate on Account (after insert, after update) {
    
    Double  newRate; 
    Double  histRate;
    Boolean pseudoAccount;
    
    // allocate map by Account ID of updated RPX Rates
    Map<Id, Double> newRatesMap = new Map<Id, Double>();
    // allocate map by Account ID of historical RPX Rates
    Map<Id, Double> histRatesMap = new Map<Id, Double>();
    // intitalize global variable
    pseudoAccount = false;
    
    
    // loop through the accounts and get the new and historical rates
    for (Account acct : System.Trigger.new) {
        // the "Seller To Be Specified" account is a "pseudo"
        // account - do not process it
        if(acct.Name != 'Seller To Be Specified') {
            histRate = 0;
            // if the record already exists, then this is an update 
            if (System.Trigger.isUpdate){
                // when we execute in the trigger after an update, the 
                // historical value is in the RPX_Rate__c's oldMap field
                if (System.Trigger.oldMap.get(acct.Id).RPX_RCRate__c != null) {
                    histRate = System.Trigger.oldMap.get(acct.Id).RPX_RCRate__c;
                    newRatesMap.put(acct.Id, acct.RPX_RCRate__c);
                } else {
                    newRatesMap.put(acct.Id, 0);
                }
                histRatesMap.put(acct.Id, histRate);
            // otherwise this is a new record
            } else if (System.Trigger.isInsert) {
                newRatesMap.put(acct.Id, acct.RPX_RCRate__c);
                // note in insert case, that the histRate is zero as
                // initialized at the top of this loop
                histRatesMap.put(acct.Id, histRate);            
            }
        } else {
            pseudoAccount = true;           
        }
    }    

    // get the set of account IDs in this update    
    Set<ID>acctKeySet = newRatesMap.keySet();
    // get the set of opportunities we need to update that match the account IDs
    // the Opportunity.AccountId is a shared key relationship with Account.Id
    List<Opportunity> opptys = [select o.Id, o.AccountId, o.RPX_Rate_Card_From_Account__c, o.Historical_Rate__c, o.StageName 
                                from Opportunity o 
                                where AccountId in : acctKeySet and StageName != 'Closed Won'];
    if (pseudoAccount != true) {
        // loop through the accounts and update the list of opportunities
        for (Account acct : System.Trigger.new) {
            if (opptys != null) {
                for (Opportunity oppty : opptys) {
                    if (oppty.StageName != 'Closed Won') { 
                        if (oppty.AccountId == acct.Id)
                        {
                            newRate = 0;
                            histRate = 0;
                            newRate = newRatesMap.get(oppty.AccountId); 
                            oppty.RPX_Rate_Card_From_Account__c = newRate * 1000;
                            histRate = histRatesMap.get(oppty.AccountId);
                            oppty.Historical_Rate__c = histRate * 1000;
                        }
                    }
                }
            }
        }
    }
    // commit the the Opportunities list in one transaction
    if (pseudoAccount != true) {
        update opptys;
    }
}