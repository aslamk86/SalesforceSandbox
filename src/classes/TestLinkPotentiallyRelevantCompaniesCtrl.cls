/****************************************************************************************************************************
 * Name             : TestLinkPotentiallyRelevantCompaniesCtrl
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 31 MAR, 2012.
 * Purpose          : Test class for LinkPotentiallyRelevantCompaniesCtrl
****************************************************************************************************************************/
@isTest
private class TestLinkPotentiallyRelevantCompaniesCtrl{

	static testMethod void testPotentiallyRelevantFunctionality() {
		Map<String,Id> accRecType = TestUtil.getRecordType('Account');
	  Map<String,Id> oppRecType = TestUtil.getRecordType('Acquisition_Opportunity__c');
	  
	  //Test Data Creation
	  Account acct = TestUtil.createAccount(true);
	  
	  //Creating OMA Acquisition Opportunity
	  Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Prospect', 'Test', false);
	  acqOpp.RecordTypeId = oppRecType.get('OMA');
	  insert acqOpp;
	  
	  //Inserting patent Families
	  List<Assets__c> lstPatentFamily = new List<Assets__c> ();
	  Assets__c patentFamily1 = TestUtil.createPortfolio(false);
	  Assets__c patentFamily2 = TestUtil.createPortfolio(false);
	  
	  lstPatentFamily.add(patentFamily1);
	  lstPatentFamily.add(patentFamily2);
	  insert lstPatentFamily;
      
    //4 products created      
  	List<Product_or_Service__c> lstProducts = new List<Product_or_Service__c> ();
    Product_or_Service__c prod1 = TestUtil.createProductOrServices('PR1', false);
    Product_or_Service__c prod2 = TestUtil.createProductOrServices('PR2', false);
    Product_or_Service__c prod3 = TestUtil.createProductOrServices('PR3', false);
    Product_or_Service__c prod4 = TestUtil.createProductOrServices('PR4', false);
    lstProducts.add(prod1);
    lstProducts.add(prod2);
    lstProducts.add(prod3);
    lstProducts.add(prod4);
    insert lstProducts;
    
    //4 product in family 1 and 3 in family 2 
    List<portfolio2product__c> lstFamilyToProdMap = new List<portfolio2product__c> ();
    portfolio2product__c familyToProdMapping1 = TestUtil.createPortFolioToProductRecord(patentFamily1.Id, prod1.Id, acqOpp.Id, false);
    portfolio2product__c familyToProdMapping2 = TestUtil.createPortFolioToProductRecord(patentFamily1.Id, prod2.Id, acqOpp.Id, false);
    portfolio2product__c familyToProdMapping3 = TestUtil.createPortFolioToProductRecord(patentFamily1.Id, prod3.Id, acqOpp.Id, false);
    portfolio2product__c familyToProdMapping4 = TestUtil.createPortFolioToProductRecord(patentFamily1.Id, prod4.Id, acqOpp.Id, false);
    portfolio2product__c familyToProdMapping5 = TestUtil.createPortFolioToProductRecord(patentFamily2.Id, prod1.Id, acqOpp.Id, false);
    portfolio2product__c familyToProdMapping6 = TestUtil.createPortFolioToProductRecord(patentFamily2.Id, prod2.Id, acqOpp.Id, false);
    portfolio2product__c familyToProdMapping7 = TestUtil.createPortFolioToProductRecord(patentFamily2.Id, prod3.Id, acqOpp.Id, false);
    
    lstFamilyToProdMap.add(familyToProdMapping1);
    lstFamilyToProdMap.add(familyToProdMapping2);
    lstFamilyToProdMap.add(familyToProdMapping3);
    lstFamilyToProdMap.add(familyToProdMapping4);
    lstFamilyToProdMap.add(familyToProdMapping5);
    lstFamilyToProdMap.add(familyToProdMapping6);
    lstFamilyToProdMap.add(familyToProdMapping7);
    insert lstFamilyToProdMap;
    
    List<Acquisition_Patent_Families__c> lstAcqPatentFamily = new List<Acquisition_Patent_Families__c>();
    lstAcqPatentFamily.add(TestUtil.createAcqOppFamily(acqOpp.Id, patentFamily1.Id, false));
    lstAcqPatentFamily.add(TestUtil.createAcqOppFamily(acqOpp.Id, patentFamily2.Id, false));
    insert lstAcqPatentFamily;
    
    List<Account> lstAccount = new List<Account> ();
    lstAccount.add(TestUtil.createAccount(false));
    lstAccount.add(TestUtil.createAccount(false));
    lstAccount.add(TestUtil.createAccount(false));
    lstAccount.add(TestUtil.createAccount(false));
    
    // change account record type to member
    for(Account acc : lstAccount) {
        acc.RecordTypeId = accRecType.get('Member');
    }
    insert lstAccount;
    
    //add products into account
    List<account2product__c> lstAcc2Prod = new List<account2product__c>();
    lstAcc2Prod.add(TestUtil.createCompanyToProductRecord(lstAccount[0].Id, prod1.Id, false));
    lstAcc2Prod.add(TestUtil.createCompanyToProductRecord(lstAccount[1].Id, prod1.Id, false));
    lstAcc2Prod.add(TestUtil.createCompanyToProductRecord(lstAccount[2].Id, prod1.Id, false));
    lstAcc2Prod.add(TestUtil.createCompanyToProductRecord(lstAccount[0].Id, prod4.Id, false));
	  insert lstAcc2Prod;
	  
	  //Code Verification Starts
	  Test.startTest();
	  
	  Test.setCurrentPage(Page.LinkPotentiallyRelevantCompanies);
	  Map<String, String> pageParams = ApexPages.currentPage().getParameters();
	  pageParams.put('Id',acqOpp.Id);
	   
	  LinkPotentiallyRelevantCompaniesCtrl ctrl = new LinkPotentiallyRelevantCompaniesCtrl();
	  System.assertEquals(2, ctrl.lstPatentFamilies.size()); 
	  //will throw exception please select family
	  ctrl.search();
	  System.assertEquals(Label.Atleast_One_Family_Required, ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getDetail()); 
	  
	  ctrl.lstPatentFamilies[0].isSelected = true;
	  ctrl.lstPatentFamilies[1].isSelected = true;
	  ctrl.companyType = 'Both';
	  ctrl.search();
	  System.assertEquals(3, ctrl.lstAccounts.size());
	  
	  //will throw exception please select family and account
	  ctrl.createCompanyWhoCareRecords();
	  System.assertEquals(Label.Atleast_One_Account_And_Family_Required, ApexPages.getMessages()[ApexPages.getMessages().size() - 1].getDetail());
	  
	  ctrl.lstAccounts[0].isSelected = true;
	  ctrl.lstAccounts[1].isSelected = true;
	  ctrl.lstAccounts[2].isSelected = true;
	  ctrl.createCompanyWhoCareRecords();
	  
	  //6 records 2 family and 3 Accounts
	  System.assertEquals(6,[Select count() 
	                         From Potentially_Relevant_Company__c
	                         Where Patent_Family__c in :lstPatentFamily]);
	  
	  ctrl.createCompanyWhoCareRecords();
	
    //6 records 2 family and 3 Accounts
    System.assertEquals(6,[Select count() 
                       From Potentially_Relevant_Company__c
                       Where Patent_Family__c in :lstPatentFamily]);
	  
	  System.assert(ctrl.cancel().getUrl().contains(acqOpp.Id));
	  Test.stopTest();
	}
}