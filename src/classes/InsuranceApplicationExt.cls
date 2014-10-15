public with sharing class InsuranceApplicationExt {
    
    public Id AccountId {get; set;}
    public Application__c thisApplication {get; set;}
    public List<Contact> contactList {get; set;}
    public List<Related_Company__c> relatedCompany {get; set;}
    public Boolean shortForm {get; set;}

    public List<Assertion__c> assertionList {get; set;}
    public List<Indemnification_Request__c> indemnificationList {get; set;}
    public List<Financial_Detail__c> financialDetails {get; set;}
    public List<Financial_Detail__c> productRevenue {get; set;}
    public List<Financial_Detail__c> customerRevenue {get; set;}
    public List<Financial_Detail__c> funding {get; set;}
    public List<M_A_History__c> acqAndDivestures {get; set;}
    
    public List<CampaignLitWrapper.response> wrap {get; set;}
    
    public List<Defendant_History__c> defHistory {get; set;}
    public List<Defendant_History__c> existingDefendantHistory {get; set;}
    public List<Defendant_History__c> newDefHistory {get; set;}
    
    public Attachment attachment {get; set;}
    public String deleteAttachmentId {get; set;}
    
    public List<Application__c> appExisting{get; set;}
    public Boolean hasDraft {get; set;}
    public Id existingApplication {get; set;}
    public String companyName {get; set;}
    public List<ContactWrapper> contactWrapperList {get; set;}
    public String contactId {get; set;}
    public User thisUser {get; set;}
    
    public Boolean summary {get; set;}
    public boolean dispInv{get;set;}
    
    public Integer competitorCount;
    public Integer supplierCount;
    public Integer ecommCount;
    
    public List<Account> nestedAccounts {get; set;}
    public String selectedAccount{get; set;}
    public String selectedAccountName{get; set;}
    
    public List<Account> accountHierarchy {get; set;}    
    
    public static id invReqConId{get;set;}
    public static string InvReqMsg{get;set;}        
    
    public string deletedId {get; set;}
    public string typeOfObjectToDelete {get; set;} 
    
    public class ContactWrapper{
        public Contact con {get; set;}
        public Boolean selected {get; set;}
       // public boolean dispInvite{get;set;}
        
        public ContactWrapper(Contact c) {
            this.con = c;
            this.selected = false;  
            //this.dispInvite = disp;          
        }

    }
    
    public echosign_dev1__SIGN_Agreement__c agreement {get; set;}
                
    public InsuranceApplicationExt(ApexPages.StandardController controller) {        
        
        Apexpages.currentPage().getHeaders().put('p3p', 'CP="CUR OTR STA"');        
        
        summary = false;
        thisApplication = (Application__c)controller.getRecord();         
        shortForm = thisApplication.short_form__c;
        hasDraft=false; 
        newDefHistory = new List<Defendant_History__c>();
        accountHierarchy = new List<Account>();
        InvReqMsg =System.Label.Invite_Request_Submission_Msg;
        
        thisUser = [select id,name,contactId,AccountId,profileid from User where id=:UserInfo.getUserId()];
        if(thisUser.contactId!=null && thisUser.AccountId!=null){
            Account acc = [Select id,Name,BillingStreet,BillingCity,BillingState,
                                 BillingPostalCode,BillingCountry from Account 
                                 where id=:thisUser.AccountId];
            companyName = acc.Name;   
            selectedAccountName = acc.Name; 
            
            /*accountHierarchy.add(new Account(id=thisUser.AccountId,Name=acc.Name));            
            nestedAccounts = [select id,Name from Account where Broker__c=:thisUser.AccountId];
            
            accountMap = new Map<id,String>();
            accountMap.put(thisUser.AccountId,selectedAccountName);
            accountIdList =  new Set<id>();   
            accountIdList.add(thisUser.AccountId);*/
            //fetchNestedAccounts();
            
            accountIdList =  new Set<id>(); 
            accountIdList.add(thisUser.AccountId);
            List<CustomShare__c> cs = [select id,User__c, Account__c from CustomShare__c where User__c=:thisUser.id];

            for(CustomShare__c ctemp:cs){
                  accountIdList.add(ctemp.Account__c);
            }
                                    
            fetchAllApplications();
           
        }
        
         agreement = new echosign_dev1__SIGN_Agreement__c();                          
    }
    
    public PageReference checkId(){
        if(thisApplication.id==null || thisApplication.status__c!='Draft Application'){
          PageReference pg = new PageReference('/apex/InsuranceApplicationStartForm');       
          pg.SetRedirect(true);
          return pg;                 
        }
        else return null;
    } 
    
    public PageReference startNewShortForm(){
        thisApplication.short_form__c=true;
        return startNewApplication();
    }
    
    
    public PageReference startNewApplication(){ 
        displayPopup = false;
        thisApplication.id=null;
        Account acc = [Select id,Name,BillingStreet,BillingCity,BillingState,
                                 BillingPostalCode,BillingCountry from Account 
                                 where id=:thisApplication.Company_name__c];
        if(!thisApplication.short_form__c){
        thisApplication.Company_Address__c = acc.BillingStreet;
        thisApplication.Company_Address_City__c = acc.BillingCity;
        thisApplication.Company_Address_State__c = acc.BillingState;
        thisApplication.Company_Address_Country__c = acc.BillingCountry;
        thisApplication.Company_Address_Zip_Code__c = acc.BillingPostalCode;
        }
        companyName = acc.Name;
               
        insert thisApplication;
        
        System.debug('###AK '+thisApplication.id);
        
        contactList = [select id, firstName, lastName, email, phone,Insurance_App_Contact__c from Contact where AccountId =:thisApplication.Company_name__c and Insurance_App_Contact__c=true];
        contactWrapperList = new List<ContactWrapper>();               
        for(Contact c:contactList){                 
            contactWrapperList.add(new ContactWrapper(c));                          
        }
        
        competitorCompany =  new List<Related_Company__c>();
        supplierCompany =  new List<Related_Company__c>();
        ecommCompany =  new List<Related_Company__c>(); 
        
        for(integer i = 0; i<5;i++){
            competitorCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='Competitor'));
        }
        for(integer i = 0; i<3;i++){
            supplierCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='Supplier or Partner'));
        }
        for(integer i = 0; i<5;i++){
            ecommCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='E-commerce Partner'));
        }
        
        
        financialDetails = new List<Financial_Detail__c>();
        
        Financial_Detail__c tempFinancial = new Financial_Detail__c();        
        tempFinancial.Application__c = thisApplication.id;        
        tempFinancial.Detail_Type__c = 'Gross Revenue';
        tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Key Financial Details').getRecordTypeId();
        financialDetails.add(tempFinancial);
        
        tempFinancial = new Financial_Detail__c();
        tempFinancial.Application__c = thisApplication.id;
        tempFinancial.Detail_Type__c = 'US Revenue';
        tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Key Financial Details').getRecordTypeId();
        financialDetails.add(tempFinancial);
        
        tempFinancial = new Financial_Detail__c();
        tempFinancial.Application__c = thisApplication.id;
        tempFinancial.Detail_Type__c = 'E-Commerce Revenue';
        tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Key Financial Details').getRecordTypeId();        
        financialDetails.add(tempFinancial);
        
        tempFinancial = new Financial_Detail__c();
        tempFinancial.Application__c = thisApplication.id;        
        tempFinancial.Detail_Type__c = 'Operating Income';
        tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Key Financial Details').getRecordTypeId();        
        financialDetails.add(tempFinancial);   
        
        tempFinancial = new Financial_Detail__c();
        tempFinancial.Application__c = thisApplication.id;        
        tempFinancial.Detail_Type__c = 'Cash';
        tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Key Financial Details').getRecordTypeId();        
        financialDetails.add(tempFinancial);
        
        tempFinancial = new Financial_Detail__c();
        tempFinancial.Application__c = thisApplication.id;        
        tempFinancial.Detail_Type__c = 'Headcount';
        tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Key Financial Details').getRecordTypeId();        
        financialDetails.add(tempFinancial);
        
        tempFinancial = new Financial_Detail__c();
        tempFinancial.Application__c = thisApplication.id;        
        tempFinancial.Detail_Type__c = 'Other Revenue';
        tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Key Financial Details').getRecordTypeId();        
        financialDetails.add(tempFinancial);
        
        insert financialDetails;
        
        productRevenue =  new List<Financial_Detail__c>();
        customerRevenue = new List<Financial_Detail__c>();
        funding = new List<Financial_Detail__c>();
        acqAndDivestures =  new List<M_A_History__c>();
        
        for(integer i=productRevenue.size();i<5;i++){
            productRevenue.add(new Financial_Detail__c(RecordTypeId=Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Product Revenue Details').getRecordTypeId()
                            ,Application__c=thisApplication.id));
        }
        for(integer i=customerRevenue.size();i<5;i++){
            customerRevenue.add(new Financial_Detail__c(RecordTypeId=Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Customer Revenue Details').getRecordTypeId()
                            ,Application__c=thisApplication.id));
        }
                        
        for(integer i=acqAndDivestures .size();i<5;i++){
            acqAndDivestures.add(new M_A_History__c(Application__c=thisApplication.id));            
        }
        
       PageReference pg = new PageReference('/apex/insuranceapplicationform?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;
    }
     
    
    public PageReference existingApplicationCommunity(){
       
       Application__c  app = [select id, Accepted_terms__c, Company_Name__r.Name from Application__c where id=:existingApplication limit 1];
       
       /*if(!app.Accepted_terms__c){
           app.Accepted_terms__c = true;
           update app;
       }*/
       
       companyName = app.Company_Name__r.Name;
                     
       PageReference pg = new PageReference('/apex/insuranceapplicationform?id='+existingApplication);
       
       pg.SetRedirect(true);
       
       return pg;
       
    }
    
    
    public PageReference existingApplication(){
       
       Application__c  app = [select id, Accepted_terms__c, Company_Name__r.Name from Application__c where id=:existingApplication limit 1];
       
       companyName = app.Company_Name__r.Name;
                     
       PageReference pg = new PageReference('/apex/insuranceapplicationform?id='+existingApplication);
       
       pg.SetRedirect(true);
       
       return pg;
       
    }
    
    public PageReference deleteExistingApplication(){       
       Application__c app = new Application__c(id=existingApplication);

       try{
           delete app;
           fetchApplications();
       }
       catch(Exception e){
           
       }
       return null;       
    }   
    
    public List<Related_Company__c> competitorCompany {get; set;}
    public List<Related_Company__c> supplierCompany {get; set;}    
    public List<Related_Company__c> ecommCompany {get; set;}        
    
    public PageReference getContactAndRelatedCompanies(){
        
        if(summary==false && (thisApplication.id==null || thisApplication.status__c!='Draft Application')){
          PageReference pg = new PageReference('/apex/InsuranceApplicationStartForm');       
          pg.SetRedirect(true);
          return pg;                 
        }
        
        competitorCompany =  new List<Related_Company__c>();
        supplierCompany =  new List<Related_Company__c>();
        ecommCompany =  new List<Related_Company__c>();        
        
        contactList = [select id, firstName, lastName, email, phone,Insurance_App_Contact__c from Contact where AccountId =:thisApplication.Company_name__c and Insurance_App_Contact__c=true];
        contactWrapperList = new List<ContactWrapper>();
         
           
        system.debug('@@contactList'+contactList);
      /*INVITE COLLOBORATOR FUNCTIONALITY
        List<user> dispInvUserList = new List<user>();
        dispInvUserList = [select id ,name,email,contactId from user where contactId in:contactList];
        system.debug('@@dispInvUserList'+dispInvUserList);
        set<id> contactIdSet = new set<Id>();
        
        for(Contact c: contactList){   
            if(dispInvUserList.size()>0){   
                for(user u: dispInvUserList ){                  
                    if(c.Id==u.contactId){
                        contactIdSet.add(c.id);
                        system.debug('@@in if');
                        contactWrapperList.add(new ContactWrapper(c,false));
                    }                                                   
                }
            }
            if(!contactIdSet.contains(c.id))
            contactWrapperList.add(new ContactWrapper(c,true));                             
        }*/
        for(Contact c: contactList){
            contactWrapperList.add(new ContactWrapper(c));
        }               
        
        
        relatedCompany = [select id,Related_Account_User_Input__c,Type_Of_Relation__c,Related_Account__c from related_company__c where Application__c=:thisApplication.id];
        for(Related_Company__c relTemp:relatedCompany){
            if(relTemp.Type_Of_Relation__c == 'Competitor'){
                competitorCompany.add(relTemp);
            }
            else if(relTemp.Type_Of_Relation__c == 'Supplier or Partner'){
                supplierCompany .add(relTemp);
            }
            else{
                ecommCompany.add(relTemp);
            }
        }
        
        competitorCount = competitorCompany.size();
        
        if(summary==false){
        for(integer i = competitorCompany.size(); i<5;i++){
            competitorCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='Competitor'));
        }
        for(integer i = supplierCompany.size(); i<3;i++){
            supplierCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='Supplier or Partner'));
        }
        for(integer i = ecommCompany.size(); i<5;i++){
            ecommCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='E-commerce Partner'));
        }
        }
        
        return null;
    }
    
    public void addSupplier(){
        supplierCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='Supplier or Partner'));       
    }
    
    public void addCompetitor(){
        competitorCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='Competitor'));
    }
    public void addEcomm(){
        ecommCompany.add(new related_Company__c(Application__c=thisApplication.id,Type_Of_Relation__c='E-commerce Partner'));        
    }
    
    public PageReference getFinancialDetails(){        
        
        if(summary==false && (thisApplication.id==null || thisApplication.status__c!='Draft Application')){
          PageReference pg = new PageReference('/apex/InsuranceApplicationStartForm');       
          pg.SetRedirect(true);
          return pg;          
        }
        
        financialDetails = [select id,Detail_Type__c,X2011__c,X2012__c,X2013__c,X2014__c,Fiscal_Year_Ended__c,Product_Name__c
                            from Financial_Detail__c where Application__c=:thisApplication.id
                            and RecordType.Name IN ('Key Financial Details')];
        
        
        productRevenue = [select id,Detail_Type__c,X2011__c,X2012__c,X2013__c,X2014__c,X2011_text__c,X2012_text__c,X2013_text__c,X2014_text__c,Fiscal_Year_Ended__c,Product_Name__c 
                            from Financial_Detail__c where Application__c=:thisApplication.id
                            and RecordType.Name IN ('Product Revenue Details')];
        
        
        customerRevenue = [select id,Detail_Type__c,customer__c,X2011__c,X2012__c,X2013__c,X2014__c,X2011_text__c,X2012_text__c,X2013_text__c,X2014_text__c,Fiscal_Year_Ended__c,Product_Name__c 
                            from Financial_Detail__c where Application__c=:thisApplication.id
                            and RecordType.Name IN ('Customer Revenue Details')];

        funding =         [select id,Detail_Type__c,Lead_Investors__c,customer__c,Series_Round__c,Funding_Date__c,Funding_Amount__c,X2011__c,X2012__c,X2013__c,X2014__c,X2011_text__c,X2012_text__c,X2013_text__c,X2014_text__c,Fiscal_Year_Ended__c,Product_Name__c 
                            from Financial_Detail__c where Application__c=:thisApplication.id
                            and RecordType.Name IN ('Material Funding')];

        acqAndDivestures = [select id,name,Entity_Name__c,Divestiture_or_Acquisition__c,Date__c,year__c,Value_of_Deal__c,Brief_Description__c from M_A_History__c where Application__c=:thisApplication.id];
                            
        if(summary==false){                            
        for(integer i=productRevenue.size();i<5;i++){
            productRevenue.add(new Financial_Detail__c(RecordTypeId=Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Product Revenue Details').getRecordTypeId(),Application__c=thisApplication.id));
        }
        for(integer i=customerRevenue.size();i<5;i++){
            customerRevenue.add(new Financial_Detail__c(RecordTypeId=Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Customer Revenue Details').getRecordTypeId(),Application__c=thisApplication.id));
        }
                        
        for(integer i=acqAndDivestures .size();i<5;i++){
            acqAndDivestures.add(new M_A_History__c(Application__c=thisApplication.id));            
        }
        
        }      
        return null;
    }
    
    public PageReference next1(){

        saveApplication();
        
       PageReference pg = new PageReference('/apex/InsuranceApplicationFinancialForm?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;        
    }
    
    public PageReference back1(){
        saveApplication();
        
        PageReference pg = new PageReference('/apex/InsuranceApplicationForm?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;        
    }
    
    public PageReference next2(){
       saveApplication();    
        
       PageReference pg = new PageReference('/apex/InsuranceApplicationAnticipatedFuture?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;
        
    }
    
    public PageReference back2(){
        saveApplication();    
           PageReference pg = new PageReference('/apex/InsuranceApplicationFinancialForm?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;
    }
    
    public PageReference getNPEHistory(){
        
        if(summary==false && (thisApplication.id==null || thisApplication.status__c!='Draft Application')){
          PageReference pg = new PageReference('/apex/InsuranceApplicationStartForm');       
          pg.SetRedirect(true);
          return pg;                 
        }
        
        Account acc = [select id,Entity_Id__c from Account where id=:thisApplication.Company_Name__c];
        
        assertionList = [Select a.Technology_Asserted__c, a.Supplier_seeking_indemnification_from__c, a.Settlement_Details__c, a.Seeking_Indemnification__c, a.Resolved_Date__c, a.Patents__c,a.Parent_Plaintiff__c, a.Name, a.Matter_Name__c, a.License_Resolution__c, a.Legal_Cost__c, a.Last_Contact_Date__c, a.Id, a.First_Contact_Date__c, a.Application__c, a.Amount_of_Indemnification_Paid__c,a.Assertion_status__c,a.Did_you_get_any_Indemnification_requests__c,a.Estimated_to_you__c,a.Estimated_to_Others__c,Comments__c  From Assertion__c a where a.Application__c=:thisApplication.id];
        indemnificationList = [Select a.Technology_Asserted__c, a.Supplier_seeking_indemnification_from__c, a.Settlement_Details__c, a.Seeking_Indemnification__c, a.Resolved_Date__c, a.Patents__c,a.Parent_Plaintiff__c, a.Name, a.Matter_Name__c, a.License_Resolution__c, a.Legal_Cost__c, a.Last_Contact_Date__c, a.Id, a.First_Contact_Date__c, a.Application__c, a.Amount_of_Indemnification_Paid__c,a.Assertion_status__c,a.Did_you_get_any_Indemnification_requests__c,a.Estimated_to_you__c,a.Estimated_to_Others__c,a.Requesting_Party__c From Indemnification_Request__c a where a.Application__c=:thisApplication.id];
        existingDefendantHistory = [select Id,Campaign_Id__c,Case_Name__c,Campaign_Name__c,File_date__c,Resolve_date__c,Parent_Plaintiff__c, Defendant_names__c,Settlement__c,Settlement_Offer__c,Applicant_Law_Firm__c,Status__c,
                                                                Litigation_Expenses__c,Assertion_Letter_Recieved_Prior_to_Suit__c,Date_of_Assertion_letter__c,Indemnification_Recieved__c,Amount_Indemnified_for__c,
                                                                Notes__c,Company__c,Did_you_request_indemnification__c,Did_you_receive_an_Assertion_letter__c,Received_Date__c,Legal_cost_prior_to_litigation__c,Damage_Award__c  
                                                                From Defendant_History__c where Application__c=:thisApplication.id order by File_date__c asc];
        
         if(summary==false && shortForm==false){
         
         List<Defendant_History__c> allCampaignLits = [select Id,Campaign_Id__c,Case_Name__c,Campaign_Name__c,File_date__c,Resolve_date__c,Parent_Plaintiff__c, Defendant_names__c,Settlement__c,Settlement_Offer__c,Applicant_Law_Firm__c,Status__c,
                                                                Litigation_Expenses__c,Assertion_Letter_Recieved_Prior_to_Suit__c,Date_of_Assertion_letter__c,Indemnification_Recieved__c,Amount_Indemnified_for__c,
                                                                Notes__c,Company__c,Did_you_request_indemnification__c,Did_you_receive_an_Assertion_letter__c,Received_Date__c,Legal_cost_prior_to_litigation__c,Damage_Award__c  
                                                                From Defendant_History__c where Account__c=:thisApplication.Company_Name__c order by File_date__c asc];
         
         defHistory = new List<Defendant_History__c>();
            try{                                                                           
                for(Defendant_History__c wrapTemp:allCampaignLits){
                    Boolean campaignExists = false;
                    for(Defendant_History__c defTemp:existingDefendantHistory){
                        if(defTemp.Campaign_Id__c==wrapTemp.Campaign_Id__c){
                            defTemp.campaign_name__c=wrapTemp.campaign_name__c;
                            defTemp.Case_Name__c=wrapTemp.Case_Name__c;
                            defTemp.File_date__c=wrapTemp.File_date__c;
                            defTemp.Resolve_date__c=wrapTemp.Resolve_date__c;
                            defTemp.Parent_Plaintiff__c = wrapTemp.Parent_Plaintiff__c;
                            defTemp.Defendant_names__c = wrapTemp.Defendant_names__c;
                            defHistory.add(defTemp);
                            campaignExists = true;
                        }
                    }
                    if(campaignExists==false){
                    defHistory.add(new Defendant_History__c(
                                        Campaign_Id__c=wrapTemp.Campaign_Id__c,
                                        campaign_name__c=wrapTemp.campaign_name__c,
                                        Case_Name__c=wrapTemp.case_name__c,
                                        File_date__c=wrapTemp.file_date__c,
                                        Resolve_date__c=wrapTemp.resolve_date__c,
                                        Parent_Plaintiff__c = wrapTemp.Parent_Plaintiff__c,
                                        Defendant_names__c = wrapTemp.defendant_names__c,
                                        Application__c = thisApplication.id
                                   ));
                    }
                }
                                
            }
            catch(System.CalloutException e){
                String error = e.getMessage();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
            }
                        
        }                               
        
       for(Defendant_History__c defTemp:existingDefendantHistory){
             if(defTemp.Campaign_id__c==null){  newDefHistory.add(defTemp); }
        }
        
        return null;
    }
            
    public PageReference next3(){ 
        //getNPEHistory();
        saveApplication();   
        PageReference pg = new PageReference('/apex/InsuranceApplicationNPEHistory?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;        
    }
    
    public PageReference next4(){    
              
       saveApplication();    
        
       PageReference pg = new PageReference('/apex/InsuranceApplicationIPPractices?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;
        
       //return Page.InsuranceApplicationIPPractices;    
    }
    
    public PageReference next5(){
        saveApplication();  
        
        PageReference pg = new PageReference('/apex/InsuranceApplicationSummary?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;
          
       // return Page.InsuranceApplicationSummary;
    }
    
    public PageReference next6(){
        
        String errorMsg = '';
        String errorMsgAdditional = '';
        /*String[] fieldNames = {'Company_Website__c','What_Year_was_the_Applicant_founded__c','E_Commerce_capabilities__c','Primary_Contact__c'}
        String[] fieldNames = {'Company Website','Year the Applicant was founded','Has E-Commerce capabilities?','Primary Contact'}
        */
        /*
        Map<String, String> fieldNames = new Map<String, String>{'Company_Website__c' => 'Company Website',
                                                                 'What_Year_was_the_Applicant_founded__c' => 'Year the Applicant was founded',
                                                                 'E_Commerce_capabilities__c' => 'Has E-Commerce capabilities?',
                                                                 'Primary_Contact__c' => 'Primary Contact',
                                                                 'Entity_Type__c' => 'Entity Type',
                                                                 'Is_Company_Publicly_Traded__c' => 'Is Company Publicly Traded?',
                                                                 'Is_Parent_Company_Publicly_Traded__c' => 'Is Parent Company Publicly Traded?',
                                                                 'Fiscal_Year_Ended__c' => 'Fiscal Year Ended',
                                                                 'Any_product_line__c' => 'Does the Applicant have any product lines accounting for >10% of revenue?',
                                                                 'Customers_accounting_for_10_of_revenue__c' => 'Does the Applicant have any customers accounting for >10% of revenue?' ,
                                                                 'Any_acquisitions__c' => 'Has the Applicant completed any acquisitions or divestitures over the last 3 years?',
                                                                 'Applicant_will_raise_capital_in_12mo__c' => 'In the next 12 months does the Applicant intend to raise capital?',
                                                                 'Any_insurance_covering_patent_lits__c' => 'Does the Applicant currently have any insurance covering patent litigation?',
                                                                 'Patent_related_insurance_in_the_past__c' => 'Has the Applicant ever obtained patent related insurance in the past?',
                                                                 'Member_of_any_defensive_buying_orgs__c' => 'Is the Applicant a member of any defensive buying organization(s)'
                                                                };
        
        for(String field:fieldNames.keyset()){
        
            if(thisApplication.get(field)==null){
                errorMsg+='<i>'+fieldNames.get(field)+'</i><br/>';              
            }
        }
        
        if(competitorCount==0){
            errorMsgAdditional+='<i>Please enter atleast one Competitor</i><br/>';
        }
        if(thisApplication.Is_Company_Publicly_Traded__c=='Yes' && (thisApplication.Ticker_Symbol__c==null || thisApplication.Ticker_Symbol__c=='')){
            errorMsgAdditional+='<i>Ticker Symbol</i><br/>';
        }
        if(thisApplication.Is_Parent_Company_Publicly_Traded__c=='Yes' && (thisApplication.Parent_Company_Ticker_Symbol__c==null || thisApplication.Parent_Company_Ticker_Symbol__c=='')){
            errorMsgAdditional+='<i>Parent Company Ticker Symbol</i><br/>';
        }

        if(thisApplication.Applicant_will_raise_capital_in_12mo__c=='Yes'){        
           if(thisApplication.Target_Amount_of_Capital__c==null)
                errorMsgAdditional+='<i>What is the target amount of Capital?</i><br/>';     
            if(thisApplication.What_is_the_source_of_Capital_raising__c==null)
                errorMsgAdditional+='<i>What is the source of capital raising?</i><br/>';
            if(thisApplication.Anticipated_S_1_filling_date__c==null)
                errorMsgAdditional+='<i>What is the anticipated S-1 filing date?</i><br/>';                                    
        }
        
        if(errorMsg.length()>0){
          
          String errorMsgFinal;
          
          errorMsgFinal = '<b>Some required fields have not been filled in.</b><br/>'+errorMsg;
          if(errorMsgAdditional.length()>0)
              errorMsgFinal+='<br/><b>Additional Errors</b><br/>'+errorMsgAdditional;
        
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,errorMsgFinal));  
          return null;
        }
        
        */
           
            
        thisApplication.Status__c = 'Completed Application';
      
        saveApplication();    
        
        displayPopup = false;   
        
        /*-------Adding EchoSign Logic----------*/
        
            agreement.Name = 'Application For ' + ' ' + companyName ;
            PageReference pg;
            
            if(thisUser.ContactId!=null){
                Contact con = [Select Id,Email from Contact where Id =: thisUser.ContactId];
                agreement.echosign_dev1__Recipient__c= con.Id;
                agreement.Application__c = thisApplication.Id;
            
                insert agreement;
                system.debug('#####agreement:'+agreement);
        
               pg = Page.SubmitSuccessfull;
            // add parent id to the parameters for standardcontroller
                pg.getParameters().put('id',thisApplication.Id);
                pg.getParameters().put('agmtId',agreement.Id);
                
            }
            else{
                pg = new PageReference('/apex/InsuranceApplicationStartForm'); 
           }
    
           pg.SetRedirect(true);           
           return pg;
                
    }
    
    public boolean displayPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {        
        displayPopup = true;    
    }
    
    public void addMoreAssertions(){
        assertionList.add(new Assertion__c(Application__c=thisApplication.id));
        if(assertionList!=null && assertionList.size()>0)
            upsert assertionList;        
    }
    
    public void initializeAttachment(){
        attachment = new Attachment();
    
    }
    
    public void addAssertionFile(){
        id parentID = ApexPages.currentPage().getParameters().get('parentId');
        if(parentId!=null && attachment.body!=null){
            attachment.parentId = parentId;
            insert attachment;
            attachment = new Attachment();
        }
        else{
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select a file'));
        }
    }
    
    public void fetchApplications(){
        hasDraft=false;
        appExisting = [select id,name,Status__c,Accepted_Terms__c,CreatedDate,LastModifiedById,LastModifiedBy.Name from Application__c where company_name__c=:thisApplication.Company_Name__c order by CreatedDate desc limit 100];
        for(Application__c appTemp: appExisting){
            if(appTemp.status__c=='Draft Application'){
                hasDraft=true;
            }
        }       
    }
    
    
    
    public PageReference getAllData(){
        if(thisApplication.id==null || thisApplication.status__c!='Draft Application'){
          PageReference pg = new PageReference('/apex/InsuranceApplicationStartForm');       
          pg.SetRedirect(true);
          return pg;                 
        }
    
        summary = true;
        getNPEHistory();
        getFinancialDetails();
        getContactAndRelatedCompanies();
        
        return null;
    }
    
    public PageReference getAllDataForPDF(){        
    
        summary = true;
        getNPEHistory();
        getFinancialDetails();
        getContactAndRelatedCompanies();
        
        return null;
    }

    /* Main Save Method */
    public PageReference saveApplication(){      
        if(contactId!=null && (contactId.length() == 15 || contactId.length() == 18))
            thisApplication.Primary_Contact__c = contactId;  
        update thisApplication;
        
        List<Financial_Detail__c> listFinance = new List<Financial_Detail__c>();
        List<Financial_Detail__c> listFinanceDelete = new List<Financial_Detail__c>();        
        
        if(financialDetails!=null && financialDetails.size()>0){              
            listFinance.addAll(financialDetails);
        }
        if(productRevenue!=null && productRevenue.size()>0){
            for(integer i=0;i<productRevenue.size();i++){
                if((productRevenue[i].Product_Name__c!=null && productRevenue[i].Product_Name__c.length()>0) || 
                   (productRevenue[i].X2011_Text__c!=null && productRevenue[i].X2011_Text__c.length()>0) || 
                   (productRevenue[i].X2012_Text__c!=null && productRevenue[i].X2012_Text__c.length()>0) || 
                   (productRevenue[i].X2013_Text__c!=null && productRevenue[i].X2013_Text__c.length()>0) ||
                   (productRevenue[i].X2014_Text__c!=null && productRevenue[i].X2014_Text__c.length()>0))
                    listFinance.add(productRevenue[i]);
                 
                 if(productRevenue[i].id!=null &&
                    (productRevenue[i].Product_Name__c==null || productRevenue[i].Product_Name__c.length()==0) &&
                    (productRevenue[i].X2011_Text__c==null || productRevenue[i].X2011_Text__c.length()==0) &&
                    (productRevenue[i].X2012_Text__c==null || productRevenue[i].X2012_Text__c.length()==0) && 
                    (productRevenue[i].X2013_Text__c==null || productRevenue[i].X2013_Text__c.length()==0) &&
                    (productRevenue[i].X2014_Text__c==null || productRevenue[i].X2014_Text__c.length()==0))
                    listFinanceDelete.add(productRevenue[i]);
            }            
        }
        if(customerRevenue!=null && customerRevenue.size()>0){    
            for(integer i=0;i<customerRevenue.size();i++){
                if((customerRevenue[i].Customer__c!=null && customerRevenue[i].Customer__c.length()>0) || 
                   (customerRevenue[i].X2011_Text__c!=null && customerRevenue[i].X2011_Text__c.length()>0) || 
                   (customerRevenue[i].X2012_Text__c!=null && customerRevenue[i].X2012_Text__c.length()>0) || 
                   (customerRevenue[i].X2013_Text__c!=null && customerRevenue[i].X2013_Text__c.length()>0) ||
                   (customerRevenue[i].X2014_Text__c!=null && customerRevenue[i].X2014_Text__c.length()>0))
                    listFinance.add(customerRevenue[i]);
                    
                if(customerRevenue[i].id!=null &&
                   (customerRevenue[i].Customer__c==null || customerRevenue[i].Customer__c.length()==0) && 
                   (customerRevenue[i].X2011_Text__c==null || customerRevenue[i].X2011_Text__c.length()==0) &&
                   (customerRevenue[i].X2012_Text__c==null || customerRevenue[i].X2012_Text__c.length()==0) && 
                   (customerRevenue[i].X2013_Text__c==null || customerRevenue[i].X2013_Text__c.length()==0) &&
                   (customerRevenue[i].X2014_Text__c==null || customerRevenue[i].X2014_Text__c.length()==0))
                    listFinanceDelete.add(customerRevenue[i]);                    
            }              
        }

         if(funding!=null && funding.size()>0){    
            for(integer i=0;i<funding.size();i++){
                if((funding[i].Series_Round__c!=null && funding[i].Series_Round__c.length()>0) || 
                   (funding[i].Funding_Amount__c!=null) || 
                   (funding[i].Lead_Investors__c!=null && funding[i].Lead_Investors__c.length()>0))
                    listFinance.add(funding[i]);
                
                if(funding[i].id!=null &&
                   (funding[i].Series_Round__c==null || funding[i].Series_Round__c.length()>0) && 
                   (funding[i].Funding_Amount__c==null) && 
                   (funding[i].Lead_Investors__c==null || funding[i].Lead_Investors__c.length()>0))
                    listFinanceDelete.add(funding[i]);
                
            }              
        }

        
        
        if(listFinance.size()>0)
            upsert listFinance;
        
        List<M_A_History__c> MAHistory =  new List<M_A_History__c>();
        List<M_A_History__c> MAHistoryDelete =  new List<M_A_History__c>();        
        
        if(acqAndDivestures!=null && acqAndDivestures.size()>0){    
            for(integer i=0;i<acqAndDivestures.size();i++){
                if((acqAndDivestures[i].Entity_Name__c!=null && acqAndDivestures[i].Entity_Name__c.length()>0) || 
                   (acqAndDivestures[i].Year__c !=null && acqAndDivestures[i].Year__c.length()>0) || 
                   (acqAndDivestures[i].Value_of_Deal__c!=null) ||
                   (acqAndDivestures[i].Brief_Description__c!=null && acqAndDivestures[i].Brief_Description__c.length()>0))
                    MAHistory.add(acqAndDivestures[i]);
                    
                if(acqAndDivestures[i].id!=null &&
                   (acqAndDivestures[i].Entity_Name__c==null || acqAndDivestures[i].Entity_Name__c.length()==0) &&
                   (acqAndDivestures[i].Year__c==null || acqAndDivestures[i].Year__c.length()==0) &&
                   (acqAndDivestures[i].Value_of_Deal__c==null) &&
                   (acqAndDivestures[i].Brief_Description__c==null || acqAndDivestures[i].Brief_Description__c.length()==0))
                    MAHistoryDelete.add(acqAndDivestures[i]);                    
            }              
        }
        upsert MAHistory;
        
        
        List<Related_Company__c> listRel = new List<Related_Company__c>();
        List<Related_Company__c> listRelDelete = new List<Related_Company__c>();

        if(competitorCompany!=null && competitorCompany.size()>0){

            for(integer i=0;i<competitorCompany.size();i++){
                if(competitorCompany[i].Related_Account_User_Input__c!=null && competitorCompany[i].Related_Account_User_Input__c.length()>0)
                    listRel.add(competitorCompany[i]);
                if((competitorCompany[i].Related_Account_User_Input__c==null || competitorCompany[i].Related_Account_User_Input__c.length()==0)&&competitorCompany[i].id!=null)
                    listRelDelete.add(competitorCompany[i]);
                    
            }
        }
        if(supplierCompany!=null && supplierCompany.size()>0){
        for(integer i=0;i<supplierCompany.size();i++){
                if(supplierCompany[i].Related_Account_User_Input__c!=null && supplierCompany[i].Related_Account_User_Input__c.length()>0)
                    listRel.add(supplierCompany[i]);
                if((supplierCompany[i].Related_Account_User_Input__c==null || supplierCompany[i].Related_Account_User_Input__c.length()==0) && supplierCompany[i].id!=null)
                    listRelDelete.add(supplierCompany[i]);                    
            }
        }
        
        if(ecommCompany!=null && ecommCompany.size()>0){
            for(integer i=0;i<ecommCompany.size();i++){
                if(ecommCompany[i].Related_Account_User_Input__c!=null && ecommCompany[i].Related_Account_User_Input__c.length()>0)
                    listRel.add(ecommCompany[i]);
                if((ecommCompany[i].Related_Account_User_Input__c==null || ecommCompany[i].Related_Account_User_Input__c.length()==0) && ecommCompany[i].id!=null)
                    listRelDelete.add(ecommCompany[i]);                         
            }
        }
                
       if(listRel.size()>0)
           upsert listRel;
            
       if(assertionList!=null && assertionList.size()>0)
           upsert assertionList;

         if(defHistory!=null && defHistory.size()>0){           
           upsert defHistory;  
         }

         if(newDefHistory!=null && newDefHistory.size()>0){
           upsert newDefHistory;        
         }  

         if(indemnificationList!=null && indemnificationList.size()>0)
           upsert indemnificationList;             
           
           
        
       if(listRelDelete!=null && listRelDelete.size()>0)
           delete listRelDelete;
       
       if(listFinanceDelete!=null && listFinanceDelete.size()>0)
           delete listFinanceDelete;
       
       if(MAHistoryDelete!=null && MAHistoryDelete.size()>0)
           delete MAHistoryDelete;
           
           
       getContactAndRelatedCompanies();
       newDefHistory = new List<Defendant_History__c>();
       getNPEHistory();
       
       PageReference pg = new PageReference(Apexpages.currentPage().getUrl());
       pg.SetRedirect(false);
       
       return null;
    }
    
  
    
    public Contact con {get; set;}
    public boolean newContactFlag = false;
    public void addNewContact(){
        if(!newContactFlag){
            con = new Contact(AccountId=thisApplication.Company_name__c,Insurance_App_Contact__c=true);
            contactWrapperList.add(new ContactWrapper(con));
            newContactFlag = true;
        }
    }
    
    public void saveContact(){
        insert con;
        newContactFlag = false;
    }
    
    public void cancelNewContact(){
        for(integer i=0;i<contactWrapperList.size();i++){
            if(contactWrapperList[i].con.id==null){
                contactWrapperList.remove(i);
                newContactFlag = false;
            }
        }
    }
    
    public PageReference cloneApplication(){
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get('Application__C').getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        String selects = '';
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        
        
        Application__c app = database.query('select '+selects+' from Application__c where id=\''+existingApplication+'\'');
        
        Application__c newApp = app.clone(false,true);
        newApp.status__c = 'Draft Application';
        insert newApp;
        
        List<Related_Company__c> relComp = [select id,Related_Account_User_Input__c,Type_Of_Relation__c,Related_Account__c from related_company__c where Application__c=:existingApplication];
        List<Related_Company__c> relCompNew = new List<Related_Company__c>();
        
        for(Related_Company__c relTemp: relComp){
            Related_Company__c localRel = relTemp.clone(false,true);
            localRel.Application__c = newApp.id;
            relCompNew.add(localRel);
        }
        
        insert relCompNew;
        
        List<Financial_Detail__c> existingFin = [select id,Detail_Type__c,Lead_Investors__c,X2011__c,X2012__c,X2013__c,X2014__c,X2011_text__c,X2012_text__c,X2013_text__c,X2014_text__c,Fiscal_Year_Ended__c,Product_Name__c 
                                                 from Financial_Detail__c where Application__c=:existingApplication];
        List<Financial_Detail__c> newFinDetails = new List<Financial_Detail__c>();
        
        for(Financial_Detail__c finTemp: existingFin){
            Financial_Detail__c localFin = finTemp.clone(false,true);
            localFin.Application__c = newApp.id;
            newFinDetails.add(localFin);
        }
        insert newFinDetails;
        
        List<M_A_History__c> maExisting = [select id,name,Entity_Name__c,Divestiture_or_Acquisition__c,Date__c,Value_of_Deal__c,Brief_Description__c 
                                            from M_A_History__c where Application__c=:existingApplication];
        List<M_A_History__c> newMHistory = new List<M_A_History__c>();
        
        for(M_A_History__c histTemp:maExisting ){
            M_A_History__c localHist = histTemp.clone(false,true);
            localHist.Application__c = newApp.id;
            newMHistory.add(localHist);
        }
        
        insert newMHistory;
        
        List<Assertion__c> assertionExisting = [Select Technology_Asserted__c, Supplier_seeking_indemnification_from__c, Settlement_Details__c,
                                                Seeking_Indemnification__c, Resolved_Date__c, Patents__c, Parent_Plaintiff__c, Name, Matter_Name__c, 
                                                License_Resolution__c, Legal_Cost__c, Last_Contact_Date__c, Id, First_Contact_Date__c, Application__c, 
                                                Amount_of_Indemnification_Paid__c,Comments__c,Did_you_get_any_Indemnification_requests__c,Estimated_to_Others__c,
                                                Estimated_to_you__c,Assertion_Status__c  From Assertion__c a where Application__c=:existingApplication];
        List<Assertion__c> newAssertion = new List<Assertion__c>();
        
        for(Assertion__c assertTemp:assertionExisting ){
            Assertion__C localAssert = assertTemp.clone(false,true);
            localAssert.Application__c = newApp.id;
            newAssertion.add(localAssert);
        }
        
        insert newAssertion;
        
        List<Defendant_History__c> existingDefendant = [select Id,Campaign_Id__c,Case_Name__c,File_date__c,Resolve_date__c,Parent_Plaintiff__c,Defendant_names__c ,Settlement__c,Settlement_Offer__c,Applicant_Law_Firm__c,Status__c,
                                                                Litigation_Expenses__c,Assertion_Letter_Recieved_Prior_to_Suit__c,Date_of_Assertion_letter__c,Indemnification_Recieved__c,Amount_Indemnified_for__c,Notes__c,
                                                                Company__c,Did_you_request_indemnification__c,Did_you_receive_an_Assertion_letter__c,Received_Date__c,Legal_cost_prior_to_litigation__c,Damage_Award__c  
                                                                From Defendant_History__c where Application__c=:existingApplication];
        List<Defendant_History__c> newDefendantList = new List<Defendant_History__c>();
        
        for(Defendant_History__c defTemp:existingDefendant){
            Defendant_History__c localDef = defTemp.clone(false,true);
            localDef.Application__c = newApp.id;
            newDefendantList.add(localDef);
        }
        
        insert newDefendantList;
                
        PageReference pg = new PageReference('/apex/insuranceapplicationform?id='+newApp.id);
       
        pg.SetRedirect(true);
       
        return pg;
        
    }
    
    public List<Attachment> getAttachments(){
        id parentID = ApexPages.currentPage().getParameters().get('parentId');
        return [select id,Body,Name from Attachment where ParentId =:parentId];
    
    }
    
    public void deleteAttachment(){
    
        Attachment delAtt = new Attachment(id=deleteAttachmentId);
        try{
            delete delAtt;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    /*public void fetchNestedAccounts(){            
        List<Account> tempList = [select id,name from Account where Broker__c=:selectedAccount];
        if(tempList.size()>0){
            nestedAccounts = tempList;
            accountHierarchy.add(new Account(id=selectedAccount,name=selectedAccountName));    
            
        }
    }
    
    public void fetchApplicationsForAccount(){
        thisApplication.company_name__c = selectedAccount;
        fetchApplications();        
    }
    
    public void goToPreviousLevel(){
        List<Account> tempList = [select id,name from Account where Broker__c=:selectedAccount];
        if(tempList.size()>0){
            nestedAccounts = tempList;
            List<Account> tempAccountHierarchy = new List<Account>();
            for(Account acc:accountHierarchy){
                if(acc.id==selectedAccount){
                    tempAccountHierarchy.add(new Account(id=acc.id,name=acc.name));
                    break;
                }
                else{
                    tempAccountHierarchy.add(new Account(id=acc.id,name=acc.name));
                }
            }
            accountHierarchy = tempAccountHierarchy;
                      
        }
    }
    */
    
    public void addFirstDefHistory(){
        
        if(newDefHistory.size()==0){
            AddNewDefHistory();
        }
    
    }
    
    public void AddNewDefHistory(){
        
        newDefHistory.add(new Defendant_History__c(Application__c=thisApplication.id));
        upsert newDefHistory;
    }
    
    public void firstIndemnification(){
        if(thisApplication.Any_other_indemnification_requests__c=='Yes'){
        if(indemnificationList==null || indemnificationList.size()==0){
            indemnificationList =  new List<Indemnification_request__c>();
            indemnificationList.add(new Indemnification_request__c(Application__c=thisApplication.id));
        }
        }
        saveApplication();
    }
    public void addIndemnification(){                 
            indemnificationList.add(new Indemnification_request__c(Application__c=thisApplication.id));             
            upsert indemnificationList;                        
    }
    
    
    public void firstAssertion(){
        if(thisApplication.Have_you_received_any_assertion_letters__c=='Yes'){
        if(assertionList==null || assertionList.size()==0){
            assertionList =  new List<assertion__c>();
            assertionList.add(new assertion__c(Application__c=thisApplication.id));
        }
        }
        saveApplication();
    }
    
    
    public Map<id,String> accountMap{get; set;}
    public Set<id> accountIdList{get; set;}
    public List<Application__c> allApplications {get; set;}
    
    public void fetchNestedAccounts(){
        Boolean hasMore = false;
        Set<id> tempAccountList = new Set<id>();
        List<Account> tempList = [select id,name from Account where Broker__c in:accountIdList];
        for(Account tempAccount:tempList){
            hasMore = true;
            tempAccountList.add(tempAccount.id);
            accountMap.put(tempAccount.id,tempAccount.name);
        }
        
        if(hasMore) {
            accountIdList = tempAccountList;
            fetchNestedAccounts();            
        }
    }
    
    public void fetchAllApplications(){
    
        allApplications = [select id,Name,CreatedDate,Accepted_Terms__c,Status__c,LastModifiedById,Company_Name__c,Company_Name__r.Name,LastModifiedBy.Name from Application__c where Company_Name__c in:accountIdList];
    }
    
    public void addFirstFunding(){
        if(funding==null)
            funding = new List<Financial_Detail__c>();
    
    
        if(funding.size()==0 && thisApplication.Applicant_raised_any_material_funding__c=='Yes'){      
            Financial_Detail__c tempFinancial = new Financial_Detail__c();        
            tempFinancial.Application__c = thisApplication.id;        
            tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Material Funding').getRecordTypeId();
            funding.add(tempFinancial);
        }
        saveApplication();        
    }
    public void addMoreFunding(){
            if(funding==null)
                funding = new List<Financial_Detail__c>();
                
            Financial_Detail__c tempFinancial = new Financial_Detail__c();        
            tempFinancial.Application__c = thisApplication.id;        
            tempFinancial.RecordTypeId = Schema.SObjectType.Financial_Detail__c.getRecordTypeInfosByName().get('Material Funding').getRecordTypeId();
            funding.add(tempFinancial);
            saveApplication();            
    }
    
    
    public PageReference DeleteNewEntry(){
        saveApplication();       
        sObject sobj;
        if(typeOfObjectToDelete == 'def'){
            sobj = new Defendant_History__c(id=deletedId);
 //           newDefHistory = new List<Defendant_History__c>();
        }
        else if(typeOfObjectToDelete == 'ass'){
            sobj = new Assertion__c(id=deletedId);
//            assertionList = new List<Assertion__c>();
        }
        else if(typeOfObjectToDelete == 'indem'){
            sobj = new Indemnification_Request__c(id=deletedId);
        }
        try {
            delete sobj;
            getNPEHistory();
        }
        catch(Exception e){
            System.debug('####### '+e);
        }
        
        
       PageReference pg = new PageReference('/apex/InsuranceApplicationNPEHistory?id='+thisApplication.id);
       
       pg.SetRedirect(true);
       
       return pg;

        
    }
    
 /* INVITE COLLOBORATOR FUNCTIONALITY
 public pagereference createInviteReq(){
    if(invReqConId!=null && thisApplication.id!=null){
            application__c applicationRec = [select id,Company_Name__c,(select id,contact__c from InviteRequests__r where contact__c =:invReqConId) from application__c where id=:thisApplication.id];
            if(applicationRec.InviteRequests__r.size()==0){
                system.debug('Hi in if of Invite Req@@');
                InviteRequest__c invReq = new InviteRequest__c(Application__c = thisApplication.id,Contact__c=invReqConId,Account__c=applicationRec.Company_Name__c,Status__c='Invite Pending');
                insert invReq;
                InvReqMsg =System.Label.Invite_Request_Submission_Msg;              
            }
            else{
                system.debug('inside else');
                InvReqMsg = system.label.Insurance_Collaborator_Already_Invited_Msg;
            }                        
    }
    return null;
}
*/    
}