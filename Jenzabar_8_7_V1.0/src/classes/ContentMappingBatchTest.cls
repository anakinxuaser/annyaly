@isTest
public with sharing class ContentMappingBatchTest {

	static testMethod void contentMappingBatchTestMethod (){
		 	
		insert new TriggerSetting__c(Name = 'ContentMapping',Handler_Names__c='ContentMappingTriggerHandler');		
		
		System__c systemObject= new System__c(Name__c='S-0009');
		insert systemObject;
		
		Content_Mapping__c contentMappingNewObj=new Content_Mapping__c(Status__c=false,Local_Field__c='Program_Section__c',LocalObject__c='Academic_Record__c',JSONObject__c='Academic Record',JSONField__c='SectionID',Source_ID__c=systemObject.Id);
  		insert contentMappingNewObj;	
  		
  		String localFieldValue='{"REFERENCETO":"(EDU_Product__c)","FIELDNAME":"Program_Section__c","DATATYPE":"LOOKUP"}';
  		
  		
				
   		Test.StartTest(); 
   		ContentMappingBatch Batch = new ContentMappingBatch();
	    Id batchprocessId = Database.executeBatch(Batch);
   		Test.StopTest();
		
		Content_Mapping__c ContentMapObject=[Select Id,Local_Field__c from Content_Mapping__c ];
  		system.assertEquals(ContentMapObject.Local_Field__c, localFieldValue);
	
	}
}