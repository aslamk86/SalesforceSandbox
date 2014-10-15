/*****************************************************************************
 * Name                 : TestLastUpdateTimeAndUserTrigger
 * Created By           : Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for CaptureLastManualUpdate. 
 *****************************************************************************/
@isTest
private class TestLastUpdateTimeAndUserTrigger {
    // A Map To get the record type information From Record Type Name
    static Map<String,Schema.RecordTypeInfo> rtMapByName;
    static {
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account;
        rtMapByName = d.getRecordTypeInfosByName();
    }
    //Test Method To check the Quality of Code.
    static testMethod void myUnitTest() {
        //Testing start from here
        Test.startTest();
            //Insert Account Record
            Account account = TestUtil.createAccount(false);
            //Update information to fire a trigger
            account.Entity_ID__c = 1234567890;
            insert account;
           
            account.Financial_Data_Source_Type__c = 'Thomson';
            account.Fiscal_Year_Close_Thomson__c = date.today();
            account.Operating_Income_Y1_Thomson__c =  1000;
            account.Operating_Income_Y2_Thomson__c = 1000;
            account.Operating_Income_Y3_Thomson__c = 1000;
             account.Operating_Income_Y1_Manual__c =  1000;
            account.Operating_Income_Y2_Manual__c = 1000;
            account.Operating_Income_Y3_Manual__c = 1000;
            account.Revenue_Current_Year_Thomson__c = 1000;
            //Update an account to fire the trigger on UPDATE
            update account;
            
            account = getAccountRecord(account.Id);
            //Check that Updated User must be Thomson.
            system.debug('=============' + account.Rate_Last_Update_By__c);
            system.assertEquals(account.Rate_Last_Update_By__c ,'Thomson');
            
            account.Rate_Comments_Thomson__c = 'Testing Under process';
            account.Financial_Data_Source_Type__c = 'Manual';
             //Update an account to fire the trigger on UPDATE 
            update account;
            //retrieve account Object After Update
            account = getAccountRecord(account.Id);
            //Check that Current User or Updated User is Same.
            system.assertEquals(account.Rate_Last_Updated_By_Manual__c ,UserInfo.getName());
            
        Test.stopTest();
    }
    
    //Retrieve an account information of specific account Id
    static Account getAccountRecord(Id accountId){
        for(Account account : [select Rate_Last_Update_By__c,Rate_Last_Updated_By_Manual__c  From Account where Id = :accountId]){
            return account;
        }
        return null;
    }
}