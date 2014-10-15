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
private class dtoApiEchosign_Test{

    static testMethod void myUnitTest() {

        dtoApiEchosign testdtoApiEchosign  = new dtoApiEchosign();
        dtoApiEchosign.VaultingInfo testVaultingInfo  = new dtoApiEchosign.VaultingInfo();
        dtoApiEchosign.Pong testPong = new dtoApiEchosign.Pong();
        dtoApiEchosign.FormCreationInfo   testFormCreationInfo   = new dtoApiEchosign.FormCreationInfo();
        dtoApiEchosign.CallbackInfo   testCallbackInfo   = new dtoApiEchosign.CallbackInfo  ();
        dtoApiEchosign.ArrayOfDocumentPageImages   testArrayOfDocumentPageImages   = new dtoApiEchosign.ArrayOfDocumentPageImages  ();
        dtoApiEchosign.ExternalId   testExternalId   = new dtoApiEchosign.ExternalId  ();
        dtoApiEchosign.UserCreationInfo   testUserCreationInfo   = new dtoApiEchosign.UserCreationInfo  ();
        dtoApiEchosign.DocumentCreationInfo   testDocumentCreationInfo   = new dtoApiEchosign.DocumentCreationInfo  ();
        dtoApiEchosign.CancelDocumentResult   testCancelDocumentResult   = new dtoApiEchosign.CancelDocumentResult  ();
        dtoApiEchosign.SecurityOptions   testSecurityOptions   = new dtoApiEchosign.SecurityOptions  ();
        dtoApiEchosign.DocumentImageList   testDocumentImageList   = new dtoApiEchosign.DocumentImageList  ();
        dtoApiEchosign.SenderInfo    testSenderInfo    = new dtoApiEchosign.SenderInfo   ();
        dtoApiEchosign.ArrayOfFileInfo    testArrayOfFileInfo    = new dtoApiEchosign.ArrayOfFileInfo   ();
        dtoApiEchosign.DisplayUserInfo    testDisplayUserInfo    = new dtoApiEchosign.DisplayUserInfo   ();
        dtoApiEchosign.DocumentPageImages    testDocumentPageImages    = new dtoApiEchosign.DocumentPageImages();
        dtoApiEchosign.SendReminderResult    testSendReminderResult    = new dtoApiEchosign.SendReminderResult();      
        dtoApiEchosign.UserVerificationInfo     testUserVerificationInfo     = new dtoApiEchosign.UserVerificationInfo();      
        dtoApiEchosign.DocumentUrlResult     testDocumentUrlResult     = new dtoApiEchosign.DocumentUrlResult();       
        dtoApiEchosign.FileInfo     testFileInfo     = new dtoApiEchosign.FileInfo();      
        dtoApiEchosign.RemoveDocumentResult      testRemoveDocumentResult      = new dtoApiEchosign.RemoveDocumentResult();        
        dtoApiEchosign.DocumentKey      testDocumentKey      = new dtoApiEchosign.DocumentKey     ();      
        
    }
}