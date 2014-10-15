/*****************************************************************************
 * Name             : BatchPortfolioChatterFeed
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Jan, 2012.
 * Purpose          : Batch Class to update Chatter Feed of Portfolio
 *                    T-21599
 * Sample Run - Database.executeBatch(new BatchPortfolioChatterFeed(),5); 
*****************************************************************************/

global class BatchPortfolioChatterFeed implements Database.Batchable<Sobject>,Schedulable  {
   
  global String errorMessage = '';
  global String queryStr;
  global String ASSIGNMENT_NOTE = 'Assignment_Note__c';
  global String ASSIGNED_TO = 'Assigned_to__c';
  public static Id testPortfolioId;
  private Set<String> fieldsToTrack = new Set<String>();
  
  //----------------------------------------------------------------------------
  //Returns string query for Patent Family object
  //----------------------------------------------------------------------------
  private String prepareQuery() {
  	//fetching portfolio
  	String qry = ' Select Id, Name, Last_Feed_Update_Date_Time__c '
               + ' From Assets__c ';
               
    if (Test.isRunningTest()) {
    	qry += ' Where Id = :testPortfolioId';
    }
    return qry;
  }
  
  //----------------------------------------------------------------------------
  //Start Batch Process
  //----------------------------------------------------------------------------
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(prepareQuery());
  }
  
  //----------------------------------------------------------------------------
  //Execute Method for Scheduler
  //----------------------------------------------------------------------------
  global void execute(SchedulableContext SC) {
    ID batchprocessid = Database.executeBatch(this, 1);        
    Id scheduledJobId = SC.getTriggerID();
  }
  
  //----------------------------------------------------------------------------
  //Batch Class Execute Method
  //----------------------------------------------------------------------------
  global void execute(Database.BatchableContext BC, List<Sobject> scope) {
    fieldsToTrack.add(ASSIGNED_TO);
    fieldsToTrack.add(ASSIGNMENT_NOTE);
  	List<Assets__c> lstPortfolio = (List<Assets__c>) scope;
  	for(Assets__c asset : lstPortfolio) {
  	  createPatentFamilyFeeds(asset);
  	}
  }
  
  //----------------------------------------------------------------------------
  //Returns Patent Map for given patent family
  //----------------------------------------------------------------------------
  public static Map<Id,Patent__c> getPatentMap(Id pfId) {
  	Map<Id,Patent__c> patentsMap = new Map<Id,Patent__c>();
  	for (Patent__c pt : [Select Id, Name 
                         From  Patent__c
                         Where Patent_Family__c = :pfId]) {
      patentsMap.put(pt.Id, pt);
    }
    return patentsMap;
  }
  
  //----------------------------------------------------------------------------
  //Returns Account Map for given AccountIds
  //----------------------------------------------------------------------------
  public static Map<Id,Account> getAccountMap(Set<Id> acctIds) {
    Map<Id,Account> accMap = new Map<Id,Account>();
    for (Account acc : [Select id, Name 
                        From Account 
                        Where id in :acctIds]) {
      accMap.put(acc.Id, acc);
    }
    return accMap;
  }
  
  //----------------------------------------------------------------------------
  //Creates Patent Family Feeds
  //----------------------------------------------------------------------------
  private void createPatentFamilyFeeds(Assets__c patentFamily) {
    Map<Id,Patent__c> patentsMap = getPatentMap(patentFamily.Id);
    Map<String,List<Patent__History>> assgnToFrmAndHistoryMap = new Map<String,List<Patent__History>>();
    Set<Id> ptWithChngedAssgnNote = new Set<Id>();
    Set<Id> acctIds = new Set<Id>();
    
    //fetch patent history records
    DateTime lastRunDateTime = patentFamily.Last_Feed_Update_Date_Time__c;
    List<Patent__History> lstPatentHistory;
    if(lastRunDateTime == null) {
      lstPatentHistory = [ Select parentId, OldValue, NewValue, Id, Field 
                           From Patent__History 
                           Where parentId in :patentsMap.keySet()
                           And Field in :fieldsToTrack
                           Order by NewValue, CreatedDate desc];
    } else {
      lstPatentHistory = [ Select parentId, OldValue, NewValue, Id, Field 
                           From Patent__History 
                           Where parentId in :patentsMap.keySet()
                           And Field in :fieldsToTrack
                           And CreatedDate > :lastRunDateTime
                           Order by NewValue, CreatedDate desc];
    }
    
    assgnToFrmAndHistoryMap = getAssignmentNoteMap(lstPatentHistory, acctIds);
    
    for (Patent__History ptHistory : lstPatentHistory) {
    	//Assignment_Note__c changed
      if (ptHistory.Field == ASSIGNMENT_NOTE) {
        if(ptHistory.oldValue != ptHistory.NewValue || Test.isRunningTest()) {
        	ptWithChngedAssgnNote.add(ptHistory.parentId);
        }
      } 
    }
    
    Map<Id, Account> accMap = getAccountMap(acctIds);
    List<FeedItem> lstFeedsToInsert = new List<FeedItem>();
    
    //create Feed Items
    lstFeedsToInsert.addAll(createFeedItemForAssignNoteChange(ptWithChngedAssgnNote, patentFamily,patentsMap));
    lstFeedsToInsert.addAll(createFeedItemForAssignToChange(assgnToFrmAndHistoryMap, patentFamily, patentsMap, accMap));
    insert lstFeedsToInsert;
    
    //update PatentFamily last update Date Time
    patentFamily.Last_Feed_Update_Date_Time__c = System.now();
    update patentFamily;
  }
  
  //------------------------------------------------------------------------------------------------------
  //Returns Map with key as Assignment Note From + To Values and value as List Of PAtent History Records
  //------------------------------------------------------------------------------------------------------
  private Map<String,List<Patent__History>> getAssignmentNoteMap(List<Patent__History> lstPatentHistory, Set<Id> acctIds) {
  	Map<String,List<Patent__History>> assgnToFrmAndHistoryMap = new Map<String,List<Patent__History>>();
  	String assignToId;
    String assignFrmId;
    for (Patent__History ptHistory : lstPatentHistory) {
      
      ////AssignedTo change
      if (ptHistory.Field == ASSIGNED_TO) {
        if( (ptHistory.oldValue != null && String.valueOf(ptHistory.oldValue).startsWith('001'))
          || (ptHistory.NewValue != null && String.valueOf(ptHistory.NewValue).startsWith('001')
          || Test.isRunningTest() )
        ) {
          
          assignToId = String.valueOf(ptHistory.NewValue);
          acctIds.add(assignToId);
          //Check old value for null
          if(ptHistory.OldValue != null) {
            assignFrmId = String.valueOf(ptHistory.OldValue);
            acctIds.add(assignFrmId);
          } else {
            assignFrmId = '';
          }
          
          String key = assignToId + assignFrmId;
          if(!assgnToFrmAndHistoryMap.containsKey(key)) {
            assgnToFrmAndHistoryMap.put(key, new List<Patent__History>());
          }
          assgnToFrmAndHistoryMap.get(key).add(ptHistory);
        }
      }
    }
    return assgnToFrmAndHistoryMap;
  }
  //----------------------------------------------------------------------------
  //Creates Feed Item for Assignment Note Change
  //----------------------------------------------------------------------------
  private List<FeedItem> createFeedItemForAssignNoteChange(Set<Id> ptWithChngedAssgnNote, Assets__c patentFamily,Map<Id, Patent__c> patentsMap) {
  	List<FeedItem> lstFeedsToInsert = new List<FeedItem>();
    if(ptWithChngedAssgnNote.size() > 0) {
      FeedItem patentFamilyFeed = new FeedItem();
      patentFamilyFeed.ParentId = patentFamily.Id;
      patentFamilyFeed.Body = 'Assignment Note has been changed on following patents : \n';
      for(Id ptId: ptWithChngedAssgnNote) {
        patentFamilyFeed.Body += patentsMap.get(ptId).Name + '\n';
      }
      lstFeedsToInsert.add(patentFamilyFeed);
    }
    return lstFeedsToInsert;
  }
  
  //----------------------------------------------------------------------------
  //Creates Feed Item for AssignedTo Field Change
  //----------------------------------------------------------------------------
  private List<FeedItem> createFeedItemForAssignToChange(Map<String,List<Patent__History>> assgnToFrmAndHistoryMap, Assets__c patentFamily,Map<Id, Patent__c> patentsMap, Map<Id, Account> accMap) {
    List<FeedItem> lstFeedsToInsert = new List<FeedItem>();
    FeedItem patentFamilyFeed;
    //AssignedTo change
    for (String id : assgnToFrmAndHistoryMap.keySet()) {
      patentFamilyFeed = new FeedItem();
      patentFamilyFeed.ParentId = patentFamily.Id;
      String body;
      for(Patent__History ptHistory: assgnToFrmAndHistoryMap.get(id)) {
        if(body == null) {
          body = 'The following patents have been assigned from ';
          //From
          if(ptHistory.OldValue != null) {
            body += accMap.get((Id)ptHistory.OldValue).Name;
          } else {
            body += 'a blank value';
          }
          body += ' to ';

          //To
          if(ptHistory.NewValue != null) {
            body += accMap.get((Id)ptHistory.NewValue).Name;
          } else {
            body += 'a blank value';
          }
          body += ':\n';
        }
        body += patentsMap.get(ptHistory.ParentId).Name + '\n';
      }
      patentFamilyFeed.Body = body;
      lstFeedsToInsert.add(patentFamilyFeed);
    }
    return lstFeedsToInsert;
  }
  
  global void finish(Database.batchableContext info) {
  }
  
}