/*
    Apex Class:MemberAccountController
    Description: This Class is used as a controller for a page(MemberAccountWithHeatMapDetails) 
                 To display All member Account with Heat Map details.
    Created By : Bharti(Appirio offshore)
    Last Modified Date : 23rd jan 2012
*/
public without sharing class MemberAccountController {
    
    static Map<String,Map<Decimal,Decimal>> mapDateRating;
    static Map<String,Map<Decimal,Decimal>> mapROI;
    static Map<String,Map<Decimal,Decimal>> mapScore;
    static Map<String,Decimal> mapWeightInCalculation;
    //Static Block
    static {
        mapDateRating = new Map<String,Map<Decimal,Decimal>>();
        for(Date__c daterating : Date__c.getAll().values()){
            if(!mapDateRating.containsKey(daterating.type__c))
                mapDateRating.put(daterating.type__c,new Map<Decimal,Decimal>());
            if(daterating.Number_of_Months__c == null) daterating.Number_of_Months__c = -1.0;
            mapDateRating.get(daterating.type__c).put(daterating.Number_of_Months__c,daterating.Point__c);
        }
        
        
        mapROI = new Map<String,Map<Decimal,Decimal>>();
        for(ROI__c roiRating : ROI__c.getAll().values()){
            if(!mapROI.containsKey(roiRating.type__c))
                mapROI.put(roiRating.type__c,new Map<Decimal,Decimal>());
            mapROI.get(roiRating.type__c).put(roiRating.Lower_Limit__c,roiRating.Point__c);
        }
        
        mapWeightInCalculation = new Map<String,Decimal>();
        for(WeightInCalculation__c weightInCalc : WeightInCalculation__c.getAll().values()){
            mapWeightInCalculation.put(weightInCalc.Type__c,weightInCalc.Percent__c);
        }
        
    }
    
    public List<HeatMapWrapper> memberAccount {get;set;}
    public Boolean isAscending {get;set;}
    public string sortField {
        get;
        set {     
          this.previousSortField = sortField;
          this.sortField = value;
          if(previousSortField == sortField) {
            isAscending = !isAscending;
            return;
          }
            this.isAscending = true;  
         }
    }
        
    //variables
    private String previousSortField = '';
    
    public MemberAccountController(){
        previousSortField = 'AdjustedTotal';
        SortField = 'AdjustedTotal';
        isAscending = false;
        queryData();
    }
    
    public PageReference updateAccounts(){
        List<Account> accountsToUpdate = new List<Account>();
        for(HeatMapWrapper wrapper : memberAccount){
            if(wrapper.adjustedTotal != wrapper.Account.HeatMapScore__c || wrapper.color != wrapper.Account.HeatMapColor__c){
            accountsToUpdate.add(new Account(Id = wrapper.account.id , 
                                             HeatMapScore__c = wrapper.adjustedTotal,
                                             HeatMapColor__c = wrapper.color,
                                             HeatMapLastModifiedBy__c = UserInfo.getUserId(),
                                             HeatMapLastModifiedDate__c = DateTime.now()));
            }
        }
        
        system.debug('Bharti == ' + accountsToUpdate);
        update accountsToUpdate;
        return null;
    }
 
    //----------------------------------------------------------------//
    //Action methods for search
    //---------------------------------------------------------------//
    
    public PageReference DoSort(){     
        queryData();
        return null;    
    }
    
    //----------------------------------------------------------------//
    //Helper methods
    //---------------------------------------------------------------//    
    public void queryData(){
        memberAccount = new List<HeatMapWrapper>();
        for(Account account: database.query(buidQuery())){
            HeatMapWrapper wrapper = new HeatMapWrapper(account);
            memberAccount.add(wrapper);
        }
        
        if(SortField == 'AdjustedTotal'){
            memberAccount = sortByAdjustedTotal(memberAccount,isAscending);             
        }
        if(SortField != 'AdjustedTotal' || isAscending){
            setColorCodes(sortByAdjustedTotal(memberAccount,false));
        }else{
            setColorCodes(memberAccount);
        }
        system.debug('bharti  == ' + memberAccount);
    }  
    
    // Prepares query order by sortfield    
    private String buidQuery() {                
        string sortingOrder = 'ASC';
        if (isAscending == false){
          sortingOrder = 'DESC';
        }               
         
        string strQuery = 'select HeatMapScore__c,HeatMapColor__c ,Name,ContractROI__c,ProratedROI__c,Last12MonthROI__c,RenewalDate__c,Membership_Start_Date__c,Volume_of_dismissals__c,Proximity_of_dismissals_to_renewal_date__c,Most_Recent_OM__c,Most_Recent_Litigation__c,CROverride_for_Heat_Map__c,RPX_RCRate__c,OwnerId,Owner.Name from Account where RecordType.Name =\'Member\' and Type =\'Member\'';
        
        if(SortField != 'AdjustedTotal'){
            strQuery = strQuery + ' ORDER BY ' + SortField;
            strQuery = strQuery + ' ' + sortingOrder;
            strQuery = strQuery + ' NULLS LAST';
        }
        return strQuery;
    }
    
   private void setColorCodes(List<HeatMapWrapper> lst){
        HeatMapColorContribution__c colorContribution = HeatMapColorContribution__c.getAll().get('Default');
        Integer colorLimit =  Math.round(lst.size() * colorContribution.Red__c*0.01);
        String color = 'Red';
        for(Integer index = 0 ; index < lst.size(); index++ ){
            if(index < colorLimit){
                lst.get(index).color = color;
            }else{
                if(color == 'Red'){
                    colorLimit += Math.round(lst.size() * colorContribution.Yellow__c*0.01);
                    color = 'Yellow';
                }else{
                    colorLimit += Math.round(lst.size() * colorContribution.Green__c*0.01);
                    color = 'Green';
                }  
                lst.get(index).color = color;               
            }
        }
    }  
    
    private List<HeatMapWrapper> sortByAdjustedTotal(List<HeatMapWrapper> lst,Boolean isAscending){
        List<HeatMapWrapper> sortedList = new List<HeatMapWrapper>();
        for(HeatMapWrapper wrapper : lst){
            Integer position = 0;
            while(position < sortedList.size()){
                if((isAscending && wrapper.adjustedTotal <  sortedList.get(position).adjustedTotal)
                    || (!isAscending && wrapper.adjustedTotal >  sortedList.get(position).adjustedTotal)){
                    break;
                }
                position++;
            }               
            if(sortedList.size() == position)
                sortedList.add(wrapper);
            else{               
                sortedList.add(position,wrapper);
            }           
        }
        return sortedList;
    }  
    
    
    //Wrapper Class for Heat Map Details
    public class HeatMapWrapper {
        public Account account{get;set;}
        public String color{get;set;}
        public Decimal adjustedTotal{get;set;}
        public Decimal autoTotal{get;set;}
        public Decimal contractROIScore{get;set;}
        public Decimal proratedROIScore{get;set;}
        public Decimal ROITotal{get;set;}
        public Decimal renewalScore{get;set;}
        public Decimal dismissalsScore{get;set;}
        public Decimal twelveMonthROIScore{get;set;}
        public Decimal mostRecentOM_Score{get;set;}
        public Decimal mostRecentLitScore{get;set;}
        public Decimal recencyTotal{get;set;}
        public Decimal rateScore{get;set;} 
        public String appliedStyle {get;set;}
        
        //Constructor of wrapper Class 
        public HeatMapWrapper(Account account){
            this.account = account;
            this.mostRecentOM_Score = getMostRecentScore('MostRecentOMDeal',account.Most_Recent_OM__c);
            this.mostRecentLitScore = getMostRecentScore('MostRecentLitigation',account.Most_Recent_Litigation__c);
            this.renewalScore = getRenewalScore('Renewal',account.RenewalDate__c);
            this.contractROIScore = getROIScore('Contract',account.ContractROI__c);
            this.proratedROIScore = getROIScore('Prorated',account.ProratedROI__c);
            this.twelveMonthROIScore = getROIScore('12Month',account.Last12MonthROI__c);
            this.ROITotal = this.contractROIScore*mapWeightInCalculation.get('ContractROIWeight')*0.01 
                          + this.proratedROIScore*mapWeightInCalculation.get('ProratedROIWeight')*0.01;         
            this.recencyTotal = this.twelveMonthROIScore*mapWeightInCalculation.get('12MonthROIWeight')*0.01 
                              + this.mostRecentOM_Score*mapWeightInCalculation.get('MostRecentOMWeight')*0.01 
                              + this.mostRecentLitScore*mapWeightInCalculation.get('MostRecentLitWeight')*0.01;
            this.dismissalsScore = getDismissalsScore(account.Volume_of_dismissals__c);
            this.rateScore = getRateScore(account.RPX_RCRate__c);
            
            this.autoTotal = this.ROITotal*mapWeightInCalculation.get('ROI')*0.01
                           + this.renewalScore*mapWeightInCalculation.get('Renewal')*0.01
                           + this.dismissalsScore*mapWeightInCalculation.get('Dismissal')*0.01
                           + this.recencyTotal*mapWeightInCalculation.get('Recency')*0.01
                           + this.rateScore*mapWeightInCalculation.get('Rate')*0.01;
            
            this.appliedStyle = '';
            if(account.CROverride_for_Heat_Map__c == null){
                if(account.Membership_Start_Date__c != null && account.Membership_Start_Date__c.daysBetween(date.today()) < 90 && this.autoTotal > 3.4){
                    this.adjustedTotal = 3.4;
                }else{
                    this.adjustedTotal = this.autoTotal;
                }
            }else{
                this.adjustedTotal = account.CROverride_for_Heat_Map__c;
                this.appliedStyle += 'color:red;';
            }
            if(account.Membership_Start_Date__c != null && account.Membership_Start_Date__c.daysBetween(date.today()) < 90){                
                this.appliedStyle += 'text-decoration:underline;';
            }
                
        }
        //method used to determine scores according to date type(MostRecentOMDeal,MostRecentLitigation,Renewal)
        private Decimal getRenewalScore(String dateType , Date searchDate){
            Decimal matchedLimit;
            if(searchDate != null){
                for(Decimal numberOfMonths : mapDateRating.get(dateType).keyset()){
                    if(numberOfMonths == -1.0)
                        continue;
                    if(Date.today().addMonths(Integer.valueOf(numberOfMonths)).daysBetween(searchDate) <= 0 && (matchedLimit == null || matchedLimit > numberOfMonths)){
                        matchedLimit = numberOfMonths;
                    }               
                }
            }
            matchedLimit = matchedLimit == null ? -1.0 : matchedLimit;          
            return mapDateRating.get(dateType).get(matchedLimit);
        }
        
        //method used to determine scores according to date type(MostRecentOMDeal,MostRecentLitigation,Renewal)
        private Decimal getMostRecentScore(String dateType , Date searchDate){
            Decimal matchedLimit;
            if(searchDate != null){
                for(Decimal numberOfMonths : mapDateRating.get(dateType).keyset()){
                    if(numberOfMonths == -1.0)
                        continue;
                    if(searchDate.addMonths(Integer.valueOf(numberOfMonths)).daysBetween(Date.today()) >= 0 && (matchedLimit == null || matchedLimit < numberOfMonths)){
                        matchedLimit = numberOfMonths;
                    }               
                }
            }
            matchedLimit = matchedLimit == null ? -1.0 : matchedLimit;          
            return mapDateRating.get(dateType).get(matchedLimit);
        }
        
        //method used to determine scores according to ROI type(Contract,Prorated,12Month)
        private Decimal getROIScore(String dateType , Decimal searchROI){
            Decimal ratePoint,matchedLimit,minLimit;
            for(Decimal roiRating : mapROI.get(dateType).keyset()){
                if(searchROI != null){
                    if(roiRating < searchROI && (matchedLimit == null || matchedLimit < roiRating )){
                        matchedLimit = roiRating;
                    }
                }                       
                minLimit = minLimit == null || minLimit > roiRating? roiRating : minLimit;      
            }
            matchedLimit = matchedLimit == null ? minLimit : matchedLimit;
            ratePoint = mapROI.get(dateType).get(matchedLimit);
            return ratePoint;
        }
        //method used to calculate Dismissals Score
        private Decimal getDismissalsScore(Decimal dismissal){
            if(dismissal == null) return 0;
            for(DismissalScore__c dismissalScore : DismissalScore__c.getAll().values()){
                if(dismissal == dismissalScore.Dismissals_greater_than__c){
                    return dismissalScore.point__c;
                }
            }
            return 0;
        }
        //method used to calculate Rate Score
        private Decimal getRateScore(Decimal rate){
            rate = (rate == null || rate == 0) ? 1 : rate;
            Decimal ratePoint,matchedLimit;
            for(RateScore__c rateScore : RateScore__c.getAll().values()){
                if(rate > rateScore.rate_greater_than__c && ( matchedLimit == null || matchedLimit < rateScore.rate_greater_than__c)){
                    matchedLimit =  rateScore.rate_greater_than__c;
                    ratePoint = rateScore.point__c;
                }
            }
            return ratePoint;
        }
                
    }
}