/****************************************************
    
    CORE DB API INTEGRATION
    
    Built by Hank Ryan Thompson.
    Created 3/29/20013.
    Last updated 10/6/2013 by Hank.
    
    This is a utility Apex Class that interfaces with
    the RPX Core DB API and provides Apex functions 
    that make it simple for other Apex Classes to
    pull data from Core DB.
    
    REQUIREMENTS
     - You must create a CoreAPIAuthentication__c
       custom settings record for each of the available
       EndpointNames listed below.
     - The CONSTANTS & ENUMS section below must be
       properly configured.
    
    TO USE THIS CLASS
    
    Reference one of the following endpoint functions:
     - CoreAPI.getPatents(...)
     - CoreAPI.getPatentAnnotations(...)
     - CoreAPI.getPatentFamilies(...)
     - CoreAPI.getPortfolios(...)
     - CoreAPI.getTechTags(...)
    
    Or these utility functions:
     - CoreAPI.encodeDateTime(...)
     - CoreAPI.getEndpointURL(...)
     
  

****************************************************/


global class CoreAPI {
    
    /*=== CONSTANTS & ENUMS ===*/
    
    // The names of all available endpoints
    // ADMIN NOTE: Use these names (EXACTLY as typed below) as the names of the "Core API Endpoint" custom setting records
    global enum EndpointName {
        ClaimChartedCompanies,
        Licensees,
        Patents, 
        PatentAnnotations, 
        PatentFamilies, 
        Portfolios, 
        RelevantCompanies,
        TechTags, 
        ClaimChartedCompanyChanges,
        LicenseeChanges,
        PatentAnnotationChanges,
        PatentFamilyChanges,
        PortfolioAnnotationChanges,
        RelevantCompanyChanges,
        TechTagChanges 
    }  
    /*
        HOW TO ADD A NEW CORE API ENDPOINT: Follow these instructions to add a new endpoint to this class
            1) Add a new value to the enum above (Typically named something like CoreRecords or CoreRecordChanges)
            2) Insert a CoreAPIAuthentication__c setting record for the new endpoint
            3) Create a get______() function (copy and paste another get function as a template)
                > NOTE: There are currently 2 types of endpoints, DETAIL endpoints (retrieve object details) and CHANGES endpoints (retrieve change rows).
                        Make sure to use an appropriate get____ function as your template and put your new function in the appropriate section of the class. 
            4) Search this class for "*EndpointName*"" (w/o the quotes) and make changes as instructed
            5) Update CoreAPIMockResponseGenerator.cls (follow the instructions near the top of the class file)
            6) Update the test coverage in CoreAPITests.cls 
            7) Be sure to manually test the new endpoint with the Salesforce Developer Console
            8) After everything in THIS class file is tested and working,
               Update SyncEngine.cls (follow the instructions near the top of the class file)
    */
    
    // Limit-Specific Constants
    // ADMIN NOTE: These have been set specifically to avoid triggering governor limits & api limitations, do not change without testing!
    public static Integer PAGE_SIZE = 2000; // This is the max number of response rows that this class can process in a single transaction (w/o hitting "too many script statements" governor limit)
    public static Integer MAX_URL_LENGTH = 5000; // The maximum number of characters that the API supports in the request endpoint url
    public static Integer HTTP_REQUEST_TIMEOUT = 120000; // how many milliseconds to wait for an api response (max = 120,000)
    
    // Configuration Constants
    public static String[] TOSTRING_DEFAULT_SINGLEVALUEKEYS = new String[]{'patnum', 'id', 'name', 'title', 'key', 'obj_id'}; // Used in the ResponseRow.toString() function to set which keys are output by default
    public static String LIST_JOIN_STRING = '; '; // this is used by ResponseRow.refreshFlattenedValues() to convert list fields returned by the API into flat string values
    // ADMIN NOTE: Be careful when changing LIST_JOIN_STRING. It is referenced by triggers and used parse certain values. Changing this constant may require updating the Salesforce database. 
    
    public static String PAGE_SIZE_PARAM = 'per_page';
    public static String PAGE_NUMBER_PARAM = 'page';    
    public static String DATE_TIME_FORMAT = 'yyyy-MM-dd HH:mm'; // Used to convert date time parameters into strings
    public static String DATE_FORMAT = 'yyyy-MM-dd'; // Used to convert date parameters into strings
    
    //Added as enhencement to handle too many rows in query

    
    /*=== INNER CLASS TO FORMAT RETURNED ROWS ===*/
    
    
    global class PaginatedResponse {
        
        /*
            
            This contains a list of ResponseRows as well as state variables to manage pagination.
            This class is used as a return value ONLY for endpoints which allow pagination.
                  
        */
        
        // STATE VARS
        public Integer currentPage;
        public Integer previousPage;
        public Integer nextPage;
        public Integer perPage;
        public Integer itemCount; // Total number of items
        public Integer pageCount; // Total number of pages
        public ResponseRow[] responseRows;
        
        // CONSTRUCTORS
        
        public PaginatedResponse() {
            this.currentPage = null;
            this.previousPage = null;
            this.nextPage = null;
            this.perPage = null;
            this.itemCount = null;
            this.pageCount = null;
            this.responseRows = new ResponseRow[]{};
        }
        
        public PaginatedResponse(ResponseRow[] responseRows) {
            this.currentPage = null;
            this.previousPage = null;
            this.nextPage = null;
            this.perPage = null;
            this.itemCount = null;
            this.pageCount = null;
            this.responseRows = responseRows;
        }
        
        // STRING OUTPUT
        
        public override String toString() { 
            return this.toString(0, TOSTRING_DEFAULT_SINGLEVALUEKEYS);
        }
        
        public String toString(String singleValueKey) { return this.toString(new String[]{singleValueKey}); }
        
        public String toString(String[] singleValueKeys) { return this.toString(0, singleValueKeys); }
        
        public String toString(Integer tabLevel, String[] singleValueKeys) {
            String[] responseRowStrings = new String[]{};
            
            for (ResponseRow rr:responseRows)
                responseRowStrings.add(rr.toString(tabLevel, singleValueKeys));
            
            return
                '[ currentPage=' + currentPage
                + ', previousPage=' + previousPage
                + ', nextPage=' + nextPage
                + ', perPage=' + perPage
                + ', itemCount=' + itemCount
                + ', pageCount=' + pageCount
                + ', responseRows=[' + String.join(responseRowStrings, '') + ']'
                + ' ]';
        }
        
    } 
    
    
    
    global class ResponseRow {
        
        /*
            
            The goal of using a universal ResponseRow class is to LOOSELY couple the Apex code with 
            the Core DB API implementation so that small changes to the fields available in the API
            do not require chnging Apex code.
            
            This class is designed to store TWO types of response rows:
            
            MAP   = A map of keys to values, lists and/or child maps
                    "singleValues" stores keys with primitive SINGLE values, all converted to string
                    "listValues" stores keys with primitive LIST values, all converted to string
                    "singleChildren" stores keys with complex SINGLE values, each stored as a single child ResponseRow
                    "listChildren" stores keys with complex LIST values, each stored as a list of child ResponseRows
            
            LIST  = A list of maps. (Primitive lists are stored in the parent map.)
                    Only "listChildren" will be set for this type of row
            
            >> Useful Note: The refreshFlattenedValues() method flattens out listChildren & listValues and combines
                            them with singleValues into a single map called allFlattenedValues.
                            (singleChildren is excluded from this process.)
                  
        */
        
        // STATE VARS
        public String name; // The name of this key in the response
        public Map<String, String> singleValues; // Single primitive values in a MAP type row.
        public Map<String, String[]> listValues; // Primitive list values in a MAP type row.
        public Map<String, ResponseRow> singleChildren; // Single complex values in a MAP type row.
        public Map<String, ResponseRow[]> listChildren; // Complex list values in a MAP or LIST type row.
        public Map<String, String> allFlattenedValues; // Call refreshFlattenedValues() before referencing this property 
        
        // STATE FUNCTIONS
        public Boolean hasSingleChildren() {return (singleChildren != null) && (singleChildren.keySet().size() > 0);}
        public Boolean hasListChildren() {return (listChildren != null) && (listChildren.keySet().size() > 0);}
        
        // CONSTRUCTORs
        public ResponseRow() {
            name = null;
            singleValues = new Map<String, String>();
            listValues = new Map<String, String[]>();
            singleChildren = new Map<String, ResponseRow>();
            listChildren = new Map<String, ResponseRow[]>();
            allFlattenedValues = new Map<String, String>();
        }
        
        public ResponseRow(String name) {
            this.name = name;
            singleValues = new Map<String, String>();
            listValues = new Map<String, String[]>();
            singleChildren = new Map<String, ResponseRow>();
            listChildren = new Map<String, ResponseRow[]>();
            allFlattenedValues = new Map<String, String>();
        }
        
        // STRING OUTPUT
        
        public override String toString() { // Overrides the standard toString() method by calling the recursive method below.
            return this.toString(0, TOSTRING_DEFAULT_SINGLEVALUEKEYS); //by default start with tabLevel = 0 and show the listed singleValues only
        }
        
        public String toString(String singleValueKey) { return this.toString(new String[]{singleValueKey}); }
        
        public String toString(String[] singleValueKeys) { return this.toString(0, singleValueKeys); }
        
        public String toString(Integer tabLevel, String[] singleValueKeys) {
            // This recursive function returns a concise, human-readible summary of the ResponseRow. 
            // [singleValueKeys] is an optional argument
            //     If included, then the specified keys from singleValues will be included in the output ( Example: {'id', 'patnum', 'title'} )
            //     If included and the first element equals '*', all keys will be included in the output ( Example: {'*'} )
            
            String eol = '\n'; // END OF LINE string
            String tab = '    '; // TAB string
            String[] keysToPrint = new String[]{};
            
            if ((tabLevel == null) || (tabLevel < 0)) tabLevel = 0;
            //system.debug('###ResponseRow.toString(): Entering function with tabLevel=' + tabLevel + ', this=' + this + '.###');
            
            //first create the string and initialize it with the title line 
            String returnValue = tab.repeat(tabLevel) + name+'=[';
            returnValue += String.valueOf(singleValues.size()) + ' SVs';
            returnValue += ', ' + String.valueOf(listValues.size()) + ' LVs';
            returnValue += ', ' + String.valueOf(singleChildren.size()) + ' SCh';
            returnValue += ', ' + String.valueOf(listChildren.size()) + ' LCh';
            
            //next include the singleValueKeys if specified
            if ((singleValueKeys != null) && (singleValueKeys.size() > 0)) {
                if (singleValueKeys[0] == '*') 
                    keysToPrint.addAll(singleValues.keySet()); //include all keys if we are passed a single star
                else 
                    keysToPrint.addAll(singleValueKeys); //otherwise only include the specified keys
            }
            for (String key:keysToPrint)
                if (singleValues.containsKey(key)) 
                    returnValue += ', ' + key + '=' + singleValues.get(key);
            
            //now include single children if any
            if (singleChildren.size() > 0) {
                returnValue += eol + tab.repeat(tabLevel+1) + 'singleChildren={' + eol;
                for (String key:singleChildren.keySet())
                    returnValue += singleChildren.get(key).toString(tabLevel+2, singleValueKeys);
                returnValue += tab.repeat(tabLevel+1) + '}';
            }
            if (listChildren.size() > 0) {
                returnValue += eol + tab.repeat(tabLevel+1) + 'listChildren={' + eol;
                for (String key:listChildren.keySet()) {
                    returnValue += tab.repeat(tabLevel+2) + key + '={' + eol;
                    for (ResponseRow rr:listChildren.get(key))
                        returnValue += rr.toString(tabLevel+3, singleValueKeys);
                    returnValue += tab.repeat(tabLevel+2) + '}' + eol;
                }
                returnValue += tab.repeat(tabLevel+1) + '}';
            }
            
            returnValue += ']\n';
            
            return returnValue;
        }
        
        public void refreshFlattenedValues(String[] extraKeysToInclude) {
            // This function builds the allFlattenedValues map
            // It merges all of the response maps into a single map, which involves "flattening" listChildren and listValues maps by joining them with the {listJoinString} constant
            // NOTE ABOUT FLATTENING {LISTCHILDREN}: The first matched key in the {TOSTRING_DEFAULT_SINGLEVALUEKEYS} constant will be used to represent each listChild and singleChild
            // >> [extraKeysToInclude] can be used to specify additional keys which are added in the highest priority spot
            
            //system.debug('###CoreAPI.refreshFlattenedValues(): Entering function.###');
            
            String[] childKeys = new String[]{}; String[] listChildValues;
            String listChildKey;
            ResponseRow firstChildRow; ResponseRow singleChildRow;
            
            allFlattenedValues = new Map<String, String>(); //initialize the "return" value
            
            // First build out the list of keys we'll use to attempt to flatten the listChildren 
            if ((extraKeysToInclude != null) && (extraKeysToInclude.size() > 0))
                childKeys.addAll(extraKeysToInclude);
            if ((TOSTRING_DEFAULT_SINGLEVALUEKEYS != null) && (TOSTRING_DEFAULT_SINGLEVALUEKEYS.size() > 0) && (TOSTRING_DEFAULT_SINGLEVALUEKEYS[0] != '*')) // {'*'} is the "show all" value
                childKeys.addAll(TOSTRING_DEFAULT_SINGLEVALUEKEYS);
            
            // 1) First simplify any singleChildren (lowest priority)
            for (String key:this.singleChildren.keySet()) {
                singleChildRow = this.singleChildren.get(key);
                
                if (singleChildRow != null)
                    for (String potentialKey:childKeys)
                        if (singleChildRow.singleValues.containsKey(potentialKey)) {
                            allFlattenedValues.put(key, singleChildRow.singleValues.get(potentialKey));
                            break;
                        }
            }
            
            // 2) Flatten out any listChildren so they are available for mapping as flat string values 
            for (String key:this.listChildren.keySet())
                if (this.listChildren.get(key).size() > 0) {
                    //first determine the which key to use as a flattener
                    listChildKey = null;
                    firstChildRow = this.listChildren.get(key)[0];
                    for (String potentialKey:childKeys)
                        if (firstChildRow.singleValues.containsKey(potentialKey)) {
                            listChildKey = potentialKey;
                            break;
                        }
                    
                    //then run through and flatten out this child by selecting just the listChildKey's value from the singleValues map
                    if (listChildKey != null) {
                        listChildValues = new String[]{};
                        for (ResponseRow curRow:this.listChildren.get(key))
                            if (curRow.singleValues.containsKey(listChildKey) && (curRow.singleValues.get(listChildKey) != null) && (curRow.singleValues.get(listChildKey).trim().length() > 0))
                                 listChildValues.add(curRow.singleValues.get(listChildKey.trim()));
                        allFlattenedValues.put(key, String.join(listChildValues, LIST_JOIN_STRING));
                    }
                }
            
            // 3) Flatten out any listValues so they are available for mapping as flat string values (higher priority = duplicate keys here will override listChildren)
            for (String key:this.listValues.keySet())
                allFlattenedValues.put(key, String.join(this.listValues.get(key), LIST_JOIN_STRING));
            
            //system.debug('###CoreAPI.refreshFlattenedValues(): Newly flattened values = snapshot of allFlattenedValues = ' + allFlattenedValues + '.###');
            
            // 4) Copy singleValues into the fieldValueMap (HIGHEST priority = duplicate keys here will override listChildren & listValues)
            allFlattenedValues.putAll(this.singleValues);
            
            //system.debug('###CoreAPI.refreshFlattenedValues(): Exiting function with allFlattenedValues = ' + allFlattenedValues + '.###');
        }
        
        public void minimizeViewState() {
            // Call this function to null out all of the state variables EXCEPT allFlattenedValues
            // This is useful for minimizing Visualforce view state (since 90% of the size is stored in the listChildren and other un-needed elements)
            
            this.singleValues = null;
            this.singleChildren = null;
            this.listValues = null;
            this.listChildren = null;
        }
        
    }
    
    
    
    
    /*=== INNER EXCEPTION CLASS ===*/
    
    public class ApiException extends Exception {
        public String errorType; // 'ERROR', 'INFO'
        public ApiException(String errorMessage, String errorType) { this.setMessage(errorMessage); this.errorType = errorType; }
    }
    
    
    
    /*=== ENDPOINT FUNCTIONS PART 1 - RECORD DETAILS ===*/
    
    public static ResponseRow[] getClaimChartedCompanies(String[] claimChartedCompanyIds, String[] salesforcePatentIds, String[] salesforceAccountIds) {
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        String searchKey;
        system.debug('###getClaimChartedCompanies(): Entering function with claimChartedCompanyIds = ' + claimChartedCompanyIds + '.###');
        
        //first build the parameter maps
        if ((claimChartedCompanyIds != null) && (claimChartedCompanyIds.size() > 0)) { urlParameters_Arrays.put('ids[]', claimChartedCompanyIds); searchKey = 'ids[]'; }
        if ((salesforcePatentIds != null) && (salesforcePatentIds.size() > 0)) { urlParameters_Arrays.put('pat_ids[]', salesforcePatentIds); searchKey = 'pat_ids[]'; }
        if ((salesforceAccountIds != null) && (salesforceAccountIds.size() > 0)) { urlParameters_Arrays.put('ent_ids[]', salesforceAccountIds); searchKey = 'ent_ids[]'; }
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.ClaimChartedCompanies, null, urlParameters_Arrays, searchKey, null, null), 'response').responseRows;
        //system.debug('###getClaimChartedCompanies(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }

    public static ResponseRow[] getLicensees(String[] licenseeIds, String[] salesforcePatentIds, String[] salesforceAccountIds) {
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        String searchKey;
        system.debug('###getLicensees(): Entering function with licenseeIds = ' + licenseeIds + '.###');
        
        //first build the parameter maps
        if ((licenseeIds != null) && (licenseeIds.size() > 0)) { urlParameters_Arrays.put('ids[]', licenseeIds); searchKey = 'ids[]'; }
        if ((salesforcePatentIds != null) && (salesforcePatentIds.size() > 0)) { urlParameters_Arrays.put('pat_ids[]', salesforcePatentIds); searchKey = 'pat_ids[]'; }
        if ((salesforceAccountIds != null) && (salesforceAccountIds.size() > 0)) { urlParameters_Arrays.put('ent_ids[]', salesforceAccountIds); searchKey = 'ent_ids[]'; }
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.Licensees, null, urlParameters_Arrays, searchKey, null, null), 'response').responseRows;
        //system.debug('###getLicensees(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }
    
    public static ResponseRow[] getPatents(String[] strippedPatentNumbers, Boolean includePatentFamily, Boolean includeRecentAssignees, Boolean includeSponsoringEntities) {
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        String[] includesValue = new String[]{};
        system.debug('###getPatents(): Entering function with strippedPatentNumbers = ' + strippedPatentNumbers + '.###');
        
        //first build the parameter maps
        if ((strippedPatentNumbers != null) && (strippedPatentNumbers.size() > 0)) urlParameters_Arrays.put('stripped_patnums[]', strippedPatentNumbers);
        if (includePatentFamily) includesValue.add('patent_family');
        if (includeRecentAssignees) includesValue.add('most_recent_assignees');
        if (includeSponsoringEntities) includesValue.add('sponsoring_entities');
        if (includesValue.size() > 0) urlParameters_Arrays.put('includes[]', includesValue);
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.Patents, null, urlParameters_Arrays, 'stripped_patnums[]', null, null), 'response').responseRows;
        //system.debug('###getPatents(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }
    
    
    public static ResponseRow[] getPatentAnnotations(String[] countryPatentNumbers) {
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        system.debug('###getPatentAnnotations(): Entering function with countryPatentNumbers = ' + countryPatentNumbers + '.###');
        
        //first build the parameter maps
        if ((countryPatentNumbers != null) && (countryPatentNumbers.size() > 0)) urlParameters_Arrays.put('patent_key[]', countryPatentNumbers);
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.PatentAnnotations, null, urlParameters_Arrays, 'patent_key[]', null, null), 'response').responseRows;
        //system.debug('###getPatentAnnotations(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }
    
    public static ResponseRow[] getPatentFamilies(String[] applicationNumbers, String[] patentFamilyIds, String[] publicationNumbers, String[] countryPatentNumbers, Boolean includeAllPatents, Boolean includeUSApplications, Boolean includeUSPatents, Boolean includeNonUSApplications, Boolean includeNonUSPatents, Boolean showRollupFields) {
        // Provides access to the PatentFamilies endpoint.
        //     The String[] arguments are the SEARCH parameters
        //         Best practice is to set one search parameter and leave the rest null
        //         Setting more than one search parameter may have unintended results
        //     The Boolean arguments control what gets returned
        //         Setting [includeAllPatents] is the equivalent of setting both [includeUSPatents] and [includeNonUSPatents]
        //         [showRollupFields] controls whether all of the rollup fields are included in the response 
        
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        String[] includesValue = new String[]{};
        String searchKey;
        system.debug('###getPatentFamilies(): Entering function with countryPatentNumbers = ' + countryPatentNumbers + '.###');
        
        //first build the parameter maps
        if ((applicationNumbers != null) && (applicationNumbers.size() > 0)) { urlParameters_Arrays.put('appnums[]', applicationNumbers); searchKey = 'appnums[]'; }
        if ((patentFamilyIds != null) && (patentFamilyIds.size() > 0)) { urlParameters_Arrays.put('ids[]', patentFamilyIds); searchKey = 'ids[]'; }
        if ((publicationNumbers != null) && (publicationNumbers.size() > 0)) { urlParameters_Arrays.put('pubnums[]', publicationNumbers); searchKey = 'pubnums[]'; }
        if ((countryPatentNumbers != null) && (countryPatentNumbers.size() > 0)) { urlParameters_Arrays.put('patnums[]', countryPatentNumbers); searchKey = 'patnums[]'; }
        
        if (includeAllPatents) includesValue.add('patents');
        if (includeUSApplications) includesValue.add('us_applications');
        if (includeUSPatents) includesValue.add('us_patents');
        if (includeNonUSApplications) includesValue.add('non_us_applications');
        if (includeNonUSPatents) includesValue.add('non_us_patents');
        if (includesValue.size() > 0) urlParameters_Arrays.put('includes[]', includesValue);
        
        if (showRollupFields) urlParameters_Arrays.put('fields[]', new String[]{'max_expire_date', 'min_priority_date', 'us_patents_count', 'non_us_patents_count', 'us_applications_count', 'non_us_applications_count'});
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.PatentFamilies, null, urlParameters_Arrays, searchKey, null, null), 'response').responseRows;
        //system.debug('###getPatentFamilies(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }
    
    public static ResponseRow[] getPortfolios(String[] portfolioIds) {
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        system.debug('###getPortfolios(): Entering function with portfolioIds = ' + portfolioIds + '.###');
        
        //first build the parameter maps
        if ((portfolioIds != null) && (portfolioIds.size() > 0)) urlParameters_Arrays.put('id[]', portfolioIds);
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.Portfolios, null, urlParameters_Arrays, 'id[]', null, null), 'response').responseRows;
        //system.debug('###getPortfolios(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }
    
    public static ResponseRow[] getRelevantCompanies(String[] relevantCompanyIds, String[] salesforcePatentIds, String[] salesforceAccountIds) {
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        String searchKey;
        system.debug('###getRelevantCompanies(): Entering function with relevantCompanyIds = ' + relevantCompanyIds + '.###');
        
        //first build the parameter maps
        if ((relevantCompanyIds != null) && (relevantCompanyIds.size() > 0)) { urlParameters_Arrays.put('ids[]', relevantCompanyIds); searchKey = 'ids[]'; }
        if ((salesforcePatentIds != null) && (salesforcePatentIds.size() > 0)) { urlParameters_Arrays.put('pat_ids[]', salesforcePatentIds); searchKey = 'pat_ids[]'; }
        if ((salesforceAccountIds != null) && (salesforceAccountIds.size() > 0)) { urlParameters_Arrays.put('ent_ids[]', salesforceAccountIds); searchKey = 'ent_ids[]'; }
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.RelevantCompanies, null, urlParameters_Arrays, searchKey, null, null), 'response').responseRows;
        //system.debug('###getRelevantCompanies(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }
    
    public static ResponseRow[] getTechTags(String[] countryPatentNumbers, String[] techTagIds) {
        ResponseRow[] responseRows; Map<String, String[]> urlParameters_Arrays = new Map<String, String[]>();
        system.debug('###getTechTags(): Entering function with countryPatentNumbers = ' + countryPatentNumbers + ', techTagIds = ' + techTagIds + '.###');
        
        //first build the parameter maps
        if ((countryPatentNumbers != null) && (countryPatentNumbers.size() > 0)) urlParameters_Arrays.put('patent_key[]', countryPatentNumbers);
        if ((techTagIds != null) && (techTagIds.size() > 0)) urlParameters_Arrays.put('ids[]', techTagIds);
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseRows = sendRequests(generateRequests(EndpointName.TechTags, null, urlParameters_Arrays, 'patent_key[]', null, null), 'response').responseRows;
        //system.debug('###getTechTags(): Exiting function with responseRows = ' + responseRows + '.###');
        return responseRows;
    }
    public static ResponseRow[] getTechTags(String[] countryPatentNumbers) { return getTechTags(countryPatentNumbers, null); }
    
    
    /*=== ENDPOINT FUNCTIONS PART 2 - CHANGES ===*/
    
    
    public static paginatedResponse getClaimChartedCompanyChanges(DateTime fromDateTime, Integer pageNumber, Integer overridePageSize) {
        paginatedResponse responseObject; Map<String, String> urlParameters_Single = new Map<String, String>();
        system.debug('###getClaimChartedCompanyChanges(): Entering function with fromDateTime = ' + fromDateTime + ' and pageNumber = ' + pageNumber + '.###');
        
        //first build the parameter map
        urlParameters_Single.put('from_date_time', encodeDateTime(fromDateTime));
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseObject = sendRequests(generateRequests(EndpointName.ClaimChartedCompanyChanges, urlParameters_Single, null, null, pageNumber, overridePageSize), 'response');
        //system.debug('###getClaimChartedCompanyChanges(): Exiting function with responseObject = ' + responseObject + '.###');
        return responseObject;
    }
    
    public static paginatedResponse getLicenseeChanges(DateTime fromDateTime, Integer pageNumber, Integer overridePageSize) {
        paginatedResponse responseObject; Map<String, String> urlParameters_Single = new Map<String, String>();
        system.debug('###getLicenseeChanges(): Entering function with fromDateTime = ' + fromDateTime + ' and pageNumber = ' + pageNumber + '.###');
        
        //first build the parameter map
        urlParameters_Single.put('from_date_time', encodeDateTime(fromDateTime));
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseObject = sendRequests(generateRequests(EndpointName.LicenseeChanges, urlParameters_Single, null, null, pageNumber, overridePageSize), 'response');
        //system.debug('###getLicenseeChanges(): Exiting function with responseObject = ' + responseObject + '.###');
        return responseObject;
    }
    
    public static paginatedResponse getPatentAnnotationChanges(DateTime fromDateTime, Integer pageNumber, Integer overridePageSize) {
        paginatedResponse responseObject; Map<String, String> urlParameters_Single = new Map<String, String>();
        system.debug('###getPatentAnnotationChanges(): Entering function with fromDateTime = ' + fromDateTime + ' and pageNumber = ' + pageNumber + '.###');
        
        //first build the parameter map
        urlParameters_Single.put('from_date_time', encodeDateTime(fromDateTime));
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseObject = sendRequests(generateRequests(EndpointName.PatentAnnotationChanges, urlParameters_Single, null, null, pageNumber, overridePageSize), 'response');
        //system.debug('###getPatentAnnotationChanges(): Exiting function with responseObject = ' + responseObject + '.###');
        return responseObject;
    }
    
    public static paginatedResponse getPatentFamilyChanges(DateTime fromDateTime, Integer pageNumber, Integer overridePageSize) {
        paginatedResponse responseObject; Map<String, String> urlParameters_Single = new Map<String, String>();
        system.debug('###getPatentFamilyChanges(): Entering function with fromDateTime = ' + fromDateTime + ' and pageNumber = ' + pageNumber + '.###');
        
        //first build the parameter map
        urlParameters_Single.put('from_date_time', encodeDateTime(fromDateTime));
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseObject = sendRequests(generateRequests(EndpointName.PatentFamilyChanges, urlParameters_Single, null, null, pageNumber, overridePageSize), 'response');
        //system.debug('###getPatentFamilyChanges(): Exiting function with responseObject = ' + responseObject + '.###');
        return responseObject;
    }
    
    public static paginatedResponse getPortfolioAnnotationChanges(DateTime fromDateTime, Integer pageNumber, Integer overridePageSize) {
        paginatedResponse responseObject; Map<String, String> urlParameters_Single = new Map<String, String>();
        system.debug('###getPortfolioAnnotationChanges(): Entering function with fromDateTime = ' + fromDateTime + ' and pageNumber = ' + pageNumber + '.###');
        
        //first build the parameter map
        urlParameters_Single.put('from_date_time', encodeDateTime(fromDateTime));
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseObject = sendRequests(generateRequests(EndpointName.PortfolioAnnotationChanges, urlParameters_Single, null, null, pageNumber, overridePageSize), 'response');
        //system.debug('###getPortfolioAnnotationChanges(): Exiting function with responseObject = ' + responseObject + '.###');
        return responseObject;
    }
    
    public static paginatedResponse getRelevantCompanyChanges(DateTime fromDateTime, Integer pageNumber, Integer overridePageSize) {
        paginatedResponse responseObject; Map<String, String> urlParameters_Single = new Map<String, String>();
        system.debug('###getRelevantCompanyChanges(): Entering function with fromDateTime = ' + fromDateTime + ' and pageNumber = ' + pageNumber + '.###');
        
        //first build the parameter map
        urlParameters_Single.put('from_date_time', encodeDateTime(fromDateTime));
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseObject = sendRequests(generateRequests(EndpointName.RelevantCompanyChanges, urlParameters_Single, null, null, pageNumber, overridePageSize), 'response');
        //system.debug('###getRelevantCompanyChanges(): Exiting function with responseObject = ' + responseObject + '.###');
        return responseObject;
    }
    
    public static paginatedResponse getTechTagChanges(DateTime fromDateTime, Integer pageNumber, Integer overridePageSize) {
        paginatedResponse responseObject; Map<String, String> urlParameters_Single = new Map<String, String>();
        system.debug('###getTechTagChanges(): Entering function with fromDateTime = ' + fromDateTime + ' and pageNumber = ' + pageNumber + '.###');
        
        //first build the parameter map
        urlParameters_Single.put('from_date_time', encodeDateTime(fromDateTime));
        
        //now build and send the request itself (Note: Different endpoint is used if we're in staging mode.)
        responseObject = sendRequests(generateRequests(EndpointName.TechTagChanges, urlParameters_Single, null, null, pageNumber, overridePageSize), 'response');
        //system.debug('###getTechTagChanges(): Exiting function with responseObject = ' + responseObject + '.###');
        return responseObject;
    }
    
    
    
    /*=== UTILITY FUNCTIONS ===*/
    
    public static String encodeDateTime(DateTime dateTimeValue) {
        // Returns the CoreAPI-compatible URL encoded version of this date time (in GMT)
        if (dateTimeValue == null) return null;
        else return EncodingUtil.urlEncode(dateTimeValue.formatGMT(DATE_TIME_FORMAT), 'UTF-8');
    }
    
    public static String encodeDate(Date dateValue) {
        // Returns the CoreAPI-compatible URL encoded version of this date (in GMT)
        if (dateValue == null) return null;
        else return EncodingUtil.urlEncode(((DateTime)dateValue).formatGMT(DATE_FORMAT), 'UTF-8');
    }
    
    public static String getEndpointURL(EndpointName theEndpoint) {
        // Retrieves the current endpoint url from custom settings. (Will return either production or staging based on the In_Production__c checkbox)
        CoreAPIAuthentication__c settingRecord = CoreAPIAuthentication__c.getValues(theEndpoint.name());
        
        if (settingRecord == null) {
            if (Test.isRunningTest()) return 'https://api.rpxcorp.com/core_patents/1/' + theEndpoint.name().toLowerCase(); // mock up the url for tests (if needed)
            else return null;
        } else if (settingRecord.In_Production__c) return settingRecord.URL__c;
        else return settingRecord.Staging_URL__c;
    }
    
    public static String getEndpointURL(EndpointName theEndpoint, Boolean returnProductionInfo) {
        // Retrieves the current endpoint url from custom settings. (Will return either production or staging based on [returnProductionInfo])
        CoreAPIAuthentication__c settingRecord = CoreAPIAuthentication__c.getValues(theEndpoint.name());
        
        if (settingRecord == null) {
            if (Test.isRunningTest()) return 'https://api.rpxcorp.com/core_patents/1/' + theEndpoint.name().toLowerCase(); // mock up the url for tests (if needed)
            else return null;
        } else if (returnProductionInfo) return settingRecord.URL__c;
        else return settingRecord.Staging_URL__c;
    }
    
    private static String getAuthenticationToken(EndpointName theEndpoint) {
        CoreAPIAuthentication__c settingRecord = CoreAPIAuthentication__c.getValues(theEndpoint.name());
        
        if (settingRecord == null) {
            if (Test.isRunningTest()) return '1234567abcdefg987654321xyzlmnop0'; // mock up the token for tests (if needed)
            else return null;
        } else if (settingRecord.In_Production__c) return settingRecord.Token__c;
        else return settingRecord.Staging_Token__c;
    }
    
    public static String responseRowListToString(ResponseRow[] responseRows) { return responseRowListToString(responseRows, TOSTRING_DEFAULT_SINGLEVALUEKEYS); }
    
    public static String responseRowListToString(ResponseRow[] responseRows, String singleValueKey) { return responseRowListToString(responseRows, new String[]{singleValueKey}); }
    
    public static String responseRowListToString(ResponseRow[] responseRows, String[] singleValueKeys) {
        // This is a static function converts an entire list of response rows to a string using the supplied value for keys to include
        // [singleValueKeys] is a list of keys 
        //     The specified keys from singleValues will be included in the output ( Example: {'id', 'patnum', 'title'} )
        //     If included and the first element equals '*', all keys will be included in the output ( Example: {'*'} )
        
        String[] rowsAsStrings = new String[]{};
        for (ResponseRow rr:responseRows) rowsAsStrings.add(rr.toString(singleValueKeys));
        return String.join(rowsAsStrings, '');
    }
    
    private static HttpRequest[] generateRequests(EndpointName theEndpoint, Map<String, String> urlParameters_Single, Map<String, String[]> urlParameters_Arrays, String searchParameterKey, Integer pageNumber, Integer overridePageSize) {
        // generates a list of http requests with authentication info
        // NOTE: The function will attempt to create a single request, but will dynamically generate more as required (to avoid going over MAX_URL_LENGTH)
        //       by slicing the primary search parameter list into batches.
        //    [theEndpoint] specifies the endpoint to use.
        //    [urlParameters_Single] contains non-array url parameters
        //    [urlParameters_Arrays] contains array-based url parameters
        //    [searchParameterKey] is an optional parameter used to specify the key in [urlParameters_Arrays] which maps to the "primary search" list (which must be sliceable)
        //    [pageNumber] controls which page is requested (only used for changes endpoints)
        //    [overridePageSize] manually overrides the page size specified in the constants, set to null to use default value 
        //               WARNING: Do not raise the page size above the default value unless your code is running in a batch context and the governor limits are higher. 
        
        system.debug('###generateRequests(): Entering function with theEndpoint = ' + theEndpoint + ' and urlParameters_Single = ' + urlParameters_Single + ', urlParameters_Arrays = ' + urlParameters_Arrays + ', searchParameterKey = ' + searchParameterKey + ' and pageNumber = ' + pageNumber + '.###');
        
        String authenticationToken;
        String mainURL;
        Boolean isFirstParameter = true;
        String[] searchParameters = new String[]{};
        HttpRequest[] returnRequests = new HttpRequest[]{};
        HttpRequest currentRequest;
        String[] currentSearchParameters = new String[]{};
        Integer searchParameterLength; Integer remainingURLLength;
        Integer numberOfRequests; Integer batchSize; 
        Integer startIndex; Integer stopIndex;
        Integer scaledPageSize;
        Boolean isChangesEndpoint;
        
        // First init all our state variables
        authenticationToken = getAuthenticationToken(theEndpoint);
        mainURL = getEndpointURL(theEndpoint);
        if (overridePageSize == null) overridePageSize = PAGE_SIZE;
        if (pageNumber == null) pageNumber = 1;
        
        // ADMIN NOTE: When adding a new CHANGES *EndpointName* add another logic branch below.
        //             This boolean controls whether the page size parameter is included. 
        isChangesEndpoint = (theEndpoint == EndpointName.ClaimChartedCompanyChanges)
                            || (theEndpoint == EndpointName.LicenseeChanges)
                            || (theEndpoint == EndpointName.PatentAnnotationChanges)
                            || (theEndpoint == EndpointName.PatentFamilyChanges) 
                            || (theEndpoint == EndpointName.PortfolioAnnotationChanges) 
                            || (theEndpoint == EndpointName.RelevantCompanyChanges)
                            || (theEndpoint == EndpointName.TechTagChanges);
        
        // Then process the url parameters
        if (urlParameters_Single != null)
            for (String key:urlParameters_Single.keySet())
                if (isFirstParameter) {
                    mainURL += '?' + key + '=' + urlParameters_Single.get(key);
                    isFirstParameter = false;
                } else {
                    mainURL += '&' + key + '=' + urlParameters_Single.get(key);
                }
        if (urlParameters_Arrays != null)
            for (String key:urlParameters_Arrays.keySet())
                for (String value:urlParameters_Arrays.get(key))
                    if (key == searchParameterKey)
                        searchParameters.add(key + '=' + value);
                    else {
                        if (isFirstParameter) {
                            mainURL += '?' + key + '=' + value;
                            isFirstParameter = false;
                        } else {
                            mainURL += '&' + key + '=' + value;
                        }
                    }
        
        
        // Now determine if (1) we have a search parameter and (2) if we are in danger of running out of URL characters
        if (searchParameters.size() > 0) {
            // first prep the main url for joining
            if (isFirstParameter) { mainURL += '?'; isFirstParameter = false; }
            else mainURL += '&';
            
            // run through all of the searchParameters and find the longest one
            searchParameterLength = 1;
            for (String searchParameter:searchParameters)
                searchParameterLength = Math.max(searchParameterLength, searchParameter.length());
            searchParameterLength++; // +1 for the amperstand
            
            remainingURLLength = MAX_URL_LENGTH - mainURL.length();
            if (isChangesEndpoint) remainingURLLength -= PAGE_SIZE_PARAM.length() + PAGE_NUMBER_PARAM.length() + '=100000&=500'.length(); //leave some space for the pagination variables
            
            batchSize = Math.max(Integer.valueOf(Math.floor(Decimal.valueOf(remainingURLLength)/searchParameterLength)), 1);
            numberOfRequests = Math.max(Integer.valueOf(Math.ceil(Decimal.valueOf(searchParameters.size())/batchSize)), 1);
            system.debug('###generateRequests(): In batch calculation branch with remainingURLLength = ' + remainingURLLength + ', searchParameterLength = ' + searchParameterLength + ', searchParameters.size() = ' + searchParameters.size() + ', batchSize = ' + batchSize + ', numberOfRequests = ' + numberOfRequests + '.###');    
        } else
            numberOfRequests = 1;
        
        
        // Now add pagination parameters (only if this is a changes endpoint)
        if (isChangesEndpoint) {
            // Note: In the case that there is pagination AND multiple requests we need to scale down the page size so we don't hit governor limits
            scaledPageSize = Integer.valueOf(Math.floor(overridePageSize / numberOfRequests)); 
            
            if (isFirstParameter) { mainURL += '?'; isFirstParameter = false; }
            else mainURL += '&';
            mainURL += PAGE_SIZE_PARAM + '=' + scaledPageSize;
            mainURL += '&' + PAGE_NUMBER_PARAM + '=' + String.valueOf(pageNumber);
        }
        
        system.debug('###generateRequests(): Done building mainURL = ' + mainURL + ', searchParameters = ' + searchParameters + ', numberOfRequests = ' + numberOfRequests + '.###');
        
        //Now build the requests
        for (Integer i=0; i<numberOfRequests; i++) {
            // First build the current slice of search parameters (if needed)
            if (searchParameters.size() > 0) {
                startIndex = i*batchSize;
                stopIndex = Math.min(((i+1)*batchSize), searchParameters.size());
                currentSearchParameters = new String[]{};
                for (Integer j=startIndex; j<stopIndex; j++)
                   currentSearchParameters.add(searchParameters[j]);
            }
            
            // Now build the the request itself
            currentRequest = new HTTPRequest();
            currentRequest.setMethod('GET');
            currentRequest.setEndpoint(mainURL + String.join(currentSearchParameters, '&'));
            currentRequest.setTimeout(HTTP_REQUEST_TIMEOUT);
            if ((authenticationToken != null) && (authenticationToken.trim() != ''))
                currentRequest.setHeader('Authorization' , 'Token token="' + authenticationToken.trim() + '"');
            
            system.debug('###generateRequests(): Done building currentRequest = ' + currentRequest + ', request url (length ' + currentRequest.getEndpoint().length() + ') = ' + currentRequest.getEndpoint() + '.###');
            returnRequests.add(currentRequest);
        }
        
        system.debug('###generateRequests(): Exiting function with returnRequests = ' + returnRequests + '.###');
        return returnRequests;
    }
    
    private static PaginatedResponse sendRequests(HttpRequest[] apiRequests, String responseKeyName) {
        // Submits request to api and returns the response as a list of response rows
        // Checks for pagination info and (if present) set the pagination state variables of the returned object
        // NOTE: Throws an exception (of type CoreAPI.ApiException) if there is a non-OK response from the web service.
        //    [responseKeyName] = the name of the parent-level branch of the JSON that contains the response rows
            
        system.debug('###sendRequests(): Entering function with apiRequests = ' + apiRequests + '.###');
        
        PaginatedResponse responseObject = new PaginatedResponse();
        Http http = new Http();
        HttpResponse currentResponse;
        String responseBody;
        Map<String, Object> responseMap;
        Object[] responseList;
        CoreAPIMockResponseGenerator mock;
        
        // Initialize the count variables (which will be composited if there are multiple requests)
        responseObject.perPage = 0;
        responseObject.itemCount = 0;
        responseObject.pageCount = 0;
        
        if (Test.isRunningTest() && SyncEngine.getDoNotCallout()) mock = new CoreAPIMockResponseGenerator();
        
        Integer counter = -1;

        // Check if we have any more requests available and if so... send it.
        for (HttpRequest apiRequest:apiRequests){
            if (Limits.getCallouts() < Limits.getLimitCallouts()) {                 
                counter++;
                system.debug('###sendRequests(): Initializing call to web service with urlEndpoint = ' + apiRequest.getEndpoint() + '.###');
                if (Test.isRunningTest() && SyncEngine.getDoNotCallout()) currentResponse = mock.respond(apiRequest);
                else currentResponse = http.send(apiRequest);
                responseBody = currentResponse.getBody();
                system.debug('###sendRequests(): Web service call complete. responseBody = ' + responseBody + '.###');
                if (currentResponse.getStatusCode() != 200) {
                    system.debug('###sendRequests(): Error encountered. Throwing exception e = ' + null + '.###');
                    throw new ApiException('Non-OK status code returned from external web service. (API Request = ' + apiRequest + ', API Response = ' + currentResponse + ').', 'ERROR');
                } else if (SyncEngine.getThrowTestError()) throw new ApiException('Test error. (Thrown because THROW_TEST_ERROR flag is set.)', 'ERROR');
                
                // Deserialize the response, then convert the returned maps into ResponseRows
                responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                responseList = (Object[])(responseMap.get(responseKeyName));
                //system.debug('###sendRequests(): Done de-serializing response into a list of maps with count = ' + responseList.size() + '. Entering responseRows building loop...###');
                
                if (responseList != null)
                    for (Integer index=0; index<responseList.size(); index++)
                        responseObject.responseRows.add(buildResponseRowFromMap((Map<String, Object>)responseList[index], responseKeyName + '.' + String.valueOf(index)));
                
                // Check for pagination info
                if (responseMap.containsKey('pagination')) {
                    Map<String, Object> paginationMap = (Map<String, Object>)responseMap.get('pagination');
                    if (paginationMap.get('previous') != null) responseObject.previousPage = (Integer)paginationMap.get('previous');
                    if (paginationMap.get('next') != null) responseObject.nextPage = (Integer)paginationMap.get('next');
                    if (paginationMap.get('current') != null) responseObject.currentPage = (Integer)paginationMap.get('current');
                    if (paginationMap.get('per_page') != null) responseObject.perPage += (Integer)paginationMap.get('per_page');
                    if (paginationMap.get('count') != null) responseObject.itemCount += (Integer)paginationMap.get('count');
                    if (paginationMap.get('pages') != null) responseObject.pageCount = Math.max((Integer)paginationMap.get('pages'), responseObject.pageCount); // keep the HIGHEST value of page count

                }
                
                
            } else {
                system.debug('###sendRequests(): Error encountered. Throwing exception e = ' + null + '.###');

                System.currentPagereference().getParameters().put('msg',System.Label.PatentSearchMaximumCalloutMessage);
                System.currentPagereference().getParameters().put('counter',String.valueof(counter+1));
                System.currentPagereference().getParameters().put('totalSize',String.valueof(apiRequests.size()));   
                
                if(Test.isRunningTest())
                    throw new ApiException('Maximum number of web callouts reached. Too many query parameters. Please reduce query size and try again.', 'ERROR');                
                
                break;             
            }
        }
        //system.debug('###sendRequests(): Exiting with responseObject = ' + responseObject + '.###');
        return responseObject;
    }    
    
    private static ResponseRow buildResponseRowFromMap(Object responseObject, String name) {
        // Recursive function builds a single response row from the passed response object
        //    [responseObject] = a map<string, object> 
        //         >> NOTE: Do NOT call this function with a list or a single primitive value
        //    [name] = the value to use as the "name" of the response row 
        //             (for a MAP row only, LIST rows are named with their index number)
        // NOTE: Lists of lists are not supported by the recursion in this function.
        //       Only lists of maps and lists of primitives are supported.
        
        ResponseRow responseRow = new ResponseRow(name);
        ResponseRow[] listChildren;
        Object curValue; Object[] curValueList;
        String[] listValues;
        
        //system.debug('###buildResponseRowFromMap(): Entering function with responseObject = ' + responseObject + '.###');
        
        if (responseObject instanceof Map<String, Object>) { // This is a MAP  
            Map<String, Object> responseMap = (Map<String, Object>)responseObject;
            
            for (String keyName:responseMap.keySet()) {
                curValue = responseMap.get(keyName);
                //system.debug('###buildResponseRowFromMap(): Inside responseMap loop with keyName = ' + keyName + ' and curValue = ' + curValue + ' (bool1 = ' + (curValue instanceof Map<String, Object>) + ', bool2 = ' + (curValue == null) + ').###');
                
                if (curValue == null) { 
                    //null values fire as true when compared "instanceof" to anything so we need to carve these off first
                    responseRow.singleValues.put(keyName, null);
                } else if (curValue instanceof Map<String, Object>) { //single complex value
                    responseRow.singleChildren.put(keyName, buildResponseRowFromMap(curValue, keyName)); //recursion 
                } else if (curValue instanceof Object[]) { //list but we need to figure out if it's primitive or complex
                    curValueList = (Object[])curValue;
                    if (curValueList.size() > 0) {
                        if (curValueList[0] instanceof Map<String, Object>) { // COMPLEX
                            listChildren = new ResponseRow[]{};
                            for (Integer index=0; index<curValueList.size(); index++)
                               listChildren.add(buildResponseRowFromMap(curValueList[index], keyName + '.' + String.valueOf(index))); //recursion
                            responseRow.listChildren.put(keyName, listChildren);
                        } else { // PRIMITIVE (Note: Lists of lists will also get flattened out here.)
                            listValues = new String[]{};
                            for (Object primitiveValue:curValueList) 
                                listValues.add(String.valueOf(primitiveValue));
                            responseRow.listValues.put(keyName, listValues);
                        }
                    } //else we won't store a zero size list
                } else { //single primitive value
                    responseRow.singleValues.put(keyName, String.valueOf(curValue));
                }
                
                //now we check to see if we have child rows and if so whether they are lists or not
            }  
        } else {
            // ERROR
            system.debug('###buildResponseRowFromMap(): Error! A responseObject was passed that is not a map. This might indicate that the web service response included a list of lists, which are not supported by the apex code. responseObject = ' + responseObject + '.###');
        }
        
        //system.debug('###buildResponseRowFromMap(): Exiting function with responseRow = ' + responseRow + '.###');
        return responseRow;
    }
    
    
    /*=== TEST FUNCTIONS ===*/
    
    public static void testCoreAPI_Live() { testCoreAPI_Live(EndpointName.PatentFamilies, new String[]{'US8287210', 'US8145824', 'US7429807'}); }
    
    public static void testCoreAPI_Live(EndpointName theEndpoint) {
        // ADMIN NOTE: When adding a new *EndpointName* add another logic branch below if needed. 
        //             (Only needed if the new endpoint is querying against an object with a non-country-patent-key id)
        if (theEndpoint == EndpointName.Patents) testCoreAPI_Live(theEndpoint, new String[]{'8287210', '8145824', '7429807'}); 
        else if ((theEndpoint == CoreAPI.EndpointName.ClaimChartedCompanies) || (theEndpoint == CoreAPI.EndpointName.Licensees) || (theEndpoint == CoreAPI.EndpointName.RelevantCompanies)) {
            Patent__c[] patents = [select id from Patent__c order by CreatedDate desc limit 10];
            String[] patentIds = new String[]{};
            for (Patent__c p:patents) patentIds.add(p.Id);
            testCoreAPI_Live(theEndpoint, patentIds);
        } else testCoreAPI_Live(theEndpoint, new String[]{'US8287210', 'US8145824', 'US7429807'});
    }
    
    public static void testCoreAPI_Live(EndpointName theEndpoint, String[] recordIds) {
        // This is a "live test" method.  It must be run from the developer console.
        // Since all of the http callouts are mocked in the actual test method, this is the only way to test the api with real data.
        //     [recordIds] should be....
        //        CHANGE ENDPOINTS: blank
        //        PATENTS: stripped patent numbers 
        //        CLAIM CHARTED COMPANY, LICENSEE, RELEVANT COMPANY: salesforce patent record id
        //        EVERYTHING ELSE: country patent numbers 
        
        system.debug('###testCoreAPI_Live(): Entering function.###');
        
        ResponseRow[] responseRows;
        PaginatedResponse paginatedResponse;
        DateTime fromDateTime = DateTime.now().addDays(-14);
        
        // ADMIN NOTE: When adding a new *EndpointName* add another logic branch below.
        if (theEndpoint == EndpointName.ClaimChartedCompanies) responseRows = getClaimChartedCompanies(null, recordIds, null);
        else if (theEndpoint == EndpointName.Licensees) responseRows = getLicensees(null, recordIds, null);
        else if (theEndpoint == EndpointName.Patents) responseRows = getPatents(recordIds, true, true, true);
        else if (theEndpoint == EndpointName.PatentAnnotations) responseRows = getPatentAnnotations(recordIds);
        else if (theEndpoint == EndpointName.PatentFamilies) responseRows = getPatentFamilies(null, null, null, recordIds, true, true, true, true, true, true);
        else if (theEndpoint == EndpointName.Portfolios) responseRows = getPortfolios(recordIds);
        else if (theEndpoint == EndpointName.RelevantCompanies) responseRows = getRelevantCompanies(null, recordIds, null);
        else if (theEndpoint == EndpointName.TechTags) responseRows = getTechTags(recordIds, null);
        else if (theEndpoint == EndpointName.ClaimChartedCompanyChanges) paginatedResponse = getClaimChartedCompanyChanges(fromDateTime, 1, null);
        else if (theEndpoint == EndpointName.LicenseeChanges) paginatedResponse = getLicenseeChanges(fromDateTime, 1, null);
        else if (theEndpoint == EndpointName.PatentAnnotationChanges) paginatedResponse = getPatentAnnotationChanges(fromDateTime, 1, null);
        else if (theEndpoint == EndpointName.PatentFamilyChanges) paginatedResponse = getPatentFamilyChanges(fromDateTime, 1, null);
        else if (theEndpoint == EndpointName.PortfolioAnnotationChanges) paginatedResponse = getPortfolioAnnotationChanges(fromDateTime, 1, null);
        else if (theEndpoint == EndpointName.RelevantCompanyChanges) paginatedResponse = getRelevantCompanyChanges(fromDateTime, 1, null);
        else if (theEndpoint == EndpointName.TechTagChanges) paginatedResponse = getTechTagChanges(fromDateTime, 1, null);
        
        if (responseRows != null) 
            system.debug('###testCoreAPI_Live(): Done querying API. responseRows = ' + responseRowListToString(responseRows, '*') + '.###');
        else
            system.debug('###testCoreAPI_Live(): Done querying API. paginatedResponse = ' + paginatedResponse.toString('*') + '.###');
        
        system.debug('###testCoreAPI_Live(): Exiting function.###');
    }
    
    
}