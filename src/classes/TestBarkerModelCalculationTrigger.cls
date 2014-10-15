/****************************************************************************
 * Name             : TestBarkerModelCalculationTrigger
 * Created By       : Bharti(Appirio Offshore)
 * Created Date     : 18 Jan, 2012.
 * Purpose          : TestClass for BarkerModelCalculationTrigger 
*****************************************************************************/
@isTest
private class TestBarkerModelCalculationTrigger {
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
        rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    } 
    static testMethod void myUnitTest() {
       //test data start
      Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
       Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
       Schema.RecordTypeInfo rtByName =  rtMapByName.get('Prospect');
       
       List<Account> listAccount = new List<Account>();
       Account testAccount = TestUtil.createAccount(false);
       testAccount.Entity_ID__c = 99999994;
       testAccount.Remaining_Credit__c = 1000.00;
       testAccount.Member_Credit_Remaining_No_Pre_Contrac__c = 10.0;
       testAccount.RecordTypeId = rtByName.getRecordTypeId();
       listAccount.add(testAccount);
       
       Account testAccount1 = TestUtil.createAccount(false);
       testAccount1.Entity_ID__c = 99999995;
       testAccount1.Remaining_Credit__c = 1000.00;
       testAccount1.Member_Credit_Remaining_No_Pre_Contrac__c = 10.0;
       //testAccount1.RecordTypeId = rtByName.getRecordTypeId();
       listAccount.add(testAccount1);
       
       insert listAccount;
       
       Acquisition_Opportunity__c acqOpportunity = TestUtil.createAcquisitionOpp(listAccount[1].Id, 'Hold', 'Test AcQ Oppty', false);
       acqOpportunity.RecordTypeId = getRecortdTypeIdForAcqOpp('OMA');
       insert acqOpportunity;
       
       BarkerModel__c barkerModel = TestUtil.createBarkerModel(acqOpportunity.Id,false);  
       barkerModel.Credit_Toggle__c = '0 – Credit Remaining'; 
       
       insert barkerModel; 
       //test data end
       
       //test start
       Test.startTest();
        List<BarkerModelCalculation__c> listBMC = new List<BarkerModelCalculation__c>();       
        listBMC.add(TestUtil.createBarkerModelCalculation(listAccount[0].Id,barkerModel.Id,false));
        insert listBMC;
        
        barkerModel.Credit_Toggle__c = '1 - Exclude Pending Deals';
        barkerModel.Exclude_Pre_Contract_Credit__c = true;
        update barkerModel;
        
        listBMC[0].Probability_Weighting__c += 10;
        update listBMC;
        
        barkerModel.Credit_Toggle__c = '3 - Other';
        update barkerModel;
        
        listBMC[0].Probability_Weighting__c += 10;
        update listBMC;
        
                
        acqOpportunity.StageName__c = 'Rejected';
        acqOpportunity.Closed_Lost_Primary_Reason_LIT__c = 'Timing';
        update acqOpportunity;
        try{
        delete listBMC[0];
        }catch(DmlException ex){
            System.assert(listBMC[0].id != null);
        }
       Test.stopTest();
       //test end
    }
    static Id getRecortdTypeIdForAcqOpp(String recordType){
        return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
    }  
}