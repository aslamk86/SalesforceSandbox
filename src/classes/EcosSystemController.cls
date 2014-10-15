/********************************************

Controller for the Ecosystem management page

********************************************/


public class EcosSystemController{
    
    public string viewType {get; set;}
    public List<EcoSystem__c> allEcoSystems {get; set;}
    public List<EcoSystem__c> ecoSystems {get; set;}
    public Account thisAccount {get; set;}
    public List<EcoSystem_Detail__c> accountsToShowInList {get; set;}
    public Map<Id,List<Account>> selectedAccounts {get; set;}
    public Id selectedEcoSystem {get; set;}
    public String selectedEcosystemName {get; set;}
    public boolean hasDraft{get;set;}
    public Id draftEcosystemId{get; set;}
    public boolean draftEditMode{get; set;}
    public Id tobeRemoved {get; set;}
    public Set<id> accountIdsInPreviousEcos {get; set;}
    public Set<id> accountIdsInThisDraft {get; set;}
    public List<Account> otherAccountSearchList{get; set;}
    public String searchString {get; set;}
    public String selectedEcoSys {get; set;}
    public List<compareWrapper> compareWrapperList {get; set;}
    public EcoSystem__c primaryCompare {get; set;}
    public List<searchAccountsWrapper> searchAccountWrapperList{get; set;}
    public boolean displayPopup {get; set;}
    public String versionName {get; set;}
    public List<RelatedCompanyWrapper.Response> relatedCompanyObj {get; set;}
    public List<CoDefendantWrapper.Response> coDefendantObj {get; set;}
    public Boolean clone{get; set;}
    public Id deleteDraftId{get; set;}
    public Id accountIdToAdd{get; set;}
    public Decimal percentToAssign{get; set;}
    public String typeOfRecord{get; set;}
    public Boolean firstCompareFlag {get; set;}
    public List<compareWrapper> selectedCompareWrapperList {get; set;}
    
    public Map<id,Account> accountMapList {get; set;}
    
    public EcoSystem__c newClonedEcosystemFromOther {get;set;}
    public List<EcoSystem__c> listOfOtherAccEcosystems {get; set;} //to get the list for cloning
    public Id cloneId{get; set;}

   public Integer coDefPageNum{get; set;}
   public CoDefendantWrapper.pagination cdwPageInfo{get; set;}
   public CoDefendantWrapper cdw = new CoDefendantWrapper();
   
   public EcosSystemController(ApexPages.StandardController controller) {
        thisAccount = (Account)controller.getRecord();
        viewType ='All';
        coDefPageNum = 1;
        clone = false;
        relatedCompanyObj = FetchRelatedCompany();
        coDefendantObj  = FetchCoDefendants();
        refreshData();
        firstCompareFlag = false;
        newClonedEcosystemFromOther = new EcoSystem__c();
    }      
                            
    public class searchAccountsWrapper{
        public Account searchedAccount{get; set;}
        public Boolean alreadInEcosystem{get; set;}
        public Boolean alreadyInPastEcosystem{get; set;}
        public Boolean addToThisEcosystem{get; set;}
        public searchAccountsWrapper(Account searchedAccount,Boolean alreadInEcosystem,Boolean alreadyInPastEcosystem,Boolean addToThisEcosystem){
            this.searchedAccount = searchedAccount;
            this.alreadInEcosystem = alreadInEcosystem;
            this.alreadyInPastEcosystem = alreadyInPastEcosystem;
            this.addToThisEcosystem = addToThisEcosystem;
        }
    }
    
    public class compareWrapper{
    
        public EcoSystem__c ecoSystem {get; set;}
        public boolean selectedEco {get; set;}
        public List<Account> uniqueAccnts {get; set;}
        public List<Account> missingAccnts {get; set;} //accounts in primary, but not in compared one
        public Map<id,id> ecoDetailAccountMap {get; set;}
        public compareWrapper(Ecosystem__c ecoSystem,Boolean selecteEco){
            this.ecoSystem = ecoSystem;
            this.selectedEco = selectedEco;
            missingAccnts = new List<Account>();
            ecoDetailAccountMap = new Map<Id,Id>();
        }
    }
    
   
    
    
    public void refreshData(){
        allEcoSystems = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedDate,CreatedById,LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c,First_Added__c, Ecosystem_Entity__r.Name,CreatedDate,Source__c,Similarity__c,CreatedBy.Name  From EcoSystem_Details__r order by  Ecosystem_Entity__r.Name asc) from EcoSystem__c where Company__c =: thisAccount.id order by LastModifiedDate desc];
        ecoSystems = new List<EcoSystem__c>();
        ecoSystems.addAll(allEcoSystems);
        selectedEcosystemName = 'Ecosystem : None Selected';
        hasDraft = false;
        accountIdsInPreviousEcos = new set<id>();
        accountIdsInThisDraft  =  new set<id>();
        
        if(allEcoSystems!=null && allEcoSystems.size()>0){
        for(EcoSystem__c ecoTemp:allEcoSystems){

            if(ecoTemp.status__c=='Draft'){
                hasDraft = true;
                draftEcosystemId = ecoTemp.id;
                for(EcoSystem_Detail__c ecoDet:ecoTemp.EcoSystem_Details__r){
                    accountIdsInThisDraft.add(ecoDet.Ecosystem_Entity__c);
                }
            }
            else{
                for(EcoSystem_Detail__c ecoDet:ecoTemp.EcoSystem_Details__r){
                    accountIdsInPreviousEcos.add(ecoDet.Ecosystem_Entity__c);
                }
            }
        }
        }
        
        List<Id> AccountIdList = new List<Id>();
        
        if(relatedCompanyObj!=null){
        
            for(RelatedCompanyWrapper.Response temp: relatedCompanyObj){
                AccountIdList.add(temp.relevant_company);
                
            }
        }
        if(coDefendantObj!=null){
            for(CoDefendantWrapper.Response temp: coDefendantObj){
                if(temp.salesforce_id_codef!=null)
                    AccountIdList.add(temp.salesforce_id_codef);
                    //temp.InThisDraft=accountIdsInThisDraft.contains(temp.salesforce_id_codef);
            }        
        }
        
        accountMapList = new Map<id,Account>([select id,Has_Ecosystem__c from Account where id in:AccountIdList]);                        
        
        
        if(relatedCompanyObj!=null){
        for(RelatedCompanyWrapper.Response temp: relatedCompanyObj){
            if(temp.relevant_company!=null){
                if(accountMapList.get(temp.relevant_company)!=null){
                    temp.PastEcoSystem = accountMapList.get(temp.relevant_company).Has_Ecosystem__c>0;
                    temp.inThisDraft = accountIdsInThisDraft.contains(temp.relevant_company);
                }
            }
        }
        }
        if(coDefendantObj!=null){
        for(CoDefendantWrapper.Response temp: coDefendantObj){
            if(temp.salesforce_id_codef!=null){
                if(accountMapList.get(temp.salesforce_id_codef)!=null){
                    temp.PastEcoSystem = accountMapList.get(temp.salesforce_id_codef).Has_Ecosystem__c>0;
                    temp.InThisDraft = accountIdsInThisDraft.contains(temp.salesforce_id_codef);
                }
            }
        }
        }
    }        
   
    public void refreshVersionsList(){
        selectedEcoSystem = null;
        ecoSystems.clear();
        for(EcoSystem__c ecoTemp: allEcoSystems){
                ecoSystems.add(ecoTemp);
        }  
    }
 
    public void fetchAccountsForThisEco(){        
        for(EcoSystem__c ecoTemp:allEcoSystems){
            if(ecoTemp.id==selectedEcoSystem){
                accountsToShowInList = new List<EcoSystem_Detail__c>();
                for(EcoSystem_Detail__c ecoDetailTemp: ecoTemp.EcoSystem_Details__r){
                    accountsToShowInList.add(ecoDetailTemp);
                    accountIdsInThisDraft.add(ecoDetailTemp.Ecosystem_Entity__c);
                }
                if(ecoTemp.Status__c == 'Draft'){
                    selectedEcosystemName = 'Ecosystem : '+ecoTemp.Status__c+' ('+ecoTemp.Version_name__c+')';
                    versionName = ecoTemp.Version_name__c;
                }
                else {
                    selectedEcosystemName = 'Ecosystem : Version '+ecoTemp.version__c+' ('+ecoTemp.version_name__c+')';
                    draftEditMode = false;
                }
                break;
            }
        }
    }
    public void createNewDraftVersion(){
        
        EcoSystem__c newEcosystem = new EcoSystem__c(Company__c=ThisAccount.id,status__c='Draft',version_name__c=versionName );
        List<Ecosystem__c> draftEcos = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedById,CreatedDate, LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c,First_Added__c, Ecosystem_Entity__r.Name,CreatedDate,Source__c,Similarity__c,CreatedBy.Name  From EcoSystem_Details__r) from EcoSystem__c where Company__c =: thisAccount.id and status__c='Draft'];                    
        
        if(draftEcos.size()==0){
           insert newEcosystem;            
           
           selectedEcosystemName = 'Ecosystem : '+newEcosystem.Status__c+' ('+newEcosystem.version_name__c;
           displayPopup = false;
           hasDraft = true;
           if(clone){
             List<EcoSystem_Detail__c> ecoDetTobeInsterted = new List<EcoSystem_Detail__c>();
             List<EcoSystem_Detail__c> ecoDetList = [select id,Name,Ecosystem_Entity__c,EcoSystem__c,First_Added__c,Similarity__c,Source__c from EcoSystem_Detail__c where EcoSystem__c=:selectedEcoSystem];
             for(EcoSystem_Detail__c eco:ecoDetList){
                 String unique = newEcosystem.id+'-'+eco.Ecosystem_Entity__c;                
                 accountIdsInThisDraft.add(eco.Ecosystem_Entity__c);
                 EcoSystem_Detail__c ecoTemp = new EcoSystem_Detail__c(Ecosystem_Entity__c=eco.Ecosystem_Entity__c,EcoSystem__c=newEcosystem.id,Unique_Check__c=unique,Similarity__c=eco.Similarity__c,Source__c=eco.Source__c,First_Added__c=eco.First_Added__c);                 
                 
                 for(EcoSystem__c ecoTemp1:allEcoSystems){
                    for(EcoSystem_Detail__c ecoDet: ecoTemp1.EcoSystem_Details__r){
                        if(ecoDet.Ecosystem_Entity__c == eco.Ecosystem_Entity__c){
                            ecoTemp.First_Added__c = ecoDet.CreatedDate;
                        }
                    }        
                 } 
                 
                 
                 ecoDetTobeInsterted.add(ecoTemp);
             }
             insert ecoDetTobeInsterted;
           }
           //allEcoSystems = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedById,CreatedDate, LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c, Ecosystem_Entity__r.Name,CreatedDate,Source__c,First_Added__c,Similarity__c,CreatedBy.Name  From EcoSystem_Details__r) from EcoSystem__c where Company__c =: thisAccount.id order by LastModifiedDate desc];                    
           refreshVersionsList();
           refreshData();
           draftEcosystemId = selectedEcoSystem = newEcosystem.id;
           fetchAccountsForThisEco();

           displayPopup = false;
           hasDraft = true;           
           loadDraftForEditing();

        }        
        
    }
  
    public void loadDraftForEditing(){
        draftEditMode = true;
        
    }
    
    
    public void addToEcosystem(){
        String unique = selectedEcoSystem+'-'+accountIdToAdd;
        System.debug('###Unique '+unique);
        EcoSystem_Detail__c ecos = new EcoSystem_Detail__c();
        
        ecos.EcoSystem__c=selectedEcoSystem;
        ecos.Ecosystem_Entity__c=accountIdToAdd;
        ecos.Unique_Check__c=unique;
        ecos.Source__c=typeOfRecord;
        if(typeOfRecord == 'Manual' || typeOfRecord == 'Relevance'){
            List<SourceVerification.Response> svResp = CheckSource(accountIdToAdd);
            ecos.Similarity__c=svResp[0].percentage; 
            ecos.Source__c = svResp[0].account_type;
        }
        else{
            ecos.Similarity__c=percentToAssign;             
        }
        
        for(EcoSystem__c ecoTemp:allEcoSystems){
            for(EcoSystem_Detail__c ecoDet:ecoTemp.EcoSystem_Details__r){
                if(ecoDet.Ecosystem_Entity__c == ecos.Ecosystem_Entity__c && (ecos.First_Added__c == null || ecos.First_Added__c > ecoDet.createdDate)){
                    ecos.First_Added__c = ecoDet.CreatedDate;
                }
            }
        
        }
        
        if(ecos.First_Added__c==null) ecos.First_Added__c=System.now();
        
        upsert ecos Unique_Check__c;
        System.debug('###inserted '+ecos.id);
        
         allEcoSystems = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedDate,CreatedById, LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c, Ecosystem_Entity__r.Name,First_Added__c,CreatedDate,Source__c,Similarity__c,CreatedBy.Name  From EcoSystem_Details__r) from EcoSystem__c where Company__c =: thisAccount.id ];
            for(EcoSystem__c ecoTemp:allEcoSystems){
            if(ecoTemp.id==selectedEcoSystem){
                accountsToShowInList = new List<EcoSystem_Detail__c>();
                for(EcoSystem_Detail__c ecoDetailTemp: ecoTemp.EcoSystem_Details__r){
                    accountsToShowInList.add(ecoDetailTemp);
                    accountIdsInThisDraft.add(ecoDetailTemp.Ecosystem_Entity__c);
                }
                break;
            }
            }            
         refreshData();
         if(firstCompareFlag==true){
             repopulateData();
             populateCompareWrapper();
         }
         if(searchString!=null && searchString.length()>0)
             queryAccounts();         
    }           

    public void repopulateData(){        
        System.debug('### Entered repopulateData() ');
        for(EcoSystem__c ecoTemp:allEcoSystems){
            for(compareWrapper compTemp:compareWrapperList){
                if(ecoTemp.id == compTemp.Ecosystem.id){
                    compTemp.Ecosystem = ecoTemp;
                    //compTemp.Ecosystem = ecoTemp;
                }
            }
        }

    }
    
    public void comparePageLoad(){
        compareWrapperList = new List<compareWrapper>();
        for(EcoSystem__c ecoTemp:allEcoSystems){
            compareWrapperList.add(new compareWrapper(ecoTemp,false));
        }
    }  

    public void firstCompareFlag(){
       firstCompareFlag = true;
       populateCompareWrapper();
    }

    public void populateCompareWrapper(){
        List<compareWrapper> toBeReturned = new List<compareWrapper>();
                        
        primaryCompare = new EcoSystem__c();
        
        for(compareWrapper tempCompareWrap:compareWrapperList){
            if(tempCompareWrap.selectedEco!=null && tempCompareWrap.selectedEco==true && tempCompareWrap.ecosystem.id!=selectedEcoSys){
                toBeReturned.add(tempCompareWrap);
                tempCompareWrap.missingAccnts = new List<Account>();
            }

            if(selectedEcoSys==tempCompareWrap.ecoSystem.id){
                primaryCompare = tempCompareWrap.ecoSystem;
            }
        }     
                    
        for(CompareWrapper tempCompareWrap: toBeReturned){
            tempCompareWrap.uniqueAccnts = new List<Account>();
            for(EcoSystem_Detail__c ecoTempInner: tempCompareWrap.ecosystem.EcoSystem_Details__r){
              Boolean unique = true;
              for(EcoSystem_Detail__c ecoTemp: primaryCompare.EcoSystem_Details__r){ 
                if(ecoTemp.Ecosystem_Entity__c==ecoTempInner.Ecosystem_Entity__c){
                    unique=false;    
                }
              }
              if(unique)
                   tempCompareWrap.uniqueAccnts.add(ecoTempInner.Ecosystem_Entity__r);
            }
         }
         
        for(EcoSystem_Detail__c ecoDetTemp:primaryCompare.Ecosystem_Details__r){
            for(CompareWrapper tempCompareWrap: toBeReturned){
                boolean unique = true;
                for(EcoSystem_Detail__c ecoTempInner: tempCompareWrap.Ecosystem.Ecosystem_Details__r){
                    if(ecoTempInner.Ecosystem_Entity__r.id==ecoDetTemp.Ecosystem_Entity__r.id)
                        unique=false;
                } 
                if(unique){
                    tempCompareWrap.missingAccnts.add(ecoDetTemp.Ecosystem_Entity__r);
                    tempCompareWrap.ecoDetailAccountMap.put(ecoDetTemp.Ecosystem_Entity__r.id,ecoDetTemp.id);
                }
            }
        }            
                                
        selectedCompareWrapperList = toBeReturned;
    }



    
    public void removeAccountFromSelection(){
    try{
        System.debug('### toberemoved : '+tobeRemoved);
        delete new EcoSystem_Detail__c(id=tobeRemoved);
        allEcoSystems = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedDate,CreatedById, LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c, Ecosystem_Entity__r.Name,CreatedDate,Source__c,First_added__c,Similarity__c,CreatedBy.Name  From EcoSystem_Details__r) from EcoSystem__c where Company__c =: thisAccount.id ];
        for(EcoSystem__c ecoTemp:allEcoSystems){
            if(ecoTemp.id==selectedEcoSystem){
                accountsToShowInList = new List<EcoSystem_Detail__c>();
                accountIdsInThisDraft = new Set<id>();
                for(EcoSystem_Detail__c ecoDetailTemp: ecoTemp.EcoSystem_Details__r){
                    accountsToShowInList.add(ecoDetailTemp);
                    accountIdsInThisDraft.add(ecoDetailTemp.Ecosystem_Entity__c);
                }
                refreshData();
                if(searchString!=null && searchString.length()>0)
                     queryAccounts(); 

                
                break;
            }
            }
            
        if(firstCompareFlag==true){
          //   refreshData();
             repopulateData();
             populateCompareWrapper();
        }
    }
    catch(Exception e){
        System.debug('### '+e.getMessage());
       }
    }
       
    
    public void showPopup(){
        displayPopup = true;
    }
    public void closePopup(){
        displayPopup = false;
    }
       
    public void finalizeVersion(){
        Decimal count = 0;

        count = (Decimal)[select max(version__c)max from EcoSystem__c where Company__c =: thisAccount.id][0].get('max');
        if(count==null)count=0;
        
        List<EcoSystem__c> ecoList = new List<EcoSystem__c>();
        
        List<EcoSystem__c> oldMostRecent = [select id,Most_Recent__c from EcoSystem__c where Company__c =: thisAccount.id and Most_Recent__c=true];
        for(EcoSystem__c eco:oldMostRecent){
            if(eco.Most_Recent__c){
                eco.Most_Recent__c=false;
                ecoList.add(eco);
            }
        }
        
        ecoList.add(new EcoSystem__c(id=selectedEcoSystem, status__c='Final',Version__c=count+1,version_name__c=versionName,Most_Recent__c=true));
        
        update ecoList;
        allEcoSystems = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedDate,CreatedById, LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c, Ecosystem_Entity__r.Name,CreatedDate,Source__c,Similarity__c,First_Added__c,CreatedBy.Name  From EcoSystem_Details__r) from EcoSystem__c where Company__c =: thisAccount.id];        
        viewType='Final';
        hasDraft = false;
        draftEditMode=false;
        draftEcosystemId =null;
        selectedEcoSystem = null;
        accountsToShowInList.clear();
        displayPopup = false;
        versionName = null;
        fetchAccountsForThisEco();
        refreshVersionsList();
        refreshData();
    }
    
    public void queryAccounts(){
        if(searchString.length()>2){
        String searchParam = '%'+searchString+'%';
        searchAccountWrapperList = new List<searchAccountsWrapper>();
        otherAccountSearchList = [select id,name,Entity_ID__c,has_ecosystem__c,Ultimate_Parent__c from Account where name like :searchParam limit 100];
        for(Account acc:otherAccountSearchList){
            searchAccountWrapperList.add(new searchAccountsWrapper(acc,accountIdsInThisDraft.contains(acc.id),accountIdsInPreviousEcos.contains(acc.id),false ));
        }
        }
    }
     
    
            
    public List<SelectOption> getCompareWrapperListSelOptions(){
        List<SelectOption> toBeReturnedSelOptions = new List<SelectOption>();
        
        for(CompareWrapper compTemp:compareWrapperList){
            if(compTemp.ecoSystem.Version__c==null)
                toBeReturnedSelOptions.add(new SelectOption(''+compTemp.ecoSystem.id, 'Draft'));
            else toBeReturnedSelOptions.add(new SelectOption(''+compTemp.ecoSystem.id, 'Version '+compTemp.ecoSystem.version__c));
        }
        
        return toBeReturnedSelOptions;
    }
    
        
    public void loadMoreCoDefRecords(){        
    
      if(cdwPageInfo.pages>coDefPageNum){
            coDefPageNum=coDefPageNum + 1;
            coDefendantObj = FetchCoDefendants();
            refreshData();
      }
    }
    
    public void loadPrevCoDefRecords(){
       
      if(coDefPageNum>1){
            coDefPageNum=coDefPageNum - 1;
            coDefendantObj = FetchCoDefendants();
            refreshData();
      } 
       
    }
  
    public void deleteDraft(){
        try{
            delete new Ecosystem__c(id=deleteDraftId);
            allEcoSystems = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedDate,CreatedById, LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c, Ecosystem_Entity__r.Name,CreatedDate,Source__c,Similarity__c,CreatedBy.Name  From EcoSystem_Details__r) from EcoSystem__c where Company__c =: thisAccount.id ];
            accountsToShowInList.clear();
            refreshData();            
        }
        catch(Exception e){
        
        }
        refreshVersionsList();
        refreshData();
        
    }
    
    public List<RelatedCompanyWrapper.Response> FetchRelatedCompany(){
     
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string url = EcoSystemAPI__c.getValues('RelevantCompanies').Endpoint__c+'?id='+thisAccount.id;
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Token token="'+EcoSystemAPI__c.getValues('RelevantCompanies').Token__c+'"');
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        system.debug(res.getBody());
        
        RelatedCompanyWrapper rcw = new RelatedCompanyWrapper();
        try{
            rcw = RelatedCompanyWrapper.parse(res.getBody());
        }
        catch(Exception e){
        
        }
        if(rcw.response!=null)
            return rcw.response;
        else return null;    
    }
    
    public List<CoDefendantWrapper.Response> FetchCoDefendants(){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string url = EcoSystemAPI__c.getValues('CoDefendant').Endpoint__c+'?id='+thisAccount.id+'&page='+coDefPageNum;
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Token token="'+EcoSystemAPI__c.getValues('CoDefendant').Token__c+'"');
        req.setMethod('GET');
        req.setTimeout(120000);
        HttpResponse res = h.send(req);
        system.debug(res.getBody());        
        
        try{
            cdw =  (CoDefendantWrapper) System.JSON.deserialize(res.getBody(), CoDefendantWrapper.class); //CoDefendantWrapper.parse(res.getBody());
            cdwPageInfo = cdw.Pagination;
        }
        catch(Exception e){
            System.debug('Exception '+e);
        }
        if(cdw.response!=null)
            return cdw.response;
        else return null;
    }
    
    public List<SourceVerification.Response> CheckSource(Id relatedId){        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string url = EcoSystemAPI__c.getValues('VerifySource').Endpoint__c+'?id='+thisAccount.id+'&related_ids[]='+relatedId;
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Token token="'+EcoSystemAPI__c.getValues('VerifySource').Token__c+'"');
        req.setMethod('GET');
        req.setTimeout(120000);
        
        SourceVerification sv = new SourceVerification();
        
            HttpResponse res = h.send(req);
            system.debug(res.getBody());                    
        
            try{
                sv = (SourceVerification) System.JSON.deserialize(res.getBody(), SourceVerification.class);            
            }    
            catch(Exception e){
                System.debug('Exception '+e);
            }
        
        return sv.response;
    }
    
    public List<SourceVerification.Response> CheckSourceMultiple(String relatedIds){        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string url = EcoSystemAPI__c.getValues('VerifySource').Endpoint__c+'?id='+thisAccount.id+relatedIds;
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Token token="'+EcoSystemAPI__c.getValues('VerifySource').Token__c+'"');
        req.setMethod('GET');
        req.setTimeout(120000);
        
        SourceVerification sv = new SourceVerification();
        
            HttpResponse res = h.send(req);
            system.debug(res.getBody());                    
        
            try{
                sv = (SourceVerification) System.JSON.deserialize(res.getBody(), SourceVerification.class);            
            }    
            catch(Exception e){
                System.debug('Exception '+e);
            }
        
        return sv.response;
    }
    
    public void fetchEcosystemForTheAccount(){
        if(newClonedEcosystemFromOther.Company__c!=null)
        listOfOtherAccEcosystems = [select id,name,version__c,version_name__c, status__c,createdDate,CreatedById from Ecosystem__c where Company__c =:newClonedEcosystemFromOther.Company__c order by CreatedDate desc limit 2000];
    
    }
    
    public PageReference cloneEcosystemFromOtherAccount(){
        
        EcoSystem__c newEcosystem = new EcoSystem__c(Company__c=ThisAccount.id,status__c='Draft',version_name__c='Cloned');
        List<Ecosystem__c> draftEcos = [select id,name, version__c,version_name__c, status__c,LastModifiedDate,CreatedById,CreatedDate, LastModifiedBy.Name,(Select Id,Name,Ecosystem_Entity__c,First_Added__c, Ecosystem_Entity__r.Name,CreatedDate,Source__c,Similarity__c,CreatedBy.Name  From EcoSystem_Details__r) from EcoSystem__c where Company__c =: thisAccount.id and status__c='Draft'];                    
        List<EcoSystem_Detail__c> ecoDetList = [select id,Name,Ecosystem_Entity__c,EcoSystem__c,First_Added__c,Similarity__c,Source__c from EcoSystem_Detail__c where EcoSystem__c=:cloneId];
        
        String relatedIds='';
        
        for(EcoSystem_Detail__c ecoDetTemp:ecoDetList){
             relatedIds+='&related_ids[]='+ecoDetTemp.Ecosystem_Entity__c;
        }

        List<SourceVerification.Response> svResponse = CheckSourceMultiple(relatedIds);
        
        
        if(draftEcos.size()==0){
           insert newEcosystem;
           System.debug('### '+cloneId);
           List<EcoSystem_Detail__c> newList = new List<EcoSystem_Detail__c>();                                 
           
           for(EcoSystem_Detail__c ecoDetTemp:ecoDetList){
               String unique = newEcosystem.id+'-'+ecoDetTemp.Ecosystem_Entity__c;                                
               EcoSystem_Detail__c ecoTemp = new EcoSystem_Detail__c(Ecosystem_Entity__c=ecoDetTemp.Ecosystem_Entity__c,EcoSystem__c=newEcosystem.id,Unique_Check__c=unique);
               
               for(SourceVerification.Response resp:svResponse){
                   if(resp.related_id == ecoTemp.Ecosystem_Entity__c){
                       ecoTemp.Similarity__c = resp.percentage;
                       ecoTemp.Source__c = resp.account_type;
                       //break;
                   }
               }
               for(EcoSystem__c ecoTmp:allEcoSystems){
                    for(EcoSystem_Detail__c ecoDet:ecoTmp.EcoSystem_Details__r){
                        if(ecoDet.Ecosystem_Entity__c == ecoTemp.Ecosystem_Entity__c && (ecoTemp.First_Added__c == null || ecoTemp.First_Added__c > ecoDet.createdDate)){
                            ecoTemp.First_Added__c = ecoDet.CreatedDate;
                    }
                }
        
                }
        
               if(ecoTemp.First_Added__c==null) ecoTemp.First_Added__c=System.now();
               
               
               newList.add(ecoTemp);
               System.debug('### inside : '+ecoTemp );
           }
           
           insert newList;
        }
        
        refreshData();
        PageReference pg = new PageReference('/apex/EcoSystemPage?id='+thisAccount.id);
        pg.setredirect(true);
        return pg;
        
        
        
        
    }
    
}