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
private class dto17ApiEchosign_Test{

    static testMethod void myUnitTest() {

        dto17ApiEchosign  testdto17ApiEchosign  = new dto17ApiEchosign ();
        dto17ApiEchosign.ReplaceSignerResult   testReplaceSignerResult = new dto17ApiEchosign.ReplaceSignerResult ();
        dto17ApiEchosign.DelegateSigningResult  testDelegateSigningResult = new dto17ApiEchosign.DelegateSigningResult ();      
        dto17ApiEchosign.GetComposeDocumentUrlResult testGetComposeDocumentUrlResult = new dto17ApiEchosign.GetComposeDocumentUrlResult();
        dto17ApiEchosign.ComposeDocumentInfo testComposeDocumentInfo = new dto17ApiEchosign.ComposeDocumentInfo();
        dto17ApiEchosign.DeviceInfo testDeviceInfo = new dto17ApiEchosign.DeviceInfo();
        dto17ApiEchosign.SignatureLocation testSignatureLocation  = new dto17ApiEchosign.SignatureLocation();
        dto17ApiEchosign.DelegateSigningOptions testDelegateSigningOptions = new dto17ApiEchosign.DelegateSigningOptions();
        dto17ApiEchosign.RejectDocumentResult testRejectDocumentResult = new dto17ApiEchosign.RejectDocumentResult();
        dto17ApiEchosign.ArrayOfDocumentLibraryItem testArrayOfDocumentLibraryItem = new dto17ApiEchosign.ArrayOfDocumentLibraryItem();     
        dto17ApiEchosign.NotifyDocumentVaultedResult  testNotifyDocumentVaultedResult  = new dto17ApiEchosign.NotifyDocumentVaultedResult();
        dto17ApiEchosign.GetMegaSignDocumentResult testGetMegaSignDocumentResult = new dto17ApiEchosign.GetMegaSignDocumentResult();
        dto17ApiEchosign.ArrayOfLibraryTemplateType testArrayOfLibraryTemplateType = new dto17ApiEchosign.ArrayOfLibraryTemplateType();
        dto17ApiEchosign.VaultEventInfo testVaultEventInfo = new dto17ApiEchosign.VaultEventInfo();
        dto17ApiEchosign.GetLibraryDocumentsForUserResult  testGetLibraryDocumentsForUserResult  = new dto17ApiEchosign.GetLibraryDocumentsForUserResult();
        dto17ApiEchosign.DocumentLibraryItem  testDocumentLibraryItem = new dto17ApiEchosign.DocumentLibraryItem();     
        dto17ApiEchosign.RejectDocumentOptions testRejectDocumentOptions = new dto17ApiEchosign.RejectDocumentOptions();
        dto17ApiEchosign.DocumentListItem testDocumentListItem = new dto17ApiEchosign.DocumentListItem();
        dto17ApiEchosign.ReplaceSignerOptions testReplaceSignerOptions = new dto17ApiEchosign.ReplaceSignerOptions();
        dto17ApiEchosign.GetDocumentsForUserResult testGetDocumentsForUserResult = new dto17ApiEchosign.GetDocumentsForUserResult();
        dto17ApiEchosign.ArrayOfDocumentListItem testArrayOfDocumentListItem = new dto17ApiEchosign.ArrayOfDocumentListItem();
        
    }
}