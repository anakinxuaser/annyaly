@isTest
public with sharing class ContentMappingTriggerHelperHandlerTest {
			
			 static testMethod void testCaseTrigger() {
   		 	 			ContentMappingTriggerHelperHandler ContentMappingTriggerHelperHandler=new ContentMappingTriggerHelperHandler();
   						set<Id> contentMappingIdSet=new set<Id>();
   						List<Content_Mapping__c> contentMappingUpdateLst= new List<Content_Mapping__c>();
   						List<Content_Mapping__c> contentMappingInsertLst= new List<Content_Mapping__c>();
   						List<Topic__c> topicInsertLst= new List<Topic__c>();
   						List<Topic__c> topicNewInsertLst= new List<Topic__c>();
   						
   						
   						
   						insert new TriggerSetting__c(Name = 'ContentMapping',Handler_Names__c='ContentMappingTriggerHandler');
   						insert new TriggerSetting__c(Name = 'Topic',Handler_Names__c='TopicTriggerHandler');
   			
   						for(Integer i=0;i<3;i++) {
  						Topic__c topicObj=new  Topic__c(Object_Name__c='Case');		 
  						topicInsertLst.add(topicObj);			
  						}
  						
   						insert topicInsertLst;
   		
  						Content_Mapping__c contentMappingNewObj=new Content_Mapping__c(Source_ID__c='a0Yi0000002sWei',LocalObject__c='Case');	
  						insert contentMappingNewObj;
  			
  						List<Topic_Content__c> topicContentLst=[SELECT Id 
  																FROM Topic_Content__c 
  																WHERE Id != null];
  							
  						system.assertEquals(topicContentLst.size(),3);
  			
  						for(Integer i=0;i<2;i++) {
  								Topic__c topicNewObj=new  Topic__c(Object_Name__c='Contact');		 
  								topicNewInsertLst.add(topicNewObj);			
  						}
  						insert topicNewInsertLst;
  						
  						for(Content_Mapping__c contentMappingObj:[SELECT Id,LocalObject__c 
  								 								  FROM Content_Mapping__c 
  								   								  WHERE LocalObject__c='Case']){
  									contentMappingObj.LocalObject__c='Contact';
  									contentMappingUpdateLst.add(contentMappingObj);
  						}
  			
  						update contentMappingUpdateLst;
  			
  					for(Content_Mapping__c contentMappingNewObject:contentMappingUpdateLst){
  								contentMappingIdSet.add(contentMappingNewObject.Id);	
  			
  					}
  			List<Topic_Content__c> topicContentNewLst=[SELECT Id 
  													   FROM Topic_Content__c 
  													   WHERE Content_Mapping__c IN: contentMappingIdSet];
  													   
 			system.assertEquals(topicContentNewLst.size(),2);
  		 }	
	
	

}