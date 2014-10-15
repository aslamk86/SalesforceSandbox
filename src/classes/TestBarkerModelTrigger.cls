/*****************************************************************************
 * Name             : TestBarkerModelTrigger
 * Created By       : Bharti(Appirio Offshore)
 * Created Date     : 21 Jan, 2012.
 * Purpose          : TestClass for BarkerModelTrigger
*****************************************************************************/
@isTest
private class TestBarkerModelTrigger {
		//Describe Acquisition To Get the record types of Accounts
    static Map<String,Schema.RecordTypeInfo> rtMapByNameForAcqOpp = null;
    static{
        Schema.DescribeSObjectResult d2 = Schema.SObjectType.Acquisition_Opportunity__c; 
        rtMapByNameForAcqOpp = d2.getRecordTypeInfosByName();
    } 
    static testMethod void myUnitTest() { 
       //Describe Accounts To get The Record type Of Accounts.
       Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
       Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
       Schema.RecordTypeInfo rtByName =  rtMapByName.get('Prospect');
       
       //Create Accounts
       List<Account> listAccount = new List<Account>();
       Account testAccount = TestUtil.createAccount(false);
       testAccount.Entity_ID__c = 99999991;
       testAccount.Remaining_Credit__c = 1000.00;
       testAccount.Member_Credit_Remaining_No_Pre_Contrac__c = 10.0;
       testAccount.RecordTypeId = rtByName.getRecordTypeId();
       listAccount.add(testAccount);
       
       Account testAccount1 = TestUtil.createAccount(false);
       testAccount1.Entity_ID__c = 99999992;
       testAccount1.Remaining_Credit__c = 1000.00;
       testAccount1.Member_Credit_Remaining_No_Pre_Contrac__c = 10.0;
       //testAccount1.RecordTypeId = rtByName.getRecordTypeId();
       listAccount.add(testAccount1);
       
       Account testAccount2 = TestUtil.createAccount(false);
       testAccount2.Entity_ID__c = 99999993;
       testAccount2.Remaining_Credit__c = 1000.00;
       testAccount2.Member_Credit_Remaining_No_Pre_Contrac__c = 10.0;
       testAccount2.RecordTypeId = rtByName.getRecordTypeId();
       listAccount.add(testAccount2);
       
       insert listAccount;
       //Insert Acquisition opportunity
       Acquisition_Opportunity__c acqOpportunity = TestUtil.createAcquisitionOpp(listAccount[1].Id, 'Hold', 'Test AcQ Oppty', false);
       acqOpportunity.RecordTypeId = getRecortdTypeIdForAcqOpp('Litigations');
       insert acqOpportunity;
       
       Litigation__c litigition = createLitigition(acqOpportunity.Id,true);
       Defendant__c defendant = createDefendant(listAccount[2].Id,litigition.Id,true);
       Opportunity_Litigation__c oppLitigition = createOppLitigition(acqOpportunity.Id,litigition.Id,true);
       
        //List of patent families
            List<Assets__c> listpatentFamilies = new List<Assets__c>();
            //Insert patent families   
                Assets__c patentFamily1 = TestUtil.createPortfolio(false);
                patentFamily1.Summary__c = 'summary';
                patentFamily1.Earliest_priority__c = date.today().addDays(5);
                patentFamily1.Expiration_Date__c = date.today().addDays(10);
                patentFamily1.Assignment_Note__c = 'ABC';
                patentFamily1.Populate_on_All_Patents_in_Portfolio__c = false;
                listpatentFamilies.add(patentFamily1);
                
                Assets__c patentFamily2 = TestUtil.createPortfolio(false);
                patentFamily2.Summary__c = 'summary';
                patentFamily2.Earliest_priority__c = date.today().addDays(5);
                patentFamily2.Expiration_Date__c = date.today().addDays(10);
                listpatentFamilies.add(patentFamily2);
                insert listpatentFamilies;
                
        Litigation_Patent_Family__c litigationPF1 = TestUtil.createLitigationPatentFamily(listpatentFamilies[0].Id, litigition .Id, true);
        Litigation_Patent_Family__c litigationPF2 = TestUtil.createLitigationPatentFamily(listpatentFamilies[1].Id, litigition .Id, true);
        
        
        
        
        
       Test.startTest();
        //Insert Barker Model
        	BarkerModel__c barkerModel = TestUtil.createBarkerModel(acqOpportunity.Id,false);  
        	barkerModel.Credit_Toggle__c = '0 – Credit Remaining';
        	insert barkerModel;
        
        //Retrieve list of barker model those are inserted by trigger.
					List<BarkerModelCalculation__c> listOfBMA = [select Id From BarkerModelCalculation__c where Account__c IN :listAccount AND BarkerModel__c =: barkerModel.Id];
       		system.assert(listOfBMA.size() > 0);
       		
       		List<BarkerModelCalculation__c> listBMC = new List<BarkerModelCalculation__c>();       
        	listBMC.add(TestUtil.createBarkerModelCalculation(listAccount[0].Id,barkerModel.Id,false));
        	insert listBMC;
        
       	
       	//Update barker Model to fire the trigger on Update event 
        barkerModel.Credit_Toggle__c = '1 - Exclude Pending Deals';
        barkerModel.Exclude_Pre_Contract_Credit__c = true;
        barkerModel.Target_Margin_Prospects__c = 25;
        update barkerModel;
        //Check that Prospect_RPX_target_margin_by_problem_ty__c of barker model Account should be same as Target_Margin_Prospects__c of Barker Model after the trigger fire on update event
        system.assertEquals(barkerModel.Target_Margin_Prospects__c, retrieveBarkerModelAccount(listBMC[0].Id).Prospect_RPX_target_margin_by_problem_ty__c);
        //Update Acquisition
        acqOpportunity.StageName__c = 'Rejected';
        acqOpportunity.Closed_Lost_Primary_Reason_LIT__c = 'Timing';
        update acqOpportunity;
        //Delete barker model to fire the trigger on Delete Event
        try{
        delete barkerModel;
        }catch(DmlException ex){
            System.assert(barkerModel.id != null);
        }
       Test.stopTest();
    }
    ////Get record Type of Acq Opp
    static Id getRecortdTypeIdForAcqOpp(String recordType){
        return rtMapByNameForAcqOpp.get(recordType).getRecordTypeId();
    } 
    //A method To create Litigation
    static Litigation__c createLitigition(Id acqOpportunityId ,Boolean isInsert){
       Litigation__c litigition = new Litigation__c();
       litigition.Docket_Number__c = '123456789';
       litigition.Court__c = 'Alaska District Court';
       litigition.Case_Name__c = 'Test';
       litigition.Acquisition_Opportunity__c = acqOpportunityId;
       litigition.Name = 'TestLitigition';
       if(isInsert)
        insert litigition;
       return litigition;
    }
    //A method to create Opportunity Litigation.
    static Opportunity_Litigation__c createOppLitigition(Id acqOpportunityId ,Id litigitionId,Boolean isInsert){
       Opportunity_Litigation__c oppLitigition = new Opportunity_Litigation__c();
       oppLitigition.Acquisition_Opportunity__c = acqOpportunityId;
       oppLitigition.Litigation__c = litigitionId;
       if(isInsert)
        insert oppLitigition;
       return oppLitigition;
    }
    //A method to Create Defendant
    static Defendant__c createDefendant(Id accountId ,Id litigitionId,Boolean isInsert){
       Defendant__c defendant = new Defendant__c();
       defendant.Account__c = accountId;
       defendant.Litigation_ID__c= litigitionId;
       if(isInsert)
        insert defendant;
       return defendant;
    }
    static BarkerModelCalculation__c retrieveBarkerModelAccount(Id barkerModelAccountId){
    	for(BarkerModelCalculation__c bmc : [select Id,Prospect_RPX_target_margin_by_problem_ty__c From BarkerModelCalculation__c where Id =: barkerModelAccountId]){
    		return bmc;
    	}
    	return null;
    }
        
}