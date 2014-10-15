/*****************************************************************************
 * Name             : AccountRelevantOpportunitiesNew
 * Created By       : Vamsi Chinnam
 * Created Date     : 31 July, 2014.
 * Purpose          : Fetch Acquisition opportunity related to Account.                     
 *****************************************************************************/

public Class AccountRelevantOpportunitiesNew {
    //--------------------------------------------------------------------------
    //Local Variables
  //--------------------------------------------------------------------------
   
  
  public String myAccountName {set; get;}
  public String accId {set; get;}
  public Acquisition_Opportunity__c filterCriteria{get;set;}
  public Acquisition_Opportunity__c startDateFilter{get;set;}
  public Acquisition_Opportunity__c endDateFilter{get;set;}
  
  public List<SortWrapper> sortFields{get;set;}
  public List<SelectOption> lstAllStages{get;set;}
  public List<SelectOption> lstSelectedStages{get;set;}
  
  public List<TechTagMatchedAcqWrapper.response> TechTagMatchedAcqWrapList {get; set;}
  public string URL;
  public string idValue;  
  public boolean noRec{get;set;}
  public string statuscode;
  public TechTagMatchedAcqWrapper alw = new TechTagMatchedAcqWrapper();
  
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
    //Constructor
  //--------------------------------------------------------------------------
  public AccountRelevantOpportunitiesNew() {    
    accId = ApexPages.currentPage().getParameters().get('AccountId');
    if(accId == null) {
      return;
    }
    myAccountName = [Select Name From Account Where Id= :accId].Name;   
    init();     
    
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //Initialization
  //---------------------------------------------------------------------------------------------------------------------
  public void init() {
    noRec = false;
    filterCriteria = new Acquisition_Opportunity__c();
    startDateFilter = new Acquisition_Opportunity__c();
    endDateFilter = new Acquisition_Opportunity__c();
    
    lstSelectedStages = new List<SelectOption>();
    populateStageList(); 
    sortFields = populateSortFields();    
    Set<Id> techTagIds = new Set<Id>();    
    // Iterate through all the Product/Services related to account
    for (account2product__c ap : [Select Account__r.Id, Account__r.Name,Product_or_Service__r.Id,
                                         Product_or_Service__r.Name,Does_Not_Care__c 
                                 From account2product__c 
                                 Where Account__r.Id = :accId limit 200]) {
        if(ap.Product_or_Service__r.id!=null)
        techTagIds.add(ap.Product_or_Service__r.id);      
    }   
    if(techTagIds.size()>0){
    for(id tecId:techTagIds){
        if(idValue!=null)
            idValue=idValue+','+String.valueOf(tecId);
        else
            idValue=String.valueOf(tecId);
    }
    //To Not Exceed the URL Limit of 4096 Characters
    if(idValue.length()>3888){
        idValue = idValue.subString(0,3887);
    }
    else{
        idValue= idValue;
    }    
     }
    filterAndSort();
   
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
  // Returns sorted filter results.
  //---------------------------------------------------------------------------------------------------------------------
  public void filterAndSort(){
    
    try{
            TechTagMatchedAcqWrapList = new List<TechTagMatchedAcqWrapper.Response>();
            system.debug('@@ TechTagMatchedAcqWrapList'+TechTagMatchedAcqWrapList); 
            
            string nameFilter;
            string startFilter;
            string endFilter;
            string stageFilter;
            String selectedStageFilter;
            string sortFilter;
            string sortOrderFilter;
            if(filterCriteria.Name != null && filterCriteria.Name.trim() != '') {
                nameFilter = filterCriteria.Name; 
            }
            string a='stage_filter[]';
            if(lstSelectedStages.size()>0){              
                for(Selectoption opt : lstSelectedStages) {
                string ab=string.valueOf(opt.getValue());
                system.debug('@@'+ab);
               string encodedOpt= EncodingUtil.urlEncode(ab, 'UTF-8');
                system.debug('@@'+encodedOpt);
               
                  if(stageFilter!=null)
                    stageFilter = stageFilter+'&'+a+'='+encodedOpt;
                  else
                    stageFilter = a+'='+encodedOpt;
                }                               
            }
            
            if(startDateFilter.Date_Filter__c != null) {    
                dateTime startDate =(dateTime)startDateFilter.Date_Filter__c;               
                startFilter =startDate.formatGMT('dd-MM-YYYY');
                //startFilter = TEXT(startDateFilter.Date_Filter__c.day())+'-' +TEXT(MONTH(startDateFilter.Date_Filter__c))+'-' +TEXT(YEAR(startDateFilter.Date_Filter__c));                 
                //startFilter = startDateFilter.Date_Filter__c.format('DD-MM-YYYY');
                //startFilter='2009-02-23';
            }
            
            if(endDateFilter.Date_Filter__c != null) {
                if(endDateFilter.Date_Filter__c!=null && startDateFilter.Date_Filter__c==null){
                    endDateFilter.Date_Filter__c = endDateFilter.Date_Filter__c+1;
                }
                dateTime endDate =(dateTime)endDateFilter.Date_Filter__c;               
                endFilter =endDate.formatGMT('dd-MM-YYYY');                
                //endFilter = TEXT(DAY(endDateFilter.Date_Filter__c))+'-' +TEXT(MONTH(endDateFilter.Date_Filter__c))+'-' +TEXT(YEAR(endDateFilter.Date_Filter__c));
                //endFilter = endDateFilter.Date_Filter__c.format('DD-MM-YYYY');
                //endFilter='2011-08-29';
            }
            nameFilter =nameFilter!=null?'&acquisition_name_filter='+EncodingUtil.urlEncode(nameFilter, 'UTF-8'):'';
            stageFilter =stageFilter!=null?stageFilter:'';
            startFilter =startFilter!=null?'&date_filter_start='+startFilter:'';
            endFilter = endFilter!=null?'&date_filter_end='+endFilter:'';
            if(sortFields.size()>0){
                for (SortWrapper sOrder : sortFields) {
                    sortFilter = sOrder.selectedField;
                    sortOrderFilter=sOrder.selectedOrder;
                }
            }
            if(sortFilter==null){
                system.debug('@@sortFilter if Test Check'+sortFilter);
            }
            sortFilter = sortFilter!=null?+sortFilter:'acquisition_type';
            sortOrderFilter=sortOrderFilter!=null?+sortOrderFilter:'ASC';
            system.debug('@@nameFilter'+nameFilter);
            system.debug('@@startDateFilter'+startDateFilter);
            system.debug('@@endDateFilter'+endDateFilter);
            system.debug('@@stageFilter'+stageFilter);
            system.debug('@@sortFilter'+sortFilter);
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('TechTag Details API').Authorization_Token__c;
            string EndPoint=API_ENDPOINT_URLS__c.getValues('TechTag Details API').ENDPOINT_URL__c;
            if(nameFilter==null && startFilter==null && endFilter==null && stageFilter==null & sortFilter==null)
            URL= EndPoint+idValue+'&page=1&per_page=100&type=OPRS&sort_by=acquisition_type&sort_type=ASC';
            
            else{           
            URL= EndPoint+idValue+'&page=1&per_page=100&type=OPRS'+nameFilter+endFilter+startFilter+'&'+stageFilter+'&sort_by='+sortFilter+'&sort_type='+sortOrderFilter;
            //URL= Label.TechTagDetails_EndPoint+idValue+'&page=1&per_page=100&type=OPRS&date_filter_end='+endFilter+'&date_filter_start='+startFilter+'&sort_by=stage&sort_type=ASC';
            }                       
            
            system.debug('@@URL'+URL);          
            // Instantiate a new http object
            Http h = new Http();
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL);
           //req.setEndpoint('{!JSINHTMLENCODE(URL)}');
           // String encodedURL = EncodingUtil.urlEncode(URL, 'UTF-8');
            //req.setEndpoint(encodedURL);
            req.setMethod('GET');
            req.setHeader('Authorization', AuthorizationToken);
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug('@@ response'+res);
            
            //Parsing the Response
            TechTagMatchedAcqWrapper  wrap = new TechTagMatchedAcqWrapper ();         
            wrap = TechTagMatchedAcqWrapper.parse(res.getBody());  
            statuscode=string.valueOf(res.getStatusCode()) ;                                           
            system.debug('@@wrap'+wrap);    
            
            if(wrap.response!=null){                       
                TechTagMatchedAcqWrapList.addAll(wrap.response); 
                //Added for Date Format
                for(TechTagMatchedAcqWrapper.response resp:TechTagMatchedAcqWrapList){
                     if(resp.created_date!=null)
                    resp.createddateValFormat= dateTime.valueOfGMT(resp.created_date).format();
                    if(resp.last_stage_change!=null)
                    resp.stageddateValFormat= date.valueOf(resp.last_stage_change);
                }
                
               system.debug('@@TechTagMatchedAcqWrapList123'+TechTagMatchedAcqWrapList); 
                if(TechTagMatchedAcqWrapList.size()==0){
                    noRec=true;              
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found)); 
                }
                system.debug('@@TechTagMatchedAcqWrapList'+TechTagMatchedAcqWrapList.size());              
                alw =  (TechTagMatchedAcqWrapper) System.JSON.deserialize(res.getBody(), TechTagMatchedAcqWrapper.class); 
                //alwPageInfo = alw.Pagination;                                                                   
            }      
        }
        catch(System.CalloutException e){
            System.debug('@@in Callout Exception '+e.getMessage());
            String error = 'Error Occured.Please try after sometime';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
        }
        catch(exception e){
            System.debug('@@in final Exception '+e.getMessage());
            if(statuscode!=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'(Error Code-'+statuscode+')'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message)); 
        }
    }            
  
  //---------------------------------------------------------------------------------------------------------------------
  //Returns list of sortWrapper Class
  //---------------------------------------------------------------------------------------------------------------------
  private List<SortWrapper> populateSortFields() {
    List<SortWrapper> sortFields = new List<SortWrapper>();
    sortFields.add(new SortWrapper(getFields(), getSortOrder()));        
    return sortFields;
  }
  
  //---------------------------------------------------------------------------------------------------------------------
  //returns Select option list of fields available for sorting. 
  //---------------------------------------------------------------------------------------------------------------------
  private List<SelectOption> getFields() {
    List<SelectOption> lstSortOrders = new List<SelectOption>();
    lstSortOrders.add(new SelectOption('','-None-'));
    lstSortOrders.add(new SelectOption('acquisition_name','Acquisition Opportunity Name'));
    lstSortOrders.add(new SelectOption('stage','Stage'));
    lstSortOrders.add(new SelectOption('acquisition_type','Acquisition Type'));
    lstSortOrders.add(new SelectOption('created_date','Created Date'));
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
     
}