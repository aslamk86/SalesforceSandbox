public class FetchAcqCCCompDetails{

//Declaring Variables
public List<FetchCCCompDetailsWrapper.response> FetchAcqCCCompDetailsWrapList {get; set;}
public string URL;
public boolean noRec{get;set;}
public string statuscode;
public String currentSortColumn{get;set;}
public boolean isPFAsc{set; get;} 
public boolean isPatAsc{get;set;}
public boolean isCCAsc{get;set;}
private string previousPFSortColumn;  
private string previousPatSortColumn; 
private string previousCCSortColumn;   
private string sortDir;
public string idValue;
public id acqId;
public integer acqLicPageNum{get;set;}
public FetchCCCompDetailsWrapper.pagination acqlwPageInfo{get;set;}
public FetchCCCompDetailsWrapper acqlw = new FetchCCCompDetailsWrapper();
public Acquisition_opportunity__c acqRec{get;set;}
public Acquisition_Opportunity__c acqOppLit{get;set;}
public set<decimal> oppLitSet = new set<decimal>();
    //Start of Constructor
    public FetchAcqCCCompDetails(ApexPages.StandardController controller){      
        noRec = false;  
        FetchAcqCCCompDetailsWrapList = new List<FetchCCCompDetailsWrapper.Response>();        
        acqId = controller.getId();
        idValue=string.valueof(acqId);
        acqLicPageNum=1; 
        currentSortColumn = 'patent_number';        
        previousPFSortColumn = 'patent_family_name';  
        previousPatSortColumn = 'patent_number';
        previousCCSortColumn = 'company_name';        
        isPFAsc = true;
        isPatAsc = true;
        isCCAsc = true;   
        sortDir='ASC';  
    }

    //Start of Action Method     
    public pagereference FetchCCCompDetails(){     
        acqLicPageNum=1; 
        acqlwPageInfo= new FetchCCCompDetailsWrapper.pagination();        
        
        if(idValue != null)
        refreshData(false,currentSortColumn,null);        
        return null;
    }
    
    //Method to make sorting API call
    public void sortData(){
        if(currentSortColumn =='patent_family_name'){
            if(previousPFSortColumn.equals(currentSortColumn)){   
                isPFAsc = !isPFAsc;     
            }else{     
                isPFAsc = true; 
            }     
            sortDir = isPFAsc ? 'ASC' : 'DESC';
            previousPFSortColumn = currentSortColumn;
        }           
        
        if(currentSortColumn =='patent_number'){
            if(previousPatSortColumn.equals(currentSortColumn)){   
                isPatAsc = !isPatAsc;     
            }else{     
                isPatAsc = true; 
            }     
            sortDir = isPatAsc ? 'ASC' : 'DESC';
            previousPatSortColumn = currentSortColumn;  
        }
        
        if(currentSortColumn =='company_name'){
            if(previousCCSortColumn.equals(currentSortColumn)){   
                isCCAsc = !isCCAsc;     
            }else{     
                isCCAsc = true; 
            }     
            sortDir = isCCAsc ? 'ASC' : 'DESC';
            previousCCSortColumn = currentSortColumn;  
        }
                
        refreshData(true,currentSortColumn,sortDir);        
    }
    
    public void refreshData(boolean isSort,string sortColumn,string sortType){
        try{
            FetchAcqCCCompDetailsWrapList = new List<FetchCCCompDetailsWrapper.Response>();
            system.debug('@@ FetchAcqCCCompDetailsWrapList'+FetchAcqCCCompDetailsWrapList);
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Claim Charted Comp API').Authorization_Token__c; 
            string EndPoint=API_ENDPOINT_URLS__c.getValues('Claim Charted Comp API').ENDPOINT_URL__c;                                                              
            if(!isSort) 
            URL= EndPoint+idValue+'&type=OPRS&page='+acqLicPageNum+'&per_page=10&sort_by='+sortColumn+'&sort_type=ASC';
            else
            URL= EndPoint+idValue+'&type=OPRS&page='+acqLicPageNum+'&per_page=10&sort_by='+sortColumn+'&sort_type='+sortType;                      
            system.debug('@@URL'+URL);
            
                                  
            // Instantiate a new http object
            Http h = new Http();
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL);
            req.setMethod('GET');
            req.setHeader('Authorization',AuthorizationToken);
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug('@@ response'+res);
            
            //Parsing the Response
            FetchCCCompDetailsWrapper wrap = new FetchCCCompDetailsWrapper();           
            wrap = FetchCCCompDetailsWrapper.parse(res.getBody());   
            statuscode=string.valueOf(res.getStatusCode()) ;                                                                         
            system.debug('@@wrap'+wrap);    
            
            if(wrap.response!=null){        
                FetchAcqCCCompDetailsWrapList.addAll(wrap.response); 
                if(FetchAcqCCCompDetailsWrapList.size()==0)
                noRec = true;                           
                system.debug('@@FetchAcqCCCompDetailsWrapList'+FetchAcqCCCompDetailsWrapList.size());              
                acqlw =  (FetchCCCompDetailsWrapper) System.JSON.deserialize(res.getBody(), FetchCCCompDetailsWrapper.class); 
                acqlwPageInfo = acqlw.Pagination;                                                                       
            }
        }
        catch(System.CalloutException e){
            System.debug('@@in Callout Exception '+e.getMessage());            
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
     public void loadMoreLicensees(){            
      if(acqlwPageInfo.pages>acqLicPageNum){
            acqLicPageNum=acqLicPageNum+ 1;
            refreshData(true,currentSortColumn,sortDir);          
      }
    }
    
     public void loadPrevLicensees(){       
      if(acqLicPageNum>1){
            acqLicPageNum=acqLicPageNum - 1;
            refreshData(true,currentSortColumn,sortDir);
      } 
       
    }
    
}