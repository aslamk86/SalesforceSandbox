/*****************************************************************************
 * Name             : TestAcqOpportunityDefendantTrigger
 * Created By       : Sudhir Kumar Jagetiya(Appirio Offshore)
 * Last Modified Date     : 13 March, 2012.
 * Description           : Test Class for AcquisitionOpportunityDefendantTrigger.
 *****************************************************************************/
@isTest
private class TestAcqOpportunityDefendantTrigger {
    //Test Methods
    
    //--------------------------------------------------------------------------------------------------------
    //Test Account_Lookup Field Value is populating correctly from trigger.
    //--------------------------------------------------------------------------------------------------------
    static testMethod void testAccountLookupField() {
        
        //Test Data Creation
        Account acct = TestUtil.createAccount(true);
        Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Prospect', 'TestAcqOptyForAccountLookupField1', true);
        Litigation__c litigation = TestUtil.createLitigation(true);
        Defendant__c defendant = TestUtil.createDefendant(acct.Id, litigation.Id, true);
        
        Test.startTest();
        //Creating Acquisition_Opportunity_Defendant__c record with defendant.
        Acquisition_Opportunity_Defendant__c acqOppDefendant = new Acquisition_Opportunity_Defendant__c();
    acqOppDefendant.Acquisition_Opportunity__c = acqOpp.Id;
    acqOppDefendant.Defendant__c = defendant.Id;
    insert acqOppDefendant;
    
    //After insert this record should have Account_Lookup__c field populated with same account as on Defendant 
    System.assertEquals([Select Account_Lookup__c From Acquisition_Opportunity_Defendant__c Where id = :acqOppDefendant.Id].Account_Lookup__c, acct.Id);
    
    //update Acquisition_Opportunity_Defendant__c record with blank defendant value
    acqOppDefendant.Defendant__c = null;
    update acqOppDefendant;
    
    //After update Account_Lookup__c field should be null as there is no associated defendant available.
    System.assertEquals([Select Account_Lookup__c From Acquisition_Opportunity_Defendant__c Where id = :acqOppDefendant.Id].Account_Lookup__c, null);
    
    //Update AOD record with defendant value
    acqOppDefendant.Defendant__c = defendant.Id;
    update acqOppDefendant;
    
    //After update Account_Lookup__c field should get populated with same account as on Defendant.
    System.assertEquals([Select Account_Lookup__c From Acquisition_Opportunity_Defendant__c Where id = :acqOppDefendant.Id].Account_Lookup__c, acct.Id);
        Test.StopTest();
        
    }
    
    
    static testMethod void myUnitTest() {
            //List of acquisition opportunities
        List<Acquisition_Opportunity__c> acqOppList = new List<Acquisition_Opportunity__c>();
        //Create test Data
        //create account
        Account account = TestUtil.createAccount(true); 
        //create acquisition opportunities
        Acquisition_Opportunity__c acqOpp1 = TestUtil.createAcquisitionOpp(account.Id, 'Phase 1', 'TestAcqOptyForAccountLookupField2', false);
        acqOpp1.CloseDate__c = date.today().addDays(5);
        acqOpp1.Free_Options_Negotiated__c = 4;
        acqOppList.add(acqOpp1);
        
        Acquisition_Opportunity__c acqOpp2 = TestUtil.createAcquisitionOpp(account.Id, 'Phase 1', 'TestAcqOptyForAccountLookupField3', false);
        acqOpp2.CloseDate__c = date.today().addDays(5);
        acqOpp1.Free_Options_Negotiated__c = 3;
        acqOppList.add(acqOpp2);
        
        insert acqOppList;
        
        //Testing is start from here
        Test.startTest();
                //Insert Acquisition opportunity Defendant to fire a trigger(case of insert) which update Free_Options_Used__c field of acq Opp
            Acquisition_Opportunity_Defendant__c acqOppDefendant = createAcqOppDefendant(acqOppList[0].Id, 'Closed - Free Option Used', true);
            //On insert Check that free option used must be equal to 1 for acqOppList[0].
            system.assertEquals(getAcqOpp(acqOppList[0].Id).Free_Options_Used__c, 1);
            
            //Insert Acquisition opportunity Defendant to fire a trigger(case of update) which update Free_Options_Used__c field of acq Opp
            acqOppDefendant.Acquisition_Opportunity__c = acqOppList[1].Id;
            update acqOppDefendant;
            //On update Check that free option used must be equal to 0 for acqOppList[0].
            system.assertEquals(getAcqOpp(acqOppList[0].Id).Free_Options_Used__c, 0);
            //On update Check that free option used must be equal to 1 for acqOppList[1].
            system.assertEquals(getAcqOpp(acqOppList[1].Id).Free_Options_Used__c, 1);
            
            //To fire a trigger on delete
            delete acqOppDefendant;
            //On delete Check that free option used must be equal to 0 for acqOppList[1].
            system.assertEquals(getAcqOpp(acqOppList[1].Id).Free_Options_Used__c,0);
            
            //In case of undelete
            undelete new Acquisition_Opportunity_Defendant__c(Id = acqOppDefendant.Id);
            //On undelete Check that free option used must be equal to 1 for acqOppList[1].
            system.assertEquals(getAcqOpp(acqOppList[1].Id).Free_Options_Used__c,1);
        Test.stopTest();
        
    }
    //method to create Acquisition_Opportunity_Defendant__c
    static Acquisition_Opportunity_Defendant__c createAcqOppDefendant(Id acqOppId,String defendantStatus ,Boolean isInsert){
        Acquisition_Opportunity_Defendant__c acqOppDefendant = new Acquisition_Opportunity_Defendant__c();
        acqOppDefendant.Acquisition_Opportunity__c = acqOppId;
        acqOppDefendant.Defendant_Status__c = defendantStatus;
        
        if(isInsert)
            insert acqOppDefendant;
        return acqOppDefendant;
    }
    //Method to retrieve Acquisition_Opportunity__c
    static Acquisition_Opportunity__c getAcqOpp(Id acqOppId){
        for(Acquisition_Opportunity__c acqOpp :[select Id,Free_Options_Used__c from Acquisition_Opportunity__c where Id =:acqOppId]){
            return acqOpp;
        }
        return null;
    }
}