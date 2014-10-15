public class FetchPatentTransactionViewDetails{

//Declaring Variables
public List<FetchPatentTransactionViewWrapper.response> FetchPatentViewWrapList {get; set;}
public string URL;
public boolean noRec{get;set;}
public string idValue;
public string statuscode;
public Patent__c pat;
public integer patViewPageNum{get;set;}
public FetchPatentTransactionViewWrapper.pagination patlwPageInfo{get;set;}
public FetchPatentTransactionViewWrapper patvw = new FetchPatentTransactionViewWrapper();
public Patent__c patRec{get;set;}

    //Start of Constructor
    public FetchPatentTransactionViewDetails(ApexPages.StandardController controller){      
        noRec = false;  
        FetchPatentViewWrapList = new List<FetchPatentTransactionViewWrapper.Response>();        
        pat = (Patent__c)controller.getRecord();
        patViewPageNum=1;        
    }

    //Start of Action Method   
    public pagereference FetchTransactions(){     
        patViewPageNum=1; 
        patlwPageInfo= new FetchPatentTransactionViewWrapper.pagination();
        patRec =[select id,name from Patent__c where id =:pat.id][0];
        system.debug('@@ in FetchLicensee');                
        idValue=string.valueof(patRec.name);                 
        if(idValue != null)
        refreshData();
        return null;
    }
    
    public void refreshData(){
        try{
            FetchPatentViewWrapList = new List<FetchPatentTransactionViewWrapper.Response>();
            system.debug('@@ FetchPatentViewWrapList'+FetchPatentViewWrapList);  
                string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Patent View API').Authorization_Token__c; 
                string EndPoint=API_ENDPOINT_URLS__c.getValues('Patent View API').ENDPOINT_URL__c;              
                URL= EndPoint+idValue+'&page='+patViewPageNum+'&per_page=10&type=PATS';
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
            FetchPatentTransactionViewWrapper wrap = new FetchPatentTransactionViewWrapper();    
            statuscode=string.valueOf(res.getStatusCode()) ;     
            wrap = FetchPatentTransactionViewWrapper.parse(res.getBody());                                                                           
            system.debug('@@wrap'+wrap);
            
            if(wrap.response!=null){        
                FetchPatentViewWrapList.addAll(wrap.response); 
                if(FetchPatentViewWrapList.size()==0)
                noRec = true;                            
                system.debug('@@FetchPatentViewWrapList'+FetchPatentViewWrapList.size());            
                patvw =  (FetchPatentTransactionViewWrapper) System.JSON.deserialize(res.getBody(), FetchPatentTransactionViewWrapper.class); 
                patlwPageInfo = patvw.Pagination;                                                                        
            }
        }
        catch(System.CalloutException e){
            System.debug('@@in Callout Exception '+e.getMessage());
            //String error = 'Error Occured.Please try after sometime';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
            if(statuscode!=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'(Error Code-'+statuscode+')'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
        }
        catch(exception e){
            System.debug('@@in final Exception '+e.getMessage());
            //String error = e.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));  
            if(statuscode!=null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message+'(Error Code-'+statuscode+')'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));
        }
    }           
    
     public void loadMoreLicensees(){            
        if(patlwPageInfo.pages>patViewPageNum){
            patViewPageNum=patViewPageNum+ 1;         
            refreshData();          
        }
    }
    
     public void loadPrevLicensees(){       
        if(patViewPageNum>1){
            patViewPageNum=patViewPageNum - 1;            
            refreshData();          
        }      
    }
    
}