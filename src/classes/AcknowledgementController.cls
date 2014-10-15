/**
  * @author Paul Battisson, Xactium Ltd.
  * @description This class is the controller for the custom Acknowledgement letter.
  */
public with sharing class AcknowledgementController
{
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

	//This is the reference to the incident that will be used for the letter
	public Claims__Incident_Report__c report {get; set;}

	public AcknowledgementController(ApexPages.StandardController stdController)
	{
		report = [SELECT other_insurers_accepted_as_claim__c, street_address__c, contact_address__c, Alleged_patent_infringement__c, description_of_circumstances__c, 
					served_with_complaint__c, conditions_on_claim__c, Claims__Date_Reported__c, Claims__IncidentDate__c, date_when_served__c, 
					Claims__Description_of_Incident__c, Description_of_prior_communication__c, Description_of_subsequent_communications__c, 
					Claims__Details_of_3rd_Party_Damage__c, Claims__Details_of_All_Any_Injuries__c, due_date_first_pleading__c, Claims__First_Name__c, 
					Claims__Email__c, identified_potential_panel__c, Identified_non_panel_candidates__c, Identified_potential_candidate_info__c, Name, 
					Claims__Incident_Reported_By__c, Incident_or_Event_Notification__c, insured__c, intend_to_engage__c, Claims__Last_Name__c, 
					nature_of_monetary_relief__c, Claims__Title__c, Subsequent_communications__c, Claims__Report_Completion_Date__c, 
					Claims__Report_Completed_By__c, Other_policies__c, Mobile_Number__c, Claims__Liability__c, Other_policy_information__c, 
					Other_policy_notice__c, Office_Phone_Number__c, policy_number__c, contact_person_position__c, Potential_claimants__c, Prior_communications__c, Id, Client__c, Client__r.Name 
					FROM Claims__Incident_Report__c WHERE Id = :stdController.getId()];

		setPreliminaryLetterText();

	}

	private void setPreliminaryLetterText()
	{
		letterText = getFormattedDate(Date.today()) + '\n\n' + getNamedInsuredRep() + ', \n\t' + report.Claims__Title__c + ', \n\t' + report.Client__r.Name + ', \n\t' + report.street_address__c + ',\n\t'  + report.contact_address__c  + ', \n\n' 
		+ 'By email to ' + getNamedInsuredRep() + ': ' + report.Claims__Email__c + '\n\nRe:\n\tInsured: ' + report.Client__r.Name + '\n\tInsured\'s Representative: ' + getNamedInsuredRep() + '\n\tNPE Patent Infringement Liability Policy No.: '
		+ report.policy_number__c + '\n\tRPXIS Incident Number: ' + report.Name + '\n\tDate of Notice: ' + getFormattedDate(report.Claims__Date_Reported__c) + '\n\nDear ' + report.Claims__Title__c + ' ' + report.Claims__Last_Name__c +
		+ 'We received your Notice of Incident/Notice of Reportable Event to Claims Services for RPX Insurance Services, LLC (RPXIS), which is responsible for managing claims on policies issued by RPX Risk Retention Group, Inc. (“RPX RRG”), regarding the above-referenced lawsuit against '
		+ report.Client__r.Name + ' or communication received by ' + report.Client__r.Name + ' from ' + report.Potential_claimants__c + '. This letter is RPXIS’s acknowledgement of such notice; it does not constitute acceptance of a covered Claim.\n\n' +
		'IF NOTICE OF INCIDENT: RPXIS is currently investigating the facts and circumstances surrounding the lawsuit brought against you by ' + report.Potential_claimants__c + ' and the availability of coverage under the terms of the above-referenced policy. We will advise you of the results of that investigation as soon as we have completed it by providing an Explanation of Coverage.\n\n' +
		'I have been assigned to assist you with the defense of this matter. If you become aware of any additional information relating to the above-referenced claim/lawsuit, including but not limited to the information that ' 
		+ report.Client__r.Name + ' is required to provide to RPXIS on behalf of RPX RRG by the terms of the NPE Patent Policy, please provide that information to me at your earliest convenience. Please use the incident number set forth above in all future communications about the above-referenced lawsuit.\n\n'
		+ 'IF NOTICE OF REPORTABLE EVENT:[EITHER REFERENCE EARLIER DISCUSSIONS RE: REPORTABLE EVENT OR STATE THAT YOU WILL FOLLOW UP TO SCHEDULE A CALL TO DISCUSS] If you become aware of any additional information relating to the above-referenced Reportable Event, including but not limited to the information that ' 
		+ report.Client__r.Name + ' is required to provide to RPXIS on behalf of RPX RRG by the terms of the NPE Patent Policy, please provide that information to me at your earliest convenience. Please use the incident number set forth above in all future communications about the above-referenced lawsuit.\n\n'
		+ 'Best regards,\n\n\n\n\n\nKimberly Klein Cauthorn,\nSenior Director, Claims\nkcauthorn@rpxcorp.com';
	}

	public String letterText {get; set;}

	public String getImageURL()
	{
		List<Document> rsDocument = [SELECT Id FROM Document WHERE DeveloperName = 'Claim_Manager_App_Logo' LIMIT 1];

		if (!rsDocument.isEmpty()){
			return '/servlet/servlet.FileDownload?file=' + rsDocument[0].Id;
		}
		return '';
	}

	public String getPDFText()
	{
		String returnText = letterText.replaceAll('\n', '<br/>');
		return returnText.replaceAll('\t', '&emsp;&emsp;');
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
		return Page.AcknowledgementPDF;
	}
}