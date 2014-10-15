/*
    Class        : MS_RefreshObjects
    Description  : Refresh calculated fields on various objects (account, litigation, acquisition)
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

public without sharing class MS_RefreshObjects
	{
	//
	// Refresh functions need to reset "Refresh" checkbox!
	//
	// For refresh functions that run on "BEFORE" triggers, this is best done here. Refresh functions that run on "AFTER"
	// triggers should reset it after querying the objects that need to be refreshed.
	//
	// Refresh functions that run on the same trigger event (insert, update, delete, undelete) on "BEFORE" and "AFTER"
	// triggers need to reset it on the "AFTER" trigger (otherwise the "AFTER" trigger part will never be executed).
	//

	//-------------------------------------------------------------------------------------------------------------------------
	// RefreshAccount
	//-------------------------------------------------------------------------------------------------------------------------
	public static void RefreshAccount(List<Account> lstAccount)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_RefreshObjects.RefreshAccount (' + lstAccount.Size() + ' accounts)');

		List<Account> AccToRefresh = new List<Account>();
		for (Account a :lstAccount)
			{
			if (a.Refresh__c == true)
				{
				AccToRefresh.add(a);
				}
			}

		// check if there are accounts that need update
		if (!AccToRefresh.isEmpty())
			{
			//
			// add refresh functions for accounts here
			//
			MS_LitigationInfo.RefreshAccount(AccToRefresh);
			MS_AccountEntiTree.RefreshAccount(AccToRefresh);
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_RefreshObjects.RefreshAccount (' + AccToRefresh.Size() + ' accounts refreshed)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// RefreshAcquisition
	//-------------------------------------------------------------------------------------------------------------------------
	public static void RefreshAcquisition(List<Acquisition_Opportunity__c> lstAcquisition, boolean isBefore)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_RefreshObjects.RefreshAcquisition (' + lstAcquisition.Size() + ' acquisitions, isBefore: '+ isBefore + ')');

		List<Acquisition_Opportunity__c> AcqToRefresh = new List<Acquisition_Opportunity__c>();
		for (Acquisition_Opportunity__c acq :lstAcquisition)
			{
			if (acq.Refresh__c == true)
				{
				AcqToRefresh.add(acq);

				if (isBefore)
					acq.Refresh__c = false;
				}
			}

		// check if there are accounts that need update
		if (!AcqToRefresh.isEmpty())
			{
			//
			// add refresh functions for acquisitions here
			//
			MS_LitigationInfo.RefreshAcquisition(AcqToRefresh, isBefore);
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_RefreshObjects.RefreshAcquisition (' + AcqToRefresh.Size() + ' acquisitions refreshed)');
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// RefreshLitigation
	//-------------------------------------------------------------------------------------------------------------------------
	public static void RefreshLitigation(List<Litigation__c> lstLitigation, boolean isBefore)
		{
		System.Debug(MS_Tools.Debug , '--- enter MS_RefreshObjects.RefreshLitigation (' + lstLitigation.Size() + ' litigations, isBefore: '+ isBefore + ')');

		List<Litigation__c> LitToRefresh = new List<Litigation__c>();
		for (Litigation__c l :lstLitigation)
			{
			if (l.Refresh__c == true)
				{
				LitToRefresh.add(l);

				if (isBefore)
					l.Refresh__c = false;
				}
			}

		// check if there are accounts that need update
		if (!LitToRefresh.isEmpty())
			{
			//
			// add refresh functions for litigations here
			//
			MS_LitigationInfo.RefreshLitigation(LitToRefresh, isBefore);
			}

		System.Debug(MS_Tools.Debug , '--- leave MS_RefreshObjects.RefreshLitigation (' + LitToRefresh.Size() + ' of ' + lstLitigation.Size() + ' litigations refreshed)');
		}

	}