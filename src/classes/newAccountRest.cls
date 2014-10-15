@RestResource(urlMapping='/NewAccount/*')
global with sharing class newAccountRest {
    
    global class Result {
        global String status{get;set;}
    }
    
    
    @HttpPost
    global static Result doPost(String company_name,String first_name, String last_name, String email, String phone, String user_type, String application_type) {
          
        Account newAccount = new Account(name=company_name);
        Contact newContact = new Contact(firstname=first_name,lastname=last_name,email=email,phone=phone);
        
        if(Insurance_APP__c.getValues('Default Owner External Account').Default_Owner__c!=null){
            newAccount.ownerId=Insurance_APP__c.getValues('Default Owner External Account').Default_Owner__c;
            newContact.ownerId=Insurance_APP__c.getValues('Default Owner External Account').Default_Owner__c;
            }
            insert newAccount;
            newContact.AccountId = newAccount.id;
            newContact.Insurance_App_Contact__c = true;
            insert newContact;
            
            Application__c thisApplication = new Application__c(Company_Name__c = newAccount.id,Short_Form__c=true);
            insert thisApplication;
            
            
             
        List<Financial_Detail__c> financialDetails = new List<Financial_Detail__c>();
        
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
            
            
            //InviteRequest__c inv = new InviteRequest__c(Contact__c=newContact.id,Account__c=newAccount.id);
            //insert inv;
            
            Result r = new Result();
            r.status= newContact.id;
            return r; 
        
    }

}