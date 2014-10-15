@isTest(seealldata =true)
public class TestFetchAcqRelCompDetails{
    static testmethod void testFetchAcqRelCompDetails(){
        
        List<Acquisition_Opportunity__c> acqList = new List<Acquisition_Opportunity__c>();
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee1'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee2'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee3'));        
        insert acqList;                      
        
        ApexPages.StandardController acq = new ApexPages.Standardcontroller(acqList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceRelevantComp());
        Test.startTest();
        FetchAcqRelCompDetails facld= new FetchAcqRelCompDetails(acq);
        FetchRelCompDetailsWrapper.response falResp = new FetchRelCompDetailsWrapper.response();
        if(facld.FetchAcqRelCompDetailsWrapList.size()>0)
        falResp =facld.FetchAcqRelCompDetailsWrapList[0];
        else
        falResp=null;
        facld.FetchRelCompDetails();        
        facld.loadMoreLicensees();     
        facld.loadPrevLicensees();   
        facld.sortData();                                         
        Test.stopTest();          
    }          
}