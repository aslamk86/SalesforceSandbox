/**
  * Apex Class : AccountWithClaimChartsExt
  * Description : Class to fetch and summarise Accounts with claim charts data
  * Created By : Aslam
  * Created Date : Jan 17, 2014
  */

public class AccountWithClaimChartsExt {
    public Map<Id,Set<id>> numberOfPatentFamilies{get; set;}
    public Map<Id,Integer> countOfPatentFamilies{get; set;}
    public Acquisition_Opportunity__c thisAcquisition {get; set;}
    public List<Accounts_with_Claim_Charts__c> accountWithClaimChartsList {get; set;}
    public List<Account> accountIds {get; set;}
    
    public List<OMA_Patent__c> thisPatentList{get; set;}
    public List<Accounts_with_Claim_Charts__c> claimsPatentList{get; set;}
    
    public Set<Id> thisPatentNames{get; set;}
    
    public AccountWithClaimChartsExt(ApexPages.StandardController controller) {
        
        //Get this acquisition record
        thisAcquisition = (Acquisition_Opportunity__c)controller.getRecord();
        
        //Get all the patents for this Acquistion using the OMA Patent relationship
        thisPatentList = [select id,Patent__c,Patent__r.Patent_Family__c,Patent__r.Name from OMA_Patent__c 
                                              where Acquisition_Opportunity__c=:thisAcquisition.id ];
        thisPatentNames = new Set<Id>();
        
        //Add patents to a Set, which will be used next to get the list of patents associated with accounts. 
        for(OMA_Patent__c omaPat: thisPatentList){
            thisPatentNames.add(omaPat.Patent__c); //Set containing all patents for this acquisition
        }        
                
        accountWithClaimChartsList = [select id,Account__c,Account__r.Name,Patent__c from Accounts_with_Claim_Charts__c 
                                        where AcquisitionOpportunity__c = :thisAcquisition.id];
        
        countOfPatentFamilies = new Map<Id,Integer>();
        accountIds = new List<Account>();
        for(Accounts_with_Claim_Charts__c acClmChart: accountWithClaimChartsList ){
            if(countOfPatentFamilies.get(acClmChart.Account__c)==null){
                    countOfPatentFamilies.put(acClmChart.Account__c,0);
                    accountIds.add(new Account(id=acClmChart.Account__c, Name=acClmChart.Account__r.Name));
            }
            if(thisPatentNames.contains(acClmChart.patent__c)){           
                    countOfPatentFamilies.put(acClmChart.Account__c,countOfPatentFamilies.get(acClmChart.Account__c)+1);                
            }
        }
    }

}