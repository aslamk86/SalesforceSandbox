@isTest(seealldata =true)
public class TestFetchPatentTransactionDetails{
    static testmethod void testFetchPatentTransactionDetails(){
        
        List<patent__c> patList = new List<patent__c>();
        patList.add(new patent__c(Name='Test Patent1',Core_DB_Patent_ID__c=123456789));
        patList.add(new patent__c(Name='Test Patent2',Core_DB_Patent_ID__c=1234567891));
        patList.add(new patent__c(Name='Test Patent3',Core_DB_Patent_ID__c=1234567892));        
        insert patList;                      
        //API_ENDPOINT_URLS__c
        
        ApexPages.StandardController pat = new ApexPages.Standardcontroller(patList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServicePatTransaction());
        Test.startTest();
        FetchPatentTransactionViewDetails fald= new FetchPatentTransactionViewDetails(pat);       
        FetchPatentTransactionViewWrapper.response falResp = new FetchPatentTransactionViewWrapper.response();
        if(fald.FetchPatentViewWrapList.size()>0)
        falResp =fald.FetchPatentViewWrapList[0];
        else
        falResp=null;       
        fald.FetchTransactions();                
        fald.loadMoreLicensees();     
        fald.loadPrevLicensees();                                            
        Test.stopTest();          
    }          
}