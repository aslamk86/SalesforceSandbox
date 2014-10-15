public class FetchAccntLicenseeDetails{

//Declaring Variables
public List<FetchLicenseeDetailsWrapper.response> FetchLicenseeDetailsWrapList {get; set;}
public string URL;
public string TypeOfObj{get;set;}
public boolean noRec{get;set;}
public string statuscode;
public String currentSortColumn{get;set;}
public boolean isPFAsc{set; get;} 
public boolean isPatAsc{get;set;}
public boolean isEDAsc{get;set;}
private string previousPFSortColumn;  
private string previousPatSortColumn; 
private string previousEDSortColumn;   
private string sortDir; 
public string idValue;
public account accnt;
public integer acntLicPageNum{get;set;}
public FetchLicenseeDetailsWrapper.pagination alwPageInfo{get;set;}
public FetchLicenseeDetailsWrapper alw = new FetchLicenseeDetailsWrapper();
public Account accntRec{get;set;}
    //Start of Constructor
    public FetchAccntLicenseeDetails(ApexPages.StandardController controller){   
        noRec=false;     
        FetchLicenseeDetailsWrapList = new List<FetchLicenseeDetailsWrapper.Response>();   
        FetchLicenseeDetailsWrapper.pagination alwPageInfo = new  FetchLicenseeDetailsWrapper.pagination();    
        accnt = (Account)controller.getRecord();
        acntLicPageNum =1;    
        currentSortColumn = 'patent_number';        
        previousPFSortColumn = 'patent_family_name';  
        previousPatSortColumn = 'patent_number';
        previousEDSortColumn = 'expiry_date';        
        isPFAsc = true;
        isPatAsc = true;
        isEDAsc = true;    
        sortDir='ASC';    
    }

    //Start of Action Method
    public pagereference FetchLicenseeDetails(){      
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
        
        if(currentSortColumn =='expiry_date'){
            if(previousEDSortColumn.equals(currentSortColumn)){   
                isEDAsc = !isEDAsc;     
            }else{     
                isEDAsc = true; 
            }     
            sortDir = isEDAsc ? 'ASC' : 'DESC';
            previousEDSortColumn = currentSortColumn;  
        }
                
        refreshData(true,currentSortColumn,sortDir);        
    }
    
   
    public void refreshData(boolean isSort,string sortColumn,string sortType){
        try{
            FetchLicenseeDetailsWrapList = new List<FetchLicenseeDetailsWrapper.Response>();
            system.debug('@@ FetchLicenseeDetailsWrapList'+FetchLicenseeDetailsWrapList);
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Licensee API').Authorization_Token__c; 
            string EndPoint=API_ENDPOINT_URLS__c.getValues('Licensee API').ENDPOINT_URL__c;  
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
            FetchLicenseeDetailsWrapper  wrap = new FetchLicenseeDetailsWrapper ();        
            wrap = FetchLicenseeDetailsWrapper.parse(res.getBody());                                             
            statuscode=string.valueOf(res.getStatusCode()) ;  
                                   
            if(wrap.response!=null){                   
                FetchLicenseeDetailsWrapList.addAll(wrap.response); 
                if(FetchLicenseeDetailsWrapList.size()==0)
                noRec=true;              
                system.debug('@@FetchLicenseeDetailsWrapList'+FetchLicenseeDetailsWrapList.size());            
                alw =  (FetchLicenseeDetailsWrapper) System.JSON.deserialize(res.getBody(), FetchLicenseeDetailsWrapper.class); 
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