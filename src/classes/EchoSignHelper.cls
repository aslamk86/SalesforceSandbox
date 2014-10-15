public class EchoSignHelper {
    @future(callout=true)
    public static void SignedDocumentToProcess(Id applicationId,String Name,String documentKey) {
    
        String api_Key = EchoSign_API_Settings__c.getInstance('APIKEY').Value__c;
        
        //Retrieve Signed Document from EchoSign
        apiEchosign.EchoSignDocumentService19HttpPort api = new apiEchosign.EchoSignDocumentService19HttpPort();
        dto14ApiEchosign.GetDocumentsOptions documentOptions = new dto14ApiEchosign.GetDocumentsOptions();
        dto16ApiEchosign.GetDocumentsResult documentResult = api.getDocuments(api_Key,documentKey,documentOptions);
        System.debug(LoggingLevel.INFO, 'documentResult = ' + documentResult);        
        
        String filename = 'Application - Signed.pdf';
        Attachment attachment = new Attachment(name=filename);
        attachment.ContentType = documentResult.documents.DocumentContent[0].mimetype;
        attachment.Body = EncodingUtil.base64Decode(documentResult.documents.DocumentContent[0].bytes);
        attachment.ParentId = applicationId;
        insert attachment;
        System.debug(LoggingLevel.INFO, 'attachment = ' + attachment);        
    }
}