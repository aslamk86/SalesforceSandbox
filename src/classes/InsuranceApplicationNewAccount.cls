public class InsuranceApplicationNewAccount {

    public Account newAccount{get; set;}
    public Contact newContact{get; set;}
    
    public boolean saved{get; set;}
    
    public InsuranceApplicationNewAccount (){
        saved = false;
        newAccount = new Account();
        newContact = new Contact();
    }
    
    public PageReference saveDetails() {
        if(Insurance_APP__c.getValues('Default Owner External Account').Default_Owner__c!=null)
        newAccount.ownerId=Insurance_APP__c.getValues('Default Owner External Account').Default_Owner__c;
        insert newAccount;
        newContact.AccountId = newAccount.id;
        newContact.Insurance_App_Contact__c = true;
        insert newContact;
        
        InviteRequest__c inv = new InviteRequest__c(Contact__c=newContact.id,Account__c=newAccount.id);
        insert inv;
        
        saved = true;
        newAccount = new Account();
        newContact = new Contact();
        return null;        
    }
    
}