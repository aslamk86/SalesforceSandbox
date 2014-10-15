/*
    Class        : MS_AccountsAndLitigationsCtrl
    Description  : Controller for Accounts and Litigations page
    Created By   : Martin Sieler
    Created Date : October 24, 2012
*/

public without sharing class MS_AccountsAndLitigationsCtrl
	{
	private Map<String, String> pageParams;
	public User RunningUser{get;set;}
	public Account SelectedAccount{get;set;}

	// data tables
	public list<AccountWrapper>     lstAccounts{get;set;}
	public list<AcquisitionWrapper> lstAcquisitions{get;set;}
	public list<DefendantWrapper>   lstDefendants{get;set;}
	
	private list<Account> lstAccWithMembershipOppy;

	// sort fields
	public  String  Acc_CurrentSortColumn{get;set;}
	public  boolean Acc_IsAsc{set;get;}
	private String  Acc_PreviousSortColumn;

	public  String  Acq_CurrentSortColumn{get;set;}
	public  boolean Acq_IsAsc{set;get;}
	private String  Acq_PreviousSortColumn;

	public  String  Lit_CurrentSortColumn{get;set;}
	public  boolean Lit_IsAsc{set;get;}
	private String  Lit_PreviousSortColumn;

	// options for account selection
	public String TimeFrame{get;set;}
	public list<SelectOption> TimeFrameItems{get;set;}

	public list<String> Users{get;set;}
	public list<SelectOption> UsersItems{get;set;}
	private boolean UsersAllSelected;

	public list<String> OppyType{get;set;}
	public list<SelectOption> OppyTypeItems{get;set;}

	// options for acquisition filtering
	public list<String> NCS{get;set;}
	public list<SelectOption> NCSItems{get;set;}

	public list<String> Priority{get;set;}
	public list<SelectOption> PriorityItems{get;set;}

	public list<String> Stage{get;set;}
	public list<SelectOption> StageItems{get;set;}

	public String MinAllAccounts{get;set;}
	public String MinMyAccounts{get;set;}
	public String MinRedHeatmap{get;set;}

	public boolean AcqOnlyActive{get;set;}	
	public boolean AcqMoreOptions{get;set;}

	// options for litigation filtering
	public boolean OnlyNPE{get;set;}
	public boolean OnlyDJ{get;set;}
	public boolean OnlyActive{get;set;}
	public boolean OnlyWithoutAcquisition{get;set;}

	// general viewing options
	public boolean bMemberMode{get;set;}
	public boolean bAccMemberView{get;set;}
	public boolean AccOptions{get;set;}

/*
private static String FIELDS_CSV = 'bInsuranceOpportunity, InsCloseDate, InsStage';
public String[] fields { get { return parseCsv(FIELDS_CSV);} }
private String[] parseCsv(String s)
	{
	List<String> l = new List<String>();
	for (String f : s.split(','))
		{
		l.add(f.trim());
		}
	return l;
	}
*/

	//---------------------------------------------------------------------------
	// Constructor
	//---------------------------------------------------------------------------
	public MS_AccountsAndLitigationsCtrl()
		{
		pageParams = Apexpages.currentPage().getParameters();

		//
		// get running user
		//
		RunningUser = null;
		String sUser = pageParams.get('User');

		if (!MS_Tools.isBlankString(sUser))
			{
			sUser = '%' + sUser.Trim() + '%';
			
			for (User u : [Select Id, Name from User where name like :sUser limit 1])
				RunningUser = u;
			}

		if (RunningUser == null)
			{
			Id xId = UserInfo.getUserId();

			RunningUser = [Select Id, Name from User where Id = :xId limit 1];
			}

		//
		// init
		//
		lstAccounts     = new list<AccountWrapper>();
		lstAcquisitions = new list<AcquisitionWrapper>();
		lstDefendants   = new list<DefendantWrapper>();

		lstAccWithMembershipOppy = [Select Id From Account Where Id IN (Select AccountId From Opportunity Where RecordType.Name = 'Membership' AND isClosed = false)];

		//
		// sort fields
		//
		Acc_CurrentSortColumn  = 'RenewalDate__c';
		Acc_PreviousSortColumn = '';     
		Acc_IsAsc              = true;

		Acq_CurrentSortColumn  = 'XX_MyAccounts';
		Acq_PreviousSortColumn = '';     
		Acq_IsAsc              = false;

		Lit_CurrentSortColumn  = 'Litigation_ID__r.Filed__c';
		Lit_PreviousSortColumn = '';     
		Lit_IsAsc              = false;

		//
		// options for account selection
		//
		TimeFrameItems = new List<SelectOption>();
		TimeFrameItems.add(new SelectOption('THIS_MONTH','This month'));
		TimeFrameItems.add(new SelectOption('THIS_QUARTER','This quarter'));
		TimeFrameItems.add(new SelectOption('THIS_MONTH,NEXT_N_MONTHS:6','Next six months'));
		TimeFrameItems.add(new SelectOption('THIS_MONTH,NEXT_N_MONTHS:12','Next 12 months'));
		TimeFrameItems.add(new SelectOption('All','All'));

		TimeFrame = 'THIS_QUARTER';

		UsersItems = new List<SelectOption>();
		Users = new list<String>();
		UsersAllSelected = false;

		OppyTypeItems = new List<SelectOption>();
		OppyTypeItems.add(new SelectOption('MyAccWithOppy','My Accounts with Membership Opportunities'));
		OppyTypeItems.add(new SelectOption('AccWithMyOppy','Accounts that I do not own with My Membership Opportunities'));
		OppyTypeItems.add(new SelectOption('NoOppy','My Accounts Without Membership Opportunities'));

		OppyType = new list<String>();
		OppyType.add('MyAccWithOppy');

		//
		// options for acquisition filtering
		//
		MinAllAccounts = '';
		MinMyAccounts  = '';
		MinRedHeatMap  = '';

		AcqOnlyActive  = true;
		AcqMoreOptions = false;

		NCSItems = new List<SelectOption>();
		NCS = new list<String>();

		PriorityItems = new List<SelectOption>();
		Priority = new list<String>();

		StageItems = new List<SelectOption>();
		Stage = new list<String>();

		InitAcquisitionFilters();

		//
		// options for litigation filtering
		//
		OnlyNPE                = true;
		OnlyDJ                 = false;
		OnlyActive             = true;
		OnlyWithoutAcquisition = true;

		//
		// general viewing options
		//
		bMemberMode = true;
		bAccMemberView = true;
		AccOptions = true;

		//
		// determine mode
		//
		Id xId      = pageParams.get('Id');
		String mode = pageParams.get('Mode');

		SelectedAccount = null;
		if (xId != null && xId.getSObjectType() == Account.sObjectType)
			{
			Acc_CurrentSortColumn  = 'Name';

			bMemberMode = false;
			bAccMemberView = false;
			AccOptions = false;

			SelectedAccount = [Select id, name, Entity_ID__c, Ultimate_Parent_Entity_ID__c, SFDC_Ultimate_Parent_ID__c
			                   From Account Where id = :xId limit 1];
			}
		else if (!MS_Tools.isBlankString(mode) && mode == 'Prospect')
			{
			//
			// Prospect Mode
			//
			Acc_CurrentSortColumn  = 'Name';

			bMemberMode = false;
			bAccMemberView = false;
			}
		else
			{
			//
			// Member Mode
			//
			}

		if (SelectedAccount == null)
			QueryUsers();

		//
		// get data
		//
		UpdateAll();
		}

	//---------------------------------------------------------------------------
	// UpdateAll
	//---------------------------------------------------------------------------
	public void UpdateAll()
		{
		QueryAccounts();
		UpdateAcqAndLit();
		}

	//---------------------------------------------------------------------------
	// UpdateAcqAndLit
	//---------------------------------------------------------------------------
	public void UpdateAcqAndLit()
		{
		QueryAcquisitions();
		QueryLitigations();
		}

	//---------------------------------------------------------------------------
	// ToggleAcqMoreOptions
	//---------------------------------------------------------------------------
	public void ToggleAcqMoreOptions()
		{
		AcqMoreOptions = !AcqMoreOptions;
		
		if (!AcqMoreOptions)
			{
			InitAcquisitionFilters();
			QueryAcquisitions();
			}
		}

	//---------------------------------------------------------------------------
	// SortAccounts
	//---------------------------------------------------------------------------
	public void SortAccounts()
		{
		if (!MS_Tools.isBlankString(Acc_PreviousSortColumn))
			Acc_IsAsc = Acc_PreviousSortColumn.equals(Acc_CurrentSortColumn) ? !Acc_IsAsc : true;

		Acc_PreviousSortColumn = Acc_CurrentSortColumn;
		
		lstAccounts.sort();
		}

	//---------------------------------------------------------------------------
	// SortAcquisitions
	//---------------------------------------------------------------------------
	public void SortAcquisitions()
		{
		if (!MS_Tools.isBlankString(Acq_PreviousSortColumn))
			Acq_IsAsc = Acq_PreviousSortColumn.equals(Acq_CurrentSortColumn) ? !Acq_IsAsc : true;

		Acq_PreviousSortColumn = Acq_CurrentSortColumn;
		
		lstAcquisitions.sort();
		}

	//---------------------------------------------------------------------------
	// SortLitigations
	//---------------------------------------------------------------------------
	public void SortLitigations()
		{
		if (!MS_Tools.isBlankString(Lit_PreviousSortColumn))
			Lit_IsAsc = Lit_PreviousSortColumn.equals(Lit_CurrentSortColumn) ? !Lit_IsAsc : true;

		Lit_PreviousSortColumn = Lit_CurrentSortColumn;

		lstDefendants.sort();
		}

	//---------------------------------------------------------------------------
	// QueryUsers
	//---------------------------------------------------------------------------
	private void QueryUsers()
		{
		boolean isUpdate = UsersItems.Size() > 0 ? true : false;

		if (isUpdate)
			{
			boolean AllSelected = false;

			for (String s : Users)
				if (s == 'All')
					AllSelected = true;

			if (AllSelected)
				{
				UsersAllSelected = true;

				Users.clear();
				for (SelectOption so : UsersItems)
					Users.add(so.getValue());
				}
			else if (UsersAllSelected)
				{
				UsersAllSelected = false;
				Users.clear();
				}
			}
		else
			{
			Users.clear();
			UsersItems.clear();
			}

		String query = '';

		if (bMemberMode)
			{
			query = 'Select id, name from User where Id in '
			      + '('
			      + '  Select OwnerId '
			      + '  From Account '
			      + '  Where RecordType.Name = \'Member\' AND '
			      +    (isUpdate ? GetTimeFilter(TimeFrame, bMemberMode) : GetTimeFilter('All', bMemberMode))
			      + ') '
			      + 'Order By firstname desc';
			}
		else
			{
			set<id> OwnerIds = new set<id>();
			for (Opportunity Opp : [select Account.OwnerId from Opportunity where RecordType.Name = 'Membership' AND isClosed = false AND Account.RecordType.Name != 'Member'])
				OwnerIds.add(Opp.Account.OwnerId);

			for (Opportunity Opp : [select OwnerId from Opportunity where RecordType.Name = 'Membership' AND isClosed = false AND Account.RecordType.Name != 'Member'])
				OwnerIds.add(Opp.OwnerId);

			query = 'Select id, name from User where Id in '
			      + ':OwnerIds '
			      + 'Order By firstname desc';
			}

		if (!isUpdate)
			{
			map<id, User> mapUser = new map<id, User>();
			for (User u : Database.query(query))
				mapUser.put(u.id, u);

			list<user> lu = mapUser.values();
			lu.sort();
			for (User u : lu)
				{
				UsersItems.add(new SelectOption(u.id, u.name));
				
				if (u.Id == RunningUser.Id)
					Users.add(u.Id);
				}
			
			UsersItems.add(new SelectOption('All', 'All'));
			}
		}

	//---------------------------------------------------------------------------
	// QueryAccounts
	//---------------------------------------------------------------------------
	private void QueryAccounts()
		{
		lstAccounts.clear();
		Acc_PreviousSortColumn = '';

		String query = 'Select Id, Name, Type, Type2__c, RenewalDate__c, RPX_RCRate__c, HeatMapColor__c, HeatMapColorDisplay__c, OwnerId, Owner.name, '
		             + 'SFDC_Ultimate_Parent_ID__c, Entity_ID__c, Ultimate_Parent_Entity_ID__c, '
		             + '(select id, name, ownerid, owner.name, amount, stagename, closedate, recordtype.name '
		             + ' from Opportunities '
		             + ' where isclosed = false AND '
		             +'        (recordtype.name = \'Insurance\' or recordtype.name = \'Membership\')'
		             + '), '
		             + '(select id, defendant_active__c from defendants__r) '
		             + 'From Account ';

		String filter = '';

		set<id> UserIds = new set<id>();
		Id AccId = null;

		if (SelectedAccount != null)
			{
			//
			// account view mode
			//
			AccId = SelectedAccount.Id;

			filter = 'Where id = :AccId OR '
			       + 'SFDC_Ultimate_Parent_ID__c = \'' + SelectedAccount.SFDC_Ultimate_Parent_ID__c + '\' OR '
			       + 'Entity_ID__c = ' + SelectedAccount.Ultimate_Parent_Entity_ID__c + ' OR '
			       + 'Ultimate_Parent_Entity_ID__c = ' + SelectedAccount.Entity_ID__c + ' OR '
			       + 'Ultimate_Parent_Entity_ID__c = ' + SelectedAccount.Ultimate_Parent_Entity_ID__c + ' '
			       ;
			}
		else if (bMemberMode)
			{
			//
			// member mode
			//
			QueryUsers();

			for (String s : Users)
				if (s != 'All')
					UserIds.add(s);

			filter = 'Where RecordType.Name = \'Member\' AND '
			       + 'OwnerId IN :UserIds AND '
			       + GetTimeFilter(TimeFrame, bMemberMode);
			}
		else
			{
			//
			// prospect mode
			//
			QueryUsers();

			for (String s : Users)
				if (s != 'All')
					UserIds.add(s);

			boolean MyAccWithOppy = false;
			boolean AccWithMyOppy = false;
			boolean NoOppy        = false;
			
			for (String s : OppyType)
				{
				if (s == 'MyAccWithOppy')
					MyAccWithOppy = true;
				else if (s == 'AccWithMyOppy')
					AccWithMyOppy = true;
				else if (s == 'NoOppy')
					NoOppy = true;
				}

			if (MyAccWithOppy || AccWithMyOppy)
				{
				if (!MS_Tools.isBlankString(filter))
					filter += ' OR ';

				String UserFilter = '';
				
				if (MyAccWithOppy)
					{
					if (!MS_Tools.isBlankString(UserFilter))
						UserFilter += ' OR ';

					UserFilter += ' (Account.OwnerId IN :UserIds) ';
					}

				if (AccWithMyOppy)
					{
					if (!MS_Tools.isBlankString(UserFilter))
						UserFilter += ' OR ';

					UserFilter += ' (Account.OwnerId NOT IN :UserIds AND OwnerId IN :UserIds) ';
					}

				UserFilter = ' (' + UserFilter + ') ';

				filter += '('
			          + 'Id IN (Select AccountId '
			          + '       From Opportunity '
			          + '       Where RecordType.Name = \'Membership\' AND '
			          + '             isClosed = false AND '
			          +               GetTimeFilter(TimeFrame, bMemberMode) + 'AND '
			          +               UserFilter
			          + '      ) '
				        + ')'
				        ;				
				}

			if (NoOppy)
				{
				String NoOppyFilter = 'Where OwnerId IN :UserIds AND '
			                      + '      Id NOT IN :lstAccWithMembershipOppy '
				                    ;

				for (Account a : Database.query(query+NoOppyFilter))
					{
					lstAccounts.add(new AccountWrapper(this, a, true));
					}
				}

			if (MS_Tools.isBlankString(filter))
				filter = 'Where id = null';
			else
				filter = 'Where ' + filter;
			}

		for (Account a : Database.query(query+filter))
			{
			// Selected Accounts mode: need to recheck which accounts to add
			// 'SFDC_Ultimate_Parent_ID__c' is stored as 15-digit text field (case insensitive!),
			// but 15-digit IDs are case sensitive!!!
			if (
			     (SelectedAccount == null) ||
			     (a.ID == AccId) ||
			     ((id)a.SFDC_Ultimate_Parent_ID__c == (id)SelectedAccount.SFDC_Ultimate_Parent_ID__c) ||
			     (a.Entity_ID__c == SelectedAccount.Ultimate_Parent_Entity_ID__c) ||
			     (a.Ultimate_Parent_Entity_ID__c == SelectedAccount.Entity_ID__c) ||
			     (a.Ultimate_Parent_Entity_ID__c == SelectedAccount.Ultimate_Parent_Entity_ID__c)
			   )
			  {
			  boolean isSelected = (SelectedAccount == null || a.Id == AccId) ? true : false;
				lstAccounts.add(new AccountWrapper(this, a, isSelected));
			  }
			}

		SortAccounts();
		}

	//---------------------------------------------------------------------------
	// QueryAcquisitions
	//---------------------------------------------------------------------------
	public void QueryAcquisitions()
		{
		lstAcquisitions.clear();
		Acq_PreviousSortColumn = '';

		//
		// get acquisition IDs via acquisition opportunity defendants
		//
		set<Id> AccIds = GetAccountIds();
		set<Id> AcqIds = new set<Id>();
		set<Id> ActiveAcqIds = new set<Id>();
		for (Acquisition_Opportunity_Defendant__c aod : [Select Acquisition_Opportunity__c
		                                                 From Acquisition_Opportunity_Defendant__c
		                                                 Where Account_Lookup__c IN : AccIds AND
		                                                       Acquisition_Opportunity__c != null AND
		                                                       Defendant__r.Defendant_Active__c = 'Yes'])
			{
			AcqIds.add(aod.Acquisition_Opportunity__c);
			ActiveAcqIds.add(aod.Acquisition_Opportunity__c);
			}

		if (!AcqOnlyActive)
			{
			for (Acquisition_Opportunity_Defendant__c aod : [Select Acquisition_Opportunity__c
			                                                 From Acquisition_Opportunity_Defendant__c
			                                                 Where Account_Lookup__c in : AccIds AND
			                                                       Acquisition_Opportunity__c != null])
				{
				AcqIds.add(aod.Acquisition_Opportunity__c);
				}
			}
		// calculate additional fields
		map<id, map<String, integer>> TheMap = GetMap_AcqStats(AcqIds, AccIds);

		//
		// prepare filter options
		//
		set<String> NCSValues = new set<String>();
		for (String s : NCS)
			NCSValues.add(s == '<blank>' ? null : s);

		set<String> PriorityValues = new set<String>();
		for (String s : Priority)
			PriorityValues.add(s == '<blank>' ? null : s);

		set<String> StageValues = new set<String>();
		for (String s : Stage)
			StageValues.add(s == '<blank>' ? null : s);

		Integer nMinAllAccounts = MinAllAccounts.isNumeric() ? Integer.valueOf(MinAllAccounts) : -1;
		if (!MinAllAccounts.isNumeric())
			MinAllAccounts = '';

		Integer nMinMyAccounts = MinMyAccounts.isNumeric() ? Integer.valueOf(MinMyAccounts) : -1;
		if (!MinMyAccounts.isNumeric())
			MinMyAccounts = '';

		Integer nMinRedHeatMap = MinRedHeatMap.isNumeric() ? Integer.valueOf(MinRedHeatMap) : -1;
		if (!MinRedHeatMap.isNumeric())
			MinRedHeatMap = '';

		//
		// get acquisitions; add to list depending on filter options
		//
		for (Acquisition_Opportunity__c acq : [Select Id, Name,
		                                              N_Defendants__c,
		                                              N_Defendants_Active__c, N_Members_Active__c, N_Prospects_Active__c,
		                                              StageName__c,
		                                              Suit_Ranking__c,
		                                              Priority__c
		                                       From Acquisition_Opportunity__c
		                                       Where RecordType.Name = 'Litigations' AND
		                                             Id in :AcqIds])
			{
			map<String, integer> m = TheMap.get(acq.id); 

			if (
			     (
			       NCSValues.contains(acq.Suit_Ranking__c) &&
			       PriorityValues.contains(acq.Priority__c) &&
			       StageValues.contains(acq.StageName__c)
			     ) &&
					 (
			       (nMinAllAccounts < 0 && nMinMyAccounts < 0 && nMinRedHeatMap < 0) ||
			       (
			         (nMinAllAccounts >= 0 && m.get('AllAccounts') >= nMinAllAccounts) ||
			         (nMinMyAccounts >= 0  && m.get('MyAccounts')  >= nMinMyAccounts)  ||
			         (nMinRedHeatMap >= 0  && m.get('Red')         >= nMinRedHeatMap)
			       )
			     )
			   )
				{
				AcquisitionWrapper acqw = new AcquisitionWrapper(this, acq);

				acqw.isActive = ActiveAcqIds.contains(acqw.acq.id) ? true : false;

				acqw.Qualification    = m.get('Qualification');
				acqw.RecognitionAndUp = m.get('RecognitionAndUp');

				acqw.AllAccounts      = m.get('AllAccounts');
				acqw.MyAccounts       = m.get('MyAccounts');

				acqw.Red              = m.get('Red');
				acqw.Yellow           = m.get('Yellow');
				acqw.Green            = m.get('Green');

				lstAcquisitions.add(acqw);
				}
			}

		SortAcquisitions();
		}

	//---------------------------------------------------------------------------
	// QueryLitigations
	//---------------------------------------------------------------------------
	public void QueryLitigations()
		{
		lstDefendants.clear();
		Lit_PreviousSortColumn = '';

		set<Id> AccIds = GetAccountIds();

		String query = 'select account__c, '
		             + 'Date_Added__c, '
		             + 'Date_Terminated__c, '
		             + 'Defendant_Active__c, '
		             + 'Defendant_Active_Color__c, '
		             + 'Defendant_as_Listed__c, '
		             + 'account__r.name, '
		             + 'account__r.ownerid, '
		             + 'account__r.owner.name, '
		             + 'litigation_ID__c, '
		             + 'litigation_ID__r.name, '
		             + 'litigation_ID__r.Case_Key__c, '
		             + 'litigation_ID__r.Case_Name__c, '
		             + 'litigation_ID__r.Docket_Number__c, '
		             + 'litigation_ID__r.Filed__c, '
		             + 'litigation_ID__r.Close_Date__c, '
		             + 'litigation_ID__r.Active_or_Closed__c, '
		             + 'litigation_ID__r.Is_NPE__c, '
		             + 'litigation_ID__r.Is_DJ__c, '
		             + 'litigation_ID__r.Docket_URL__c, '
		             + 'litigation_ID__r.N_Defendants__c, '
		             + 'litigation_ID__r.N_Defendants_Active__c, '
		             + 'litigation_ID__r.N_Members__c, '
		             + 'litigation_ID__r.N_Members_Active__c, '
		             + 'litigation_ID__r.N_Prospects__c, '
		             + 'litigation_ID__r.N_Prospects_Active__c, '
		             + '(select id, defendant__c, acquisition_opportunity__c, acquisition_opportunity__r.name from Acquisition_Opportunity_Defendants__r) '
		             + 'from defendant__c '
		             + 'where '
		             + 'account__c in :AccIds '
 		             + (OnlyNPE ? 'and litigation_ID__r.Is_NPE__c = true ' : '')
 		             + (OnlyDJ  ? 'and litigation_ID__r.Is_DJ__c = true ' : '')
		             + (OnlyActive ? 'and defendant_active__c = \'Yes\' ' : '')
		             + (OnlyWithoutAcquisition ? 'and id not in (select defendant__c from acquisition_opportunity_defendant__c)' : '');

		for (Defendant__c def : Database.query(query))
			{
			def.litigation_ID__r.Docket_URL__c = MS_Tools.FixDocketUrl(def.litigation_ID__r.Docket_URL__c);
			lstDefendants.add(new DefendantWrapper(this, def));
			}

		SortLitigations();
		}

	//---------------------------------------------------------------------------
	// GetMap_AcqStats
	//---------------------------------------------------------------------------
	private map<id, map<String, integer>> GetMap_AcqStats(set<id> AcqIds, set<id> AccIds)
		{
		map<id, map<String, integer>> TheMap = new map<id, map<String, integer>>();

		//
		// reset fields
		//
		for (Id xId : AcqIds)
			{
			map<String, Integer> mapHM = new map<String, Integer>();
			mapHM.put('Qualification', 0);
			mapHM.put('RecognitionAndUp', 0);

			mapHM.put('AllAccounts', 0);
			mapHM.put('MyAccounts', 0);

			mapHM.put('Red', 0);
			mapHM.put('Yellow', 0);
			mapHM.put('Green', 0);

			TheMap.put(xId, mapHM);
			}

		//
		// get count of Red / Yellow / Green HeatMap Members
		//
		for (AggregateResult q : 
				[Select Acquisition_Opportunity__c,
			          Defendant__r.Account__r.HeatMapColor__c defHeatMap, 
			          Grouping(Defendant__r.Account__r.HeatMapColor__c) grpHeatMap,
			          Count_distinct(Defendant__r.Account__c) cnt
			   From Acquisition_Opportunity_Defendant__c
			   Where Acquisition_Opportunity__c in :AcqIds AND
			         Defendant__r.Defendant_Active__c = 'Yes' AND
			         Defendant__r.Account__r.RecordType.Name = 'Member'
			   group by cube (Acquisition_Opportunity__c,
			                  Defendant__r.Account__r.HeatMapColor__c)
				]
			)
			{
			if (q == null)
				continue;

			Id AcqId = (Id)q.get('Acquisition_Opportunity__c');
			
			if ( AcqId == null )
				continue;

			String  defHeatMap = (String)q.get('defHeatMap');
			Integer grpHeatMap = (Integer)q.get('grpHeatMap');
			Integer cnt        = ((Integer)q.get('cnt') == null ) ? 0 : (Integer)q.get('cnt');

			if (grpHeatMap == 0)
				TheMap.get(AcqId).put(defHeatMap, cnt);
			}

		//
		// get count of all active accounts from account list
		//
		for (AggregateResult q : 
				[Select Acquisition_Opportunity__c,
		            Count_distinct(Defendant__r.Account__c) cnt
		     From Acquisition_Opportunity_Defendant__c
		     Where Acquisition_Opportunity__c in :AcqIds AND
		           Defendant__r.Defendant_Active__c = 'Yes' AND
		           Defendant__r.Account__c in :AccIds
		     group by cube (Acquisition_Opportunity__c)
				]
			)
			{
			if (q == null)
				continue;

			Id AcqId = (Id)q.get('Acquisition_Opportunity__c');
			
			if ( AcqId == null )
				continue;

			Integer cnt = ((Integer)q.get('cnt') == null ) ? 0 : (Integer)q.get('cnt');

			TheMap.get(AcqId).put('AllAccounts', cnt);
			}

		//
		// get count of my active accounts from account list
		//
		for (AggregateResult q : 
				[Select Acquisition_Opportunity__c,
		            Count_distinct(Defendant__r.Account__c) cnt
		     From Acquisition_Opportunity_Defendant__c
		     Where Acquisition_Opportunity__c in :AcqIds AND
		           Defendant__r.Defendant_Active__c = 'Yes' AND
		           Defendant__r.Account__c in :AccIds AND
		           Defendant__r.Account__r.OwnerId = :RunningUser.Id
		     group by cube (Acquisition_Opportunity__c)
				]
			)
			{
			if (q == null)
				continue;

			Id AcqId = (Id)q.get('Acquisition_Opportunity__c');
			
			if ( AcqId == null )
				continue;

			Integer cnt = ((Integer)q.get('cnt') == null ) ? 0 : (Integer)q.get('cnt');

			TheMap.get(AcqId).put('MyAccounts', cnt);
			}

		//
		// get count of qualification prospects
		//
		for (AggregateResult q : 
				[Select Acquisition_Opportunity__c,
		            Count_distinct(Defendant__r.Account__c) cnt
		     From Acquisition_Opportunity_Defendant__c
		     Where Acquisition_Opportunity__c in :AcqIds AND
		           Defendant__r.Defendant_Active__c = 'Yes' AND
		           Account_Lookup__c in (Select AccountId from Opportunity Where RecordType.Name='Membership' AND StageName='Qualification')
		     group by cube (Acquisition_Opportunity__c)
				]
			)
			{
			if (q == null)
				continue;

			Id AcqId = (Id)q.get('Acquisition_Opportunity__c');
			
			if ( AcqId == null )
				continue;

			Integer cnt = ((Integer)q.get('cnt') == null ) ? 0 : (Integer)q.get('cnt');

			TheMap.get(AcqId).put('Qualification', cnt);
			}

		//
		// get count of recognition and up prospects
		//
		for (AggregateResult q : 
				[Select Acquisition_Opportunity__c,
		            Count_distinct(Defendant__r.Account__c) cnt
		     From Acquisition_Opportunity_Defendant__c
		     Where Acquisition_Opportunity__c in :AcqIds AND
		           Defendant__r.Defendant_Active__c = 'Yes' AND
		           Account_Lookup__c in (Select AccountId from Opportunity Where RecordType.Name='Membership' AND (StageName = 'Recognition' OR StageName = 'Go/No Go Decision'))
		     group by cube (Acquisition_Opportunity__c)
				]
			)
			{
			if (q == null)
				continue;

			Id AcqId = (Id)q.get('Acquisition_Opportunity__c');
			
			if ( AcqId == null )
				continue;

			Integer cnt = ((Integer)q.get('cnt') == null ) ? 0 : (Integer)q.get('cnt');

			TheMap.get(AcqId).put('RecognitionAndUp', cnt);
			}

		return TheMap;
		}

	//---------------------------------------------------------------------------
	// GetAccountIds
	//---------------------------------------------------------------------------
	private set<Id> GetAccountIds()
		{
		set<Id> AccIds = new set<Id>();
		for (AccountWrapper a: lstAccounts)
			if (a.isSelected == true)
				AccIds.add(a.acc.id);
		
		return AccIds;
		}

	//---------------------------------------------------------------------------
	// GetTimeFilter
	//---------------------------------------------------------------------------
	private String GetTimeFilter(String TimeFrame, boolean bMemberMode)
		{
		String r = '';
		String field = bMemberMode ? 'RenewalDate__c' : 'CloseDate';

		for (String item : TimeFrame.split(','))
			{
			if (!MS_Tools.isBlankString(r))
				r += ' or ';

			if (item == 'All')
				r += ' ' + field + ' != null ';
			else
				r += ' ' + field + ' = ' + item + ' ';
			}
		return ' (' + r + ') ';
		}

	//-------------------------------------------------------------------------------------------------------
	// InitAcquisitionFilters
	//-------------------------------------------------------------------------------------------------------
	private void InitAcquisitionFilters()
		{
		NCSItems.clear();
		NCS.clear();
		for (AggregateResult q : [select Suit_Ranking__c from acquisition_opportunity__c Where RecordType.Name = 'Litigations' group by suit_ranking__c])
			{
			if (MS_Tools.isBlankString((String)q.get('Suit_Ranking__c')))
				{
				NCSItems.add(new SelectOption('<blank>', '<unrated>'));
				NCS.add('<blank>');
				}
			else
				{
				NCSItems.add(new SelectOption((String)q.get('Suit_Ranking__c'), (String)q.get('Suit_Ranking__c')));
				NCS.add((String)q.get('Suit_Ranking__c'));
				}
			}

		PriorityItems.clear();
		Priority.clear();
		for (AggregateResult q : [select Priority__c from acquisition_opportunity__c Where RecordType.Name = 'Litigations' group by Priority__c])
			{
			if (MS_Tools.isBlankString((String)q.get('Priority__c')))
				{
				PriorityItems.add(new SelectOption('<blank>', '<unrated>'));
				Priority.add('<blank>');
				}
			else
				{
				PriorityItems.add(new SelectOption((String)q.get('Priority__c'), (String)q.get('Priority__c')));
				Priority.add((String)q.get('Priority__c'));
				}
			}

		StageItems.clear();
		Stage.clear();
		for (AggregateResult q : [select StageName__c from acquisition_opportunity__c Where RecordType.Name = 'Litigations' group by StageName__c])
			{
			if (MS_Tools.isBlankString((String)q.get('StageName__c')))
				{
				StageItems.add(new SelectOption('<blank>', '<no stage>'));
				Stage.add('<blank>');
				}
			else
				{
				StageItems.add(new SelectOption((String)q.get('StageName__c'), (String)q.get('StageName__c')));
				Stage.add((String)q.get('StageName__c'));
				}
			}
		}

	//-------------------------------------------------------------------------------------------------------
	// AccountWrapper
	//-------------------------------------------------------------------------------------------------------
	public class AccountWrapper implements Comparable
		{
    private MS_AccountsAndLitigationsCtrl ctrl;
    public Account acc{get;set;}
    public boolean isSelected{get;set;}

		public boolean isMember{get;set;}

		public boolean bMembershipOpportunity{get;set;}
		public String  MbrCloseDate{get;set;}
		public String  MbrStage{get;set;}
		public String  MbrOwnerName{get;set;}

		public boolean bInsuranceOpportunity{get;set;}
		public String  InsCloseDate{get;set;}
		public String  InsStage{get;set;}
		public String  InsOwnerName{get;set;}

		public boolean bHasLitigations{get;set;}
		public boolean bHasActiveLitigations{get;set;}

		public AccountWrapper(MS_AccountsAndLitigationsCtrl ctrl, Account acc, boolean isSelected)
			{
			this.ctrl = ctrl;
			this.acc = acc;
			this.isSelected = isSelected;

			this.isMember = (acc.Type2__c == 'Member');

			this.bMembershipOpportunity = false;
			this.MbrCloseDate = null;
			this.MbrStage = null;
			this.MbrOwnerName = null;

			this.bInsuranceOpportunity = false;
			this.InsCloseDate = null;
			this.InsStage = null;
			this.InsOwnerName = null;

			if (!isMember)
				{
				for (Opportunity o  : acc.Opportunities)
					{
					if (!this.bMembershipOpportunity && o.RecordType.Name == 'Membership')
						{
						this.bMembershipOpportunity = true;
						this.MbrCloseDate = o.CloseDate.format();
						this.MbrStage = o.StageName;
						this.MbrOwnerName = o.Owner.Name;
						}
					else if (!this.bInsuranceOpportunity && o.RecordType.Name == 'Insurance')
						{
						this.bInsuranceOpportunity = true;
						this.InsCloseDate = o.CloseDate.format();
						this.InsStage = o.StageName;
						this.InsOwnerName = o.Owner.Name;
						}
					}
				}

			this.bHasLitigations = acc.Defendants__r.Size() > 0 ? true : false;
			this.bHasActiveLitigations = false;

			for (Defendant__c def : acc.Defendants__r)
				{
				if (def.Defendant_Active__c == 'Yes')
					{
					this.bHasActiveLitigations = true;
					break;
					}
				}
			}

		public Integer compareTo(Object objToCompare)
			{
			if (ctrl.Acc_CurrentSortColumn == 'XX_bMembershipOpportunity')
				{
				return MS_Tools.Compare(bMembershipOpportunity, ((AccountWrapper)objToCompare).bMembershipOpportunity, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_MbrStage')
				{
				return MS_Tools.Compare(MbrStage, ((AccountWrapper)objToCompare).MbrStage, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_MbrCloseDate')
				{
				date a = MbrCloseDate == null ? null : date.parse(MbrCloseDate);
				date b = ((AccountWrapper)objToCompare).MbrCloseDate == null ? null : date.parse(((AccountWrapper)objToCompare).MbrCloseDate);

				return MS_Tools.Compare(a, b, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_MbrOwnerName')
				{
				return MS_Tools.Compare(MbrOwnerName, ((AccountWrapper)objToCompare).MbrOwnerName, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_bInsuranceOpportunity')
				{
				return MS_Tools.Compare(bInsuranceOpportunity, ((AccountWrapper)objToCompare).bInsuranceOpportunity, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_InsStage')
				{
				return MS_Tools.Compare(InsStage, ((AccountWrapper)objToCompare).InsStage, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_InsCloseDate')
				{
				date a = InsCloseDate == null ? null : date.parse(InsCloseDate);
				date b = ((AccountWrapper)objToCompare).InsCloseDate == null ? null : date.parse(((AccountWrapper)objToCompare).InsCloseDate);

				return MS_Tools.Compare(a, b, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_InsOwnerName')
				{
				return MS_Tools.Compare(InsOwnerName, ((AccountWrapper)objToCompare).InsOwnerName, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_bHasLitigations')
				{
				return MS_Tools.Compare(bHasLitigations, ((AccountWrapper)objToCompare).bHasLitigations, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_bHasActiveLitigations')
				{
				return MS_Tools.Compare(bHasActiveLitigations, ((AccountWrapper)objToCompare).bHasActiveLitigations, '', ctrl.Acc_IsAsc);
				}
			else
				{
				return MS_Tools.Compare(acc, ((AccountWrapper)objToCompare).acc, ctrl.Acc_CurrentSortColumn, ctrl.Acc_IsAsc);
				}
			}
		}

	//-------------------------------------------------------------------------------------------------------
	// AcquisitionWrapper
	//-------------------------------------------------------------------------------------------------------
	public class AcquisitionWrapper implements Comparable
		{
    public Acquisition_Opportunity__c acq{get;set;}
    private MS_AccountsAndLitigationsCtrl ctrl;

		public boolean isActive{get;set;}

		public integer Qualification{get;set;}
		public integer RecognitionAndUp{get;set;}

    public integer AllAccounts{get;set;}
    public integer MyAccounts{get;set;}

    public integer Red{get;set;}
    public integer Yellow{get;set;}
    public integer Green{get;set;}

		public AcquisitionWrapper(MS_AccountsAndLitigationsCtrl ctrl, Acquisition_Opportunity__c acq)
			{
			this.acq = acq;
			this.ctrl = ctrl;

			this.isActive = false;

			this.Qualification    = 0;
			this.RecognitionAndUp = 0;

			this.AllAccounts = 0;
			this.MyAccounts  = 0;

			this.Red         = 0;
			this.Yellow      = 0;
			this.Green       = 0;
			}

		public Integer compareTo(Object objToCompare)
			{
			if (ctrl.Acq_CurrentSortColumn == 'XX_isActive')
				{
				return MS_Tools.Compare(isActive, ((AcquisitionWrapper)objToCompare).isActive, '', ctrl.Acq_IsAsc);
				}
			else if (ctrl.Acq_CurrentSortColumn == 'XX_Qualification')
				{
				return MS_Tools.Compare(Qualification, ((AcquisitionWrapper)objToCompare).Qualification, '', ctrl.Acq_IsAsc);
				}
			else if (ctrl.Acq_CurrentSortColumn == 'XX_RecognitionAndUp')
				{
				return MS_Tools.Compare(RecognitionAndUp, ((AcquisitionWrapper)objToCompare).RecognitionAndUp, '', ctrl.Acq_IsAsc);
				}
			else if (ctrl.Acq_CurrentSortColumn == 'XX_AllAccounts')
				{
				return MS_Tools.Compare(AllAccounts, ((AcquisitionWrapper)objToCompare).AllAccounts, '', ctrl.Acq_IsAsc);
				}
			else if (ctrl.Acq_CurrentSortColumn == 'XX_MyAccounts')
				{
				return MS_Tools.Compare(MyAccounts, ((AcquisitionWrapper)objToCompare).MyAccounts, '', ctrl.Acq_IsAsc);
				}
			else if (ctrl.Acq_CurrentSortColumn == 'XX_Red')
				{
				return MS_Tools.Compare(Red, ((AcquisitionWrapper)objToCompare).Red, '', ctrl.Acq_IsAsc);
				}
			else if (ctrl.Acq_CurrentSortColumn == 'XX_Yellow')
				{
				return MS_Tools.Compare(Yellow, ((AcquisitionWrapper)objToCompare).Yellow, '', ctrl.Acq_IsAsc);
				}
			else if (ctrl.Acq_CurrentSortColumn == 'XX_Green')
				{
				return MS_Tools.Compare(Green, ((AcquisitionWrapper)objToCompare).Green, '', ctrl.Acq_IsAsc);
				}
			else
				{
				return MS_Tools.Compare(acq, ((AcquisitionWrapper)objToCompare).acq, ctrl.Acq_CurrentSortColumn, ctrl.Acq_IsAsc);
				}
			}
		}

	//-------------------------------------------------------------------------------------------------------
	// DefendantWrapper
	//-------------------------------------------------------------------------------------------------------
	public class DefendantWrapper implements Comparable
		{
    private MS_AccountsAndLitigationsCtrl ctrl;
    public Defendant__c def{get;set;}
    
    public boolean bHasAcquisition{get;set;}

		public DefendantWrapper(MS_AccountsAndLitigationsCtrl ctrl, Defendant__c def)
			{
			this.ctrl = ctrl;
			this.def = def;
			
			bHasAcquisition = (def.Acquisition_Opportunity_Defendants__r.Size() > 0) ? true : false;
			}

		public Integer compareTo(Object objToCompare)
			{
			if (ctrl.Acq_CurrentSortColumn == 'XX_bHasAcquisition')
				{
				return MS_Tools.Compare(bHasAcquisition, ((DefendantWrapper)objToCompare).bHasAcquisition, '', ctrl.Lit_IsAsc);
				}
			else
				{
				return MS_Tools.Compare(def, ((DefendantWrapper)objToCompare).def, ctrl.Lit_CurrentSortColumn, ctrl.Lit_IsAsc);
				}
			}
		}

	//---------------------------------------------------------------------------
	// Test
	//---------------------------------------------------------------------------
	@isTest static void Test()
		{
		Account acct = TestUtil.createAccount(true);
		Acquisition_Opportunity__c acqOpp = TestUtil.createAcquisitionOpp(acct.Id, 'Closed Won', 'Test', true);

		List<Litigation__c> lstLitigation = new List<Litigation__c> ();
		lstLitigation.add(TestUtil.createLitigation(false));
		lstLitigation.add(TestUtil.createLitigation(false));
		lstLitigation.add(TestUtil.createLitigation(false));
		insert lstLitigation;

		List<Patent__c> lstPatents = new List<Patent__c> ();
		lstPatents.add(TestUtil.createPatent(false));
		insert lstPatents;

		List<Patents_in_Suit__c> lstPatentsInSuit = new List<Patents_in_Suit__c> ();
		lstPatentsInSuit.add(TestUtil.createPatentInSuit(lstPatents[0].Id, lstLitigation[0].Id, false));
		lstPatentsInSuit.add(TestUtil.createPatentInSuit(lstPatents[0].Id, lstLitigation[1].Id, false));
		lstPatentsInSuit.add(TestUtil.createPatentInSuit(lstPatents[0].Id, lstLitigation[2].Id, false));
		insert lstPatentsInSuit;

		Account acc1 = TestUtil.createAccount(true);
		Account acc2 = TestUtil.createAccount(true);
		Account acc3 = TestUtil.createAccount(true);

		TestUtil.createDefendant(acc1.Id, lstLitigation[0].Id, true);
		TestUtil.createDefendant(acc2.Id, lstLitigation[1].Id, true);
		TestUtil.createDefendant(acc3.Id, lstLitigation[2].Id, true);

		TestUtil.createOpportunityLitigation(acqOpp.Id, lstLitigation[1].Id, true);

		Test.startTest();

		// ---------------------------------------
		
		Test.setCurrentPage(Page.MS_AccountsAndLitigations);

		Map<String,String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put('Id', acc1.Id);

		MS_AccountsAndLitigationsCtrl controller = new MS_AccountsAndLitigationsCtrl();

		controller.UpdateAll();

		// ---------------------------------------
		
		Test.setCurrentPage(Page.MS_AccountsAndLitigations);

		controller = new MS_AccountsAndLitigationsCtrl();

		controller.UpdateAll();
		controller.ToggleAcqMoreOptions();
		controller.SortAccounts();
		controller.SortAcquisitions();
		controller.SortLitigations();
		

		// ---------------------------------------

		Test.setCurrentPage(Page.MS_AccountsAndLitigations);

		pageParams = ApexPages.currentPage().getParameters();
		pageParams.put('mode', 'prospect');

		controller = new MS_AccountsAndLitigationsCtrl();

		controller.UpdateAll();

		// ---------------------------------------

		Test.stopTest();		
		}

	}