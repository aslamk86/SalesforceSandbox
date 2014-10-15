/*
    Class        : MS_RollUpSummaryUtility
    Description  : Roll-Up Summary functionality
                   Source: http://www.anthonyvictorio.com/salesforce/roll-up-summary-utility/
                           with modifications by Martin Sieler
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

public class MS_RollUpSummaryUtility
	{
	//-------------------------------------------------------------------------------------------------------------------------
	// field names and desired operations
	//-------------------------------------------------------------------------------------------------------------------------
	public class fieldDefinition
    {
    public String operation {get;set;}
    public String childField {get;set;}
    public String parentField {get;set;}
     
    public fieldDefinition (String o, String c, String p)
	    {
	    operation = o;
	    childField = c;
	    parentField = p;
	    }
    }

	//-------------------------------------------------------------------------------------------------------------------------
	// field names and filter
	//-------------------------------------------------------------------------------------------------------------------------
	public class FieldAndFilter
		{
		public String Field {get;set;}
		public String Filter {get;set;}
		
		public FieldAndFilter(String sField, String sFilter)
			{
			Field = sField;
			Filter = sFilter;
			}
		}   

	//-------------------------------------------------------------------------------------------------------------------------
	// rollUpTrigger for list of fieldDefinitions, all using same filter
	//-------------------------------------------------------------------------------------------------------------------------
	public static void rollUpTrigger(list<fieldDefinition> fieldDefinitions,
		list<sObject> records, String childObject, String childParentLookupField,
    String parentObject, String queryFilter)
		{
		//Limit the size of list by using Sets which do not contain duplicate
		//elements prevents hitting governor limits
		set<Id> parentIds = new set<Id>();
		for(sObject s : records)
			{
		  parentIds.add((Id)s.get(childParentLookupField));
		  }
		 
		//populate query text strings to be used in child aggregrator and parent value assignment
		String fieldsToAggregate = '';
		String parentFields = '';
		 
		for(fieldDefinition d : fieldDefinitions)
			{
		  fieldsToAggregate += d.operation + '(' + d.childField + ') ' + ', ';
		  parentFields += d.parentField + ', ';
		  }
		 
		//Using dynamic SOQL with aggergate results to populate parentValueMap
		String aggregateQuery = 'Select ' + fieldsToAggregate +
			childParentLookupField + ' from ' + childObject + ' where  ' +
			childParentLookupField + ' IN :parentIds ' + queryFilter + ' ' +
			' group by ' + childParentLookupField;
		 
		//Map will contain one parent record Id per one aggregate object
		map<Id, AggregateResult> parentValueMap = new map <Id, AggregateResult>();
		     
		for(AggregateResult q : Database.query(aggregateQuery))
			{
			parentValueMap.put((Id)q.get(childParentLookupField), q);
			}
		 
		//list of parent object records to update
		list<sObject> parentsToUpdate = new list<sObject>();
		 
		String parentQuery = 'select ' + parentFields + ' Id ' + ' from ' + parentObject + ' where Id IN :parentIds';
		 
		//for each affected parent object, retrieve aggregate results and
		//for each field definition add aggregate value to parent field
		for(sObject s : Database.query(parentQuery))
	    {
	    Integer row = 0; //row counter reset for every parent record
	    for(fieldDefinition d : fieldDefinitions)
        {
        String field = 'expr' + row.format();
        AggregateResult r = parentValueMap.get(s.Id);
        //r will be null if no records exist
        //(e.g. last record deleted)
        if(r != null)
        	{
        	Decimal value = ((Decimal)r.get(field) == null ) ? 0 : (Decimal)r.get(field);
        	s.put(d.parentField, value);
					}
        else
	        {
  	      s.put(d.parentField, 0);
    	    }
        row += 1; //plus 1 for every field definition after first
        }
	    parentsToUpdate.add(s);
	    }
		 
		//if parent records exist, perform update of all parent records
		//with a single DML statement
		if(parentsToUpdate.Size() > 0)
	    {
	    update parentsToUpdate;
	    }
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// rollUpTrigger for single fieldDefinition
	//-------------------------------------------------------------------------------------------------------------------------
	public static void rollUpTrigger(fieldDefinition fieldDef,
		list<sObject> records, String childObject, String childParentLookupField,
		String parentObject, String queryFilter)
		{
		list<fieldDefinition> fieldDefinitions = new list<fieldDefinition> { fieldDef };
		rollUpTrigger(fieldDefinitions, records, childObject, childParentLookupField, parentObject, queryFilter);
		}

	//-------------------------------------------------------------------------------------------------------------------------
	// rollUpTrigger for list of FieldsAndFilter all using same operation and child field
	//-------------------------------------------------------------------------------------------------------------------------
	public static void rollUpTrigger(list<FieldAndFilter> FieldAndFilters, String Operation, String ChildField, 
		list<sObject> Records, String ChildObject, String ChildParentLookupField,
		String ParentObject)
		{
		//Limit the size of list by using Sets which do not contain duplicate
		//elements prevents hitting governor limits
		set<Id> parentIds = new set<Id>();
		for(sObject s : Records)
			{
		  parentIds.add((Id)s.get(childParentLookupField));
		  }

		//get list of parents
		String ParentFields = '';
		for(FieldAndFilter f : FieldAndFilters)
			{
			ParentFields += f.Field + ', ';
			}
		String parentQuery = 'select ' + ParentFields + 'Id' + ' from ' + ParentObject + ' where Id IN : parentIds';
		list<sObject> Parents = Database.query(parentQuery);

		System.Debug(MS_Tools.Finer , 'rollUpTrigger(): RollUp Query ('+ Parents.Size() + ' parents): ' + parentQuery);

		// query and store result for each field and filter entry
		for(FieldAndFilter f : FieldAndFilters)
			{
			//Using dynamic SOQL with aggergate results to populate parentValueMap
			String aggregateQuery = 'Select ' +  Operation + '(' + ChildField + '), ' +
				ChildParentLookupField + ' from ' + ChildObject + ' where ' +
				ChildParentLookupField + ' IN : parentIds ' + f.Filter + ' ' +
				'group by ' + ChildParentLookupField;

			System.Debug(MS_Tools.Finer , 'rollUpTrigger(): RollUp Query: ' + aggregateQuery);
			
			//Map will contain one parent record Id per one aggregate object
			map<Id, AggregateResult> parentValueMap = new map <Id, AggregateResult>();

			for(AggregateResult q : Database.query(aggregateQuery))
				{
				parentValueMap.put((Id)q.get(childParentLookupField), q);
				}
			 
			//for each affected parent object, retrieve aggregate results and add aggregate value to parent field
			for(sObject s : Parents)
		    {
				AggregateResult r = parentValueMap.get(s.Id);
				//r will be null if no records exist
				//(e.g. last record deleted)
				if(r != null)
					{
					Decimal value = ((Decimal)r.get('expr0') == null ) ? 0 : (Decimal)r.get('expr0');
					s.put(f.Field, value);
					}
				else
					{
					s.put(f.Field, 0);
					}	     
		    }
			}

		//if parent records exist, perform update of all parent records
		//with a single DML statement
		if(!Parents.isEmpty())
			{
			update Parents;
			}
		}

	}

/*

	The utility accepts the following variables:
	
	  MS_RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, records, childObject, childParentLookupField, parentObject, queryFilter);
	  
	  
	fieldDefinitions (list<MS_RollUpSummaryUtility.fieldDefinition>) – The list of field definitions.  
	
	  The fieldDefinition class is comprised of three variables:
	
	    operation (String)   – Can be either SUM, MAX, MIN, or COUNT. When using COUNT, the childField must ALWAYS be ‘ID’.
	    childField (String)  – The api name for the child object’s field that contains the values you wish to summarize.
	                           Remember, when using the COUNT operation, the value for this variable must ALWAYS be ‘ID’.
	    parentField (String) – The api name for the parent object’s field that where the summarized value of the child object field will be stored.
	
	  Here’s an example of how you can create a fieldDefinitions list:
		
	    list<MS_RollUpSummaryUtility.fieldDefinition> fieldDefinitions =
	      new list<MS_RollUpSummaryUtility.fieldDefinition>
	        {
	        new MS_RollUpSummaryUtility.fieldDefinition('SUM', 'Amount__c', 'Total_Payments__c'),
	        new MS_RollUpSummaryUtility.fieldDefinition('MAX', 'Amount_2__c', 'Total_Payments_2__c')
	        };
	
  records (list<sObject>) – The list of records being passed to the utility.
	                          When using with a trigger this can either be trigger.new or trigger.old.
	                          Tip: Use trigger.old when executing during a trigger.isDelete operation.
	
	childObject (String) – The API name for the child object.
	                       This object must have either a look-up or master-detail relationship to a parent object.
	
	childParentLookupField (String) – The API name for the child object field that performs a look-up to a parent object
	                                  where the summary results will be stored.
	
	parentObject (String) – The API name for the parent object related to the child object.
	                        The childParentLookupField variable must be related to the object supplied in this variable.
	
	queryFilter (String) – An SOQL statement that will be used to filter the child object records.
	                       The string must always begin with ‘and’ if it’s being used.
	                       If no filter is needed simply supply an empty text value of ”, never supply a NULL value.
	                       Let’s say that based on the above example we only want to get a sum of payments made by check,
	                       our code would look like this:

 	  MS_RollUpSummaryUtility.RollUpTrigger(fieldDefinitions, trigger.new, 'Payment__c',
	    'Opportunity__c', 'Opportunity', 'and Type__c = \'Check\'');

*/