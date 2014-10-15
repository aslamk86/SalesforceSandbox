global class SignedAttachmentInsertSchedulable implements Schedulable{
    global String Out_for_Signature = 'Out for Signature';
    
    global void execute(SchedulableContext sc) {
        
        SignedAttachmentInsertBatch aCheck= new SignedAttachmentInsertBatch();                              
        
        // Actual Batch Execution
       database.executebatch(aCheck);
       
       /****
        List<echosign_dev1__SIGN_Agreement__c> finalAgreementUpdate = new List<echosign_dev1__SIGN_Agreement__c>();
        List<Attachment> finalAttachInsert = new List<Attachment>();
        
        List<echosign_dev1__SIGN_Agreement__c> agmtRecords= [SELECT
                                                            ID,
                                                            Name,
                                                            Agreement_Signed__c,
                                                            echosign_dev1__Status__c,
                                                            Application__c,
                                                            echosign_dev1__Document_Key__c
                                                            FROM echosign_dev1__SIGN_Agreement__c                                                            
                                                            WHERE echosign_dev1__Status__c = 'Out for Signature'  LIMIT 5];     
        system.debug('####agmtRecords:-'+agmtRecords); 
        
        for(echosign_dev1__SIGN_Agreement__c agreement : agmtRecords){  
            apiEchosign.EchoSignDocumentService19HttpPort  api = new apiEchosign.EchoSignDocumentService19HttpPort();
            dto19ApiEchosign.DocumentInfo documt = api.getDocumentInfo('XE84R2SF2WZ9N3X',agreement.echosign_dev1__Document_Key__c);
            System.debug('###### Status'+documt .status);
            if(documt .status == 'SIGNED' && !agreement.Agreement_Signed__c ){ 
                dto14ApiEchosign.GetDocumentsOptions options = new dto14ApiEchosign.GetDocumentsOptions();
                options.combine = FALSE;
                dto16ApiEchosign.getDocumentsResult doc = api.getDocuments('XE84R2SF2WZ9N3X',agreement.echosign_dev1__Document_Key__c,options);
                System.debug('###### HI:-'+options);
                System.debug('###### DocumentInfo:-'+doc);
                System.debug('###### DocumentInfo success:-'+doc.success);
                System.debug('###### DocumentInfo supportingDocuments:-'+doc.supportingDocuments);
                System.debug('###### DocumentInfo documents:-'+doc.documents.DocumentContent[0].name);
                if(doc.success){
                    try {
                        Blob body =  Blob.valueOf('Sample Agreement');
                       body = EncodingUtil.base64Decode(doc.documents.DocumentContent[0].bytes);      
                       //body = body.toPDF(doc.documents.DocumentContent[0].bytes);
                        String filename = agreement.Name + ' ' + DateTime.Now().format('MM-dd-yy') + ' Signed.pdf';
                        Attachment attach = new Attachment(parentId = agreement.Application__c, name=filename, body = body, ContentType = 'application/pdf');
                        finalAttachInsert.add(attach);
                        
                        echosign_dev1__SIGN_Agreement__c agmtUpdate = new echosign_dev1__SIGN_Agreement__c(Id = agreement.Id);
                        agmtUpdate.Agreement_Signed__c = true;
                        agmtUpdate.echosign_dev1__Status__c = 'Signed';
                        finalAgreementUpdate.add(agmtUpdate);
                        
                    }catch (VisualforceException e) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));                      
                    }
                }
            }
        }
        if(finalAttachInsert.size()>0){
            insert finalAttachInsert;
        }
        if(finalAgreementUpdate.size()>0){
            update finalAgreementUpdate;
        } ******/       
        
    }
    
}