/**
	* Apex Class : RelatedAcquisitionProductServicesExt
	* Description : Controller Class of  Inline VF (ProductServicesForAcquisition) To show all Product Or services.
	* Created By : Bharti(Appirio Offshore)
	* Created Date : April 18 , 2012
	*/
public without sharing class RelatedAcquisitionProductServicesExt {
	public List<portfolio2product__c> listPortfolio2Product {get;set;}
	public String currentSortColumn{get;set;}
    public boolean isAsc{set; get;} 
    private string previousSortColumn;  
    private string sortDir;
    Id currentRecordId;
    
	//Standard Controller
	public RelatedAcquisitionProductServicesExt(ApexPages.StandardController controller){
		currentRecordId = controller.getId();
		currentSortColumn = 'Product_or_Service__r.Name';
	    previousSortColumn = 'Product_or_Service__r.Name';     
	    isAsc = true;
	    
		if(currentRecordId != null){
			//Set<Id> patentFamilyIds = AcquisitionOpportunityUtility.getPatentFamiliesForAcqOppty(currentRecordId);
			//listPortfolio2Product = loadDistinctData(patentFamilyIds);
			sortData();
		}
		if(listPortfolio2Product.size() == 0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'No Records To Display'));
		}
	}
	//A Method to fetch distinct Product or services
	private List<portfolio2product__c> loadDistinctData(Set<Id> patentFamilyIds){
		List<portfolio2product__c> distinctData = new List<portfolio2product__c> ();
		Set<Id> includedProducts = new Set<Id>();
		for(portfolio2product__c portfolio2Product : (List<portfolio2product__c>)Database.query('Select Product_or_Service__c ,Product_or_Service__r.Name From portfolio2product__c  where Portfolio__c IN :patentFamilyIds order by ' +currentSortColumn + ' '+sortDir)){
			if(!includedProducts.contains(portfolio2Product.Product_or_Service__c)){
				distinctData.add(portfolio2Product);
				includedProducts.add(portfolio2Product.Product_or_Service__c);
			}
		}
		return distinctData;
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
	  	Set<Id> patentFamilyIds = AcquisitionOpportunityUtility.getPatentFamiliesForAcqOppty(currentRecordId);
		listPortfolio2Product = loadDistinctData(patentFamilyIds);
	  }
}