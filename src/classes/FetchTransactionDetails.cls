public class FetchTransactionDetails{

//Declaring Variables
public List<FetchTransactionDetailWrapper.response> FetchTransactionDetailWrapList {get; set;}
public List<string> TDRelatedPatentsWrapList{get;set;}
public List<TDRelatedAcqsWrapper.response> TDRelatedAcqsWrapList{get;set;}
public List<TDRelatedAssnWrapper.response> TDRelatedAssnWrapList{get;set;} 
public string URL;
public boolean noRec{get;set;}
public boolean noOppRec{get;set;}
public boolean noPatRec{get;set;}
public boolean noAssnRec{get;set;}
public string idValue{get;set;}
public string statuscode;
//public string patstatuscode;
//public string acqstatuscode;
//public string assnstatuscode;
//public string transtatuscode;
public integer patViewPageNum{get;set;}
public integer acqViewPageNum{get;set;}
public integer assnViewPageNum{get;set;}
public FetchTransactionDetailWrapper.pagination patlwPageInfo{get;set;}
public TDRelatedPatentsWrapper.pagination rlpatlwPageInfo{get;set;}
public TDRelatedAcqsWrapper.pagination rlacqlwPageInfo{get;set;}
public TDRelatedAssnWrapper.pagination rlassnlwPageInfo{get;set;} 
public FetchTransactionDetailWrapper patvw = new FetchTransactionDetailWrapper();
public TDRelatedPatentsWrapper rlpatvw = new TDRelatedPatentsWrapper();
public TDRelatedAcqsWrapper rlacqvw = new TDRelatedAcqsWrapper();
public TDRelatedAssnWrapper rlassnvw = new TDRelatedAssnWrapper();
public Assets__c patFamilyRec{get;set;}
public string EndPoint{get;set;}
//public Assets__c acqOppLit{get;set;}
public set<decimal> oppLitSet = new set<decimal>();
    //Start of Constructor
    public FetchTransactionDetails(){      
        noRec = false;  
        FetchTransactionDetailWrapList = new List<FetchTransactionDetailWrapper.Response>();
        TDRelatedPatentsWrapList = new List<string>();  
        TDRelatedAcqsWrapList = new List<TDRelatedAcqsWrapper.response>();  
        TDRelatedAssnWrapList = new List<TDRelatedAssnWrapper.response>();
        idValue=ApexPages.currentPage().getParameters().get('TransactionId');
        system.debug('@@In Constructor'+idvalue);   
        patViewPageNum=1;  
        acqViewPageNum=1;
        assnViewPageNum=1;      
    }

    //Start of Action Method   
    public pagereference FetchTransactions(){         
        patViewPageNum=1; 
        acqViewPageNum=1;
        assnViewPageNum=1;
        patlwPageInfo= new FetchTransactionDetailWrapper.pagination();                     
        rlpatlwPageInfo = new TDRelatedPatentsWrapper.pagination();
        rlacqlwPageInfo = new TDRelatedAcqsWrapper.pagination();
        rlassnlwPageInfo = new TDRelatedAssnWrapper.pagination();
        
        EndPoint=API_ENDPOINT_URLS__c.getValues('Transaction Detail API').ENDPOINT_URL__c;  
        if(idValue != null){    
        //Endpoint URL for Trasaction   
        URL= EndPoint+idValue+'&page='+patViewPageNum+'&per_page=10&type=DTLS';
        refreshData(URL,'DTLS','action');
        //Endpoint URL for Related Patents
        URL= EndPoint+idValue+'&page='+patViewPageNum+'&per_page=10&type=RLPT';        
        refreshData(URL,'RLPT','action');
        //Endpoint URL for Related Acquisitions
        URL= EndPoint+idValue+'&page='+acqViewPageNum+'&per_page=10&type=RLAQ';        
        refreshData(URL,'RLAQ','action');
        //Endpoint URL for Related Assignments
        URL= EndPoint+idValue+'&page='+assnViewPageNum+'&per_page=10&type=RLAS';        
        refreshData(URL,'RLAS','action');
        
        }
        else{
            noRec = true;  
            patViewPageNum =1;
            rlpatlwPageInfo.pages =1;
            rlpatlwPageInfo.Count=0;
        }
        return null;
    }
    
    public void refreshData(string URL,String type,string origin){
        try{
            //FetchTransactionDetailWrapList = new List<FetchTransactionDetailWrapper.Response>();
            if(origin=='paginationPat')
            TDRelatedPatentsWrapList = new List<string>();
            if(origin=='paginationAcq') 
            TDRelatedAcqsWrapList = new List<TDRelatedAcqsWrapper.response>();
            if(origin=='paginationAssn')
            TDRelatedAssnWrapList = new List<TDRelatedAssnWrapper.response>();
            system.debug('@@ FetchTransactionDetailWrapList'+FetchTransactionDetailWrapList);  
                string AuthorizationToken=API_ENDPOINT_URLS__c.getValues('Transaction Detail API').Authorization_Token__c;
                //string EndPoint=API_ENDPOINT_URLS__c.getValues('Transaction Detail API').ENDPOINT_URL__c;              
                //URL= EndPoint+idValue+'&page='+patViewPageNum+'&per_page=10&type=DTLS';
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
            statuscode = string.valueOf(res.getStatusCode()) ;              
            //Parsing the Response
            if(type=='DTLS'){
                FetchTransactionDetailWrapper wrap = new FetchTransactionDetailWrapper();
                //transtatuscode = string.valueOf(res.getStatusCode()) ;        
                wrap = FetchTransactionDetailWrapper.parse(res.getBody());                                                                           
                system.debug('@@wrap'+wrap);
                
                if(wrap.response!=null){        
                    FetchTransactionDetailWrapList.addAll(wrap.response);                   
                    if(FetchTransactionDetailWrapList.size()==0)
                    noRec = true;  
                                                             
                    patvw =  (FetchTransactionDetailWrapper) System.JSON.deserialize(res.getBody(), FetchTransactionDetailWrapper.class); 
                    //patlwPageInfo = patvw.Pagination;                                                                        
                }  
            }

            if(type=='RLPT'){
                TDRelatedPatentsWrapper wrap = new TDRelatedPatentsWrapper();   
                //patstatuscode = string.valueOf(res.getStatusCode()) ;      
                wrap = TDRelatedPatentsWrapper.parse(res.getBody());                                                                           
                system.debug('@@wrap'+wrap);
                
                if(wrap.response!=null){        
                    TDRelatedPatentsWrapList.addAll(wrap.response); 
                    
                    if(TDRelatedPatentsWrapList.size()==0)
                    noPatRec = true;                                        
                                                             
                    rlpatvw =  (TDRelatedPatentsWrapper) System.JSON.deserialize(res.getBody(), TDRelatedPatentsWrapper.class); 
                    rlpatlwPageInfo = rlpatvw.Pagination;                                                                        
                }  
            }   
            
            if(type=='RLAQ'){
                TDRelatedAcqsWrapper wrap = new TDRelatedAcqsWrapper(); 
                //acqstatuscode = string.valueOf(res.getStatusCode()) ;        
                wrap = TDRelatedAcqsWrapper.parse(res.getBody());                                                                           
                system.debug('@@wrap'+wrap);

                if(wrap.response!=null){        
                    TDRelatedAcqsWrapList.addAll(wrap.response); 

                    if(TDRelatedAcqsWrapList.size()==0)
                    noOppRec = true;                                        
                                                             
                    rlacqvw =  (TDRelatedAcqsWrapper) System.JSON.deserialize(res.getBody(), TDRelatedAcqsWrapper.class); 
                    rlacqlwPageInfo = rlacqvw.Pagination;                                                                        
                }  
            }   
            
            if(type=='RLAS'){
                TDRelatedAssnWrapper  wrap = new TDRelatedAssnWrapper (); 
                //assnstatuscode = string.valueOf(res.getStatusCode()) ;        
                wrap = TDRelatedAssnWrapper.parse(res.getBody());                                                                           
                system.debug('@@wrap'+wrap);

                if(wrap.response!=null){        
                    TDRelatedAssnWrapList.addAll(wrap.response); 

                    if(TDRelatedAssnWrapList.size()==0)
                    noAssnRec = true;                                        
                                                             
                    rlassnvw =  (TDRelatedAssnWrapper) System.JSON.deserialize(res.getBody(), TDRelatedAssnWrapper.class); 
                    rlassnlwPageInfo = rlassnvw.Pagination;                                                                        
                }  
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
        
    
    public void loadMorePatents(){            
        if(rlpatlwPageInfo.pages>patViewPageNum){
            patViewPageNum=patViewPageNum+ 1;   
            URL= EndPoint+idValue+'&page='+patViewPageNum+'&per_page=10&type=RLPT'; 
            refreshData(URL,'RLPT','paginationPat');          
        }
    }
    
     public void loadPrevPatents(){       
        if(patViewPageNum>1){
            patViewPageNum=patViewPageNum - 1; 
            URL= EndPoint+idValue+'&page='+patViewPageNum+'&per_page=10&type=RLPT'; 
            refreshData(URL,'RLPT','paginationPat');          
        }      
    }
    
    public void loadMoreAcqs(){            
        if(rlacqlwPageInfo.pages>acqViewPageNum){
            acqViewPageNum=acqViewPageNum+ 1;   
            URL= EndPoint+idValue+'&page='+acqViewPageNum+'&per_page=10&type=RLAQ'; 
            refreshData(URL,'RLAQ','paginationAcq');          
        }
    }
    
     public void loadPrevAcqs(){       
        if(acqViewPageNum>1){
            acqViewPageNum=acqViewPageNum - 1; 
            URL= EndPoint+idValue+'&page='+acqViewPageNum+'&per_page=10&type=RLAQ'; 
            refreshData(URL,'RLAQ','paginationAcq');          
        }      
    }
    
    public void loadMoreAssns(){            
        if(rlassnlwPageInfo.pages>assnViewPageNum){
            assnViewPageNum=assnViewPageNum+ 1;   
            URL= EndPoint+idValue+'&page='+assnViewPageNum+'&per_page=10&type=RLAS'; 
            refreshData(URL,'RLAS','paginationAssn');          
        }
    }
    
     public void loadPrevAssns(){       
        if(assnViewPageNum>1){
            assnViewPageNum=assnViewPageNum - 1; 
            URL= EndPoint+idValue+'&page='+assnViewPageNum+'&per_page=10&type=RLAS'; 
            refreshData(URL,'RLAS','paginationAssn');          
        }      
    }
    
}