trigger ClientTrigger on Claims__Client__c(after insert, after update)
{
	//We must first retrieve all of the Account Ids from the Clients and ensure we have 
	//a map of the Account Ids to the Client Id.
	Map<Id, Id> accountClientIds = new Map<Id, Id>();

	//Let us loop through the clients in new trigger and add the Client Id and Account
	//Id to the map. If we are in an update trigger we only want to do this if the Client's
	//Account reference has changed.
	for(Claims__Client__c client : trigger.new)
	{
		//Check that we are either in a before trigger (always run the update) or that the Account has changed.
		if(!trigger.isUpdate || (client.Claims__Account__c != trigger.oldMap.get(client.Id).Claims__Account__c))
		{
			//If we already have a Client assigned to this account then we need to throw an error
			if(accountClientIds.get(client.Claims__Account__c) != null)
			{
				throw new ClaimsException('You cannot have multiple clients associated to a single account.');
			}

			//Place the Account Id and Client Id in the map.
			accountClientIds.put(client.Claims__Account__c, client.Id);
		}
	}

	//Let us have a list of Contacts for update
	List<Contact> contactsForUpdate = new List<Contact>();

	//Now loop through all the Contacts with an Id in the map we have setup.
	for(Contact con : [Select Id, AccountId, Claims__Client__c from Contact Where AccountId in :accountClientIds.keySet()])
	{
		//Set the Client correctly and add to the update list.
		con.Claims__Client__c = accountClientIds.get(con.AccountId);
		contactsForUpdate.add(con);
	}

	//Update the Contacts
	update contactsForUpdate;

}