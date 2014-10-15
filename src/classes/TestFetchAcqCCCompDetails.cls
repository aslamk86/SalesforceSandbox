@isTest(seealldata =true)
public class TestFetchAcqCCCompDetails{
    static testmethod void testFetchAcqCCCompDetails(){
        
        List<Acquisition_Opportunity__c> acqList = new List<Acquisition_Opportunity__c>();
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee1'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee2'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee3'));        
        insert acqList;                      
        
        ApexPages.StandardController acq = new ApexPages.Standardcontroller(acqList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceCCComp());
        Test.startTest();
        FetchAcqCCCompDetails facld= new FetchAcqCCCompDetails(acq);
        FetchCCCompDetailsWrapper.response falResp = new FetchCCCompDetailsWrapper.response();
        if(facld.FetchAcqCCCompDetailsWrapList.size()>0)
        falResp =facld.FetchAcqCCCompDetailsWrapList[0];
        else
        falResp=null;
        facld.FetchCCCompDetails();        
        facld.loadMoreLicensees();     
        facld.loadPrevLicensees();
        facld.sortData();                                            
        Test.stopTest();          
    }          
}