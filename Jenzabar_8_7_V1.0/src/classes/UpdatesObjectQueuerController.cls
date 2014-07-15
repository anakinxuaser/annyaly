public with sharing class UpdatesObjectQueuerController {

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
		 Map<Integer,sObject> mapsObject = new Map<Integer,sObject>();
		 Map<Integer,Event__c> mapeventsObject = new Map<Integer,Event__c>();
		 Map<Integer,Map<String,Boolean>> mapStatus = new Map<Integer,Map<String,Boolean>>();

        // Create Wrapper Container with required data
        NotificationUtilityController.createQueueWrapperContainer(pQueueIds,queueWrapperMap);
        
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
            Database.saveResult[] saveResult = Database.update(mapsObject.values(),false);
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
                }
                queLstToUpdate.add(wrapItr.queueRec);
            }
        }
        
        if(!queLstToUpdate.isEmpty()){
            update queLstToUpdate;
        }
	}
}






























    /*
    public static void execute(Id queueId){
        String sObjectName = '';
        String strTopicId = '';
        String jsonData = '';
        String systemId = '';
        Map<String,List<Content_Mapping__c>> mapTopicRelatedContentMapping = 
                                                            new Map<String,List<Content_Mapping__c>>();
        Map<String,String> mapContent = new Map<String,String>();
        Map<String,String> mapJsonContent  = new Map<String,String>();
        Map<String,String> mapFields  = new Map<String,String>();
        List<Topic__c> topicObjLst = new List<Topic__c>();
        
        List<Queue__c> queObjLst = [SELECT Id,
                                           EventID__c,
                                           Attempt_Count__c,
                                           Queue_State_ID__c,
                                           Retriever__c,
                                           TopicId__c
                                           FROM Queue__c 
                                           WHERE Id=: queueId LIMIT 1];
                                           
        if(!queObjLst.isEmpty()){                                   
            topicObjLst = [SELECT Id,
                                  Object_Name__c
                                  FROM Topic__c 
                                  WHERE Id=: queObjLst[0].TopicId__c];
            
        }
        
        if(!queObjLst.isEmpty()){                                   
            for(Event__c eventItr : [SELECT id,
                                            Event_State_ID__c,
                                            Topic_ID__c,
                                            Content_JSON__c, 
                                            SourceSystem_ID__c 
                                            FROM Event__c 
                                            WHERE Id=: queObjLst[0].Eventid__c LIMIT 1]){
                      
            
                strTopicId = eventItr.Topic_ID__c;
                jsonData = eventItr.Content_JSON__c;
                systemId = eventItr.SourceSystem_ID__c;
            }
        }
        System.debug(jsonData);
        if(!topicObjLst.isEmpty()){
            sObjectName = topicObjLst[0].Object_Name__c;
        }
        
        mapJsonContent = NotificationUtilityController.jsonParser(jsonData);
        //mapContent =  ContentMappingHandler.contentMapping(strTopicId,mapJsonContent,sObjectName,systemId);
        
        sObject sObjRec = NotificationUtilityController.getsObjectRec(sObjectName,mapContent);
       
        Database.saveResult result;
        try{
            result = Database.update(sObjRec);
           
            queObjLst[0].Retriever__c = result.getId();
            queObjLst[0].Queue_State_ID__c = 'Complete';  
        }
        catch(Exception e){
            queObjLst[0].Retriever__c = String.valueOf(e.getMessage());
            queObjLst[0].Queue_State_ID__c = 'Error';
        }
        finally{
            queObjLst[0].Attempt_Count__c = queObjLst[0].Attempt_Count__c != null ? queObjLst[0].Attempt_Count__c+1 : 1; 
            Database.saveResult queueResult = Database.update( queObjLst[0]);
        }
    } */