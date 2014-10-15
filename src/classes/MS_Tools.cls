/*
    Class        : MS_Tools
    Description  : Useful functions
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

public without sharing class MS_Tools
	{

	// use these for special logging
	// set APEX logging to ERROR and set all values to ERROR that you want to see in that log
	public static final LoggingLevel Error  = LoggingLevel.Error;
	public static final LoggingLevel Warn   = LoggingLevel.Error;
	public static final LoggingLevel Info   = LoggingLevel.Error;
	public static final LoggingLevel Debug  = LoggingLevel.Error;
	public static final LoggingLevel Fine   = LoggingLevel.Error;
	public static final LoggingLevel Finer  = LoggingLevel.Finer;
	public static final LoggingLevel Finest = LoggingLevel.Finest;

/*
	// use these for normal logging
	public static final LoggingLevel Error  = LoggingLevel.Error;
	public static final LoggingLevel Warn   = LoggingLevel.Warn;
	public static final LoggingLevel Info   = LoggingLevel.Info;
	public static final LoggingLevel Debug  = LoggingLevel.Debug;
	public static final LoggingLevel Fine   = LoggingLevel.Fine;
	public static final LoggingLevel Finer  = LoggingLevel.Finer;
	public static final LoggingLevel Finest = LoggingLevel.Finest;
*/

	//-------------------------------------------------------------------------------------------------------------------------------
	// cObject class - thin wrapper for sObjects
	//-------------------------------------------------------------------------------------------------------------------------------
	public class cObject
		{
		sObject obj {get; set;}
		public cObject(sObject obj) {this.obj = obj;}
		}

	//-------------------------------------------------------------------------------------------------------------------------------
	// FixDocketUrl - docket url changed with new portal release
	//-------------------------------------------------------------------------------------------------------------------------------
	public static String FixDocketUrl(String url)
		{
		String s = url;

		if (isBlankString(url))
			return s;
		else
			return s.replace('/intelligence/litigation/details/', '/litigations/');
		}

	//-------------------------------------------------------------------------------------------------------------------------------
	// Compare - compare two objects
	//-------------------------------------------------------------------------------------------------------------------------------
	public static integer Compare(object a, object b, String SortColumn, boolean isAsc)
		{
		object s0 = a;
		object s1 = b;

		System.Debug('s0: ' + s0);
		System.Debug('s1: ' + s1);

		if (!isBlankString(SortColumn))
			{
			String[] SortToken = SortColumn.split('\\.');
	
			for (integer i=0; i<SortToken.Size()-1; i++)
				{
				System.Debug('Field name: ' + SortToken[i]);

				s0 = ((sObject)s0).getSObject(SortToken[i]);
				s1 = ((sObject)s1).getSObject(SortToken[i]);
	
				System.Debug('s0: ' + s0);
				System.Debug('s1: ' + s1);
				}
	
			s0 = ((sObject)s0).get(SortToken[SortToken.Size()-1]);
			s1 = ((sObject)s1).get(SortToken[SortToken.Size()-1]);
	
			System.Debug('s0: ' + s0);
			System.Debug('s1: ' + s1);
			}

		if (s0 == s1)
			return 0;

		list<object> l = new object[2];
		l[0] = s0;
		l[1] = s1;

		l.sort();

		if (l[1] == s0)
			return IsAsc ? 1 : -1;
		else
			return IsAsc ? -1 : 1;
		}

	//-------------------------------------------------------------------------------------------------------------------------------
	// isNewOrChanged - Returns true if field value is new or changed
	//-------------------------------------------------------------------------------------------------------------------------------
	public static boolean isNewOrChanged(sObject newRecord, Map<Id, sObject> oldMap, String fieldName)
		{
		// if no old map or no corresponding value in old map, return true
		if (oldMap == null || !oldMap.containsKey(newRecord.Id))
			return true;
        
		// check for changed value
		return (oldMap.get(newRecord.Id).get(fieldName) != newRecord.get(fieldName));
		}

	//-------------------------------------------------------------------------------------------------------------------------------
	// getOldObject - Get old version of object from oldMap
	//-------------------------------------------------------------------------------------------------------------------------------
	public static sObject getOldObject(sObject newRecord, Map<Id, sObject> oldMap)
		{
		// if no old map or no object for newRecord in map return null
		if (oldMap == null || !oldMap.containsKey(newRecord.Id))
			return null;
        
		// return old object
		return (oldMap.get(newRecord.Id));
		}

	//-------------------------------------------------------------------------------------------------------------------------------
	// isBlankString - Check if a string is null or blank
	//-------------------------------------------------------------------------------------------------------------------------------
	public static boolean isBlankString(String s)
		{
		return (s == null || s == '' || s.length() == 0);
		}

	//-------------------------------------------------------------------------------------------------------------------------------
	// SendEmail - Send an email (for debugging purposes)
	//-------------------------------------------------------------------------------------------------------------------------------
	public static void SendEmail(String sAddress, String sSubject, String sBody)
		{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {sAddress};
		mail.setToAddresses(toAddresses);
		mail.setSubject(sSubject);
		mail.setPlainTextBody(sBody);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}

	}