/*
    Trigger : TestRoleTrigger 
    Description : test class for RoleTrigger 
    Created By : Bharti (Offshore)
    Last Modified Date :02 Feb 2012
*/
@isTest
private class TestRoleTrigger  {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account AccObj = Testutil.createAccount(true);
        
        Contact ctct = new Contact();
        ctct.accountid = AccObj.id;
        ctct.LastName = 'test';
        insert ctct;
        
        Role__c role = new Role__c();
        role.Contact__c = ctct.id;
        insert role;
        
        System.assertEquals(AccObj.id, [select Account__c from role__c where id = : role.id].Account__c);
    }
}