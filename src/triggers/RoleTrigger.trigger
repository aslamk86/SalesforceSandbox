/*
    Trigger : RoleTrigger 
    Description : If a contact is added in a role, capture the ccontact's account and add this value in the account lookup
    Created By : Bharti (Offshore)
    Last Modified Date :02 Feb 2012
*/
trigger RoleTrigger on Role__c (before insert, before update) {
    
    //if role.Account__c is null then populating this field by role__C.contact.accountid
    Set<Id> contactIDs = new Set<ID>();
    for(Role__c role : Trigger.new){
        if(role.Account__c == null && role.Contact__c != null)
            contactIDs.add(role.Contact__c);
    }
    Map<Id,Contact> mapContacts = new Map<ID,Contact>([select Accountid from contact where id in : contactIDs]);
    for(Role__c role : Trigger.new){
        if(role.Account__c == null && role.Contact__c != null){
            role.Account__c = mapContacts.get(role.Contact__c).Accountid;       
        }
    }
}