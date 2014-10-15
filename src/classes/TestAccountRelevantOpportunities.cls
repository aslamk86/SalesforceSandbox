/*****************************************************************************
 * Name             : TestAccountRelevantOpportunities
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 17 Jan, 2012.
 * Purpose          : Test Class for AccountRelevantOpportunities.
 *                    T-22105
 *****************************************************************************/
@isTest
private class TestAccountRelevantOpportunities {

	static testMethod void TestAccountRelevantOpportunity() {
	  Account acct = TestUtil.createAccount(true);
	  
	  //Create Product
	  List<Product_or_Service__c> lstProdServ = new List<Product_or_Service__c>(); 
    lstProdServ.add(TestUtil.createProductOrServices('PS1', false));
    lstProdServ.add(TestUtil.createProductOrServices('PS2', false));
    lstProdServ.add(TestUtil.createProductOrServices('PS3', false));
    insert lstProdServ;
    
    //Add product into Account
    List<account2product__c> lstAccToProdMap = new List<account2product__c>();
    for(Product_or_Service__c ps : lstProdServ) {
      lstAccToProdMap.add(
        TestUtil.createCompanyToProductRecord(acct.Id, ps.Id, false));
    }
    lstAccToProdMap[2].Does_Not_Care__c = true;
    insert lstAccToProdMap;
    
    //Create Patent Family;
    Assets__c patentFamily = TestUtil.createPortfolio(true);
    
    Map<String,Id> oppRecType = TestUtil.getRecordType('Acquisition_Opportunity__c');
    //Create Acquisition Opportunity Records
    List<Acquisition_Opportunity__c> lstAcqOpp = new List<Acquisition_Opportunity__c>();
    lstAcqOpp.add(TestUtil.createAcquisitionOpp(acct.Id, 'Phase 0', 'AOpp0', false));
    lstAcqOpp.add(TestUtil.createAcquisitionOpp(acct.Id, 'Phase 1', 'AOpp1', false));
    lstAcqOpp.add(TestUtil.createAcquisitionOpp(acct.Id, 'Phase 2', 'AOpp2', false));
    
    for(Acquisition_Opportunity__c acqOpp : lstAcqOpp) {
    	acqOpp.RecordTypeId = oppRecType.get('OMA');
    }
    insert lstAcqOpp;
    
    //Add Families in Acquisition Opportunity 
    List<Acquisition_Patent_Families__c> lstAcqPatentFamily = new List<Acquisition_Patent_Families__c>();
    for (Acquisition_Opportunity__c acqOpp : lstAcqOpp) {
	    lstAcqPatentFamily.add(TestUtil.createAcqOppFamily(acqOpp.Id, patentFamily.Id, false));
    }
    insert lstAcqPatentFamily;
     
    //Add product in Patent Family
    List<portfolio2product__c> lstPF2Prod = new List<portfolio2product__c>();
    lstPF2Prod.add(TestUtil.createPortFolioToProductRecord(patentFamily.Id, lstProdServ[0].Id, lstAcqOpp[0].Id, false));
    lstPF2Prod.add(TestUtil.createPortFolioToProductRecord(patentFamily.Id, lstProdServ[1].Id, lstAcqOpp[1].Id, false));
    lstPF2Prod.add(TestUtil.createPortFolioToProductRecord(patentFamily.Id, lstProdServ[2].Id, lstAcqOpp[2].Id, false));
    
    //Remove below lines when Required Opportunity validation gets removed.
    /*Opportunity opp = TestUtil.createOpportunity(acct.Id, 'Phase0', true); 
    lstPF2Prod[0].Opportunity__c = opp.Id;
    lstPF2Prod[1].Opportunity__c = opp.Id;
    lstPF2Prod[2].Opportunity__c = opp.Id;*/
    insert lstPF2Prod;
    
    Test.startTest();
    Test.setCurrentPage(Page.AccountRelevantOpportunities);
    Map<String, String> pageParams = Apexpages.currentPage().getParameters();
    pageParams.put('AccountId', acct.Id);
    
    AccountRelevantOpportunities controller = new AccountRelevantOpportunities();
    System.assertEquals(3, controller.getacqOppList().size());
    
    controller.filterCriteria.Name = 'AOpp0';
    controller.filterAndSort(); 
    System.assertEquals(1, controller.getacqOppList().size(), 
      'There must be two result rows one ' 
      + 'for do not care and one as per selected criteria');
    
    controller.filterCriteria.Name = 'AOpp';
    controller.filterAndSort();
    System.assertEquals(3, controller.getacqOppList().size());
    
    //Testing sorting
    //controller.sortExpression = 'name';
    //controller.setSortDirection('DESC');
    controller.filterAndSort();
    System.assertEquals(3, controller.getacqOppList().size());
    
    //controller.sortExpression = 'CloseDate__c';
    //controller.setSortDirection('ASC');
    controller.filterAndSort();
    System.assertEquals(3, controller.getacqOppList().size());
    
    //After filling all filter criteria.
    controller.filterCriteria.Name = lstAcqOpp[0].Name;
    controller.filterCriteria.CloseDate__c = lstAcqOpp[0].CloseDate__c;
    //controller.filterCriteria.Probability__c = lstAcqOpp[0].Probability__c;
    controller.filterCriteria.StageName__c = lstAcqOpp[0].StageName__c;
    controller.filterAndSort();
    System.assertEquals(1, controller.getacqOppList().size());
    controller.reset();
    Test.stopTest();
    
    
	}
	
}