@isTest(seealldata =true)
public class TestFetchTransactionDetails{

    static testmethod void TestTransactionDetails(){
    
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
        
        Test.setMock(HttpCalloutMock.class, new WebServiceTransactionDetails());
        Test.startTest();
        PageReference pageRef = Page.TransactionDetails;
        pageRef.getParameters().put('TransactionId', '101352');
        Test.setCurrentPage(pageRef);
        FetchTransactionDetails  facld= new FetchTransactionDetails();
        facld.patViewPageNum =2;
        facld.FetchTransactions();
        
        FetchTransactionDetailWrapper.response falResp = new FetchTransactionDetailWrapper.response();
        if(facld.FetchTransactionDetailWrapList.size()>0) {
            falResp =facld.FetchTransactionDetailWrapList[0];
        }
        else {
            falResp=null;
        }   
        
        TDRelatedPatentsWrapper falResp2 = new TDRelatedPatentsWrapper();
        if(facld.TDRelatedPatentsWrapList.size()>0) {
            falResp2.response =facld.TDRelatedPatentsWrapList;
        }
        else {
            falResp2=null;
        }   
        
        TDRelatedAcqsWrapper.response falResp3 = new TDRelatedAcqsWrapper.response();
        if(facld.TDRelatedAcqsWrapList.size()>0) {
            falResp3 =facld.TDRelatedAcqsWrapList[0];
        }
        else {
            falResp3=null;
        }
        
        TDRelatedAssnWrapper.response falResp4 = new TDRelatedAssnWrapper.response();
        if(facld.TDRelatedAssnWrapList.size()>0) {
            falResp4 =facld.TDRelatedAssnWrapList[0];
        }
        else {
            falResp4=null;
        }
        
        facld.loadMorePatents();
        facld.loadPrevPatents();
        facld.loadMoreAcqs();
        facld.loadPrevAcqs();
        facld.loadMoreAssns();
        facld.loadPrevAssns();
        Test.stopTest();          
    }    
    
     static testmethod void TestTransactionDetails2(){
    
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
        
        Test.setMock(HttpCalloutMock.class, new WebServiceTDRelatedPatents());
        Test.startTest();
        PageReference pageRef = Page.TransactionDetails;
        pageRef.getParameters().put('TransactionId', '101352');
        Test.setCurrentPage(pageRef);
        FetchTransactionDetails  facld= new FetchTransactionDetails();
        facld.patViewPageNum =2;
        facld.FetchTransactions();
        TDRelatedPatentsWrapper falResp2 = new TDRelatedPatentsWrapper();
        if(facld.TDRelatedPatentsWrapList.size()>0) {
            falResp2.response =facld.TDRelatedPatentsWrapList;
        }
        else {
            falResp2=null;
        }  
        facld.loadMorePatents();
        facld.loadPrevPatents();
        Test.stopTest(); 
    }    
    
    static testmethod void TestTransactionDetails3(){

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

        Test.setMock(HttpCalloutMock.class, new WebServiceTransactionDetails());
        Test.startTest();
        PageReference pageRef = Page.TransactionDetails;
        pageRef.getParameters().put('TransactionId', null);
        Test.setCurrentPage(pageRef);
        FetchTransactionDetails  facld= new FetchTransactionDetails();
        facld.patViewPageNum =2;
        facld.FetchTransactions();
        Test.stopTest(); 
    }
}