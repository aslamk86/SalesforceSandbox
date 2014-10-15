/****************************************************************************************************************************
 * Name             : LitAcquisitionPatentFamiliesController
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Apr, 2012.
 * Purpose          : Extension class for LitAcquisitionPatentFamilies VF page
 											Inline Vf page to displays all patent families related to Litigation Acquisition Opportunity.
 * Task             : T-42964
****************************************************************************************************************************/
public without sharing class LitAcquisitionPatentFamiliesController {
	private Acquisition_Opportunity__c acqOpp;
	public List<Assets__c> lstPatentFamilies {get;set;}
	Set<Id> patentFamilyIds ;
	public String currentSortColumn{get;set;}
    public boolean isAsc{set; get;} 
    private string previousSortColumn;  
    private string sortDir; 
    
	//-------------------------------------------------------------------------------------------------------------------------
	//Constructor
	//-------------------------------------------------------------------------------------------------------------------------
	public LitAcquisitionPatentFamiliesController(ApexPages.StandardController controller) {
		acqOpp = (Acquisition_Opportunity__c)controller.getRecord();
		currentSortColumn = 'Account__r.Name';
    	previousSortColumn = 'Account__r.Name';     
    	isAsc = true;
    	
		//Fetch litigations related to acquisition opportunity
		Set<Id> litigationIds = AcquisitionOpportunityUtility.getLitigationsForAcquisition(new Set<Id> {acqOpp.Id});
		
		//Set for related patent Family Ids
		patentFamilyIds = new Set<Id>();
		
		//Fetch patent in suits related to litigations
		for (Patents_in_Suit__c pts : [Select Patent__r.Patent_Family__c 
																	 From Patents_in_Suit__c 
																	 Where Litigation__c in :litigationIds]) {
			//populate patent family set
			patentFamilyIds.add(pts.Patent__r.Patent_Family__c);
		}
		/*
		//Query patent families to display
		lstPatentFamilies = [Select id,Name, Number_of_US_Patents__c, Number_of_US_Applications__c 
												 From Assets__c 
												 Where id in :patentFamilyIds];
	    */
	    sortData();
		if(lstPatentFamilies.size() == 0) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, Label.No_Record_Found));
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
    
     public void executeQuery(){
     	//Query patent families to display
     	String query = 'Select id,Name, Number_of_US_Patents__c, Number_of_US_Applications__c'+
												 ' From Assets__c '+
												 ' Where id in :patentFamilyIds order by '+currentSortColumn+' '+sortDir ;
		lstPatentFamilies = (List<Assets__c>)Database.query(query);
     }
}