@IsTest
public class testNonPartyEntityHandler{
public static id MembRType;
public static id ProsRtype;
public static id OtherRtype;
public static List<Recordtype> RTypeList;
public static Account a1;
public static Account a2;
public static Account a3;
public static Acquisition_Opportunity__c acq1;
public static Acquisition_Opportunity__c acq2;
    Public static void createData(){
        RTypeList= [select name,id from RecordType where sObjectType='Account'];
        for(Recordtype r:RTypeList){
            if(r.Name=='Member'){
                MembRType = r.id;
            }
            else if(r.Name=='Prospect'){
                ProsRtype = r.id;
            }
            else{
                OtherRtype = r.id;
            }   }
            a1 = new Account(name='TestAccnt',Entity_ID__c=12345,recordtypeid=MembRType);
            insert a1;

            a2 = new Account(name='TestAccnt',Entity_ID__c=123456,recordtypeid=ProsRtype);
            insert a2;

            a3 = new Account(name='TestAccnt',Entity_ID__c=1234567,recordtypeid=OtherRtype);
            insert a3;
            
            acq1 = new Acquisition_Opportunity__c(name='TestAcq1',Account__c=a1.id);
            insert acq1;
            
            acq2 = new Acquisition_Opportunity__c(name='TestAcq2',Account__c=a2.id);
            insert acq2;
    }
    public  static testMethod void NPEHandlerMethod(){
        createData();        
       test.startTest();
        Non_Party_Entity__c npe1 = new Non_Party_Entity__c(Account__c=a1.id,Acquisition_Opportunity__c=acq1.id);
        insert npe1;
        
        npe1.Acquisition_Opportunity__c = acq2.id;
        update npe1;
        
        npe1.Account__c = a2.id;
        update npe1;        
        
        npe1.Account__c = a3.id;
        update npe1;
        
        delete npe1;  
        test.stopTest();          
    }
    
   /*  public  static testMethod void NPEHandlerMethod2(){
        createData();        
       
        Non_Party_Entity__c npe1 = new Non_Party_Entity__c(Account__c=a1.id,Acquisition_Opportunity__c=acq1.id);
        insert npe1;
        List<Non_Party_Entity__c>npeList = new List<Non_Party_Entity__c>();
        NonPartyEntityHandler nph = new NonPartyEntityHandler();
        nph.IsDummyUpdate ='ON';
        nph.UpdateCountOnAcquisition(npeList,npeList);
                            
    } */
    
   

}