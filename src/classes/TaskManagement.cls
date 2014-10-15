public without sharing class TaskManagement {

public static void beforeInsertUpdate(list<task> newMap) {
            for (task ttu:newmap)
            {
                contact[] c = [select id, name, title from contact where id = :ttu.WhoId];
                lead[] l = [select id, name, title from lead where id = :ttu.WhoId];
                
                If (!c.isEmpty())
                {   
                    ttu.Contact_Name__c = c[0].Name ;
                    	ttu.Contact_Title__c = c[0].Title;
                    system.debug('Assigned lead name and title to Task WhoID');
                }
                else if (!l.isEmpty())
                {  ttu.Contact_Name__c = l[0].Name;
                    ttu.Contact_Title__c = l[0].Title;
                    system.debug('Assigned lead name and title to Task WhoID');
                }
            }//for every new value
    }//updateTaskContactNameTitle
}// TaskManagement