/**************************************************************
 * Name             : AutoFollowOpp
 * Created By       : Tu Dao
 * Created Date     : Sep 20, 2012.
 * Purpose          : This page allows user to follow/unfollow Opps
 * Note            : Related Class : OpportunityTrigger
 **************************************************************/
public class AutoFollowOppController {
    
    public List<UserWrapper> followers{get;set;}
    public List<UserWrapper> unfollowers{get;set;}
    
    public boolean followAll{get;set;}
    public boolean unfollowAll{get;set;}
    
    public Set<String> oppStage;
    
    public User filter{get;set;}
    
    /*
    * Constructor 
    */
    public AutoFollowOppController(){
        this.filter = new User();
        this.oppStage = AutoFollowUtils.getOppLateStages();
        this.Reload();
    }
    
    public void ReLoad(){
        this.followers = this.getFollowingUsers();
        this.unfollowers = this.getUnfollowList();
    }
    
    public List<UserWrapper> getFollowingUsers(){
        List<UserWrapper> temp = new List<UserWrapper>();
        for(User usr : [Select u.Id, u.Title, u.Name, u.Email, u.Department From User u Where Auto_Follow_Opportunity__c = true Order by u.Name]){
            temp.add(new UserWrapper(usr));
        }
        return temp;
    }
    
    public List<UserWrapper> getUnfollowList(){
        String query = 'Select u.Id, u.Title, u.Name, u.Email, u.Department From User u Where IsActive=true AND Auto_Follow_Opportunity__c != true';
        String filterCond = '';
        if(filter.FirstName!=null){
            query += ' AND u.Name like \'%' + filter.FirstName + '%\'';
        }
        if(filter.Division!=null){
            query += ' AND u.Email like \'%' + filter.Division + '%\'';
        }
        if(filter.Title!=null){
            query += ' AND u.Title like \'%' + filter.Title + '%\'';
        }
        if(filter.Department!=null){
            query += ' AND u.Department like \'%' + filter.Department + '%\'';
        }
        query += ' Order by u.Name ';
        
        List<UserWrapper> temp = new List<UserWrapper>();
        for(User usr : Database.query(query)){
            temp.add(new UserWrapper(usr));
        }
        return temp;
    }
    
    public void follow(){
        List<User> selectedUsers = new List<User>();
        List<EntitySubscription> esFollowList = new List<EntitySubscription>();
        List<Opportunity> oppList = this.GetAvailableOpp();
        Map<Id, Set<Id>> userOppMap = this.GetUserOppMap(new Map<Id, Opportunity>(oppList).KeySet());
        
        EntitySubscription follow;
        
        for(UserWrapper uf : unfollowers){
            if(uf.selected==true){
                uf.user.Auto_Follow_Opportunity__c = true;
                selectedUsers.add(uf.user);
                for(Opportunity opp : oppList){
                    if(!this.IsEsExists(userOppMap, uf.User.Id, opp.Id)){
                        esFollowList.add(new EntitySubscription (parentId = opp.Id, SubscriberId = uf.user.Id));
                    }
                }
            }
        }
        update selectedUsers;   
        insert esFollowList;
        
        this.Reload();
    }
    
    public void searchUser(){
        this.unfollowers = this.getUnfollowList();
    }
    
    public void unfollow(){
        List<User> selectedUsers = new List<User>();
        
        for(UserWrapper f : followers){
            if(f.selected==true){
                f.user.Auto_Follow_Opportunity__c = false;
                selectedUsers.add(f.user);
            }
        }
        update selectedUsers;
        
        Set<Id> oppIds = new Map<Id,Opportunity>(this.GetAvailableOpp()).keySet();
        Set<Id> usrIds = new Map<Id,User>(selectedUsers).keySet();
        
        delete [Select Id from EntitySubscription where SubscriberId IN :usrIds and ParentId IN :oppIds];
        
        this.Reload();
    }
    
    private List<Opportunity> GetAvailableOpp(){
        return [Select Id from Opportunity where (StageName IN :oppStage OR (StageName = 'Initial Reach Out' AND Probability >= 11)) AND (RecordType__c=:AutoFollowUtils.OPP_INSURANCE_RECORD_TYPE)];
    }
    
    private Map<Id, Set<Id>> GetUserOppMap(Set<Id> sObjectIds){
        List<EntitySubscription> esList = [SELECT SubscriberId, ParentId FROM EntitySubscription WHERE ParentId IN :sObjectIds];
        Map<Id, Set<Id>> temp = new Map<Id, Set<Id>>();
            
        for(EntitySubscription item: esList){
            if(temp.ContainsKey(item.SubscriberId)){
                temp.Get(item.SubscriberId).Add(item.ParentId);
            }
            else{
                temp.Put(item.SubscriberId, new Set<Id>{item.ParentId});
            }
        }
        
        return temp;
    }
    
    private boolean IsEsExists(Map<Id, Set<Id>> userOppMap, Id subscriberId, Id parentId){
        if(!userOppMap.ContainsKey(subscriberId) || !userOppMap.Get(subscriberId).Contains(parentId)){
            return false;
        }
        else{
            return true;
        }
    }
    
    public class UserWrapper{
        public boolean selected{get;set;}
        public User user{get;set;}
        
        public UserWrapper(User u){
            this.user = u;
            this.selected = false;
        }
    }
    
    static testMethod void testAutoChatterFollow() {
        AutoFollowOppController controller = new AutoFollowOppController();
        controller.Filter = new User(FirstName = 'test', Division = 'test', Title = 'test', Department = 'test');
        controller.follow();
        controller.unfollow();
        controller.searchUser();
        
        //Test update Opportunity
        Account acct = TestUtil.createAccount(false);
        insert acct;
      
        Schema.DescribeSObjectResult oppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> rtMapByNameForOpp = oppSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtByNameForOpp =  rtMapByNameForOpp.get(AutoFollowUtils.OPP_INSURANCE_RECORD_TYPE);
        
        Opportunity opp = TestUtil.createOpportunity(acct.Id, 'Closed Won', false);
        opp.Discount__c = 0;
        opp.Discount_Amount__c = 0;
        opp.Win_Loss_Code__c = 'Test';
        opp.Specified_Publicity_on_Account_pg__c = true;
        opp.Attached_All_Relevant_Sales_Materials__c = true;
        opp.RecordTypeId = rtByNameForOpp.getRecordTypeId();
        opp.Per_Claim_Limit__c = 5;
        opp.Aggregate_Limit__c = 5;
        opp.Per_Claim_Retention__c =5;
        opp.Aggregate_Retention__c = 5;
        opp.Co_Pay__c = 25;
        opp.Annual_Premium__c = 5;
        opp.Annual_RPX_Membership_Fee__c = 5;
        opp.Bundle_Discount__c = 5;
        opp.RRG_Investment__c = 5;
        opp.Date_Quoted__c = date.today();
        insert opp;
    }
    
}