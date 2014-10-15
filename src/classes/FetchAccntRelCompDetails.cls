public class FetchAccntRelCompDetails{

//Declaring Variables
public List<FetchRelCompDetailsWrapper.Response> FetchAccntRelCompDetailsWrapList{get;set;}
public string URL;
public boolean noRec{get;set;}
public string statuscode;
public String currentSortColumn{get;set;}
public boolean isPFAsc{set; get;} 
public boolean isPatAsc{get;set;}
public boolean isRCAsc{get;set;}
private string previousPFSortColumn;  
private string previousPatSortColumn; 
private string previousRCSortColumn;   
private string sortDir;
public string idValue;
public account accnt;
public integer acntLicPageNum{get;set;}
public FetchRelCompDetailsWrapper.pagination alwPageInfo{get;set;}
public FetchRelCompDetailsWrapper alw = new FetchRelCompDetailsWrapper();
public Account accntRec{get;set;}
    //Start of Constructor
    public FetchAccntRelCompDetails(ApexPages.StandardController controller){   
        noRec=false;     
        FetchAccntRelCompDetailsWrapList = new List<FetchRelCompDetailsWrapper.Response>();   
        FetchRelCompDetailsWrapper.pagination alwPageInfo = new  FetchRelCompDetailsWrapper.pagination();    
        accnt = (Account)controller.getRecord();
        acntLicPageNum =1;
        currentSortColumn = 'patent_number';        
        previousPFSortColumn = 'patent_family_name';  
        previousPatSortColumn = 'patent_number';
        previousRCSortColumn = 'relevant_company_name';        
        isPFAsc = true;
        isPatAsc = true;
        isRCAsc = true;
        sortDir='ASC';
    }

    //Start of Action Method    
    public pagereference FetchRelCompDetails(){      
        acntLicPageNum =1;
        Account accntRec =[select id,name,Entity_ID__c from account where id =:accnt.id][0];
        idValue=string.valueof(accntRec.Entity_ID__c);
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
        
        if(currentSortColumn =='relevant_company_name'){
            if(previousRCSortColumn.equals(currentSortColumn)){   
                isRCAsc = !isRCAsc;     
            }else{     
                isRCAsc = true; 
            }     
            sortDir = isRCAsc ? 'ASC' : 'DESC';
            previousRCSortColumn = currentSortColumn;  
        }
                
        refreshData(true,currentSortColumn,sortDir);        
    }
    
    public void refreshData(boolean isSort,string sortColumn,string sortType){
        try{
            FetchAccntRelCompDetailsWrapList = new List<FetchRelCompDetailsWrapper.Response>();
            system.debug('@@ FetchAccntRelCompDetailsWrapList'+FetchAccntRelCompDetailsWrapList);                     
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Relevant Company API').Authorization_Token__c; 
            string EndPoint=API_ENDPOINT_URLS__c.getValues('Relevant Company API').ENDPOINT_URL__c;
            if(!isSort) 
            URL= EndPoint+idValue+'&type=ENTS&page='+acntLicPageNum+'&per_page=10&sort_by='+sortColumn+'&sort_type=ASC';
            else
            URL= EndPoint+idValue+'&type=ENTS&page='+acntLicPageNum+'&per_page=10&sort_by='+sortColumn+'&sort_type='+sortType;                      
                                   
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
            FetchRelCompDetailsWrapper  wrap = new FetchRelCompDetailsWrapper ();           
            wrap = FetchRelCompDetailsWrapper.parse(res.getBody());                                             
            statuscode=string.valueOf(res.getStatusCode()) ; 
            system.debug('@@wrap'+wrap);                        
            
            if(wrap.response!=null){                       
                FetchAccntRelCompDetailsWrapList.addAll(wrap.response); 
                if(FetchAccntRelCompDetailsWrapList.size()==0)
                noRec=true;              
                system.debug('@@FetchAccntRelCompDetailsWrapList'+FetchAccntRelCompDetailsWrapList.size());                 
                alw =  (FetchRelCompDetailsWrapper) System.JSON.deserialize(res.getBody(), FetchRelCompDetailsWrapper.class); 
                alwPageInfo = alw.Pagination;                                                                  
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
        if(alwPageInfo.pages>acntLicPageNum){
            acntLicPageNum=acntLicPageNum+ 1;            
            refreshData(true,currentSortColumn,sortDir);             
        }
    }
    
    public void loadPrevLicensees(){       
        if(acntLicPageNum>1){
            acntLicPageNum=acntLicPageNum - 1;
            refreshData(true,currentSortColumn,sortDir);          
        }        
    }
}