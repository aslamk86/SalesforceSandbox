@isTest(seealldata =true)
public class TestAccountRelevantOpportunitiesNew{

    static testmethod void TestAccountRelevantOpportunitiesNew(){
    
        List<Account> accList= new List<Account>();
        accList.add(new Account(Name='Test Account1'));
        accList.add(new Account(Name='Test Account2'));
        accList.add(new Account(Name='Test Account3'));        
        insert accList;                

        List<Product_or_Service__c> lstProdServ = new List<Product_or_Service__c>(); 
        lstProdServ.add(TestUtil.createProductOrServices('PS1', false));
        lstProdServ.add(TestUtil.createProductOrServices('PS2', false));
        lstProdServ.add(TestUtil.createProductOrServices('PS3', false));
        insert lstProdServ;
        
        
        List<account2product__c> techTagList = new List<account2product__c>(); 
        techTagList.add(new account2product__c(Product_or_Service__c=lstProdServ[0].id,Account__c=accList[0].id));
        techTagList.add(new account2product__c(Product_or_Service__c=lstProdServ[0].id,Account__c=accList[0].id));
        techTagList.add(new account2product__c(Product_or_Service__c=lstProdServ[0].id,Account__c=accList[0].id));
        insert techTagList;
        
        //ApexPages.StandardController acc = new ApexPages.Standardcontroller(accList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceAccountRelevantComp());
        Test.startTest();
        PageReference pageRef = Page.AccountRelevantOpportunitiesNew;
        pageRef.getParameters().put('AccountId', String.valueOf(accList[0].id));
        Test.setCurrentPage(pageRef);
        AccountRelevantOpportunitiesNew  facld= new AccountRelevantOpportunitiesNew();
        
        TechTagMatchedAcqWrapper.response falResp = new TechTagMatchedAcqWrapper.response();
        system.debug('@@intest facld.TechTagMatchedAcqWrapList'+facld.TechTagMatchedAcqWrapList);
        if(facld.TechTagMatchedAcqWrapList.size()>0) {
            falResp =facld.TechTagMatchedAcqWrapList[0];
        }
        else {
            falResp=null;
        }
        
        //facld.FetchTransactions();        
        facld.filterAndSort();   
        facld.reset();      
        //facld.loadPrevLicensees();                                            
        Test.stopTest();          
    }          
}