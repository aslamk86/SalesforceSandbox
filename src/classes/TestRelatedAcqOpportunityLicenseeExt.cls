/*****************************************************************************
 * Name             	: TestRelatedAcqOpportunityLicenseeExt
 * Created By       	: Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012. 
 * Description        : Test Class for RelatedAcquisitionOpportunityLicenseeExt.
 *****************************************************************************/
@isTest
private class TestRelatedAcqOpportunityLicenseeExt {
		//A map that contains the record type information of Acquisition Opportunity
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
        rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    } 
    //Test method to check the quality of code
    static testMethod void myUnitTest() {
    		//Record type info of Account
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByName =  rtMapByName.get('General');
        
        //Prepare test Data
        //Create An Account
        Account acc = TestUtil.createAccount(false);
       	//acc.EntityId__c = 999999996;
        acc.Remaining_Credit__c = 1000.00;
        acc.RecordTypeId = rtByName.getRecordTypeId();
        insert acc;
        //Insert Acq Opp
        Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acc.Id, 'Open','Test', false);
        acqOpp.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
        insert acqOpp;
        //Insert Patent Family
        Assets__c patentFamily = new Assets__c();
        patentFamily.Account__c = acc.Id;
        insert patentFamily;
        //Insert licensees
        Licensees__c lic = new Licensees__c();
        lic.Account__c = acc.Id;
        insert lic;
        //Insert Acquisition_Patent_Families__c
        Acquisition_Patent_Families__c acqFamily = TestUtil.createAcqOppFamily(acqOpp.Id, patentFamily.Id, true);
        //Start testing
        Test.startTest();
        		//Set current page reference to RelatedAcquisitionOpportunityLicensee
            Test.setCurrentPage(Page.RelatedAcquisitionOpportunityLicensee);
            //Constructor call of standard Controller
            ApexPages.StandardController ctrl = new ApexPages.StandardController(acqOpp);
            //Constructor call of RelatedAcquisitionOpportunityLicenseeExt Controller
            RelatedAcquisitionOpportunityLicenseeExt controller = new RelatedAcquisitionOpportunityLicenseeExt(ctrl);
        Test.stopTest();
    }
    //Method that return the Id of provided recordType
    static Id getRecortdTypeIdForAcqOpp(String recordType){
        return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
    }  
}