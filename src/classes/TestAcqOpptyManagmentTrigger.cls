/*****************************************************************************
 * Name                 : TestAcqOpptyManagmentTrigger
 * Created By           : Bharti Bhandari(Appirio Offshore)
 * Modified By        : Martin Sieler - Sept 28, 2012
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for AcquisitionOpportunityTrigger.
 *****************************************************************************/
@isTest
private class TestAcqOpptyManagmentTrigger {
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
    rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    }
    //Test method
  static testMethod void myUnitTest() {
    //Create test data
    Account account = TestUtil.createAccount(false);
    account.Rate_Comments_Manual__c = 'sssss';
    insert account;
    //Testing is start from here
    Test.startTest();
    /*
            //Create Acq Opp
            Acquisition_Opportunity__c acqOpp = createAcquisitionOpportunity(true,account.Id);
            acqOpp.RecordTypeId = rtMapByNameForAcqOpp.get('OMA').getRecordTypeId();
            update acqOpp;
            //On update probabilty (Updated by trigger) should be 10% for Phase 0 Acq Opp.
            system.assertEquals(retrieveAcquisitionOpportunity(acqOpp.Id).Probability__c, '10');*/
              
        //Create Acq Opp 
        Acquisition_Opportunity__c acqOpportunity = createAcquisitionOpportunity(true,account.Id);
        acqOpportunity.Amount_for_Pipeline__c = 100;
        //Update acq Opp
        update acqOpportunity;
        //On update probabilty (Updated by trigger) should be be null for Litigation Acq Opp.
        system.assertEquals(retrieveAcquisitionOpportunity(acqOpportunity.Id).Probability__c, null);
        
        //Insert litigation
        Litigation__c litigition = TestUtil.createLitigation(false);
        litigition.Acquisition_Opportunity__c = acqOpportunity.Id;
        insert litigition;
        
        //Insert defendant ;
        Defendant__c defendant = TestUtil.createDefendant(account.Id, litigition.Id, true);
         
        //Insert opportunity Litigation   
        Opportunity_Litigation__c oppLitigition = TestUtil.createOpportunityLitigation(acqOpportunity.Id, litigition.Id, true);
        
        //Insert clone of acqOpportunity acquisition Opportunity 
        Acquisition_Opportunity__c cloneAcqOpp = acqOpportunity.clone(false);
        cloneAcqOpp.ClonedFrom__c = acqOpportunity.Id;
        cloneAcqOpp.CloseDate__c = Date.today();
        cloneAcqOpp.Name ='TestAcqOptyForAcqOpptyManagmentTrigger';
        insert cloneAcqOpp;
       
        Acquisition_Opportunity__c updatedAcqOpportunity = retrieveAcquisitionOpportunity(acqOpportunity.Id);
        //On update probabilty (Updated by trigger) should be null for Litigation Acq Opp.
        System.assertEquals(updatedAcqOpportunity.Probability__c , null);
    Test.stopTest();
    }
    
    static testMethod void testRecTypeOfBM() {
    Test.startTest();
    Account account = TestUtil.createAccount(false);
    account.Rate_Comments_Manual__c = 'sssss';
    insert account;

    Acquisition_Opportunity__c acqOpportunity = createAcquisitionOpportunity(true,account.Id);
    
    BarkerModel__c bModel = TestUtil.createBarkerModel(acqOpportunity.Id,true);
    BarkerModelCalculation__c bmc = TestUtil.createBarkerModelCalculation(account.Id,bModel.Id,true);
    
    for(BarkerModel__c bm : [ Select id, RecordType.DeveloperName, AcquisitionOpportunity__c,
                                         (Select id, RecordType.DeveloperName
                                          From BarkerModelCalculations__r) 
                                  From BarkerModel__c
                                  Where AcquisitionOpportunity__c = :acqOpportunity.id]) {
                                  
               System.assertEquals('Open',bm.RecordType.DeveloperName); 
               System.assertEquals('Open',bm.BarkerModelCalculations__r[0].RecordType.DeveloperName);                   
    
    }
    acqOpportunity.StageName__c = 'Closed Lost';
    acqOpportunity.Amount_for_Pipeline__c = 100;
    acqOpportunity.Closed_Lost_Primary_Reason_LIT__c = 'Defendant preferred to fight';
    update acqOpportunity;
    
    System.assertEquals('Closed Lost',acqOpportunity.StageName__c);
    for(BarkerModel__c bm : [ Select id, RecordType.DeveloperName, AcquisitionOpportunity__c,
                                         (Select id, RecordType.DeveloperName
                                          From BarkerModelCalculations__r) 
                                  From BarkerModel__c
                                  Where AcquisitionOpportunity__c = :acqOpportunity.id]) {
                                  
               System.assertEquals('Close',bm.RecordType.DeveloperName); 
               System.assertEquals('Close',bm.BarkerModelCalculations__r[0].RecordType.DeveloperName);                      
    
    }
    
    acqOpportunity.StageName__c = 'Closed Won';
    acqOpportunity.Amount_for_Pipeline__c = 100;
    acqOpportunity.Closed_Lost_Primary_Reason_LIT__c = 'Defendant preferred to fight';
    update acqOpportunity;
    
    for(BarkerModel__c bm : [ Select id, RecordType.DeveloperName, AcquisitionOpportunity__c,
                                         (Select id, RecordType.DeveloperName
                                          From BarkerModelCalculations__r) 
                                  From BarkerModel__c
                                  Where AcquisitionOpportunity__c = :acqOpportunity.id]) {
                                  
               System.assertNotEquals('Open',bm.RecordType.DeveloperName); 
               System.assertNotEquals('Open',bm.BarkerModelCalculations__r[0].RecordType.DeveloperName);                    
    
    }
    
    acqOpportunity.StageName__c = 'Phase 1';
    update acqOpportunity;
    
    for(BarkerModel__c bm : [ Select id, RecordType.DeveloperName, AcquisitionOpportunity__c,
                                         (Select id, RecordType.DeveloperName
                                          From BarkerModelCalculations__r) 
                                  From BarkerModel__c
                                  Where AcquisitionOpportunity__c = :acqOpportunity.id]) {
                                  
               System.assertEquals('Open',bm.RecordType.DeveloperName); 
               System.assertEquals('Open',bm.BarkerModelCalculations__r[0].RecordType.DeveloperName);                   
    
    }
    Test.stopTest();
    }
    //A method that is used to create acquisition Opportunity
    static Acquisition_Opportunity__c createAcquisitionOpportunity(Boolean isInsert,Id accountId){
      Acquisition_Opportunity__c opportunity = new Acquisition_Opportunity__c();
      opportunity.Account__c= accountId;
        opportunity.Name='Test Opportunity';
        opportunity.CloseDate__c = Date.today();
        opportunity.StageName__c = 'Phase 1';
        //opportunity.Amount__c = 100000;
        opportunity.ContractEffectiveDate__c = Date.today();
        if(isInsert)
            insert opportunity;
        return opportunity;
    }
    //A method that is used to retrieve Acquisition Opportunity
    static Acquisition_Opportunity__c retrieveAcquisitionOpportunity(Id acqOpportunityId){
        for(Acquisition_Opportunity__c acqOpportunity : [Select Probability__c,ForecastCategoryName__c From Acquisition_Opportunity__c where Id =: acqOpportunityId]){
            return acqOpportunity;
        }
        return null;
    }

}