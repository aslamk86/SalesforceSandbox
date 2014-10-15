public class acctOppSort {

    List<Opportunity> opps;
    public String sortField {get; set;}
    public String previousSortField {get; set;}
    Public String myAccountName {set; get;}
    Public String myAccountID {set; get;}
    Private boolean test = false;
  
   /* public List<Opportunity> getOpps() {
        if(opps == null){
            myAccountID = ApexPages.currentPage().getParameters().get('AccountId');
            if (myAccountID == null) myAccountID = '0014000000KaG2W'; // test case = amazon.com
            myAccountName = [SELECT Name FROM Account WHERE Id=:myAccountID].Name;   

            AccountRelevantOpportunities aro = new AccountRelevantOpportunities();
            //opps = [select Id, Name, StageName, Probability, CloseDate, Amount, CreatedDate, CreatedById from Opportunity ORDER BY CloseDate DESC LIMIT 10];
            opps = aro.OppList;
        }
        return opps;
    }*/
    
    public void doSort(){
        String order = 'asc';
        
        /*This checks to see if the same header was click two times in a row, if so 
        it switches the order.*/
        if(previousSortField == sortField){
            order = 'desc';
            previousSortField = null;
        }else{
            previousSortField = sortField;
        }
       
        //To sort the table we simply need to use this one line, nice!
        superSort.sortList(opps,sortField,order);
    }
    
	public Static testMethod void Test() {
	  Account acct = TestUtil.createAccount(true);
	  Opportunity opp = Testutil.createOpportunity(acct.Id, 'Closed', true);
	  acctOppSort aos = new acctOppSort();
	  aos.opps = new List<Opportunity>{opp};
	  aos.sortField = 'stageName';
	  aos.doSort();
	  aos.doSort();
	}
	
}