/*
    Class        : MS_AccountEntiTree
    Description  : Update account fields dealing with Entity Ids, etc.
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

public without sharing class MS_AccountEntiTree
	{
  //-------------------------------------------------------------------------------------------------------------------------
  // AccountTriggerBefore
  //-------------------------------------------------------------------------------------------------------------------------
  public static void AccountTriggerBefore(List<Account> lstAccount, Map<Id, Account> oldMap, boolean isDelete)
    {
		System.Debug(MS_Tools.Debug , '--- enter MS_AccountEntiTree.AccountTriggerBefore (' + lstAccount.Size() + ' accounts, isDelete: ' + isDelete + ')');

		AccountSetFields(lstAccount, oldMap, false);

		System.Debug(MS_Tools.Debug , '--- leave MS_AccountEntiTree.AccountTriggerBefore');
    }

  //-------------------------------------------------------------------------------------------------------------------------
  // AccountTriggerAfter
  //-------------------------------------------------------------------------------------------------------------------------
  public static void AccountTriggerAfter(List<Account> lstAccount, Map<Id, Account> oldMap, boolean isDelete)
    {   
		System.Debug(MS_Tools.Debug , '--- enter MS_AccountEntiTree.AccountTriggerAfter (' + lstAccount.Size() + ' accounts, isDelete: ' + isDelete + ')');

		integer nAccountsUpdated = AccountSetCalculatedFields(lstAccount, oldMap, false, isDelete);

		System.Debug(MS_Tools.Debug , '--- leave MS_AccountEntiTree.AccountTriggerAfter (' + nAccountsUpdated + ' of ' + lstAccount.Size() + ' accounts updated)');
    }

  //-------------------------------------------------------------------------------------------------------------------------
  // RefreshAccount
  //-------------------------------------------------------------------------------------------------------------------------
	public static void RefreshAccount(List<Account> lstAccount)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_AccountEntiTree.RefreshAccount (' + lstAccount.Size() + ' accounts)');

		integer nAccountsUpdated = AccountSetCalculatedFields(lstAccount, null, true, false);

		System.Debug(MS_Tools.Debug , '--- leave MS_AccountEntiTree.RefreshAccount (' + nAccountsUpdated + ' accounts of ' + lstAccount.Size() + ' accounts refreshed)');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // AccountSetFields
  //-------------------------------------------------------------------------------------------------------------------------
	private static void AccountSetFields(List<Account> lstAccount, Map<Id, Account> oldMap, boolean isRefresh)
		{
		for (Account a : lstAccount)
			{
			//
			// reset Refresh checkbox on isRefresh == true
			//
			if (isRefresh)
				a.Refresh__c = false;
			
			//
			// if account name or core name changed, compare them
			//
			if (MS_Tools.isNewOrChanged(a, oldMap, 'name') || MS_Tools.isNewOrChanged(a, oldMap, 'Entity_Core_Name__c'))
				{
				a.SFDC_Core_Name_Similar__c = MS_StringSimilarity.isCompanyNameSimilar(a.name, a.Entity_Core_Name__c);
				}
				
			//
			// Set Ultimate_Parent_IDs_Match__c
			// Need to do this via code as API returns 15-digit Ids and Apex returns 18-digit Ids.
			// As both are casted to type "Id", Apex takes care of 15-digit <-> 18-digit conversion
			//
			if (MS_Tools.isBlankString(a.Core_Ultimate_Parent_ID__c))
				a.Ultimate_Parent_IDs_Match__c = '?';
			else if ((Id)a.Core_Ultimate_Parent_ID__c == (Id)a.SFDC_Ultimate_Parent_ID__c)
				a.Ultimate_Parent_IDs_Match__c = 'Y';
			else
				a.Ultimate_Parent_IDs_Match__c = 'N';
			}
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // AccountSetCalculatedFields
  //-------------------------------------------------------------------------------------------------------------------------
  private static integer AccountSetCalculatedFields(List<Account> lstAccount, Map<Id, Account> oldMap, boolean isRefresh, boolean isDelete)
		{
		//
		// updating account fields dealing with Entity ID, etc.
		//

		System.Debug(MS_Tools.Debug, '...... AccountSetCalculatedFields: isRefresh: ' + isRefresh + ', isDelete: ' + isDelete);

		// do not update records that are in a merge operation
		set<id> MergeWinningAccounts = new set<id>();
		if (isDelete)
			{
			for (Account a : lstAccount)
				if (a.MasterRecordID != null)
					MergeWinningAccounts.add(a.MasterRecordID);
		
			if (!MergeWinningAccounts.isEmpty())
				{
				System.Debug(MS_Tools.Debug, '...... AccountSetCalculatedFields: found ' + MergeWinningAccounts.Size() + ' winning records of a merge operation');
				}
			}

		//
		// check which accounts need update
		//
		Set<integer> lstEIdToUpdateUPID      = new Set<integer>();
		Set<integer> lstUpEIdToUpdateUPID    = new Set<integer>();

		Set<integer> lstEIdToUpdateRollUp    = new Set<integer>();

		Set<Id>      lstIdToUpdateNoRollUp   = new Set<Id>();
		Set<String>  lstUpIdToUpdateNoRollUp = new Set<String>();
		Set<integer> lstEIdToUpdateNoRollUp  = new Set<integer>();

		Set<integer> lstMap_EId              = new Set<integer>();
		Set<integer> lstMap_UpEId            = new Set<integer>();

		for (Account a : lstAccount)
			{
			Account oldAccount = (Account)MS_Tools.getOldObject(a, oldMap);

			System.Debug(MS_Tools.Finest, '...... checking \'' + a.name + '\'' + (oldAccount != null ? ' (previous values available)' : ' (previous values NOT available)'));

			//
			// check for change in Salesforce parent ID
			//
			if (MS_Tools.isNewOrChanged(a, oldMap, 'ParentId'))
				{
				System.Debug(MS_Tools.Finer, '...... \'' + a.name + '\' changed Parent ID');
				
				// need to update no-roll-up for all accounts with old and new _ultimate_ parent ID
				addIfNotNull(lstUpIdToUpdateNoRollUp, a.SFDC_Ultimate_Parent_ID__c);
				if (oldAccount != null)
					addIfNotNull(lstUpIdToUpdateNoRollUp, oldAccount.SFDC_Ultimate_Parent_ID__c);

				// MAP: need all accounts with same ultimate parent ID as accounts-to-update
				//      taken care of below
				}

			//
			// check for change in Salesforce ultimate parent
			//
			if (MS_Tools.isNewOrChanged(a, oldMap, 'SFDC_Ultimate_Parent_ID__c'))
				{
				System.Debug(MS_Tools.Finer, '...... \'' + a.name + '\' changed Ultimate Parent ID');

				// need to update list of rolled-up accounts for account that has UP EID of this account as EID
				addIfNotNull(lstEIdToUpdateRollUp, a.Ultimate_Parent_Entity_ID__c);

				// MAP: need all accounts that have same UP EID as this account
				addIfNotNull(lstMap_UpEId, a.Ultimate_Parent_Entity_ID__c);
				}

			//
			// check for change in Entity ID
			//
			if (MS_Tools.isNewOrChanged(a, oldMap, 'Entity_ID__c'))
				{
				System.Debug(MS_Tools.Finer, '...... \'' + a.name + '\' changed Entity ID');

				// update ID and name of ultimate parent for accounts that have new and old EID as ultimate parent EID
				addIfNotNull(lstUpEIdToUpdateUPID, a.Entity_ID__c);
				if (oldAccount != null)
					addIfNotNull(lstUpEIdToUpdateUPID, oldAccount.Entity_ID__c);

				// MAP: need accounts that have ultimate parent EID of accounts to change as EID
				addIfNotNull(lstMap_EId, a.Entity_ID__c);

				// update list of rolled-up accounts for this account
				addIfNotNull(lstEIdToUpdateRollUp, a.Entity_ID__c);

				// MAP: need all accounts that have EID of this account as ultimate parent EID
				addIfNotNull(lstMap_UpEId, a.Entity_ID__c);

				// update no-roll-up for this account
				addIfNotNull(lstIdToUpdateNoRollUp, a.Id);

				// MAP: need all accounts with same ultimate parent ID as accounts-to-update
				//      taken care of below
				}

			//
			// check for change in ultimate parent Entity ID
			//
			if (MS_Tools.isNewOrChanged(a, oldMap, 'Ultimate_Parent_Entity_ID__c'))
				{
				System.Debug(MS_Tools.Finer, '...... \'' + a.name + '\' changed Ultimate Parent Entity ID');

				// update ID and name of ultimate parent for this account
				addIfNotNull(lstEIdToUpdateUPID, a.Entity_ID__c);

				// MAP: need account that has ultimate parent EID of this account as EID
				addIfNotNull(lstMap_EId, a.Ultimate_Parent_Entity_ID__c);

				// need to update rolled-up accounts for all accounts that have old and new ultimate parent EID
				// of this account as EID
				addIfNotNull(lstEIdToUpdateRollUp, a.Ultimate_Parent_Entity_ID__c);
				if (oldAccount != null)
					addIfNotNull(lstEIdToUpdateRollUp, oldAccount.Ultimate_Parent_Entity_ID__c);

				// MAP: need all accounts that have same (old and new) UP EID as this account
				addIfNotNull(lstMap_UpEId, a.Ultimate_Parent_Entity_ID__c);
				if (oldAccount != null)
					addIfNotNull(lstMap_UpEId, oldAccount.Ultimate_Parent_Entity_ID__c);				

				// need to update no-roll-up for all accounts that have old and new ultimate parent EID
				// of this account as EID
				addIfNotNull(lstEIdToUpdateNoRollUp, a.Ultimate_Parent_Entity_ID__c);
				if (oldAccount != null)
					addIfNotNull(lstEIdToUpdateNoRollUp, oldAccount.Ultimate_Parent_Entity_ID__c);

				// MAP: need all accounts with same ultimate parent ID as accounts-to-update
				//      taken care of below
				}
			}

		//
		// if nothing to do, return
		//
		if (lstEIdToUpdateUPID.isEmpty() &&
		    lstUpEIdToUpdateUPID.isEmpty() &&
		    lstEIdToUpdateRollUp.isEmpty() &&
		    lstIdToUpdateNoRollUp.isEmpty() &&
		    lstUpIdToUpdateNoRollUp.isEmpty() &&
		    lstEIdToUpdateNoRollUp.isEmpty()
		    )
			{
			System.Debug(MS_Tools.Debug, '...... AccountSetCalculatedFields: nothing to update');
			return 0;
			}

		//
		// debug messages
		//
		System.Debug(MS_Tools.Debug, '...... lstEIdToUpdateUPID: '      + lstEIdToUpdateUPID.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... lstUpEIdToUpdateUPID: '    + lstUpEIdToUpdateUPID.Size() + ' entries');

		System.Debug(MS_Tools.Debug, '...... lstEIdToUpdateRollUp: '    + lstEIdToUpdateRollUp.Size() + ' entries');

		System.Debug(MS_Tools.Debug, '...... lstIdToUpdateNoRollUp: '   + lstIdToUpdateNoRollUp.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... lstUpIdToUpdateNoRollUp: ' + lstUpIdToUpdateNoRollUp.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... lstEIdToUpdateNoRollUp: '  + lstEIdToUpdateNoRollUp.Size() + ' entries');

		System.Debug(MS_Tools.Debug, '...... lstMap_EId: '              + lstMap_EId.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... lstMap_UpEId: '            + lstMap_UpEId.Size() + ' entries');

		System.Debug(MS_Tools.Finest, '...... lstEIdToUpdateUPID: '      + lstEIdToUpdateUPID);
		System.Debug(MS_Tools.Finest, '...... lstUpEIdToUpdateUPID: '    + lstUpEIdToUpdateUPID);

		System.Debug(MS_Tools.Finest, '...... lstEIdToUpdateRollUp: '    + lstEIdToUpdateRollUp);

		System.Debug(MS_Tools.Finest, '...... lstIdToUpdateNoRollUp: '   + lstIdToUpdateNoRollUp);
		System.Debug(MS_Tools.Finest, '...... lstUpIdToUpdateNoRollUp: ' + lstUpIdToUpdateNoRollUp);
		System.Debug(MS_Tools.Finest, '...... lstEIdToUpdateNoRollUp: '  + lstEIdToUpdateNoRollUp);

		System.Debug(MS_Tools.Finest, '...... lstMap_EId: '              + lstMap_EId);
		System.Debug(MS_Tools.Finest, '...... lstMap_UpEId: '            + lstMap_UpEId);

		//
		// get all accounts that need update and all accounts that are needed for one of the maps in one query
		// to prevent exceeding governor limits
		//
		map<Id, Account> AccountsQueried = new map<Id, Account>
		    (
				[SELECT id, 
				        name,
				        All_Subs_Rolling_Up_Here__c,
				        Core_Ultimate_Parent_ID__c,
				        Core_Ultimate_Parent_Name__c,
				        Entity_Core_Name__c,
				        Entity_ID__c,
				        ParentId,
				        Refresh__c,
				        Rolled_up_Accounts__c,
				        SFDC_Core_Name_Similar__c,
				        SFDC_Ultimate_Parent_ID__c,
				        Ultimate_Parent__c,
				        Ultimate_Parent_Entity_ID__c,
				        Ultimate_Parent_IDs_Match__c		            
				 from Account
				 where Entity_ID__c IN :lstEIdToUpdateUPID or
				       Ultimate_Parent_Entity_ID__c IN :lstUpEIdToUpdateUPID or
				       Entity_ID__c IN :lstEIdToUpdateRollUp or
				       Id IN :lstIdToUpdateNoRollUp or
				       SFDC_Ultimate_Parent_ID__c IN :lstUpIdToUpdateNoRollUp or
				       Entity_ID__c IN :lstEIdToUpdateNoRollUp or
				       Entity_ID__c IN :lstMap_EId or
				       Ultimate_Parent_Entity_ID__c IN :lstMap_UpEId
				 ORDER BY name Asc]
				);

		System.Debug(MS_Tools.Debug, '...... queried ' + AccountsQueried.Size() + ' accounts');

		//
		// create maps needed to set fields below
		//

		// sets of IDs that need update
		Set<Id> UpdateUPID     = new Set<Id>();
		Set<Id> UpdateRollUp   = new Set<Id>();
		Set<Id> UpdateNoRollUp = new Set<ID>();
		Set<String> UpIdToMap  = new Set<String>();

		// map of EIDs to Accounts
		map<decimal, Account> mapEIDtoAccount = new map<decimal, Account>();

		// map of Ultimate Parent EIDs to list of Accounts
		map<decimal, List<Account>> mapUPEIDtoAccountList = new map<decimal, List<Account>>();
		
		// map of Parent ID to list of Accounts
		map<Id, List<Account>> mapParentIdToAccountList = new map<Id, List<Account>>();

		for (Account a : AccountsQueried.values())
			{
			System.Debug(MS_Tools.Finest, 'mapping ' + a.name + ' EID: ' + a.Entity_ID__c + ' UP EID: ' + a.Ultimate_Parent_Entity_ID__c);

			// add to update Sets

			if (SafeContains(lstEIdToUpdateUPID, a.Entity_ID__c) ||
			    SafeContains(lstUpEIdToUpdateUPID, a.Ultimate_Parent_Entity_ID__c)
			   )
				UpdateUPID.add(a.Id);

			if (SafeContains(lstEIdToUpdateRollUp, a.Entity_ID__c))
				UpdateRollUp.add(a.Id);

			if (SafeContains(lstIdToUpdateNoRollUp, a.Id) || 
			    SafeContains(lstUpIdToUpdateNoRollUp, a.SFDC_Ultimate_Parent_ID__c) ||
			    SafeContains(lstEIdToUpdateNoRollUp, a.Entity_ID__c)
			   )
				{
				addIfNotNull(UpIdToMap, a.SFDC_Ultimate_Parent_ID__c);
				UpdateNoRollUp.add(a.Id);
				}

			// create maps

			if (a.Entity_ID__c != null)
				mapEIDtoAccount.put(a.Entity_ID__c, a);

			if (a.Ultimate_Parent_Entity_ID__c != null)
				{
				// create new list for key, if key does not yet exist
				if (!mapUPEIDtoAccountList.containsKey(a.Ultimate_Parent_Entity_ID__c))
					{
					List<Account> lst = new List<Account>();
					mapUPEIDtoAccountList.put(a.Ultimate_Parent_Entity_ID__c, lst);
					}

				mapUPEIDtoAccountList.get(a.Ultimate_Parent_Entity_ID__c).add(a);
				}

			if (a.ParentId != null)
				{
				// create new list for key, if key does not yet exist
				if (!mapParentIdToAccountList.containsKey(a.ParentId))
					{
					List<Account> lst = new List<Account>();
					mapParentIdToAccountList.put(a.ParentId, lst);
					}

				mapParentIdToAccountList.get(a.ParentId).add(a);
				}
			}

		// need another query to finish building map of ParentIDs to list of accounts
		// final list of accounts-to-update only known after first query above (I think...)
		// is there a way to merge this into query above?
		integer nCount = 0;
		for (Account a : [Select Id, name, ParentID, Ultimate_Parent_Entity_ID__c
		                  from Account
		                  where (ParentId != null) AND
		                        (Id NOT IN :AccountsQueried.keySet()) AND
		                        (SFDC_Ultimate_Parent_ID__c IN :UpIdToMap)
		                 ])
			{
			nCount++;
			
			// create new list for key, if key does not yet exist
			if (!mapParentIdToAccountList.containsKey(a.ParentId))
				{
				List<Account> lst = new List<Account>();
				mapParentIdToAccountList.put(a.ParentId, lst);
				}

			mapParentIdToAccountList.get(a.ParentId).add(a);
			}

		System.Debug(MS_Tools.Debug, '...... queried another ' + nCount + ' accounts for ' + UpIdToMap.Size() + ' ultimate parent IDs');

		System.Debug(MS_Tools.Debug, '...... mapEIDtoAccount: '          + mapEIDtoAccount.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... mapUPEIDtoAccountList: '    + mapUPEIDtoAccountList.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... mapParentIdToAccountList: ' + mapParentIdToAccountList.Size() + ' entries');		
		System.Debug(MS_Tools.Debug, '...... UpdateUPID: '               + UpdateUPID.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... UpdateRollUp: '             + UpdateRollUp.Size() + ' entries');
		System.Debug(MS_Tools.Debug, '...... UpdateNoRollUp: '           + UpdateNoRollUp.Size() + ' entries');

		System.Debug(MS_Tools.Finest, '...... mapEIDtoAccount keys: '          + mapEIDtoAccount.keySet());
		System.Debug(MS_Tools.Finest, '...... mapUPEIDtoAccountList keys: '    + mapUPEIDtoAccountList.keySet());
		System.Debug(MS_Tools.Finest, '...... mapParentIdToAccountList keys: ' + mapParentIdToAccountList.keySet());
		System.Debug(MS_Tools.Finest, '...... UpdateUPID: '                    + UpdateUPID);
		System.Debug(MS_Tools.Finest, '...... UpdateRollUp: '                  + UpdateRollUp);
		System.Debug(MS_Tools.Finest, '...... UpdateNoRollUp: '                + UpdateNoRollUp);

		//
		// update fields
		//
		Map<Id, Account> AccountsToUpdate = new Map<Id, Account>();
		
		for (Account a : AccountsQueried.values())
			{
			System.Debug(MS_Tools.Finest , '...... updating \'' + a.name + '\'');

			//
			// do not update winning records of a merge operation
			//
			if (MergeWinningAccounts.contains(a.Id))
				{
				System.Debug(MS_Tools.Debug, '...... skipping \'' + a.name + '\' (winning record in a merge operation)');
				continue;
				}

			//
			// set Core Ultimate Parent ID / name
			//
			if (UpdateUPID.contains(a.Id))
				{
				System.Debug(MS_Tools.Fine , '...... setting new core ultimate parent ID/name for \'' + a.name + '\'');
				AccountsToUpdate.put(a.Id, a);
				
				if (a.Ultimate_Parent_Entity_ID__c != null && mapEIDtoAccount.containsKey(a.Ultimate_Parent_Entity_ID__c))
					{
					Account acc = mapEIDtoAccount.get(a.Ultimate_Parent_Entity_ID__c);
					a.Core_Ultimate_Parent_ID__c   = acc.Id;
					a.Core_Ultimate_Parent_Name__c = acc.name;
					}
				else
					{
					// no account in Salesforce for this Ultimate Parent EID
					a.Core_Ultimate_Parent_ID__c   = '';
					a.Core_Ultimate_Parent_Name__c = '';
					
					System.Debug(MS_Tools.Fine , '...... no entry in mapEIDtoAccount for EID ' + a.Ultimate_Parent_Entity_ID__c);
					}
				}

			//
			// set list of accounts rolled up to this account
			//
			if (UpdateRollUp.contains(a.Id))
				{
				System.Debug(MS_Tools.Fine , '...... setting rolled-up accounts for \'' + a.name + '\'');
				AccountsToUpdate.put(a.Id, a);

				a.Rolled_up_Accounts__c = '';

				if (a.Entity_ID__c != null && mapUPEIDtoAccountList.containsKey(a.Entity_ID__c))
					{
					List<Account> lst = mapUPEIDtoAccountList.get(a.Entity_ID__c);
					lst.sort();

					for (Account acc : lst)
						{
						a.Rolled_up_Accounts__c += CreateLink(acc.Id, acc.name, null);

						if ((Id)a.SFDC_Ultimate_Parent_ID__c != (Id)acc.SFDC_Ultimate_Parent_ID__c)
							{
							if ((Id)acc.SFDC_Ultimate_Parent_ID__c != acc.Id)
								a.Rolled_up_Accounts__c += ' (ultimate parent: ' + CreateLink(acc.SFDC_Ultimate_Parent_ID__c, acc.Ultimate_Parent__c, null) + ')';
							else
								a.Rolled_up_Accounts__c += ' (top-level account)';
							}
						a.Rolled_up_Accounts__c += '<br>';
						}
					}
				else
					{
					System.Debug(MS_Tools.Fine , '...... no entry in mapUPEIDtoAccountList for EID ' + a.Entity_ID__c);
					}
				}

			//
			// set list of subsidiaries not rolled up to this account
			//
			if (UpdateNoRollUp.contains(a.Id))
				{
				System.Debug(MS_Tools.Fine , '...... setting no-rolled-up subsidiaries for \'' + a.name + '\'');
				AccountsToUpdate.put(a.Id, a);

				a.Subs_Not_Rolling_Up_Here__c = '';
				a.All_Subs_Rolling_Up_Here__c = 'Y';

				List<Account> lstSubs = new List<Account>();
				if (GetSubs(a.Id, lstSubs, mapParentIdToAccountList))
					{
					List<Account> NoRollUps = new List<Account>();
					for (Account acc : lstSubs)
						if (acc.Ultimate_Parent_Entity_ID__c != a.Entity_ID__c)
							NoRollUps.add(acc);
					
					if (!NoRollUps.isEmpty())
						{
						a.All_Subs_Rolling_Up_Here__c = 'N';

						NoRollUps.sort();
						for (Account acc : NoRollUps)
							a.Subs_Not_Rolling_Up_Here__c += CreateLink(acc.Id, acc.name, null) + '<br>';
						}
					else
						{
						System.Debug(MS_Tools.Fine, '...... \'' + a.name + '\': all subsidiaries rolling up here');
						}
					}
				else
					{
					System.Debug(MS_Tools.Fine, '...... \'' + a.name + '\': no subsidiaries');
					}
				}
			}

		//
		// This is a totally useless comment. It's only purpose is to check if anyone will ever
		// read it. If you do: congratulations! Send me an email: msieler@rpxcorp.com (if I am
		// still around) or martin.sieler@gmx.net.
		// I am really sorry that this method is "slightly" complicated...:-). I hope it still works.
		//

		if (!AccountsToUpdate.isEmpty())
			{
			//
			// also calculate other fields on isRefresh == true
			//
			if (isRefresh)
				AccountSetFields(AccountsToUpdate.values(), oldMap, true);
			
			update AccountsToUpdate.values();
			}

		return AccountsToUpdate.Size();
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// addIfNotNull
	//-------------------------------------------------------------------------------------------------------------------------
	private static boolean addIfNotNull(Set<integer> lst, decimal value)
		{
		integer v = (value != null) ? value.intValue() : 0;
		
		if (v != 0)
			return lst.add(v);
		else
			return false;
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// addIfNotNull
	//-------------------------------------------------------------------------------------------------------------------------
	private static boolean addIfNotNull(Set<Id> lst, Id xId)
		{
		if (xId != null)
			return lst.add(xId);
		else
			return false;
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// addIfNotNull
	//-------------------------------------------------------------------------------------------------------------------------
	private static boolean addIfNotNull(Set<String> lst, String s)
		{
		if (!MS_Tools.isBlankString(s))
			return lst.add(s);
		else
			return false;
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // SafeContains
  //-------------------------------------------------------------------------------------------------------------------------
	private static boolean SafeContains(Set<integer> lst, decimal value)
		{
		integer v = (value != null) ? value.intValue() : 0;

		if (v != 0)
			return lst.contains(v);
		else
			return false;
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// SafeContains
	//-------------------------------------------------------------------------------------------------------------------------
	private static boolean SafeContains(Set<Id> lst, Id xId)
		{
		if (xId != null)
			return lst.contains(xId);
		else
			return false;
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// SafeContains
	//-------------------------------------------------------------------------------------------------------------------------
	private static boolean SafeContains(Set<String> lst, String s)
		{
		if (!MS_Tools.isBlankString(s))
			return lst.contains(s);
		else
			return false;
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// CreateLink
	//-------------------------------------------------------------------------------------------------------------------------
	private static String CreateLink(ID xID, String FriendlyName, String Target)
		{
		String sTarget = ' target="' + (MS_Tools.isBlankString(Target) ? '_self' : Target) + '"';
			
		return ('<A href="/' + xID + '"' + sTarget + '>' + FriendlyName + '</A>');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// GetSubs
	//-------------------------------------------------------------------------------------------------------------------------
	private static boolean GetSubs(Id AccId, List<Account> lstSubs, map<Id, List<Account>> mapParentIds)
		{
		GetSubsWorker(AccId, lstSubs, mapParentIds);
		
		// return true if there are subsidiaries
		return (!lstSubs.isEmpty());
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// GetSubsWorker
	//-------------------------------------------------------------------------------------------------------------------------
	private static void GetSubsWorker(Id AccId, List<Account> lstSubs, map<Id, List<Account>> mapParentIds)
		{
		if (mapParentIds.containsKey(AccId))
			{
			for (Account a : mapParentIds.get(AccId))
				{
				lstSubs.add(a);
				GetSubsWorker(a.Id, lstSubs, mapParentIds);
				}
			}
		}

	}