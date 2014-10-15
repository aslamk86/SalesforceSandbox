/***********************************************************************************
 * Name             : MultiSelectComponentController
 * Created By       : Neeraj G.(Appirio Offshore)
 * Created Date     : 19 Mar, 2012.
 * Purpose          : Component can be used to create custom picklist
 *                    This Component can be used to display Custom MultiSelect Picklist
										  Two Attributes are required
										  - AvailableList : This contains all available options. 
										  - ChosenList : This contains selected options. 
***********************************************************************************/
public with sharing class MultiSelectComponentController {
  public List<SelectOption> options{ get; set;} //= new List<SelectOption> ();
  public List<SelectOption> selectedOptions{get;set;} //= new List<SelectOption>();
  public SelectOption available{get;set;}
  public SelectOption chosen{get;set;}
  public List<String> selected{get;set;}
  public List<String> deselected{get;set;}
  
  public MultiSelectComponentController() {
  	available = new SelectOption('','<b>Available</b>');//new SelectOption('', '<optgroup label=\'Available\'>');
    available.setEscapeItem(false);
  	chosen = new SelectOption('','Selected');
  }
  
  public void selecting() {
	 for(String toSelect: selected) {
	  Integer i = 0;
	  While(i < options.size()) {
	  if(options[i].getvalue() == toSelect) {
	   selectedOptions.add(new SelectOption(toSelect,toSelect));
	   options.remove(i);
	  }              
	  i++;
	  }
	 }
	}
	 
	public void deselecting() { 
	 for(String toDeselect: deselected) {            
	  Integer i = 0;
	  While(i<selectedOptions.size()) {
	  if(selectedOptions[i].getvalue()==toDeselect) {
	   options.add(new SelectOption(toDeselect, toDeselect));
	   selectedOptions.remove(i);
	  }                    
	  i++;
	  }
	 }  
	}
}