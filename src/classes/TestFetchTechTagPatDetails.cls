@isTest(seealldata =true)
public class TestFetchTechTagPatDetails{
    static testmethod void testFetchTechTagPatDetails(){
        
        List<Product_or_Service__c> techTagList = new List<Product_or_Service__c>();
        techTagList.add(new Product_or_Service__c(Name='Test TechTag1'));
        techTagList.add(new Product_or_Service__c(Name='Test TechTag2'));
        techTagList.add(new Product_or_Service__c(Name='Test TechTag3'));        
        insert techTagList;                      
        
        ApexPages.StandardController techtag = new ApexPages.Standardcontroller(techTagList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceTechTagPat());
        Test.startTest();
        FetchTechTagPatentDetails facld= new FetchTechTagPatentDetails(techtag);
        FetchTechTagPFDetailsWrapper.response falResp = new FetchTechTagPFDetailsWrapper.response();
        if(facld.FetchTechTagPFDetailsWrapList.size()>0)
        falResp =facld.FetchTechTagPFDetailsWrapList[0];
        else
        falResp=null;
        facld.FetchTechTagDetails();        
        facld.loadMoreLicensees();     
        facld.loadPrevLicensees();                                            
        Test.stopTest();          
    }          
}