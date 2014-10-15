/*
    Trigger : ApplicationTrigger
    Description : - Common class for all the trigger events of ApplicationTrigger
    Created By : Prakash
    Created Date : Sep 24th,2014
*/
public class ApplicationTriggerHandler{

    public static void afterUpdate(Id appId){
        sendApplicationsForSignature(appId);
    }
 
    public static void sendApplicationsForSignature(Id applicationId){
        system.debug('#####applicationList:'+applicationId);
        
            Id agreementId ;
            List<echosign_dev1__SIGN_Agreement__c> agmtList =[Select ID FROM 
                                                                echosign_dev1__SIGN_Agreement__c WHERE
                                                                Application__c =: applicationId
                                                                order by LastModifiedDate desc LIMIT 1];
            agreementId =agmtList[0].Id ;
            
            PageReference pdf = Page.InsuranceApplicationSummaryPDF;
                // add parent id to the parameters for standardcontroller
                pdf.getParameters().put('id',applicationId);
                 // the contents of the attachment from the pdf
                Blob body =  Blob.valueOf('Sample Agreement');
                // the contents of the attachment from the pdf
                system.debug('#####before Attachment :');
                try {
                  // returns the output of the page as a PDF
                  body = pdf.getContent();
                  String filename =  agmtList[0].Name + ' ' + DateTime.Now().format('MM-dd-yy') + '.pdf';
                  Attachment attach = new Attachment(parentId = agmtList[0].id, name=filename, body = body, ContentType = 'application/pdf');              
                  Insert attach;              
                  system.debug('#####attach:--'+attach.Id);          
                } catch (VisualforceException e) {
                   system.debug('#####Error in Trigger:'); 
                   // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
                    
                }
                system.debug('#####before sendforSign:');  
                sendforSign(agreementId);                                                                      
                system.debug('#####afer sendforSign:');   
          }  
    @Future(callout= true)  
    public static void sendforSign(String agreementId){
            system.debug('#####Entered sendforSign:');              
            dtoApiEchosign.SenderInfo senderInfo = new dtoApiEchosign.SenderInfo();
            senderInfo.email = 'akamal@rpxcorp.com';  
            
            echosign_dev1__SIGN_Agreement__c agreement =[Select Id,Name,echosign_dev1__Recipient__r.Email From echosign_dev1__SIGN_Agreement__c agreement where Id =: agreementId ]; 
            apiEchosign.EchoSignDocumentService19HttpPort  api = new apiEchosign.EchoSignDocumentService19HttpPort();
  
            dtoApiEchosign.DocumentCreationInfo documentCreationInfo = new dtoApiEchosign.DocumentCreationInfo();
            
            String apiKey = 'XE84R2SF2WZ9N3X';                    
            
            documentCreationInfo.name = agreement.Name;
            documentCreationInfo.signatureFlow = 'SENDER_SIGNATURE_NOT_REQUIRED';
            documentCreationInfo.signatureType = 'ESIGN';
            
            
            //documentCreationInfo.externalId = getExternalId(agreement.Id);
            
            dtoApiEchosign.ExternalId externalId = new dtoApiEchosign.ExternalId();        
            String namespace = 'SALESFORCE';
            String groupName = UserInfo.getOrganizationId();
            String id = agreementId.substring(0, 15);
            
            externalId.namespace = namespace;
            externalId.group_x = groupName;
            externalId.id = id;
        
            dto14ApiEchosign.ArrayOfRecipientInfo recipients = new dto14ApiEchosign.ArrayOfRecipientInfo();
            dto14ApiEchosign.RecipientInfo[] recipientInfos = new dto14ApiEchosign.RecipientInfo[]{};
            
            dto14ApiEchosign.RecipientInfo recipientInfo = new dto14ApiEchosign.RecipientInfo();
            
            recipientInfo.email = agreement.echosign_dev1__Recipient__r.Email;              
            recipientInfo.role = 'SIGNER';
            
            recipientInfos.add(recipientInfo);      
            recipients.RecipientInfo = recipientInfos;          
            documentCreationInfo.recipients = recipients;
            
            map<Id, list<Attachment>> attachmentsMap = new map<Id,list<Attachment>>();
            list<Attachment> attachmentList = [select Id, Name, Body from Attachment where parentId = :agreement.Id];
            
            attachmentsMap.put(agreement.Id, attachmentList);
            documentCreationInfo.fileInfos = getDocumentInfos(agreement, attachmentsMap);
            
            system.debug('#####apiKey:'+apiKey);
            system.debug('#####recipientInfo:'+recipientInfo);
            system.debug('#####senderInfo:'+senderInfo);
            system.debug('#####:documentCreationInfo'+documentCreationInfo);
            dto16ApiEchosign.ArrayOfDocumentKey docKeyList;
            
        if(!(Test.isRunningTest())){
            docKeyList =  api.sendDocument(apiKey, senderInfo, documentCreationInfo); 
            system.debug('#####docKeyList :'+docKeyList ); 
        }
        system.debug('#####Exiting sendforSign:');     
    }
      
   public static dtoApiEchosign.ArrayOfFileInfo getDocumentInfos(echosign_dev1__SIGN_Agreement__c agreement, map<Id, list<Attachment>> attachmentsMap) 
   {
        transient dtoApiEchosign.ArrayOfFileInfo arrayOfFileInfo = new dtoApiEchosign.ArrayOfFileInfo();
        
        list<Attachment> attachments = attachmentsMap.get( agreement.Id );
        
        if( attachments == null ) 
        {
            return arrayOfFileInfo;
        }
        
        transient dtoApiEchosign.FileInfo[] fileInfos = new dtoApiEchosign.FileInfo[]{};

        for(Attachment attachment : attachments) 
        {
            dtoApiEchosign.FileInfo fileInfo = new dtoApiEchosign.FileInfo();
            fileInfo.file = EncodingUtil.base64Encode(attachment.Body);            
            fileInfo.FileName = attachment.Name;            
            fileInfos.add(fileInfo);
        }
        
        arrayOfFileInfo.FileInfo = fileInfos;   
        
        return arrayOfFileInfo;
    }
    
}