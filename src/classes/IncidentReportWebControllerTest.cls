@isTest
public with sharing class IncidentReportWebControllerTest 
{
 

    @isTest
    private static void testSaveIncidentReport()
    {
        //Instantiate a new controller
        PageReference pageRef = Page.IncidentReportWebEntryIncidentType;
        Test.setCurrentPage(pageRef);
        Claims__Incident_Report__c newClaim = new Claims__Incident_Report__c();
        //Assert that it has a new non-null incident report instance for use
        ApexPages.StandardController sc = new ApexPages.standardController(newClaim);
        IncidentReportWebController controller = new IncidentReportWebController(sc);
        controller.checkAndRedirect();
        System.AssertNotEquals(null, controller.report, 'Report should be non-null');

        //Set some values on the report
        controller.report.Claims__First_Name__c = 'Mickey';
        controller.report.Claims__Last_Name__c = 'Mouse';
        controller.report.Claims__Email__c = 'mmouse@test.com';
        controller.report.Claims__IncidentDate__c = Date.today();
        controller.report.Claims__IncidentLocation__c = 'California';
        controller.report.Claims__Date_Reported__c = Date.today();
        controller.report.Claims__Report_Completion_Date__c = Date.today();
        controller.report.Claims__Report_Completed_By__c = 'Minnie Mouse';
        controller.report.contact_address__c = 'California';

        //Save and assert not null
        System.assert(controller.save() != null);

    }

    @isTest
    private static void testAttachFile()
    {
        //Instantiate a new controller
        Claims__Incident_Report__c newClaim = new Claims__Incident_Report__c();
        //Assert that it has a new non-null incident report instance for use
        ApexPages.StandardController sc = new ApexPages.standardController(newClaim);
        IncidentReportWebController controller = new IncidentReportWebController(sc);
        controller.report.Incident_or_Event_Notification__c = 'Complaint';
        controller.checkAndRedirect();
        
        //Set some values on the report
        controller.report.Claims__First_Name__c = 'Mickey';
        controller.report.Claims__Last_Name__c = 'Mouse';
        controller.report.Claims__Email__c = 'mmouse@test.com';
        controller.report.Claims__IncidentDate__c = Date.today();
        controller.report.Claims__IncidentLocation__c = 'California';
        controller.report.Claims__Date_Reported__c = Date.today();
        controller.report.Claims__Report_Completion_Date__c = Date.today();
        controller.report.Claims__Report_Completed_By__c = 'Minnie Mouse';
        controller.report.contact_address__c = 'California';

        //Save and assert not null
        System.assert(controller.save() != null);

        //Set an attachment for addition
        controller.file.Body = Blob.valueOf('Mickey Mouse');
        controller.file.Name = 'Mickey';

        System.assertEquals(null, controller.addAttachment());
        System.assertNotEquals(null, controller.file);

    }

    @isTest
    private static void testFinish()
    {
        //Instantiate a new controller
        IncidentReportWebController controller = new IncidentReportWebController();

        System.assert(controller.finish().getURL().contains('incidentreportfinish'), controller.finish().getURL());
    }
}