/* Description : This controller is utility controller for Notification model */

public with sharing class NotificationUtilityController {
     
    
    private static final string DT_DOUBLE = 'Double';
    private static final string EXTERNAL_ID = 'ExternalId';
    private static final string OBJECT_NAME = 'sObject';
    private static final string ID = 'ID';
    private static final string DT_DATETIME = 'Datetime';
    private static final string DT_BOOLEAN = 'Boolean';
    private static final string DT_Date = 'Date';
    private static final string REFERENCE = 'REFERENCE';
    private static final string NAME = 'Name';
	private static final String SOBJECT_CSNAME = 'sObject';
    private static final String INTERNAL_TYPE = 'InternalType';
    private static final String INTERNAL_ID = 'InternalId';
    private static final String SYSTEM_ID = 'SystemId';
    private static final String RECORDTYPE_ID = 'RecordTypeId';
    private static final String EXTERNALID = 'Id';
    private static final String STUB = 'Stub';
    private static final Map<String,Set<String>> requiredMap = new Map<String,Set<String>>{
        'Contact' => new Set<String>{'Name','IsEmailBounced','HasOptedOutOfEmail','HasOptedOutOfFax'},
        'Account' => new Set<String>{''}
     };
     
    public static final Set<String> objecttoExcludeforName = new Set<String>{'Contact'}; 
    public static final Set<String> excludingObject = new Set<String>{'User','Group'}; 
    public static final Set<String> fieldtoExclude = new Set<String>{'isDeleted','CreatedDate','IsDeleted','LastModifiedDate','SystemModstamp','Id','CreatedById','OwnerId','LastModifiedById'};
    private static Set<String> keyPrefixSet; 
    private static Map<String,Schema.SObjectType> describeObj;  
    private static Map<String, String> keyPrefixMap;  
    private static Map<String,Stub_Data__c> stubMap = Stub_Data__c.getAll();
    private static Map<String,Stub_sObject_Id_Mapping__c> sObjectIdMapping = Stub_sObject_Id_Mapping__c.getAll();
    private static Map<String,Id> topicStubMap = new Map<String,Id>();
    public static Set<String> objectProcessed = new Set<String>();
    public static Map<Integer,Set<String>> referenceMap = new Map<Integer,Set<String>>();
    public static integer index = 0;
    public static Map<Integer,Boolean> isAllProcessed = new Map<Integer,Boolean>();
    public static Map<String,Schema.SObjectType> globalFieldResult = Schema.getGlobalDescribe();
    
    
    
    // This method will be used for creating keyPrefix & Object Name map
    private static void init() {  
        
        describeObj = Schema.getGlobalDescribe();  
        keyPrefixMap = new Map<String, String>{};  
        keyPrefixSet = describeObj.keySet();  
        
        for(String sObj : keyPrefixSet)  
        {  
            Schema.DescribeSObjectResult dsResult =  describeObj.get(sObj).getDescribe();  
            String objName = dsResult.getName();  
            String objPrefix = dsResult.getKeyPrefix();  
            keyPrefixMap.put(objPrefix, objName);  
        }  
    }  
    
    // This method will create Queue Wrapper Container
    public static void createQueueWrapperContainer(Set<Id> pQueueIds,Map<String,WrapperQueueContainer> pQueueWrapperMap,List<Queue__c> queLst){
    	 Integer indexVal = 0; 
    	 for(Queue__c queItr :[SELECT Id,
                                     EventID__c,
                                     Attempt_Count__c,
                                     Event_Queuer_ID__c,
                                     Queue_State_ID__c,
                                     Retriever__c,
                                     TopicId__c,
                                     TopicId__r.Object_Name__c,
                                     TopicId__r.Record_Type__c,
                                     EventId__r.Id,
                                     EventId__r.Content_JSON__c,
                                     EventId__r.Event_State_ID__c,
                                     EventId__r.Source_System__c
                                     FROM Queue__c 
                                     WHERE Id IN: pQueueIds]){
    	 		
    	 	if(!String.isBlank(queItr.TopicId__c)){
    	 		pQueueWrapperMap.put(indexVal+','+queItr.id,new WrapperQueueContainer(queItr.TopicId__r.Record_Type__c,
    	 	                                                              indexVal++,
    	 	                                                              new Queue__c(id=queItr.Id,
    	 	                                                              		       Event_Queuer_ID__c = queItr.Event_Queuer_ID__c,
    	 	                                                              		       Queue_State_ID__c = queItr.Queue_State_ID__c,
    	 	                                                              		       Retriever__c = queItr.Retriever__c,
    	 	                                                              		       EventID__c = queItr.EventID__c),
 	                                                              		  new Topic__c(Id=queItr.TopicId__c,
 	                                                              		  			   Object_Name__c = queItr.TopicId__r.Object_Name__c
 	                                                              		  			    ),
 	                                                              		  new Event__c(Id = queItr.EventId__r.Id,
 	                                                              		  			Content_JSON__c = queItr.EventId__r.Content_JSON__c,
 	                                                              		  			Event_State_ID__c = queItr.EventId__r.Event_State_ID__c,
 	                                                              		  			Source_System__c = queItr.EventId__r.Source_System__c),			    
 	                                                              		  queItr.TopicId__r.Object_Name__c,
 	                                                              		  queItr.EventId__r.Source_System__c));
    	 	}
    	 	else{
    	 		queItr.Queue_State_ID__c = Label.Queue_Error;	
    	 		queItr.Retriever__c = Label.Topic_ID_is_missing;
    	 		queLst.add(queItr);
    	 	}
    
		}
    } 
    // This method will parse the Event's JSON content & store it in wrapper container.
    public static void parseJSON(Map<String,WrapperQueueContainer> pWrapper){
        
        for(String IdItr : pWrapper.keySet()){
       		pWrapper.get(IdItr).jsonContent = jsonParser(pWrapper.get(IdItr).eventRec.Content_JSON__c);
       		if(pwrapper.get(IdItr).jsonContent.containsKey(EXTERNALID)){
       			pWrapper.get(IdItr).externalId = pwrapper.get(IdItr).jsonContent.remove(EXTERNALID);
       		}
        }
     }
     
    // This method will be used to parse the Event's JSON content  
    public static Map<String,String> jsonParser(String pJsonContent){
        Map<String,String> mapJsonContent  = new Map<String,String>();
        String jsonData = pJsonContent;
        JSONParser parser = JSON.createParser(jsonData);

        while (parser.nextToken() != null) {
            
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME)
            {
            	String fieldName = parser.getCurrentName();
            	parser.nextToken();
            	String fieldValue = parser.getText();
                mapJsonContent.put(fieldName,fieldValue);
            }
        }
        
        if(!mapJsonContent.isEmpty()){
            return mapJsonContent;
        }
        
        return null;    
    }
    
    private static void stubInit(){
    	for(Topic__c topicItr : [SELECT id,
    							     Object_Name__c,
    							     Topic_Area__c
    							     FROM Topic__c
    							     WHERE Topic_Area__r.Name =: STUB]){
    		topicStubMap.put(topicItr.Object_Name__c,topicItr.Id);					     
     	}
    }
    
    // To typecast the JSON field values & return a valid sObject for operation
    public static sObject getsObjectRec(String sObjectName,Map<String,String> mapContent){
        
        Schema.SObjectType t = globalFieldResult.get(sObjectName);
        SObject sObjRec = t.newSObject();
        Schema.Describesobjectresult dsr = t.getDescribe();
        Map<String, Schema.SObjectField> acRecObjMap = dsr.fields.getMap();
      	
        if(!mapContent.isEmpty()){
            for(String str : mapContent.keySet()){
                
                if(acRecObjMap.containsKey(str)){
                    Schema.DescribeFieldResult meta1 = acRecObjMap.get(str).getDescribe();
                    
                    if(MapContent.get(str) <> null && !MapContent.get(str).equals('') && !MapContent.get(str).equals('null')){
                        if(String.valueOf(meta1.getType()) == DT_DOUBLE){
                        	sObjRec.put(str,Decimal.valueOf(String.valueOf(mapContent.get(str)).trim()));
                        }
                        
                        else if(String.valueOf(meta1.getType()) == DT_DATETIME){
                            sObjRec.put(str,Datetime.valueOf(mapContent.get(str)));
                        }
                        else if(String.valueOf(meta1.getType()) == DT_BOOLEAN){
                            sObjRec.put(str,Boolean.valueOf(mapContent.get(str)));
                        }
                        else if(String.valueOf(meta1.getType()) == DT_DATE){
                            sObjRec.put(str,Date.valueOf(mapContent.get(str)));
                        }
                        else{
                            sObjRec.put(str,String.valueOf(mapContent.get(str)));
                        }
                           
                    }
                }
            }
        }
        return sObjRec;
    }
    
    
    // This method will be used to create stub record when external record is not found for external Id
    public static void createStubRec(Map<String,String> jsonContentMap,Map<String,Boolean> refJsonContent,Map<String,String> lookupSystemIds){
        init();
        List<SObject> sObjtoInsert = new List<sObject>();
        Set<Id> sIds = new Set<Id>();
        Map<String,External_Record__c> exttoInsert = new Map<String,External_Record__c>();
        Map<String,Event__c> eventtoInsert = new Map<String,Event__c>();
                
        for(String str : refJsonContent.keySet()){
          
            String objectName = str.subString(0,str.indexOf(','));
            sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
            NotificationUtilityController.getRequiredValues(objectName,sObj);
            //sObj.put((Notification_CreateExternalRecordMapping__c.getAll().get(objectName)).sObject_External_Id_Field_API__c,str.subString(str.indexOf(',')+1,str.length()));
            sObjtoInsert.add(sObj);
        }
        
        if(!sObjtoInsert.isEmpty()){
           
           Database.saveresult[] result = Database.insert(sObjtoInsert);
            
           for(Integer i=0;i<result.size();i++){
                for(String strItr : refJsonContent.keySet()){
                        if(strItr.subString(0,strItr.indexOf(',')) == keyPrefixMap.get(String.valueOf((result[i].id)).subString(0,3))
                          && !exttoInsert.containsKey(strItr) && !sIds.contains(result[i].id)){
                            jsonContentMap.put(strItr,result[i].id);
                            
                            External_Record__c externalRec = new External_Record__c();
                            externalRec.Internal_Type__c = keyPrefixMap.get(String.valueOf((result[i].id)).subString(0,3));
                            externalRec.Internal_ID__c = result[i].Id;
                            externalRec.External_ID__c = strItr.subString(strItr.indexOf(',')+1,strItr.length());
                            externalRec.System_ID__c = lookupSystemIds.get(strItr);
                            exttoInsert.put(strItr,externalRec);
                            sIds.add(result[i].Id);
                            
                            Event__c eventRec = new Event__c();
                            eventRec.Source_System__c = lookupSystemIds.get(strItr);
                            eventRec.Topic_ID__c = sObjectIdMapping.get(strItr.subString(0,strItr.indexOf(','))).Topic_Id__c;
                            eventRec.Content_Json__c = '{'+ID+':"'+result[i].id+','
                            							  +EXTERNAL_ID+':"'+strItr.subString(strItr.indexOf(',')+1,strItr.length())+','
                            							  +'"'+OBJECT_NAME+'":"'+keyPrefixMap.get(String.valueOf((result[i].id)).subString(0,3))+'"}';
                            eventtoInsert.put(strItr,eventRec);
                            jsonContentMap.put(strItr,result[i].id);
                        }
                  }
            }
           
            if(!exttoInsert.isEmpty()){
                insert exttoInsert.values();
            }
            
            if(!eventtoInsert.isEmpty()){
                insert eventtoInsert.values();
            }
        }
    }
    
    // This method is used to create to External Record for Id Cross footing
    public static External_Record__c createExeternalRecord(String sObjectName,sObject sobjRec,String sourceSystemId,Id recordTypeId,String pExternalId){
        
        External_Record__c externalRec = new External_Record__c();
        externalRec.Internal_Type__c = sObjectName;
        externalRec.Internal_ID__c = sObjRec.Id;
        externalRec.External_ID__c = pExternalId;
        externalRec.System_ID__c = sourceSystemId;
       	externalRec.Record_Type__c = recordTypeId; 
      	
      	if(externalRec != null){
      		return externalRec;
      	}
      	return null;
    }
    
    public static Event__c createEvent(External_Record__c externalRec,String sourceSystemId){
         Event__c eventRec = new Event__c();
         eventRec.Topic__c = Label.TopicID_ExternalRecord;
         eventRec.Source_System__c = sourceSystemId;
         eventRec.Content_JSON__c = NotificationUtilityController.returnExternalJsonforEvent(externalRec.Internal_Type__c,
                                                                                                        externalRec.Internal_ID__c,
                                                                                                        externalRec.External_ID__c, 
                                                                                                        externalRec.System_ID__c,
                                                                                                        externalRec.Record_Type__c);
        
        if(externalRec != null){
      		return eventRec;
      	}
      	return null;            
    }
    
    // This method will return a string for Event's JSON content for External Record Id Crossfooting
    public static String returnExternalJsonforEvent(String internalType,String internalId,String pExternalId,Id systemId,String recordTypeId){
         return '{"'+INTERNAL_TYPE+'":'+ internalType+'",'+'\n'+
                 +'"'+INTERNAL_ID+'":"'+ internalId+'",'+'\n'+
                 +'"'+EXTERNAL_ID+'":"'+ pExternalId+'",'+'\n'+
                 +'"'+SYSTEM_ID+'":"'+ systemId+'",'+'\n'+
                 +'"'+RECORDTYPE_ID+'":"'+ recordTypeId+'"}';
    }
    
    
    public static sObject getRequiredValues(String sObjectName,sObject sObjRec){
        
        Schema.Describesobjectresult dsr = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        Map<String, Schema.SObjectField> acRecObjMap = dsr.fields.getMap();
        
        for(Schema.Sobjectfield fieldItr : acRecObjMap.values()){
            Schema.Describefieldresult fieldResult = fieldItr.getDescribe();
         	
         		if(!fieldResult.isNillable()  && !String.valueOf(fieldResult.getType().Name()).equalsIgnoreCase(DT_BOOLEAN) && !String.valueOf(fieldResult.getType().Name()).equalsIgnoreCase(REFERENCE) &&   
                !fieldResult.isAutoNumber() && !fieldtoExclude.contains(fieldResult.getName()) && 
                (String.valueOf(fieldResult.getSobjectField()) == NAME || objecttoExcludeforName.contains(sObjectName)) &&
                !requiredMap.get(sObjectName).contains(String.valueOf(fieldResult.getName()))){
                
                if(String.valueOf(fieldResult.getType()) == DT_DOUBLE){
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get(SOBJECT_CSNAME).Double__c);
                }
                
                else if(String.valueOf(fieldResult.getType()) == DT_DATETIME){
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get(SOBJECT_CSNAME).Datetime__c);
                }
                else if(String.valueOf(fieldResult.getType()) == DT_DATE){
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get(SOBJECT_CSNAME).Date__c);
                }
                else{
                    sObjRec.put(String.valueOf(fieldItr),stubMap.get(SOBJECT_CSNAME).Text__c);
                }
            }
            else if(!fieldResult.isNillable() && fieldResult.getType().name() == REFERENCE && !fieldtoExclude.contains(String.valueOf(fieldResult.getName()))){
            	System.debug('fieldResult.getName()==='+fieldResult.getName());
            	sObjRec.put(String.valueOf(fieldItr),sObjectIdMapping.get(String.valueOf(fieldResult.getReferenceTo())).Stub_Id__c);
            }
        
        }
        
        return sObjRec;
    }
}