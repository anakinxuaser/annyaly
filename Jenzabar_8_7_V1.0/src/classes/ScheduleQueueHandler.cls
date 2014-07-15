/*
 * Description : This class with be used as controller class for ScheduleQueue scheduler
 */
public with sharing class ScheduleQueueHandler {

    // This method will be used to schedule queue with status new & will instantiate the queuer class.
    public static void scheduleQueue(){
        Map<Id,Queue__c> mapEventQueue = new Map<Id,Queue__c>();
        Map<Id,Topic__c> topicMap = new Map<Id,Topic__c>(); 
        Map<Id,Set<Id>> eventQueuerMap = new  Map<Id,Set<Id>>();
        List<Queue__c> queLsttoUpdate = new List<Queue__c>();
        
        for(Queue__c queItr : [SELECT EventID__c, 
                                      Event_Queuer_ID__c,
                                      Queue_State_ID__c,
                                      TopicId__c
                                      FROM Queue__c 
                                      WHERE Queue_State_ID__c =: Label.Event_New]){
                                        
            if(eventQueuerMap.containsKey(queItr.Event_Queuer_ID__c)){
                eventQueuerMap.get(queItr.Event_Queuer_ID__c).add(queItr.id);
            }       
            else{
                eventQueuerMap.put(queItr.Event_Queuer_ID__c,new Set<Id>{queItr.id});
            }
            mapEventQueue.put(queItr.Event_Queuer_ID__c,queItr);         
            queItr.Queue_State_ID__c = Label.Queue_In_Progress;
            queLsttoUpdate.add(queItr);
        }
        
        if(!queLsttoUpdate.isEmpty()){
            update queLsttoUpdate;
        }
       
        for(Event_Queuer__c eventQueuerItr : [SELECT Id,
                                                     Queuer__c,
                                                     Topic_ID__r.Scope__c
                                                     FROM Event_Queuer__c 
                                                     WHERE Id IN : eventQueuerMap.keySet()]){
            
            
                                          
            System.Type typeObj = System.Type.forName(eventQueuerItr.Queuer__c);
            Object obj = typeObj.newInstance();
            
            if((obj instanceof BaseInterface) && typeObj != null){
                BaseInterface bInf = (BaseInterface)obj;
                if( bInf != null){
                    bInf.execute(mapEventQueue.get(eventQueuerItr.id).Eventid__c);
                }
            }
            
            else if((obj instanceof QueuerInterface) && typeObj != null){
                QueuerInterface bInf = (QueuerInterface)obj;
                
                bInf.batchExecute(eventQueuerMap.get(eventQueuerItr.id),Integer.valueOf(eventQueuerItr.Topic_ID__r.Scope__c));
            }
        }
    }


}