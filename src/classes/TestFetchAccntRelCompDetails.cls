@isTest(seealldata =true)
public class TestFetchAccntRelCompDetails{
    static testmethod void testFetchAccntRelCompDetails(){
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='Test Account Licensee'));
        accList.add(new Account(Name='Test Account Licensee'));
        accList.add(new Account(Name='Test Account Licensee'));        
        insert accList;                      
        
        ApexPages.StandardController acc = new ApexPages.Standardcontroller(accList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceRelevantComp());
        Test.startTest();
        FetchAccntRelCompDetails fald= new FetchAccntRelCompDetails(acc);       
        FetchRelCompDetailsWrapper.response falResp = new FetchRelCompDetailsWrapper.response();
        if(fald.FetchAccntRelCompDetailsWrapList.size()>0)
        falResp =fald.FetchAccntRelCompDetailsWrapList[0];
        else
        falResp=null;
        fald.FetchRelCompDetails();        
        fald.loadMoreLicensees();     
        fald.loadPrevLicensees();  
        fald.sortData();                                          
        Test.stopTest();          
    }
    
  
    
}