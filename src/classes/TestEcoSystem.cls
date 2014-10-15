@isTest(SeeAllData=true)
private class TestEcoSystem{
    static testmethod void testEcoSystem(){
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='Test Account Ecosystem'));
        accList.add(new Account(Name='Test Account Ecosystem'));
        accList.add(new Account(Name='Test Account Ecosystem'));        
        insert accList;
        List<Ecosystem__c> ecoList = new List<EcoSystem__c>();
        ecoList.add(new Ecosystem__c(Company__c=accList[0].id,status__c='Draft',Version_Name__c='Test'));
        ecoList.add(new Ecosystem__c(Company__c=accList[0].id,status__c='Final',Version_Name__c='Test',Version__c=1));
        ecoList.add(new Ecosystem__c(Company__c=accList[0].id,status__c='Final',Version_Name__c='Test',Version__c=2,Most_recent__c=true));
        insert ecoList;               
        
        ApexPages.StandardController acc = new ApexPages.Standardcontroller(accList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceCoDefMock());
        Test.startTest();
        EcosSystemController ecos = new EcosSystemController(acc);
        ecos.selectedEcoSystem=ecoList[0].id;                                                                           
        ecos.accountIdToAdd = accList[1].id;  
        ecos.typeOfRecord = 'Manual';
        ecos.searchString = 'cisco';
        ecos.addToEcosystem();                                                  
        Test.stopTest();          
    }
    
    static testmethod void testEcoSystem2(){
        
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name='Test Account Ecosystem'));
        accList.add(new Account(Name='Test Account Ecosystem'));
        accList.add(new Account(Name='Test Account Ecosystem'));        
        insert accList;
        List<Ecosystem__c> ecoList = new List<EcoSystem__c>();
        ecoList.add(new Ecosystem__c(Company__c=accList[0].id,status__c='Draft',Version_Name__c='Test'));
        ecoList.add(new Ecosystem__c(Company__c=accList[0].id,status__c='Final',Version_Name__c='Test',Version__c=1));
        ecoList.add(new Ecosystem__c(Company__c=accList[0].id,status__c='Final',Version_Name__c='Test',Version__c=2,Most_recent__c=true));
        insert ecoList;               
        
        ApexPages.StandardController acc = new ApexPages.Standardcontroller(accList[0]);      
        
        Test.setMock(HttpCalloutMock.class, new WebServiceCoDefMock());
        Test.startTest();
        EcosSystemController ecos = new EcosSystemController(acc);
        ecos.selectedEcoSystem=ecoList[0].id; 
        ecos.searchString = 'cisco';
        ecos.accountIdToAdd = accList[2].id;
        ecos.addToEcosystem();
        
        List<EcoSystem_Detail__c> ecoSystem_detail = ecos.accountsToShowInList;
        
        ecos.tobeRemoved = ecoSystem_detail[0].id;
        ecos.removeAccountFromSelection();
        
        ecos.showPopup();
        ecos.finalizeVersion();
        ecos.closePopup();                
        
        ecos.clone=true;
        ecos.createNewDraftVersion();
        
        ecos.deleteDraftId=ecos.selectedEcoSystem;
        ecos.deleteDraft();
        
        ecos.selectedEcoSys = ecoList[2].id;
        //ecos.getCompareWrapperListSelOptions();        
        
        Test.stopTest();
    }
    
}