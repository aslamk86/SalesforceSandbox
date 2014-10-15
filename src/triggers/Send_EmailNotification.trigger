/******************************************************************************************
 * Name             : Send_EmailNotification 
 * Created By       : Sreenivasulu Binkam
 * Created Date     : 4/17/2014 12:41 AM
 * Purpose          : Alert to Sector Representative on Non-Party entity creation-  CRM 168
 ******************************************************************************************/

trigger Send_EmailNotification on Non_Party_Entity__c (after insert) {
    
    EmailTemplate et=[Select id from EmailTemplate where name='New NPE Email Notification'];
    Messaging.SingleEmailMessage[] msgList = new List<Messaging.SingleEmailMessage>();
        
    Map<Id,Id> acqIdsMap = new Map<Id,Id>();
    
    for(Non_Party_Entity__c npe: Trigger.new){
        if(npe.Acquisition_Opportunity__c!=null)
            acqIdsMap.put(npe.id,npe.Acquisition_Opportunity__c);
    }
    
    Map<id,Acquisition_Opportunity__c> acqRecordMap = new Map<id,Acquisition_Opportunity__c>([select id,Sector_Representative__c from Acquisition_Opportunity__c where id in: acqIdsMap.values()]);

    for(id npe:acqIdsMap.keySet()){
        
        if(acqRecordMap.get(acqIdsMap.get(npe)).Sector_Representative__c!=null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(acqRecordMap.get(acqIdsMap.get(npe)).Sector_Representative__c);
            mail.setSenderDisplayName('Salesforce Support Team');
            mail.setSaveAsActivity(false);
            mail.setTemplateId(et.id);
            mail.setWhatId(npe);
            msgList.add(mail);        
        }
    
    }
    
    Messaging.sendEmail(msgList);
    
    /*Map<Id,Id> accountIds = new Map<Id,Id>();
    Messaging.SingleEmailMessage[] msgList = new List<Messaging.SingleEmailMessage>();
    for(Non_Party_Entity__c npe: Trigger.new){
        if(npe.Acquisition_Opportunity__c!=null)
            accountIds.put(npe.id,npe.account__c);
    }
    
    Map<Id,Account> accountList = new Map<id,Account>([select ID,Name,Sector_Representative__c,Sector_Representative__r.Name from Account where id in:accountIds.values()]);
        
    for(id npe:accountIds.keySet()){
        if(accountList.get(accountIds.get(npe)).Sector_Representative__c!=null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(accountList.get(accountIds.get(npe)).Sector_Representative__c);
            mail.setSenderDisplayName('Salesforce Support Team');
            mail.setSaveAsActivity(false);
            mail.setTemplateId(et.id);
            mail.setWhatId(npe);
            msgList.add(mail);
        }
    }
    Messaging.sendEmail(msgList);
    */
}