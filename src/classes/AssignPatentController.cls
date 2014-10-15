/*****************************************************************************
 * Name             : AssignPatentController
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 06 Feb, 2012.
 * Last Modified    : 9/21/13 by Hank Ryan Thompson
 * Purpose          : This controller powers two different visualforce pages:
 *                     - AssignPatent.page
 *                     - CorePatentSearch.page
 *
 *                    T-24262  
*****************************************************************************/
public without sharing class AssignPatentController {
  
    private Map<String, String> pageParams = new Map<String, String>();
    private Id recordId;
    private static String INFO_SELECT_ANY_PATENT = Label.Atleast_One_Patent_Required;
    private static String INFO_NO_PATENT_FOUND = Label.No_Patent_Found;
    private static String INFO_REQUIRED_SEARCH_CRITERIA = Label.Search_Criteria_Required;
    private static String ERROR_CORE_API = Label.Core_API_Error;
  
    public Boolean includeNonUSPatents {get;set;}
    public Acquisition_Opportunity__c acquisition {get;set;}
    public String srchPatentNum {get;set;}
    public String srchPubNum {get;set;}
    public String srchAppNum {get;set;}
    public List<ResultRow> resultRows{get;set;}
    public Integer resultRowCount {get;set;}
    
    public String[] matchedNumbers {get;set;}
    public String[] unmatchedNumbers {get;set;}
    public String getMatchedNumberString() { if (matchedNumbers != null) return String.join(matchedNumbers, ', '); else return null; }
    public String getUnmatchedNumberString() { if (unmatchedNumbers != null) return String.join(unmatchedNumbers, ', '); else return null; } 
    
    public String msg{get; set;}
    public Integer counter{get; set;}    
    
    //----------------------------------------------------------------------------
    //Wrapper Class for Result table
    //   The rows are nested with a patentFamily having children for each patent
    //   The patentFamilies cannot be selected, only the child patents
    //----------------------------------------------------------------------------
    public Class ResultRow {
        public Boolean isSelected {get;set;}
        public Boolean isDisabled{get;set;}
        public Patent__c patent{get;set;}
        public Assets__c patentFamily{get;set;}
        public ResultRow parent{get;set;}
        public ResultRow[] children{get;set;}
        public Acquisition_Opportunity__c[] relatedAcquisitions{get;set;}                
        public Litigation__c[] relatedLitigations{get; set;}
        private CoreAPI.ResponseRow originalResponseRow;
        
        //----------------------------------------------------------------------------
        //Intelligent Getters
        //----------------------------------------------------------------------------
        public Boolean getIsBlankPatentFamily() {
            return (patentFamily != null) && ((patentFamily.name == '') || (patentFamily.name == null));
        }
        public Boolean getIsInSalesforce() { //returns true if record is stored in salesforce
            return ((patent != null) && (patent.Id != null))
                || ((patentFamily != null) && (patentFamily.Id != null));
        }
        
        public String getDetailURL() { //returns the relative URL for the detail page of this record (either salesforce or core)
            if (patent != null) return SyncEngine.getDetailURL(patent);
            else if (patentFamily != null) return SyncEngine.getDetailURL(patentFamily);
            else return null;
        }
        public String getAPIResponseText() { 
            // Returns a string representation of all of the (flattened) values returned from the api (even un-mapped values)
            // This is very helpful for trouble-shooting and finding new values to map.
            if ((originalResponseRow == null) || (originalResponseRow.allFlattenedValues == null)) return null;
            else return SyncEngine.mapToString(originalResponseRow.allFlattenedValues);
        }
        
        //----------------------------------------------------------------------------
        //Constructor
        //----------------------------------------------------------------------------
        public ResultRow(Patent__c patent, ResultRow parent, Boolean isDisabled, Boolean isSelected) {
            this.patent = patent;
            this.patentFamily = null;
            this.parent = parent;
            this.children = new ResultRow[]{};
            this.isDisabled = isDisabled;
            this.isSelected = isSelected;
            this.relatedAcquisitions = new Acquisition_Opportunity__c[]{};
            this.relatedLitigations = new Litigation__c[]{};
        }
        public ResultRow(Assets__c patentFamily) {
            this.patent = null;
            this.patentFamily = patentFamily;
            this.parent = null;
            this.children = new ResultRow[]{};
            this.isSelected = false;
            this.isDisabled = false;
            this.relatedAcquisitions = new Acquisition_Opportunity__c[]{};
            this.relatedLitigations = new Litigation__c[]{};
        }
    }
  
    //----------------------------------------------------------------------------
    //Constructor
    //----------------------------------------------------------------------------
    public assignPatentController() {
        resultRows = new List<ResultRow>();
        pageParams = ApexPages.currentPage().getParameters();
        includeNonUSPatents = false;
        resultRowCount = 0;
        
        if(!pageParams.containsKey('relatedRecordId')){
          return;
        }
        recordId = (ID)pageParams.get('relatedRecordId');
        if (recordId != null) {
            Acquisition_Opportunity__c[] tempList = [select Id, Name, AccountId__c, rpx_project_code__c, StageName__c from Acquisition_Opportunity__c where Id = :recordId];
            if (tempList.size() > 0) acquisition = tempList[0];
            else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'relatedRecordId is not a valid Acquisition record id.'));
        }
    }
  
    //----------------------------------------------------------------------------
    //Searches Patents for Given criteria (Note: Filters out non-us patents)
    //----------------------------------------------------------------------------
    String regex_stripPatentNumber = '^(?!RE|PP)[A-Z]{2}|[A-Z]\\d?$'; // selects country code and kind code
    public PageReference searchPatents() {
        
        system.debug('###searchPatents(): Entering function with srchPatentNum = ' + srchPatentNum + ', srchAppNum = ' + srchAppNum + ' srchPubNum = ' + srchPubNum + '.###');
        
        SyncEngine.ConvertedResponseRow[] responseRows;
        Boolean apiError = false; Boolean infoErrorOnly = false; String errorText = '';
        List<String> ptNumbers;
        List<String> appNumbers;
        List<String> pubNumbers;
        Set<String> searchParameters = new Set<String>(); //contains all search parameters
        Set<String> strippedSearchParameters = new Set<String>(); //stripped with regex 
        Set<Id> patentIds = new Set<Id>();
        Map<Id, Acquisition_Opportunity__c[]> patentAcquisitionMap = new Map<Id, Acquisition_Opportunity__c[]>(); // maps patent record id to the list of related acquisitions in that patent's ResultRow 
        Map<Id, Opportunity_Litigation__c[]> patentLitigationMap = new Map<Id,Opportunity_Litigation__c[]>();
        
        ResultRow newPFRow; ResultRow newPRow;
        OMA_Patent__c[] omaPatents;
        Set<String> allReturnParameters = new Set<String>(); //a set of the stripped pat/app/pub of all the returned rows
        Set<String> currentReturnParameters;
        Boolean isAlreadyLinked; Boolean isForeign; Boolean isMatch;
        
        Patents_in_Suit__c[] patentsInSuit;
        Set<Id> litigationIds = new Set<Id>();
        Map<Id, Set<Id>> litigationPatentIdMap = new Map<Id, Set<Id>>(); //maps from litigation id to a set of of related patent ids
        Opportunity_Litigation__c[] oppLitigations;
        Map<Id, Set<Id>> patentLitAcquisitionIdMap = new Map<Id, Set<Id>>(); //maps from patent id to a set of of related litigation acquisition ids
        Map<Id, Acquisition_Opportunity__c> litAcquisitionMap = new Map<Id, Acquisition_Opportunity__c>(); //maps from acqusition id to the record itself
        
        Set<Id> existingPatentIds = fetchOMAPatentsForAcqOpp(recordId);
        
        // initialize results
        resultRows = new List<ResultRow>();
        matchedNumbers = new String[]{};
        unmatchedNumbers = new String[]{};
        resultRowCount = 0;
        
        // clean up and process the search parameters
        srchPatentNum = formatSearchText(srchPatentNum);
        srchAppNum = formatSearchText(srchAppNum);
        srchPubNum = formatSearchText(srchPubNum);
        system.debug('###searchPatents(): Done formatting search text. srchPatentNum = ' + srchPatentNum + ', srchAppNum = ' + srchAppNum + ', srchPubNum = ' + srchPubNum + '.###');
        ptNumbers = buildSearchList(srchPatentNum, true);
        appNumbers = buildSearchList(srchAppNum, false);
        pubNumbers = buildSearchList(srchPubNum, false);
        system.debug('###searchPatents(): Done building search lists. ptNumbers = ' + ptNumbers + ', appNumbers = ' + appNumbers + ', pubNumbers = ' + pubNumbers + '.###');
        
        if ((ptNumbers.size() + appNumbers.size() + pubNumbers.size()) == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, INFO_REQUIRED_SEARCH_CRITERIA));
            system.debug('###searchPatents(): Exiting with error because there are no search parameters.###');
            return null; 
        }
        
        // add everything to the searchParameters set to allow for easy determination of matches 
        searchParameters.addAll(ptNumbers);
        searchParameters.addAll(appNumbers);
        searchParameters.addAll(pubNumbers);
        for (String s:searchParameters)
            strippedSearchParameters.add(s.replaceAll(regex_stripPatentNumber, ''));
        system.debug('###searchPatents(): searchParameters = ' + searchParameters + ', strippedSearchParameters = ' + strippedSearchParameters + '.###');
                
        // query the API for the patents (this function will also match them up with salesforce records if present)
                                        
        try {responseRows = SyncEngine.getPatentFamiliesSearchPage(appNumbers, null, pubNumbers, ptNumbers, true, true);
            msg = System.currentPagereference().getParameters().get('msg');
            String tempCounter=System.currentPagereference().getParameters().get('counter');
            if(tempCounter!=null)
                counter = Integer.valueOf(tempCounter);
            else counter = 0;
        }
        catch(Exception e) {
            apiError = true;
            errorText = e.getMessage();
            
            infoErrorOnly = 
                ((e instanceof CoreAPI.ApiException) && (((CoreAPI.ApiException)e).errorType == 'INFO')) 
                || ((e instanceof SyncEngine.SyncException) && (((SyncEngine.SyncException)e).errorType == 'INFO'));
             
            responseRows = new SyncEngine.ConvertedResponseRow[]{};
        }
        system.debug('###searchPatents(): Done getting responseRows = ' + responseRows + '.###');
        
        //build the responseRows
        for (SyncEngine.ConvertedResponseRow pfRow:responseRows) {
            newPFRow = new ResultRow(pfRow.patentFamily);
            newPFRow.originalResponseRow = pfRow.originalResponseRow;
            pfRow.originalResponseRow.minimizeViewState(); //clears out un-needed collections
            resultRowCount++;
        
            for (Patent__c patent:pfRow.childPatents) {
                //system.debug('###searchPatents(): In loop with patent = ' + patent + '.###');
                if (includeNonUSPatents || (patent.Country__c == 'US') || (patent.Country__c == '') || (patent.Country__c == null)) { // filter out non-us matches
                    isAlreadyLinked = existingPatentIds.contains(patent.Id);
                    isForeign = ((patent.Country__c != 'US') && (patent.Country__c != '') && (patent.Country__c != null));
                    newPRow = new ResultRow(patent, newPFRow, isAlreadyLinked || isForeign, isAlreadyLinked); //disable if already added or foreign (non-us patents have no core id and can't be added at this time), check only if linked
                    newPRow.originalResponseRow = pfRow.originalChildResponseRowMap.get(SyncEngine.getPrimaryKey(patent));
                    newPRow.originalResponseRow.minimizeViewState(); //clears out un-needed collections
                    newPFRow.children.add(newPRow);
                    resultRowCount++;
                    
                    // First, strip down all the searchable parameters returned by this row and add them to the master list
                    currentReturnParameters = new Set<String>();
                    if (newPRow.patent.Patent_No__c != null) currentReturnParameters.add(newPRow.patent.Patent_No__c);
                    if (newPRow.patent.Application_Number__c != null) currentReturnParameters.add(newPRow.patent.Application_Number__c.replaceAll(regex_stripPatentNumber, ''));
                    if (newPRow.patent.Publication_Number__c != null) currentReturnParameters.add(newPRow.patent.Publication_Number__c.replaceAll(regex_stripPatentNumber, ''));
                    allReturnParameters.addAll(currentReturnParameters);
                    
                    // Then determine whether this is a match and check the box if so (don't uncheck box if it's a disabled item)
                    isMatch = false;
                    for (String returnParameter:currentReturnParameters) isMatch = isMatch || strippedSearchParameters.contains(returnParameter);
                    newPRow.isSelected = newPRow.isSelected || isMatch; 
                    
                    if (patent.Id != null) {
                        patentIds.add(patent.Id);
                        patentAcquisitionMap.put(patent.Id, newPRow.relatedAcquisitions); //store a link to the omaPatents list for later    
                        //patentLitigationMap.put(patent.Id, newPRow.relatedLitigations);
                    }
                }
            }
            resultRows.add(newPFRow);
        }
        system.debug('###searchPatents(): Done building resultRows = ' + resultRows + ' and patentIds = ' + patentIds + '.###');
        
        // now query for related acquisitions and add them directly to the acquisition lists in the response rows
        if (patentIds.size() > 0) {
            // First query for oma patents and add them 
            omaPatents = [select Id, Name, Acquisition_Opportunity__c, Acquisition_Opportunity__r.Name, Patent__c, Patent__r.Name from OMA_Patent__c where Patent__c in :patentIds];
            system.debug('###searchPatents(): Done querying for omaPatents = ' + omaPatents + '.###');
            for (OMA_Patent__c omap:omaPatents)
                patentAcquisitionMap.get(omap.Patent__c).add(new Acquisition_Opportunity__c(
                   Id = omap.Acquisition_Opportunity__c,
                   Name = omap.Acquisition_Opportunity__r.Name
                ));
                
            // Now query for related litigation acquisitions (it's a two step process).. first get the patents in suit, then get the litigations
            patentsInSuit = [select id,Patent__c, Litigation__c,Litigation__r.Name from Patents_in_Suit__c where Patent__c in :patentIds];
            for (Patents_in_Suit__c pis:patentsInSuit) {
                litigationIds.add(pis.Litigation__c);
                if (litigationPatentIdMap.containsKey(pis.Litigation__c)) litigationPatentIdMap.get(pis.Litigation__c).add(pis.Patent__c);
                else litigationPatentIdMap.put(pis.Litigation__c, new Set<Id>{pis.Patent__c});
            }
            
            
            
            oppLitigations = [select Litigation__c, Acquisition_Opportunity__c, Acquisition_Opportunity__r.Name from Opportunity_Litigation__c where Litigation__c in :litigationIds];
            system.debug('###searchPatents(): Done querying for patentsInSuit = ' + patentsInSuit + ' and oppLitigations = ' + oppLitigations + '.###');
            for (Opportunity_Litigation__c ol:oppLitigations) {
                litAcquisitionMap.put(ol.Acquisition_Opportunity__c, new Acquisition_Opportunity__c(
                       Id = ol.Acquisition_Opportunity__c,
                       Name = ol.Acquisition_Opportunity__r.Name
                ));                
                
                for (Id patentId:litigationPatentIdMap.get(ol.Litigation__c))
                    if (patentLitAcquisitionIdMap.containsKey(patentId)) patentLitAcquisitionIdMap.get(patentId).add(ol.Acquisition_Opportunity__c);
                    else patentLitAcquisitionIdMap.put(patentId, new Set<Id>{ol.Acquisition_Opportunity__c});
            }
            
            // Run back through the patentLitAcquisitionIdMap and add each acquisition to the patent's row (using the map prevents duplicates)
            for (Id patentId:patentLitAcquisitionIdMap.keySet())
                for (Id litAcquisitionId:patentLitAcquisitionIdMap.get(patentId))
                    patentAcquisitionMap.get(patentId).add(litAcquisitionMap.get(litAcquisitionId));
        }
         
        if(patentsInSuit!=null && patentsInSuit.size()>0){
         for(Patents_in_Suit__c patTemp:patentsInSuit){
                for(ResultRow r:resultRows){
                    for(ResultRow childRow:r.children){
                        if(childRow.Patent.Id==patTemp.Patent__c)
                            childRow.relatedLitigations.add(new Litigation__c(id=patTemp.Litigation__c,Name=patTemp.Litigation__r.Name));
                    }
                }
            }  
        }
        // finally let's build out the list of matched & unmatched search parameters
        for (String s:searchParameters)
            if (allReturnParameters.contains(s.replaceAll(regex_stripPatentNumber, '')))
                matchedNumbers.add(s);
            else
                unmatchedNumbers.add(s);
        system.debug('###searchPatents(): Done determining matches. allReturnParameters = ' + allReturnParameters + ', matchedNumbers = ' + matchedNumbers + ', unmatchedNumbers = ' + unmatchedNumbers + '.###');
        
        system.debug('###searchPatents(): Exiting function with resultRows = ' + resultRows + '.###');
        if (apiError) {
            if (infoErrorOnly) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, errorText));
            else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ERROR_CORE_API+'\n\nError Message: '+errorText));
        } else if (resultRows.size() == 0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,INFO_NO_PATENT_FOUND)); 
        
        return null;
    }
  
    //----------------------------------------------------------------------------
    //Creates OMA Patent Records for Selected values
    //----------------------------------------------------------------------------
    public pageReference createMappingRecords() {
        
        system.debug('###createMappingRecords(): Entering function.###');
        
        List<ResultRow> selectedRows;
        List<Assets__c> patentFamiliesToInsert = new List<Assets__c>();
        List<Patent__c> patentsToInsert = new List<Patent__c>();
        List<OMA_Patent__c> omaPatentsToInsert = new List<OMA_Patent__c>();
        Set<String> processedPatentFamilyKeys = new Set<String>();
        PageReference returnPage = new PageReference('/' + recordId);
        
        // get the selected rows & display error if none
        selectedRows = getSelectedPatentRows(resultRows);
        system.debug('###createMappingRecords(): selectedRows = ' + selectedRows + '.###');
        if(selectedRows.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,INFO_SELECT_ANY_PATENT));
            return null;
        }
        
        // first run through and build a list of patent families that need inserting (filter out blank patent family rows by testing the primary key)
        for (ResultRow row:selectedRows)
            if ((row.parent.patentFamily.Id == null)
            && (SyncEngine.getPrimaryKey(row.parent.patentFamily) != '0')
            && !processedPatentFamilyKeys.contains(SyncEngine.getPrimaryKey(row.parent.patentFamily))) {
                patentFamiliesToInsert.add(row.parent.patentFamily);
                processedPatentFamilyKeys.add(SyncEngine.getPrimaryKey(row.parent.patentFamily)); //this prevents us form adding dupes to the list
            }
        if (patentFamiliesToInsert.size() > 0) insert patentFamiliesToInsert; //this should automatically populate the ids in their respective ResultRows
        system.debug('###createMappingRecords(): Done inserting patentFamiliesToInsert = ' + patentFamiliesToInsert + '.###');
        
        // now run through and build a list of patents that need inserting
        for (ResultRow row:selectedRows)
            if (row.patent.Id == null) {
                if (row.patent.Patent_Family__c == null) row.patent.Patent_Family__c = row.parent.patentFamily.Id;
                patentsToInsert.add(row.patent);
            }
        if (patentsToInsert.size() > 0) insert patentsToInsert; //this should automatically populate the ids in their respective ResultRows
        system.debug('###createMappingRecords(): Done inserting patentsToInsert = ' + patentsToInsert + '.###');
        
        // now that all selected records are isnerted we can run back through one last time and build out the oma patent records (a trigger will create the patent family join records) 
        for (ResultRow row:selectedRows)
            omaPatentsToInsert.add(new OMA_Patent__c(Acquisition_Opportunity__c = recordId, Patent__c = row.patent.Id));
        if (omaPatentsToInsert.size() > 0) insert omaPatentsToInsert;
        system.debug('###createMappingRecords(): Done inserting omaPatentsToInsert = ' + omaPatentsToInsert + '.###');
        
        system.debug('###createMappingRecords(): Exiting function.###');
        returnPage.setRedirect(true);
        return returnPage;
    }
  
    //----------------------------------------------------------------------------
    //Return user back to Acquisition Opportunity 
    //----------------------------------------------------------------------------
    public pageReference cancel() {
        if(recordId != null) {
            PageReference pg = new PageReference('/' + recordId);
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
    
    //----------------------------------------------------------------------------
    //Returns list of selected Patents
    //----------------------------------------------------------------------------
    private List<ResultRow> getSelectedPatentRows(List<ResultRow> lstResultRow) {
        List<ResultRow> selectedRows = new List<ResultRow>();
         
        for (ResultRow pfRow:lstResultRow)
            for (ResultRow pRow:pfRow.children)
                if (pRow.isSelected && !pRow.isDisabled)
                    selectedRows.add(pRow);
        
        return selectedRows;
    }
  
    //---------------------------------------------------------------------------------  
    //Step 1: Clean up special characters, then identify & isolate patent-type numbers
    //        NOTE: This function is designed to support the copy-and-paste of
    //        blocks of html-formatted text that contain patent numbers but also 
    //        other unrelated text and numbers. 
    //---------------------------------------------------------------------------------
    String regex_PatentTypeNumber = '\\b([A-Z]{2})?(RE|PP|D|H)?\\d{5,15}([A-Z][0-9]?)?\\b'; // matches all patent/application/publication numbers
    private String formatSearchText(String srchTxt){
        String result = srchTxt;
        String[] patentTypeNumbers = new String[]{};
        Pattern patentTypeNumberPattern = Pattern.compile(regex_PatentTypeNumber);
        Matcher patentTypeNumberMatcher;
        
        if (result == null) result = '';

        // First remove commas and replace all special characters with semi-colons.
        //     NOTE: Commas need to be replaced with a blank so that patent numbers in the form of "6,543,210" aren't split up
        result = result.toUpperCase().trim().replace(',','').replace(' ',';').replace('\r',';').replace('\t',';').replace('\n',';');
        for(integer i=0; i< 10; i++){
            result = result.replace(';;',';');
        }
        
        // Next extract the patent-type numbers
        patentTypeNumberMatcher = patentTypeNumberPattern.matcher(result);
        do {
            if (patentTypeNumberMatcher.find())
                patentTypeNumbers.add(patentTypeNumberMatcher.group());
        } while (!patentTypeNumberMatcher.hitEnd());
        result = String.join(patentTypeNumbers, ';');

        return result;
    }
    
    //----------------------------------------------------------------------------  
    // Creates and returns a list of strings from [srchTxt]
    // Assumes that [srchTxt] contains only valid patent-type formatted numbers
    //    [addCountryCode] will add  "US" to beginning of string if country code is not present
    //----------------------------------------------------------------------------
    String regex_StrippedPatentNumber = '^(RE|PP|D|H)?\\d{5,15}$'; // matches only valid stripped patent numbers (acceptable document type code followed by digits)
    private List<String> buildSearchList(String srchTxt, Boolean addCountryCode) {
        Set<String> cleanNumSet = new Set<String>();
        List<String> cleanNumList = new List<String>();
        Pattern strippedPatentNumberPattern = Pattern.compile(regex_StrippedPatentNumber);
        
        if (srchTxt != null && srchTxt.trim() != '')
            for (String patentTypeNum:srchTxt.split(';')) {
                patentTypeNum = patentTypeNum.trim().toUpperCase();
                system.debug('###buildSearchList(): Inside loop with patentTypeNum = ' + patentTypeNum + ', isStripped? = ' + strippedPatentNumberPattern.matcher(patentTypeNum).find() + '###');
                
                if (patentTypeNum != '') {
                    if (addCountryCode && strippedPatentNumberPattern.matcher(patentTypeNum).find())
                        patentTypeNum = 'US' + patentTypeNum; //only add the "US" if this is a stripped patent number
                    
                    cleanNumSet.add(patentTypeNum);
                }
            }
        
        cleanNumList.addAll(cleanNumSet);
        return cleanNumList;
    }
  
    //----------------------------------------------------------------------------
    //Returns existing OMA Patent Record for Acquisition Opportunity
    //----------------------------------------------------------------------------
    private Set<Id> fetchOMAPatentsForAcqOpp(Id acqOppId) {
        Set<Id> patentIds = new Set<Id>();
        
        for (OMA_Patent__c pt : [Select id ,Patent__c From OMA_Patent__c Where Acquisition_Opportunity__c = :acqOppId]) {
            patentIds.add(pt.Patent__c);
        }
        
        return patentIds;
    }
    
}