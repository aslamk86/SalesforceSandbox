/*
    Trigger      : MS_AcquisitionOpportunityDefendantTrigger
    Object       : Acquisition Opportunity Defendant
    Description  : Update Litigation/Defendant Info Fields
    Created By   : Martin Sieler
    Created Date : July 27, 2012
*/

trigger MS_AcquisitionOpportunityDefendantTrigger on Acquisition_Opportunity_Defendant__c
		(
		after insert,
		after update,
		after undelete,
		after delete
		)
	{
	if (Label.MartinSieler_Stuff_Active == 'yes')
		{
		if (trigger.isAfter)
			{
			if (trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)
				{
				MS_LitigationInfo.AcqOppDefendantTriggerAfter(trigger.new);
				}
			else if (trigger.isDelete)
				{
				MS_LitigationInfo.AcqOppDefendantTriggerAfter(trigger.old);
				}
			}
		}
	}