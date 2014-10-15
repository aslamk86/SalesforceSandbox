@isTest
private class ClosureControllerTest {
	
		private static Id createClient()
	{
		//A policy requires a valid Client
		Claims__Client__c client = new Claims__Client__c();
		insert client;
		return client.Id;
	}

	private static Id createPolicy(Id clientId)
	{
		//A cover type requires a valid Policy
		Claims__Policy__c policy = new Claims__Policy__c();
		policy.Claims__Is_Active__c = true;
		policy.Claims__Client__c = clientId;
		insert policy;
		return policy.Id;
	}

	private static Id createCoverType(Id policyId)
	{
		//Create the cover type
		Claims__Policy_Detail__c coverType = new Claims__Policy_Detail__c();
		coverType.Claims__Inception_Date__c = Date.today();
		coverType.Claims__Policy__c = policyId;
		coverType.Claims__Is_Active__c = true;

		//Set the financial information
		coverType.Per_Claim_Limit_of_Liability__c = 1000000;
		coverType.Aggregate_Limit_of_Liability__c = 2500000;
		coverType.Per_Claim_SIR__c = 50000;
		coverType.Aggregate_SIR__c = 500000;

		//Set the default percentages
		coverType.Stage_1_Default_Percentage__c = 5;
		coverType.Stage_2_Default_Percentage__c = 35;
		coverType.Stage_3_Default_Percentage__c = 75;
		coverType.Stage_4_Default_Percentage__c = 100;

		//Insert the coverType and return it's Id
		insert coverType;
		return coverType.Id;
	}

	private static Claims__Claim__c createClaim(Id clientId, Id coverTypeId, Id incidentId)
	{
		//Instantiate a new Claim and set the required fields
		Claims__Claim__c claim = new Claims__Claim__c();
		claim.Claims__Client__c = clientId;
		claim.Claims__Date_Notified__c = Date.today();
		claim.Claims__Policy_Detail__c = coverTypeId;
		claim.Claims__Incident_Report__c = incidentId;
		claim.Resolution_Payment_Date__c = Date.today();

		//Now let us set the stage information
		claim.Stage_1_Start_Date__c = Date.today();
		claim.Stage_1_End_Date__c = Date.today().addMonths(1);
		claim.Stage_2_Start_Date__c = Date.today().addMonths(2);
		claim.Stage_2_End_Date__c = Date.today().addMonths(3);
		claim.Stage_3_Start_Date__c = Date.today().addMonths(4);
		claim.Stage_3_End_Date__c = Date.today().addMonths(5);
		claim.Stage_4_Start_Date__c = Date.today().addMonths(6);
		claim.Stage_4_End_Date__c = Date.today().addMonths(7);

		//Insert our claim and return the correct Id
		insert claim;
		return claim;
	}

	private static Id createClaimPayment(Id claimId)
	{
		//Instantaite a new claim payment
		Claims__Claim_Payment__c payment = new Claims__Claim_Payment__c();

		//Set the amount, put the date within stage 1 and relate to the existing claim
		payment.Out_of_Pocket_Expenses__c = 100.00;
		payment.Claims__Claim__c = claimId;
		payment.Claims__Date_Paid__c = Date.today();

		//Insert the claim payment and return its value
		insert payment;

		return payment.Id;
	}

	private static Claims__Incident_Report__c createIncidentReport(Id policyId, Id clientId)
	{
		Claims__Incident_Report__c incidentReport = new Claims__Incident_Report__c();
		incidentReport.Client__c = clientId;
		incidentReport.Cover_Type__c = policyId;
		incidentReport.Claims__First_Name__c = 'Bob';
		incidentReport.Claims__Last_Name__c = 'Bobson';
		incidentReport.Claims__Report_Completed_By__c = incidentReport.Claims__First_Name__c + ' ' + incidentReport.Claims__Last_Name__c;
		incidentReport.Claims__IncidentLocation__c = 'United States of America';
		incidentReport.Claims__Date_Reported__c = Date.today();
		incidentReport.Claims__Email__c = 'bob@bobson.com';
		incidentReport.Claims__IncidentDate__c = Date.today();
		insert incidentReport;
		return incidentReport;
	}
	

	static testMethod void testNewController()
	{
		Id clientId = createClient();
		Id policyId = createPolicy(clientId);
		Id coverTypeId = createCoverType(policyId);
		Claims__Incident_Report__c report = createIncidentReport(coverTypeId, clientId);
		Claims__Claim__c claim = createClaim(clientId, coverTypeId, report.Id);
		Id paymentId = createClaimPayment(claim.Id);

		ApexPages.StandardController controller = new ApexPages.StandardController(claim);
		ClosureControllerExtension cloController = new ClosureControllerExtension(controller);
		System.assertNotEquals(null, cloController.letterText1);
		System.assertNotEquals(null, cloController.letterText2);
		System.assertNotEquals(null, cloController.letterText3);
		System.assertNotEquals(null, cloController.getImageURL());
		System.assertNotEquals(null, cloController.print());

	}
}