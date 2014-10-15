public class ValuationPrepopulationExtn {
    
    Public Acquisition_Opportunity__c acq;    
    Public Valuation_Tracking__c obj {get; set;}
    Public Id recordTypeId {get; set;}
    Public Id acqId {get; set;}
    
    public ValuationPrepopulationExtn (ApexPages.StandardController controller) {
        
        obj = (Valuation_Tracking__c)controller.getRecord();
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
    }
    
    public PageReference populateAndRedirect(){    
        //if(obj.Acquisition__c!=null)        
        if(obj!=null && obj.Acquisition__c!=null){
        
        System.debug('#### '+obj.Acquisition__c);
        System.debug('#### '+acqId );        
            acq = [select id,Name,Account__r.Name,Account__c,Source__c,Source__r.Name from Acquisition_Opportunity__c where id=:obj.Acquisition__c ];                                            
        
        
        ValuationPrepopulation__c mc = ValuationPrepopulation__c.getOrgDefaults();
        
        String url = '/'+mc.ObjectCode__c+'/e?';
        
        PageReference pg = new PageReference(url);
        pg.getParameters().put('nooverride', '1');
        
        pg.getParameters().put(mc.AcqNameIDField__c, acq.Name);
        pg.getParameters().put(mc.AcqNameIDField__c+'_lkid',acq.id);
        
        pg.getParameters().put(mc.AcqSourceID__c, acq.Source__r.Name);
        pg.getParameters().put(mc.AcqSourceID__c+'_lkid', acq.Source__c);
        
        pg.getParameters().put(mc.AccountNameId__c, acq.Account__r.Name);
        pg.getParameters().put(mc.AccountNameId__c+'_lkid', acq.Account__c);
        
        pg.getParameters().put('RecordType', recordTypeId);
        pg.getParameters().put(mc.DateFieldId__c, System.today().format());     
        pg.getParameters().put('retURL', acq.id);                        
        
        return pg;
        }
        else return null;
    }
}