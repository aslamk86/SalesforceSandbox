trigger ClaimPaymentTrigger on Claims__Claim_Payment__c (before insert, before update, after insert, after update) 
{
	/*if(trigger.isInsert)
	{
		StageCalculationManager manager = new StageCalculationManager(trigger.new);
		manager.performCalculations(false);
		manager.callUpdateOnClaimsAndCoverTypes();	
	}
	else if(trigger.isUpdate)
	{
		StageCalculationManager manager = new StageCalculationManager(trigger.newMap);
		manager.performCalculations(true);
		manager.callUpdateOnClaimsAndCoverTypes();
	}*/

	//The before trigger for the claim payments deals with setting the payments stage. All the values are now calculated so we
	//ony need to ensure the stage values are correctly set.
	if(trigger.isBefore)
	{
		StageCalculationManager.setPaymentStages(trigger.new);
	}

	if(trigger.isAfter)
	{
		if(trigger.isDelete)
		{
			StageCalculationManager.updatePayments(trigger.old);	
		}
		else
		{
			StageCalculationManager.updatePayments(trigger.new);
		}
		
	//	StageCalculationManager.setClaimAndCoverTypeTotals(trigger.new, trigger.isInsert);
	}
}