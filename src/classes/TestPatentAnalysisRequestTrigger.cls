/*****************************************************************************
 * Name             	: TestPatentAnalysisRequestTrigger
 * Created By       	: Bharti Bhandari(Appirio Offshore)
 * Last Modified Date : 13 March, 2012.
 * Description        : Test Class for PatentAnalysisRequestTrigger.
 *****************************************************************************/
@IsTest(SeeAllData=true)
private class TestPatentAnalysisRequestTrigger  {
		//Test Method to check the quality of code
    static testMethod void myUnitTest() {
    	//Patent Analysis Request list
      List<Patent_Analysis_Request__c> analysisRequestList = new List<Patent_Analysis_Request__c>();
      //Create Test Data
      //Create an Account
      Account acc = TestUtil.createAccount(true);
      //Create Acq opp
      Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acc.Id, 'Phase - 1','Test', true);
      //Start Testing
      Test.startTest();
          //Create Patent Analysis Request to fire a trigger on insert Event
          analysisRequestList.add(createPatentAnalysisRequest(acqOpp.id,false));
          analysisRequestList.add(createPatentAnalysisRequest(acqOpp.id,false));
          analysisRequestList.add(createPatentAnalysisRequest(acqOpp.id,false));
          insert analysisRequestList;
          
          //Update Patent Analysis Request to fire a trigger on Update Event
          analysisRequestList[0].Assigned_To__c  = UserInfo.getUserId();
          analysisRequestList[1].Assigned_To__c  = UserInfo.getUserId();
          analysisRequestList[2].Assigned_To__c  = UserInfo.getUserId();
          update analysisRequestList;
          //Retrieve patent analysis requests
          List<Patent_Analysis_Request__c> retrievePatentAnalysisRequestList = [select Ranking__c,SendAssignmentNotification__c from Patent_Analysis_Request__c where Id In :analysisRequestList];
          // Check for all SendAssignmentNotification__c must be true if Assigned_To__c is not null
          system.assertEquals(retrievePatentAnalysisRequestList[0].SendAssignmentNotification__c ,true);
          system.assertEquals(retrievePatentAnalysisRequestList[1].SendAssignmentNotification__c ,true);
          system.assertEquals(retrievePatentAnalysisRequestList[2].SendAssignmentNotification__c ,true);
          
          
          /*
          system.assertEquals(retrievePatentAnalysisRequestList[0].Ranking__c ,ranking.Value__c+1);
          system.assertEquals(retrievePatentAnalysisRequestList[1].Ranking__c ,ranking.Value__c+2);
          system.assertEquals(retrievePatentAnalysisRequestList[2].Ranking__c ,ranking.Value__c+3);
          */
       Test.stopTest();
    }
    //Create patent analysis request
    static Patent_Analysis_Request__c createPatentAnalysisRequest(Id acqOppId,Boolean isInsert){
          Patent_Analysis_Request__c request= new Patent_Analysis_Request__c();
          request.Acquisition_Opportunity__c = acqOppId;
          request.Request_Type__c = 'Other';
          request.Status__c = 'Completed';
          if(isInsert) {
            insert request;
          }
          return request;
    }
}