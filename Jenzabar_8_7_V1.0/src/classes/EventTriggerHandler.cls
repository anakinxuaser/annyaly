public with sharing class EventTriggerHandler extends BaseTrigger {
	
	public void EventTriggerHandler(){
		
	}
	
	public void bulkBefore()
    {
    }
 
    public void bulkAfter()
    {
    }
	 
	public void beforeInsert(List<SObject> so){
		/*list<Event__c> eventLst = new list<Event__c>();
		
		for(Sobject soItr : so){
			eventLst.add((Event__c)soItr);
		}
		EventTriggerHelperHandler.mapSourceSystemIdOnInsert(eventLst,Null);*/
    
    }
 
    public void beforeUpdate(Map<Id,SObject> oldSo, Map<Id,SObject> so){
    	/*Map<Id,Event__c> eventNewMap = new Map<Id,Event__c>();
    	Map<Id,Event__c> eventOldMap = new Map<Id,Event__c>();
    	
    	for(sObject eventItr : so.values()){
            eventNewMap.put(eventItr.id,(Event__c)eventItr);
        }
        for(sObject eventItr : oldSo.values()){
            eventOldMap.put(eventItr.id,(Event__c)eventItr);
        }
        
        EventTriggerHelperHandler.mapSourceSystemIdOnUpdate(eventNewMap,eventOldMap);*/
    	 
    }
    
    public void beforeDelete(List<SObject> so)
    {
        
    }
    public void afterInsert(List<SObject> so)
    {    
    }
 
    public void afterUpdate(Map<id,sObject> oldMap, Map<Id,sObject> newMap)
    {
        
    }
 
    public void afterDelete(List<SObject> so)
    {
    }
 
    public void andFinally()
    {
        
    }

}