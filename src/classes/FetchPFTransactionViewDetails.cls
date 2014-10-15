public class FetchPFTransactionViewDetails{

//Declaring Variables
public List<FetchPFTransactionViewWrapper.response> FetchPatentFamilyViewWrapList {get; set;}
public string URL;
public boolean noRec{get;set;}
public string idValue;
public string statuscode;
public Assets__c pat;
public integer patViewPageNum{get;set;}
public FetchPFTransactionViewWrapper.pagination patlwPageInfo{get;set;}
public FetchPFTransactionViewWrapper patvw = new FetchPFTransactionViewWrapper();
public Assets__c patFamilyRec{get;set;}
//public Assets__c acqOppLit{get;set;}
public set<decimal> oppLitSet = new set<decimal>();
    //Start of Constructor
    public FetchPFTransactionViewDetails(ApexPages.StandardController controller){      
        noRec = false;  
        FetchPatentFamilyViewWrapList = new List<FetchPFTransactionViewWrapper.Response>();        
        pat = (Assets__c)controller.getRecord();
        patViewPageNum=1;        
    }

    //Start of Action Method   
    public pagereference FetchTransactions(){     
        patViewPageNum=1; 
        patlwPageInfo= new FetchPFTransactionViewWrapper.pagination();
        patFamilyRec =[select id,name,Core_Patent_Family_Id__c from Assets__c where id =:pat.id][0];
        system.debug('@@ in FetchLicensee');                
        idValue=string.valueof(patFamilyRec.Core_Patent_Family_Id__c);                 
        if(idValue != null)
        refreshData();
        else{
            patViewPageNum =1;
            patlwPageInfo.pages =1;
            patlwPageInfo.Count=0;
        }
        return null;
    }
    
    public void refreshData(){
        try{
            FetchPatentFamilyViewWrapList = new List<FetchPFTransactionViewWrapper.Response>();
            system.debug('@@ FetchPatentFamilyViewWrapList'+FetchPatentFamilyViewWrapList);  
                string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Patent View API').Authorization_Token__c;
                string EndPoint=API_ENDPOINT_URLS__c.getValues('Patent View API').ENDPOINT_URL__c;              
                URL= EndPoint+idValue+'&page='+patViewPageNum+'&per_page=10&type=PFMS';
                system.debug('@@URL'+URL);
            
                                  
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
            FetchPFTransactionViewWrapper wrap = new FetchPFTransactionViewWrapper();  
            statuscode=string.valueOf(res.getStatusCode()) ;       
            wrap = FetchPFTransactionViewWrapper.parse(res.getBody());                                                                           
            system.debug('@@wrap'+wrap);
            
            if(wrap.response!=null){        
                FetchPatentFamilyViewWrapList.addAll(wrap.response); 
                if(FetchPatentFamilyViewWrapList.size()==0)
                noRec = true;                            
                system.debug('@@FetchPatentFamilyViewWrapList'+FetchPatentFamilyViewWrapList.size());            
                patvw =  (FetchPFTransactionViewWrapper) System.JSON.deserialize(res.getBody(), FetchPFTransactionViewWrapper.class); 
                patlwPageInfo = patvw.Pagination;                                                                        
            }
        }
        catch(System.CalloutException e){
            System.debug('@@in Callout Exception '+e.getMessage());
            //String error = 'Error Occured.Please try after sometime';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.API_Error_Message));            
        }
        catch(exception e){
            System.debug('@@in final Exception '+e.getMessage());
            String error = e.getMessage();
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