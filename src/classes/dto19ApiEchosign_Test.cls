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
private class dto19ApiEchosign_Test{

    static testMethod void myUnitTest() {

        dto19ApiEchosign  testdto19ApiEchosign  = new dto19ApiEchosign ();        
        dto19ApiEchosign.SignerFormField testSignerFormField  = new dto19ApiEchosign.SignerFormField ();
        dto19ApiEchosign.ArrayOfSignerFormFieldLocation   testArrayOfSignerFormFieldLocation   = new dto19ApiEchosign.ArrayOfSignerFormFieldLocation();
        dto19ApiEchosign.GetSignerFormFieldsOptions testGetSignerFormFieldsOptions = new dto19ApiEchosign.GetSignerFormFieldsOptions();     
        dto19ApiEchosign.ArrayOfDocumentPageInfo testArrayOfDocumentPageInfo = new dto19ApiEchosign.ArrayOfDocumentPageInfo();
        dto19ApiEchosign.PhoneInfo testPhoneInfo = new dto19ApiEchosign.PhoneInfo();
        dto19ApiEchosign.ArrayOfSignerFormField testArrayOfSignerFormField = new dto19ApiEchosign.ArrayOfSignerFormField();
        dto19ApiEchosign.ArrayOfPhoneInfo testArrayOfPhoneInfo = new dto19ApiEchosign.ArrayOfPhoneInfo();
        dto19ApiEchosign.OnBehalfOfUser testOnBehalfOfUser = new dto19ApiEchosign.OnBehalfOfUser();
        dto19ApiEchosign.ArrayOfDocumentInfo testArrayOfDocumentInfo = new dto19ApiEchosign.ArrayOfDocumentInfo();
        dto19ApiEchosign.FormValue testFormValue = new dto19ApiEchosign.FormValue();        
        dto19ApiEchosign.GetSignerFormFieldsResult testGetSignerFormFieldsResult = new dto19ApiEchosign.GetSignerFormFieldsResult();
        dto19ApiEchosign.GetDocumentPagesInfoResult testGetDocumentPagesInfoResult = new dto19ApiEchosign.GetDocumentPagesInfoResult();
        dto19ApiEchosign.ParticipantInfo testParticipantInfo = new dto19ApiEchosign.ParticipantInfo();
        dto19ApiEchosign.ArrayOfParticipantSecurityOption testArrayOfParticipantSecurityOption = new dto19ApiEchosign.ArrayOfParticipantSecurityOption();       
        dto19ApiEchosign.DocumentInfoList testDocumentInfoList = new dto19ApiEchosign.DocumentInfoList();
        dto19ApiEchosign.SignerFormFieldLocation testSignerFormFieldLocation = new dto19ApiEchosign.SignerFormFieldLocation();
        dto19ApiEchosign.DocumentPageInfo testDocumentPageInfo = new dto19ApiEchosign.DocumentPageInfo();
        
        dto19ApiEchosign.EmbeddedViewOptions testEmbeddedViewOptions = new dto19ApiEchosign.EmbeddedViewOptions();
        dto19ApiEchosign.SignerFormFieldCondition testSignerFormFieldCondition = new dto19ApiEchosign.SignerFormFieldCondition();
        dto19ApiEchosign.GetEmbeddedViewResult testGetEmbeddedViewResult = new dto19ApiEchosign.GetEmbeddedViewResult();
        dto19ApiEchosign.ArrayOfSignerFormFieldCondition testArrayOfSignerFormFieldCondition = new dto19ApiEchosign.ArrayOfSignerFormFieldCondition();
        
        dto19ApiEchosign.DocumentInfo testDocumentInfo = new dto19ApiEchosign.DocumentInfo();
        dto19ApiEchosign.ArrayOfParticipantRole testArrayOfParticipantRole = new dto19ApiEchosign.ArrayOfParticipantRole();
        dto19ApiEchosign.ArrayOfParticipantInfo testArrayOfParticipantInfo = new dto19ApiEchosign.ArrayOfParticipantInfo();
        dto19ApiEchosign.ArrayOfFormValue testArrayOfFormValue = new dto19ApiEchosign.ArrayOfFormValue();
        
        
        
    }
}