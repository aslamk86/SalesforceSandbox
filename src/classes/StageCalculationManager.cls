/**
  * @author Paul Battisson, Xactium Ltd.
  * @description This class is utilised by the triggers on Claim and Claim Payment to correctly aggregate and update
  * 			 values on the Claim and associated Cover Type (Claims__Policy_Detail__c) so that the stage calculations 
  * 			 may be performed correctly.
  */
public with sharing class StageCalculationManager
{

	public static Set<Id> updatedPaymentIds = new Set<Id>();

	public static void setPaymentStages(List<Claims__Claim_Payment__c> payments)
	{
		//Firstly retrieve the claim payment claim Ids
		Set<Id> claimIds = new Set<Id>();

		for(Claims__Claim_Payment__c payment : payments)
		{
			claimIds.add(payment.Claims__Claim__c);
		}

		Map<Id, Claims__Claim__c> claims = new Map<Id, Claims__Claim__c>([SELECT Stage_1_Start_Date__c, Stage_1_End_Date__c, Stage_2_Start_Date__c, 
																			Stage_2_End_Date__c, Stage_3_Start_Date__c, Stage_3_End_Date__c, 
																			Stage_4_Start_Date__c, Stage_4_End_Date__c  
																			FROM Claims__Claim__c WHERE Id in :claimIds]);

		for(Claims__Claim_Payment__c pay : payments)
		{
			pay.Stage__c = getStage(pay, claims.get(pay.Claims__Claim__c));
		}
	}

	/*public static void setPriorValues(List<Claims__Claim_Payment__c> payments)
	{
		//What is needed in this method is the following:
		//	1) Retrieve all of the claims and payments related to the policy(ies)
		//	2) Loop through the payments in our list
		//	3) For each payment, loop through the other payments available
		//	4) If the date is earlier and is the same policy => increment the total amount paid on the policy
		//	5) If the date is earlier and is the same claim => increment the claim previous amount
		// 	6) If the date was later then add this payment to a list of those needing updating
		//	7) Update the same values on the payments in this update needed list

		Set<Id> policyIds = new Set<Id>();

		for(Claims__Claim_Payment__c payment : payments)
		{
			policyIds.add(payment.Policy__c);
		}

		Map<Id, Claims__Claim__c> claimsMap = new Map<Id, Claims__Claim__c>([SELECT Claims__Policy_Detail__c, Id, (SELECT Claims__Claim__c, Policy__c, Total_Amount_Approved__c, Claims__Date_Paid__c, Is_LAE__c, Id FROM Claims__Payments__r WHERE Is_LAE__c = false) FROM Claims__Claim__c WHERE Claims__Policy_Detail__c in :policyIds]);

		Map<Id, Claims__Claim_Payment__c> otherPaymentsNeedingUpdate = new Map<Id, Claims__Claim_Payment__c>();

		//Loop through the payments in the list
		for(Claims__Claim_Payment__c payment : payments)
		{
			Double priorAmountClaim = 0.0;
			Double priorAmountPolicy = 0.0;

			//Now loop through the claims in the map 
			for(Claims__Claim__c claim : claimsMap.values())
			{
				//If the policy is the same we then need to loop through the associated payments to total them up
				if(claim.Claims__Policy_Detail__c == payment.Policy__c)
				{
					for(Claims__Claim_Payment__c claimPay : claim.Claims__Payments__r)
					{
						//If the payment date is earlier than the date of our new payment then we need to add it on
						if(claimPay.Claims__Date_Paid__c < payment.Claims__Date_Paid__c)
						{
							if(claimPay.Claims__Claim__c == claim.Id)
							{
								priorAmountClaim += claimPay.Total_Amount_Approved__c;
							}
							priorAmountPolicy += claimPay.Total_Amount_Approved__c;
						}
						//Otherwise we will need to update our payment
						else
						{
							if(otherPaymentsNeedingUpdate.get(claimPay.Claims__Claim__c) != null && otherPaymentsNeedingUpdate.get(claimPay.Claims__Claim__c).Claims__Date_Paid__c > claimPay.Claims__Date_Paid__c)
							{
								otherPaymentsNeedingUpdate.put(claimPay.Claims__Claim__c, claimPay);
							}
						}
						
					}

				}
			}

			payment.Prior_Amount_Claim__c = priorAmountClaim;
			payment.Prior_Amount_Policy__c = priorAmountPolicy;
		}

		update otherPaymentsNeedingUpdate.values();

	}*/

	/**
	  * @description This method deals with recalculating all of the values on a payment.
	  */
	public static void updatePayments(List<Claims__Claim_Payment__c> payments)
	{
		//Firstly retrieve the set of policyIds that we will be using
		Set<String> policyIds = new Set<String>();

		//Loop through all the payments and get all of the policy ids
		for(Claims__Claim_Payment__c payment : payments)
		{
			policyIds.add(payment.Policy__c);
		}

		Map<Id, Decimal> claimRunningTotals = new Map<Id, Decimal>();

		Map<Id, Decimal> policyRunningTotals = new Map<Id, Decimal>();

		List<Claims__Claim_Payment__c> updatedPayments = new List<Claims__Claim_Payment__c>();


		for(Claims__Claim_Payment__c payment : [SELECT Name, Claims__Claim__c, Policy__c, Total_Amount_Approved__c, Claims__Date_Paid__c, Is_LAE__c, Policy_Running_Total__c, Claim_Running_Total__c, Id, Use_Per_Claim_SIR__c FROM Claims__Claim_Payment__c WHERE Is_LAE__c = false AND Policy__c in :policyIds ORDER BY Claims__Date_Paid__c, Name])
		{

			if(!updatedPaymentIds.contains(payment.Id))
			{
				
				if(policyRunningTotals.containsKey(payment.Policy__c))
				{
					policyRunningTotals.put(payment.Policy__c, policyRunningTotals.get(payment.Policy__c) + payment.Total_Amount_Approved__c);
				}
				else
				{
					policyRunningTotals.put(payment.Policy__c, payment.Total_Amount_Approved__c);
				}

				
				if(claimRunningTotals.containsKey(payment.Claims__Claim__c))
				{
					claimRunningTotals.put(payment.Claims__Claim__c, claimRunningTotals.get(payment.Claims__Claim__c) + payment.Total_Amount_Approved__c);
				}
				else
				{
					claimRunningTotals.put(payment.Claims__Claim__c, payment.Total_Amount_Approved__c);
				}

				payment.Policy_Running_Total__c = policyRunningTotals.get(payment.Policy__c);
				payment.Claim_Running_Total__c = claimRunningTotals.get(payment.Claims__Claim__c);


				updatedPayments.add(payment);
				updatedPaymentIds.add(payment.Id);

			}
		}

		update updatedPayments;
	}


	public static String getStage(Claims__Claim_Payment__c payment, Claims__Claim__c claim)
	{
		if((claim.Stage_1_Start_Date__c <= payment.Claims__Date_Paid__c) && (claim.Stage_1_End_Date__c >= payment.Claims__Date_Paid__c || claim.Stage_1_End_Date__c == null))
		{
			return '1';
		}
		else if((claim.Stage_2_Start_Date__c <= payment.Claims__Date_Paid__c) && (claim.Stage_2_End_Date__c >= payment.Claims__Date_Paid__c || claim.Stage_2_End_Date__c == null))
		{
			return '2';
		}
		else if((claim.Stage_3_Start_Date__c <= payment.Claims__Date_Paid__c) && (claim.Stage_3_End_Date__c >= payment.Claims__Date_Paid__c || claim.Stage_3_End_Date__c == null))
		{
			return '3';
		}
		else if((claim.Stage_4_Start_Date__c <= payment.Claims__Date_Paid__c) && (claim.Stage_4_End_Date__c >= payment.Claims__Date_Paid__c || claim.Stage_4_End_Date__c == null))
		{
			return '4';
		}

		return '';
	}

}