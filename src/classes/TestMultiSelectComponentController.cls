/**
  This Component can be used to display Custom MultiSelect Picklist
  Two Attributes are required
	- AvailableList : This contains all available options. 
	- ChosenList : This contains selected options. 
 */
@isTest
private class TestMultiSelectComponentController {

  static testMethod void myUnitTest() {
    List<SelectOption> lstAllOptions = new List<SelectOption> ();
    lstAllOptions.add(new SelectOption('1', '1'));
    lstAllOptions.add(new SelectOption('2', '2'));
    lstAllOptions.add(new SelectOption('3', '3'));
    lstAllOptions.add(new SelectOption('4', '4'));
    
    List<SelectOption> lstChosenOptions = new List<SelectOption> ();
    MultiSelectComponentController controller = new MultiSelectComponentController();
    controller.options = lstAllOptions;
    controller.selectedOptions = lstChosenOptions;
    
    Test.startTest();
    
    controller.selected = new List<String> ();
    controller.selected.add('1');
    controller.selected.add('3');
    controller.selecting();
    System.assertEquals(2, controller.selectedOptions.size());
    
    controller.deSelected = new List<String> ();
    controller.deSelected.add('1');
    controller.deSelecting();
    System.assertEquals(1, controller.selectedOptions.size());
    
    Test.stopTest();
  }
}