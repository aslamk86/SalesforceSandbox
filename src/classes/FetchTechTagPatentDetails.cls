public class FetchTechTagPatentDetails{

//Declaring Variables
public List<FetchTechTagPFDetailsWrapper.response> FetchTechTagPFDetailsWrapList {get; set;}
public string URL;
public boolean noRec{get;set;}
public string statuscode;
public string idValue;
public id techTagId;
public integer acqLicPageNum{get;set;}
public FetchTechTagPFDetailsWrapper.pagination acqlwPageInfo{get;set;}
public FetchTechTagPFDetailsWrapper acqlw = new FetchTechTagPFDetailsWrapper();


    //Start of Constructor
    public FetchTechTagPatentDetails(ApexPages.StandardController controller){      
        noRec = false;  
        FetchTechTagPFDetailsWrapList = new List<FetchTechTagPFDetailsWrapper.Response>();        
        techTagId= controller.getId();
        idValue=string.valueof(techTagId);
        acqLicPageNum=1;        
    }

    //Start of Action Method     
    public pagereference FetchTechTagDetails(){     
        acqLicPageNum=1; 
        acqlwPageInfo= new FetchTechTagPFDetailsWrapper.pagination();
        
        if(idValue!=null)       
        refreshData();
        
        return null;
    }
    public void refreshData(){
        try{
            FetchTechTagPFDetailsWrapList = new List<FetchTechTagPFDetailsWrapper.Response>();
            system.debug('@@ FetchTechTagPFDetailsWrapList'+FetchTechTagPFDetailsWrapList);            
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('TechTag Details API').Authorization_Token__c;  
            string EndPoint=API_ENDPOINT_URLS__c.getValues('TechTag Details API').ENDPOINT_URL__c;  
            URL= EndPoint+idValue+'&page='+acqLicPageNum+'&per_page=10&type=PATS';       
                                          
            // Instantiate a new http object
            Http h = new Http();
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL);
            req.setMethod('GET');
            req.setHeader('Authorization', AuthorizationToken);
            req.setTimeOut(120000) ; // timeout in milliseconds
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug('@@ response'+res);
            
            //Parsing the Response
            FetchTechTagPFDetailsWrapper wrap = new FetchTechTagPFDetailsWrapper();       
            wrap = FetchTechTagPFDetailsWrapper.parse(res.getBody());   
            statuscode=string.valueOf(res.getStatusCode()) ;                                                                         
            system.debug('@@wrap'+wrap);
                
            if(wrap.response!=null){        
                FetchTechTagPFDetailsWrapList.addAll(wrap.response); 
                if(FetchTechTagPFDetailsWrapList.size()==0)
                    noRec = true;                         
                system.debug('@@FetchTechTagPFDetailsWrapList'+FetchTechTagPFDetailsWrapList.size());           
                acqlw =  (FetchTechTagPFDetailsWrapper) System.JSON.deserialize(res.getBody(), FetchTechTagPFDetailsWrapper.class); 
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