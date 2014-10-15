/**
*
* Description : Unit test class for SubmitSuccessfullCtrl
* 
* History 
* [01.OCT.2014] Hari Prakash: Code creation.
*/

@isTest(SeeAllData=false)
public class SubmitSuccessfullCtrl_Test{

Static Application__c application ;
Static echosign_dev1__SIGN_Agreement__c agreement ;

 public static testmethod void testSubmitSuccessfullCtrl (){
    
    setuptestdata();
    Test.startTest();
    
    PageReference pageRef = Page.SubmitSuccessfull;
    Test.setCurrentPage(pageRef);  
    Apexpages.currentPage().getParameters().put('Id',application.id);
    Apexpages.currentPage().getParameters().put('agmtId',agreement.id);
    
    SubmitSuccessfullCtrl submitctrl = new SubmitSuccessfullCtrl(); 
    submitctrl.doSubmit();  
    SubmitSuccessfullCtrl.sendForSignatureProcess(agreement.Id);
    Test.stopTest();
 }
    
 public static void setuptestdata() {     
     
     application = new Application__c();
     application.Status__c = 'Completed Application';
     insert application;
     
     agreement = new echosign_dev1__SIGN_Agreement__c();
     agreement.Name ='Test Agreement SubmitSuccessfullCtrl';
     agreement.Application__c = application.Id; 
     insert agreement;
     
     List<EchoSign_API_Settings__c> eSignAPIList = new List<EchoSign_API_Settings__c>();
     
     EchoSign_API_Settings__c eSign = new EchoSign_API_Settings__c();
     eSign.Name = 'APIKEY';
     eSign.Value__c = 'abc123';
     eSignAPIList.add(eSign);
     
     eSign = new EchoSign_API_Settings__c();
     eSign.Name = 'Sender_Mail';
     eSign.Value__c = 'akamal@rpxcorp.com';
     eSignAPIList.add(eSign);
     
     eSign = new EchoSign_API_Settings__c();
     eSign.Name = 'Signed_Document_Url';
     eSign.Value__c = 'https://rpxtst01-rpxinsurance.cs8.force.com/EchoSignCallback/services/apexrest/getEchoSignUpdate';
     eSignAPIList.add(eSign);
     
     insert eSignAPIList ;
 }
 

}