/*****************************************************************************
 * Name             : TestPortfolio2ProductManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 29 Feb, 2012.
 * Purpose          : Test Class for Portfolio2ProductManagement
*****************************************************************************/
@isTest
private class TestPortfolio2ProductManagement {

    static testMethod void myUnitTest() {
      
      Assets__c patentFamily = TestUtil.createPortfolio(true);
      Patent__c patent = TestUtil.createPatent(patentFamily.Id, true);
      Product_or_Service__c product = TestUtil.createProductOrServices('Test Prod', true);
      
      Test.startTest();
      portfolio2product__c pf2prod = new portfolio2product__c();
      pf2prod.Product_or_Service__c = product.Id;
      pf2prod.Patent__c = patent.Id;
      insert pf2prod;
      
      System.assertEquals(patentFamily.Id,[Select Portfolio__c 
                                           From portfolio2product__c 
                                           Where id = :pf2prod.Id].Portfolio__c);
      
      pf2prod.Portfolio__c = null;
      update pf2prod;
      
      System.assertEquals(patentFamily.Id,[Select Portfolio__c 
                                           From portfolio2product__c 
                                           Where id = :pf2prod.Id].Portfolio__c);
      
      Test.stopTest();
      
    }
}