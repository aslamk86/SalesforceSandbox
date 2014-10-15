@isTest(seealldata =true)
public class TestFetchAcccntTransactionDetails{

    static testmethod void TestFetchAcccntTransactionDetails(){
    
        List<Account> accList= new List<Account>();
        accList.add(new Account(Name='Test Account1'));
        accList.add(new Account(Name='Test Account2'));
        accList.add(new Account(Name='Test Account3'));        
        insert accList;                      
        
        ApexPages.StandardController acc = new ApexPages.Standardcontroller(accList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceAccTransaction());
        Test.startTest();
        FetchAccountTransactionDetails facld= new FetchAccountTransactionDetails(acc);
        
        FetchAcqOrAccTransactionWrapper.response falResp = new FetchAcqOrAccTransactionWrapper.response();
        if(facld.FetchAccViewWrapList.size()>0) {
            falResp =facld.FetchAccViewWrapList[0];
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