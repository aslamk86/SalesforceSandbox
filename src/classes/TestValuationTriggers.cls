/*******************************************************
Description: Test class to test the Valuation
    functionalities.

********************************************************/

@isTest (seeAllData=true)
public class TestValuationTriggers{

   @isTest 
   static void testValuationInsert() {
        Account testAccount = new Account(Name = 'testAccount', Rate_Comments__c = 'test', Applicable_Segment_Revenue_Manual__c = 100, Fiscal_Year_Close_Manual__c = Date.today(), Operating_Income_Y1_Manual__c = 10, Operating_Income_Y2_Manual__c = 20, Operating_Income_Y3_Manual__c = 30, 
                              Rate_Comments_Manual__c = 'Test Comment', Rate_Last_Updated_By_Manual__c = 'Test Manual Update', Rate_Last_Updated_Manual__c = Date.today(), Revenue_Current_Year_Manual__c = 40, Entity_ID__c = 500000 + Math.Rint(Math.random()*250000));
        insert testAccount;        
        Acquisition_Opportunity__c testAcq =  new Acquisition_Opportunity__c(Name='test acq',Account__c=testAccount.id);
        insert testAcq;
            
        RecordType rtGuidance = [select Id,Name from RecordType where Name = 'Guidance' and SobjectType = 'Valuation_Tracking__c'];
        RecordType rtBid = [select Id,Name from RecordType where Name ='Bid Notifications' and SobjectType = 'Valuation_Tracking__c'];        
        
        Test.startTest();
        Valuation_Tracking__c vt1 = new Valuation_Tracking__c(Acquisition__c=testAcq.id, RecordTypeId=rtGuidance.id);
        vt1.Date_Received__c = date.today().addDays(-5);
        vt1.Valuation_in_000s__c = 1500;
        insert vt1;                                       
        
        testAcq.Most_Recent_Valuation_Tracking__c = null;
        update testAcq;        
        
        vt1.Valuation_in_000s__c = 800;
        update vt1;                
        
        vt1.Valuation_in_000s__c = 1000;
        update vt1;                
            
        Valuation_Tracking__c vt2 = new Valuation_Tracking__c(Acquisition__c=testAcq.id, RecordTypeId=rtBid.id,Bidder_Type__c='NPE');
        vt1.Date_Received__c = System.today();
        vt2.Valuation_in_000s__c = 2000;
        insert vt2;
        
        
        
        Test.stopTest();
                
        testAcq = [select id,Amount_for_Pipeline__c,NPE_Offer__c  from Acquisition_Opportunity__c where id=:testAcq.id];        
        System.assert(vt1.Valuation_in_000s__c == testAcq.Amount_for_Pipeline__c);
        System.assert(testAcq.NPE_Offer__c == true);
   }
   
   
   @isTest
   static void testPrePopulation(){
       Account testAccount = new Account(Name = 'testAccount', Rate_Comments__c = 'test', Applicable_Segment_Revenue_Manual__c = 100, Fiscal_Year_Close_Manual__c = Date.today(), Operating_Income_Y1_Manual__c = 10, Operating_Income_Y2_Manual__c = 20, Operating_Income_Y3_Manual__c = 30, 
                              Rate_Comments_Manual__c = 'Test Comment', Rate_Last_Updated_By_Manual__c = 'Test Manual Update', Rate_Last_Updated_Manual__c = Date.today(), Revenue_Current_Year_Manual__c = 40, Entity_ID__c = 500000 + Math.Rint(Math.random()*250000));
       insert testAccount;        
       Acquisition_Opportunity__c testAcq =  new Acquisition_Opportunity__c(Name='test acq',Account__c=testAccount.id);
       insert testAcq;
       
       Test.startTest();
       Valuation_Tracking__c vt1 = new Valuation_Tracking__c(Acquisition__c=testAcq.id);
       ApexPages.StandardController con = new ApexPages.StandardController(vt1);
       ValuationPrepopulationExtn valPrepopExtn = new ValuationPrepopulationExtn(con);
       valPrepopExtn.populateAndRedirect();   
       Test.stopTest();
   }
   
}