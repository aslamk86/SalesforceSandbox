/*****************************************************************************
 * Name             : TestBatchPortfolioChatterFeed
 * Created By       : Neeraj G.(Appirio Offshore)
 * Modified By      : Martin Sieler - Sept 28, 2012
 * Created Date     : 12 Jan, 2012.
 * Purpose          : Utility Class for test classes
 *                    T-21599
*****************************************************************************/
@isTest
public without sharing class TestUtil {

  //-------------------------------------------------------------------------------------------------------------------------
  // getAccountRecType
  //-------------------------------------------------------------------------------------------------------------------------
  private static RecordType getAccountRecType(boolean bMember)
    {
    String strType = bMember ? 'Member' : 'Prospect';
     for (RecordType rType : [Select id 
                             From RecordType
                             Where SObjectType = 'Account'
                             And Name = :strType
                             Limit 1])
      {
      return rType;
      }

//    system.assert(false, 'No Record Type Found!');
    return null;
    }

  //------------------------------------------------
  //Returns a record of Account
  //------------------------------------------------
  public static Account createAccount(Boolean isInsert) {
    Account acct = new Account();
    acct.Name = 'Test Account';
    acct.Rate_Comments__c = 'test';
    acct.Rate_Comments_Manual__c = 'test';
    acct.Applicable_Segment_Revenue_Manual__c = 100;
    acct.Fiscal_Year_Close_Manual__c = Date.today();
    acct.Operating_Income_Y1_Manual__c = 10;
    acct.Operating_Income_Y2_Manual__c = 20;
    acct.Operating_Income_Y3_Manual__c = 30;
    acct.Rate_Comments_Manual__c ='Test Comment';
    acct.Rate_Last_Updated_By_Manual__c = 'Test Manual Update';
    acct.Rate_Last_Updated_Manual__c = Date.today();
    acct.Revenue_Current_Year_Manual__c = 40; 
    acct.Entity_ID__c = 500000 + Math.Rint(Math.random()*250000);
    acct.Ultimate_Parent_Entity_ID__c = acct.Entity_ID__c;
    acct.RecordTypeId = getAccountRecType(false).Id;
    
    if (isInsert) {
     insert acct;
    }
    return acct;
  }
  
  public static Acquisition_Patent_Families__c createAcqOppFamily(Id acqOppId, Id patentFamilyId, Boolean isInsert) {
    Acquisition_Patent_Families__c acqPatFamily = new Acquisition_Patent_Families__c();
    acqPatFamily.Acquisition_Opportunity__c = acqOppId;
    acqPatFamily.Patent_Family__c = patentFamilyId;
    if (isInsert) {
     insert acqPatFamily;
    }
    return acqPatFamily;
  }
  
  //------------------------------------------------
  //Returns a record of portfolio
  //------------------------------------------------
  public static Assets__c createPortfolio(Boolean isInsert) {
    Assets__c portfolio = new Assets__c();
      portfolio.Name = 'Test Portfolio';
      if (isInsert) {
        insert portfolio;
      }
      return portfolio;
  }
  
  //------------------------------------------------
  //Returns a record of Patent__c
  //------------------------------------------------
  public static Patent__c createPatent(Boolean isInsert) {
      Patent__c patent = new Patent__c();
      patent.Name = 'Test patent';
      patent.Core_DB_Patent_ID__c = Math.Random() + 459;
      patent.Patent_No__c = String.valueOf(Math.random());
      patent.Assignment_Note__c = 'xyz';
      if (isInsert) {
       insert patent;
      }
      return patent;
    }
    
    public static Patent__c createPatent(Id pfId, Boolean isInsert) {
    Patent__c patent = new Patent__c();
    patent.Name = 'Test patent';
    patent.Patent_Family__c = pfId;
    patent.Core_DB_Patent_ID__c = Math.Random() + 459;
    patent.Assignment_Note__c = 'xyz';
    patent.Patent_No__c = String.valueOf(Math.random());
    if (isInsert) {
     insert patent;
    }
    return patent;
  }
    
    public static Litigation__c createLitigation(Boolean isInsert) { 
    Litigation__c litigation = new Litigation__c(); 
    litigation.Name = 'Test';
    litigation.Case_Name__c = 'CN-001';
    if (isInsert) {
     insert litigation;
    }
    return litigation;
    }
    
    public static Patents_in_Suit__c createPatentInSuit(Id patentId, Id litigationId, Boolean isInsert) { 
    Patents_in_Suit__c patentInSuit = new Patents_in_Suit__c(); 
    patentInSuit.Patent__c = patentId;
    patentInSuit.Litigation__c = litigationId;
    if (isInsert) {
     insert patentInSuit;
    }
    return patentInSuit;
  }
  
  public static Opportunity_Litigation__c createOpportunityLitigation(Id acqOppId, Id litigationId, Boolean isInsert) { 
    Opportunity_Litigation__c oli = new Opportunity_Litigation__c(); 
    oli.Litigation__c = litigationId;
    oli.Acquisition_Opportunity__c = acqOppId;
    if (isInsert) {
     insert oli;
    }
    return oli;
  }

    //------------------------------------------------
  //Returns a record of Patent__History
  //------------------------------------------------
    public static Patent__History createParentHistory(Id patentId, 
    String Field, Boolean isInsert) {
         
      Patent__History pHistory = 
      new Patent__History(ParentId = patentId, Field = Field);
      
    if (isInsert) {
      insert pHistory;
    }
    return pHistory;
    }
    
  //------------------------------------------------
  //Returns a record of Opportunity
  //------------------------------------------------
  public static Opportunity createOpportunity(Id accId,String stageName, 
    Boolean isInsert) {
        
    Opportunity opp = new Opportunity();
    opp.Name = 'Test opp';
    opp.AccountId = accId;
    opp.StageName = stageName;
    opp.CloseDate = Date.today();
    opp.ContractEffectiveDate__c = Date.today();
    if (isInsert) {
      insert opp;       
    }
    return opp;
  }
  
  //------------------------------------------------
  //Returns a record of Product_or_Service__c
  //------------------------------------------------
  public static Product_or_Service__c createProductOrServices(String name, 
    Boolean isInsert) {
        
    Product_or_Service__c ps = new Product_or_Service__c();
    ps.Name = name;
    
    if (isInsert) {
        insert ps;
    }
    return ps;
  }
  
  //------------------------------------------------
  //Returns a record of Company2ProductMapping 
  //------------------------------------------------
  public static account2product__c createCompanyToProductRecord(Id accId, 
    Id prodServId, Boolean isInsert) {
        
    account2product__c acc2Prod = new account2product__c();
      acc2Prod.Account__c = accId;
      acc2Prod.Product_or_Service__c = prodServId; 
      if (isInsert) {
        insert acc2Prod;
      }
      return acc2Prod;
  }
  
  //------------------------------------------------
  //Returns a record of Company2ProductMapping 
  //------------------------------------------------
  public static portfolio2product__c createPortFolioToProductRecord(Id PFId, 
    Id prodServId, Id acqOppId, Boolean isInsert) {
      
    portfolio2product__c PF2Prod = new portfolio2product__c();
    PF2Prod.Portfolio__c = PFId;
    //PF2Prod.Acquisition_Opportunity__c = acqOppId;
    PF2Prod.Product_or_Service__c = prodServId; 
    if (isInsert) {
      insert PF2Prod;
    }
    return PF2Prod;
  }

  //------------------------------------------------
  //Returns a record of Company2ProductMapping 
  //------------------------------------------------
  public static portfolio2product__c createPatentToProductRecord(Id PatentId, 
    Id prodServId, Id acqOppId, Boolean isInsert) {
      
    portfolio2product__c PF2Prod = new portfolio2product__c();
    PF2Prod.Patent__c = PatentId;
    //PF2Prod.Acquisition_Opportunity__c = acqOppId;
    PF2Prod.Product_or_Service__c = prodServId;
    //Remove below line once we get Opportunity field removed from object. 
    PF2Prod.Opportunity__c = createOpportunity(createAccount(true).Id, 'Phase 0', true).Id; 
    if (isInsert) {
      insert PF2Prod;
    }
    return PF2Prod;
  }
  
  //------------------------------------------------
  //Returns a record of Acquisition Opportunity.
  //------------------------------------------------
  private static Integer autoNumber = 1;
  public static Acquisition_Opportunity__c createAcquisitionOpp(
    Id accId, String stageName, String name, Boolean isInsert) {
        
    Acquisition_Opportunity__c acqOpp = new Acquisition_Opportunity__c();
    acqOpp.Account__c = accId; 
    acqOpp.StageName__c = stageName;
    acqOpp.Name = name;
    acqOpp.Probability__c = '25';
    acqOpp.CloseDate__c = Date.today();
    acqOpp.Purchase_Date__c = Date.today();
    acqOpp.ContractEffectiveDate__c = Date.today();
    acqOpp.Amount_for_Pipeline__c = 50;
    acqOpp.LegacyOpportunityID__c = String.valueOf(autoNumber++);
    
    if (isInsert) {
        insert acqOpp;
    }
    return acqOpp;
  }
  
  //------------------------------------------------
  //Returns a record of Barker Model.
  //------------------------------------------------
  public static BarkerModel__c createBarkerModel(Id acqOppId,Boolean isInsert){
        BarkerModel__c barkerModel = new BarkerModel__c();
        barkerModel.AcquisitionOpportunity__c = acqOppId;
        if(isInsert)
            insert barkerModel;
        return barkerModel;
   }
   
  //------------------------------------------------
  //Returns a record of Barker Model Calculation.
  //------------------------------------------------
    public static BarkerModelCalculation__c createBarkerModelCalculation(Id accountId,Id barkerModelId,Boolean isInsert){
        BarkerModelCalculation__c barkerModelCalculation = new BarkerModelCalculation__c();
        barkerModelCalculation.Account__c = accountId; 
        barkerModelCalculation.BarkerModel__c = barkerModelId;
        barkerModelCalculation.Probability_Weighting__c = '50';
        barkerModelCalculation.Potential_Avoided_Cost__c = 1000;
        barkerModelCalculation.Prospect_Probability_w_In_24_months__c = 50;
        barkerModelCalculation.Prospect_RPX_target_margin_by_problem_ty__c = 50;
        if(isInsert)
            insert barkerModelCalculation;
        return barkerModelCalculation;
    }
    public static Defendant__c createDefendant(Id accId ,Id litigitionId, Boolean isInsert){
        Defendant__c defendant = new Defendant__c();
        defendant.Litigation_ID__c = litigitionId;
        defendant.Account__c = accId;
        defendant.Date_Terminated__c = Date.today();
        defendant.Defendant_Name__c = 'Test';
        if(isInsert)
            insert defendant;
        return defendant;
   }
   
   public static Map<String, Id> getRecordType(String objectName) {
    Map<String,Id> recType = new Map<String,Id>();
    for (RecordType rType : [Select Id, Name
                             From RecordType
                             Where SobjectType = :objectName]) {
      recType.put(rType.Name, rType.Id);
    }
    return recType;
   }
   public static Litigation_Patent_Family__c createLitigationPatentFamily(Id PatentFamilyId ,Id litigitionId,Boolean isInsert){
        Litigation_Patent_Family__c litigationPF = new Litigation_Patent_Family__c();
        litigationPF.Litigation__c = litigitionId;
        litigationPF.Patent_Family__c = PatentFamilyId;
        if(isInsert)
            insert litigationPF;
        return litigationPF;
   }
  //------------------------------------------------
  //Returns a record of Non Party Entity.
  //------------------------------------------------
  public static Non_Party_Entity__c createNonPartyEntity(Id acqOppId,Id accId,Id oppId,Boolean isInsert){
        Non_Party_Entity__c npe = new Non_Party_Entity__c();
        npe.Acquisition_Opportunity__c = acqOppId;
        npe.Account__c = accId;
        npe.Opportunity__c = oppId;
        if(isInsert)
            insert npe;
        return npe;
  }
  
  //------------------------------------------------
  //Returns a record of OMA Patent
  //------------------------------------------------
  public static OMA_Patent__c createOMAPatent(Id acqOppId, Id patentId, Boolean isInsert) {
    OMA_Patent__c omaPatent = new OMA_Patent__c();
    omaPatent.Patent__c = patentId;
    omaPatent.Acquisition_Opportunity__c = acqOppId;
    if(isInsert) {
      insert omaPatent;
    }
    return omaPatent;
  }
  
  //------------------------------------------------
  //Returns a record of Task
  //------------------------------------------------
  public static Task createTask(Id WhoId, Id WhatId, Boolean isInsert) {
    Task task = new Task();
    task.Description = 'Test Desctiption Text';
    task.OwnerId = UserInfo.getUserId();
    task.WhatId = whatId;
    task.WhoId = WhoId;
    task.Subject = 'Test';
    task.Type = 'Feedback Received';
    task.ActivityDate = Date.today().addYears(1);
    task.Quality_of_Conversation__c = '1';
    if(isInsert) {
      insert task;
    }
    return task;
  }
  
  //------------------------------------------------
  //Returns a record of Task
  //------------------------------------------------
  public static Contact createContact(Id accId, Boolean isInsert) {
    Contact contact = new Contact();
    contact.accountid = accId;
    contact.LastName = 'test';
    if(isInsert) {
      insert contact;
    }
    return contact;
  }
}