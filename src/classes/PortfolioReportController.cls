/*******************************************
Description : Class to query and fetch 
              data for the recently created
              tags
*******************************************/

public class PortfolioReportController {
    
    public List<portfolio2product__c> allPortfolios{get; set;}
    
    //Dummy fields for the Date
    public Acquisition_Opportunity__c portfolioStart{get; set;}
    public Acquisition_Opportunity__c portfolioEnd{get; set;}
    public Acquisition_Opportunity__c acquiStart{get; set;}
    public Acquisition_Opportunity__c acquiEnd{get; set;}
    
    public Set<id> psId {get; set;}

    public Map<id,List<Acquisition_opportunity__c>> acqMap{get; set;}
    public List<Acquisition_Opportunity__c> result{get; set;}
    
    public Map<id,Product_or_Service__c> prodSer {get; set;}
    
    public Set<id> acqIds {get; set;}

    public String fieldToBeSorted{get; set;}
    public String orderToBeSorted{get; set;}
    
    public Boolean norecords {get; set;}     
    
    public String errorMsg {get; set;}      
    
    public PortfolioReportController(){
    
        //initializing the dummy date fields with default values
        portfolioStart = new  Acquisition_Opportunity__c();
        portfolioStart.Date_Filter__c = System.today()-30;
        
        portfolioEnd = new  Acquisition_Opportunity__c();
        portfolioEnd.Date_Filter__c = System.today();
        
        acquiStart = new  Acquisition_Opportunity__c();
        acquiStart.Date_Filter__c = System.today()-30;
        
        acquiEnd = new  Acquisition_Opportunity__c();
        acquiEnd.Date_Filter__c = System.today();

        
        fieldToBeSorted = 'Name';
        orderToBeSorted = 'asc';
        fetchAllPortfolios();
    }
    
    public List<SelectOption> getFieldSelectOptions(){
        List<SelectOption> selToBeReturned = new List<SelectOption>();
        
        selToBeReturned.add(new SelectOption('Name','Acquisition Name'));
        selToBeReturned.add(new SelectOption('StageName__c','Stage'));
        selToBeReturned.add(new SelectOption('Owner.Name','Owner'));        
        selToBeReturned.add(new SelectOption('CreatedDate','Created Date'));
        selToBeReturned.add(new SelectOption('Record_Type_Text__c','Type'));        
        
        
       return selToBeReturned;
    }
    
    public List<SelectOption> getorderSelectOptions(){
       List<SelectOption> selToBeReturned = new List<SelectOption>();
        
       selToBeReturned.add(new SelectOption('asc','Ascending'));
       selToBeReturned.add(new SelectOption('desc','Descending'));
        
       return selToBeReturned;
    }
    
    
    public void fetchAllPortfolios(){
        norecords = true;
        errorMsg = null;
        Map<String, ReportProducts__c> mcs = ReportProducts__c.getAll();

        psID = new Set<id>();
        for(ReportProducts__c rp:mcs.values()){
            psId.add(rp.ProductId__c);
        }
        
        Set<Id> prodFamilyIds = new Set<Id>();
        prodSer = new Map<id,Product_or_Service__c>([select id,Name from Product_or_Service__c where id in:psId]);

        acqMap = new Map<id,List<Acquisition_opportunity__c>>();

        List<portfolio2product__c> p2p = [Select id,Portfolio__c From portfolio2product__c where Product_or_Service__c in :psId And portfolio__c != null and CreatedDate > :portfolioStart.Date_Filter__c and CreatedDate < :portfolioEnd.Date_Filter__c];
        
        for(portfolio2product__c portTemp:p2p){
            prodFamilyIds.add(portTemp.Portfolio__c);
        }
                  
        acqIds = AcquisitionOpportunityUtility.getAcqOppForPatentFamily(prodFamilyIds);
            
        DateTime dt1 = acquiStart.date_filter__c;
        DateTime dt2 = acquiEnd.date_filter__c;
        String query = 'select Id, Name, StageName__c,Record_Type_Text__c,CreatedDate, Probability__c, CloseDate__c,Summary__c, RecordType.Name, Priority__c, Account__c, Account__r.Name, LastModifiedDate,OwnerId,Owner.Name,NextStep__c From Acquisition_Opportunity__c '+
                           ' Where id in :acqIds and CreatedDate > :dt1 and CreatedDate <= :dt2 '+
                           ' order by '+fieldToBeSorted+' '+orderToBeSorted+' limit 2000 ';
        System.debug('### '+query);                           
        result = Database.query(query);                                    
    }
    
    public void filterResults(){
        if(portfolioEnd.Date_Filter__c < portfolioStart.Date_Filter__c || acquiEnd.date_filter__c < acquiStart.date_filter__c){
            errorMsg = 'Start Date can not be after End Date';
            return;
        }
        fetchAllPortfolios();
    }
}