/*****************************************************************************
 * Name             : PortfolioManagement
 * Created By       : Neeraj G.(Appirio Offshore)
 * Purpose          : portfolio2product Trigger
 *
 * Modified         : Hank Ryan Thompson, 4/2013. Changes marked "HRT.4.13"
 *
*****************************************************************************/

trigger portfolio2productTrigger on portfolio2product__c (before insert, before update,after delete, after insert, after update) {
    // HRT.4.13: Added debug messages, cleaned up formatting.
    
    system.debug('###portfolio2productTrigger: Entering trigger.###');
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            portfolio2ProductManagement.beforePortfolio2ProductInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            portfolio2ProductManagement.beforePortfolio2ProductUpdate(Trigger.new);
        } 
    }
    
    system.debug('###portfolio2productTrigger: Exiting trigger.###');
    
}