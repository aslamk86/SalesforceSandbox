public with sharing class AssignAcqMarketSectorDetailController {
   private Id acqId;
   private Map<String, String> pageParams;
  public List<MarketSectorDetailWrapper> lstMarketSectorDetailWrapper{get;set;}
  public String prodOrServSrchTxt{get;set;}
  public Acquisition_Opportunity__c acquisition{get;set;}
  
  //------------------------------------------------------------------------------------------------------------------------------------
  //Wrapper Class
  //------------------------------------------------------------------------------------------------------------------------------------
  public Class MarketSectorDetailWrapper {
   public Boolean isSelected{get;set;}
    public Boolean isDisabled{get;set;}
    public Market_Sector_Detail__c marketSectorDetail{get;set;}
    public Acquisition_Market_Sector_Detail__c acqMarketSecDetail{get;set;}
    
    //------------------------------------------------------------------------------------------------------------------------------------
    //Constructor
    //------------------------------------------------------------------------------------------------------------------------------------
    public MarketSectorDetailWrapper(Market_Sector_Detail__c msd, Acquisition_Market_Sector_Detail__c acqMarketSecDetail, Boolean isDisabled) {
      this.marketSectorDetail = msd;
      this.acqMarketSecDetail = acqMarketSecDetail;
      this.isSelected = isDisabled;
      this.isDisabled = isDisabled;
      
      if(this.acqMarketSecDetail == null) {
         this.acqMarketSecDetail = new Acquisition_Market_Sector_Detail__c();
      }
    }
  }
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  public AssignAcqMarketSectorDetailController(ApexPages.StandardController stdController) {
     //this.acquisition = (Acquisition_Opportunity__c)stdController.getRecord();
     pageParams = Apexpages.currentPage().getParameters();
     for(String param : pageParams.keySet())
     {
         if(param.contains('_lkid')) {
	        acqId = pageParams.get(param);
	        acquisition = [Select id, Name From Acquisition_Opportunity__c Where id = :acqId];
	      }
     }
     prodOrServSrchTxt = '';
     searchMarketSectorDetail();
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------
  //Search
  //------------------------------------------------------------------------------------------------------------------------------------
  public void searchMarketSectorDetail() {
   Set<Id> existingMarketSectorDetails = new Set<Id>();
   Map<Id, Acquisition_Market_Sector_Detail__c> msdAndamsdMap = new Map<Id, Acquisition_Market_Sector_Detail__c>();  
   
   for (Acquisition_Market_Sector_Detail__c amsd : 
        [Select Acquisition__c , Market_Sector_Detail__c, CD_Priority__c, Notes__c
         From Acquisition_Market_Sector_Detail__c 
         Where Acquisition__c = :acqId]) {
      existingMarketSectorDetails.add(amsd.Market_Sector_Detail__c);
      msdAndamsdMap.put(amsd.Market_Sector_Detail__c, amsd);
    }
    
    lstMarketSectorDetailWrapper = new List<MarketSectorDetailWrapper>();
    lstMarketSectorDetailWrapper.clear();
    String searchStr = prodOrServSrchTxt; 
    
    String query = ' Select Id, Name ' 
                 + ' From Market_Sector_Detail__c';
    
    if(searchStr != null || searchStr != '') {
      searchStr = '%' + searchStr + '%';
      query += ' Where Name like :searchStr';
    }
    query += ' Order by Name';
    
    for(Market_Sector_Detail__c msd : (List<Market_Sector_Detail__c>)Database.query(query)) {
      if(existingMarketSectorDetails.contains(msd.Id)) {
        lstMarketSectorDetailWrapper.add(new MarketSectorDetailWrapper(msd, msdAndamsdMap.get(msd.Id), true));
      } else {
        lstMarketSectorDetailWrapper.add(new MarketSectorDetailWrapper(msd, msdAndamsdMap.get(msd.Id), false));
      }
    }
    
    if(lstMarketSectorDetailWrapper.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Found));
    } 
    
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------
  //Creates Acquisition Market Sector Detail Records and redirect user back to Acquisition
  //------------------------------------------------------------------------------------------------------------------------------------
  public pageReference createAcqMarketSectorDetail() {
   List<Acquisition_Market_Sector_Detail__c> lstacqMarketSecDetail = new List<Acquisition_Market_Sector_Detail__c>();  
   for (MarketSectorDetailWrapper msdw : lstMarketSectorDetailWrapper) {
      if( msdw.isSelected && !msdw.isDisabled) {
         Acquisition_Market_Sector_Detail__c amsd = msdw.acqMarketSecDetail;
         amsd.Acquisition__c = acquisition.Id;
         amsd.Market_Sector_Detail__c = msdw.marketSectorDetail.Id;
         lstacqMarketSecDetail.add(amsd);
      }
   }
   
   if(lstacqMarketSecDetail.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Selected));
      return null;
   }
   insert lstacqMarketSecDetail;
   PageReference pg = new PageReference('/' + acqId);
   return pg;
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------
  //Returns user back to Acquisition
  //------------------------------------------------------------------------------------------------------------------------------------
  public pageReference back() {
   PageReference pg = new PageReference('/' + acqId);
    return pg;
  }
  
  static testMethod void testControllerExt() {
      Account acc = TestUtil.createAccount(true);
      Acquisition_Opportunity__c acq = TestUtil.createAcquisitionOpp(acc.Id, 'Preliminary Discussion', 'Test Acq', true);
      
      Market_Sector_Detail__c marketSectorDetail = new Market_Sector_Detail__c();
      marketSectorDetail.Description__c = 'Test';
      insert marketSectorDetail;
      
      Acquisition_Market_Sector_Detail__c acqMarketSectorDetail = new Acquisition_Market_Sector_Detail__c();
      acqMarketSectorDetail.Acquisition__c = acq.Id;
      acqMarketSectorDetail.Market_Sector_Detail__c = marketSectorDetail.Id;
      acqMarketSectorDetail.Notes__c = 'Future';
      acqMarketSectorDetail.CD_Priority__c = 'abc';
      insert acqMarketSectorDetail;
        
        Test.startTest();
         Test.setCurrentPage(Page.AssignMarketSectorDetail);
         Apexpages.currentPage().getParameters().put('_lkid',acq.Id);
         ApexPages.StandardController sc = new ApexPages.standardController(acqMarketSectorDetail);
         AssignAcqMarketSectorDetailController ctrl = new AssignAcqMarketSectorDetailController(sc);
         ctrl.createAcqMarketSectorDetail();
         ctrl.back();
        Test.stopTest();
    }
  
}