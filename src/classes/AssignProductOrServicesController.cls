/****************************************************************************************************************************
 * Name             : AssignProductOrServicesController 
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 18 Jan, 2012.
 * Purpose          : Assign ProductOrServices with Account or Portfolio. 
 *                    T-22105 
 *                                      This page is used to tag Account, Patent or Patent Family with Patent 
 ***************************************************************************************************************************/
public without sharing class AssignProductOrServicesController {

  private String relatedRecordId = '';
  public String LABEL_RELATED_OBJECT_NAME = 'RelatedObjectName';
  public String LABEL_RELATED_RECORD_ID = 'RelatedRecordId';
  public String INFO_SELECT_ANY_PRODUCT = Label.Atleast_One_Product_Required;
  
  public String relatedObjectName{get;set;}
  public List<ProductWrapper> lstProdWrapper{get;set;}  
  public String selectedView{get;set;}
  public String srchProduct{get;set;}
  public String recordName{get;set;}
  public Boolean isAccount{get;set;}
  public Boolean isPortfolio{get;set;}
  public Boolean isPatent {get;set;}
  
  //properties
  private String prodOrServSrchTxt{
    get{
      if(srchProduct == null || srchProduct == '') {
        return null;
      } else {
        return '%' + srchProduct +'%';
      }
    }
    set;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
    //Wrapper Class for Resultset
  //-------------------------------------------------------------------------------------------------------------------------
  public Class ProductWrapper {
    public Boolean isSelected{get;set;}
    public Boolean isDisabled{get;set;}
    public Product_or_Service__c ProductOrService{get;set;}
    public portfolio2product__c portfolio2Prod{get;set;}
    public account2product__c acct2Prod{get;set;}

    //Constructor
    public ProductWrapper(Product_or_Service__c prodOrServ,account2product__c acc2Prod,portfolio2product__c pf2Prod, Boolean isDisabled) {
      this.isSelected = this.isDisabled = isDisabled;
      ProductOrService = prodOrServ;
      if (acc2Prod != null) {
        this.acct2Prod = acc2Prod;
      }else {
        acct2Prod = new account2product__c();
      }
      
      if (pf2Prod != null) {
        this.portfolio2Prod = pf2Prod;
      } else {
        portfolio2Prod = new portfolio2product__c();
      }
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
    //Constructor
  //-------------------------------------------------------------------------------------------------------------------------
  public AssignProductOrServicesController() {
    srchProduct = '';
    isAccount = false;
    isPortfolio = false;
    isPatent = false;
    selectedView = '';
    
    //Get object Name and record Id based on page parameters. 
    //page parameters specify the page is accessed from.
    //for ex : if page is accessed from account then RelatedObjectName parameter will be Account and related record id 
    //will contain id of Account.  
    Map<String,String> pageParams = ApexPages.currentPage().getParameters();
    if (pageParams.containsKey(LABEL_RELATED_OBJECT_NAME) && pageParams.containsKey(LABEL_RELATED_RECORD_ID)) {
      relatedObjectName = pageParams.get(LABEL_RELATED_OBJECT_NAME);
      relatedRecordId = pageParams.get(LABEL_RELATED_RECORD_ID);
      
      if(relatedObjectName.trim().equalsIgnoreCase('Account') ) {
        isAccount = true;
        recordName = [Select Name From Account Where id = : relatedRecordId][0].Name;
      } else if(relatedObjectName.trim().equalsIgnoreCase('PatentFamily') ) {
        isPortfolio = true;
        recordName = [Select Name From Assets__c Where id = : relatedRecordId][0].Name;
      } else if(relatedObjectName.trim().equalsIgnoreCase('Patent') ) {
        isPatent = true;
        recordName = [Select Name From Patent__c Where id = : relatedRecordId][0].Name;
      }
    }
    searchProdOrServ();
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Searches Product or Services Records.
  //-------------------------------------------------------------------------------------------------------------------------
  public Pagereference searchProdOrServ() {
    Set<Id> existingProdServIds = new Set<Id>();
    Map<Id, account2product__c> prodIdAndaccToProdMap = new Map<Id, account2product__c>();
    Map<Id, portfolio2product__c> prodIdAndPF2ProdMap = new Map<Id, portfolio2product__c>();
    
    //fetch products already tagged with selected Account if page is accessed from Account.
    if(isAccount) {
      for (account2product__c acct2Prod : [Select product_Or_Service__c , RelevantProducts__c, Tier__c
                                           From account2product__c 
                                           Where Account__c = :relatedRecordId]) {
        existingProdServIds.add(acct2Prod.product_Or_Service__c);
        prodIdAndaccToProdMap.put(acct2Prod.product_Or_Service__c, acct2Prod);
      }
    }
    //fetch products already tagged with Patent Family if page is accessed from Patent Family.
    else if(isPortfolio) {
      for (portfolio2product__c PF2Prod : [Select product_Or_Service__c , TheoriesOfRelevance__c, Freeform_Tags__c, Tier__c 
                                           From portfolio2product__c 
                                           Where portfolio__c = :relatedRecordId and Patent__c='']) {
        existingProdServIds.add(PF2Prod.product_Or_Service__c);
        prodIdAndPF2ProdMap.put(PF2Prod.product_Or_Service__c, PF2Prod);
      }
    } 
    //fetch products already tagged with Patent if page is accessed from Patent.
    else if(isPatent) {
      for (portfolio2product__c PF2Prod : [Select product_Or_Service__c , TheoriesOfRelevance__c, Freeform_Tags__c, Tier__c
                                           From portfolio2product__c 
                                           Where Patent__c = :relatedRecordId]) {
        existingProdServIds.add(PF2Prod.product_Or_Service__c);
        prodIdAndPF2ProdMap.put(PF2Prod.product_Or_Service__c, PF2Prod);
      }
    }   
    
    //prepare wrapper list for resultset.
    lstProdWrapper = getProductList(existingProdServIds, prodIdAndaccToProdMap, prodIdAndPF2ProdMap);
    
    //if no product found then display message that no Product Found
    if (lstProdWrapper.size() == 0 ) {
        ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.INFO, Label.No_Product_Found)); 
    }
    return null;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
    //Create Mapping Records Based on RelatedObjectName
  //-------------------------------------------------------------------------------------------------------------------------
  public PageReference createMappingRecords() {
    //get Selected products
    List<ProductWrapper> selectedProducts = getSelectedProducts(lstProdWrapper);
    
    //if no product is selected display error message 
    if(selectedProducts.size() == 0) {
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.Severity.INFO,INFO_SELECT_ANY_PRODUCT));
      return null;
    }
    
    try{
      //if Page is accessed from Account create account to product mapping records
      if(relatedObjectName.trim().equalsIgnoreCase('Account') ) {
        createAccountToProdMappingRecords(relatedRecordId, selectedProducts);
      } 
      //if Page is accessed from Patent Family create patent family to product mapping records with patent family field populated.
      else if(relatedObjectName.trim().equalsIgnoreCase('PatentFamily')) {
        createPatentFamilyToProdMappingReocrds(relatedRecordId, selectedProducts);
      } 
      //if Page is accessed from Patent create patent family to product mapping records with patent field populated.
      else if(relatedObjectName.trim().equalsIgnoreCase('Patent')) {
        createPatentToProdMappingReocrds(relatedRecordId, selectedProducts);
      }
      
      //return back to Account or patent or patent family.
      PageReference pg = new PageReference(ApexPages.CurrentPage().getUrl());
      pg.setRedirect(true);
      return pg;
    } catch(Exception ex) {
      ApexPages.addMessages(ex);
      return null;
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns list of available Options for picklist 
  //-------------------------------------------------------------------------------------------------------------------------
  public List<SelectOption> getFilterPicklist() {
    List<SelectOption> filterPickList = new List<SelectOption>();
    SelectOption sOption;
    
    sOption = new SelectOption('', 'All');
    filterPickList.add(sOption); 
    for(Product_Search_Filters__c prodFilter : [Select name, Search_String__c from Product_Search_Filters__c Order by Name asc]) {
        sOption = new SelectOption(prodFilter.Search_String__c, prodFilter.Name);
        filterPickList.add(sOption);
    }
    return filterPickList;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns user back to Account, Patent Or Patent Family
  //-------------------------------------------------------------------------------------------------------------------------
  public pageReference back() {
    if(relatedRecordId != null) {
      PageReference pg = new PageReference('/' + relatedRecordId);
      pg.setRedirect(true);
      return pg;
    }
    return null; 
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns List of Products for resultset
  //-------------------------------------------------------------------------------------------------------------------------
  private List<ProductWrapper> getProductList(Set<Id> existingProdServIds,Map<Id, account2product__c> prodIdAndaccToProdMap,Map<Id, portfolio2product__c> prodIdAndPF2ProdMap) {
    List<ProductWrapper> lstProdWrapper = new List<ProductWrapper>();
    
    //prepare query based on object
    String prodQry = prepareQuery();
    
    for(Product_or_Service__c prodOrServ : (List<Product_or_Service__c>)Database.query(prodQry)) {
      if(existingProdServIds.contains(prodOrServ.Id)) {
        lstProdWrapper.add(new ProductWrapper(prodOrServ,prodIdAndaccToProdMap.get(prodOrServ.Id), prodIdAndPF2ProdMap.get(prodOrServ.Id), true));
      } else {
        lstProdWrapper.add(new ProductWrapper(prodOrServ,prodIdAndaccToProdMap.get(prodOrServ.Id), prodIdAndPF2ProdMap.get(prodOrServ.Id), false));
      }
    }
    return lstProdWrapper;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns Query in String format with all filters
  //-------------------------------------------------------------------------------------------------------------------------
  private String prepareQuery() {
    String condition = '';
    //if any filter view is selected from picklist  
    if(selectedView != null && selectedView != '') {
      for(String searchStr : selectedView.split(',')) {
        if(searchStr.trim() != '') {
            
            //handle underscore in search string
            if(searchStr == '_') {
                searchStr = '\\_';
            }
            
            //handle % in search string
            if(searchStr == '%') {
                searchStr = '\\%';
            }
            
            searchStr = '%' + searchStr.trim() + '%';
            if(condition.contains(' Where ')) {
                condition += ' Or ';
            } else {
                condition += ' Where ';
            }
            condition += ' Name like \''+ searchStr + '\''; 
        }
      }
    }
    
    //for custom Text Search
    if(prodOrServSrchTxt != null && prodOrServSrchTxt.trim() != '') {
        if(!condition.contains(' Where ')) {
          condition += ' Where ';
        } else {
          condition += ' and ';
        }
        condition += ' Name like :prodOrServSrchTxt';
    }
    String prodQry = 'Select Name ,Id ' 
                   + 'From Product_or_Service__c ' 
                   +  condition
                   + ' Order by Name asc';
    return prodQry;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Creates Account To product mapping records for given account and products
  //-------------------------------------------------------------------------------------------------------------------------
  private void createAccountToProdMappingRecords(Id accountId, List<ProductWrapper> selectedProducts) {
    List<account2product__c> lstComp2prodMapRecsToInsert = new List<account2product__c>(); 
    for (ProductWrapper pWrap : selectedProducts) {
      account2product__c acc2Prod = new account2product__c();
      acc2Prod.Account__c = accountId;
      acc2Prod.Product_or_Service__c = pWrap.ProductOrService.Id; 
      acc2Prod.RelevantProducts__c = pWrap.acct2Prod.RelevantProducts__c ;
      acc2Prod.Tier__c = pWrap.acct2Prod.Tier__c ;
      lstComp2prodMapRecsToInsert.add(acc2Prod);
    }
    if(lstComp2prodMapRecsToInsert.size() > 0) {
          insert lstComp2prodMapRecsToInsert;
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Creates Patent To product mapping records for given account and products
  //-------------------------------------------------------------------------------------------------------------------------
  private void createPatentToProdMappingReocrds(Id patentId, List<ProductWrapper> selectedProducts) {
    List<portfolio2product__c> lstPF2ProdMapRecsToInsert = new List<portfolio2product__c>(); 
      for (ProductWrapper pWrap : selectedProducts) {
        portfolio2product__c portFolio2Prod = pWrap.portfolio2Prod;
      portFolio2Prod.Mapping_Type__c = 'Patent';
      portFolio2Prod.Patent__c = patentId;
        portFolio2Prod.Product_or_Service__c = pWrap.ProductOrService.Id;
        lstPF2ProdMapRecsToInsert.add(portFolio2Prod);
      }
      if(lstPF2ProdMapRecsToInsert.size() > 0) {
        insert lstPF2ProdMapRecsToInsert;
      } 
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Creates Patent Family To product mapping records for given account and products
  //-------------------------------------------------------------------------------------------------------------------------
  private void createPatentFamilyToProdMappingReocrds(Id PatentFamilyId, List<ProductWrapper> selectedProducts) {
    List<portfolio2product__c> lstPF2ProdMapRecsToInsert = new List<portfolio2product__c>(); 
    for (ProductWrapper pWrap : selectedProducts) {
        portfolio2product__c portFolio2Prod = pWrap.portfolio2Prod;
          portFolio2Prod.Mapping_Type__c = 'Patent Family';
          portFolio2Prod.Portfolio__c = PatentFamilyId;
        portFolio2Prod.Product_or_Service__c = pWrap.ProductOrService.Id;
        lstPF2ProdMapRecsToInsert.add(portFolio2Prod);
    }
      if(lstPF2ProdMapRecsToInsert.size() > 0) {
        insert lstPF2ProdMapRecsToInsert;
      } 
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Returns list of Selected Products
  //-------------------------------------------------------------------------------------------------------------------------
  private List<ProductWrapper> getSelectedProducts(List<ProductWrapper> lstProdWrapper) {
    List<ProductWrapper> lstSelectedProdWraps = new List<ProductWrapper>(); 
    for (ProductWrapper pWrap : lstProdWrapper) {
      if(pWrap.isSelected && (!pWrap.isDisabled)) {
        lstSelectedProdWraps.add(pWrap);
      }
    }
    return lstSelectedProdWraps;
  }
  
}