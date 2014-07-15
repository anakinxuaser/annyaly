public with sharing class EventTriggerHelperHandler {

	//Map the external topic Id to the local Source System Id on Event object.
	public static void mapSourceSystemIdOnInsert(List<Event__c> pEventLst,Map<String,Event__c> afterUpdateEventMap){
		list<External_Record__c> extRecords = new list<External_Record__c>();
		list<External_Record__c> extTopicRecords = new list<External_Record__c>();
		map<Id,Id> internalIdMap = new map<Id,Id>();
		map<Id,Id> internalIdTopicMap = new map<Id,Id>();
		map<Id,string> sourceSystemIdMap = new map<Id,string>();
		map<Id,string> topicIdMap = new map<Id,string>();
		map<String,string>internalSystemIdMap = new map<string,string>();
		
		if(pEventLst != null && pEventLst.size()>0){
			for(Event__c event: pEventLst){
				if(event.SourceSystem_ID__c <> null && 
				   event.SourceSystem_ID__c <>''){
					
					sourceSystemIdMap.put(event.Id,event.SourceSystem_ID__c);
				}
				if(event.Topic_ID__c <> null &&
				   event.Topic_ID__c <> ''){
					
					topicIdMap.put(event.Id,event.Topic_ID__c);
				}	
			}
		}
		else if(afterUpdateEventMap != null && afterUpdateEventMap.size()>0){
			for(Event__c event: afterUpdateEventMap.Values()){
				if(event.SourceSystem_ID__c <> null && 
				   event.SourceSystem_ID__c <>''){
					
					sourceSystemIdMap.put(event.Id,event.SourceSystem_ID__c);
				}
				if(event.Topic_ID__c <> null &&
				   event.Topic_ID__c <> ''){
					
					topicIdMap.put(event.Id,event.Topic_ID__c);
				}	
			}
			
		}
		
		if(sourceSystemIdMap.size() >0){
			extRecords = [select Internal_ID__c,System_ID__c
                          from External_Record__c 
                          where External_ID__c 
                          IN :sourceSystemIdMap.values() 
                          and Internal_Type__c = 'System__c'];
			
		}
		
		if(extRecords.size()>0){
			for(External_Record__c extRecItr :extRecords){
        	 internalIdMap.put(extRecItr.Id,extRecItr.Internal_ID__c);
        	 //internalSystemIdMap.put(extRecItr.External_ID__c,extRecItr.System_ID__c);
        	}
		}
		
		if(topicIdMap.size()>0){
			extTopicRecords = [select Internal_ID__c
                          	   from External_Record__c
                               where External_ID__c 
                               IN :topicIdMap.values() 
                               and Internal_Type__c = 'Topic__c'
                               and System_ID__c IN: internalIdMap.values()];
       	system.debug('Values of extTopicRecords...'+extTopicRecords);
			
		}
		
		if(extTopicRecords.size()>0){
			for(External_Record__c extRecItr :extTopicRecords){
        	 internalIdTopicMap.put(extRecItr.Id,extRecItr.Internal_ID__c);
        	}
			
		}
		
		for(System__c sysItr : [Select Id
							    from System__c 
							    where Id 
							    IN:internalIdMap.values()]){
    		if(pEventLst != null && pEventLst.size()>0){
	    		for(Event__c eventItr: pEventLst){
	    			eventItr.Source_System__c = sysItr.Id;
	    		}
    		}
    		
    		else if(afterUpdateEventMap != null && afterUpdateEventMap.size()>0){
    			for(Event__c eventItr: afterUpdateEventMap.values()){
	    			eventItr.Source_System__c = sysItr.Id;
	    		}
    		}
							    	
	   }
	    
	    for(Topic__c topicItr: [select Id from Topic__c where Id IN:internalIdTopicMap.values()]){
	    	
	    	if(pEventLst != null && pEventLst.size()>0){
		    	for(Event__c eventItr :pEventLst){
		    		eventItr.Topic__c = topicItr.Id;
		    	}
	    	}
	    	else if(afterUpdateEventMap != null && afterUpdateEventMap.size()>0){
    			for(Event__c eventItr: afterUpdateEventMap.values()){
	    			eventItr.Topic__c = topicItr.Id;
	    		}
    		}
	    	
	    }
	}//mapSourceSystemIdOnInsert ends
	
	//Map the source system Id to Topic and systen id, when there is any update call
	public static void mapSourceSystemIdOnUpdate(map<Id,Event__c> pNewMapValues,
												 map<Id,Event__c> pOldMapValues){
	 	
	 	Map<String,Event__c> eventSysTopicAfterUpdateMap = new Map<String,Event__c>();

 		For(Event__c eventItr: pNewMapValues.Values()){
 			 
 			 if(eventItr.SourceSystem_ID__c != null && eventItr.SourceSystem_ID__c != '' &&
 			    eventItr.SourceSystem_ID__c != pOldMapValues.get(eventItr.Id).SourceSystem_ID__c){
 			    	
 			 	eventSysTopicAfterUpdateMap.put(eventItr.SourceSystem_ID__c,eventItr);
 			 }
 			 
 			 if(eventItr.Topic_ID__c != null && eventItr.Topic_ID__c != '' &&
 			    eventItr.Topic_ID__c != pOldMapValues.get(eventItr.Id).Topic_ID__c){
 			    	
 			 	eventSysTopicAfterUpdateMap.put(eventItr.Topic_ID__c,eventItr);
 			 }
 			 
 		}//for ends
 		
 		EventTriggerHelperHandler.mapSourceSystemIdOnInsert(null,eventSysTopicAfterUpdateMap);
 	}//mapSourceSystemIdOnUpdate ends
	
	
}//EventTriggerHelperHandler ends