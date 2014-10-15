/****************************************************
   
    CORE RECORD CONTROLLER
    
    Built by Hank Ryan Thompson.
    Created 6/4/2013.
    Last updated 6/5/2013 by Hank.
    
    This controller retrieves records from the Core
    API via the SyncEngine.
    
    It can retrieve either Patent Family or Patent
    records and supports being invoked either with
    a single "key" parameter in the page url
    OR via a standard record controller extension
    for one of the two supported objects.
    
    This controller currently powers the following:
     - CorePatent.page
     - CorePatentFamily.page
     - CorePatentFamilyChildren.page
    
****************************************************/


public class CoreRecordController {
    
    /*=== CONSTANTS & ENUMS ===*/
    
    
    public String regex_CleanURL = '^.+/|\\?.*$'; //this regex is used to clean the page url --> removes everything at-before "/" and at-after "?"
    
    private String ERROR_UNSUPPORTED_OBJECT = 'This object type is unsupported. The CoreRecordController is only able to extend the Patent or Patent Family records.';
    private String ERROR_MISSING_KEY_STANDARD = 'The "key" parameter is missing from the URL.';
    private String ERROR_MISSING_KEY_EXTENSION = 'The primary key value is missing from the Salesforce record.';
    private String ERROR_BLANK_RESULT = 'The Core API did not return any results for the provided key.';
    private String ERROR_CORE_API = Label.Core_API_Error;
    
    private enum InvocationType {Standard, Extension} 
    
    
    
    /*=== STATE VARIABLES ===*/
    
    
    // Internal Variables
    private InvocationType theInvocation;
    private Id recordId;
    private SyncEngine.CoreObject theObject;
    private SyncEngine.ConvertedResponseRow convertedRow {get; set;}
    
    // Public Variables
    public String primaryKeyValue {get; set;}
    public ChildPatentRow[] childPatentRows {get; set;}
    
    // Other Getters & Setters
    public Boolean getIsError() {return (convertedRow == null);}
    public String getAPIResponseText() {
    	if ((convertedRow == null) || (convertedRow.originalResponseRow == null)) return null;
    	else return SyncEngine.mapToString(convertedRow.originalResponseRow.allFlattenedValues);
    }
    
    public Patent__c getPatent() {if (convertedRow == null) return null; else return convertedRow.patent;}
    public void setPatent(Patent__c p) {if (convertedRow != null) convertedRow.patent = p;}
    public String getPatentDetailURL() {
        if ((convertedRow == null) || (convertedRow.patent == null)) return null;
        else return SyncEngine.getDetailURL(convertedRow.patent);
    }
    
    public void setPatentFamily(Assets__c pf) {if (convertedRow != null) convertedRow.patentFamily = pf;}
    public Assets__c getPatentFamily() {if (convertedRow == null) return null; else return convertedRow.patentFamily;}
    public String getPatentFamilyDetailURL() {
        if ((convertedRow == null) || (convertedRow.patentFamily == null)) return null;
        else return SyncEngine.getDetailURL(convertedRow.patentFamily);
    }
    
    
    /*=== CHILD PATENT ROW INNER CLASS ===*/
   
   
    public class ChildPatentRow {
       
        /*
            This inner class is required in order to provide the patent detail url      
        */
       
        public Patent__c patent {get; set;}
        public Boolean getIsInSalesforce() {return (patent != null) && (patent.Id != null);}
        public String getPatentDetailURL() {
            if (patent == null) return null;
            else return SyncEngine.getDetailURL(patent);
        }
        
        public ChildPatentRow(Patent__c patent) {
            this.patent = patent;
        }
       
    }
    
    
    
    /*=== INITIALIZATION ===*/
    
    
    public CoreRecordController() {
        // This is the default controller (for standard visualforce pages)
        
        system.debug('###CoreRecordController(): Entering STANDARD constructor with ApexPages.currentPage().getParameters() = ' + ApexPages.currentPage().getParameters() + '.###');
        
        String cleanURL;        
        theInvocation = InvocationType.Standard; // This helps us decide what kind of error messages to post later 
        
        // Retrieve the state variables from the page state 
        if (ApexPages.currentPage().getParameters().containsKey('key')) primaryKeyValue = ApexPages.currentPage().getParameters().get('key');
        if (ApexPages.currentPage().getURL() == null) cleanURL = 'BLANK';
        else cleanURL = ApexPages.currentPage().getURL().replaceAll(regex_CleanURL, '').toLowerCase();
        // >> NOTE: We determine the object type by checking whether the Page URL contains the word "family". This is a little kludgy but prevents having to include it as a page parameter.
        if (cleanURL.contains('family')) theObject = SyncEngine.CoreObject.PatentFamily;
        else theObject = SyncEngine.CoreObject.Patent;
        
        // Call the init function
        getRecord();
        
        system.debug('###CoreRecordController(): Exiting constructor.###');        
    }
    
    public CoreRecordController(ApexPages.StandardController controller) {
        // This is the controller for inline visualforce pages
        
        system.debug('###CoreRecordController(): Entering EXTENSION constructor with controller = ' + controller + '.###');
        
        SObject standardRecord;
        String objectName;
        String queryString;
        theInvocation = InvocationType.Extension; // This helps us decide what kind of error messages to post later
        
        // Retrieve the record from the standard controller & set the state variables
        standardRecord = controller.getRecord();
        recordId = standardRecord.Id;
        if (standardRecord instanceof Patent__c) { 
            theObject = SyncEngine.CoreObject.Patent;
            objectName = 'Patent__c';
        } else if (standardRecord instanceof Assets__c) { 
            theObject = SyncEngine.CoreObject.PatentFamily;
            objectName = 'Assets__c';
        }
        
        // Now re-query the standardRecord (to ensure that the primaryKey is included)
        if (theObject != null) { 
            queryString = 'select ' + SyncEngine.PrimaryKey_Salesforce.get(theObject) + ' from ' + objectName + ' where Id = \'' + recordId + '\'';
            standardRecord = Database.query(queryString);
            primaryKeyValue = SyncEngine.getPrimaryKey(standardRecord);
        }
        
        // Call the init function
        getRecord();
        
        system.debug('###CoreRecordController(): Exiting constructor.###');
    }
    
    private void getRecord() {
        // Retrieve the record from the Core API via the Sync Engine
        
        system.debug('###getRecord(): Entering function with theObject = ' + theObject + ', primaryKeyValue = ' + primaryKeyValue + '...###');
        
        // Initialize the rows or fire an error
        if (theObject == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_UNSUPPORTED_OBJECT));
        } else if (primaryKeyValue == null) {
            if (theInvocation == InvocationType.Standard) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_MISSING_KEY_STANDARD));
            else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_MISSING_KEY_EXTENSION + ' (Key Field = ' + SyncEngine.PrimaryKey_Salesforce.get(theObject) + ')'));
        } else {
            try {
                convertedRow = SyncEngine.getCoreRecord(theObject, primaryKeyValue);
                if (convertedRow == null) {
		            if (theInvocation == InvocationType.Standard) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ERROR_BLANK_RESULT + ' (' + SyncEngine.PrimaryKey_Core.get(theObject) + ' = ' + primaryKeyValue + ')'));
		            else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ERROR_BLANK_RESULT + ' (' + SyncEngine.PrimaryKey_Salesforce.get(theObject) + ' = ' + primaryKeyValue + ')'));
		        } else if (convertedRow.childPatents != null) { 
                    // Initialize the child rows if present
                    childPatentRows = new ChildPatentRow[]{};
                    for (Patent__c p:convertedRow.childPatents)
                        if ((p.Country__c == 'US') || (p.Country__c == '') || (p.Country__c == null)) // filter out foreign patents
                            childPatentRows.add(new ChildPatentRow(p));
                }
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_CORE_API  + ' (Error Message: ' + e.getMessage() + ')'));
            }
        }
        
        // Finally, if there was an error and we are in EXTENSION mode, then let's attempt to manually query for the childPatents 
        if ((convertedRow == null) && (recordId != null))
            manuallyQueryChildPatents();
        
        system.debug('###getRecord(): Exiting function with convertedRow = ' + convertedRow + '.###');
    }
    
    private void manuallyQueryChildPatents() {
        // This function helps the patent family related list "revert back" to the normal related list if the API ties are broken
        // NOTE: This function assumes that recordId is not null
        
        system.debug('###manuallyQueryChildPatents(): Entering function with patent family recordId = ' + recordId + '.###');
        
        String queryString;
        Set<String> fieldSet = new Set<String>(); 
        String[] fieldList = new String[]{}; 
        String fieldString;
        Patent__c[] childPatents;
        
        // First build the field list
        for (Schema.FieldSetMember fsm:SObjectType.Patent__c.FieldSets.Patent_Family_Related_List.getFields())
            fieldSet.add(fsm.getFieldPath().toLowerCase());
        fieldSet.add(SyncEngine.PrimaryKey_Salesforce.get(SyncEngine.CoreObject.Patent).toLowerCase());
        fieldList.addAll(fieldSet); // The set helped prevent a duplicate, but we need to have a list to do the join
        fieldString = String.join(fieldList, ', ');
        
        // Now build the query string and do the query
        queryString = 'select ' + fieldString + ' from Patent__c where Patent_Family__r.Id = \'' + recordId + '\'';
        system.debug('###manuallyQueryChildPatents(): Done building queryString = "' + queryString + '".###');
        childPatents = (Patent__c[])Database.query(queryString);
        
        // Finally run through and build out the childPatentRows
        childPatentRows = new ChildPatentRow[]{};
        for (Patent__c p:childPatents)
            childPatentRows.add(new ChildPatentRow(p));
        
        system.debug('###manuallyQueryChildPatents(): Exiting function with childPatentRows = "' + childPatentRows + '".###');
    }
    
    
    
    /*=== ACTIONS ===*/
    
    
    // NO ACTIONS FOR NOW
    
    
}