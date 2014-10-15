/****************************************************************************************************************************
 * Name             : LinkPotentiallyRelevantCompaniesCtrl
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 31 MAR, 2012.
 * Purpose          : LinkPotentiallyRelevantCompaniesCtrl
                    : Controller for generic page accessed from 
                        -   Acquisition Oppty detail page (Custom Link : Link Relevant Companies) 
                        -   Acquisition Oppty detail page (Custom Link : Link Licensees) 
                        -   Patent Family(New button on Potentially Relevant Accounts related list)
                        - Patent Family(New button on Licensee related list)
                      This page has 3 sections:
                      Section 1 : Select Patent Family(In case accessed from acquisition opportunity)
                      Section 2 : Filter criteria for company search
                      Section 3 : Result Companies based on search filter
****************************************************************************************************************************/
public without sharing class LinkPotentiallyRelevantCompaniesCtrl {
  
  //constants
  private static final String POTENTIAL_RELEVANT = 'PotentialRelevance';
  private static final String LICENSEE = 'Licensee';
  
  private Id acqOppId;
  private Id pfId;
  private String RECORD_TYPE_MEMBER = 'Member';
  private String RECORD_TYPE_PROSPECT = 'Prospect';
  private String ERROR_NO_FAMILY_SELECTED = Label.Atleast_One_Family_Required;
  private String ERROR_ACCOUNT_AND_FAMILY_REQUIRED = Label.Atleast_One_Account_And_Family_Required;
  private String INFO_NO_RECORD_FOUND = Label.No_Record_Found_For_Given_Criteria;
  private String returnURL;
  private Set<Id> alreadyAddedCompanies;
  private Set<Id> selectedPatentFamilies;
  
  
  //Variables used in custom query because custom query needs class level variable for execution of query in different methods. 
  private Set<String> accRecTypes;
  private Set<Id> accIds;
  private Set<Id> prodIds;
  private String srchExp;
  private String accountSector;
  
  //Page Variables
  public Acquisition_Opportunity__c acqOpp{get;set;}
  public String currentView{get;set;}
  public Account account{get;set;}
  public List<PatentFamilyWrapper> lstPatentFamilies{get;set;}
  public List<AccountWrapper> lstAccounts{get;set;}
  public List<SelectOption> companyTypeOptions{get;set;}
  public String companyType{get;set;}
  public Boolean runningInPfContext{get;set;}
  public Boolean runningInAcqOppContext{get;set;}
  public Boolean bypassProductServiceMatch{get;set;}
  
  public String pageTitle {
    get{
        return currentView == POTENTIAL_RELEVANT? 'Potentially Relevant Companies' : 'Licensees';
    }
  }
  
  //variables for Sorting
  private String previousSortField = '';
  public Boolean isAscending {get;set;}
  
  //Properties
  public string sortField {
    get;
        set {     
          this.previousSortField = sortField;
          this.sortField = value;
          if(previousSortField == sortField) {
            isAscending = !isAscending;
            return;
      }
        this.isAscending = true;  
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Controller Constructor
  //-------------------------------------------------------------------------------------------------------------------------
  public LinkPotentiallyRelevantCompaniesCtrl() {
    //Default Sort Field
    SortField = 'RecordType.Name , RPX_RCRate__c';
    isAscending = true;
        
    //Initialize variables
    lstPatentFamilies = new List<PatentFamilyWrapper>();
    lstAccounts = new List<AccountWrapper>();
    account = new Account();
    bypassProductServiceMatch = false;
    
    //get Page Parameters
    Map<String, String> pageParams = ApexPages.currentPage().getParameters();
    if (pageParams.containsKey('id')) {
      acqOppId = pageParams.get('id');
      runningInAcqOppContext = true;
      returnURL = '/' + acqOppId;
      acqOpp = [Select id, Name From Acquisition_Opportunity__c Where id = :acqOppId];
      init();
    } else {
      if(pageParams.containsKey('pfId')) {
        pfId = pageParams.get('pfId');
        runningInPfContext = true;
        returnURL = '/' + pfId;
        init();
      }
    }
    currentView = pageParams.containsKey('objectType')?  pageParams.get('objectType') : POTENTIAL_RELEVANT;
    if (currentView == LICENSEE) {
        bypassProductServiceMatch = true;
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Search Account & Products for filter criteria.
  //-------------------------------------------------------------------------------------------------------------------------
  public pageReference search() {
    //fetch selected patent families
    selectedPatentFamilies = getSelectedFamilyIds(lstPatentFamilies);
    
    //check for validations when user clicks on search
    if(isValidSearch(selectedPatentFamilies)) {
        alreadyAddedCompanies = getAlreadyAddedRelevantCompanies(selectedPatentFamilies);
        lstAccounts = loadRelatedAccounts(selectedPatentFamilies);//modified by bharti on 27th June 2012
    } else {
        //clear search result if an invalid search is attempted
        lstAccounts.clear();
    }
    return null;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Do Sort
  //-------------------------------------------------------------------------------------------------------------------------
  public void doSort() {
    // Need to preserve selection While sorting, So preparing a set of selected account ids 
    Set<Id> selectedAccIds = new Set<Id>();
    for(AccountWrapper accWrap : lstAccounts) {
        if(accWrap.isSelected) {
          selectedAccIds.add(accWrap.account.Id);
        }
    }
    String qry = prepareQueryForAccounts();
    lstAccounts = execAccountQuery(qry,selectedPatentFamilies);
    
    for(AccountWrapper accWrap : lstAccounts) {
      if(selectedAccIds.contains(accWrap.account.Id)) {
        accWrap.isSelected = true;
      }
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Return back to Acquisition opportunity Record
  //-------------------------------------------------------------------------------------------------------------------------
  public pageReference cancel() {
    PageReference pg = new PageReference(returnURL);
    pg.setRedirect(true);
    return pg;
  } 
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Create Records for Selected Account and families.
  //-------------------------------------------------------------------------------------------------------------------------
  public pageReference createCompanyWhoCareRecords() {
    
    //get selected patent family List
    selectedPatentFamilies = getSelectedFamilyIds(lstPatentFamilies);
    
    //get selected account List
    Set<Id> accIds = getSelectedAccountIds(lstAccounts);
    
    //check that user has selected atleast one family and one account
    if(isValidSelection(selectedPatentFamilies, accIds)){
        //fetch existing records of Potentially relevant companies
        Set<String> existingRecs =  getFamilyAndExistingRelevantCompany(accIds, selectedPatentFamilies);
        //Create List of Potentially_Relevant_Company__c records to be inserted
        List<sObject> lstCompaniesWhoCare = new List<sObject>(); 
        
        for (Id pfId : selectedPatentFamilies) {
          for(Id accId : accIds) {
            //only if there is no existing Mapping for same account and family
            if(!existingRecs.contains(getKey(accId, pfId))) {
                if(currentView == POTENTIAL_RELEVANT) {
                	lstCompaniesWhoCare.add(new Potentially_Relevant_Company__c(Patent_Family__c = pfId,Account__c = accId));
                }else {
                	lstCompaniesWhoCare.add(new Licensees__c(Patent_Family__c = pfId,Account__c = accId));
                }
            } 
          }
        } 
        
	    try{ 
         insert lstCompaniesWhoCare;
        } catch(Exception ex) {
          ApexPages.addMessages(ex);
          return null;
        }
        //PageReference pg = new PageReference(returnURL);
        //PageReference pg = new PageReference(ApexPages.CurrentPage().getUrl());
        //pg.setRedirect(true);
        search();
        return null;
    
    } else {
        return null;
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  // confirm that user has selected atleast one patent family and one account
  //-------------------------------------------------------------------------------------------------------------------------
  private Boolean isValidSelection( Set<Id> selectedFamilyIds, Set<Id> selectedAccountIds) {
    //show warning message if account or patent family is not selected
    if(selectedFamilyIds.size() == 0 || selectedAccountIds.size() == 0) {
      if(runningInPfContext != null && runningInPfContext) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.Account_Required));
      } else {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ERROR_ACCOUNT_AND_FAMILY_REQUIRED));
      }
        return false;
    }
    return true;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns already added company records as a Set of Keys where key = family id + accountId
  //-------------------------------------------------------------------------------------------------------------------------
  private Set<String> getFamilyAndExistingRelevantCompany(Set<Id> accIds, Set<Id> familyIds) {
    Set<String> existingRecs = new Set<String>();    
    String soql = 'Select Patent_Family__c, Account__c From ' 
                + (currentView == POTENTIAL_RELEVANT? 'Potentially_Relevant_Company__c' : 'Licensees__c')
                + ' Where Patent_Family__c in :familyIds AND Account__c in :accIds';

    for (sObject prc : database.query(soql)) {
      existingRecs.add(getKey((Id)prc.get('Account__c'), (Id)prc.get('Patent_Family__c')));                                   
    }
    return existingRecs;
  }
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns key as combination of accountId and Family Id
  //-------------------------------------------------------------------------------------------------------------------------
  private String getKey(Id accId, Id familyId) {
    return (accId + '~' + familyId);
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Initialize lists for page
  //-------------------------------------------------------------------------------------------------------------------------
  private void init() {
     populateCompanyType();
     companyType = 'Both';
     loadPatentFamilies();
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //populate list of company types in search section
  //-------------------------------------------------------------------------------------------------------------------------
  private void populateCompanyType() {
    companyTypeOptions = new List<SelectOption>();
    companyTypeOptions.add(new SelectOption(RECORD_TYPE_MEMBER, RECORD_TYPE_MEMBER));
    companyTypeOptions.add(new SelectOption(RECORD_TYPE_PROSPECT, RECORD_TYPE_PROSPECT));
    companyTypeOptions.add(new SelectOption('Both', 'Both'));
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Fetch related family records
  //-------------------------------------------------------------------------------------------------------------------------
  private void loadPatentFamilies() {
    Set<Id> patentFamilyIds = new Set<Id> ();
    //pfId will be passed if this page is accessed from patent family
    if(pfId != null) {
        //If accessed from Patent Family then add patent family in set
      patentFamilyIds.add(pfId);
    } else {
        //If accessed from acquisition opportunity fetch all related patent family
      patentFamilyIds.addAll(AcquisitionOpportunityUtility.getPatentFamiliesForAcqOppty(acqOppId)); 
    }
    
    //modifieid by bharti on 27th June 2012 start
    //pull all patents related to the patent family and map all patents with related patent family
    Map<Id,List<Patent__c>> mapPatents = new Map<Id,List<Patent__c>>();
    for(List<Patent__c> patents : [Select Patent_No__c,Title__c,Patent_Family__c From Patent__c Where Patent_Family__c IN :patentFamilyIds]){
    	for(Patent__c patent : patents){
    		if(!mapPatents.containsKey(patent.Patent_Family__c))
    			mapPatents.put(patent.Patent_Family__c, new List<Patent__c>());    			
    		mapPatents.get(patent.Patent_Family__c).add(patent);    		
    	}    	
    }
    
    
    //query patent family along with patents
    for(Assets__c family : [Select id, Name, Asset_Type__c, Type__c
    						//commented by bharti on 27th June 2012
                           //(Select Product_or_Service__c From Portfolio_to_Product_Mappings__r), 
                           //(Select Patent_No__c,Title__c From Patents__r Order by Patent_No__c)
                            From Assets__c 
                            Where id in :patentFamilyIds 
                            Order by Name]) {
            
      if(runningInPfContext != null && runningInPfContext) {
        //if accessed from patent family then select patent family by default                        
        lstPatentFamilies.add(new PatentFamilyWrapper(family,mapPatents.get(family.id), true));
      } else {
        //if accessed from Acquisition Opportunity then do not select patent family by default
        lstPatentFamilies.add(new PatentFamilyWrapper(family,mapPatents.get(family.id), false));
      }                        
    }
    //modifieid by bharti on 27th June 2012 end
    
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Validates that atleast one patent family is selected
  //-------------------------------------------------------------------------------------------------------------------------
  private Boolean isValidSearch(Set<Id> familyIds) {
    Boolean isValid = true;
    //if no patent family selected then display warning message
    if(familyIds.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,ERROR_NO_FAMILY_SELECTED));
      isValid = false; 
    }
    return isValid;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Fetch related Account records
  //-------------------------------------------------------------------------------------------------------------------------
  //modified by bharti on 27th June 2012 start
  //private List<AccountWrapper> loadRelatedAccounts(List<PatentFamilyWrapper> lstSelectedPatentFamily) { 
  private List<AccountWrapper> loadRelatedAccounts(Set<Id> familyIds) {
    // if user has not selected bypass Product Service Match then get all products related to product families
    // and get their related accounts 
    if(!bypassProductServiceMatch) {
        prodIds = getProductIdsOfSelectedFamily(familyIds);
        accIds = AcquisitionOpportunityUtility.getAccountIdsForProducts(prodIds);
    }
    //perpare and execute query for accounts
    String qry = prepareQueryForAccounts();
    return execAccountQuery(qry,familyIds);
  }
  //modified by bharti on 27th June 2012 end
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Executes Account Query and return wrapper list of accounts for resultset
  //-------------------------------------------------------------------------------------------------------------------------
  private List<AccountWrapper> execAccountQuery(String qry,Set<Id> familyIds) {
    List<AccountWrapper> lstAccWrapper = new List<AccountWrapper> (); 
    for(Account acct : (List<Account>)Database.query(prepareQueryForAccounts())) {
        //Select and disable already added companies only if a single Patent Family is selected
        if(selectedPatentFamilies.size() == 1 && alreadyAddedCompanies.contains(acct.Id)) {
        	lstAccWrapper.add(new AccountWrapper(acct, true));
        } else {
            lstAccWrapper.add(new AccountWrapper(acct, false));
        }
    }
    if (lstAccWrapper.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,INFO_NO_RECORD_FOUND));
    }
    return lstAccWrapper;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns query for Accounts
  //-------------------------------------------------------------------------------------------------------------------------
  private String prepareQueryForAccounts() {
    accountSector = account.Primary_Market_Sector__c;
    String qry = ' Select id, Name,Type, RPX_RCRate__c, RecordType.Name From Account ';
    
    if(!bypassProductServiceMatch) {
      qry += getFilterLogic(qry) + ' id in :accIds';
    }
    if(accountSector != null && accountSector.trim() != '') {
      qry += getFilterLogic(qry) + ' Primary_Market_Sector__c = :accountSector';
    }
    //Account Name Filter
    if (account.Name != null && account.Name.trim() != '') {
      srchExp = '%' + account.Name + '%'; 
      qry += getFilterLogic(qry) + ' Name like :srchExp';
    }
    //Company Filter
    accRecTypes = new Set<String>();
    if (companyType != null && companyType == 'Both') {
      accRecTypes.add(RECORD_TYPE_MEMBER);
      accRecTypes.add(RECORD_TYPE_PROSPECT);
    } else {
      accRecTypes.add(companyType);
    }
    qry += getFilterLogic(qry) + ' RecordType.Name in :accRecTypes';
    
    //Sorting field
    qry += ' ORDER BY ' + SortField;
    
    //get Sort Order
    string sortingOrder = 'ASC';
    if (isAscending == false){
      sortingOrder = 'DESC';
    }   
    qry += ' ' + sortingOrder;
    qry += ' NULLS LAST Limit 1000';
    return qry;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns "Where" or "And" for query filter based on given query
  //-------------------------------------------------------------------------------------------------------------------------
  private String getFilterLogic(String query) {
    String filterLogic;
    if(query.contains(' Where ')) {
      filterLogic = ' And ';
    } else {
      filterLogic = ' Where ';
    }
    return filterLogic;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns selected Patent Family Ids 
  //-------------------------------------------------------------------------------------------------------------------------
  private Set<Id> getSelectedFamilyIds(List<PatentFamilyWrapper> lstSelectedPatentFamily) {
    Set<Id> familyIds = new Set<Id>();
    //prepare set of selected Patent Family ids
    for (PatentFamilyWrapper pfw : lstSelectedPatentFamily) {
    	 if(pfw.isSelected) {
    	 	familyIds.add(pfw.patentfamily.Id);
    	 }      
    }
    return familyIds;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns selected AccountIds 
  //-------------------------------------------------------------------------------------------------------------------------
  private Set<Id> getSelectedAccountIds(List<AccountWrapper> lstSelectedAccountWrap) {
    Set<Id> accIds = new Set<Id>();
    //prepare set of selected account ids
    for(AccountWrapper aw : lstSelectedAccountWrap) {
      if(aw.isSelected){
      	accIds.add(aw.account.Id);
      }      
    }
    return accIds;
  }
  
  //------------------------------------------------------------------------------------------------------------------------
  //Returns ProductIds related to Selected Patent Families
  //------------------------------------------------------------------------------------------------------------------------
  //commented by bharti on 27th June 2012
  /*private Set<Id> getProductIdsOfSelectedFamily(List<PatentFamilyWrapper> lstPatentFamilies) {
    Set<Id> prodIds = new Set<Id>();
    for (PatentFamilyWrapper pfWrap : lstPatentFamilies) {
      if(pfWrap.patentFamily != null) {
        for(portfolio2product__c pf2p : pfWrap.patentFamily.Portfolio_to_Product_Mappings__r) {
          prodIds.add(pf2p.Product_Or_Service__c);
        }
      }
    }
    return prodIds;
  }*/
  
  //add by bharti on 27th June 2012
  private Set<Id> getProductIdsOfSelectedFamily(Set<Id> familyIds) {
    Set<Id> prodIds = new Set<Id>();
    for(List<portfolio2product__c> pf2ps: [Select Product_Or_Service__c From portfolio2product__c Where Portfolio__c IN : familyIds]) {
    	for(portfolio2product__c pf2p : pf2ps){
    		prodIds.add(pf2p.Product_Or_Service__c);
    	}
    }
    return prodIds;
  }
  
  //------------------------------------------------------------------------------------------------------------------------
  //Returns Set of already added relevant companies as a Set of key (key = AccountId + Patent Family Id)
  //------------------------------------------------------------------------------------------------------------------------
  private Set<Id> getAlreadyAddedRelevantCompanies(set<Id> familyIds)  {
    Set<Id> existingRecs = new Set<Id>();
    String soql = 'Select Patent_Family__c, Account__c From ' 
                + (currentView == POTENTIAL_RELEVANT? 'Potentially_Relevant_Company__c' : 'Licensees__c')
                + ' Where Patent_Family__c in :familyIds';

    for (sObject prc : database.query(soql)) {
      existingRecs.add((Id)prc.get('Account__c'));                                   
    }
    return existingRecs;
  }
  
  
  /*********************************************** Inner Wrapper Classes*********************************************************/
    
  //-------------------------------------------------------------------------------------------------------------------------
  //Wrapper Class for Patent Family Result Set
  //-------------------------------------------------------------------------------------------------------------------------
  public Class PatentFamilyWrapper {
    public Boolean isSelected{get;set;}
    public Boolean isDisabled{get;set;}
    public Assets__c patentFamily{get;set;} 
    public String patentNumbers{get;set;}    
    
    //Constructor
    //public PatentFamilyWrapper(Assets__c patentFamily, Boolean isSelected) {
    public PatentFamilyWrapper(Assets__c patentFamily,List<Patent__c> patents, Boolean isSelected) {
      this.patentFamily = patentFamily;
      this.isSelected = isSelected;
      
      //modified by bharti on 27th June 2012 start
      patentNumbers = '';        
      if(patents != null){
  		  for(Patent__c pt : patents) {
	        if(pt.Patent_No__c != null) {
	         	patentNumbers += (pt.Patent_No__c + ' - ' + (pt.Title__c != null ? pt.Title__c : '')) + '<br/>';
	        }
	      }
      }            
      //modified by bharti on 27th June 2012 end
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Wrapper Class for Account Result Set
  //-------------------------------------------------------------------------------------------------------------------------
  public Class AccountWrapper {
    public Boolean isSelected{get;set;}
    public Boolean isDisabled{get;set;}
    public Account account{get;set;}
    //constructor
    public AccountWrapper(Account account, Boolean isSelected) {
      this.account = account;
      this.isSelected = isSelected;
      this.isDisabled = isSelected;
    }
  }
}