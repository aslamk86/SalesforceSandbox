@isTest(seealldata =true)
public class TestSchedule_CreateCommUsers{

    static testmethod void TestSched_createCommUsers(){
         User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
         system.runas(thisUser){
             schedule_CreateCommUsers cc = new schedule_CreateCommUsers();
                String sch = '0 34 10 19 9 ?';
                system.schedule('Test One Time Pro', sch, cc);
         }
    }
    
}