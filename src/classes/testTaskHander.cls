/*************************************************************************************************
* Name          :    taskHandler
* Description   :    test Class for TaskHandler associated with Trigger "trigTask";                     
* Author        :    Vamsi Chinnam
Modification Log
----------------
Date             Version    Developer                Comments
---------------------------------------------------------------------------------------------------
08-Jul-2014          1.0     Vamsi Chinnam           Created
****************************************************************************************************/
@isTest
public class testTaskHander{

static Account a = new Account(name='testAccount');
static contact c = new contact(lastname='testContact',Accountid=a.id,title='testContTitle');
static lead l = new lead(lastname='testLead',company='testCompany',title='testLeadTitle');

    public static testMethod void taskHandlerData(){
        test.startTest();
        
            insert a;
            insert c;
            insert l;
            
            task t = new task(subject='test',whoid=c.id,recordtypeid=label.TaskAORRecTypeID);
            insert t;
            
        test.stopTest();
    }

    public static testMethod void taskHandlerData2(){
        test.startTest();
            insert a;
            insert c;
            insert l;
        
            task t = new task(subject='test',whoid=l.id,recordtypeid=label.TaskAORRecTypeID);
            insert t;   
            
            t.whoid=l.id;   
            update t;
            
        test.stopTest();
    }
    
}