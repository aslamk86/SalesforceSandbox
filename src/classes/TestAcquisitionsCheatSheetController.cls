@isTest
private class TestAcquisitionsCheatSheetController {
    
    static testMethod void testInit() {  
        
        Map<String,Id> oppRecType = TestUtil.getRecordType('Acquisition_Opportunity__c');
        Account acct = TestUtil.createAccount(true);
        
        Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Prospect', 'TestAcqOptyForAcquisitionsCheatSheetController1', false);
        acqOpp.RecordTypeId = oppRecType.get('OMA');
        acqOpp.Patent_Portfolio_Summary__c = 'Hello world';
        insert acqOpp;
        
        Acquisition_Opportunity__c acqOpp2 = TestUtil.createAcquisitionOpp(acct.Id, 'Prospect', 'TestAcqOptyForAcquisitionsCheatSheetController2', false);
        acqOpp2.RecordTypeId = oppRecType.get('OMA');
        insert acqOpp2;
        
        Product_or_Service__c ps1 = TestUtil.createProductOrServices('Test PS 1', true);
        Product_or_Service__c ps2 = TestUtil.createProductOrServices('Test PS 2', true);
                
        PageReference pageRef = Page.AcquisitionsCheatSheet;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id','');
        ApexPages.currentPage().getParameters().put('psId',ps1.Id + ';' + ps2.Id);
        AcquisitionsCheatSheetController controller = new AcquisitionsCheatSheetController();
        
        System.assertEquals(1,controller.acquisitions.size());
        
        ApexPages.currentPage().getParameters().put('id',acqOpp.Id + ';' + acqOpp2.Id);
        AcquisitionsCheatSheetController controller2 = new AcquisitionsCheatSheetController();
        
        System.assertEquals(2,controller2.acquisitions.size());
        
    }
}