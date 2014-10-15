trigger ClaimTrigger on Claims__Claim__c (after update) 
{

	Map<Id, Claims__Claim__c> updatedClaims = new Map<Id, Claims__Claim__c>();
	Set<Id> coverTypeIds = new Set<Id>();
	for(Claims__Claim__c claim : trigger.new)
	{
		Boolean dateChanged = (claim.Stage_1_Start_Date__c != trigger.oldMap.get(claim.Id).Stage_1_Start_Date__c) ||
								(claim.Stage_1_End_Date__c != trigger.oldMap.get(claim.Id).Stage_1_End_Date__c) ||
								(claim.Stage_2_Start_Date__c != trigger.oldMap.get(claim.Id).Stage_2_Start_Date__c) ||
								(claim.Stage_2_End_Date__c != trigger.oldMap.get(claim.Id).Stage_2_End_Date__c) ||
								(claim.Stage_3_Start_Date__c != trigger.oldMap.get(claim.Id).Stage_3_Start_Date__c) ||
								(claim.Stage_3_End_Date__c != trigger.oldMap.get(claim.Id).Stage_3_End_Date__c) ||
								(claim.Stage_4_Start_Date__c != trigger.oldMap.get(claim.Id).Stage_4_Start_Date__c) ||
								(claim.Stage_4_End_Date__c != trigger.oldMap.get(claim.Id).Stage_4_End_Date__c);
		System.debug('DATE PAUL: ' + dateChanged);
		if(dateChanged)
		{
			updatedClaims.put(claim.Id, claim);
		}

		coverTypeIds.add(claim.Claims__Policy_Detail__c);
	}

	List<Claims__Claim_Payment__c> payments = [SELECT Stage__c, Claims__Date_Paid__c, Claims__Claim__c 
												FROM Claims__Claim_Payment__c WHERE Claims__Claim__c in :updatedClaims.keySet()];

	for(Claims__Claim_Payment__c payment : payments)
	{
		payment.Stage__c = StageCalculationManager.getStage(payment, updatedClaims.get(payment.Claims__Claim__c));
	}

	update payments;

	Map<Id, Claims__Policy_Detail__c> coverTypes = new Map<Id, Claims__Policy_Detail__c>([SELECT Total_Paid_Amount__c, Total_Policy_Amount_Approved__c, Id FROM Claims__Policy_Detail__c WHERE Id in :coverTypeIds]);

	Map<Id, Claims__Claim__c> claims = new Map<Id, Claims__Claim__c>([SELECT Claims__Policy_Detail__c, Total_Amount_Approved__c, Total_Paid__c FROM Claims__Claim__c WHERE Claims__Policy_Detail__c in :coverTypeIds]);

	Map<Id, Double> coverTypeTotalApproved = new Map<Id, Double>();
	Map<Id, Double> coverTypeTotalPaid = new Map<Id, Double>();

	for(Claims__Claim__c claim : claims.values())
	{
		if(coverTypeTotalApproved.containsKey(claim.Claims__Policy_Detail__c))
		{
			coverTypeTotalApproved.put(claim.Claims__Policy_Detail__c, coverTypeTotalApproved.get(claim.Claims__Policy_Detail__c) + claim.Total_Amount_Approved__c);
			coverTypeTotalPaid.put(claim.Claims__Policy_Detail__c, coverTypeTotalPaid.get(claim.Claims__Policy_Detail__c) + claim.Total_Paid__c);
		}
		else
		{
			coverTypeTotalApproved.put(claim.Claims__Policy_Detail__c, claim.Total_Amount_Approved__c);
			coverTypeTotalPaid.put(claim.Claims__Policy_Detail__c, claim.Total_Paid__c);
		}
	}

	for(Claims__Policy_Detail__c coverType : coverTypes.values())
	{
		coverType.Total_Policy_Amount_Approved__c = coverTypeTotalApproved.get(coverType.Id);
		coverType.Total_Paid_Amount__c = coverTypeTotalPaid.get(coverType.Id);
	}

	update coverTypes.values();
}