/*****************************************************************************
 * Name             : AccountRelevantOpportunities
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 17 Jan, 2012.
 * Purpose          : Fetch Acquisition opportunity related to Account. 
 *                    T-22105 -  
 *****************************************************************************/
// - There are 5 objects involved with the linking. The purpose of this class is to 
//   find all (candidate) relevant opportunities for the current account.
// - The structure is:  a-a2ps-ps-o2ps-o
//   Account - Account2Product/Service - Product/Services - Portfolio2Product/Service -  Acquisition Opportunity
// - Display is done by the 'relevant opportunity' button on the Account page, 
//   which triggers the AccountRelevantOpportunities visualforce page 
 
public Class AccountRelevantOpportunities {
    //--------------------------------------------------------------------------
    //Local Variables
  //--------------------------------------------------------------------------
  transient List<Acquisition_Opportunity__c> acqOppList;
  private Map<Id,Date> acqOppAndLastStageChngDt = new Map<Id,Date>();  
  private Set<Id> allAcqIds;
  private set<Id> acqIds;
  private set<Id> doNotCareAcqIds;
  
  /*public String myAccountName {set; get;}
  public String accId {set; get;}
  public Acquisition_Opportunity__c filterCriteria{get;set;}
  public Acquisition_Opportunity__c startDateFilter{get;set;}
  public Acquisition_Opportunity__c endDateFilter{get;set;}
  
  public List<SortWrapper> sortFields{get;set;}
  public List<SelectOption> lstAllStages{get;set;}
  public List<SelectOption> lstSelectedStages{get;set;}*/
  
  public String myAccountName {set; get;}
  public String accId {set; get;}
  public Acquisition_Opportunity__c filterCriteria{get;set;}
  public Acquisition_Opportunity__c startDateFilter{get;set;}
  public Acquisition_Opportunity__c endDateFilter{get;set;}
  
  public List<SortWrapper> sortFields{get;set;}
  public List<SelectOption> lstAllStages{get;set;}
  public List<SelectOption> lstSelectedStages{get;set;}
  
  
  
  //--------------------------------------------------------------------------
    //Wrapper Classes
  //--------------------------------------------------------------------------
  public Class AcquisitionOppWrapper {
    public Acquisition_Opportunity__c acqOpp{get;set;}
    public Date lastStageChangedDt{get;set;}
    public Boolean doNotCare{get;set;}
    public AcquisitionOppWrapper(Acquisition_Opportunity__c acqOpp, Date lastStageChangedDt, Boolean donotCare) {
        this.acqOpp = acqOpp;
        this.lastStageChangedDt = lastStageChangedDt;
        this.doNotCare = donotCare;
    }
  }
  
  public Class SortWrapper {
    public String selectedField{get;set;}
    public String selectedOrder{get;set;}
    public List<SelectOption> fieldNames{get;set;}
    public List<SelectOption> lstSortOrder{get;set;}
    
    public SortWrapper(List<SelectOption> fieldNames, List<SelectOption> lstSortOrder) {
      this.fieldNames = fieldNames;
      this.lstSortOrder = lstSortOrder;
    }
  }
  
  //--------------------------------------------------------------------------
  //Private Properties
  //--------------------------------------------------------------------------
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
    
  //--------------------------------------------------------------------------
    //Constructor
  //--------------------------------------------------------------------------
  public AccountRelevantOpportunities() {
    accId = ApexPages.currentPage().getParameters().get('AccountId');
    if(accId == null) {
      return;
    }
    myAccountName = [Select Name From Account Where Id= :accId].Name;   
    init();
    
    if (acqOppList == null || acqOppList.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found)); 
    }
    
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //Initialization
  //---------------------------------------------------------------------------------------------------------------------
  public void init() {
    filterCriteria = new Acquisition_Opportunity__c();
    startDateFilter = new Acquisition_Opportunity__c();
    endDateFilter = new Acquisition_Opportunity__c();
    
    lstSelectedStages = new List<SelectOption>();
    populateStageList(); 
    sortFields = populateSortFields();
    acqOppList = new List<Acquisition_Opportunity__c>();
    Set<Id> productIds = new Set<Id>();
    Set<Id> doNotCareProductIds = new Set<Id>();
    // Iterate through all the Product/Services related to account
    for (account2product__c ap : [Select Account__r.Id, Account__r.Name,Product_or_Service__r.Id,
                                         Product_or_Service__r.Name,Does_Not_Care__c 
                                 From account2product__c 
                                 Where Account__r.Id = :accId limit 200]) {
      if(ap.Does_Not_Care__c) {
        doNotCareProductIds.add(ap.Product_or_Service__r.Id);
      } else {
        productIds.add(ap.Product_or_Service__r.Id);
      }
    }
    
    acqIds = AcquisitionOpportunityUtility.getAcqOppForProducts(productIds);
    doNotCareAcqIds = AcquisitionOpportunityUtility.getAcqOppForProducts(doNotCareProductIds);
    
    allAcqIds = new Set<Id>(); 
    allAcqIds.addAll(acqIds);
    allAcqIds.addAll(doNotCareAcqIds);
    acqOppAndLastStageChngDt = getAcqStageFieldHistory(allAcqIds);
    acqOppList.addAll(fetchAcqRecords(allAcqIds, false));
  }
  
  //---------------------------------------------------------------------------------------------------------------------
    // Clear Search Criteria.
  //---------------------------------------------------------------------------------------------------------------------
  public void reset() {
    filterCriteria.Name = null;
    filterCriteria.Probability__c = null;
    filterCriteria.StageName__c = null;
    filterCriteria.Start_Date__c = null;
    filterCriteria.Expiration_Date__c = null;
    
    startDateFilter.Date_Filter__c = null;
    endDateFilter.Date_Filter__c = null;
    
    sortFields = populateSortFields();
    lstAllStages.addAll(lstSelectedStages);
    lstSelectedStages.clear();
    filterAndSort();
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
  
  //---------------------------------------------------------------------------------------------------------------------
  // Returns AcquisitionOpportunity Stage History Map
  //---------------------------------------------------------------------------------------------------------------------
  private Map<Id,Date> getAcqStageFieldHistory(Set<Id> allAcqIds) {
    Map<Id,Date> acqAndStageDtMap = new Map<Id,Date>();
    for (AggregateResult acqOppHistory : 
      [Select parentId, Max(CreatedDate) lastStageChangeDt 
       From Acquisition_Opportunity__History 
       Where parentId in :allAcqIds
       And Field = 'StageName__c' 
       Group by parentId
       Order by Max(CreatedDate) desc]) { 
                
        if(!acqAndStageDtMap.containsKey((Id)acqOppHistory.get('parentId'))) {
          acqAndStageDtMap.put((Id)acqOppHistory.get('parentId'),Date.valueOf(acqOppHistory.get('lastStageChangeDt')));
        }
    }
    return acqAndStageDtMap;
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  // Returns AcquistionOpportunity Wrapper List for Result block.
  //---------------------------------------------------------------------------------------------------------------------
  public List<AcquisitionOppWrapper> getacqOppList(){
    
    List<AcquisitionOppWrapper> lstWrapper = new List<AcquisitionOppWrapper>();
    List<AcquisitionOppWrapper> lstdoNotCareWrapper = new List<AcquisitionOppWrapper>();
  
    if(acqOppList != null && acqOppList.size()>0){
    system.debug('acqOppList in getacqOppList------'+acqOppList+'size of acqOppList in getacqOppList-----'+acqOppList.size());
    
    for (Acquisition_Opportunity__c acqOpp : acqOppList) {
        //check that only do not care contains acquisition opportunity
        if(doNotCareAcqIds.contains(acqOpp.Id) && (!acqIds.contains(acqOpp.Id))) {
        lstdoNotCareWrapper.add(new AcquisitionOppWrapper(acqOpp,acqOppAndLastStageChngDt.get(acqOpp.Id), true));                 
      } else {
        lstWrapper.add(new AcquisitionOppWrapper(acqOpp,acqOppAndLastStageChngDt.get(acqOpp.Id), false));
      }
    }
    lstWrapper.addAll(lstdoNotCareWrapper);
    }
    return lstWrapper;
  }
  
  
  //---------------------------------------------------------------------------------------------------------------------
  // Returns sorted filter results.
  //---------------------------------------------------------------------------------------------------------------------
  public void filterAndSort(){
    
    
   // acqOppList.clear();
     acqOppList = new List<Acquisition_Opportunity__c>(); 
     acqOppList.addAll(fetchAcqRecords(allAcqIds, false));
    
    system.debug('acqOppList in filterSort------'+acqOppList+'size of acqOppList-----'+acqOppList.size());
    if (acqOppList == null || acqOppList.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.INFO, Label.No_Record_Found_For_Given_Criteria)); 
    }
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //Returns list of sortWrapper Class
  //---------------------------------------------------------------------------------------------------------------------
  private List<SortWrapper> populateSortFields() {
    List<SortWrapper> sortFields = new List<SortWrapper>();
    sortFields.add(new SortWrapper(getFields(), getSortOrder()));    
    sortFields.add(new SortWrapper(getFields(), getSortOrder()));
    sortFields.add(new SortWrapper(getFields(), getSortOrder()));
    sortFields.add(new SortWrapper(getFields(), getSortOrder()));
    return sortFields;
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //returns Select option list of fields available for sorting. 
  //---------------------------------------------------------------------------------------------------------------------
  private List<SelectOption> getFields() {
    List<SelectOption> lstSortOrders = new List<SelectOption>();
    lstSortOrders.add(new SelectOption('','-None-'));
    lstSortOrders.add(new SelectOption('Name','Acquisition Opportunity Name'));
    lstSortOrders.add(new SelectOption('StageName__c','Stage'));
    lstSortOrders.add(new SelectOption('RecordType.Name','Acquisition Type'));
    lstSortOrders.add(new SelectOption('CreatedDate','Created Date'));
    return lstSortOrders;
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //return select option list for sort order.
  //---------------------------------------------------------------------------------------------------------------------
  private List<SelectOption> getSortOrder() {
    List<SelectOption> lstSortOrders = new List<SelectOption>(); 
    lstSortOrders.add(new SelectOption('','None'));
    lstSortOrders.add(new SelectOption('ASC','ASC'));
    lstSortOrders.add(new SelectOption('DESC','DESC')); 
    return lstSortOrders;
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //Fetch Acquisition Opportunity recoreds as per given Filter Criteria 
  //and Acq Opp RecordIds.
  //---------------------------------------------------------------------------------------------------------------------
  private List<Acquisition_Opportunity__c> fetchAcqRecords(Set<Id> acqIds, Boolean isSortOnly) {
    List<Acquisition_Opportunity__c> acqOpps = new List<Acquisition_Opportunity__c>();
    String query;
    query = ' Select Id, Name, StageName__c,CreatedDate, Probability__c, CloseDate__c, ' 
          + ' Summary__c, RecordType.Name'
          + ' From Acquisition_Opportunity__c'
          + ' Where id in :acqIds ';
    
    if(!isSortOnly) {      
        String filterString = getFilterConditions().trim(); 
        if (filterString != '') {
          query += ' and ' +  filterString;
        }
    }
    
    String orderBy = getSortOrderString();
    if(orderBy != '') {
      query += ' order by ' + orderBy + ' NULLS LAST';
    } else {
      query += ' order by RecordType.Name, Name ';  
    }
    query += ' limit 200 ';
    acqOpps = Database.query(query);
    
    system.debug('acqOpps in fetchAcqRecords------'+acqOpps);
    return acqOpps;
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //Returns sort order
  //---------------------------------------------------------------------------------------------------------------------
  private String getSortOrderString() {
    String orderBy = '';
    if(sortFields == null) {
      return '';
    }
    for (SortWrapper sOrder : sortFields) {
      if (sOrder.selectedField != null && sOrder.selectedField.trim() != ''
        && sOrder.selectedOrder != null && sOrder.selectedOrder.trim() != ''
      ) {
        if(orderBy.trim() != '') {
          orderBy += ', ';
        }
        orderBy += sOrder.selectedField + ' ' + sOrder.selectedOrder;
      }
    }
    return orderBy;
    
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //Return Filter String based on Filter Criteria.
  //---------------------------------------------------------------------------------------------------------------------
  private String getFilterConditions() {
    String filterString = '';
    
    if(filterCriteria.Name != null && filterCriteria.Name.trim() != '') {
      filterString += 'Name Like \'%' + filterCriteria.Name + '%\'';
    }
    if(lstSelectedStages.size() > 0) {
        if(filterString != '') {
        filterString += ' and ';
      }
      filterString += ' StageName__c in :selectedStages ';
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
  
}