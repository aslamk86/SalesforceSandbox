/*************************************************************************************************
* Name          :    taskHandler
* Description   :    Handler for Trigger "trigTask";
                     Used to copy the title field from associated name object onto task object
* Author        :    Vamsi Chinnam

Modification Log
----------------
Date             Version    Developer                Comments
---------------------------------------------------------------------------------------------------
07-Jul-2014          1.0     Vamsi Chinnam           Created
****************************************************************************************************/

public class taskHandler{

    //Declaring Variables
    public static boolean firstRun = true;
    public static boolean isContObj=false;
    public static boolean isLeadObj=false;    
    public static set<id> idSet = new set<id>();
    public static Map<id,string> taskTitleMap = new Map<id,string>();
    
    /*********************************************
    **** Method name  : updateTitleOnTask
    **** Description  : Copies the title from Contact/Lead Object and updates onto Task
    **** Return Type  : void
    **** Parameter    : List<task>
    *********************************************/
    public static void updateTitleOnTask(List<task>taskList){
    
        for(task t:taskList){
            if(t.whoid!=null)
            idSet.add(t.whoid);
            
            if(string.valueOf(t.whoid).substring(0,3)=='003'){
                isContObj=true;
            }
            if(string.valueOf(t.whoid).substring(0,3)=='00Q'){
                isLeadObj=true;
            }
        }
        if(isContObj==true){
            List<contact> contactList= returnObjList('contact',idset);
            system.debug('@@contactList'+contactList);
            for(task t:taskList){
                for(contact c: contactList){
                    if(t.whoid==c.id){
                        system.debug('@@in if'+c.title);
                        taskTitleMap.put(t.id,c.title);
                    }
                }
            }
        }
        if(isLeadObj==true){
            List<lead>leadList = returnObjList('lead',idset);
            for(task t:taskList){
                for(lead l: leadList){
                    if(t.whoid==l.id)
                    taskTitleMap.put(t.id,l.title);
                }
            }
        }
        
        list<task> newTaskList = new list<task>();
        newTaskList = [select id,title__c from task where id in:taskList];
        system.debug('@@newTaskList'+newTaskList );
        for(task t: newTaskList){
            system.debug('@@taskTitleMap'+taskTitleMap);
            t.Title__c= taskTitleMap.get(t.id);
        }
        system.debug('@@newTaskList'+newTaskList );
        if(newTaskList.size()>0){      
           system.debug('@@'+newTaskList);
           update newTaskList;
        }
                
    }
    /*********************************************
    **** Method name  : returnObjList
    **** Description  : returns the list of Contact/Lead Objects
    **** Return Type  : List<sObject>
    **** Parameter    : string,Set<id>
    *********************************************/
    public static List<sObject> returnObjList(string Obj,set<id> convertedIds){
        system.debug('@@'+Obj);
        /*string convertedIds =inClausify(objidSet);*/
        string query ='select id,title from '+Obj+' where Id IN:convertedIds'; 
        system.debug('@@query '+query); 
        return database.query(query); 
    }   
}