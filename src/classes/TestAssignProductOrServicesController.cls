/*****************************************************************************
 * Name             : TestAssignProductOrServicesController 
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 18 Jan, 2012.
 * Purpose          : Test Class for AssignProductOrServicesController. 
 *                    T-22105 -  
 *****************************************************************************/
@isTest
private class TestAssignProductOrServicesController { 
  
  public static String LABEL_RELATED_OBJECT_NAME = 'RelatedObjectName';
  public static String LABEL_RELATED_RECORD_ID = 'RelatedRecordId';
      
	static testMethod void TestAssignProductOrServices() {
	  Account acct = TestUtil.createAccount(true);
	  Assets__c portfolio = TestUtil.createPortfolio(true);
	  Patent__c patent = TestUtil.createPatent(false);
	  patent.Patent_Family__c = portfolio.Id;
	  insert patent;
	  
	  delete [select id from Product_or_Service__c];
	  
	  List<Product_or_Service__c> lstProdServ = new List<Product_or_Service__c>(); 
	  lstProdServ.add(TestUtil.createProductOrServices('Hardware', false));
	  lstProdServ.add(TestUtil.createProductOrServices('Hardware', false));
	  lstProdServ.add(TestUtil.createProductOrServices('Software', false));
	  lstProdServ.add(TestUtil.createProductOrServices('Software', false));
	  lstProdServ.add(TestUtil.createProductOrServices('Software', false));
	  insert lstProdServ;
	  
	  Test.startTest();
	  Test.setCurrentPage(Page.AssignProductOrServices);
	  Map<String, String> pageParams = Apexpages.currentPage().getParameters();
	  //--------------------------------
	   //Test Account 2 Product Mapping
	  //--------------------------------
	  pageParams.put(LABEL_RELATED_OBJECT_NAME, 'Account');
	  pageParams.put(LABEL_RELATED_RECORD_ID, acct.Id);
	  
	  AssignProductOrServicesController controller = new AssignProductOrServicesController();
	  controller.getFilterPicklist();
	  
	  controller.selectedView = 'Hardware';
	  controller.searchProdOrServ();
	  System.assertEquals(2, controller.lstProdWrapper.size()
	    , 'There must be 3 product & Services as we created.');
	  
	  controller.lstProdWrapper[0].isSelected = true;
	  controller.lstProdWrapper[1].isSelected = true;
	  controller.createMappingRecords();
    //To check that no duplicate records created
    controller.searchProdOrServ();
    controller.createMappingRecords();
    
	  System.assertEquals(2, 
	   [Select count() 
	    From account2product__c
	    Where Account__c = :acct.Id] , 
     'Two new Company to Mapping records should get created.');
	  
	  
	  //----------------------------------
     //Test Portfolio 2 Product Mapping
    //----------------------------------
    pageParams.put(LABEL_RELATED_OBJECT_NAME, 'PatentFamily');
    pageParams.put(LABEL_RELATED_RECORD_ID, portfolio.Id);
    controller = new AssignProductOrServicesController();

    controller.selectedView = 'Software';
    controller.searchProdOrServ();
    System.assertEquals(3, controller.lstProdWrapper.size()
      , 'There must be 3 product & Services as we created.');
    
    controller.lstProdWrapper[0].isSelected = true;
    controller.lstProdWrapper[1].isSelected = true;
    controller.createMappingRecords();
    //To check that no duplicate records created
    controller.searchProdOrServ();
    controller.createMappingRecords();
    System.assertEquals(2, 
      [Select count() 
       From portfolio2product__c
       Where portfolio__c = :portfolio.Id] , 
      'Two new Patent Family to product Mapping records should get created.');
	  
	  
	  //----------------------------------
     //Test Portfolio 2 Product Mapping
    //----------------------------------
    pageParams.put(LABEL_RELATED_OBJECT_NAME, 'Patent');
    pageParams.put(LABEL_RELATED_RECORD_ID, patent.Id);
    controller = new AssignProductOrServicesController();

    controller.selectedView = 'Software';
    controller.searchProdOrServ();
    System.assertEquals(3, controller.lstProdWrapper.size()
      , 'There must be 3 product & Services as we created.');
    
    controller.lstProdWrapper[0].isSelected = true;
    controller.lstProdWrapper[1].isSelected = true;
    controller.createMappingRecords();
    //To check that no duplicate records created
    controller.searchProdOrServ();
    controller.createMappingRecords();
    
    System.assertEquals(2, 
      [Select count() 
       From portfolio2product__c
       Where Patent__c = :patent.Id] , 
      'Two new Patent Family to product Mapping records should get created.');
    
    controller.back();
	  
	  Test.stopTest();
	  
	}
	
}