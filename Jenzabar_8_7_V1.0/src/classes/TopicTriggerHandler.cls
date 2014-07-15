public with sharing class TopicTriggerHandler extends BaseTrigger {

	// Constructor
    public TopicTriggerHandler()
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
    	 List<Topic__c> topicLst = new List<Topic__c>();
	        for(Sobject soItr : so){
	            topicLst.add((Topic__c)soItr);
	        }
	        TopicTriggerHelperHandler TopicTriggerHelperHandler = new TopicTriggerHelperHandler();
	        TopicTriggerHelperHandler.createNewTopicContent(topicLst); //handler class method for performing after insert functions
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
    		Map<Id,Topic__c> topicNewMap = new Map<Id,Topic__c>();
	    
	        
	        for(sObject topicItr : newMap.values()){
	            topicNewMap.put(topicItr.id,(Topic__c)topicItr);
	           
	        }
	        Map<Id,Topic__c> topicOldMap = new Map<Id,Topic__c>();
	        
	        for(sObject topicItr : oldMap.values()){
	            topicOldMap.put(topicItr.id,(Topic__c)topicItr);
	           
	        }
			
			
	        TopicTriggerHelperHandler topicTriggerHelperHandler = new TopicTriggerHelperHandler();
	        topicTriggerHelperHandler.updateTopicContent(topicNewMap,topicOldMap);//handler class method for performing after update functions
		
    }
    
 
    public void afterDelete(List<SObject> so)
    {
    }
 
    public void andFinally()
    {
        
    }
}