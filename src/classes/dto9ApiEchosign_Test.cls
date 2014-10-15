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
private class dto9ApiEchosign_Test{

    static testMethod void myUnitTest() {

        dto9ApiEchosign  testdto9ApiEchosign  = new dto9ApiEchosign ();
        dto9ApiEchosign.AuditTrailResult   testAuditTrailResult   = new dto9ApiEchosign.AuditTrailResult();
        dto9ApiEchosign.LibraryDocumentCreationInfo testLibraryDocumentCreationInfo = new dto9ApiEchosign.LibraryDocumentCreationInfo();
        dto9ApiEchosign.ArrayOfNextParticipantInfo   testArrayOfNextParticipantInfo   = new dto9ApiEchosign.ArrayOfNextParticipantInfo();
        dto9ApiEchosign.SigningUrl   testSigningUrl   = new dto9ApiEchosign.SigningUrl();
        dto9ApiEchosign.ArrayOfSigningUrl   testArrayOfSigningUrl    = new dto9ApiEchosign.ArrayOfSigningUrl();
        dto9ApiEchosign.InitiateInteractiveSendDocumentResult   testInitiateInteractiveSendDocumentResult  = new dto9ApiEchosign.InitiateInteractiveSendDocumentResult();
        dto9ApiEchosign.MergeFieldInfo   testMergeFieldInfo  = new dto9ApiEchosign.MergeFieldInfo();
        dto9ApiEchosign.NextParticipantInfo   testNextParticipantInfo   = new dto9ApiEchosign.NextParticipantInfo();
        dto9ApiEchosign.UserCredentials   testUserCredentials  = new dto9ApiEchosign.UserCredentials();
        dto9ApiEchosign.MergeField   testMergeField = new dto9ApiEchosign.MergeField();
        dto9ApiEchosign.ArrayOfMergeField   testArrayOfMergeField   = new dto9ApiEchosign.ArrayOfMergeField();
    }
}