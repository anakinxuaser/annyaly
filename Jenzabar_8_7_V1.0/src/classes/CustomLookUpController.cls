public with sharing class CustomLookUpController {
      public Reference__c referenceObj {get;set;} // new account to create
	  public List<Reference__c> results{get;set;} // search results
	  public string searchString{get;set;} // search keyword
	  public string searchString1{get;set;} 
	  public string ObjName{get;set;}
	  public string fieldName{get;set;}
	  public String refRecTyp;
	  public boolean searchPanelRender{get; set;}
	  public CustomLookUpController() {
		  	referenceObj = new Reference__c();
		  	// get the current search string
		  	searchString = System.currentPageReference().getParameters().get('lksrch');
		  	ObjName = System.currentPageReference().getParameters().get('objname');
		  	fieldName = System.currentPageReference().getParameters().get('fapi');
		  	runSearch();  
	  }
	  // performs the keyword search
	  public PageReference search() {
	    	runSearch();
	    	return null;
	  }
	  // prepare the query and issue the search command
	  private void runSearch() {
	  	   // TODO prepare query string for complex serarches & prevent injections
	       results = performSearch(searchString);               
	  } 
	  // run the search and return the records found. 
	  private List<Reference__c> performSearch(string searchString) {
	  	
	  	  getRefMappings();
	      String soql = 'select id, name from Reference__c';
	      if(refRecTyp != null && refRecTyp != ''){
	      	searchPanelRender = true;
		      if(searchString != null && searchString != ''){
		           soql = soql +  ' where name LIKE \'%' + searchString +'%\''+' and RecordType.Name=\''+refRecTyp+'\'';
		      }else{
		      	   soql = soql +  ' where RecordType.Name=\''+refRecTyp+'\'';
		      }
		      system.debug('soql is******'+soql);
			  soql = soql + ' limit 25';
		      return database.query(soql);
		      }else{
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No records found');
        		ApexPages.addMessage(myMsg);
        		searchPanelRender = false;
	      	}
	      return null;
	  }
	  
	  // searches for the Record Type from Reference_Mapping__c records 
	  private void getRefMappings(){
	  	refRecTyp = '';
	  	String soqlRm = 'Select id, name, Reference_Record_Type__c, Object_Name__c, API_Name__c From Reference_Mapping__c';
	    if(ObjName != null && ObjName != '' && fieldName != null && fieldName != ''){
	    	soqlRm += ' where Object_Name__c=\''+ObjName+'\'' +'and API_Name__c=\''+fieldName+'\'';
	    }
	    List<Reference_Mapping__c> rm  = new List<Reference_Mapping__c>();
	    rm = database.query(soqlRm);

	    if(rm != null && rm.size() > 0){

	    	for(Reference_Mapping__c ref:rm){
	    		if(ref.Reference_Record_Type__c != null){
	    		refRecTyp = ref.Reference_Record_Type__c;
	    		}
	    	}
	    }

	  }
	  // used by the visualforce page to send the link to the right dom element
	  public string getFormTag() { 
	    	return System.currentPageReference().getParameters().get('frm');
	  }
	  // used by the visualforce page to send the link to the right dom element for the text box
	  public string getTextBox() {
	        return System.currentPageReference().getParameters().get('txt');
	  }

}