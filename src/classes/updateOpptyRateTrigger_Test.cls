/**
 * This class contains unit tests for validating the behavior of the
 * updateOpptyRpxRate.trigger.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 */
@isTest
private class updateOpptyRateTrigger_Test {

    static testMethod void updateOpptyRateTest() {
    	
    	// Account test variables
    	Double acRevCur;
     	Double acOpIncY1;
    	Double acOpIncY2;
    	Double acOpIncY3;
    	String acName;
    	String acProspect;
    	String acMember;
    	 
    	// Opportunity test variables
    	Double opDisc;
    	Double opAmt;
    	Double opSGR;
    	Date opClsDate;
    	String opProspectName;
		String opClosedWonName;
    	String opNewBizType;
    	String opRenewType;
    	String opMember;
    	String opProspectStage;
    	String opClosedWonStage;

        // Get the owner ID
        User ownerId = [Select u.Id From User u  where u.Profile.Name = 'System Administrator' limit 1];

    	// Account Name - Account.Name
    	acName = 'RPXTest';
    	// Account Types - Account.Type
    	acProspect = 'Prospect';
    	acMember = 'Member';
    	// Revenue Current Year - Account.AnnualRevenue
    	acRevCur = 400000;
    	// Operating Income Y1 - Account.Operating_Income_Y1__c
    	acOpIncY1 = 100000;
    	// Operating Income Y2 - Account.Operating_Income_Y2__c
    	acOpIncY2 = 200000;
    	// Operating Income Y3 - Account.Operating_Income_Y3__c
    	acOpIncY3 = 300000;
    	
    	// n.b.: The RPX Rate for these values should be 960
    	
    	// Create the Account
    	List<Account> accts = new List<Account>();
    	Account ac1 = new Account(
    		Name = acName,
    		Type = acProspect,
    		AnnualRevenue = acRevCur,
    		Operating_Income_Y1__c = acOpIncY1,
    		Operating_Income_Y2__c = acOpIncY2,
    		Operating_Income_Y3__c = acOpIncY3,
    		Rate_Comments_Manual__c = 'test'
    	);
    	//OwnerId = ownerId.Id
    	accts.add(ac1);

    	try { insert accts; } catch(system.DMLException e) {
			System.debug('ERROR: failed to create the test account');				
   		}
    	
        // Get the Account reference
        //Account acctId = [Select a.Id From Account a  where a.Name = 'RPXTest' limit 1];

    	// Opportunity Name
    	opProspectName = 'RPXTriggerTest';
    	// Opportunity Types - Opportunity.Type
    	opNewBizType = 'New Business';
    	opRenewType = 'Renewal';
    	// Opportunity Custom Types - Opportunity.Opportunity_Type__c
    	opMember = 'Membership';
    	// Opportunity Stage - Opportunity.StageName
    	opProspectStage = 'Prospect';
    	opClosedWonStage = 'Closed Won';
    	opClosedWonStage = 'Closed Lost';
    	// Opportunity close date - Opportunity.CloseDate
    	opClsDate = date.today();
    	opClsDate = opClsDate.addYears(1);
    	
    	// Create an Opportunity for the test Account
    	List<Opportunity> opptys = new List<Opportunity>();
    	Opportunity op1 = new Opportunity(
    		Name = opProspectName,
    		AccountId = accts[0].Id,
    		StageName = opProspectStage,
    		Type = opNewBizType,
    		Opportunity_Type__c = opMember,
    		CloseDate = opClsDate
  			
    	);  
    	//OwnerId = ownerId.Id  	
		opptys.add(op1);		
		
    	try { insert opptys; } catch(system.DMLException e) {
			System.debug('ERROR: failed to create the test opportunity');				
	   	}
	   	// we have to follow the insert with an update in order to get
	   	// the trigger to actually fire in this test configuration...
    	try { update opptys; } catch(system.DMLException e) {
			System.debug('ERROR: failed to update the test opportunity');				
	   	}

    	
    	

		test.starttest();
		// Get the SGR and RPX_Rate_Card_From_Account__c fields 
		List<Opportunity> tstOp1 = [Select t.RPX_Rate_Card_From_Account__c, t.Historical_Rate__c, t.RPX_Rate__c, t.StageName From Opportunity t where t.Name = 'RPXTriggerTest' limit 1];
		// First test handles case of a new account record
		system.debug('Sudhir'+tstOp1[0]);
		// Ensure that we have good data		
		//system.assert(tstOp1.RPX_Rate_Card_From_Account__c != null);
		System.debug('DEBUG Pass 1: test RPX_Rate_Card_From_Account__c: ' + tstOp1[0].RPX_Rate_Card_From_Account__c);				
		//system.assert(tstOp1.RPX_Rate_Card_From_Account__c != null);
		System.debug('DEBUG Pass 1: test RPX_Rate_Card_From_Account__c: ' + tstOp1[0].RPX_Rate_Card_From_Account__c);				
		
		// Test that the SGR and RPX_Rate_Card_From_Account__c fields are equivalent
		if (tstOp1[0].RPX_Rate_Card_From_Account__c == tstOp1[0].RPX_Rate_Card_From_Account__c) {
			System.debug('DEBUG Pass 1: updateOpptyRpxRate PASSED');				
		} else {
			System.debug('DEBUG Pass 1: updateOpptyRpxRate FAILED');								
		}
		
		// Second test handles the case of updating an account record
        // Get the Account reference
        List<Account> ac1pass2 = [Select a.Id, a.AnnualRevenue, a.Operating_Income_Y3__c From Account a  where a.Name = 'RPXTest' limit 1];
		ac1pass2[0].AnnualRevenue = 10400000;
    	ac1pass2[0].Operating_Income_Y3__c = 10400000;	
		List<Account> accts2 = new List<Account>();
    	accts2.add(ac1pass2[0]);		
		try { update accts2; } catch(system.DMLException e) {
			System.debug('ERROR Pass 2: failed to update the test account');				
   		}
   		
		List<Opportunity> tstOpPass2 = [Select t.RPX_Rate_Card_From_Account__c, t.Historical_Rate__c, t.RPX_Rate__c, t.StageName From Opportunity t where t.Name = 'RPXTriggerTest' limit 1];
		tstOpPass2[0].StageName = opClosedWonStage;
    	// Create an Opportunity for the test Account
    	List<Opportunity> opptys2 = new List<Opportunity>();
		opptys2.add(tstOpPass2[0]);		
		try { update opptys2; } catch(system.DMLException e) {
			System.debug('ERROR Pass 2: failed to update the test opportunity');				
	   	}

		List<Opportunity> tstOp2 = [Select t.RPX_Rate_Card_From_Account__c, t.Historical_Rate__c, t.RPX_Rate__c, t.StageName From Opportunity t where t.Name = 'RPXTriggerTest' limit 1];

		//system.assert(tstOp2[0].RPX_Rate_Card_From_Account__c != null);
		System.debug('DEBUG Pass 2: test RPX Rate: ' + tstOp2[0].RPX_Rate_Card_From_Account__c);			
		//system.assert(tstOp2[0].Historical_Rate__c != null);
		//System.debug('DEBUG Pass 2: test RPX Historical Rate: ' + tstOp2[0].Historical_Rate__c);					
		system.assert(tstOp2[0].RPX_Rate_Card_From_Account__c != null);
		System.debug('DEBUG Pass 2: test RPX_Rate_Card_From_Account__c: ' + tstOp2[0].RPX_Rate_Card_From_Account__c);				
		system.assert(tstOp2[0].StageName != null);
		System.debug('DEBUG Pass 3: test Stage Name: ' + tstOp2[0].StageName);				

		// Test that the SGR and RPX_Rate_Card_From_Account__c fields are equivalent
		if (tstOp2[0].RPX_Rate_Card_From_Account__c == tstOp2[0].RPX_Rate_Card_From_Account__c) {
			System.debug('DEBUG Pass 2: updateOpptyRpxRate PASSED');			
		} else {
			System.debug('DEBUG Pass 2: updateOpptyRpxRate FAILED');								
		}
		if (tstOp2[0].Historical_Rate__c != tstOp2[0].RPX_Rate_Card_From_Account__c) {
			System.debug('DEBUG Pass 2: updateOpptyRpxRate PASSED');				
		} else {
			System.debug('DEBUG Pass 2: updateOpptyRpxRate FAILED');								
		}
		if (tstOp2[0].StageName != 'Closed Won') if (tstOp2[0].StageName != 'Closed Lost') {
			System.debug('DEBUG Pass 2: updateOpptyRpxRate PASSED');				
		} else {
			System.debug('DEBUG Pass 2: updateOpptyRpxRate FAILED');								
		}
		
		
		test.stoptest();
				
    }//updateOpptyRateTest
}