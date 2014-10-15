/****************************************************
   
    MANAGE CONTENT CONTROLLER TESTS
   
    Built by Hank Ryan Thompson.
    Created 11/23/2013.
    Last updated 01/17/2014 by Sharmila.
   
    This class contains testMethods that test the
    functionality of the Manage Content Controller.
    
****************************************************/

@isTest(seeAllData=true) // NOTE: We can't create content workspaces so we have to rely on pre-existing ones
public class TestManageContent_ContentVersionTrigger {

   
       
    public static testMethod void testManageContentController() {
        // This tests coverage and logic
        
        system.debug('###testManageContentController(): Entering function.###' );
        
        // First insert the test records
        Account testAccount = new Account(Name = 'testAccount', Rate_Comments__c = 'test', Applicable_Segment_Revenue_Manual__c = 100, Fiscal_Year_Close_Manual__c = Date.today(), Operating_Income_Y1_Manual__c = 10, Operating_Income_Y2_Manual__c = 20, Operating_Income_Y3_Manual__c = 30, 
                              Rate_Comments_Manual__c = 'Test Comment', Rate_Last_Updated_By_Manual__c = 'Test Manual Update', Rate_Last_Updated_Manual__c = Date.today(), Revenue_Current_Year_Manual__c = 40, Entity_ID__c = 500000 + Math.Rint(Math.random()*250000));
        insert testAccount;
                        
        //Test funcitons that are unique to the different users of the page
        User primary = [SELECT Id FROM User WHERE Alias = 'reza'];
        User confidentiality = [SELECT Id FROM User WHERE Alias = 'craymond'];
        User editorial = [SELECT Id FROM User WHERE Alias = 'relliott'];              
        User UserUnauthorized = [SELECT Id FROM User WHERE Alias = 'jerdos'];
        
        
        Acquisition_Opportunity__c testAcq =  new Acquisition_Opportunity__c(Name='test acq',Account__c=testAccount.id,Analysis_Assigned_to__c=confidentiality.id);
        insert testAcq;
        
        // NOTE: Inserting content is a multi-step process to avoid error messages.
        ContentVersion testContentVersionA = new ContentVersion(Title='testContentA', ContentURL='http://google.com');
        ContentVersion testContentVersionB = new ContentVersion(Title='testContentB', ContentURL='http://yahoo.com');
        insert new ContentVersion[]{testContentVersionA, testContentVersionB};
        ContentWorkspace testContentWorkspace = [select Id from ContentWorkspace where IsRestrictContentTypes=false and IsRestrictLinkedContentTypes=false limit 1];
        testContentVersionA = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c, NDA__c, Review_Status__c,Account__c from ContentVersion where id = :testContentVersionA.Id];
        testContentVersionB = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c, NDA__c, Review_Status__c, Account__c from ContentVersion where id = :testContentVersionB.Id];
        ContentWorkspaceDoc cwdA = new ContentWorkspaceDoc(ContentWorkspaceId=testContentWorkspace.Id, ContentDocumentId=testContentVersionA.ContentDocumentId);
        ContentWorkspaceDoc cwdB = new ContentWorkspaceDoc(ContentWorkspaceId=testContentWorkspace.Id, ContentDocumentId=testContentVersionB.ContentDocumentId);
        
        testContentVersionB.Portal_Visible__c=testContentVersionB.Portal_Visible_Review__c=testContentVersionB.Portal_Visible_Final__c=testContentVersionB.NDA__c= 'Not Recorded';
        testContentVersionA.Portal_Visible__c=testContentVersionA.Portal_Visible_Review__c=testContentVersionA.Portal_Visible_Final__c=testContentVersionA.NDA__c= 'Not Recorded';
        testContentVersionA.Review_Status__c = testContentVersionB.Review_Status__c = 'Not Submitted';
        
        insert new ContentWorkspaceDoc[]{cwdA, cwdB};
          // Only three users have access to update records on ContentVersions; only system admins have the rights to change review status
                testContentVersionA.Account__c = testAccount.Id; testContentVersionA.Portal_Visible_Review__c='Not Recorded'; testContentVersionA.NDA__c='Not Recorded'; testContentVersionA.Review_Status__c = 'Not Submitted';
                testContentVersionB.Account__c = testAccount.Id; testContentVersionB.Acquisition__c=testAcq.Id; testContentVersionA.Portal_Visible_Review__c='Not Recorded'; testContentVersionB.NDA__c='Not Recorded'; testContentVersionB.Review_Status__c = 'Not Submitted';
                update new ContentVersion[]{testContentVersionA, testContentVersionB};
         
        
        // Verify that our starting point is "not visible in portal"
        /*system.assert(testContentVersionA.Portal_Visible__c != 'Yes');
        system.assert(testContentVersionA.NDA__c != 'No');
        system.assert(testContentVersionA.Review_Status__c != 'Publication Approved');
        system.assert(testContentVersionB.Portal_Visible__c != 'Yes');
        system.assert(testContentVersionB.NDA__c != 'No');
        system.assert(testContentVersionB.Review_Status__c != 'Publication Approved');
        */
        // Start the test
        Test.startTest ();
       
        // Invoke code several times to test different errors
        ManageContentController controller;
        ManageContentController generalController;        
        
        ApexPages.currentPage().getParameters().put('id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('field', 'Notafield__c');
        controller = new ManageContentController();        
        
        ApexPages.currentPage().getParameters().put('id', testAccount.Id);
        ApexPages.currentPage().getParameters().put('field', 'Account__c');
        generalController = new ManageContentController();
        
        controller.cancel();
        controller.refresh();
        
        //system.assertEquals(2, generalController.ReviewDocuments.size());
        //system.assertEquals(testContentVersionA.Title, generalController.ReviewDocuments[0].doc.Title); // Sorted in alphabetical order by title
        
         System.runAs(UserUnauthorized) {

            ManageContentController invalidUserController;
            ApexPages.currentPage().getParameters().put('id', testAcq.Id);
            ApexPages.currentPage().getParameters().put('field', 'Acquisition__c');
            invalidUserController = new ManageContentController();
            invalidUserController.ReviewDocuments[0].doc.Portal_Visible__c = 'Yes';
            invalidUserController.saveChanges();               
            //system.assert(ApexPages.hasMessages());
            try{                                    
                
                update invalidUserController.ReviewDocuments[0].doc;
            }
            catch(Exception e){
                //system.assert(e.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }
    
        }
        
        //User update in an incorrect workflow
        System.runAs(editorial) {
            ManageContentController incorrectWorkflowController;
            ApexPages.currentPage().getParameters().put('id', testAccount.Id);
            ApexPages.currentPage().getParameters().put('field', 'Account__c');
            incorrectWorkflowController = new ManageContentController();
            incorrectWorkflowController.ReviewDocuments[0].doc.Portal_Visible_Review__c = 'Yes';
            incorrectWorkflowController.Reviewed();
            //system.assert(ApexPages.hasMessages());
            //system.assert(testContentVersionA.Review_Status__c == 'Not Submitted');                   
        }
    
        //Confidentiality Review
        System.runAs(primary) {
            ManageContentController ConfidentialityReviewController;
            ApexPages.currentPage().getParameters().put('id', testAccount.Id);
            ApexPages.currentPage().getParameters().put('field', 'Account__c');
            ConfidentialityReviewController = new ManageContentController();            
            ConfidentialityReviewController.ReviewDocuments[0].doc.Portal_Visible__c = 'Yes';
            ConfidentialityReviewController.ReviewDocuments[0].doc.NDA__c = 'No';
            ConfidentialityReviewController.Reviewed();
            testContentVersionA = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c, Account__c, NDA__c, Review_Status__c from ContentVersion where id = :testContentVersionA.Id];
            system.debug('### Confidentiality Review testConentVersionA: '+ testContentVersionA);
            //system.assert(testContentVersionA.Review_Status__c == 'Confidentiality Review');
          
          
          //Error cases             
            ConfidentialityReviewController.ReviewDocuments[0].doc.Portal_Visible__c = 'No';
            ConfidentialityReviewController.ReviewDocuments[0].doc.NDA__c = 'No';
            ConfidentialityReviewController.ReviewDocuments[0].doc.Review_Status__c = 'Editorial Review';
            ConfidentialityReviewController.Reviewed();
            //system.assert(ApexPages.hasMessages());
            //system.assert(testContentVersionA.Review_Status__c == 'Confidentiality Review');
            
            ConfidentialityReviewController.ReviewDocuments[0].doc.Portal_Visible__c = 'Yes';
            ConfidentialityReviewController.ReviewDocuments[0].doc.NDA__c = 'No';
            ConfidentialityReviewController.ReviewDocuments[0].doc.Review_Status__c = 'Publication Denied - Primary Approval';
            ConfidentialityReviewController.Reviewed();
            //system.assert(ApexPages.hasMessages());
            //system.assert(testContentVersionA.Review_Status__c == 'Confidentiality Review');
            
            testContentVersionA.Portal_Visible__c = 'No';                   
            testContentVersionA.Review_Status__c = 'Publication Denied - Confidentiality Review';
            testContentVersionA.Portal_Visible_Review__c = 'Yes';
            
            try{
                update testContentVersionA;
                //system.assert(false); //This should not be reached. The above update should fail.
            }
            catch(Exception e){
                //system.assert(e.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }
                       
        }
    
        //confidentiality Approval
        System.runAs(confidentiality) {
            ManageContentController EditorialReviewController;
            ApexPages.currentPage().getParameters().put('id', testAccount.Id);
            ApexPages.currentPage().getParameters().put('field', 'Account__c');
            EditorialReviewController = new ManageContentController();
            EditorialReviewController.ReviewDocuments[0].doc.Type__c = 'Marketing Info';
            EditorialReviewController.Reviewed();
            testContentVersionA = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c, Account__c, NDA__c, Review_Status__c from ContentVersion where id = :testContentVersionA.Id];
            system.debug('### Editorial Review testConentVersionA: '+ testContentVersionA);
            //system.assert(testContentVersionA.Review_Status__c == 'Editorial Review');
            
            EditorialReviewController.ReviewDocuments[0].doc.Type__c = 'Marketing Info';
            EditorialReviewController.Reviewed();
            //system.assert(ApexPages.hasMessages());
            
            //Error cases
            EditorialReviewController.ReviewDocuments[0].doc.NDA__c = 'Yes';
            EditorialReviewController.Reviewed();
            //system.assert(ApexPages.hasMessages());
            
            EditorialReviewController.ReviewDocuments[0].doc.Portal_Visible__c = 'No';
            EditorialReviewController.Reviewed();
            //system.assert(ApexPages.hasMessages());
                                                                
                        
        }
        
        //Final approval
        System.runAs(editorial) {
                        
            ManageContentController NoReviewController;
            ApexPages.currentPage().getParameters().put('id', testAccount.Id);
            ApexPages.currentPage().getParameters().put('field', 'Account__c');
            NoReviewController = new ManageContentController();
            NoReviewController.ReviewDocuments[0].doc.Portal_Visible_Final__c = 'Yes';
            NoReviewController.Reviewed();
            testContentVersionA = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c,Account__c, NDA__c, Review_Status__c from ContentVersion where id = :testContentVersionA.Id];
            //system.assert(testContentVersionA.Review_Status__c == 'Publication Approved');                    
            
            //Publishing Denied
            ManageContentController PublicationApprovedReviewController;
            ApexPages.currentPage().getParameters().put('id', testAccount.Id);
            ApexPages.currentPage().getParameters().put('field', 'Account__c');
            PublicationApprovedReviewController = new ManageContentController();
            PublicationApprovedReviewController.ReviewDocuments[0].doc.Portal_Visible_Final__c = 'No';
            PublicationApprovedReviewController.Reviewed();
            testContentVersionA = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c, Account__c, NDA__c, Review_Status__c from ContentVersion where id = :testContentVersionA.Id];
            //system.assert(testContentVersionA.Portal_Visible_Final__c == 'Yes');
            //system.assert(testContentVersionA.Review_Status__c == 'Publication Denied - Editorial Review');
            
            
            //possible forced updates through data loader or through the API
            testContentVersionA.NDA__c = 'Yes';
            testContentVersionA.Portal_Visible__c = 'Yes';
            testContentVersionA.Review_Status__c = 'Confidentiality Review'; 
            
            try{
                update testContentVersionA;
                //system.assert(false); //This should not be reached. The above update should fail.
            }
            catch(Exception e){
                //system.assert(e.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }
            
            testContentVersionA.NDA__c = 'No';
            testContentVersionA.Portal_Visible__c = 'Yes';
            testContentVersionA.Review_Status__c = 'Publication Denied - Editorial Approval'; 
            
            try{
                update testContentVersionA;
                //system.assert(false); //This should not be reached. The above update should fail.
            }
            catch(Exception e){
                //system.assert(e.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }                      
            
            
        }
    
        //Publication denied
        
        System.runAs(editorial) {
            ManageContentController PublicationDeniedReviewController;
            ApexPages.currentPage().getParameters().put('id', testAccount.Id);
            ApexPages.currentPage().getParameters().put('field', 'Account__c');
            PublicationDeniedReviewController = new ManageContentController();
            PublicationDeniedReviewController.ReviewDocuments[1].doc.Portal_Visible__c = 'Yes';
            PublicationDeniedReviewController.ReviewDocuments[1].doc.NDA__c = 'Yes';
            PublicationDeniedReviewController.Reviewed();
            testContentVersionB = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c, Account__c, NDA__c, Review_Status__c from ContentVersion where id = :testContentVersionB.Id];
            //system.assert(ApexPages.hasMessages());            
        }
        
        System.runAs(primary) {
            ManageContentController PublicationDeniedReviewController;
            ApexPages.currentPage().getParameters().put('id', testAccount.Id);
            ApexPages.currentPage().getParameters().put('field', 'Account__c');
            PublicationDeniedReviewController = new ManageContentController();            
            PublicationDeniedReviewController.ReviewDocuments[0].doc.NDA__c = 'Yes';
            PublicationDeniedReviewController.Reviewed();
            testContentVersionA = [select Id, ContentDocumentId, Title, Portal_Visible__c, Portal_Visible_Review__c, Portal_Visible_Final__c, Account__c, NDA__c, Review_Status__c from ContentVersion where id = :testContentVersionA.Id];
            //system.assert(testContentVersionA.Portal_Visible_Review__c == 'N/A');
            //system.assert(testContentVersionA.Review_Status__c == 'Publication Denied - Primary Review');
                                    
        }
                                
        
        
        // More test coverage
        generalController.cancel();
        generalController.refresh();
        generalController.MakeAllEligibleEditable();
        
        Opportunity testOppty = new Opportunity(name='testOppty',accountId=testAccount.id,stageName='Proposal', closedate=system.today());
        insert testOppty;
        ApexPages.currentPage().getParameters().put('id', testOppty.Id);
        ApexPages.currentPage().getParameters().put('field', 'Account__c');
        ManageContentController opptyCon = new ManageContentController();
        
        
        ApexPages.currentPage().getParameters().put('id', testAcq.Id);
        ApexPages.currentPage().getParameters().put('field', 'Acquisition__c');
        ManageContentController acqCon = new ManageContentController();                                                
        
        // Stop the test
        Test.stopTest ();
              

        
        system.debug('###testManageContentController(): Exiting function.###' );
    }
   
}