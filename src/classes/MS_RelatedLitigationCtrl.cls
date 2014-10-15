/*
    Class        : MS_RelatedLitigationCtrl
    Description  : Controller for Related Litigation Pages (based on Patents-in-suit)
    Created By   : Martin Sieler
    Created Date : October 10, 2012
*/

public without sharing class MS_RelatedLitigationCtrl
	{
	private Map<String, String> pageParams;
	private Id RunningUser;

	public Acquisition_Opportunity__c Acq{get;set;}
	public Litigation__c              Lit{get;set;}

	// defendants
	public list<AccountWrapper> lstAccounts{get;set;}

	public integer N_Defendants{get;set;}
	public integer N_Members{get;set;}
	public integer N_Prospects{get;set;}
	public integer N_Defendants_Active{get;set;}
	public integer N_Members_Active{get;set;}
	public integer N_Prospects_Active{get;set;}
	public integer N_Defendants_Terminated{get;set;}
	public integer N_Members_Terminated{get;set;}
	public integer N_Prospects_Terminated{get;set;}

	public list<String> AccType{get;set;}
	public list<SelectOption> AccTypeItems{get;set;}

	public String AccStatus{get;set;}
	public list<SelectOption> AccStatusItems{get;set;}

	public  String  Acc_CurrentSortColumn{get;set;}
	public  boolean Acc_IsAsc{set;get;}
	private String  Acc_PreviousSortColumn;

	// acquisitions
	public list<AcquisitionWrapper> lstAcquisitions{get;set;}

	public  String  Acq_CurrentSortColumn{get;set;}
	public  boolean Acq_IsAsc{set;get;}
	private String  Acq_PreviousSortColumn;

	// litigations
	public list<LitigationWrapper> lstRelatedLits{get;set;}

	public integer N_Lit{get;set;}
	public integer N_Lit_Active{get;set;}
	public integer N_Lit_Closed{get;set;}
	public integer N_Lit_DJ{get;set;}
	public integer N_Lit_NPE{get;set;}

	public  String  Lit_CurrentSortColumn{get;set;}
	public  boolean Lit_IsAsc{set;get;}
	private String  Lit_PreviousSortColumn;

	public boolean LitMoreColumns{set;get;}

	// patents
	public list<PatentWrapper> lstPatentsInSuit{get;set;}
	public list<PatentWrapper> lstPatentsRelated{get;set;}

	// private data
	private Set<Id> ExistingLitigationIds;
	private Set<Id> RelatedLitigationIds;

	//---------------------------------------------------------------------------
	// Constructor
	//---------------------------------------------------------------------------
	public MS_RelatedLitigationCtrl()
		{
		RunningUser = UserInfo.getUserId();

		Acq = null;
		Lit = null;

		lstAccounts       = new list<AccountWrapper>();
		lstAcquisitions   = new list<AcquisitionWrapper>();
		lstRelatedLits    = new list<LitigationWrapper>();
		lstPatentsInSuit  = new list<PatentWrapper>();
		lstPatentsRelated = new list<PatentWrapper>();

		AccType = new list<String>();
		AccTypeItems = new List<SelectOption>();
		AccTypeItems.add(new SelectOption('Members','Members'));
		AccTypeItems.add(new SelectOption('Prospects','Prospects'));
		AccTypeItems.add(new SelectOption('Others','Others'));

		for (SelectOption so : AccTypeItems)
			AccType.add(so.getValue());

		AccStatusItems = new List<SelectOption>();
		AccStatusItems.add(new SelectOption('Active','Active'));
		AccStatusItems.add(new SelectOption('Terminated','Terminated'));
		AccStatusItems.add(new SelectOption('Both','Both'));

		AccStatus = 'Both';

		Acc_CurrentSortColumn  = 'Name';
		Acc_PreviousSortColumn = '';     
		Acc_IsAsc              = true;

		Acq_CurrentSortColumn  = 'Name';
		Acq_PreviousSortColumn = '';     
		Acq_IsAsc              = true;

		Lit_CurrentSortColumn  = 'Filed__c';
		Lit_PreviousSortColumn = '';     
		Lit_IsAsc              = false;

		LitMoreColumns = false;

		ExistingLitigationIds = new Set<id>();
		RelatedLitigationIds  = new Set<Id>();

		pageParams = Apexpages.currentPage().getParameters();
		Id xId = pageParams.get('Id');

		if (xId.getSObjectType() == Acquisition_Opportunity__c.sObjectType)
			{
			Acq = [select id, name from Acquisition_Opportunity__c where id = :xId limit 1];

			// get related opportunity litigation ids
			for (Opportunity_Litigation__c ol : [Select Litigation__c
	                                         From Opportunity_Litigation__c
	                                         Where Acquisition_Opportunity__c = :Acq.Id AND Litigation__c != null])
				{
				ExistingLitigationIds.add(ol.Litigation__c);                                                 
				}
			}
		else if (xId.getSObjectType() == Litigation__c.sObjectType)
			{
			Lit = [select id, name from Litigation__c where id = :xId limit 1];
			
			ExistingLitigationIds.add(Lit.Id);   
			}

		if (ExistingLitigationIds.Size() > 0)
			{
			RelatedLitigationIds.addAll(ExistingLitigationIds);
			
			// get patents-in-suit for existing litigations
			Set<String> PatentNumbers = new Set<String>();
			for (Patents_in_Suit__c pis : [Select Patent__r.Patent_no__c
			                               From Patents_in_Suit__c
			                               Where Litigation__c in :ExistingLitigationIds And
			                                     Patent__r.Patent_No__c != null And
			                                     Litigation__c != null])
				{
				PatentNumbers.add(pis.Patent__r.Patent_no__c);
				}

			if (PatentNumbers.Size() > 0)
				{
				// get litigations with same patents
				for (Patents_in_Suit__c pis : [Select Litigation__c 
				                               From Patents_in_Suit__c
				                               Where Patent__r.Patent_No__c IN :PatentNumbers And
				                                     Patent__r.Patent_No__c != null And
				                                     Litigation__c != null])
					{
					RelatedLitigationIds.add(pis.Litigation__c);
					}
				}

			QueryLitigations();
			LitigationCount();
			QueryAccounts();
			DefendantCount();
			QueryAcquisitions();
			QueryPatents();
			}

		if (lstRelatedLits.Size() == 0)
			{
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, Label.No_Record_Found));
			}
		}

	//---------------------------------------------------------------------------
	// UpdateFields
	//---------------------------------------------------------------------------
  public void UpdateFields()
  	{
  	QueryLitigations();
  	LitigationCount();
		QueryAccounts();
		DefendantCount();
		QueryAcquisitions();
  	QueryPatents();
  	}

	//---------------------------------------------------------------------------
	// ToggleLitMoreColumns
	//---------------------------------------------------------------------------
	public void ToggleLitMoreColumns()
		{
		LitMoreColumns = !LitMoreColumns;
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

		lstRelatedLits.sort();
		}

	//---------------------------------------------------------------------------
	// QueryAccounts
	//---------------------------------------------------------------------------
	public void QueryAccounts()
		{
		lstAccounts.clear();
		Acc_PreviousSortColumn = '';

		set<Id> LitIds = GetLitIds(true);

		map<id, boolean> AccIds = new map<id, boolean>();
		for (Defendant__c def : [select Account__c, Defendant_Active__c
		                         from Defendant__c
		                         where Litigation_ID__c in :LitIds])
			{
			if (!AccIds.containsKey(def.Account__c))
				{
				AccIds.put(def.Account__c, def.Defendant_Active__c == 'Yes' ? true : false);
				}
			else
				{
				if (def.Defendant_Active__c == 'Yes' && AccIds.get(def.Account__c) == false)
					AccIds.put(def.Account__c, def.Defendant_Active__c == 'Yes' ? true : false);
				}
			}

		Set<id> keys = AccIds.keySet();

		String query = 'select id, name, type, type2__c, RPX_RCRate__c, HeatMapColor__c, HeatMapColorDisplay__c, Owner.Name, OwnerId, Entity_ID__c, '
		             + '(select id, name, ownerid, owner.name, amount, stagename, closedate, recordtype.name '
		             + ' from Opportunities '
		             + ' where isclosed = false AND '
		             +'        (recordtype.name = \'Insurance\' or recordtype.name = \'Membership\')'
		             + ') '
		             + 'from Account '
		             + 'where id in :keys';

		// filters
		boolean bMembers = false;
		boolean bProspects = false;
		boolean bOthers = false;

		boolean bActive = false;
		boolean bTerminated = false;

		for (String s : AccType)
			{
			if (s == 'Members')
				bMembers = true;
			else if (s == 'Prospects')
				bProspects = true;
			else if (s == 'Others')
				bOthers = true;
			}

		if (AccStatus == 'Active')
			{
			bActive = true;
			}
		else if (AccStatus == 'Terminated')
			{
			bTerminated = true;
			}
		else if (AccStatus == 'Both')
			{
			bActive = true;
			bTerminated = true;
			}

		for (Account a : Database.query(query))
			{
			boolean bAccStatus = AccIds.get(a.id);

			if (
			     ((bActive && (bAccStatus == true)) || (bTerminated && (bAccStatus == false))) &&
			     ((bMembers && (a.Type2__c == 'Member')) || (bProspects && (a.Type2__c == 'Prospect')) || (bOthers && (a.Type2__c == 'Other')))
			   )
				lstAccounts.add(new AccountWrapper(this, a, bAccStatus));
			}

		SortAccounts();
		}

	//---------------------------------------------------------------------------
	// QueryAcquisitions
	//---------------------------------------------------------------------------
	private void QueryAcquisitions()
		{
		lstAcquisitions.clear();
		Acq_PreviousSortColumn = '';

		//
		// get acquisition IDs via acquisition opportunity defendants
		//
		set<id> LitIds = GetLitIds(true);
		set<Id> AcqIds = new set<id>();

		for (Opportunity_Litigation__c ol : [Select Acquisition_Opportunity__c
		                                     From Opportunity_Litigation__c
		                                     Where Litigation__c IN :LitIds AND
		                                           Acquisition_Opportunity__c != null])
			{
			AcqIds.add(ol.Acquisition_Opportunity__c);
			}

		// calculate additional fields
		set<id> AccIds = new set<id>();
		for (AccountWrapper accw : lstAccounts)
			AccIds.add(accw.acc.id);

		map<id, map<String, integer>> TheMap = GetMap_AcqStats(AcqIds, AccIds);

		//
		// get acquisitions; add to list
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

			AcquisitionWrapper acqw = new AcquisitionWrapper(this, acq);

			acqw.Qualification    = m.get('Qualification');
			acqw.RecognitionAndUp = m.get('RecognitionAndUp');

			acqw.AllAccounts      = m.get('AllAccounts');
			acqw.MyAccounts       = m.get('MyAccounts');

			acqw.Red              = m.get('Red');
			acqw.Yellow           = m.get('Yellow');
			acqw.Green            = m.get('Green');

			lstAcquisitions.add(acqw);
			}

		SortAcquisitions();
		}

	//---------------------------------------------------------------------------
	// QueryLitigations
	//---------------------------------------------------------------------------
	private void QueryLitigations()
		{
		map<id, boolean> MapIsSelected = new map<id, boolean>();
		for (LitigationWrapper l : lstRelatedLits)
			MapIsSelected.put(l.lit.id, l.isSelected);

		if (lstRelatedLits.Size() > 0)
			{
			RelatedLitigationIds.clear();
			RelatedLitigationIds.addAll(ExistingLitigationIds);
			
			Set<String> PatentNumbers = new Set<String>();
			for (LitigationWrapper l : lstRelatedLits)
				{
				if (l.isSelected)
					for (Patents_in_Suit__c pis : l.lit.Patents_In_Suit__r)
						if (pis.Patent__r.Patent_No__c != null)
							PatentNumbers.add(pis.Patent__r.Patent_No__c);
				}

			if (PatentNumbers.Size() > 0)
				{
				// get litigations with same patents
				for (Patents_in_Suit__c pis : [Select Litigation__c 
				                               From Patents_in_Suit__c
				                               Where Patent__r.Patent_No__c IN :PatentNumbers And
				                                     Patent__r.Patent_No__c != null And
				                                     Litigation__c != null])
					{
					RelatedLitigationIds.add(pis.Litigation__c);
					}
				}
			}

		lstRelatedLits.clear();
		Lit_PreviousSortColumn = '';

		String query = 'SELECT id, Name, Case_Key__c, Case_Name__c, Docket_Number__c , Filed__c, Close_Date__c, Active_or_Closed__c, '
		             + '       Is_NPE__c, Is_DJ__c, Docket_URL__c, Plaintiff__c, '
		             + '       N_Defendants__c, N_Defendants_Active__c, N_Members__c, N_Members_Active__c, '
			           + '       (Select id, Patent__r.Patent_No__c From Patents_In_Suit__r order by Patent__r.Patent_No__c), '
			           + '       (Select id, acquisition_opportunity__r.name From Opportunity_Litigation__r order by acquisition_opportunity__r.name) '
		             + 'FROM Litigation__c '
		             + 'WHERE id IN :RelatedLitigationIds ';

		for (Litigation__c l : Database.query(query))
			{
			l.Docket_URL__c = MS_Tools.FixDocketUrl(l.Docket_URL__c);

			boolean isDisabled = ExistingLitigationIds.contains(l.Id) ? true : false;
			lstRelatedLits.add(new LitigationWrapper(this, l, isDisabled));			
			}

// ==================================================

/*

		xxxS = '';
		set<String> lstPlaintiff = new set<String>();
		for (LitigationWrapper lw : lstRelatedLits)
			if (!MS_Tools.isBlankString(lw.lit.Plaintiff__c))
				for (String s : lw.lit.Plaintiff__c.split(';'))
					{
					if (!lstPlaintiff.contains(s))
						xxxS += s + ' # ';

					lstPlaintiff.add(s);
					}

		query = 'SELECT id, Name, Case_Key__c, Case_Name__c, Docket_Number__c , Filed__c, Close_Date__c, Active_or_Closed__c, '
		             + '       Is_NPE__c, Is_DJ__c, Docket_URL__c, Plaintiff__c, '
		             + '       N_Defendants__c, N_Defendants_Active__c, N_Members__c, N_Members_Active__c, '
			           + '       (Select id, Patent__r.Patent_No__c From Patents_In_Suit__r order by Patent__r.Patent_No__c), '
			           + '       (Select id, acquisition_opportunity__r.name From Opportunity_Litigation__r order by acquisition_opportunity__r.name) '
		             + 'FROM Litigation__c '
		             + 'WHERE plaintiff__c in :lstPlaintiff and id NOT IN :RelatedLitigationIds ';

		for (Litigation__c l : Database.query(query))
			{
			l.Docket_URL__c = MS_Tools.FixDocketUrl(l.Docket_URL__c);

			boolean isDisabled = ExistingLitigationIds.contains(l.Id) ? true : false;
			lstRelatedLits.add(new LitigationWrapper(this, l, isDisabled));			
			}

*/

// ==================================================

		for (LitigationWrapper l : lstRelatedLits)
			if (MapIsSelected.containsKey(l.lit.id))
				l.isSelected = MapIsSelected.get(l.lit.id);

		SortLitigations();
		}

// ==================================================
/*
public string xxxs{get;set;}
*/
// ==================================================

	//---------------------------------------------------------------------------
	// QueryPatents
	//---------------------------------------------------------------------------
	private void QueryPatents()
		{
		// get patents from selected litigations
		lstPatentsInSuit.clear();
		
		set<Id> LitIds = GetLitIds(true);

		set<Id> PInSuitChk = new set<Id>();
		for (Patents_in_Suit__c pis : [Select Patent__r.id, Patent__r.name, Patent__r.Patent_no__c, Patent__r.Title__c, Patent__r.File_Date__c, Patent__r.Patent_Family__c
		                               From Patents_in_Suit__c
		                               Where Litigation__c IN :LitIds AND
		                                     Patent__r.Patent_No__c != null And
		                                     Litigation__c != null
		                               order by Patent__r.Patent_no__c])
			{
			if (!PInSuitChk.contains(pis.Patent__r.id))
				{
				PInSuitChk.add(pis.Patent__r.id);
				lstPatentsInSuit.add(new PatentWrapper(new Patent__c(id=pis.Patent__r.id, Patent_no__c=pis.Patent__r.Patent_no__c, name=pis.Patent__r.name, Title__c=pis.Patent__r.Title__c, File_Date__c=pis.Patent__r.File_Date__c, Patent_Family__c=pis.Patent__r.Patent_Family__c)));
				}
			}

		// get patents from un-selected litigations
		lstPatentsRelated.clear();
		
		set<Id> LitRelIds = GetLitIds(false);

		set<Id> PRelChk = new set<Id>();
		for (Patents_in_Suit__c pis : [Select Patent__r.id, Patent__r.name, Patent__r.Patent_no__c, Patent__r.Title__c, Patent__r.File_Date__c, Patent__r.Patent_Family__c
		                               From Patents_in_Suit__c
		                               Where Litigation__c IN :LitRelIds AND
		                                     Patent__r.Patent_No__c != null And
		                                     Litigation__c != null
		                               order by Patent__r.Patent_no__c])
			{
			if (!PRelChk.contains(pis.Patent__r.id))
				{
				PRelChk.add(pis.Patent__r.id);
				lstPatentsRelated.add(new PatentWrapper(new Patent__c(id=pis.Patent__r.id, Patent_no__c=pis.Patent__r.Patent_no__c, name=pis.Patent__r.name, Title__c=pis.Patent__r.Title__c, File_Date__c=pis.Patent__r.File_Date__c, Patent_Family__c=pis.Patent__r.Patent_Family__c)));
				}
			}

		for (PatentWrapper pat : lstPatentsRelated)
			pat.isInSuit = PInSuitChk.contains(pat.pat.id);
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
		           Defendant__r.Account__r.OwnerId = :RunningUser
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
	// LitigationCount
	//---------------------------------------------------------------------------
  private void LitigationCount()
  	{
		N_Lit        = 0;
		N_Lit_Active = 0;
		N_Lit_Closed = 0;
		N_Lit_DJ     = 0;
		N_Lit_NPE    = 0;

		for (LitigationWrapper l : lstRelatedLits)
			{
			if (l.isSelected)
				{
				N_Lit++;
				
				if (l.lit.Is_NPE__c)
					N_Lit_NPE++;
	
				if (l.lit.Is_DJ__c)
					N_Lit_DJ++;
	
				if (l.lit.Active_or_Closed__c == 'Active')
					N_Lit_Active++;
				else
					N_Lit_Closed++;
				}
			}

  	}

	//---------------------------------------------------------------------------
	// DefendantCount
	//---------------------------------------------------------------------------
  private void DefendantCount()
		{
		N_Defendants            = 0;
		N_Members               = 0;
		N_Prospects             = 0;

		N_Defendants_Active     = 0;
		N_Members_Active        = 0;
		N_Prospects_Active      = 0;

		// note: N_<xxx>_Terminated fields will be set below

		set<Id> LitIds = GetLitIds(true);

		for (AggregateResult q : [Select Defendant_Active__c defStatus, 
					                           Account__r.Type2__c recType,
					                           Grouping(Defendant_Active__c) grpStatus,
					                           Grouping(Account__r.Type2__c) grpType,
					                           Count_distinct(Account__c) cnt
					                    From Defendant__c
					                    Where Litigation_ID__c in :LitIds
					                    group by cube (Defendant_Active__c, Account__r.Type2__c)])
			{
			if ( q != null )
				{
				String  defStatus = (String)q.get('defStatus');
				String  recType   = (String)q.get('recType');
				Integer grpStatus = (Integer)q.get('grpStatus');
				Integer grpType   = (Integer)q.get('grpType');
				Integer cnt       = ((Integer)q.get('cnt') == null ) ? 0 : (Integer)q.get('cnt');

				System.Debug(MS_Tools.Finer , 'DefendantCount() LOOP: ' +
				                                 'cnt: ' + cnt + ' ' + 
				                                 'grpStatus: \'' + grpStatus + '\' ' +
				                                 'grpType: \'' + grpType + '\' ' +
				                                 'defStatus: \'' + defStatus + '\' '+ 
				                                 'recType: \'' + recType + '\' ');

				if      (grpStatus == 1 && grpType == 1 && defStatus == null && recType == null)
					N_Defendants += cnt;
				else if (grpStatus == 1 && grpType == 0 && defStatus == null && recType == 'Member')
					N_Members += cnt;
				else if (grpStatus == 1 && grpType == 0 && defStatus == null && recType == 'Prospect')
					N_Prospects += cnt;
				else if (grpStatus == 0 && grpType == 1 && defStatus == 'Yes' && recType == null)
					N_Defendants_Active += cnt;
				else if (grpStatus == 0 && grpType == 0 && defStatus == 'Yes' && recType == 'Member')
					N_Members_Active += cnt;
				else if (grpStatus == 0 && grpType == 0 && defStatus == 'Yes' && recType == 'Prospect')
					N_Prospects_Active += cnt;
				}
			}

		N_Defendants_Terminated = N_Defendants - N_Defendants_Active;
		N_Members_Terminated    = N_Members    - N_Members_Active;
		N_Prospects_Terminated  = N_Prospects  - N_Prospects_Active;
		}

	//---------------------------------------------------------------------------
	// GetLitIds
	//---------------------------------------------------------------------------
	private set<Id> GetLitIds(boolean Selected)
		{
		set<Id> LitIds = new set<Id>();
		for (LitigationWrapper l: lstRelatedLits)
			if (l.isSelected == Selected)
				LitIds.add(l.lit.id);
		
		return LitIds;
		}

	//-------------------------------------------------------------------------------------------------------
	// AccountWrapper
	//-------------------------------------------------------------------------------------------------------
	public class AccountWrapper implements Comparable
		{
    public Account acc{get;set;}
		private MS_RelatedLitigationCtrl ctrl;

		public boolean isActive{get;set;}
		public boolean isMember{get;set;}

		public boolean bMembershipOpportunity{get;set;}
		public String  MbrCloseDate{get;set;}
		public String  MbrStage{get;set;}
		public String  MbrOwnerName{get;set;}

		public boolean bInsuranceOpportunity{get;set;}
		public String  InsCloseDate{get;set;}
		public String  InsStage{get;set;}
		public String  InsOwnerName{get;set;}

		public AccountWrapper(MS_RelatedLitigationCtrl ctrl, Account acc, boolean isActive)
			{
			this.acc = acc;
			this.ctrl = ctrl;

			this.isActive = isActive;
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

			}

		public Integer compareTo(Object objToCompare)
			{
			if (ctrl.Acc_CurrentSortColumn == 'XX_isActive')
				{
				return MS_Tools.Compare(isActive, ((AccountWrapper)objToCompare).isActive, '', ctrl.Acc_IsAsc);
				}
			else if (ctrl.Acc_CurrentSortColumn == 'XX_bMembershipOpportunity')
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
    private MS_RelatedLitigationCtrl ctrl;

		public integer Qualification{get;set;}
		public integer RecognitionAndUp{get;set;}

    public integer AllAccounts{get;set;}
    public integer MyAccounts{get;set;}

    public integer Red{get;set;}
    public integer Yellow{get;set;}
    public integer Green{get;set;}

		public AcquisitionWrapper(MS_RelatedLitigationCtrl ctrl, Acquisition_Opportunity__c acq)
			{
			this.acq = acq;
			this.ctrl = ctrl;

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
			if (ctrl.Acq_CurrentSortColumn == 'XX_Qualification')
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
	// LitigationWrapper
	//-------------------------------------------------------------------------------------------------------
	public class LitigationWrapper implements Comparable
		{
		public Litigation__c lit{get;set;}
		private MS_RelatedLitigationCtrl ctrl;

		public boolean isSelected{get;set;}
		public boolean isDisabled{get;set;}

		public String PatentNumbers{get;set;}
		public integer PatentCount{get;set;}
		public boolean hasPatents {get;set;}
		public String AssociatedAcq{get;set;}
		public boolean isAssociatedToOpp {get;set;}

		public LitigationWrapper(MS_RelatedLitigationCtrl ctrl, Litigation__c lit, Boolean isDisabled)
			{
			this.lit = lit;
			this.ctrl = ctrl;

			this.isDisabled = isDisabled;
			this.isSelected = isDisabled;

			PatentNumbers = '';

			for (Patents_in_Suit__c pis : lit.Patents_In_Suit__r)
				if (pis.Patent__r.Patent_No__c != null)
					PatentNumbers += pis.Patent__r.Patent_No__c + ', ';

			if (PatentNumbers != '')
				PatentNumbers = PatentNumbers.substring(0, PatentNumbers.length()-2);

			PatentCount = lit.Patents_In_Suit__r.Size();
			hasPatents = lit.Patents_In_Suit__r.Size() > 0 ? true : false;

			AssociatedAcq = '';

			for (Opportunity_Litigation__c ol : lit.Opportunity_Litigation__r)
				if (ol.Acquisition_Opportunity__r.name != null)
					AssociatedAcq += ol.Acquisition_Opportunity__r.name + ', ';

			if (AssociatedAcq != '')
				AssociatedAcq = AssociatedAcq.substring(0, AssociatedAcq.length()-2);

			isAssociatedToOpp = lit.Opportunity_Litigation__r.Size() > 0 ? true : false;
			}

		public Integer compareTo(Object objToCompare)
			{
			if (ctrl.Lit_CurrentSortColumn == 'XX_PatentNumbers')
				{
				return MS_Tools.Compare(PatentNumbers, ((LitigationWrapper)objToCompare).PatentNumbers, '', ctrl.Lit_IsAsc);
				}
			else if (ctrl.Lit_CurrentSortColumn == 'XX_PatentCount')
				{
				return MS_Tools.Compare(PatentCount, ((LitigationWrapper)objToCompare).PatentCount, '', ctrl.Lit_IsAsc);
				}
			else if (ctrl.Lit_CurrentSortColumn == 'XX_hasPatents')
				{
				return MS_Tools.Compare(hasPatents, ((LitigationWrapper)objToCompare).hasPatents, '', ctrl.Lit_IsAsc);
				}
			else if (ctrl.Lit_CurrentSortColumn == 'XX_AssociatedAcq')
				{
				return MS_Tools.Compare(AssociatedAcq, ((LitigationWrapper)objToCompare).AssociatedAcq, '', ctrl.Lit_IsAsc);
				}
			else if (ctrl.Lit_CurrentSortColumn == 'XX_isAssociatedToOpp')
				{
				return MS_Tools.Compare(isAssociatedToOpp, ((LitigationWrapper)objToCompare).isAssociatedToOpp, '', ctrl.Lit_IsAsc);
				}
			else
				{
				return MS_Tools.Compare(lit, ((LitigationWrapper)objToCompare).lit, ctrl.Lit_CurrentSortColumn, ctrl.Lit_IsAsc);
				}
			}
	}

	//-------------------------------------------------------------------------------------------------------
	// PatentWrapper
	//-------------------------------------------------------------------------------------------------------
	public class PatentWrapper
		{
    public Patent__c pat{get;set;}
    public boolean   isInSuit{get;set;}

		public PatentWrapper(Patent__c pat)
			{
			this.pat = pat;
			this.isInSuit = false;
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
		
		Test.setCurrentPage(Page.MS_RelatedLitigation_Lit);

		Map<String,String> pageParams = ApexPages.currentPage().getParameters();
		pageParams.put('Id', lstLitigation[0].Id);

		MS_RelatedLitigationCtrl controller = new MS_RelatedLitigationCtrl();

		controller.UpdateFields();

		// ---------------------------------------

		Test.setCurrentPage(Page.MS_RelatedLitigation_Acq);

		pageParams = ApexPages.currentPage().getParameters();
		pageParams.put('Id', acqOpp.Id);

		controller = new MS_RelatedLitigationCtrl();

		controller.UpdateFields();

		// ---------------------------------------

		Test.stopTest();		
		}

	}