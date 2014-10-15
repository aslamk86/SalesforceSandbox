/**
    * Apex Class : TestRelatedAcquisitionProductServicesExt
    * Description : Test Class For RelatedAcquisitionProductServicesExt
    * Created By : Bharti(Appirio Offshore)
    * Created Date : April 19 , 2012
    */
@isTest
private class TestRelatedAcquisitionProductServicesExt {
        //A map that contains the record type information of Acquisition Opportunity
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
        rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    } 
        //Test Method to check the Quality of the Code
    static testMethod void myUnitTest() {
       // Create Test Data
       //Create An Account
        Account acct = TestUtil.createAccount(true);
       //Insert Acq Opp
        Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Open','Test', false);
        acqOpp.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
        insert acqOpp;
       
        Assets__c patentFamily = TestUtil.createPortfolio(true);
        Product_or_Service__c product = TestUtil.createProductOrServices('Test Prod', true);
        
        Acquisition_Patent_Families__c acqFamily = TestUtil.createAcqOppFamily(acqOpp.Id, patentFamily.Id, true);
        
        
        //Start testing
        Test.startTest();
                //Set current page reference to RelatedAcquisitionOpportunityLicensee
            Test.setCurrentPage(Page.ProductServicesForAcquisition);
            //Constructor call of standard Controller
            ApexPages.StandardController ctrl = new ApexPages.StandardController(acqOpp);
            //Constructor call of RelatedAcquisitionOpportunityLicenseeExt Controller
            RelatedAcquisitionProductServicesExt controller = new RelatedAcquisitionProductServicesExt(ctrl);
            //Check that size of listPortfolio2Product must be zero.
            System.assertEquals(controller.listPortfolio2Product.size(), 0);
            
            
            portfolio2product__c pf2prod = new portfolio2product__c();
        		pf2prod.Product_or_Service__c = product.Id;
        		pf2prod.Portfolio__c = patentFamily.Id;
        		insert pf2prod;
        		//Constructor call of RelatedAcquisitionOpportunityLicenseeExt Controller
        		controller = new RelatedAcquisitionProductServicesExt(ctrl);
        		//Check that size of listPortfolio2Product must be one.
        		System.assertEquals(controller.listPortfolio2Product.size(), 1);
       Test.stopTest();

    }
    //Method that return the Id of provided recordType
    static Id getRecortdTypeIdForAcqOpp(String recordType){
        return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
    }  
}