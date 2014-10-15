@isTest
public with sharing class ClaimsReserveTriggerTest 
{
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

    private static Id createClaim(Id clientId, Id coverTypeId)
    {
        //Instantiate a new Claim and set the required fields
        Claims__Claim__c claim = new Claims__Claim__c();
        claim.Claims__Client__c = clientId;
        claim.Claims__Date_Notified__c = Date.today();
        claim.Claims__Policy_Detail__c = coverTypeId;

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
        return claim.Id;
    }

    private static void createReserve(Id claimId, Boolean isLAE)
    {
    	Claims__Reserve__c reserve = new Claims__Reserve__c();
    	reserve.Claims__Amount__c = 10.00;
    	reserve.Claims__Claim__c = claimId;
    	reserve.Is_LAE__c = isLAE;
    	insert reserve;
    }

	@isTest
	private static void testAddNewReserveNonLAE()
	{
		Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);
        createReserve(claimId, false);
	}

	@isTest
	private static void testAddNewReserveLAE()
	{
		Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);
        createReserve(claimId, true);
	}
}