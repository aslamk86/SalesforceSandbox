trigger ClaimsReserveTrigger on Claims__Reserve__c (after insert, after update, after delete)
{
	Set<Id> claimIds = new Set<Id>();

	if(trigger.isDelete)
	{
		for(Claims__Reserve__c reserve : trigger.old)
		{
			claimIds.add(reserve.Claims__Claim__c);
		}
	}
	else
	{
		for(Claims__Reserve__c reserve : trigger.new)
		{
			claimIds.add(reserve.Claims__Claim__c);
		}	
	}

	List<Claims__Claim__c> claims = [SELECT Total_Reserve_Val__c, Id, (SELECT Claims__Amount__c, Is_LAE__c FROM Claims__Reserves__r) FROM Claims__Claim__c WHERE Id in :claimIds];

	for(Claims__Claim__c claim : claims)
	{
		claim.Total_Reserve_Val__c = 0.0;

		for(Claims__Reserve__c reserve : claim.Claims__Reserves__r)
		{
			if(reserve.Is_LAE__c)
			{
				claim.Total_LAE_Reserve_Val__c = claim.Total_LAE_Reserve_Val__c == null ? reserve.Claims__Amount__c : claim.Total_LAE_Reserve_Val__c + reserve.Claims__Amount__c;	
			}
			else
			{
				claim.Total_Reserve_Val__c = claim.Total_Reserve_Val__c == null ? reserve.Claims__Amount__c : claim.Total_Reserve_Val__c + reserve.Claims__Amount__c;		
			}
		}
	}

	update claims;
}