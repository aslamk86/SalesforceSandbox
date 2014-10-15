@isTest
public class TestAcqOppForPSController{
    static TestMethod void test(){
        Product_or_Service__c ps = new Product_or_Service__c();
        upsert ps;
        
        Test.SetCurrentPage(Page.AcqOppForPS);
        ApexPages.StandardController sc = new ApexPages.StandardController(ps);
        AcqOppForPSController con = new AcqOppForPSController(sc);
        con.GetAcquisitions();
    }
}