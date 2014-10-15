/**
  * Apex Class : TestAccountWithClaimChartsExt
  * Description : Test Class for AccountWithClaimChartsExt
  * Created By : Aslam
  * Created Date : Feb 6, 2014
  */
@isTest
private class TestAccountWithClaimChartsExt{
    static testMethod void myUnitTest() {  
    Map<String,Id> oppRecType = TestUtil.getRecordType('Acquisition_Opportunity__c');
    
    Account acct = TestUtil.createAccount(true);
    Account acct2 = TestUtil.createAccount(true);
    
    //Creating OMA Acquisition Opportunity
    Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Prospect', 'Test', false);
    acqOpp.RecordTypeId = oppRecType.get('OMA');
    insert acqOpp;
    
    Accounts_with_Claim_Charts__c acClmChrts1 = new Accounts_with_Claim_Charts__c(AcquisitionOpportunity__c=acqOpp.id,Account__c =acct.id);
    Accounts_with_Claim_Charts__c acClmChrts2 = new Accounts_with_Claim_Charts__c(AcquisitionOpportunity__c=acqOpp.id,Account__c =acct2.id);
    List<Accounts_with_Claim_Charts__c> listAcClmChrts = new List<Accounts_with_Claim_Charts__c>();
    listAcClmChrts.add(acClmChrts1);listAcClmChrts.add(acClmChrts2);
    insert listAcClmChrts;
    
    Test.startTest();
    ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(acqOpp);
    AccountWithClaimChartsExt ext = new AccountWithClaimChartsExt(controller);    
    Test.stopTest();
    
    }
}