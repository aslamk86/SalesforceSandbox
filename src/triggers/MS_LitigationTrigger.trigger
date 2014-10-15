/*
    Trigger      : MS_LitigationTrigger
    Object       : Litigation
    Description  : Update Litigation/Defendant Info Fields
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

trigger MS_LitigationTrigger on Litigation__c
		(
		before insert, after insert,
		before update, after update,
		after undelete,
		before delete, after delete
		)
	{
	if (Label.MartinSieler_Stuff_Active == 'yes')
		{
		if (trigger.isBefore)
			{
			if (trigger.isInsert || trigger.isUpdate)
				{
				MS_LitigationInfo.LitigationTriggerBefore(trigger.new, trigger.isDelete);
				MS_RefreshObjects.RefreshLitigation(trigger.new, trigger.isBefore);
				}
			else if (trigger.isDelete)
				{
				MS_LitigationInfo.LitigationTriggerBefore(trigger.old, trigger.isDelete);
				}
			}
		else if (trigger.isAfter)
			{
			if (trigger.isInsert || trigger.isUpdate)
				{
				MS_LitigationInfo.LitigationTriggerAfter(trigger.new, trigger.oldMap, trigger.isDelete);
				}
			else if (trigger.isUnDelete)
				{
				MS_RefreshObjects.RefreshLitigation(trigger.new, trigger.isBefore);
				MS_LitigationInfo.LitigationTriggerAfter(trigger.new, trigger.oldMap, trigger.isDelete);
				}
			else if (trigger.isDelete)
				{
				MS_LitigationInfo.LitigationTriggerAfter(trigger.old, null, trigger.isDelete);
				}
			}
		}
	else
		{
		if (trigger.isBefore)
			{
			if (trigger.isInsert || trigger.isUpdate)
				{
				MS_LitigationInfo.LitigationTriggerBefore(trigger.new, trigger.isDelete);
				}
			}
		}
	}