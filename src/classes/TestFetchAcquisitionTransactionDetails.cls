@isTest(seealldata =true)
public class TestFetchAcquisitionTransactionDetails{

    static testmethod void TestFetchAcquisitionTransactionDetails(){
    
        List<Acquisition_Opportunity__c> acqList = new List<Acquisition_Opportunity__c>();
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee1'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee2'));
        acqList.add(new Acquisition_Opportunity__c(Name='Test Acquisition Licensee3'));        
        insert acqList;                      
        
        ApexPages.StandardController acq = new ApexPages.Standardcontroller(acqList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceLicensee());
        Test.startTest();
        FetchAcquisitionTransactionDetails facld= new FetchAcquisitionTransactionDetails(acq);
        
        FetchAcqOrAccTransactionWrapper.response falResp = new FetchAcqOrAccTransactionWrapper.response();
        if(facld.FetchAcqViewWrapList.size()>0) {
            falResp =facld.FetchAcqViewWrapList[0];
        }
        else {
            falResp=null;
        }
        
        facld.FetchTransactions();        
        facld.loadMoreLicensees();     
        facld.loadPrevLicensees();                                            
        Test.stopTest();          
    }          
}