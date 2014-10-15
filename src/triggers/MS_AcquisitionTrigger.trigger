/*
    Trigger      : MS_AcquisitionTrigger
    Object       : Acquisition Opportunity
    Description  : Update Litigation/Defendant Info Fields
    Created By   : Martin Sieler
    Created Date : July 31, 2012
*/

trigger MS_AcquisitionTrigger on Acquisition_Opportunity__c
		(
		after insert,
		after update,
		after undelete
		)
	{
	if (Label.MartinSieler_Stuff_Active == 'yes')
		{
		if (trigger.isAfter)
			{
			if (trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)
				{
				MS_RefreshObjects.RefreshAcquisition(trigger.new, trigger.isBefore);
				}
			}
		}
	}