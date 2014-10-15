/*****************************************************************************
 * Name             : PatentFamilyRollupSummaryFields
 * Created By       : Bharti Mehta(Appirio Offshore)
 * Created Date     : 19 march, 2012.
 * Purpose          : A webservice class rollsup all patent information
*****************************************************************************/
global class PatentFamilyRollupSummaryFields {
    
    webservice static String rollupSummaryFields(Id patentFamiltyId ){
        String summary = '', charClaim = '', repClaim = '';
        
        for(List<Patent__c> patents : [Select Patent_No__c,Characterization_of_Claims__c,Representative_Claims__c, Summary__c 
                                      From Patent__c 
                                      Where Patent_Family__c = :patentFamiltyId]){
            for(Patent__c patent : patents){
                summary += patent.Summary__c != null ? patent.Patent_No__c + ' : ' + (patent.Summary__c != null? patent.Summary__c : '') + '\n\n' : '';
                charClaim += patent.Characterization_of_Claims__c != null? patent.Patent_No__c + ' : ' + (patent.Characterization_of_Claims__c != null? patent.Characterization_of_Claims__c : '') + '\n\n' : '';
                repClaim += patent.Representative_Claims__c != null? patent.Patent_No__c + ' : ' + (patent.Representative_Claims__c != null? patent.Representative_Claims__c : '') + '\n\n' : '';
            }           
        }
        
        try{
            update new Assets__c(Id = patentFamiltyId , Characterization_of_Claims__c = charClaim , Summary__c = summary , Representative_Claims__c = repClaim,Info_Pulled_from_Patents_on__c = datetime.now());
        }catch(DMLException exp){
            return  exp.getDmlMessage(0);
        }
        return '';
        
    }
    
    @isTest
    static void unitTest(){
         //prepare testdata start
        Assets__c patentFamily = TestUtil.createPortfolio(true);
        String testString = '';
        List<Patent__c> patents = new List<Patent__c>();
        patents.add(TestUtil.createPatent(patentFamily.Id, false));
        patents.add(TestUtil.createPatent(patentFamily.Id, false));
        for(Patent__c patent : patents ){
            patent.Characterization_of_Claims__c = 'Hello';
            patent.Representative_Claims__c = 'Hello';
            patent.Summary__c = 'Hello';
            testString +=  patent.Patent_No__c + ' : Hello\n\n';
        }
        testString = testString.substring(0,testString.lastIndexOf('\n'));
        insert patents; 
        
        //prepare testdata end
        
        //Test start        
        Test.startTest();
        rollupSummaryFields(patentFamily.Id);
        Test.stopTest();
        //Test end
        
        //Verify test result
        System.assertEquals(testString.trim(), [Select Characterization_of_Claims__c, Id From Assets__c Where Id = :patentFamily.Id].Characterization_of_Claims__c);
    }

}