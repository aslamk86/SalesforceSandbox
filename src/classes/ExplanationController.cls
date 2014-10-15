/**
  * @author Paul Battisson, Xactium Ltd
  * @description 
  */
public with sharing class ExplanationController
{
    public Claims__Claim__c claim {get; private set;}
    public Claims__Client__c client {get; private set;}
    public Claims__Policy_Detail__c coverType {get; private set;}
    public Claims__Incident_Report__c report {get; private set;}
    public List<Claims__Claim_Payment__c> payments {get; set;}
    public String letterText1 {get; set;}
    public String letterText2 {get; set;}
    public String letterText3 {get; set;}

    private static Map<Integer, String> months = new Map<Integer, String>
    {
        1 => 'January',
        2 => 'February',
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'
    };

    public ExplanationController(ApexPages.StandardController stdCtlr)
    {
        try
        {
        claim = [SELECT Claims__Activity_Status__c, Name, Claims__Client__c, Claims__Client__r.Name, Claims__Policy_Detail__c, Claims__Date_Notified__c, Claims__Retained_Within_Excess__c,
                    Claims__Employee_Name__c, Claims__Employee_Name_Display__c, Claims__External_Id__c, Claims__Gross_Incurred__c, Claims__Incident_Report__c,
                    Claims__Location__c, Claims__Loss_Date__c, Claims__Loss_Description__c, Claims__Loss_Estimate__c, Claims__Net_Incurred__c, Claims__Net_Paid__c, 
                    Claims__Net_Reserve__c, Other_Claims_TotalF__c, Other_Claims_Total__c, Claims__Paid_Total__c, Panel_Council__c, Id, Remaining_Aggregate_SIR__c, 
                    Remaining_LAE_Reserve__c, Remaining_Per_Claim_SIR__c, Remaining_Reserve__c, Claims__Reserve_Cost__c, Claims__Reserve_Total__c, Claims__Reserve__c, 
                    SIR_Remaining__c, Stage_1_Available__c, Stage_1_End_Date__c, Stage_1_Limit__c, Stage_1_Paid__c, Stage_1_Start_Date__c, Stage_2_Available__c, 
                    Stage_2_End_Date__c, Stage_2_Limit__c, Stage_2_Paid__c, Stage_2_Start_Date__c, Stage_3_Available__c, Stage_3_End_Date__c, Stage_3_Limit__c, Stage_3_Paid__c, 
                    Stage_3_Start_Date__c, Stage_4_Available__c, Stage_4_End_Date__c, Stage_4_Limit__c, Stage_4_Paid__c, Stage_4_Start_Date__c, Claims__Status__c,
                    Total_LAE_Payments__c, Total_LAE_Reserve_Val__c, Total_Paid__c, Total_Reserve_Val__c, Date_Approved_as_Claim__c, Date_Claim_Closed__c, Total_Amount_Approved__c,
                    Remaining_Aggregate_SIR_T__c, Remaining_Per_Claim_SIR_T__c, Resolution_Payment_Amount__c, Resolution_Payment_Date__c, Total_Paid_With_Resolution__c 
                    FROM Claims__Claim__c WHERE Id = :stdCtlr.getId()];


        payments = [SELECT Claims__Amount__c, Amount_Reimbursed_F__c, Claims__Claim__c, Co_Ins_Amount_F__c, Claims__Cost_Heading__c, Claims__Date_Paid__c, Date_Received__c, 
                         Is_LAE__c, Claims__Notes__c, Claims__Policy__c, Id, Stage__c, SystemModstamp, Claims__Year__c,
                        Provider__c, Role__c, Invoice_Number__c 
                        FROM Claims__Claim_Payment__c WHERE Claims__Claim__c = :claim.Id ORDER BY Date_Received__c, Name];

        client = [SELECT Claims__Account__c, Claims__Address__c, Claims__Building__c, Claims__City__c, Name, Claims__Country__c, Claims__Industry__c, Claims__Level__c, 
                    Claims__Parent__c, Id, Claims__State_Province__c, Claims__Street__c, Claims__Post_Code__c FROM Claims__Client__c WHERE Id = :claim.Claims__Client__c];

        coverType = [SELECT Claims__Is_Active__c, Aggregate_Limit_of_Liability__c, Aggregate_SIR__c, Co_Pay_Percentage__c, Co_Pay_Percentage_Panel__c, Claims__Cover_Type__c,
                        Claims__Cover_Type_Lookup__c, Claims__Description__c, Claims__Expiry_Date__c, Claims__Inception_Date__c, Claims__Insurer__c, Claims__Lead_Insurer__c,
                        Claims__Limit__c, Claims__Net_Premium__c, Name, Per_Claim_Limit_of_Liability__c, Per_Claim_SIR__c, Claims__Policy__c, Id, Stage_1_Default_Percentage__c,
                        Stage_2_Default_Percentage__c, Stage_3_Default_Percentage__c, Stage_4_Default_Percentage__c, Claims__Sums_Insured__c, Total_Paid_Amount__c, Claims__Deductible__c, Remaining_Aggregate_SIR__c, Remaining_Aggregate_Limit_of_Liability__c 
                        FROM Claims__Policy_Detail__c WHERE Id = :claim.Claims__Policy_Detail__c];

        report = [SELECT other_insurers_accepted_as_claim__c, street_address__c, contact_address__c, Alleged_patent_infringement__c, description_of_circumstances__c, 
                    served_with_complaint__c, conditions_on_claim__c, Claims__Date_Reported__c, Claims__IncidentDate__c, date_when_served__c, 
                    Claims__Description_of_Incident__c, Description_of_prior_communication__c, Description_of_subsequent_communications__c, 
                    Claims__Details_of_3rd_Party_Damage__c, Claims__Details_of_All_Any_Injuries__c, due_date_first_pleading__c, Claims__First_Name__c, 
                    Claims__Email__c, identified_potential_panel__c, Identified_non_panel_candidates__c, Identified_potential_candidate_info__c, Name, 
                    Claims__Incident_Reported_By__c, Incident_or_Event_Notification__c, insured__c, intend_to_engage__c, Claims__Last_Name__c, 
                    nature_of_monetary_relief__c, Claims__Title__c, Subsequent_communications__c, Claims__Report_Completion_Date__c, 
                    Claims__Report_Completed_By__c, Other_policies__c, Mobile_Number__c, Claims__Liability__c, Other_policy_information__c, 
                    Other_policy_notice__c, Office_Phone_Number__c, policy_number__c, contact_person_position__c, Potential_claimants__c, Prior_communications__c, Id 
                    FROM Claims__Incident_Report__c WHERE Id = :claim.Claims__Incident_Report__c];

        setPreliminaryLetterText();
        }
        catch(Exception e)
        {
            System.debug('PAUL: ' + e.getLineNumber());
        }


    }

    private void setPreliminaryLetterText()
    {
        letterText1 = getFormattedDate(Date.today()) + '\n\n' + getNamedInsuredRep() + ', \n\t' + report.Claims__Title__c + ', \n\t' + claim.Claims__Client__r.Name + ', \n\t' + report.street_address__c + ',\n\t' + report.contact_address__c  + ', \n\n' 
        + 'By email to ' + getNamedInsuredRep() + ': ' + report.Claims__Email__c + '\n\nRe:\n\tInsured: ' + claim.Claims__Client__r.Name + '\n\tInsured\'s Representative: ' + getNamedInsuredRep() + '\n\tNPE Patent Infringement Liability Policy No.: '
        + report.policy_number__c + '\n\tRPXIS Incident Number: ' + report.Name + '\n\tDate of Notice: ' + getFormattedDate(report.Claims__Date_Reported__c) + '\n\nDear ' + report.Claims__Title__c + ' ' + report.Claims__Last_Name__c +
        '\n\nAs you know, RPX Insurance Services, LLC (“RPXIS”) is responsible for managing claims on policies issued by RPX Risk Retention Group, Inc. (“RPX RRG”). Based on information currently available to us, on behalf of RPX RRG, we approve the above-referenced incident formally reported to us on ' + getFormattedDate(report.Claims__Date_Reported__c) + ' because it falls within the Policy’s insuring agreement as a covered Claim. On behalf of RPX RRG, RPXIS reserves all its rights under the terms of the Policy and applicable law. RPX RRG understands that the rights of the Insured ' + claim.Claims__Client__r.Name + ' (“Insured” or "'+ claim.Claims__Client__r.Name + '") are similarly reserved. This letter serves as RPX RRG’s explanation of coverage.'
        + '\n\nBased on currently available information, the Policy definition of Claim is satisfied because a lawsuit meeting the definition of a Civil Proceeding  has been brought by ' + report.Potential_claimants__c + ', which meets the Policy definition of Non-Practicing Entity,  where ' + claim.Claims__Client__r.Name + ' is a defendant and the Civil Proceeding meets the definition of a Covered Litigation.'
        + '\n\nThe Policy provides that RPX RRG will reimburse Litigation Expenses and, if appropriate, Resolution Payments that ' + claim.Claims__Client__r.Name + ' incurs in defense of the above-referenced Civil Proceeding first brought against ' + claim.Claims__Client__r.Name + ' during the Coverage Period or Extended Reporting Period, if applicable, and reported in compliance with Section VIII.A  of the Policy. The Policy is effective from ' + coverType.Claims__Inception_Date__c + ' to ' + coverType.Claims__Expiry_Date__c + '.  The Policy has an aggregate retention of $' + coverType.Aggregate_SIR__c + ' and a per claim retention of $' + coverType.Per_Claim_SIR__c + ' and has a per claim Limit of Reimbursement Liability of ' + coverType.Per_Claim_Limit_of_Liability__c + ' and aggregate Limit of Reimbursement Liability of $' 
        + coverType.Aggregate_Limit_of_Liability__c + '.  In order for a payment to a third party arising out of a Covered Litigation to be eligible to erode the per Claim and Aggregate retentions, it must meet the Policy definition of Litigation Expense or Resolution Payment and satisfy the Policy requirements for reimbursement.'
        + '\n\nAssuming ' + claim.Claims__Client__r.Name + ' selects Panel Litigation Counsel , ' + claim.Claims__Client__r.Name + 'will be responsible for a Copayment Percentage of twenty percent (20%) on all approved Litigation Expenses. Any Resolution Payment also is subject to a Copayment Percentage of twenty percent (20%).'
        + '\n\nBecause RPX RRG does not have a duty to defend any Claim, ' + claim.Claims__Client__r.Name + 'is responsible for hiring Litigation Counsel and defending the Claim.  However, RPX RRG, through RPXIS, has the right to consent to Litigation Counsel.  We understand that '  + claim.Claims__Client__r.Name + ' has identified ' + report.Identified_potential_candidate_info__c + ' from ' + report.identified_potential_panel__c + ' as a Panel Litigation Counsel candidate.  We have provided the RFP form for ' + report.Identified_potential_candidate_info__c + ' to complete and submit to both you and RPXIS to begin the Panel Litigation Counsel approval process.'
        + '\n\nShould you have any questions regarding this Explanation of Coverage, please do not hesitate to contact me.\n\nBest regards,\n\n\n\nKimberly Klein Cauthorn,\nSenior Director, Claims\nkcauthorn@rpxcorp.com\n\n\n';

        letterText2 = '1. See Section I.A.\n2. C. “Claim” means:\n (1) any <b>Civil Proceeding</b> that is brought by a <b>Non-Practicing Entity</b> alleging <b>Patent Infringement</b> (other than as to an <b>Excluded Patent</b>) where the Insured is a defendant and the <b>Civil Proceeding</b> is a <b>Covered Litigation</b>.\n3. See, e.g., Section I.G (requires repayment of any Litigation Expense or Resolution Payment made by RPX RRG if it is later determined that the plaintiff did not meet  the Policy definition of Non-Practicing Entity).\n4. ' + report.Identified_potential_candidate_info__c
        + 'brought suit in the U.S. District Court in the ____ District of ____ solely alleging Patent Infringement by ' + claim.Claims__Client__r.Name + '.  See Policy Section III.B.\n5. Under Policy Section III.Y, ' + report.Identified_potential_candidate_info__c + ' is not an Excluded NPE under Policy Appendix A, and EXPLANATION OF HOW NPE DEFINITION SATISFIED.\n6. ' + report.Identified_potential_candidate_info__c + '\'s lawsuit against ' + claim.Claims__Client__r.Name + ' was filed on ' + report.date_when_served__c + ', which is during the annual Policy Period that began ' + coverType.Claims__Inception_Date__c + ', and ' + claim.Claims__Client__r.Name + ' gave formal notice on ' + report.Claims__Date_Reported__c + ', which is within the Policy Period and within the Reporting Window of thirty days from when ' + claim.Claims__Client__r.Name + ' became aware of the Claim.';
    }

    public String getImageURL()
    {
        List<Document> rsDocument = [SELECT Id FROM Document WHERE DeveloperName = 'Claim_Manager_App_Logo' LIMIT 1];

        if (!rsDocument.isEmpty()){
            return '/servlet/servlet.FileDownload?file=' + rsDocument[0].Id;
        }
        return '';
    }

    public void getPDFText()
    {
        letterText1 = letterText1.replaceAll('\n', '<br/>');
        letterText1 = letterText1.replaceAll('\t', '&emsp;&emsp;');
        letterText2 = letterText2.replaceAll('\n', '<br/>');
        letterText2 = letterText2.replaceAll('\t', '&emsp;&emsp;');
    }

    public String getNamedInsuredRep()
    {
        return report.Claims__First_Name__c + ' ' + report.Claims__Last_Name__c;
    }

    public String getFormattedDate(Date dt)
    {
        return months.get(dt.month()) + ' ' +  dt.day() + ', ' + dt.year();
    }

    public PageReference print()
    {
        getPDFText();
        return Page.ClosurePDF;
    }
}