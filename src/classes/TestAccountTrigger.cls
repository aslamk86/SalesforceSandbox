/*****************************************************************************
 * Name             : TestAccountTrigger
 * Created By       : Bharti(Appirio Offshore)
 * Created Date     : 13 April, 2012.
 * Purpose          : test class for AccountTrigger
*****************************************************************************/
@isTest
private class TestAccountTrigger {
    static testmethod void checkUpdateOpptyRpxRate(){
        //prepare testdata start
        
        //create account
        Account account = TestUtil.createAccount(true);
        
        //Get the record type info of Opportunity Object
       Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity; 
       Map<String,Schema.RecordTypeInfo> rtMapByNameForOpp = oppSchema.getRecordTypeInfosByName();
       Schema.RecordTypeInfo rtByNameForOpp =  rtMapByNameForOpp.get('Membership');
       
       //create opportunity for the account
       Opportunity opp = TestUtil.createOpportunity(account.Id, 'New', false);
       opp.RecordTypeId = rtByNameForOpp.getRecordTypeId();
       insert opp;
       
       //prepare testdata end
           
        Test.startTest();   
        account.Operating_Income_Y1__c = 100000;
        update account;
        Test.stopTest();
        
        //verify result
        Opportunity queriedOpty = [Select RPX_Rate_Card_From_Account__c,Account.RPX_RCRate__c From Opportunity Where Id = : opp.Id];
        system.assertEquals(queriedOpty.RPX_Rate_Card_From_Account__c, queriedOpty.Account.RPX_RCRate__c * 1000);
    }
}