/*
    Trigger      : MS_AccountTrigger
    Object       : Account
    Description  : Update Litigation/Defendant Info Fields / Update EntiTree fields on Account
    Created By   : Martin Sieler
    Created Date : July 22, 2012
*/

trigger MS_AccountTrigger on Account
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
				MS_LitigationInfo.AccountTriggerBefore(trigger.new, trigger.oldMap, trigger.isDelete);
				MS_AccountEntiTree.AccountTriggerBefore(trigger.new, trigger.oldMap, trigger.isDelete);
				}
			else if (trigger.isDelete)
				{
				MS_LitigationInfo.AccountTriggerBefore(trigger.old, null, trigger.isDelete);
				}
			}
		else if (trigger.isAfter)
			{
			if (trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)
				{
				MS_RefreshObjects.RefreshAccount(trigger.new);
				MS_LitigationInfo.AccountTriggerAfter(trigger.new, trigger.oldMap, trigger.isDelete);
				MS_AccountEntiTree.AccountTriggerAfter(trigger.new, trigger.oldMap, trigger.isDelete);
				}
			else if (trigger.isDelete)
				{
				MS_LitigationInfo.AccountTriggerAfter(trigger.old, null, trigger.isDelete);
				MS_AccountEntiTree.AccountTriggerAfter(trigger.old, null, trigger.isDelete);
				}
			}
		}
	else
		{
		if (trigger.isBefore)
			{
			if (trigger.isInsert || trigger.isUpdate)
				{
				MS_LitigationInfo.AccountTriggerBefore(trigger.new, trigger.oldMap, trigger.isDelete);
				// MS_AccountEntiTree.AccountTriggerBefore(trigger.new, trigger.oldMap);
				}
			}
		}
	}