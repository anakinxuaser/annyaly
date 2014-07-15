public with sharing class ContactTriggerHelperHandler {
    
    public static final string ID = 'Id';
    public static final string SALESFORCE_SYSTEM = 'Salesforce';
    public List<Event__c> commonFieldsUpdateEvents(Map<Id,Contact> oldMap,Map<Id,Contact> newMap){
    	
        Map<String, Schema.SObjectField> ContactFieldsMap = Schema.SObjectType.Contact.fields.getMap();
        List<String> commonFields = new List<String>();
        List<Event__c> eventList = new List<Event__c>();
        String contactJson,FieldJson;
        
        List<Topic__c> commonFieldUpdateTopic = [Select id,Name from Topic__c where Name__c =: Label.Contact_Common_Fields_Update];
        List<System__c> systemList = [Select id,Name__c from System__c where Name__c =: SALESFORCE_SYSTEM];
        system.debug('commonFieldUpdateTopic-------'+commonFieldUpdateTopic);
        if(!String.isEmpty(Contact_Common_Fields_Setting__c.getAll().get('Contact').Common_Fields__c)){
        	 String cFields = Contact_Common_Fields_Setting__c.getAll().get('Contact').Common_Fields__c;
        	 if(cFields != null){
        	 	  cFields = cFields.toLowerCase();
                  commonFields = (cFields.replaceAll( '\\s+', '')).split(',');
        	 }
        }
        system.debug('commonFields-----'+commonFields);
        for(Contact conItr : newMap.values()){
        	 
        	 FieldJson = contactJson = '';
        	 contactJson = '{"'+ID+'":"'+ conItr.id+'",';
        	
             for(String strItr : commonFields){
                 if(ContactFieldsMap.containsKey(strItr.toLowerCase())){
                    if(oldMap.get(conItr.id) != null && NewMap.get(conItr.id) != null && oldMap.get(conItr.id).get(strItr) != NewMap.get(conItr.id).get(strItr)){
                    	 FieldJson = FieldJson +  createJsonContent(strItr,String.valueOf(NewMap.get(conItr.id).get(strItr)));
                    }
                 }
                 else{
                     conItr.addError('Invalid Field Name '+ strItr + ' in Contact Common Fields Setting.');
                 }
             }
             if(FieldJson == ''){
            	 contactJson = '';
             }
             else{
            	 contactJson = contactJson + FieldJson; 
            	 contactJson = contactJson.subString(0,contactJson.length()-1);
            	 contactJson = contactJson + '}';
            	 Event__c eventInst = new Event__c();
            	 eventInst.Topic__c = commonFieldUpdateTopic != null ? commonFieldUpdateTopic[0].id : null;
            	 eventInst.Source_System__c = systemList != null ? systemList[0].id : null; 
            	 eventInst.Content_JSON__c = contactJson;
            	 eventList.add(eventInst);
             }
         }
        return eventList;
    } 
    private String createJsonContent(String fieldAPI, String fieldValue){
    	 return '"'+fieldAPI+'":"'+ fieldValue+'",';
    }
}