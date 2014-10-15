@isTest
public class testUpdateNPE{

public static testMethod void updateNP(){
test.startTest();
Account a1 = new Account(name='testAccnt',recordtypeId=label.AccntProspRecTypeId,entity_id__c=445454335);
insert a1;
Acquisition_Opportunity__c acq1 = new Acquisition_Opportunity__c(name='TestAcq1',Account__c=a1.id);
insert acq1;
Non_Party_Entity__c npe1 = new Non_Party_Entity__c(Account__c=a1.id,Acquisition_Opportunity__c=acq1.id);
insert npe1;
system.debug('@@Account of npe1'+npe1.Account__c);
a1.recordtypeId= label.AccntMemberRecTypeId;
update a1;
delete a1;
test.stopTest();
}

}