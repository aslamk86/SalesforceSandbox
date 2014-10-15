public with sharing class PSTController {
	
	public String getFormattedDatetime(){
		return System.NOW().format('MM/dd/yyyy HH:mm:ss a','PST'); //Specify Time zone like IST,CST
	}
}