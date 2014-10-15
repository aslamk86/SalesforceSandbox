/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestAssignMarketSectorDetailController {
	
    static testMethod void myUnitTest() {
    	Account acc = TestUtil.createAccount(true);
    	
    	Market_Sector_Detail__c marketSectorDetail = new Market_Sector_Detail__c();
    	marketSectorDetail.Description__c = 'Test';
    	insert marketSectorDetail;
    	
    	Account_Market_Sector_Detail__c accMarketSectorDetail = new Account_Market_Sector_Detail__c();
    	accMarketSectorDetail.Account__c = acc.Id;
    	accMarketSectorDetail.Market_Sector_Detail__c = marketSectorDetail.Id;
    	accMarketSectorDetail.Status__c = 'Future';
    	accMarketSectorDetail.Revenue__c = 100;
    	accMarketSectorDetail.Products__c = 'Test';
    	insert accMarketSectorDetail;
        
        Test.startTest();
        	Test.setCurrentPage(Page.AssignMarketSectorDetail);
        	Apexpages.currentPage().getParameters().put('accountId',acc.Id);
        	AssignMarketSectorDetailController ctrl = new AssignMarketSectorDetailController(); 
        	ctrl.createAccountMarketSectorDetail();
        	ctrl.back();
        Test.stopTest();
    }
}