/****************************************************************************************************************************
 * Name             : SearchActivityHistoryController
 * Created By       : Neeraj(Appirio Offshore)
 * Created Date     : 15 April, 2012.
 * Purpose          : Controller class for Custom Activity Search Page
 * Task                         :   T-43296
****************************************************************************************************************************/
public without sharing class SearchActivityHistoryController {
	private Map<String, String> pageParams;
	private Id parentId;
	private String previousSortField = '';
	private Boolean showAll = false;
	private Set<Id> oppIds;
	private Set<Id> contactIds = new Set<Id>();
	Set<Id> patentIds = new Set<Id>();
	
	public String searchText {get;set;}
	public List<Task> lstTask {get;set;}
	public String parentRecordName{get;set;}
	public Boolean isAscending {get;set;}
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
	//Constructor
	//-------------------------------------------------------------------------------------------------------------------------
  public SearchActivityHistoryController() {
  	oppIds = new Set<Id>();
    pageParams = Apexpages.currentPage().getParameters();
    if(pageParams.containsKey('Id') && pageParams.get('Id') != '') {
        parentId = pageParams.get('Id');
    }
    if(parentId == null) {
        return;
    }
		
    //initialize task list
    lstTask = new List<Task>();
    
    //get Parent Record Name
    parentRecordName = keyPrefix.getRecordName(parentId);
    
    //initialize
    searchText = '';
    lstTask = new List<Task>();
    
    //Default sort fields and sort order
    sortField = 'CreatedDate';
    isAscending = false;
    
    //get and sort all related records.
    searchActivities();
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Search Activities as per given criteria.
  //-------------------------------------------------------------------------------------------------------------------------
  public PageReference searchActivities() {
  	patentIds = new Set<Id>();
  	patentIds.add(parentId);
    String objectApiName = keyPrefix.GetKeyPrefix(parentId); 
    
    //Check if Account then search Tasks for related contact records as well
    if(objectApiName == 'Account') {
    	for(Account acct : [Select id, (Select id from Opportunities), (Select id from Contacts) From Account Where id = :parentId]) {
    		
    		for (Opportunity opp : acct.Opportunities) {
    			oppIds.add(opp.Id);
	    	}
	    	for (Contact contact : acct.Contacts) {
	    		contactIds.add(contact.Id);
	    	}
    	}
    }
    patentIds.addAll(oppIds);
    
    //get search string formatted as per SOSL find Expression 
    String soslSearchExp = getSearchString(searchText);
    
    //if no Search Expression provided display Message that Search Text Required. 
    if(soslSearchExp.trim() != '') {
	    //Run SOSL and find related records
	    for(List<Sobject> tasks : [FIND :soslSearchExp IN ALL FIELDS RETURNING Task(Id, Subject, Contact_Type__c, WHATID, WHOID, Quality_of_Conversation__c, ImportanceHelpfulnessOfMeeting__c, CreatedDate, LastModifiedDate,ownerId Where WhatId in :patentIds  or WhoId in :contactIds)]) {
	        lstTask = ((List<Task>) tasks);
	    }
	    showAll = false;
    } else {
    	showAll = true;
    }
    
    doSort();
    
    //if no task found then display message that No Record Found.
    if(lstTask.size() == 0) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO , Label.NO_RECORD_FOUND));
    } 
    return null;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Query Tasks with sort order
  //-------------------------------------------------------------------------------------------------------------------------
  public pageReference doSort() {
    string sortingOrder = 'ASC';
    if (isAscending == false){
  		sortingOrder = 'DESC';
    } 
    
    //Prepare query for execution
    String qry = 'Select Id, Subject, Description, Contact_Type__c, WHATID, WHOID, Quality_of_Conversation__c, ImportanceHelpfulnessOfMeeting__c, CreatedDate, LastModifiedDate,ownerId, Activity_Date__c' 
               + ' From Task '
               + ' Where (WhatId in :patentIds or (whoId != null and whoId in :contactIds))';
    
    if(!showAll) {
	    qry += 'and ( id in :lstTask  ';
    	qry += ' Or ' + filterExp('What.Name') ;
    	qry += ' Or ' + filterExp('Owner.Name') ;
    	qry += ' Or ' + filterExp('Who.Name') ;
    	qry += ' Or ' + filterExp('CallType') ;
    	qry += ' Or ' + filterExp('Quality_of_Conversation__c');
    	qry += ' Or ' + filterExp('ImportanceHelpfulnessOfMeeting__c');
    	qry += ' Or ' + filterExp('Contact_Type__c');
    	qry += ')';
    }
    
    qry += ' Order by ' + sortField + ' ' + sortingOrder + ' NULLS LAST ';
    lstTask = Database.query(qry);
    return null;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns String expression for lookup fields
  //-------------------------------------------------------------------------------------------------------------------------
  private String filterExp (String fieldToSearch) {
  	//SOSL do not search into lookup fields due to this a seperate search string is created to search against "Related To Field" Field
    //IF user enters "related to name" in Search String
    String relatedToSearchString = '';
    for(String str : searchText.split(';')) {
    	if(relatedToSearchString == '') {
    		relatedToSearchString += fieldToSearch + ' like ';
    	} else {
    		relatedToSearchString += ' Or ' + fieldToSearch + ' like ';
    	}
    	relatedToSearchString += '\'%'+ str + '%\'';
    }
    return relatedToSearchString;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns user back to Parent Record Page
  //-------------------------------------------------------------------------------------------------------------------------
  public pageReference goBack() {
    return new Pagereference('/' + ParentId);
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns Search String by replacing all semi colons with OR
  //-------------------------------------------------------------------------------------------------------------------------
  private String getSearchString(String searchText) {
    String searchString = '';
    for(String str : searchText.split(';')) {
	    if(str.trim() != '') {
	        if(searchString != '') {
	            searchString += ' OR ';
	        }
	        searchString += str;
	    }
    }
    return searchString;
  } 
}