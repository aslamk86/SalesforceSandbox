@isTest(seealldata =true)
public class TestFetchAcqLicenseeDetails{
    static testmethod void testFetchAcqLicenseeDetails(){
        
        List<Acquisition_Opportunity__c> acqList = new List<Acquisition_Opportunity__c>();
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee1'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee2'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee3'));        
        insert acqList;                      
        
        ApexPages.StandardController acq = new ApexPages.Standardcontroller(acqList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceLicensee());
        Test.startTest();
        FetchAcquisitionLicenseeDetails facld= new FetchAcquisitionLicenseeDetails(acq);
        FetchLicenseeDetailsWrapper.response falResp = new FetchLicenseeDetailsWrapper.response();
        if(facld.FetchLicenseeDetailsWrapList.size()>0)
        falResp =facld.FetchLicenseeDetailsWrapList[0];
        else
        falResp=null;
        facld.FetchLicenseeDetails();        
        facld.loadMoreLicensees();     
        facld.loadPrevLicensees();
        facld.sortData();                                            
        Test.stopTest();          
    }          
}