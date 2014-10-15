public class FetchAccntCCCompDetails{

//Declaring Variables
public List<FetchCCCompDetailsWrapper.Response> FetchAccntCCCompDetailsWrapList{get;set;}
public string URL;
public boolean noRec{get;set;}
public string statuscode;
public string idValue;
public String currentSortColumn{get;set;}
public boolean isPFAsc{set; get;} 
public boolean isPatAsc{get;set;}
public boolean isCCAsc{get;set;}
private string previousPFSortColumn;  
private string previousPatSortColumn; 
private string previousCCSortColumn;   
private string sortDir;
public id accntId;
public integer acntLicPageNum{get;set;}
public FetchCCCompDetailsWrapper.pagination alwPageInfo{get;set;}
public FetchCCCompDetailsWrapper alw = new FetchCCCompDetailsWrapper();
public Account accntRec{get;set;}
    //Start of Constructor
    public FetchAccntCCCompDetails(ApexPages.StandardController controller){   
        noRec=false;     
        FetchAccntCCCompDetailsWrapList = new List<FetchCCCompDetailsWrapper.Response>();   
        FetchCCCompDetailsWrapper.pagination alwPageInfo = new  FetchCCCompDetailsWrapper.pagination();    
        accntId = controller.getId();
        acntLicPageNum =1;
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
        acntLicPageNum =1;
        Account accntRec =[select id,name,Entity_ID__c from account where id =:accntId][0];
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
            FetchAccntCCCompDetailsWrapList = new List<FetchCCCompDetailsWrapper.Response>();
            system.debug('@@ FetchAccntCCCompDetailsWrapList'+FetchAccntCCCompDetailsWrapList);  
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Claim Charted Comp API').Authorization_Token__c;
            string EndPoint=API_ENDPOINT_URLS__c.getValues('Claim Charted Comp API').ENDPOINT_URL__c;           
            if(!isSort) 
            URL= EndPoint+idValue+'&type=ENTS&page='+acntLicPageNum+'&per_page=10&sort_by='+sortColumn+'&sort_type=ASC';
            else
            URL= EndPoint+idValue+'&type=ENTS&page='+acntLicPageNum+'&per_page=10&sort_by='+sortColumn+'&sort_type='+sortType;          
            system.debug('@@URL'+URL);                       
            // Instantiate a new http object
            Http h = new Http();
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL);
            req.setMethod('GET');
            req.setHeader('Authorization', AuthorizationToken);
            
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug('@@ response'+res);
            
            //Parsing the Response
            FetchCCCompDetailsWrapper  wrap = new FetchCCCompDetailsWrapper ();         
            wrap = FetchCCCompDetailsWrapper.parse(res.getBody());                                             
            statuscode=string.valueOf(res.getStatusCode()) ;    
            system.debug('@@wrap'+wrap);    
            
            if(wrap.response!=null){                       
                FetchAccntCCCompDetailsWrapList.addAll(wrap.response); 
                if(FetchAccntCCCompDetailsWrapList.size()==0)
                noRec=true;              
                system.debug('@@FetchAccntCCCompDetailsWrapList'+FetchAccntCCCompDetailsWrapList.size());              
                alw =  (FetchCCCompDetailsWrapper) System.JSON.deserialize(res.getBody(), FetchCCCompDetailsWrapper.class); 
                alwPageInfo = alw.Pagination;                                                                   
            }      
        }
        catch(System.CalloutException e){
            System.debug('@@in Callout Exception '+e.getMessage());            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
        }
        catch(exception e){
            System.debug('@@in final Exception '+e.getMessage());
            String error = e.getMessage();
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