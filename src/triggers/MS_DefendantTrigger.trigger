/*
    Trigger      : MS_DefendantTrigger
    Object       : Defendant
    Description  : Update Litigation/Defendant Info Fields
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

trigger MS_DefendantTrigger on Defendant__c
		(
		before insert, after insert,  
		before update, after update,
		after undelete,
		after delete
		)
	{
	if (Label.MartinSieler_Stuff_Active == 'yes')
		{
		if (trigger.isBefore)
			{
			if (trigger.isInsert || trigger.isUpdate)
				{
				MS_LitigationInfo.DefendantTriggerBefore(trigger.new);
				}
			}
		else if (trigger.isAfter)
			{
			if (trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)
				{
				MS_LitigationInfo.DefendantTriggerAfter(trigger.new);
				}
			else if (trigger.isDelete)
				{
				MS_LitigationInfo.DefendantTriggerAfter(trigger.old);
				}
			}
		}
	else
		{
		if (trigger.isBefore)
			{
			if (trigger.isInsert || trigger.isUpdate)
				{
				MS_LitigationInfo.DefendantTriggerBefore(trigger.new);
				}
			}
		}
	}