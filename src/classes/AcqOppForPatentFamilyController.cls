/****************************************************************************************************************************
 * Name             : AcqOppForPatentFamilyController
 * Created By       : Neeraj(Appirio Offshore)
 * Created Date     : 18 April, 2012.
 * Purpose          : Controller Class for AcqOppForPatentFamily VF Page 
 ****************************************************************************************************************************/
public with sharing class AcqOppForPatentFamilyController {
    private Id recordId;
    private Set<Id> acqIds;
    private String previousSortField = '';

    public List<Acquisition_Opportunity__c> lstAcqOpp{get;set;}
    public String objectType{get;set;}
    
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
    public AcqOppForPatentFamilyController(ApexPages.StandardController controller){
        Id currentRecordId = controller.getId();
        if(currentRecordId != null){
            recordId = currentRecordId;
            objectType = KeyPrefix.GetKeyPrefix(recordId);
            Id pfId;
            if(objectType == 'Patent__c') {
                Patent__c patent =  (Patent__c)controller.getRecord();
                pfId =  patent.Patent_Family__c;//getFamilyId(recordId);
            } else if(objectType == 'Assets__c') {
                pfId = recordId;
            }
            queryAcquisitionOpportunity(pfId);
        }
    }
    public void queryAcquisitionOpportunity(Id pfId) {
        acqIds = AcquisitionOpportunityUtility.getAcqOppForPatentFamily(new Set<Id> {pfId});
        
        //Default sort fields and sort order
    sortField = 'RecordTypeId';
    isAscending = false;
        doSort();
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
    String qry = 'Select id, Name , StageName__c , CreatedDate , OwnerId,RecordType.DeveloperName From Acquisition_Opportunity__c Where id in :acqIds Order by ' 
                         +  sortField + ' ' + sortingOrder;
    lstAcqOpp = (List<Acquisition_Opportunity__c>)Database.query(qry);
    
        if(lstAcqOpp.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.No_Record_Found));
        }
        
    return null;
  }

}