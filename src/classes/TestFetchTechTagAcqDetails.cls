@isTest(seealldata =true)
public class TestFetchTechTagAcqDetails{
    static testmethod void testFetchTechTagAcqDetails(){
        
        List<Product_or_Service__c> techTagList = new List<Product_or_Service__c>();
        techTagList.add(new Product_or_Service__c(Name='Test TechTag1'));
        techTagList.add(new Product_or_Service__c(Name='Test TechTag2'));
        techTagList.add(new Product_or_Service__c(Name='Test TechTag3'));        
        insert techTagList;                      
        
        ApexPages.StandardController techtag = new ApexPages.Standardcontroller(techTagList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceTechTagAcq());
        Test.startTest();
        FetchTechTagAcqDetails facld= new FetchTechTagAcqDetails(techtag);
        FetchTechTagAcqDetailsWrapper.response falResp = new FetchTechTagAcqDetailsWrapper.response();
        if(facld.FetchTechTagAcqDetailsWrapList.size()>0)
        falResp =facld.FetchTechTagAcqDetailsWrapList[0];
        else
        falResp=null;
        facld.FetchTechTagDetails();        
        facld.loadMoreLicensees();     
        facld.loadPrevLicensees();                                            
        Test.stopTest();          
    }          
}