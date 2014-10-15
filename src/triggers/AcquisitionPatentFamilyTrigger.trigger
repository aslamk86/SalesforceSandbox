trigger AcquisitionPatentFamilyTrigger on Acquisition_Patent_Families__c (after insert, after delete, after update) {
  
  if(Trigger.isAfter) {
  	if(Trigger.isInsert) {
      AcquisitionPatentFamilyManagement.afterAcquisitionPatentFamilyInsert(Trigger.New);
	  }
	  if(Trigger.isUpdate) {
	  	AcquisitionPatentFamilyManagement.afterAcquisitionPatentFamilyUpdate(Trigger.newMap, Trigger.oldMap);
	  }
	  if(Trigger.isDelete) {
	    AcquisitionPatentFamilyManagement.afterAcquisitionPatentFamilyDelete(Trigger.oldMap);
	  } 
  }
  
  
  /*
  public String getKey(Id acqId, Id pfId) {
  	return  acqId + '~' + pfId;
  	
  }*/
  
}