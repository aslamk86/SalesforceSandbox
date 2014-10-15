@isTest(seealldata =true)
public class TestFetchPFTransactionDetails{
    static testmethod void testFetchPFTransactionDetails(){
        
        List<assets__c> patList = new List<assets__c>();
        patList.add(new assets__c(Name='Test PatentFamily1',Core_Patent_Family_Id__c=123456789));
        patList.add(new assets__c(Name='Test PatentFamily2',Core_Patent_Family_Id__c=1234567891));
        patList.add(new assets__c(Name='Test PatentFamily3',Core_Patent_Family_Id__c=1234567892));        
        insert patList;                      
        
        
        ApexPages.StandardController pat = new ApexPages.Standardcontroller(patList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServicePatTransaction());
        Test.startTest();
        FetchPFTransactionViewDetails fald= new FetchPFTransactionViewDetails(pat);       
        FetchPFTransactionViewWrapper.response falResp = new FetchPFTransactionViewWrapper.response();
        if(fald.FetchPatentFamilyViewWrapList.size()>0)
        falResp =fald.FetchPatentFamilyViewWrapList [0];
        else
        falResp=null;       
        fald.FetchTransactions();                
        fald.loadMoreLicensees();     
        fald.loadPrevLicensees();                                            
        Test.stopTest();          
    }          
}