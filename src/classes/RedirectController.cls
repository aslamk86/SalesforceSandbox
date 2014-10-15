public class RedirectController {

    public PageReference redirect() {
        String userId = UserInfo.getLastName();
        
        String url = API_ENDPOINT_URLS__c.getValues('Insurance Call Back URL').ENDPOINT_URL__c;
        PageReference pg = new PageReference(url);
        pg.setRedirect(true);
        if(userId!=null && userId!='Site Guest User')        
            pg.getParameters().put('status','true');
        else 
            pg.getParameters().put('status','false');
            
            
        return pg;
    }

}