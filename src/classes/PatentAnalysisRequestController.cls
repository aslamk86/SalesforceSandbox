/*
    Apex Class:PatentAnalysisRequestController
    Description: This Class is used as a controller for a page(PatentAnalysisRequest) 
                 To display All member Account with Heat Map details.
    Created By : Bharti(Appirio offshore)
    Modified Date : 3 July 2012
    
    Revision: changed "Completed" to "Closed Loop" as criteria for filtering from list
              Added refresh of section after saving the queue.

     Last Modified Date: Feb 25, 2014.  
     Modification:  Changed so the page can segregate Prior Art versus Non-Prior Art
     
     06-AUG-2014 : N Hari Prakash : Updated : Added "Other_Notes__c" in soql for CRM-288

*/
public without sharing class PatentAnalysisRequestController {
    //----------------------------------------------------------------//
    //Contacts
    //---------------------------------------------------------------//   
    
    static final String ALL = Label.PatentAnalysisRequestAllView;
    static final String MY = Label.PatentAnalysisRequestMyView;
    
    //----------------------------------------------------------------//
    //Page properties
    //---------------------------------------------------------------//   
    
    public Boolean isAdminView {get;set;}
    public List<AnalysisRequestWrapper> analysisRequests {get;set;}
    public String recordURL {get;set;} 
    public String PageType {get;set;}
    
    public Boolean isAsc {get; set;}
    public String columnName {get; set;}
    
    public List<SelectOption> getfilterOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ALL,ALL));
        options.add(new SelectOption(MY,MY));
        return options;
    }
    
    public String selectedFilter{get;set;}
    
    Boolean isAdmin;    
    public Map<Id,List<ContentVersion>> mapPARwithCVRecords ; // Map of PAR Id and List of CV records for that PAR
    
    //----------------------------------------------------------------//
    //Constructor
    //---------------------------------------------------------------//   

    public PatentAnalysisRequestController(ApexPages.StandardController controller) {
      isAsc=true;
      columnName='Name';
        analysisRequests = new List<AnalysisRequestWrapper>();
        recordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        if (ApexPages.currentPage().getParameters().containsKey('sfdc.tabname')) 
        {
            if (ApexPages.currentPage().getParameters().get('sfdc.tabname' ) == '01r400000005jpW' )
                PageType = 'PatentAnalysis'; //PriorArt OR PatentAnalysis         
            else 
                PageType = 'PriorArt'; 
        }
        
        for(User currentUser : [Select Profile.Name From User Where Id = : UserInfo.getUserId()]){
            if (PageType == 'PatentAnalysis')
                isAdmin = currentUser.Profile.Name.contains(Label.PatentAnalysisRequestAdminProfile);
            else
                isAdmin = currentUser.Profile.Name.contains(Label.PriorArtRequestAdminProfile);
         }
        selectedFilter = ALL;
        loadRequests();
    }
    
    //----------------------------------------------------------------//
    //Page methods
    //---------------------------------------------------------------//   
    public PageReference applyFilter(){
        loadRequests();   
        return null;
    }
    
    
    public PageReference evaluateRequestRankings(){
        List<AnalysisRequestWrapper> modifiedRequests = getModifiedRequests();
        List<AnalysisRequestWrapper> newList = new List<AnalysisRequestWrapper>();
        system.debug('bharti ==' + modifiedRequests);
        Decimal lastProcessedRanking = 0;
        for(AnalysisRequestWrapper wrapper : modifiedRequests){
            Integer listSize = analysisRequests.size();
            for(Integer index = 0 ; index < listSize ; index++){
                if(wrapper.rowNumber == (index + 1)){
                    if(wrapper.oldRowNumber > (index + 1)){
                        wrapper.request.Ranking__c = analysisRequests.get(index).request.Ranking__c;
                        lastProcessedRanking = analysisRequests.get(index).request.Ranking__c = 0.001;  
                        wrapper.hasRankingModified = true;                   
                        analysisRequests.get(index).hasRankingModified = true;
                        newList.add(wrapper);  
                        newList.add(analysisRequests.get(index));
                    }else{
                        lastProcessedRanking = wrapper.request.Ranking__c = analysisRequests.get(index).request.Ranking__c + 0.001;
                        wrapper.hasRankingModified = true;                      
                        newList.add(analysisRequests.get(index));
                        newList.add(wrapper);  
                    }               
                } else
                if(wrapper.oldRowNumber != analysisRequests.get(index).oldRowNumber){
                    if(analysisRequests.get(index).request.Ranking__c == lastProcessedRanking){
                        lastProcessedRanking = analysisRequests.get(index).request.Ranking__c = lastProcessedRanking + .001;
                        analysisRequests.get(index).hasRankingModified = true;
                    }
                    newList.add(analysisRequests.get(index));
                }
                    
            }
            analysisRequests.clear();
            analysisRequests = newList;
            newList = new List<AnalysisRequestWrapper>();
        }
        
        for(Integer index = 0 ; index < analysisRequests.size() ; index++){
            analysisRequests.get(index).rowNumber = analysisRequests.get(index).oldRowNumber = index + 1;
        }        
        //reloadRequests();
        return null;
    }
    
         //------dps note: This might be where they set the completed time/date for the task. not sure if this should be updated to "Closed Loop" 
         // JBasara confirmed - all deals will be closed before they close loop, and triggers/dates should be based on closed. 

    public PageReference saveRequests(){
        evaluateRequestRankings();
        set<Patent_Analysis_Request__c> modifiedRequests = new set<Patent_Analysis_Request__c>();
        for(AnalysisRequestWrapper wrapper : analysisRequests){
            if(wrapper.request.Status__c == 'Completed')
                wrapper.request.Completed_Date__c = system.today();
            //if(wrapper.hasRankingModified){
            system.debug('Adding Request : ' + wrapper.request);
                modifiedRequests.add(wrapper.request);
              
            //}
        }
        List <Patent_Analysis_Request__c> UpdateRequests = new List<Patent_Analysis_Request__c>();
        UpdateRequests.addAll(modifiedRequests);
        update UpdateRequests;
        loadRequests(); //Fix added by Aslam to repopulate the list
        return null;
    }    
     //----------------------------------------------------------------//
    //Helper methods
    
    //  (dps-original string here)       String soql = 'Select Name,Id ,Status__c ,Ranking__c , SendAssignmentNotification__c, Requested_By__c, Request__c, Request_Type__c, Priority__c, Opportunity__c, Hours__c, Due_Date__c, Completed_Date__c, Assigned_To__c, Admin_Notes__c, Acquisition_Opportunity__c From Patent_Analysis_Request__c Where Status__c != \'Completed\'';

    //---------------------------------------------------------------//   
    private void loadRequests(){     
        isAdminView = isAdmin & selectedFilter == ALL ;     
        
        analysisRequests.clear();   
        // DPS 7/3/2012 changed criteria for filtering from "Completed" to "Closed Loop".          
        String soql = 'Select Name,Id ,Status__c ,Ranking__c ,   Analysis_Type__c, Vendor_Search_Due_Date__c, SendAssignmentNotification__c, Requested_By__c, Request__c, Request_Type__c, Priority__c, Opportunity__c, Hours__c, Due_Date__c, Completed_Date__c, Assigned_To__c, Admin_Notes__c, Acquisition_Opportunity__c, Assigned_Searcher__c, Patent__r.Name,Other_Notes__c From Patent_Analysis_Request__c Where Status__c != \'Closed Loop\'';
            //START Of Add Criteria for filtering out Complete & Rejected Status.
            if(PageType != 'PatentAnalysis')
                soql +='and Status__c != \'Complete\' and Status__c != \'Rejected\'';
            //END Of Add Criteria for filtering out Complete & Rejected Status.
            
            if (PageType == 'PatentAnalysis')//PriorArt OR PatentAnalysis
                    soql += 'and Analysis_Type__c != \'Prior Art Pilot Program\'';
                else
                    soql += 'and Analysis_Type__c = \'Prior Art Pilot Program\'';
        soql += selectedFilter == ALL ? '' : ' And Assigned_To__c = \'' + UserInfo.getUserId() + '\'';
        
        if (PageType == 'PatentAnalysis')
          soql += '  Order by Ranking__c';
        else{
          soql += '  Order by '+columnName;
        
          if(isAsc)
            soql=soql+' asc';
          else
            soql=soql+' desc';
        }  
        
        Integer index = 1;
        
        // Populating wrapper Data for 'PatentAnalysis'
        if (PageType == 'PatentAnalysis'){
            for(Patent_Analysis_Request__c patentAnalysisRequest :Database.query(soql)){
                    analysisRequests.add(new AnalysisRequestWrapper(patentAnalysisRequest,index++,null));
            }
        }else{
            // Populating wrapper Data for 'Prior Art'
            List<Patent_Analysis_Request__c> patentAnalysisRequestList = Database.query(soql);
            List<Id> validPARIDs = new List<Id>();
            
            if(patentAnalysisRequestList != null && patentAnalysisRequestList.size()>0){
                for(Patent_Analysis_Request__c par : patentAnalysisRequestList){                
                    validPARIDs.add(par.Id);
                }
                // Calling a method which returns a map of PAR Id and List of CV Records
                mapPARwithCVRecords = fetchContentItems(validPARIDs);
            }
            for(Patent_Analysis_Request__c patentAnalysisRequest: patentAnalysisRequestList){
                    analysisRequests.add(new AnalysisRequestWrapper(patentAnalysisRequest,index++,mapPARwithCVRecords.get(patentAnalysisRequest.Id)));
            }
        }
    }
    
    private List<AnalysisRequestWrapper> getModifiedRequests(){
         List<AnalysisRequestWrapper> modifiedRequests = new  List<AnalysisRequestWrapper> ();
         for(AnalysisRequestWrapper wrapper : analysisRequests){
            if(wrapper.rowNumber != wrapper.oldRowNumber){
                Integer position = 0;
                while(position < modifiedRequests.size()){
                    if(wrapper.rowNumber <  modifiedRequests.get(position).rowNumber){
                        break;
                    }
                    position++;
                }               
                if(modifiedRequests.size() == position)
                    modifiedRequests.add(wrapper);
                else{               
                    modifiedRequests.add(position,wrapper);
                }                   
            }
         }
         return modifiedRequests;
    }
    
    public void sortData(){
      if(isAsc)
        isAsc=false;
      else isAsc=true;
      
      loadRequests();
    }
    
    
    //----------------------------------------------------------------//
    //Inner wrapper classes
    //---------------------------------------------------------------//   
    public class AnalysisRequestWrapper{
        public Integer rowNumber{get;set;}
        public Integer oldRowNumber{get;set;}
        public Patent_Analysis_Request__c request {get;set;}
        public Boolean hasRankingModified {get;set;}
        public List<ContentVersion> listContentRecords {get;set;}
        
        public AnalysisRequestWrapper(Patent_Analysis_Request__c request,Integer rowNumber,List<ContentVersion> listContentRecords){
            this.request = request;
            this.oldRowNumber = this.rowNumber = rowNumber;
            this.hasRankingModified = false;
            this.listContentRecords = listContentRecords;
        }
        
    }
    
     /**
        Method to fetch content Item details and populate a map of PAR Id and List of CV Records
    */
    
    public Map<Id,List<ContentVersion>> fetchContentItems(List<Id> listId){
        List<ContentVersion> listContentItems = new List<ContentVersion>();// variable to fetch Content Items for List of PAR Id's 
        Map<Id,List<ContentVersion>> mapPARwithCV = new Map<Id,List<ContentVersion>>();
        // creating string query
        listContentItems = [SELECT Account__c, Acquisition__c, Opportunity__c,Patent_Analysis_Request__c, Title FROM ContentVersion where Patent_Analysis_Request__c IN: listId];
       
        System.debug('listContentItems in fetchContentItems------------------------------->' +listContentItems);        
        List<ContentVersion> listContentV;
        for(Id parID: listId){
            listContentV= new List<ContentVersion>();
            for(ContentVersion cv: listContentItems){
                if(cv.Patent_Analysis_Request__c == parID){
                listContentV.add(cv);
                }
            }
            mapPARwithCV.put(parID,listContentV);
        }       
        return mapPARwithCV;
    }
}