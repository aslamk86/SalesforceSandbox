/*
    Class        : MS_LitigationInfo
    Description  : Update Litigation/Defendant Count Fields on Accounts, Litigations, Acquisitions
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

public without sharing class MS_LitigationInfo
	{
	//-------------------------------------------------------------------------------------------------------------------------
	// used to calculate litigation counts on accounts
	//-------------------------------------------------------------------------------------------------------------------------
	private static final integer thisyear  = date.today().year();
	private static final String  sThisYear = String.valueof(thisyear);
	private static final String  s5YrsAgo  = String.valueof(thisyear-5);

	//-------------------------------------------------------------------------------------------------------------------------
	// objects that need to be recalculated due to delete triggers
	//-------------------------------------------------------------------------------------------------------------------------

	private static set<id> gAccsToUpdate = new set<id>();
	private static set<id> gAcqsToUpdate = new set<id>();
	private static set<id> gLitsToUpdate = new set<id>();

  //-------------------------------------------------------------------------------------------------------------------------
  // CheckUpdateLists
  //-------------------------------------------------------------------------------------------------------------------------
  public static void CheckUpdateLists()
		{
		String Result = '';
		String Body = '';
		
		if (gAccsToUpdate.Size() == 0 && gAcqsToUpdate.Size() == 0 && gLitsToUpdate.Size() == 0)
			{
			Result = 'OK';
			}
		else
			{
			Result = 'Entries Found';
			
			if (gAccsToUpdate.Size() > 0)
				Body += 'Accounts: ' + gAccsToUpdate.Size() + '\n';

			if (gAcqsToUpdate.Size() > 0)
				Body += 'Acquisitions: ' + gAcqsToUpdate.Size() + '\n';

			if (gLitsToUpdate.Size() > 0)
				Body += 'Accounts: ' + gLitsToUpdate.Size() + '\n';
			}
			
		MS_Tools.SendEmail('msieler@rpxcorp.com', 'Update Lists: ' + Result, Body);
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // AccountTriggerBefore
  //-------------------------------------------------------------------------------------------------------------------------
  public static void AccountTriggerBefore(List<Account> lstAccount, Map<Id, Account> oldMap, boolean isDelete)
    {
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.AccountTriggerBefore (' + lstAccount.Size() + ' accounts, isDelete: ' + isDelete + ')');

		if (!isDelete)
			{
			for (Account a : lstAccount)
				{
				if (a.Type == 'Member' || a.Type == 'Member Subsidiary' || a.Type == 'Member Insured')
					a.Type2__c = 'Member';
				else if (a.Type == 'Prospect' || a.Type == 'Prospect Subsidiary' || a.Type == 'Former Member')
					a.Type2__c = 'Prospect';
				else
					a.Type2__c = 'Other';
				}
			}
		else
			{
			// get defendants and acq opp defendants
			// need to do this in the "before" trigger as defendants will already be deleted in the "after" trigger
			for(Defendant__c d : [Select Litigation_ID__c,
			                             (  select acquisition_opportunity__c
			                                from Acquisition_Opportunity_Defendants__r
			                                where acquisition_opportunity__c != null
			                             )
			                             From Defendant__c
			                             Where Account__c IN :lstAccount])
				{
				gLitsToUpdate.add(d.Litigation_ID__c);
				
				for (Acquisition_Opportunity_Defendant__c aod : d.Acquisition_Opportunity_Defendants__r)
					gAcqsToUpdate.add(aod.acquisition_opportunity__c);
				}

			System.Debug(MS_Tools.Debug, '...... found ' + gLitsToUpdate.Size() + ' litigations and ' + gAcqsToUpdate.Size() + ' acquisitions that need update');
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.AccountTriggerBefore');
    }

	//-------------------------------------------------------------------------------------------------------------------------
	// AccountTriggerAfter
	//-------------------------------------------------------------------------------------------------------------------------
	public static void AccountTriggerAfter(List<Account> lstAccount, Map<Id, Account> oldMap, boolean isDelete)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.AccountTriggerAfter (' + lstAccount.Size() + ' accounts, isDelete: ' + isDelete + ')');

		if (!isDelete)
			{
			// Preparing set of Account Ids that have modified value in Type field
			Set<Id> AccountIds = new Set<Id>();
			for (Account a : lstAccount)
				if (MS_Tools.isNewOrChanged(a, oldMap, 'Type2__c'))
					AccountIds.add(a.Id);
	
			if (!AccountIds.isEmpty())
				{
				System.Debug(MS_Tools.Debug, '...... found ' + AccountIds.Size() + ' accounts with changed Type2');

				// Fetching all Defendants related to Accounts determined above
				List<Defendant__c> lstDefendant = [Select id,
				                                          Account__c,
				                                          Litigation_ID__c
				                                   From Defendant__c
				                                   Where Account__c IN :AccountIds];
				if (!lstDefendant.isEmpty())
					{
					System.Debug(MS_Tools.Debug , '...... MS_LitigationInfo.AccountTriggerAfter (found ' + lstDefendant.Size() + ' defendants for ' + AccountIds.Size() + ' accounts)');
	
					// update defendant counts
					LitStats_Acquisition(lstDefendant);
					LitStats_Litigation(lstDefendant);
					}
				}
			}
		else
			{
			if (!gAcqsToUpdate.isEmpty())
				{
				System.Debug(MS_Tools.Debug, '...... found ' + gAcqsToUpdate.Size() + ' acquisitions that need update');
				LitStats_Acquisition(gAcqsToUpdate);
				gAcqsToUpdate.clear();
				}

			if (!gLitsToUpdate.isEmpty())
				{
				System.Debug(MS_Tools.Debug, '...... found ' + gLitsToUpdate.Size() + ' litigations that need update');
				LitStats_Litigation(gLitsToUpdate);
				gLitsToUpdate.clear();
				}
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.AccountTriggerAfter');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// AcqOppDefendantTriggerAfter
	//-------------------------------------------------------------------------------------------------------------------------
	public static void AcqOppDefendantTriggerAfter(List<Acquisition_Opportunity_Defendant__c> lstAODefendant)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.AcqOppDefendantTriggerAfter (' + lstAODefendant.Size() + ' acq opp defendants)');

		// only need to update acquisition records
		LitStats_Acquisition(lstAODefendant);

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.AcqOppDefendantTriggerAfter');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// DefendantTriggerBefore
	//-------------------------------------------------------------------------------------------------------------------------
	public static void DefendantTriggerBefore(List<Defendant__c> lstDefendant)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.DefendantTriggerBefore (' + lstDefendant.Size() + ' defendants)');

		for (Defendant__c d : lstDefendant)
			{
			// checking for changed values would take longer than just updating the field

			// need to set this field by code (instead of formula field) as formula fields cannot be used in SOQL groupings
			if (d.Date_Terminated__c != null || d.Status__c == 'Closed')
				d.Defendant_Active__c = 'No';
			else
				d.Defendant_Active__c = 'Yes';
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.DefendantTriggerBefore');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// DefendantTriggerAfter
	//-------------------------------------------------------------------------------------------------------------------------
	public static void DefendantTriggerAfter(List<Defendant__c> lstDefendant)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.DefendantTriggerAfter (' + lstDefendant.Size() + ' defendants)');

		LitStats_Acquisition(lstDefendant);
		LitStats_Litigation(lstDefendant);
		LitStats_Account(lstDefendant);

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.DefendantTriggerAfter');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitigationTriggerBefore
	//-------------------------------------------------------------------------------------------------------------------------
	public static void LitigationTriggerBefore(List<Litigation__c> lstLitigation, boolean isDelete)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.LitigationTriggerBefore (' + lstLitigation.Size() + ' litigations, isDelete: ' + isDelete + ')');

		if (!isDelete)
			{
			for (Litigation__c l : lstLitigation)
				{
				// checking for changed values would take longer than just updating the field
	
				// need to set this field by code (instead of formula field) as formula fields cannot be used in SOQL groupings
				// number fields are not groupable, so need to use a text field
				if (l.Filed__c != null)
					l.Filed_Year__c = String.valueOf(l.Filed__c.year());
				else
					l.Filed_Year__c = '';
				}
			}
		else
			{
			// get defendants and acq opp defendants
			// need to do this in the "before" trigger as defendants will already be deleted in the "after" trigger
			for(Defendant__c d : [Select account__c,
			                             (  select acquisition_opportunity__c
			                                from Acquisition_Opportunity_Defendants__r
			                                where acquisition_opportunity__c != null
			                             )
			                             From Defendant__c
			                             Where litigation_id__c IN :lstLitigation])
				{
				gAccsToUpdate.add(d.account__c);
				
				for (Acquisition_Opportunity_Defendant__c aod : d.Acquisition_Opportunity_Defendants__r)
					gAcqsToUpdate.add(aod.acquisition_opportunity__c);
				}

			System.Debug(MS_Tools.Debug, '...... found ' + gAccsToUpdate.Size() + ' accounts and ' + gAcqsToUpdate.Size() + ' acquisitions that need update');
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.LitigationTriggerBefore');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitigationTriggerAfter
	//-------------------------------------------------------------------------------------------------------------------------
	public static void LitigationTriggerAfter(List<Litigation__c> lstLitigation, Map<Id, Litigation__c> oldMap, boolean isDelete)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.LitigationTriggerAfterUpdate (' + lstLitigation.Size() + ' litigations, isDelete: ' + isDelete + ')');

		if (!isDelete)
			{
			// Preparing set of Litigation Ids that have modified value in Filed_Year__c / Active_or_Closed__c field
			Set<Id> litigationIds = new Set<Id>();
			for(Litigation__c lit : lstLitigation)
				if (MS_Tools.isNewOrChanged(lit, oldMap, 'Filed_Year__c') || MS_Tools.isNewOrChanged(lit, oldMap, 'Active_or_Closed__c'))
					litigationIds.add(lit.Id);
	
			if (!litigationIds.isEmpty())
				{
				System.Debug(MS_Tools.Debug, '...... found ' + litigationIds.Size() + ' litigations with changed status');

				// Fetching all Defendants related to Litigations
				List<Defendant__c> lstDefendant = [Select id, Account__c, Litigation_ID__c
				                                   from Defendant__c
				                                   Where Litigation_ID__c IN :litigationIds];
				if (!lstDefendant.isEmpty())
					{
					System.Debug(MS_Tools.Debug , '...... MS_LitigationInfo.LitigationTriggerAfterUpdate (updating ' + lstDefendant.Size() + ' defendants for ' + litigationIds.Size() + ' litigations)');
	
					// updating defendants will update litigation/defendant count fields
					// cannot call LitStats_<xxx>() directly, as we also need to update defendant records
					update lstDefendant;
					}
				}
			}
		else
			{
			if (!gAccsToUpdate.isEmpty())
				{
				System.Debug(MS_Tools.Debug, '...... found ' + gAccsToUpdate.Size() + ' accounts that need update');
				LitStats_Account(gAccsToUpdate);
				gAccsToUpdate.clear();
				}
	
			if (!gAcqsToUpdate.isEmpty())
				{
				System.Debug(MS_Tools.Debug, '...... found ' + gAcqsToUpdate.Size() + ' acquisitions that need update');
				LitStats_Acquisition(gAcqsToUpdate);
				gAcqsToUpdate.clear();
				}
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.LitigationTriggerAfterUpdate');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// RefreshAccount
	//-------------------------------------------------------------------------------------------------------------------------  
	public static void RefreshAccount(List<Account> lstAccount)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.RefreshAccount (' + lstAccount.Size() + ' accounts)');

		if (!lstAccount.isEmpty())
			{
			LitStats_Account(lstAccount, true, true);
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.RefreshAccount');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// RefreshAcquisition
	//-------------------------------------------------------------------------------------------------------------------------  
	public static void RefreshAcquisition(List<Acquisition_Opportunity__c> lstAcquisition, boolean isBefore)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.RefreshAcquisition (' + lstAcquisition.Size() + ' acquisitions, isBefore: ' + isBefore + ')');

		if (!lstAcquisition.isEmpty())
			{
			if (!isBefore)
				FixAcqOppDef_Acquisition(lstAcquisition);
			LitStats_Acquisition(lstAcquisition, !isBefore, true, isBefore);
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.RefreshAcquisition');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// RefreshLitigation
	//-------------------------------------------------------------------------------------------------------------------------  
	public static void RefreshLitigation(List<Litigation__c> lstLitigation, boolean isBefore)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_LitigationInfo.RefreshLitigation (' + lstLitigation.Size() + ' litigations, isBefore: ' + isBefore + ')');

		if (!lstLitigation.isEmpty())
			{
			LitStats_Litigation(lstLitigation, !isBefore, true, isBefore);
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_LitigationInfo.RefreshLitigation');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Account (from Defendant list)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Account(List<Defendant__c> lstDefendant)
		{
		System.Debug(MS_Tools.Debug , '...... enter LitStats_Account(lstDefendant) (' + lstDefendant.Size() + ' defendants)');

		// Limit the size of list by using Sets which do not contain duplicate elements
		// prevents hitting governor limits
		set<Id> AccIds = new set<Id>();
		for (Defendant__c d : lstDefendant)
			AccIds.add(d.Account__c);

		if (!AccIds.isEmpty())
			{
			LitStats_Account(AccIds);
			}
		else
			{
			System.Debug(MS_Tools.Debug, '...... no accounts found!');
			}

		System.Debug(MS_Tools.Debug , '...... leave  LitStats_Account(lstDefendant)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Account (from Account ID List)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Account(set<id> AccIds)
		{
		System.Debug(MS_Tools.Debug , '...... enter LitStats_Account(AccIds) (' + AccIds.Size() + ' account IDs)');

		// get list of accounts
		list<Account> Acc = [Select Id,
		                            Lits_filed_this_calendar_years__c,
		                            Lits_filed_last_years__c,
		                            Lits_filed_2_years_ago__c,
		                            Lits_filed_3_years_ago__c,
		                            Lits_filed_4_years_ago__c,
		                            Lits_filed_5_years_ago__c,
		                            Lits_filed_within_last_5_years_all__c,
		                            Lits_filed_within_last_5_years_Active__c,
		                            Refresh__c
				                 From Account
				                 Where Id IN :AccIds];

		LitStats_Account(Acc, false, false);

		System.Debug(MS_Tools.Debug , '...... leave  LitStats_Account(AccIds)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Account (from Account List)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Account(List<Account> lstAccount, boolean bReadOnly, boolean isRefresh)
		{
		// Aggregate queries have a limit of 2,000 rows.
		// Aggregate query will return 21 rows per Account plus 21 rows for summary
		// Maximum batch size = (2000-21)/21 = 94.
		final integer nMaxBatchSize = 94;

		System.Debug(MS_Tools.Debug , '...... enter LitStats_Account(lstAccount) (' + lstAccount.Size() + ' accounts, read-only: ' + bReadOnly + ', refresh: ' + isRefresh + ')');

		list<Account> Acc;
		
		if (bReadOnly)
			{
			// get list of accounts
			Acc = [Select Id,
		                Lits_filed_this_calendar_years__c,
		                Lits_filed_last_years__c,
		                Lits_filed_2_years_ago__c,
		                Lits_filed_3_years_ago__c,
		                Lits_filed_4_years_ago__c,
		                Lits_filed_5_years_ago__c,
		                Lits_filed_within_last_5_years_all__c,
		                Lits_filed_within_last_5_years_Active__c,
		                Refresh__c
				 From Account
				 Where Id IN :lstAccount];
			}
		else
			{
			Acc = lstAccount;
			}

		// Map will contain one account record Id per one account object
		map<Id, Account> AccMap = new map <Id, Account>();		
		for (Account a : Acc)
			{
			AccMap.put(a.Id, a);

			a.Lits_filed_this_calendar_years__c = 0;
			a.Lits_filed_last_years__c          = 0;
			a.Lits_filed_2_years_ago__c         = 0;
			a.Lits_filed_3_years_ago__c         = 0;
			a.Lits_filed_4_years_ago__c         = 0;
			a.Lits_filed_5_years_ago__c         = 0;
			a.Lits_filed_within_last_5_years_all__c    = 0;
			a.Lits_filed_within_last_5_years_Active__c = 0;
			
			if (isRefresh == true)
				a.Refresh__c = false;
			}

		// Aggregate queries have a limit of 2,000 rows.
		// Need to process accounts in batches to stay below that limit
		for (integer i = 0; i < Acc.Size(); i += nMaxBatchSize)
			{
			List<Account> AccQuery = GetSubList(Acc, i, nMaxBatchSize);

			// query all related Defendants; returns table with subtotals
			for (AggregateResult q : 
					[Select Account__c,
			            Defendant_Active__c defStatus, 
			            Litigation_ID__r.Filed_Year__c litFiled,
			            Grouping(Defendant_Active__c) grpStatus,
			            Grouping(Litigation_ID__r.Filed_Year__c) grpFiled,
			            Count_distinct(Litigation_ID__c) cnt
			     From Defendant__c
			     Where Account__c IN :AccQuery AND Litigation_ID__r.Filed_Year__c <= :sThisYear AND Litigation_ID__r.Filed_Year__c >= :s5YrsAgo
			     group by cube (Account__c, Defendant_Active__c, Litigation_ID__r.Filed_Year__c)
					]	
				)
				{
				Account a = AccMap.get((Id)q.get('Account__c'));
				if ( a == null )
					{
					System.Debug(MS_Tools.Finer , 'LitStats_Account() LOOP: no Acc in map for ' + (Id)q.get('Account__c'));
					continue;
					}
						 
				// q will be null if no records exist (e.g. last record deleted)
				if ( q != null )
					{
	
					String  defStatus = (String)q.get('defStatus');
					String 	slitFiled = (String)q.get('litFiled');
					Integer litFiled  = slitFiled != null ? Integer.valueOf(slitFiled) : 0;
					Integer grpStatus = (Integer)q.get('grpStatus');
					Integer grpFiled  = (Integer)q.get('grpFiled');
					Decimal cnt       = ((Decimal)q.get('cnt') == null ) ? 0 : (Decimal)q.get('cnt');
					
					System.Debug(MS_Tools.Finer , 'LitStats_Account() LOOP: Acc: ' + a.Id + ' ' +
					                                 'cnt: ' + cnt + ' ' + 
					                                 'grpStatus: \'' + grpStatus + '\' ' +
					                                 'grpFiled: \'' + grpFiled + '\' ' +
					                                 'defStatus: \'' + defStatus + '\' '+ 
					                                 'litFiled: \'' + litFiled + '\' ');
	
					if      (grpStatus == 1 && grpFiled == 0 && defStatus == null && litFiled == thisyear)
						a.Lits_filed_this_calendar_years__c = cnt;
					else if (grpStatus == 1 && grpFiled == 0 && defStatus == null && litFiled == thisyear-1)
						a.Lits_filed_last_years__c = cnt;
					else if (grpStatus == 1 && grpFiled == 0 && defStatus == null && litFiled == thisyear-2)
						a.Lits_filed_2_years_ago__c = cnt;
					else if (grpStatus == 1 && grpFiled == 0 && defStatus == null && litFiled == thisyear-3)
						a.Lits_filed_3_years_ago__c = cnt;
					else if (grpStatus == 1 && grpFiled == 0 && defStatus == null && litFiled == thisyear-4)
						a.Lits_filed_4_years_ago__c = cnt;
					else if (grpStatus == 1 && grpFiled == 0 && defStatus == null && litFiled == thisyear-5)
						a.Lits_filed_5_years_ago__c = cnt;
						
					if      (grpStatus == 1 && grpFiled == 0 && defStatus == null && litFiled <= thisyear && litFiled >= (thisyear-5))
						a.Lits_filed_within_last_5_years_all__c += cnt;
					else if (grpStatus == 0 && grpFiled == 0 && defStatus == 'Yes' && litFiled <= thisyear && litFiled >= thisyear-5)
						a.Lits_filed_within_last_5_years_Active__c += cnt;
					}
				}
			}

		// if account records exist, perform update of all account records
		// with a single DML statement
		if (!Acc.isEmpty())
			update Acc;

		System.Debug(MS_Tools.Debug , '...... leave  LitStats_Account (' + Acc.Size() + ' accounts updated)');		
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Acquisition (from Defendant list)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Acquisition(List<Defendant__c> lstDefendant)
		{
		System.Debug(MS_Tools.Debug , '...... enter LitStats_Acquisition(lstDefendant) (' + lstDefendant.Size() + ' defendants)');

		// get list of related acquisition opportunity defendants
		list<Acquisition_Opportunity_Defendant__c> lstAODefendant = 
				[Select id, 
				        Acquisition_Opportunity__c 
				 From Acquisition_Opportunity_Defendant__c
				 Where Acquisition_Opportunity__c != null AND Defendant__c IN :lstDefendant];

		LitStats_Acquisition(lstAODefendant);

		System.Debug(MS_Tools.Debug , '...... leave LitStats_Acquisition(lstDefendant)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Acquisition (from Acquisition Opportunity Defendant list)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Acquisition(List<Acquisition_Opportunity_Defendant__c> lstAODefendant)
		{
		System.Debug(MS_Tools.Debug , '...... enter LitStats_Acquisition(lstAODefendant) (' + lstAODefendant.Size() + ' acq opp defendants)');

		// Limit the size of list by using Sets which do not contain duplicate elements
		// prevents hitting governor limits
		set<Id> AcqIds = new set<Id>();
		for (Acquisition_Opportunity_Defendant__c aod : lstAODefendant)
		  AcqIds.add(aod.Acquisition_Opportunity__c);

		if (!AcqIds.isEmpty())
			{
			LitStats_Acquisition(AcqIds);
			}
		else
			{
			System.Debug(MS_Tools.Debug, '...... no aacquisitions found!');
			}

		System.Debug(MS_Tools.Debug , '...... leave LitStats_Acquisition(lstAODefendant)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Acquisition (from Acquisition Opportunity ID set)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Acquisition(Set<id> AcqIds)
		{
		System.Debug(MS_Tools.Debug , '...... enter LitStats_Acquisition(AcqIds) (' + AcqIds.Size() + ' aacquisition IDs)');

		// get list of acquisitions
		list<Acquisition_Opportunity__c> Acq = 
		    [Select Id,
				        N_Defendants__c, N_Members__c, N_Prospects__c,
				        N_Defendants_Active__c, N_Members_Active__c, N_Prospects_Active__c,
				        N_Defendants_Terminated__c, N_Members_Terminated__c, N_Prospects_Terminated__c,
				        Refresh__c
				 From Acquisition_Opportunity__c
				 Where Id IN :AcqIds];

		LitStats_Acquisition(Acq, false, false, false);

		System.Debug(MS_Tools.Debug , '...... leave LitStats_Acquisition(AcqIds)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Acquisition (from Acquisition Opportunity list)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Acquisition(List<Acquisition_Opportunity__c> lstAcquisition, boolean bReadOnly, boolean isRefresh, boolean isBefore)
		{
		// Aggregate queries have a limit of 2,000 rows.
		// Aggregate query will return 12 rows per Acquisition Opportunity plus 12 rows for summary
		// Maximum batch size = (2000-12)/12 = 165.
		final integer nMaxBatchSize = 165;

		System.Debug(MS_Tools.Debug , '...... enter LitStats_Acquisition(lstAcquisition) (' + lstAcquisition.Size() + ' acquisitions, read-only: ' + bReadOnly + ', refresh: ' + isRefresh + ', isBefore: ' + isBefore + ')');

		list<Acquisition_Opportunity__c> Acq;
		
		if (bReadOnly)
			{
			// get list of acquisitions
			Acq = [Select Id,
				            N_Defendants__c, N_Members__c, N_Prospects__c,
				            N_Defendants_Active__c, N_Members_Active__c, N_Prospects_Active__c,
				            N_Defendants_Terminated__c, N_Members_Terminated__c, N_Prospects_Terminated__c,
				            Refresh__c
				     From Acquisition_Opportunity__c
				     Where Id IN :lstAcquisition];
			}
		else
			{
			Acq = lstAcquisition;
			}

		// Map will contain one acquisition record Id per one acquisition object
		map<Id, Acquisition_Opportunity__c> AcqMap = new map <Id, Acquisition_Opportunity__c>();		
		for (Acquisition_Opportunity__c a : Acq)
			{
			AcqMap.put(a.Id, a);

			a.N_Defendants__c            = 0;
			a.N_Members__c               = 0;
			a.N_Prospects__c             = 0;

			a.N_Defendants_Active__c     = 0;
			a.N_Members_Active__c        = 0;
			a.N_Prospects_Active__c      = 0;

			// note: N_<xxx>_Terminated fields will be set below
			
			if (!isBefore && isRefresh)
				a.Refresh__c = false;
			}

		// Aggregate queries have a limit of 2,000 rows.
		// Need to process acquisitions in batches to stay below that limit
		for (integer i = 0; i < Acq.Size(); i += nMaxBatchSize)
			{
			List<Acquisition_Opportunity__c> AcqQuery = GetSubList(Acq, i, nMaxBatchSize);

			// query all related Acquisition Opportunity Defendants; returns table with subtotals
			for (AggregateResult q : 
					[Select Acquisition_Opportunity__c,
					        Defendant__r.Defendant_Active__c defStatus, 
					        Defendant__r.Account__r.Type2__c recType,
					        Grouping(Defendant__r.Defendant_Active__c) grpStatus,
					        Grouping(Defendant__r.Account__r.Type2__c) grpType,
					        Count_distinct(Defendant__r.Account__c) cnt
					 From Acquisition_Opportunity_Defendant__c
					 Where Acquisition_Opportunity__c IN :AcqQuery
					 group by cube (Acquisition_Opportunity__c,
					                Defendant__r.Defendant_Active__c, 
					                Defendant__r.Account__r.Type2__c)
					]
				)
				{
				Acquisition_Opportunity__c a = AcqMap.get((Id)q.get('Acquisition_Opportunity__c'));
				if ( a == null )
					{
					System.Debug(MS_Tools.Finer , 'LitStats_Acquisition() LOOP: no Acq in map for ' + (Id)q.get('Acquisition_Opportunity__c'));
					continue;
					}
						 
				// q will be null if no records exist (e.g. last record deleted)
				if ( q != null )
					{
					String  defStatus = (String)q.get('defStatus');
					String  recType   = (String)q.get('recType');
					Integer grpStatus = (Integer)q.get('grpStatus');
					Integer grpType   = (Integer)q.get('grpType');
					Decimal cnt       = ((Decimal)q.get('cnt') == null ) ? 0 : (Decimal)q.get('cnt');
					
					System.Debug(MS_Tools.Finer , 'LitStats_Acquisition() LOOP: Acq: ' + a.Id + ' ' +
					                                 'cnt: ' + cnt + ' ' + 
					                                 'grpStatus: \'' + grpStatus + '\' ' +
					                                 'grpType: \'' + grpType + '\' ' +
					                                 'defStatus: \'' + defStatus + '\' '+ 
					                                 'recType: \'' + recType + '\' ');
	
					if      (grpStatus == 1 && grpType == 1 && defStatus == null && recType == null)
						a.N_Defendants__c += cnt;
					else if (grpStatus == 1 && grpType == 0 && defStatus == null && recType == 'Member')
						a.N_Members__c += cnt;
					else if (grpStatus == 1 && grpType == 0 && defStatus == null && recType == 'Prospect')
						a.N_Prospects__c += cnt;
					else if (grpStatus == 0 && grpType == 1 && defStatus == 'Yes' && recType == null)
						a.N_Defendants_Active__c += cnt;
					else if (grpStatus == 0 && grpType == 0 && defStatus == 'Yes' && recType == 'Member')
						a.N_Members_Active__c += cnt;
					else if (grpStatus == 0 && grpType == 0 && defStatus == 'Yes' && recType == 'Prospect')
						a.N_Prospects_Active__c += cnt;
					}
				}
			}

		// set "terminated" counts
		for (Acquisition_Opportunity__c a : Acq)
			{
			a.N_Defendants_Terminated__c = a.N_Defendants__c - a.N_Defendants_Active__c;
			a.N_Members_Terminated__c    = a.N_Members__c    - a.N_Members_Active__c;
			a.N_Prospects_Terminated__c  = a.N_Prospects__c  - a.N_Prospects_Active__c;
			}

		// if acquisition records exist, perform update of all acquisition records
		// with a single DML statement
		if (!isBefore && !Acq.isEmpty())
			update Acq;

		System.Debug(MS_Tools.Debug , '...... leave  LitStats_Acquisition(lstAcquisition) (' + Acq.Size() + ' acquisitions updated)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Litigation (from Defendant list)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Litigation(List<Defendant__c> lstDefendant)
		{
		System.Debug(MS_Tools.Debug , '...... enter LitStats_Litigation(lstDefendant) (' + lstDefendant.Size() + ' defendants)');

		// Limit the size of list by using Sets which do not contain duplicate elements
		// prevents hitting governor limits
		set<Id> LitIds = new set<Id>();
		for (Defendant__c d : lstDefendant)
		  LitIds.add(d.Litigation_ID__c);

		if (!LitIds.isEmpty())
			{
			LitStats_Litigation(LitIds);
			}
		else
			{
			System.Debug(MS_Tools.Debug, '...... no litigations found!');
			}

		System.Debug(MS_Tools.Debug , '...... leave  LitStats_Litigation(lstDefendant)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Litigation (from Litigation Id set)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Litigation(set<id> LitIds)
		{
		System.Debug(MS_Tools.Debug , '...... enter LitStats_Litigation(LitIds) (' + LitIds.Size() + ' litigation IDs)');

		list<litigation__c>	Lit = [Select Id,
					                            N_Defendants__c, N_Members__c, N_Prospects__c,
					                            N_Defendants_Active__c, N_Members_Active__c, N_Prospects_Active__c,
					                            N_Defendants_Terminated__c, N_Members_Terminated__c, N_Prospects_Terminated__c,
					                            Refresh__c
					                     From Litigation__c
					                     Where Id IN :LitIds];

		LitStats_Litigation(Lit, false, false, false);

		System.Debug(MS_Tools.Debug , '...... leave  LitStats_Litigation(LitIds)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// LitStats_Litigation (from Litigation list)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void LitStats_Litigation(List<Litigation__c> lstLitigation, boolean bReadOnly, boolean isRefresh, boolean isBefore)
		{
		// Aggregate queries have a limit of 2,000 rows.
		// Aggregate query will return 12 rows per Litigation plus 12 rows for summary
		// Maximum batch size = (2000-12)/12 = 165.
		final integer nMaxBatchSize = 165;

		System.Debug(MS_Tools.Debug , '...... enter LitStats_Litigation(lstLitigation) (' + lstLitigation.Size() + ' litigations, read-only: ' + bReadOnly + ', refresh: ' + isRefresh + ', isBefore: ' + isBefore + ')');

		list<Litigation__c> Lit;
		
		if (bReadOnly)
			{
			// get list of litigations
			Lit = [Select Id,
					          N_Defendants__c, N_Members__c, N_Prospects__c,
					          N_Defendants_Active__c, N_Members_Active__c, N_Prospects_Active__c,
					          N_Defendants_Terminated__c, N_Members_Terminated__c, N_Prospects_Terminated__c,
					          Refresh__c
					   From Litigation__c
					   Where Id IN :lstLitigation];
			}
		else
			{
			Lit = lstLitigation;
			}

		// Map will contain one litigation record Id per one litigation object
		map<Id, Litigation__c> LitMap = new map <Id, Litigation__c>();		
		for (Litigation__c l : Lit)
			{
			LitMap.put(l.Id, l);

			l.N_Defendants__c            = 0;
			l.N_Members__c               = 0;
			l.N_Prospects__c             = 0;

			l.N_Defendants_Active__c     = 0;
			l.N_Members_Active__c        = 0;
			l.N_Prospects_Active__c      = 0;

			// note: N_<xxx>_Terminated fields will be set below
			
			if (!isBefore && isRefresh)
				l.Refresh__c = false;
			}

		// Aggregate queries have a limit of 2,000 rows.
		// Need to process litigations in batches to stay below that limit
		for (integer i = 0; i < Lit.Size(); i += nMaxBatchSize)
			{
			List<Litigation__c> LitQuery = GetSubList(Lit, i, nMaxBatchSize);

			// query all related Defendants; returns table with subtotals
			for (AggregateResult q : 
			    [Select Litigation_ID__c,
					        Defendant_Active__c defStatus, 
					        Account__r.Type2__c recType,
					        Grouping(Defendant_Active__c) grpStatus,
					        Grouping(Account__r.Type2__c) grpType,
					        Count_distinct(Account__c) cnt
					 From Defendant__c
					 Where Litigation_ID__c IN :LitQuery
					 group by cube (Litigation_ID__c,
					                Defendant_Active__c, 
					                Account__r.Type2__c)
					]
				)
				{
				Litigation__c l = LitMap.get((Id)q.get('Litigation_ID__c'));
				if ( l == null )
					{
					System.Debug(MS_Tools.Finer , 'LitStats_Litigation() LOOP: no Lit in map for ' + (Id)q.get('Litigation_ID__c'));
					continue;
					}
						 
				// q will be null if no records exist (e.g. last record deleted)
				if ( q != null )
					{
					String  defStatus = (String)q.get('defStatus');
					String  recType   = (String)q.get('recType');
					Integer grpStatus = (Integer)q.get('grpStatus');
					Integer grpType   = (Integer)q.get('grpType');
					Decimal cnt       = ((Decimal)q.get('cnt') == null ) ? 0 : (Decimal)q.get('cnt');
					
					System.Debug(MS_Tools.Finer , 'LitStats_Litigation() LOOP: Lit: ' + l.Id + ' ' +
					                                 'cnt: ' + cnt + ' ' + 
					                                 'grpStatus: \'' + grpStatus + '\' ' +
					                                 'grpType: \'' + grpType + '\' ' +
					                                 'defStatus: \'' + defStatus + '\' '+ 
					                                 'recType: \'' + recType + '\' ');
	
					if      (grpStatus == 1 && grpType == 1 && defStatus == null && recType == null)
						l.N_Defendants__c += cnt;
					else if (grpStatus == 1 && grpType == 0 && defStatus == null && recType == 'Member')
						l.N_Members__c += cnt;
					else if (grpStatus == 1 && grpType == 0 && defStatus == null && recType == 'Prospect')
						l.N_Prospects__c += cnt;
					else if (grpStatus == 0 && grpType == 1 && defStatus == 'Yes' && recType == null)
						l.N_Defendants_Active__c += cnt;
					else if (grpStatus == 0 && grpType == 0 && defStatus == 'Yes' && recType == 'Member')
						l.N_Members_Active__c += cnt;
					else if (grpStatus == 0 && grpType == 0 && defStatus == 'Yes' && recType == 'Prospect')
						l.N_Prospects_Active__c += cnt;
					}
				}
			}

		// set "terminated" counts
		for (Litigation__c l : Lit)
			{
			l.N_Defendants_Terminated__c = l.N_Defendants__c - l.N_Defendants_Active__c;
			l.N_Members_Terminated__c    = l.N_Members__c    - l.N_Members_Active__c;
			l.N_Prospects_Terminated__c  = l.N_Prospects__c  - l.N_Prospects_Active__c;
			}

		// if litigation records exist, perform update of all litigation records
		// with a single DML statement
		if (!isBefore && !Lit.isEmpty())
			update Lit;

		System.Debug(MS_Tools.Debug , '...... leave  LitStats_Litigation(lstLitigation) (' + Lit.Size() + ' litigations updated)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// FixAcqOppDef_Acquisition
	//-------------------------------------------------------------------------------------------------------------------------  
	private static void FixAcqOppDef_Acquisition(List<Acquisition_Opportunity__c> lstAcquisition)
		{
		System.Debug(MS_Tools.Debug , '...... enter FixAcqOppDef_Acquisition (' + lstAcquisition.Size() + ' acquisitions)');

		list<Acquisition_Opportunity_Defendant__c> AODToUpsert = new list<Acquisition_Opportunity_Defendant__c>();

		// create map (kind of ...)
		Set<String> SetAOD = new Set<String>();
		for (Acquisition_Opportunity_Defendant__c AOD : [Select id,
		                                                        Defendant__c,
		                                                        Acquisition_Opportunity__c,
		                                                        Account_Lookup__c
		                                                 From Acquisition_Opportunity_Defendant__c
		                                                 Where Defendant__c != null AND
		                                                       Acquisition_Opportunity__c != null AND
		                                                       Acquisition_Opportunity__c IN :lstAcquisition])
			{
			String s = AOD.Defendant__c + '##' + AOD.Acquisition_Opportunity__c;
			SetAOD.add(s);
			
			// updating will run trigger that adds Account lookup
			if (AOD.Account_Lookup__c == null)
				AODToUpsert.add(AOD);
			}
			
		System.Debug(MS_Tools.Fine , '...... found ' + SetAOD.Size() + ' acq opp defendants');

		// get Litigation Ids via Opportunity Litigations
		list<Opportunity_Litigation__c> LstOppLit = [Select id,
		                                                    Acquisition_Opportunity__c,
		                                                    Acquisition_Opportunity__r.name,
		                                                    Litigation__c
		                                             From Opportunity_Litigation__c
		                                             Where Litigation__c != null AND
		                                                   Acquisition_Opportunity__c != null AND
		                                                   Acquisition_Opportunity__c IN :lstAcquisition];
		
		System.Debug(MS_Tools.Fine , '...... found ' + LstOppLit.Size() + ' opportunity litigations');
		
		Set<Id> LitigationIds = new Set<Id>();
		for (Opportunity_Litigation__c OppLit : LstOppLit)
			LitigationIds.add(OppLit.Litigation__c);

		System.Debug(MS_Tools.Fine , '...... found ' + LitigationIds.Size() + ' litigations');

		map<Id,Litigation__c> mapLitigation = new map<Id,Litigation__c>([Select (Select Id,
		                                                                                Account__r.name,
		                                                                                Litigation_ID__r.name
		                                                                         From Defendants__r)
		                                                                 From Litigation__c
		                                                                 where Id IN :LitigationIds]);

		integer nAdded = 0;
		for (Opportunity_Litigation__c OppLit : LstOppLit)
			{
			if (mapLitigation.containsKey(OppLit.Litigation__c))
				{
				for (Defendant__c def : mapLitigation.get(OppLit.Litigation__c).Defendants__r)
					{
					String s = def.Id + '##' + OppLit.Acquisition_Opportunity__c;
					if (SetAOD.contains(s))
						{
						System.Debug(MS_Tools.Finer, 'AOD found for ' + def.account__r.name + ' - ' + def.litigation_id__r.name + ' - ' + OppLit.acquisition_opportunity__r.name);
						}
					else
						{
						System.Debug(MS_Tools.Debug, 'adding AOD for ' + def.account__r.name + ' - ' + def.litigation_id__r.name + ' - ' + OppLit.acquisition_opportunity__r.name);

						//Create an Acquisition Opportunity Defendant record;
						Acquisition_Opportunity_Defendant__c NewAOD = new Acquisition_Opportunity_Defendant__c();
						NewAOD.Acquisition_Opportunity__c = OppLit.Acquisition_Opportunity__c;
						NewAOD.Defendant__c = def.Id;
						NewAOD.Defendant_Status__c = 'Open';
						AODToUpsert.add(NewAOD);
						
						nAdded++;
						}
					}
				}
			}

		if (!AODToUpsert.IsEmpty())
			upsert AODToUpsert;

		System.Debug(MS_Tools.Debug , '...... leave FixAcqOppDef_Acquisition(lstAcquisition) (' + nAdded + ' acq opp defendants added, ' + (AODToUpsert.Size() - nAdded) + ' AODs fixed)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// GetSubList (Account)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static list<Account> GetSubList(List<Account> lst, integer nStart, integer nCount)
		{
		integer j = 0;
		list<Account> SubList = new list<Account>();

		while (j < nCount && nStart+j < lst.Size())
			{				
			SubList.add(lst.get(nStart+j));
			j++;
			}

		return SubList;
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// GetSubList (Acquisition_Opportunity__c)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static list<Acquisition_Opportunity__c> GetSubList(List<Acquisition_Opportunity__c> lst, integer nStart, integer nCount)
		{
		integer j = 0;
		list<Acquisition_Opportunity__c> SubList = new list<Acquisition_Opportunity__c>();

		while (j < nCount && nStart+j < lst.Size())
			{				
			SubList.add(lst.get(nStart+j));
			j++;
			}

		return SubList;
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// GetSubList (Litigation__c)
	//-------------------------------------------------------------------------------------------------------------------------  
	private static list<Litigation__c> GetSubList(List<Litigation__c> lst, integer nStart, integer nCount)
		{
		integer j = 0;
		list<Litigation__c> SubList = new list<Litigation__c>();

		while (j < nCount && nStart+j < lst.Size())
			{				
			SubList.add(lst.get(nStart+j));
			j++;
			}

		return SubList;
		}

	}