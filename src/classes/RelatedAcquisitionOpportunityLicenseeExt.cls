/*****************************************************************************
 * Name             : RelatedAcquisitionOpportunityLicenseeExt
 * Created By       : Bharti(Appirio Offshore)
 * Created Date     : 13 Feb, 2012.
 * Purpose          : Extension Class for licensees related to patent families related to that acquisition opportunity
*****************************************************************************/
public without sharing class RelatedAcquisitionOpportunityLicenseeExt {
    public List<Licensees__c> licensees {get;set;} 
    public Map<Id, Integer> mapCounts {get;set;}
    public Integer totalPatents {get;private set;}
    public String currentSortColumn{get;set;}
    public boolean isAsc{set; get;} 
    private string previousSortColumn;  
    private string sortDir;   
    Id currentRecordId;
    public RelatedAcquisitionOpportunityLicenseeExt(ApexPages.StandardController controller){
        currentRecordId = controller.getId();
       // licensees = new List<Licensees__c>();  
       // mapCounts = new Map<Id, Integer>();
        currentSortColumn = 'Account__r.Name';
    	previousSortColumn = 'Account__r.Name';     
    	isAsc = true;
    
        if(currentRecordId != null){
        	/*
            Set<Id> patentFamilyIds = AcquisitionOpportunityUtility.getPatentFamiliesForAcqOppty(currentRecordId);
            for(Licensees__c lc :[Select Name,Account__c,Account__r.Name,Patent_Family__c,Patent_Family__r.Name,Licensee_Note__c From Licensees__c Where Patent_Family__c IN : patentFamilyIds order by Account__r.Name]){
                if(mapCounts.containsKey(lc.Account__c)){
                    mapCounts.put(lc.Account__c, mapCounts.get(lc.Account__c) + 1) ;
                }else{
                    mapCounts.put(lc.Account__c, 1) ;
                    licensees.add(lc);
                }
            }*/
            sortData();
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
     	licensees = new List<Licensees__c>();  
        mapCounts = new Map<Id, Integer>();
     	Set<Id> patentFamilyIds = AcquisitionOpportunityUtility.getPatentFamiliesForAcqOppty(currentRecordId);
        for(Licensees__c lc :(List<Licensees__c>)Database.query('Select Name,Account__c,Account__r.Name,Patent_Family__c,Patent_Family__r.Name,Licensee_Note__c From Licensees__c Where Patent_Family__c IN : patentFamilyIds ' + 'order by '+ currentSortColumn + ' '+sortDir)){
            if(mapCounts.containsKey(lc.Account__c)){
                mapCounts.put(lc.Account__c, mapCounts.get(lc.Account__c) + 1) ;
            }else{
                mapCounts.put(lc.Account__c, 1) ;
                licensees.add(lc);
            }
        }
     }
}