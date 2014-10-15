/*******************************************************************************
 * Name             : NewOpportunityLitigationCtrl
 * Created By       : Neeraj G.(Appirio Offshore)
 * Modified By      : Martin Sieler
 * Created Date     : 14 Mar, 2012.
 * Purpose          : Allows to search Litigations record and associate them to 
                      Acquisition Opportunity.
 *                    T-36662 
 *******************************************************************************/
public with sharing class NewOpportunityLitigationCtrl {

	public boolean ShowExisting{get;set;}

  private Id acqId;
  private Map<String, String> pageParams;
  private Set<Id> existingLitigationIds{get;set;}

  public Acquisition_Opportunity__c acqOpp{get;set;}  
  
  //Search Fields
  public String caseNameToSrch {get;set;}
  public String docketNumberToSrch{get;set;}
  public String LitigationIdToSrch {get;set;}
  public String plainTiffToSrch {get;set;}
  public String caseKeyToSrch {get;set;}
  public String patentNumToSearch{get;set;}
  
  //Result List
  public List<LitigationWrapper> lstLitWrapper{get; set;}
  public Set<Id> litigationIds{get;set;}
  

  //--------------------------------------------------------------------------------------------------------
  //Properties
  //--------------------------------------------------------------------------------------------------------
  private String caseName {
    get {
        if (caseNameToSrch != null && caseNameToSrch.trim() != '') {
        return '%' + caseNameToSrch + '%';
        } else {
            return caseNameToSrch;
        }
    }
  }
  private String plaintiff {
    get {
        if(plainTiffToSrch != null && plainTiffToSrch.trim() != '') {
        return '%' + plainTiffToSrch + '%' ;
        } else {
            return plainTiffToSrch;
        }
    }
  }
  private String docketNumber {
    get {
        if(docketNumberToSrch != null && docketNumberToSrch.trim() != '') {
          return '%' + docketNumberToSrch + '%';
        } else {
          return docketNumberToSrch;
        }
    }
  }
  private String Name {
    get {
        if(LitigationIdToSrch != null && LitigationIdToSrch.trim() != '') {
            return '%' + LitigationIdToSrch + '%';
        } else {
        return LitigationIdToSrch;
        }
    }
  }
  private String caseKey {
    get {
        if(caseKeyToSrch != null && caseKeyToSrch.trim() != '') {
          return '%' + caseKeyToSrch + '%';
        } else {
            return caseKeyToSrch;
        }
    }
  }
  
  //-------------------------------------------------------------------------------------------------------
  // LitigationWrapper class contains information of result table
  //-------------------------------------------------------------------------------------------------------
  public Class LitigationWrapper {
    public Boolean isSelected{get;set;}
    public Litigation__c litigation{get;set;}
    public String patentNumbers{get;set;}
    public Boolean isAssociatedToOpp {get;set;}
    public Boolean isDisabled{get;set;}
    
    public litigationWrapper(Litigation__c litigation, Boolean isDisabled) {
      this.litigation = litigation;
      patentNumbers = '';
      for(Patents_in_Suit__c pis  : litigation.Patents_In_Suit__r) {
        if(pis.Patent__r.Patent_No__c != null) {
          patentNumbers += pis.Patent__r.Patent_No__c + ',';
        }
      }
      if(patentNumbers != '') {
        patentNumbers = patentNumbers.substring(0,patentNumbers.length() - 1);
      }
      if(litigation.Opportunity_Litigation__r.size() > 0) {
        isAssociatedToOpp = true;
      }
      this.isDisabled = isDisabled;
      this.isSelected = isDisabled;
    }
  }
  
  //--------------------------------------------------------------------------------------------------------
  //Constructor
  //--------------------------------------------------------------------------------------------------------
  public NewOpportunityLitigationCtrl() {
  	ShowExisting = true;

    lstLitWrapper = new List<LitigationWrapper> ();
      //litigationToSearch = new Litigation__c();
      existingLitigationIds = new Set<Id>();
      
      pageParams = Apexpages.currentPage().getParameters();
      acqId = pageParams.get('acqId');
      acqOpp = [select Id,Name from Acquisition_Opportunity__c Where id=:acqId];
      
      for(Opportunity_Litigation__c ol : [Select Litigation__c
                                          From Opportunity_Litigation__c
                                          Where Acquisition_Opportunity__c = :acqId]) { 
        existingLitigationIds.add(ol.Litigation__c);
      }
  }
  
  //-------------------------------------------------------------------------------------------------------
  // Returns true if atleast one search criteria is specified
  //-------------------------------------------------------------------------------------------------------
  private Boolean isValidSearch() {
    if(   (caseNameToSrch == null || caseNameToSrch.trim() == '') 
       && (plainTiffToSrch == null || plainTiffToSrch.trim() == '')
       && (docketNumberToSrch == null || docketNumberToSrch.trim() == '')
       && (LitigationIdToSrch == null || LitigationIdToSrch.trim() == '')
       && (patentNumToSearch == null || patentNumToSearch.trim() == '')
       && (caseKeyToSrch == null || caseKeyToSrch.trim() == '')
       ) {
      return false;
    } else {
      return true;
    }
  }

// --- START REPLACED BY NEW VERSION ----------------------------------------------
//
// Martin Sieler: search without any criteria will search for litigations
//                with same patents as currently added litigations
//
/*

  //-------------------------------------------------------------------------------------------------------
  // Fetch Litigations
  //-------------------------------------------------------------------------------------------------------
  public pageReference search() {
    lstLitWrapper.clear();
    if(!isValidSearch()) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Search_Criteria_Required));  
      return null;
    }
    
    String query = prepareQuery();
    for(Litigation__c litigation : Database.query(query) ) {
        if(existingLitigationIds.contains(litigation.Id)) {
          lstLitWrapper.add(new LitigationWrapper(litigation, true));
        } else {
            lstLitWrapper.add(new LitigationWrapper(litigation, false));
        }
    }
    
    if(lstLitWrapper.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found));  
    }
    
     return null;
  }

*/

//
// --- START OF NEW VERSION -------------------------------------------------------
//

  //-------------------------------------------------------------------------------------------------------
  // Fetch Litigations
  //-------------------------------------------------------------------------------------------------------
  public pageReference search()
  	{
    lstLitWrapper.clear();

		String query = '';

    if (!isValidSearch())
			{
			// get patents-in-suit for existing litigations
			Set<String> PatentNumbers = new Set<String>();
			for (Patents_in_Suit__c pis : [Select Patent__r.Patent_no__c 
			                               From Patents_in_Suit__c
			                               Where Litigation__c in :existingLitigationIds And
			                                     Patent__r.Patent_No__c != null And
			                                     Litigation__c != null
			                              ])
				{
				PatentNumbers.add(pis.Patent__r.Patent_no__c);
				}
	
			// get litigations with same patents
			LitigationIds = new Set<Id> ();
			for (Patents_in_Suit__c pis : [Select Litigation__c 
			                               From Patents_in_Suit__c
			                               Where Patent__r.Patent_No__c IN :PatentNumbers And Patent__r.Patent_No__c != null And Litigation__c != null])
				{
				LitigationIds.add(pis.Litigation__c);
				}

			query = 'Select id, Name, Case_Name__c, Docket_Number__c , Filed__c, '
			             + 'Acquisition_Opportunity__r.Name, Case_Key__c, '
			             + '(Select id, Patent__r.Patent_No__c From Patents_In_Suit__r), '
			             + '(Select id From Opportunity_Litigation__r  Limit 1) '
			             + 'From Litigation__c '
			             + 'WHERE id IN :LitigationIds '
			             + (ShowExisting == false ? 'AND id NOT IN :existingLitigationIds ' : '')
			             + 'ORDER BY Filed__c desc';
			}
		else
			{
			query = prepareQuery();
			}

		for (Litigation__c litigation : Database.query(query))
			{
			if (existingLitigationIds.contains(litigation.Id))
				{
				lstLitWrapper.add(new LitigationWrapper(litigation, true));
        }
			else
				{
				lstLitWrapper.add(new LitigationWrapper(litigation, false));
				}
			}

		if (lstLitWrapper.size() == 0)
			{
			ShowExisting = true;
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found));  
			}

		return null;
		}

// --- END REPLACED BY NEW VERSION ------------------------------------------------
  
  //--------------------------------------------------------------------------------------------------------
  //On Save Button Click : Creates Opportunity Litigation Object Records 
  //--------------------------------------------------------------------------------------------------------
  public pageReference createOpportunityLitigations() {
    List<Opportunity_Litigation__c> lstOppLitToInsert = new List<Opportunity_Litigation__c>(); 
    for(LitigationWrapper lwrap : lstLitWrapper) {
        if(lwrap.isSelected && !lwrap.isDisabled) {
         Opportunity_Litigation__c oppLitigation = new Opportunity_Litigation__c();
         oppLitigation.Acquisition_Opportunity__c = acqId;
         oppLitigation.Litigation__c = lwrap.litigation.Id;
         lstOppLitToInsert.add(oppLitigation);
        }
    }
    insert lstOppLitToInsert;
    return new PageReference('/' + acqId);
  }
  
  //-------------------------------------------------------------------------------------------------------
  // Reqturns query in String format 
  //-------------------------------------------------------------------------------------------------------
  private String prepareQuery() {
    litigationIds = new Set<Id> ();
    //Query patents as per given criteria.
    if (patentNumToSearch != null && patentNumToSearch.trim() != '') {
      Set<String> patentNumbers = new Set<String> (); 
      //Kala - 03/20 - Changed the delimeter from "," to ";" ;
      //for(String patentNo : patentNumToSearch.split(',') )  ;
        for(String patentNo : patentNumToSearch.replaceAll(',','').split(';') ) {
        patentNumbers.add(patentNo.trim());
      } 
      for (Patents_in_Suit__c pis : [Select Litigation__c 
                                     From Patents_in_Suit__c
                                     Where Patent__r.Patent_No__c in : patentNumbers And Patent__r.Patent_No__c != null And Litigation__c != null]) {
        litigationIds.add(pis.Litigation__c);
      } 
    }
    Boolean isFilterAdded = false;
    String query = 'Select id, Name, Case_Name__c, Docket_Number__c , Filed__c,'
                       + ' Acquisition_Opportunity__r.Name, Case_Key__c, ' 
                 + '(Select id, Patent__r.Patent_No__c ' 
                 + ' From Patents_In_Suit__r), '
                 + '(Select id From Opportunity_Litigation__r  Limit 1)'
          + ' From Litigation__c '; 
    
    if(caseName != null && caseName.trim() != '') {
        isFilterAdded = true;
      query += ' Where Case_Name__c like :caseName ';
    }
    
    if(plaintiff != null && plaintiff.trim() != '') {
      query += getFilterLogic(query);
      isFilterAdded = true;
      query += ' Plaintiff__c like :plaintiff ';
    }
    
    if(docketNumber != null && docketNumber.trim() != '') {
        query += getFilterLogic(query);
      isFilterAdded = true;
      query += ' Docket_Number__c like :docketNumber ';
    }
    
    if(Name != null && Name.trim() != '') {
        query += getFilterLogic(query);
      isFilterAdded = true;
      query += '  Name like :Name ';
    }
    
    if(casekey != null && casekey.trim() != '') {
      query += getFilterLogic(query);
      isFilterAdded = true;
      query += '  Case_Key__c like :casekey ';
    }
    
    if (patentNumToSearch != null && patentNumToSearch.trim() != '') {
      query += getFilterLogic(query);
      isFilterAdded = true;
      query += ' id in :litigationIds';
    }
    
// --- START REPLACED BY NEW VERSION ----------------------------------------------
//
// Martin Sieler: replaced by new version
//
/*
    query += ' Order by Name ';
*/

//
// --- START OF NEW VERSION -------------------------------------------------------
//

		query += ShowExisting == false ? getFilterLogic(query) + ' id NOT IN :existingLitigationIds ' : ' ';
    query += ' ORDER BY Filed__c desc ';

// --- END REPLACED BY NEW VERSION ------------------------------------------------

    if(!isFilterAdded) {
        query += ' Limit 0';
    }
    return query;
  }
  
  //-------------------------------------------------------------------------------------------------------
  //Returns Where or And for query filter based on given query
  //-------------------------------------------------------------------------------------------------------
  private String getFilterLogic(String query) {
    String filterLogic;
    if(query.contains(' Where ')) {
        filterLogic = ' And ';
      } else {
        filterLogic = ' Where ';
      }
      return filterLogic;
  }
  
  //-------------------------------------------------------------------------------------------------------
  //On Cancel Click : Returns to Acquisition 
  //-------------------------------------------------------------------------------------------------------
  public pageReference cancel() {
      return new PageReference('/' + acqId);
  }
}