trigger ContactTrigger on Contact (before insert) 
{
	Set<Id> accountIds = new Set<Id>();

	for(Contact c :trigger.new)
	{
		accountIds.add(c.AccountId);
	}

	Map<Id,Id> accountClientMap = new Map<Id,Id>();
	for(Claims__Client__c client : [Select Claims__Account__c, Id FROM Claims__Client__c Where Claims__Account__c in :accountIds])
	{
		accountClientMap.put(client.Claims__Account__c, client.Id);
	}

	for(Contact con :trigger.new)
	{
		con.Claims__Client__c = accountClientMap.get(con.AccountId);
	}
}