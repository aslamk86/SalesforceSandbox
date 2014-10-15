/**
    * Apex Class : AccountPotentiallyReleventCompaniesExt
    * Description : Controller Class of  Inline VF (AccountPotentiallyReleventCompanies) To show all Acquisition Opportunities.
    * Created By : Bharti(Offshore)
    * Created Date : 23rd April
    */
public without sharing class AccountPotentiallyReleventCompaniesExt{
    
  private Account currentRecord;
  public List<Acquisition_Opportunity__c> acquisitionOpportunities{get;set;}
  public String currentSortColumn{get;set;}
  public boolean isAsc{set; get;} 
  private string previousSortColumn;  
  private string sortDir;    
    
  //Constructor of Standard Controller
  public AccountPotentiallyReleventCompaniesExt(ApexPages.StandardController controller) {
    currentRecord = (Account)controller.getRecord();
    currentSortColumn = 'Name';
    previousSortColumn = 'Name';     
    isAsc = true;
    /*
    //pull all patent families related to the account using potentially relevent companies relation
    Set<Id> patentFamilyIds = getRelatedPatentFamilyIds();
    
    //pull all acq oppty ids related to patentFamilyIds
    Set<Id> acquisitionOpportunityIds = new Set<Id>();
    acquisitionOpportunityIds.addAll(getLitigationAcqOpportunityIds(patentFamilyIds));
    acquisitionOpportunityIds.addAll(getOMAAcqOpportunityIds(patentFamilyIds));
    
    
    //fetch all acq oppty details to be displayed on the inline VF
    acquisitionOpportunities = [Select Id,Name,recordType.Name,Analysis_Stage__c,Analysis_Assigned_to__c,StageName__c,CreatedDate  From Acquisition_Opportunity__c  Where Id IN : acquisitionOpportunityIds order by recordType.Name , Name];
    
    //Check that size of list acquisitionOpportunities is zero then set the error message.
    if(acquisitionOpportunities.size() == 0) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found)); 
    }
    */  
    //sortData();
  }
     
  public void executeQuery(){ 
    //pull all patent families related to the account using potentially relevent companies relation
    Set<Id> patentFamilyIds = getRelatedPatentFamilyIds();   
    
    //pull all acq oppty ids related to patentFamilyIds
    Set<Id> acquisitionOpportunityIds = new Set<Id>();      
    acquisitionOpportunityIds.addAll(getLitigationAcqOpportunityIds(patentFamilyIds));
    acquisitionOpportunityIds.addAll(getOMAAcqOpportunityIds(patentFamilyIds));          
    //fetch all acq oppty details to be displayed on the inline VF
    acquisitionOpportunities = (List<Acquisition_Opportunity__c>)Database.query('Select Id,Name,recordType.Name,Analysis_Stage__c,Analysis_Assigned_to__c,StageName__c,CreatedDate  From Acquisition_Opportunity__c  Where Id IN : acquisitionOpportunityIds   order by '+currentSortColumn + ' '+sortDir);
    
    //Check that size of list acquisitionOpportunities is zero then set the error message.
    if(acquisitionOpportunities.size() == 0) {  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found)); 
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
      
  //pull all patent families related to the account using potentially relevent companies relation
  private Set<Id> getRelatedPatentFamilyIds(){
    Set<Id> patentFamilyIds = new Set<Id>();
    for (Potentially_Relevant_Company__c cwc : [ Select Patent_Family__c From Potentially_Relevant_Company__c  Where  Account__c = : currentRecord.Id]) {
        patentFamilyIds.add(cwc.Patent_Family__c);           
    }    
    return patentFamilyIds;
  }
  
  //pull all litigation acq oppty ids related to patentFamilyIds
  private Set<Id> getLitigationAcqOpportunityIds(Set<Id> patentFamilyIds){
    Set<Id> acqOpptyIds = new Set<Id>();
    for(Opportunity_Litigation__c oppLitigation : [Select Acquisition_Opportunity__c From Opportunity_Litigation__c 
                                                   Where Litigation__c IN (Select Litigation__c From Litigation_Patent_Family__c Where Patent_Family__c IN : patentFamilyIds)]){
        acqOpptyIds.add(oppLitigation.Acquisition_Opportunity__c);
    }
    return acqOpptyIds;
  }
  
  //pull all OMA/HUB SA acq oppty ids related to patentFamilyIds
  private Set<Id> getOMAAcqOpportunityIds(Set<Id> patentFamilyIds){
    Set<Id> acqOpptyIds = new Set<Id>();
    for(Acquisition_Patent_Families__c omaPatentFamily : [Select Acquisition_Opportunity__c 
                                                          From Acquisition_Patent_Families__c 
                                                          Where Patent_Family__c IN : patentFamilyIds]){
        acqOpptyIds.add(omaPatentFamily.Acquisition_Opportunity__c);
    }
    return acqOpptyIds;
  }
  
}