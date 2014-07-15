/** 
 *  Description : Handler class for ScheduleNewEvents scheduler. 
 *
 *  Revision History:
 *
 *  Version          Author              Date                Description
 *  1.0              Vishal Prasad       19/06/2014          Initial Draft
 */
public with sharing class ScheduleEventHandler  {
    /**
     * Method to fetch all new events and group them by retriever type.
     * Based on retriever type it will call batch class and pass list of EventBean and Map of System.
     * EventBean is a wrapper class consists of Event object and parsed Retriever type and Retriever Link.
     */
     public static void fetchNewEvent(){
        
          Set<Id> sourceSystemIds = new Set<Id>();
          List<EventBean> eventBeanList = new List<EventBean>();   
          List<Event__c> tempEventList = new List<Event__c>();     
          Map<String,String> externalSystemMap = new Map<String,String>(); 
          List<Event__c> newEventList = [Select id,Name,
                                                Event_State_ID__c,
                                                Topic_ID__c ,
                                                Retriever_Info__c,
                                                SourceSystem_ID__c,
                                                Content_JSON__c,
                                                Source_System__c,
                                                Topic__c
                                                FROM Event__c 
                                                WHERE Event_State_ID__c =: Label.Event_New];
          for(Event__c eventInst : newEventList){
                eventInst.Event_State_ID__c = Label.Retrieval_In_Progress_State;
                sourceSystemIds.add(eventInst.Source_System__c);
          }
          Update newEventList;
          Map<Id,System__c> systemMap = new Map<Id,System__c>([Select id,
                                                                      Name,
                                                                      (Select LocalObject__c,JSONObject__c,Local_Field__c,JSONField__c FROM Content_Mappings__r),
                                                                      (Select Id, Name, Bucket_Name__c,System__c, Service__c, Service__r.Name, URL__c, Credentials__c, Token__c, Subscriber__c From Credentials__r)                                                         
                                                                      from System__c where id IN : sourceSystemIds]);
                                                                      
          List<Service__c> serviceList = [select id,Name,Class__c,Transaction_Scope__c from Service__c];
                                                              
          Map<String,Service__c> serviceMap = new Map<String,Service__c>();
          for(Service__c sInst : serviceList){
                serviceMap.put(sInst.Name.toLowerCase(),sInst);
          }
          for(Event__c eInst : newEventList){
                if(eInst.Content_JSON__c == null || eInst.Content_JSON__c == ''){
                    String rtype,rlink,jType,jLink;
                    EventBean eventBeanObj = new EventBean();
                    eventBeanObj.eventObj = eInst;
                    Map<String, String> InfoRetrievalMap = retrieverMap(eInst.Retriever_Info__c);//Parsing retreval info JSON content
                   
                    if(InfoRetrievalMap != null && !InfoRetrievalMap.isEmpty()){                        
                         System__c systemObj = systemMap.get(eInst.Source_System__c);
                         if(systemObj != null){
                             for(Content_Mapping__c contentMapInst : systemObj.Content_Mappings__r){
                                  if(contentMapInst.Local_Field__c != null && contentMapInst.Local_Field__c.equalsIgnoreCase(Label.Content_Mapping_Type)){
                                        jType = contentMapInst.JSONField__c;
                                  }
                                  else if(contentMapInst.Local_Field__c != null && contentMapInst.Local_Field__c.equalsIgnoreCase(Label.Content_Mapping_Location)){
                                        jLink = contentMapInst.JSONField__c;
                                  }       
                             }
                             if(jType != null){
                                  rtype = InfoRetrievalMap.get(jType.toLowerCase());
                             }
                             else{
                                  eventBeanObj.eventObj.Content_JSON__c = Label.Type_Not_Found;
                             }
                             if(jLink != null){
                                  rlink = InfoRetrievalMap.get(jLink.toLowerCase());
                             }
                             else{
                                  eventBeanObj.eventObj.Content_JSON__c = Label.Location_Not_Found;
                             }     
                             eventBeanObj.retriverType = rtype;
                             eventBeanObj.link = rlink;
                             eventBeanList.add(eventBeanObj);   
                         }
                         else{
                              eInst.Content_JSON__c = Label.External_Mapping_Not_Found ;
                              eInst.Event_State_ID__c = Label.Error_State;
                              tempEventList.add(eInst);
                         } 
                    }
                    else{
                    	 eInst.Content_JSON__c = Label.Retrieval_Info_Invalid;
                         eInst.Event_State_ID__c = Label.Error_State;
                         tempEventList.add(eInst);
                    }
                }
          } 
          update tempEventList;
          Map<String, List<EventBean>> retriverTypeEventMap = new Map<String, List<EventBean>>();
          
          for(EventBean beanInst : eventBeanList){
                if(retriverTypeEventMap != null && retriverTypeEventMap.containsKey(beanInst.retriverType)){
                      retriverTypeEventMap.get(beanInst.retriverType).add(beanInst);
                }
                else{
                     retriverTypeEventMap.put(beanInst.retriverType,new EventBean[]{beanInst}); 
                }
          }
          for(String rType : retriverTypeEventMap.keySet()){
                if(serviceMap != null){
                	Service__c serviceObj;
                	if(rType != null){
                    	 serviceObj = serviceMap.get(rType.toLowerCase());
                	}
                    if(serviceObj != null && serviceObj.Class__c != null && serviceObj.Class__c != ''){
                        System.Type typeObj = System.Type.forName(serviceObj.Class__c);
                        if(typeObj != null){
                            Object obj = typeObj.newInstance();
                            EventInterface eInterface = (EventInterface)obj;
                            if(eInterface != null){
                                //Pass serice object to retriver to set batch scope and handle when a system is linked with multiple services
                                eInterface.newEventBatchExecute(retriverTypeEventMap.get(rType),serviceObj,systemMap); 
                            }
                        }
                    }
                    else{
                         List<Event__c> eList = new List<Event__c>();
                         for(EventBean eb : retriverTypeEventMap.get(rType)){
                              if(eb.eventObj.Content_JSON__c == null || eb.eventObj.Content_JSON__c == ''){
                                   eb.eventObj.Content_JSON__c = Label.Service_Not_Found;
                              }
                              eb.eventObj.Event_State_ID__c = Label.Error_State;
                              eList.add(eb.eventObj);
                         }
                         update eList; 
                    }
                }
          }
    }                
    /**
     * Method to fetch list of ready events and group them by TopicId.
     * Based on TopicId, it will call queuer and pass list of ready event.
     */ 
    @future
    public static void createReadyQueue(){
        Map<Id,Event__c> eventMapToUpdate = new Map<Id,Event__c>();
        Map<Id,List<Event__c>> eventMap = new Map<Id,List<Event__c>>();
        List<Event__c> eventLsttoUpdate = new List<Event__c>();
        Set<String> topicIds = new Set<String>();
        
        for(Event__c eventItr : [SELECT Id,
                                        Event_State_ID__c,
                                        Topic__c,
                                        Retriever_Info__c,
                                        Content_JSON__c,
                                        Source_System__c
                                        FROM Event__c
                                        WHERE Event_State_ID__c =: Label.Event_Ready
                                       ]){
            topicIds.add(eventItr.Topic__c);
            if(!String.isEmpty(eventItr.Content_JSON__c)){
                    if(eventMap.containsKey(eventItr.Topic__c)){
                        eventMap.get(eventItr.Topic__c).add(eventItr);
                    }
                    else{
                        eventMap.put(eventItr.Topic__c,new List<Event__c>{eventItr});
                    }
             }
             eventItr.Event_State_ID__c = System.label.InProgress_State;
             eventLsttoUpdate.add(eventItr);
         }
         CreateQueue.createQueuewithHandler(eventMap);
         if(!eventLsttoUpdate.isEmpty()){
            Database.saveResult[] result = Database.update(eventLsttoUpdate);
         }
    }
    /**
     * Method to parse JSON content available in retrieverInfo field of event record.
     * Argument: RetrieverInfo field value.
     * Return: Map of field name and field value of JSON content.
     */
    private static Map<String, String> retrieverMap(String retInfo){
        Map<String, String> retrievedValMap = new Map<String, String>();
        try{
            if(retInfo != null && retInfo != ''){
                String retrieverInfo = '\''+retInfo+'\'';
                JSONParser parser = JSON.createParser(retInfo);
                parser.nextToken();
                while (parser.nextToken() != null){
                    parser.nextValue();
                    String fieldName = parser.getCurrentName();         
                    String fieldVal = parser.getText();
                    if(fieldName != null && fieldVal != null){
                        retrievedValMap.put(fieldName.toLowerCase(), fieldVal);
                    }
                }
            }
        }
        catch(Exception e){
             retrievedValMap = new Map<String, String>();
        }
        return retrievedValMap;
    }
}