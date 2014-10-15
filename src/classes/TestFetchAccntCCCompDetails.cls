@isTest(seealldata =true)
public class TestFetchAccntCCCompDetails{
    static testmethod void testFetchAccntCCCompDetails(){
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='Test Account Licensee'));
        accList.add(new Account(Name='Test Account Licensee'));
        accList.add(new Account(Name='Test Account Licensee'));        
        insert accList;                      
        
        ApexPages.StandardController acc = new ApexPages.Standardcontroller(accList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceCCComp());
        Test.startTest();
        FetchAccntCCCompDetails fald= new FetchAccntCCCompDetails(acc);       
        FetchCCCompDetailsWrapper.response falResp = new FetchCCCompDetailsWrapper.response();
        system.debug('@@intest fald.FetchAccntCCCompDetailsWrapList'+fald.FetchAccntCCCompDetailsWrapList);
        if(fald.FetchAccntCCCompDetailsWrapList.size()>0)
        falResp =fald.FetchAccntCCCompDetailsWrapList[0];
        else
        falResp=null;
        fald.FetchCCCompDetails();        
        fald.loadMoreLicensees();     
        fald.loadPrevLicensees();  
        fald.sortData();                                          
        Test.stopTest();          
    }
    
  
    
}