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
private class dto18ApiEchosign_Test{

    static testMethod void myUnitTest() {

        dto18ApiEchosign  testdto18ApiEchosign  = new dto18ApiEchosign ();
        dto18ApiEchosign.SearchUserDocumentsOptions  testSearchUserDocumentsOptions    = new dto18ApiEchosign.SearchUserDocumentsOptions();
        dto18ApiEchosign.ArrayOfRecipientSecurityOption testArrayOfRecipientSecurityOption = new dto18ApiEchosign.ArrayOfRecipientSecurityOption();     
        dto18ApiEchosign.DocumentEventsForUserOptions testDocumentEventsForUserOptions = new dto18ApiEchosign.DocumentEventsForUserOptions();
        dto18ApiEchosign.DocumentEventForUser testDocumentEventForUser = new dto18ApiEchosign.DocumentEventForUser();
        dto18ApiEchosign.GetUserInfoOptions testGetUserInfoOptions = new dto18ApiEchosign.GetUserInfoOptions();
        dto18ApiEchosign.UserData testUserData = new dto18ApiEchosign.UserData();
        dto18ApiEchosign.ArrayOfUserCapabilityFlag testArrayOfUserCapabilityFlag = new dto18ApiEchosign.ArrayOfUserCapabilityFlag();
        dto18ApiEchosign.ArrayOfUserRole testArrayOfUserRole = new dto18ApiEchosign.ArrayOfUserRole();
        dto18ApiEchosign.GetDocumentEventsForUserResult testGetDocumentEventsForUserResult = new dto18ApiEchosign.GetDocumentEventsForUserResult();
        dto18ApiEchosign.ArrayOfDocumentEventForUser testArrayOfDocumentEventForUser = new dto18ApiEchosign.ArrayOfDocumentEventForUser();
        dto18ApiEchosign.GetUserInfoResult testGetUserInfoResult = new dto18ApiEchosign.GetUserInfoResult();
        dto18ApiEchosign.RecipientSecurityOption testRecipientSecurityOption = new dto18ApiEchosign.RecipientSecurityOption();
        dto18ApiEchosign.ArrayOfAgreementEventType testArrayOfAgreementEventType = new dto18ApiEchosign.ArrayOfAgreementEventType();
        dto18ApiEchosign.ArrayOfDocumentHistoryEvent  testArrayOfDocumentHistoryEvent  = new dto18ApiEchosign.ArrayOfDocumentHistoryEvent ();
        dto18ApiEchosign.DocumentHistoryEvent  testDocumentHistoryEvent = new dto18ApiEchosign.DocumentHistoryEvent ();
    }
}