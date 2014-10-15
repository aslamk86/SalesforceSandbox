public without sharing class IncidentReportWebController {

    public IncidentReportWebController(){

    }

    public IncidentReportWebController(ApexPages.StandardController controller) {
        report = (Claims__Incident_Report__c)controller.getRecord();             
    }

    
    public Claims__Incident_Report__c report {get; set;}

    public Attachment file {get; set;}

    public List<String> fileNames {get;set;}
    
    public String type {get; set;}
  
    
    public PageReference checkAndRedirect(){
       if(report==null || report.Incident_or_Event_Notification__c==null){
            PageReference newPage = new PageReference('/apex/IncidentReportWebEntryIncidentType');
            newPage.setRedirect(true);
            return newPage;    
       }
       else{
            if(report.Incident_or_Event_Notification__c=='Complaint')
                type='A';
            else if(report.Incident_or_Event_Notification__c=='Assertion Letter' ||
                    report.Incident_or_Event_Notification__c=='Indemnification Demand' ||
                    report.Incident_or_Event_Notification__c=='Solicitation')
                type='B';
            else type='C';
            file = new Attachment();
            fileNames = new List<String>();
       }
       return null;
    }

    public PageReference save()
    {
        report.Claims__Report_Completed_By__c = report.Claims__First_Name__c + ' ' + report.Claims__Last_Name__c;
        report.Claims__IncidentLocation__c = 'United States of America';
        insert report;      
        return Page.IncidentReportAttachFiles;
    }

    public PageReference addAttachment()
    {
        if(report.id==null)
            return Page.IncidentReportWebEntryIncidentType;
        if(file.name!=null && file.body!=null){
            file.ParentId = report.Id;
            insert file;
            fileNames.add(file.Name);
            file = new Attachment();
        }
        return null;
    }

    public PageReference finish()
    {
        return Page.IncidentReportFinish;
    }
    
    public PageReference next(){
        return Page.IncidentReportWebEntry;
    }
}