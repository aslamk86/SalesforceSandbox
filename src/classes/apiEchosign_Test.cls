/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class apiEchosign_Test{

    static testMethod void myUnitTest() {

        apiEchosign  testapiEchosign  = new apiEchosign ();
        apiEchosign.deliverDocumentResponse_element  testDocResponse  = new apiEchosign.deliverDocumentResponse_element();
        apiEchosign.getDocumentByVersion_element  testPongDocByVer = new apiEchosign.getDocumentByVersion_element();
        apiEchosign.getImagesByVersionResponse_element    testImagesByVersionResponseelement   = new apiEchosign.getImagesByVersionResponse_element();
        apiEchosign.getUserInfo_element   testUserInfoelement    = new apiEchosign.getUserInfo_element();
        apiEchosign.createPersonalEmbeddedWidgetResponse_element testPersonalEmbeddedWidgetResponseelement = new apiEchosign.createPersonalEmbeddedWidgetResponse_element();
        apiEchosign.renameGroup_element testrenameGroupelement   = new apiEchosign.renameGroup_element();
        apiEchosign.deliverDocument_element    testdeliverDocumentelement    = new apiEchosign.deliverDocument_element();
        apiEchosign.getMyDocuments_element     testgetMyDocumentselement   = new apiEchosign.getMyDocuments_element ();
        apiEchosign.getSigningUrlResponse_element testgetSigningUrlResponseelement     = new apiEchosign.getSigningUrlResponse_element();
        apiEchosign.getUsersInGroupResponse_element testgetUsersInGroupResponseelement = new apiEchosign.getUsersInGroupResponse_element();
        apiEchosign.getFormData_element  testgetFormDataelement     = new apiEchosign.getFormData_element ();
        apiEchosign.getMegaSignDocument_element testgetMegaSignDocumentelement = new apiEchosign.getMegaSignDocument_element();
        apiEchosign.getUserDocuments_element  testgetUserDocumentselement  = new apiEchosign.getUserDocuments_element();
        apiEchosign.initiateInteractiveSendDocumentResponse_element testinitiateInteractiveSendDocumentResponseelement = new apiEchosign.initiateInteractiveSendDocumentResponse_element ();
        apiEchosign.getMyDocumentsResponse_element testgetMyDocumentsResponseelement = new apiEchosign.getMyDocumentsResponse_element();
        apiEchosign.createLibraryDocument_element     testcreateLibraryDocumentelement = new apiEchosign.createLibraryDocument_element();
        apiEchosign.cancelDocumentResponse_element testcancelDocumentResponseelement  = new apiEchosign.cancelDocumentResponse_element();
        apiEchosign.personalizeEmbeddedWidgetResponse_element  testpersonalizeEmbeddedWidgetResponseelement   = new apiEchosign.personalizeEmbeddedWidgetResponse_element ();
        apiEchosign.initiateInteractiveSendDocument_element initiateInteractiveSendDocumentelement  = new apiEchosign.initiateInteractiveSendDocument_element();
        apiEchosign.getLatestImagesResponse_element  testgetLatestImagesResponseelement   = new apiEchosign.getLatestImagesResponse_element();
        apiEchosign.sendDocumentMegaSign_element  testsendDocumentMegaSignelement   = new apiEchosign.sendDocumentMegaSign_element();
        apiEchosign.getDocumentImageUrls_element  testgetDocumentImageUrlselement   = new apiEchosign.getDocumentImageUrls_element ();
        apiEchosign.searchUserDocumentsResponse_element  testsearchUserDocumentsResponse_element   = new apiEchosign.searchUserDocumentsResponse_element ();
        apiEchosign.getDocumentsForUser_element  testgetDocumentsForUserelement   = new apiEchosign.getDocumentsForUser_element ();
        apiEchosign.getDocumentByVersionResponse_element  testgetDocumentByVersionResponseelement   = new apiEchosign.getDocumentByVersionResponse_element ();
        apiEchosign.getSupportingDocuments_element  testgetSupportingDocumentselement   = new apiEchosign.getSupportingDocuments_element ();
        apiEchosign.deleteGroupResponse_element  testdeleteGroupResponseelement   = new apiEchosign.deleteGroupResponse_element ();
        
        apiEchosign.getLatestDocumentUrl_element   testgetLatestDocumentUrlelement    = new apiEchosign.getLatestDocumentUrl_element  ();
        apiEchosign.rejectDocument_element   testrejectDocumentelement    = new apiEchosign.rejectDocument_element  ();
        apiEchosign.delegateSigning_element   testdelegateSigningelement    = new apiEchosign.delegateSigning_element  ();
        apiEchosign.sendReminder_element   testsendReminder_element    = new apiEchosign.sendReminder_element  ();
        apiEchosign.createGroupResponse_element   testcreateGroupResponseelement    = new apiEchosign.createGroupResponse_element  ();
        apiEchosign.disableWidget_element   testdisableWidget_element    = new apiEchosign.disableWidget_element  ();
        apiEchosign.sendReminderResponse_element   testsendReminderResponseelement    = new apiEchosign.sendReminderResponse_element  ();
        apiEchosign.deleteGroup_element   testdeleteGroupelement    = new apiEchosign.deleteGroup_element  ();
        apiEchosign.getLibraryDocumentsForUserResponse_element   testgetLibraryDocumentsForUserResponseelement    = new apiEchosign.getLibraryDocumentsForUserResponse_element  ();
        apiEchosign.createUrlWidget_element   testcreateUrlWidgetelement    = new apiEchosign.createUrlWidget_element  ();
        apiEchosign.getDocumentsResponse_element   testgetDocumentsResponseelement    = new apiEchosign.getDocumentsResponse_element  ();
        
        apiEchosign.sendDocumentInteractiveResponse_element    testsendDocumentInteractiveResponseelement     = new apiEchosign.sendDocumentInteractiveResponse_element   ();
        apiEchosign.replaceSignerResponse_element    testreplaceSignerResponseelement     = new apiEchosign.replaceSignerResponse_element   ();
        apiEchosign.getGroupsInAccount_element   testgetGroupsInAccountelement    = new apiEchosign.getGroupsInAccount_element  ();
        apiEchosign.delegateSigningResponse_element   testdelegateSigningResponseelement    = new apiEchosign.delegateSigningResponse_element  ();
        apiEchosign.getComposeDocumentUrl_element    testgetComposeDocumentUrlelement     = new apiEchosign.getComposeDocumentUrl_element   ();
        apiEchosign.getDocumentPagesInfoResponse_element    testgetDocumentPagesInfoResponseelement     = new apiEchosign.getDocumentPagesInfoResponse_element   ();
        apiEchosign.createForm_element    testcreateFormelement     = new apiEchosign.createForm_element   ();
        apiEchosign.notifyDocumentVaultedResponse_element    testnotifyDocumentVaultedResponseelement     = new apiEchosign.notifyDocumentVaultedResponse_element   ();
        apiEchosign.getLibraryDocumentsForUser_element    testgetLibraryDocumentsForUserelement     = new apiEchosign.getLibraryDocumentsForUser_element   ();
        apiEchosign.createPersonalUrlWidgetResponse_element    testcreatePersonalUrlWidgetResponseelement     = new apiEchosign.createPersonalUrlWidgetResponse_element   ();
        apiEchosign.getDocumentUrlByVersionResponse_element    testgetDocumentUrlByVersionResponseelement     = new apiEchosign.getDocumentUrlByVersionResponse_element   ();
        apiEchosign.verifyUser_element    testverifyUserelement     = new apiEchosign.verifyUser_element ();
        apiEchosign.getDocumentPagesInfo_element   testgetDocumentPagesInfoelement    = new apiEchosign.getDocumentPagesInfo_element();
        apiEchosign.createUrlWidgetResponse_element    testcreateUrlWidgetResponseelement     = new apiEchosign.createUrlWidgetResponse_element ();
        apiEchosign.getEmbeddedViewResponse_element    testgetEmbeddedViewResponseelement     = new apiEchosign.getEmbeddedViewResponse_element ();
        apiEchosign.personalizeUrlWidget_element    testpersonalizeUrlWidgetelement     = new apiEchosign.personalizeUrlWidget_element ();
        apiEchosign.enableWidget_element   testenableWidgetelement    = new apiEchosign.enableWidget_element();
        
        apiEchosign.sendDocumentMegaSignResponse_element   a1    = new apiEchosign.sendDocumentMegaSignResponse_element();
        apiEchosign.getFormDataResponse_element   a2    = new apiEchosign.getFormDataResponse_element();
        apiEchosign.testEchoFile_element   a3    = new apiEchosign.testEchoFile_element();
        apiEchosign.replaceSigner_element   a4    = new apiEchosign.replaceSigner_element();        
        apiEchosign.getMyLibraryDocumentsResponse_element   a5    = new apiEchosign.getMyLibraryDocumentsResponse_element();
        apiEchosign.moveUsersToGroupResponse_element   a6    = new apiEchosign.moveUsersToGroupResponse_element();
        apiEchosign.getSupportingDocumentsResponse_element   a7    = new apiEchosign.getSupportingDocumentsResponse_element();
        apiEchosign.removeDocument_element    a8    = new apiEchosign.removeDocument_element ();        
        apiEchosign.getDocumentEventsForUserResponse_element   a9    = new apiEchosign.getDocumentEventsForUserResponse_element();
        apiEchosign.getDocumentsForUserResponse_element   a10    = new apiEchosign.getDocumentsForUserResponse_element();
        apiEchosign.getLatestImages_element    a111    = new apiEchosign.getLatestImages_element ();
        apiEchosign.getLatestDocumentUrlResponse_element    a12    = new apiEchosign.getLatestDocumentUrlResponse_element ();
        apiEchosign.testPing_element    a13    = new apiEchosign.testPing_element ();
        apiEchosign.createPersonalEmbeddedWidget_element    a14    = new apiEchosign.createPersonalEmbeddedWidget_element ();
        apiEchosign.getLatestDocumentResponse_element   a15    = new apiEchosign.getLatestDocumentResponse_element();
        apiEchosign.getDocumentInfoResponse_element   a16    = new apiEchosign.getDocumentInfoResponse_element();       
        apiEchosign.moveUsersToGroup_element    a17    = new apiEchosign.moveUsersToGroup_element ();
        apiEchosign.cancelDocument_element    a18    = new apiEchosign.cancelDocument_element ();
        apiEchosign.searchUserDocuments_element    a19    = new apiEchosign.searchUserDocuments_element ();
        apiEchosign.getAuditTrailResponse_element    a20    = new apiEchosign.getAuditTrailResponse_element ();     
        apiEchosign.getUserDocumentsResponse_element    a21    = new apiEchosign.getUserDocumentsResponse_element ();
        apiEchosign.testEchoFileResponse_element    a22    = new apiEchosign.testEchoFileResponse_element ();
        apiEchosign.getEmbeddedView_element    a23    = new apiEchosign.getEmbeddedView_element ();
        apiEchosign.disableWidgetResponse_element    a24    = new apiEchosign.disableWidgetResponse_element ();
        apiEchosign.getDocumentUrls_element    a25    = new apiEchosign.getDocumentUrls_element ();
        apiEchosign.createUser_element    a26    = new apiEchosign.createUser_element ();
        apiEchosign.getSigningUrl_element    a27    = new apiEchosign.getSigningUrl_element ();
        apiEchosign.ArrayOfString    a28    = new apiEchosign.ArrayOfString ();     
        apiEchosign.getSignerFormFieldsResponse_element    a29    = new apiEchosign.getSignerFormFieldsResponse_element ();
        apiEchosign.renameGroupResponse_element    a30    = new apiEchosign.renameGroupResponse_element ();
        apiEchosign.notifyDocumentVaulted_element    a31    = new apiEchosign.notifyDocumentVaulted_element ();
        apiEchosign.getDocumentImageUrlsResponse_element    a32    = new apiEchosign.getDocumentImageUrlsResponse_element ();       
        apiEchosign.createUserResponse_element    a33    = new apiEchosign.createUserResponse_element ();
        apiEchosign.getAuditTrail_element    a34    = new apiEchosign.getAuditTrail_element ();
        apiEchosign.enableWidgetResponse_element    a35    = new apiEchosign.enableWidgetResponse_element ();
        apiEchosign.rejectDocumentResponse_element    a36    = new apiEchosign.rejectDocumentResponse_element ();
        apiEchosign.testPingResponse_element    a37    = new apiEchosign.testPingResponse_element ();
        apiEchosign.sendDocumentResponse_element    a38    = new apiEchosign.sendDocumentResponse_element ();
        apiEchosign.createLibraryDocumentResponse_element    a39    = new apiEchosign.createLibraryDocumentResponse_element ();
        apiEchosign.getDocumentUrlsResponse_element    a40    = new apiEchosign.getDocumentUrlsResponse_element ();     
        apiEchosign.getDocumentUrlByVersion_element    a41   = new apiEchosign.getDocumentUrlByVersion_element ();
        apiEchosign.getDocumentInfosByExternalId_element    a42    = new apiEchosign.getDocumentInfosByExternalId_element ();
        apiEchosign.createEmbeddedWidgetResponse_element    a43    = new apiEchosign.createEmbeddedWidgetResponse_element ();
        apiEchosign.createPersonalUrlWidget_element    a44    = new apiEchosign.createPersonalUrlWidget_element ();     
        apiEchosign.getDocumentEventsForUser_element    a45    = new apiEchosign.getDocumentEventsForUser_element ();
        apiEchosign.verifyUserResponse_element    a46    = new apiEchosign.verifyUserResponse_element ();
        apiEchosign.personalizeUrlWidgetResponse_element    a47    = new apiEchosign.personalizeUrlWidgetResponse_element ();
        apiEchosign.getWidgetsForUser_element    a48    = new apiEchosign.getWidgetsForUser_element ();     
        apiEchosign.getUserInfoResponse_element     a49    = new apiEchosign.getUserInfoResponse_element();
        apiEchosign.getMegaSignDocumentResponse_element     a50    = new apiEchosign.getMegaSignDocumentResponse_element();
        
        apiEchosign.createFormResponse_element   b1 = new apiEchosign.createFormResponse_element();
        apiEchosign.removeDocumentResponse_element b2 = new apiEchosign.removeDocumentResponse_element();
        apiEchosign.getGroupsInAccountResponse_element b3 = new apiEchosign.getGroupsInAccountResponse_element();
        apiEchosign.getUsersInAccount_element b4  = new apiEchosign.getUsersInAccount_element();
        apiEchosign.createAccount_element  b5 = new apiEchosign.createAccount_element ();
        apiEchosign.getLatestDocument_element  b6 = new apiEchosign.getLatestDocument_element();        
        apiEchosign.getMyWidgets_element  b7 = new apiEchosign.getMyWidgets_element();
        apiEchosign.getSignerFormFields_element  b8 = new apiEchosign.getSignerFormFields_element();
        apiEchosign.getDocuments_element  b9 = new apiEchosign.getDocuments_element();
        apiEchosign.createGroup_element   b10 = new apiEchosign.createGroup_element();
        apiEchosign.getMyWidgetsResponse_element  b11 = new apiEchosign.getMyWidgetsResponse_element();
        apiEchosign.personalizeEmbeddedWidget_element  b12 = new apiEchosign.personalizeEmbeddedWidget_element();
        apiEchosign.createAccountResponse_element  b13 = new apiEchosign.createAccountResponse_element();
        apiEchosign.getUsersInGroup_element b24 = new apiEchosign.getUsersInGroup_element();
        apiEchosign.getUsersInAccountResponse_element  b14 = new apiEchosign.getUsersInAccountResponse_element();
        apiEchosign.getDocumentInfo_element  b15 = new apiEchosign.getDocumentInfo_element();
        apiEchosign.getWidgetsForUserResponse_element  b16 = new apiEchosign.getWidgetsForUserResponse_element();
        apiEchosign.getDocumentInfosByExternalIdResponse_element  b17 = new apiEchosign.getDocumentInfosByExternalIdResponse_element();
        apiEchosign.sendDocumentInteractive_element  b18 = new apiEchosign.sendDocumentInteractive_element();
        
        apiEchosign.createEmbeddedWidget_element  b19 = new apiEchosign.createEmbeddedWidget_element();
        apiEchosign.getMyLibraryDocuments_element  b20 = new apiEchosign.getMyLibraryDocuments_element();
        apiEchosign.sendDocument_element   b21 = new apiEchosign.sendDocument_element();
        apiEchosign.getImagesByVersion_element  b22 = new apiEchosign.getImagesByVersion_element();
        apiEchosign.EchoSignDocumentService19HttpPort   b23 = new apiEchosign.EchoSignDocumentService19HttpPort ();
        /*
        dto16ApiEchosign.GetWidgetsForUserResult result = new dto16ApiEchosign.GetWidgetsForUserResult();
        result = b23.getMyWidgets('XXXXXXXXX');
        
        String StrTest ; 
        StrTest = b23.getLatestDocument('XXXXXXXX','XXXXXXXXXXXXXXXXXXXXX') ;
        
        dto16ApiEchosign.ArrayOfDocumentKey sendDoc = new dto16ApiEchosign.ArrayOfDocumentKey();
        dtoApiEchosign testdtoApiEchosign  = new dtoApiEchosign();      
        dtoApiEchosign.DocumentCreationInfo testDocumentCreationInfo = new dtoApiEchosign.DocumentCreationInfo();
        dtoApiEchosign.SenderInfo   testSenderInfo  = new dtoApiEchosign.SenderInfo();
        sendDoc = b23.sendDocument('XXXXXXXX',testSenderInfo,testDocumentCreationInfo);
        
        dtoApiEchosign.UserVerificationInfo userVerif = new dtoApiEchosign.UserVerificationInfo();
        
        userVerif = b23.verifyUser('XXXXXXXX','xyzRPX@gmail.com','abc123');
        
        StrTest = b23.testEchoFile('XXXXXXXX','TestAgreementFile');      */ 
        
    }
}