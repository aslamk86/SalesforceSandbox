/*****************************************************************************
 * Name                 : TestMemberAccountController
 * Created By           : Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for MemberAccountController.
 *****************************************************************************/
@isTest
private class TestMemberAccountController {
        //A map that contains the RecordType information of Account
        static Map<String,Schema.RecordTypeInfo> rtMapByName = null;
        static{
            Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
            rtMapByName = d.getRecordTypeInfosByName();
        }
        //Test method to check the Quality of Code
    static testMethod void myUnitTest() {
        //Start Testing
        Test.startTest();
                //Create An Account
            Account account = updateAccount();
            //Constructor call of  MemberAccountController class
            MemberAccountController objMemberAcctCont = new MemberAccountController();
        Test.stopTest();
    }
    //Create an Account
    static Account updateAccount(){
            Account account = TestUtil.createAccount(false);
            account.Name = 'SAP';
            account.ContractROI__c = -66;
            account.ProratedROI__c = -51;
            account.Last12MonthROI__c = -51;
            account.RenewalDate__c = date.newInstance(2012, 10, 30);
            account.Volume_of_dismissals__c = 1;
            account.StartDate__c = date.newInstance(2009, 10, 30);
            account.Proximity_of_dismissals_to_renewal_date__c = 3;
            account.Most_Recent_OM__c = date.newInstance(2011, 8, 4);
            account.Most_Recent_Litigation__c = date.newInstance(2011, 3, 11);
            account.CROverride_for_Heat_Map__c = 0;
            account.RPX_RCRate__c = 4230;
            account.Type = 'Member';
            account.RecordTypeId = getRecortdTypeId('Member');
            insert account;
            return account;
    }
    //Method used to get the id of record type
    static Id getRecortdTypeId(String recordType){
        return rtMapByName.get(recordType).getRecordTypeId();
    }
    //Test method to check the Quality of Code
    static testMethod void testHeatMapWrapper() {
        //Start Testing
        Test.startTest();
        //Create the object of wrapper class
          HeatMapWrapper wrap = new HeatMapWrapper();
        Test.stopTest();
    }
}