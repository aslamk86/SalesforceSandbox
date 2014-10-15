@isTest(seealldata =true)
public class TestFetchAcqTechTagDetails{
    static testmethod void testFetchAcqTechTagDetails(){
        
        List<Acquisition_Opportunity__c> acqList = new List<Acquisition_Opportunity__c>();
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee1'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee2'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee3'));        
        insert acqList;                      
        
        ApexPages.StandardController acq = new ApexPages.Standardcontroller(acqList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceTechTag());
        Test.startTest();
        FetchAcqTechTagDetails facld= new FetchAcqTechTagDetails(acq);
        FetchTechTagDetailsWrapper.response falResp = new FetchTechTagDetailsWrapper.response();
        if(facld.FetchAcqTechTagDetailsWrapList.size()>0)
        falResp =facld.FetchAcqTechTagDetailsWrapList[0];
        else
        falResp=null;
        facld.FetchTechTagDetails();        
        facld.loadMoreLicensees();     
        facld.loadPrevLicensees();
        facld.sortData();                                            
        Test.stopTest();          
    }          
}