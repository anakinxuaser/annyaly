/*
 *  Description : A class that will be used for mapping the JSON content with salesforce's fields.
 */
public with sharing class ContentMappingHandler{
    
    private static final String Id = 'Id';
    private static final String RECORDTYPEID = 'RecordTypeId'; 
    private static final String CONTENTMAPPINGERROR = 'Content Mapping is not present.';
    // This wrapper class will hold all type of fields those are required for content mapping.
    public class FieldContentWrapper{
        public String fieldValue;
        public String datatype;
        public String referenceTo;
       
        public FieldContentWrapper(String pfieldValue,String pDatatype,String pReference){
            fieldValue = pfieldValue;
            datatype = pDatatype;
            referenceTo = pReference;
        }
    }
    
    // This method will be used for Content mapping 
    public static void contentMapping(Set<Id> topicIds,Set<Id> systemIds,Map<String,WrapperQueueContainer> pWrapper){
        
        List<sObject> sObjectToforDML = new List<sObject>();
        Map<String,Map<String,FieldContentWrapper>> contentMappingMap = new Map<String,Map<String,FieldContentWrapper>>();
        Map<String,String> lookupMap = new Map<String,String>();
        Map<String,String> lookupSystemId = new Map<String,String>();
        Map<String,String> stringMap;
        Set<String> queueIds = new Set<String>();
        Set<String> objectReferenced = new Set<String>();
        if(!pWrapper.isEmpty()){
        	queueIds.addAll(pWrapper.keySet());
        }
        
        for(Content_Mapping__c objContentMappingRec : [SELECT Id,
                                                              JSONField__c,
                                                              JSONObject__c,
                                                              Local_Field__c,
                                                              LocalObject__c,
                                                              Source_ID__c 
                                                       FROM Content_Mapping__c 
                                                       WHERE  Source_ID__c IN:systemIds
                                                       AND Id IN (SELECT Content_Mapping__c
                                                                            FROM Topic_Content__c
                                                                            WHERE Topic__c IN:topicIds)])
        {   
        	if(! String.isBlank(objContentMappingRec.JSONField__c) && 
               ! String.isBlank(objContentMappingRec.LocalObject__c) &&
               ! String.isBlank(objContentMappingRec.Local_Field__c)){
                if(!contentMappingMap.containsKey(objContentMappingRec.LocalObject__c)){
                	contentMappingMap.put(objContentMappingRec.LocalObject__c,new Map<String,FieldContentWrapper>{objContentMappingRec.JSONField__c =>parseField(objContentMappingRec.Local_Field__c)});
                }
                else{
                	contentMappingMap.get(objContentMappingRec.LocalObject__c).put(objContentMappingRec.JSONField__c,parseField(objContentMappingRec.Local_Field__c));
                }
            }     
        }
       
        if(!contentMappingMap.isEmpty()){
	        for(String queueIdItr : queueIds){
	        	if(pWrapper.containsKey(queueIdItr)){
	            	WrapperQueueContainer wrapItr = pWrapper.get(queueIdItr);
	            	if(contentMappingMap.containsKey(wrapItr.objectName)){
		            	for(String strItr : wrapItr.jsonContent.keySet()){
		                	
		                	wrapItr.jsonData.put(contentMappingMap.get(wrapItr.objectName).get(strItr).fieldValue,new FieldContentWrapper(wrapItr.jsonContent.get(strItr),contentMappingMap.get(wrapItr.objectName).get(strItr).datatype,contentMappingMap.get(wrapItr.objectName).get(strItr).referenceTo));
	                    
	                    	if(contentMappingMap.get(wrapItr.objectName).get(strItr).fieldValue != null && !String.isBlank(contentMappingMap.get(wrapItr.objectName).get(strItr).datatype) &&
	                        	String.valueOf(contentMappingMap.get(wrapItr.objectName).get(strItr).datatype).equalsIgnoreCase(Label.Content_Mapping_Lookup)
	                        )
	                        {
		                        lookupMap.put(contentMappingMap.get(wrapItr.objectName).get(strItr).referenceTo+','+wrapItr.jsonContent.get(strItr),wrapItr.jsonContent.get(strItr));
		                        objectReferenced.add(contentMappingMap.get(wrapItr.objectName).get(strItr).referenceTo);
		                        lookupSystemId.put(contentMappingMap.get(wrapItr.objectName).get(strItr).referenceTo+','+wrapItr.jsonContent.get(strItr),wrapItr.systemId);
	                    	}
	                 	}
	            	}
	        	}
	        }
        }
        else{
	  		for(WrapperQueueContainer wrapItr : pWrapper.values()){
            	if(wrapItr.queueRec != null){
	            	wrapItr.queueRec.Retriever__c = String.isBlank(wrapItr.queueRec.Retriever__c) ? CONTENTMAPPINGERROR  : wrapItr.queueRec.Retriever__c + CONTENTMAPPINGERROR ;
	                wrapItr.queueRec.Queue_State_ID__c = Label.Queue_Error;
            	}
        	}
        }
        lookupMap = ExternalRecMappingHandler.getExternalRecordFieldValues(lookupMap,lookupSystemId,objectReferenced);
       
        for(WrapperQueueContainer wrapItr : pWrapper.values()){
	   		stringMap = new Map<String,String>();
	   		for(String str : wrapItr.jsonData.keySet()){
				
				if(String.valueOf(wrapItr.jsonData.get(str).datatype) == Label.Content_Mapping_Lookup){
			    	 wrapItr.jsonData.get(str).fieldValue = lookupMap.get(wrapItr.jsonData.get(str).referenceTo+','+wrapItr.jsonData.get(str).fieldValue);
			    }
			    stringMap.put(str,wrapItr.jsonData.get(str).fieldValue);
			    if(!String.isBlank(wrapItr.recordTypeId)){
			    	stringMap.put(RECORDTYPEID,wrapItr.recordTypeId);
			    }
			}
			wrapItr.sObjRec = NotificationUtilityController.getsObjectRec(wrapItr.objectName,stringMap);
		}
    }
		
    // This method will parse the JSON content & will create wrapper with all required details
    public static FieldContentWrapper parseField(String localFieldJSON){
        
        JSONParser parser = JSON.createParser(localFieldJSON);
        FieldContentWrapper wrapperObj;
        Map<String,String> wrapperMap = new Map<String,String>();
        String fieldName,fieldValue;
        String reference = '';
        
        while(parser.nextToken() != null){
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                    fieldName = parser.getText();
                    parser.nextToken();
                    fieldValue = parser.getText();
                    wrapperMap.put(fieldName,fieldValue);
            }
        }
          
        if(!wrapperMap.containsKey(Label.Content_Mappng_ReferenceTo)){
            wrapperMap.put(Label.Content_Mappng_ReferenceTo,'');
        }
        
       
        wrapperObj = new FieldContentWrapper(wrapperMap.get(Label.Content_Mapping_FieldName),wrapperMap.get(Label.Content_Mapping_Datatype),wrapperMap.get(Label.Content_Mappng_ReferenceTo));
        return wrapperObj;
    }
}