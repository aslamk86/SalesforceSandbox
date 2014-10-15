/*******************************************************************************
 * Name             : TestAcquisitionOpportunityWrapper
 * Created By       : Neeraj(Appirio Offshore)
 * Created Date     : 25 Feb, 2012.
 * Purpose          : Test class for LitigationCheatSheetController. 
 * Task               T-34016  
 ******************************************************************************/
@isTest
private class TestLitigationCheatSheetController {
	static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    
	static{
	    Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
	    rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
	}
    
	static testMethod void myUnitTest() {
		// TO DO: implement unit test
		Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
		Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
		Schema.RecordTypeInfo rtByName =  rtMapByName.get('Prospect');
		
		Account testAccount = TestUtil.createAccount(false);
		testAccount.RecordTypeId = rtByName.getRecordTypeId();
		insert testAccount;
		
		Acquisition_Opportunity__c acqOpportunity = TestUtil.createAcquisitionOpp(testAccount.Id, 'Hold', 'Test AcQ Oppty', false);
    acqOpportunity.RecordTypeId = getRecortdTypeIdForAcqOpp('Litigations');
    insert acqOpportunity;
   
    Litigation__c litigition = createLitigition(acqOpportunity.Id,true);
   
    Defendant__c defendant = createDefendant(testAccount.Id,litigition.Id,false);
    defendant.Defendant_Name__c = 'test defendant';
    defendant.Date_Terminated__c = Date.today();
    insert defendant;
   
    Opportunity_Litigation__c oppLitigition = createOppLitigition(acqOpportunity.Id,litigition.Id,true);
   
    BarkerModel__c barkerModel = TestUtil.createBarkerModel(acqOpportunity.Id,false);  
    barkerModel.Credit_Toggle__c = '0 – Credit Remaining';
    insert barkerModel;
    
    Test.startTest();   
		ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
		LitigationCheatSheetController controller = new LitigationCheatSheetController(stdController);
		Test.stopTest(); 
	}
    
	static Id getRecortdTypeIdForAcqOpp(String recordType){
		return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
	}
    
	static Litigation__c createLitigition(Id acqOpportunityId ,Boolean isInsert){
		Litigation__c litigition = new Litigation__c();
		litigition.Docket_Number__c = '123456789';
		litigition.Court__c = 'Alaska District Court';
		litigition.Case_Name__c = 'Test';
		litigition.Acquisition_Opportunity__c = acqOpportunityId;
		litigition.Name = 'TestLitigition';
		if(isInsert) {
			insert litigition;
		}
   	return litigition;
	}
	static Opportunity_Litigation__c createOppLitigition(Id acqOpportunityId ,Id litigitionId,Boolean isInsert){
		Opportunity_Litigation__c oppLitigition = new Opportunity_Litigation__c();
		oppLitigition.Acquisition_Opportunity__c = acqOpportunityId;
		oppLitigition.Litigation__c = litigitionId;
		if(isInsert) {
			insert oppLitigition;
		}
		return oppLitigition;
	}
	static Defendant__c createDefendant(Id accountId ,Id litigitionId,Boolean isInsert){
		Defendant__c defendant = new Defendant__c();
		defendant.Account__c = accountId;
		defendant.Litigation_ID__c= litigitionId;
		if(isInsert) {
			insert defendant;
		}
		return defendant;
	} 
}