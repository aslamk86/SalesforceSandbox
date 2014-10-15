/*****************************************************************************
 * Name             : PatentsInSuitController
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 03 Feb, 2012.
 * Purpose          : Extension Class for Relevant_Litigation_Patents
 * Task             : T-24261
*****************************************************************************/
public without sharing class PatentsInSuitController{
  
  private Acquisition_Opportunity__c acqOpp;
  private Set<Id> relatedLitigationIds;
  public List<Patents_in_Suit__c> lstPatentsInSuit{get;set;}
  public String currentSortColumn{get;set;}
  public boolean isAsc{set; get;} 
  private string previousSortColumn;  
  private string sortDir;  
  
  //---------------------------------------------------------------------------
  //Constructor
  //---------------------------------------------------------------------------
  public PatentsInSuitController(ApexPages.StandardController controller){
    
    lstPatentsInSuit = new List<Patents_in_Suit__c>();
    acqOpp = (Acquisition_Opportunity__c) controller.getRecord();
    currentSortColumn = 'Name';
    previousSortColumn = 'Name';     
    isAsc = true;
    
    relatedLitigationIds = new Set<Id>();
    //fetch related opportunity litigation ids
    for (Opportunity_Litigation__c ol : [Select id, Litigation__c
                                         From Opportunity_Litigation__c
                                         Where Acquisition_Opportunity__c = :acqOpp.Id]) {
      relatedLitigationIds.add(ol.Litigation__c);                                                 
    }
    
            
        
        
    
    
   /* Set<Id> patentIds = new Set<Id> ();
    //query Patents in Suit for litigation and acq opp patents
    for (Patents_in_Suit__c patentInSuit : [ Select id, Patent__r.Name, Litigation__c,
                                                    Patent__r.Title__c, Patent__r.Publication_Number__c, 
                                                    Patent__r.Patent_No__c,  
                                                    Patent__r.Assigned_to__r.Name,
                                                    Patent__r.Priority_Date__c,
                                                    Patent__r.File_Date__c,
                                                    Patent__r.Issue_Date__c, 
                                                    Patent__r.Estimated_Expiration_Date__c
                                             From Patents_in_Suit__c
                                             Where Litigation__c in : relatedLitigationIds
                                             order by Patent__r.Patent_No__c]) {
      
      if(!patentIds.contains(patentInSuit.patent__c)) {
      	if(patentInSuit.Patent__r.Title__c != null && patentInSuit.Patent__r.Title__c.length() > 50) {
      	 patentInSuit.Patent__r.Title__c = patentInSuit.Patent__r.Title__c.subString(0, 50);
      	}
        lstPatentsInSuit.add(patentInSuit);
      }
      patentIds.add(patentInSuit.patent__c);
                                 
    }*/
    sortData();
    
    if (lstPatentsInSuit.size() == 0) {
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, Label.No_Record_Found));
    }
  
  }
  
  public void executeQuery(){
  		Set<Id> patentIds = new Set<Id> ();
  		if(lstPatentsInSuit != null && lstPatentsInSuit.size() >0){
  		 	lstPatentsInSuit.clear();
  		}
  		String qry = 'Select id, Patent__r.Name, Litigation__c,'+
	                                                    ' Patent__r.Title__c, Patent__r.Publication_Number__c, '+
	                                                    ' Patent__r.Patent_No__c,  '+
	                                                    ' Patent__r.Assigned_to__r.Name,'+
	                                                    ' Patent__r.Priority_Date__c,'+
	                                                    ' Patent__r.File_Date__c,'+
	                                                    ' Patent__r.Issue_Date__c, '+
	                                                    ' Patent__r.Estimated_Expiration_Date__c'+
	                                             ' From Patents_in_Suit__c'+
	                                             ' Where Litigation__c in : relatedLitigationIds'+
	                                             ' order by '+ currentSortColumn + ' '+sortDir;
	                                             
	    //query Patents in Suit for litigation and acq opp patents
	    for (Patents_in_Suit__c patentInSuit : (List<Patents_in_Suit__c>)Database.query(qry)) {
	      
	      if(!patentIds.contains(patentInSuit.patent__c)) {
	      	if(patentInSuit.Patent__r.Title__c != null && patentInSuit.Patent__r.Title__c.length() > 50) {
	      	 patentInSuit.Patent__r.Title__c = patentInSuit.Patent__r.Title__c.subString(0, 50);
	      	}
	        lstPatentsInSuit.add(patentInSuit);
	      }
	      patentIds.add(patentInSuit.patent__c);
	                                 
	    }
  }
  
  /** This function sorts the result according to given field. 
   *  @return void
   */ 
  public void sortData(){  
      if(previousSortColumn.equals(currentSortColumn)){   
      	isAsc = !isAsc;     
      }else{     
        isAsc = true; 
      }     
      sortDir = isAsc ? ' ASC ' : ' DESC ';   
      previousSortColumn = currentSortColumn;  
      executeQuery(); 
  }
  
}