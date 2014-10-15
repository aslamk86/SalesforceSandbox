public class FetchAccountTransactionDetails{

//Declaring Variables
public List<FetchAcqOrAccTransactionWrapper.response> FetchAccViewWrapList {get; set;}
public string URL;
public boolean noRec{get;set;}
public string idValue;
public string statuscode;
public integer accViewPageNum{get;set;}
public FetchAcqOrAccTransactionWrapper.pagination accListWrapPageInfo{get;set;}
public FetchAcqOrAccTransactionWrapper accWrapper = new FetchAcqOrAccTransactionWrapper();
public Id accId;

    //Start of Constructor
    public FetchAccountTransactionDetails(ApexPages.StandardController controller){      
        noRec = false;  
        FetchAccViewWrapList = new List<FetchAcqOrAccTransactionWrapper.Response>();         
        accId = controller.getId(); 
        accViewPageNum=1;        
    }

    //Start of Action Method   
    public pagereference FetchTransactions(){     
        //accViewPageNum=1; 
        accListWrapPageInfo= new FetchAcqOrAccTransactionWrapper.pagination();
        //acquisitionRecord =[select id,name from Acquisition_Opportunity__c where id =:pat.id][0];
        system.debug('@@ in FetchTransactions accId:'+ accId);      
        
        idValue=string.valueof(accId);                 
        if (idValue != null) {
            refreshData();
        }
        return null;
    }
    
    public void refreshData(){
        try{
            FetchAccViewWrapList = new List<FetchAcqOrAccTransactionWrapper.Response>();
            system.debug('@@ FetchAccViewWrapList'+FetchAccViewWrapList);           
            string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Account_Acquisition_View_API').Authorization_Token__c; 
            // Preparing EndPoint   
            string EndPoint=API_ENDPOINT_URLS__c.getValues('Account_Acquisition_View_API').ENDPOINT_URL__c;
            
            // Final End Point URL  
            URL= EndPoint+idValue+'&page='+accViewPageNum+'&per_page=10&type=ACT';
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
            wrap = FetchAcqOrAccTransactionWrapper.parse(res.getBody());                                                                           
            system.debug('@@wrap'+wrap);
            
            if(wrap.response!=null){        
                FetchAccViewWrapList.addAll(wrap.response);
                
                if(FetchAccViewWrapList.size()==0) {
                    noRec = true;             
                }               
                system.debug('@@FetchAccViewWrapList'+FetchAccViewWrapList.size());            
                accWrapper =  (FetchAcqOrAccTransactionWrapper) System.JSON.deserialize(res.getBody(), FetchAcqOrAccTransactionWrapper.class); 
                accListWrapPageInfo = accWrapper.Pagination;                                                                        
            }
        }
        catch(System.CalloutException e){
            System.debug('@@in Callout Exception '+e.getMessage());
           // String error = 'Error Occured.Please try after sometime';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
             if(statuscode!=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'(Error Code-'+statuscode+')'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
        }
        catch(exception e){
            System.debug('@@in final Exception '+e.getMessage());
           // String error = e.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));  
            if(statuscode!=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'(Error Code-'+statuscode+')'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
        }
    }           
    
     public void loadMoreLicensees(){            
        if(accListWrapPageInfo.pages>accViewPageNum){
            accViewPageNum=accViewPageNum+ 1;         
            refreshData();          
        }
    }
    
     public void loadPrevLicensees(){       
        if(accViewPageNum>1){
            accViewPageNum=accViewPageNum - 1;            
            refreshData();          
        }      
    }
    
}