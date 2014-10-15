public with sharing class AssignMarketSectorDetailController {
	private Id acctId;
	private Map<String, String> pageParams;
  public List<MarketSectorDetailWrapper> lstMarketSectorDetailWrapper{get;set;}
  public String prodOrServSrchTxt{get;set;}
  public Account account{get;set;}
  
  //------------------------------------------------------------------------------------------------------------------------------------
  //Wrapper Class
  //------------------------------------------------------------------------------------------------------------------------------------
  public Class MarketSectorDetailWrapper {
  	public String defaultStatus{get;set;}
  	public Boolean isSelected{get;set;}
    public Boolean isDisabled{get;set;}
    public Market_Sector_Detail__c marketSectorDetail{get;set;}
    public Account_Market_Sector_Detail__c accMarketSecDetail{get;set;}
    
    //------------------------------------------------------------------------------------------------------------------------------------
    //Constructor
    //------------------------------------------------------------------------------------------------------------------------------------
    public MarketSectorDetailWrapper(Market_Sector_Detail__c msd, Account_Market_Sector_Detail__c accMarketSecDetail, Boolean isDisabled) {
    	this.marketSectorDetail = msd;
    	this.accMarketSecDetail = accMarketSecDetail;
    	this.isSelected = isDisabled;
    	this.isDisabled = isDisabled;
    	
    	if(defaultStatus == null) {
	    	Schema.DescribeFieldResult F = Account_Market_Sector_Detail__c.Status__c.getDescribe();
	      List<Schema.PicklistEntry> P = F.getPicklistValues();
	      for(Schema.PicklistEntry pEntry : P) {
	        if(pEntry.isDefaultValue()) {
	          defaultStatus = pEntry.getValue();
	        }
	      }
    	}
    	if(this.accMarketSecDetail == null) {
    		this.accMarketSecDetail = new Account_Market_Sector_Detail__c();
    	  this.accMarketSecDetail.Status__c = defaultStatus;
    	}
    }
  }
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  public AssignMarketSectorDetailController() {
  	pageParams = Apexpages.currentPage().getParameters();
  	if(pageParams.containsKey('accountId')) {
  		acctId = pageParams.get('accountId');
  		account = [Select id, Name From Account Where id = :acctId];
  	}
  	prodOrServSrchTxt = '';
  	searchMarketSectorDetail();
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------
  //Search
  //------------------------------------------------------------------------------------------------------------------------------------
  public void searchMarketSectorDetail() {
  	Set<Id> existingMarketSectorDetails = new Set<Id>();
  	Map<Id, Account_Market_Sector_Detail__c> msdAndamsdMap = new Map<Id, Account_Market_Sector_Detail__c>();  
  	
  	for (Account_Market_Sector_Detail__c amsd : 
        [Select Account__c , Market_Sector_Detail__c, Status__c, Revenue__c,Products__c, CD_Priority__c
         From Account_Market_Sector_Detail__c 
         Where Account__c = :acctId]) {
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
  //Creates Account Market Sector Detail Records and redirect user back to Account
  //------------------------------------------------------------------------------------------------------------------------------------
  public pageReference createAccountMarketSectorDetail() {
  	List<Account_Market_Sector_Detail__c> lstAccMarketSecDetail = new List<Account_Market_Sector_Detail__c>();  
  	for (MarketSectorDetailWrapper msdw : lstMarketSectorDetailWrapper) {
  		if( msdw.isSelected && !msdw.isDisabled) {
  			Account_Market_Sector_Detail__c amsd = msdw.accMarketSecDetail;
  			amsd.Account__c = account.Id;
  			amsd.Market_Sector_Detail__c = msdw.marketSectorDetail.Id;
  			lstAccMarketSecDetail.add(amsd);
  		}
  	}
  	
  	if(lstAccMarketSecDetail.size() == 0) {
  		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.No_Record_Selected));
  		return null;
  	}
  	insert lstAccMarketSecDetail;
  	PageReference pg = new PageReference('/' + acctId);
  	return pg;
  }
  
  //------------------------------------------------------------------------------------------------------------------------------------
  //Returns user back to Account
  //------------------------------------------------------------------------------------------------------------------------------------
  public pageReference back() {
  	PageReference pg = new PageReference('/' + acctId);
    return pg;
  }
  
  static testMethod void myUnitTest() {
      Account acc = TestUtil.createAccount(true);
      
      Market_Sector_Detail__c marketSectorDetail = new Market_Sector_Detail__c();
      marketSectorDetail.Description__c = 'Test';
      insert marketSectorDetail;
      
      Account_Market_Sector_Detail__c accMarketSectorDetail = new Account_Market_Sector_Detail__c();
      accMarketSectorDetail.Account__c = acc.Id;
      accMarketSectorDetail.Market_Sector_Detail__c = marketSectorDetail.Id;
      accMarketSectorDetail.Status__c = 'Future';
      accMarketSectorDetail.Revenue__c = 100;
      accMarketSectorDetail.Products__c = 'Test';
      insert accMarketSectorDetail;
        
        Test.startTest();
         Test.setCurrentPage(Page.AssignMarketSectorDetail);
         Apexpages.currentPage().getParameters().put('accountId',acc.Id);
         AssignMarketSectorDetailController ctrl = new AssignMarketSectorDetailController(); 
         ctrl.createAccountMarketSectorDetail();
         ctrl.back();
        Test.stopTest();
    }
  
}