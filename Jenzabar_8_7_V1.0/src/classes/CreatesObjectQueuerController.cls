/*
 * Description : The Queuer Class  will insert the sObject by performing the creating Queue wrapper Container,
 *				 Parsing the JSON Content, Content Mapping & External Record Mapping.   
 */

global class CreatesObjectQueuerController{
    
    private static final String BLANK = '';
    private static final String NEWLINE = '\n';
    
    /* This method will be perform all the operations such as creating Queue wrapper Container,
 	   Parsing the JSON Content, Content Mapping & External Record Mapping. */
    public static void execute(Set<Id> pQueueIds){
        Map<String,WrapperQueueContainer> queueWrapperMap = new Map<String,WrapperQueueContainer>();
        Set<Id> topicIds = new Set<Id>();
        Set<Id> systemIds = new Set<Id>();
        List<Queue__c> queLstToUpdate = new List<Queue__c>();
        Map<String,List<sObject>> externalRecEventLst = new Map<String,List<sObject>>();
        List<External_Record__c> externalRecLst = new List<External_Record__c>();
        List<Event__c> eventLst = new List<Event__c>();
        Map<Integer,sObject> mapsObject = new Map<Integer,sObject>();
        Map<Integer,Event__c> mapeventsObject = new Map<Integer,Event__c>();
        Map<Integer,Map<String,Boolean>> mapStatus = new Map<Integer,Map<String,Boolean>>();
        
        // Create Wrapper Container with required data
        NotificationUtilityController.createQueueWrapperContainer(pQueueIds,queueWrapperMap,queLstToUpdate);
        
        for(WrapperQueueContainer wrapItr : queueWrapperMap.values()){
        	if(wrapItr.topicRec != null){
        		topicIds.add(wrapItr.topicRec.Id);
        	}
        	if(wrapItr.systemid != null){
        		systemIds.add(wrapItr.systemid);
        	}
        	
        }
        
        // Parse the JSON Content
        NotificationUtilityController.parseJSON(queueWrapperMap);
        List<sObject> sObjLst = new List<sObject>();
        
        // Map the JSON Content, Convert the JSON field to Local fields
        ContentMappingHandler.contentMapping(topicIds,systemIds,queueWrapperMap);
        for(WrapperQueueContainer wrapItr : queueWrapperMap.values()){
            mapsObject.put(wrapItr.index,wrapItr.sObjRec);
            mapeventsObject.put(wrapItr.index,wrapItr.eventRec);
        }
        
        
        if(!mapsObject.isEmpty()){
            System.debug('mapsObject==='+mapsObject);
            Database.saveResult[] saveResult = Database.insert(mapsObject.values(),false);
            for(Integer j=0;j<saveResult.size();j++) {
                if(saveResult[j].isSuccess()) {
                    mapStatus.put(j,new Map<String,Boolean>{saveResult[j].id => true});
                }
                else {
                    String strErrorMessage = BLANK;
                    for(Database.Error err : saveResult[j].getErrors()) {
                    	strErrorMessage += err.getMessage() + NEWLINE;
                    }
                    mapStatus.put(j,new Map<String,Boolean>{strErrorMessage => false});
                }
            }
        }
        
        for(WrapperQueueContainer wrapItr : queueWrapperMap.values()){
            
            if(mapStatus.containsKey(wrapItr.index)){
                System.debug(wrapItr);
                for(String str : mapStatus.get(wrapItr.index).keySet()){
                	wrapItr.queueRec.Retriever__c = String.isBlank(wrapItr.queueRec.Retriever__c) ? str : wrapItr.queueRec.Retriever__c + str ;
                    wrapItr.queueRec.Queue_State_ID__c = mapStatus.get(wrapItr.index).get(str)==true? Label.Queue_Complete : Label.Queue_Error ;
                    if(wrapItr.queueRec.Queue_State_ID__c == Label.Queue_Complete){
                    	External_Record__c exterRec = new External_Record__c();
                    	exterRec = NotificationUtilityController.createExeternalRecord(wrapItr.objectName, wrapItr.sobjRec, wrapItr.systemid,wrapItr.recordTypeId,wrapItr.externalId);
                    	if(exterRec != null){
                    		externalRecLst.add(exterRec);
                    	}
                    	
                    	if(exterRec != null){
                    		Event__c eventRec = new Event__c();
                    		eventRec = NotificationUtilityController.createEvent(exterRec,wrapItr.systemid);
                    		if(eventRec != null) eventLst.add(eventRec);
                    	}
                    	
                    }
                }
                queLstToUpdate.add(wrapItr.queueRec);
            }
        }
        
        if(!queLstToUpdate.isEmpty()){
            update queLstToUpdate;
        }
        
        if(!externalRecLst.isEmpty()){
        	System.debug('external Lst==='+externalRecLst);
            insert externalRecLst;
        }
        
        if(!eventLst.isEmpty()){
        	System.debug('Event Lst==='+eventLst);
            insert eventLst;
        }
    }
}