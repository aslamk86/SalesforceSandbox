public class FetchAcquisitionTransactionDetails{

//Declaring Variables
public List<FetchAcqOrAccTransactionWrapper.response> FetchAcqViewWrapList {get; set;}
public string URL;
public boolean noRec{get;set;}
public string idValue;
public string statuscode;
//public Acquisition_Opportunity__c pat;
public integer acqViewPageNum{get;set;}
public FetchAcqOrAccTransactionWrapper.pagination acqListWrapPageInfo{get;set;}
public FetchAcqOrAccTransactionWrapper acqWrapper = new FetchAcqOrAccTransactionWrapper();
//public Acquisition_Opportunity__c acquisitionRecord{get;set;}
public Id acqId;

    //Start of Constructor
    public FetchAcquisitionTransactionDetails(ApexPages.StandardController controller){      
        noRec = false;  
        FetchAcqViewWrapList = new List<FetchAcqOrAccTransactionWrapper.Response>();         
        acqId = controller.getId(); 
        acqViewPageNum=1;        
    }

    //Start of Action Method   
    public pagereference FetchTransactions(){     
        //acqViewPageNum=1; 
        acqListWrapPageInfo= new FetchAcqOrAccTransactionWrapper.pagination();
        system.debug('@@ in FetchTransactions acqId:'+ acqId);      
        
        idValue=string.valueof(acqId);                 
        if (idValue != null) {
            refreshData();
        }
        return null;
    }
    
    public void refreshData(){
        try{
            FetchAcqViewWrapList = new List<FetchAcqOrAccTransactionWrapper.Response>();
            system.debug('@@ FetchAcqViewWrapList'+FetchAcqViewWrapList); 
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Account_Acquisition_View_API').Authorization_Token__c;          
            // Preparing EndPoint   
            string EndPoint=API_ENDPOINT_URLS__c.getValues('Account_Acquisition_View_API').ENDPOINT_URL__c;
            
            // Final End Point URL  
            URL= EndPoint+idValue+'&page='+acqViewPageNum+'&per_page=10&type=ACQ';
            system.debug('@@URL'+URL);            
                                  
            // Instantiate a new http object
            Http h = new Http();
            
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL);
            req.setMethod('GET');
            req.setHeader('Authorization', AuthorizationToken);
            req.setTimeOut(120000);
            // Send the request, and return a response
            HttpResponse res = h.send(req);
            system.debug('@@ response'+res);
            
            //Parsing the Response
            FetchAcqOrAccTransactionWrapper wrap = new FetchAcqOrAccTransactionWrapper();   
            statuscode=string.valueOf(res.getStatusCode()) ;   
            system.debug('@@statuscode'+res.getStatusCode());           
            system.debug('@@response'+res);
            system.debug('@@statuscode'+statuscode);
            
            wrap = FetchAcqOrAccTransactionWrapper.parse(res.getBody());                                                                           
            system.debug('@@wrap'+wrap);
            
            if(wrap.response!=null){        
                FetchAcqViewWrapList.addAll(wrap.response);
                
                if(FetchAcqViewWrapList.size()==0) {
                    noRec = true;             
                }               
                system.debug('@@FetchAcqViewWrapList'+FetchAcqViewWrapList.size());            
                acqWrapper =  (FetchAcqOrAccTransactionWrapper) System.JSON.deserialize(res.getBody(), FetchAcqOrAccTransactionWrapper.class); 
                acqListWrapPageInfo = acqWrapper.Pagination;                                                                        
            }
        }
        catch(System.CalloutException e){
            System.debug('@@in Callout Exception '+e.getMessage());
            //String error = 'Error Occured.Please try after sometime'+statuscode;
            if(statuscode!=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'(Error Code-'+statuscode+')'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
        }
        catch(exception e){
            System.debug('@@in final Exception '+e.getMessage());
            //String error = e.getMessage()+statuscode ;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'('+statuscode+')'));
            if(statuscode!=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'(Error Code-'+statuscode+')'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));  
        }
    }           
    
     public void loadMoreLicensees(){            
        if(acqListWrapPageInfo.pages>acqViewPageNum){
            acqViewPageNum=acqViewPageNum+ 1;         
            refreshData();          
        }
    }
    
     public void loadPrevLicensees(){       
        if(acqViewPageNum>1){
            acqViewPageNum=acqViewPageNum - 1;            
            refreshData();          
        }      
    }
    
}