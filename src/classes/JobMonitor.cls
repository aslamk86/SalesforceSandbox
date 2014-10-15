/*Class to check the status of the Sync jobs and restart them if required. */

global class JobMonitor implements Schedulable{

global void execute(SchedulableContext SC) {
    
boolean ClaimChartedCompanyChanges = false;
boolean LicenseeChanges = false;
boolean PatentAnnotationChanges = false;
boolean PatentFamilyChanges = false;
boolean PortfolioAnnotationChanges = false;
boolean TechTagChanges = false;
boolean RelevantCompanyChanges = false;

boolean atleastOneRestarted = false;
Integer counter = 0;

CoreAPIAuthentication__c ClaimChartedCompanyChangesSetting = CoreAPIAuthentication__c.getInstance('ClaimChartedCompanyChanges');
CoreAPIAuthentication__c LicenseeChangesSetting = CoreAPIAuthentication__c.getValues('LicenseeChanges');
CoreAPIAuthentication__c PatentAnnotationChangesSetting = CoreAPIAuthentication__c.getValues('PatentAnnotationChanges');
CoreAPIAuthentication__c PatentFamilyChangesSetting = CoreAPIAuthentication__c.getValues('PatentFamilyChanges');
CoreAPIAuthentication__c PortfolioAnnotationChangesSetting = CoreAPIAuthentication__c.getValues('PortfolioAnnotationChanges');
CoreAPIAuthentication__c TechTagChangesSetting = CoreAPIAuthentication__c.getValues('TechTagChanges');
CoreAPIAuthentication__c RelevantCompanyChangesSetting = CoreAPIAuthentication__c.getValues('RelevantCompanyChanges');

List<CronTrigger> syncCronJobs = [SELECT Id, CronExpression, CronJobDetail.Name, CronJobDetail.JobType, OwnerId, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name like 'Sync Engine Change Processor%'];

for(CronTrigger c:syncCronJobs){
  
  if(c.CronJobDetail.Name.contains('ClaimChartedCompanyChanges')){
    ClaimChartedCompanyChanges = true;
  }
  if(c.CronJobDetail.Name.contains('LicenseeChanges')){
    LicenseeChanges = true;
  }
  if(c.CronJobDetail.Name.contains('PatentAnnotationChanges')){
    PatentAnnotationChanges = true;
  }  
  if(c.CronJobDetail.Name.contains('PatentFamilyChanges')){
    PatentFamilyChanges = true;
  }
  if(c.CronJobDetail.Name.contains('PortfolioAnnotationChanges')){
    PortfolioAnnotationChanges = true;
  }
  if(c.CronJobDetail.Name.contains('TechTagChanges')){
    TechTagChanges = true;
  }
  if(c.CronJobDetail.Name.contains('RelevantCompanyChanges')){
    RelevantCompanyChanges = true;
  } 

}


Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

List<String> userAlias = new List<String> {'akamal'};

User user = [select id from User where alias in :userAlias limit 1];
mail.setTargetObjectId(user.id);
mail.setSaveAsActivity(False);    
mail.setSubject('Job Status Alert');

String format = 'MM/dd/yyyy HH:mm:ss';

String msg = 'Job Status at '+System.now().format(format,'America/Los_Angeles')+' <br/><br/><b>Running successfully </b><br/>';


if(ClaimChartedCompanyChanges){    
    msg = msg + ClaimChartedCompanyChangesSetting.Name +' - Last Sync Time : '+ ClaimChartedCompanyChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles')+ '<br/>';
}
if(LicenseeChanges){
    msg = msg + LicenseeChangesSetting.Name +' - Last Sync Time : '+ LicenseeChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}
if(PatentAnnotationChanges){    
    msg = msg + PatentAnnotationChangesSetting.Name +' - Last Sync Time : '+ PatentAnnotationChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}    
if(PatentFamilyChanges){    
    msg = msg + PatentFamilyChangesSetting.Name +' - Last Sync Time : '+ PatentFamilyChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}    
if(PortfolioAnnotationChanges){    
    msg = msg + PortfolioAnnotationChangesSetting.Name +' - Last Sync Time : '+ PortfolioAnnotationChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}
if(TechTagChanges){    
    msg = msg + TechTagChangesSetting.Name +' - Last Sync Time : '+ TechTagChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}    
if(RelevantCompanyChanges){    
    msg = msg + RelevantCompanyChangesSetting.Name +' - Last Sync Time : '+ RelevantCompanyChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles')  + '<br/>';
}    

msg = msg + '<br/><br/><b>Jobs that were restarted : </b><br/>';

Double minutes;

if(!ClaimChartedCompanyChanges){
  minutes = Math.Floor(Double.valueOf((System.now().getTime()  - ClaimChartedCompanyChangesSetting.Last_Sync_Date_Time__c.getTime())/ (1000.0*60.0)));
  if(counter < 5 && minutes > 30){
      counter++;
      SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.ClaimChartedCompanyChanges);
  }
  atleastOneRestarted = true;
  msg = msg + ClaimChartedCompanyChangesSetting.Name +' - Last Sync Time '+ ClaimChartedCompanyChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles')+ '<br/>';
}

if(!LicenseeChanges){
  minutes = Math.Floor(Double.valueOf((System.now().getTime()  - LicenseeChangesSetting.Last_Sync_Date_Time__c.getTime())/ (1000.0*60.0)));
  if(counter < 5 && minutes > 30){
      counter++;
      SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.LicenseeChanges);
    }
  atleastOneRestarted = true;
  msg = msg + LicenseeChangesSetting.Name +' - Last Sync Time : '+ LicenseeChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}

if(!PatentAnnotationChanges){
  minutes = Math.Floor(Double.valueOf((System.now().getTime()  - PatentAnnotationChangesSetting.Last_Sync_Date_Time__c.getTime())/ (1000.0*60.0)));
  if(counter < 5 && minutes > 30){
      counter++;
      SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.PatentAnnotationChanges);
    }
  atleastOneRestarted = true;
  msg = msg + PatentAnnotationChangesSetting.Name +' - Last Sync Time : '+ PatentAnnotationChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}

if(!PatentFamilyChanges){
  minutes = Math.Floor(Double.valueOf((System.now().getTime()  - PatentFamilyChangesSetting.Last_Sync_Date_Time__c.getTime())/ (1000.0*60.0)));
  if(counter < 5 && minutes > 30){
      counter++;
      SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.PatentFamilyChanges);
   }
  atleastOneRestarted = true;
  msg = msg + PatentFamilyChangesSetting.Name +' - Last Sync Time : '+ PatentFamilyChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}


if(!PortfolioAnnotationChanges){
  minutes = Math.Floor(Double.valueOf((System.now().getTime()  - PortfolioAnnotationChangesSetting.Last_Sync_Date_Time__c.getTime())/ (1000.0*60.0)));
  if(counter < 5 && minutes > 30){
      counter++;
      SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.PortfolioAnnotationChanges);
    }
  atleastOneRestarted = true;
  msg = msg + PortfolioAnnotationChangesSetting.Name +' - Last Sync Time : '+ PortfolioAnnotationChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}


if(!TechTagChanges){
  minutes = Math.Floor(Double.valueOf((System.now().getTime()  - TechTagChangesSetting.Last_Sync_Date_Time__c.getTime())/ (1000.0*60.0)));
  if(counter < 5 && minutes > 30){
      counter++;
      SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.TechTagChanges);
  }
  atleastOneRestarted = true;  
  msg = msg + TechTagChangesSetting.Name +' - Last Sync Time : '+ TechTagChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles') + '<br/>';
}

if(!RelevantCompanyChanges){
  //SyncEngineChangeProcessor.startProcessor(CoreAPI.EndpointName.RelevantCompanyChanges);
  msg = msg +' (Not restarted) '+ RelevantCompanyChangesSetting.Name +' - Last Sync Time : '+ RelevantCompanyChangesSetting.Last_Sync_Date_Time__c.format(format,'America/Los_Angeles')  + '<br/>';
}


mail.setHtmlBody(msg);
if(atleastOneRestarted)
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
}

}