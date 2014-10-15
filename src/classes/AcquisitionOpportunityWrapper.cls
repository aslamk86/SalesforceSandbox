/*******************************************************************************
 * Name             : AcquisitionOpportunityWrapper
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 25 Feb, 2012.
 * Purpose          : Wrapper class for cheatsheet Resultset. 
 * Task               T-34016  
 ******************************************************************************/
public Class AcquisitionOpportunityWrapper {
    private List<Patents_in_Suit__c> lstPatentsInSuit{get;set;}
    private List<Defendant__c> lstDefendant{get;set;}
    public Acquisition_Opportunity__c acqOpp{get;set;}
    public Litigation__c litigation{get;set;}
    public List<OMA_Patent__c> lstOMAPatent{get;set;}
    public String patents{get;set;}
    public String defendants{get;set;}
    public Boolean isNPE {get;set;}
    //--------------------------------------------------------------------------
    //OMA Constructor
    //--------------------------------------------------------------------------
    public AcquisitionOpportunityWrapper(Acquisition_Opportunity__c acqOpp){
      this.acqOpp = acqOpp;
      this.lstOMAPatent = new List<OMA_Patent__c> ();
      if(acqOpp.OMA_Patents__r != null) {
        this.lstOMAPatent.addAll(acqOpp.OMA_Patents__r);
        this.patents = generatePatentString(this.lstOMAPatent);
      }
    }
    
    //--------------------------------------------------------------------------
    //Litigation Constructor
    //--------------------------------------------------------------------------
    public AcquisitionOpportunityWrapper(Acquisition_Opportunity__c acqOpp, List<Defendant__c> lstDefendant, Litigation__c litigation, Boolean isNPE){
      this.isNPE = isNPE;
      this.acqOpp = acqOpp;
      this.lstPatentsInSuit = new List<Patents_in_Suit__c> ();
      this.lstDefendant =  new List<Defendant__c>();
      
      if(litigation != null) {
	      if(litigation.Patents_in_Suit__r != null) {
	        this.lstPatentsInSuit.addAll(litigation.Patents_in_Suit__r);
          this.patents = generatePatentString(litigation.Patents_in_Suit__r);
        } 
      }
      
      if(lstDefendant != null) {
        this.lstDefendant.addAll(lstDefendant);
        this.defendants = generateDefendantString(this.lstDefendant);
      }
      
      this.litigation  = new Litigation__c();
      if(litigation != null) {
        this.litigation = litigation;
      }
      
    }
    
    //--------------------------------------------------------------------------
    //Return defendant String
    //--------------------------------------------------------------------------
    private String generateDefendantString(List<Defendant__c> lstDefendant){
      String defendantString = '';
      for(Defendant__c defendant : lstDefendant){
        /*
        if(!(defendant.Defendant_Name__c == null && defendant.Date_Terminated__c == null)){
          defendant.Defendant_Name__c = defendant.Defendant_Name__c == null ? '' : defendant.Defendant_Name__c;
          defendantString += defendant.Defendant_Name__c + ' - ';
          */
        //in case at least one value exist
        if(defendant.Account__c != null || defendant.Account__r.Name != null || defendant.Date_Terminated__c != null) {
        	if(defendant.Account__c != null) {
	          defendant.Account__r.Name = defendant.Account__r.Name == null ? '' : defendant.Account__r.Name;
	          defendantString += defendant.Account__r.Name + ' - ';  
        	}
        	
          if(defendant.Date_Terminated__c != null) {
            defendantString += defendant.Date_Terminated__c.format() + '&#10;';// &#10;
          }
          else{
            defendantString += '&#10;';
          }
        }
      }
      return defendantString;
    }
    
    //--------------------------------------------------------------------------
    //Return Patent String for OMA Patents
    //--------------------------------------------------------------------------
    private String generatePatentString(List<OMA_Patent__c> lstOMAPatent){
      String patentString = '';
      Integer i = 0;
      for(OMA_Patent__c omaPatent : lstOMAPatent){
        if(omaPatent.patent__r.Name != null){
          if(i != 0) {
            patentString += ' &#10;';
          }
          i++;
          
          if(omaPatent.Patent__r.Patent_No__c == null) {
            omaPatent.Patent__r.Patent_No__c = '';
          }
          
          if(omaPatent.Patent__r.Title__c == null) {
            omaPatent.Patent__r.Title__c = '';
          } 
          if(omaPatent.Patent__r.Title__c.length() > 100) {
            omaPatent.Patent__r.Title__c = omaPatent.Patent__r.Title__c.subString(0,100);
          }
          patentString += omaPatent.Patent__r.Patent_No__c + ' - ' + omaPatent.patent__r.Title__c + ' ';
        }
      }
      return patentString;
    }
    
    //--------------------------------------------------------------------------
    //Return Patent String for Patents In Suit
    //--------------------------------------------------------------------------
    private String generatePatentString(List<Patents_in_Suit__c> lstPatentInSuit){
      String patentString = '';
      Integer i = 0;
      for(Patents_in_Suit__c patentInSuit : lstPatentInSuit){
        if(patentInSuit.patent__r.Name != null){
          if(i != 0) {
            patentString += '&#10;';
          }
          i++;
          
          if(patentInSuit.Patent__r.Patent_No__c == null) {
            patentInSuit.Patent__r.Patent_No__c = '';
          }
          
          if(patentInSuit.Patent__r.Title__c == null) {
            patentInSuit.Patent__r.Title__c = '';
          } 
          if(patentInSuit.Patent__r.Title__c.length() > 100) {
            patentInSuit.Patent__r.Title__c = patentInSuit.Patent__r.Title__c.subString(0,100);
          }
          patentString += patentInSuit.Patent__r.Patent_No__c + ' - ' + patentInSuit.patent__r.Title__c ;
        }
      }
      return patentString;
    }
    
    
  }