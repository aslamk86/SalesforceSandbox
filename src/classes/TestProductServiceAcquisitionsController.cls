@isTest
private class TestProductServiceAcquisitionsController{
    
    static ProductServiceAcquisitionsController controller;
    
    static testMethod void test() {
        
        controller = new ProductServiceAcquisitionsController();
        System.assertEquals(0, controller.getProducts().size());
        
       //Create Product
        List<Product_or_Service__c> lstProdServ = new List<Product_or_Service__c>(); 
        lstProdServ.add(TestUtil.createProductOrServices('PS1', false));
        lstProdServ.add(TestUtil.createProductOrServices('PS2', false));
        lstProdServ.add(TestUtil.createProductOrServices('PS3', false));
        insert lstProdServ;
        
        System.assertEquals(3, controller.getProducts().size());
        
        controller.searchProduct();
        System.assertEquals(0, controller.acquisitionList.size());
        
        DateTime dT = System.now();
        controller.startDateFilter.Date_Filter__c =  Date.newinstance(dT.year(), dT.month(), dT.day());
        controller.endDateFilter.Date_Filter__c =  Date.newinstance(dT.year(), dT.month(), dT.day());
        controller.filterCriteria.Name = 'Test';
        controller.psFilter = 'Name';
        controller.lstSelectedStages.add(new SelectOption('Phase 0', 'Phase 0'));
        controller.lstSelectedPS.add(new SelectOption(lstProdServ.get(0).Id, lstProdServ.get(0).Name));
        
        controller.searchProduct();
        controller.filterPS();
        controller.sortProduct();
        
        System.assertEquals(0, controller.acquisitionList.size());
        
        controller.reset();
        
        System.assertEquals(null, controller.filterCriteria.Name);
        
        controller.exportExcel();
    }
}