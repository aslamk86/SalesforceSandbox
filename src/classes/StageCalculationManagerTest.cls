/**
  * @author Paul Battisson, Xactium Ltd
  * @description This is the test class for the StageCalculationManager class which handles all of the calculations 
  *              regarding staged payements and totals within the claims system.
  */
@isTest
public with sharing class StageCalculationManagerTest 
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

    @isTest
    private static void testCorrectlySetStagesAndValues()
    {
        Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);

        Test.startTest();

        Claims__Claim__c testClaim = [SELECT Id, Stage_1_Limit__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(5, testClaim.Stage_1_Limit__c, 'Incorrect stage 1 default limit set');
        System.assertEquals(35, testClaim.Stage_2_Limit__c, 'Incorrect stage 2 default limit set');
        System.assertEquals(75, testClaim.Stage_3_Limit__c, 'Incorrect stage 3 default limit set');
        System.assertEquals(100, testClaim.Stage_4_Limit__c, 'Incorrect stage 4 default limit set');

    }

    @isTest
    private static void testCorrectlySetStagesAndValuesWithNewPayment()
    {
        Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);

        Test.startTest();

        Claims__Claim__c testClaim = [SELECT Id, Stage_1_Limit__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(5, testClaim.Stage_1_Limit__c, 'Incorrect stage 1 default limit set');
        System.assertEquals(35, testClaim.Stage_2_Limit__c, 'Incorrect stage 2 default limit set');
        System.assertEquals(75, testClaim.Stage_3_Limit__c, 'Incorrect stage 3 default limit set');
        System.assertEquals(100, testClaim.Stage_4_Limit__c, 'Incorrect stage 4 default limit set');

        Id paymentId = createClaimPayment(claimId);

        testClaim = [SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c, Total_Amount_Approved__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(100.00, testClaim.Total_Amount_Approved__c, 'Incorrect stage 1 paid amount');
        System.assertEquals(50000, testClaim.Stage_1_Available__c, 'Incorrect stage 1 available amount');
    }

    @isTest
    private static void testCorrectlySetStagesAndValuesWithNewThenUpdatedPayment()
    {
        Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);

        Test.startTest();

        Claims__Claim__c testClaim = [SELECT Id, Stage_1_Limit__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(5, testClaim.Stage_1_Limit__c, 'Incorrect stage 1 default limit set');
        System.assertEquals(35, testClaim.Stage_2_Limit__c, 'Incorrect stage 2 default limit set');
        System.assertEquals(75, testClaim.Stage_3_Limit__c, 'Incorrect stage 3 default limit set');
        System.assertEquals(100, testClaim.Stage_4_Limit__c, 'Incorrect stage 4 default limit set');

        Id paymentId = createClaimPayment(claimId);

        testClaim = [SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c, Total_Amount_Approved__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(100.00, testClaim.Total_Amount_Approved__c, 'Incorrect stage 1 paid amount');
        System.assertEquals(50000, testClaim.Stage_1_Available__c, 'Incorrect stage 1 available amount');

        Claims__Claim_Payment__c testPayment = [SELECT Out_of_Pocket_Expenses__c, Claims__Claim__c, Claims__Date_Paid__c, Stage__c, Id 
                                                FROM Claims__Claim_Payment__c WHERE Id = :paymentId];

        testPayment.Out_of_Pocket_Expenses__c = 200.00;
        update testPayment;

        testClaim = [SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c, Total_Amount_Approved__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(200.00, testClaim.Total_Amount_Approved__c, 'Incorrect stage 1 paid amount');
        System.assertEquals(50000, testClaim.Stage_1_Available__c, 'Incorrect stage 1 available amount');

    }

    @isTest
    private static void testCorrectlySetStagesAndValuesWithMultipleNewThenSingleUpdatedPayment()
    {
        Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);

        Test.startTest();

        Claims__Claim__c testClaim = [SELECT Id, Stage_1_Limit__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(5, testClaim.Stage_1_Limit__c, 'Incorrect stage 1 default limit set');
        System.assertEquals(35, testClaim.Stage_2_Limit__c, 'Incorrect stage 2 default limit set');
        System.assertEquals(75, testClaim.Stage_3_Limit__c, 'Incorrect stage 3 default limit set');
        System.assertEquals(100, testClaim.Stage_4_Limit__c, 'Incorrect stage 4 default limit set');

        Id paymentId = createClaimPayment(claimId);
        Id payment2Id = createClaimPayment(claimId);

        testClaim = [SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c,Total_Amount_Approved__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(200.00, testClaim.Total_Amount_Approved__c, 'Incorrect stage 1 paid amount');
        System.assertEquals(50000, testClaim.Stage_1_Available__c, 'Incorrect stage 1 available amount');

        Claims__Claim_Payment__c testPayment = [SELECT Out_of_Pocket_Expenses__c, Claims__Claim__c, Claims__Date_Paid__c, Stage__c, Id 
                                                FROM Claims__Claim_Payment__c WHERE Id = :paymentId];

        testPayment.Out_of_Pocket_Expenses__c = 200.00;
        Date newDate = Date.today().addMonths(2);
        testPayment.Claims__Date_Paid__c = newDate.addDays(10);
        update testPayment;

        testPayment = [SELECT Out_of_Pocket_Expenses__c, Claims__Claim__c, Claims__Date_Paid__c, Stage__c, Id 
                                                FROM Claims__Claim_Payment__c WHERE Id = :paymentId];

        System.assertEquals('2', testPayment.Stage__c, 'Incorrect Stage set');

        testClaim = [SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_2_Paid__c, Stage_2_Available__c, Stage_3_Limit__c, Stage_4_Limit__c,Total_Amount_Approved__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(0.0, testClaim.Stage_1_Paid__c, 'Incorrect stage 1 paid amount');
        System.assertEquals(50000, testClaim.Stage_1_Available__c, 'Incorrect stage 1 available amount');

        System.assertEquals(300.00, testClaim.Total_Amount_Approved__c, 'Incorrect stage 2 paid amount');
        System.assertEquals(350000, testClaim.Stage_2_Available__c, 'Incorrect stage 2 available amount');

    }

    @isTest
    private static void testCorrectlySetOtherClaimsTotal()
    {
        Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);
        Id claim2Id = createClaim(clientId, coverTypeId);

        Test.startTest();

        Claims__Claim__c testClaim = [SELECT Id, Stage_1_Limit__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(5, testClaim.Stage_1_Limit__c, 'Incorrect stage 1 default limit set');
        System.assertEquals(35, testClaim.Stage_2_Limit__c, 'Incorrect stage 2 default limit set');
        System.assertEquals(75, testClaim.Stage_3_Limit__c, 'Incorrect stage 3 default limit set');
        System.assertEquals(100, testClaim.Stage_4_Limit__c, 'Incorrect stage 4 default limit set');

        Id paymentId = createClaimPayment(claimId);
        Id payment2Id = createClaimPayment(claimId);

        testClaim = [SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_3_Limit__c, Stage_4_Limit__c, Total_Amount_Approved__c 
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(200.00, testClaim.Total_Amount_Approved__c, 'Incorrect stage 1 paid amount');
        System.assertEquals(50000, testClaim.Stage_1_Available__c, 'Incorrect stage 1 available amount');

        Claims__Claim_Payment__c testPayment = [SELECT Out_of_Pocket_Expenses__c, Claims__Claim__c, Claims__Date_Paid__c, Stage__c, Id 
                                                FROM Claims__Claim_Payment__c WHERE Id = :paymentId];

        testPayment.Out_of_Pocket_Expenses__c = 200.00;
        Date newDate = Date.today().addMonths(2);
        testPayment.Claims__Date_Paid__c = newDate.addDays(10);
        update testPayment;

        testPayment = [SELECT Out_of_Pocket_Expenses__c, Claims__Claim__c, Claims__Date_Paid__c, Stage__c, Id 
                                                FROM Claims__Claim_Payment__c WHERE Id = :paymentId];

        System.assertEquals('2', testPayment.Stage__c, 'Incorrect Stage set');

        testClaim = [SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_2_Paid__c, Stage_2_Available__c, Stage_3_Limit__c, Stage_4_Limit__c, Total_Amount_Approved__c
                                        FROM Claims__Claim__c WHERE Id = :claimId];

        System.assertEquals(300.00, testClaim.Total_Amount_Approved__c, 'Incorrect stage 1 paid amount');
        System.assertEquals(50000, testClaim.Stage_1_Available__c, 'Incorrect stage 1 available amount');

        System.assertEquals(350000, testClaim.Stage_2_Available__c, 'Incorrect stage 2 available amount');


    }

    @isTest
    private static void testCorrectlySetFullDetailsTwoClaims()
    {
        Id clientId = createClient();
        Id policyId = createPolicy(clientId);
        Id coverTypeId = createCoverType(policyId);
        Id claimId = createClaim(clientId, coverTypeId);
        Id claim2Id = createClaim(clientId, coverTypeId);

        Id claim1_payment1Id = createClaimPayment(claimId);
        Id claim1_payment2Id = createClaimPayment(claimId);
        Id claim1_payment3Id = createClaimPayment(claimId);
        Id claim1_payment4Id = createClaimPayment(claimId);

        Id claim2_payment1Id = createClaimPayment(claim2Id);
        Id claim2_payment2Id = createClaimPayment(claim2Id);
        Id claim2_payment3Id = createClaimPayment(claim2Id);
        Id claim2_payment4Id = createClaimPayment(claim2Id);

        Set<Id> paymentIds = new Set<Id>{claim1_payment1Id, claim1_payment2Id, claim1_payment3Id, claim1_payment4Id, claim2_payment1Id, claim2_payment2Id, claim2_payment3Id, claim2_payment4Id};


        Map<Id, Claims__Claim_Payment__c> testPayments = new Map<Id, Claims__Claim_Payment__c>([SELECT Out_of_Pocket_Expenses__c, Claims__Claim__c, Claims__Date_Paid__c, Stage__c, Id 
                                                FROM Claims__Claim_Payment__c WHERE Id in :paymentIds]);

        Test.startTest();
        
        testPayments.get(claim1_payment1Id).Out_of_Pocket_Expenses__c = 0;
        testPayments.get(claim1_payment2Id).Out_of_Pocket_Expenses__c = 46400;
        testPayments.get(claim1_payment2Id).Claims__Date_Paid__c = Date.today().addMonths(2);
        testPayments.get(claim1_payment3Id).Out_of_Pocket_Expenses__c = 326400;
        testPayments.get(claim1_payment3Id).Claims__Date_Paid__c = Date.today().addMonths(4);
        testPayments.get(claim1_payment4Id).Out_of_Pocket_Expenses__c = 0;
        testPayments.get(claim1_payment4Id).Claims__Date_Paid__c = Date.today().addMonths(6);

        testPayments.get(claim2_payment1Id).Out_of_Pocket_Expenses__c = 0;
        testPayments.get(claim2_payment2Id).Out_of_Pocket_Expenses__c = 42000;
        testPayments.get(claim2_payment2Id).Claims__Date_Paid__c = Date.today().addMonths(2);
        testPayments.get(claim2_payment3Id).Out_of_Pocket_Expenses__c = 408000;
        testPayments.get(claim2_payment3Id).Claims__Date_Paid__c = Date.today().addMonths(4);
        testPayments.get(claim2_payment4Id).Out_of_Pocket_Expenses__c = 0;
        testPayments.get(claim2_payment4Id).Claims__Date_Paid__c = Date.today().addMonths(6);

        update testPayments.values();

        Map<Id, Claims__Claim__c> claims = new Map<Id,Claims__Claim__c>([SELECT Id, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Available__c, Stage_2_Limit__c, Stage_2_Paid__c, Stage_2_Available__c, Stage_3_Limit__c,
                                            Stage_3_Paid__c, Stage_3_Available__c, Stage_4_Limit__c, Stage_4_Paid__c, Stage_4_Available__c, Total_Amount_Approved__c 
                                            FROM Claims__Claim__c WHERE Id = :claimId OR Id = :claim2Id]);

 /*       System.assertEquals(372800, claims.get(claimId).Total_Amount_Approved__c, 'Incorrect value of paid for Claim 1');
        System.assertEquals(50000, claims.get(claimId).Stage_1_Available__c, 'Incorrect value of stage 1 available for Claim 1');

        System.assertEquals(350000, claims.get(claimId).Stage_2_Available__c, 'Incorrect value of stage 2 available for Claim 1');

        System.assertEquals(750000, claims.get(claimId).Stage_3_Available__c, 'Incorrect value of stage 3 available for Claim 1');

        System.assertEquals(1000000, claims.get(claimId).Stage_4_Available__c, 'Incorrect value of stage 4 available for Claim 1');

        System.assertEquals(450000, claims.get(claim2Id).Total_Amount_Approved__c, 'Incorrect value of paid for Claim 2');
        System.assertEquals(50000, claims.get(claim2Id).Stage_1_Available__c, 'Incorrect value of stage 1 available for Claim 2');

        System.assertEquals(350000, claims.get(claim2Id).Stage_2_Available__c, 'Incorrect value of stage 2 available for Claim 2');

        System.assertEquals(750000, claims.get(claim2Id).Stage_3_Available__c, 'Incorrect value of stage 3 available for Claim 2');

        System.assertEquals(1000000, claims.get(claim2Id).Stage_4_Available__c, 'Incorrect value of stage 4 available for Claim 2');
*/
    }

}