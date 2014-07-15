public with sharing class ContentMappingTriggerHandler extends BaseTrigger {
			// Constructor
    public ContentMappingTriggerHandler()
    {
    }
    
    
    public void bulkBefore()
    {
    }
 
    public void bulkAfter()
    {
    }
 
    public void afterInsert(List<SObject> so)
    {
    	 List<Content_Mapping__c> contentMappingLst = new List<Content_Mapping__c>();
	        for(Sobject soItr : so){
	            contentMappingLst.add((Content_Mapping__c)soItr);
	        }
	        
	        ContentMappingTriggerHelperHandler contentMappingTriggerHelperHandler = new ContentMappingTriggerHelperHandler();
	        contentMappingTriggerHelperHandler.createNewTopicContentInsert(contentMappingLst); //handler class method for performing after insert functions
	        
    }
 
    public void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap)
    {
			
    }
    
    public void beforeDelete(List<SObject> so)
    {
        
    }
 
    public void beforeInsert(List<SObject> so) 
    {
	        
    }
    
    public void afterUpdate(Map<id,sObject> oldMap, Map<Id,sObject> newMap)
    {
    		Map<Id,Content_Mapping__c> contentMappingNewMap = new Map<Id,Content_Mapping__c>();
	    	
	        
	        for(sObject contentMappingItr : newMap.values()){
	            contentMappingNewMap.put(contentMappingItr.id,(Content_Mapping__c)contentMappingItr);
	        
	        }
	        Map<Id,Content_Mapping__c> contentMappingOldMap = new Map<Id,Content_Mapping__c>();
	        
	        for(sObject contentMappingItr : oldMap.values()){
	            contentMappingOldMap.put(contentMappingItr.id,(Content_Mapping__c)contentMappingItr);
	        
	        }

	        ContentMappingTriggerHelperHandler contentMapTriggerHelperHandler = new ContentMappingTriggerHelperHandler();
	        contentMapTriggerHelperHandler.updateTopicContent(contentMappingNewMap,contentMappingOldMap);//handler class method for performing after update functions
    }
    
 
    public void afterDelete(List<SObject> so)
    {
    }
 
    public void andFinally()
    {
        
    }	
}