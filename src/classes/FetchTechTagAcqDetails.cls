public class FetchTechTagAcqDetails{

//Declaring Variables
public List<FetchTechTagAcqDetailsWrapper.response> FetchTechTagAcqDetailsWrapList {get; set;}
public string URL;
public boolean noRec{get;set;}
public string statuscode;
public string idValue;
public id techTagId;
public integer acqLicPageNum{get;set;}
public FetchTechTagAcqDetailsWrapper.pagination acqlwPageInfo{get;set;}
public FetchTechTagAcqDetailsWrapper acqlw = new FetchTechTagAcqDetailsWrapper();
public Product_or_Service__c techTagRec{get;set;}

    //Start of Constructor
    public FetchTechTagAcqDetails(ApexPages.StandardController controller){      
        noRec = false;  
        FetchTechTagAcqDetailsWrapList = new List<FetchTechTagAcqDetailsWrapper.Response>();        
        techTagId = controller.getId();
        idValue=string.valueof(techTagId);
        acqLicPageNum=1;        
    }

    //Start of Action Method     
    public pagereference FetchTechTagDetails(){     
        acqLicPageNum=1; 
        acqlwPageInfo= new FetchTechTagAcqDetailsWrapper.pagination();
       
        if(idValue!=null)        
        refreshData();
        
        return null;
    }
    public void refreshData(){
        try{
            FetchTechTagAcqDetailsWrapList = new List<FetchTechTagAcqDetailsWrapper.Response>();
            system.debug('@@ FetchTechTagAcqDetailsWrapList'+FetchTechTagAcqDetailsWrapList);                                       
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('TechTag Details API').Authorization_Token__c; 
            string EndPoint=API_ENDPOINT_URLS__c.getValues('TechTag Details API').ENDPOINT_URL__c;
            URL= EndPoint+idValue+'&page='+acqLicPageNum+'&per_page=10&type=OPRS';        
                                  
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
            FetchTechTagAcqDetailsWrapper wrap = new FetchTechTagAcqDetailsWrapper();        
                wrap = FetchTechTagAcqDetailsWrapper.parse(res.getBody()); 
                statuscode=string.valueOf(res.getStatusCode()) ;                                                                           
                system.debug('@@wrap'+wrap);
            
            
            if(wrap.response!=null){        
                FetchTechTagAcqDetailsWrapList.addAll(wrap.response); 
                if(FetchTechTagAcqDetailsWrapList.size()==0)
                noRec = true;    
                //Added for Date Format
                for(FetchTechTagAcqDetailsWrapper.response resp: FetchTechTagAcqDetailsWrapList){
                    if(resp.created_date!=null)
                    resp.createddateValFormat= dateTime.valueOfGMT(resp.created_date).format();                   
                }                     
                system.debug('@@FetchTechTagAcqDetailsWrapList'+FetchTechTagAcqDetailsWrapList.size());           
                acqlw =  (FetchTechTagAcqDetailsWrapper) System.JSON.deserialize(res.getBody(), FetchTechTagAcqDetailsWrapper.class); 
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
            refreshData();          
        }
    }
    
    public void loadPrevLicensees(){       
        if(acqLicPageNum>1){
            acqLicPageNum=acqLicPageNum - 1;        
            refreshData();          
        } 
    }
    
}