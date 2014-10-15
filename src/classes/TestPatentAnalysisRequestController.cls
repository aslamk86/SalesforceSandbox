/*****************************************************************************
 * Name                 : TestPatentAnalysisRequestController
 * Created By           : Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for PatentAnalysisRequestController.
 *****************************************************************************/
@isTest
private class TestPatentAnalysisRequestController {
        //Test Method to check the Quality of the Code
    static testMethod void myUnitTest() {
        //Patent analysis requests list
        List<Patent_Analysis_Request__c> analysisRequestList = new List<Patent_Analysis_Request__c>();
        //Create account
        Account acc = TestUtil.createAccount(true);
        //Create Acq opp
        Acquisition_Opportunity__c acqOpp = createAcquisitionOpp(acc.Id, 'Phase - 1','Test - PAR#1', true);
        //Create Patent analysis requests
        analysisRequestList.add(createPatentAnalysisRequest(acqOpp.id,false));
        analysisRequestList.add(createPatentAnalysisRequest(acqOpp.id,false));
        analysisRequestList.add(createPatentAnalysisRequest(acqOpp.id,false));
        insert analysisRequestList;
        Test.startTest();
                //Set the current page reference to PatentAnalysisRequest
            PageReference pageRef = Page.PatentAnalysisRequest;
            Test.setCurrentPageReference(pageRef);
            //set current page Parameter the Id of Patent analysis request 
            ApexPages.currentPage().getParameters().put('id',analysisRequestList[0].Id);
            ApexPages.currentPage().getParameters().put('sfdc.tabname', '01r400000005jpW');
            //Constructor call of standard controller
            ApexPages.StandardController controller = new ApexPages.StandardController(analysisRequestList[0]);
            //Constructor call of PatentAnalysisRequestController controller
            PatentAnalysisRequestController patentrequest = new PatentAnalysisRequestController(controller);
            //method call
            patentrequest.saveRequests();
            patentrequest.analysisRequests[0].oldRowNumber = 1;
            patentrequest.analysisRequests[0].rowNumber = 2;
            patentrequest.analysisRequests[0].hasRankingModified = true;            
            patentrequest.analysisRequests[0].request.Status__c = 'Completed';
            
            patentrequest.analysisRequests[1].oldRowNumber = 2;
            patentrequest.analysisRequests[1].rowNumber = 1;
            patentrequest.analysisRequests[1].hasRankingModified = true;                                    
            
            patentrequest.analysisRequests[3].oldRowNumber = 3;
            patentrequest.analysisRequests[3].rowNumber = 3;
            patentrequest.analysisRequests[3].hasRankingModified = true;
                                    
            //method call
            patentrequest.saveRequests();
            
            //for code coverage only 
            patentrequest.getfilterOptions();
            patentrequest.selectedFilter = Label.PatentAnalysisRequestMyView;
            patentrequest.applyFilter();
            
            ApexPages.currentPage().getParameters().put('sfdc.tabname', '01re00000000O3P');
            PatentAnalysisRequestController priorArtRequest = new PatentAnalysisRequestController(controller);
            priorArtRequest.sortData();
            priorArtRequest.sortData();
            
        Test.stopTest();
    }

    //A method to create Patent Analysis Request
    static Patent_Analysis_Request__c createPatentAnalysisRequest(Id acqOppId,Boolean isInsert){
          Patent_Analysis_Request__c request= new Patent_Analysis_Request__c();
          request.Acquisition_Opportunity__c = acqOppId;
          request.Request_Type__c = 'Other';
          request.Status__c = 'Pending';
          request.Assigned_To__c = UserInfo.getUserId();
          //request.Analysis_Type__c = 'Refresh';
          if(isInsert)
              insert request;
          return request;
    }
    
    //CreateAcquisitionOpp
    private static Integer autoNumber = 1;
    static Acquisition_Opportunity__c createAcquisitionOpp(
    Id accId, String stageName, String name, Boolean isInsert) {
        
    Acquisition_Opportunity__c acqOpp = new Acquisition_Opportunity__c();
    acqOpp.Account__c = accId; 
    acqOpp.StageName__c = stageName;
    acqOpp.Name = name;
    acqOpp.Probability__c = '25';
    acqOpp.CloseDate__c = Date.today();
    acqOpp.Purchase_Date__c = Date.today();
    acqOpp.ContractEffectiveDate__c = Date.today();
    acqOpp.Amount_for_Pipeline__c = 50;
    acqOpp.LegacyOpportunityID__c = String.valueOf(autoNumber++);
    
    if (isInsert) {
        insert acqOpp;
    }
    return acqOpp;
  }
}