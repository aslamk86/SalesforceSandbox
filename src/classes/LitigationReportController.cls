/*
  Apex Class :LitigationReportController
  Description : A controller that is used to generate Litigation Report.
  Created By : Sudhir Kumar Jagetiya
  Last Modified Date : Feburary 26,2012
*/
public without sharing class LitigationReportController {
	
    public Transient List<List<AcqOppLitigationReportWrapper>> litigationReportList{get;set;}
    public string xmlheader {get;set;}
  	public string endfile{get;set;}
    static Integer maxLimit = 200;
    //Constructor
    public LitigationReportController(){
    	try{
    		maxLimit = Integer.valueOf(System.Label.MaxLimitOfRecordForLitigationTop120Report);
    	}catch(Exception e){
    		maxLimit = 200;
    	}
    	system.debug('====Max====start==' + limits.getLimitScriptStatements() + '=======' + limits.getScriptStatements());  
			xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
			endfile = '</Workbook>';
	    loadReportData();
    }
    
    //Retrieve All Acq Opp where RecordType is Litigations
    private void loadReportData(){
    	Map<Id,Acquisition_Opportunity__c> mapAcqOpptys = new Map<Id,Acquisition_Opportunity__c>(
						[Select Name,Assets__r.Name,Priority__c,SellersExplicitExpectation__c,Current_Status__c,Last_Action__c,NextStep__c,Action_Item_Assigned_To__c,    	
					    Suit_Ranking__c, Primary_Market_Sector__c, Account__r.Name ,Id, Degree_of_Dialogue__c, Deal_Probability__c, 
                        (Select Account__r.Name,Account__r.RecordTypeName__c, Account__r.RecordType.Name,Account__r.Top_Prospect_List__c From Non_Party_Entities__r), 
                        (Select Id,Acquisition_Opportunity__c, Litigation__c, Litigation__r.Active_or_Closed__c,Litigation__r.Filed__c, Litigation__r.Docket_Number__c From Opportunity_Litigation__r) 
                        From Acquisition_Opportunity__c 
                        where RecordType.Name = 'Litigations' limit :maxLimit]);
                        
        Set<Id> litigationIds = new Set<Id>();
        for(Acquisition_Opportunity__c acqOpp : mapAcqOpptys.values()){
        	for(Opportunity_Litigation__c oppLit : acqOpp.Opportunity_Litigation__r){
        		litigationIds.add(oppLit.Litigation__c);
        	}
        }
        
        system.debug('====Max====after acq query==' + limits.getLimitScriptStatements() + '=======' + limits.getScriptStatements());        
        
        Map<Id,Litigation__c> mapLitigations = new Map<Id,Litigation__c>([Select 
        							(Select Account__r.Top_Prospect_List__c, RPX_Rate_del__c, Date_Terminated__c,Account__r.Name,Account__r.RecordType.Name,
        							 Litigation_ID__c, Account__c From Defendants__r ) 
        							 From Litigation__c Where Id IN :litigationIds]);
        
        Set<Id> accountIds = new Set<Id>();
        for(Litigation__c litigations : mapLitigations.values()){
        	for(Defendant__c defendant :litigations.Defendants__r){
        		accountIds.add(defendant.Account__c);
        	}
        }        
        
        system.debug('====Max====after lit query==' + limits.getLimitScriptStatements() + '=======' + limits.getScriptStatements());
        
        Map<Id,Account> mapAccounts = new Map<Id,Account>([Select 
        							(Select Name, StageName From Opportunities Where StageName Not IN :ClosedOpportunityStages__c.getAll().keySet()
	                                 And RecordType.Name = 'Membership' ORDER BY CreatedDate DESC limit 1)
		                             From Account where Id In :accountIds]);
		                             
		populateLitigationReportLists(mapAcqOpptys,mapLitigations,mapAccounts);
    }
    
    //process report data and prepare list
    public void populateLitigationReportLists(Map<Id,Acquisition_Opportunity__c> mapAcqOpptys, Map<Id,Litigation__c> mapLitigations, Map<Id,Account> mapAccounts ){
    	
    	litigationReportList = new List<List<AcqOppLitigationReportWrapper>>();
    	List<AcqOppLitigationReportWrapper> tempList = new List<AcqOppLitigationReportWrapper>();
    	
    	for(Acquisition_Opportunity__c acqOpp :mapAcqOpptys.values()){
    		// For all the Acquisition Opportunity and Non Party Entity where Acquisition Opportunity record type is Litigation 
	        for(Non_Party_Entity__c nonPartyEntity :acqOpp.Non_Party_Entities__r){
	        	if(tempList.size() == 1000){
	        		litigationReportList.add(tempList);
	        		tempList = new List<AcqOppLitigationReportWrapper>();
	        	}
	        	tempList.add(new AcqOppLitigationReportWrapper(acqOpp,nonPartyEntity));	        		
	  		}
	  		
	  		for(Opportunity_Litigation__c oppLit :acqOpp.Opportunity_Litigation__r){
	  			if(oppLit.Litigation__c != null) {
		  			for(Defendant__c defendant : mapLitigations.get(oppLit.Litigation__c).Defendants__r){
		  				for(Opportunity opp :mapAccounts.get(defendant.Account__c).Opportunities){
		  					if(tempList.size() == 1000){
				        		litigationReportList.add(tempList);
				        		tempList = new List<AcqOppLitigationReportWrapper>();
				        	}			        	
		        			tempList.add(new AcqOppLitigationReportWrapper(acqOpp,oppLit,defendant,opp));
	          			}
		  			}
	  			}	  		 	
	  		}
    	}
    	litigationReportList.add(tempList);
    	system.debug('====Max====End==' + limits.getLimitScriptStatements() + '=======' + limits.getScriptStatements());
    }
}