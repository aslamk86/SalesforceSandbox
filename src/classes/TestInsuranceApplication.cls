@isTest
public class TestInsuranceApplication{

public testmethod static void testInsuranceApplication(){
    Account acc = new Account(Name='Test Account #Application');
    insert acc;
    Contact con = new Contact(LastName='Smith',email='abc@mail.com',AccountId=acc.id,Insurance_App_Contact__c=true);
    insert con;
    PageReference pageRef = Page.InsuranceApplicationStartForm;
    test.setCurrentPage(pageRef);

    ApexPages.StandardController app = new ApexPages.Standardcontroller(new Application__c());      
    InsuranceApplicationExt ext = new InsuranceApplicationExt(app);
   	
    ext.thisApplication.Company_Name__c=acc.id;
    ext.fetchApplications();
    ext.getAllData();
    String nextPage = ext.startNewApplication().getURL();
    System.debug('###' +nextPage);
    test.setCurrentPage(new pageReference(nextPage));
    System.debug('### thisId '+ext.thisApplication.id);
    
    ext.getContactAndRelatedCompanies();
    
    nextPage = ext.next1().getUrl();
    System.debug('###' +nextPage);
    test.setCurrentPage(new pageReference(nextPage));
    
    System.debug('### thisId '+ext.thisApplication.id);
    ext.getFinancialDetails();
    
    ext.thisApplication.status__c = 'Draft Application';
    ext.summary=true;
    ext.getAllData();
    ext.back1();
    ext.back2();
    
    ext.next1();
    ext.next2();
    ext.next3();
    ext.next4();
    ext.next5();
    ext.next6();  
    
    ext.summary=false;
    ext.getAllData();
    
    ext.existingApplication = ext.thisApplication.id;
    ext.existingApplication();
    ext.cloneApplication();
    ext.closePopup();
    ext.showPopup();
    ext.addNewContact();
    ext.cancelNewContact();
    ext.con.LastName = 'TestPerson';
    ext.saveContact();
    
    ext.addMoreAssertions();
    ext.addAssertionFile();
    
    ext.fetchApplications();
}
}