@isTest(seealldata =true)
public class TestFetchAccntLicenseeDetails{
    static testmethod void testFetchAccntLicenseeDetails(){
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='Test Account Licensee'));
        accList.add(new Account(Name='Test Account Licensee'));
        accList.add(new Account(Name='Test Account Licensee'));        
        insert accList;                      
        
        ApexPages.StandardController acc = new ApexPages.Standardcontroller(accList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceLicensee());
        Test.startTest();
        FetchAccntLicenseeDetails fald= new FetchAccntLicenseeDetails(acc);       
        FetchLicenseeDetailsWrapper.response falResp = new FetchLicenseeDetailsWrapper.response();
        if(fald.FetchLicenseeDetailsWrapList.size()>0)
        falResp =fald.FetchLicenseeDetailsWrapList[0];
        else
        falResp=null;
        fald.FetchLicenseeDetails();        
        fald.loadMoreLicensees();     
        fald.loadPrevLicensees();  
        fald.sortData();                                          
        Test.stopTest();          
    }
    
  
    
}