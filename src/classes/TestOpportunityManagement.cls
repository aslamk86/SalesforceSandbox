/*****************************************************************************
 * Name                 : TestOpportunityManagement
 * Created By           : Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for OpportunityTrigger.
 *****************************************************************************/
@isTest
private class TestOpportunityManagement {
    //Test method to check the Quality of Code
    static testMethod void TestAccountTypeUpdate() {
        //Create test Data
        //Create Account
      Account acct = TestUtil.createAccount(false);
      acct.Type = 'Partner';
      insert acct;
      
      //Get the record type info of Opportunity Object
       Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity; 
       Map<String,Schema.RecordTypeInfo> rtMapByNameForOpp = oppSchema.getRecordTypeInfosByName();
       Schema.RecordTypeInfo rtByNameForOpp =  rtMapByNameForOpp.get('Membership');
      //Start Test
          Test.startTest();
              //Create opportunity To fire a trigger on insert Event
              Opportunity opp = TestUtil.createOpportunity(acct.Id, 'Closed Won', false);
              opp.Discount__c = 0;
              opp.Discount_Amount__c = 0;
              opp.Win_Loss_Code__c = 'Test';
              opp.Specified_Publicity_on_Account_pg__c = true;
              opp.Attached_All_Relevant_Sales_Materials__c = true;
              opp.RecordTypeId = rtByNameForOpp.getRecordTypeId();
              opp.Support_Team_Engaged__c = 'Ned Segal';
              insert opp;
              //Check the Account type for the membership Account
              System.assertEquals('Member', [Select Type 
                                             From Account 
                                             Where id = :acct.Id][0].Type);
          Test.stopTest();                           
      
    }
}