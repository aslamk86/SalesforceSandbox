/*
    Class        : Test_MS_Classes
    Description  : Test Class for MS_<xxx> classes
    Created By   : Martin Sieler
    Created Date : July 22, 2012

Modified Feb 26, 2014 - split the class into two because of the number of SOQL queries used.
*/

@isTest
private class Test_MS_Classes
	{
		/*
	//-------------------------------------------------------------------------------------------------------------------------
	// DefendantCount_Litigation
	//-------------------------------------------------------------------------------------------------------------------------
	static testMethod void DefendantCount_Litigation()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : DefendantCount_Litigation');

		// Create Accounts
		list<Account> lAcc = new list<Account>();

		Account Acc = TestUtil.createAccount(false);
		Acc.Type = 'Prospect';
		lAcc.add(Acc);

		Account Acc2 = TestUtil.createAccount(false);
		Acc2.Type = 'Member';
		lAcc.add(Acc2);

		insert lAcc;
	  	  
	  // Create litigation
	  list<Litigation__c> Lits = new list<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = Date.today().adddays(5);
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);

		Defendant__c Defendant2  = TestUtil.createDefendant(Acc2.Id, Litigation.Id, false);
		Defendant2.Date_Terminated__c = null;
		Defs.add(Defendant2);
		
		insert Defs;

	  // Testing starts from here  
		Test.startTest();
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Start');

		// test refresh
		Litigation.N_Defendants__c = 999;
		Litigation.N_Members__c    = 999;
		Litigation.N_Prospects__c  = 999;
		Litigation.N_Defendants_Active__c = 999;
		Litigation.N_Members_Active__c    = 999;
		Litigation.N_Prospects_Active__c  = 999;
		Litigation.N_Defendants_Terminated__c = 999;
		Litigation.N_Members_Terminated__c    = 999;
		Litigation.N_Prospects_Terminated__c  = 999;
		
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : All counts to 999');
		update Litigation;
		
		// Check defendant count on litigation
		Litigation = getLitigation(Litigation.Id);
		System.assertEquals(Litigation.N_Defendants__c, 999);
		System.assertEquals(Litigation.N_Members__c,    999);
		System.assertEquals(Litigation.N_Prospects__c,  999);
		System.assertEquals(Litigation.N_Defendants_Active__c, 999);
		System.assertEquals(Litigation.N_Members_Active__c,    999);
		System.assertEquals(Litigation.N_Prospects_Active__c,  999);
		System.assertEquals(Litigation.N_Defendants_Terminated__c, 999);
		System.assertEquals(Litigation.N_Members_Terminated__c,    999);
		System.assertEquals(Litigation.N_Prospects_Terminated__c,  999);
		
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Refresh litigation');
		Litigation.Refresh__c = true;
		update Litigation;
		
		// Check defendant count on litigation
		Litigation = getLitigation(Litigation.Id);
		System.assertEquals(Litigation.N_Defendants__c, 2);
		System.assertEquals(Litigation.N_Members__c,    1);
		System.assertEquals(Litigation.N_Prospects__c,  1);
		System.assertEquals(Litigation.N_Defendants_Active__c, 2);
		System.assertEquals(Litigation.N_Members_Active__c,    1);
		System.assertEquals(Litigation.N_Prospects_Active__c,  1);
		System.assertEquals(Litigation.N_Defendants_Terminated__c, 0);
		System.assertEquals(Litigation.N_Members_Terminated__c,    0);
		System.assertEquals(Litigation.N_Prospects_Terminated__c,  0);
				
		// make account a member
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Account type Member');
		Acc.Type = 'Member';
		update Acc;

		// Check defendant count on litigation
		Litigation = getLitigation(Litigation.Id);
		System.assertEquals(Litigation.N_Defendants__c, 2);
		System.assertEquals(Litigation.N_Members__c,    2);
		System.assertEquals(Litigation.N_Prospects__c,  0);
		System.assertEquals(Litigation.N_Defendants_Active__c, 2);
		System.assertEquals(Litigation.N_Members_Active__c,    2);
		System.assertEquals(Litigation.N_Prospects_Active__c,  0);
		System.assertEquals(Litigation.N_Defendants_Terminated__c, 0);
		System.assertEquals(Litigation.N_Members_Terminated__c,    0);
		System.assertEquals(Litigation.N_Prospects_Terminated__c,  0);

		// terminate defendant
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Defendant terminated');
		Defendant.Date_Terminated__c = date.today();
		update Defendant;

		// Check defendant count on litigation
		Litigation = getLitigation(Litigation.Id);
		System.assertEquals(Litigation.N_Defendants__c, 2);
		System.assertEquals(Litigation.N_Members__c,    2);
		System.assertEquals(Litigation.N_Prospects__c,  0);
		System.assertEquals(Litigation.N_Defendants_Active__c, 1);
		System.assertEquals(Litigation.N_Members_Active__c,    1);
		System.assertEquals(Litigation.N_Prospects_Active__c,  0);
		System.assertEquals(Litigation.N_Defendants_Terminated__c, 1);
		System.assertEquals(Litigation.N_Members_Terminated__c,    1);
		System.assertEquals(Litigation.N_Prospects_Terminated__c,  0);

		// Close case
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Litigation closed');
		Litigation.Active_or_Closed__c = 'Closed';
		update Litigation;

		// Check defendant count on litigation
		Litigation = getLitigation(Litigation.Id);
		System.assertEquals(Litigation.N_Defendants__c, 2);
		System.assertEquals(Litigation.N_Members__c,    2);
		System.assertEquals(Litigation.N_Prospects__c,  0);
		System.assertEquals(Litigation.N_Defendants_Active__c, 0);
		System.assertEquals(Litigation.N_Members_Active__c,    0);
		System.assertEquals(Litigation.N_Prospects_Active__c,  0);
		System.assertEquals(Litigation.N_Defendants_Terminated__c, 2);
		System.assertEquals(Litigation.N_Members_Terminated__c,    2);
		System.assertEquals(Litigation.N_Prospects_Terminated__c,  0);

		// delete defendant
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete defendant');
		delete Defendant;

		// Check defendant count on litigation
		Litigation = getLitigation(Litigation.Id);
		System.assertEquals(Litigation.N_Defendants__c, 1);
		System.assertEquals(Litigation.N_Members__c,    1);
		System.assertEquals(Litigation.N_Prospects__c,  0);
		System.assertEquals(Litigation.N_Defendants_Active__c, 0);
		System.assertEquals(Litigation.N_Members_Active__c,    0);
		System.assertEquals(Litigation.N_Prospects_Active__c,  0);
		System.assertEquals(Litigation.N_Defendants_Terminated__c, 1);
		System.assertEquals(Litigation.N_Members_Terminated__c,    1);
		System.assertEquals(Litigation.N_Prospects_Terminated__c,  0);

		// delete Acc2
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete Account 2');
		delete Acc2;

		// Check defendant count on litigation
		Litigation = getLitigation(Litigation.Id);
		System.assertEquals(Litigation.N_Defendants__c, 0);
		System.assertEquals(Litigation.N_Members__c,    0);
		System.assertEquals(Litigation.N_Prospects__c,  0);
		System.assertEquals(Litigation.N_Defendants_Active__c, 0);
		System.assertEquals(Litigation.N_Members_Active__c,    0);
		System.assertEquals(Litigation.N_Prospects_Active__c,  0);
		System.assertEquals(Litigation.N_Defendants_Terminated__c, 0);
		System.assertEquals(Litigation.N_Members_Terminated__c,    0);
		System.assertEquals(Litigation.N_Prospects_Terminated__c,  0);

		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Stop');
		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : DefendantCount_Litigation');
		}
*/
  //-------------------------------------------------------------------------------------------------------------------------
  // DefendantCount_Acquisition
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void DefendantCount_Acquisition()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : DefendantCount_Acquisition');

		// Create Accounts
		list<Account> lAcc = new list<Account>();

		Account Acc = TestUtil.createAccount(false);
		Acc.Type = 'Prospect';
		lAcc.add(Acc);

		Account Acc2 = TestUtil.createAccount(false);
		Acc2.Type = 'Member';
		lAcc.add(Acc2);

		Account Acc3 = TestUtil.createAccount(false);
		Acc3.Type = 'Prospect';
		lAcc.add(Acc3);

		insert lAcc;
	  	  
	  // Create litigation
	  list<Litigation__c> Lits = new list<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = Date.today().adddays(5);
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);
	  
	  Litigation__c Litigation2 = TestUtil.createLitigation(false);
	  Litigation2.Filed__c = Date.today().adddays(5);
	  Litigation2.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation2);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);

		Defendant__c Defendant2  = TestUtil.createDefendant(Acc2.Id, Litigation.Id, false);
		Defendant2.Date_Terminated__c = null;
		Defs.add(Defendant2);

		Defendant__c Defendant3  = TestUtil.createDefendant(Acc3.Id, Litigation2.Id, false);
		Defendant3.Date_Terminated__c = null;
		Defs.add(Defendant3);

		insert Defs;

	  // Create acquisition opportunity
	  Acquisition_Opportunity__c AcqOpp = TestUtil.createAcquisitionOpp(Acc.Id, 'Phase 1', 'Test Defandant', false);
	  AcqOpp.CloseDate__c = date.today().addDays(5);
	  insert AcqOpp;

		// add Litigation to Acq Oppy
		Opportunity_Litigation__c oppLit = TestUtil.createOpportunityLitigation(AcqOpp.Id, Litigation.Id, true);
        
	    // Testing starts from here  
		Test.startTest();
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Start');
		
		

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 2);
		System.assertEquals(AcqOpp.N_Members__c,    1);
		System.assertEquals(AcqOpp.N_Prospects__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 2);
		System.assertEquals(AcqOpp.N_Members_Active__c,    1);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);
		
        // Delete defendant
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete defendant');
		delete Defendant;
        
        Test.stopTest();
        
		// delete Acc2
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete Acc2');
		delete Acc2;
        
        
		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 0);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 0);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);
        
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Stop');
		
		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : DefendantCount_Acquisition');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // DefendantCount_Acquisition2
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void DefendantCount_Acquisition2()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : DefendantCount_Acquisition2');

		// Create Accounts
		list<Account> lAcc = new list<Account>();

		Account Acc = TestUtil.createAccount(false);
		Acc.Type = 'Prospect';
		lAcc.add(Acc);

		Account Acc2 = TestUtil.createAccount(false);
		Acc2.Type = 'Member';
		lAcc.add(Acc2);

		Account Acc3 = TestUtil.createAccount(false);
		Acc3.Type = 'Prospect';
		lAcc.add(Acc3);

		insert lAcc;
	  	  
	  // Create litigation
	  list<Litigation__c> Lits = new list<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = Date.today().adddays(5);
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);
	  
	  Litigation__c Litigation2 = TestUtil.createLitigation(false);
	  Litigation2.Filed__c = Date.today().adddays(5);
	  Litigation2.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation2);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);

		Defendant__c Defendant2  = TestUtil.createDefendant(Acc2.Id, Litigation.Id, false);
		Defendant2.Date_Terminated__c = null;
		Defs.add(Defendant2);

		Defendant__c Defendant3  = TestUtil.createDefendant(Acc3.Id, Litigation2.Id, false);
		Defendant3.Date_Terminated__c = null;
		Defs.add(Defendant3);

		insert Defs;

	  // Create acquisition opportunity
	  Acquisition_Opportunity__c AcqOpp = TestUtil.createAcquisitionOpp(Acc.Id, 'Phase 1', 'Test Defandant', false);
	  AcqOpp.CloseDate__c = date.today().addDays(5);
	  insert AcqOpp;

		// add Litigation to Acq Oppy
		Opportunity_Litigation__c oppLit = TestUtil.createOpportunityLitigation(AcqOpp.Id, Litigation.Id, true);

	  // Testing starts from here  
		Test.startTest();
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Start');

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 2);
		System.assertEquals(AcqOpp.N_Members__c,    1);
		System.assertEquals(AcqOpp.N_Prospects__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 2);
		System.assertEquals(AcqOpp.N_Members_Active__c,    1);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// add litigation to acquisition
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Add 2nd Opp Lit');
		Opportunity_Litigation__c oppLit2 = TestUtil.createOpportunityLitigation(AcqOpp.Id, Litigation2.Id, true);

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 3);
		System.assertEquals(AcqOpp.N_Members__c,    1);
		System.assertEquals(AcqOpp.N_Prospects__c,  2);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 3);
		System.assertEquals(AcqOpp.N_Members_Active__c,    1);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  2);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// delete Acc2
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete Acc2');
		delete Acc2;

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 2);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  2);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 2);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  2);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// delete litigation
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete Litigation');
		delete Litigation2;

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 1);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 1);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Stop');
		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : DefendantCount_Acquisition2');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // DefendantCount_Acquisition2
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void DefendantCount_Acquisition3()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : DefendantCount_Acquisition3');

	  // Create Account
	  Account Acc = TestUtil.createAccount(false);
	  Acc.Type = '';
	  insert Acc;
	  	  
	  // Create litigations
	  List<Litigation__c> Lits = new List<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = date.today();
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);

		insert Defs;

	  // Create acquisition opportunity
	  Acquisition_Opportunity__c AcqOpp = TestUtil.createAcquisitionOpp(Acc.Id, 'Phase 1', 'Test Defandant', false);
	  AcqOpp.CloseDate__c = date.today().addDays(5);
	  insert AcqOpp;

		// add Litigation to Acq Oppy
		Opportunity_Litigation__c oppLit = TestUtil.createOpportunityLitigation(AcqOpp.Id, Litigation.Id, true);

	  // Testing starts from here  
		Test.startTest();
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Start');

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 1);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 1);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// make account a member
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Account type member');
		Acc.Type         = 'Member';
		update Acc;

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 1);
		System.assertEquals(AcqOpp.N_Members__c,    1);
		System.assertEquals(AcqOpp.N_Prospects__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 1);
		System.assertEquals(AcqOpp.N_Members_Active__c,    1);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// make account a member subsidiary
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Account type member subsidiary');
		Acc.Type         = 'Member Subsidiary';
		update Acc;

		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 1);
		System.assertEquals(AcqOpp.N_Members__c,    1);
		System.assertEquals(AcqOpp.N_Prospects__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 1);
		System.assertEquals(AcqOpp.N_Members_Active__c,    1);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// make account a prospect
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Account type prospect');
		Acc.Type         = 'Prospect';
		update Acc;

		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 1);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 1);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// make account a prospect subsidiary
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Account type prospect subsidiary');
		Acc.Type         = 'Prospect Subsidiary';
		update Acc;

		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 1);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 1);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  1);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// delete defendant and case
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete all defendants');
		delete Defs;
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete all litigations');
		delete Lits;
		
		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 0);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 0);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Stop');
		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : DefendantCount_Acquisition3');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // DefendantCount_Acquisition4
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void DefendantCount_Acquisition4()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : DefendantCount_Acquisition4');

	  // Create Account
	  Account Acc = TestUtil.createAccount(false);
	  Acc.Type = '';
	  insert Acc;
	  	  
	  // Create litigations
	  List<Litigation__c> Lits = new List<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = date.today();
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);

		insert Defs;

	  // Create acquisition opportunity
	  Acquisition_Opportunity__c AcqOpp = TestUtil.createAcquisitionOpp(Acc.Id, 'Phase 1', 'Test Defandant', false);
	  AcqOpp.CloseDate__c = date.today().addDays(5);
	  insert AcqOpp;

		// add Litigation to Acq Oppy
		Opportunity_Litigation__c oppLit = TestUtil.createOpportunityLitigation(AcqOpp.Id, Litigation.Id, true);

	  // Testing starts from here  
		Test.startTest();
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Start');

		// test refresh
		AcqOpp.N_Defendants__c = 999;
		AcqOpp.N_Members__c    = 999;
		AcqOpp.N_Prospects__c  = 999;
		AcqOpp.N_Defendants_Active__c = 999;
		AcqOpp.N_Members_Active__c    = 999;
		AcqOpp.N_Prospects_Active__c  = 999;
		AcqOpp.N_Defendants_Terminated__c = 999;
		AcqOpp.N_Members_Terminated__c    = 999;
		AcqOpp.N_Prospects_Terminated__c  = 999;
		
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : All counts to 999');
		update AcqOpp;
		
		// Check defendant count on litigation
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 999);
		System.assertEquals(AcqOpp.N_Members__c,    999);
		System.assertEquals(AcqOpp.N_Prospects__c,  999);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 999);
		System.assertEquals(AcqOpp.N_Members_Active__c,    999);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  999);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 999);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    999);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  999);

		// delete acq opp def
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete Acq opp defendants');
		list<Acquisition_Opportunity_Defendant__c> lAOD = [SELECT id from Acquisition_Opportunity_Defendant__c where Acquisition_Opportunity__c = :AcqOpp.Id];
		delete lAOD;
		
		// refresh
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Refresh acquisition');
		AcqOpp.Refresh__c = true;
		update AcqOpp;

		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 1);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 1);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		// delete defendant and case
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete all defendants');
		delete Defs;
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Delete all litigations');
		delete Lits;
		
		// Check defendant count on acquisition
		AcqOpp = GetAcquisition(AcqOpp.Id);
		System.assertEquals(AcqOpp.N_Defendants__c, 0);
		System.assertEquals(AcqOpp.N_Members__c,    0);
		System.assertEquals(AcqOpp.N_Prospects__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Active__c, 0);
		System.assertEquals(AcqOpp.N_Members_Active__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Active__c,  0);
		System.assertEquals(AcqOpp.N_Defendants_Terminated__c, 0);
		System.assertEquals(AcqOpp.N_Members_Terminated__c,    0);
		System.assertEquals(AcqOpp.N_Prospects_Terminated__c,  0);

		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Stop');
		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : DefendantCount_Acquisition4');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // LitigationCount_Account
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void LitigationCount_Account()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : LitigationCount_Account');
  
	  // Create Account
	  Account Acc = TestUtil.createAccount(false);
	  Acc.Type = 'Prospect';
	  insert Acc;
	  	  
	  // Create litigations
	  List<Litigation__c> Lits = new List<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = date.today();
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);
		
		insert Defs;

	  // Testing starts from here  
		Test.startTest();
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 1);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

    // Update Litigations to fire the trigger.
		Litigation.Filed__c = Date.today().adddays(-1*365);
    update Lits;
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          1);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

    // Update Litigations to fire the trigger.
		Litigation.Filed__c = Date.today().adddays(-2*365);
    update Lits;
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         1);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

    // Update Litigations to fire the trigger.
		Litigation.Filed__c = Date.today().adddays(-3*365);
    update Lits;
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         1);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

    // Update Litigations to fire the trigger.
		Litigation.Filed__c = Date.today().adddays(-4*365);
    update Lits;
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         1);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

    // Update Litigations to fire the trigger.
		Litigation.Filed__c = Date.today().adddays(-5*365);
    update Lits;
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

		// Close case
		Litigation.Active_or_Closed__c = 'Closed';
		update Litigation;

	  // Check that Lits_filed_this_calendar_years__c on account must be 0 after defendant deleted
		Acc = getAccount(Acc.Id);
	  System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,0);

    // Update Litigations to fire the trigger.
		Litigation.Filed__c = Date.today().adddays(-6*365);
    update Lits;
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,0);

		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : LitigationCount_Account');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // LitigationCount_Account2
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void LitigationCount_Account2()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : LitigationCount_Account2');
  
	  // Create Account
	  Account Acc = TestUtil.createAccount(false);
	  Acc.Type = 'Prospect';
	  insert Acc;
	  	  
	  // Create litigations
	  List<Litigation__c> Lits = new List<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = date.today();
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);
		
		insert Defs;

	  // Testing starts from here  
		Test.startTest();
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 1);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

		// Close case
		Litigation.Active_or_Closed__c = 'Closed';
		update Litigation;

	  // Check that Lits_filed_this_calendar_years__c on account must be 0 after defendant deleted
		Acc = getAccount(Acc.Id);
	  System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 1);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,0);

		// delete defendants
    delete Defs;
	
		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,0);

		// make case active and add new defendant
		Litigation.Active_or_Closed__c = 'Active';
		update Litigation;

		Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		insert Defendant;

		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 1);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   1);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,1);

		// delete litigation
		delete Litigation;

		// Check account
		Acc = getAccount(Acc.Id);
		System.assertEquals(Acc.Lits_filed_this_calendar_years__c , 0);
		System.assertEquals(Acc.Lits_filed_last_years__c ,          0);
		System.assertEquals(Acc.Lits_filed_2_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_3_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_4_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_5_years_ago__c ,         0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_all__c ,   0);
		System.assertEquals(Acc.Lits_filed_within_last_5_years_Active__c ,0);

		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : LitigationCount_Account2');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // EntiTree_Test
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void EntiTree_Test()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : EntiTree_Test');
  
	  // Create Accounts
	  Account Acc = TestUtil.createAccount(false);
	  Acc.Name = 'dummy';
	  Acc.Type = 'Prospect';
	  Acc.Entity_ID__c = 1;
	  Acc.Ultimate_Parent_Entity_ID__c = 1;
	  insert Acc;

		Acc = getAccount(Acc.Id);
		
	  Account Acc2 = TestUtil.createAccount(false);
	  Acc2.Name = 'dummy 2';
	  Acc2.Type = 'Prospect Subsidiary';
	  Acc2.Entity_ID__c = 2;
	  Acc2.Ultimate_Parent_Entity_ID__c = 1;
	  insert Acc2;

		Acc2 = getAccount(Acc2.Id);

	  Account Acc3 = TestUtil.createAccount(false);
	  Acc3.Name = 'dummy 3';
	  Acc3.Type = 'Prospect Subsidiary';
	  Acc3.Entity_ID__c = 3;
	  Acc3.Ultimate_Parent_Entity_ID__c = 2;
	  Acc3.ParentId = Acc2.Id;
	  insert Acc3;

		Acc3 = getAccount(Acc3.Id);

	  // Testing starts from here  
		Test.startTest();

	  Acc.Entity_ID__c = 7;
		update Acc;		

	  Acc.Ultimate_Parent_Entity_ID__c = 7;
		update Acc;
		
		Acc.Entity_Core_Name__c = 'Dummy, Co.';
		update Acc;

		Acc2.ParentId = Acc.Id;
		update Acc2;

		Acc2.Ultimate_Parent_Entity_ID__c = 5;
		update Acc2;
		
		Acc2.ParentId = null;
		update Acc2;

		Acc3.Ultimate_Parent_Entity_ID__c = 7;
		update Acc3;

		delete Acc;

		MS_StringSimilarity.isCompanyNameSimilar(null, '');
		MS_StringSimilarity.isCompanyNameSimilar('', '');
		MS_StringSimilarity.isCompanyNameSimilar('dummy 1', '');
		MS_StringSimilarity.isCompanyNameSimilar('dummy 1', 'dummy 1, Co.');
		MS_StringSimilarity.isCompanyNameSimilar('dummy, Inc.', 'dummy, iNcOrPoRaTeD');
		MS_StringSimilarity.isCompanyNameSimilar('dummy Inc', 'dummy co');

		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : EntiTree_Test');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // AccountMerge_Test
  //-------------------------------------------------------------------------------------------------------------------------
	static testMethod void AccountMerge_Test()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : AccountMerge_Test');
  
	  // Create Accounts
	  list<Account> lstAcc = new list<Account>();

	  Account Acc = TestUtil.createAccount(false);
	  Acc.Name = 'dummy';
	  Acc.Type = 'Prospect';
	  Acc.Entity_ID__c = 1;
	  Acc.Ultimate_Parent_Entity_ID__c = 1;
	  lstAcc.add(Acc);

		Account Acc2 = TestUtil.createAccount(false);
	  Acc2.Name = 'dummy 2';
	  Acc2.Type = 'Prospect Subsidiary';
	  Acc2.Entity_ID__c = 2;
	  Acc2.Ultimate_Parent_Entity_ID__c = 1;
	  lstAcc.add(Acc2);

	  Account Acc3 = TestUtil.createAccount(false);
	  Acc3.Name = 'dummy 3';
	  Acc3.Type = 'Prospect Subsidiary';
	  Acc3.Entity_ID__c = 3;
	  Acc3.Ultimate_Parent_Entity_ID__c = 2;
	  Acc3.ParentId = Acc2.Id;
	  lstAcc.add(Acc3);

		insert lstAcc;

		Acc = getAccount(Acc.Id);
		Acc2 = getAccount(Acc2.Id);
		Acc3 = getAccount(Acc3.Id);

	  // Testing starts from here  
		Test.startTest();
		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Start');

		System.Debug(MS_Tools.Debug, Acc.name + ' => ' + Acc.id);
		System.Debug(MS_Tools.Debug, Acc2.name + ' => ' + Acc2.id);
		System.Debug(MS_Tools.Debug, Acc3.name + ' => ' + Acc3.id);

		merge Acc Acc2;

		System.Debug(MS_Tools.Debug , '=== U N I T   T E S T : Stop');
		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : AccountMerge_Test');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // MS_BatchRefresh
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void MS_BatchRefresh()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : MS_BatchRefresh');

	  // Create Account
	  Account Acc = TestUtil.createAccount(false);
	  Acc.Type = 'Prospect Subsidiary';
	  insert Acc;
	  	  
	  // Create litigations
	  List<Litigation__c> Lits = new List<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = date.today();
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);

		insert Defs;

	  // Create acquisition opportunity
	  Acquisition_Opportunity__c AcqOpp = TestUtil.createAcquisitionOpp(Acc.Id, 'Phase 1', 'Test Defandant', false);
	  AcqOpp.CloseDate__c = date.today().addDays(5);
	  insert AcqOpp;

		// add Litigation to Acq Oppy
		Opportunity_Litigation__c oppLit = TestUtil.createOpportunityLitigation(AcqOpp.Id, Litigation.Id, true);

	  // Testing starts from here  
		Test.startTest();

		// refresh tests
		Acc.Refresh__c = true;
		update Acc;
		
		Litigation.Refresh__c = true;
		update Litigation;

		// Acquisition refresh will re-create acq opp defendants, so let's delete them for the test
		delete [select id from Acquisition_Opportunity_Defendant__c];

		AcqOpp.Refresh__c = true;
		update AcqOpp;

		// test MS_BatchRefresh
		MS_BatchRefresh batch1 = new MS_BatchRefresh('Account');
		Id batchId1 = Database.executeBatch(batch1);

		MS_BatchRefresh batch2 = new MS_BatchRefresh('Acquisition_Opportunity__c');
		Id batchId2 = Database.executeBatch(batch2);

		MS_BatchRefresh batch3 = new MS_BatchRefresh('Litigation__c');
		Id batchId3 = Database.executeBatch(batch3);

		MS_BatchRefresh batch4 = new MS_BatchRefresh('Defendant__c');
		Id batchId4 = Database.executeBatch(batch4);

		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : MS_BatchRefresh');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // MS_RollUpSummaryUtility
  //-------------------------------------------------------------------------------------------------------------------------
	
	static testMethod void MS_RollUpSummaryUtility()
		{
		// do not run any tests if disabled
		if (Label.MartinSieler_Stuff_Active != 'yes')
			return;

		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T : MS_RollUpSummaryUtility');

	  // Create Account
	  Account Acc = TestUtil.createAccount(false);
	  Acc.Type = 'Prospect Subsidiary';
	  insert Acc;
	  	  
	  // Create litigations
	  List<Litigation__c> Lits = new List<Litigation__c>();

	  Litigation__c Litigation = TestUtil.createLitigation(false);
	  Litigation.Filed__c = date.today();
	  Litigation.Active_or_Closed__c = 'Active';
	  Lits.add(Litigation);

	  insert Lits;

		// Create defendants
		List<Defendant__c> Defs = new List<Defendant__c>();
		
		Defendant__c Defendant  = TestUtil.createDefendant(Acc.Id, Litigation.Id, false);
		Defendant.Date_Terminated__c = null;
		Defs.add(Defendant);

		insert Defs;

	  // Testing starts from here  
		Test.startTest();

		integer thisyear = date.today().year();

		// 1st test for MS_RollUpSummaryUtility
		list<MS_RollUpSummaryUtility.fieldDefinition> fieldDefinitions =
			new list<MS_RollUpSummaryUtility.fieldDefinition>
				{
				new MS_RollUpSummaryUtility.fieldDefinition('COUNT', 'Id', 'Lits_filed_5_years_ago__c')
				};

 	  MS_RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, Defs, 'Defendant__c', 'Account__c', 'Account', 'and CALENDAR_YEAR(Filed__c) = ' + (thisyear-5));

		// 2nd test for MS_RollUpSummaryUtility
		MS_RollUpSummaryUtility.fieldDefinition fieldDefinition =
				new MS_RollUpSummaryUtility.fieldDefinition('COUNT', 'Id', 'Lits_filed_this_calendar_years__c');
				
 	  MS_RollUpSummaryUtility.rollUpTrigger(fieldDefinition, Defs, 'Defendant__c', 'Account__c', 'Account', '');

		// 3rd test for MS_RollUpSummaryUtility
		list<MS_RollUpSummaryUtility.FieldAndFilter> f = new list<MS_RollUpSummaryUtility.FieldAndFilter>
			{
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_this_calendar_years__c', 'and CALENDAR_YEAR(Filed__c) = ' + thisyear),
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_last_years__c', 'and CALENDAR_YEAR(Filed__c) = ' + (thisyear-1)),
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_2_years_ago__c', 'and CALENDAR_YEAR(Filed__c) = ' + (thisyear-2)),
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_3_years_ago__c', 'and CALENDAR_YEAR(Filed__c) = ' + (thisyear-3)),
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_4_years_ago__c', 'and CALENDAR_YEAR(Filed__c) = ' + (thisyear-4)),
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_5_years_ago__c', 'and CALENDAR_YEAR(Filed__c) = ' + (thisyear-5)),
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_within_last_5_years_all__c', 'and CALENDAR_YEAR(Filed__c) <= ' + thisyear + ' and CALENDAR_YEAR(Filed__c) >= ' + (thisyear-5)),
			new MS_RollUpSummaryUtility.FieldAndFilter('Lits_filed_within_last_5_years_Active__c', 'and CALENDAR_YEAR(Filed__c) <= ' + thisyear + ' and CALENDAR_YEAR(Filed__c) >= ' + (thisyear-5) + ' and Defendant_Active__c = \'Yes\'')
			};

		MS_RollUpSummaryUtility.rollUpTrigger(f, 'COUNT', 'ID', Defs, 'Defendant__c', 'Account__c', 'Account');

		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T : MS_RollUpSummaryUtility');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // myUnitTestXXX
  //-------------------------------------------------------------------------------------------------------------------------
	static testMethod void myUnitTestXXX()
		{
		System.Debug(MS_Tools.Debug , '=== START === U N I T   T E S T   XXX');

	  // Testing starts from here  
		Test.startTest();

		Test.stopTest();

		System.Debug(MS_Tools.Debug , '=== END ===== U N I T   T E S T   XXX');
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // getAccount
  //-------------------------------------------------------------------------------------------------------------------------
	private static Account getAccount(Id accId)
		{
    for (Account account :
        [
         select RecordTypeId, Type,
		            Entity_ID__c, Ultimate_Parent_Entity_ID__c,
		            Entity_Core_Name__c,
		            Lits_filed_this_calendar_years__c,
		            Lits_filed_last_years__c,
		            Lits_filed_2_years_ago__c,
		            Lits_filed_3_years_ago__c,
		            Lits_filed_4_years_ago__c,
		            Lits_filed_5_years_ago__c,
		            Lits_filed_within_last_5_years_all__c,
		            Lits_filed_within_last_5_years_Active__c,
		            Name
         from Account
         where Id = :accId
        ]
      )
  	 	{
      return account;
      }

    return null;
	  }

  //-------------------------------------------------------------------------------------------------------------------------
  // getAcquisition
  //-------------------------------------------------------------------------------------------------------------------------	
	private static Acquisition_Opportunity__c getAcquisition(Id acqId)
		{
		for (Acquisition_Opportunity__c acq :
		    [
		     select N_Defendants__c, N_Members__c, N_Prospects__c,
		            N_Defendants_Active__c, N_Members_Active__c, N_Prospects_Active__c,
		            N_Defendants_Terminated__c, N_Members_Terminated__c, N_Prospects_Terminated__c
		     from Acquisition_Opportunity__c
		     where Id = :acqId
		    ]
		  )
			{
			return acq;
			}
			
		return null;
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // getLitigation
  //-------------------------------------------------------------------------------------------------------------------------	
	private static Litigation__c getLitigation(Id litId)
		{
		for (Litigation__c lit : 
		    [
		     select Filed__c,
		            N_Defendants__c, N_Members__c, N_Prospects__c,
		            N_Defendants_Active__c, N_Members_Active__c, N_Prospects_Active__c,
		            N_Defendants_Terminated__c, N_Members_Terminated__c, N_Prospects_Terminated__c		            
		     from Litigation__c
		     where Id = :litId
		    ]
		  )
			{
			return lit;
			}
			
		return null;
		}
    }