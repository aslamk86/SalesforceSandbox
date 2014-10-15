public class CustomSharingController {
    
    public String searchString{get; set;}
    
    public List<CustomShare__c> csList {get; set;}
    public List<CustomShare__c> csSearchList {get; set;}
    
    public CustomShare__c cs{get; set;}
    public CustomShare__c cs2{get; set;}
    public boolean noResult{get;set;}
    public CustomSharingController(){
        cs=new CustomShare__c();  
        cs2=new CustomShare__c(); 
        csSearchList = new List<CustomShare__c>();  
        noResult =true;    
        queryRecords();
    }
    
    public void assignPermission(){
        insert cs;
        cs=new CustomShare__c();
        queryRecords();        
    }
    
    public void filterCustShare(){
        try{
         csSearchList = new List<CustomShare__c>();
         system.debug('@@cs.user__c'+cs2.user__c);
         system.debug('@@cs.account__c'+cs2.account__c);
         if(cs2.user__c!=null)
         csSearchList = [select id,User__c,User__r.Firstname,User__r.LastName,Account__c,Account__r.Name from CustomShare__c where user__c=:cs2.user__c and account__c=:cs2.account__c];
         if(cs2.user__c==null)
         csSearchList = [select id,User__c,User__r.Firstname,User__r.LastName,Account__c,Account__r.Name from CustomShare__c where account__c=:cs2.account__c];
         if(csSearchList.size()<=0)
         noResult =true;
         else
         noResult=false;
         }
         catch(exception e){
             system.debug('@@ in excpetion'+e.getMessage());
         }
    }
    
    public void queryRecords(){
//        if(searchString==null)    
            csList = [select id,User__c,User__r.Firstname,User__r.LAstName,Account__c,Account__r.Name from CustomShare__c order by createdDate desc limit 50];
/*        else{
            String param='%'+searchString+'%';
            csList = [select id,User__c,User__r.Firstname,User__r.LastName,Account__c,Account__r.Name from CustomShare__c 
                      where User__r.Firstname like :param order by createdDate limit 50];
        } */
    }
    
}