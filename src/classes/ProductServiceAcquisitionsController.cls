public class ProductServiceAcquisitionsController{
    
    public Id psId{get;set;}
    public List<Acquisition_Opportunity__c> acquisitionList{get;set;}
    public List<Acquisition_Opportunity__c> allAcqList{get;set;}
    public integer totalRecords{get;set;}
    public String noOfRecords{get;set;}
    
    public Acquisition_Opportunity__c filterCriteria{get;set;}
    public Acquisition_Opportunity__c startDateFilter{get;set;}
    public Acquisition_Opportunity__c endDateFilter{get;set;}
    
    public List<SelectOption> lstAllStages{get;set;}
    public List<SelectOption> lstSelectedStages{get;set;}
    public List<SelectOption> lstMarketSectors{get;set;}
    public List<SelectOption> lstSelectedMarketSectors{get;set;}
    public List<SelectOption> lstSelectedPS{get;set;}
    public List<SelectOption> lstNoOfRecords{get;set;}
    
    public List<PSWrapper> psWrappers{get;set;}
    private List<Id> exportedPS{get;set;}
    
    public String psFilter{get;set;}
    public String sortExpression{get;set;}
    
    public boolean isSelectAll{get;set;}
    
    
    private Date startDate{
        get{
          if(startDateFilter != null && startDateFilter.Date_Filter__c != null) {
            return startDateFilter.Date_Filter__c;
          } else {
            return null;
          }
        }
    }
    
    private Date endDate {
        get{
          if(endDateFilter != null && endDateFilter.Date_Filter__c != null) {
            return endDateFilter.Date_Filter__c;
          } else {
            return null;
          }
        }
    }
    
    private Set<String> selectedStages {
        get {
          Set<String> stages = new Set<String>();
          if (lstSelectedStages.size() > 0) {
            for(Selectoption opt : lstSelectedStages) {
              stages.add(opt.getValue());
            }
          }
          return stages;
        } 
    }
    
    private Set<String> selectedMarketSectors {
        get {
          Set<String> sectors = new Set<String>();
          if (lstSelectedMarketSectors.size() > 0) {
            for(Selectoption opt : lstSelectedMarketSectors) {
              sectors.add(opt.getValue());
            }
          }
          return sectors;
        } 
    }
    
    private Set<String> selectedPS {
        get {
          Set<String> ps = new Set<String>();
          if (lstSelectedPS.size() > 0) {
            for(Selectoption opt : lstSelectedPS) {
              ps.add(opt.getValue());
            }
          }
          return ps;
        } 
    }
    
    //--------------------------------------------------------------------------
    //Constructor
    //--------------------------------------------------------------------------
    public ProductServiceAcquisitionsController(){
        init();
    }
    
    public void init() {
        
        totalRecords = 0;
        acquisitionList = new List<Acquisition_Opportunity__c>();
        allAcqList = new List<Acquisition_Opportunity__c>();
        psFilter = '';
        sortExpression = 'ASC';
        isSelectAll = false;
        
        filterCriteria = new Acquisition_Opportunity__c();
        startDateFilter = new Acquisition_Opportunity__c();
        endDateFilter = new Acquisition_Opportunity__c();
        
        lstSelectedStages = new List<SelectOption>();
        lstSelectedMarketSectors = new List<SelectOption>();
        lstSelectedPS = new List<SelectOption>();
        
        lstNoOfRecords = new List<SelectOption>();
        lstNoOfRecords.add(new SelectOption('50000','All records'));
        lstNoOfRecords.add(new SelectOption('10','10 records'));
        lstNoOfRecords.add(new SelectOption('20','20 records'));
        lstNoOfRecords.add(new SelectOption('50','50 records'));
        
        noOfRecords = '5000';
        
        populateStageList();
        populateMarketSectorList();
        initPSList();
    }
    
    public void initPSList(){
        psWrappers = new List<PSWrapper>();
        String query = 'Select Name from Product_or_Service__c ';
        if(psFilter!=''){
            query += ' where Name like \'%' + psFilter + '%\' ';
            isSelectAll = true;
        }else{
            isSelectAll = false;
        }
        query += 'order by Name ' + sortExpression;
        List<Product_or_Service__c> psList = Database.query(query);
        for(Product_or_Service__c ps : psList){
            psWrappers.add(new PSWrapper(ps));
        }
    }
    
    public PageReference filterPS(){
        initPSList();
        return null;
    }
    
    public PageReference sortProduct(){
        if(sortExpression=='ASC'){
           sortExpression = 'DESC'; 
        }else{
           sortExpression = 'ASC';
        }
        
        List<PSWrapper> temps = new List<PSWrapper>();
        for(integer i =psWrappers.size()-1; i>=0; i--){
            temps.add(psWrappers.get(i));
        }
        psWrappers = temps;
        return null;
    }
    
    public PageReference reset(){
        init();
        return null;
    }
    
    //---------------------------------------------------------------------------------------------------------------------
    //PopulateStageName List
    //---------------------------------------------------------------------------------------------------------------------
    private void populateStageList() {
        lstAllStages = new List<SelectOption>();
        Schema.DescribeFieldResult optionFieldDescription = Acquisition_Opportunity__c.StageName__c.getDescribe();
        for(Schema.PicklistEntry pleOptions : optionFieldDescription.getPicklistValues()){
            lstAllStages.add(new SelectOption(pleOptions.getvalue(),pleOptions.getLabel()));
        }
    }
    
    private void populateMarketSectorList() {
        lstMarketSectors = new List<SelectOption>();
        Schema.DescribeFieldResult optionFieldDescription = Acquisition_Opportunity__c.Primary_Market_Sector__c.getDescribe();
        for(Schema.PicklistEntry pleOptions : optionFieldDescription.getPicklistValues()){
            lstMarketSectors.add(new SelectOption(pleOptions.getvalue(),pleOptions.getLabel()));
        }
    }
    
    public List<SelectOption> getProducts(){
        List<SelectOption> options = new List<SelectOption>();
        List<Product_or_Service__c> products = [Select Id, Name from Product_or_Service__c];
        for(Product_or_Service__c p : products){
            options.add(new SelectOption(p.Name,p.Name));
        }
        return options;
    }
    
    public PageReference searchProduct(){
        
        Set<Id> selectedPSId = new Set<Id>();
        exportedPS = new List<Id>();
        
        for(PSWrapper w : psWrappers){
            if(w.include==true){
                selectedPSId.add(w.ps.Id);
                exportedPS.add(w.ps.Id);
            }
        }
        
        Set<Id> acqIds = AcquisitionOpportunityUtility.getAcqOppForProducts(selectedPSId);
        
        String query = ' Select Id, Name, StageName__c,CreatedDate, Probability__c, CloseDate__c, Last_Significant_Update_by_Acq__c ,' 
          + ' Summary__c, RecordType.Name, Account__c, Primary_Market_Sector__c, Seller_claims_charts__c, Theories_of_Relevance__c,Patent_Portfolio_Summary__c'
          + ' From Acquisition_Opportunity__c'
          + ' Where id in :acqIds';
        String filterString = getFilterConditions().trim(); 
        if (filterString != '') {
          query += ' and ' +  filterString;
        }
        //query += ' LIMIT ' + noOfRecords;
        allAcqList = Database.query(query);
        if (allAcqList == null || allAcqList.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found)); 
        }
        totalRecords = allAcqList.size();
        acquisitionList = new List<Acquisition_Opportunity__c>();
        for(Integer i=0; (i< Integer.valueOf(noOfRecords) && i < allAcqList.size()); i++){
            acquisitionList.add(allAcqList.get(i));
        }
       
        return null;
    }
        
    public PageReference exportExcel(){
        PageReference page = new PageReference('/apex/AcquisitionsCheatSheet');
        String acqId = '';
        for(Acquisition_Opportunity__c acq : allAcqList){
            if(acqId.equals('')){
                acqId = String.valueOf(acq.Id);
            }else{
                acqId += ';' + String.valueOf(acq.Id);
            }
        }
        page.getParameters().put('id',acqId);
        
        String psId='';
        for(Id  ps : exportedPS){
            if(psId.equals('')){
                psId = String.valueOf(ps);
            }else{
                psId += ';' + String.valueOf(ps);
            }
        }
        page.getParameters().put('psId',psId);
        page.getParameters().put('filter',psFilter);
        return page;
    }
    
  //---------------------------------------------------------------------------------------------------------------------
  //Return Filter String based on Filter Criteria.
  //---------------------------------------------------------------------------------------------------------------------
  private String getFilterConditions() {
    String filterString = '';
    
    if(filterCriteria.Name != null && filterCriteria.Name.trim() != '') {
      filterString += 'Name Like \'%' + filterCriteria.Name + '%\'';
    }
      
    if(filterCriteria.Seller_claims_charts__c != null) {
        if(filterString != '') {
            filterString += ' and ';
        }
        filterString += 'Seller_claims_charts__c =' + filterCriteria.Seller_claims_charts__c;
    }
      
    if(lstSelectedStages.size() > 0) {
        if(filterString != '') {
            filterString += ' and ';
        }
        filterString += ' StageName__c in :selectedStages ';
    }
    
    if(selectedMarketSectors.size() > 0) {
        if(filterString != '') {
        filterString += ' and ';
      }
      filterString += ' Primary_Market_Sector__c in :selectedMarketSectors ';
    }
    
    if(startDateFilter.Date_Filter__c != null) {
        if(filterString != '') {
        filterString += ' and ';
      }
        filterString += ' CreatedDate >= :startDate ';
      }
      
      if(endDateFilter.Date_Filter__c != null) {
        if(filterString != '') {
        filterString += ' and ';
      }
        filterString += ' CreatedDate <= :endDate ';
      }
      
    return filterString;
  }
    
    public class PSWrapper{
        public Product_or_Service__c ps{get;set;}
        public boolean include{get;set;}
        
        public PSWrapper(Product_or_Service__c ps){
            this.ps = ps;
            this.include = false;
        }
    }
    
}