/****************************************************
   
    SYNC ENGINE CLASS
    
    Built by Hank Ryan Thompson.
    Created 5/7/20013.
    Last updated 10/15/2013 by Hank.
    
    This class helps sync Salesforce with Core DB.
    It contains static functions which convert the
    output of CoreAPI calls into Salesforce records.
    It also provides access to the underlying field
    mappings themselves.
    
    REQUIREMENTS
     - You must create SyncEngineField__c custom
       setting records to store the field mappings.
     - Set the contants below to control the primary
       keys which are used to match and link records.
    
    TO USE THIS CLASS
    
    The following functions query the API details:
     - SyncEngine.getCoreRecord(...)
     - SyncEngine.getPatentsWithPatentFamilies(...)
     - SyncEngine.getPatentFamiliesWithPatents(...)
     - SyncEngine.getAcquisitions(...)
     - SyncEngine.getTechTags(...)
     
    The following functions query & process changes:
     - SyncEngine.getChanges(...)
     - SyncEngine.sortAndFilterChangeRowList(...)
     - SyncEngine.processChanges(...)
     - SyncEngine.syncRecords(...) 
    
    Other potentially useful functions
     - SyncEngine.getFieldMappings(...)
     - SyncEngine.getPrimaryKey(...)
     - SyncEngine.getDetailURL(...)
     - SyncEngine.testSyncEngine_Live(...)
     - SyncEngine.sendEmailToAdmins(...)
    
    
****************************************************/


global class SyncEngine {
    
    /*=== CONSTANTS & ENUMS ===*/
    
    //public static String errorNotificationEmailAddress = 'ryan.hank@gmail.com'; // IMPORTANT: Address to notify in case of sync errors FIXME
    public static String errorNotificationEmailAddress = 'sfdcrequest@rpxcorp.com'; // IMPORTANT: Address to notify in case of sync errors
    
    global enum CoreObject {ClaimChartedCompany, Licensee, Patent, PatentFamily, Acquisition, RelevantCompany, TechTag} // the objects available for syncing (refer to the block quote below for more info)
    public enum Direction {FromCoreToSalesforce, FromSalesforceToCore} // used by the getFieldMappings() function
    /*
        HOW TO ADD A NEW CORE OBJECT: Follow these instructions to add a new syncable object to this class
            0) Before doing these steps you will need to follow the instructions in CoreAPI.cls for adding the new endpoint(s)
            1) Update the enum above and the constant maps immediately below
            2) Create a get______() function (copy and paste another get function as a template)
            3) Search this class for "*CoreObject*" (w/o the quotes) and make changes as instructed
            4) Update the test coverage in SyncEngineTests.cls
            5) IF THE NEW OBJECT NEEDS TO WORK WITH THE CHANGE PROCESSOR:
                >> Search SyncEngineChangeProcessor.cls for "*CoreObject*" (w/o the quotes) and making any necessary changes  
    */
    
    // This following maps store the field names and data types of the PRIMARY key for each sync record in both systems (Core & SFDC)
    // This key will be used to match records and to confirm data validity when converting Core data into Salesforce records
    // The absence of this key in the API response will trigger an error email to system administrators
    // IMPORTANT ADMIN NOTE INCLUDED IN BLOCK QUOTE BELOW (Read before changing primary keys)
    public static Map<CoreObject, String> PrimaryKey_Core = new Map<CoreObject, String> {
        CoreObject.ClaimChartedCompany => 'id',
        CoreObject.Licensee => 'id',
        CoreObject.Patent => 'patnum',
        CoreObject.PatentFamily => 'id',
        CoreObject.Acquisition => 'id',
        CoreObject.RelevantCompany => 'id',
        CoreObject.TechTag => 'id'
    };
    public static Map<CoreObject, String> PrimaryKey_Salesforce = new Map<CoreObject, String> {
        CoreObject.ClaimChartedCompany => 'Core_Claim_Charted_Company_Id__c',
        CoreObject.Licensee => 'Core_Licensee_Id__c',
        CoreObject.Patent => 'Name',
        CoreObject.PatentFamily => 'Core_Patent_Family_Id__c',
        CoreObject.Acquisition => 'Id',
        CoreObject.RelevantCompany => 'Core_Relevant_Company_Id__c',
        CoreObject.TechTag => 'Core_Tech_Tag_Id__c'
    };
    public static Map<CoreObject, Schema.DisplayType> PrimaryKeyType_Salesforce = new Map<CoreObject, Schema.DisplayType> {
        CoreObject.ClaimChartedCompany => Schema.DisplayType.String,
        CoreObject.Licensee => Schema.DisplayType.String,
        CoreObject.Patent => Schema.DisplayType.String,
        CoreObject.PatentFamily => Schema.DisplayType.Double,
        CoreObject.Acquisition => Schema.DisplayType.String,
        CoreObject.RelevantCompany => Schema.DisplayType.String,
        CoreObject.TechTag => Schema.DisplayType.Double
    };
    /*
        HOW TO CHANGE THE PRIMARY KEYS: Changing the primary key fields also (potentially) requires altering the following items:
            1) The content of the mocked web service responses defined in CoreAPI.MockResponseGenerator.respond() >> make sure it contains the new key
            2) The apex test coverage in SyncEngineTests.cls >> Make sure it references the new key
            3) The apex test coverage of any other class that references "CoreAPI.MockResponseGenerator" >> do a search all
            4) SyncEngine.getCoreRecord() >> Update the logic so that it properly converts the primary key into parameters for the endpoint functions
            5) Any code that explicitly references the OLD key field >> do a search all 
    */
    
    // Limit-Focused Constants
    public static Decimal LIMIT_THRESHOLD_CODE_STATEMENTS = 0.9; // how close will we go toward maxing out the code statements limit before we throw an exception? 
    
    // RegEx's used in the SyncEngine
    public static String regex_StrippedPatentNumber = '^(?!RE|PP)[A-Z]{2}|[A-Z]\\d?$'; // selects the country code & kind code
    public static String regex_CountryPatentNumber = '[A-Z]\\d?$'; // selects ony the kind code
    public static String regex_SalesforceId = '^[a-zA-Z0-9]*$'; // matches a properly-formatted salesforce id        
    
    // Object Codes for Changes Endpoint (Add a new item to this map when adding a *CoreObject* with a CHANGES endpoint)
    public static Map<String, CoreObject> changeObjectMap = new Map<String, CoreObject> {
        'pat_claim_charted_company' => CoreObject.ClaimChartedCompany,
        'pat_licensee' => CoreObject.Licensee,
        'patent' => CoreObject.Patent,
        'pat_family' => CoreObject.PatentFamily,
        'portfolio' => CoreObject.Acquisition,
        'tech_tag' => CoreObject.TechTag,
        'pat_relevant_company' => CoreObject.RelevantCompany,
        'pat_tech_tag' => CoreObject.TechTag
    };
    
    /*=== INNER EXCEPTION CLASS ===*/
    
    public class SyncException extends Exception {
        public String errorType; // 'ERROR', 'INFO'
        public SyncException(String errorMessage, String errorType) { this.setMessage(errorMessage); this.errorType = errorType; }
    }
    
    
    
    /*=== CONVERTED RESPONSE ROW INNER CLASS ===*/
    
    public class ConvertedResponseRow {
        
        /*
           
            All of the Core API record detail functions in SyncEngine use this class
            as their return type.  An instance of ConvertedResponseRow represents
            the entire collection of records contained in a CoreAPI.ResponseRow
            instance, but converted into Salesforce records.
            
            Use the {responseObject} property to determine which other properties will be set.
            
            responseObject = PATENT:
              > patent = Always populated
              > patentFamily = Populated if present in the response
              > childPatents = NULL
            
            responseObject = PATENT FAMILY:
              > patent = NULL
              > patentFamily = Always populated
              > childPatents = Populated if present in the response
            
        */
        
        // STATE VARS
        // ADMIN NOTE: When adding a new *CoreObject*, update the state vars, getter & constructor below.
        public CoreObject responseObject; 
        public Accounts_with_Claim_Charts__c claimChartedCompany;
        public Licensees__c licensee;
        public Patent__c patent;
        public Assets__c patentFamily;
        public Acquisition_Opportunity__c acquisition;
        public Potentially_Relevant_Company__c relevantCompany;
        public portfolio2product__c techTag;
        public Patent__c[] childPatents;
        public CoreAPI.ResponseRow originalResponseRow;
        public Map<String, CoreAPI.ResponseRow> originalChildResponseRowMap; // maps from primary key to the original response rows of the children
        private Boolean missingPrimaryKey; // Internally used to weed out invalid data received from Core
        private Boolean conversionError; // Internally used to weed out invalid data received from Core
        private Set<String> missingFieldList; // Used to keep track of which fields were missing for invalid data (only used when conversionError == true)
        
        // GETTER
        public SObject getRecord(CoreObject theObject) {
            if (theObject == CoreObject.ClaimChartedCompany) return claimChartedCompany;
            else if (theObject == CoreObject.Licensee) return licensee;
            else if (theObject == CoreObject.Patent) return patent;
            else if (theObject == CoreObject.PatentFamily) return patentFamily;
            else if (theObject == CoreObject.Acquisition) return acquisition;
            else if (theObject == CoreObject.RelevantCompany) return relevantCompany;
            else if (theObject == CoreObject.TechTag) return techTag;
            else return null;
        }
        
        // CONSTRUCTOR
        public ConvertedResponseRow(CoreObject responseObject) {
            this.responseObject = responseObject;
            this.claimChartedCompany = null;
            this.licensee = null;
            this.patent = null;
            this.patentFamily = null;
            this.acquisition = null;
            this.relevantCompany = null;
            this.techTag = null;
            this.childPatents = new Patent__c[]{};
            this.missingPrimaryKey = false;
            this.conversionError = false;
            this.missingFieldList = new Set<String>();
            this.originalResponseRow = null;
            this.originalChildResponseRowMap = new Map<String, CoreAPI.ResponseRow>();
        }
        
    }
    
    
    
    /*=== CHANGE ROW-RELATED INNER CLASSES ===*/
    /*
    
        Response rows from the Core API changes endpoints are converted into instances of
        this class. This class is the primary object used by the SyncEngineChangeProcessor
        to poll for changes between Core DB and Salesforce.
        
        There are three different classes related to the change rows:
         - ChangeRow: The main class, one instance is created for each change endpont response row
         - ChangeRowIterator: Custom iterator that iterates through a collection of ChangeRows
         - ChangeQueue: Iterable interface that allows the ChangeRowIterator to be used in batch processes
         
    */
    
    
    global class ChangeRow {
        
        // STATE VARS
        global CoreAPI.EndpointName theEndpoint;
        global String action;
        global CoreObject objectType;
        global String objectId;
        global DateTime fromDateTime;
        global Integer resultsPageNumber;
        global Integer resultsNextPageNumber;
        global String processingResult; // set after change is processed
        global Id salesforceRecordId; // set after change is processed
        global String changeSummary; // set after change is processed 
        
        
        // CONSTRUCTOR
        global ChangeRow(CoreAPI.EndpointName theEndpoint, String action, CoreObject objectType, String objectId, DateTime fromDateTime, Integer resultsPageNumber, Integer resultsNextPageNumber) {
            this.theEndpoint = theEndpoint;
            this.action = action;
            this.objectType = objectType;
            this.objectId = objectId;
            this.fromDateTime = fromDateTime;
            this.resultsPageNumber = resultsPageNumber;
            this.resultsNextPageNumber = resultsNextPageNumber;
        }
        
        // CONVERSION FUNCTION
        global Sync_Engine_Change_Item__c convertToSalesforceRecord(String endpointURL) {
            // Converts the ChangeRow to a Sync_Engine_Change_Item__c record
            // NOTE: The endpointURL is a string parameter in order to save execution statements
            
            return new Sync_Engine_Change_Item__c(
                Endpoint__c = endpointURL,
                Action__c = action,
                Sync_Object__c = objectType.name(),
                Core_Object_Key__c = objectId,
                From_Date_Time__c = fromDateTime,
                Results_Page__c = resultsPageNumber,
                Sync_Result__c = processingResult,
                Matched_Salesforce_Record_Id__c = salesforceRecordId,
                Change_Summary__c = changeSummary
            );
        }
        
    }
    
    
    global class ChangeRowIterator implements Iterator<ChangeRow> {
        
        global ChangeRow[] changeRows;
        global Integer index;
        
        global ChangeRowIterator(ChangeRow[] changeRows) {
            system.debug('###ChangeRowIterator(): Entering constructor.###');
            
            this.changeRows = changeRows;
            index = 0;
        }
        
        global boolean hasNext() {
            system.debug('###ChangeRowIterator.hasNext(): Entering function.###');
            
            return (index < changeRows.size());
        }
        
        global ChangeRow next() {
            system.debug('###ChangeRowIterator.next(): Entering function.###');
            
            if (index < changeRows.size()) {
                index++;
                return changeRows[index-1];
            } else return null;
        }
    }
    
    
    global class ChangeQueue implements Iterable<ChangeRow> {
        
        global ChangeRow[] changeRows;
        
        global ChangeQueue(ChangeRow[] changeRows) {
            system.debug('###ChangeQueue(): Entering constructor.###');
            
            this.changeRows = changeRows;
        }
        
        global Iterator<ChangeRow> Iterator() {
            system.debug('###ChangeQueue.Iterator(): Entering function.###');
            
            return new ChangeRowIterator(changeRows);
        }
    
    }
    
    
    
    /*=== DETAILS ENDPOINTS ===*/
    
    
    public static ConvertedResponseRow getCoreRecord(CoreObject objectType, String primaryKeyValue) {
        // This function returns a single record from Core, by querying the appropriate endpoint function below with the supplied [primaryKeyValue].
        // This function works best when the [primaryKeyValue] has already been verified by using the endpoint functions to search
        // >> Companion functions: getDetailURL(), getPrimaryKey()

        system.debug('###getCoreRecord(): Entering function with objectType = ' + objectType + ', primaryKeyValue = ' + primaryKeyValue + '.###');

        ConvertedResponseRow[] convertedRows;
        ConvertedResponseRow matchRow;
        
        if (objectType == CoreObject.Patent) {
            // NOTE: We're assuming that the primary key is Patent__c.Name == CorePatent.patnum
            
            // First we strip the patent number and query for the converted rows
            String strippedPatentNumber = primaryKeyValue.trim().toUpperCase().replaceAll(regex_StrippedPatentNumber, '');
            String countryPatentNumber = primaryKeyValue.trim().toUpperCase().replaceAll(regex_CountryPatentNumber, ''); //We use this one to do the matching
            convertedRows = getPatentsWithPatentFamilies(new String[]{strippedPatentNumber});
            system.debug('###getCoreRecord(): In patent branch with strippedPatentNumber = ' + strippedPatentNumber + ', countryPatentNumber = ' + countryPatentNumber + '.###');
            
            // Now we run through the results and select the match (if it exists)
            for (ConvertedResponseRow potentialMatchRow:convertedRows)
                if (getPrimaryKey(potentialMatchRow.patent).toUpperCase().replaceAll(regex_CountryPatentNumber, '') == countryPatentNumber) {
                    matchRow = potentialMatchRow;
                    break;
                }
        } else if (objectType == CoreObject.PatentFamily) {
            // NOTE: We're assuming that the primary key is Assets__c.Core_DB_Patent_ID__c == CorePatent.id
            
            // First we query for the converted rows (the primary key needs no conversion)
            convertedRows = getPatentFamiliesWithPatents(null, new String[]{primaryKeyValue}, null, null);
            
            // Now we run through the results and select the match (if it exists)
            for (ConvertedResponseRow potentialMatchRow:convertedRows)
                if (getPrimaryKey(potentialMatchRow.patentFamily) == primaryKeyValue) {
                    matchRow = potentialMatchRow;
                    break;
                }
        } else throw new SyncException('Unsupported object type.', 'ERROR');
        
        // Done!
        system.debug('###getCoreRecord(): Done filtering convertedRows = ' + convertedRows + ', returning matchRow = ' + matchRow + '.###');
        return matchRow;
    }



    public static ConvertedResponseRow[] getClaimChartedCompanies(String[] claimChartedCompanyIds, String[] salesforcePatentIds, String[] salesforceAccountIds) {return getClaimChartedCompanies(claimChartedCompanyIds, salesforcePatentIds, salesforceAccountIds, true);}
    public static ConvertedResponseRow[] getClaimChartedCompanies(String[] claimChartedCompanyIds, String[] salesforcePatentIds, String[] salesforceAccountIds, Boolean sendErrorEmail) {
        // This function queries CoreAPI.getClaimChartedCompanies() with the supplied search parameters
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // For more info refer to the comments for the convertAndMatchResponseRows() function.
        
        system.debug('###getClaimChartedCompanies(): Entering function with claimChartedCompanyIds = ' + claimChartedCompanyIds + ', salesforcePatentIds = ' + salesforcePatentIds + ', salesforceAccountIds = ' + salesforceAccountIds + '.###');
        CoreAPI.ResponseRow[] responseRows; ConvertedResponseRow[] convertedRows;
        responseRows = CoreAPI.getClaimChartedCompanies(claimChartedCompanyIds, salesforcePatentIds, salesforceAccountIds);
        //system.debug('###getClaimChartedCompanies(): Done getting rows from API, about to convert them. responseRows = ' + responseRows + '.###');
        
        // Then convert & match the rows
        convertedRows = matchAndConvertResponseRows(responseRows, CoreObject.ClaimChartedCompany, sendErrorEmail);
        //system.debug('###getClaimChartedCompanies(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }
    
    public static ConvertedResponseRow[] getLicensees(String[] licenseeIds, String[] salesforcePatentIds, String[] salesforceAccountIds) {return getLicensees(licenseeIds, salesforcePatentIds, salesforceAccountIds, true);}
    public static ConvertedResponseRow[] getLicensees(String[] licenseeIds, String[] salesforcePatentIds, String[] salesforceAccountIds, Boolean sendErrorEmail) {
        // This function queries CoreAPI.getLicensees() with the supplied search parameters
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // For more info refer to the comments for the convertAndMatchResponseRows() function.
        
        system.debug('###getLicensees(): Entering function with licenseeIds = ' + licenseeIds + ', salesforcePatentIds = ' + salesforcePatentIds + ', salesforceAccountIds = ' + salesforceAccountIds + '.###');
        CoreAPI.ResponseRow[] responseRows; ConvertedResponseRow[] convertedRows;
        responseRows = CoreAPI.getLicensees(licenseeIds, salesforcePatentIds, salesforceAccountIds);
        //system.debug('###getLicensees(): Done getting rows from API, about to convert them. responseRows = ' + responseRows + '.###');
        
        // Then convert & match the rows
        convertedRows = matchAndConvertResponseRows(responseRows, CoreObject.Licensee, sendErrorEmail);
        //system.debug('###getLicensees(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }
    
    public static ConvertedResponseRow[] getPatentsWithPatentFamilies(String[] strippedPatentNumbers) {return getPatentsWithPatentFamilies(strippedPatentNumbers, true);}

    public static ConvertedResponseRow[] getPatentsWithPatentFamilies(String[] strippedPatentNumbers, Boolean sendErrorEmail) {
        // This function queries CoreAPI.getPatents() with the supplied search parameter (it includes all return options)
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // NOTE: This function also queries getPatentAnnotations() & getTechTags() and merges the results into the returned rows
        // For more info refer to the comments for the convertAndMatchResponseRows() function.

        system.debug('###getPatentsWithPatentFamilies(): Entering function with strippedPatentNumbers = ' + strippedPatentNumbers + '.###');

        CoreAPI.ResponseRow[] responseRows_Patents; CoreAPI.ResponseRow[] responseRows_PatentAnnotations; CoreAPI.ResponseRow[] responseRows_TechTags;
        ConvertedResponseRow[] convertedRows;
        String[] countryPatentNumbers = new String[]{};
        Map<String, CoreAPI.ResponseRow> patentRowMap = new Map<String, CoreAPI.ResponseRow>(); //maps from COUNTRY pat num to the patent row
        String patentKey;
        
        // First build countryPatentNumbers (we assume everything is US)
        for (String strippedPatentNumber:strippedPatentNumbers)
            countryPatentNumbers.add('US' + strippedPatentNumber);
        //system.debug(LoggingLevel.ERROR, '###getPatentsWithPatentFamilies(): Done building countryPatentNumbers = ' + countryPatentNumbers + '.###');
        
        // Query the three different API endpoints
        responseRows_Patents = CoreAPI.getPatents(strippedPatentNumbers, true, true, true);
        responseRows_PatentAnnotations = CoreAPI.getPatentAnnotations(countryPatentNumbers);
        responseRows_TechTags = CoreAPI.getTechTags(countryPatentNumbers);
        
        // Now merge everything together. First build a map of the patent rows, then run through the other responses and merge them in.
        for (CoreAPI.ResponseRow patentRow:responseRows_Patents)
            patentRowMap.put(patentRow.singleValues.get('country') + patentRow.singleValues.get('stripped_patnum'), patentRow);
        for (CoreAPI.ResponseRow annotationRow:responseRows_PatentAnnotations) {
            patentKey = annotationRow.singleValues.get('patent_key');
            if (patentRowMap.get(patentKey) != null) patentRowMap.get(patentKey).singleValues.putAll(annotationRow.singleValues);
        }
        for (CoreAPI.ResponseRow techTagRow:responseRows_TechTags) {
            patentKey = techTagRow.singleValues.get('patent_key');
            if (patentRowMap.get(patentKey) != null) {
                if (patentRowMap.get(patentKey).listChildren.containsKey('tech_tags'))
                    patentRowMap.get(patentKey).listChildren.get('tech_tags').add(techTagRow);
                else
                    patentRowMap.get(patentKey).listChildren.put('tech_tags', new CoreAPI.ResponseRow[]{techTagRow});
            }
        }
        
        // Then convert & match the rows
        //system.debug(LoggingLevel.ERROR, '###getPatentsWithPatentFamilies(): Done getting rows from API and merging them together, about to convert them. responseRows_Patents = ' + CoreAPI.responseRowListToString(responseRows_Patents, '*') + '.###');
        convertedRows = matchAndConvertResponseRows(responseRows_Patents, CoreObject.Patent, sendErrorEmail);
        
        // Done!
        //system.debug(LoggingLevel.ERROR, '###getPatentsWithPatentFamilies(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }


    public static ConvertedResponseRow[] getPatentFamiliesWithPatents(String[] applicationNumbers, String[] patentFamilyIds, String[] publicationNumbers, String[] countryPatentNumbers) {
        // This is an old version of function for backwards compatibility
        return getPatentFamilies(applicationNumbers, patentFamilyIds, publicationNumbers, countryPatentNumbers, true);
    }
                    
    
    public static ConvertedResponseRow[] getPatentFamilies(String[] applicationNumbers, String[] patentFamilyIds, String[] publicationNumbers, String[] countryPatentNumbers, Boolean includePatents) {return getPatentFamilies(applicationNumbers, patentFamilyIds, publicationNumbers, countryPatentNumbers, includePatents, true);}
    public static ConvertedResponseRow[] getPatentFamilies(String[] applicationNumbers, String[] patentFamilyIds, String[] publicationNumbers, String[] countryPatentNumbers, Boolean includePatents, Boolean sendErrorEmail) {
        // This function queries CoreAPI.getPatentFamilies() with the supplied search parameters (You may set one or more at a time) and includes all return options
        // It also queries CoreAPI.getPatents() for each returned patent and merges the results into the patent family childPatents list
        // NOTE: If [countryPatentNumbers] is used, this function will also query three additional endpoints (and will also return parent-less patents)
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // For more info refer to the comments for the convertAndMatchResponseRows() function.

        system.debug('###getPatentFamilies(): Entering function with applicationNumbers = ' + applicationNumbers + ', patentFamilyIds = ' + patentFamilyIds + ', publicationNumbers = ' + publicationNumbers + ', countryPatentNumbers = ' + countryPatentNumbers + '.###');

        CoreAPI.ResponseRow[] patentFamilyResponseRows; CoreAPI.ResponseRow[] techTagResponseRows; CoreAPI.ResponseRow[] patentAnnotationResponseRows;
        CoreAPI.ResponseRow[] patentResponseRows = new CoreAPI.ResponseRow[]{};
        ConvertedResponseRow[] convertedRows;
        String[] strippedPatentNumbers;
        Set<String> allCountryPatentNumbers = new Set<String>(); String[] allCountryPatentNumbers_List = new String[]{};
        Map<String, CoreAPI.ResponseRow> fullPatentRowMap = new Map<String, CoreAPI.ResponseRow>(); //maps from country + stripped_patnum to the patent response row from the patents endpoint 
        CoreAPI.ResponseRow[] blankFamilyPatentList = new CoreAPI.ResponseRow[]{}; 
        CoreAPI.ResponseRow[] newPatentList;
        String patentKey;
        
        // First query the API for the response rows (set the patent fields based on {includePatents}, always include rollup fields)
        patentFamilyResponseRows = CoreAPI.getPatentFamilies(applicationNumbers, patentFamilyIds, publicationNumbers, countryPatentNumbers, includePatents, includePatents, includePatents, includePatents, includePatents, true);
        //system.debug('###getPatentFamilies(): Done getting patentFamilyResponseRows from API. patentFamilyResponseRows = ' + patentFamilyResponseRows + '.###');
        
        
        if (includePatents) {
            // Now go through and build a list of stripped patnums to query against the patents endpoint
            // First add the stripped countryPatnums (if provided)... this allows the inclusion of blank patent family records
            if (countryPatentNumbers == null) strippedPatentNumbers = new String[]{};
            else strippedPatentNumbers = replaceAllInList(countryPatentNumbers, regex_StrippedPatentNumber, '');
            
            // Then run through the patent family response rows and add all the extra children  
            for (CoreAPI.ResponseRow patentFamilyRow:patentFamilyResponseRows)
                if (patentFamilyRow.listChildren.containsKey('patents'))
                    for (CoreAPI.ResponseRow patentRow:patentFamilyRow.listChildren.get('patents')) {
                        strippedPatentNumbers.add(patentRow.singleValues.get('stripped_patnum'));
                        allCountryPatentNumbers.add(patentRow.singleValues.get('country') + patentRow.singleValues.get('stripped_patnum'));
                    }
            
            // Then re-query the other endpoint (if needed) for those patents (to get the extra fields) and build the map
            if (strippedPatentNumbers.size() > 0) {
                strippedPatentNumbers.addAll(strippedPatentNumbers);
                allCountryPatentNumbers_List.addAll(allCountryPatentNumbers);
                patentResponseRows = CoreAPI.getPatents(strippedPatentNumbers, true, true, true);
                patentAnnotationResponseRows = CoreAPI.getPatentAnnotations(allCountryPatentNumbers_List);
                techTagResponseRows = CoreAPI.getTechTags(allCountryPatentNumbers_List);
                
                // process the full patent rows (and create a map)
                for (CoreAPI.ResponseRow fullPatentRow:patentResponseRows) {
                    if (fullPatentRow.singleChildren.containsKey('patent_family')) { 
                        if (fullPatentRow.singleChildren.get('patent_family').singleValues.get('id') == '0')
                            blankFamilyPatentList.add(fullPatentRow);
                        //fullPatentRow.singleChildren.remove('patent_family'); // now that we've checked the family, we can remove the key (so it doesn't trigger recursion in the conversion function) >> UPDATE: Now that all fields are required we need the recursion
                    }
                    fullPatentRowMap.put(fullPatentRow.singleValues.get('country') + fullPatentRow.singleValues.get('stripped_patnum'), fullPatentRow);
                }
                //system.debug('###getPatentFamilies(): Extracted strippedPatentNumbers = ' + strippedPatentNumbers + ', then queried patentResponseRows = ' + patentResponseRows + ', then built fullPatentRowMap = ' + fullPatentRowMap + '.###');
                
                // then go through the annotations & tech tags and merge those into the full patent rows
                if(patentAnnotationResponseRows!=null)
                for (CoreAPI.ResponseRow annotationRow:patentAnnotationResponseRows) {
                    patentKey = annotationRow.singleValues.get('patent_key');
                    if (fullPatentRowMap.get(patentKey) != null) fullPatentRowMap.get(patentKey).singleValues.putAll(annotationRow.singleValues);
                }
                if(techTagResponseRows!=null)
                for (CoreAPI.ResponseRow techTagRow:techTagResponseRows) {
                    patentKey = techTagRow.singleValues.get('patent_key');
                    if (fullPatentRowMap.get(patentKey) != null) {
                        if (fullPatentRowMap.get(patentKey).listChildren.containsKey('tech_tags'))
                            fullPatentRowMap.get(patentKey).listChildren.get('tech_tags').add(techTagRow);
                        else
                            fullPatentRowMap.get(patentKey).listChildren.put('tech_tags', new CoreAPI.ResponseRow[]{techTagRow});
                    }
                }
                
                
                // Next go back through the patent family rows and merge in the full patent rows
                for (CoreAPI.ResponseRow patentFamilyRow:patentFamilyResponseRows)
                    if (patentFamilyRow.listChildren.containsKey('patents')) {
                        newPatentList = new CoreAPI.ResponseRow[]{};
                        
                        for (CoreAPI.ResponseRow patentRow:patentFamilyRow.listChildren.get('patents'))
                            if (fullPatentRowMap.containsKey(patentRow.singleValues.get('country') + patentRow.singleValues.get('stripped_patnum')))
                                newPatentList.add(fullPatentRowMap.get(patentRow.singleValues.get('country') + patentRow.singleValues.get('stripped_patnum')));
                            else
                                newPatentList.add(patentRow); // default back to the original if something goes wrong
                        
                        patentFamilyRow.listChildren.put('patents', newPatentList); //overwrite the existing listChild
                    }
                    
                
                // If there were any blank family patents, then create a pfamily row for them and insert it in the beginning of the list 
                if (blankFamilyPatentList.size() > 0) {
                    CoreAPI.ResponseRow blankPatentFamilyRow = new CoreAPI.ResponseRow('blank_family_patents');
                    blankPatentFamilyRow.singleValues.put('id', '0');
                    blankPatentFamilyRow.listChildren.put('patents', blankFamilyPatentList);
                    
                    CoreAPI.ResponseRow[] tempPatentFamilyResponseRows = patentFamilyResponseRows;
                    patentFamilyResponseRows = new CoreAPI.ResponseRow[]{blankPatentFamilyRow}; // insert the blank row at the top of the list
                    patentFamilyResponseRows.addAll(tempPatentFamilyResponseRows); // then add the rest
                }
                
                //system.debug('###getPatentFamilies(): Done merging in the queried patent rows. patentFamilyResponseRows = ' + patentFamilyResponseRows + '.###');
            }
        }
        
        // Then convert & match the rows 
        convertedRows = matchAndConvertResponseRows(patentFamilyResponseRows, CoreObject.PatentFamily, sendErrorEmail);
        
        // Done!
        //system.debug('###getPatentFamilies(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }
   
    
    
    public static ConvertedResponseRow[] getPatentFamiliesSearchPage(String[] applicationNumbers, String[] patentFamilyIds, String[] publicationNumbers, String[] countryPatentNumbers, Boolean includePatents, Boolean sendErrorEmail) {
    	//THIS METHOD ONLY FOR THE INVOCATION FROM THE PAGE. IT EXCLUDES THE CALLOUTS TO ANNOTATIONS AND TECH TAGS.
    	 
    	// This function queries CoreAPI.getPatentFamilies() with the supplied search parameters (You may set one or more at a time) and includes all return options
        // It also queries CoreAPI.getPatents() for each returned patent and merges the results into the patent family childPatents list
        // NOTE: If [countryPatentNumbers] is used, this function will also query three additional endpoints (and will also return parent-less patents)
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // For more info refer to the comments for the convertAndMatchResponseRows() function.

        system.debug('###getPatentFamilies(): Entering function with applicationNumbers = ' + applicationNumbers + ', patentFamilyIds = ' + patentFamilyIds + ', publicationNumbers = ' + publicationNumbers + ', countryPatentNumbers = ' + countryPatentNumbers + '.###');

        CoreAPI.ResponseRow[] patentFamilyResponseRows; CoreAPI.ResponseRow[] techTagResponseRows; CoreAPI.ResponseRow[] patentAnnotationResponseRows;
        CoreAPI.ResponseRow[] patentResponseRows = new CoreAPI.ResponseRow[]{};
        ConvertedResponseRow[] convertedRows;
        String[] strippedPatentNumbers;
        Set<String> allCountryPatentNumbers = new Set<String>(); String[] allCountryPatentNumbers_List = new String[]{};
        Map<String, CoreAPI.ResponseRow> fullPatentRowMap = new Map<String, CoreAPI.ResponseRow>(); //maps from country + stripped_patnum to the patent response row from the patents endpoint 
        CoreAPI.ResponseRow[] blankFamilyPatentList = new CoreAPI.ResponseRow[]{}; 
        CoreAPI.ResponseRow[] newPatentList;
        String patentKey;
        
        // First query the API for the response rows (set the patent fields based on {includePatents}, always include rollup fields)
        patentFamilyResponseRows = CoreAPI.getPatentFamilies(applicationNumbers, patentFamilyIds, publicationNumbers, countryPatentNumbers, includePatents, includePatents, includePatents, includePatents, includePatents, true);
        //system.debug('###getPatentFamilies(): Done getting patentFamilyResponseRows from API. patentFamilyResponseRows = ' + patentFamilyResponseRows + '.###');
        
        
        if (includePatents) {
            // Now go through and build a list of stripped patnums to query against the patents endpoint
            // First add the stripped countryPatnums (if provided)... this allows the inclusion of blank patent family records
            if (countryPatentNumbers == null) strippedPatentNumbers = new String[]{};
            else strippedPatentNumbers = replaceAllInList(countryPatentNumbers, regex_StrippedPatentNumber, '');
            
            // Then run through the patent family response rows and add all the extra children  
            for (CoreAPI.ResponseRow patentFamilyRow:patentFamilyResponseRows)
                if (patentFamilyRow.listChildren.containsKey('patents'))
                    for (CoreAPI.ResponseRow patentRow:patentFamilyRow.listChildren.get('patents')) {
                        strippedPatentNumbers.add(patentRow.singleValues.get('stripped_patnum'));
                        allCountryPatentNumbers.add(patentRow.singleValues.get('country') + patentRow.singleValues.get('stripped_patnum'));
                    }
            
            // Then re-query the other endpoint (if needed) for those patents (to get the extra fields) and build the map
            if (strippedPatentNumbers.size() > 0) {
                strippedPatentNumbers.addAll(strippedPatentNumbers);
                allCountryPatentNumbers_List.addAll(allCountryPatentNumbers);
                patentResponseRows = CoreAPI.getPatents(strippedPatentNumbers, true, true, true);
                //patentAnnotationResponseRows = CoreAPI.getPatentAnnotations(allCountryPatentNumbers_List);
                //techTagResponseRows = CoreAPI.getTechTags(allCountryPatentNumbers_List);
                
                // process the full patent rows (and create a map)
                for (CoreAPI.ResponseRow fullPatentRow:patentResponseRows) {
                    if (fullPatentRow.singleChildren.containsKey('patent_family')) { 
                        if (fullPatentRow.singleChildren.get('patent_family').singleValues.get('id') == '0')
                            blankFamilyPatentList.add(fullPatentRow);
                        //fullPatentRow.singleChildren.remove('patent_family'); // now that we've checked the family, we can remove the key (so it doesn't trigger recursion in the conversion function) >> UPDATE: Now that all fields are required we need the recursion
                    }
                    fullPatentRowMap.put(fullPatentRow.singleValues.get('country') + fullPatentRow.singleValues.get('stripped_patnum'), fullPatentRow);
                }
                //system.debug('###getPatentFamilies(): Extracted strippedPatentNumbers = ' + strippedPatentNumbers + ', then queried patentResponseRows = ' + patentResponseRows + ', then built fullPatentRowMap = ' + fullPatentRowMap + '.###');                               
                                                
                
                // Next go back through the patent family rows and merge in the full patent rows
                for (CoreAPI.ResponseRow patentFamilyRow:patentFamilyResponseRows)
                    if (patentFamilyRow.listChildren.containsKey('patents')) {
                        newPatentList = new CoreAPI.ResponseRow[]{};
                        
                        for (CoreAPI.ResponseRow patentRow:patentFamilyRow.listChildren.get('patents'))
                            if (fullPatentRowMap.containsKey(patentRow.singleValues.get('country') + patentRow.singleValues.get('stripped_patnum')))
                                newPatentList.add(fullPatentRowMap.get(patentRow.singleValues.get('country') + patentRow.singleValues.get('stripped_patnum')));
                            else
                                newPatentList.add(patentRow); // default back to the original if something goes wrong
                        
                        patentFamilyRow.listChildren.put('patents', newPatentList); //overwrite the existing listChild
                    }
                    
                
                // If there were any blank family patents, then create a pfamily row for them and insert it in the beginning of the list 
                if (blankFamilyPatentList.size() > 0) {
                    CoreAPI.ResponseRow blankPatentFamilyRow = new CoreAPI.ResponseRow('blank_family_patents');
                    blankPatentFamilyRow.singleValues.put('id', '0');
                    blankPatentFamilyRow.listChildren.put('patents', blankFamilyPatentList);
                    
                    CoreAPI.ResponseRow[] tempPatentFamilyResponseRows = patentFamilyResponseRows;
                    patentFamilyResponseRows = new CoreAPI.ResponseRow[]{blankPatentFamilyRow}; // insert the blank row at the top of the list
                    patentFamilyResponseRows.addAll(tempPatentFamilyResponseRows); // then add the rest
                }
                
                //system.debug('###getPatentFamilies(): Done merging in the queried patent rows. patentFamilyResponseRows = ' + patentFamilyResponseRows + '.###');
            }
        }
        
        // Then convert & match the rows 
        convertedRows = matchAndConvertResponseRows(patentFamilyResponseRows, CoreObject.PatentFamily, sendErrorEmail);
        
        // Done!
        //system.debug('###getPatentFamilies(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }
    
    
    
    public static ConvertedResponseRow[] getAcquisitions(String[] acquisitionIds) {return getAcquisitions(acquisitionIds, true);}
    public static ConvertedResponseRow[] getAcquisitions(String[] acquisitionIds, Boolean sendErrorEmail) {
        // This function queries CoreAPI.getPortfolios() with the supplied search parameter
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // For more info refer to the comments for the convertAndMatchResponseRows() function.
        // NOTE: Acquisitions are called "Portfolios" in the Core API, but it's the same object.
        
        system.debug('###getAcquisitions(): Entering function with acquisitionIds = ' + acquisitionIds + '.###');
        CoreAPI.ResponseRow[] responseRows; ConvertedResponseRow[] convertedRows;
        responseRows = CoreAPI.getPortfolios(acquisitionIds);
        //system.debug('###getAcquisitions(): Done getting rows from API, about to convert them. responseRows = ' + responseRows + '.###');
        
        // Then convert & match the rows
        convertedRows = matchAndConvertResponseRows(responseRows, CoreObject.Acquisition, sendErrorEmail);
        //system.debug('###getAcquisitions(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }
    
    public static ConvertedResponseRow[] getRelevantCompanies(String[] relevantCompanyIds, String[] salesforcePatentIds, String[] salesforceAccountIds) {return getRelevantCompanies(relevantCompanyIds, salesforcePatentIds, salesforceAccountIds, true);}
    public static ConvertedResponseRow[] getRelevantCompanies(String[] relevantCompanyIds, String[] salesforcePatentIds, String[] salesforceAccountIds, Boolean sendErrorEmail) {
        // This function queries CoreAPI.getRelevantCompanies() with the supplied search parameters
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // For more info refer to the comments for the convertAndMatchResponseRows() function.
        
        system.debug('###getRelevantCompanies(): Entering function with relevantCompanyIds = ' + relevantCompanyIds + ', salesforcePatentIds = ' + salesforcePatentIds + ', salesforceAccountIds = ' + salesforceAccountIds + '.###');
        CoreAPI.ResponseRow[] responseRows; ConvertedResponseRow[] convertedRows;
        responseRows = CoreAPI.getRelevantCompanies(relevantCompanyIds, salesforcePatentIds, salesforceAccountIds);
        //system.debug('###getRelevantCompanies(): Done getting rows from API, about to convert them. responseRows = ' + responseRows + '.###');
        
        // Then convert & match the rows
        convertedRows = matchAndConvertResponseRows(responseRows, CoreObject.RelevantCompany, sendErrorEmail);
        //system.debug('###getRelevantCompanies(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }
    
    public static ConvertedResponseRow[] getTechTags(String[] countryPatentNumbers, String[] techTagIds) {return getTechTags(countryPatentNumbers, techTagIds, true);}
    public static ConvertedResponseRow[] getTechTags(String[] countryPatentNumbers, String[] techTagIds, Boolean sendErrorEmail) {
        // This function queries CoreAPI.getTechTags() with the supplied search parameter
        // Then it converts them and matches them with salesforce records (matched records will have their "Id" field set to indicate the match)
        // For more info refer to the comments for the convertAndMatchResponseRows() function.
        
        system.debug('###getTechTags(): Entering function with countryPatentNumbers = ' + countryPatentNumbers + '.###');
        CoreAPI.ResponseRow[] responseRows; ConvertedResponseRow[] convertedRows;
        responseRows = CoreAPI.getTechTags(countryPatentNumbers, techTagIds);
        //system.debug('###getTechTags(): Done getting rows from API, about to convert them. responseRows = ' + responseRows + '.###');
        
        // Then convert & match the rows
        convertedRows = matchAndConvertResponseRows(responseRows, CoreObject.TechTag, sendErrorEmail);
        //system.debug('###getTechTags(): Done converting & matching convertedRows = ' + convertedRows + '.###');
        return convertedRows;
    }
    
    
    
    /*=== CHANGES ENDPOINTS ===*/
    
    
    public static ChangeRow[] getChanges(CoreAPI.EndpointName theEndpoint, Integer pageSize, DateTime fromDateTime, Integer pageNumber) {
        // This function queries the specified changes endpoint for the next page of changes.
        // (Based on the Last Sync Date Time and Next Sync Page fields on the CoreAPIAuthentication__c setting record)
        // It then converts the response rows into ChangeRows and updates the setting record to point at the next page of changes.
        // ERROR NOTE: Any invalidly formatted change rows will trigger an error email to admins. 
        
        system.debug('###getChanges(): Entering function with theEndpoint = ' + theEndpoint + ', fromDateTime = ' + fromDateTime + ', pageNumber = ' + pageNumber + '.###');
        
        String errorEmailBody = ''; String errorEmailSubject = 'Sync Engine Change Processor: Invalid responses from changes endpoint';
        CoreAPI.PaginatedResponse responseObject;
        CoreAPI.ResponseRow[] errorRows = new CoreAPI.ResponseRow[]{};
        ChangeRow[] changeRows = new ChangeRow[]{};
        Integer nextPageNumber; DateTime queryDateTime;
        String objectId; String action; CoreObject objectType;
        Pattern salesforceIdPattern = Pattern.compile(regex_SalesforceId); // weeds out invalid ids
        
        // Next query the api for the changes (and record the precise time of the api call for later)
        // ADMIN NOTE: When adding a new *CoreObject* with a CHANGES endpoint, add a logic branch below.
        queryDateTime = DateTime.now();
        if (theEndpoint == CoreAPI.EndpointName.ClaimChartedCompanyChanges) responseObject = CoreAPI.getClaimChartedCompanyChanges(fromDateTime, pageNumber, pageSize);
        else if (theEndpoint == CoreAPI.EndpointName.LicenseeChanges) responseObject = CoreAPI.getLicenseeChanges(fromDateTime, pageNumber, pageSize);
        else if (theEndpoint == CoreAPI.EndpointName.PatentAnnotationChanges) responseObject = CoreAPI.getPatentAnnotationChanges(fromDateTime, pageNumber, pageSize);
        else if (theEndpoint == CoreAPI.EndpointName.PatentFamilyChanges) responseObject = CoreAPI.getPatentFamilyChanges(fromDateTime, pageNumber, pageSize);
        else if (theEndpoint == CoreAPI.EndpointName.PortfolioAnnotationChanges) responseObject = CoreAPI.getPortfolioAnnotationChanges(fromDateTime, pageNumber, pageSize);
        else if (theEndpoint == CoreAPI.EndpointName.RelevantCompanyChanges) responseObject = CoreAPI.getRelevantCompanyChanges(fromDateTime, pageNumber, pageSize);
        else if (theEndpoint == CoreAPI.EndpointName.TechTagChanges) responseObject = CoreAPI.getTechTagChanges(fromDateTime, pageNumber, pageSize);
        else throw new SyncException('Unsupported endpoint for getChanges(): ' + theEndpoint.name(), 'ERROR');
        nextPageNumber = responseObject.nextPage;
        
        // Process the returned rows (filter out invalid rows and convert valid ones)
        for (CoreAPI.ResponseRow responseRow:responseObject.responseRows) {
            action = responseRow.singleValues.get('action');
            objectType = changeObjectMap.get(responseRow.singleValues.get('obj_type'));
            objectId = responseRow.singleValues.get('obj_id');
            
            if ((action == null) || (objectType == null) || (objectId == null) || (action == '') || (objectId == ''))
                errorRows.add(responseRow);
            else if ((objectType == CoreObject.Acquisition) && !salesforceIdPattern.matcher(objectId).find())
                errorRows.add(responseRow); // this is not a valid salesforce id
            else {
                changeRows.add(new ChangeRow(theEndpoint, action, objectType, objectId, fromDateTime, pageNumber, nextPageNumber)); 
            }
        }
        
        // Send an email if there are any errors 
        if (errorRows.size() > 0) {
            errorEmailBody = 'An error was encountered during the regular operation of the SyncEngineChangeProcessor: One or more invalid rows were returned by one of the changes API endpoints. (They either had blank values or invalid salesforce ids.) Full details are included below.\n\n';
            errorEmailBody += 'Endpoint Name: ' + theEndpoint.name() + '.\n';
            errorEmailBody += 'Endpoint URL: ' + CoreAPI.getEndpointURL(theEndpoint) + '.\n\n';
            errorEmailBody += 'INVALID RESPONSE ROWS:\n';
            errorEmailBody += CoreAPI.responseRowListToString(errorRows, '*'); //we're using the special string conversion function so we can force the string output to include ALL of the keys
            if (!Test.isRunningTest()) sendEmailToAdmins(errorEmailSubject, errorEmailBody, null);
        }
        
        //system.debug('###getChanges(): Exiting function with changeRows = ' + changeRows + '.###');
        return changeRows;
    }
    
    public static ChangeRow[] sortAndFilterChangeRowList(ChangeRow[] changeRows) {
        // This function compresses the passed changeRowList by removing duplicates and by grouping the rows by objectType
        // It also REMOVES patent family rows (since they are duplicate information)
        // NOTE: This function may result in the "action" property being lost.
        // NOTE: Any action which contains "delete" will ALWAYS be preserved and will override any other action values.
        
        Map<CoreObject, Map<String, ChangeRow>> changeRowMap = new Map<CoreObject, Map<String, ChangeRow>>(); // maps from object type to map from object id to unique change row  
        ChangeRow[] fixedRowList = new ChangeRow[]{};
        ChangeRow existingRow;
        
        // Build the map
        for (ChangeRow row:changeRows)
            if (row.objectType != CoreObject.PatentFamily) { //filter out patent families
                if (!changeRowMap.containsKey(row.objectType)) changeRowMap.put(row.objectType, new Map<String, ChangeRow>());
                
                // Filter the objectId of patents (this makes sure they are all country+stripped patent number)
                if (row.objectType == CoreObject.Patent) row.objectId = row.objectId.trim().toUpperCase().replaceAll(regex_CountryPatentNumber, '');
                
                if (changeRowMap.get(row.objectType).containsKey(row.objectId)) { 
                    // We need to intelligently "merge" the actions. If one of them is "deleted" then we must preserve it, otherwise just set it to [multiple]
                    existingRow = changeRowMap.get(row.objectType).get(row.objectId);
                    
                    if (row.action != existingRow.action) {
                       if (row.action.contains('delete')) existingRow.action = row.action;
                       else if (!existingRow.action.contains('delete')) existingRow.action = '[multiple]';
                    }
                } else
                    changeRowMap.get(row.objectType).put(row.objectId, row);
            }   
        
        // Put it back into a list
        for (CoreObject co:changeRowMap.keySet())
            for (ChangeRow row:changeRowMap.get(co).values())
                fixedRowList.add(row);
        
        return fixedRowList;
    }
    
    public static ChangeRow[] processChanges(ChangeRow[] changeRows) {
        // This function processes the passed change rows, queries the appropriate details endpoint and syncs changes between Core and Salesforce.
        // The function returns the processed changeRows with the salesforceRecordId & processingResult fields set
        // ERROR NOTE: Any invalidly formatted change rows will trigger an error email to admins. 
        // ADMIN NOTE: This function is technically designed in such a way that it *could* support receiving a collection of [changeRows] that 
        //             contain different object types, but no testing has been done towards this end (since it isn't part of the initial spec).
        //             So for now the only supported use is of a SINGLE object type per call to processChanges().
        
        system.debug('###processChanges(): Entering function with ' + changeRows + ' changeRows.###');
        
        String errorEmailBody = ''; String errorEmailSubject = 'Sync Engine Change Processor: Records missing from Salesforce';
        ConvertedResponseRow[] errorRows_ToUpdate = new ConvertedResponseRow[]{}; // for unmatched rows that need updating
        ChangeRow[] errorRows_ToDelete = new ChangeRow[]{}; // for unmatched rows that need deleting
        Set<String> patentKeys = new Set<String>(); Set<Id> acquisitionIds = new Set<Id>(); Set<String> techTagKeys = new Set<String>(); Set<String> patentKeysForTechTags = new Set<String>();
        Map<CoreObject, Map<String, ChangeRow>> changeRowMap = new Map<CoreObject, Map<String, ChangeRow>>(); // maps from object type to map from object id to unique change row
        Map<String, ChangeRow> objectRowMap; // the main map within the loop 
        Map<Id, ChangeRow> matchedRowMap = new Map<Id, ChangeRow>(); // maps from salesforce id to the change row (used to track status of processed rows)
        Map<String, ChangeRow> insertedRowMap = new Map<String, ChangeRow>(); // maps from primary key to the change row (used to update id of inserted rows after the dml)
        Map<String, ChangeRow> deletedRowMap = new Map<String, ChangeRow>(); // maps from primary key to the change row (used to status of deleted rows after the dml)
        Map<String, String> fieldMap;
        ConvertedResponseRow[] responseRows;
        Map<String, ConvertedResponseRow[]> childrenMissingParentsMap; // maps from primary key of parent to list of converted rows missing that parent record
        SObject[] parentRecordsToInsert;
        Set<Id> newlyInsertedParentIds; // used to assist with the change summary for synced records
        Set<String> missingRecordKeys;
        SObject[] missingRecords;
        String parentLookupField;
        SObject[] salesforceRecords; 
        Map<CoreObject, SObject[]> recordsToUpdateMap = new Map<CoreObject, SObject[]>(); 
        Map<CoreObject, SObject[]> recordsToInsertMap = new Map<CoreObject, SObject[]>();
        Map<CoreObject, SObject[]> recordsToDeleteMap = new Map<CoreObject, SObject[]>();
        Map<Id, SObject> apiRecordMap; // maps from salesforce id to a converted version of the api repsonse row record
        String[] recordKeys; Set<Id> recordIds; SObject currentRecord;
        CoreAPI.EndpointName currentEndpoint;
        CoreAPI.ResponseRow[] techTagRows = new CoreAPI.ResponseRow[]{}; ConvertedResponseRow[] convertedTechTagRows; 
        String currentRowKey; ChangeRow currentChangeRow; String currentParentKey;
        String syncResult;
        Boolean insertAndDeleteSalesforceRecords; // controls whether non-matches are deleted / inserted 
        String processingResultDefaultValue = 'No Details from API';
        Boolean throwTestError = getThrowTestError();
        
        // Capture and temporarily clear the error flag if needed (so that CoreAPI.sendRequests() doesn't capture it.. since we want to simulate an error on salesforce udpate not api query)
        if (throwTestError) setThrowTestError(false);
        
        // First build the change row map
        for (ChangeRow row:changeRows) {
            row.processingResult = processingResultDefaultValue; // the default value
            if (!changeRowMap.containsKey(row.objectType)) changeRowMap.put(row.objectType, new Map<String, ChangeRow>());
            changeRowMap.get(row.objectType).put(row.objectId, row);
        }   
        //system.debug(LoggingLevel.ERROR, '###processChanges(): changeRowMap = ' + changeRowMap + '.###');
        
        // Now run through the map by object (Note: Only tech tag changes should ever have more than one object in a single call)
        for (CoreObject objectType:changeRowMap.keySet()) {
            
            // Initialize the state variables
            fieldMap = getFieldMappings(objectType, Direction.FromSalesforceToCore, false);
            objectRowMap = changeRowMap.get(objectType);
            recordIds = new Set<Id>(); recordKeys = new String[]{}; 
            childrenMissingParentsMap = new Map<String, ConvertedResponseRow[]>();
            parentRecordsToInsert = new SObject[]{}; newlyInsertedParentIds = new Set<Id>(); parentLookupField = null;
            apiRecordMap = new Map<Id, SObject>(); salesforceRecords = new SObject[]{};
            recordsToUpdateMap.put(objectType, new SObject[]{});
            recordsToInsertMap.put(objectType, new SObject[]{});
            recordsToDeleteMap.put(objectType, new SObject[]{});
            if (objectRowMap.size() > 0) currentEndpoint = objectRowMap.values()[0].theEndpoint;
            else currentEndpoint = null;
            insertAndDeleteSalesforceRecords = false;
            
            // First query the api for records
            // ADMIN NOTE: When adding a new *CoreObject*, add a new logic branch below.
            recordKeys.addAll(objectRowMap.keySet());
            if (objectType == CoreObject.ClaimChartedCompany) {
                responseRows = getClaimChartedCompanies(recordKeys, null, null);
                insertAndDeleteSalesforceRecords = true; // these records will be inserted and deleted based on the api (unlike patents, patent families and acquisitions)
            } else if (objectType == CoreObject.Licensee) {
                responseRows = getLicensees(recordKeys, null, null);
                insertAndDeleteSalesforceRecords = true;
            } else if (objectType == CoreObject.Patent) { 
                recordKeys = replaceAllInList(recordKeys, regex_StrippedPatentNumber, ''); // strip the patent numbers
                responseRows = getPatentsWithPatentFamilies(recordKeys, false);
                parentLookupField = 'Patent_Family__c'; // this will be used to update the child records in a later loop (if needed)
                fieldMap.put(parentLookupField, null); // This will ensure that the parent lookup field gets both queried and synced
                
                //system.debug(LoggingLevel.ERROR, '###processChanges(): Done retrieving patents... recordKeys = ' + recordKeys + ', responseRows = ' + responseRows + '.###');
                
                // now find any matched patents with uninserted patent families (build a key list and a map to the child rows)
                String[] corePatentFamilyKeys = new String[]{};
                for (ConvertedResponseRow row:responseRows)
                    if ((row.patent != null) && (row.patent.Id != null) && (row.patentFamily != null) && (row.patentFamily.Id == null)) {
                        // This is an UNINSERTED patent family (and thus a "missing parent record")
                        currentParentKey = getPrimaryKey(row.patentFamily);
                        if (childrenMissingParentsMap.containsKey(currentParentKey)) childrenMissingParentsMap.get(currentParentKey).add(row);
                        else {
                            childrenMissingParentsMap.put(currentParentKey, new ConvertedResponseRow[]{row});
                            corePatentFamilyKeys.add(currentParentKey); // putting this in the if block prevents inserting this patent family twice
                        }
                    }
                
                // Now requery the missing parent patent families (if present) in order to get the fields which weren't returned by the patents endpoint (especially the list values which will be flattened out in the convert and match function)
                if (corePatentFamilyKeys.size() > 0) {
                     // ADMIN NOTE: The arguments of the line may need to be changed if the primary key for the patent family ever changes (from the core id)
                    ConvertedResponseRow[] unfilteredPatentFamilyRows = getPatentFamilies(null, corePatentFamilyKeys, null, null, false, false); // don't include the children! (that is UNNEEDED and VERY resource intensive)
                    
                    // Run back through the returned rows and only queue the ones that match our original query for insert
                    for (ConvertedResponseRow pfRow:unfilteredPatentFamilyRows)
                        if ((pfRow.patentFamily != null) && childrenMissingParentsMap.containsKey(getPrimaryKey(pfRow.patentFamily)))
                            parentRecordsToInsert.add(pfRow.patentFamily);
                }   
            } else if (objectType == CoreObject.Acquisition) responseRows = getAcquisitions(recordKeys);
            else if (objectType == CoreObject.RelevantCompany) {
                responseRows = getRelevantCompanies(recordKeys, null, null);
                insertAndDeleteSalesforceRecords = true;
            } else if (objectType == CoreObject.TechTag) {
                responseRows = getTechTags(null, recordKeys);
                insertAndDeleteSalesforceRecords = true;
            } else throw new SyncException('Unsupported object type for change processing. (' + objectType.name() + ')', 'ERROR');
            
            // Now insert any missing parent records (right now just patent families)
            if (parentRecordsToInsert.size() > 0) {
                insert parentRecordsToInsert; 
                
                // copy the newly minted record ids into the child rows
                for (SObject newParentRecord:parentRecordsToInsert)
                    if (childrenMissingParentsMap.containsKey(getPrimaryKey(newParentRecord))) {
                        newlyInsertedParentIds.add(newParentRecord.Id);
                        for (ConvertedResponseRow childRow:childrenMissingParentsMap.get(getPrimaryKey(newParentRecord)))
                            childRow.getRecord(objectType).put(parentLookupField, newParentRecord.Id);
                    }
            }
            
            // Run through and figure out which ones have ids. Map those and error out the rest (if this is an endpoint we care to be notified about)
            //system.debug(LoggingLevel.ERROR, '###processChanges(): In first loop, objectType = ' + objectType + ', responseRows = ' + responseRows + '.###');
            for (ConvertedResponseRow row:responseRows) {
                currentRecord = row.getRecord(objectType);
                
                // Update this when adding new *CoreObject*
                if (objectType == CoreObject.Patent) currentRowKey = row.originalResponseRow.singleValues.get('country') + row.originalResponseRow.singleValues.get('stripped_patnum');
                else if ((objectType == CoreObject.Acquisition) || (objectType == CoreObject.ClaimChartedCompany) 
                         || (objectType == CoreObject.Licensee) || (objectType == CoreObject.RelevantCompany) 
                         || (objectType == CoreObject.TechTag))
                                currentRowKey = getPrimaryKey(currentRecord);
                else currentRowKey = null;
                
                //system.debug(LoggingLevel.ERROR, '###processChanges(): In inner loop, row = ' + row + ', currentRowKey = ' + currentRowKey + '.###');
                if (((currentRowKey) != null) && (objectRowMap.get(currentRowKey) != null)) { // This filters out irrelevant data from the api (especially for testMethods!)
                    currentChangeRow = objectRowMap.get(currentRowKey);
                    
                    if (currentRecord != null) {  
                        if (currentRecord.Id != null) {
                            recordIds.add(currentRecord.Id);
                            apiRecordMap.put(currentRecord.Id, currentRecord);
                            currentChangeRow.salesforceRecordId = currentRecord.Id;
                            matchedRowMap.put(currentRecord.Id, currentChangeRow);
                        } else if (insertAndDeleteSalesforceRecords && !currentChangeRow.action.contains('delete')) {
                            recordsToInsertMap.get(objectType).add(currentRecord);
                            insertedRowMap.put(currentRowKey, currentChangeRow); // this helps us copy the newly inserted ID back into the change row
                            currentChangeRow.processingResult = 'Record Insert FAILED'; // if we don't touch the change row again then that's what happened (not sure how this would actually occur)
                        } else if (currentEndpoint != CoreAPI.EndpointName.PatentFamilyChanges) {
                            // Explanation of above logic: Basically we want to get notified about unmatched records unless this is
                            //       the patent family changes endpoint (since tons of irrelevant patents come through that endpoint).  
                            if (currentChangeRow.action.contains('delete')) {
                                currentChangeRow.processingResult = 'No Salesforce Match to Delete';
                                errorRows_ToDelete.add(currentChangeRow);
                            } else {
                                currentChangeRow.processingResult = 'No Salesforce Match to Update';
                                errorRows_ToUpdate.add(row);
                            }
                        } else
                            currentChangeRow.processingResult = 'No Salesforce Match (OK)';
                    }
                }
            }
            
            // Now query for the full salesforce records
            salesforceRecords = queryRecords(objectType, fieldMap, recordIds, null);
            
            // Run through the salesforce records and sync everything
            for (SObject salesforceRecord:salesforceRecords) {
                syncResult = syncRecords(salesforceRecord, apiRecordMap.get(salesforceRecord.Id), objectType, fieldMap);
                currentChangeRow = matchedRowMap.get(salesforceRecord.Id);
                
                if (syncResult == null) {
                    currentChangeRow.processingResult = 'No Changes';
                } else {
                    currentChangeRow.processingResult = 'Changes Synced';
                    currentChangeRow.changeSummary = syncResult;
                    if ((parentLookupField != null) && newlyInsertedParentIds.contains((Id)salesforceRecord.get(parentLookupField)))
                        currentChangeRow.changeSummary += ' | INSERTED MISSING PARENT = ' + salesforceRecord.get(parentLookupField);
                    recordsToUpdateMap.get(objectType).add(salesforceRecord);
                }
            }
            
            // Finally, if we are deleting things, then we need to look for rows that were missing from the api response
            if (insertAndDeleteSalesforceRecords) {
                missingRecordKeys = new Set<String>();
                for (ChangeRow row:objectRowMap.values())
                    if (row.processingResult == processingResultDefaultValue) { // then this row was not returned by the API
                        missingRecordKeys.add(row.objectId);
                        row.processingResult = 'No Salesforce Match to Delete';
                    }
                    
                if (missingRecordKeys.size() > 0) {
                    missingRecords = queryRecords(objectType, fieldMap, null, missingRecordKeys);
                    
                    // run through the returned salesforce records and match them to their change rows
                    for (SObject o:missingRecords) {
                        currentRowKey = getPrimaryKey(o);
                        
                        if ((currentRowKey != null) && (objectRowMap.get(currentRowKey) != null)) {
                            recordsToDeleteMap.get(objectType).add(o);
                            
                            currentChangeRow = objectRowMap.get(currentRowKey);
                            currentChangeRow.processingResult = 'Record Delete FAILED'; // This is what happened (somehow) if we don't touch this row again
                            currentChangeRow.salesforceRecordId = o.Id;
                            deletedRowMap.put(currentRowKey, currentChangeRow);
                        }
                    }
                    
                    // go back and find any rows which weren't found in salesforce and add them to the error list
                    for (ChangeRow row:objectRowMap.values())
                        if (row.processingResult == 'No Salesforce Match to Delete') { 
                            // then this row was not found in salesforce or returned by the api (so notify admins)
                            errorRows_ToDelete.add(row);
                        }
                    
                }
            }
        }
        
        // Do the DML
        for (SObject[] recordsToUpdate:recordsToUpdateMap.values())
            if (recordsToUpdate.size() > 0) { 
                if (Test.isRunningTest()) SyncEngine.setDoNotCallout(true); // this is a kludge, read the comments of the function for more info
                //system.debug(LoggingLevel.ERROR, '###processChanges(): About to update recordsToUpdate = ' + recordsToUpdate + '.###');
                update recordsToUpdate;
            }
        for (SObject[] recordsToInsert:recordsToInsertMap.values())
            if (recordsToInsert.size() > 0) { 
                // First insert the records
                system.debug(LoggingLevel.ERROR, '###processChanges(): About to insert recordsToInsert = ' + recordsToInsert + '.###');
                insert recordsToInsert;
                
                // Then go back and update the change rows with the new record id & processing result
                for (SObject newRecord:recordsToInsert) {
                    currentChangeRow = insertedRowMap.get(getPrimaryKey(newRecord));
                    
                    if (currentChangeRow != null) {
                        currentChangeRow.processingResult = 'Record Inserted';
                        currentChangeRow.salesforceRecordId = newRecord.Id;
                    }
                }
            }
        for (SObject[] recordsToDelete:recordsToDeleteMap.values())
            if (recordsToDelete.size() > 0) {
                // First delete the records
                //system.debug(LoggingLevel.ERROR, '###processChanges(): About to delete recordsToDelete = ' + recordsToDelete + '.###');
                delete recordsToDelete;
                
                // Then go back and update the change rows with the new record id & processing result
                for (SObject deletedRecord:recordsToDelete) {
                    currentChangeRow = deletedRowMap.get(getPrimaryKey(deletedRecord));
                    if (currentChangeRow != null) currentChangeRow.processingResult = 'Record Deleted';
                }
            }
        
        // Send an email if there are any errors 
        if ((errorRows_ToUpdate.size() + errorRows_ToDelete.size()) > 0) {
            errorEmailBody = 'An error was encountered during the regular operation of the SyncEngineChangeProcessor: While attempting to sync changes between Core and Salesforce, one or more records were found to be missing from Salesforce. Full details are included below.\n\n';
            if (errorRows_ToUpdate.size() > 0) errorEmailBody += 'UNMATCHED RECORDS THAT NEED UPDATING:\n' + errorRows_ToUpdate + '\n\n';
            if (errorRows_ToDelete.size() > 0) errorEmailBody += 'UNMATCHED RECORDS THAT NEED DELETING:\n' + errorRows_ToDelete + '\n\n';
            sendEmailToAdmins(errorEmailSubject, errorEmailBody, null);
        }
        
        if (throwTestError) {
            setThrowTestError(true); // restore the initial flag before throwing the error
            throw new SyncException('Test error. (Thrown because THROW_TEST_ERROR flag is set.)', 'ERROR');
        }
        
        system.debug('###processChanges(): Exiting function with ' + String.valueOf(errorRows_ToUpdate.size() + errorRows_ToDelete.size()) + ' error rows.###');
        return changeRows;
    }
    
    
    
    
    /*=== SYNC UTILITY FUNCTIONS ===*/
    
    public static ConvertedResponseRow[] matchAndConvertResponseRows(CoreAPI.ResponseRow[] responseRows, CoreObject responseObject) {return matchAndConvertResponseRows(responseRows, responseObject, true);}
    public static ConvertedResponseRow[] matchAndConvertResponseRows(CoreAPI.ResponseRow[] responseRows, CoreObject responseObject, Boolean sendErrorEmail) {
        // Accepts a list of responseRows from the API for the specified responseObject
        // Converts the responseRows using the convertResponseRow() function, then queries for any matching Salesforce records based on the primary keys specified in the constants
        // When matching records are present, this function will populate their "Id" fields
        // >> NOTE: For salesforce-present records ONLY the Id field will be overwritten in the returned sobject (Meaning that if any field values are different between Core and SFDC, the Core values will be returned)
        // Error Note: If errors are encountered, then an email is sent to system administrators.
        
        system.debug('###matchAndConvertResponseRows(): Entering function with responseObject = ' + responseObject + '...###');
        
        String errorEmailBody = ''; String errorEmailSubject = 'Sync Engine: Missing fields error'; 
        ConvertedResponseRow[] returnRows = new ConvertedResponseRow[]{}; // the return value
        CoreAPI.ResponseRow[] errorRows = new CoreAPI.ResponseRow[]{}; // rows that have conversionErrors
        Set<String> missingFieldList = new Set<String>();
        Map<String, String> primaryFieldMap; // map from core field name to salesforce field name
        Map<String, String> secondaryFieldMap;  // only used for patent & patent family
        CoreObject secondaryResponseObject;

        Set<String> primaryRecordKeys= new Set<String>();
        Set<String> secondaryRecordKeys = new Set<String>();
        String primaryObjectName; String secondaryObjectName;
        String primaryKey; String secondaryKey;
        String primaryKeyType; String secondaryKeyType;
        String childLookupField; // the api name of the field pointing from child to parent (for objects with secondary objects)

        Map<String, SObject> primaryRecordMap = new Map<String, SObject>(); //maps from primary key to the converted record
        Map<String, SObject> secondaryRecordMap = new Map<String, SObject>(); //maps from primary key to the converted record
        Map<String, SObject[]> secondaryParentRecordInstancesMap = new Map<String, SObject[]>(); //maps from primary key of a secondary parent to ALL instances of that parent in the response (there could be multiple)
        Map<String, SObject[]> parentToChildRecordsMap = new Map<String, SObject[]>(); // maps from primary key of parent to list of children

        ConvertedResponseRow currentRow;
        SObject primaryRecord; SObject secondaryParentRecord; SObject[] secondaryChildRecords;
        String primaryKeyValue; String secondaryParentKeyValue; String secondaryChildKeyValue; String secondaryKeyValue;
        
        String primaryConditionString; String secondaryConditionString;
        SObject[] existingPrimaryRecords = new SObject[]{};
        SObject[] existingSecondaryRecords = new SObject[]{};

        
        // First configure the manually specified items
        // ADMIN NOTE: When adding a new *CoreObject*, add a new logic branch below.
        if (responseObject == CoreObject.ClaimChartedCompany) {
            primaryObjectName = 'Accounts_with_Claim_Charts__c';
        } else if (responseObject == CoreObject.Licensee) {
            primaryObjectName = 'Licensees__c';
        } else if (responseObject == CoreObject.Patent) {
            primaryObjectName = 'Patent__c';
            secondaryObjectName = 'Assets__c';
            childLookupField = 'Patent_Family__c';
            secondaryResponseObject = CoreObject.PatentFamily;
        } else if (responseObject == CoreObject.PatentFamily) {
            primaryObjectName = 'Assets__c';
            secondaryObjectName = 'Patent__c';
            childLookupField = 'Patent_Family__c';
            secondaryResponseObject = CoreObject.Patent;
        } else if (responseObject == CoreObject.Acquisition) {
            primaryObjectName = 'Acquisition_Opportunity__c';
        } else if (responseObject == CoreObject.RelevantCompany) {
            primaryObjectName = 'Potentially_Relevant_Company__c';
        } else if (responseObject == CoreObject.TechTag) {
            primaryObjectName = 'portfolio2product__c';
        } else
            throw new SyncException('Unsupported object type for conversion.', 'ERROR');

        // Now retrieve values from the various maps
        primaryFieldMap = getFieldMappings(responseObject, Direction.FromCoreToSalesforce, sendErrorEmail);
        primaryKey = PrimaryKey_Salesforce.get(responseObject);
        primaryKeyType = PrimaryKeyType_Salesforce.get(responseObject).name();
        if (secondaryResponseObject != null) {
            secondaryFieldMap = getFieldMappings(secondaryResponseObject, Direction.FromCoreToSalesforce, sendErrorEmail);
            secondaryKey = PrimaryKey_Salesforce.get(secondaryResponseObject);
            secondaryKeyType = PrimaryKeyType_Salesforce.get(secondaryResponseObject).name();
        }
        
        // Then run through and convert each of the responserows to salesforce records (and add the records to our sets/maps)
        for (CoreAPI.ResponseRow rr:responseRows) {
            // First check to see if we're out of script statements 
            /*if (Limits.getScriptStatements() > (LIMIT_THRESHOLD_CODE_STATEMENTS*Limits.getLimitScriptStatements())) {
                Exception e = new SyncException('Close to code statement limit. There were too many API response rows to process. Please reduce query size and try again.', 'INFO');
                throw e;
            }*/
            currentRow = convertResponseRow(rr, responseObject, primaryFieldMap, secondaryFieldMap);
            
            if (currentRow.conversionError) {
                errorRows.add(rr);
                missingFieldList.addAll(currentRow.missingFieldList);
            } else {
                returnRows.add(currentRow); //add to the return list

                // initialize the pointers
                primaryRecord = currentRow.getRecord(responseObject); secondaryParentRecord = null; secondaryChildRecords = null;
                primaryKeyValue = null; secondaryParentKeyValue = null; secondaryChildKeyValue = null;

                // ADMIN NOTE: When adding a new *CoreObject* that has a secondary object, add a new logic branch below.
                if (responseObject == CoreObject.Patent)                secondaryParentRecord = currentRow.patentFamily;
                else if (responseObject == CoreObject.PatentFamily)     secondaryChildRecords = currentRow.childPatents;

                // Log and map the primary record if present
                if (primaryRecord != null) {
                    primaryKeyValue = getPrimaryKey(primaryRecord);
                    primaryRecordKeys.add(primaryKeyValue);
                    primaryRecordMap.put(primaryKeyValue, primaryRecord);
                }

                // Log and map the secondary parent record if present (the only current example of this is the Patent Family returned by the patents endpoint)
                if (secondaryParentRecord != null) {
                    // Secondary parent records are unique in that they can appear multiple times across different response rows, so we have to keep track of each occurance in a list.
                    secondaryParentKeyValue = getPrimaryKey(secondaryParentRecord);
                    secondaryRecordKeys.add(secondaryParentKeyValue);
                    secondaryRecordMap.put(secondaryParentKeyValue, secondaryParentRecord);
                    
                    if (secondaryParentRecordInstancesMap.containsKey(secondaryParentKeyValue)) secondaryParentRecordInstancesMap.get(secondaryParentKeyValue).add(secondaryParentRecord);
                    else secondaryParentRecordInstancesMap.put(secondaryParentKeyValue, new SObject[]{secondaryParentRecord});

                    if (primaryRecord != null) {
                        if (parentToChildRecordsMap.containsKey(secondaryParentKeyValue)) parentToChildRecordsMap.get(secondaryParentKeyValue).add(primaryRecord);
                        else parentToChildRecordsMap.put(secondaryParentKeyValue, new SObject[]{primaryRecord});
                    }
                }

                //log and map the secondary child records list if present (the only current example of this is the child patents returned by the patent families endpoint)
                if (secondaryChildRecords != null)
                    for (SObject childRecord:secondaryChildRecords) {
                        secondaryChildKeyValue = getPrimaryKey(childRecord);
                        secondaryRecordKeys.add(secondaryChildKeyValue);
                        secondaryRecordMap.put(secondaryChildKeyValue, childRecord);
                        
                        if (primaryKeyValue != null) {
                            if (parentToChildRecordsMap.containsKey(primaryKeyValue)) parentToChildRecordsMap.get(primaryKeyValue).add(childRecord);
                            else parentToChildRecordsMap.put(primaryKeyValue, new SObject[]{childRecord});
                        }
                    }
            }
        }
        //system.debug('###matchAndConvertResponseRows(): Done converting returnRows = ' + returnRows + ' and errorRows = ' + errorRows + '\n\n\nprimaryRecordMap = ' + primaryRecordMap + ', secondaryRecordMap = ' + secondaryRecordMap + '.###');
        
        // Now build out the query parameters (formatting is conditionally based on the field type of the key) and query for existing records if needed
        if (primaryRecordKeys.size() > 0) {
            primaryConditionString = buildQueryConditionString(primaryRecordKeys, primaryKeyType);
            existingPrimaryRecords = Database.query('select ' + primaryKey + ' from ' + primaryObjectName + ' where ' + primaryKey + ' in ' + primaryConditionString);
        }
        if (secondaryRecordKeys.size() > 0) {
            secondaryConditionString = buildQueryConditionString(secondaryRecordKeys, secondaryKeyType);
            existingSecondaryRecords = Database.query('select ' + secondaryKey + ' from ' + secondaryObjectName + ' where ' + secondaryKey + ' in ' + secondaryConditionString);
        }
        //system.debug(LoggingLevel.ERROR, '###matchAndConvertResponseRows(): Done querying existingPrimaryRecords = ' + existingPrimaryRecords + '\n\n\nexistingSecondaryRecords = ' + existingSecondaryRecords + ',\n\n\nparentToChildRecordsMap = ' + parentToChildRecordsMap + '.###');
        
        // Run through the existing primary records and match them up by inserting the ids (this will indicate to the consuming function which records already exist in Salesforce)
        for (SObject existingPrimaryRecord:existingPrimaryRecords) {
            primaryKeyValue = getPrimaryKey(existingPrimaryRecord);
            
            if (primaryRecordMap.containsKey(primaryKeyValue)) primaryRecordMap.get(primaryKeyValue).Id = existingPrimaryRecord.Id;
            if (parentToChildRecordsMap.containsKey(primaryKeyValue))
                for (SObject childRecord:parentToChildRecordsMap.get(primaryKeyValue))
                    childRecord.put(childLookupField, existingPrimaryRecord.Id);
        }
        
        // Now run through the secondary records and match them up too
        
        for (SObject existingSecondaryRecord:existingSecondaryRecords) {
            secondaryKeyValue = getPrimaryKey(existingSecondaryRecord); // Note: This could be a parent OR a child secondary record
            
            if (secondaryRecordMap.containsKey(secondaryKeyValue)) secondaryRecordMap.get(secondaryKeyValue).Id = existingSecondaryRecord.Id;
            if (secondaryParentRecordInstancesMap.containsKey(secondaryKeyValue)) // then this is a parent
                for (SObject instanceOfParentRecord:secondaryParentRecordInstancesMap.get(secondaryKeyValue))
                    instanceOfParentRecord.Id = existingSecondaryRecord.Id; //there might be multiple instances of the same parent record in different response rows, set the ids for each
            if (parentToChildRecordsMap.containsKey(secondaryKeyValue))
                for (SObject childRecord:parentToChildRecordsMap.get(secondaryKeyValue))
                    childRecord.put(childLookupField, existingSecondaryRecord.Id);
        }
        
        // before returning let's send an email if there were any errors
        if (errorRows.size() > 0) {
            String[] missingFieldList_List = new String[]{};
            missingFieldList_List.addAll(missingFieldList); // convert it to a list collection to allow the use of String.join()
            
            errorEmailBody = 'One or more errors was encountered during the regular operation of the SyncEngine. The api fields list below are currently mapped in SyncEngineField__c setting records, ';
            errorEmailBody += 'but were missing from one or more of the response rows retrieved from Core DB via the API. The full response rows in question are included below.\n';
            errorEmailBody += 'WARNING: This error directly effects users. It means that Core Patent Search is incorrectly returning no results or filtering out some results from searches.\n\n';
            errorEmailBody += 'HOW TO FIX THIS: To stop this message you will either need to remove the specified field mapping setting record(s) or fix the data coming in from the API so that it always contains all mapped fields. ';
            errorEmailBody += 'You may also consider setting one or more fields as optional by checking the "Allow Field to be Missing" checkbox on the field mapping setting record. However, be aware that allowing missing fields can result in Salesforce data loss.';
            errorEmailBody += '(NOTE: The Sync Engine does not allow missing fields in the API responses because those missing fields could result in blank data from the API overwriting non-blank data in Salesforce during change syncing.)\n\n';
            errorEmailBody += 'SYNC OBJECT: ' + responseObject.name() + '\n\n';
            errorEmailBody += 'MISSING FIELD LIST: ' + String.join(missingFieldList_List, ', ') + '\n\n';
            errorEmailBody += 'ERROR RESPONSE ROWS:\nThe following are the response rows which were returned from the Core API with missing fields for one or more members. As such they were discarded from the information returned to Salesforce users.\n';
            errorEmailBody += CoreAPI.responseRowListToString(errorRows, '*'); //we're using the special string conversion function so we can force the string output to include ALL of the keys
            system.debug(LoggingLevel.ERROR, '###matchAndConvertResponseRows(): Error encountered, sendErrorEmail = ' + sendErrorEmail + ', errorEmailBody = ' + errorEmailBody + '.###');
            if (sendErrorEmail) sendEmailToAdmins(errorEmailSubject, errorEmailBody, null);
        }
        
        // Done! Now we the responses are converted to Patent Families & Patents and all salesforce reocords have an id 
        //system.debug('###matchAndConvertResponseRows(): Exiting function with returnRows = ' + returnRows + '..###');
        return returnRows;
         
    }
    
    public static ConvertedResponseRow convertResponseRow(CoreAPI.ResponseRow responseRow, CoreObject responseObject, Map<String, String> primaryFieldMap, Map<String, String> secondaryFieldMap) {
        // Converts a ResponseRow (of the type specified by [responseObject] into a collection of Salesforce records.
        // The function uses the included fieldMaps (with Direction = CoreToSalesforce) to do the field mapping.
        //     [primaryFieldMap] is the field map for the responseObject, [secondaryFieldMap] is only needed if this object has a secondary collection contained in the response
        // If there is a secondary collection, the function will operate recursively to convert the related records if present.
        // Conversion Error Note: The conversionError property will be set to TRUE if any of the api fields in the field map key are missing for any of the records in the collection
        //                        If conversionError == true, then missingFieldList will also be set.
        
        //system.debug('###convertResponseRow(): Entering function with responseRow = ' + responseRow + ' and responseObject = ' + responseObject + '.###');
        
        ConvertedResponseRow returnRow = new ConvertedResponseRow(responseObject);
        Map<String, String> fieldValueMap; //maps from key of singleValue OR listChild OR listValue to flattened string value
        ConvertedResponseRow secondaryRow;
        SObject primaryObject; 
        String primaryKeyValue;
        
        // First set the object specific variables
        // ADMIN NOTE: When adding a new *CoreObject* add a new logic branch below.
        if (responseObject == CoreObject.ClaimChartedCompany)   returnRow.claimChartedCompany = new Accounts_with_Claim_Charts__c();
        else if (responseObject == CoreObject.Licensee)         returnRow.licensee = new Licensees__c();
        else if (responseObject == CoreObject.Patent)           returnRow.patent = new Patent__c();
        else if (responseObject == CoreObject.PatentFamily)     returnRow.patentFamily = new Assets__c();
        else if (responseObject == CoreObject.Acquisition)      returnRow.acquisition = new Acquisition_Opportunity__c();
        else if (responseObject == CoreObject.RelevantCompany)  returnRow.relevantCompany = new Potentially_Relevant_Company__c();
        else if (responseObject == CoreObject.TechTag)          returnRow.techTag = new portfolio2product__c();
        else                                                    throw new SyncException('Unsupported object for conversion.', 'ERROR');
        
        primaryObject = returnRow.getRecord(responseObject);
        
        //system.debug('###convertResponseRow(): Done setting primaryObject = ' + primaryObject + ' and primaryFieldMap = ' + primaryFieldMap + '.###');

        // Now let's build out the fieldValueMap by using the built-in ResponseRow method to flatten out the list fields and mash them up with the singleValues map
        responseRow.refreshFlattenedValues(PrimaryKey_Core.values()); // we're adding the primary keys as extraKeysToInclude
        fieldValueMap = responseRow.allFlattenedValues;
        
        // Store the original information for later reference by function consumers
        returnRow.originalResponseRow = responseRow;
        
        // Next we copy the fields into the primary row object record by using the utility function (which handles the messy data type conversion for us)
        returnRow.missingFieldList = copyValuesIntoObject(primaryObject, primaryFieldMap, fieldValueMap);
        primaryKeyValue = getPrimaryKey(primaryObject);
        
        // First check that no fields are missing.  If they are then we will flag the returnRow with an error value (there are two types of errors: primary key missing - which propogates up to the parent, missing field - which doesn't)
        // There are two reasons for this: 1) If the primary key is missing, then this is non-auditable junk data, 2) Missing fields are read by syncRecords() as blank values that should be copied into Salesforce
        if (returnRow.missingFieldList.size() > 0) {    
            returnRow.missingPrimaryKey = (primaryKeyValue == null); 
            
            // We need to poke a hole in the enforcement of missing fields, specifically for the blank patent family rows that are used to act as parent nodes for patents without patent families.
            // These blank rows are identifiable because their primary key value is '0'. Technically these should only be patent families, but we will go ahead and poke a universal hole for all '0' values.
            if (primaryKeyValue != '0') {
                returnRow.conversionError = true;
                system.debug('###convertResponseRow(): ERROR! This response row is missing one or more fields (' + returnRow.missingFieldList + '). primaryKey = ' +  +  primaryKeyValue + '.###');
            }
        }
          
        if (!returnRow.missingPrimaryKey) {
            // Finally, if we've made it this far...
            // Then we want to build out the appropriate secondary collection (parent patent family OR child patents) if it is present
            // ADMIN NOTE: When adding a new *CoreObject* that DOES HAVE a secondary collection, add a new logic branch below.
            
            if ((responseObject == CoreObject.Patent) && (responseRow.singleChildren.get('patent_family') != null)) {
                secondaryRow = convertResponseRow(responseRow.singleChildren.get('patent_family'), CoreObject.PatentFamily, secondaryFieldMap, primaryFieldMap); //swap the field map argument order
                returnRow.patentFamily = secondaryRow.patentFamily;
                
                if (secondaryRow.missingPrimaryKey) { // If this is a mission critical error then we'll return the error ourselves, otherwise we'll let it slide
                    returnRow.conversionError = true;
                    returnRow.missingFieldList.addAll(secondaryRow.missingFieldList);
                    system.debug('###convertResponseRow(): ERROR! Error encountered while building parent patentFamily row.###');
                }
            }

            if ((responseObject == CoreObject.PatentFamily) && (responseRow.listChildren.get('patents') != null))
                for (CoreAPI.ResponseRow patentResponseRow:responseRow.listChildren.get('patents')) {
                    secondaryRow = convertResponseRow(patentResponseRow, CoreObject.Patent, secondaryFieldMap, primaryFieldMap);
                    returnRow.childPatents.add(secondaryRow.patent);
                    returnRow.originalChildResponseRowMap.put(getPrimaryKey(secondaryRow.patent), secondaryRow.originalResponseRow);
                    
                    if (secondaryRow.missingPrimaryKey) { // If this is a mission critical error then we'll return the error ourselves, otherwise we'll let it slide
                        returnRow.conversionError = true;
                        returnRow.missingFieldList.addAll(secondaryRow.missingFieldList);
                        system.debug('###convertResponseRow(): ERROR! Error encountered while building childPatent row.###');
                    }
                }
        }
        
        //system.debug('###convertResponseRow(): Exiting function with returnRow = ' + returnRow + '.###');
        return returnRow;
        
    }
    
    public static Map<String, String> getFieldMappings(CoreObject objectToSync, Direction mappingDirection) {return getFieldMappings(objectToSync, mappingDirection, true);}
    public static Map<String, String> getFieldMappings(CoreObject objectToSync, Direction mappingDirection, Boolean sendErrorEmail) {
        // Gets AND VALIDATES field mappings from the SyncEngineField__c custom settings record for the specified object and mapping direction
        // Validation Notes: This function verifies that the Salesforce fields actually exist before adding them to the returned map
        //                   It also adds the DATA TYPE of each salesforce field to the map.
        //                   Finally, it verifies that the data type of the field is currently supported by the SyncEngine's copyValuesIntoObject() function
        // Error Notes: If errors are encountered, then an email is sent to system administrators.
        // RETURN MAP CONTENTS:
        //     > Validated Salesforce Fields: Added to map with key = "{fromFieldName}" and value = "{toFieldName}" (depending on mapping direction)
        //     > Validated Salesforce Field Types: Added to map with... 
        //         > key = "{salesforceFieldName}*" (an asterisk appended to the end of the SF field name)
        //         > value = Schema.DisplayType enum (converted to string via the .name method)
        //         > List of Schema.DisplayType values => http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_fields_describe.htm#apex_displaytype
        //     > For Salesforce Fields that ARE NOT UPDATEABLE: The string 'TRUE' is added to the map with key = "{salesforceFieldName}!"
        //     > For Core Fields that ARE OPTIONAL: The string 'TRUE' is added to the map with key = "{core_field_name}?"
        //     > Invalid Salesforce Fields: Added to comma-delimited list stored in map under the key "*fielderrors"
        //     > Unallowed Salesforce Types: Added to comma-delimited list stored in map under the key "*typeerrors"    
        
        system.debug('###getFieldMappings(): Entering function with objectToSync = ' + objectToSync + ', mappingDirection = ' + mappingDirection + '.###');
        
        String fieldErrorsKey = '*fielderrors'; String typeErrorsKey = '*typeerrors';
        String errorEmailBody = ''; String errorEmailSubject = 'Sync Engine: Field mapping error';
        Map<String, String> returnMap = new Map<String, String>();
        Map<String, SyncEngineField__c> fieldMappings;   
        String objectName = objectToSync.name().replaceAll(' ', '').toLowerCase();
        Map<String, Schema.SObjectField> fieldNameMap; //maps from lowercase api name of field to the field token
        Set<String> allowedFieldTypes;
        Schema.DescribeFieldResult describeField;
        String sfFieldName; String coreFieldName; String sfFieldType; //tempvars used during mapping
        Boolean isReadOnly; Boolean isOptional;
        
        // First get the field mappings
        // ADMIN NOTE: When adding a new *CoreObject*, add a logic branch below
        if (objectToSync == CoreObject.ClaimChartedCompany)     fieldNameMap = Schema.SObjectType.Accounts_with_Claim_Charts__c.fields.getMap();
        else if (objectToSync == CoreObject.Licensee)           fieldNameMap = Schema.SObjectType.Licensees__c.fields.getMap();
        else if (objectToSync == CoreObject.Patent)             fieldNameMap = Schema.SObjectType.Patent__c.fields.getMap();
        else if (objectToSync == CoreObject.PatentFamily)       fieldNameMap = Schema.SObjectType.Assets__c.fields.getMap();
        else if (objectToSync == CoreObject.Acquisition)        fieldNameMap = Schema.SObjectType.Acquisition_Opportunity__c.fields.getMap();
        else if (objectToSync == CoreObject.RelevantCompany)    fieldNameMap = Schema.SObjectType.Potentially_Relevant_Company__c.fields.getMap();
        else if (objectToSync == CoreObject.TechTag)            fieldNameMap = Schema.SObjectType.portfolio2product__c.fields.getMap();
        else                                                    throw new SyncException('Unsupported CoreObject for getFieldMappings. (' + objectToSync.name() + ')', 'ERROR');
        
        // Now retrieve custom settings & ballowed field types 
        allowedFieldTypes = getAllowedTypes_CopyValuesIntoObject();
        fieldMappings = SyncEngineField__c.getAll(); // retrieve all field mappings custom setting
        
        // initialize the error values to a blank string...
        returnMap.put(fieldErrorsKey, '');
        returnMap.put(typeErrorsKey, '');
        
        system.debug('###getFieldMappings(): About to loop through fieldMappings = ' + fieldMappings + '.###');
        // then run through the custom settings and build the return map for this object & direction
        for (SyncEngineField__c sef:fieldMappings.values())
            if ((sef.Object__c != null) && (sef.Object__c.replaceAll(' ', '').toLowerCase() == objectName)) { //then this is the desired object
                coreFieldName = sef.Core_Field_Name__c;
                sfFieldName = sef.Salesforce_Field_Name__c;
                
                if (fieldNameMap.containsKey(sfFieldName)) { //it IS a valid field
                    sfFieldType = fieldNameMap.get(sfFieldName).getDescribe().getType().name();
                    isReadOnly = !fieldNameMap.get(sfFieldName).getDescribe().isUpdateable();
                    isOptional = sef.Allow_Field_to_be_Missing__c;
                    
                    if (allowedFieldTypes.contains(sfFieldType)) { // it IS an allowed type
                        returnMap.put(sfFieldName+'*', sfFieldType); //store the field type string in the map
                        if (mappingDirection == Direction.FromSalesforceToCore) returnMap.put(sfFieldName, coreFieldName);
                        else returnMap.put(coreFieldName, sfFieldName);
                        
                        // If this field is READ-ONLY then add a value to the map in the form of: 'Field_Name__c!'
                        if (isReadOnly) returnMap.put(sfFieldName+'!', 'TRUE');
                        // If this field is OPTIONAL then add a value to the map in the form of: 'field_name?'
                        if (isOptional) returnMap.put(coreFieldName+'?', 'TRUE');
                    } else { // invalid field type, add it to the error list
                        if (returnMap.get(typeErrorsKey) != '') returnMap.put(typeErrorsKey, returnMap.get(typeErrorsKey)+','); //add a comma if not the first value
                        returnMap.put(typeErrorsKey, returnMap.get(typeErrorsKey)+sfFieldName+'('+sfFieldType+')');
                    }
                } else { //it is NOT a valid field (so add it to the error list)
                    if (returnMap.get(fieldErrorsKey) != '') returnMap.put(fieldErrorsKey, returnMap.get(fieldErrorsKey)+','); //add a comma if not the first value
                    returnMap.put(fieldErrorsKey, returnMap.get(fieldErrorsKey)+sfFieldName);
                }
            }
        
        // finally we add the hard-coded primary key to the returnMap (overriding the custom setting mapping if present)
        coreFieldName = PrimaryKey_Core.get(objectToSync);
        sfFieldName = PrimaryKey_Salesforce.get(objectToSync);
        if (mappingDirection == Direction.FromSalesforceToCore) returnMap.put(sfFieldName, coreFieldName);
        else returnMap.put(coreFieldName, sfFieldName);
        returnMap.put(sfFieldName+'*', PrimaryKeyType_Salesforce.get(objectToSync).name());
        
        // before returning let's send an email if there were any errors
        if (returnMap.get(fieldErrorsKey).length() > 0)
            errorEmailBody += 'INVALID FIELDS:\nThe following Salesforce fields are present in the SyncEngineField custom setting list but are not valid Salesforce fields.\n' + returnMap.get(fieldErrorsKey) + '\n\n';
        if (returnMap.get(typeErrorsKey).length() > 0)
            errorEmailBody += 'UNALLOWED FIELD TYPES:\nThe following VALID Salesforce fields are present in the SyncEngineField custom setting list.\nThe field types of the destination fields, however, are not currently supported by the "SyncEngine.copyValuesIntoObject()" function.\n' + returnMap.get(typeErrorsKey) + '\n\n';
        
        if (errorEmailBody.length() > 0) {
            errorEmailBody = 'One or more errors was encountered during the regular operation of the SyncEngine while attempting to retrieve and parse the field mappings stored in the SyncEngineField__c custom settings. Details are included below.\n\n\n' + errorEmailBody;
            system.debug(LoggingLevel.ERROR, '###getFieldMappings(): Error encountered, sendErrorEmail = ' + sendErrorEmail + ', errorEmailBody = ' + errorEmailBody + '.###');
            if (sendErrorEmail) sendEmailToAdmins(errorEmailSubject, errorEmailBody, null);
        }
        
        system.debug('###getFieldMappings(): Exiting function with returnValue = ' + returnMap + '.###');
        return returnMap;
    }
    
    public static String mapToString(Map<String, String> sourceMap) {
        // Returns a NON-ABBREVIATED, flat string representation the map.
        String[] listItems = new String[]{};
        for (String key:sourceMap.keySet())
            listItems.add(key + '=' + sourceMap.get(key));
        return '{' + String.join(listItems, ', ') + '}';
    }
    
    public static String syncRecords(SObject salesforceRecord, SObject apiRecord, CoreObject theObject, Map<String, String> fieldMap) {
        // Compares [salesforceRecord] with [apiRecord] (looking only at the fields in [fieldMap])
        // If there are any non-blank fields in [apiRecord] which are different from those in [salesforceRecord],  
        // the values in [salesforceRecord] are overwritten.
        // >> The function returns a string list of all changed fields OR null if no changes were made
        // NOTE: The primary object key is automatically excluded from syncing.
        //    [fieldMap] should be Direction.FromSalesforceToCore
        
        system.debug('###syncRecords(): Entering function with theObject = ' + theObject + '.###');
        //system.debug(LoggingLevel.ERROR, '###syncRecords(): Entering function with salesforceRecord = ' + salesforceRecord + ', apiRecord = ' + apiRecord + '.###');
        
        String primaryKey = PrimaryKey_Salesforce.get(theObject);
        Object salesforceFieldValue; Object apiFieldValue;
        String[] changedFields = new String[]{}; 
        
        // Run through and compare the field values
        // We need specifically avoid syncing the primary key. We also need to filter out the info keys (they all have one of these: *, !, ?)
        for (String fieldName:fieldMap.keySet())
            if (!fieldName.contains('*') && !fieldName.contains('!') && !fieldName.contains('?') && (fieldName != primaryKey)) {
                salesforceFieldValue = salesforceRecord.get(fieldName);
                apiFieldValue = apiRecord.get(fieldName);
                
                if (apiFieldValue != salesforceFieldValue) {
                    salesforceRecord.put(fieldName, apiFieldValue);
                    changedFields.add(fieldName);
                }
            }
        
        //system.debug('###syncRecords(): Exiting function with salesforceRecord = ' + salesforceRecord + '.###');   
        if (changedFields.size() > 0) return 'UPDATED FIELD VALUES: ' + String.join(changedFields, CoreAPI.LIST_JOIN_STRING);
        else return null;
    }
    
    public static SObject[] queryRecords(CoreObject theObject, Map<String, String> fieldMap, Set<Id> recordIds, Set<String> primaryKeys) {
        // Constructs a dynamic query for all [theObject] records with Id in [recordIds] or primary key in [primaryKeys]
        // Query includes all fields from fieldMap
        //    [fieldMap] should be Direction.FromSalesforceToCore
        
        system.debug('###queryRecords(): Entering function with theObject = ' + theObject + '.###');
        
        SObject[] returnValue = new SObject[]{}; // return empty set by default
        String objectAPIName; Set<String> recordIdStrings = new Set<String>(); 
        String[] fieldList = new String[]{}; String fieldString; 
        String conditionString_Id; String conditionString_PrimaryKey; String conditionString = '';
        String queryString;
        
        // First make sure neither of the search params are null
        if (recordIds == null) recordIds = new Set<Id>();
        if (primaryKeys == null) primaryKeys = new Set<String>();
        
        // Set the object name
        // ADMIN NOTE: When adding a new *CoreObject*, add a new logic branch below.
        if (theObject == CoreObject.ClaimChartedCompany) objectAPIName = 'Accounts_with_Claim_Charts__c';
        else if (theObject == CoreObject.Licensee) objectAPIName = 'Licensees__c';
        else if (theObject == CoreObject.Patent) objectAPIName = 'Patent__c';
        else if (theObject == CoreObject.PatentFamily)objectAPIName = 'Assets__c';
        else if (theObject == CoreObject.Acquisition) objectAPIName = 'Acquisition_Opportunity__c';
        else if (theObject == CoreObject.RelevantCompany) objectAPIName = 'Potentially_Relevant_Company__c';
        else if (theObject == CoreObject.TechTag) objectAPIName = 'portfolio2product__c';
        else throw new SyncException('Unsupported object type for querying.', 'ERROR');
        
        // Now build the field and individual condition strings
        for (String fieldName:fieldMap.keySet()) if (!fieldName.contains('*') && !fieldName.contains('!') && !fieldName.contains('?')) fieldList.add(fieldName);
        fieldString = String.join(fieldList, ', ');
        for (Id i:recordIds) recordIdStrings.add(i); //convert to string set
        conditionString_Id = buildQueryConditionString(recordIdStrings, Schema.DisplayType.ID.name());
        conditionString_PrimaryKey = buildQueryConditionString(primaryKeys, PrimaryKeyType_Salesforce.get(theObject).name());
        
        // Build the composite condition string (test if length is greater than a blank string in parentheses >> ('') >> length = 4)
        if (conditionString_Id.length() > 4) { 
            conditionString += 'Id in ' + conditionString_Id;
            if (conditionString_PrimaryKey.length() > 4) conditionString += ' or '; // there are two conditions so we need to OR them together
        }
        if (conditionString_PrimaryKey.length() > 4) conditionString += PrimaryKey_Salesforce.get(theObject) + ' in ' + conditionString_PrimaryKey;
        
        // Put it all together and do the query
        queryString = 'select ' + fieldString + ' from ' + objectAPIName;
            if (conditionString!='')
            queryString += ' where ' + conditionString;
        system.debug('###queryRecords(): Done building queryString = ' + queryString + ', about to query.###');
        if (conditionString.length() >  0) returnValue = Database.query(queryString); // otherwise there were no conditions and we will be querying all records
           
        //system.debug('###queryRecords(): Exiting function with returnValue = ' + returnValue + '.###');
        return returnValue;
    }
    
    
    
    /*=== OTHER UTILITY FUNCTIONS ===*/
    
    
    public static void sendEmailToAdmins(String subject, String plainTextBody, String htmlBody) {
        // Sends an email to the system administrators (you can use one or both of the body parameters). 
        // The email is sent to the address specified in the {errorNotificationEmailAddress} constant.
        
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        email.setToAddresses(new String[] {errorNotificationEmailAddress});
        email.setReplyTo('do-not-reply@rpxcorp.com');
        email.setSenderDisplayName('Core to Salesforce Sync Engine');
        
        email.setSubject(subject);
        email.setPlainTextBody(plainTextBody);
        email.setHtmlBody(htmlBody);
        
        system.debug(LoggingLevel.ERROR, '###sendEmailToAdmins(): Sending email = '  + email + ', email limit: ' + Limits.getEmailInvocations() + ' out of ' + Limits.getLimitEmailInvocations() + '.###');
        if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    
    private static Set<String> getAllowedTypes_CopyValuesIntoObject() {
        // Returns a set containing the Schema.DisplayType._____.name() of all field types which the copyValuesIntoObject() is able to process
        return new Set<String>{
            Schema.DisplayType.Combobox.name(),
            Schema.DisplayType.Email.name(),
            Schema.DisplayType.ID.name(),
            Schema.DisplayType.Phone.name(),
            Schema.DisplayType.Picklist.name(),
            Schema.DisplayType.Reference.name(),
            Schema.DisplayType.String.name(),
            Schema.DisplayType.TextArea.name(),
            Schema.DisplayType.MultiPicklist.name(),
            Schema.DisplayType.URL.name(),
            Schema.DisplayType.Integer.name(),
            Schema.DisplayType.Date.name(),
            Schema.DisplayType.DateTime.name(),
            Schema.DisplayType.Double.name(),
            Schema.DisplayType.Percent.name(),
            Schema.DisplayType.Boolean.name()
        };
    }
    
    private static Set<String> copyValuesIntoObject(SObject salesforceObject, Map<String, String> objectFieldMap, Map<String, String> coreValueMap) {
        // Copies the values from the [coreValueMap] into the passed [salesforceObject] using the fields and field types provided in [objectFieldMap]
        // Returns a string set of the api fields which were present as keys in [objectFieldMap] but missing as keys in [coreValueMap]. 
        // This function will automatically convert the data types of all of the strings from [coreValueMap] into the type specified in [objectFieldMap]. 
        //      [salesforceObject] should be the Patent or Patent Family record
        //      [objectFieldMap] should be the map generated by getFieldMappings() with Direction.FromCoreToSalesforce
        //      [coreValueMap] should map from the core field names to the string value returned by the Core API
        
        String sfFieldName; String fieldType; String fieldValue; 
        Set<String> missingFieldList = new Set<String>();
        
        for (String coreFieldName:objectFieldMap.keySet())
            if (coreValueMap.containsKey(coreFieldName)) {
                // Pull the values into easy to read variables
                sfFieldName = objectFieldMap.get(coreFieldName);
                fieldType = objectFieldMap.get(sfFieldName+'*');
                fieldValue = coreValueMap.get(coreFieldName);
                //system.debug('###copyValuesIntoObject(): In loop with sfFieldName = ' + sfFieldName + ', fieldType = ' + fieldType + ', fieldValue = ' + fieldValue + '.###');
                
                // Then do a big, ugly data type conversion if statement
                // NOTE: Complete list of Schema field types here: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_fields_describe.htm#apex_displaytype
                if (fieldValue != null) {
                    if ((fieldType == Schema.DisplayType.Combobox.name())
                    || (fieldType == Schema.DisplayType.Email.name())
                    || (fieldType == Schema.DisplayType.ID.name())
                    || (fieldType == Schema.DisplayType.Phone.name())
                    || (fieldType == Schema.DisplayType.Picklist.name())
                    || (fieldType == Schema.DisplayType.Reference.name())
                    || (fieldType == Schema.DisplayType.String.name())
                    || (fieldType == Schema.DisplayType.TextArea.name())
                    || (fieldType == Schema.DisplayType.MultiPicklist.name())
                    || (fieldType == Schema.DisplayType.URL.name()))              { salesforceObject.put(sfFieldName, fieldValue); }
                    else if (fieldType == Schema.DisplayType.Integer.name())      { salesforceObject.put(sfFieldName, Integer.valueOf(fieldValue)); }
                    else if (fieldType == Schema.DisplayType.Date.name())         { salesforceObject.put(sfFieldName, Date.valueOf(fieldValue)); }
                    else if (fieldType == Schema.DisplayType.DateTime.name())     { salesforceObject.put(sfFieldName, DateTime.valueOf(fieldValue)); }
                    else if (fieldType == Schema.DisplayType.Double.name())       { salesforceObject.put(sfFieldName, Double.valueOf(fieldValue)); }
                    else if (fieldType == Schema.DisplayType.Percent.name())      { salesforceObject.put(sfFieldName, Decimal.valueOf(fieldValue)); }
                    else if (fieldType == Schema.DisplayType.Boolean.name())      { salesforceObject.put(sfFieldName, Boolean.valueOf(fieldValue)); }
                }
            } else if (!coreFieldName.contains('*') && !coreFieldName.contains('!') && !coreFieldName.contains('?') && !objectFieldMap.containsKey(coreFieldName+'?')) {
                // Explanation of IF statement logic above: First we check for special characters to make sure this isn't an info key. 
                //                                          Then we make sure this field isn't optional by checking for the presence of the 'core_field_name?' key.
                missingFieldList.add(coreFieldName);
            }
        
        return missingFieldList;
    }
    
    private static String buildQueryConditionString(Set<String> values, String fieldType) {
        // Converts a set of strings into a single comma delimited list either with or without quotes (a string that can be used in the dynamic query)
        //     [fieldType] should be of type Schema.DisplayType.______.name()
        
        system.debug('###buildQueryConditionString(): Entering function with values = ' + values + ', fieldType = ' + fieldType + '.###');
        
        String returnValue;
        Boolean includeQuotes;
        String[] valuesList = new String[]{};
        valuesList.addAll(values); // convert to an list collection so we can join it
        
        // (We include quotes if it's not a number or a boolean)
        includeQuotes = !(  
                            (fieldType == Schema.DisplayType.Integer.name())
                            || (fieldType == Schema.DisplayType.Double.name())
                            || (fieldType == Schema.DisplayType.Percent.name())
                            || (fieldType == Schema.DisplayType.Boolean.name())
                         );
        
        if (includeQuotes) returnValue = '(\'' + String.join(valuesList, '\',\'') + '\')';
        else returnValue = '(' + String.join(valuesList, ',') + ')';
        
        system.debug('###buildQueryConditionString(): Exiting function with returnValue = ' + returnValue + '.###');
        return returnValue;
    }
    
    public static String cleanPrimaryKey(Object keyValue) {
        // Cleans up the provided key value 
        
        if (keyValue instanceof Double) return String.valueOf(Integer.valueOf(keyValue)); 
        else return String.valueOf(keyValue);
    }
    
    public static String getPrimaryKey(SObject salesforceRecord) {
        // Returns the primary key for this record (if it is a Patent or Patent Family)
        // ADMIN NOTE: When adding a new *CoreObject* be sure to add another logic branch below.
        
        if (salesforceRecord instanceof Accounts_with_Claim_Charts__c)          return cleanPrimaryKey(salesforceRecord.get(PrimaryKey_Salesforce.get(CoreObject.ClaimChartedCompany)));
        else if (salesforceRecord instanceof Licensees__c)                      return cleanPrimaryKey(salesforceRecord.get(PrimaryKey_Salesforce.get(CoreObject.Licensee)));
        else if (salesforceRecord instanceof Patent__c)                         return cleanPrimaryKey(salesforceRecord.get(PrimaryKey_Salesforce.get(CoreObject.Patent)));
        else if (salesforceRecord instanceof Assets__c)                         return cleanPrimaryKey(salesforceRecord.get(PrimaryKey_Salesforce.get(CoreObject.PatentFamily)));
        else if (salesforceRecord instanceof Acquisition_Opportunity__c)        return cleanPrimaryKey(salesforceRecord.get(PrimaryKey_Salesforce.get(CoreObject.Acquisition)));
        else if (salesforceRecord instanceof Potentially_Relevant_Company__c)   return cleanPrimaryKey(salesforceRecord.get(PrimaryKey_Salesforce.get(CoreObject.RelevantCompany)));
        else if (salesforceRecord instanceof portfolio2product__c)              return cleanPrimaryKey(salesforceRecord.get(PrimaryKey_Salesforce.get(CoreObject.TechTag)));
        else                                                                    throw new SyncException('Unsupported SObject for getPrimaryKey.', 'ERROR');
    }
    
    public static String getDetailURL(SObject salesforceRecord) {
        // Returns the relative URL of the detail page for this salesforceRecord (if it is a Patent or Patent Family)
        // If the "Id" field is blank it will return a link to the CorePatent / CorePatentFamily Page
        // If the "Id" field is non-blank it will return a link to the standard Salesforce detail page
        // ADMIN NOTE (Optional): When adding a new *CoreObject* add another logic branch below. (Only if there is a visualforce page to display the object detail.)
        
        if (salesforceRecord instanceof Patent__c) {
            if (salesforceRecord.Id == null) return Page.CorePatent.getUrl() + '?key=' + getPrimaryKey(salesforceRecord);
            else return '/' + salesforceRecord.Id; 
        } else if (salesforceRecord instanceof Assets__c) {
            if (salesforceRecord.Id == null) return Page.CorePatentFamily.getUrl() + '?key=' + getPrimaryKey(salesforceRecord);
            else return '/' + salesforceRecord.Id;
        } else {
            if (salesforceRecord.Id != null) return '/' + salesforceRecord.Id;
            else throw new SyncException('Cannot display detail page of this unsupported object type.', 'ERROR');
        }
    }
    
    public static Set<String> replaceAllInList(Set<String> stringSet, String regexToReplace, String replaceWith) {
        String[] stringList = new String[]{}; Set<String> returnSet = new Set<String>();
        returnSet.addAll(replaceAllInList(stringList, regexToReplace, replaceWith));
        return returnSet;
    }
    
    public static String[] replaceAllInList(String[] stringList, String regexToReplace, String replaceWith) {
        // Replaces [regexToReplace] with [replaceWith] for every string in [stringList]
        // Uppercases & trims strings first
        
        if (stringList == null) 
            return null;
        else {
            String[] returnList = new String[]{};
            for (String s:stringList) returnList.add(s.trim().toUpperCase().replaceAll(regexToReplace, replaceWith));
            return returnList;
        }
    }
    
    
    
    /*=== TEST FUNCTIONS ===*/
    
    public static String TEST_DO_NOT_CALLOUT_NAME = 'xxDO_NOT_CALLOUTxx';
    public static String TEST_THROW_ERROR_NAME = 'xxTHROW_TEST_ERRORxx';
    
    public static void setDoNotCallout(Boolean hasCalledOut) {
        // This function is used in test methods to help future functions determine if there has alredy been a callout.
        // If so they should NOT callout because it will cause the test method to fail.
        // NOTE: This is totally a kludge, but there's no other way to check if you will hit this error. 
        //       It only occurs because of the way @future calls are handled in testMethods. 
        
        SyncEngineField__c settingRecord = SyncEngineField__c.getValues(TEST_DO_NOT_CALLOUT_NAME);
        
        if ((settingRecord == null) && hasCalledOut) insert new SyncEngineField__c(Name=TEST_DO_NOT_CALLOUT_NAME);
        else if ((settingRecord != null) && !hasCalledOut) delete settingRecord;
    }
    
    public static Boolean getDoNotCallout() {
        // This function is used in test methods to help future functions determine if there has alredy been a callout.
        // If so they should NOT callout because it will cause the test method to fail.
        // NOTE: This is totally a kludge, but there's no other way to check if you will hit this error. 
        //       It only occurs because of the way @future calls are handled in testMethods. 
        
        SyncEngineField__c settingRecord = SyncEngineField__c.getValues(TEST_DO_NOT_CALLOUT_NAME);
        
        return (settingRecord != null);
    }
    
    public static void setThrowTestError(Boolean throwError) {
        // This function is used in test methods to simulate a processing error. 
        
        SyncEngineField__c settingRecord = SyncEngineField__c.getValues(TEST_THROW_ERROR_NAME);
        
        if ((settingRecord == null) && throwError) insert new SyncEngineField__c(Name=TEST_THROW_ERROR_NAME);
        else if ((settingRecord != null) && !throwError) delete settingRecord;
    }
    
    public static Boolean getThrowTestError() {
        // This function is used in test methods to simulate a processing error.
        
        SyncEngineField__c settingRecord = SyncEngineField__c.getValues(TEST_THROW_ERROR_NAME);
        
        return (settingRecord != null);
    }
    
    public static void testSyncEngine_Live() { testSyncEngine_Live(CoreObject.PatentFamily, new String[]{'US8287210', 'US8145824', 'US7429807'}, null); }
    
    public static void testSyncEngine_Live(CoreObject queryObject, String[] patentNumbers, Id[] salesforceRecordIds) {
        // This is a "live test" method.  It must be run from the developer console.
        // Since all of the http callouts are mocked in the actual test method, this is the only way to test the sync engine with real data.
        // NOTE: You can also call to the get____() functions directly.
        //     [includeAllFieldsInOutput] = true >> will cause the function include all of the keys in the string output in the results (handy for seeing what's available)
        //     [patentNumbers] NOTE: The search values should be STRIPPED for Patent and COUNTRY for others
        //     [salesforceRecordIds] is only used for queryObject = Acquisition, ClaimChartedCompany, Licensee, or RelevantCompany
        //                           For Acquisitions: It should be set to an acquisition record id
        //                           For ClaimChartedCompany, Licensee, or RelevantCompany: It should be a patent record salesforce id
        
        system.debug('###testSyncEngine_Live(): Entering function.###');
        
        ConvertedResponseRow[] responseRows;
        
        // ADMIN NOTE: When adding a new *CoreObject* add another logic branch below.
        if (queryObject == CoreObject.ClaimChartedCompany) responseRows = getClaimChartedCompanies(null, salesforceRecordIds, null);
        else if (queryObject == CoreObject.Licensee) responseRows = getLicensees(null, salesforceRecordIds, null);
        else if (queryObject == CoreObject.Patent) responseRows = getPatentsWithPatentFamilies(patentNumbers);
        else if (queryObject == CoreObject.PatentFamily) responseRows = getPatentFamiliesWithPatents(null, null, null, patentNumbers);
        else if (queryObject == CoreObject.Acquisition) responseRows = getAcquisitions(salesforceRecordIds);
        else if (queryObject == CoreObject.RelevantCompany) responseRows = getRelevantCompanies(null, salesforceRecordIds, null);
        else if (queryObject == CoreObject.TechTag) responseRows = getTechTags(patentNumbers, null);
        else throw new SyncException('Unsupported object for testSyncEngine_Live().', 'ERROR');
        
        system.debug('###testSyncEngine_Live(): responseRows.size() = ' + responseRows.size() + '\n\n\n\nresponseRows = ' + responseRows + '\n.###');
        system.debug('###testSyncEngine_Live(): Exiting function.###');
    }
       
}