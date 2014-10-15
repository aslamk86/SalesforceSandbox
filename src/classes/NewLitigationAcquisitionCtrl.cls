/*****************************************************************************
 * Name             : NewLitigationAcquisitionCtrl
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 14 Mar, 2012.
 * Purpose          : Custom Edit Page for Acquisition Opportunity
 *                    T-36662 
 *****************************************************************************/
public with sharing class NewLitigationAcquisitionCtrl {
  public Acquisition_Opportunity__c acqOpp{get;set;}
  private Map<String,String> pageParams;
  private Id litId;
  
  //----------------------------------------------------------------------------
  //Constructor
  //----------------------------------------------------------------------------
  public newLitigationAcquisitionCtrl() {
  	pageParams = ApexPages.currentPage().getParameters();
  	litId =(Id) pageParams.get('lid');
  	
    acqOpp = new Acquisition_Opportunity__c();
    Map<String, Id> recTypes = 
      AcquisitionOpportunityUtility.getRecordType('Acquisition_Opportunity__c');
      
    acqOpp.RecordTypeId = recTypes.get('Litigations');
    acqOpp.OwnerId = Userinfo.getUserId();
  }
  
  //----------------------------------------------------------------------------;
  //Save Method Creates new Opportunity Litigation Records
  //----------------------------------------------------------------------------
  public PageReference save() {
  	insert acqOpp;
  	Opportunity_Litigation__c ol = new Opportunity_Litigation__c ();
  	ol.Acquisition_Opportunity__c = acqOpp.Id;
  	ol.Litigation__c = litId;
  	insert ol;
  	return new PageReference('/' + litId);
  }

  //----------------------------------------------------------------------------
  //Return back to Litigation
  //----------------------------------------------------------------------------
  public pageReference cancel() {
  	return new PageReference('/' + litId);
  }
  
}