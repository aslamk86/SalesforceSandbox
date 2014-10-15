/*****************************************************************************
 * Name             : PortfolioManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 12 Jan, 2012.
 * Purpose          : Portfolio Trigger
 *                    T-21599
*****************************************************************************/
trigger PortfolioTrigger on Assets__c (after insert, after update, before insert, before update, before delete) {
//;
  if(trigger.isAfter){
      if(trigger.isUpdate){
        PortfolioManagement.afterPortfolioUpdate (Trigger.newMap, Trigger.oldMap);
      }
  } else {
    if(trigger.isDelete) {
      PortfolioManagement.beforePortfolioDelete(Trigger.oldMap);
    }
  }
}