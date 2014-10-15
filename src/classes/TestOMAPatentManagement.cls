/*****************************************************************************
 * Name             : TestOMAPatentManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 06 Feb, 2012.
 * Purpose          : Test class for OMAPatentManagement
 *                    T-24262  
*****************************************************************************/
@isTest
private class TestOMAPatentManagement {

  static testMethod void testOMAPatentManagement() {
    //Acquisition Opportunity
    //Patent
    Account acct = TestUtil.createAccount(true);
    Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test acqOpp', false);
    RecordType OMARecType = [Select id 
                             From RecordType
                             Where SobjectType = 'Acquisition_Opportunity__c' 
                             And Name = 'OMA'][0];
    acqOpp.RecordTypeId = OMARecType.Id;
    insert acqOpp;
    
    List<Assets__c> lstPatentFamily = new List<Assets__c>();
    lstPatentFamily.add(TestUtil.createPortfolio(false));
    lstPatentFamily.add(TestUtil.createPortfolio(false));
    lstPatentFamily.add(TestUtil.createPortfolio(false));
    insert lstPatentFamily;
    
    List<Patent__c> lstPatent = new List<Patent__c>();
    lstPatent.add(TestUtil.createPatent(lstPatentFamily[0].Id, false));
    lstPatent.add(TestUtil.createPatent(lstPatentFamily[0].Id, false));
    lstPatent.add(TestUtil.createPatent(lstPatentFamily[1].Id, false));
    //lstPatent.add(TestUtil.createPatent(lstPatentFamily[2].Id, false));
    insert lstPatent;
    
    Test.startTest();
    List<OMA_Patent__c> lstOMAPatents = new List<OMA_Patent__c>();
	  for(Patent__c patent : lstPatent) {
	      OMA_Patent__c pt = new OMA_Patent__c();
	      pt.Acquisition_Opportunity__c = acqOpp.Id;
	      pt.Patent__c = patent.Id;
	      lstOMAPatents.add(pt);
	  }
	  insert lstOMAPatents[0];
	  System.assertEquals(1, [Select count() 
                            From Acquisition_Patent_Families__c
                            Where Acquisition_Opportunity__c = :acqOpp.Id]);
    
    insert lstOMAPatents[1];
    //same patent family so no record will be added
    System.assertEquals(1, [Select count() 
                            From Acquisition_Patent_Families__c
                            Where Acquisition_Opportunity__c = :acqOpp.Id]);
    
    insert lstOMAPatents[2];
    System.assertEquals(2, [Select count() 
                            From Acquisition_Patent_Families__c
                            Where Acquisition_Opportunity__c = :acqOpp.Id]);
                            
    
    delete lstOMAPatents[0];
    
    // Stopping the test now to avoid "too many queries" governor limit
    Test.stopTest();
    
    System.assertEquals(2, [Select count() 
                            From Acquisition_Patent_Families__c
                            Where Acquisition_Opportunity__c = :acqOpp.Id]);
    
    delete lstOMAPatents[1];
    System.assertEquals(1, [Select count() 
                            From Acquisition_Patent_Families__c
                            Where Acquisition_Opportunity__c = :acqOpp.Id]);
    
    delete lstOMAPatents[2];
    System.assertEquals(0, [Select count() 
                            From Acquisition_Patent_Families__c
                            Where Acquisition_Opportunity__c = :acqOpp.Id]);
      
  }
}