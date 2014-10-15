/*******************************************************************************
 * Name             : LitigationCheatSheetController
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 25 Feb, 2012.
 * Purpose          : Litigation Cheat Sheet. 
 * Task               T-34016  
 ******************************************************************************/
public without sharing class LitigationCheatSheetController{
  
  private Account account;
  private Set<Id> allAcqOppIds;
  private Map<Id, List<Patent__c>> OMAAcqOppPatentMap;
  private Map<Id, List<Defendant__c>> litigationDefendantMap;
  private Map<Id, List<Litigation__c>> acqOppLitigationMap;
  private Map<Id, List<Patent__c>> litigationPatentMap;
  private Map<Id, Litigation__c> mapLitigation;
  private Map<Id, Set<Id>> acqOppLitigationIdsMap;
  
  public transient List<AcquisitionOpportunityWrapper> lstOMAAcqOpp{get;set;}
  public transient List<AcquisitionOpportunityWrapper> lstLitigationAcqOpp{get;set;}
  public string xmlheader {get;set;}
  public string endfile{get;set;}
  public Set<Id> OMAAcqOppIds{get;set;}
  public Set<Id> litigationNPEAcqOppIds{get;set;}
  public Set<Id> litigationAcqOppIds{get;set;}
  
  //-------------------------------------------------------------------------------------------------------------------------------
  //Constructor
  //-------------------------------------------------------------------------------------------------------------------------------
  public LitigationCheatSheetController(ApexPages.StandardController controller) {
    //VF page gives some issues directly using the below code there, so wrap up in variable
    xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
    endfile = '</Workbook>';
    account = (Account) controller.getRecord();
    
    //Initialize;
    lstOMAAcqOpp = new List<AcquisitionOpportunityWrapper>();
    lstLitigationAcqOpp = new List<AcquisitionOpportunityWrapper>();
    allAcqOppIds = new Set<Id>();
    litigationAcqOppIds = new Set<Id>(); 
    
    //All OMA Opportunities
    OMAAcqOppIds = AcquisitionOpportunityUtility.fetchAcqOppRelatedToBarkerModelAccount(account.Id, true, 'OMA', 'Rejected');
    
    //NPE Litigation Opp
    litigationNPEAcqOppIds = AcquisitionOpportunityUtility.fetchNPEAcquisitionOpportunity(account.Id);
    
    //Other Litigation OPP
    litigationDefendantMap = AcquisitionOpportunityUtility.getLitigationDefendantMap(account.Id);
    
    mapLitigation = AcquisitionOpportunityUtility.getLitigationMap(litigationDefendantMap.keySet());
    acqOppLitigationIdsMap = AcquisitionOpportunityUtility.getAcqOppLitigationMap(litigationDefendantMap.keySet());
    litigationAcqOppIds = acqOppLitigationIdsMap.keySet();
    
    allAcqOppIds.addAll(OMAAcqOppIds);
    allAcqOppIds.addAll(litigationNPEAcqOppIds);
    allAcqOppIds.addAll(litigationAcqOppIds);
    
    //Create Wrapper List
    createWrapperList();
  } 
  
  //-------------------------------------------------------------------------------------------------------------------------------
  //Creates List of Wrapper Class for ResultSet
  //-------------------------------------------------------------------------------------------------------------------------------
  private void createWrapperList() {
    List<Acquisition_Opportunity__c> lstAcqOpp = AcquisitionOpportunityUtility.getAcqusitionOpportunity(allAcqOppIds);
    for (Acquisition_Opportunity__c acqOpp : lstAcqOpp) {
        //OMA
        if(OMAAcqOppIds.contains(acqOpp.Id)) {
            lstOMAAcqOpp.add(new AcquisitionOpportunityWrapper(acqOpp));
        } else {
            //Litigation
            if(litigationAcqOppIds.contains(acqOpp.Id)) {
                //Defendant & Patent Family
                for(Id litId : acqOppLitigationIdsMap.get(acqOpp.Id)) {
                    //Acquisition_Opportunity__c acqOpp, List<Patent__c> lstPatent, List<Defendant__c> lstDefendant
                    lstLitigationAcqOpp.add(new AcquisitionOpportunityWrapper(acqOpp,litigationDefendantMap.get(litId),mapLitigation.get(litId), false));
                }
            } else {
                //NPE
                lstLitigationAcqOpp.add(new AcquisitionOpportunityWrapper(acqOpp,  null, null, true));
            }
        }
    }
  }
}