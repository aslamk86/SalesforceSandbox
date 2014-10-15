/*****************************************************************************
 * Name                 : TestLitigationReportController
 * Created By           : Sudhir Kumar Jagetiya(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for LitigationReportController.
 *****************************************************************************/
@isTest(seeAllData = false)
private class TestLitigationReportController {
        //A map that contains the record type information of Acquisition_Opportunity__c
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
        rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    }
    //Test method to check the Quality of code
    static testMethod void myUnitTest() {
        //Get the record type info of Account Object
       Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
       Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
       Schema.RecordTypeInfo rtByName =  rtMapByName.get('Prospect');
       //Create Test Data
       //Insert Account
       Account testAccount = TestUtil.createAccount(false);
       testAccount.RecordTypeId = rtByName.getRecordTypeId();
       testAccount.Entity_ID__c = 123456789;
       insert testAccount;
       
       //Get the record type info of Opportunity Object
       Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity; 
       Map<String,Schema.RecordTypeInfo> rtMapByNameForOpp = oppSchema.getRecordTypeInfosByName();
       Schema.RecordTypeInfo rtByNameForOpp =  rtMapByNameForOpp.get('Membership');
       
       //Insert the Opportunity
       Opportunity opp = TestUtil.createOpportunity(testAccount.Id, 'Open', false);
       opp.RecordTypeId = rtByNameForOpp.getRecordTypeId();
       insert opp;
        
         //Insert the Acquisition_Opportunity__c
       Acquisition_Opportunity__c acqOpportunity = TestUtil.createAcquisitionOpp(testAccount.Id, 'Hold', 'Test AcQ Oppty', false);
       acqOpportunity.RecordTypeId = getRecortdTypeIdForAcqOpp('Litigations');
       insert acqOpportunity;
       
       //Insert the litigation
       Litigation__c litigation = TestUtil.createLitigation(false);
       litigation.Acquisition_Opportunity__c = acqOpportunity.Id;
       litigation.Docket_Number__c = '1234587';
       litigation.Filed__c = date.today();
       litigation.Active_or_Closed__c = 'Active';
       insert litigation;
       
       //Insert defendant
       Defendant__c defendant = TestUtil.createDefendant(testAccount.Id, litigation.Id, false);
       defendant.Defendant_Name__c = 'test defendant';
       defendant.Date_Terminated__c = Date.today();
       insert defendant;
       
       Opportunity_Litigation__c oppLitigation = TestUtil.createOpportunityLitigation(acqOpportunity.Id, litigation.Id, true);
       
       //Insert Non party Entity
       Non_Party_Entity__c npe = TestUtil.createNonPartyEntity(acqOpportunity.Id,testAccount.Id,opp.Id,true);
       //Testing is start from here
       Test.startTest();
                //set the current page reference to LitigationTop120Report page
            PageReference pageRef = Page.LitigationTop120Report;
            Test.setCurrentPageReference(pageRef);
            //create the Object of LitigationReportController.
            LitigationReportController testObject = new LitigationReportController();
            //Check that return list size should be greater than zero
            system.assert(testObject.litigationReportList.get(0).size() > 0 );
       Test.stopTest();
    }
    
    static Id getRecortdTypeIdForAcqOpp(String recordType){
        return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
    }
}