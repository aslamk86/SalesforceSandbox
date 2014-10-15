/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        Apexpages.currentPage().getHeaders().put('p3p', 'CP="CAO DSP IVAa IVDa OUR BUS UNI OTC"');
        return Network.communitiesLanding();        
    }
    
    public CommunitiesLandingController() {}
}