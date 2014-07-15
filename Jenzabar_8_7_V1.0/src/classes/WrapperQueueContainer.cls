/*
 * Description : This class is Wrapper class for all Notification Queuer which will hold all the information required for 
 *				 operation such as JSON Parsing, Content Mapping, External Record Mapping & Type Casting the Content.   
 */

global with sharing class WrapperQueueContainer{

	public queue__c queueRec;
	public event__c eventRec;
	public topic__c topicRec;
	public Map<String,String> jsonContent = new Map<String,String>();
	public Map<String,ContentMappingHandler.FieldContentWrapper> jsonData = new Map<String,ContentMappingHandler.FieldContentWrapper>();
	public sObject sObjRec;
	public String objectName;
	public String systemid;
	public Integer index;
	public String recordTypeId;
	public String externalId;
	public WrapperQueueContainer(String pRecordTypeId,Integer pIndex,Queue__c pQueue,Topic__c pTopic,Event__c pEvent,String pObjectName,String pSystemId){
		index = pIndex;
		queueRec = pQueue;
		topicRec = pTopic;
		eventRec = pEvent;
		objectName = pObjectName;
		systemId = pSystemId;
		recordTypeId = pRecordTypeId;
	}
}