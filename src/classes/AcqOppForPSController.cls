public class AcqOppForPSController {
    
    public Product_or_Service__c ps{get;set;}
    //public List<Acquisition_Opportunity__c> acquisitionList{get;set;}
    public String currentSortColumn{get;set;}
    public boolean isAsc{set; get;} 
    private string previousSortColumn;  
    private string sortDir;  
    
    public AcqOppForPSController(ApexPages.StandardController stdController) {
        this.ps = (Product_or_Service__c)stdController.getRecord();
        currentSortColumn = 'LastModifiedDate';
        previousSortColumn = 'LastModifiedDate';
        isAsc = false;
        SortData(); 
    }
    
    public List<Acquisition_Opportunity__c> GetAcquisitions(){
        Set<Id> psId = new Set<Id>();
        psId.add(ps.Id);
        Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForProducts(psId);
        
        String query = ' Select Id, Name, StageName__c,CreatedDate, Probability__c, CloseDate__c, ' 
            + ' Summary__c, RecordType.Name, Priority__c, Account__c, Account__r.Name, LastModifiedDate'
            + ' From Acquisition_Opportunity__c'
            + ' Where id in :acqIds  order by '+currentSortColumn + ' '+sortDir ; //LastModifiedDate desc';
        
        List<Acquisition_Opportunity__c> result = removeDuplicatedAcqOpp(Database.query(query));
        
        if (result == null || result.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found)); 
            return new List<Acquisition_Opportunity__c>();
        }
        
        return result;
    }
    
    public List<Acquisition_Opportunity__c> RemoveDuplicatedAcqOpp(List<Acquisition_Opportunity__c> entities){
        Set<Id> acqIds =  new Set<Id>();
        for(integer i=entities.size()-1; i>=0; i--){
            if(acqIds.contains(entities.get(i).Id)){
                entities.remove(i);
            }else{
                acqIds.add(entities.get(i).Id);
            }
        }
        
        return entities;
    }
    
    public void SortData(){  
        if(previousSortColumn.equals(currentSortColumn)){   
            isAsc = !isAsc;     
        }else{     
            isAsc = true; 
        }     
        sortDir = isAsc ? ' ASC ' : ' DESC ';   
        previousSortColumn = currentSortColumn;
    }
}