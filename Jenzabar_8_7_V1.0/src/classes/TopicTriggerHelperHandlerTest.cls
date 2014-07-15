@isTest
public with sharing class TopicTriggerHelperHandlerTest {
			
   static testMethod void testCaseTrigger() {
   		 				TopicTriggerHelperHandler TopicTriggerHelperHandler=new TopicTriggerHelperHandler();
   			set<Id> topicIdSet=new set<Id>();
   			List<Topic__c> topicUpdateLst= new List<Topic__c>();
   			List<Topic__c> topicInsertLst= new List<Topic__c>();
   			List<Content_Mapping__c> contentMapInsertLst= new List<Content_Mapping__c>();
   			List<Content_Mapping__c> contentMapNewInsertLst= new List<Content_Mapping__c>();
   			insert new TriggerSetting__c(Name = 'Topic',Handler_Names__c='TopicTriggerHandler');
   			insert new TriggerSetting__c(Name = 'ContentMapping',Handler_Names__c='ContentMappingTriggerHandler');
   			
   			
   			for(Integer i=0;i<3;i++) {
  						Content_Mapping__c contentMapObj=new  Content_Mapping__c(Source_ID__c='a0Yi0000002sWei',LocalObject__c='Account');		 
  						contentMapInsertLst.add(contentMapObj);			
  			}
   			insert contentMapInsertLst;
   		
  			Topic__c topicNewObj=new Topic__c(Object_Name__c='Account');	
  			insert topicNewObj;
  			List<Topic_Content__c> topicContentLst=[SELECT Id 
  													FROM Topic_Content__c 
  													WHERE Id != null];
  													
  			system.assertEquals(topicContentLst.size(),3);
  			
  			for(Integer i=0;i<2;i++) {
  						Content_Mapping__c contentMapObj=new  Content_Mapping__c(Source_ID__c='a0Yi0000002sWei',LocalObject__c='Case');		 
  						contentMapNewInsertLst.add(contentMapObj);			
  			}
  			insert contentMapNewInsertLst;
  			
  			
  			for(Topic__c topicObj:[SELECT Id,Object_Name__c 
  								   FROM Topic__c 
  								   WHERE Object_Name__c='Account']){
  			topicObj.Object_Name__c='Case';
  			topicUpdateLst.add(topicObj);
  			}
  			
  			update topicUpdateLst;
  			
  			for(Topic__c topicNewObject:topicUpdateLst){
  					topicIdSet.add(topicNewObject.Id);	
  			
  			}
  			List<Topic_Content__c> topicContentNewLst=[SELECT Id 
  													   FROM Topic_Content__c 
  													   WHERE Topic__c IN: topicIdSet];
 			system.assertEquals(topicContentNewLst.size(),2);
  		 }
}