/****************************************************
  
    MANAGE CONTENT CONTROLLER
   
    Built by Hank Ryan Thompson.
    Created 11/13/2013.
    Last updated 01/07/2014 by Sharmila J.
   
    This controller powers the Manage Content buttons
    on the Content related list of the Account,
    Opportunity and Acquisition records.
   
****************************************************/


public class ManageContentController {
    
    /*=== STATE VARIABLES ===*/
    
    // Public Variables & Getters
    public Id objectId {get; set;}
    public String relatedFieldName {get; set;}
    public string tabselected {get; set;}
    
    //Approver Information.  If approvers change, please also update ContentVersionManagement
    private string PrimaryApproverList= Label.Seller_Documents_Portal_Visibility_Primary_Approver_List;
    private string ConfidentialityApproverList = Label.Seller_Documents_Portal_Visibility_Confidentiality_Approver_List;
    private string EditorialApproverList = Label.Seller_Documents_Portal_Visibility_Editorial_Approver_List;
    private string[] PrimaryApproverEmailList=new String[] {Label.PrimaryApproverEmailList};
    private string[] ConfidentialityApproverEmailList;
    private string[] EditorialApproverEmailList = new String[] {Label.EditorialApproverEmailList};
    
    //User authentication variables
    Id profileId=userinfo.getProfileId(); //May move to profiled based system in the future
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    string ThisUserName = userinfo.getName();
    public string currentUserApprovalLevel {get; set;}

    //EmailNotification
    public List<RelatedContentWrapper> ReviewDocuments {get;set;}
    private Integer OriginalLoadCount {get;set;}
    private Integer CurrentLoadCount {get;set;}
    private String[] ApprovalReqNotificaitonEmail; 
    private String ApprovalEmailSubject {get;set;}
    private String DeniedEmailSubject  {get;set;}

    private String envURL  =  System.URL.getSalesforceBaseUrl().getHost();
    private String URLLink  {get;set;}
    private String closeLink  {get;set;}
    private String ApprovalemailBody  {get;set;}
    private String DeniedEmailBody  {get;set;}

    private Integer NumApproved {get;set;}
    private Integer NumDenied {get;set;}
    private Object ObjectName {get;set;}
    private string RelatedField {get;set;}
    public Set<Id> contentIdSet = new Set<Id>(); //to check which content is newly created for incremental loads
    
    public User ConfidentialityApprover {get; set;}
    
    
    /*=== INITIALIZATION ===*/
    
    public ManageContentController () {
        system.debug('###ManageContentController(): Entering constructor...###');
       
        // Get page parameters
        if (ApexPages.currentPage().getParameters().containsKey('id')) objectId = ApexPages.currentPage().getParameters().get('id' );
        if (ApexPages.currentPage().getParameters().containsKey('field')) relatedFieldName = ApexPages.currentPage().getParameters().get('field' );               
             

        Schema.SObjectType token = objectId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        String ObjectNameQuery = 'SELECT Name FROM ' + dr.getName() + ' WHERE Id=\'' + objectId + '\''; 
        SObject TheObject = Database.query(ObjectNameQuery);
        ObjectName = TheObject.get('Name');
            if (dr.getName() == 'Opportunity'){            
                RelatedField = 'Opportunity__c';
                ConfidentialityApprover = [select id,name,email,ProfileID from User where name=:ConfidentialityApproverList];
            }
            else if (dr.getName() == 'Account'){
                RelatedField = 'Account__c';
                ConfidentialityApprover = [select id,name,email,ProfileID from User where name=:ConfidentialityApproverList];                
            }
            else{
                RelatedField ='Acquisition__c';
                try{
                    TheObject = [select id,Analysis_Assigned_to__c from Acquisition_Opportunity__c where id=:objectId];
                    ConfidentialityApprover = [select id,name,email,ProfileID from User where Id=:(Id)TheObject.get('Analysis_Assigned_to__c')];
                    ConfidentialityApproverEmailList = new String[] {ConfidentialityApprover.email}; 
                }
                catch(Exception e){
                    
                }
                
            }        
        // Initialize state variables
        tabselected = 'manageContent';
        if (PrimaryApproverList.contains(ThisUserName))
            currentUserApprovalLevel = 'Primary Approver';        
        else if ((RelatedField=='Acquisition__c' && ConfidentialityApprover!=null && ConfidentialityApprover.Id==UserInfo.getUserId())
               ||((RelatedField=='Account__c' || RelatedField=='Opportunity__c') && ConfidentialityApproverList.contains(ThisUserName)))
            currentUserApprovalLevel = 'Confidentiality Approver';
        else if (EditorialApproverList.contains(ThisUserName))
            currentUserApprovalLevel = 'Editorial Approver';
        else if (profileName.contains('System Administrator'))
            currentUserApprovalLevel = 'System Administrator';
       system.debug('ThisUserName: '+ ThisUserName + ',  PrimaryApproverList: ' + PrimaryApproverList + ' Current User Approval Level: '+ currentUserApprovalLevel+ ' the contain function: ' + (EditorialApproverList.contains(ThisUserName+',')));
        ReviewDocuments = new List<RelatedContentWrapper>();
        
                
        DefaultEmailSettings();
        if ((objectId != null) && (relatedFieldName != null)){  
            checkForNewDocuments();
        }
        else {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required page parameters are missing.'));
        }
        
        
        
        system.debug('###ManageContentController(): Exiting constructor.###');       
    }

    private void DefaultEmailSettings()
    {
        Schema.SObjectType token = objectId.getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        
        ApprovalEmailSubject = ObjectName + '- Document(s) waiting your approval';
        DeniedEmailSubject = ObjectName + '- Document(s) Denied Portal Publishing Rights';

        envURL  =  System.URL.getSalesforceBaseUrl().getHost();
        URLLink = '<a href=https://' + envURL + '/' + objectId+'>' ;
        closeLink = '</a><br>';
        ApprovalemailBody =  'Your Approval is needed for the following documents related to ' + dr.getName() + ': ' + URLLink  + ObjectName + closeLink + '<br>';
        DeniedEmailBody = 'For ' + dr.getName() + ': ' + URLLink  +  ObjectName + closeLink + '<br>The following Documents have been denied publishing to the Client Portal by User: '+ ThisUserName + '<br><br>';

        system.debug('Starting  mid-workflow items progressing: ' + NumApproved + '. Number of rejected: ' + NumDenied);
        URLLink = '<a href=https://' + envURL + '/apex/ManageContent?id='+ ObjectId+ '&field=' + RelatedField+ '>' ;

        NumApproved =0;
        NumDenied =0;
    }

    /*=== ACTIONS ===*/

    public PageReference checkForNewDocuments()
    {
        CurrentLoadCount = 0;
        OriginalLoadCount = ReviewDocuments.size();
         String queryString = 'select Id, Title, NDA__c, Portal_Visible__c,Portal_Visible_Review__c,Portal_Visible_Final__c, Review_Status__c, Type__c , CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate from ContentVersion where IsLatest=true and ' + relatedFieldName + '=\'' + objectId + '\' order by CreatedDate desc';
        try {
             ContentVersion[] AttachedDocuments = Database.query(queryString);
             CurrentLoadCount = AttachedDocuments.size();
                system.debug('Initial Check CurrentLoadCount: ' + CurrentLoadCount + ' OriginalLoadCount: ' + OriginalLoadCount);
                if (CurrentLoadCount != OriginalLoadCount)
                 {
                    ReviewDocuments.clear();
                    ApexPages.getMessages().clear();
                    for(ContentVersion cv :AttachedDocuments){
                        ReviewDocuments.add(new RelatedContentWrapper(cv,currentUserApprovalLevel));
                    }
                    OriginalLoadCount = ReviewDocuments.size();
                    system.debug('When not equal set CurrentLoadCount: ' + CurrentLoadCount + ' OriginalLoadCount: ' + OriginalLoadCount);
                    //refresh();
                }//New Documents Added
            }//try
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered while querying for related content items.\nERROR MESSAGE: ' + e.getMessage()));
            
        }
        Return null;
    }

    public PageReference Reviewed()
    {
        system.debug('###Reviewed(): Entering function.###');
        tabselected = 'manageContent';
        NumApproved = 0; //updated in SaveChanges()
        NumDenied = 0;
        //NumFinalized = 0;
        PageReference returnPage;
        //PageReference returnPage; // default to null
        try 
        {
        
         for(RelatedContentWrapper cv: ReviewDocuments)
            {   
                if(currentUserApprovalLevel!='System Administrator')
                    cv.doc.Review_Status__c=cv.OriginalReviewStatus;
               if (cv.RecordEditable == true)
               {
                    cv.ReviewErrorMessage = '';
                    if(currentUserApprovalLevel == 'Primary Approver')
                    {                   
                        //Denied
                        if ( (cv.doc.NDA__c != cv.NDA_Original || cv.doc.Portal_Visible__c != cv.primaryPortalReview_Original ) && (cv.doc.NDA__c == 'Yes' || (cv.doc.NDA__c != 'Not Recorded' && cv.doc.Portal_Visible__c=='No')))
                        {   
                            cv.doc.Review_Status__c = 'Publication Denied - Primary Review';
                            cv.doc.Type__c='';
                            cv.doc.Portal_Visible_Review__c='N/A';
                            cv.doc.Portal_Visible_Final__c='N/A';
                                                                           
                            if(cv.portalVisibilityEditable==false && cv.doc.Portal_Visible__c=='Yes'){
                                cv.doc.Portal_Visible__c='N/A';
                                //cv.portalVisibilityEditable = true;
                            }                                                   
                        }
                        //Approved
                        else if ( (cv.doc.NDA__c != cv.NDA_Original || cv.doc.Portal_Visible__c != cv.primaryPortalReview_Original) && cv.doc.Portal_Visible__c=='Yes')
                        { 
                            if (cv.doc.NDA__c=='Not Recorded' || cv.doc.NDA__c=='N/A')
                                {
                                    //cv.doc.adderror('Please add a NDA value.');
                                    cv.ReviewErrorMessage = 'Please add a NDA value.';                                   
                                }                                         
                            else{
                                cv.doc.Review_Status__c = 'Confidentiality Review'; 
                                cv.doc.Portal_Visible_Review__c='Not Recorded';
                                cv.doc.Portal_Visible_Final__c='Not Recorded';
                            }//If NDA value is filled
                        }// Approved                 
                        
                        if((cv.doc.NDA__c != cv.NDA_Original) && cv.doc.NDA__c=='Not Recorded' || cv.doc.NDA__c=='' || cv.doc.NDA__c==null || cv.doc.NDA__c=='N/A'){
                            cv.ReviewErrorMessage = 'Please add a NDA value.'; 
                        }
                        
                        if((cv.doc.Portal_Visible__c != cv.primaryPortalReview_Original || cv.doc.NDA__c != cv.NDA_Original) && (cv.doc.Portal_Visible__c == 'Not Recorded' || cv.doc.Portal_Visible__c==null || cv.doc.Portal_Visible__c=='N/A')){
                           if(cv.portalVisibilityEditable){
                            cv.ReviewErrorMessage = 'Please add Portal Visibility value.';
                            cv.portalVisibilityEditable = true;
                           }                           
                        }   
                        
                    }// Primary Approver
                    else if (currentUserApprovalLevel == 'Confidentiality Approver')
                    {
                        //Denied
                        if (cv.doc.Type__c=='Claim Charts' || cv.doc.Type__c=='EOU')
                        { 
                            if(cv.doc.Review_Status__c!='Publication Denied - Primary Review'){
                                cv.doc.Review_Status__c = 'Publication Denied - Confidentiality Review';
                                cv.doc.Portal_Visible_Final__c='N/A';
                            }
                        }
                        //Approved
                        else if (cv.doc.Type__c=='Marketing Info' || cv.doc.Type__c=='Public Patent & Lit Info')
                        {
                            if(cv.doc.Review_Status__c=='Confidentiality Review' || cv.doc.Review_Status__c=='Publication Denied - Confidentiality Review'){
                                cv.doc.Review_Status__c = 'Editorial Review';
                                cv.doc.Portal_Visible_Final__c='Not Recorded';
                            }
                        }
                        
                       /* if(cv.confidentialityPortalReview_Original!=cv.doc.Portal_Visible_Review__c && (cv.doc.Portal_Visible_Review__c=='Not Recorded' || cv.doc.Portal_Visible_Review__c=='N/A' || cv.doc.Portal_Visible_Review__c==null)){
                            cv.ReviewErrorMessage = 'Please add Portal Visibility value.';          
                        } */                 
                         
                    }
                     else if (currentUserApprovalLevel == 'Editorial Approver')
                    {
                        //Denied
                        if (cv.doc.Portal_Visible_Final__c=='No')
                        { 
                            cv.doc.Review_Status__c = 'Publication Denied - Editorial Review';
                        }
                        //Approved
                        else if (cv.doc.Portal_Visible_Final__c=='Yes')
                        {
                            cv.doc.Review_Status__c = 'Publication Approved';
                        }
                        
                        if(cv.portalVisibileFinal_Original!=cv.doc.Portal_Visible_Final__c && (cv.doc.Portal_Visible_Final__c=='Not Recorded' || cv.doc.Portal_Visible_Final__c=='N/A' || cv.doc.Portal_Visible_Final__c==null)){
                            cv.ReviewErrorMessage = 'Please add Portal Visibility value.';    
                        }
                    }
                }// If record is editable
            }//For every content record



            //Save the changes with the newly assigned review state
            system.debug('###Reviewed(): call saveChanges.###' );
            saveChanges();
            system.debug('Saved without erros   Total number of mid-workflow items progressing: ' + NumApproved + '. Number of rejected: ' + NumDenied);
                
            // system.debug('###Reviewed(): Exiting function with returnPage = ' + returnPage + '.###' );
            //Send out notification emails 
            if (NumApproved>0)
            {
                system.debug(ThisUserName +' has requested approval for '+ NumApproved + ' number of documents sending to email '+ ApprovalReqNotificaitonEmail);
                sendNotificationEmails(ApprovalReqNotificaitonEmail,ApprovalEmailSubject, null, ApprovalemailBody);
            }
            if (NumDenied>0) {
                 system.debug(ThisUserName +' has denied approval for '+ NumDenied + ' number of documents sending to email '+ PrimaryApproverEmailList);
                sendNotificationEmails(PrimaryApproverEmailList,DeniedEmailSubject, null,DeniedEmailBody);
            }           
            system.debug('###Reviewed(): Exiting function. ###' );
        
        }//End Try

        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered trying to review related content items.\nERROR MESSAGE: ' + e.getMessage()));
        }
        return returnPage ;
       
    }
    
    public void saveChanges() {
        // Update related content items
        tabselected = 'manageContent';
        system.debug('###saveChanges(): Entering function with relatedContentItems = ' + ReviewDocuments + '.###' );
        
       try {
           DefaultEmailSettings();
           list<ContentVersion> docs = new list<ContentVersion>();
           for (RelatedContentWrapper cvw: ReviewDocuments)
           {
               System.debug('## '+cvw.doc.Review_Status__c+' - '+cvw.OriginalReviewStatus+' '+cvw.doc.title);
               
               if(((cvw.doc.Review_Status__c != cvw.OriginalReviewStatus 
                    || cvw.doc.Portal_visible__c != cvw.primaryPortalReview_Original 
                    || cvw.doc.Type__c != cvw.Type_Original
                    || cvw.doc.NDA__c != cvw.NDA_Original) &&  cvw.ReviewErrorMessage=='' )
                                  
                    ) {       
                   System.debug('#### added '+cvw.doc.title);             
                   docs.add(cvw.doc);                                        
               }
           }
         //update docs;
         
         Database.SaveResult[] lsr = Database.update(docs,false);
         Integer counter = 0;
         for(Database.SaveResult sr:lsr){           
            if(sr.isSuccess()){ //If successfully updated the documents, send the emails and restrict further editing of the record.                                
                 for(RelatedContentWrapper cvw: ReviewDocuments){
                       if(cvw.doc.Id==docs[counter].id){
                           if(currentUserApprovalLevel!='System Administrator'){
                            cvw.RecordEditable=false;
                            cvw.portalVisibilityEditable = false;
                           }
                           cvw.OriginalReviewStatus = cvw.doc.Review_Status__c;                           
                           prepEmail(cvw);
                       } //for related documents
                   }//Successfully saved document
            }//Saved Successfully
            else {                              
                for(RelatedContentWrapper cvw: ReviewDocuments){
                    if(cvw.doc.Id==docs[counter].id){
                        //cvw.ReviewErrorMessage = sr.getErrors()[0].getmessage(); //one record may have multiple errors. But getting only the first here.
                        for(Database.Error err: sr.getErrors()){ //We are looping here in case there are multiple errors for the same record.
                                cvw.ReviewErrorMessage = cvw.ReviewErrorMessage+err.getMessage()+'<BR/>';
                                cvw.doc.Review_Status__c = cvw.OriginalReviewStatus;
                        }//For every error
                        
                        System.debug('## '+cvw.doc.Review_Status__c+' - '+cvw.OriginalReviewStatus+' '+cvw.doc.title);
                    }//Related Wrapper
                }//For each related wrapper
            }//For Error
         counter++;
         }//For every save Result
         refresh();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error encountered trying to update related content items.\nERROR MESSAGE: ' + e.getMessage()+ ' . No changes saved.  Click the \'Refresh\' button to see current values in the database.'));
        }
        
         system.debug('###saveChanges(): Exiting function.###' );
    }
    

    public void prepEmail (RelatedContentWrapper cv)
    {
        //We need to prep both approval emails and denial emails because a batch could contain a mix of both
        system.debug('###Reviewed(): Setting Email info.###' );
        
      // public string ReviewEmail {get;set;} {None, ApprovalRequired, Denied, Finalized}
        if(currentUserApprovalLevel == 'Primary Approver' && cv.doc.Review_Status__c == 'Confidentiality Review' && ConfidentialityApprover!=null)
        {               
            ApprovalReqNotificaitonEmail = ConfidentialityApproverEmailList;
            ApprovalemailBody += URLLink +cv.doc.Title + closeLink;
            NumApproved++;
        }// Primary Approver, Confidentiality Review
        else if (currentUserApprovalLevel == 'Confidentiality Approver' && cv.doc.Review_Status__c == 'Editorial Review')
        {
            ApprovalReqNotificaitonEmail = EditorialApproverEmailList;
            ApprovalemailBody += URLLink+cv.doc.Title + closeLink;
            NumApproved++;
        }//Confidentiality approver, Editorial review        
        else if (cv.doc.Review_Status__c .contains('Publication Denied') && currentUserApprovalLevel != 'Primary Approver')
        { 
            DeniedEmailBody += URLLink +cv.doc.Title + closeLink;
            NumDenied++;
        }//Publication denied, SystemAdmin/Editorial/Confidentiality approver
        
    }
    
    public static void sendNotificationEmails(String[] sendTo, String subject, String plainTextBody, String htmlBody) {
        // Sends an email as per the review workflow determined 
        system.debug('###sendNotificationEmails(): Entering###' );
        Messaging.reserveSingleEmailCapacity(10);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        //email.setToAddresses(new String[] {errorNotificationEmailAddress});
        email.setToAddresses(sendTo);
        email.setReplyTo('do-not-reply@rpxcorp.com');
        email.setSenderDisplayName('Seller Document Approval Process');
        
        email.setSubject(subject);
        email.setPlainTextBody(plainTextBody);
        email.setHtmlBody(htmlBody);
        system.debug('###sendNotificationEmails(): Entering###' );
        system.debug(LoggingLevel.ERROR, '###sendNotificationEmails(): Sending email = '  + email + ', email limit: ' + Limits.getEmailInvocations() + ' out of ' + Limits.getLimitEmailInvocations() + '.###');
        //If this is not test and hasn't exceeded email limits for the da, send out the notifications prepared in the review() method
            {
                if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) 
                    {
                        if (!Test.isRunningTest()) 
                        {
                            if(SellerBrokerEmail__c.getInstance().Send_Email__c==true)
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});    
                        }
                    }
                }
         system.debug('###sendNotificationEmails(): Exiting###' );
    }

    
    public PageReference cancel() {
        String theURL = '/';
        if (objectId != null) theURL += objectId;
        return new PageReference(theURL);
    }
    
    public PageReference refresh() {
        // Re-queries the related content items
        system.debug('###refresh(): Entering function.###');        
        tabselected = 'manageContent';
        return null;
    }
    
    public PageReference MakeAllEligibleEditable()
    {
        ReviewDocuments.clear();
        checkForNewDocuments();
        for(RelatedContentWrapper cv: ReviewDocuments)
        { 
            if (    (currentUserApprovalLevel=='Primary Approver')
                        && ( (cv.doc.Review_Status__c=='Not Submitted'||cv.doc.Review_Status__c=='Publication Denied - Primary Review' 
                                || cv.doc.Review_Status__c=='Editorial Review' || cv.doc.Review_Status__c=='Publication Approved' 
                            )
                            || (cv.doc.Review_Status__c=='Confidentiality Review' && cv.doc.Portal_Visible_Review__c=='Not Recorded'))
                ){
                cv.RecordEditable = true;
                if( cv.doc.Review_Status__c=='Editorial Review' || cv.doc.Review_Status__c=='Publication Approved') //|| cv.doc.Review_Status__c=='Publication Denied - Confidentiality Review' || cv.doc.Review_Status__c=='Publication Denied - Editorial Review')
                    cv.portalVisibilityEditable = false;
                else  cv.portalVisibilityEditable = true;
            }
            else if (   (currentUserApprovalLevel=='Confidentiality Approver')
                        && ( (cv.doc.Review_Status__c=='Confidentiality Review'||cv.doc.Review_Status__c=='Publication Denied - Confidentiality Review')
                           || (cv.doc.Review_Status__c=='Editorial Review' && cv.doc.Portal_Visible_Final__c=='Not Recorded' || cv.doc.Review_Status__c=='Publication Denied - Primary Review'))
                    )
                cv.RecordEditable = true;
            else if (   (currentUserApprovalLevel=='Editorial Approver')
                        && ((cv.doc.Review_Status__c=='Editorial Review'||cv.doc.Review_Status__c=='Publication Denied - Editorial Review')
                            || cv.doc.Review_Status__c=='Publication Approved')//??????????
                    )
                cv.RecordEditable = true;
            else if (currentUserApprovalLevel == 'System Administrator'){
                cv.RecordEditable = true;
                cv.portalVisibilityEditable = true;
            }
            else
                cv.RecordEditable = false;
            
        }
        return null;
    }
    
    
    //----------------------------------------------------------------//
    //Inner wrapper classes
    //---------------------------------------------------------------//   
    public class RelatedContentWrapper{
        public boolean ndaVisible {get;set;}
        public boolean RecordEditable {get;set;}
        public boolean portalVisibilityEditable {get; set;} 
        public ContentVersion doc {get;set;}
        public string OriginalReviewStatus {get;set;}
        public string ReviewErrorMessage {get;set;}
        public string Approver {get;set;}
        public string NDA_Original {get; set;}
        public string type_original {get; set;}
        public string primaryPortalReview_Original {get; set;}
        public string confidentialityPortalReview_Original {get; set;}
        public string portalVisibileFinal_Original {get; set;}
        public RelatedContentWrapper(ContentVersion doc,string currentUserApprovalLevel){           
            this.doc = doc;
            this.Approver = currentUserApprovalLevel;
            NDA_Original = doc.NDA__c;
            primaryPortalReview_Original = doc.Portal_Visible__c;
            OriginalReviewStatus = doc.Review_Status__c;
            confidentialityPortalReview_Original = doc.Portal_Visible_Review__c;
            portalVisibileFinal_Original = doc.Portal_Visible_Final__c;
            type_original = doc.Type__c;
            if (currentUserApprovalLevel=='Primary Approver'){ 
                if(doc.Review_Status__c=='Not Submitted'){
                    RecordEditable = true;
                    portalVisibilityEditable = true;
                }
                else {
                    RecordEditable = true;
                    portalVisibilityEditable = false;                   
                }
                 
            }
            else if (currentUserApprovalLevel=='Confidentiality Approver'
                        && ( doc.Review_Status__c=='Confidentiality Review'|| doc.Review_Status__c=='Publication Denied - Primary Review'))
                RecordEditable = true;
            else if (currentUserApprovalLevel=='Editorial Approver' && (doc.Review_Status__c=='Editorial Review'))
                RecordEditable = true;
            else if (currentUserApprovalLevel == 'System Administrator'){
                RecordEditable = true;
                portalVisibilityEditable = true;
            }
            else
                RecordEditable = false;
        }
    }
}