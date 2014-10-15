/*
    Class        : MS_StringSimilarity
    Description  : Class to determine string similarity (e.g. for company names)
    Created By   : Martin Sieler
    Created Date : July 23, 2012
*/

public without sharing class MS_StringSimilarity
	{
	// add new abbreviations here
	private static final map<String, String> mapAbbr = new map<String, String>
		{
		'ag'        => 'ag',             // dummy for corp remove
		'a/s'       => 'as',
		'asa'       => 'asa',            // dummy for corp remove
		'b.v.'      => 'bv',
		'b v'       => 'bv',
		'co'        => 'company',
		'corp'      => 'corporation',
		'gmbh'      => 'gmbh',           // dummy for corp remove
		'inc'       => 'incorporated',
		'kg'        => 'kg',             // dummy for corp remove
		'l.l.c.'    => 'llc',
		'l.p.'      => 'lp',
		'ltd'       => 'limited',
		'n.v.'      => 'nv',
		'p.c.'      => 'pc',
		'p.l.c.'    => 'plc',
		's.a.'      => 'sa'
		};

	private static final String punctuation = '\\.,;';

  //-------------------------------------------------------------------------------------------------------------------------
  // isCompanyNameSimilar
  //-------------------------------------------------------------------------------------------------------------------------
	public static String isCompanyNameSimilar(String str1, String str2)
		{
		// if either one is blank and the other is not, they are not similar
		if ((MS_Tools.isBlankString(str1) && !MS_Tools.isBlankString(str2)) || (!MS_Tools.isBlankString(str1) && MS_Tools.isBlankString(str2)))
			return 'N';

		// two blank strings are similar
		if (MS_Tools.isBlankString(str1) && MS_Tools.isBlankString(str2))
			return 'Y';

		String s1  = ReplaceAbbr(str1);
		String s2  = ReplaceAbbr(str2);
		String s1N = Normalize(s1);
		String s2N = Normalize(s2);

		if (s1N == s2N)
			return 'Y';
			
		String s1CorpRemoved = Normalize(RemoveCorp(s1));
		String s2CorpRemoved = Normalize(RemoveCorp(s2));
		
		if (s1CorpRemoved == s2N || s1N == s2CorpRemoved)
			return '?';		

		return 'N';
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // Normalize
  //-------------------------------------------------------------------------------------------------------------------------
	private static String Normalize(String str)
		{
		if (MS_Tools.isBlankString(str))
			return '';

		// remove punctuation, lower case, multiple whitespace to single whitespace, trim
		String s = str;
		
		s = s.replaceAll('[' + punctuation + ']', ' ');
		s = s.replaceAll('\\s+', ' ');
		s = s.toLowerCase();
		s = s.trim();
		
//		System.Debug(MS_Tools.Finest, '--- MS_StringSimilarity.Normalize: \'' + str + '\' --> \'' + s + '\'');
		
		return s;
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // ReplaceAbbr
  //-------------------------------------------------------------------------------------------------------------------------
	private static String ReplaceAbbr(String str)
		{
		if (MS_Tools.isBlankString(str))
			return '';

		String s = ' ' + str.toLowerCase() + ' ';

		for (String regEx : mapAbbr.keySet())
			s = s.replaceAll('[' + punctuation + '\\s]+' + regEx + '[' + punctuation + '\\s]+', ' ' + mapAbbr.get(regEx) + ' ');

//		System.Debug(MS_Tools.Finest, '--- MS_StringSimilarity.ReplaceAbbr: \'' + str + '\' --> \'' + s + '\'');

		return s.trim();
		}

  //-------------------------------------------------------------------------------------------------------------------------
  // RemoveCorp
  //-------------------------------------------------------------------------------------------------------------------------
	private static String RemoveCorp(String str)
		{
		if (MS_Tools.isBlankString(str))
			return '';

		String s = ' ' + str.toLowerCase() + ' ';

		for (String regEx : mapAbbr.keySet())
			s = s.replaceAll('[' + punctuation + '\\s]+' + mapAbbr.get(regEx) + '[' + punctuation + '\\s]+', ' ');

//		System.Debug(MS_Tools.Finest, '--- MS_StringSimilarity.RemoveCorp: \'' + str + '\' --> \'' + s + '\'');

		return s.trim();
		}

	}