/****************************************************
   
   Content Version Management
   
    Built by Sharmila Jeevarakshagan.
    Created 01/07/2014
    Last updated 01/07/2014 by Sharmila J.
   
    This class validates editing on Content Version.
    
****************************************************/
public without sharing class ContentVersionManagement{
    
    public static void beforeCVUpdate(Map<Id,contentVersion> oldMap,Map<Id,contentVersion> newMap) {
        string ThisUserName = userinfo.getName();
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        string PrimaryApproverList=Label.Seller_Documents_Portal_Visibility_Primary_Approver_List;
        string ConfidentialityApproverList = Label.Seller_Documents_Portal_Visibility_Confidentiality_Approver_List;
        string EditorialApproverList = Label.Seller_Documents_Portal_Visibility_Editorial_Approver_List;
        string currentUserApprovalLevel = '';

    Id thisUser = UserInfo.getUserId();
    
    List<contentVersion> contentList = newMap.Values();
    
    Map<Id,Id> analystContentMap = new Map<Id,Id>();
    
    for(contentVersion tempVar:contentList){
      analystContentMap.put(tempVar.id,tempVar.Acquisition__c);
    }
    
    Map<Id,Acquisition_Opportunity__c> acqMap = new Map<Id,Acquisition_Opportunity__c>([select id, Analysis_Assigned_to__c from Acquisition_Opportunity__c   where id in :analystContentMap.values()]);
    
                            
        if (PrimaryApproverList.contains(ThisUserName))
            currentUserApprovalLevel = 'Primary Approver';   
        else if (EditorialApproverList.contains(ThisUserName))
            currentUserApprovalLevel = 'Editorial Approver';
       else if (ConfidentialityApproverList.contains(ThisUserName))
            currentUserApprovalLevel = '';            
        else if (profileName.contains('System Administrator'))
            currentUserApprovalLevel = 'System Administrator';    
                            
                            
      /*  if (currentUserApprovalLevel == '')
        {
            for (contentVersion newMapCV: newMap.values())
            { 
               if (newMap.get(newMapCV.Id).NDA__c != oldMap.get(newMapCV.Id).NDA__c|| newMap.get(newMapCV.Id).Portal_Visible__c != oldMap.get(newMapCV.Id).Portal_Visible__c|| newMap.get(newMapCV.Id).Review_Status__c != oldMap.get(newMapCV.Id).Review_Status__c)
                newMapCV.addError('User Not authorized to update the NDA, Portal Visibility, or Review Status on this document'); 
            }
        }//end if invalid users
        else
        {*/
            for (contentVersion cv: newMap.values())
            {
                system.debug('Profile name: '+ profileName +', Username: ' + ThisUserName +', Old details: ' + oldMap.get(cv.Id) + ', details: ' + cv);
                if (currentUserApprovalLevel == 'System Administrator')
              {
                //Do nothing.  System Administrators should be able to override review status from the back end.
                //Buttons from the Manage Content page is not available to them.
              }
                else if (currentUserApprovalLevel == 'Primary Approver')
                {
                    if ( (oldMap.get(cv.Id).NDA__c != cv.NDA__c ||  oldMap.get(cv.Id).Review_Status__c != cv.Review_Status__c || oldMap.get(cv.Id).portal_visible__c != cv.Portal_Visible__c) 
                        && (oldMap.get(cv.Id).Review_Status__c !='Not Submitted' && oldMap.get(cv.Id).Review_Status__C !='Publication Denied - Primary Review'&& oldMap.get(cv.Id).Review_Status__C !='Publication Approved')
                        && ( oldMap.get(cv.Id).Review_Status__C == 'Confidentiality Review' && oldMap.get(cv.Id).Portal_Visible_Review__c !='Not Recorded')
                        )
                    {
                        //cv.addError ('Cannot update the document details because it is not your turn in the review process for ' + oldMap.get(cv.Id).Title); 
                    }
                    else
                    {
                        if ( oldMap.get(cv.Id).Review_Status__C != cv.Review_Status__c)
                        {
                        //Primary Reviewer only allowed to put documents from publication denied\Not submitted to Confidentiality Review OR to deny publication
                            if (cv.Review_Status__c == 'Publication Denied - Primary Review'){
                               // if (cv.NDA__c != 'Yes' && cv.Portal_Visible__c !='No')
                                 //   cv.addError('Cannot update the Review Status to Publication Denied; please check the NDA and Portal Visible values for ' + oldMap.get(cv.Id).Title); 
                                 }
                            
                            else if (cv.Review_Status__c == 'Confidentiality Review'){
                                if ( (oldMap.get(cv.Id).Review_Status__c !='Not Submitted'&& oldMap.get(cv.Id).Review_Status__C !='Publication Denied - Primary Review') || ( oldMap.get(cv.Id).Review_Status__c=='Confidentiality Review' &&  oldMap.get(cv.Id).Portal_Visible_Review__c!='Not Recorded') )
                                    cv.addError('Cannot update the Review Status to the Confidentiality Review either because of the current workflow state or because Portal Visible is set to No for ' + oldMap.get(cv.Id).Title); }
                            else 
                                cv.addError('You do not have the permission to update the review status to the value specified for ' + oldMap.get(cv.Id).Title); 
                            } //changed review process
                        }//changed record on correct reivew process
                }//end primary approver
                else if (currentUserApprovalLevel == '') //Either the this user is invalid user or he might be the Confidentialty approver who is retrieved dynamically
                {
                  //Getting the Analyst for this Acquistion
                  Id thisContentAnalyst;
                  if(analystContentMap!=null && acqMap!=null){
                    Id contentId = analystContentMap.get(cv.id); 
                    if(contentId!=null){
                      thisContentAnalyst=acqMap.get(contentId).Analysis_Assigned_to__c;
                    }
                  }
                  System.debug('##This User :'+thisUser+' '+thisContentAnalyst);
                  if((thisContentAnalyst!=null && thisUser==thisContentAnalyst) || analystContentMap.get(cv.Id)==null){
                                    
                    if ( (oldMap.get(cv.Id).NDA__c != cv.NDA__c ||  oldMap.get(cv.Id).Review_Status__c != cv.Review_Status__c || oldMap.get(cv.Id).type__c != cv.type__c) //any changes
                        && (oldMap.get(cv.Id).Review_Status__c !='Confidentiality Review') && oldMap.get(cv.Id).Review_Status__C != 'Publication Denied - Confidentiality Review' //Changes outside of Confidentiality Review or Publication Denied
                         && ( oldMap.get(cv.Id).Review_Status__C == 'Editorial Review' && oldMap.get(cv.Id).Portal_Visible_Final__c !='Not Recorded'))// If in Editorial Review, Portal_Visible_Review__c=='Not Recorded'
                    {
                        cv.addError ('Cannot update the document details because it is not your turn in the review process for ' + oldMap.get(cv.Id).Title); 
                    }
                    else
                    {
                        if ( oldMap.get(cv.Id).Review_Status__C != cv.Review_Status__c)
                        {
                        //Reza only allowed to put documents from publication denied\Not submitted to Confidentiality Review OR to deny publication
                            if (cv.Review_Status__c == 'Publication Denied - Confidentiality Review'){
                                if (cv.NDA__c != 'Yes' && cv.Type__c !=null && cv.Type__c != 'Claim Charts' && cv.Type__c != 'EOU')
                                    cv.addError('Cannot update the Review Status to Publication Denied; please check the NDA and Portal Visible values for ' + oldMap.get(cv.Id).Title); }
                            else if (cv.Review_Status__c == 'Editorial Review'){
                            if ( oldMap.get(cv.Id).Review_Status__C !='Confidentiality Review' && oldMap.get(cv.Id).Review_Status__C != 'Publication Denied - Confidentiality Review' || (oldMap.get(cv.Id).Review_Status__c=='Editorial Review' && oldMap.get(cv.Id).Type__c!=null))
                                    cv.addError('Cannot update the Review Status to the Confidentiality Review either because of the current workflow state or because Portal Visible is set to No for ' + oldMap.get(cv.Id).Title); }
                            else 
                                cv.addError('You do not have the permission to update the review status to the value specified for ' + oldMap.get(cv.Id).Title); 
                            } //changed review process
                        }//changed record on correct reivew process
                  }                
                  else{
                    if (newMap.get(cv.Id).NDA__c != oldMap.get(cv.Id).NDA__c|| newMap.get(cv.Id).Portal_Visible__c != oldMap.get(cv.Id).Portal_Visible__c|| newMap.get(cv.Id).Review_Status__c != oldMap.get(cv.Id).Review_Status__c)
                      cv.addError('User Not authorized to update the NDA, Portal Visibility, or Review Status on this document'); 
                  }
                }//end confidentiality approver
                else if (currentUserApprovalLevel == 'Editorial Approver')
                {
                    //If the user trying to change details when it is not their turn add error (but user can deny at any point)
                    if ( (oldMap.get(cv.Id).NDA__c != cv.NDA__c ||  oldMap.get(cv.Id).Review_Status__c != cv.Review_Status__c || oldMap.get(cv.Id).portal_visible_final__c != cv.Portal_Visible_final__c) 
                        && (oldMap.get(cv.Id).Review_Status__c !='Editorial Review') && oldMap.get(cv.Id).Review_Status__C != 'Publication Denied - Editorial Review' && oldMap.get(cv.Id).Review_Status__C != 'Publication Approved')
                    {
                        cv.addError ('Cannot update the document details because it is not your turn in the review process for ' + oldMap.get(cv.Id).Title); 
                    }
                    else
                    {
                        if ( oldMap.get(cv.Id).Review_Status__C != cv.Review_Status__c)
                        {
                            //Third Approver only allowed to put documents from Editorial Review to Publishing Approved
                            if (cv.Review_Status__c == 'Publication Denied - Editorial Review'){
                                if (cv.NDA__c != 'Yes' && cv.Portal_Visible_Final__c !='No')
                                    cv.addError('Cannot update the Review Status to Publication Denied; please check the NDA and Portal Visible values for ' + oldMap.get(cv.Id).Title); }
                            else if (cv.Review_Status__c == 'Publication Approved'){
                                if ( oldMap.get(cv.Id).Review_Status__C !='Editorial Review' &&  oldMap.get(cv.Id).Review_Status__C != 'Publication Denied - Editorial Review' && oldMap.get(cv.Id).Review_Status__c!='Publication Approved')
                                    cv.addError('Cannot update the Review Status to the Editorial Review either because of the current workflow state or because Portal Visible is set to No for ' + oldMap.get(cv.Id).Title); }
                            else
                                cv.addError('You do not have the permission to update the review status to the value specified for ' + oldMap.get(cv.Id).Title);
                        } //changed review status
                    }//changed record on right workflow process
                }//Editorial Reviewer
            }//for every new value
    }//beforeCVUpdate
}//ContentVersionManagement