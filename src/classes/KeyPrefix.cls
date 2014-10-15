/****************************************************************************************************************************
 * Name             : KeyPrefix
 * Created By       : Neeraj(Appirio Offshore)
 * Created Date     : 18 April, 2012.
 * Purpose          : Utility Class to get Record Name and type based on Record Id (Uses metadata api)
 ****************************************************************************************************************************/
public class KeyPrefix  {  
	// map to hold global describe data  
	private static Map<String,Schema.SObjectType> gd;  
  
	// map to store objects and their prefixes  
	private static Map<String, String> keyPrefixMap;  
  
	// to hold set of all sObject prefixes  
	private static Set<String> keyPrefixSet;  
  
  //-------------------------------------------------------------------------------------------------------------------------
  //Initialization
  //-------------------------------------------------------------------------------------------------------------------------    
	private static void init() {  
    // get all objects from the org  
    gd = Schema.getGlobalDescribe();  
      
    // to store objects and their prefixes  
    keyPrefixMap = new Map<String, String>{};  
          
    //get the object prefix in IDs  
    keyPrefixSet = gd.keySet();  
          
    // fill up the prefixes map  
    for(String sObj : keyPrefixSet)  
    {  
        Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();  
        String tempName = r.getName();  
        String tempPrefix = r.getKeyPrefix();  
        keyPrefixMap.put(tempPrefix, tempName);  
    }  
	}  
	
	//-------------------------------------------------------------------------------------------------------------------------
	//Returns Object Name
	//-------------------------------------------------------------------------------------------------------------------------       
	public static String GetKeyPrefix(String ObjId) {  
		init() ;  
		String tPrefix = ObjId;  
		tPrefix = tPrefix.subString(0,3);  
          
    //get the object type now  
    String objectType = keyPrefixMap.get(tPrefix);  
    return objectType;  
	}  
	
	//-------------------------------------------------------------------------------------------------------------------------
  //Returns current Record Object Type
  //-------------------------------------------------------------------------------------------------------------------------
  public static String getRecordName(String Id) {
  	String objApiName = KeyPrefix.GetKeyPrefix(Id);
  	for(Sobject sobj : Database.query('Select Name From ' + objApiName + ' Where id = :Id')) {
  		return String.valueOf(sobj.get('Name'));
  	}
  	return null;
  }
}