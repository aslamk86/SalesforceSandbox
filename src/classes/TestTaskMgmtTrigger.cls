@isTest(SeeAllData=true)
private class TestTaskMgmtTrigger {

//start creating test data
static TestMethod void TriggerUnitTest()
{
	  Account acc1 = TestUtil.createAccount(true);
	  //Insert new Acquisition_Opportunity__c
      //Acquisition_Opportunity__c acq1 = TestUtil.createAcquisitionOpp(acc1.Id, 'Open','Sharmila_Test_Acquisition', false);
      Contact c = new contact();
      c.firstName = 'Try';
      c.LastName = 'taskMgmtTriggerTest';
      c.CurrencyIsoCode = 'USD';
      c.AccountId = acc1.id;
    insert c;
    system.debug('new contact name: '+ c.name);
    system.debug('new contact title: '+ c.title);
      
      lead l = new lead();
      l.firstName = 'Try';
      l.LastName = 'taskMgmtTriggerTest';
      l.Company = 'Test_Portal_Visibility_Company';
     l.CurrencyIsoCode = 'USD';
    insert l;
    system.debug('new lead name: '+ l.name);
    system.debug('new lead title: '+ l.title);
    	
      Task tWithWhoID_c1 = createTask(c.ID, 'Task with Contact1',false);//acq1.id,
      Task tWithWhoID_l1 = createTask(l.ID, 'Task with Lead1',false);
      Task tWithWhoID_l2 = createTask(l.ID, 'Task with Lead2',true);
    
      Test.startTest();
      //testing trigger on insert
      insert tWithWhoID_c1;
      insert tWithWhoID_l1;

      //test update whoid from contact to lead
      tWithWhoID_l2.whoid= c.id;
      update tWithWhoID_l2;

      //do the checks Lead2 and Contact1 should have Contact_name__c and Contact_title__c from the inserted Contact (Name and Title), 
    	 // whereas Lead1 should have Contact_name__c and Contact_title__c from the inserted Lead (Name and Title)
    system.debug('contact ID: '+c.id+',Name: '+c.name+',Title: '+ c.title);
    system.debug('l2 ID: '+tWithWhoID_l2.whoid+',Name: '+tWithWhoID_l2.Contact_name__c+',Title: '+tWithWhoID_l2.Contact_title__c);
    system.debug('c1 ID: '+tWithWhoID_c1.whoid+',Name: '+tWithWhoID_c1.Contact_name__c+',Title: '+tWithWhoID_c1.Contact_title__c);
        
    system.debug('Lead ID: '+l.id+',Name: '+l.name+',Title: '+l.title);
    system.debug('l1 ID: '+tWithWhoID_l1.whoid+',Name: '+tWithWhoID_l1.contact_name__c+',Title: '+ tWithWhoID_l1.contact_title__c);
        
    system.assertEquals(tWithWhoID_l2.whoid,c.id);
    system.assertEquals(tWithWhoID_l2.contact_name__c,c.name);
    system.assertEquals(tWithWhoID_l2.contact_title__c,c.title);
    system.assertEquals(tWithWhoID_c1.WhoId,c.id);
    system.assertEquals(tWithWhoID_c1.contact_name__c,c.name);
    system.assertEquals(tWithWhoID_c1.contact_title__c,c.title);
    system.assertEquals(tWithWhoID_l1.WhoId,l.id);
    system.assertEquals(tWithWhoID_l1.contact_name__c,l.name);
    system.assertEquals(tWithWhoID_l1.contact_title__c,l.title);
    
      Test.stopTest();

}

 static Task createTask(id ContactID, string TaskSubject, boolean isInsert)//id acqID,
 {
        Task task = new Task();
        task.Whoid = ContactID;
       // task.whatid = acqID;
        task.OwnerId = UserInfo.getUserId();
        task.Subject = TaskSubject;
        if(isInsert)
            insert task;
        return task;
    }


}