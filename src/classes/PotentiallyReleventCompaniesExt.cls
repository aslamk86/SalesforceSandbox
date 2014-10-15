/****************************************************************************************************************************
    * Apex Class        : PotentiallyReleventCompaniesExt
    * Description   : Controller Class of  Inline VF (PotentiallyReleventCompanies) To show all Relevent Compaines.
    * Created By        : Neeraj Gupta
    * Created Date  : 13 Feb 2012
    * Task                  :   T-26957
    * Modified By   : Sudhir Kr. Jagetiya, Neeraj Gupta
    * Last Modified Date : 20 April 2012., 24 April 2012
****************************************************************************************************************************/
public without sharing class PotentiallyReleventCompaniesExt{
    private Acquisition_Opportunity__c acqOpp;
    private String previousSortField = '';
    private Set<Id> patentFamilyIds;
    
    public List<Potentially_Relevant_Company__c> lstCompaniesWhoCare{get;set;}
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
    //Constructor of Standard Controller
  //-------------------------------------------------------------------------------------------------------------------------
    public PotentiallyReleventCompaniesExt(ApexPages.StandardController controller) {
        acqOpp = (Acquisition_Opportunity__c)controller.getRecord();
        patentFamilyIds = AcquisitionOpportunityUtility.getPatentFamiliesForAcqOppty(acqOpp.Id);
    //Default sort fields and sort order
    //sortField = 'Account__r.RecordType.Name, Account__r.Name';
    sortField = 'Account__r.Type';    
    isAscending = false;
    doSort();
        
    }
    
    //-------------------------------------------------------------------------------------------------------------------------
  //Sort and Populate Resultset
  //-------------------------------------------------------------------------------------------------------------------------
    public pageReference doSort() {
        string sortingOrder = 'ASC';
        if (isAscending == false){
        sortingOrder = 'DESC';
      } 
        
      lstCompaniesWhoCare = new List<Potentially_Relevant_Company__c>();
        
      //All Accounts those are included to display
      Set<Id> includedCompanies = new Set<Id>();
        
      //Prepare query for execution
        String qry  =  'Select Id, Name, Account__r.Name, Patent_Family__r.Name,Account__r.RecordType.DeveloperName, Account__r.Type'
                    + ' From Potentially_Relevant_Company__c '
                    + ' Where  Patent_Family__c in :patentFamilyIds ' 
                    + 'Order by ' + sortField + ' ' + sortingOrder;
    if(sortField=='Account__r.Type')
    	qry = qry + ' , Account__r.Name ASC';
      
    for (Potentially_Relevant_Company__c cwc : (List<Potentially_Relevant_Company__c>)Database.query(qry)) {
        if(!includedCompanies.contains(cwc.Account__c)){
            includedCompanies.add(cwc.Account__c);
            lstCompaniesWhoCare.add(cwc);
        }
    }
        
    //Check that size of list lstCompaniesWhoCare is zero then set the error message.
    if(lstCompaniesWhoCare.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found)); 
    }
    return null;
    }
    
}