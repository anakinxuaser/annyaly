@isTest(seeAllData=true)
public with sharing class ContactLinkControllerTest {

			 static testMethod void ContactLinkControllerTestMethod() {
			 	
			 	
			 		//create contact
        			Contact cont = new Contact(RecordTypeId ='012i0000001IUae',LastName='test');
        			insert cont;
			 	
			       	ApexPages.StandardController sc = new ApexPages.standardController(cont);
			 		insert new Contact_Link__c(Student_Id__c=cont.Id);
			 		
			 		ApexPages.CurrentPage().getparameters().put('id', cont.Id);
			 		ContactLinkController ContactLinkControllerObj=new ContactLinkController(sc);
			  		
			  		
			 		system.assertEquals(ContactLinkControllerObj.isContactLinkTable, true);
			 		
			 		PageReference pageRef=	ContactLinkControllerObj.goBack();
			 }
}